import SwiftUI

extension ComponentPage {
    static let fullScreen = ComponentPage(
        id: "full-screen",
        title: "Full screen",
        summary: "Let a window fill the screen for focused work, and keep what people need in reach.",
        category: .patterns,
        kind: .concept,
        symbol: "arrow.up.left.and.arrow.down.right",
        availability: ["macOS 15.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/view/windowtoolbarfullscreenvisibility(_:)",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/going-full-screen",
        aliases: [
            "full-screen mode", "Enter Full Screen", "⌃⌘F", "green button", "zoom", "presentation mode",
            "distraction free", "windowToolbarFullScreenVisibility", "windowFullScreenBehavior",
            "appearsActive", "toggleFullScreen", "kiosk",
        ],
        related: ["windows-tabs", "toolbars-pattern", "menu-bar-conventions", "window-style"],
        notes: [
            "**Full screen comes with the window.** SwiftUI decides from the scene and its modifiers. With `.windowResizability`, the content's maximum size also decides whether a window can go full screen.",
            "**Option-click the green button to zoom instead.** The window grows to its maximum size, or as large as the display allows.",
        ],
        api: [
            APIItem("`.windowToolbarFullScreenVisibility(_:)`", "Shows the toolbar only on hover in full screen."),
            APIItem("`.windowFullScreenBehavior(.disabled)`", "Keeps a window out of full screen."),
            APIItem("`\\.appearsActive`", "False when the window isn't the active one."),
            APIItem("`.toolbarVisibility(_:for:)`", "Hides the window's toolbar entirely."),
        ],
        guidelines: [
            Guideline(
                "Offer full screen where focus helps.",
                "Games, photos, video, slideshows, and deep work like writing benefit most from filling the screen."
            ),
            Guideline(
                "Use the system's full screen.",
                "The green button, View > Enter Full Screen, and ⌃⌘F already work and handle things like the camera housing on some Macs. Don't add a menu of your own window modes.",
                good: "The standard item in the View menu.",
                bad: "A custom menu of window modes."
            ) {
                DPMenuDrawing(title: "View", items: [
                    .item("Show Sidebar"),
                    .divider,
                    .item("Enter Full Screen", "⌃⌘F", highlighted: true),
                ], width: 220)
            } bad: {
                DPMenuDrawing(title: "View", items: [
                    .item("Show Sidebar"),
                    .divider,
                    .item("Window Mode: Borderless", highlighted: true),
                ], width: 220)
            },
            Guideline(
                "Adjust the layout, not the window.",
                "Use the extra room for the content, with subtle changes so switching modes isn't jarring. Never resize the window from code."
            ),
            Guideline(
                "Keep essential controls in reach.",
                "People should finish their task without leaving full screen, like playback controls that are always there or easy to reveal."
            ),
            Guideline(
                "Hide toolbars when content is the point, and bring them back on request.",
                "For reading or viewing, tuck controls away, and show them when people move the pointer to the top of the screen."
            ),
            Guideline(
                "Let people decide when to leave, and pause when they look away.",
                "Don't end full screen on your own when something finishes. If people switch away, pause a game or slideshow so they don't miss anything."
            ),
        ],
        sources: [
            "https://developer.apple.com/design/human-interface-guidelines/going-full-screen",
            "https://developer.apple.com/design/human-interface-guidelines/the-menu-bar",
            "https://developer.apple.com/design/human-interface-guidelines/keyboards",
            "https://developer.apple.com/documentation/swiftui/view/windowtoolbarfullscreenvisibility(_:)",
            "https://developer.apple.com/documentation/swiftui/windowtoolbarfullscreenvisibility",
            "https://developer.apple.com/documentation/swiftui/view/windowfullscreenbehavior(_:)",
            "https://developer.apple.com/documentation/swiftui/environmentvalues/appearsactive",
            "https://developer.apple.com/documentation/swiftui/customizing-window-styles-and-state-restoration-behavior-in-macos",
        ],
        reviewed: "October 2026"
    ) {
        ZStack {
            SceneryView(.lake)
                .frame(width: 170, height: 100)
                .clipShape(.rect(cornerRadius: 8))
            Image(systemName: "arrow.up.left.and.arrow.down.right")
                .font(.title2.weight(.semibold))
                .foregroundStyle(.white)
                .shadow(radius: 4)
        }
        .accessibilityHidden(true)
    } content: { page in
        MacFullScreenArticle(page: page)
    }
}

extension Catalog {
    /// A slideshow window to take full screen.
    static let fullScreenDemoWindow = DemoWindow(id: "dp-slideshow", title: "Slideshow", size: CGSize(width: 640, height: 420)) {
        SlideshowSample()
            .windowToolbarFullScreenVisibility(.onHover)
    }
}

// MARK: - Page

private struct MacFullScreenArticle: View {
    let page: ComponentPage

    var body: some View {
        ArticlePage(page: page) {
            Prose("Any Mac window that can grow can usually fill the screen in a space of its own: people click the green window button, choose **View > Enter Full Screen**, or press ⌃⌘F. The menu bar hides until the pointer reaches the top of the screen, and by default the window's toolbar stays at the top, above the content.")
            Prose("SwiftUI windows get this for free. Your part is the layout, deciding what to hide, and pausing when people switch away.")

            VStack(alignment: .leading, spacing: 16) {
                SectionTitle("Try it")
                Prose("Open the slideshow, then click its green button. Its toolbar hides until you move the pointer to the top. Switch to another app and the slideshow pauses.")
                OpenDemoWindowButton(id: "dp-slideshow", label: "Open the Slideshow")
                    .controlSize(.large)
            }
            .id("demo")

            VStack(alignment: .leading, spacing: 16) {
                SectionTitle("Examples")
                    .id("examples")
                VStack(alignment: .leading, spacing: 44) {
                    ExampleCard(
                        title: "Tuck the toolbar away in full screen",
                        caption: "`.windowToolbarFullScreenVisibility(.onHover)` hides the toolbar in full screen until the pointer moves to the top.",
                        code: """
                        SlideshowView()
                            .toolbar {
                                Button("Pause", systemImage: "pause") { }
                            }
                            .windowToolbarFullScreenVisibility(.onHover)
                        """,
                        minHeight: 220,
                        aside: Aside(.note, "It only affects the window it's in. The slideshow above uses it; the preview draws the result.")
                    ) {
                        DPFullScreenDrawing()
                    }

                    ExampleCard(
                        title: "Pause when the window isn't active",
                        caption: "Run the timer only while `appearsActive` is true; it turns false when people switch to another window or app.",
                        code: """
                        @Environment(\\.appearsActive) private var appearsActive
                        @State private var slide = 0

                        Text("Slide \\(slide + 1)")
                            .task(id: appearsActive) {
                                guard appearsActive else { return }
                                while !Task.isCancelled {
                                    try? await Task.sleep(for: .seconds(2))
                                    slide = (slide + 1) % 5
                                }
                            }
                        """,
                        minHeight: 130
                    ) {
                        ActiveSample()
                    }

                    ExampleCard(
                        title: "Keep a utility window out of full screen",
                        caption: "Add `.windowFullScreenBehavior(.disabled)` to a small panel's content, like a color mixer, that has no use for the whole screen.",
                        code: """
                        Window("Color Mixer", id: "mixer") {
                            ColorMixer()
                                .windowFullScreenBehavior(.disabled)
                        }
                        """,
                        minHeight: 170
                    ) {
                        MacWindowFrame(title: "Color Mixer", width: 260, height: 130) {
                            HStack(spacing: 10) {
                                ForEach([Color.red, .orange, .blue], id: \.self) { color in
                                    Circle().fill(color.gradient).frame(width: 30, height: 30)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Samples

/// The demo window's slideshow: pauses with a button, and on its own
/// whenever the window isn't active.
private struct SlideshowSample: View {
    @Environment(\.appearsActive) private var appearsActive
    @State private var index = 0
    @State private var isPlaying = true

    private let slides: [Scenery] = [.lake, .city, .meadow, .wallpaper]
    private var isRunning: Bool { isPlaying && appearsActive }

    var body: some View {
        SceneryView(slides[index])
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay(alignment: .bottomLeading) {
                Label(isRunning ? "Playing" : "Paused", systemImage: isRunning ? "play.fill" : "pause.fill")
                    .font(.callout.weight(.medium))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(.regularMaterial, in: .capsule)
                    .padding(16)
            }
            .toolbar {
                Button(isPlaying ? "Pause" : "Play", systemImage: isPlaying ? "pause" : "play") {
                    isPlaying.toggle()
                }
            }
            .task(id: isRunning) {
                guard isRunning else { return }
                while !Task.isCancelled {
                    try? await Task.sleep(for: .seconds(3))
                    withAnimation(.easeInOut(duration: 0.6)) {
                        index = (index + 1) % slides.count
                    }
                }
            }
    }
}

private struct ActiveSample: View {
    @Environment(\.appearsActive) private var appearsActive
    @State private var slide = 0

    var body: some View {
        VStack(spacing: 10) {
            Text("Slide \(slide + 1)")
                .font(.title2.monospacedDigit())
                .task(id: appearsActive) {
                    guard appearsActive else { return }
                    while !Task.isCancelled {
                        try? await Task.sleep(for: .seconds(2))
                        slide = (slide + 1) % 5
                    }
                }
            Text("appearsActive = \(appearsActive ? "true" : "false")")
                .font(.footnote.monospaced())
                .foregroundStyle(.secondary)
        }
    }
}

/// A drawing of a full-screen slideshow with its toolbar tucked away.
private struct DPFullScreenDrawing: View {
    var body: some View {
        SceneryView(.lake)
            .frame(width: 420, height: 200)
            .overlay(alignment: .top) {
                Text("Toolbar appears when the pointer reaches the top")
                    .font(.caption)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(.black.opacity(0.45), in: .capsule)
                    .padding(.top, 8)
            }
            .clipShape(.rect(cornerRadius: 6))
            .overlay {
                RoundedRectangle(cornerRadius: 6).strokeBorder(.separator)
            }
    }
}
