import SwiftUI

extension ComponentPage {
    static let menuBarConventions = ComponentPage(
        id: "menu-bar-conventions",
        title: "The menu bar",
        summary: "The standard menus, their order, and which commands belong in each.",
        category: .patterns,
        kind: .concept,
        symbol: "menubar.rectangle",
        availability: ["macOS 11.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/building-and-customizing-the-menu-bar-with-swiftui",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/the-menu-bar",
        aliases: [
            "main menu", "NSMenu", "app menu", "File menu", "Edit menu", "View menu", "Window menu",
            "Help menu", "Format menu", "CommandMenu", "CommandGroup", "menu order", "menu items",
            "SidebarCommands", "ToolbarCommands", "FocusedValue",
        ],
        related: ["commands", "keyboard-shortcuts", "context-menu", "settings-pattern", "undo-redo", "keyboard-access"],
        notes: [
            "**People learn your app from its menus.** Opening each menu is how many people find out what an app can do, so a command that's only in a toolbar or a context menu is easy to miss.",
            "**This app's Go menu is a `CommandMenu`.** The system put it after View, where app-specific menus go.",
        ],
        api: [
            APIItem("`.commands { }`", "Adds menus and items to a scene."),
            APIItem("`CommandMenu(_:)`", "Your own menu, placed after View."),
            APIItem("`CommandGroup(after:)`", "Adds items next to a standard group."),
            APIItem("`CommandGroup(replacing:)`", "Swaps out a standard group, like Help."),
            APIItem("`SidebarCommands()`", "The menu item that shows or hides the sidebar."),
            APIItem("`TextFormattingCommands()`", "The Format menu, for styled text."),
            APIItem("`@FocusedValue`", "Lets a command act on the frontmost window."),
        ],
        guidelines: [
            Guideline(
                "Keep the standard menus, in the standard order.",
                "People expect App, File, Edit, Format, View, your menus, Window, and Help. Many standard items work without any code from you."
            ),
            Guideline(
                "Disable items instead of hiding them.",
                "A menu that keeps the same items teaches people what the app can do, even when a command doesn't apply right now.",
                good: "Pin Note is dimmed when nothing is selected.",
                bad: "Pin Note vanishes, so the menu changes shape."
            ) {
                DPMenuDrawing(title: "Note", items: [
                    .item("Pin Note", enabled: false),
                    .item("Show Note Info", "⌘I"),
                ], width: 200)
            } bad: {
                DPMenuDrawing(title: "Note", items: [
                    .item("Show Note Info", "⌘I"),
                ], width: 200)
            },
            Guideline(
                "Put every command in a menu.",
                "Even rare and advanced commands. In a menu, people can find them, see their shortcuts, and reach them with Full Keyboard Access."
            ),
            Guideline(
                "Use short, one-word menu titles.",
                "The menu bar shares its space with menu bar extras and may truncate long titles. One word is quick to scan.",
                good: "One word: Note.",
                bad: "A phrase that crowds the bar."
            ) {
                DPMenuBarStrip(titles: ["Notes", "File", "Edit", "View", "Note"])
            } bad: {
                DPMenuBarStrip(titles: ["Notes", "File", "Edit", "View", "Note Actions & Tools"])
            },
            Guideline(
                "Name show and hide items for what they'll do.",
                "When the toolbar is showing, the item says Hide Toolbar; when it's hidden, Show Toolbar."
            ),
            Guideline(
                "Keep a Window menu, even with one window.",
                "Its Minimize and Zoom items give keyboard users a way to do what the window buttons do."
            ),
        ],
        sources: [
            "https://developer.apple.com/design/human-interface-guidelines/the-menu-bar",
            "https://developer.apple.com/design/human-interface-guidelines/menus",
            "https://developer.apple.com/design/human-interface-guidelines/keyboards",
            "https://developer.apple.com/documentation/swiftui/building-and-customizing-the-menu-bar-with-swiftui",
            "https://developer.apple.com/documentation/swiftui/commandmenu",
            "https://developer.apple.com/documentation/swiftui/commandgroup",
            "https://developer.apple.com/documentation/swiftui/commandgroupplacement",
            "https://developer.apple.com/documentation/swiftui/sidebarcommands",
            "https://developer.apple.com/documentation/swiftui/toolbarcommands",
            "https://developer.apple.com/documentation/swiftui/textformattingcommands",
            "https://developer.apple.com/documentation/swiftui/inspectorcommands",
            "https://developer.apple.com/documentation/swiftui/focusedvalue",
        ],
        reviewed: "October 2026"
    ) {
        DPMenuDrawing(title: "Edit", items: [
            .item("Undo", "⌘Z"),
            .item("Copy", "⌘C", highlighted: true),
            .item("Paste", "⌘V"),
        ], width: 150)
        .accessibilityHidden(true)
    } content: { page in
        MacMenuBarConventionsArticle(page: page)
    }
}

// MARK: - Page

private struct MacMenuBarConventionsArticle: View {
    let page: ComponentPage

    var body: some View {
        ArticlePage(page: page) {
            Prose("The menu bar is how people learn what a Mac app can do and find its commands. Every app uses the same menus in the same order, so people know where to look before they've opened yours: your app's menu, **File**, **Edit**, **Format**, **View**, any menus of your own, **Window**, and **Help**. The Apple menu sits before them, and menu bar extras sit at the far end.")

            VStack(alignment: .leading, spacing: 16) {
                SectionTitle("What goes where")
                Prose("Click a menu to see the items the HIG lists for it, in order. The app here is a notes app.")
                MenuExplorer()
            }
            .id("demo")

            VStack(alignment: .leading, spacing: 16) {
                SectionTitle("What SwiftUI adds for you")
                Prose("Each scene brings its own menu items. Add the optional ones with `.commands`.")
                ConnectFacts(rows: [
                    ("WindowGroup", "Hiding and quitting the app, Copy and Paste, and window management."),
                    ("Settings", "The **Settings…** item in the app menu. See [Settings](catalog://settings-scene)."),
                    ("DocumentGroup", "Document items like Save and Duplicate."),
                    ("SidebarCommands, ToolbarCommands, InspectorCommands", "Items for the sidebar, the toolbar, and the inspector. Add the ones your windows have."),
                    ("TextFormattingCommands", "The Format menu, for apps that edit styled text."),
                ])
            }

            VStack(alignment: .leading, spacing: 16) {
                SectionTitle("Examples")
                    .id("examples")
                Aside(.note, "A real `.commands` here would change this app's own menu bar, so the previews draw the menus.")
                VStack(alignment: .leading, spacing: 44) {
                    ExampleCard(
                        title: "Add a menu of your own",
                        caption: "`CommandMenu` adds a menu after View: fill it with buttons, and give only the frequent ones a shortcut.",
                        code: """
                        WindowGroup {
                            ContentView()
                        }
                        .commands {
                            CommandMenu("Note") {
                                Button("Pin Note") { }
                                Button("Duplicate Note") { }
                                    .keyboardShortcut("d")
                                Divider()
                                Button("Show Note Info") { }
                                    .keyboardShortcut("i")
                            }
                        }
                        """,
                        minHeight: 190
                    ) {
                        DPMenuDrawing(title: "Note", items: [
                            .item("Pin Note"),
                            .item("Duplicate Note", "⌘D"),
                            .divider,
                            .item("Show Note Info", "⌘I"),
                        ])
                    }

                    ExampleCard(
                        title: "Add to a standard menu",
                        caption: "`CommandGroup(after:)` puts items next to a standard group, like after New in the File menu.",
                        code: """
                        .commands {
                            CommandGroup(after: .newItem) {
                                Button("New Note from Clipboard") { }
                            }
                        }
                        """,
                        minHeight: 170
                    ) {
                        DPMenuDrawing(title: "File", items: [
                            .item("New Note", "⌘N"),
                            .item("New Note from Clipboard", highlighted: true),
                            .divider,
                            .item("Close", "⌘W"),
                        ], width: 260)
                    }

                    ExampleCard(
                        title: "Turn on the standard extras",
                        caption: "If a window has a sidebar or a customizable toolbar, add `SidebarCommands` and `ToolbarCommands` for their menu items.",
                        code: """
                        WindowGroup {
                            ContentView()
                        }
                        .commands {
                            SidebarCommands()
                            ToolbarCommands()
                        }
                        """,
                        minHeight: 170
                    ) {
                        DPMenuDrawing(title: "View", items: [
                            .item("Hide Toolbar", "⌥⌘T"),
                            .item("Customize Toolbar…"),
                            .divider,
                            .item("Show Sidebar", "⌃⌘S"),
                        ])
                    }

                    ExampleCard(
                        title: "Act on the frontmost window",
                        caption: "Publish the window's model with `.focusedSceneValue`, read it with `@FocusedValue`, and disable the item when there isn't one.",
                        code: """
                        @Observable
                        final class NoteModel {
                            var isPinned = false
                        }

                        struct NoteCommands: Commands {
                            @FocusedValue(NoteModel.self) private var note

                            var body: some Commands {
                                CommandMenu("Note") {
                                    Button("Pin Note") { note?.isPinned.toggle() }
                                        .disabled(note == nil)
                                }
                            }
                        }

                        // In the window's view:
                        // .focusedSceneValue(model)
                        """,
                        minHeight: 140
                    ) {
                        DPMenuDrawing(title: "Note", items: [
                            .item("Pin Note", enabled: false),
                        ])
                    }
                }
            }
        }
    }
}

// MARK: - Explorer

private enum StandardMenu: String, CaseIterable, Identifiable {
    case app = "Notes"
    case file = "File"
    case edit = "Edit"
    case format = "Format"
    case view = "View"
    case custom = "Note"
    case window = "Window"
    case help = "Help"

    var id: Self { self }

    var about: String {
        switch self {
        case .app: "Things about the app as a whole. The title is your app's short name, shown in bold."
        case .file: "Managing documents and files. If your app has no files, rename this menu or leave it out."
        case .edit: "Changing content and using the clipboard. Useful even without documents."
        case .format: "Fonts and text styles. Only for apps that edit formatted text."
        case .view: "How every window looks. Not for switching between windows."
        case .custom: "Your app's own commands, after View, from most to least general."
        case .window: "Moving between, arranging, and minimizing windows. Close is in File."
        case .help: "Your help, plus a few extra items. Keep it short."
        }
    }

    var items: [DPMenuItem] {
        switch self {
        case .app: [
            .item("About Notes"),
            .divider,
            .item("Settings…", "⌘,"),
            .divider,
            .item("Services"),
            .divider,
            .item("Hide Notes", "⌘H"),
            .item("Hide Others", "⌥⌘H"),
            .item("Show All"),
            .divider,
            .item("Quit Notes", "⌘Q"),
        ]
        case .file: [
            .item("New Note", "⌘N"),
            .item("Open…", "⌘O"),
            .item("Open Recent"),
            .divider,
            .item("Close", "⌘W"),
            .item("Save", "⌘S"),
            .item("Duplicate", "⇧⌘S"),
            .item("Rename…"),
            .item("Export As…"),
            .divider,
            .item("Print…", "⌘P"),
        ]
        case .edit: [
            .item("Undo", "⌘Z"),
            .item("Redo", "⇧⌘Z"),
            .divider,
            .item("Cut", "⌘X"),
            .item("Copy", "⌘C"),
            .item("Paste", "⌘V"),
            .item("Delete"),
            .item("Select All", "⌘A"),
            .divider,
            .item("Find"),
        ]
        case .format: [
            .item("Font"),
            .item("Text"),
        ]
        case .view: [
            .item("Show Tab Bar"),
            .item("Hide Toolbar", "⌥⌘T"),
            .item("Customize Toolbar…"),
            .item("Show Sidebar"),
            .divider,
            .item("Enter Full Screen", "⌃⌘F"),
        ]
        case .custom: [
            .item("Pin Note"),
            .item("Duplicate Note", "⌘D"),
            .divider,
            .item("Show Note Info", "⌘I"),
        ]
        case .window: [
            .item("Minimize", "⌘M"),
            .item("Zoom"),
            .divider,
            .item("Show Previous Tab"),
            .item("Show Next Tab"),
            .item("Move Tab to New Window"),
            .item("Merge All Windows"),
            .divider,
            .item("Bring All to Front"),
            .divider,
            .item("Groceries"),
            .item("Trip Notes"),
        ]
        case .help: [
            .item("Notes Help"),
            .divider,
            .item("Release Notes"),
        ]
        }
    }
}

/// A drawn menu bar: click a title to open its menu and read what goes in it.
private struct MenuExplorer: View {
    @State private var selection = StandardMenu.edit

    var body: some View {
        DPPanel {
            VStack(alignment: .leading, spacing: 18) {
                HStack(spacing: 2) {
                    Image(systemName: "apple.logo")
                        .padding(.horizontal, 8)
                        .accessibilityHidden(true)
                    ForEach(StandardMenu.allCases) { menu in
                        Button {
                            selection = menu
                        } label: {
                            Text(menu.rawValue)
                                .fontWeight(menu == .app ? .bold : .regular)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(selection == menu ? AnyShapeStyle(.fill.secondary) : AnyShapeStyle(.clear), in: .rect(cornerRadius: 5))
                                .contentShape(.rect)
                        }
                        .buttonStyle(.plain)
                        .accessibilityAddTraits(selection == menu ? .isSelected : [])
                    }
                }
                .font(.callout)
                .padding(.vertical, 4)
                .padding(.horizontal, 4)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.fill.quaternary, in: .rect(cornerRadius: 8))

                HStack(alignment: .top, spacing: 28) {
                    DPMenuDrawing(title: selection.rawValue, items: selection.items, width: 240)
                    VStack(alignment: .leading, spacing: 8) {
                        Text(selection == .custom ? "Your own menus" : "\(selection.rawValue) menu")
                            .font(.headline)
                        Text(selection.about)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: 260, alignment: .leading)
                    .padding(.top, 30)
                }
            }
        }
    }
}

/// A strip of menu titles, as in the menu bar.
private struct DPMenuBarStrip: View {
    let titles: [String]
    var highlighted: String? = nil

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "apple.logo")
            ForEach(Array(titles.enumerated()), id: \.offset) { index, title in
                Text(title)
                    .fontWeight(index == 0 ? .bold : .regular)
                    .padding(.horizontal, 4)
                    .background(title == highlighted ? AnyShapeStyle(.fill.secondary) : AnyShapeStyle(.clear), in: .rect(cornerRadius: 4))
            }
        }
        .font(.callout)
        .lineLimit(1)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(.fill.quaternary, in: .rect(cornerRadius: 6))
        .accessibilityElement(children: .combine)
    }
}
