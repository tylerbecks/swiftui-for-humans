import SwiftUI

extension ComponentPage {
    static let openingWindows = ComponentPage(
        id: "opening-windows",
        title: "Opening windows",
        summary: "Open, bring forward, and close windows from your own code.",
        category: .windows,
        kind: .concept,
        symbol: "macwindow.badge.plus",
        availability: ["macOS 13.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/openwindowaction",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/windows",
        aliases: [
            "openWindow", "OpenWindowAction", "dismissWindow", "DismissWindowAction", "dismiss",
            "pushWindow", "close window", "show window", "new window", "open in new window",
            "makeKeyAndOrderFront", "showWindow", "window.open",
        ],
        related: ["window-group", "window", "commands", "context-menu", "keyboard-shortcuts"],
        notes: [
            "**Opening the same value twice doesn't make two windows.** If a window already shows that value, SwiftUI brings it to the front.",
            "**`pushWindow` is visionOS only.** It swaps one window for another there. On the Mac, open the new window and dismiss the old one.",
        ],
        about: "Read `openWindow` from the environment and call it with a scene's ID, a value, or both. A `Window` comes to the front. A `WindowGroup` opens a new window, unless one is already showing that value.\n\nTo close a window, call `dismiss` from a view inside it, or `dismissWindow` with the scene's ID from anywhere in your app.",
        api: [
            APIItem("`@Environment(\\.openWindow)`", "The action that opens windows."),
            APIItem("`openWindow(id:)`", "Opens a scene by its ID."),
            APIItem("`openWindow(value:)`", "Opens the window group for that value's type."),
            APIItem("`openWindow(id:value:)`", "Picks between groups that take the same type."),
            APIItem("`@Environment(\\.dismiss)`", "Closes the window this view is in."),
            APIItem("`@Environment(\\.dismissWindow)`", "Closes a window by ID or value."),
        ],
        guidelines: [
            Guideline(
                "Pick the moments that deserve a window.",
                "A new window helps people compare or keep context, like a draft next to the inbox. Opening one for everything clutters the screen."
            ),
            Guideline(
                "Make “Open in New Window” easy to find.",
                "Offer it in the item's context menu or the File menu, so it's there for people who want it."
            ),
        ]
    ) {
        VStack(spacing: 10) {
            Image(systemName: "macwindow.badge.plus")
                .font(.system(size: 34))
                .foregroundStyle(.tint)
            Text("openWindow(value:)")
                .font(.caption.monospaced())
        }
    } content: { page in
        MacOpeningWindowsArticle(page: page)
    }
}

// MARK: - Page

private struct MacOpeningWindowsArticle: View {
    let page: ComponentPage
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        ArticlePage(page: page) {
            if let about = page.about {
                AboutSection(text: about)
            }

            SectionTitle("Usage")
                .id("code")
            CodeBlock(code: """
            struct ShowActivityButton: View {
                @Environment(\\.openWindow) private var openWindow

                var body: some View {
                    Button("Show Activity") {
                        openWindow(id: "activity")
                    }
                }
            }
            """)

            SectionTitle("Examples")
                .id("examples")
            ExampleCard(
                title: "Open and close by value",
                caption: "These buttons open real windows. Open a note twice and its window comes forward; close it with `dismissWindow(value:)`.",
                code: """
                struct NoteControls: View {
                    let note: Note
                    @Environment(\\.openWindow) private var openWindow
                    @Environment(\\.dismissWindow) private var dismissWindow

                    var body: some View {
                        HStack {
                            Button("Open") {
                                openWindow(value: note.id)
                            }
                            Button("Close") {
                                dismissWindow(value: note.id)
                            }
                        }
                    }
                }
                """,
                minHeight: 200
            ) {
                OpenCloseSample()
            }

            ExampleCard(
                title: "Close the window you're in",
                caption: "Inside a window, `dismiss` closes that window. Each note window above has a Close button that does this.",
                code: """
                struct NoteView: View {
                    @Environment(\\.dismiss) private var dismiss

                    var body: some View {
                        VStack {
                            Text("Groceries")
                            Button("Close") {
                                dismiss()
                            }
                            .keyboardShortcut(.cancelAction)
                        }
                        .padding()
                    }
                }
                """,
                minHeight: 160,
                aside: Aside(.important, "Called from a sheet or popover, `dismiss` closes that presentation, not the window.")
            ) {
                VStack(spacing: 12) {
                    Button("Open the Groceries Note", systemImage: "cart") {
                        openWindow(id: DemoWindow.sceneID, value: WindowsNavNote.groceries.windowID)
                    }
                    Text("Then click Close in the window, or press Esc.")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
            }

            ExampleCard(
                title: "Open a window from the menu bar",
                caption: "Menu commands can read `openWindow` too. This app's About item in the app menu opens its About window this way.",
                code: """
                struct AboutCommands: Commands {
                    @Environment(\\.openWindow) private var openWindow

                    var body: some Commands {
                        CommandGroup(replacing: .appInfo) {
                            Button("About Notes") {
                                openWindow(id: "about")
                            }
                        }
                    }
                }

                // In your App:
                // WindowGroup { … }
                //     .commands { AboutCommands() }
                """,
                minHeight: 140
            ) {
                Button("About \(AppInfo.name)") {
                    openWindow(id: AboutWindow.id)
                }
            }

            SectionTitle("Two groups, one type")
            Prose("If two window groups take the same type, like a `UUID` for both messages and accounts, give each an `id` and pass both to `openWindow`.")
            CodeBlock(code: """
            WindowGroup("Message", id: "message", for: UUID.self) { $id in
                MessageView(id: id)
            }
            WindowGroup("Account", id: "account", for: UUID.self) { $id in
                AccountView(id: id)
            }

            // Elsewhere:
            openWindow(id: "account", value: account.id)
            """)
        }
    }
}

// MARK: - Samples

/// Open and Close buttons for each note. The windows are real; the Close
/// buttons use `dismissWindow`.
private struct OpenCloseSample: View {
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow

    var body: some View {
        Grid(alignment: .leading, horizontalSpacing: 14, verticalSpacing: 10) {
            ForEach(WindowsNavNote.allCases) { note in
                GridRow {
                    Label(note.title, systemImage: note.symbol)
                    Button("Open") {
                        openWindow(id: DemoWindow.sceneID, value: note.windowID)
                    }
                    Button("Close") {
                        dismissWindow(id: DemoWindow.sceneID, value: note.windowID)
                    }
                }
            }
        }
    }
}
