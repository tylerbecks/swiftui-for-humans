import SwiftUI

extension ComponentPage {
    static let commands = ComponentPage(
        id: "commands",
        title: "Commands & menu bar",
        summary: "Add your own menus and menu items to the Mac's menu bar.",
        category: .menus,
        symbol: "menubar.rectangle",
        availability: ["macOS 11.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/building-and-customizing-the-menu-bar-with-swiftui",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/the-menu-bar",
        aliases: ["menu bar", "menubar", "main menu", "CommandMenu", "CommandGroup", "Commands", "FocusedValue", "focusedSceneValue", "NSMenu", "NSMenuItem", "File menu", "Edit menu", "Help menu", "app menu"],
        related: ["keyboard-shortcuts", "context-menu", "menu", "menu-bar-conventions", "settings-scene"],
        notes: [
            "**Scenes bring the standard menus.** A `WindowGroup` already has Copy, Paste, and the window commands, and a `Settings` scene adds Settings… to the app menu. Add only what's yours.",
            "**Values in `FocusedValues` are always optional.** A value is `nil` while no focused window or view publishes it, which is your cue to disable the command.",
        ],
        about: "`.commands` adds menus and items to the menu bar from your `App`. `CommandMenu` makes a new menu, which the system puts between View and Window. `CommandGroup` adds items to a menu the system already has, or replaces some of them.\n\nCommands aren't inside any window, so they read `@FocusedValue` to find out what's in front and act on it.",
        composition: """
        WindowGroup
        └── .commands
            ├── CommandMenu("Story")
            │   ├── Button
            │   ├── Divider
            │   └── Toggle
            └── CommandGroup(after: .newItem)
                └── Button
        """,
        api: [
            APIItem("`.commands { }`", "Adds menus and items to a scene."),
            APIItem("`CommandMenu(_:)`", "A new menu, after View."),
            APIItem("`CommandGroup(after:)`", "Adds items to a standard menu."),
            APIItem("`CommandGroup(replacing:)`", "Swaps out a standard group of items."),
            APIItem("`@FocusedValue`", "Reads a value from the focused window or view."),
            APIItem("`.focusedSceneValue(_:_:)`", "Publishes a value for the whole window."),
            APIItem("`.focusedValue(_:_:)`", "Publishes a value while a view has focus."),
            APIItem("`SidebarCommands()`", "Adds Show or Hide Sidebar to the View menu."),
        ],
        guidelines: [
            Guideline(
                "Dim commands that don't apply. Don't hide them.",
                "A menu that keeps the same items teaches people what the app can do, even when a command isn't available right now.",
                good: "Split Chapter stays in the menu, dimmed.",
                bad: "Split Chapter disappears when it can't run."
            ) {
                MenusInputMenuDrawing(title: "Story", rows: [
                    .item("New Chapter", "⌥⌘N"),
                    .item("Split Chapter", "⇧⌘K", isEnabled: false),
                    .divider,
                    .item("Show Word Count"),
                ], width: 210)
            } bad: {
                MenusInputMenuDrawing(title: "Story", rows: [
                    .item("New Chapter", "⌥⌘N"),
                    .divider,
                    .item("Show Word Count"),
                ], width: 210)
            },
            Guideline(
                "End a command with an ellipsis when it asks for more.",
                "The … tells people a window or dialog opens next, so choosing the item doesn't act right away.",
                good: "Export… opens a save dialog.",
                bad: "Export looks like it acts immediately."
            ) {
                MenusInputMenuDrawing(title: "File", rows: [
                    .item("New Chapter", "⌥⌘N"),
                    .item("Export…"),
                    .divider,
                    .item("Close", "⌘W"),
                ], width: 210)
            } bad: {
                MenusInputMenuDrawing(title: "File", rows: [
                    .item("New Chapter", "⌥⌘N"),
                    .item("Export"),
                    .divider,
                    .item("Close", "⌘W"),
                ], width: 210)
            },
            Guideline(
                "Put every command in the menu bar.",
                "People look there first when they're learning an app. A command in the menu bar can have a shortcut and works with Full Keyboard Access, even if it's also in a toolbar or context menu."
            ),
            Guideline(
                "Keep menu titles short, and in the usual order.",
                "One word fits best. Custom menus sit between View and Window, from the most general to the most specific."
            ),
        ]
    ) {
        MenusInputMenuDrawing(title: "Story", rows: [
            .item("New Chapter", "⌥⌘N"),
            .item("Split Chapter", "⇧⌘K", isEnabled: false),
            .divider,
            .item("Show Word Count"),
        ], width: 190)
        .scaleEffect(0.85)
    } content: { page in
        MacCommandsArticle(page: page)
    }
}

// MARK: - Page

private struct MacCommandsArticle: View {
    let page: ComponentPage

    var body: some View {
        ArticlePage(page: page) {
            if let about = page.about {
                AboutSection(text: about)
            }
            Aside(.note, "Try it in this app: its Go menu is a `CommandMenu`. Control-click a page in the sidebar to open it in a new window, then choose Go > Next Page. Only the window in front moves on.")

            SectionTitle("Usage")
                .id("code")
            CodeBlock(code: """
            @main
            struct WriterApp: App {
                var body: some Scene {
                    WindowGroup {
                        ContentView()
                    }
                    .commands {
                        CommandMenu("Story") {
                            Button("New Chapter") { }
                                .keyboardShortcut("n", modifiers: [.command, .option])
                        }
                    }
                }
            }
            """)

            if let composition = page.composition {
                CompositionSection(tree: composition)
            }

            SectionTitle("Examples")
                .id("examples")
            StoryMenuExample()

            VStack(alignment: .leading, spacing: 14) {
                Text("Add to a standard menu")
                    .font(.title3.bold())
                    .outlineEntry("Add to a standard menu", level: 2)
                RichText("`CommandGroup` places items before or after a group the system already has, or replaces the group. Pass one of these placements:")
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                CodeBlock(code: """
                .commands {
                    CommandGroup(after: .newItem) {
                        Button("New from Clipboard") { }
                    }
                    CommandGroup(replacing: .help) {
                        Button("Writer User Guide") { }
                    }
                }
                """)
                ConnectFacts(rows: [
                    (".appInfo", "About *App Name*, in the app menu."),
                    (".newItem", "File > New."),
                    (".saveItem", "Close, Save, Duplicate, and Revert to Saved."),
                    (".importExport", "Empty, for import and export commands."),
                    (".pasteboard", "Cut, Copy, Paste, Delete, and Select All."),
                    (".sidebar, .toolbar", "Show or hide the sidebar and toolbar, in View."),
                    (".help", "The app's help item, in Help."),
                ])
                Aside(.note, "`CommandGroup(replacing:)` removes the system's items in that group. Replacing `.newItem` removes File > New.")
            }

            FocusedNoteExample()
        }
    }
}

// MARK: - Examples

/// A real `Menu` with the items a `CommandMenu("Story")` would have, in a
/// drawn menu bar. The page can't add to this app's real menu bar.
private struct StoryMenuExample: View {
    @State private var lastCommand = "Choose a command from the Story menu."
    @State private var showsWordCount = true

    var body: some View {
        ExampleCard(
            title: "A menu of your own",
            caption: "`CommandMenu` holds buttons, toggles, and `Menu` submenus. Shortcuts you add appear next to each item.",
            code: """
            @State private var showsWordCount = true

            var body: some Scene {
                WindowGroup {
                    ContentView()
                }
                .commands {
                    CommandMenu("Story") {
                        Button("New Chapter") { }
                            .keyboardShortcut("n", modifiers: [.command, .option])
                        Button("Split Chapter") { }
                            .keyboardShortcut("k", modifiers: [.command, .shift])
                        Divider()
                        Toggle("Show Word Count", isOn: $showsWordCount)
                        Menu("Export As") {
                            Button("PDF…") { }
                            Button("Plain Text…") { }
                        }
                    }
                }
            }
            """,
            minHeight: 170,
            aside: Aside(.note, "The preview draws a menu bar, and its Story menu is a real `Menu` with the same items. While this page is open, ⌥⌘N and ⇧⌘K run them too.")
        ) {
            VStack(spacing: 18) {
                HStack(spacing: 18) {
                    Text("Writer").bold()
                    Text("File")
                    Text("Edit")
                    Text("View")
                    Menu("Story") {
                        Button("New Chapter") { lastCommand = "New Chapter" }
                            .keyboardShortcut("n", modifiers: [.command, .option])
                        Button("Split Chapter") { lastCommand = "Split Chapter" }
                            .keyboardShortcut("k", modifiers: [.command, .shift])
                        Divider()
                        Toggle("Show Word Count", isOn: $showsWordCount)
                        Menu("Export As") {
                            Button("PDF…") { lastCommand = "Export As PDF…" }
                            Button("Plain Text…") { lastCommand = "Export As Plain Text…" }
                        }
                    }
                    .menuStyle(.button)
                    .buttonStyle(.borderless)
                    .menuIndicator(.hidden)
                    .fixedSize()
                    Text("Window")
                    Text("Help")
                    Spacer(minLength: 0)
                }
                .font(.callout)
                .padding(.horizontal, 12)
                .frame(height: 30)
                .background(.bar, in: .rect(cornerRadius: 8))
                .overlay {
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(.separator)
                }
                .frame(maxWidth: 520)

                Text(lastCommand)
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

extension FocusedValues {
    /// The note in the commands page's focus example.
    @Entry var macCommandsDemoNote: String?
}

private struct FocusedNoteExample: View {
    @State private var groceries = "Eggs, oat milk, coffee"
    @State private var trip = "Book the ferry"
    @State private var pinned = "Nothing pinned yet."

    var body: some View {
        ExampleCard(
            title: "Act on what's in focus",
            caption: "Publish a value with `.focusedSceneValue` or `.focusedValue`, and read it in your commands with `@FocusedValue`.",
            code: """
            extension FocusedValues {
                @Entry var note: Note?
            }

            struct NoteEditor: View {
                @State private var note = Note()

                var body: some View {
                    TextEditor(text: $note.text)
                        .focusedSceneValue(\\.note, note)
                }
            }

            struct NoteCommands: Commands {
                @FocusedValue(\\.note) private var note

                var body: some Commands {
                    CommandMenu("Note") {
                        Button("Pin Note") { note?.pin() }
                            .keyboardShortcut("p", modifiers: [.command, .shift])
                            .disabled(note == nil)
                    }
                }
            }
            """,
            minHeight: 200,
            aside: Aside(.note, "Click a field, then the button. It stands in for a menu item and reads the same kind of `@FocusedValue`, so it's dimmed until a field has focus. `.focusedSceneValue` would keep the value while focus moves elsewhere in the window.")
        ) {
            VStack(alignment: .leading, spacing: 12) {
                PinFocusedNoteButton(pinned: $pinned)
                Grid(alignment: .leadingFirstTextBaseline) {
                    GridRow {
                        Text("Groceries")
                            .gridColumnAlignment(.trailing)
                        TextField("Groceries", text: $groceries)
                            .labelsHidden()
                            .focusedValue(\.macCommandsDemoNote, "Groceries")
                    }
                    GridRow {
                        Text("Trip")
                        TextField("Trip", text: $trip)
                            .labelsHidden()
                            .focusedValue(\.macCommandsDemoNote, "Trip")
                    }
                }
                Text(pinned)
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: 360)
        }
    }
}

private struct PinFocusedNoteButton: View {
    @Binding var pinned: String
    @FocusedValue(\.macCommandsDemoNote) private var note

    var body: some View {
        Button(note.map { "Pin “\($0)”" } ?? "Pin Note", systemImage: "pin") {
            if let note { pinned = "Pinned “\(note)”." }
        }
        .disabled(note == nil)
    }
}
