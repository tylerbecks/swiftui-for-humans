import SwiftUI

extension ComponentPage {
    static let binding = ComponentPage(
        id: "binding",
        title: "@Binding",
        summary: "Lets a child view read and write a value its parent owns, so both stay in sync.",
        category: .dataFlow,
        kind: .concept,
        symbol: "arrow.left.arrow.right.circle",
        availability: ["iOS 13.0+", "macOS 10.15+", "visionOS 1.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/binding",
        aliases: ["props", "two-way binding", "v-model", "lifting state up", "callback", "pass state to child", "inout", "shared value", "setter"],
        related: ["state", "observable", "choosing-wrappers", "toggle"],
        notes: [
            "**A binding stores nothing.** It points at a value someone else owns, usually a parent's `@State`, so there's no copy to keep in sync.",
            "**It's a prop and its setter in one.** Where React passes `value` and `onChange`, SwiftUI passes a single `$value`.",
            "**Use `.constant(_:)` in previews.** `Toggle(\"Wi-Fi\", isOn: .constant(true))` makes a binding that never changes, handy in `#Preview`.",
        ],
        api: [
            APIItem("`@Binding var isOn: Bool`", "Declares a value the parent owns and this view can change."),
            APIItem("`$isOn`", "Passes a binding to a child or a control."),
            APIItem("`$settings.volume`", "A binding to one property of a struct."),
            APIItem("`ForEach($items) { $item in }`", "A binding to each element of an array."),
            APIItem("`Binding(get:set:)`", "A custom binding that converts or validates on the way."),
            APIItem("`.constant(_:)`", "A binding that never changes, for previews."),
        ]
    ) {
        BindingThumbnail()
    } content: { page in
        BindingDemo(page: page)
    }
}

// MARK: - Thumbnail

private struct BindingThumbnail: View {
    var body: some View {
        VStack(spacing: 6) {
            BindingBoxLabel(name: "Parent", detail: "@State var isOn", tint: .blue) {
                Text("true")
                    .font(.caption.monospaced())
            }
            Image(systemName: "arrow.up.arrow.down")
                .font(.caption.bold())
                .foregroundStyle(.secondary)
            BindingBoxLabel(name: "Child", detail: "@Binding var isOn", tint: .green) {
                Toggle("Wi-Fi", isOn: .constant(true))
                    .labelsHidden()
                    .scaleEffect(0.8)
                    .frame(height: 22)
            }
        }
        .frame(width: 210)
    }
}

private struct BindingBoxLabel<Content: View>: View {
    let name: String
    let detail: String
    let tint: Color
    @ViewBuilder let content: Content

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 1) {
                Text(name)
                    .font(.caption.bold())
                Text(detail)
                    .font(.caption2.monospaced())
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .fixedSize()
            }
            Spacer(minLength: 4)
            content
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(tint.opacity(0.12), in: .rect(cornerRadius: 10))
        .overlay {
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(tint.opacity(0.5))
        }
    }
}

// MARK: - Demo

private enum BindingControlKind: DemoOption {
    case stepper, toggle, textField

    var label: String {
        switch self {
        case .stepper: "Stepper (Int)"
        case .toggle: "Toggle (Bool)"
        case .textField: "TextField (String)"
        }
    }
}

private enum BindingPassMode: DemoOption {
    case binding, plainLet, stateCopy

    var label: String {
        switch self {
        case .binding: "@Binding"
        case .plainLet: "let (read-only)"
        case .stateCopy: "@State copy (bug)"
        }
    }

    var declaration: String {
        switch self {
        case .binding: "@Binding var"
        case .plainLet: "let"
        case .stateCopy: "@State var"
        }
    }
}

private struct BindingConfig {
    var control: BindingControlKind = .stepper
    var mode: BindingPassMode = .binding
    var count = 3
    var isOn = true
    var name = "Taylor"
    /// Bumped when a value travels child -> parent or parent -> child, to
    /// animate the arrows.
    var upPulses = 0
    var downPulses = 0
}

private struct BindingDemo: View {
    let page: ComponentPage

    var body: some View {
        DemoPage(
            page: page,
            initial: BindingConfig(),
            previewHeight: 280,
            usage: """
            struct WiFiRow: View {
                @Binding var isOn: Bool

                var body: some View {
                    Toggle("Wi-Fi", isOn: $isOn)
                }
            }

            // In the parent, which owns it:
            // @State private var isOn = true
            // WiFiRow(isOn: $isOn)
            """,
            usageNote: Aside(.note, "Use `@Binding` only when the child changes the value. If it just shows it, declare a plain `let` and pass the value without `$`.")
        ) { $config in
            BindingFlowPreview(config: $config)
        } controls: { $config in
            Section("Child control") {
                OptionPicker("Control", selection: $config.control)
            }
            Section {
                Picker("Pass as", selection: $config.mode) {
                    ForEach(BindingPassMode.allCases) { mode in
                        Text(mode.label).tag(mode)
                    }
                }
                .pickerStyle(.inline)
                .labelsHidden()
            } header: {
                Text("How the parent passes the value")
            } footer: {
                Text(footer(for: config.mode))
            }
        } code: { config in
            bindingCode(config)
        } examples: {
            BindingExamples()
        }
    }

    private func footer(for mode: BindingPassMode) -> String {
        switch mode {
        case .binding: "The child writes straight into the parent's @State. Both always match."
        case .plainLet: "The child gets a copy it can only read. It still updates when the parent changes."
        case .stateCopy: "The child copies the value into its own @State once. After that, the two drift apart."
        }
    }
}

private struct BindingFlowPreview: View {
    @Binding var config: BindingConfig

    private var valueText: String {
        switch config.control {
        case .stepper: "\(config.count)"
        case .toggle: config.isOn ? "true" : "false"
        case .textField: swiftString(config.name)
        }
    }

    private var variable: String {
        switch config.control {
        case .stepper: "count"
        case .toggle: "isOn"
        case .textField: "name"
        }
    }

    var body: some View {
        VStack(spacing: 8) {
            BindingBox(title: "ParentView", declaration: "@State private var \(variable)", tint: .blue) {
                HStack {
                    Text("\(variable) = \(valueText)")
                        .font(.callout.monospaced())
                        .contentTransition(.numericText())
                        .lineLimit(1)
                    Spacer(minLength: 8)
                    Button("Reset", action: resetFromParent)
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                }
            }

            HStack(spacing: 28) {
                BindingArrow(
                    symbol: "arrow.down",
                    text: config.mode == .stateCopy ? "copied once" : "value",
                    isActive: true,
                    pulses: config.downPulses
                )
                BindingArrow(
                    symbol: "arrow.up",
                    text: config.mode == .binding ? "writes back" : "no way back",
                    isActive: config.mode == .binding,
                    pulses: config.upPulses
                )
            }

            BindingBox(title: "ChildView", declaration: "\(config.mode.declaration) \(variable)", tint: config.mode == .stateCopy ? .orange : .green) {
                childContent
            }
            .id("\(config.mode)-\(config.control)")
        }
        .frame(maxWidth: 360)
        .animation(.snappy, value: config.mode)
    }

    @ViewBuilder
    private var childContent: some View {
        switch config.mode {
        case .binding:
            BindingChildControl(control: config.control, count: childBinding(\.count), isOn: childBinding(\.isOn), name: childBinding(\.name))
        case .plainLet:
            BindingReadOnlyChild(text: readOnlyText)
        case .stateCopy:
            BindingStateCopyChild(control: config.control, count: config.count, isOn: config.isOn, name: config.name)
        }
    }

    private var readOnlyText: String {
        switch config.control {
        case .stepper: "Count: \(config.count)"
        case .toggle: config.isOn ? "Wi-Fi is on" : "Wi-Fi is off"
        case .textField: "Hello, \(config.name)!"
        }
    }

    /// A binding into the parent's value that also pulses the "writes back" arrow.
    private func childBinding<Value: Equatable>(_ keyPath: WritableKeyPath<BindingConfig, Value>) -> Binding<Value> {
        Binding {
            config[keyPath: keyPath]
        } set: { newValue in
            guard newValue != config[keyPath: keyPath] else { return }
            config[keyPath: keyPath] = newValue
            config.upPulses += 1
        }
    }

    private func resetFromParent() {
        withAnimation(.snappy) {
            switch config.control {
            case .stepper: config.count = 0
            case .toggle: config.isOn = false
            case .textField: config.name = "Taylor"
            }
            // A @State copy never hears about the reset, so nothing travels down.
            if config.mode != .stateCopy {
                config.downPulses += 1
            }
        }
    }
}

private struct BindingBox<Content: View>: View {
    let title: String
    let declaration: String
    let tint: Color
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Text(title)
                    .font(.subheadline.bold())
                Text(declaration)
                    .font(.caption.monospaced())
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            content
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(tint.opacity(0.1), in: .rect(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(tint.opacity(0.45))
        }
    }
}

private struct BindingArrow: View {
    let symbol: String
    let text: String
    let isActive: Bool
    let pulses: Int

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: symbol)
                .font(.body.bold())
                .symbolEffect(.bounce, value: pulses)
            Text(text)
                .font(.caption)
        }
        .foregroundStyle(isActive ? Color.accentColor : Color.secondary.opacity(0.6))
        .strikethrough(!isActive)
        .keyframeAnimator(initialValue: 1.0, trigger: pulses) { content, scale in
            content.scaleEffect(scale)
        } keyframes: { _ in
            SpringKeyframe(1.25, duration: 0.15)
            SpringKeyframe(1.0, duration: 0.3)
        }
    }
}

private struct BindingChildControl: View {
    let control: BindingControlKind
    @Binding var count: Int
    @Binding var isOn: Bool
    @Binding var name: String

    var body: some View {
        switch control {
        case .stepper:
            Stepper("Count: \(count)", value: $count)
        case .toggle:
            Toggle("Wi-Fi", isOn: $isOn)
        case .textField:
            TextField("Name", text: $name)
                .textFieldStyle(.roundedBorder)
        }
    }
}

private struct BindingReadOnlyChild: View {
    let text: String

    var body: some View {
        HStack {
            Text(text)
            Spacer()
            Image(systemName: "lock.fill")
                .foregroundStyle(.secondary)
                .accessibilityLabel("Read-only")
        }
    }
}

private struct BindingStateCopyChild: View {
    let control: BindingControlKind
    @State private var count: Int
    @State private var isOn: Bool
    @State private var name: String

    init(control: BindingControlKind, count: Int, isOn: Bool, name: String) {
        self.control = control
        _count = State(initialValue: count)
        _isOn = State(initialValue: isOn)
        _name = State(initialValue: name)
    }

    var body: some View {
        BindingChildControl(control: control, count: $count, isOn: $isOn, name: $name)
    }
}

private func bindingCode(_ config: BindingConfig) -> String {
    let variable: String
    let type: String
    let initial: String
    let reset: String
    let childView: String
    let readOnlyView: String
    switch config.control {
    case .stepper:
        variable = "count"; type = "Int"; initial = "\(config.count)"; reset = "0"
        childView = "Stepper(\"Count: \\(count)\", value: $count)"
        readOnlyView = "Text(\"Count: \\(count)\")"
    case .toggle:
        variable = "isOn"; type = "Bool"; initial = "\(config.isOn)"; reset = "false"
        childView = "Toggle(\"Wi-Fi\", isOn: $isOn)"
        readOnlyView = "Text(isOn ? \"Wi-Fi is on\" : \"Wi-Fi is off\")"
    case .textField:
        variable = "name"; type = "String"; initial = swiftString(config.name); reset = "\"Taylor\""
        childView = "TextField(\"Name\", text: $name)\n            .textFieldStyle(.roundedBorder)"
        readOnlyView = "Text(\"Hello, \\(name)!\")"
    }

    let argument: String
    let childDeclaration: String
    let childBody: String
    switch config.mode {
    case .binding:
        argument = "$\(variable)"
        childDeclaration = "@Binding var \(variable): \(type)"
        childBody = childView
    case .plainLet:
        argument = variable
        childDeclaration = "let \(variable): \(type) // Read-only"
        childBody = readOnlyView
    case .stateCopy:
        argument = variable
        childDeclaration = "@State var \(variable): \(type) // ⚠️ Copied once, then out of sync"
        childBody = childView
    }

    return """
    struct ParentView: View {
        @State private var \(variable) = \(initial)

        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("\(variable) = \\(\(variable))")
                    Spacer()
                    Button("Reset") { \(variable) = \(reset) }
                }
                ChildView(\(variable): \(argument))
            }
        }
    }

    struct ChildView: View {
        \(childDeclaration)

        var body: some View {
            \(childBody)
        }
    }
    """
}

// MARK: - Examples

private struct BindingExamples: View {
    var body: some View {
        ExampleCard(
            title: "Bind to a property",
            caption: "Write `$settings.volume` to bind a control to one field of a struct in `@State`.",
            code: """
            struct Settings {
                var volume = 0.5
                var isMuted = false
            }

            @State private var settings = Settings()

            VStack(spacing: 12) {
                Slider(value: $settings.volume)
                Toggle("Mute", isOn: $settings.isMuted)
                Text(settings.isMuted ? "Muted" : "Volume \\(Int(settings.volume * 100))%")
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: 280)
            """
        ) {
            BindingPropertyExample()
        }

        ExampleCard(
            title: "A binding for each row",
            caption: "Pass `$tasks` to `ForEach`, and each row gets a binding to its own element.",
            code: """
            struct TodoItem: Identifiable {
                let id = UUID()
                var title: String
                var isDone = false
            }

            @State private var tasks = [
                TodoItem(title: "Buy milk"),
                TodoItem(title: "Walk the dog", isDone: true),
                TodoItem(title: "Learn SwiftUI"),
            ]

            VStack(alignment: .leading, spacing: 10) {
                Text("\\(tasks.filter(\\.isDone).count) of \\(tasks.count) done")
                    .font(.headline)
                ForEach($tasks) { $task in
                    Toggle(task.title, isOn: $task.isDone)
                }
            }
            .frame(maxWidth: 280)
            """,
            aside: Aside(.note, "Writing `{ $task in }` gives you both names: `task` to read, and `$task` to pass to a control.")
        ) {
            BindingForEachExample()
        }

        ExampleCard(
            title: "A custom binding",
            caption: "Use `Binding(get:set:)` when a control's value is derived, like a Mute toggle backed by `volume == 0`.",
            code: """
            @State private var volume = 0.6

            var body: some View {
                let isMuted = Binding {
                    volume == 0
                } set: { muted in
                    volume = muted ? 0 : 0.6
                }

                VStack(spacing: 12) {
                    Toggle("Mute", isOn: isMuted)
                    Slider(value: $volume)
                }
                .frame(maxWidth: 280)
            }
            """
        ) {
            BindingCustomExample()
        }
    }
}

private struct BindingSettings {
    var volume = 0.5
    var isMuted = false
}

private struct BindingPropertyExample: View {
    @State private var settings = BindingSettings()

    var body: some View {
        VStack(spacing: 12) {
            Slider(value: $settings.volume)
            Toggle("Mute", isOn: $settings.isMuted)
            Text(settings.isMuted ? "Muted" : "Volume \(Int(settings.volume * 100))%")
                .monospacedDigit()
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: 280)
    }
}

private struct BindingTodo: Identifiable {
    let id = UUID()
    var title: String
    var isDone = false
}

private struct BindingForEachExample: View {
    @State private var tasks = [
        BindingTodo(title: "Buy milk"),
        BindingTodo(title: "Walk the dog", isDone: true),
        BindingTodo(title: "Learn SwiftUI"),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("\(tasks.filter(\.isDone).count) of \(tasks.count) done")
                .font(.headline)
            ForEach($tasks) { $task in
                Toggle(task.title, isOn: $task.isDone)
            }
        }
        .frame(maxWidth: 280)
    }
}

private struct BindingCustomExample: View {
    @State private var volume = 0.6

    var body: some View {
        let isMuted = Binding {
            volume == 0
        } set: { muted in
            volume = muted ? 0 : 0.6
        }

        VStack(spacing: 12) {
            Toggle("Mute", isOn: isMuted)
            Slider(value: $volume)
        }
        .frame(maxWidth: 280)
    }
}
