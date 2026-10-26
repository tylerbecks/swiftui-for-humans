#!/usr/bin/env python3
"""Lint Swift files for outdated SwiftUI APIs and a few HIG smells.

Rules come from corrections.yaml next to this file, plus built-in HIG checks.
Standard library only, so it runs anywhere Python 3.9+ does.

    check-swift.sh [paths...]          lint files or folders (default: the current folder)
    check-swift.sh --json [paths...]   print findings as JSON
    check-swift.sh --target "iOS 17"   skip corrections whose fix needs a newer OS
    check-swift.sh --min-severity warning
    check-swift.sh --list              print the rules
    check-swift.sh --self-test         check every rule against its own examples

Output: path:line: id — message. Exit status 1 when anything is found, 2 on bad input.
Silence a line with a comment on it or on the line above:
    // check-swift:ignore            (every rule)
    // check-swift:ignore any-view   (one or more ids, comma separated)
"""

from __future__ import annotations

import argparse
import json
import os
import re
import sys
from dataclasses import dataclass, field
from pathlib import Path

HERE = Path(__file__).resolve().parent
DEFAULT_RULES = HERE / "corrections.yaml"
SEVERITIES = {"info": 0, "warning": 1, "error": 2}
SKIP_DIRS = {".git", ".build", "build", "DerivedData", "Pods", "Carthage", "checkouts", "node_modules", ".swiftpm"}
REQUIRED = ("id", "old", "new", "brief", "why", "min_os", "regex", "example_old", "example_new")


# --------------------------------------------------------------------------- YAML subset

def _unquote(raw: str) -> str:
    raw = raw.strip()
    if len(raw) >= 2 and raw[0] == raw[-1] == "'":
        return raw[1:-1].replace("''", "'")
    if len(raw) >= 2 and raw[0] == raw[-1] == '"':
        return json.loads(raw)
    return raw


def load_rules(path: Path) -> list[dict]:
    """Read the YAML subset used by corrections.yaml: a list of flat maps whose values
    are plain scalars, quoted strings, or `|` blocks."""
    items: list[dict] = []
    current: dict | None = None
    lines = path.read_text(encoding="utf-8").splitlines()
    i = 0
    while i < len(lines):
        line = lines[i]
        stripped = line.strip()
        if not stripped or stripped.startswith("#"):
            i += 1
            continue
        m = re.match(r"^(\s*)(- )?([A-Za-z_][\w-]*):(?:\s(.*))?$", line)
        if not m:
            raise ValueError(f"{path.name}:{i + 1}: can't parse: {line!r}")
        indent, dash, key, value = len(m.group(1)), m.group(2), m.group(3), (m.group(4) or "").strip()
        if dash:
            current = {}
            items.append(current)
            indent += 2
        if current is None:
            raise ValueError(f"{path.name}:{i + 1}: key outside a list item")
        if key in current:
            raise ValueError(f"{path.name}:{i + 1}: duplicate key {key!r}")
        if value == "|":
            block: list[str] = []
            i += 1
            while i < len(lines) and (not lines[i].strip() or len(lines[i]) - len(lines[i].lstrip()) > indent):
                block.append(lines[i])
                i += 1
            while block and not block[-1].strip():
                block.pop()
            margin = min((len(b) - len(b.lstrip()) for b in block if b.strip()), default=0)
            current[key] = "\n".join(b[margin:] for b in block) + "\n"
            continue
        current[key] = _unquote(value)
        i += 1
    return items


# --------------------------------------------------------------------------- source prep

def strip_code(src: str) -> str:
    """Blank comments and string contents (keeping quotes, newlines, and interpolated
    code) so rules only see code. Line and column positions stay the same."""
    out = list(src)
    n = len(src)

    def blank(a: int, b: int) -> None:
        for k in range(a, min(b, n)):
            if out[k] != "\n":
                out[k] = " "

    def scan_code(i: int, in_interpolation: bool) -> int:
        depth = 0
        while i < n:
            c = src[i]
            if src.startswith("//", i):
                j = src.find("\n", i)
                j = n if j < 0 else j
                blank(i, j)
                i = j
            elif src.startswith("/*", i):
                j, level = i + 2, 1
                while j < n and level:
                    if src.startswith("/*", j):
                        level, j = level + 1, j + 2
                    elif src.startswith("*/", j):
                        level, j = level - 1, j + 2
                    else:
                        j += 1
                blank(i, j)
                i = j
            elif c == '"' or (c == "#" and re.match(r'#+"', src[i:i + 8])):
                i = scan_string(i)
            elif in_interpolation and c == "(":
                depth += 1
                i += 1
            elif in_interpolation and c == ")":
                if depth == 0:
                    return i + 1
                depth -= 1
                i += 1
            else:
                i += 1
        return i

    def scan_string(i: int) -> int:
        hashes = 0
        while src[i] == "#":
            hashes += 1
            i += 1
        triple = src.startswith('"""', i)
        close = ('"""' if triple else '"') + "#" * hashes
        i += 3 if triple else 1
        escape = "\\" + "#" * hashes
        while i < n:
            if src.startswith(close, i):
                return i + len(close)
            if src.startswith(escape, i):
                after = i + len(escape)
                if after < n and src[after] == "(":
                    i = scan_code(after + 1, True)
                    continue
                blank(i, after + 1)
                i = after + 1
                continue
            if not triple and src[i] == "\n":
                return i
            blank(i, i + 1)
            i += 1
        return i

    scan_code(0, False)
    return "".join(out)


IGNORE_RE = re.compile(r"//\s*check-swift:ignore(?:\s+([\w,\s-]+))?")


def ignored_ids(raw_lines: list[str], lineno: int) -> set[str] | None:
    """Ids silenced on this line (or the line above). '*' means all; None means none."""
    found: set[str] = set()
    for k in (lineno - 1, lineno - 2):
        if 0 <= k < len(raw_lines):
            m = IGNORE_RE.search(raw_lines[k])
            if m:
                ids = [x.strip() for x in (m.group(1) or "").replace(",", " ").split()]
                found.update(ids or ["*"])
    return found or None


# --------------------------------------------------------------------------- findings

@dataclass
class Finding:
    path: str
    line: int
    column: int
    id: str
    severity: str
    message: str
    fix: str = ""

    def text(self) -> str:
        return f"{self.path}:{self.line}: {self.id} — {self.message}"


@dataclass
class Rule:
    id: str
    severity: str
    message: str
    fix: str
    regex: re.Pattern
    multiline: bool = False
    file_requires: re.Pattern | None = None
    unless_near: re.Pattern | None = None
    min_os: dict = field(default_factory=dict)


def parse_min_os(text: str) -> dict:
    return {m.group(1).lower(): float(m.group(2)) for m in re.finditer(r"\b(iOS|macOS)\s+(\d+(?:\.\d+)?)", text)}


def build_rules(entries: list[dict]) -> list[Rule]:
    rules = []
    for e in entries:
        rules.append(Rule(
            id=e["id"],
            severity=e.get("severity", "warning"),
            message=f"{e['why']} Use instead: {e['new']}",
            fix=e["new"],
            regex=re.compile(e["regex"], re.MULTILINE),
            multiline=e.get("multiline", "false").lower() == "true",
            file_requires=re.compile(e["file_requires"]) if e.get("file_requires") else None,
            unless_near=re.compile(e["unless_near"]) if e.get("unless_near") else None,
            min_os=parse_min_os(e.get("min_os", "")),
        ))
    return rules


def line_of(text: str, pos: int) -> tuple[int, int]:
    line = text.count("\n", 0, pos) + 1
    col = pos - (text.rfind("\n", 0, pos) + 1) + 1
    return line, col


# HIG smells -------------------------------------------------------------------

PROMINENT_RE = re.compile(r"\.(?:borderedProminent|glassProminent)\b")
FIXED_FONT_RE = re.compile(r"\.font\s*\(\s*(?:Font)?\.system\s*\(\s*size\s*:|\bFont\.system\s*\(\s*size\s*:|\.custom\s*\([^\n]*\bfixedSize\s*:")
TAP_GESTURE_RE = re.compile(r"\.onTapGesture\s*(?:\(\s*(?:count\s*:\s*1\s*)?\))?\s*\{")
BUTTON_RE = re.compile(r"\bButton\s*(?=[({])")


def _balanced(text: str, i: int, open_c: str, close_c: str) -> int:
    depth = 0
    while i < len(text):
        if text[i] == open_c:
            depth += 1
        elif text[i] == close_c:
            depth -= 1
            if depth == 0:
                return i + 1
        i += 1
    return len(text)


def _skip_space(code: str, i: int) -> int:
    while i < len(code) and code[i] in " \t\n":
        i += 1
    return i


def _button_parts(code: str, start: int) -> tuple[int, bool, str]:
    """For a Button call at start, return (end of call, has a title, label code)."""
    i = _skip_space(code, start + len("Button"))
    args, has_title = None, False
    if i < len(code) and code[i] == "(":
        args_end = _balanced(code, i, "(", ")")
        args = code[i + 1:args_end - 1]
        has_title = bool(re.match(r'\s*(?:"|Text\s*\(|LocalizedStringKey|LocalizedStringResource)', args)) \
            or bool(re.match(r"\s*[A-Za-z_][\w.]*\s*,\s*(?:systemImage|image|role|action)\s*:", args)) \
            or bool(re.search(r"\b(?:systemImage|image|titleKey)\s*:", args))
        i = args_end
    closures: list[tuple[str | None, str]] = []
    while True:
        j = _skip_space(code, i)
        name = None
        m = re.match(r"(\w+)\s*:\s*(?=\{)", code[j:])
        if m and closures:
            name, j = m.group(1), j + m.end()
        if j < len(code) and code[j] == "{":
            k = _balanced(code, j, "{", "}")
            closures.append((name, code[j + 1:k - 1]))
            i = k
            continue
        break
    label = ""
    if args is not None:
        m = re.search(r"\blabel\s*:\s*\{", args)
        if m:
            k = _balanced(args, m.end() - 1, "{", "}")
            label = args[m.end():k - 1]
    if not label:
        named = [body for name, body in closures if name == "label"]
        if named:
            label = named[0]
        elif args is not None and closures:
            label = closures[0][1]  # Button(action: f) { label }
    return i, has_title, label


def _is_image_only(label: str) -> bool:
    """True when the label is one Image call plus its modifiers and nothing else."""
    statements = [s.strip() for s in re.split(r"[\n;]", label) if s.strip()]
    if not statements or not re.match(r"Image\s*\(", statements[0]):
        return False
    depth = 0
    for n, s in enumerate(statements):
        if n and depth == 0 and not s.startswith((".", ")", "}")):
            return False
        depth += s.count("(") + s.count("{") - s.count(")") - s.count("}")
    return True


def hig_findings(path: str, code: str) -> list[Finding]:
    found: list[Finding] = []
    # More than one prominent button style in a file.
    hits = list(PROMINENT_RE.finditer(code))
    for m in hits[1:]:
        line, col = line_of(code, m.start())
        found.append(Finding(path, line, col, "hig-multiple-prominent", "warning",
                             f"{len(hits)} prominent button styles in this file. If they share a screen, keep one "
                             "prominent action and make the others .bordered or plain so the main one stands out.",
                             "one .borderedProminent / .glassProminent per screen"))
    for m in FIXED_FONT_RE.finditer(code):
        line, col = line_of(code, m.start())
        found.append(Finding(path, line, col, "hig-fixed-font-size", "warning",
                             "fixed point size ignores Dynamic Type. Use a text style (.body, .headline, .largeTitle), "
                             "or Font.custom(_:size:relativeTo:) / @ScaledMetric when you need a custom size.",
                             ".font(.title) or @ScaledMetric"))
    for m in BUTTON_RE.finditer(code):
        call_end, has_title, label = _button_parts(code, m.start())
        if has_title or not _is_image_only(label) or re.search(r"accessibilityLabel|accessibilityHidden", label):
            continue
        # Modifiers chained right after the button may add the label.
        tail = code[call_end:call_end + 600]
        chain = re.match(r"(?:\s*\.\w+\s*(?:\([^\n]*\))?(?:\s*\{[^\n]*\})?)*", tail)
        if chain and re.search(r"accessibilityLabel", chain.group(0)):
            continue
        line, col = line_of(code, m.start())
        found.append(Finding(path, line, col, "hig-icon-button-label", "warning",
                             "icon-only Button with no text for VoiceOver. Use Button(\"Title\", systemImage:) "
                             "(add .labelStyle(.iconOnly) to hide the title) or add .accessibilityLabel.",
                             "Button(\"Add\", systemImage: \"plus\")"))
    for m in TAP_GESTURE_RE.finditer(code):
        line, col = line_of(code, m.start())
        found.append(Finding(path, line, col, "hig-tap-gesture-button", "info",
                             "onTapGesture gives no button trait, keyboard focus, or pointer highlight. "
                             "Use a Button (style it with .buttonStyle(.plain)) for anything people tap to act.",
                             "Button { } label: { }"))
    return found


HIG_IDS = {
    "hig-multiple-prominent": "More than one .borderedProminent/.glassProminent in a file",
    "hig-fixed-font-size": ".font(.system(size:)) or Font.custom(_:fixedSize:)",
    "hig-icon-button-label": "Icon-only Button without a text label or accessibilityLabel",
    "hig-tap-gesture-button": "onTapGesture used where a Button belongs",
}


def lint_source(path: str, src: str, rules: list[Rule]) -> list[Finding]:
    code = strip_code(src)
    raw_lines = src.splitlines()
    code_lines = code.splitlines()
    found: list[Finding] = []
    for rule in rules:
        if rule.file_requires and not rule.file_requires.search(code):
            continue
        if rule.multiline:
            for m in rule.regex.finditer(code):
                line, col = line_of(code, m.start())
                found.append(Finding(path, line, col, rule.id, rule.severity, rule.message, rule.fix))
        else:
            for n, text in enumerate(code_lines, start=1):
                m = rule.regex.search(text)
                if m:
                    found.append(Finding(path, n, m.start() + 1, rule.id, rule.severity, rule.message, rule.fix))
    found.extend(hig_findings(path, code))
    near = {r.id: r.unless_near for r in rules if r.unless_near}
    kept = []
    for f in found:
        if f.id in near and any(near[f.id].search(t) for t in code_lines[max(0, f.line - 7):f.line]):
            continue
        ids = ignored_ids(raw_lines, f.line)
        if ids and ("*" in ids or f.id in ids):
            continue
        kept.append(f)
    kept.sort(key=lambda f: (f.line, f.column, f.id))
    return kept


def swift_files(paths: list[str]):
    for p in paths:
        path = Path(p)
        if path.is_file():
            yield path
        elif path.is_dir():
            for root, dirs, files in os.walk(path):
                dirs[:] = sorted(d for d in dirs if d not in SKIP_DIRS and not d.endswith(".xcodeproj"))
                for name in sorted(files):
                    if name.endswith(".swift"):
                        yield Path(root) / name
        else:
            raise FileNotFoundError(p)


def target_filter(rules: list[Rule], targets: list[str]) -> list[Rule]:
    wanted = {}
    for t in targets:
        m = re.match(r"(?i)\s*(ios|macos)\s*(\d+(?:\.\d+)?)\s*$", t)
        if not m:
            raise ValueError(f"--target must look like 'iOS 17' or 'macos14', got {t!r}")
        wanted[m.group(1).lower()] = float(m.group(2))
    if not wanted:
        return rules
    kept = []
    for r in rules:
        needs = [r.min_os[p] > v for p, v in wanted.items() if p in r.min_os]
        if not any(needs):
            kept.append(r)
    return kept


# --------------------------------------------------------------------------- self-test

HIG_FIXTURES = [
    ("hig-multiple-prominent",
     'VStack {\n    Button("Save") { }.buttonStyle(.borderedProminent)\n    Button("Share") { }.buttonStyle(.borderedProminent)\n}\n',
     'VStack {\n    Button("Save") { }.buttonStyle(.borderedProminent)\n    Button("Share") { }.buttonStyle(.bordered)\n}\n'),
    ("hig-fixed-font-size",
     'Text("Title").font(.system(size: 28, weight: .bold))\n',
     'Text("Title").font(.title.bold())\n'),
    ("hig-icon-button-label",
     'Button { add() } label: {\n    Image(systemName: "plus")\n}\n',
     'Button("Add Item", systemImage: "plus") { add() }\n    .labelStyle(.iconOnly)\n'),
    ("hig-icon-button-label",
     'Button(action: share) { Image(systemName: "square.and.arrow.up") }\n',
     'Button(action: share) { Image(systemName: "square.and.arrow.up") }\n    .accessibilityLabel("Share")\n'),
    ("hig-tap-gesture-button",
     'Text("Retry").onTapGesture { retry() }\n',
     'Button("Retry") { retry() }\n'),
]


def self_test(entries: list[dict], rules: list[Rule]) -> int:
    problems: list[str] = []
    ids = [e.get("id", "?") for e in entries]
    if len(set(ids)) != len(ids):
        problems.append("duplicate ids: " + ", ".join(sorted({i for i in ids if ids.count(i) > 1})))
    if not 30 <= len(entries) <= 50:
        problems.append(f"expected 30-50 corrections, found {len(entries)}")
    for e in entries:
        for key in REQUIRED:
            if not e.get(key, "").strip():
                problems.append(f"{e.get('id', '?')}: missing {key}")
        if e.get("severity", "warning") not in SEVERITIES:
            problems.append(f"{e['id']}: unknown severity {e.get('severity')!r}")
        if e.get("platforms", "all") not in ("all", "ios", "macos"):
            problems.append(f"{e['id']}: platforms must be all, ios, or macos")
        if len(e.get("why", "")) > 160 or "\n" in e.get("why", ""):
            problems.append(f"{e['id']}: why should be one short line")
        min_os = e.get("min_os", "")
        if not (parse_min_os(min_os) or min_os.startswith("any")):
            problems.append(f"{e['id']}: min_os {min_os!r} names no OS version")
    by_id = {r.id: r for r in rules}
    for e in entries:
        if e["id"] not in by_id:
            continue
        old_hits = lint_source("example_old", e["example_old"], rules)
        if not any(f.id == e["id"] for f in old_hits):
            problems.append(f"{e['id']}: example_old is not flagged")
        new_hits = lint_source("example_new", e["example_new"], rules)
        for f in new_hits:
            problems.append(f"{e['id']}: example_new line {f.line} is flagged by {f.id}")
    for rule_id, bad, good in HIG_FIXTURES:
        if not any(f.id == rule_id for f in lint_source("fixture", bad, rules)):
            problems.append(f"{rule_id}: bad fixture is not flagged")
        for f in lint_source("fixture", good, rules):
            problems.append(f"{rule_id}: good fixture is flagged by {f.id}")
    # Code in the topic files should model the corrections too.
    topic_blocks = 0
    for md in sorted((HERE / "topics").glob("*.md")):
        text = md.read_text(encoding="utf-8")
        for m in re.finditer(r"^```swift([^\n]*)\n(.*?)^```", text, re.M | re.S):
            if "nocompile" in m.group(1).split():
                continue
            topic_blocks += 1
            start = text[:m.start()].count("\n") + 2
            for f in lint_source(md.name, m.group(2), rules):
                problems.append(f"{md.name}:{start + f.line - 1}: snippet flagged by {f.id}")
    # Comments, strings, and ignore markers.
    quiet = ('// NavigationView { } in a comment\nlet s = "use .foregroundColor(.red)"\n'
             'let t = """\nNavigationView\n"""\nText("a").foregroundColor(.red) // check-swift:ignore foreground-color\n')
    for f in lint_source("quiet", quiet, rules):
        problems.append(f"comment/string handling: flagged {f.id} on line {f.line}")
    quiet2 = ('Toggle("On", isOn: $on.animation(.snappy))\n'
              'BarMark(x: .value("Day", day), y: .value("Cups", cups))\n    .cornerRadius(4)\n'
              'Button(action: open) {\n    HStack {\n        label\n        Image(systemName: "chevron.right")\n    }\n}\n'
              'Button { toggle() } label: {\n    Label { Text("Done") } icon: { Image(systemName: "checkmark") }\n}\n'
              'Button(role: .destructive) { remove() } label: { Image(systemName: "trash") }\n    .accessibilityLabel("Delete")\n'
              '.toggleStyle(CheckboxStyle())\n')
    for f in lint_source("quiet2", quiet2, rules):
        problems.append(f"false positive: flagged {f.id} on line {f.line}")
    loud = 'Text("\\(name)").foregroundColor(.red)\n'
    if not any(f.id == "foreground-color" for f in lint_source("loud", loud, rules)):
        problems.append("code after an interpolated string is not linted")
    if problems:
        print("self-test FAILED:")
        for p in problems:
            print("  " + p)
        return 1
    print(f"self-test passed: {len(entries)} corrections (old and new examples), {len(HIG_IDS)} HIG checks "
          f"({len(HIG_FIXTURES) * 2} fixtures), {topic_blocks} topic snippets, comment/string/false-positive cases")
    return 0


# --------------------------------------------------------------------------- main

def main(argv: list[str] | None = None) -> int:
    ap = argparse.ArgumentParser(prog="check-swift.sh", description=__doc__.split("\n\n")[0])
    ap.add_argument("paths", nargs="*", help="Swift files or folders (default: .)")
    ap.add_argument("--json", action="store_true", help="print findings as JSON")
    ap.add_argument("--rules", default=str(DEFAULT_RULES), help="path to corrections.yaml")
    ap.add_argument("--target", action="append", default=[], metavar="OS",
                    help="deployment target such as 'iOS 17' or 'macOS 14'; skips fixes that need newer OSes")
    ap.add_argument("--min-severity", choices=list(SEVERITIES), default="info")
    ap.add_argument("--ignore", default="", help="comma-separated rule ids to skip")
    ap.add_argument("--list", action="store_true", help="list the rules and exit")
    ap.add_argument("--self-test", action="store_true", help="test every rule against its examples")
    args = ap.parse_args(argv)

    try:
        entries = load_rules(Path(args.rules))
        rules = build_rules(entries)
    except (OSError, ValueError, KeyError, re.error) as e:
        print(f"check-swift: bad rules file: {e}", file=sys.stderr)
        return 2

    if args.self_test:
        return self_test(entries, rules)
    if args.list:
        for e in entries:
            print(f"{e['id']:<30} {e.get('severity', 'warning'):<8} {e['min_os']:<22} {e['old']}  ->  {e['new']}")
        for rule_id, desc in HIG_IDS.items():
            print(f"{rule_id:<30} {'hig':<8} {'':<22} {desc}")
        return 0

    try:
        rules = target_filter(rules, args.target)
    except ValueError as e:
        print(f"check-swift: {e}", file=sys.stderr)
        return 2
    skip = {x.strip() for x in args.ignore.split(",") if x.strip()}
    floor = SEVERITIES[args.min_severity]
    findings: list[Finding] = []
    try:
        for path in swift_files(args.paths or ["."]):
            try:
                src = path.read_text(encoding="utf-8")
            except (OSError, UnicodeDecodeError) as e:
                print(f"check-swift: can't read {path}: {e}", file=sys.stderr)
                continue
            for f in lint_source(str(path), src, rules):
                if f.id not in skip and SEVERITIES[f.severity] >= floor:
                    findings.append(f)
    except FileNotFoundError as e:
        print(f"check-swift: no such file or folder: {e}", file=sys.stderr)
        return 2

    if args.json:
        print(json.dumps([f.__dict__ for f in findings], indent=2))
    else:
        for f in findings:
            print(f.text())
        sys.stdout.flush()
        if findings:
            counts = {s: sum(f.severity == s for f in findings) for s in SEVERITIES}
            summary = ", ".join(f"{n} {s}" for s, n in counts.items() if n)
            print(f"\n{len(findings)} finding(s): {summary}", file=sys.stderr)
    return 1 if findings else 0


if __name__ == "__main__":
    sys.exit(main())
