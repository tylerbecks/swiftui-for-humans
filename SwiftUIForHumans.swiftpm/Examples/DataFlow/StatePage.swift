import SwiftUI

extension ComponentPage {
    static let state = ComponentPage(
        id: "state",
        title: "@State",
        summary: "Stores a value that one view owns, and redraws the view when it changes.",
        category: .dataFlow,
        kind: .concept,
        symbol: "circle.dotted.circle",
        availability: ["iOS 13.0+", "macOS 10.15+", "visionOS 1.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/state",
        aliases: ["useState", "setState", "local state", "state variable", "reactive variable", "variable", "store a value", "useRef", "stateful"],
        related: ["binding", "choosing-wrappers", "view-updates", "observable"],
        notes: [
            "**Mark it `private`.** The value belongs to the view that declares it. Children get a plain value to read, or a `$binding` to edit.",
            "**The view is rebuilt; the state isn't.** SwiftUI recreates view structs all the time, but keeps each `@State` value alive while the view stays on screen.",
            "**Use it for simple values.** `Bool`, `Int`, `String`, enums, and small structs. For data several screens share, hold an [@Observable](catalog://observable) class in `@State` instead.",
        ],
        api: [
            APIItem("`@State private var count = 0`", "Declares a value this view owns, with its starting value."),
            APIItem("`count += 1`", "Write to it directly. The view redraws on its own."),
            APIItem("`$count`", "A `Binding` that controls and child views can write to."),
            APIItem("`withAnimation { }`", "Animates the views that change because of the write."),
            APIItem("`@State private var model = Model()`", "Owns an `@Observable` class, created once."),
        ]
    ) {
        StateThumbnail()
    } content: { page in
        StateDemo(page: page)
    }
}

// MARK: - Thumbnail

private struct StateThumbnail: View {
    var body: some View {
        VStack(spacing: 10) {
            Text("3")
                .font(.system(size: 44, weight: .bold, design: .rounded))
            HStack(spacing: 8) {
                Button("Decrement", systemImage: "minus") {}
                    .buttonStyle(.bordered)
                Button("Increment", systemImage: "plus") {}
                    .buttonStyle(.borderedProminent)
            }
            .labelStyle(.iconOnly)
            Text("@State private var count = 3")
                .font(.caption2.monospaced())
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Demo

private enum StateValueKind: DemoOption {
    case counter, toggle, text, slider

    var label: String {
        switch self {
        case .counter: "Int (counter)"
        case .toggle: "Bool (switch)"
        case .text: "String (text field)"
        case .slider: "Double (slider)"
        }
    }
}

private struct StateConfig {
    var kind: StateValueKind = .counter
    var startCount = 0
    var startOn = false
    var startName = "Taylor"
    var startSize = 40.0
    var animated = true

    /// Changing anything that affects the initial value gives the preview a
    /// new identity, so its @State starts over (just like in a real app).
    var identity: String {
        "\(kind)-\(startCount)-\(startOn)-\(startName)-\(startSize)"
    }
}

private struct StateDemo: View {
    let page: ComponentPage

    var body: some View {
        DemoPage(
            page: page,
            initial: StateConfig(),
            usage: """
            @State private var count = 0

            var body: some View {
                Button("Count: \\(count)") {
                    count += 1
                }
            }
            """,
            usageNote: Aside(.note, "Unlike React's `useState`, there's no setter function. Assign to the property, and SwiftUI redraws every view that reads it.")
        ) { $config in
            VStack(spacing: 18) {
                Group {
                    switch config.kind {
                    case .counter: StateCounterView(start: config.startCount, animated: config.animated)
                    case .toggle: StateLightSwitch(start: config.startOn, animated: config.animated)
                    case .text: StateGreeting(start: config.startName, animated: config.animated)
                    case .slider: StateStarSizer(start: config.startSize, animated: config.animated)
                    }
                }
                .id(config.identity)
            }
        } controls: { $config in
            Section {
                OptionPicker("Value type", selection: $config.kind)
            } header: {
                Text("State")
            } footer: {
                Text("Changing the starting value creates the view again, so its state starts over.")
            }
            Section("Starting value") {
                switch config.kind {
                case .counter:
                    Stepper("count = \(config.startCount)", value: $config.startCount, in: -10...10)
                case .toggle:
                    Toggle("isOn = \(config.startOn ? "true" : "false")", isOn: $config.startOn)
                case .text:
                    TextField("name", text: $config.startName)
                case .slider:
                    ValueSlider("size", value: $config.startSize, in: 20...100, step: 1)
                }
            }
            Section("Updates") {
                Toggle("Animate changes", isOn: $config.animated)
            }
        } code: { config in
            stateCode(config)
        } examples: {
            StateExamples()
        }
    }
}

/// A small inline readout of the value SwiftUI is storing.
private struct StateStorageBadge: View {
    let name: String
    let value: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "memorychip")
            Text("\(name) = \(value)")
                .monospaced()
                .contentTransition(.numericText())
        }
        .font(.caption)
        .foregroundStyle(.secondary)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(.fill.tertiary, in: .capsule)
    }
}

private struct StateCounterView: View {
    @State private var count: Int
    let animated: Bool

    init(start: Int, animated: Bool) {
        _count = State(initialValue: start)
        self.animated = animated
    }

    var body: some View {
        VStack(spacing: 16) {
            VStack(spacing: 16) {
                Text("\(count)")
                    .font(.system(size: 56, weight: .bold, design: .rounded))
                    .contentTransition(.numericText(value: Double(count)))
                HStack {
                    Button("Decrement", systemImage: "minus") {
                        count -= 1
                    }
                    .buttonStyle(.bordered)
                    Button("Increment", systemImage: "plus") {
                        count += 1
                    }
                    .buttonStyle(.borderedProminent)
                }
                .labelStyle(.iconOnly)
                .controlSize(.large)
            }
            .animation(animated ? .snappy : nil, value: count)
            StateStorageBadge(name: "count", value: "\(count)")
        }
    }
}

private struct StateLightSwitch: View {
    @State private var isOn: Bool
    let animated: Bool

    init(start: Bool, animated: Bool) {
        _isOn = State(initialValue: start)
        self.animated = animated
    }

    var body: some View {
        VStack(spacing: 16) {
            VStack(spacing: 16) {
                Image(systemName: isOn ? "lightbulb.fill" : "lightbulb")
                    .font(.system(size: 56))
                    .foregroundStyle(isOn ? Color.yellow : Color.secondary)
                Toggle("Lights", isOn: $isOn)
                    .fixedSize()
            }
            .animation(animated ? .snappy : nil, value: isOn)
            StateStorageBadge(name: "isOn", value: isOn ? "true" : "false")
        }
    }
}

private struct StateGreeting: View {
    @State private var name: String
    let animated: Bool

    init(start: String, animated: Bool) {
        _name = State(initialValue: start)
        self.animated = animated
    }

    var body: some View {
        VStack(spacing: 16) {
            VStack(spacing: 16) {
                Text("Hello, \(name)!")
                    .font(.title.bold())
                    .multilineTextAlignment(.center)
                TextField("Name", text: $name)
                    .textFieldStyle(.roundedBorder)
                    .frame(maxWidth: 240)
            }
            .animation(animated ? .snappy : nil, value: name)
            StateStorageBadge(name: "name", value: swiftString(name))
        }
    }
}

private struct StateStarSizer: View {
    @State private var size: Double
    let animated: Bool

    init(start: Double, animated: Bool) {
        _size = State(initialValue: start)
        self.animated = animated
    }

    var body: some View {
        VStack(spacing: 16) {
            VStack(spacing: 16) {
                Image(systemName: "star.fill")
                    .font(.system(size: size))
                    .foregroundStyle(.orange)
                    .frame(height: 100)
                Slider(value: $size, in: 20...100)
                    .frame(maxWidth: 240)
            }
            .animation(animated ? .snappy : nil, value: size)
            StateStorageBadge(name: "size", value: swiftNumber(size))
        }
    }
}

private func stateCode(_ config: StateConfig) -> String {
    let animation = config.animated
    func animationLine(_ name: String) -> String {
        animation ? "\n        .animation(.snappy, value: \(name))" : ""
    }
    switch config.kind {
    case .counter:
        return """
        struct CounterView: View {
            @State private var count = \(config.startCount)

            var body: some View {
                VStack(spacing: 16) {
                    Text("\\(count)")
                        .font(.system(size: 56, weight: .bold, design: .rounded))
                        .contentTransition(.numericText(value: Double(count)))
                    HStack {
                        Button("Decrement", systemImage: "minus") {
                            count -= 1
                        }
                        .buttonStyle(.bordered)
                        Button("Increment", systemImage: "plus") {
                            count += 1
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .labelStyle(.iconOnly)
                    .controlSize(.large)
                }\(animationLine("count"))
            }
        }
        """
    case .toggle:
        return """
        struct LightSwitch: View {
            @State private var isOn = \(config.startOn)

            var body: some View {
                VStack(spacing: 16) {
                    Image(systemName: isOn ? "lightbulb.fill" : "lightbulb")
                        .font(.system(size: 56))
                        .foregroundStyle(isOn ? Color.yellow : Color.secondary)
                    Toggle("Lights", isOn: $isOn)
                        .fixedSize()
                }\(animationLine("isOn"))
            }
        }
        """
    case .text:
        return """
        struct Greeting: View {
            @State private var name = \(swiftString(config.startName))

            var body: some View {
                VStack(spacing: 16) {
                    Text("Hello, \\(name)!")
                        .font(.title.bold())
                        .multilineTextAlignment(.center)
                    TextField("Name", text: $name)
                        .textFieldStyle(.roundedBorder)
                        .frame(maxWidth: 240)
                }\(animationLine("name"))
            }
        }
        """
    case .slider:
        let start = swiftNumber(config.startSize)
        return """
        struct StarSizer: View {
            @State private var size\(start.contains(".") ? "" : ": Double") = \(start)

            var body: some View {
                VStack(spacing: 16) {
                    Image(systemName: "star.fill")
                        .font(.system(size: size))
                        .foregroundStyle(.orange)
                        .frame(height: 100)
                    Slider(value: $size, in: 20...100)
                        .frame(maxWidth: 240)
                }\(animationLine("size"))
            }
        }
        """
    }
}

// MARK: - Examples

private struct StateExamples: View {
    var body: some View {
        ExampleCard(
            title: "Show a sheet",
            caption: "A `Bool` in `@State` drives `.sheet(isPresented:)`, the usual way to show and hide something.",
            code: """
            @State private var isShowingDetails = false

            Button("Show details") {
                isShowingDetails = true
            }
            .buttonStyle(.borderedProminent)
            .sheet(isPresented: $isShowingDetails) {
                VStack(spacing: 12) {
                    Text("Order #1042")
                        .font(.title2.bold())
                    Text("Arriving Thursday")
                        .foregroundStyle(.secondary)
                    Button("Close") {
                        isShowingDetails = false
                    }
                    .buttonStyle(.bordered)
                }
                .presentationDetents([.medium])
            }
            """,
            aside: Aside(.note, "You only set it to `true`. When people swipe the sheet down, SwiftUI sets it back to `false` through the binding.")
        ) {
            StateSheetExample()
        }

        ExampleCard(
            title: "A struct as state",
            caption: "Group related values in a struct, and bind controls to its fields with `$draft.title`.",
            code: """
            struct Draft {
                var title = ""
                var isUrgent = false
            }

            @State private var draft = Draft()

            VStack(alignment: .leading, spacing: 12) {
                TextField("Title", text: $draft.title)
                    .textFieldStyle(.roundedBorder)
                Toggle("Urgent", isOn: $draft.isUrgent)
                Text(draft.isUrgent ? "🔥 \\(draft.title)" : draft.title)
                    .font(.headline)
            }
            .frame(maxWidth: 280)
            """,
            aside: Aside(.note, "Changing any field counts as a change to the whole struct, so every view that reads `draft` redraws.")
        ) {
            StateDraftExample()
        }

        ExampleCard(
            title: "Gotcha: state ignores later inputs",
            caption: "The child copies the parent's number into its own `@State`, so it stops following the parent.",
            code: """
            struct Parent: View {
                @State private var count = 0

                var body: some View {
                    VStack(spacing: 12) {
                        Stepper("Parent: \\(count)", value: $count)
                        Child(count: count)
                    }
                }
            }

            struct Child: View {
                @State var count: Int // ⚠️ Copied once, then ignored

                var body: some View {
                    Text("Child: \\(count)")
                }
            }
            """,
            aside: Aside(.important, "`@State` uses its starting value only once. To follow a value the parent owns, declare `let count: Int`, or `@Binding var count: Int` if the child also changes it.")
        ) {
            StateStaleParent()
        }
    }
}

private struct StateSheetExample: View {
    @State private var isShowingDetails = false

    var body: some View {
        Button("Show details") {
            isShowingDetails = true
        }
        .buttonStyle(.borderedProminent)
        .sheet(isPresented: $isShowingDetails) {
            VStack(spacing: 12) {
                Text("Order #1042")
                    .font(.title2.bold())
                Text("Arriving Thursday")
                    .foregroundStyle(.secondary)
                Button("Close") {
                    isShowingDetails = false
                }
                .buttonStyle(.bordered)
            }
            .presentationDetents([.medium])
        }
    }
}

private struct StateDraft {
    var title = ""
    var isUrgent = false
}

private struct StateDraftExample: View {
    @State private var draft = StateDraft()

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            TextField("Title", text: $draft.title)
                .textFieldStyle(.roundedBorder)
            Toggle("Urgent", isOn: $draft.isUrgent)
            Text(draft.isUrgent ? "🔥 \(draft.title)" : draft.title)
                .font(.headline)
        }
        .frame(maxWidth: 280)
    }
}

private struct StateStaleParent: View {
    @State private var count = 0

    var body: some View {
        VStack(spacing: 12) {
            Stepper("Parent: \(count)", value: $count)
            StateStaleChild(count: count)
        }
        .frame(maxWidth: 280)
    }
}

private struct StateStaleChild: View {
    @State var count: Int

    var body: some View {
        Text("Child: \(count)")
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
