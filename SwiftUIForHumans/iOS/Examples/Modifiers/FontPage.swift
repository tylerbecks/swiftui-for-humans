import SwiftUI

extension ComponentPage {
    static let font = ComponentPage(
        id: "font",
        title: "font",
        summary: "Sets the size, weight, and design of text, and scales it with the user's text size.",
        category: .modifiers,
        kind: .modifier,
        symbol: "textformat.size",
        availability: ["iOS 13.0+", "macOS 10.15+", "visionOS 1.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/view/font(_:)",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/typography",
        aliases: ["font-size", "font-weight", "font-family", "bold", "typography", "text size", "Dynamic Type", "h1", "UIFont", "monospace"],
        related: ["typography", "text", "foreground-style", "label"],
        notes: [
            "**`.font` flows down to every text inside a container.** The closest one wins, so a child can override it, like CSS `font` inheritance.",
            "**Adjust a font without replacing it.** `fontWeight`, `fontDesign`, `fontWidth`, and `italic` change the current font, so they combine with a style set further up.",
        ],
        api: [
            APIItem("`.font(.headline)`", "A text style that scales with Dynamic Type."),
            APIItem("`.font(.title.weight(.semibold))`", "A text style at a different weight."),
            APIItem("`.fontWeight(_:)` / `.bold()`", "Changes the weight of the current font."),
            APIItem("`.fontDesign(_:)`", "`.rounded`, `.serif`, or `.monospaced`."),
            APIItem("`.monospacedDigit()`", "Equal-width digits, so numbers don't shift."),
            APIItem("`.custom(_:size:relativeTo:)`", "A custom font that still scales."),
        ],
        guidelines: [
            Guideline(
                "Show hierarchy with size, weight, and color.",
                "A bold title over secondary detail tells people what to read first. Text that all looks the same makes them read every word.",
                good: "Headline over secondary text.",
                bad: "Every line has the same weight."
            ) {
                FontHierarchySample(isStyled: true)
            } bad: {
                FontHierarchySample(isStyled: false)
            },
            Guideline(
                "Avoid light weights at small sizes.",
                "Ultralight and Thin strokes get hard to read when text is small. Use Regular or heavier for body and caption text.",
                good: "Regular weight stays readable.",
                bad: "Ultralight is hard to read when small."
            ) {
                FontWeightSample(weight: .regular)
            } bad: {
                FontWeightSample(weight: .ultraLight)
            },
            Guideline(
                "Use text styles instead of fixed sizes.",
                "Many people change their text size in Settings. Text styles follow that choice, and a hard-coded `.system(size:)` doesn't."
            ),
            Guideline(
                "Stick to one or two typefaces.",
                "The system font with a rounded or serif accent is plenty. More fonts make a screen look unplanned."
            ),
        ]
    ) {
        VStack(alignment: .leading, spacing: 2) {
            Text("Large Title").font(.largeTitle.bold())
            Text("Headline").font(.headline)
            Text("Rounded body").font(.body).fontDesign(.rounded)
            Text("caption, monospaced").font(.caption).monospaced().foregroundStyle(.secondary)
        }
    } content: { page in
        FontDemo(page: page)
    }
}

private struct FontConfig {
    var text = "The quick brown fox"
    var style: FontTextStyle = .title
    var weight: FontWeightOption = .regular
    var design: FontDesignOption = .default
    var width: FontWidthOption = .standard
    var italic = false
    var dynamicType: FontDynamicSize = .large
}

private enum FontTextStyle: DemoOption {
    case largeTitle, title, title2, title3, headline, subheadline, body, callout, footnote, caption, caption2

    var label: String {
        switch self {
        case .largeTitle: ".largeTitle"
        case .title: ".title"
        case .title2: ".title2"
        case .title3: ".title3"
        case .headline: ".headline"
        case .subheadline: ".subheadline"
        case .body: ".body"
        case .callout: ".callout"
        case .footnote: ".footnote"
        case .caption: ".caption"
        case .caption2: ".caption2"
        }
    }

    var font: Font {
        switch self {
        case .largeTitle: .largeTitle
        case .title: .title
        case .title2: .title2
        case .title3: .title3
        case .headline: .headline
        case .subheadline: .subheadline
        case .body: .body
        case .callout: .callout
        case .footnote: .footnote
        case .caption: .caption
        case .caption2: .caption2
        }
    }
}

private enum FontWeightOption: DemoOption {
    case ultraLight, light, regular, medium, semibold, bold, heavy, black

    var label: String { ".\(self)" }

    var weight: Font.Weight {
        switch self {
        case .ultraLight: .ultraLight
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

private enum FontDesignOption: DemoOption {
    case `default`, rounded, serif, monospaced

    var label: String { ".\(self)" }

    var design: Font.Design {
        switch self {
        case .default: .default
        case .rounded: .rounded
        case .serif: .serif
        case .monospaced: .monospaced
        }
    }
}

private enum FontWidthOption: DemoOption {
    case compressed, condensed, standard, expanded

    var label: String { ".\(self)" }

    var width: Font.Width {
        switch self {
        case .compressed: .compressed
        case .condensed: .condensed
        case .standard: .standard
        case .expanded: .expanded
        }
    }
}

private enum FontDynamicSize: DemoOption {
    case xSmall, large, xxxLarge, accessibility3

    var label: String {
        switch self {
        case .xSmall: "Extra small"
        case .large: "Default (large)"
        case .xxxLarge: "XXX large"
        case .accessibility3: "Accessibility 3"
        }
    }

    var code: String {
        switch self {
        case .xSmall: ".xSmall"
        case .large: ".large"
        case .xxxLarge: ".xxxLarge"
        case .accessibility3: ".accessibility3"
        }
    }

    var size: DynamicTypeSize {
        switch self {
        case .xSmall: .xSmall
        case .large: .large
        case .xxxLarge: .xxxLarge
        case .accessibility3: .accessibility3
        }
    }
}

private struct FontDemo: View {
    let page: ComponentPage

    var body: some View {
        DemoPage(
            page: page,
            initial: FontConfig(),
            usage: """
            VStack(alignment: .leading, spacing: 2) {
                Text("Trip to Lisbon")
                    .font(.headline)
                Text("May 4 – 9 · 3 travelers")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            """,
            usageNote: Aside(.important, "`.system(size:)` doesn't grow with Dynamic Type, the text size people pick in Settings. Prefer a text style like `.headline`.")
        ) { $config in
            VStack(spacing: 14) {
                Text(config.text)
                    .font(config.style.font)
                    .fontWeight(config.weight == .regular ? nil : config.weight.weight)
                    .fontDesign(config.design == .default ? nil : config.design.design)
                    .fontWidth(config.width == .standard ? nil : config.width.width)
                    .italic(config.italic)
                    .multilineTextAlignment(.center)
                    .dynamicTypeSize(config.dynamicType.size)
                    .animation(.snappy, value: config.style)
                if config.dynamicType != .large {
                    Label("Previewing Dynamic Type at \(config.dynamicType.label)", systemImage: "textformat.size")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        } controls: { $config in
            Section("Text") {
                TextField("Text", text: $config.text)
            }
            Section("Font") {
                OptionPicker("Text style", selection: $config.style)
                OptionPicker("Weight", selection: $config.weight)
                OptionPicker("Design", selection: $config.design)
                OptionPicker("Width", selection: $config.width)
                Toggle("Italic", isOn: $config.italic)
            }
            Section {
                OptionPicker("Text size", selection: $config.dynamicType)
            } header: {
                Text("Dynamic Type")
            } footer: {
                Text("Simulates the text size people pick in Settings. Text styles grow and shrink with it.")
            }
        } code: { config in
            var lines = ["Text(\(swiftString(config.text)))", "    .font(\(config.style.label))"]
            if config.weight != .regular { lines.append("    .fontWeight(\(config.weight.label))") }
            if config.design != .default { lines.append("    .fontDesign(\(config.design.label))") }
            if config.width != .standard { lines.append("    .fontWidth(\(config.width.label))") }
            if config.italic { lines.append("    .italic()") }
            lines.append("    .multilineTextAlignment(.center)")
            if config.dynamicType != .large {
                lines.append("    // Preview only: forces a text size. Leave it out in real apps.")
                lines.append("    .dynamicTypeSize(\(config.dynamicType.code))")
            }
            return lines.joined(separator: "\n")
        } examples: {
            ExampleCard(
                title: "The type scale",
                caption: "Use the built-in text styles, from `.largeTitle` to `.caption2`, like a design system's type ramp.",
                code: """
                VStack(alignment: .leading, spacing: 4) {
                    Text("Large Title").font(.largeTitle)
                    Text("Title").font(.title)
                    Text("Title 2").font(.title2)
                    Text("Title 3").font(.title3)
                    Text("Headline").font(.headline)
                    Text("Body").font(.body)
                    Text("Callout").font(.callout)
                    Text("Subheadline").font(.subheadline)
                    Text("Footnote").font(.footnote)
                    Text("Caption").font(.caption)
                    Text("Caption 2").font(.caption2)
                }
                """,
                minHeight: 360
            ) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Large Title").font(.largeTitle)
                    Text("Title").font(.title)
                    Text("Title 2").font(.title2)
                    Text("Title 3").font(.title3)
                    Text("Headline").font(.headline)
                    Text("Body").font(.body)
                    Text("Callout").font(.callout)
                    Text("Subheadline").font(.subheadline)
                    Text("Footnote").font(.footnote)
                    Text("Caption").font(.caption)
                    Text("Caption 2").font(.caption2)
                }
            }

            ExampleCard(
                title: "Numbers that don't jiggle",
                caption: "Add `.monospacedDigit()` so timers and counters don't shift sideways as the digits change.",
                code: """
                @State private var start = Date.now

                Text(start, style: .timer)
                    .font(.largeTitle.weight(.medium))
                    .monospacedDigit()
                """
            ) {
                FontTimerExample()
            }

            ExampleCard(
                title: "A custom font that still scales",
                caption: "Use `.custom(_:size:relativeTo:)` so a custom font grows with Dynamic Type like a text style.",
                code: """
                Text("Once upon a time")
                    .font(.custom("Georgia", size: 24, relativeTo: .title2))
                """,
                aside: Aside(.note, "Fonts you bundle need to be listed in your app's Info.plist under `UIAppFonts` before `.custom` can find them.")
            ) {
                Text("Once upon a time")
                    .font(.custom("Georgia", size: 24, relativeTo: .title2))
            }

            ExampleCard(
                title: "Mixed styles in one line",
                caption: "Write Markdown in a `Text` string literal for inline bold, italic, and code.",
                code: """
                Text("Tap **Save** to keep _all_ your `changes`.")
                """,
                aside: Aside(.important, "Markdown only works on literals. For a `String` variable, use `Text(LocalizedStringKey(value))` or `AttributedString(markdown:)`.")
            ) {
                Text("Tap **Save** to keep _all_ your `changes`.")
            }
        }
    }
}

private struct FontTimerExample: View {
    @State private var start = Date.now

    var body: some View {
        Text(start, style: .timer)
            .font(.largeTitle.weight(.medium))
            .monospacedDigit()
    }
}

// MARK: - Guideline samples

private struct FontHierarchySample: View {
    let isStyled: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Trip to Lisbon")
                .font(isStyled ? .headline : .subheadline)
            Text("May 4 – 9 · 3 travelers")
                .font(.subheadline)
                .foregroundStyle(isStyled ? .secondary : .primary)
        }
        .frame(width: 200, alignment: .leading)
    }
}

private struct FontWeightSample: View {
    let weight: Font.Weight

    var body: some View {
        Text("Your order ships in 2–3 business days.")
            .font(.footnote.weight(weight))
            .frame(width: 200, alignment: .leading)
    }
}
