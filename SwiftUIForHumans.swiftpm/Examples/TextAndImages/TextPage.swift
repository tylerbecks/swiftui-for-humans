import SwiftUI

extension ComponentPage {
    static let text = ComponentPage(
        id: "text",
        title: "Text",
        summary: "Shows read-only text, styled with fonts and colors, with built-in Markdown and formatting.",
        category: .textAndImages,
        symbol: "textformat",
        availability: ["iOS 13.0+", "macOS 10.15+", "visionOS 1.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/text",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/typography",
        aliases: ["label", "<p>", "<span>", "paragraph", "string", "UILabel", "font", "text-overflow", "ellipsis", "markdown"],
        related: ["font", "typography", "label", "text-field"],
        notes: [
            "**Text wraps by default.** It takes as many lines as it needs. `.lineLimit(2)` caps it and adds “…”, like CSS `text-overflow: ellipsis`.",
            "**Style a whole group at once.** `.font`, `.foregroundStyle`, and `.multilineTextAlignment` on a `VStack` apply to every `Text` inside it.",
            "**For fonts and the type scale, see [Typography](catalog://typography).** It shows every text style at its real size.",
        ],
        api: [
            APIItem("`Text(_:)`", "Shows a string. Literals support Markdown and are localized."),
            APIItem("`.font(_:)`", "A text style like `.headline`, which scales with Dynamic Type."),
            APIItem("`.bold()`, `.italic()`", "Quick weight and style changes. `.fontWeight(_:)` for others."),
            APIItem("`.foregroundStyle(_:)`", "The color, such as `.secondary` for less important text."),
            APIItem("`.lineLimit(_:)`", "The most lines to show before truncating."),
            APIItem("`.multilineTextAlignment(_:)`", "`.leading`, `.center`, or `.trailing` for wrapped lines."),
            APIItem("`Text(_:format:)`", "Formats a number or date for the person's locale."),
            APIItem("`.textSelection(.enabled)`", "Lets people select and copy the text."),
        ],
        guidelines: [
            Guideline(
                "Use text styles, not fixed sizes.",
                "`.headline` and `.body` grow with the person's text size setting. `.font(.system(size: 15))` stays the same and gets hard to read."
            ),
            Guideline(
                "Show hierarchy with size, weight, and color.",
                "A bold title over a smaller, secondary line tells people what to read first. Same-looking lines run together.",
                good: "The title stands out from the detail.",
                bad: "Every line looks the same."
            ) {
                TextHierarchySample(hasHierarchy: true)
            } bad: {
                TextHierarchySample(hasHierarchy: false)
            },
            Guideline(
                "Avoid light weights for small text.",
                "Thin strokes fade at small sizes. Use Regular or heavier for anything at body size or below.",
                good: "Regular weight reads clearly.",
                bad: "Ultralight is hard to read."
            ) {
                TextWeightSample(weight: .regular)
            } bad: {
                TextWeightSample(weight: .ultraLight)
            },
            Guideline(
                "Let important text wrap instead of truncating.",
                "With larger text sizes, a one-line limit cuts off words people need. Truncate only when they can open the full text.",
                good: "The message wraps onto a second line.",
                bad: "A line limit hides the end of the message."
            ) {
                TextWrapSample(lineLimit: nil)
            } bad: {
                TextWrapSample(lineLimit: 1)
            },
        ]
    ) {
        VStack(alignment: .leading, spacing: 4) {
            Text("Good morning")
                .font(.title.bold())
            Text("You have **3** new messages and a meeting at 10:00.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(width: 210, alignment: .leading)
    } content: { page in
        TextDemo(page: page)
    }
}

private struct TextConfig {
    var content = "The quick brown fox jumps over the lazy dog, then naps in the sun."
    var font: TextFontOption = .title2
    var weight: TextWeightOption = .regular
    var design: TextDesignOption = .standard
    var alignment: TextAlignmentOption = .leading
    var color: TextColorOption = .primary
    var lineLimit = 0
    var truncation: TextTruncationOption = .tail
    var isItalic = false
}

private struct TextDemo: View {
    let page: ComponentPage

    var body: some View {
        DemoPage(
            page: page,
            initial: TextConfig(),
            previewHeight: 220,
            usage: """
            VStack(alignment: .leading, spacing: 4) {
                Text("Weekend in Lisbon")
                    .font(.headline)
                Text("3 nights · Arrives Friday at 6:40 PM")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            """,
            usageNote: Aside(.note, "A bold title over a smaller, secondary line is the most common text pair in iOS apps.")
        ) { $config in
            Text(config.content)
                .font(.system(config.font.style, design: config.design.design, weight: config.weight.weight))
                .italic(config.isItalic)
                .foregroundStyle(config.color.style)
                .multilineTextAlignment(config.alignment.alignment)
                .lineLimit(config.lineLimit == 0 ? nil : config.lineLimit)
                .truncationMode(config.truncation.mode)
                .frame(maxWidth: 320)
                .animation(.snappy, value: config.lineLimit)
        } controls: { $config in
            Section("Content") {
                TextField("Text", text: $config.content, axis: .vertical)
                    .lineLimit(1...4)
            }
            Section("Font") {
                OptionPicker("Style", selection: $config.font)
                OptionPicker("Weight", selection: $config.weight)
                OptionPicker("Design", selection: $config.design)
                Toggle("Italic", isOn: $config.isItalic)
                OptionPicker("Color", selection: $config.color)
            }
            Section("Layout") {
                OptionPicker("Alignment", selection: $config.alignment)
                Stepper(config.lineLimit == 0 ? "Line limit: none" : "Line limit: \(config.lineLimit)",
                        value: $config.lineLimit, in: 0...5)
                if config.lineLimit > 0 {
                    OptionPicker("Truncation", selection: $config.truncation)
                }
            }
        } code: { config in
            var lines = ["Text(\(swiftString(config.content)))"]
            lines.append("    .font(\(fontCode(config)))")
            if config.isItalic {
                lines.append("    .italic()")
            }
            if config.color != .primary {
                lines.append("    .foregroundStyle(\(config.color.label))")
            }
            if config.alignment != .leading {
                lines.append("    .multilineTextAlignment(\(config.alignment.label))")
            }
            if config.lineLimit > 0 {
                lines.append("    .lineLimit(\(config.lineLimit))")
                if config.truncation != .tail {
                    lines.append("    .truncationMode(\(config.truncation.label))")
                }
            }
            return lines.joined(separator: "\n")
        } examples: {
            ExampleCard(
                title: "Markdown",
                caption: "A string literal in `Text` renders inline Markdown: bold, italic, code, strikethrough, and links.",
                code: """
                Text("**Bold**, *italic*, `code`, ~~strike~~, and a [link](https://developer.apple.com).")
                """,
                minHeight: 120,
                aside: Aside(.important, "Only literals are parsed. A `String` variable shows its asterisks as-is; use `Text(LocalizedStringKey(string))` to render its Markdown.")
            ) {
                Text("**Bold**, *italic*, `code`, ~~strike~~, and a [link](https://developer.apple.com).")
                    .frame(maxWidth: 320)
            }
            ExampleCard(
                title: "Dates and numbers",
                caption: "Pass a value and a `format:` to `Text`, and it formats the value for the person's locale.",
                code: """
                let price = 1299.0
                let date = Date.now

                VStack(alignment: .leading, spacing: 8) {
                    Text(price, format: .currency(code: "USD"))
                    Text(0.427, format: .percent.precision(.fractionLength(1)))
                    Text(1_250_000, format: .number.notation(.compactName))
                    Text(date, format: .dateTime.weekday(.wide).month().day())
                    Text(date, style: .time)
                    Text(date.addingTimeInterval(-90), style: .relative)
                }
                """,
                aside: Aside(.note, "The `.relative` and `.timer` styles update themselves every second, with no timer code.")
            ) {
                FormattingExample()
            }
            ExampleCard(
                title: "Mixing styles in one line",
                caption: "Interpolate a styled `Text` inside another to style part of a sentence. It still wraps as one paragraph.",
                code: """
                Text("Your order is \\(Text("on its way").bold().foregroundStyle(.green)) and arrives \\(Text("tomorrow").italic()).")
                """,
                minHeight: 120
            ) {
                Text("Your order is \(Text("on its way").bold().foregroundStyle(.green)) and arrives \(Text("tomorrow").italic()).")
                    .frame(maxWidth: 320)
            }
            ExampleCard(
                title: "Selectable text",
                caption: "Add `.textSelection(.enabled)` so people can long-press to copy an order number or address.",
                code: """
                VStack(alignment: .leading, spacing: 4) {
                    Text("Order number")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text("W-48213-7790")
                        .font(.title3.monospaced())
                }
                .textSelection(.enabled)
                """,
                minHeight: 120
            ) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Order number")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text("W-48213-7790")
                        .font(.title3.monospaced())
                }
                .textSelection(.enabled)
            }
        }
    }

    private func fontCode(_ config: TextConfig) -> String {
        if config.design == .standard {
            return config.weight == .regular
                ? config.font.label
                : "\(config.font.label).weight(\(config.weight.label))"
        }
        let weight = config.weight == .regular ? "" : ", weight: \(config.weight.label)"
        return ".system(\(config.font.label), design: \(config.design.label)\(weight))"
    }
}

private struct FormattingExample: View {
    var body: some View {
        let date = Date.now
        Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 8) {
            row(".currency", Text(1299.0, format: .currency(code: "USD")))
            row(".percent", Text(0.427, format: .percent.precision(.fractionLength(1))))
            row(".compactName", Text(1_250_000, format: .number.notation(.compactName)))
            row(".dateTime", Text(date, format: .dateTime.weekday(.wide).month().day()))
            row("style: .time", Text(date, style: .time))
            row("style: .relative", Text(date.addingTimeInterval(-90), style: .relative))
        }
        .frame(maxWidth: 340, alignment: .leading)
    }

    private func row(_ title: String, _ value: Text) -> some View {
        GridRow {
            Text(title)
                .font(.caption.monospaced())
                .foregroundStyle(.secondary)
            value
                .monospacedDigit()
        }
    }
}

// MARK: - Guideline samples

private struct TextHierarchySample: View {
    let hasHierarchy: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Weekend in Lisbon")
                .font(hasHierarchy ? .headline : .body)
            Text("3 nights · Arrives Friday")
                .font(hasHierarchy ? .subheadline : .body)
                .foregroundStyle(hasHierarchy ? .secondary : .primary)
        }
        .frame(width: 220, alignment: .leading)
    }
}

private struct TextWeightSample: View {
    let weight: Font.Weight

    var body: some View {
        Text("Your package arrives tomorrow between 2 and 4 PM.")
            .font(.footnote.weight(weight))
            .frame(width: 220, alignment: .leading)
    }
}

private struct TextWrapSample: View {
    let lineLimit: Int?

    var body: some View {
        Text("Your flight to Lisbon now leaves from gate B12 at 6:40 PM.")
            .lineLimit(lineLimit)
            .frame(width: 220, alignment: .leading)
    }
}

// MARK: - Options

private enum TextFontOption: DemoOption {
    case largeTitle, title, title2, title3, headline, body, callout, subheadline, footnote, caption

    var label: String { ".\(String(describing: self))" }

    var style: Font.TextStyle {
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

private enum TextWeightOption: DemoOption {
    case light, regular, medium, semibold, bold, heavy

    var label: String { ".\(String(describing: self))" }

    var weight: Font.Weight? {
        switch self {
        case .light: .light
        case .regular: nil
        case .medium: .medium
        case .semibold: .semibold
        case .bold: .bold
        case .heavy: .heavy
        }
    }
}

private enum TextDesignOption: DemoOption {
    case standard, rounded, serif, monospaced

    var label: String {
        switch self {
        case .standard: ".default"
        case .rounded: ".rounded"
        case .serif: ".serif"
        case .monospaced: ".monospaced"
        }
    }

    var design: Font.Design? {
        switch self {
        case .standard: nil
        case .rounded: .rounded
        case .serif: .serif
        case .monospaced: .monospaced
        }
    }
}

private enum TextAlignmentOption: DemoOption {
    case leading, center, trailing

    var label: String { ".\(String(describing: self))" }

    var alignment: TextAlignment {
        switch self {
        case .leading: .leading
        case .center: .center
        case .trailing: .trailing
        }
    }
}

private enum TextColorOption: DemoOption {
    case primary, secondary, tint, red, orange

    var label: String {
        switch self {
        case .primary: ".primary"
        case .secondary: ".secondary"
        case .tint: ".tint"
        case .red: ".red"
        case .orange: ".orange"
        }
    }

    var style: AnyShapeStyle {
        switch self {
        case .primary: AnyShapeStyle(.primary)
        case .secondary: AnyShapeStyle(.secondary)
        case .tint: AnyShapeStyle(.tint)
        case .red: AnyShapeStyle(.red)
        case .orange: AnyShapeStyle(.orange)
        }
    }
}

private enum TextTruncationOption: DemoOption {
    case tail, middle, head

    var label: String { ".\(String(describing: self))" }

    var mode: Text.TruncationMode {
        switch self {
        case .tail: .tail
        case .middle: .middle
        case .head: .head
        }
    }
}
