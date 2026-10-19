import SwiftUI

extension ComponentPage {
    static let menu = ComponentPage(
        id: "menu",
        title: "Menu & pull-down",
        summary: "A pull-down button that opens a menu of commands related to it.",
        category: .controls,
        symbol: "contextualmenu.and.cursorarrow",
        availability: ["macOS 11.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/menu",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/pull-down-buttons",
        aliases: ["pull-down button", "pulldown", "dropdown menu", "NSPopUpButton pullsDown", "split button", "primaryAction", "menu button", "menuStyle", "menuIndicator", "actions menu", "more button", "ellipsis menu"],
        related: ["picker", "button", "context-menu", "commands", "toolbar", "control-group"],
        notes: [
            "**Menus hold buttons, toggles, and pickers.** Put them in the content closure; `Divider()` and `Section` split them into groups.",
            "**A pop-up picker inside a menu becomes a submenu.** Add `.pickerStyle(.inline)` to list its options right in the menu instead.",
        ],
        api: [
            APIItem("`Menu(_:content:)`", "A pull-down button with a title."),
            APIItem("`Menu(content:label:)`", "A custom label, like a `Label`."),
            APIItem("`Menu(_:content:primaryAction:)`", "Click runs an action; the arrow opens the menu."),
            APIItem("`.menuStyle(.button)`", "Draws the menu as a button."),
            APIItem("`.menuIndicator(.hidden)`", "Hides the menu's arrow."),
            APIItem("`Section`, `Divider()`", "Group related items."),
            APIItem("`Button(_:role: .destructive)`", "Marks a dangerous item."),
        ],
        guidelines: [
            Guideline(
                "Keep a pull-down's items about the button's job.",
                "An Add button can list what to add; a Sort button can list what to sort by. For picking one of several values, use a pop-up [Picker](catalog://picker)."
            ),
            Guideline(
                "Don't hide a window's main actions in one menu.",
                "People should see the commands they use most. Keep them as buttons, and save the menu for the rest.",
                good: "New is one click away; less common actions wait in a menu.",
                bad: "Every action is behind one menu."
            ) {
                MacWindowFrame(title: "Notes", width: 270, height: 90) {
                    Color.clear
                } toolbar: {
                    Button("New Note", systemImage: "square.and.pencil") {}
                        .labelStyle(.iconOnly)
                        .buttonStyle(.borderless)
                    Menu("More", systemImage: "ellipsis.circle") {
                        Button("Duplicate") {}
                        Button("Export…") {}
                    }
                    .labelStyle(.iconOnly)
                    .menuStyle(.button)
                    .buttonStyle(.borderless)
                    .menuIndicator(.hidden)
                    .fixedSize()
                }
            } bad: {
                MacWindowFrame(title: "Notes", width: 270, height: 90) {
                    Color.clear
                } toolbar: {
                    Menu("More", systemImage: "ellipsis.circle") {
                        Button("New Note") {}
                        Button("Duplicate") {}
                        Button("Export…") {}
                    }
                    .labelStyle(.iconOnly)
                    .menuStyle(.button)
                    .buttonStyle(.borderless)
                    .menuIndicator(.hidden)
                    .fixedSize()
                }
            },
            Guideline(
                "Make the menu worth opening.",
                "Opening a menu is an extra step, so aim for at least three items. With one or two, show them as buttons or toggles instead. Very long menus are slow to scan, too."
            ),
            Guideline(
                "Write items in title case, and add an ellipsis when more input follows.",
                "Start with a verb, leave out articles like “the”, and end with “…” when the item opens a window or asks a question, as in Export…."
            ),
            Guideline(
                "Mark destructive items.",
                "Give a delete item `role: .destructive`, and ask people to confirm before you remove anything."
            ),
        ]
    ) {
        VStack(spacing: 12) {
            Menu("Add") {
                Button("Folder") {}
            }
            .fixedSize()
            Menu {
                Button("Folder") {}
            } label: {
                Label("Sort", systemImage: "arrow.up.arrow.down")
            }
            .fixedSize()
        }
    } content: { page in
        MacMenuDemo(page: page)
    }
}

private struct MacMenuConfig {
    var title = "Add"
    var showsIcon = false
    var hasPrimaryAction = false
    var style: MacMenuStyleOption = .automatic
    var indicator: MacMenuIndicatorOption = .automatic
    var size: MacMenuSizeOption = .regular
    var isDisabled = false
}

private struct MacMenuDemo: View {
    let page: ComponentPage
    @State private var lastAction = "Nothing chosen yet"

    var body: some View {
        DemoPage(
            page: page,
            initial: MacMenuConfig(),
            usage: """
            Menu("Add") {
                Button("New Folder") { addFolder() }
                Button("New Smart Folder") { addSmartFolder() }
                Divider()
                Button("Import…") { importFiles() }
            }
            """,
            usageNote: Aside(.note, "Each item is an ordinary `Button`. Choosing one runs its action and closes the menu.")
        ) { $config in
            VStack(spacing: 16) {
                MacDemoMenu(config: config) { lastAction = $0 }
                    .fixedSize()
                Text(lastAction)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        } controls: { $config in
            Section("Content") {
                TextField("Title", text: $config.title)
                Toggle("Show icon", isOn: $config.showsIcon)
                Toggle("Primary action", isOn: $config.hasPrimaryAction)
            }
            Section("Appearance") {
                OptionPicker("Style", selection: $config.style)
                OptionPicker("Indicator", selection: $config.indicator)
                OptionPicker("Size", selection: $config.size)
                Toggle("Disabled", isOn: $config.isDisabled)
            }
        } code: { config in
            var head = "Menu(\(swiftString(config.title))"
            if config.showsIcon {
                head += ", systemImage: \"plus\""
            }
            var lines = [head + ") {"]
            lines.append("    Button(\"New Folder\") { addFolder() }")
            lines.append("    Button(\"New Smart Folder\") { addSmartFolder() }")
            lines.append("    Divider()")
            lines.append("    Button(\"Import…\") { importFiles() }")
            if config.hasPrimaryAction {
                lines.append("} primaryAction: {")
                lines.append("    addDocument()")
            }
            lines.append("}")
            switch config.style {
            case .automatic: break
            case .button:
                lines.append(".menuStyle(.button)")
            case .borderless:
                lines.append(".menuStyle(.button)")
                lines.append(".buttonStyle(.borderless)")
            }
            if config.indicator != .automatic {
                lines.append(".menuIndicator(\(config.indicator.label))")
            }
            if config.size != .regular {
                lines.append(".controlSize(\(config.size.label))")
            }
            if config.isDisabled {
                lines.append(".disabled(true)")
            }
            return lines.joined(separator: "\n")
        } examples: {
            MacMenuExamples()
        }
    }
}

/// The demo's menu, built from the current options.
private struct MacDemoMenu: View {
    let config: MacMenuConfig
    let choose: (String) -> Void

    var body: some View {
        menu
            .styled(config.style)
            .modifier(MacMenuIndicator(option: config.indicator))
            .controlSize(config.size.size)
            .disabled(config.isDisabled)
    }

    @ViewBuilder private var items: some View {
        Button("New Folder") { choose("New Folder") }
        Button("New Smart Folder") { choose("New Smart Folder") }
        Divider()
        Button("Import…") { choose("Import…") }
    }

    @ViewBuilder private var menu: some View {
        switch (config.showsIcon, config.hasPrimaryAction) {
        case (false, false):
            Menu(config.title) { items }
        case (true, false):
            Menu(config.title, systemImage: "plus") { items }
        case (false, true):
            Menu(config.title) { items } primaryAction: { choose("Primary action") }
        case (true, true):
            Menu {
                items
            } label: {
                Label(config.title, systemImage: "plus")
            } primaryAction: {
                choose("Primary action")
            }
        }
    }
}

// MARK: - Examples

private struct MacMenuExamples: View {
    @State private var lastAction = "Click the button, or its arrow"
    @State private var sortKey = "Date"
    @State private var showsPreview = true

    var body: some View {
        ExampleCard(
            title: "A split button with a primary action",
            caption: "Add `primaryAction:` and a click on the button runs it right away. The menu opens from the arrow, for the variations.",
            code: """
            Menu("New Document") {
                Button("From Template…") { newFromTemplate() }
                Button("From Clipboard") { newFromClipboard() }
            } primaryAction: {
                newDocument()
            }
            """,
            minHeight: 140
        ) {
            VStack(spacing: 12) {
                Menu("New Document") {
                    Button("From Template…") { lastAction = "From Template…" }
                    Button("From Clipboard") { lastAction = "From Clipboard" }
                } primaryAction: {
                    lastAction = "New Document"
                }
                .fixedSize()
                Text(lastAction)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }

        ExampleCard(
            title: "Sections, toggles, and a picker",
            caption: "Group items with `Section`. A `Toggle` shows whether an option is on, and an `.inline` picker lists its choices in place.",
            code: """
            @State private var sortKey = "Date"
            @State private var showsPreview = true

            Menu("View Options", systemImage: "slider.horizontal.3") {
                Section("Sort By") {
                    Picker("Sort By", selection: $sortKey) {
                        Text("Date").tag("Date")
                        Text("Name").tag("Name")
                        Text("Size").tag("Size")
                    }
                    .pickerStyle(.inline)
                }
                Section {
                    Toggle("Show Preview", isOn: $showsPreview)
                }
            }
            """,
            minHeight: 140
        ) {
            VStack(spacing: 12) {
                Menu("View Options", systemImage: "slider.horizontal.3") {
                    Section("Sort By") {
                        Picker("Sort By", selection: $sortKey) {
                            Text("Date").tag("Date")
                            Text("Name").tag("Name")
                            Text("Size").tag("Size")
                        }
                        .pickerStyle(.inline)
                    }
                    Section {
                        Toggle("Show Preview", isOn: $showsPreview)
                    }
                }
                .fixedSize()
                Text("Sorted by \(sortKey.lowercased()), preview \(showsPreview ? "on" : "off")")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }

        ExampleCard(
            title: "Items with a subtitle",
            caption: "Give a menu button two `Text` views: the first is the title, the second a subtitle under it.",
            code: """
            Menu("Export") {
                Button(action: exportPDF) {
                    Text("PDF")
                    Text("Best for sharing and printing")
                }
                Button(action: exportMarkdown) {
                    Text("Markdown")
                    Text("Plain text with formatting marks")
                }
            }
            """,
            minHeight: 120
        ) {
            Menu("Export") {
                Button {} label: {
                    Text("PDF")
                    Text("Best for sharing and printing")
                }
                Button {} label: {
                    Text("Markdown")
                    Text("Plain text with formatting marks")
                }
            }
            .fixedSize()
        }

        ExampleCard(
            title: "A borderless menu",
            caption: "For a quieter menu inside content, use `.menuStyle(.button)` with `.buttonStyle(.borderless)`.",
            code: """
            Menu("Sort", systemImage: "arrow.up.arrow.down") {
                Button("Date") { sort(by: .date) }
                Button("Name") { sort(by: .name) }
                Button("Size") { sort(by: .size) }
            }
            .menuStyle(.button)
            .buttonStyle(.borderless)
            """,
            minHeight: 120,
            aside: Aside(.note, "`.menuStyle(.borderlessButton)` is deprecated. This pair of modifiers replaces it.")
        ) {
            Menu("Sort", systemImage: "arrow.up.arrow.down") {
                Button("Date") {}
                Button("Name") {}
                Button("Size") {}
            }
            .menuStyle(.button)
            .buttonStyle(.borderless)
            .fixedSize()
        }
    }
}

// MARK: - Options

private enum MacMenuStyleOption: DemoOption {
    case automatic, button, borderless

    var label: String {
        switch self {
        case .automatic: ".automatic"
        case .button: ".button"
        case .borderless: ".button, borderless"
        }
    }
}

private enum MacMenuIndicatorOption: DemoOption {
    case automatic, visible, hidden

    var label: String {
        switch self {
        case .automatic: ".automatic"
        case .visible: ".visible"
        case .hidden: ".hidden"
        }
    }

    var visibility: Visibility {
        switch self {
        case .automatic: .automatic
        case .visible: .visible
        case .hidden: .hidden
        }
    }
}

private enum MacMenuSizeOption: DemoOption {
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

private struct MacMenuIndicator: ViewModifier {
    let option: MacMenuIndicatorOption

    func body(content: Content) -> some View {
        if option == .automatic {
            content
        } else {
            content.menuIndicator(option.visibility)
        }
    }
}

private extension View {
    @ViewBuilder
    func styled(_ style: MacMenuStyleOption) -> some View {
        switch style {
        case .automatic: menuStyle(.automatic)
        case .button: menuStyle(.button)
        case .borderless: menuStyle(.button).buttonStyle(.borderless)
        }
    }
}
