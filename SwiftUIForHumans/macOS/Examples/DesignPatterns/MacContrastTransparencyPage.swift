import SwiftUI

extension ComponentPage {
    static let contrastTransparency = ComponentPage(
        id: "contrast-transparency",
        title: "Contrast & transparency",
        summary: "Stay readable when people turn on Increase Contrast or Reduce Transparency.",
        category: .accessibility,
        kind: .concept,
        symbol: "circle.lefthalf.filled",
        availability: ["macOS 10.15+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/environmentvalues/colorschemecontrast",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/accessibility",
        aliases: [
            "Increase Contrast", "Reduce Transparency", "high contrast", "prefers-contrast",
            "prefers-reduced-transparency", "colorSchemeContrast", "accessibilityReduceTransparency",
            "Differentiate Without Color", "accessibilityDifferentiateWithoutColor", "contrast ratio",
            "WCAG", "color blind", "legibility",
        ],
        related: ["color", "materials", "dark-mode", "voiceover", "reduce-motion"],
        notes: [
            "**You can read these settings, not change them.** They belong to the person using the Mac, and SwiftUI redraws your views when they change.",
            "**Asset catalogs can do it without code.** If a color only needs a stronger version, give the color set a high-contrast variant instead of checking the setting in code.",
        ],
        api: [
            APIItem("`\\.colorSchemeContrast`", "`.increased` when Increase Contrast is on."),
            APIItem("`\\.accessibilityReduceTransparency`", "True when backgrounds should be opaque."),
            APIItem("`\\.accessibilityDifferentiateWithoutColor`", "True when color alone isn't enough."),
            APIItem("`\\.colorScheme`", "Light or dark, to check alongside contrast."),
            APIItem("`.foregroundStyle(.secondary)`", "System styles that adapt on their own."),
        ],
        guidelines: [
            Guideline(
                "Prefer system colors.",
                "System colors and styles already have versions for light, dark, and Increase Contrast. Custom colors need all of those from you."
            ),
            Guideline(
                "Meet the minimum contrast.",
                "Small text needs at least 4.5:1 against its background. Faint gray text may look elegant, but many people can't read it.",
                good: "Secondary text in the system `.secondary` style.",
                bad: "A pale custom gray that fades into the window."
            ) {
                DPContrastText(color: .secondary)
            } bad: {
                DPContrastText(color: .gray.opacity(0.35))
            },
            Guideline(
                "Never rely on color alone.",
                "Some people can't tell red from green. Add a symbol, shape, or word so the meaning survives without the color.",
                good: "Each status has its own symbol.",
                bad: "Only the dot's color tells them apart."
            ) {
                DPStatusList(usesSymbols: true)
            } bad: {
                DPStatusList(usesSymbols: false)
            },
            Guideline(
                "Offer more contrast when people ask for it.",
                "If your defaults are subtle, check `colorSchemeContrast` and strengthen borders, dividers, and secondary text when it's `.increased`."
            ),
            Guideline(
                "Check both appearances.",
                "A pairing that passes in light mode can fail in dark mode. Test each setting in both."
            ),
        ],
        sources: [
            "https://developer.apple.com/design/human-interface-guidelines/accessibility",
            "https://developer.apple.com/design/human-interface-guidelines/color",
            "https://developer.apple.com/design/human-interface-guidelines/materials",
            "https://developer.apple.com/documentation/swiftui/environmentvalues/colorschemecontrast",
            "https://developer.apple.com/documentation/swiftui/colorschemecontrast",
            "https://developer.apple.com/documentation/swiftui/environmentvalues/accessibilityreducetransparency",
            "https://developer.apple.com/documentation/swiftui/environmentvalues/accessibilitydifferentiatewithoutcolor",
            "https://developer.apple.com/documentation/accessibility/performing-accessibility-testing-for-your-app",
        ],
        reviewed: "October 2026"
    ) {
        HStack(spacing: 0) {
            Text("Aa")
                .font(.title.bold())
                .foregroundStyle(.black.opacity(0.35))
                .frame(width: 62, height: 62)
                .background(.white)
            Text("Aa")
                .font(.title.bold())
                .foregroundStyle(.black)
                .frame(width: 62, height: 62)
                .background(.white)
                .overlay {
                    Rectangle().strokeBorder(.black, lineWidth: 2)
                }
        }
        .clipShape(.rect(cornerRadius: 10))
        .accessibilityHidden(true)
    } content: { page in
        MacContrastTransparencyArticle(page: page)
    }
}

// MARK: - Page

private struct MacContrastTransparencyArticle: View {
    let page: ComponentPage
    @Environment(\.colorSchemeContrast) private var contrast
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    var body: some View {
        ArticlePage(page: page) {
            Prose("Two display settings change how much of your window people can make out. **Increase Contrast** sharpens the difference between foreground and background, and **Reduce Transparency** asks for solid backgrounds instead of see-through ones. Both are in System Settings > Accessibility > Display.")
            Prose("System colors already have versions for these settings. Read the settings yourself for anything custom: your own colors, borders, and translucent layers.")

            VStack(alignment: .leading, spacing: 16) {
                SectionTitle("Try it")
                Prose("Turn the two settings on here to see what a custom card should do. The real settings on this Mac:")
                VStack(alignment: .leading, spacing: 6) {
                    DPSystemSetting(name: "Increase Contrast", isOn: contrast == .increased)
                    DPSystemSetting(name: "Reduce Transparency", isOn: reduceTransparency)
                }
                ContrastPlayground()
            }
            .id("demo")

            VStack(alignment: .leading, spacing: 16) {
                SectionTitle("Minimum contrast")
                Prose("Accessibility Inspector checks against these ratios, from WCAG level AA. Check them in light and dark.")
                ConnectFacts(rows: [
                    ("Text up to 17 points", "At least **4.5:1**."),
                    ("Text 18 points and larger", "At least **3:1**."),
                    ("Bold text at any size", "At least **3:1**."),
                ])
            }

            VStack(alignment: .leading, spacing: 16) {
                SectionTitle("Examples")
                    .id("examples")
                VStack(alignment: .leading, spacing: 44) {
                    ExampleCard(
                        title: "Strengthen a border",
                        caption: "Read `colorSchemeContrast` and draw a heavier, darker outline when it's `.increased`.",
                        code: """
                        @Environment(\\.colorSchemeContrast) private var contrast

                        Text("Draft")
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .overlay {
                                Capsule().strokeBorder(
                                    contrast == .increased ? Color.primary : Color.secondary.opacity(0.4),
                                    lineWidth: contrast == .increased ? 2 : 1
                                )
                            }
                        """,
                        minHeight: 130,
                        aside: Aside(.note, "On this Mac, Increase Contrast is \(contrast == .increased ? "on, so the preview shows the strong border" : "off, so the preview shows the light border").")
                    ) {
                        BorderExample()
                    }

                    ExampleCard(
                        title: "Make a translucent layer solid",
                        caption: "Check `accessibilityReduceTransparency` and swap a see-through background for an opaque one.",
                        code: """
                        @Environment(\\.accessibilityReduceTransparency) private var reduceTransparency

                        Image("photo")
                            .resizable()
                            .scaledToFill()
                            .overlay(alignment: .bottomLeading) {
                                Text("Lake at sunset")
                                    .foregroundStyle(.white)
                                    .padding(8)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(.black.opacity(reduceTransparency ? 1 : 0.4))
                            }
                        """,
                        minHeight: 200,
                        aside: Aside(.note, "On this Mac, Reduce Transparency is \(reduceTransparency ? "on" : "off").")
                    ) {
                        CaptionExample()
                    }

                    ExampleCard(
                        title: "Add shapes when color isn't enough",
                        caption: "When `accessibilityDifferentiateWithoutColor` is true, show a distinct symbol for each status, not only a colored dot.",
                        code: """
                        @Environment(\\.accessibilityDifferentiateWithoutColor) private var differentiate

                        HStack {
                            if differentiate {
                                Image(systemName: "exclamationmark.triangle.fill")
                            } else {
                                Circle().frame(width: 10, height: 10)
                            }
                            Text("Payment failed")
                        }
                        .foregroundStyle(.red)
                        """,
                        minHeight: 120
                    ) {
                        DifferentiateExample()
                    }
                }
            }
        }
    }
}

// MARK: - Playground

/// A photo card whose caption panel follows two stand-in toggles.
private struct ContrastPlayground: View {
    @State private var increaseContrast = false
    @State private var reduceTransparency = false

    var body: some View {
        VStack(spacing: 0) {
            PreviewCard(minHeight: 280, isAttached: true) {
                ZStack(alignment: .bottomLeading) {
                    SceneryView(.meadow)
                        .frame(width: 420, height: 240)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Summer meadow")
                            .font(.headline)
                        Text("Added to Favorites · 12 photos")
                            .font(.callout)
                            .foregroundStyle(increaseContrast ? AnyShapeStyle(.primary) : AnyShapeStyle(.secondary))
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background {
                        if reduceTransparency {
                            Rectangle().fill(.background)
                        } else {
                            Rectangle().fill(.background.opacity(0.55))
                        }
                    }
                    .overlay(alignment: .top) {
                        Rectangle()
                            .fill(increaseContrast ? AnyShapeStyle(.primary) : AnyShapeStyle(.clear))
                            .frame(height: 1)
                    }
                }
                .frame(width: 420, height: 240)
                .clipShape(.rect(cornerRadius: 12))
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(increaseContrast ? AnyShapeStyle(.primary) : AnyShapeStyle(.separator), lineWidth: increaseContrast ? 2 : 1)
                }
            }
            Divider()
            HStack(spacing: 24) {
                Toggle("Increase Contrast", isOn: $increaseContrast)
                Toggle("Reduce Transparency", isOn: $reduceTransparency)
            }
            .toggleStyle(.checkbox)
            .padding(14)
            .frame(maxWidth: .infinity)
            .background(Surface.code)
        }
        .cardStyle()
    }
}

// MARK: - Examples

private struct BorderExample: View {
    @Environment(\.colorSchemeContrast) private var contrast

    var body: some View {
        Text("Draft")
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .overlay {
                Capsule().strokeBorder(
                    contrast == .increased ? Color.primary : Color.secondary.opacity(0.4),
                    lineWidth: contrast == .increased ? 2 : 1
                )
            }
    }
}

private struct CaptionExample: View {
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    var body: some View {
        SceneryView(.lake)
            .frame(width: 320, height: 180)
            .overlay(alignment: .bottomLeading) {
                Text("Lake at sunset")
                    .foregroundStyle(.white)
                    .padding(8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.black.opacity(reduceTransparency ? 1 : 0.4))
            }
            .clipShape(.rect(cornerRadius: 10))
    }
}

private struct DifferentiateExample: View {
    @Environment(\.accessibilityDifferentiateWithoutColor) private var differentiate

    var body: some View {
        HStack {
            if differentiate {
                Image(systemName: "exclamationmark.triangle.fill")
            } else {
                Circle().frame(width: 10, height: 10)
            }
            Text("Payment failed")
        }
        .foregroundStyle(.red)
    }
}

// MARK: - Do / Don't

private struct DPContrastText: View {
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text("Quarterly report")
                .font(.headline)
            Text("Edited 2 hours ago by Sam")
                .font(.callout)
                .foregroundStyle(color)
        }
        .frame(width: 220, alignment: .leading)
    }
}

private struct DPStatusList: View {
    let usesSymbols: Bool

    private let rows: [(String, String, Color)] = [
        ("Paid", "checkmark.circle.fill", .green),
        ("Pending", "clock.fill", .orange),
        ("Failed", "xmark.octagon.fill", .red),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(rows, id: \.0) { row in
                HStack(spacing: 8) {
                    if usesSymbols {
                        Image(systemName: row.1)
                            .foregroundStyle(row.2)
                    } else {
                        Circle()
                            .fill(row.2)
                            .frame(width: 12, height: 12)
                            .frame(width: 16)
                    }
                    Text("Invoice")
                }
            }
        }
        .frame(width: 180, alignment: .leading)
    }
}
