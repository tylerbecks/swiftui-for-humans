import SwiftUI

extension ComponentPage {
    static let contextMenu = ComponentPage(
        id: "context-menu",
        title: "Context Menu",
        summary: "A menu of actions that appears when people touch and hold a view.",
        category: .presentation,
        kind: .modifier,
        symbol: "contextualmenu.and.cursorarrow",
        availability: ["iOS 13.0+", "macOS 10.15+", "visionOS 1.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/view/contextmenu(menuitems:)",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/context-menus",
        aliases: ["long press", "right click", "oncontextmenu", "press and hold", "peek", "UIContextMenuInteraction", "3D touch", "haptic touch", "secondary menu"],
        related: ["menu", "popover", "swipe-actions", "confirmation-dialog"],
        notes: [
            "**It's the web's right-click menu.** People open it by touching and holding on iPhone, or with a secondary click on iPad with a trackpad.",
            "**On a `List` row, the whole row lifts.** For multiple selected rows, `.contextMenu(forSelectionType:)` builds one menu for all of them.",
        ],
        api: [
            APIItem("`.contextMenu { }`", "Attaches a menu of buttons to any view."),
            APIItem("`.contextMenu { } preview: { }`", "Shows a custom preview above the menu."),
            APIItem("`Section { }`", "Groups items with a separator."),
            APIItem("`Menu(_:content:)`", "A submenu inside the context menu."),
            APIItem("`Button(role: .destructive)`", "A red item, like Delete."),
            APIItem("`.contextMenu(forSelectionType:)`", "One menu for selected `List` rows."),
        ],
        guidelines: [
            Guideline(
                "Hide items that don't apply.",
                "A context menu shows only what you can do right now. Dimmed items make it longer without helping.",
                good: "Only the actions that work here.",
                bad: "Dimmed items add clutter."
            ) {
                ContextGuidelineSample(showsUnavailable: false)
            } bad: {
                ContextGuidelineSample(showsUnavailable: true)
            },
            Guideline(
                "Offer the same actions somewhere visible.",
                "People can't see a context menu until they find it. Every item should also be in a toolbar, a button, or the detail screen."
            ),
            Guideline(
                "Keep it short, with the most-used items first.",
                "A few relevant actions are quick to scan. Leave rare and advanced commands out."
            ),
            Guideline(
                "Use one level of submenu at most.",
                "A submenu inside a submenu is hard to navigate. Give a submenu a title that predicts what's inside, like “Move to”."
            ),
        ]
    ) {
        ContextThumbnail()
    } content: { page in
        ContextMenuDemo(page: page)
    }
}

private struct ContextConfig {
    var preview = false
    var sections = true
    var submenu = true
    var destructive = true
    var icons = true
    var result = "Touch and hold the card"
}

private struct ContextMenuDemo: View {
    let page: ComponentPage

    var body: some View {
        DemoPage(
            page: page,
            initial: ContextConfig(),
            previewHeight: 260,
            usage: """
            Image(systemName: "photo")
                .font(.largeTitle)
                .contextMenu {
                    Button("Copy", systemImage: "doc.on.doc") {}
                    Button("Share", systemImage: "square.and.arrow.up") {}
                    Button("Delete", systemImage: "trash", role: .destructive) {}
                }
            """,
            usageNote: Aside(.note, "Items are ordinary `Button`s. Group them with `Section`, and nest a `Menu` for a submenu.")
        ) { $config in
            VStack(spacing: 14) {
                ContextTarget(config: $config)
                Text(config.result)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        } controls: { $config in
            Section("Menu") {
                Toggle("Icons", isOn: $config.icons)
                Toggle("Sections", isOn: $config.sections)
                Toggle("Submenu", isOn: $config.submenu)
                Toggle("Destructive item", isOn: $config.destructive)
            }
            Section("Preview") {
                Toggle("Custom preview", isOn: $config.preview)
            }
        } code: { config in
            code(for: config)
        } examples: {
            ContextExamples()
        }
    }

    private func code(for config: ContextConfig) -> String {
        func button(_ title: String, _ symbol: String, destructive: Bool = false) -> String {
            let role = destructive ? ", role: .destructive" : ""
            return config.icons
                ? "Button(\"\(title)\", systemImage: \"\(symbol)\"\(role)) {}"
                : (destructive ? "Button(\"\(title)\", role: .destructive) {}" : "Button(\"\(title)\") {}")
        }
        var items: [String] = []
        let first = [button("Copy", "doc.on.doc"), button("Share", "square.and.arrow.up")]
        if config.sections {
            items.append("Section {")
            items += first.map { "    " + $0 }
            items.append("}")
        } else {
            items += first
        }
        if config.submenu {
            items += [
                "Menu(\"Move to\"\(config.icons ? ", systemImage: \"folder\"" : "")) {",
                "    Button(\"Favorites\") {}",
                "    Button(\"Archive\") {}",
                "}",
            ]
        }
        if config.destructive {
            if config.sections {
                items += ["Section {", "    " + button("Delete", "trash", destructive: true), "}"]
            } else {
                items.append(button("Delete", "trash", destructive: true))
            }
        }
        var lines = [
            "RoundedRectangle(cornerRadius: 20)",
            "    .fill(.orange.gradient)",
            "    .frame(width: 160, height: 120)",
            "    .overlay {",
            "        Image(systemName: \"photo\")",
            "            .font(.largeTitle)",
            "            .foregroundStyle(.white)",
            "    }",
            "    .contextMenu {",
        ]
        lines += items.map { "        " + $0 }
        if config.preview {
            lines += [
                "    } preview: {",
                "        Text(\"Sunset.jpg\")",
                "            .font(.title.bold())",
                "            .padding(40)",
                "            .background(.orange.gradient)",
            ]
        }
        lines.append("    }")
        return lines.joined(separator: "\n")
    }
}

private struct ContextTarget: View {
    @Binding var config: ContextConfig

    var body: some View {
        let card = RoundedRectangle(cornerRadius: 20)
            .fill(.orange.gradient)
            .frame(width: 160, height: 120)
            .overlay {
                Image(systemName: "photo")
                    .font(.largeTitle)
                    .foregroundStyle(.white)
            }
        if config.preview {
            card.contextMenu {
                items
            } preview: {
                Text("Sunset.jpg")
                    .font(.title.bold())
                    .padding(40)
                    .background(.orange.gradient)
            }
        } else {
            card.contextMenu {
                items
            }
        }
    }

    @ViewBuilder
    private var items: some View {
        if config.sections {
            Section {
                item("Copy", "doc.on.doc")
                item("Share", "square.and.arrow.up")
            }
        } else {
            item("Copy", "doc.on.doc")
            item("Share", "square.and.arrow.up")
        }
        if config.submenu {
            Menu {
                Button("Favorites") { config.result = "Moved to Favorites" }
                Button("Archive") { config.result = "Moved to Archive" }
            } label: {
                if config.icons {
                    Label("Move to", systemImage: "folder")
                } else {
                    Text("Move to")
                }
            }
        }
        if config.destructive {
            if config.sections {
                Section {
                    item("Delete", "trash", destructive: true)
                }
            } else {
                item("Delete", "trash", destructive: true)
            }
        }
    }

    @ViewBuilder
    private func item(_ title: String, _ symbol: String, destructive: Bool = false) -> some View {
        let action = { config.result = "Tapped \(title)" }
        if config.icons {
            Button(title, systemImage: symbol, role: destructive ? .destructive : nil, action: action)
        } else {
            Button(title, role: destructive ? .destructive : nil, action: action)
        }
    }
}

private struct ContextThumbnail: View {
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            RoundedRectangle(cornerRadius: 12)
                .fill(.orange.gradient)
                .frame(width: 70, height: 56)
                .overlay {
                    Image(systemName: "photo")
                        .foregroundStyle(.white)
                }
            VStack(alignment: .leading, spacing: 0) {
                ForEach([("Copy", "doc.on.doc"), ("Share", "square.and.arrow.up"), ("Delete", "trash")], id: \.0) { title, symbol in
                    HStack {
                        Text(title)
                        Spacer()
                        Image(systemName: symbol)
                    }
                    .foregroundStyle(title == "Delete" ? AnyShapeStyle(.red) : AnyShapeStyle(.primary))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    if title != "Delete" { Divider() }
                }
            }
            .font(.footnote)
            .frame(width: 130)
            .glassEffect(.regular, in: .rect(cornerRadius: 16))
        }
    }
}

// MARK: - Examples

private struct ContextExamples: View {
    @State private var contacts = ["Maya", "Leo", "Priya"]
    @State private var favorites: Set<String> = []

    var body: some View {
        ExampleCard(
            title: "Context menu on list rows",
            caption: "Add `.contextMenu` to each row for actions on that item. Touch and hold a name to try it.",
            code: """
            @State private var contacts = ["Maya", "Leo", "Priya"]
            @State private var favorites: Set<String> = []

            List(contacts, id: \\.self) { name in
                Label(name, systemImage: favorites.contains(name) ? "star.fill" : "person")
                    .contextMenu {
                        Button(favorites.contains(name) ? "Unfavorite" : "Favorite", systemImage: "star") {
                            if favorites.contains(name) { favorites.remove(name) } else { favorites.insert(name) }
                        }
                        Button("Remove", systemImage: "trash", role: .destructive) {
                            contacts.removeAll { $0 == name }
                        }
                    }
            }
            """,
            minHeight: 200,
            aside: Aside(.note, "The menu can read the row's value, so `name` tells each button which contact to change.")
        ) {
            List(contacts, id: \.self) { name in
                Label(name, systemImage: favorites.contains(name) ? "star.fill" : "person")
                    .contextMenu {
                        Button(favorites.contains(name) ? "Unfavorite" : "Favorite", systemImage: "star") {
                            if favorites.contains(name) { favorites.remove(name) } else { favorites.insert(name) }
                        }
                        Button("Remove", systemImage: "trash", role: .destructive) {
                            contacts.removeAll { $0 == name }
                        }
                    }
            }
            .frame(height: 190)
            .scrollDisabled(true)
            .overlay {
                if contacts.isEmpty {
                    Button("Restore contacts") { contacts = ["Maya", "Leo", "Priya"] }
                }
            }
        }

        ExampleCard(
            title: "Custom preview",
            caption: "Pass a `preview:` closure to show a larger view above the menu, like Photos does.",
            code: """
            Image(systemName: "photo")
                .font(.largeTitle)
                .frame(width: 120, height: 90)
                .background(.teal.gradient, in: .rect(cornerRadius: 16))
                .foregroundStyle(.white)
                .contextMenu {
                    Button("Share", systemImage: "square.and.arrow.up") {}
                } preview: {
                    Text("Beach.jpg")
                        .font(.title.bold())
                        .foregroundStyle(.white)
                        .frame(width: 280, height: 200)
                        .background(.teal.gradient)
                }
            """,
            minHeight: 180
        ) {
            Image(systemName: "photo")
                .font(.largeTitle)
                .frame(width: 120, height: 90)
                .background(.teal.gradient, in: .rect(cornerRadius: 16))
                .foregroundStyle(.white)
                .contextMenu {
                    Button("Share", systemImage: "square.and.arrow.up") {}
                } preview: {
                    Text("Beach.jpg")
                        .font(.title.bold())
                        .foregroundStyle(.white)
                        .frame(width: 280, height: 200)
                        .background(.teal.gradient)
                }
        }
    }
}

/// A message bubble with a context menu, with or without dimmed items.
private struct ContextGuidelineSample: View {
    let showsUnavailable: Bool

    var body: some View {
        VStack(spacing: 10) {
            Text("See you at 6!")
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .foregroundStyle(.white)
                .background(.blue, in: .capsule)
                .contextMenu {
                    Button("Reply", systemImage: "arrowshape.turn.up.left") {}
                    Button("Copy", systemImage: "doc.on.doc") {}
                    if showsUnavailable {
                        Button("Paste", systemImage: "doc.on.clipboard") {}.disabled(true)
                        Button("Edit", systemImage: "pencil") {}.disabled(true)
                        Button("Undo Send", systemImage: "arrow.uturn.backward") {}.disabled(true)
                    }
                }
            Text("Touch and hold the message")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
}