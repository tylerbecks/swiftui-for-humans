import SwiftUI

extension ComponentPage {
    static let colorAndContrast = ComponentPage(
        id: "color-and-contrast",
        title: "Color & Contrast",
        summary: "Readable contrast, Increase Contrast support, and never using color as the only signal.",
        category: .accessibility,
        kind: .concept,
        symbol: "circle.lefthalf.filled",
        availability: ["iOS 14.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/environmentvalues/colorschemecontrast",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/color",
        aliases: ["contrast ratio", "WCAG", "AA", "4.5:1", "color blind", "colour blind", "colorblind", "high contrast", "prefers-contrast", "Increase Contrast", "Differentiate Without Color", "grayscale"],
        related: ["system-colors", "accessibility", "foreground-style", "label"],
        notes: [
            "**The ratio runs from 1:1 to 21:1.** It compares the relative brightness of two colors. Don't round it up: 4.49:1 doesn't pass 4.5:1.",
            "**Test in grayscale.** Turn on the Grayscale color filter in the Accessibility settings. It isn't what color-blind people see, but if you can't use your app in gray, something relies on color alone.",
        ],
        api: [
            APIItem("`\\.colorSchemeContrast`", "`.increased` when Increase Contrast is on."),
            APIItem("`\\.accessibilityDifferentiateWithoutColor`", "True when people ask for shapes, not just color."),
            APIItem("`.foregroundStyle(.secondary)`", "System styles adapt to contrast and dark mode."),
            APIItem("`Label(_:systemImage:)`", "Text plus an icon, an easy second cue."),
        ],
        guidelines: [
            Guideline(
                "Never use color as the only signal.",
                "Some people can't tell red from green. Add a shape, icon, or word so the meaning survives without color.",
                good: "A checkmark and an X carry the meaning.",
                bad: "Only the dot color differs."
            ) {
                VStack(alignment: .leading, spacing: 10) {
                    ColorContrastStatusRow(title: "Server 1", symbol: "checkmark.circle.fill", color: .green)
                    ColorContrastStatusRow(title: "Server 2", symbol: "xmark.octagon.fill", color: .red)
                }
            } bad: {
                VStack(alignment: .leading, spacing: 10) {
                    ColorContrastStatusRow(title: "Server 1", symbol: "circle.fill", color: .green)
                    ColorContrastStatusRow(title: "Server 2", symbol: "circle.fill", color: .red)
                }
            },
            Guideline(
                "Give text at least 4.5:1 contrast.",
                "Light text on a light fill washes out, especially outdoors or for people with low vision.",
                good: "White on blue: easy to read.",
                bad: "Light blue on blue fades away."
            ) {
                ColorContrastPill(text: "Continue", foreground: .white)
            } bad: {
                ColorContrastPill(text: "Continue", foreground: Color(red: 0.62, green: 0.78, blue: 1))
            },
            Guideline(
                "Check dark mode separately.",
                "Contrast that passes in light mode can fail in dark mode. Dim gray on black is a common miss.",
                good: "Light gray on black stays readable.",
                bad: "Dark gray on black."
            ) {
                ColorContrastDarkCard(detail: Color(white: 0.68))
            } bad: {
                ColorContrastDarkCard(detail: Color(white: 0.3))
            },
            Guideline(
                "Prefer system colors.",
                "Colors like `.primary`, `.secondary`, and `.blue` already have versions for dark mode and Increase Contrast. Custom colors need each version from you."
            ),
        ],
        sources: [
            "https://developer.apple.com/design/human-interface-guidelines/accessibility",
            "https://developer.apple.com/design/human-interface-guidelines/color",
            "https://developer.apple.com/documentation/swiftui/environmentvalues/colorschemecontrast",
            "https://developer.apple.com/documentation/swiftui/environmentvalues/accessibilitydifferentiatewithoutcolor",
            "https://developer.apple.com/help/app-store-connect/manage-app-accessibility/sufficient-contrast-evaluation-criteria",
            "https://developer.apple.com/help/app-store-connect/manage-app-accessibility/differentiate-without-color-alone-evaluation-criteria",
        ],
        reviewed: "October 2026"
    ) {
        HStack(spacing: 12) {
            Text("Aa")
                .font(.title.bold())
                .foregroundStyle(.white)
                .frame(width: 64, height: 64)
                .background(Color(red: 0, green: 0.4, blue: 0.85), in: .rect(cornerRadius: 14))
            Text("Aa")
                .font(.title.bold())
                .foregroundStyle(Color(red: 0.62, green: 0.78, blue: 1))
                .frame(width: 64, height: 64)
                .background(Color(red: 0, green: 0.4, blue: 0.85).opacity(0.85), in: .rect(cornerRadius: 14))
        }
        .accessibilityHidden(true)
    } content: { page in
        ColorContrastArticle(page: page)
    }
}

// MARK: - Page

private struct ColorContrastArticle: View {
    let page: ComponentPage

    var body: some View {
        ArticlePage(page: page) {
            Prose("Three things make color work for everyone: enough **contrast** between text and its background, support for the **Increase Contrast** setting, and never using **color alone** to say something. System colors and styles help with the first two, so most of the work is in your own colors.")

            VStack(alignment: .leading, spacing: 16) {
                SectionTitle("Check a pair")
                ColorContrastChecker()
            }
            .id("demo")

            VStack(alignment: .leading, spacing: 16) {
                SectionTitle("Minimum contrast")
                Prose("Accessibility Inspector checks your colors against these WCAG AA ratios:")
                ColorContrastTable()
                Aside(.note, "For icons, borders, and other parts of a control that aren't text, 3:1 is the common minimum.")
            }
            .id("ratios")

            VStack(alignment: .leading, spacing: 16) {
                SectionTitle("Examples")
                VStack(alignment: .leading, spacing: 44) {
                    ExampleCard(
                        title: "Respond to Increase Contrast",
                        caption: "Read `colorSchemeContrast` and strengthen custom colors and borders when it's `.increased`.",
                        code: """
                        @Environment(\\.colorSchemeContrast) private var contrast

                        Text("Beta")
                            .font(.caption.bold())
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .foregroundStyle(contrast == .increased ? .white : .purple)
                            .background(.purple.opacity(contrast == .increased ? 1 : 0.15), in: .capsule)
                        """,
                        minHeight: 140,
                        aside: Aside(.note, "If you only need different colors, add a High Contrast variant to the color in your asset catalog instead. It switches on its own.")
                    ) {
                        HStack(spacing: 20) {
                            ColorContrastBadge(increased: false)
                            ColorContrastBadge(increased: true)
                        }
                    }

                    ExampleCard(
                        title: "Give every status a shape",
                        caption: "Pair each color with its own symbol in a `Label`, and keep the text in the primary color.",
                        code: """
                        VStack(alignment: .leading) {
                            Label {
                                Text("Paid")
                            } icon: {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.green)
                            }
                            Label {
                                Text("Failed")
                            } icon: {
                                Image(systemName: "xmark.octagon.fill")
                                    .foregroundStyle(.red)
                            }
                        }
                        """,
                        minHeight: 130,
                        aside: Aside(.note, "Colored text is often too light to read. Tint the icon and leave the words in `.primary`.")
                    ) {
                        VStack(alignment: .leading, spacing: 8) {
                            Label {
                                Text("Paid")
                            } icon: {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.green)
                            }
                            Label {
                                Text("Failed")
                            } icon: {
                                Image(systemName: "xmark.octagon.fill")
                                    .foregroundStyle(.red)
                            }
                        }
                    }

                    ExampleCard(
                        title: "Explain errors in words",
                        caption: "A red border alone is easy to miss. Add a message with an icon under the field.",
                        code: """
                        @State private var email = "maya@"

                        VStack(alignment: .leading, spacing: 6) {
                            TextField("Email", text: $email)
                                .padding(10)
                                .overlay {
                                    RoundedRectangle(cornerRadius: 8)
                                        .strokeBorder(.red)
                                }
                            Label("Enter a full email address.", systemImage: "exclamationmark.circle.fill")
                                .font(.footnote)
                                .foregroundStyle(.red)
                        }
                        """,
                        minHeight: 150
                    ) {
                        ColorContrastErrorField()
                            .frame(maxWidth: 300)
                    }

                    ExampleCard(
                        title: "Add shapes when people ask",
                        caption: "When `accessibilityDifferentiateWithoutColor` is true, swap color-only marks for symbols.",
                        code: """
                        @Environment(\\.accessibilityDifferentiateWithoutColor) private var noColorOnly

                        HStack {
                            Image(systemName: noColorOnly ? "checkmark.circle.fill" : "circle.fill")
                                .foregroundStyle(.green)
                            Text("Available")
                        }
                        """,
                        minHeight: 120,
                        aside: Aside(.important, "Treat this as a fallback. Apple's guidance is to design without color-only cues from the start.")
                    ) {
                        VStack(alignment: .leading, spacing: 10) {
                            ColorContrastAvailability(noColorOnly: false)
                            ColorContrastAvailability(noColorOnly: true)
                        }
                    }
                }
            }
            .id("examples")
        }
    }
}

// MARK: - Contrast math (WCAG 2.2)

/// An sRGB color with 0–255 channels, for computing contrast ratios.
private struct ContrastColor: Hashable, Identifiable {
    let name: String
    let red: Double
    let green: Double
    let blue: Double

    var id: String { name }

    var color: Color {
        Color(.sRGB, red: red / 255, green: green / 255, blue: blue / 255)
    }

    /// Relative luminance, as WCAG defines it.
    var luminance: Double {
        func linear(_ channel: Double) -> Double {
            let c = channel / 255
            return c <= 0.04045 ? c / 12.92 : pow((c + 0.055) / 1.055, 2.4)
        }
        return 0.2126 * linear(red) + 0.7152 * linear(green) + 0.0722 * linear(blue)
    }

    static func ratio(_ a: ContrastColor, _ b: ContrastColor) -> Double {
        let lighter = max(a.luminance, b.luminance)
        let darker = min(a.luminance, b.luminance)
        return (lighter + 0.05) / (darker + 0.05)
    }

    static let swatches: [ContrastColor] = [
        ContrastColor(name: "White", red: 255, green: 255, blue: 255),
        ContrastColor(name: "Light Gray", red: 200, green: 200, blue: 200),
        ContrastColor(name: "Gray", red: 142, green: 142, blue: 147),
        ContrastColor(name: "Dark Gray", red: 72, green: 72, blue: 74),
        ContrastColor(name: "Black", red: 0, green: 0, blue: 0),
        ContrastColor(name: "Blue", red: 0, green: 102, blue: 217),
        ContrastColor(name: "Sky", red: 158, green: 199, blue: 255),
        ContrastColor(name: "Orange", red: 255, green: 149, blue: 0),
        ContrastColor(name: "Yellow", red: 255, green: 214, blue: 10),
        ContrastColor(name: "Green", red: 36, green: 138, blue: 61),
    ]
}

// MARK: - Checker

private struct ColorContrastChecker: View {
    @State private var foreground = ContrastColor.swatches[6]
    @State private var background = ContrastColor.swatches[5]

    private var ratio: Double { ContrastColor.ratio(foreground, background) }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Pick a text color and a background. The ratio uses the WCAG formula, and the marks use the WCAG AA minimums.")
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Body text, 17 pt")
                        .font(.body)
                    Text("Bold Title")
                        .font(.title2.bold())
                    Image(systemName: "heart.fill")
                        .font(.title2)
                }
                .foregroundStyle(foreground.color)
                .padding(24)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(background.color)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Sample: \(foreground.name) on \(background.name)")

                Divider()
                VStack(alignment: .leading, spacing: 12) {
                    HStack(alignment: .firstTextBaseline) {
                        Text(ratio, format: .number.precision(.fractionLength(2)))
                            .font(.largeTitle.bold())
                            .monospacedDigit()
                            .contentTransition(.numericText(value: ratio))
                            .animation(.snappy, value: ratio)
                        Text(": 1")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }
                    .accessibilityElement(children: .combine)
                    FlowLayout(spacing: 8) {
                        ColorContrastResult(title: "Text", passes: ratio >= 4.5, target: "4.5")
                        ColorContrastResult(title: "Large or bold", passes: ratio >= 3, target: "3")
                        ColorContrastResult(title: "Icons", passes: ratio >= 3, target: "3")
                    }
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                Divider()
                VStack(alignment: .leading, spacing: 12) {
                    ColorContrastSwatchRow(title: "Text", selection: $foreground)
                    ColorContrastSwatchRow(title: "Background", selection: $background)
                }
                .padding(14)
            }
            .cardStyle()
        }
    }
}

private struct ColorContrastResult: View {
    let title: String
    let passes: Bool
    let target: String

    var body: some View {
        Label("\(title) \(target):1", systemImage: passes ? "checkmark.circle.fill" : "xmark.circle.fill")
            .font(.subheadline.weight(.medium))
            .foregroundStyle(passes ? .green : .red)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background((passes ? Color.green : Color.red).opacity(0.12), in: .capsule)
            .accessibilityLabel("\(title), needs \(target) to 1, \(passes ? "passes" : "fails")")
    }
}

private struct ColorContrastSwatchRow: View {
    let title: String
    @Binding var selection: ContrastColor

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.subheadline.weight(.medium))
                Spacer()
                Text(selection.name)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            ScrollView(.horizontal) {
                HStack(spacing: 8) {
                    ForEach(ContrastColor.swatches) { swatch in
                        Button {
                            selection = swatch
                        } label: {
                            Circle()
                                .fill(swatch.color)
                                .frame(width: 32, height: 32)
                                .overlay { Circle().strokeBorder(.separator) }
                                .padding(3)
                                .overlay {
                                    if swatch == selection {
                                        Circle().strokeBorder(.tint, lineWidth: 2)
                                    }
                                }
                                .frame(width: 44, height: 44)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(swatch.name)
                        .accessibilityAddTraits(swatch == selection ? .isSelected : [])
                    }
                }
            }
            .scrollIndicators(.hidden)
        }
    }
}

private struct ColorContrastTable: View {
    var body: some View {
        Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 10) {
            GridRow {
                Text("Text").bold()
                Text("Minimum").bold()
            }
            .font(.subheadline)
            Divider()
            GridRow {
                Text("Up to 17 pt, any weight")
                Text("4.5:1").monospacedDigit()
            }
            GridRow {
                Text("18 pt and larger")
                Text("3:1").monospacedDigit()
            }
            GridRow {
                Text("Bold, any size")
                Text("3:1").monospacedDigit()
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.background.secondary, in: .rect(cornerRadius: 16))
    }
}

// MARK: - Example and guideline views

private struct ColorContrastStatusRow: View {
    let title: String
    let symbol: String
    let color: Color

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: symbol)
                .foregroundStyle(color)
            Text(title)
        }
    }
}

private struct ColorContrastPill: View {
    let text: String
    let foreground: Color

    var body: some View {
        Text(text)
            .font(.headline)
            .foregroundStyle(foreground)
            .padding(.horizontal, 28)
            .padding(.vertical, 12)
            .background(Color(red: 0, green: 0.4, blue: 0.85), in: .capsule)
    }
}

private struct ColorContrastDarkCard: View {
    let detail: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Morning Run")
                .font(.headline)
                .foregroundStyle(.white)
            Text("5.2 km · 28 min")
                .font(.subheadline)
                .foregroundStyle(detail)
        }
        .padding(16)
        .frame(width: 200, alignment: .leading)
        .background(.black, in: .rect(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(.white.opacity(0.15))
        }
    }
}

private struct ColorContrastBadge: View {
    let increased: Bool

    var body: some View {
        VStack(spacing: 8) {
            Text("Beta")
                .font(.caption.bold())
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .foregroundStyle(increased ? .white : .purple)
                .background(.purple.opacity(increased ? 1 : 0.15), in: .capsule)
            Text(increased ? "Increased" : "Standard")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

private struct ColorContrastErrorField: View {
    @State private var email = "maya@"

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            TextField("Email", text: $email)
                .padding(10)
                .overlay {
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(.red)
                }
            Label("Enter a full email address.", systemImage: "exclamationmark.circle.fill")
                .font(.footnote)
                .foregroundStyle(.red)
        }
    }
}

private struct ColorContrastAvailability: View {
    let noColorOnly: Bool

    var body: some View {
        HStack {
            Image(systemName: noColorOnly ? "checkmark.circle.fill" : "circle.fill")
                .foregroundStyle(.green)
            Text("Available")
            Text(noColorOnly ? "(setting on)" : "(setting off)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
