import SwiftUI

extension ComponentPage {
    static let contextMenu = ComponentPage(
        id: "context-menu",
        title: "Context menus",
        summary: "A menu of actions for the item people Control-click or right-click.",
        category: .menus,
        kind: .modifier,
        symbol: "contextualmenu.and.cursorarrow",
        availability: ["macOS 10.15+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/view/contextmenu(menuitems:)",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/context-menus",
        aliases: ["right click", "right-click", "control-click", "secondary click", "contextual menu", "contextmenu", "oncontextmenu", "NSMenu", "menu(for:)", "forSelectionType", "primaryAction", "double-click"],
        related: ["commands", "menu", "list-styles", "table"],
        notes: [
            "**Every way to open it works.** Control-click and a secondary click, on a mouse or a trackpad, open the same menu.",
            "**An item menu needs a container with selection.** `contextMenu(forSelectionType:)` never opens outside a `List` or `Table` that supports selection.",
        ],
        api: [
            APIItem("`.contextMenu { }`", "A menu for one view."),
            APIItem("`.contextMenu(forSelectionType:)`", "A menu for the selected rows of a list or table."),
            APIItem("`primaryAction:`", "Runs on double-click, like opening an item."),
            APIItem("`Menu(_:)`", "A submenu inside the context menu."),
            APIItem("`Divider()`", "A separator between groups of items."),
            APIItem("`Button(role: .destructive)`", "Marks an item that deletes or removes."),
        ],
        guidelines: [
            Guideline(
                "Keep it short, with the commands people need here.",
                "A context menu is a shortcut to the likely next step, not a list of everything. Leave rare and advanced commands in the menu bar.",
                good: "A few actions for this file.",
                bad: "Every command the app has."
            ) {
                MenusInputMenuDrawing(rows: [
                    .item("Open"),
                    .item("Rename…"),
                    .divider,
                    .item("Move to Trash"),
                ], width: 180)
            } bad: {
                MenusInputMenuDrawing(rows: [
                    .item("Open"),
                    .item("Rename…"),
                    .item("Page Setup…"),
                    .item("Check Spelling"),
                    .item("Customize Toolbar…"),
                    .divider,
                    .item("Move to Trash"),
                ], width: 180)
            },
            Guideline(
                "Hide items that don't apply. Don't dim them.",
                "Unlike the menu bar, a context menu shows only what works for this item. Cut, Copy, and Paste are the exception: they can appear dimmed.",
                good: "Only actions that work on this file.",
                bad: "A dimmed item that can't be used here."
            ) {
                MenusInputMenuDrawing(rows: [
                    .item("Open"),
                    .item("Rename…"),
                    .divider,
                    .item("Move to Trash"),
                ], width: 180)
            } bad: {
                MenusInputMenuDrawing(rows: [
                    .item("Open"),
                    .item("Rename…"),
                    .item("Empty Trash", isEnabled: false),
                    .divider,
                    .item("Move to Trash"),
                ], width: 180)
            },
            Guideline(
                "Leave keyboard shortcuts out.",
                "The context menu is already the shortcut. Show the keys in the menu bar, where people learn them.",
                good: "Just the commands.",
                bad: "Shortcuts crowd the menu."
            ) {
                MenusInputMenuDrawing(rows: [
                    .item("Open"),
                    .item("Duplicate"),
                ], width: 180)
            } bad: {
                MenusInputMenuDrawing(rows: [
                    .item("Open", "⌘O"),
                    .item("Duplicate", "⌘D"),
                ], width: 180)
            },
            Guideline(
                "Put every item in the menu bar too.",
                "A context menu is hidden until people go looking. The same commands belong in the menu bar, where everyone can find them."
            ),
            Guideline(
                "Keep submenus to one level.",
                "One submenu with a clear title can shorten a menu. A submenu inside a submenu is hard to reach."
            ),
        ]
    ) {
        MenusInputMenuDrawing(rows: [
            .item("Open"),
            .item("Rename…"),
            .divider,
            .item("Move to Trash"),
        ], width: 170)
        .scaleEffect(0.9)
    } content: { page in
        MacContextMenuDemo(page: page)
    }
}

private struct MacContextMenuConfig {
    var showsIcons = true
    var groups = true
    var submenu = true
    var delete = true
    var lastChoice = "Control-click the file."
}

private struct MacContextMenuDemo: View {
    let page: ComponentPage

    var body: some View {
        DemoPage(
            page: page,
            initial: MacContextMenuConfig(),
            previewHeight: 220,
            usage: """
            FileIcon(file)
                .contextMenu {
                    Button("Open") { open(file) }
                    Button("Rename…") { rename(file) }
                    Divider()
                    Button("Move to Trash", role: .destructive) {
                        trash(file)
                    }
                }
            """,
            usageNote: Aside(.note, "The menu opens where people click, so it needs no button of its own. That also means people can't see it's there: put the same commands in the menu bar.")
        ) { $config in
            VStack(spacing: 14) {
                VStack(spacing: 6) {
                    Image(systemName: "doc.text")
                        .font(.system(size: 52, weight: .light))
                        .foregroundStyle(.tint)
                    Text("Chapter 1.txt")
                        .font(.callout)
                }
                .padding(12)
                .contentShape(.rect)
                .contextMenu {
                    ContextMenuItems(config: $config)
                }
                Text(config.lastChoice)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        } controls: { $config in
            Section("Items") {
                Toggle("Icons", isOn: $config.showsIcons)
                Toggle("Separators", isOn: $config.groups)
                Toggle("Submenu", isOn: $config.submenu)
                Toggle("Move to Trash", isOn: $config.delete)
            }
        } code: { config in
            func item(_ title: String, _ symbol: String, action: String, role: Bool = false) -> String {
                let roleCode = role ? ", role: .destructive" : ""
                return config.showsIcons
                    ? "    Button(\(swiftString(title)), systemImage: \"\(symbol)\"\(roleCode)) { \(action) }"
                    : "    Button(\(swiftString(title))\(roleCode)) { \(action) }"
            }
            var lines = ["FileIcon(file)", "    .contextMenu {"]
            var body = [
                item("Open", "arrow.up.forward.app", action: "open(file)"),
                item("Rename…", "pencil", action: "rename(file)"),
            ]
            if config.submenu {
                body.append("    Menu(\"Move To\") {")
                body.append("        Button(\"Drafts\") { move(file, to: .drafts) }")
                body.append("        Button(\"Archive\") { move(file, to: .archive) }")
                body.append("    }")
            }
            if config.delete {
                if config.groups { body.append("    Divider()") }
                body.append(item("Move to Trash", "trash", action: "trash(file)", role: true))
            }
            lines += body.map { "    " + $0 }
            lines.append("    }")
            return lines.joined(separator: "\n")
        } examples: {
            MacContextMenuExamples()
        }
    }
}

private struct ContextMenuItems: View {
    @Binding var config: MacContextMenuConfig

    var body: some View {
        item("Open", "arrow.up.forward.app")
        item("Rename…", "pencil")
        if config.submenu {
            Menu("Move To") {
                Button("Drafts") { config.lastChoice = "Move To > Drafts" }
                Button("Archive") { config.lastChoice = "Move To > Archive" }
            }
        }
        if config.delete {
            if config.groups { Divider() }
            item("Move to Trash", "trash", role: .destructive)
        }
    }

    @ViewBuilder
    private func item(_ title: String, _ symbol: String, role: ButtonRole? = nil) -> some View {
        if config.showsIcons {
            Button(title, systemImage: symbol, role: role) { config.lastChoice = "Chose \(title)" }
        } else {
            Button(title, role: role) { config.lastChoice = "Chose \(title)" }
        }
    }
}

// MARK: - Examples

private struct Chapter: Identifiable, Hashable {
    let id: Int
    let title: String
    let words: Int
}

private let sampleChapters = [
    Chapter(id: 1, title: "The Harbor", words: 3_120),
    Chapter(id: 2, title: "Low Tide", words: 2_480),
    Chapter(id: 3, title: "The Lighthouse", words: 4_015),
    Chapter(id: 4, title: "Fog", words: 1_760),
]

private struct MacContextMenuExamples: View {
    @State private var listSelection = Set<Chapter.ID>()
    @State private var listStatus = "Select rows, then Control-click."
    @State private var tableSelection = Set<Chapter.ID>()
    @State private var tableStatus = "Control-click a row, or double-click one."

    var body: some View {
        ExampleCard(
            title: "Menus for the selection in a list",
            caption: "`contextMenu(forSelectionType:)` gives you the rows the menu is for: the clicked or selected ones, or none for empty space.",
            code: """
            @State private var selection = Set<Chapter.ID>()

            List(chapters, selection: $selection) { chapter in
                Text(chapter.title)
            }
            .contextMenu(forSelectionType: Chapter.ID.self) { ids in
                if ids.isEmpty {
                    Button("New Chapter") { addChapter() }
                } else if ids.count == 1 {
                    Button("Rename…") { rename(ids) }
                    Button("Delete", role: .destructive) { delete(ids) }
                } else {
                    Button("Merge \\(ids.count) Chapters") { merge(ids) }
                    Button("Delete \\(ids.count) Chapters", role: .destructive) { delete(ids) }
                }
            }
            """,
            minHeight: 260,
            aside: Aside(.note, "Clicking empty space gives an empty set, even while rows are selected. Use it for commands like New that don't need an item.")
        ) {
            VStack(spacing: 10) {
                List(sampleChapters, selection: $listSelection) { chapter in
                    Text(chapter.title)
                }
                .contextMenu(forSelectionType: Chapter.ID.self) { ids in
                    if ids.isEmpty {
                        Button("New Chapter") { listStatus = "New Chapter" }
                    } else if ids.count == 1 {
                        Button("Rename…") { listStatus = "Rename one chapter" }
                        Button("Delete", role: .destructive) { listStatus = "Delete one chapter" }
                    } else {
                        Button("Merge \(ids.count) Chapters") { listStatus = "Merge \(ids.count) chapters" }
                        Button("Delete \(ids.count) Chapters", role: .destructive) { listStatus = "Delete \(ids.count) chapters" }
                    }
                }
                .listStyle(.bordered)
                .frame(width: 320, height: 124)
                .clipShape(.rect(cornerRadius: 8))
                Text(listStatus)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }

        ExampleCard(
            title: "Double-click to open a table row",
            caption: "Add `primaryAction:` to run something on double-click, like opening the row in its own window. The same menu works on a `Table`.",
            code: """
            @State private var selection = Set<Chapter.ID>()
            @Environment(\\.openWindow) private var openWindow

            Table(chapters, selection: $selection) {
                TableColumn("Chapter", value: \\.title)
                TableColumn("Words") { Text($0.words, format: .number) }
            }
            .contextMenu(forSelectionType: Chapter.ID.self) { ids in
                Button("Open in New Window") {
                    ids.forEach { openWindow(value: $0) }
                }
            } primaryAction: { ids in
                ids.forEach { openWindow(value: $0) }
            }
            """,
            minHeight: 240
        ) {
            VStack(spacing: 10) {
                Table(sampleChapters, selection: $tableSelection) {
                    TableColumn("Chapter", value: \.title)
                    TableColumn("Words") { Text($0.words, format: .number) }
                }
                .contextMenu(forSelectionType: Chapter.ID.self) { ids in
                    Button("Open in New Window") { tableStatus = "Open \(ids.count) in new windows" }
                } primaryAction: { ids in
                    tableStatus = "Double-clicked: open \(ids.count) \(ids.count == 1 ? "chapter" : "chapters")"
                }
                .frame(width: 380, height: 136)
                .clipShape(.rect(cornerRadius: 8))
                Text(tableStatus)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }

        Aside(.note, "Try it in this app: Control-click a page in the sidebar. Its Open in New Window item comes from `contextMenu(forSelectionType:)`.")
    }
}
