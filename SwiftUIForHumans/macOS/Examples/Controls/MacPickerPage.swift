import SwiftUI

extension ComponentPage {
    static let picker = ComponentPage(
        id: "picker",
        title: "Picker",
        summary: "A pop-up button, radio group, or segmented control for one choice from a set.",
        category: .controls,
        symbol: "filemenu.and.selection",
        availability: ["macOS 10.15+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/picker",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/pop-up-buttons",
        aliases: ["pop-up button", "popup", "dropdown", "select", "<select>", "NSPopUpButton", "radio button", "radio group", "NSMatrix", "segmented control", "NSSegmentedControl", "options", "choice"],
        related: ["menu", "toggle", "form", "control-group", "labeled-content"],
        notes: [
            "**The tag type must match the selection type.** `ForEach` over an `Identifiable` enum tags each row with its `id` for you; anything else needs an explicit `.tag(_:)`.",
            "**One style on a container sets them all.** `.pickerStyle(_:)` on a `Form` or `VStack` reaches every picker inside it.",
        ],
        api: [
            APIItem("`Picker(_:selection:content:)`", "A labeled picker bound to a value."),
            APIItem("`.tag(_:)`", "The value an option stands for."),
            APIItem("`.pickerStyle(.menu)`", "The Mac default: a pop-up button."),
            APIItem("`.pickerStyle(.radioGroup)`", "Radio buttons, all options visible."),
            APIItem("`.pickerStyle(.segmented)`", "A segmented control."),
            APIItem("`.horizontalRadioGroupLayout()`", "Lays radio buttons out in a row."),
            APIItem("`.labelsHidden()`", "Hides the label on screen."),
        ],
        guidelines: [
            Guideline(
                "Use a pop-up button for choices, not commands.",
                "A pop-up button picks one of several options that affect the content or view. For a list of actions, several selections, or submenus, use a pull-down [Menu](catalog://menu) instead."
            ),
            Guideline(
                "Help people predict the options before they click.",
                "A label like “Sort by” tells people what's inside. On its own, a pop-up showing “Name” could mean anything.",
                good: "The label explains the choice.",
                bad: "Without a label, the value is a mystery."
            ) {
                Picker("Sort by", selection: .constant("Name")) {
                    Text("Name").tag("Name")
                    Text("Date").tag("Date")
                }
                .fixedSize()
            } bad: {
                Picker("Sort by", selection: .constant("Name")) {
                    Text("Name").tag("Name")
                    Text("Date").tag("Date")
                }
                .labelsHidden()
                .fixedSize()
            },
            Guideline(
                "Start with a useful default.",
                "Preselect the option most people want. If a few people need something unusual, add a Custom… item instead of more controls."
            ),
            Guideline(
                "Use either text or symbols in a segmented control.",
                "Mixing the two in one control looks disjointed. Keep segments similar in size, and aim for no more than about five to seven of them.",
                good: "Every segment is a symbol.",
                bad: "Words and symbols mixed in one control."
            ) {
                Picker("Alignment", selection: .constant(0)) {
                    Image(systemName: "text.alignleft").tag(0)
                    Image(systemName: "text.aligncenter").tag(1)
                    Image(systemName: "text.alignright").tag(2)
                }
                .pickerStyle(.segmented)
                .labelsHidden()
                .fixedSize()
            } bad: {
                Picker("Alignment", selection: .constant(0)) {
                    Image(systemName: "text.alignleft").tag(0)
                    Text("Center").tag(1)
                    Image(systemName: "text.alignright").tag(2)
                }
                .pickerStyle(.segmented)
                .labelsHidden()
                .fixedSize()
            },
            Guideline(
                "Switch the main view with tabs, not a segmented control.",
                "In the body of a window, a `TabView` is the Mac's way to switch views. A segmented control fits a toolbar or an inspector."
            ),
        ]
    ) {
        VStack(alignment: .leading, spacing: 12) {
            Picker("Sort by", selection: .constant(0)) {
                Text("Name").tag(0)
            }
            .fixedSize()
            Picker("View", selection: .constant(0)) {
                Image(systemName: "square.grid.2x2").tag(0)
                Image(systemName: "list.bullet").tag(1)
            }
            .pickerStyle(.segmented)
            .labelsHidden()
            .fixedSize()
        }
    } content: { page in
        MacPickerDemo(page: page)
    }
}

private enum SortKey: String, CaseIterable, Identifiable {
    case name, date, size, kind

    var id: Self { self }
}

private struct MacPickerConfig {
    var selection = SortKey.name
    var style: MacPickerStyleOption = .automatic
    var isHorizontal = false
    var hidesLabel = false
    var size: MacPickerSizeOption = .regular
    var isDisabled = false
}

private struct MacPickerDemo: View {
    let page: ComponentPage

    var body: some View {
        DemoPage(
            page: page,
            initial: MacPickerConfig(),
            usage: """
            enum SortKey: String, CaseIterable, Identifiable {
                case name, date, size, kind
                var id: Self { self }
            }

            @State private var sortKey = SortKey.name

            Picker("Sort by", selection: $sortKey) {
                ForEach(SortKey.allCases) { order in
                    Text(order.rawValue.capitalized)
                }
            }
            """,
            usageNote: Aside(.note, "Like a `<select>`, the picker shows the current choice and writes the new one back to your `@State`.")
        ) { $config in
            VStack(spacing: 16) {
                Picker("Sort by", selection: $config.selection) {
                    ForEach(SortKey.allCases) { order in
                        Text(order.rawValue.capitalized)
                    }
                }
                .styled(config.style)
                .modifier(MacHorizontalRadio(isOn: config.isHorizontal))
                .modifier(MacPickerHidesLabel(isHidden: config.hidesLabel))
                .controlSize(config.size.size)
                .disabled(config.isDisabled)
                .fixedSize()

                Text("selection = .\(config.selection.rawValue)")
                    .font(.footnote.monospaced())
                    .foregroundStyle(.secondary)
            }
        } controls: { $config in
            Section("Appearance") {
                OptionPicker("Style", selection: $config.style)
                Toggle("Radio buttons in a row", isOn: $config.isHorizontal)
                    .disabled(config.style != .radioGroup)
                OptionPicker("Size", selection: $config.size)
            }
            Section("Behavior") {
                Toggle("Hide label", isOn: $config.hidesLabel)
                Toggle("Disabled", isOn: $config.isDisabled)
            }
        } code: { config in
            var lines = [
                "@State private var sortKey = SortKey.\(config.selection.rawValue)",
                "",
                "Picker(\"Sort by\", selection: $sortKey) {",
                "    ForEach(SortKey.allCases) { order in",
                "        Text(order.rawValue.capitalized)",
                "    }",
                "}",
            ]
            if config.style != .automatic {
                lines.append(".pickerStyle(\(config.style.label))")
            }
            if config.style == .radioGroup && config.isHorizontal {
                lines.append(".horizontalRadioGroupLayout()")
            }
            if config.hidesLabel {
                lines.append(".labelsHidden()")
            }
            if config.size != .regular {
                lines.append(".controlSize(\(config.size.label))")
            }
            if config.isDisabled {
                lines.append(".disabled(true)")
            }
            return lines.joined(separator: "\n")
        } examples: {
            MacPickerExamples()
        }
    }
}

// MARK: - Examples

private struct MacPickerExamples: View {
    @State private var format = "Rich Text"
    @State private var encoding = "UTF-8"
    @State private var alignment = "Left"
    @State private var spacing = 1.0
    @State private var startsWith = "Last Window"

    var body: some View {
        ExampleCard(
            title: "Radio buttons in a form",
            caption: "Use `.radioGroup` when seeing every option helps, and inside a `Form` its label lines up with the other rows.",
            code: """
            @State private var format = "Rich Text"
            @State private var encoding = "UTF-8"

            Form {
                Picker("Format:", selection: $format) {
                    Text("Rich Text").tag("Rich Text")
                    Text("Plain Text").tag("Plain Text")
                }
                .pickerStyle(.radioGroup)

                Picker("Encoding:", selection: $encoding) {
                    Text("UTF-8").tag("UTF-8")
                    Text("UTF-16").tag("UTF-16")
                }
            }
            """,
            minHeight: 170
        ) {
            Form {
                Picker("Format:", selection: $format) {
                    Text("Rich Text").tag("Rich Text")
                    Text("Plain Text").tag("Plain Text")
                }
                .pickerStyle(.radioGroup)

                Picker("Encoding:", selection: $encoding) {
                    Text("UTF-8").tag("UTF-8")
                    Text("UTF-16").tag("UTF-16")
                }
            }
            .fixedSize()
        }

        ExampleCard(
            title: "Radio buttons in a row",
            caption: "`.horizontalRadioGroupLayout()` puts the radio buttons side by side, for short options in a narrow space.",
            code: """
            @State private var startsWith = "Last Window"

            Picker("Open with:", selection: $startsWith) {
                Text("Last Window").tag("Last Window")
                Text("New Window").tag("New Window")
            }
            .pickerStyle(.radioGroup)
            .horizontalRadioGroupLayout()
            """,
            minHeight: 120
        ) {
            Picker("Open with:", selection: $startsWith) {
                Text("Last Window").tag("Last Window")
                Text("New Window").tag("New Window")
            }
            .pickerStyle(.radioGroup)
            .horizontalRadioGroupLayout()
            .fixedSize()
        }

        ExampleCard(
            title: "A segmented control in an inspector",
            caption: "Use `.segmented` for a few closely related choices, like alignment in an inspector, with a text label on each symbol for VoiceOver.",
            code: """
            @State private var alignment = "Left"

            Picker("Alignment", selection: $alignment) {
                Label("Left", systemImage: "text.alignleft").tag("Left")
                Label("Center", systemImage: "text.aligncenter").tag("Center")
                Label("Right", systemImage: "text.alignright").tag("Right")
            }
            .pickerStyle(.segmented)
            .labelStyle(.iconOnly)
            """,
            minHeight: 120,
            aside: Aside(.note, "A segmented picker shows a selection. For a row of buttons that each run an action, use a [ControlGroup](catalog://control-group).")
        ) {
            Picker("Alignment", selection: $alignment) {
                Label("Left", systemImage: "text.alignleft").tag("Left")
                Label("Center", systemImage: "text.aligncenter").tag("Center")
                Label("Right", systemImage: "text.alignright").tag("Right")
            }
            .pickerStyle(.segmented)
            .labelStyle(.iconOnly)
            .fixedSize()
        }

        ExampleCard(
            title: "A Custom… option",
            caption: "Add a Custom… item after a `Divider()` for the rare value, so the pop-up stays short instead of listing everything.",
            code: """
            @State private var spacing = 1.0

            Picker("Line spacing:", selection: $spacing) {
                Text("Single").tag(1.0)
                Text("1.5 Lines").tag(1.5)
                Text("Double").tag(2.0)
                Divider()
                Text("Custom…").tag(0.0)
            }
            """,
            minHeight: 120
        ) {
            Picker("Line spacing:", selection: $spacing) {
                Text("Single").tag(1.0)
                Text("1.5 Lines").tag(1.5)
                Text("Double").tag(2.0)
                Divider()
                Text("Custom…").tag(0.0)
            }
            .fixedSize()
        }
    }
}

// MARK: - Options

private enum MacPickerStyleOption: DemoOption {
    case automatic, menu, radioGroup, segmented, inline, palette

    var label: String {
        switch self {
        case .automatic: ".automatic"
        case .menu: ".menu"
        case .radioGroup: ".radioGroup"
        case .segmented: ".segmented"
        case .inline: ".inline"
        case .palette: ".palette"
        }
    }
}

private enum MacPickerSizeOption: DemoOption {
    case mini, small, regular, large

    var label: String {
        switch self {
        case .mini: ".mini"
        case .small: ".small"
        case .regular: ".regular"
        case .large: ".large"
        }
    }

    var size: ControlSize {
        switch self {
        case .mini: .mini
        case .small: .small
        case .regular: .regular
        case .large: .large
        }
    }
}

private struct MacHorizontalRadio: ViewModifier {
    let isOn: Bool

    func body(content: Content) -> some View {
        if isOn {
            content.horizontalRadioGroupLayout()
        } else {
            content
        }
    }
}

private struct MacPickerHidesLabel: ViewModifier {
    let isHidden: Bool

    func body(content: Content) -> some View {
        if isHidden {
            content.labelsHidden()
        } else {
            content
        }
    }
}

private extension View {
    @ViewBuilder
    func styled(_ style: MacPickerStyleOption) -> some View {
        switch style {
        case .automatic: pickerStyle(.automatic)
        case .menu: pickerStyle(.menu)
        case .radioGroup: pickerStyle(.radioGroup)
        case .segmented: pickerStyle(.segmented)
        case .inline: pickerStyle(.inline)
        case .palette: pickerStyle(.palette)
        }
    }
}
