import SwiftUI

extension ComponentPage {
    static let windowGroup = ComponentPage(
        id: "window-group",
        title: "WindowGroup",
        summary: "The scene for your app's main windows. People can open as many as they need.",
        category: .windows,
        symbol: "macwindow.on.rectangle",
        availability: ["macOS 11.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/windowgroup",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/windows",
        aliases: [
            "window", "windows", "multiple windows", "new window", "File > New Window", "scene",
            "WindowGroup(for:)", "open in new window", "state restoration", "restorationBehavior",
            "NSWindow", "NSWindowController", "main window", "tabbed windows",
        ],
        related: ["window", "opening-windows", "document-group", "window-style", "windows-tabs"],
        notes: [
            "**Closing the last window doesn't quit the app.** An app built on a `WindowGroup` keeps running with no windows open. One whose only scene is a `Window` quits when it closes.",
            "**Each window starts with fresh `@State`.** Keep data that every window should see in a shared model, passed in through the environment.",
        ],
        about: "`WindowGroup` is the scene most Mac apps start with. Its content is a template: every window people open from it gets its own copy of the view, with its own state.\n\nOn the Mac you get File > New Window, a list of open windows in the Window menu, and windows that people can merge into tabs, without writing any code. For a window there should only ever be one of, use `Window` instead.",
        composition: """
        App
        ├── WindowGroup          main windows
        └── WindowGroup(for:)    one per value
            └── $value binding
        """,
        api: [
            APIItem("`WindowGroup { }`", "Main windows. People can open many."),
            APIItem("`WindowGroup(for:) { $value in }`", "One window per value, like a note's ID."),
            APIItem("`WindowGroup(_:id:)`", "A title for menus, and an ID to open it by."),
            APIItem("`defaultValue:`", "The value File > New Window passes instead of `nil`."),
            APIItem("`@Environment(\\.openWindow)`", "Opens a window from your code."),
            APIItem("`.navigationTitle(_:)`", "Each window's own title."),
            APIItem("`.restorationBehavior(.disabled)`", "Keeps a scene's windows from reopening at launch."),
        ],
        guidelines: [
            Guideline(
                "Call it a window.",
                "The system calls every window a window. Words like “scene” or “view” for the same thing only confuse people.",
                good: "The command says what it opens.",
                bad: "“Scene” is a developer word."
            ) {
                WindowGroupMenuSample(item: "Open in New Window")
            } bad: {
                WindowGroupMenuSample(item: "Open in New Scene")
            },
            Guideline(
                "Open new windows when they help, not by default.",
                "A second window is great for comparing or keeping context, like a draft beside your inbox. Opening one for every click fills the screen and makes the app harder to follow."
            ),
            Guideline(
                "Offer “Open in New Window” as a choice.",
                "Put it in the item's context menu or the File menu, so people who want a separate window can have one."
            ),
            Guideline(
                "Make windows work at any size.",
                "People resize and arrange windows constantly on the Mac. Set a sensible minimum size and let the layout grow from there."
            ),
        ]
    ) {
        ZStack {
            MacWindowFrame(title: "Notes", width: 150, height: 92) {
                Color.clear
            }
            .offset(x: -22, y: -14)
            MacWindowFrame(title: "Trip", width: 150, height: 92) {
                Text("Lisbon")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .offset(x: 22, y: 14)
        }
    } content: { page in
        MacWindowGroupArticle(page: page)
    }
}

extension Catalog {
    /// One window per note, for the value-based example. The Opening
    /// Windows page opens the same windows.
    static let windowGroupDemoWindows = WindowsNavNote.demoWindows
}

// MARK: - Page

private struct MacWindowGroupArticle: View {
    let page: ComponentPage

    var body: some View {
        ArticlePage(page: page) {
            if let about = page.about {
                AboutSection(text: about)
            }
            VStack(alignment: .leading, spacing: 10) {
                OpenInNewWindowButton(id: page.id)
                    .controlSize(.large)
                Prose("This app's windows come from `WindowGroup(for: ComponentPage.ID.self)`. Click the button to open this page in a window of its own. Click it again, and the window that's already showing this page comes to the front.")
            }

            SectionTitle("Usage")
                .id("code")
            CodeBlock(code: """
            @main
            struct NotesApp: App {
                var body: some Scene {
                    WindowGroup {
                        ContentView()
                    }
                }
            }
            """)

            if let composition = page.composition {
                CompositionSection(tree: composition)
            }

            SectionTitle("Examples")
                .id("examples")
            ExampleCard(
                title: "Every window has its own state",
                caption: "SwiftUI gives each new window fresh storage for its `@State`. Count in one window, and the other doesn't change.",
                code: """
                struct ContentView: View {
                    @State private var count = 0

                    var body: some View {
                        Stepper("Cups of tea: \\(count)", value: $count)
                            .padding()
                    }
                }
                """,
                minHeight: 200
            ) {
                HStack(spacing: 16) {
                    MacWindowFrame(title: "Untitled", width: 220, height: 130) {
                        TeaCounterSample()
                    }
                    MacWindowFrame(title: "Untitled 2", width: 220, height: 130) {
                        TeaCounterSample()
                    }
                }
            }

            ExampleCard(
                title: "A window per item",
                caption: "`WindowGroup(for:)` opens a window for a value, like a note's ID. Click a note twice: the second click brings its window forward.",
                code: """
                @main
                struct NotesApp: App {
                    var body: some Scene {
                        WindowGroup {
                            NoteList()
                        }
                        WindowGroup("Note", for: Note.ID.self) { $noteID in
                            NoteView(noteID: noteID)
                        }
                    }
                }

                struct NoteRow: View {
                    let note: Note
                    @Environment(\\.openWindow) private var openWindow

                    var body: some View {
                        Text(note.title)
                            .contextMenu {
                                Button("Open in New Window") {
                                    openWindow(value: note.id)
                                }
                            }
                    }
                }
                """,
                minHeight: 230,
                aside: Aside(.note, "The value must be `Hashable` and `Codable`. Pass an ID rather than the whole model: SwiftUI saves the value to restore the window later.")
            ) {
                NoteListSample()
            }

            SectionTitle("New windows and restoring")
            Prose("When someone chooses File > New Window, there's no value to pass, so the binding is `nil`. Give the group a `defaultValue` to start every new window with something, like a fresh note.")
            CodeBlock(code: """
            WindowGroup("Note", for: Note.ID.self) { $noteID in
                NoteView(noteID: noteID)
            } defaultValue: {
                store.makeNote().id
            }
            """)
            Prose("SwiftUI saves each window's value and passes it back when it restores the window at the next launch. If that fails, the window gets the default value, or `nil`. People turn restoring windows on or off for every app in System Settings; to leave out a scene, like a short-lived window, use `.restorationBehavior(.disabled)`.")
        }
    }
}

// MARK: - Samples

private struct TeaCounterSample: View {
    @State private var count = 0

    var body: some View {
        Stepper("Cups of tea: \(count)", value: $count, in: 0...20)
            .padding()
    }
}

/// A drawing of a notes window whose rows open real windows, one per note.
private struct NoteListSample: View {
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        MacWindowFrame(title: "Notes", width: 380, height: 190) {
            VStack(spacing: 0) {
                ForEach(WindowsNavNote.allCases) { note in
                    HStack {
                        Label(note.title, systemImage: note.symbol)
                        Spacer()
                        Button("Open in New Window", systemImage: "macwindow.badge.plus") {
                            openWindow(id: DemoWindow.sceneID, value: note.windowID)
                        }
                        .labelStyle(.iconOnly)
                        .buttonStyle(.borderless)
                        .help("Open in New Window")
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 9)
                    .contextMenu {
                        Button("Open in New Window") {
                            openWindow(id: DemoWindow.sceneID, value: note.windowID)
                        }
                    }
                    if note != WindowsNavNote.allCases.last {
                        Divider()
                            .padding(.leading, 14)
                    }
                }
                Spacer(minLength: 0)
            }
            .padding(.top, 4)
        }
    }
}

/// A drawn context menu with one command, for the "window" wording
/// guideline.
private struct WindowGroupMenuSample: View {
    let item: String

    var body: some View {
        WindowsNavMenuDrawing(items: ["Open", item, nil, "Duplicate", "Delete"], width: 180, highlighted: item)
    }
}
