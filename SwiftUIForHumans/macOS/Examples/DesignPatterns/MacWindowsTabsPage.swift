import SwiftUI

extension ComponentPage {
    static let windowsTabs = ComponentPage(
        id: "windows-tabs",
        title: "Windows & tabs",
        summary: "More than one window, tabs that gather them, and windows that come back after a relaunch.",
        category: .patterns,
        kind: .concept,
        symbol: "macwindow.on.rectangle",
        availability: ["macOS 13.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/windowgroup",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/windows",
        aliases: [
            "multiple windows", "new window", "open in new window", "window tabs", "tabbed windows",
            "state restoration", "SceneStorage", "openWindow", "WindowGroup", "NSWindow", "relaunch",
            "Merge All Windows",
        ],
        related: ["window-group", "opening-windows", "window", "document-group", "full-screen", "onboarding"],
        notes: [
            "**This app does it too.** Control-click a page in the sidebar and choose Open in New Window. Each window remembers its own tab and page with `@SceneStorage`.",
            "**Keep `@SceneStorage` small.** It's for things like a selection or a scroll position. The system decides when to save it, and throws it away when the window is closed.",
        ],
        api: [
            APIItem("`WindowGroup(for:)`", "A group of windows, one per value."),
            APIItem("`@Environment(\\.openWindow)`", "Opens a window from your code."),
            APIItem("`.navigationTitle(_:)`", "Titles the window and its Window menu item."),
            APIItem("`@SceneStorage`", "Per-window state that's restored on relaunch."),
            APIItem("`.restorationBehavior(.disabled)`", "Keeps a window from reopening at launch."),
            APIItem("`\\.supportsMultipleWindows`", "Whether opening another window is possible."),
        ],
        guidelines: [
            Guideline(
                "Open a new window when it helps, not by default.",
                "A second window is great for comparing or keeping context, like a draft beside the inbox. Opening one for everything buries people in clutter."
            ),
            Guideline(
                "Offer Open in New Window.",
                "Let people choose to see an item on its own, from a context menu or the File menu."
            ),
            Guideline(
                "Call it a window.",
                "People know windows. Scene is a word for your code, not for menus and help.",
                good: "Open in New Window.",
                bad: "Open in New Scene."
            ) {
                DPMenuDrawing(title: "Trip Notes", items: [
                    .item("Open in New Window", highlighted: true),
                    .item("Duplicate"),
                ], width: 210)
            } bad: {
                DPMenuDrawing(title: "Trip Notes", items: [
                    .item("Open in New Scene", highlighted: true),
                    .item("Duplicate"),
                ], width: 210)
            },
            Guideline(
                "Use the system's windows.",
                "People rely on the real title bar, buttons, and active and inactive looks. A homemade frame that's slightly off makes the app feel broken.",
                good: "Standard window buttons on the leading side.",
                bad: "A custom close button in the corner."
            ) {
                MacWindowFrame(title: "Trip Notes", width: 230, height: 100) {
                    Color.clear
                }
            } bad: {
                DPCustomChrome()
            },
            Guideline(
                "Bring windows back the way people left them.",
                "After a relaunch, reopen windows in the same place and state, down to the scroll position, so people pick up where they stopped."
            ),
            Guideline(
                "Keep important things out of a bottom bar.",
                "People often push a window's bottom edge off screen. Use a bottom bar only for a little status about the window's content."
            ),
        ],
        sources: [
            "https://developer.apple.com/design/human-interface-guidelines/windows",
            "https://developer.apple.com/design/human-interface-guidelines/launching",
            "https://developer.apple.com/design/human-interface-guidelines/the-menu-bar",
            "https://developer.apple.com/documentation/swiftui/windowgroup",
            "https://developer.apple.com/documentation/swiftui/openwindowaction",
            "https://developer.apple.com/documentation/swiftui/scenestorage",
            "https://developer.apple.com/documentation/swiftui/scene/restorationbehavior(_:)",
            "https://developer.apple.com/documentation/swiftui/customizing-window-styles-and-state-restoration-behavior-in-macos",
        ],
        reviewed: "October 2026"
    ) {
        ZStack {
            MacWindowFrame(title: "Groceries", width: 150, height: 90) {
                Color.clear
            }
            .offset(x: -24, y: -14)
            MacWindowFrame(title: "Trip", width: 150, height: 90) {
                Color.clear
            }
            .offset(x: 24, y: 14)
        }
        .scaleEffect(0.9)
        .accessibilityHidden(true)
    } content: { page in
        MacWindowsTabsArticle(page: page)
    }
}

extension Catalog {
    /// Two note windows, so people can open both and merge them into tabs.
    static let windowsTabsDemoWindows: [DemoWindow] = [
        DemoWindow(id: "dp-note-trip", title: "Trip Notes", size: CGSize(width: 460, height: 320)) {
            NoteWindowSample(placeholder: "Pack the hiking boots…")
        },
        DemoWindow(id: "dp-note-groceries", title: "Groceries", size: CGSize(width: 460, height: 320)) {
            NoteWindowSample(placeholder: "Milk, eggs, bread…")
        },
    ]
}

// MARK: - Page

private struct MacWindowsTabsArticle: View {
    let page: ComponentPage

    var body: some View {
        ArticlePage(page: page) {
            Prose("Mac users keep several windows open, move between them, and resize them to suit the job. A `WindowGroup` gives your app that for free: people can open more than one window, each with its own state, gather them into **tabs** in a single window, and find them all in the Window menu.")
            Prose("Your part is deciding when content deserves its own window, titling each one, and saving what each window needs to come back after a relaunch.")

            VStack(alignment: .leading, spacing: 16) {
                SectionTitle("Try it")
                Prose("Open both note windows. Click a button again and the window that's already open comes to the front instead of a copy. People can merge windows like these into one tabbed window, for example with Window > Merge All Windows.")
                HStack(spacing: 12) {
                    OpenDemoWindowButton(id: "dp-note-trip", label: "Open Trip Notes")
                    OpenDemoWindowButton(id: "dp-note-groceries", label: "Open Groceries")
                }
                .controlSize(.large)
            }
            .id("demo")

            VStack(alignment: .leading, spacing: 16) {
                SectionTitle("Examples")
                    .id("examples")
                VStack(alignment: .leading, spacing: 44) {
                    ExampleCard(
                        title: "Open an item in its own window",
                        caption: "Give `WindowGroup` a value type, then call `openWindow(value:)` from a context menu. Its title names the window in menus.",
                        code: """
                        struct Note: Identifiable, Hashable, Codable {
                            var id: String
                            var title: String
                        }

                        // In the App:
                        WindowGroup("Note", for: Note.ID.self) { $noteID in
                            NoteView(noteID: noteID)
                        }

                        // In the list:
                        @Environment(\\.openWindow) private var openWindow

                        List(notes) { note in
                            Text(note.title)
                                .contextMenu {
                                    Button("Open in New Window") {
                                        openWindow(value: note.id)
                                    }
                                }
                        }
                        """,
                        minHeight: 170,
                        aside: Aside(.note, "If a window for that value is already open, `openWindow` brings it forward instead of opening a second one.")
                    ) {
                        OpenInWindowSample()
                    }

                    ExampleCard(
                        title: "Bring each window back as it was",
                        caption: "`@SceneStorage` works like `@State`, but each window saves its own value and gets it back after a relaunch.",
                        code: """
                        struct NoteView: View {
                            @SceneStorage("draft") private var draft = ""

                            var body: some View {
                                TextEditor(text: $draft)
                                    .navigationTitle("Trip Notes")
                            }
                        }
                        """,
                        minHeight: 200,
                        aside: Aside(.note, "Window restoration is a systemwide choice in System Settings. SwiftUI follows it unless you say otherwise for a window.")
                    ) {
                        NoteWindowSample(placeholder: "Type a draft here.")
                            .frame(width: 380, height: 160)
                            .clipShape(.rect(cornerRadius: 8))
                            .overlay {
                                RoundedRectangle(cornerRadius: 8).strokeBorder(.separator)
                            }
                    }

                    ExampleCard(
                        title: "Don't reopen short-lived windows",
                        caption: "For a window that's only useful in the moment, like a connection test, add `.restorationBehavior(.disabled)` to its scene.",
                        code: """
                        Window("Connection Test", id: "connection-test") {
                            ConnectionTestView()
                        }
                        .restorationBehavior(.disabled)
                        """,
                        minHeight: 160
                    ) {
                        MacWindowFrame(title: "Connection Test", width: 300, height: 120) {
                            Label("Connected", systemImage: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Samples

/// The note editor shown in the demo windows and inline. Its text is
/// kept per window with `@SceneStorage`.
private struct NoteWindowSample: View {
    let placeholder: String
    @SceneStorage("dp.windows.note") private var draft = ""

    var body: some View {
        TextEditor(text: $draft)
            .font(.body)
            .scrollContentBackground(.hidden)
            .padding(10)
            .overlay(alignment: .topLeading) {
                if draft.isEmpty {
                    Text(placeholder)
                        .foregroundStyle(.tertiary)
                        .padding(.horizontal, 15)
                        .padding(.vertical, 10)
                        .allowsHitTesting(false)
                }
            }
            .background(.background)
    }
}

private struct OpenInWindowSample: View {
    @Environment(\.openWindow) private var openWindow

    private let notes = [("dp-note-trip", "Trip Notes"), ("dp-note-groceries", "Groceries")]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(notes, id: \.0) { note in
                Label(note.1, systemImage: "note.text")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .contentShape(.rect)
                    .contextMenu {
                        Button("Open in New Window") {
                            openWindow(id: DemoWindow.sceneID, value: note.0)
                        }
                    }
                if note.0 != notes.last?.0 { Divider() }
            }
        }
        .frame(width: 260)
        .background(.background, in: .rect(cornerRadius: 8))
        .overlay {
            RoundedRectangle(cornerRadius: 8).strokeBorder(.separator)
        }
        .overlay(alignment: .bottom) {
            Text("Control-click a note.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .offset(y: 24)
        }
    }
}

/// A window drawn with homemade chrome, for the Don't.
private struct DPCustomChrome: View {
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Trip Notes")
                    .font(.headline)
                Spacer()
                Image(systemName: "xmark")
                    .font(.caption.bold())
                    .foregroundStyle(.white)
                    .frame(width: 20, height: 20)
                    .background(.purple, in: .circle)
            }
            .padding(.horizontal, 14)
            .frame(height: 44)
            .background(.bar)
            Divider()
            Color.clear
        }
        .frame(width: 230, height: 100)
        .background(.background)
        .clipShape(.rect(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14).strokeBorder(.separator)
        }
        .shadow(color: .black.opacity(0.18), radius: 10, y: 4)
    }
}
