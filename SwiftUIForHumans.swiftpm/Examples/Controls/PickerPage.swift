import SwiftUI

extension ComponentPage {
    static let picker = ComponentPage(
        id: "picker",
        title: "Picker",
        summary: "A control for choosing one value from a list of options.",
        category: .controls,
        symbol: "filemenu.and.selection",
        availability: ["iOS 13.0+", "macOS 10.15+", "visionOS 1.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/picker",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/pickers",
        aliases: ["dropdown", "select", "<select>", "option", "segmented control", "tabs", "radio buttons", "UIPickerView", "UISegmentedControl", "combobox"],
        related: ["menu", "date-picker", "form", "toggle"],
        notes: [
            "**The tag's type must match the selection exactly.** A `String` tag on an `Int` selection compiles, but nothing ever looks selected.",
            "**The default look depends on where the picker lives.** On its own it's a menu button; in a `Form` it's a row with the value on the right.",
        ],
        api: [
            APIItem("`Picker(_:selection:content:)`", "Binds to a value; each option's `.tag` is its value."),
            APIItem("`.tag(_:)`", "The value an option stands for."),
            APIItem("`.pickerStyle(_:)`", "`.menu`, `.segmented`, `.wheel`, and more."),
            APIItem("`ForEach(Enum.allCases)`", "Builds options from an enum; tags are added for you."),
            APIItem("`.labelsHidden()`", "Hides the label but keeps it for VoiceOver."),
            APIItem("`Menu { Picker }`", "A pull-down with a checkmark on the current choice."),
        ],
        guidelines: [
            Guideline(
                "Use a segmented picker for two to five short options.",
                "More segments get cramped on iPhone and the labels get cut off. For longer lists, use the `.menu` style.",
                good: "Three short segments.",
                bad: "Too many segments to read."
            ) {
                Picker("View", selection: .constant(0)) {
                    Text("Day").tag(0)
                    Text("Week").tag(1)
                    Text("Month").tag(2)
                }
                .pickerStyle(.segmented)
                .frame(width: 260)
            } bad: {
                Picker("View", selection: .constant(0)) {
                    Text("Hourly").tag(0)
                    Text("Daily").tag(1)
                    Text("Weekly").tag(2)
                    Text("Monthly").tag(3)
                    Text("Yearly").tag(4)
                    Text("All Time").tag(5)
                }
                .pickerStyle(.segmented)
                .frame(width: 260)
            },
            Guideline(
                "Use all text or all icons in one segmented control.",
                "Mixing them makes segments look uneven and hard to compare.",
                good: "Every segment is an icon.",
                bad: "Icons and words mixed together."
            ) {
                Picker("Layout", selection: .constant(0)) {
                    Image(systemName: "list.bullet").tag(0)
                    Image(systemName: "square.grid.2x2").tag(1)
                    Image(systemName: "rectangle.grid.1x2").tag(2)
                }
                .pickerStyle(.segmented)
                .frame(width: 200)
            } bad: {
                Picker("Layout", selection: .constant(0)) {
                    Image(systemName: "list.bullet").tag(0)
                    Text("Grid").tag(1)
                    Image(systemName: "rectangle.grid.1x2").tag(2)
                }
                .pickerStyle(.segmented)
                .frame(width: 200)
            },
            Guideline(
                "Order options so people can guess what's hidden.",
                "Alphabetical, numeric, or by time. A menu or wheel hides most options, so a predictable order makes them quick to find."
            ),
            Guideline(
                "Use a segmented control to switch views, not whole sections.",
                "Switching between related views on one screen fits. For the app's main sections, use a [TabView](catalog://tab-view)."
            ),
        ]
    ) {
        VStack(spacing: 14) {
            Picker("Size", selection: .constant(1)) {
                Text("Small").tag(0)
                Text("Medium").tag(1)
                Text("Large").tag(2)
            }
            .pickerStyle(.segmented)
            .frame(width: 210)
            Picker("Flavor", selection: .constant("Vanilla")) {
                Text("Vanilla").tag("Vanilla")
            }
            .pickerStyle(.menu)
            .buttonStyle(.bordered)
        }
    } content: { page in
        PickerDemo(page: page)
    }
}

private enum Flavor: String, CaseIterable, Identifiable {
    case vanilla, chocolate, strawberry, mint

    var id: Self { self }
    var title: String { rawValue.capitalized }

    var symbol: String {
        switch self {
        case .vanilla: "leaf"
        case .chocolate: "cup.and.saucer"
        case .strawberry: "heart"
        case .mint: "snowflake"
        }
    }
}

private struct PickerConfig {
    var flavor: Flavor = .chocolate
    var style: PickerStyleOption = .automatic
    var placement: PickerPlacement = .form
    var showsIcons = false
    var hidesLabel = false
    var isDisabled = false

    /// `.inline` and `.navigationLink` only work as rows in a Form or List.
    var isInForm: Bool {
        placement == .form || style == .inline || style == .navigationLink
    }
}

private struct PickerDemo: View {
    let page: ComponentPage

    var body: some View {
        DemoPage(
            page: page,
            initial: PickerConfig(),
            previewHeight: 240,
            usage: """
            @State private var size = "Medium"

            Picker("Size", selection: $size) {
                Text("Small").tag("Small")
                Text("Medium").tag("Medium")
                Text("Large").tag("Large")
            }
            """,
            usageNote: Aside(.important, "Each option's `.tag` must be the same type as `selection`. With an optional selection, tag with `Optional(\"Small\")` or nothing shows as selected.")
        ) { $config in
            VStack(spacing: 16) {
                container(config) {
                    Picker("Flavor", selection: $config.flavor) {
                        ForEach(Flavor.allCases) { flavor in
                            if config.showsIcons {
                                Label(flavor.title, systemImage: flavor.symbol)
                            } else {
                                Text(flavor.title)
                            }
                        }
                    }
                    .styled(config.style)
                    .modifier(PickerHidesLabel(isHidden: config.hidesLabel))
                    .disabled(config.isDisabled)
                }

                Text("selection = .\(config.flavor.rawValue)")
                    .font(.footnote.monospaced())
                    .foregroundStyle(.secondary)
            }
        } controls: { $config in
            Section {
                OptionPicker("Style", selection: $config.style)
                OptionPicker("Placement", selection: $config.placement)
                    .disabled(config.style == .inline || config.style == .navigationLink)
            } header: {
                Text("Style")
            } footer: {
                Text("A picker changes its look depending on where it lives. `.inline` and `.navigationLink` only work inside a Form.")
            }
            Section("Content") {
                Picker("Selection", selection: $config.flavor) {
                    ForEach(Flavor.allCases) { Text($0.title) }
                }
                Toggle("Show icons", isOn: $config.showsIcons)
                Toggle("Hide label", isOn: $config.hidesLabel)
                Toggle("Disabled", isOn: $config.isDisabled)
            }
        } code: { config in
            pickerCode(config)
        } examples: {
            PickerExamples()
        }
    }

    @ViewBuilder
    private func container<Content: View>(_ config: PickerConfig, @ViewBuilder content: () -> Content) -> some View {
        if config.isInForm {
            // A whole phone screen, so the form looks like a real settings
            // screen and `.navigationLink` can push its list of options.
            PhoneScreen(width: 280, height: formHeight(config.style)) {
                Form {
                    Section("Ice cream") { content() }
                }
                .navigationTitle("Order")
                .navigationBarTitleDisplayMode(.inline)
            }
            .animation(.snappy, value: config.style)
        } else {
            switch config.style {
            case .segmented, .palette:
                content().frame(maxWidth: 420)
            default:
                content()
            }
        }
    }

    private func formHeight(_ style: PickerStyleOption) -> CGFloat {
        switch style {
        case .inline: 400
        case .wheel: 380
        case .navigationLink: 240
        default: 220
        }
    }
}

private func pickerCode(_ config: PickerConfig) -> String {
    var picker: [String] = []
    picker.append("Picker(\"Flavor\", selection: $flavor) {")
    picker.append("    ForEach(Flavor.allCases) { flavor in")
    picker.append(config.showsIcons
        ? "        Label(flavor.title, systemImage: flavor.symbol)"
        : "        Text(flavor.title)")
    picker.append("    }")
    picker.append("}")
    if config.style != .automatic {
        picker.append("    .pickerStyle(\(config.style.label))")
    }
    if config.hidesLabel {
        picker.append("    .labelsHidden()")
    }
    if config.isDisabled {
        picker.append("    .disabled(true)")
    }

    var body: [String]
    if config.isInForm {
        body = ["NavigationStack {", "    Form {", "        Section(\"Ice cream\") {"]
            + picker.map { "            " + $0 }
            + ["        }", "    }", "    .navigationTitle(\"Order\")", "}"]
    } else {
        body = picker
    }

    var lines = [
        "enum Flavor: String, CaseIterable, Identifiable {",
        "    case vanilla, chocolate, strawberry, mint",
        "    var id: Self { self }",
        "    var title: String { rawValue.capitalized }",
    ]
    if config.showsIcons {
        lines += [
            "    var symbol: String {",
            "        switch self {",
            "        case .vanilla: \"leaf\"",
            "        case .chocolate: \"cup.and.saucer\"",
            "        case .strawberry: \"heart\"",
            "        case .mint: \"snowflake\"",
            "        }",
            "    }",
        ]
    }
    lines.append("}")
    let state = ["@State private var flavor = Flavor.\(config.flavor.rawValue)", ""]
    return (state + body + ["", "// The options, declared outside your view:"] + lines).joined(separator: "\n")
}

// MARK: - Examples

private enum InboxFilter: String, CaseIterable, Identifiable {
    case all = "All", unread = "Unread", flagged = "Flagged"
    var id: Self { self }
}

private enum SortOrder: String, CaseIterable, Identifiable {
    case newest = "Newest", oldest = "Oldest", name = "Name"
    var id: Self { self }
}

private struct PickerExamples: View {
    @State private var filter = InboxFilter.all
    @State private var units = "Metric"
    @State private var reminder: Int? = nil
    @State private var color = "blue"
    @State private var sort = SortOrder.newest

    var body: some View {
        ExampleCard(
            title: "Segmented filter",
            caption: "Use `.pickerStyle(.segmented)` above content to filter it, like a small tab bar inside one screen.",
            code: """
            enum InboxFilter: String, CaseIterable, Identifiable {
                case all = "All", unread = "Unread", flagged = "Flagged"
                var id: Self { self }
            }

            @State private var filter = InboxFilter.all

            VStack {
                Picker("Filter", selection: $filter) {
                    ForEach(InboxFilter.allCases) { Text($0.rawValue) }
                }
                .pickerStyle(.segmented)

                Text(filter == .all ? "12 messages" : filter == .unread ? "3 unread" : "1 flagged")
            }
            """
        ) {
            VStack(spacing: 16) {
                Picker("Filter", selection: $filter) {
                    ForEach(InboxFilter.allCases) { Text($0.rawValue) }
                }
                .pickerStyle(.segmented)

                Text(filter == .all ? "12 messages" : filter == .unread ? "3 unread" : "1 flagged")
                    .foregroundStyle(.secondary)
                    .contentTransition(.numericText())
                    .animation(.snappy, value: filter)
            }
            .frame(maxWidth: 360)
        }

        ExampleCard(
            title: "In a settings form",
            caption: "Inside a `Form`, a picker becomes a row that shows the current value and opens a menu.",
            code: """
            @State private var units = "Metric"
            @State private var reminder: Int? = nil

            Form {
                Picker("Units", selection: $units) {
                    Text("Metric").tag("Metric")
                    Text("Imperial").tag("Imperial")
                }
                Picker("Reminder", selection: $reminder) {
                    Text("None").tag(Int?.none)
                    Text("5 minutes before").tag(Optional(5))
                    Text("1 hour before").tag(Optional(60))
                }
            }
            """,
            minHeight: 200,
            aside: Aside(.note, "“Reminder” has an optional selection so people can pick None. Its tags are `Int?.none` and `Optional(5)`, matching `Int?`.")
        ) {
            Form {
                Picker("Units", selection: $units) {
                    Text("Metric").tag("Metric")
                    Text("Imperial").tag("Imperial")
                }
                Picker("Reminder", selection: $reminder) {
                    Text("None").tag(Int?.none)
                    Text("5 minutes before").tag(Optional(5))
                    Text("1 hour before").tag(Optional(60))
                }
            }
            .scrollDisabled(true)
            .frame(height: 180)
            .frame(maxWidth: 420)
            .scrollContentBackground(.hidden)
        }

        ExampleCard(
            title: "Sort menu with checkmarks",
            caption: "Put a picker inside a `Menu` for a pull-down with a checkmark beside the current choice.",
            code: """
            enum SortOrder: String, CaseIterable, Identifiable {
                case newest = "Newest", oldest = "Oldest", name = "Name"
                var id: Self { self }
            }

            @State private var sort = SortOrder.newest

            Menu {
                Picker("Sort by", selection: $sort) {
                    ForEach(SortOrder.allCases) { Text($0.rawValue) }
                }
            } label: {
                Label("Sort: \\(sort.rawValue)", systemImage: "arrow.up.arrow.down")
            }
            .buttonStyle(.bordered)
            """
        ) {
            Menu {
                Picker("Sort by", selection: $sort) {
                    ForEach(SortOrder.allCases) { Text($0.rawValue) }
                }
            } label: {
                Label("Sort: \(sort.rawValue)", systemImage: "arrow.up.arrow.down")
            }
            .buttonStyle(.bordered)
        }

        ExampleCard(
            title: "Color tags in a menu",
            caption: "Inside a `Menu`, `.pickerStyle(.palette)` shows options as a row of tinted symbols, like tags in Files.",
            code: """
            @State private var color = "blue"

            Menu {
                Picker("Tag", selection: $color) {
                    Label("Red", systemImage: "circle.fill").tint(.red).tag("red")
                    Label("Orange", systemImage: "circle.fill").tint(.orange).tag("orange")
                    Label("Green", systemImage: "circle.fill").tint(.green).tag("green")
                    Label("Blue", systemImage: "circle.fill").tint(.blue).tag("blue")
                    Label("Purple", systemImage: "circle.fill").tint(.purple).tag("purple")
                }
                .pickerStyle(.palette)
                Button("Rename", systemImage: "pencil") {}
            } label: {
                Label("Tag: \\(color.capitalized)", systemImage: "tag")
            }
            .buttonStyle(.bordered)
            """,
            aside: Aside(.note, "On its own on iOS, `.palette` looks like a segmented control. The row of symbols only appears inside a `Menu`.")
        ) {
            Menu {
                Picker("Tag", selection: $color) {
                    Label("Red", systemImage: "circle.fill").tint(.red).tag("red")
                    Label("Orange", systemImage: "circle.fill").tint(.orange).tag("orange")
                    Label("Green", systemImage: "circle.fill").tint(.green).tag("green")
                    Label("Blue", systemImage: "circle.fill").tint(.blue).tag("blue")
                    Label("Purple", systemImage: "circle.fill").tint(.purple).tag("purple")
                }
                .pickerStyle(.palette)
                Button("Rename", systemImage: "pencil") {}
            } label: {
                Label("Tag: \(color.capitalized)", systemImage: "tag")
            }
            .buttonStyle(.bordered)
        }
    }
}

// MARK: - Options

private enum PickerStyleOption: DemoOption {
    case automatic, menu, segmented, wheel, inline, navigationLink, palette

    var label: String {
        switch self {
        case .automatic: ".automatic"
        case .menu: ".menu"
        case .segmented: ".segmented"
        case .wheel: ".wheel"
        case .inline: ".inline"
        case .navigationLink: ".navigationLink"
        case .palette: ".palette"
        }
    }
}

private enum PickerPlacement: DemoOption {
    case form, standalone

    var label: String {
        switch self {
        case .form: "In a Form"
        case .standalone: "On its own"
        }
    }
}

private struct PickerHidesLabel: ViewModifier {
    let isHidden: Bool

    func body(content: Content) -> some View {
        if isHidden { content.labelsHidden() } else { content }
    }
}

private extension View {
    @ViewBuilder
    func styled(_ style: PickerStyleOption) -> some View {
        switch style {
        case .automatic: pickerStyle(.automatic)
        case .menu: pickerStyle(.menu)
        case .segmented: pickerStyle(.segmented)
        case .wheel: pickerStyle(.wheel)
        case .inline: pickerStyle(.inline)
        case .navigationLink: pickerStyle(.navigationLink)
        case .palette: pickerStyle(.palette)
        }
    }
}
