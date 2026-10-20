import SwiftUI
import UIKit

extension ComponentPage {
    static let darkMode = ComponentPage(
        id: "dark-mode",
        title: "Dark Mode",
        summary: "Use colors that adapt, so your app looks right in light and dark.",
        category: .foundations,
        kind: .concept,
        symbol: "moon",
        availability: ["iOS 13.0+"],
        docsURL: "https://developer.apple.com/documentation/uikit/supporting-dark-mode-in-your-interface",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/dark-mode",
        aliases: ["dark theme", "night mode", "light mode", "theme", "appearance", "prefers-color-scheme", "color scheme", "colorScheme", "userInterfaceStyle", "overrideUserInterfaceStyle", "dark variant"],
        related: ["system-colors", "materials", "color-and-contrast", "sf-symbols", "foreground-style", "image"],
        notes: [
            "**Dark isn't light turned upside down.** Apple's dark palette uses dimmer backgrounds and brighter foregrounds, and many colors aren't simple inversions. Pick each dark value on purpose.",
            "**Leave people's own colors alone.** If someone picks a color for their content, like ink in a drawing, keep it in both modes. Adaptive colors are for your app's chrome.",
        ],
        api: [
            APIItem("`.foregroundStyle(.secondary)`", "Text styles that adapt on their own."),
            APIItem("`Color(\"Brand\")`", "A Color Set with a dark variant."),
            APIItem("`\\.colorScheme`", "Reads `.light` or `.dark`."),
            APIItem("`.preferredColorScheme(_:)`", "Forces one mode for a presentation."),
            APIItem("`\\.colorSchemeContrast`", "Tells you if Increase Contrast is on."),
        ],
        guidelines: [
            Guideline(
                "Use colors that adapt.",
                "System styles like `.primary` and `.secondary` switch with the appearance. A fixed value like `.black` stays black, even on a black background.",
                good: "`.primary` text stays readable in both modes.",
                bad: "Hard-coded `.black` text vanishes in dark."
            ) {
                DarkModeSideBySide(compact: true) {
                    DarkModeLabelSample(fixed: false)
                }
            } bad: {
                DarkModeSideBySide(compact: true) {
                    DarkModeLabelSample(fixed: true)
                }
            },
            Guideline(
                "Follow the system setting.",
                "Skip an in-app Light / Dark switch. People already chose in Settings, and an app that ignores it can look broken."
            ),
            Guideline(
                "Let sheets and popovers lift.",
                "In dark mode, iOS gives views in front a slightly lighter, elevated background. Use the system backgrounds so a sheet separates from the screen behind it.",
                good: "The system background lifts the sheet.",
                bad: "A custom black sheet blends into the screen."
            ) {
                DarkModeSheetSample(elevated: true)
            } bad: {
                DarkModeSheetSample(elevated: false)
            },
            Guideline(
                "Tone down bright images.",
                "A photo with a white background glows on a dark screen. Darken it slightly in dark mode.",
                good: "Slightly dimmed, it sits in the page.",
                bad: "Full white glares."
            ) {
                DarkModeProductTile(dimmed: true)
                    .environment(\.colorScheme, .dark)
            } bad: {
                DarkModeProductTile(dimmed: false)
                    .environment(\.colorScheme, .dark)
            },
            Guideline(
                "Check contrast in both modes.",
                "Text needs at least 4.5:1 contrast with its background, and Apple suggests aiming for 7:1 with custom colors in small text. A gray that works on white often fails on black."
            ),
        ],
        sources: [
            "https://developer.apple.com/design/human-interface-guidelines/dark-mode",
            "https://developer.apple.com/documentation/uikit/supporting-dark-mode-in-your-interface",
            "https://developer.apple.com/documentation/swiftui/environmentvalues/colorscheme",
            "https://developer.apple.com/documentation/swiftui/view/preferredcolorscheme(_:)",
        ],
        reviewed: "October 2026"
    ) {
        HStack(spacing: 0) {
            DarkModeThumbHalf(scheme: .light)
            DarkModeThumbHalf(scheme: .dark)
        }
        .clipShape(.rect(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(.separator)
        }
        .accessibilityHidden(true)
    } content: { page in
        DarkModeArticle(page: page)
    }
}

// MARK: - Page

private struct DarkModeArticle: View {
    let page: ComponentPage

    var body: some View {
        ArticlePage(page: page) {
            Prose("Many people run their iPhone in dark mode, and some let it switch automatically through the day, even while your app is open. If you build with **system colors and styles**, most of your app adapts for free. The work is in the colors, images, and backgrounds you pick yourself.")

            VStack(alignment: .leading, spacing: 16) {
                SectionTitle("Flip it")
                DarkModeFlipDemo()
            }
            .id("demo")

            VStack(alignment: .leading, spacing: 16) {
                SectionTitle("In SwiftUI")
                VStack(alignment: .leading, spacing: 44) {
                    ExampleCard(
                        title: "Use semantic styles",
                        caption: "Use `.primary`, `.secondary`, and the system backgrounds instead of fixed colors, and dark mode comes for free.",
                        code: """
                        HStack(spacing: 12) {
                            Image(systemName: "figure.run")
                                .foregroundStyle(.tint)
                            VStack(alignment: .leading) {
                                Text("Morning Run")
                                    .foregroundStyle(.primary)
                                Text("5.2 km")
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground),
                                    in: .rect(cornerRadius: 12))
                        """,
                        minHeight: 150
                    ) {
                        DarkModeSideBySide {
                            DarkModeRunCard(fixed: false)
                        }
                    }

                    ExampleCard(
                        title: "Add your own color with a dark variant",
                        caption: "Add a Color Set to your asset catalog with a light and a dark value, then use it by name.",
                        code: """
                        // Brand: a Color Set with a Dark variant
                        Text("Pro")
                            .font(.caption.bold())
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .foregroundStyle(.white)
                            .background(Color("Brand"), in: .capsule)
                        """,
                        minHeight: 130,
                        aside: Aside(.note, "The color switches on its own: no `if` in your view. Pick a brighter dark value so it still stands out on a dark background.")
                    ) {
                        DarkModeSideBySide {
                            Text("Pro")
                                .font(.caption.bold())
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .foregroundStyle(.white)
                                .background(DarkModeBrand.color, in: .capsule)
                        }
                    }

                    ExampleCard(
                        title: "Adjust an image for dark mode",
                        caption: "Read `colorScheme` when an asset variant can't do the job, like dimming a white product photo.",
                        code: """
                        @Environment(\\.colorScheme) private var colorScheme

                        Image(systemName: "cup.and.saucer.fill")
                            .font(.largeTitle)
                            .foregroundStyle(.brown)
                            .frame(width: 96, height: 96)
                            .background(.white, in: .rect(cornerRadius: 12))
                            .brightness(colorScheme == .dark ? -0.12 : 0)
                        """,
                        minHeight: 160,
                        aside: Aside(.note, "For an image that needs different artwork, add a Dark appearance to the image set in your asset catalog instead.")
                    ) {
                        DarkModeSideBySide {
                            DarkModeProductTile(dimmed: true)
                        }
                    }

                    ExampleCard(
                        title: "Keep a media screen dark",
                        caption: "Use `.preferredColorScheme(.dark)` on a screen built for photos or video, so the interface stays out of the way.",
                        code: """
                        @State private var showViewer = false

                        Button("View Photo") { showViewer = true }
                            .fullScreenCover(isPresented: $showViewer) {
                                Image(systemName: "photo")
                                    .font(.system(size: 80))
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .background(.black)
                                    .onTapGesture { showViewer = false }
                                    .preferredColorScheme(.dark)
                            }
                        """,
                        minHeight: 160,
                        aside: Aside(.important, "It overrides people's choice for that whole presentation. Use it for rare cases like a photo viewer, never to skip supporting dark mode.")
                    ) {
                        DarkModeViewerSample()
                    }
                }
            }
            .id("examples")

            VStack(alignment: .leading, spacing: 16) {
                SectionTitle("Test both appearances")
                Prose("Check every screen in light and dark before you ship:")
                VStack(alignment: .leading, spacing: 12) {
                    DarkModeStep(symbol: "rectangle.on.rectangle", text: "Add a second Xcode preview with `.preferredColorScheme(.dark)`, so you see both while you work.")
                    DarkModeStep(symbol: "clock.arrow.2.circlepath", text: "Try the **Automatic** appearance on a device. The mode can change while your app is open, so nothing should be cached at launch.")
                    DarkModeStep(symbol: "circle.lefthalf.striped.horizontal", text: "Turn on **Increase Contrast** and **Reduce Transparency**, one at a time and together. Dark text on dark fills is where problems hide.")
                }
                CodeBlock(code: """
                #Preview("Light") { ContentView() }
                #Preview("Dark") {
                    ContentView()
                        .preferredColorScheme(.dark)
                }
                """)
            }
            .id("testing")
        }
    }
}

// MARK: - Demo

private struct DarkModeFlipDemo: View {
    @State private var fixed = false

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("The same card in both modes. Switch to hard-coded colors and look at the dark side.")
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            VStack(spacing: 0) {
                DarkModeSideBySide {
                    DarkModeRunCard(fixed: fixed)
                }
                .padding(14)
                .frame(maxWidth: .infinity)
                Divider()
                VStack(alignment: .leading, spacing: 10) {
                    Picker("Colors", selection: $fixed) {
                        Text("Semantic").tag(false)
                        Text("Hard-coded").tag(true)
                    }
                    .pickerStyle(.segmented)
                    RichText(fixed
                         ? "`.black` text and a `Color(white: 0.95)` card never change, so dark mode gets a glaring gray box."
                         : "`.primary`, `.secondary`, and system backgrounds pick the right value for each mode.")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                        .animation(nil, value: fixed)
                }
                .padding(14)
            }
            .cardStyle()
        }
    }
}

// MARK: - Shared preview views

/// Shows the same content twice, forced to light and to dark, each on its
/// own system background.
private struct DarkModeSideBySide<Content: View>: View {
    var compact = false
    @ViewBuilder let content: Content

    var body: some View {
        HStack(spacing: compact ? 8 : 10) {
            pane(.light)
            pane(.dark)
        }
    }

    private func pane(_ scheme: ColorScheme) -> some View {
        VStack(spacing: 6) {
            content
                .padding(compact ? 10 : 12)
                .frame(maxWidth: .infinity, minHeight: compact ? 70 : 96)
                .background(Color(.systemBackground))
                .clipShape(.rect(cornerRadius: 12))
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(.separator)
                }
                .environment(\.colorScheme, scheme)
            Text(scheme == .dark ? "Dark" : "Light")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

private struct DarkModeRunCard: View {
    let fixed: Bool

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "figure.run")
                .font(.title3)
                .foregroundStyle(fixed ? Color(red: 0, green: 0.48, blue: 1) : .blue)
            VStack(alignment: .leading, spacing: 2) {
                Text("Morning Run")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(fixed ? Color.black : .primary)
                Text("5.2 km")
                    .font(.caption)
                    .foregroundStyle(fixed ? Color(white: 0.45) : .secondary)
            }
            .lineLimit(1)
            .minimumScaleFactor(0.8)
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(fixed ? Color(white: 0.95) : Color(.secondarySystemBackground), in: .rect(cornerRadius: 10))
    }
}

private struct DarkModeLabelSample: View {
    let fixed: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Inbox")
                .font(.subheadline.weight(.semibold))
            Text("3 unread")
                .font(.caption)
        }
        .foregroundStyle(fixed ? Color.black : .primary)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private enum DarkModeBrand {
    /// Stand-in for an asset catalog Color Set with Any and Dark values.
    static let color = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.55, green: 0.42, blue: 1, alpha: 1)
            : UIColor(red: 0.38, green: 0.2, blue: 0.85, alpha: 1)
    })
}

/// A sheet over a screen, both in dark mode. The real elevated color comes
/// from resolving the system background with an elevated trait.
private struct DarkModeSheetSample: View {
    let elevated: Bool

    private static let elevatedBackground = Color(UIColor.systemBackground.resolvedColor(
        with: UITraitCollection(traitsFrom: [
            UITraitCollection(userInterfaceStyle: .dark),
            UITraitCollection(userInterfaceLevel: .elevated),
        ])
    ))

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(0..<3) { _ in
                    RoundedRectangle(cornerRadius: 3)
                        .fill(.white.opacity(0.18))
                        .frame(height: 8)
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(.black)

            VStack(spacing: 8) {
                Capsule()
                    .fill(.white.opacity(0.3))
                    .frame(width: 30, height: 4)
                Text("New Note")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                Spacer(minLength: 0)
            }
            .padding(.top, 6)
            .frame(maxWidth: .infinity)
            .frame(height: 70)
            .background(elevated ? Self.elevatedBackground : .black,
                        in: UnevenRoundedRectangle(topLeadingRadius: 14, topTrailingRadius: 14))
        }
        .frame(width: 200, height: 130)
        .clipShape(.rect(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(.white.opacity(0.15))
        }
        .environment(\.colorScheme, .dark)
    }
}

private struct DarkModeProductTile: View {
    let dimmed: Bool
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Image(systemName: "cup.and.saucer.fill")
            .font(.largeTitle)
            .foregroundStyle(.brown)
            .frame(width: 96, height: 96)
            .background(.white, in: .rect(cornerRadius: 12))
            .brightness(dimmed && colorScheme == .dark ? -0.12 : 0)
            .padding(10)
            .background(Color(.systemBackground), in: .rect(cornerRadius: 16))
    }
}

private struct DarkModeViewerSample: View {
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "photo")
                .font(.system(size: 44))
                .foregroundStyle(.white.opacity(0.85))
                .frame(width: 200, height: 120)
                .background(.black, in: .rect(cornerRadius: 12))
            Text("Always dark, whatever the system mode.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

private struct DarkModeStep: View {
    let symbol: String
    let text: String

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            Image(systemName: symbol)
                .foregroundStyle(.tint)
                .frame(width: 24)
            RichText(text)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

private struct DarkModeThumbHalf: View {
    let scheme: ColorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Image(systemName: scheme == .dark ? "moon.fill" : "sun.max.fill")
                .foregroundStyle(scheme == .dark ? .indigo : .orange)
            Text("Aa")
                .font(.title.bold())
                .foregroundStyle(.primary)
            RoundedRectangle(cornerRadius: 3)
                .fill(.secondary)
                .frame(width: 44, height: 6)
        }
        .padding(14)
        .frame(width: 92, height: 110, alignment: .leading)
        .background(Color(.systemBackground))
        .environment(\.colorScheme, scheme)
    }
}
