import AppKit
import SwiftUI

extension ComponentPage {
    static let darkMode = ComponentPage(
        id: "dark-mode",
        title: "Dark Mode",
        summary: "Build from colors that adapt, so your app looks right in light, dark, and Auto.",
        category: .foundations,
        kind: .concept,
        symbol: "moon",
        availability: [],
        docsURL: "https://developer.apple.com/documentation/swiftui/environmentvalues/colorscheme",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/dark-mode",
        aliases: ["dark theme", "night mode", "light mode", "appearance", "auto appearance", "prefers-color-scheme", "color scheme", "colorScheme", "NSAppearance", "desktop tinting", "graphite", "effectiveAppearance"],
        related: ["color", "materials", "contrast-transparency", "sf-symbols", "settings-pattern"],
        notes: [
            "**Dark isn't light turned inside out.** The dark palette uses dimmer backgrounds and brighter foregrounds, and many colors aren't simple inversions. Pick each dark value on purpose.",
            "**Appearance can change while your app runs.** With Auto, the Mac switches during the day. Read colors when you draw, never once at launch.",
        ],
        api: [
            APIItem("`.foregroundStyle(.secondary)`", "Text styles that adapt on their own."),
            APIItem("`Color(\"Brand\")`", "A Color Set with a dark variant."),
            APIItem("`\\.colorScheme`", "Reads `.light` or `.dark`."),
            APIItem("`.preferredColorScheme(_:)`", "Forces one appearance, for rare cases."),
            APIItem("`\\.colorSchemeContrast`", "Tells you if Increase Contrast is on."),
            APIItem("`.fill.tertiary`", "A see-through fill that picks up desktop tinting."),
        ],
        guidelines: [
            Guideline(
                "Use colors that adapt.",
                "Styles like `.primary` and `.secondary` switch with the appearance. A fixed color like `.black` stays black, even on a dark window.",
                good: "`.primary` text reads in both.",
                bad: "Fixed `.black` text disappears in dark."
            ) {
                MacDesignAppearancePair(minHeight: 60) {
                    MacDarkLabel(fixed: false)
                }
            } bad: {
                MacDesignAppearancePair(minHeight: 60) {
                    MacDarkLabel(fixed: true)
                }
            },
            Guideline(
                "Follow the system setting.",
                "Skip an appearance switch in your app. People already chose one for the whole Mac, and an app that ignores it looks broken."
            ),
            Guideline(
                "Tone down bright images.",
                "A picture with a white background glows in a dark window. Darken it slightly in Dark Mode.",
                good: "Slightly dimmed, it sits in the window.",
                bad: "Full white glares."
            ) {
                MacDarkProductTile(dims: true)
                    .environment(\.colorScheme, .dark)
            } bad: {
                MacDarkProductTile(dims: false)
                    .environment(\.colorScheme, .dark)
            },
            Guideline(
                "Check contrast in both appearances.",
                "Text needs a contrast ratio of at least 4.5:1, and Apple suggests 7:1 for custom colors in small text. A gray that works on white often fails on a dark gray."
            ),
            Guideline(
                "Let system views draw text.",
                "Text fields and text views adjust for the appearance and for vibrancy on their own. Drawing text yourself means doing that work too."
            ),
            Guideline(
                "Stay dark only when content calls for it.",
                "A viewer for photos or video can stay dark so the interface recedes. Everything else should follow the person's choice."
            ),
        ],
        sources: [
            "https://developer.apple.com/design/human-interface-guidelines/dark-mode",
            "https://developer.apple.com/documentation/swiftui/environmentvalues/colorscheme",
            "https://developer.apple.com/documentation/swiftui/view/preferredcolorscheme(_:)",
            "https://developer.apple.com/documentation/swiftui/environmentvalues/colorschemecontrast",
            "https://developer.apple.com/documentation/appkit/choosing-a-specific-appearance-for-your-macos-app",
        ],
        reviewed: "October 2026"
    ) {
        HStack(spacing: 0) {
            MacDarkThumbHalf(scheme: .light)
            MacDarkThumbHalf(scheme: .dark)
        }
        .clipShape(.rect(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(.separator)
        }
        .accessibilityHidden(true)
    } content: { page in
        MacDarkModeArticle(page: page)
    }
}

// MARK: - Page

private struct MacDarkModeArticle: View {
    let page: ComponentPage

    var body: some View {
        ArticlePage(page: page) {
            Prose("Many people run their Mac in Dark Mode, and some choose **Auto**, which switches between light and dark through the day, even while your app is open. In Dark Mode every window, menu, and control turns dark. If you build with semantic colors and system views, most of your app follows along for free. The work is in the colors, images, and backgrounds you choose yourself.")

            VStack(alignment: .leading, spacing: 16) {
                SectionTitle("Flip it")
                    .id("demo")
                MacDarkFlipDemo()
            }

            VStack(alignment: .leading, spacing: 16) {
                SectionTitle("Desktop tinting")
                Prose("When people choose the **graphite** accent color, the Mac tints window backgrounds with a little color from the desktop picture, so windows blend in with what's around them.")
                Prose("Give custom backgrounds some transparency, like `.fill.tertiary`, so they pick up the tint too. Do it only in a neutral state: a colored background that's also see-through shifts color as the window moves.")
            }

            VStack(alignment: .leading, spacing: 16) {
                SectionTitle("In SwiftUI")
                    .id("examples")
                VStack(alignment: .leading, spacing: 44) {
                    ExampleCard(
                        title: "Use semantic styles",
                        caption: "Use `.primary`, `.secondary`, `.tint`, and translucent fills instead of fixed colors, and Dark Mode comes for free.",
                        code: """
                        HStack(spacing: 10) {
                            Image(systemName: "airplane")
                                .foregroundStyle(.tint)
                            VStack(alignment: .leading) {
                                Text("Flight to Lisbon")
                                Text("Gate B12 · 9:40 AM")
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(10)
                        .background(.fill.tertiary, in: .rect(cornerRadius: 8))
                        """,
                        minHeight: 150
                    ) {
                        MacDesignAppearancePair {
                            MacDarkFlightCard(fixed: false)
                        }
                    }

                    ExampleCard(
                        title: "Your own color, with a dark variant",
                        caption: "Add a Color Set to the asset catalog with an Any and a Dark value, then use it by name.",
                        code: """
                        // Brand: a Color Set with a Dark Appearance variant
                        Text("Pro")
                            .font(.caption.bold())
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .foregroundStyle(.white)
                            .background(Color("Brand"), in: .capsule)
                        """,
                        minHeight: 130,
                        aside: Aside(.note, "The color switches on its own: no `if` in your view. Pick a brighter dark value so it still stands out on a dark window.")
                    ) {
                        MacDesignAppearancePair {
                            Text("Pro")
                                .font(.caption.bold())
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .foregroundStyle(.white)
                                .background(MacDarkBrand.color, in: .capsule)
                        }
                    }

                    ExampleCard(
                        title: "Adjust an image in Dark Mode",
                        caption: "Read `colorScheme` when an asset variant can't do the job, like dimming a product photo on white.",
                        code: """
                        @Environment(\\.colorScheme) private var colorScheme

                        Image(systemName: "cup.and.saucer.fill")
                            .font(.largeTitle)
                            .foregroundStyle(.brown)
                            .frame(width: 96, height: 96)
                            .background(.white, in: .rect(cornerRadius: 12))
                            .brightness(colorScheme == .dark ? -0.12 : 0)
                        """,
                        minHeight: 170,
                        aside: Aside(.note, "For an image that needs different artwork, add a Dark appearance to its image set in the asset catalog instead.")
                    ) {
                        MacDesignAppearancePair {
                            MacDarkProductTile(dims: true)
                        }
                    }

                    ExampleCard(
                        title: "Keep a media window dark",
                        caption: "Use `.preferredColorScheme(.dark)` for a window made for photos or video, so the interface stays out of the way.",
                        code: """
                        WindowGroup("Slideshow", id: "slideshow") {
                            SlideshowView()
                                .preferredColorScheme(.dark)
                        }
                        """,
                        minHeight: 200,
                        aside: Aside(.important, "It overrides people's choice. Use it for rare cases like a photo viewer, never to skip supporting Dark Mode.")
                    ) {
                        MacWindowFrame(title: "Slideshow", width: 320, height: 170) {
                            SceneryView(.lake)
                                .padding(16)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(.black)
                        }
                        .environment(\.colorScheme, .dark)
                    }
                }
            }

            VStack(alignment: .leading, spacing: 16) {
                SectionTitle("Test both appearances")
                    .id("testing")
                VStack(alignment: .leading, spacing: 12) {
                    MacDesignTip(symbol: "rectangle.on.rectangle", text: "Add a second Xcode preview with `.preferredColorScheme(.dark)`, so you see both while you work.")
                    MacDesignTip(symbol: "circle.lefthalf.filled", text: "Switch the Mac between Light, Dark, and Auto in System Settings, and watch for anything that doesn't update.")
                    MacDesignTip(symbol: "circle.lefthalf.striped.horizontal", text: "Turn on **Increase Contrast** and **Reduce Transparency**, one at a time and together. Dark text on dark backgrounds is where problems hide.")
                    MacDesignTip(symbol: "paintpalette", text: "Pick the graphite accent color to see your windows with desktop tinting.")
                }
                CodeBlock(code: """
                #Preview("Light") { ContentView() }
                #Preview("Dark") {
                    ContentView()
                        .preferredColorScheme(.dark)
                }
                """)
            }
        }
    }
}

// MARK: - Demo

private struct MacDarkFlipDemo: View {
    @State private var fixed = false

    var body: some View {
        VStack(spacing: 0) {
            MacDesignAppearancePair {
                MacDarkFlightCard(fixed: fixed)
            }
            .padding(16)
            .frame(maxWidth: .infinity)
            .background(Surface.preview)
            Divider()
            VStack(alignment: .leading, spacing: 10) {
                Picker("Colors", selection: $fixed) {
                    Text("Semantic").tag(false)
                    Text("Hard-coded").tag(true)
                }
                .pickerStyle(.segmented)
                .fixedSize()
                RichText(fixed
                    ? "`.black` text on a `Color(white: 0.94)` card never changes, so the dark window gets a glaring gray box."
                    : "`.primary`, `.secondary`, and a translucent fill pick the right value for each appearance.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .cardStyle()
    }
}

// MARK: - Samples

private struct MacDarkFlightCard: View {
    let fixed: Bool

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "airplane")
                .foregroundStyle(fixed ? AnyShapeStyle(Color(red: 0, green: 0.48, blue: 1)) : AnyShapeStyle(.tint))
            VStack(alignment: .leading) {
                Text("Flight to Lisbon")
                    .foregroundStyle(fixed ? AnyShapeStyle(Color.black) : AnyShapeStyle(.primary))
                Text("Gate B12 · 9:40 AM")
                    .foregroundStyle(fixed ? AnyShapeStyle(Color(white: 0.45)) : AnyShapeStyle(.secondary))
            }
            .lineLimit(1)
        }
        .padding(10)
        .background(fixed ? AnyShapeStyle(Color(white: 0.94)) : AnyShapeStyle(.fill.tertiary), in: .rect(cornerRadius: 8))
    }
}

private struct MacDarkLabel: View {
    let fixed: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Inbox")
                .font(.headline)
            Text("3 unread")
        }
        .foregroundStyle(fixed ? AnyShapeStyle(Color.black) : AnyShapeStyle(.primary))
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private enum MacDarkBrand {
    /// Stand-in for an asset catalog Color Set with Any and Dark values.
    /// AppKit's dynamic provider is the only way to build one in code.
    static let color = Color(nsColor: NSColor(name: nil) { appearance in
        appearance.bestMatch(from: [.aqua, .darkAqua]) == .darkAqua
            ? NSColor(red: 0.55, green: 0.42, blue: 1, alpha: 1)
            : NSColor(red: 0.38, green: 0.2, blue: 0.85, alpha: 1)
    })
}

private struct MacDarkProductTile: View {
    let dims: Bool
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Image(systemName: "cup.and.saucer.fill")
            .font(.largeTitle)
            .foregroundStyle(.brown)
            .frame(width: 96, height: 96)
            .background(.white, in: .rect(cornerRadius: 12))
            .brightness(dims && colorScheme == .dark ? -0.12 : 0)
            .padding(10)
            .background(.windowBackground, in: .rect(cornerRadius: 16))
    }
}

private struct MacDarkThumbHalf: View {
    let scheme: ColorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Image(systemName: scheme == .dark ? "moon.fill" : "sun.max.fill")
                .foregroundStyle(scheme == .dark ? .indigo : .orange)
            Text("Aa")
                .font(.title.bold())
            RoundedRectangle(cornerRadius: 3)
                .fill(.secondary)
                .frame(width: 44, height: 6)
        }
        .padding(14)
        .frame(width: 92, height: 110, alignment: .leading)
        .background(.windowBackground)
        .environment(\.colorScheme, scheme)
    }
}
