import SwiftUI
import UIKit

extension ComponentPage {
    static let typography = ComponentPage(
        id: "typography",
        title: "Typography",
        summary: "Apple's built-in text styles, which resize automatically when people change their text size.",
        category: .foundations,
        kind: .reference,
        symbol: "textformat.size",
        availability: ["iOS 13.0+", "macOS 10.15+", "visionOS 1.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/font",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/typography",
        aliases: ["font size", "font-size", "font-weight", "h1", "heading", "type scale", "dynamic type", "rem", "San Francisco", "UIFont"],
        related: ["font", "text", "system-colors", "sf-symbols"],
        notes: [
            "**Text styles are your type scale.** They work like `h1` and `body` in a CSS reset, but they also follow the person's text size setting, like `rem`.",
            "**Test big sizes without changing Settings.** Add `.dynamicTypeSize(.accessibility3)` to a preview, or use the Variants button in Xcode's canvas.",
        ],
        api: [
            APIItem("`.font(.body)`", "Sets a text style that scales with Dynamic Type."),
            APIItem("`.fontWeight(_:)`", "Makes a style lighter or bolder and keeps its size."),
            APIItem("`.fontDesign(_:)`", "`.rounded`, `.serif`, or `.monospaced`."),
            APIItem("`.font(.custom(_:size:relativeTo:))`", "A custom font that scales with a text style."),
            APIItem("`@ScaledMetric`", "A number, like an icon size, that scales with text."),
            APIItem("`.monospacedDigit()`", "Equal-width digits, so changing numbers don't shift."),
            APIItem("`@Environment(\\.dynamicTypeSize)`", "The current text size, for adjusting layout."),
        ],
        guidelines: [
            Guideline(
                "Use text styles, not fixed point sizes.",
                "Many people raise their text size. A fixed size ignores that setting and stays small.",
                good: "At a larger setting, `.body` grows.",
                bad: "`.system(size: 17)` stays the same."
            ) {
                Text("Your order has shipped and arrives Friday.")
                    .font(.body)
                    .dynamicTypeSize(.xxxLarge)
                    .frame(maxWidth: 240)
            } bad: {
                Text("Your order has shipped and arrives Friday.")
                    .font(.system(size: 17))
                    .dynamicTypeSize(.xxxLarge)
                    .frame(maxWidth: 240)
            },
            Guideline(
                "Avoid light weights for small text.",
                "Ultralight, Thin, and Light strokes are hard to see at small sizes. Use Regular or heavier.",
                good: "Regular weight stays readable.",
                bad: "Ultralight fades away at footnote size."
            ) {
                Text("Updated 5 minutes ago")
                    .font(.footnote)
                    .fontWeight(.regular)
            } bad: {
                Text("Updated 5 minutes ago")
                    .font(.footnote)
                    .fontWeight(.ultraLight)
            },
            Guideline(
                "Let layouts grow with the text.",
                "Allow text to wrap instead of truncating, and stack side-by-side items at accessibility sizes."
            ),
            Guideline(
                "Use few typefaces.",
                "One family with a few styles and weights shows hierarchy clearly. Mixing many fonts makes a screen feel unplanned."
            ),
        ]
    ) {
        TypographyThumbnail()
    } content: { page in
        TypographyArticle(page: page)
    }
}

// MARK: - Data

private struct TextStyleRow: Identifiable {
    let name: String
    let code: String
    let font: Font
    let uiStyle: UIFont.TextStyle
    let use: String

    var id: String { code }
}

private let textStyles: [TextStyleRow] = [
    TextStyleRow(name: "Large Title", code: ".largeTitle", font: .largeTitle, uiStyle: .largeTitle, use: "Screen titles"),
    TextStyleRow(name: "Title", code: ".title", font: .title, uiStyle: .title1, use: "Big headings"),
    TextStyleRow(name: "Title 2", code: ".title2", font: .title2, uiStyle: .title2, use: "Section headings"),
    TextStyleRow(name: "Title 3", code: ".title3", font: .title3, uiStyle: .title3, use: "Small headings"),
    TextStyleRow(name: "Headline", code: ".headline", font: .headline, uiStyle: .headline, use: "Emphasized body, row titles"),
    TextStyleRow(name: "Body", code: ".body", font: .body, uiStyle: .body, use: "Default for all text"),
    TextStyleRow(name: "Callout", code: ".callout", font: .callout, uiStyle: .callout, use: "Explanations"),
    TextStyleRow(name: "Subheadline", code: ".subheadline", font: .subheadline, uiStyle: .subheadline, use: "Secondary info"),
    TextStyleRow(name: "Footnote", code: ".footnote", font: .footnote, uiStyle: .footnote, use: "Fine print"),
    TextStyleRow(name: "Caption", code: ".caption", font: .caption, uiStyle: .caption1, use: "Image captions, labels"),
    TextStyleRow(name: "Caption 2", code: ".caption2", font: .caption2, uiStyle: .caption2, use: "Smallest text"),
]

private func contentSizeCategory(_ size: DynamicTypeSize) -> UIContentSizeCategory {
    switch size {
    case .xSmall: .extraSmall
    case .small: .small
    case .medium: .medium
    case .large: .large
    case .xLarge: .extraLarge
    case .xxLarge: .extraExtraLarge
    case .xxxLarge: .extraExtraExtraLarge
    case .accessibility1: .accessibilityMedium
    case .accessibility2: .accessibilityLarge
    case .accessibility3: .accessibilityExtraLarge
    case .accessibility4: .accessibilityExtraExtraLarge
    case .accessibility5: .accessibilityExtraExtraExtraLarge
    @unknown default: .large
    }
}

private func sizeName(_ size: DynamicTypeSize) -> String {
    switch size {
    case .xSmall: "xSmall"
    case .small: "small"
    case .medium: "medium"
    case .large: "large"
    case .xLarge: "xLarge"
    case .xxLarge: "xxLarge"
    case .xxxLarge: "xxxLarge"
    case .accessibility1: "accessibility1"
    case .accessibility2: "accessibility2"
    case .accessibility3: "accessibility3"
    case .accessibility4: "accessibility4"
    case .accessibility5: "accessibility5"
    @unknown default: "large"
    }
}

private func pointSize(_ style: UIFont.TextStyle, _ size: DynamicTypeSize) -> Int {
    let traits = UITraitCollection(preferredContentSizeCategory: contentSizeCategory(size))
    return Int(UIFont.preferredFont(forTextStyle: style, compatibleWith: traits).pointSize.rounded())
}

// MARK: - Page

private struct TypographyArticle: View {
    let page: ComponentPage
    @State private var sizeIndex: Double = 3

    private var dynamicSize: DynamicTypeSize {
        let all = DynamicTypeSize.allCases
        return all[min(max(Int(sizeIndex), 0), all.count - 1)]
    }

    var body: some View {
        ArticlePage(page: page) {
            Prose("iOS has eleven **text styles**. Pick one by its *role*, like a title, the body, or a caption, and iOS sets the size, weight, and line spacing. Drag the slider to see each one grow with the person's text size setting.")

            VStack(alignment: .leading, spacing: 16) {
                stylesCard
                Aside(.important, "`.font(.system(size: 17))` is a fixed size, like `px` in CSS, and ignores the text size setting. Use a text style, or `.system(.body)`, so it scales like `rem`.")
            }
            .id("styles")

            FontBuilder()
                .id("builder")

            VStack(alignment: .leading, spacing: 16) {
                SectionTitle("Examples")
                VStack(alignment: .leading, spacing: 44) {
                    ExampleCard(
                        title: "Custom font that still scales",
                        caption: "Pass `relativeTo:` to `.custom(_:size:relativeTo:)` so your font grows with that text style.",
                        code: """
                        Text("The quick brown fox")
                            .font(.custom("Georgia", size: 20, relativeTo: .title3))
                        """,
                        minHeight: 120,
                        aside: Aside(.note, "A bundled font also needs its file listed under `UIAppFonts` in Info.plist. Georgia ships with iOS.")
                    ) {
                        Text("The quick brown fox")
                            .font(.custom("Georgia", size: 20, relativeTo: .title3))
                    }

                    ExampleCard(
                        title: "Stack items at large sizes",
                        caption: "Check `isAccessibilitySize` on the `dynamicTypeSize` environment value, and switch a row to a column.",
                        code: """
                        @Environment(\\.dynamicTypeSize) private var typeSize

                        let layout = typeSize.isAccessibilitySize
                            ? AnyLayout(VStackLayout(alignment: .leading))
                            : AnyLayout(HStackLayout())

                        layout {
                            Text("Delivery")
                            Spacer(minLength: 0)
                            Text("Friday, 9–11 AM")
                                .foregroundStyle(.secondary)
                        }
                        """,
                        minHeight: 160,
                        aside: Aside(.note, "Accessibility sizes can make text more than three times larger. Avoid fixed heights so rows can grow.")
                    ) {
                        VStack(spacing: 14) {
                            AdaptiveDeliveryRow()
                            Divider()
                            AdaptiveDeliveryRow()
                                .dynamicTypeSize(.accessibility2)
                        }
                        .frame(maxWidth: 320)
                    }

                    ExampleCard(
                        title: "Scale your own numbers",
                        caption: "`@ScaledMetric` grows a number, like an icon size, in step with a text style.",
                        code: """
                        @ScaledMetric(relativeTo: .body) private var iconSize = 28.0

                        Label {
                            Text("Scales with the text")
                        } icon: {
                            Image(systemName: "star.fill")
                                .resizable()
                                .frame(width: iconSize, height: iconSize)
                        }
                        """,
                        minHeight: 120
                    ) {
                        ScaledIconLabel()
                    }

                    ExampleCard(
                        title: "Numbers that don't jump",
                        caption: "Use `.monospacedDigit()` so every digit has the same width and a changing number stays still.",
                        code: """
                        @State private var seconds = 0.0

                        Text(seconds, format: .number.precision(.fractionLength(2)))
                            .font(.largeTitle.bold())
                            .monospacedDigit()
                        """,
                        minHeight: 120
                    ) {
                        TimelineView(.periodic(from: .now, by: 0.05)) { context in
                            let seconds = context.date.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: 60)
                            Text(seconds, format: .number.precision(.fractionLength(2)))
                                .font(.largeTitle.bold())
                                .monospacedDigit()
                        }
                    }
                }
            }
            .id("examples")
        }
    }

    private var stylesCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Text size")
                        .font(.subheadline.weight(.semibold))
                    Spacer()
                    Text(".\(sizeName(dynamicSize))\(dynamicSize == .large ? " (default)" : "")")
                        .font(.caption.monospaced())
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
                HStack(spacing: 10) {
                    Image(systemName: "textformat.size.smaller")
                        .foregroundStyle(.secondary)
                    Slider(value: $sizeIndex, in: 0...Double(DynamicTypeSize.allCases.count - 1), step: 1)
                        .accessibilityLabel("Text size")
                        .accessibilityValue(sizeName(dynamicSize))
                    Image(systemName: "textformat.size.larger")
                        .foregroundStyle(.secondary)
                }
            }
            .padding(16)

            Divider()

            VStack(alignment: .leading, spacing: 0) {
                ForEach(textStyles) { style in
                    StyleSpecimen(style: style, size: dynamicSize)
                    if style.id != textStyles.last?.id {
                        Divider()
                    }
                }
            }
            .padding(.horizontal, 16)
            .background(.background)
            .animation(.snappy, value: sizeIndex)
        }
        .cardStyle()
    }
}

private struct StyleSpecimen: View {
    let style: TextStyleRow
    let size: DynamicTypeSize

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(style.name)
                .font(style.font)
                .dynamicTypeSize(size)
                .fixedSize(horizontal: false, vertical: true)
            HStack(spacing: 8) {
                Text(style.code)
                    .font(.caption.monospaced().weight(.medium))
                Text("\(pointSize(style.uiStyle, size)) pt")
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
                    .contentTransition(.numericText())
                Spacer(minLength: 8)
                Text(style.use)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
        }
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct AdaptiveDeliveryRow: View {
    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        let layout = typeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading))
            : AnyLayout(HStackLayout())

        layout {
            Text("Delivery")
            Spacer(minLength: 0)
            Text("Friday, 9–11 AM")
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct ScaledIconLabel: View {
    @ScaledMetric(relativeTo: .body) private var iconSize = 28.0

    var body: some View {
        Label {
            Text("Scales with the text")
        } icon: {
            Image(systemName: "star.fill")
                .resizable()
                .frame(width: iconSize, height: iconSize)
                .foregroundStyle(.yellow)
        }
    }
}

// MARK: - Font builder

private enum WeightOption: DemoOption {
    case automatic, ultraLight, thin, light, regular, medium, semibold, bold, heavy, black

    var label: String {
        switch self {
        case .automatic: "Default"
        case .ultraLight: ".ultraLight"
        case .thin: ".thin"
        case .light: ".light"
        case .regular: ".regular"
        case .medium: ".medium"
        case .semibold: ".semibold"
        case .bold: ".bold"
        case .heavy: ".heavy"
        case .black: ".black"
        }
    }

    var weight: Font.Weight? {
        switch self {
        case .automatic: nil
        case .ultraLight: .ultraLight
        case .thin: .thin
        case .light: .light
        case .regular: .regular
        case .medium: .medium
        case .semibold: .semibold
        case .bold: .bold
        case .heavy: .heavy
        case .black: .black
        }
    }
}

private enum DesignOption: DemoOption {
    case `default`, rounded, serif, monospaced

    var label: String {
        switch self {
        case .default: ".default"
        case .rounded: ".rounded"
        case .serif: ".serif"
        case .monospaced: ".monospaced"
        }
    }

    var design: Font.Design {
        switch self {
        case .default: .default
        case .rounded: .rounded
        case .serif: .serif
        case .monospaced: .monospaced
        }
    }
}

private enum WidthOption: DemoOption {
    case standard, compressed, condensed, expanded

    var label: String {
        switch self {
        case .standard: ".standard"
        case .compressed: ".compressed"
        case .condensed: ".condensed"
        case .expanded: ".expanded"
        }
    }

    var width: Font.Width {
        switch self {
        case .standard: .standard
        case .compressed: .compressed
        case .condensed: .condensed
        case .expanded: .expanded
        }
    }
}

private enum BuilderStyle: DemoOption {
    case largeTitle, title, title2, title3, headline, body, callout, subheadline, footnote, caption

    var label: String {
        switch self {
        case .largeTitle: ".largeTitle"
        case .title: ".title"
        case .title2: ".title2"
        case .title3: ".title3"
        case .headline: ".headline"
        case .body: ".body"
        case .callout: ".callout"
        case .subheadline: ".subheadline"
        case .footnote: ".footnote"
        case .caption: ".caption"
        }
    }

    var font: Font {
        switch self {
        case .largeTitle: .largeTitle
        case .title: .title
        case .title2: .title2
        case .title3: .title3
        case .headline: .headline
        case .body: .body
        case .callout: .callout
        case .subheadline: .subheadline
        case .footnote: .footnote
        case .caption: .caption
        }
    }
}

/// An inline playground for weight, design, width, and italic.
private struct FontBuilder: View {
    @State private var style: BuilderStyle = .largeTitle
    @State private var weight: WeightOption = .bold
    @State private var design: DesignOption = .rounded
    @State private var width: WidthOption = .standard
    @State private var italic = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionTitle("Weight, design, and width")
            Prose("Start from a text style, then adjust it. Every combination still scales with Dynamic Type. Widths only exist for the default San Francisco design, so they have no effect on `.serif` or `.rounded`.")

            PreviewCard(title: "Try it", minHeight: 140) {
                Text("Hello, SwiftUI")
                    .font(style.font)
                    .fontWeight(weight.weight)
                    // nil leaves the text style's own design and width alone,
                    // matching the generated code, which omits the defaults.
                    .fontDesign(design == .default ? nil : design.design)
                    .fontWidth(width == .standard ? nil : width.width)
                    .italic(italic)
                    .multilineTextAlignment(.center)
                    .animation(.snappy, value: weight)
            }

            VStack(spacing: 0) {
                row("Style") { OptionPicker("Style", selection: $style) }
                Divider()
                row("Weight") { OptionPicker("Weight", selection: $weight) }
                Divider()
                row("Design") { OptionPicker("Design", selection: $design) }
                Divider()
                row("Width") { OptionPicker("Width", selection: $width) }
                Divider()
                Toggle("Italic", isOn: $italic)
                    .padding(.vertical, 6)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 4)
            .cardStyle()

            CodeBlock(code: code)
        }
    }

    private func row<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        HStack {
            Text(title)
            Spacer()
            content()
                .labelsHidden()
                .pickerStyle(.menu)
        }
        .padding(.vertical, 2)
    }

    private var code: String {
        var lines = ["Text(\"Hello, SwiftUI\")", "    .font(\(style.label))"]
        if weight != .automatic { lines.append("    .fontWeight(\(weight.label))") }
        if design != .default { lines.append("    .fontDesign(\(design.label))") }
        if width != .standard { lines.append("    .fontWidth(\(width.label))") }
        if italic { lines.append("    .italic()") }
        return lines.joined(separator: "\n")
    }
}

// MARK: - Thumbnail

private struct TypographyThumbnail: View {
    var body: some View {
        HStack(alignment: .center, spacing: 18) {
            Text("Aa")
                .font(.system(size: 64, weight: .bold, design: .rounded))
            VStack(alignment: .leading, spacing: 3) {
                Text("Title").font(.title2.bold())
                Text("Headline").font(.headline)
                Text("Body").font(.body)
                Text("Footnote").font(.footnote).foregroundStyle(.secondary)
                Text("Caption").font(.caption2).foregroundStyle(.secondary)
            }
        }
        .dynamicTypeSize(.large)
    }
}
