import SwiftUI

extension ComponentPage {
    static let lifecycle = ComponentPage(
        id: "lifecycle",
        title: "View Lifecycle",
        summary: "Run code when a view appears, load data with task, and react to changes with onChange.",
        category: .dataFlow,
        kind: .modifier,
        symbol: "arrow.trianglehead.2.clockwise.rotate.90",
        availability: ["iOS 17.0+", "macOS 14.0+", "visionOS 1.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/view/onappear(perform:)",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/loading",
        aliases: ["useEffect", "componentDidMount", "viewDidLoad", "viewWillAppear", "mounted", "watch", "fetch on load", "debounce", "lifecycle hooks", "onDisappear"],
        related: ["state", "view-updates", "searchable", "progress-view"],
        notes: [
            "**`onAppear` can run many times.** It fires each time the view comes back on screen, such as after switching tabs or navigating back. It isn't a constructor.",
            "**Keep side effects out of `init` and `body`.** SwiftUI calls them far more often than the view appears, so start work from `.task`, `.onChange`, or a button.",
        ],
        api: [
            APIItem("`.task { }`", "Runs `async` work on appear; cancelled when the view goes away."),
            APIItem("`.task(id:) { }`", "Cancels and restarts the work whenever `id` changes."),
            APIItem("`.onAppear { }`", "Runs code each time the view appears."),
            APIItem("`.onDisappear { }`", "Runs code when the view leaves the screen."),
            APIItem("`.onChange(of:initial:)`", "Runs code when a value changes, with old and new values."),
            APIItem("`.refreshable { }`", "Adds pull to refresh to a `List` or `ScrollView`."),
        ],
        guidelines: [
            Guideline(
                "Show something right away.",
                "A blank screen looks broken. Show the layout with placeholder content, then fill it in when `.task` finishes.",
                good: "Placeholder rows show what's coming.",
                bad: "An empty screen looks like an error."
            ) {
                LifecycleLoadingSample(showsPlaceholder: true)
            } bad: {
                LifecycleLoadingSample(showsPlaceholder: false)
            },
            Guideline(
                "Keep the screen usable while it loads.",
                "Load in `.task` so people can still scroll, search, or go back. Don't cover the whole screen with a spinner that blocks every tap."
            ),
            Guideline(
                "Show progress for longer waits.",
                "Use `ProgressView()` when you can't tell how long it will take, and `ProgressView(value:)` when you can."
            ),
        ]
    ) {
        LifecycleThumbnail()
    } content: { page in
        LifecycleDemo(page: page)
    }
}

// MARK: - Shared log

private enum LifecycleKind: Hashable {
    case appear, disappear, task, change

    var color: Color {
        switch self {
        case .appear: .green
        case .disappear: .red
        case .task: .purple
        case .change: .orange
        }
    }
}

private struct LifecycleEvent: Identifiable, Hashable {
    let id: Int
    let kind: LifecycleKind
    let text: String
    let time: Date
}

private struct LifecycleLogRow: View {
    let kind: LifecycleKind
    let text: String
    var time: Date?

    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(kind.color)
                .frame(width: 7, height: 7)
            Text(text)
                .lineLimit(1)
            Spacer(minLength: 4)
            if let time {
                Text(time, format: .dateTime.hour().minute().second())
                    .foregroundStyle(.tertiary)
            }
        }
        .font(.caption.monospaced())
    }
}

// MARK: - Thumbnail

private struct LifecycleThumbnail: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            LifecycleLogRow(kind: .appear, text: "onAppear")
            LifecycleLogRow(kind: .task, text: "task started")
            LifecycleLogRow(kind: .change, text: "onChange 1 → 2")
            LifecycleLogRow(kind: .task, text: "task cancelled")
            LifecycleLogRow(kind: .disappear, text: "onDisappear")
        }
        .padding(12)
        .frame(width: 180)
        .background(.background, in: .rect(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(.separator)
        }
    }
}

// MARK: - Demo

private struct LifecycleConfig {
    var useOnAppear = true
    var useOnDisappear = true
    var useTask = true
    var useOnChange = true
    var onChangeInitial = false
    var showsChild = true
    var value = 0
    var log: [LifecycleEvent] = []
    var nextID = 0

    mutating func record(_ kind: LifecycleKind, _ text: String) {
        log.append(LifecycleEvent(id: nextID, kind: kind, text: text, time: .now))
        nextID += 1
        if log.count > 30 { log.removeFirst(log.count - 30) }
    }
}

private struct LifecycleDemo: View {
    let page: ComponentPage

    var body: some View {
        DemoPage(
            page: page,
            initial: LifecycleConfig(),
            previewHeight: 380,
            usage: """
            @State private var quote = "Loading…"

            var body: some View {
                Text(quote)
                    .task {
                        try? await Task.sleep(for: .seconds(1)) // Pretend to load
                        quote = "Less, but better."
                    }
            }
            """,
            usageNote: Aside(.note, "`.task` is `useEffect` without the cleanup function. SwiftUI cancels the work for you when the view goes away.")
        ) { $config in
            LifecyclePreview(config: $config)
        } controls: { $config in
            Section {
                Toggle(".onAppear", isOn: $config.useOnAppear)
                Toggle(".onDisappear", isOn: $config.useOnDisappear)
                Toggle(".task", isOn: $config.useTask)
                Toggle(".onChange(of: value)", isOn: $config.useOnChange)
                if config.useOnChange {
                    Toggle("initial: true", isOn: $config.onChangeInitial)
                }
            } header: {
                Text("Modifiers on the child")
            } footer: {
                Text("Then show and hide the child, or change the value, in the preview and watch the log.")
            }
        } code: { config in
            lifecycleCode(config)
        } examples: {
            LifecycleExamples()
        }
    }
}

private struct LifecyclePreview: View {
    @Binding var config: LifecycleConfig

    var body: some View {
        VStack(spacing: 14) {
            VStack(spacing: 6) {
                Toggle("Show child", isOn: $config.showsChild.animation(.snappy))
                Stepper("value: \(config.value)", value: $config.value)
            }

            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(.separator, style: StrokeStyle(lineWidth: 1, dash: [5, 4]))
                if !config.showsChild {
                    Text("Child removed")
                        .font(.footnote)
                        .foregroundStyle(.tertiary)
                }
                if config.showsChild {
                    LifecycleChild(
                        value: config.value,
                        useOnAppear: config.useOnAppear,
                        useOnDisappear: config.useOnDisappear,
                        useTask: config.useTask,
                        useOnChange: config.useOnChange,
                        onChangeInitial: config.onChangeInitial
                    ) { kind, text in
                        withAnimation(.snappy) {
                            config.record(kind, text)
                        }
                    }
                    .transition(.scale(scale: 0.9).combined(with: .opacity))
                }
            }
            .frame(height: 52)

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Log")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Spacer()
                    Button("Clear") {
                        withAnimation(.snappy) { config.log.removeAll() }
                    }
                    .font(.caption)
                    .disabled(config.log.isEmpty)
                }
                if config.log.isEmpty {
                    Text("Nothing yet")
                        .font(.caption.monospaced())
                        .foregroundStyle(.tertiary)
                }
                ForEach(config.log.suffix(6)) { event in
                    LifecycleLogRow(kind: event.kind, text: event.text, time: event.time)
                        .transition(.push(from: .bottom).combined(with: .opacity))
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, minHeight: 150, alignment: .topLeading)
            .background(.fill.quaternary, in: .rect(cornerRadius: 12))
        }
        .frame(maxWidth: 340)
    }
}

private struct LifecycleChild: View {
    let value: Int
    let useOnAppear: Bool
    let useOnDisappear: Bool
    let useTask: Bool
    let useOnChange: Bool
    let onChangeInitial: Bool
    let log: (LifecycleKind, String) -> Void

    var body: some View {
        Text("Child view")
            .font(.subheadline.weight(.medium))
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(.green.opacity(0.15), in: .rect(cornerRadius: 12))
            .onAppear {
                if useOnAppear { log(.appear, "onAppear") }
            }
            .onDisappear {
                if useOnDisappear { log(.disappear, "onDisappear") }
            }
            .task(id: useTask) {
                guard useTask else { return }
                log(.task, "task started")
                do {
                    try await Task.sleep(for: .seconds(2))
                    log(.task, "task finished")
                } catch {
                    log(.task, "task cancelled")
                }
            }
            .onChange(of: value, initial: onChangeInitial) { oldValue, newValue in
                guard useOnChange else { return }
                log(.change, oldValue == newValue ? "onChange initial \(newValue)" : "onChange \(oldValue) → \(newValue)")
            }
    }
}

private func lifecycleCode(_ config: LifecycleConfig) -> String {
    var lines = [
        "@State private var showsChild = true",
        "@State private var value = 0",
        "",
        "VStack(spacing: 14) {",
        "    Toggle(\"Show child\", isOn: $showsChild.animation(.snappy))",
        "    Stepper(\"value: \\(value)\", value: $value)",
        "    if showsChild {",
        "        Text(\"Child view\")",
        "            .font(.subheadline.weight(.medium))",
        "            .padding(.horizontal, 16)",
        "            .padding(.vertical, 10)",
        "            .background(.green.opacity(0.15), in: .rect(cornerRadius: 12))",
    ]
    let indent = "            "
    if config.useOnAppear {
        lines += [
            indent + ".onAppear {",
            indent + "    print(\"onAppear\")",
            indent + "}",
        ]
    }
    if config.useOnDisappear {
        lines += [
            indent + ".onDisappear {",
            indent + "    print(\"onDisappear\")",
            indent + "}",
        ]
    }
    if config.useTask {
        lines += [
            indent + ".task {",
            indent + "    print(\"task started\")",
            indent + "    do {",
            indent + "        try await Task.sleep(for: .seconds(2)) // Pretend to load something",
            indent + "        print(\"task finished\")",
            indent + "    } catch {",
            indent + "        print(\"task cancelled\") // The view went away first",
            indent + "    }",
            indent + "}",
        ]
    }
    if config.useOnChange {
        let initial = config.onChangeInitial ? ", initial: true" : ""
        lines += [
            indent + ".onChange(of: value\(initial)) { oldValue, newValue in",
            indent + "    print(\"onChange \\(oldValue) → \\(newValue)\")",
            indent + "}",
        ]
    }
    lines += ["    }", "}"]
    return lines.joined(separator: "\n")
}

// MARK: - Examples

private struct LifecycleExamples: View {
    var body: some View {
        ExampleCard(
            title: "Load data when a view appears",
            caption: "Show a placeholder, then fill it in from `.task(id:)` so a Reload button can restart it.",
            code: """
            @State private var quote: String?
            @State private var reloadID = 0

            func loadQuote() async -> String {
                try? await Task.sleep(for: .seconds(1)) // Pretend network call
                return ["Stay hungry.", "Ship it.", "Less, but better."].randomElement()!
            }

            VStack(spacing: 16) {
                if let quote {
                    Text(quote)
                        .font(.title3.bold())
                } else {
                    ProgressView()
                }
                Button("Reload") { reloadID += 1 }
            }
            .frame(height: 100)
            .task(id: reloadID) {
                quote = nil
                quote = await loadQuote()
            }
            """,
            aside: Aside(.note, "Changing the `id` cancels the running task and starts a new one, so a reload never races an older load.")
        ) {
            LifecycleLoadExample()
        }

        ExampleCard(
            title: "Search as you type",
            caption: "Use `.task(id: query)` to cancel the previous search each time the text changes.",
            code: """
            @State private var query = ""
            @State private var results: [String] = []
            let fruits = ["Apple", "Apricot", "Banana", "Blueberry", "Cherry", "Grape", "Mango", "Peach"]

            VStack(alignment: .leading, spacing: 10) {
                TextField("Search fruit", text: $query)
                    .textFieldStyle(.roundedBorder)
                    .autocorrectionDisabled()
                Text(results.isEmpty ? "No matches" : results.joined(separator: ", "))
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: 280)
            .task(id: query) {
                do {
                    try await Task.sleep(for: .milliseconds(400)) // Debounce
                } catch {
                    return // Cancelled: the user kept typing
                }
                results = fruits.filter { query.isEmpty || $0.localizedCaseInsensitiveContains(query) }
            }
            """,
            aside: Aside(.note, "Sleeping first debounces the search: it runs only once typing pauses. A cancelled sleep throws, which ends the old task.")
        ) {
            LifecycleSearchExample()
        }

        ExampleCard(
            title: "Keep related values in sync",
            caption: "Use `.onChange(of:)` to update one value when another changes, like Airplane Mode turning Wi-Fi off.",
            code: """
            @State private var isAirplaneMode = false
            @State private var isWiFiOn = true

            VStack(spacing: 12) {
                Toggle("Airplane Mode", systemImage: "airplane", isOn: $isAirplaneMode)
                Toggle("Wi-Fi", systemImage: "wifi", isOn: $isWiFiOn)
            }
            .frame(maxWidth: 280)
            .onChange(of: isAirplaneMode) { _, isOn in
                if isOn {
                    withAnimation { isWiFiOn = false }
                }
            }
            """,
            aside: Aside(.important, "`onChange` doesn't run for the starting value. Pass `initial: true` if it should also run when the view appears.")
        ) {
            LifecycleSyncExample()
        }
    }
}

private struct LifecycleLoadExample: View {
    @State private var quote: String?
    @State private var reloadID = 0

    private func loadQuote() async -> String {
        try? await Task.sleep(for: .seconds(1))
        return ["Stay hungry.", "Ship it.", "Less, but better."].randomElement()!
    }

    var body: some View {
        VStack(spacing: 16) {
            if let quote {
                Text(quote)
                    .font(.title3.bold())
            } else {
                ProgressView()
            }
            Button("Reload") { reloadID += 1 }
        }
        .frame(height: 100)
        .task(id: reloadID) {
            quote = nil
            quote = await loadQuote()
        }
    }
}

private struct LifecycleSearchExample: View {
    @State private var query = ""
    @State private var results: [String] = []
    private let fruits = ["Apple", "Apricot", "Banana", "Blueberry", "Cherry", "Grape", "Mango", "Peach"]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            TextField("Search fruit", text: $query)
                .textFieldStyle(.roundedBorder)
                .autocorrectionDisabled()
            Text(results.isEmpty ? "No matches" : results.joined(separator: ", "))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: 280)
        .task(id: query) {
            do {
                try await Task.sleep(for: .milliseconds(400))
            } catch {
                return
            }
            results = fruits.filter { query.isEmpty || $0.localizedCaseInsensitiveContains(query) }
        }
    }
}

private struct LifecycleSyncExample: View {
    @State private var isAirplaneMode = false
    @State private var isWiFiOn = true

    var body: some View {
        VStack(spacing: 12) {
            Toggle("Airplane Mode", systemImage: "airplane", isOn: $isAirplaneMode)
            Toggle("Wi-Fi", systemImage: "wifi", isOn: $isWiFiOn)
        }
        .frame(maxWidth: 280)
        .onChange(of: isAirplaneMode) { _, isOn in
            if isOn {
                withAnimation { isWiFiOn = false }
            }
        }
    }
}

// MARK: - Guideline sample

/// A small inbox card, loading. For the "show something right away" guideline.
private struct LifecycleLoadingSample: View {
    let showsPlaceholder: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Inbox")
                .font(.headline)
            if showsPlaceholder {
                ForEach(["Lunch on Friday?", "Your order has shipped", "Team photos"], id: \.self) { subject in
                    Label(subject, systemImage: "envelope")
                }
                .redacted(reason: .placeholder)
            }
        }
        .font(.subheadline)
        .padding(14)
        .frame(width: 240, height: 130, alignment: .topLeading)
        .background(.background, in: .rect(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(.separator)
        }
    }
}
