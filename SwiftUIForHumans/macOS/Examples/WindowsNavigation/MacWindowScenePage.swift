import SwiftUI

extension ComponentPage {
    static let windowScene = ComponentPage(
        id: "window",
        title: "Window",
        summary: "A single, unique window, like an activity viewer or a floating palette.",
        category: .windows,
        symbol: "macwindow",
        availability: ["macOS 13.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/window",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/panels",
        aliases: [
            "single window", "singleton window", "one window", "auxiliary window", "secondary window",
            "UtilityWindow", "utility window", "floating window", "palette", "panel", "NSPanel",
            "inspector window", "tool window", "windowLevel", "Window menu",
        ],
        related: ["window-group", "opening-windows", "settings-scene", "window-style", "menu-bar-extra"],
        notes: [
            "**Every scene ID must be unique.** `Window` and `WindowGroup` share one set of IDs, and `openWindow(id:)` uses it to find the scene.",
            "**The Window menu lists it for you.** People can bring a `Window` back from the Window menu by its title, so it doesn't need its own menu item.",
        ],
        about: "`Window` opens one window, never two. Asking for it again brings the open window to the front, and the Window menu lists it by title.\n\n`UtilityWindow` (macOS 15) is a kind of `Window` for tool palettes and inspectors: it floats above your main windows, hides when your app isn't active, and adds an item to show and hide it in the View menu.",
        composition: """
        App
        ├── WindowGroup      main windows
        ├── Window           exactly one
        └── UtilityWindow    floating palette
        """,
        api: [
            APIItem("`Window(_:id:) { }`", "One unique window, listed in the Window menu."),
            APIItem("`UtilityWindow(_:id:) { }`", "A floating palette that follows the active window."),
            APIItem("`openWindow(id:)`", "Shows the window, or brings it to the front."),
            APIItem("`@Environment(\\.dismiss)`", "Closes the window from inside it."),
            APIItem("`@FocusedValue`", "Reads the focused main window's selection."),
            APIItem("`.windowLevel(.floating)`", "Keeps any window above normal windows."),
            APIItem("`.defaultLaunchBehavior(.presented)`", "Opens it at launch, like a welcome window."),
        ],
        guidelines: [
            Guideline(
                "Leave “panel” out of the menu item.",
                "Name the command after the panel's title, as in Show Inspector or Show Colors. Short noun titles are easy to spot in a menu and on screen.",
                good: "The command uses the panel's title.",
                bad: "“Panel” adds a word and no meaning."
            ) {
                WindowsNavMenuDrawing(items: ["Show Sidebar", "Show Inspector", nil, "Enter Full Screen"], width: 190, highlighted: "Show Inspector")
            } bad: {
                WindowsNavMenuDrawing(items: ["Show Sidebar", "Show Inspector Panel", nil, "Enter Full Screen"], width: 190, highlighted: "Show Inspector Panel")
            },
            Guideline(
                "Use a panel for controls that follow the selection.",
                "An inspector updates as people select different items. A window that always shows the same thing, like an Info window, should be a regular window."
            ),
            Guideline(
                "Prefer sliders and steppers in panels.",
                "Panels work best with direct adjustments. Typing text or picking items to act on takes extra steps in a small floating window."
            ),
            Guideline(
                "Hide panels with your app, and skip the minimize button.",
                "Panels appear when needed and disappear when your app isn't active. `UtilityWindow` does both for you."
            ),
        ]
    ) {
        ZStack(alignment: .topTrailing) {
            MacWindowFrame(title: "Photos", width: 170, height: 104) {
                Image(systemName: "photo.on.rectangle")
                    .font(.title)
                    .foregroundStyle(.tertiary)
            }
            .padding(.trailing, 40)
            .padding(.top, 18)
            MacWindowFrame(title: "Info", width: 86, height: 70) {
                Text("3 selected")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    } content: { page in
        MacWindowSceneArticle(page: page)
    }
}

extension Catalog {
    /// The Activity window from the first example.
    static let windowSceneDemoWindow = DemoWindow(id: "window-activity", title: "Activity", size: CGSize(width: 360, height: 220)) {
        ActivitySample()
    }
}

// MARK: - Page

private struct MacWindowSceneArticle: View {
    let page: ComponentPage
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        ArticlePage(page: page) {
            if let about = page.about {
                AboutSection(text: about)
            }
            VStack(alignment: .leading, spacing: 10) {
                Button("Open This App's About Window", systemImage: "info.circle") {
                    openWindow(id: AboutWindow.id)
                }
                .controlSize(.large)
                Prose("This app's About window is a `Window`. Click the button twice: the second click brings the open window forward instead of opening another.")
            }

            SectionTitle("Usage")
                .id("code")
            CodeBlock(code: """
            @main
            struct PhotosApp: App {
                var body: some Scene {
                    WindowGroup {
                        ContentView()
                    }
                    Window("Activity", id: "activity") {
                        ActivityView()
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
                title: "Show it from a button",
                caption: "Call `openWindow(id:)` with the window's ID. If the window is already open, it comes to the front.",
                code: """
                struct ShowActivityButton: View {
                    @Environment(\\.openWindow) private var openWindow

                    var body: some View {
                        Button("Show Activity") {
                            openWindow(id: "activity")
                        }
                    }
                }
                """,
                minHeight: 140
            ) {
                Button("Show Activity", systemImage: "arrow.down.circle") {
                    openWindow(id: DemoWindow.sceneID, value: "window-activity")
                }
            }

            ExampleCard(
                title: "A floating palette",
                caption: "`UtilityWindow` floats above your main windows. Read the active window's selection with `@FocusedValue`, and it updates as people switch windows.",
                code: """
                extension FocusedValues {
                    @Entry var selectedPhotoCount: Int?
                }

                @main
                struct PhotosApp: App {
                    var body: some Scene {
                        WindowGroup {
                            PhotoGrid()
                        }
                        UtilityWindow("Photo Info", id: "photo-info") {
                            PhotoInfo()
                        }
                    }
                }

                struct PhotoGrid: View {
                    @State private var selection = Set<Int>()

                    var body: some View {
                        Text("\\(selection.count) photos selected")
                            .focusedSceneValue(\\.selectedPhotoCount, selection.count)
                    }
                }

                struct PhotoInfo: View {
                    @FocusedValue(\\.selectedPhotoCount) private var count

                    var body: some View {
                        Text("\\(count ?? 0) photos selected")
                            .padding()
                    }
                }
                """,
                minHeight: 230,
                aside: Aside(.note, "A utility window isn't minimizable by default, and when it's focused, Esc closes it. It takes focus only when it needs to, like when people click its title bar or a text field in it.")
            ) {
                PaletteSample()
            }

            ExampleCard(
                title: "A window as the whole app",
                caption: "For an app that should never have two windows, like one built around the camera, make a `Window` the only scene.",
                code: """
                @main
                struct VideoCallApp: App {
                    var body: some Scene {
                        Window("Video Call", id: "main") {
                            CallView()
                        }
                    }
                }
                """,
                minHeight: 200,
                aside: Aside(.important, "When that window closes, the app quits. For most apps, start with a `WindowGroup` instead, and add a `Window` beside it.")
            ) {
                MacWindowFrame(title: "Video Call", width: 300, height: 170) {
                    VStack(spacing: 8) {
                        Image(systemName: "video")
                            .font(.largeTitle)
                            .foregroundStyle(.tertiary)
                        Text("Camera off")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }
}

// MARK: - Samples

/// Downloads in progress, for the Activity window.
private struct ActivitySample: View {
    var body: some View {
        List {
            LabeledContent {
                ProgressView(value: 0.72)
                    .frame(width: 110)
            } label: {
                Label("Lisbon.mov", systemImage: "film")
            }
            LabeledContent {
                ProgressView(value: 0.35)
                    .frame(width: 110)
            } label: {
                Label("Photos.zip", systemImage: "doc.zipper")
            }
            LabeledContent {
                Text("Done")
                    .foregroundStyle(.secondary)
            } label: {
                Label("Notes.pdf", systemImage: "doc.richtext")
            }
        }
    }
}

/// A drawing of a main window with a small palette over its corner. Click
/// a photo, and the palette follows the selection.
private struct PaletteSample: View {
    @State private var selection: Set<Int> = [1]

    var body: some View {
        ZStack(alignment: .topTrailing) {
            MacWindowFrame(title: "Library", width: 360, height: 190) {
                HStack(spacing: 10) {
                    ForEach(0..<4) { index in
                        Button {
                            if selection.contains(index) {
                                selection.remove(index)
                            } else {
                                selection.insert(index)
                            }
                        } label: {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.accentColor.opacity(0.15 + Double(index) * 0.12))
                                .frame(width: 60, height: 60)
                                .overlay {
                                    if selection.contains(index) {
                                        RoundedRectangle(cornerRadius: 6)
                                            .strokeBorder(Color.accentColor, lineWidth: 3)
                                    }
                                }
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Photo \(index + 1)")
                        .accessibilityAddTraits(selection.contains(index) ? .isSelected : [])
                    }
                }
                .padding(.trailing, 70)
            }
            .padding(.top, 30)
            .padding(.trailing, 40)
            MacWindowFrame(title: "Info", width: 150, height: 90) {
                Text("\(selection.count) selected")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
