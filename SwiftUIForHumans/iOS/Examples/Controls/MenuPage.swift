import SwiftUI

extension ComponentPage {
    static let menu = ComponentPage(
        id: "menu",
        title: "Menu",
        summary: "A button that reveals a list of actions when tapped.",
        category: .controls,
        symbol: "contextualmenu.and.cursorarrow",
        availability: ["iOS 14.0+", "macOS 11.0+", "visionOS 1.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/menu",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/pull-down-buttons",
        aliases: ["dropdown", "dropdown menu", "pull-down", "more button", "kebab", "ellipsis", "actions", "UIMenu", "popup menu", "overflow"],
        related: ["picker", "context-menu", "button", "toolbar"],
        notes: [
            "**A menu holds controls, not any view.** Inside it, use `Button`, `Toggle`, `Picker`, `Divider`, `Section`, and nested `Menu`s.",
            "**`Menu` opens from a button; `.contextMenu` opens from content.** Use [Context Menu](catalog://context-menu) for actions people find by long-pressing an item.",
        ],
        api: [
            APIItem("`Menu(_:systemImage:content:)`", "A menu with a text and icon label."),
            APIItem("`Menu { } label: { }`", "A menu with any view as its label."),
            APIItem("`primaryAction:`", "Tap runs an action; long-press opens the menu."),
            APIItem("`Section` / `Divider`", "Group related items, with or without a title."),
            APIItem("`role: .destructive`", "Shows an item in red."),
            APIItem("`.menuOrder(_:)`", "`.fixed` keeps your order when the menu opens upward."),
        ],
        guidelines: [
            Guideline(
                "Don't hide the main action in a menu.",
                "People should see the thing they came to do. Show it as a button, and put the less common actions in a More menu.",
                good: "Share is visible; extras are in the menu.",
                bad: "Every action is hidden behind one button."
            ) {
                HStack {
                    Button("Share", systemImage: "square.and.arrow.up") {}
                        .buttonStyle(.borderedProminent)
                    Menu {
                        Button("Duplicate") {}
                    } label: {
                        Label("More", systemImage: "ellipsis")
                            .labelStyle(.iconOnly)
                    }
                    .buttonStyle(.bordered)
                    .buttonBorderShape(.circle)
                }
                .controlSize(.large)
            } bad: {
                Menu("Actions") {
                    Button("Share") {}
                    Button("Duplicate") {}
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
            },
            Guideline(
                "Put at least three items in a menu.",
                "Opening a menu is an extra step. For one or two actions, show them as buttons instead."
            ),
            Guideline(
                "Put common items first, and group related ones.",
                "People read menus from the top. Use `Section` or `Divider` to separate groups like editing and sharing."
            ),
            Guideline(
                "Mark destructive items and confirm them.",
                "Give Delete `role: .destructive` so it turns red, place it last, and ask for confirmation with a `.confirmationDialog`."
            ),
        ]
    ) {
        Menu {
            Button("Copy", systemImage: "doc.on.doc") {}
        } label: {
            Label("Options", systemImage: "ellipsis.circle")
        }
        .buttonStyle(.bordered)
        .controlSize(.large)
    } content: { page in
        MenuDemo(page: page)
    }
}

private struct MenuConfig {
    var label: MenuLabelOption = .textAndIcon
    var style: MenuButtonStyleOption = .bordered
    var usesSections = true
    var includesSubmenu = false
    var includesDestructive = true
    var hasPrimaryAction = false
    var lastAction = ""
}

private struct MenuDemo: View {
    let page: ComponentPage

    var body: some View {
        DemoPage(
            page: page,
            initial: MenuConfig(),
            usage: """
            Menu("Options", systemImage: "ellipsis.circle") {
                Button("Copy", systemImage: "doc.on.doc") { copy() }
                Button("Duplicate", systemImage: "plus.square.on.square") { duplicate() }
                Divider()
                Button("Delete", systemImage: "trash", role: .destructive) { delete() }
            }
            """
        ) { $config in
            VStack(spacing: 16) {
                menu($config)
                    .styled(config.style)
                    .controlSize(.large)

                Text(config.lastAction.isEmpty ? (config.hasPrimaryAction ? "Tap to run, long-press for the menu" : "Tap the menu") : "Last action: \(config.lastAction)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        } controls: { $config in
            Section("Label") {
                OptionPicker("Label", selection: $config.label)
                OptionPicker("Style", selection: $config.style)
            }
            Section("Items") {
                Toggle("Sections", isOn: $config.usesSections)
                Toggle("Submenu", isOn: $config.includesSubmenu)
                Toggle("Destructive item", isOn: $config.includesDestructive)
                Toggle("Primary action", isOn: $config.hasPrimaryAction)
            }
        } code: { config in
            menuCode(config)
        } examples: {
            MenuExamples()
        }
    }

    @ViewBuilder
    private func menu(_ config: Binding<MenuConfig>) -> some View {
        let value = config.wrappedValue
        let items = MenuItems(config: value) { config.wrappedValue.lastAction = $0 }
        if value.hasPrimaryAction {
            Menu {
                items
            } label: {
                MenuDemoLabel(option: value.label)
            } primaryAction: {
                config.wrappedValue.lastAction = "Primary action"
            }
        } else {
            Menu {
                items
            } label: {
                MenuDemoLabel(option: value.label)
            }
        }
    }
}

private struct MenuDemoLabel: View {
    let option: MenuLabelOption

    var body: some View {
        switch option {
        case .text: Text("Options")
        case .textAndIcon: Label("Options", systemImage: "ellipsis.circle")
        case .iconOnly: Label("Options", systemImage: "ellipsis").labelStyle(.iconOnly)
        }
    }
}

private struct MenuItems: View {
    let config: MenuConfig
    let run: (String) -> Void

    var body: some View {
        if config.usesSections {
            Section {
                editItems
            }
            Section {
                shareItems
            }
        } else {
            editItems
            shareItems
        }
        if config.includesDestructive {
            Button("Delete", systemImage: "trash", role: .destructive) { run("Delete") }
        }
    }

    @ViewBuilder
    private var editItems: some View {
        Button("Copy", systemImage: "doc.on.doc") { run("Copy") }
        Button("Duplicate", systemImage: "plus.square.on.square") { run("Duplicate") }
    }

    @ViewBuilder
    private var shareItems: some View {
        Button("Share", systemImage: "square.and.arrow.up") { run("Share") }
        if config.includesSubmenu {
            Menu("Move to", systemImage: "folder") {
                Button("Inbox") { run("Move to Inbox") }
                Button("Archive") { run("Move to Archive") }
            }
        }
    }
}

private func menuCode(_ config: MenuConfig) -> String {
    var items: [String] = []
    let edit = [
        "Button(\"Copy\", systemImage: \"doc.on.doc\") { print(\"copy\") }",
        "Button(\"Duplicate\", systemImage: \"plus.square.on.square\") { print(\"duplicate\") }",
    ]
    var share = ["Button(\"Share\", systemImage: \"square.and.arrow.up\") { print(\"share\") }"]
    if config.includesSubmenu {
        share += [
            "Menu(\"Move to\", systemImage: \"folder\") {",
            "    Button(\"Inbox\") { print(\"move to inbox\") }",
            "    Button(\"Archive\") { print(\"move to archive\") }",
            "}",
        ]
    }
    if config.usesSections {
        items += ["Section {"] + edit.map { "    " + $0 } + ["}"]
        items += ["Section {"] + share.map { "    " + $0 } + ["}"]
    } else {
        items += edit + share
    }
    if config.includesDestructive {
        items.append("Button(\"Delete\", systemImage: \"trash\", role: .destructive) { print(\"delete\") }")
    }

    let label: [String]
    switch config.label {
    case .text: label = ["Text(\"Options\")"]
    case .textAndIcon: label = ["Label(\"Options\", systemImage: \"ellipsis.circle\")"]
    case .iconOnly: label = ["Label(\"Options\", systemImage: \"ellipsis\")", "    .labelStyle(.iconOnly)"]
    }

    var lines = ["Menu {"] + items.map { "    " + $0 } + ["} label: {"] + label.map { "    " + $0 }
    if config.hasPrimaryAction {
        lines += ["} primaryAction: {", "    print(\"Primary action\")"]
    }
    lines.append("}")
    if config.style != .automatic {
        lines.append(".buttonStyle(\(config.style.label))")
    }
    lines.append(".controlSize(.large)")
    return lines.enumerated()
        .map { index, line in index > 0 && line.hasPrefix(".") ? "    " + line : line }
        .joined(separator: "\n")
}

// MARK: - Examples

private struct MenuExamples: View {
    @State private var showsHidden = false
    @State private var layout = "Grid"
    @State private var message = "Nothing yet"

    var body: some View {
        ExampleCard(
            title: "More button",
            caption: "A `Menu` with an ellipsis label holds a screen's extra actions, at the end of a row or in a toolbar.",
            code: """
            @State private var showsHidden = false
            @State private var layout = "Grid"

            HStack {
                VStack(alignment: .leading) {
                    Text("Documents").font(.headline)
                    Text("\\(layout) view\\(showsHidden ? ", hidden files shown" : "")")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Menu {
                    Picker("View as", selection: $layout) {
                        Label("Grid", systemImage: "square.grid.2x2").tag("Grid")
                        Label("List", systemImage: "list.bullet").tag("List")
                    }
                    Toggle("Show Hidden Files", isOn: $showsHidden)
                    Divider()
                    Button("Select", systemImage: "checkmark.circle") {}
                } label: {
                    Image(systemName: "ellipsis")
                        .padding(8)
                }
                .buttonStyle(.glass)
                .buttonBorderShape(.circle)
            }
            """,
            aside: Aside(.note, "The `Picker` and `Toggle` inside show checkmarks on their own. Don't draw your own checkmarks.")
        ) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Documents").font(.headline)
                    Text("\(layout) view\(showsHidden ? ", hidden files shown" : "")")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Menu {
                    Picker("View as", selection: $layout) {
                        Label("Grid", systemImage: "square.grid.2x2").tag("Grid")
                        Label("List", systemImage: "list.bullet").tag("List")
                    }
                    Toggle("Show Hidden Files", isOn: $showsHidden)
                    Divider()
                    Button("Select", systemImage: "checkmark.circle") {}
                } label: {
                    Image(systemName: "ellipsis")
                        .padding(8)
                }
                .buttonStyle(.glass)
                .buttonBorderShape(.circle)
            }
            .frame(maxWidth: 360)
        }

        ExampleCard(
            title: "Split button with primaryAction",
            caption: "Add `primaryAction:` so a tap runs the most common action and a long-press offers the rest.",
            code: """
            @State private var message = "Nothing yet"

            VStack(spacing: 12) {
                Menu {
                    Button("New Folder", systemImage: "folder.badge.plus") { message = "New Folder" }
                    Button("Scan Document", systemImage: "doc.viewfinder") { message = "Scan Document" }
                } label: {
                    Label("New Note", systemImage: "square.and.pencil")
                } primaryAction: {
                    message = "New Note"
                }
                .buttonStyle(.borderedProminent)

                Text("Ran: \\(message)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            """,
            aside: Aside(.note, "Without `primaryAction:`, a tap opens the menu. With it, people may not discover the menu, so keep the extra actions optional.")
        ) {
            VStack(spacing: 12) {
                Menu {
                    Button("New Folder", systemImage: "folder.badge.plus") { message = "New Folder" }
                    Button("Scan Document", systemImage: "doc.viewfinder") { message = "Scan Document" }
                } label: {
                    Label("New Note", systemImage: "square.and.pencil")
                } primaryAction: {
                    message = "New Note"
                }
                .buttonStyle(.borderedProminent)

                Text("Ran: \(message)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }

        ExampleCard(
            title: "Sections with titles",
            caption: "Use `Section(\"Title\")` inside a menu to group related actions under a small heading.",
            code: """
            Menu("Sort & Filter") {
                Section("Sort By") {
                    Button("Date Modified") {}
                    Button("Name") {}
                }
                Section("Show") {
                    Button("Photos", systemImage: "photo") {}
                    Button("Videos", systemImage: "video") {}
                }
            }
            .menuOrder(.fixed)
            .buttonStyle(.bordered)
            """,
            aside: Aside(.note, "A menu that opens upward reverses its items so the first stays near your finger. `.menuOrder(.fixed)` keeps your order.")
        ) {
            Menu("Sort & Filter") {
                Section("Sort By") {
                    Button("Date Modified") {}
                    Button("Name") {}
                }
                Section("Show") {
                    Button("Photos", systemImage: "photo") {}
                    Button("Videos", systemImage: "video") {}
                }
            }
            .menuOrder(.fixed)
            .buttonStyle(.bordered)
        }
    }
}

// MARK: - Options

private enum MenuLabelOption: DemoOption {
    case text, textAndIcon, iconOnly

    var label: String {
        switch self {
        case .text: "Text"
        case .textAndIcon: "Text and icon"
        case .iconOnly: "Icon only"
        }
    }
}

private enum MenuButtonStyleOption: DemoOption {
    case automatic, bordered, borderedProminent, glass

    var label: String {
        switch self {
        case .automatic: ".automatic"
        case .bordered: ".bordered"
        case .borderedProminent: ".borderedProminent"
        case .glass: ".glass"
        }
    }
}

private extension View {
    @ViewBuilder
    func styled(_ style: MenuButtonStyleOption) -> some View {
        switch style {
        case .automatic: buttonStyle(.automatic)
        case .bordered: buttonStyle(.bordered)
        case .borderedProminent: buttonStyle(.borderedProminent)
        case .glass: buttonStyle(.glass)
        }
    }
}
