#!/usr/bin/env swift
// Papercuts: friction agents hit in this repo, filed the moment it happens
// and fixed in review.
//
//   scripts/papercuts.swift add "<what you hit, what would have prevented it>"
//       [--tag <area>] [--severity minor|major|blocker]
//       [--evidence "<failing command, error line, run id>" | --evidence - (stdin)]
//   scripts/papercuts.swift again <id>                      you hit an open cut again
//   scripts/papercuts.swift resolve <id>... --note "<fix>"  the fix landed (or noise, or a duplicate)
//   scripts/papercuts.swift list [--all]                    open cuts, worst first; --all adds resolved
//   scripts/papercuts.swift show <id>...                    a cut with its evidence
//
// The log is .papercuts.jsonl at the repo root: append-only, committed, and
// `merge=union` in .gitattributes so parallel branches merge cleanly. Ids
// accept any unique prefix. See AGENTS.md "Papercuts".
import CryptoKit
import Foundation

let environment = ProcessInfo.processInfo.environment
let root = URL(fileURLWithPath: #filePath).standardizedFileURL
    .deletingLastPathComponent().deletingLastPathComponent()
let file = environment["PAPERCUTS_FILE"].map { URL(fileURLWithPath: $0) }
    ?? root.appendingPathComponent(".papercuts.jsonl")
let severities = ["blocker", "major", "minor"]
// Enough for a command, its error and a run id; a whole log would bloat
// every reviewer's context.
let maxEvidenceBytes = 4096

/// One line of the log: a `cut`, or an `again` / `resolve` event on one.
/// `ev` makes each event line unique, so a line a union merge duplicated is
/// told apart from a real repeat.
struct Entry: Codable {
    var kind: String
    var id: String
    var ev: String?
    var at: String
    var agent: String
    var severity: String?
    var tags: [String]?
    var text: String?
    var evidence: String?
    var note: String?
}

struct Cut {
    var entry: Entry
    var hits = 1
    var resolution: String?
}

func fail(_ message: String) -> Never {
    FileHandle.standardError.write(Data((message + "\n").utf8))
    exit(2)
}

let agent = environment["PAPERCUTS_AGENT"]
    ?? (environment["CLAUDECODE"] != nil ? "claude"
        : environment.keys.contains { $0.hasPrefix("CODEX_") } ? "codex"
        : "human")

func now() -> String {
    let formatter = ISO8601DateFormatter()
    return formatter.string(from: Date())
}

func randomHex(bytes: Int) -> String {
    (0..<bytes).map { _ in String(format: "%02x", UInt8.random(in: 0...255)) }.joined()
}

// MARK: - Arguments

/// Node-style `parseArgs`: `--tag` repeats, `--all` is a flag, `--` ends options.
struct Arguments {
    var positionals: [String] = []
    var tags: [String] = []
    var severity = "minor"
    var note: String?
    var evidence: String?
    var all = false

    init(_ args: [String]) {
        var rest = args[...]
        while let arg = rest.popFirst() {
            if arg == "--" {
                positionals += rest
                break
            }
            guard arg.hasPrefix("--") else {
                positionals.append(arg)
                continue
            }
            let parts = arg.dropFirst(2).split(separator: "=", maxSplits: 1).map(String.init)
            let name = parts[0]
            if name == "all" {
                all = true
                continue
            }
            guard ["tag", "severity", "note", "evidence"].contains(name) else {
                fail("Unknown option '--\(name)'. To pass text that starts with '-', put it after '--'.")
            }
            guard let value = parts.count > 1 ? parts[1] : rest.popFirst() else {
                fail("Option '--\(name)' needs a value.")
            }
            switch name {
            case "tag": tags.append(value)
            case "severity": severity = value
            case "note": note = value
            default: evidence = value
            }
        }
    }
}

let command = CommandLine.arguments.dropFirst().first
let arguments = Arguments(Array(CommandLine.arguments.dropFirst(2)))

// MARK: - Log

/// Every cut in the log with its later events folded in. A line a union merge
/// duplicated counts once.
func cuts() -> [Cut] {
    guard let text = try? String(contentsOf: file, encoding: .utf8) else { return [] }
    var byID: [String: Cut] = [:]
    var order: [String] = []
    var seenEvents = Set<String>()
    for (index, line) in text.split(separator: "\n", omittingEmptySubsequences: false).enumerated() {
        guard !line.trimmingCharacters(in: .whitespaces).isEmpty else { continue }
        guard let entry = try? JSONDecoder().decode(Entry.self, from: Data(line.utf8)) else {
            FileHandle.standardError.write(Data("\(file.lastPathComponent):\(index + 1): not JSON, skipped\n".utf8))
            continue
        }
        if entry.kind == "cut" {
            if byID[entry.id] == nil {
                byID[entry.id] = Cut(entry: entry)
                order.append(entry.id)
            }
            continue
        }
        guard seenEvents.insert(entry.ev ?? "").inserted else { continue }
        if entry.kind == "again" { byID[entry.id]?.hits += 1 }
        if entry.kind == "resolve" { byID[entry.id]?.resolution = entry.note }
    }
    return order.compactMap { byID[$0] }
}

func find(_ all: [Cut], _ prefix: String) -> Cut {
    let full = prefix.hasPrefix("pc_") ? prefix : "pc_\(prefix)"
    let matches = all.filter { $0.entry.id.hasPrefix(full) }
    if matches.count == 1 { return matches[0] }
    fail(matches.isEmpty
        ? "No papercut \"\(prefix)\"."
        : "\"\(prefix)\" matches \(matches.count) papercuts; use more of the id.")
}

/// Ids for `again`/`resolve`/`show`, all checked before anything is written so
/// a typo can't half-apply.
func named(_ all: [Cut]) -> [Cut] {
    if arguments.positionals.isEmpty {
        fail("Name the papercut id(s): scripts/papercuts.swift \(command ?? "") <id>...")
    }
    return arguments.positionals.map { find(all, $0) }
}

func append(_ entry: Entry) {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
    guard let json = try? encoder.encode(entry) else { fail("Couldn't encode the entry.") }
    // A hand edit can drop the final newline; appending onto it would corrupt
    // both lines.
    let existing = (try? Data(contentsOf: file)) ?? Data()
    let unterminated = !existing.isEmpty && existing.last != UInt8(ascii: "\n")
    let line = (unterminated ? "\n" : "") + String(decoding: json, as: UTF8.self) + "\n"
    if FileManager.default.fileExists(atPath: file.path) {
        guard let handle = try? FileHandle(forWritingTo: file) else { fail("Can't write \(file.path).") }
        handle.seekToEndOfFile()
        handle.write(Data(line.utf8))
        handle.closeFile()
    } else if !FileManager.default.createFile(atPath: file.path, contents: Data(line.utf8)) {
        fail("Can't create \(file.path).")
    }
}

func event(kind: String, id: String, note: String? = nil) -> Entry {
    Entry(kind: kind, id: id, ev: randomHex(bytes: 4), at: now(), agent: agent, note: note)
}

func format(_ cut: Cut) -> String {
    let entry = cut.entry
    let hits = cut.hits > 1 ? " ×\(cut.hits)" : ""
    let tags = entry.tags.map { $0.isEmpty ? "" : " [\($0.joined(separator: ", "))]" } ?? ""
    let more = entry.evidence != nil ? " +evidence" : ""
    let done = cut.resolution.map { "\n    resolved: \($0)" } ?? ""
    let severity = entry.severity ?? "minor"
    return "\(entry.id)  \(severity)\(hits)\(tags)  \(entry.text ?? "")  (\(entry.agent), \(entry.at.prefix(10)))\(more)\(done)"
}

/// `--evidence -` reads stdin, so a multi-line error needs no shell quoting.
func evidence() -> String? {
    let raw = arguments.evidence == "-"
        ? String(decoding: FileHandle.standardInput.readDataToEndOfFile(), as: UTF8.self)
        : arguments.evidence
    guard let trimmed = raw?.trimmingCharacters(in: .whitespacesAndNewlines), !trimmed.isEmpty else {
        return nil
    }
    let bytes = trimmed.utf8.count
    if bytes > maxEvidenceBytes {
        fail("Evidence is \(bytes) bytes (max \(maxEvidenceBytes)): quote the failing lines, not the whole output.")
    }
    return trimmed
}

// MARK: - Commands

switch command {
case "add":
    let text = arguments.positionals.joined(separator: " ")
        .split(whereSeparator: \.isWhitespace).joined(separator: " ")
    if text.isEmpty {
        fail("Say what you hit: scripts/papercuts.swift add \"<friction, and what would have prevented it>\"")
    }
    if !severities.contains(arguments.severity) {
        fail("--severity is one of \(severities.joined(separator: ", ")).")
    }
    let at = now()
    let hash = SHA256.hash(data: Data("\(at)\n\(text)".utf8))
    let id = "pc_" + hash.map { String(format: "%02x", $0) }.joined().prefix(8)
    let tags = arguments.tags
        .map { $0.trimmingCharacters(in: .whitespaces).lowercased() }
        .filter { !$0.isEmpty }
    append(Entry(
        kind: "cut", id: id, at: at, agent: agent, severity: arguments.severity,
        tags: tags, text: text, evidence: evidence()
    ))
    print("Filed \(id). Carry on with your task.")
case "again":
    let hit = named(cuts())
    if let done = hit.first(where: { $0.resolution != nil }) {
        fail("\(done.entry.id) was resolved (\(done.resolution!)). If it's back, file a new cut that says so.")
    }
    for cut in hit { append(event(kind: "again", id: cut.entry.id)) }
    print("Counted. Carry on with your task.")
case "resolve":
    guard let note = arguments.note?.trimmingCharacters(in: .whitespacesAndNewlines), !note.isEmpty else {
        fail("Say what fixed it: --note \"<commit, PR, or why it was noise>\"")
    }
    let fixed = named(cuts())
    for cut in fixed { append(event(kind: "resolve", id: cut.entry.id, note: note)) }
    print("Resolved \(fixed.count).")
case "list":
    func rank(_ cut: Cut) -> Int { severities.firstIndex(of: cut.entry.severity ?? "minor") ?? 2 }
    let shown = cuts()
        .filter { arguments.all || $0.resolution == nil }
        .sorted {
            if rank($0) != rank($1) { return rank($0) < rank($1) }
            if $0.hits != $1.hits { return $0.hits > $1.hits }
            return $0.entry.at > $1.entry.at
        }
    print(shown.isEmpty ? "No open papercuts." : shown.map(format).joined(separator: "\n"))
case "show":
    for cut in named(cuts()) {
        let evidence = cut.entry.evidence.map {
            "\n  evidence:\n" + $0.split(separator: "\n", omittingEmptySubsequences: false)
                .map { "    \($0)" }.joined(separator: "\n")
        } ?? ""
        print(format(cut) + evidence)
    }
default:
    fail("Usage: scripts/papercuts.swift add|again|resolve|list|show (see the top of the script)")
}
