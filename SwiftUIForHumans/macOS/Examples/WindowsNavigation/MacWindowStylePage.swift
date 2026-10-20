import SwiftUI

extension ComponentPage {
    static let windowStyle = ComponentPage(
        id: "window-style",
        title: "Window style & sizing",
        summary: "Scene modifiers for a window's title bar, toolbar style, size, and position.",
        category: .windows,
        kind: .modifier,
        symbol: "macwindow.and.cursorarrow",
        availability: ["macOS 11.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/windows",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/windows",
        aliases: [
            "windowStyle", "hiddenTitleBar", "title bar", "titlebar", "transparent title bar",
            "windowToolbarStyle", "unified toolbar", "expanded toolbar", "defaultSize", "window size",
            "minimum window size", "windowResizability", "fixed size window", "defaultPosition",
            "center window", "containerBackground", "WindowDragGesture", "drag window",
            "styleMask", "titlebarAppearsTransparent",
        ],
        related: ["window-group", "window", "toolbar", "materials", "full-screen", "windows-layout"],
        notes: [
            "**Settings windows fit their content by default.** With `.automatic` resizability, a `Settings` window uses `.contentSize` and every other scene uses `.contentMinSize`.",
            "**These are starting values.** When the system restores a window, it comes back at the size and place people left it.",
        ],
        about: "These modifiers go on a scene in your `App`, like a `WindowGroup`, not on a view. They decide how new windows start out. People can still move and resize them, within the limits you set.\n\nA few window behaviors are view modifiers instead, like `.containerBackground(_:for:)` with `.window`, so you can set them from inside the window.",
        api: [
            APIItem("`.defaultSize(width:height:)`", "The size a new window opens at."),
            APIItem("`.windowResizability(.contentSize)`", "Sizes the window from its content's frame."),
            APIItem("`.defaultPosition(.topTrailing)`", "Where the first window appears on screen."),
            APIItem("`.windowStyle(.hiddenTitleBar)`", "Hides the title and the title bar's backing."),
            APIItem("`.windowToolbarStyle(.unified)`", "How the toolbar and title bar combine."),
            APIItem("`.containerBackground(_:for:)`", "With `.window`, the window's background."),
            APIItem("`WindowDragGesture()`", "Lets people drag the window by a view."),
            APIItem("`.windowResizeBehavior(.disabled)`", "Turns off resizing from inside the window."),
        ],
        guidelines: [
            Guideline(
                "Keep the system's window frame.",
                "People know how standard windows look and behave. A homemade frame or window buttons that don't match exactly make the app feel broken.",
                good: "The standard window buttons.",
                bad: "Homemade window buttons."
            ) {
                MacWindowFrame(title: "Library", width: 230, height: 90) {
                    Color.clear
                }
            } bad: {
                CustomFrameSample()
            },
            Guideline(
                "Let windows adapt to any size.",
                "People arrange windows side by side and resize them all the time. Set a minimum that keeps your layout intact, and let it grow from there."
            ),
            Guideline(
                "Keep important things out of a bottom bar.",
                "People often move a window so its bottom edge is off screen. Use a bottom bar only for a little status, like Finder's item count."
            ),
            Guideline(
                "Keep the system's look for each window state.",
                "People tell the active window apart by its colored window buttons and materials. Standard backgrounds and controls change with the state; custom ones have to do it themselves."
            ),
        ]
    ) {
        ZStack(alignment: .topLeading) {
            SceneryView(.lake)
                .frame(width: 180, height: 110)
            WindowsNavWindowButtons()
                .padding(10)
        }
        .frame(width: 180, height: 110)
        .windowsNavChrome()
    } content: { page in
        MacWindowStyleArticle(page: page)
    }
}

extension Catalog {
    /// Windows for the style examples: a clear, title-less window and one
    /// that can't be resized.
    static let windowStyleDemoWindows = [
        DemoWindow(id: "window-style-clear", title: "Now Playing", size: CGSize(width: 420, height: 260)) {
            ClearWindowSample()
        },
        DemoWindow(id: "window-style-fixed", title: "Timer", size: CGSize(width: 320, height: 200)) {
            FixedWindowSample()
        },
    ]
}

// MARK: - Page

private struct MacWindowStyleArticle: View {
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
            @main
            struct LibraryApp: App {
                var body: some Scene {
                    WindowGroup {
                        ContentView()
                            .frame(minWidth: 480, minHeight: 320)
                    }
                    .defaultSize(width: 900, height: 600)
                }
            }
            """)

            SectionTitle("Examples")
                .id("examples")
            ExampleCard(
                title: "A minimum size and a starting size",
                caption: "A `frame(minWidth:minHeight:)` on the content sets how small the window can get. `.defaultSize` sets the size it opens at.",
                code: """
                WindowGroup {
                    ContentView()
                        .frame(minWidth: 320, minHeight: 180)
                }
                .defaultSize(width: 440, height: 260)
                """,
                minHeight: 260,
                aside: Aside(.note, "A default size outside what the window allows is clamped to fit.")
            ) {
                MinimumSizeSample()
            }

            ExampleCard(
                title: "A window that fits its content",
                caption: "`.windowResizability(.contentSize)` takes the window's limits from the content's frame. A fixed frame makes a window people can't resize.",
                code: """
                Window("About Notes", id: "about") {
                    AboutView()
                        .frame(width: 440, height: 560)
                }
                .windowResizability(.contentSize)
                .defaultPosition(.center)
                """,
                minHeight: 160,
                aside: Aside(.note, "To turn off resizing, minimizing, or full screen from inside a window, set `.windowResizeBehavior`, `.windowMinimizeBehavior`, and `.windowFullScreenBehavior` to `.disabled`, as the Timer window does.")
            ) {
                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        Button("Open This App's About Window", systemImage: "info.circle") {
                            openWindow(id: AboutWindow.id)
                        }
                        OpenDemoWindowButton(id: "window-style-fixed", label: "Open the Timer Window")
                    }
                    Text("This app's About window uses the same frame and modifiers.")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
            }

            ExampleCard(
                title: "Where the window opens",
                caption: "The first window opens in the center of the screen. `.defaultPosition` picks another spot, given as a `UnitPoint`.",
                code: """
                WindowGroup {
                    ContentView()
                }
                .defaultPosition(.topTrailing)
                """,
                minHeight: 280
            ) {
                PositionSample()
            }

            ExampleCard(
                title: "Toolbar styles",
                caption: "`.windowToolbarStyle` sets how the title and toolbar share the top of the window. Pick a style to compare.",
                code: """
                WindowGroup {
                    ContentView()
                }
                .windowToolbarStyle(.unifiedCompact)
                """,
                minHeight: 240
            ) {
                ToolbarStyleSample()
            }

            ExampleCard(
                title: "Hide the title bar",
                caption: "`.windowStyle(.hiddenTitleBar)` hides the title and the title bar's backing, so more of the content shows.",
                code: """
                WindowGroup {
                    PlayerView()
                }
                .windowStyle(.hiddenTitleBar)
                .windowBackgroundDragBehavior(.enabled)
                """,
                minHeight: 240,
                aside: Aside(.important, "Without a title bar, people need another place to grab the window. Set `.windowBackgroundDragBehavior` to `.enabled` so they can drag it by its background.")
            ) {
                ZStack(alignment: .topLeading) {
                    SceneryView(.lake)
                    WindowsNavWindowButtons()
                        .padding(12)
                }
                .frame(width: 360, height: 200)
                .windowsNavChrome()
            }

            ExampleCard(
                title: "A see-through window",
                caption: "From inside the window, `.containerBackground(_:for:)` with `.window` sets its background, and you can hide the toolbar's title and backing.",
                code: """
                struct NowPlayingView: View {
                    var body: some View {
                        VStack {
                            Text("Now Playing")
                                .font(.title)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .containerBackground(.thinMaterial, for: .window)
                        .toolbarBackgroundVisibility(.hidden, for: .windowToolbar)
                        .toolbar(removing: .title)
                        .gesture(WindowDragGesture())
                        .allowsWindowActivationEvents()
                    }
                }
                """,
                minHeight: 140,
                aside: Aside(.note, "`WindowDragGesture` lets people move the window by dragging the view. `.allowsWindowActivationEvents()` lets the drag work even while the window is in the background.")
            ) {
                VStack(spacing: 12) {
                    OpenDemoWindowButton(id: "window-style-clear", label: "Open the See-Through Window")
                    Text("A material can't be drawn here, so this opens a real window.")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

// MARK: - Samples

/// A window drawing that can be resized with a slider, but never below
/// the content's minimum width.
private struct MinimumSizeSample: View {
    @State private var requested = 440.0
    private let minimum = 320.0

    var body: some View {
        VStack(spacing: 16) {
            MacWindowFrame(title: "Library", width: max(requested, minimum), height: 150) {
                VStack(spacing: 4) {
                    Text("\(Int(max(requested, minimum))) pt wide")
                        .font(.headline.monospacedDigit())
                    Text(requested < minimum ? "Stopped at minWidth: 320" : "Drag the slider to resize")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
            }
            .animation(.snappy, value: requested)
            Slider(value: $requested, in: 220...460) {
                Text("Window width")
            }
            .frame(width: 300)
        }
    }
}

private enum PositionOption: String, CaseIterable, Identifiable {
    case center, topLeading, topTrailing, bottomLeading, bottomTrailing

    var id: Self { self }

    var label: String { ".\(rawValue)" }

    var alignment: Alignment {
        switch self {
        case .center: .center
        case .topLeading: .topLeading
        case .topTrailing: .topTrailing
        case .bottomLeading: .bottomLeading
        case .bottomTrailing: .bottomTrailing
        }
    }
}

/// A drawing of a screen with a window placed at the chosen unit point.
private struct PositionSample: View {
    @State private var position = PositionOption.topTrailing

    var body: some View {
        VStack(spacing: 14) {
            VStack(spacing: 0) {
                Rectangle()
                    .fill(.bar)
                    .frame(height: 10)
                ZStack(alignment: position.alignment) {
                    SceneryView(.wallpaper)
                    MacWindowFrame(width: 140, height: 74) {
                        Color.clear
                    }
                    .padding(10)
                }
            }
            .frame(width: 340, height: 190)
            .clipShape(.rect(cornerRadius: 8))
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(.separator)
            }
            .animation(.snappy, value: position)
            Picker("Position", selection: $position) {
                ForEach(PositionOption.allCases) { option in
                    Text(option.label).tag(option)
                }
            }
            .frame(width: 240)
        }
    }
}

private enum ToolbarStyleOption: String, CaseIterable, Identifiable {
    case unified, unifiedCompact, expanded

    var id: Self { self }
    var label: String { ".\(rawValue)" }
}

/// Drawings of the three toolbar styles, from Apple's descriptions:
/// unified puts the title and toolbar on one row, compact makes that row
/// shorter, and expanded puts the title above the toolbar.
private struct ToolbarStyleSample: View {
    @State private var style = ToolbarStyleOption.unified

    var body: some View {
        VStack(spacing: 16) {
            VStack(spacing: 0) {
                switch style {
                case .unified, .unifiedCompact:
                    HStack(spacing: 12) {
                        WindowsNavWindowButtons()
                        Text("Inbox")
                            .font(.headline)
                        Spacer()
                        toolbarItems
                    }
                    .padding(.horizontal, 14)
                    .frame(height: style == .unified ? 52 : 38)
                case .expanded:
                    VStack(spacing: 6) {
                        ZStack {
                            HStack {
                                WindowsNavWindowButtons()
                                Spacer()
                            }
                            Text("Inbox")
                                .font(.headline)
                        }
                        HStack {
                            Spacer()
                            toolbarItems
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                }
                Divider()
                Color.clear
            }
            .background(.bar)
            .frame(width: 360, height: 140)
            .windowsNavChrome()
            .animation(.snappy, value: style)
            Picker("Style", selection: $style) {
                ForEach(ToolbarStyleOption.allCases) { option in
                    Text(option.label).tag(option)
                }
            }
            .pickerStyle(.segmented)
            .labelsHidden()
            .frame(width: 320)
        }
    }

    private var toolbarItems: some View {
        HStack(spacing: 14) {
            Image(systemName: "square.and.pencil")
            Image(systemName: "archivebox")
            Image(systemName: "trash")
        }
        .imageScale(.large)
        .foregroundStyle(.secondary)
    }
}

/// The custom-frame "Don't": square buttons with letters instead of the
/// system's window buttons.
private struct CustomFrameSample: View {
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 6) {
                ForEach(["×", "–", "+"], id: \.self) { symbol in
                    Text(symbol)
                        .font(.caption.bold())
                        .frame(width: 14, height: 14)
                        .background(.gray.opacity(0.3), in: .rect(cornerRadius: 3))
                }
                Text("Library")
                    .font(.headline)
                    .padding(.leading, 6)
                Spacer()
            }
            .padding(.horizontal, 14)
            .frame(height: 44)
            .background(.bar)
            Divider()
            Color.clear
        }
        .frame(width: 230, height: 90)
        .windowsNavChrome()
    }
}

/// The see-through demo window: a material background, no toolbar title
/// or backing, and dragging anywhere moves the window.
private struct ClearWindowSample: View {
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "music.note")
                .font(.system(size: 40))
                .foregroundStyle(.secondary)
            Text("Now Playing")
                .font(.title)
            Text("Drag anywhere to move this window.")
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(.rect)
        .containerBackground(.thinMaterial, for: .window)
        .toolbarBackgroundVisibility(.hidden, for: .windowToolbar)
        .toolbar(removing: .title)
        .gesture(WindowDragGesture())
        .allowsWindowActivationEvents()
    }
}

/// A window that can't be resized, minimized, or made full screen.
private struct FixedWindowSample: View {
    var body: some View {
        VStack(spacing: 8) {
            Text("25:00")
                .font(.system(size: 44, weight: .medium, design: .rounded).monospacedDigit())
            Text("This window can't be resized or minimized.")
                .font(.callout)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .windowResizeBehavior(.disabled)
        .windowMinimizeBehavior(.disabled)
        .windowFullScreenBehavior(.disabled)
    }
}
