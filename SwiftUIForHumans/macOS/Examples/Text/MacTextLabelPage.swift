import SwiftUI

extension ComponentPage {
    static let textLabel = ComponentPage(
        id: "text-label",
        title: "Text & Label",
        summary: "Shows read-only text, and pairs a short title with an icon in a label.",
        category: .textAndImages,
        symbol: "textformat",
        availability: ["macOS 10.15+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/text",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/labels",
        aliases: ["label", "string", "<p>", "<span>", "NSTextField", "font", "text style", "bold", "markdown", "AttributedString", "selectable", "copy text", "textSelection", "truncate", "ellipsis", "lineLimit", "labelStyle", "icon and title"],
        related: ["image-symbols", "typography", "labeled-content", "text-field", "writing"],
        notes: [
            "**Text styles have fixed sizes on the Mac.** `.body` is 13 points and `.largeTitle` is 26. The Mac doesn't support Dynamic Type.",
            "**A container can choose how a `Label` looks.** On the Mac, a toolbar shows only a label's icon unless you set `.labelStyle(.titleAndIcon)`.",
        ],
        api: [
            APIItem("`Text(_:)`", "Read-only text, one or more lines."),
            APIItem("`.font(_:)`", "A text style such as `.headline` or `.caption`."),
            APIItem("`.foregroundStyle(.secondary)`", "Ranks text with the system's label colors."),
            APIItem("`.textSelection(.enabled)`", "Lets people select and copy the text."),
            APIItem("`.lineLimit(_:)`", "Caps the lines; the rest is truncated."),
            APIItem("`.truncationMode(_:)`", "Where the ellipsis goes: `.head`, `.middle`, `.tail`."),
            APIItem("`Label(_:systemImage:)`", "A title with an SF Symbol."),
            APIItem("`.labelStyle(_:)`", "`.titleAndIcon`, `.titleOnly`, or `.iconOnly`."),
        ],
        guidelines: [
            Guideline(
                "Rank text with the label colors.",
                "Primary for the main information, secondary for supporting details, tertiary for something unavailable. People see what matters first.",
                good: "The detail line steps back.",
                bad: "Everything competes at full strength."
            ) {
                MacRankedSample(isRanked: true)
            } bad: {
                MacRankedSample(isRanked: false)
            },
            Guideline(
                "Avoid light weights, especially in small text.",
                "Ultralight, Thin, and Light are hard to read at small sizes. Regular, Medium, Semibold, and Bold hold up.",
                good: "Regular weight at caption size.",
                bad: "Ultralight at the same size."
            ) {
                MacWeightSample(weight: .regular)
            } bad: {
                MacWeightSample(weight: .ultraLight)
            },
            Guideline(
                "Let people copy useful text.",
                "Error messages, serial numbers, and addresses are often needed somewhere else. Make them selectable."
            ),
            Guideline(
                "Prefer the system font and its text styles.",
                "Text styles give you a consistent hierarchy of sizes and weights. Keep the number of typefaces small, even in a custom design."
            ),
        ]
    ) {
        VStack(alignment: .leading, spacing: 6) {
            Text("Vacation Photos")
                .font(.headline)
            Text("128 photos")
                .foregroundStyle(.secondary)
            Label("Shared", systemImage: "person.2")
                .foregroundStyle(.tint)
        }
    } content: { page in
        MacTextLabelDemo(page: page)
    }
}

private struct MacTextLabelConfig {
    var text = "Quarterly Report"
    var style: MacTextStyleOption = .title2
    var weight: MacWeightOption = .standard
    var color: MacLabelColorOption = .primary
    var isSelectable = false
    var labelStyle: MacLabelStyleOption = .automatic
}

private struct MacTextLabelDemo: View {
    let page: ComponentPage

    var body: some View {
        DemoPage(
            page: page,
            initial: MacTextLabelConfig(),
            usage: """
            VStack(alignment: .leading) {
                Text("Quarterly Report")
                    .font(.headline)
                Text("Updated today")
                    .foregroundStyle(.secondary)
                Label("Shared with 3 people", systemImage: "person.2")
            }
            """,
            usageNote: Aside(.note, "`Text` is like a `<span>`: it takes only the space it needs and wraps when its width is limited.")
        ) { $config in
            VStack(spacing: 28) {
                Text(config.text)
                    .font(config.style.font)
                    .fontWeight(config.weight.weight)
                    .foregroundStyle(config.color.style)
                    .modifier(MacSelectable(isOn: config.isSelectable))

                Label("Downloads", systemImage: "arrow.down.circle")
                    .modifier(MacLabelStyled(style: config.labelStyle))
            }
        } controls: { $config in
            Section("Text") {
                TextField("Text", text: $config.text)
                OptionPicker("Style", selection: $config.style)
                OptionPicker("Weight", selection: $config.weight)
                OptionPicker("Color", selection: $config.color)
                Toggle("Selectable", isOn: $config.isSelectable)
            }
            Section("Label") {
                OptionPicker("Label style", selection: $config.labelStyle)
            }
        } code: { config in
            var lines = ["Text(\(swiftString(config.text)))"]
            if config.style != .body {
                lines.append("    .font(\(config.style.label))")
            }
            if config.weight != .standard {
                lines.append("    .fontWeight(\(config.weight.label))")
            }
            if config.color != .primary {
                lines.append("    .foregroundStyle(\(config.color.label))")
            }
            if config.isSelectable {
                lines.append("    .textSelection(.enabled)")
            }
            lines += ["", "Label(\"Downloads\", systemImage: \"arrow.down.circle\")"]
            if config.labelStyle != .automatic {
                lines.append("    .labelStyle(\(config.labelStyle.label))")
            }
            return lines.joined(separator: "\n")
        } examples: {
            MacTextLabelExamples()
        }
    }
}

// MARK: - Examples

private struct MacTextLabelExamples: View {
    private let modified = Date(timeIntervalSinceReferenceDate: 800_000_000)
    private let path = "/Users/jo/Documents/Projects/Catalog/Exports/final-v3.pdf"

    var body: some View {
        ExampleCard(
            title: "Text people can copy",
            caption: "Add `.textSelection(.enabled)` to details people need elsewhere. They drag to select, then copy with ⌘C.",
            code: """
            Grid(alignment: .leading) {
                GridRow {
                    Text("Serial Number").foregroundStyle(.secondary)
                    Text("C02XK1JHJG5J")
                }
                GridRow {
                    Text("IP Address").foregroundStyle(.secondary)
                    Text("192.168.1.24")
                }
            }
            .textSelection(.enabled)
            """,
            minHeight: 120,
            aside: Aside(.note, "Put `.textSelection` on a container to make every `Text` inside it selectable. Buttons don't support selection.")
        ) {
            Grid(alignment: .leading) {
                GridRow {
                    Text("Serial Number").foregroundStyle(.secondary)
                    Text("C02XK1JHJG5J")
                }
                GridRow {
                    Text("IP Address").foregroundStyle(.secondary)
                    Text("192.168.1.24")
                }
            }
            .textSelection(.enabled)
        }

        ExampleCard(
            title: "Dates, sizes, and percentages",
            caption: "Pass a value and a `format:` instead of building strings. The output follows the person's language and region.",
            code: """
            let modified = Date.now

            VStack(alignment: .leading) {
                Text(modified, format: .dateTime.month().day().year())
                Text(Int64(2_400_000), format: .byteCount(style: .file))
                Text(0.42, format: .percent)
            }
            """,
            minHeight: 120
        ) {
            VStack(alignment: .leading) {
                Text(modified, format: .dateTime.month().day().year())
                Text(Int64(2_400_000), format: .byteCount(style: .file))
                Text(0.42, format: .percent)
            }
        }

        ExampleCard(
            title: "A long path in a short space",
            caption: "Use `.lineLimit(1)` with `.truncationMode(.middle)` so both ends of a path stay visible, and `.help` to show all of it on hover.",
            code: """
            let path = "/Users/jo/Documents/Projects/Catalog/Exports/final-v3.pdf"

            Text(path)
                .lineLimit(1)
                .truncationMode(.middle)
                .help(path)
                .frame(width: 240)
            """,
            minHeight: 100
        ) {
            Text(path)
                .lineLimit(1)
                .truncationMode(.middle)
                .help(path)
                .frame(width: 240)
        }

        ExampleCard(
            title: "Bold and italic inside a sentence",
            caption: "Make an `AttributedString` from Markdown to style part of a sentence. Attributes in the string win over modifiers on the `Text`.",
            code: """
            let note = try! AttributedString(markdown: "Your trial ends **Friday**. Export your work _before then_.")

            Text(note)
                .font(.title3)
            """,
            minHeight: 100
        ) {
            Text(try! AttributedString(markdown: "Your trial ends **Friday**. Export your work _before then_."))
                .font(.title3)
        }

        ExampleCard(
            title: "Label styles",
            caption: "A `Label` pairs a title with an icon. `.labelStyle` shows both, only the title, or only the icon.",
            code: """
            HStack(spacing: 32) {
                Label("Rain", systemImage: "cloud.rain")
                    .labelStyle(.titleAndIcon)
                Label("Rain", systemImage: "cloud.rain")
                    .labelStyle(.titleOnly)
                Label("Rain", systemImage: "cloud.rain")
                    .labelStyle(.iconOnly)
            }
            """,
            minHeight: 100
        ) {
            HStack(spacing: 32) {
                Label("Rain", systemImage: "cloud.rain")
                    .labelStyle(.titleAndIcon)
                Label("Rain", systemImage: "cloud.rain")
                    .labelStyle(.titleOnly)
                Label("Rain", systemImage: "cloud.rain")
                    .labelStyle(.iconOnly)
            }
        }

        ExampleCard(
            title: "A label with your own icon",
            caption: "Use `Label { } icon: { }` to put any view in the icon spot, like a person's initials.",
            code: """
            Label {
                VStack(alignment: .leading) {
                    Text("Jordan Lee")
                    Text("Designer")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            } icon: {
                Circle()
                    .fill(.teal)
                    .frame(width: 32, height: 32)
                    .overlay(Text("JL").font(.caption.bold()).foregroundStyle(.white))
            }
            """,
            minHeight: 110
        ) {
            Label {
                VStack(alignment: .leading) {
                    Text("Jordan Lee")
                    Text("Designer")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            } icon: {
                Circle()
                    .fill(.teal)
                    .frame(width: 32, height: 32)
                    .overlay(Text("JL").font(.caption.bold()).foregroundStyle(.white))
            }
        }
    }
}

// MARK: - Guideline samples

private struct MacRankedSample: View {
    let isRanked: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text("Vacation Photos")
                .font(.headline)
            Text("128 photos · Updated yesterday")
                .foregroundStyle(isRanked ? .secondary : .primary)
        }
    }
}

private struct MacWeightSample: View {
    let weight: Font.Weight

    var body: some View {
        Text("Last backup: Today at 9:41")
            .font(.caption)
            .fontWeight(weight)
    }
}

// MARK: - Options

private struct MacSelectable: ViewModifier {
    let isOn: Bool

    func body(content: Content) -> some View {
        if isOn {
            content.textSelection(.enabled)
        } else {
            content.textSelection(.disabled)
        }
    }
}

private struct MacLabelStyled: ViewModifier {
    let style: MacLabelStyleOption

    func body(content: Content) -> some View {
        switch style {
        case .automatic: content.labelStyle(.automatic)
        case .titleAndIcon: content.labelStyle(.titleAndIcon)
        case .titleOnly: content.labelStyle(.titleOnly)
        case .iconOnly: content.labelStyle(.iconOnly)
        }
    }
}

private enum MacTextStyleOption: DemoOption {
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

private enum MacWeightOption: DemoOption {
    case standard, medium, semibold, bold

    var label: String {
        switch self {
        case .standard: "Default"
        case .medium: ".medium"
        case .semibold: ".semibold"
        case .bold: ".bold"
        }
    }

    var weight: Font.Weight? {
        switch self {
        case .standard: nil
        case .medium: .medium
        case .semibold: .semibold
        case .bold: .bold
        }
    }
}

private enum MacLabelColorOption: DemoOption {
    case primary, secondary, tertiary, quaternary

    var label: String {
        switch self {
        case .primary: ".primary"
        case .secondary: ".secondary"
        case .tertiary: ".tertiary"
        case .quaternary: ".quaternary"
        }
    }

    var style: HierarchicalShapeStyle {
        switch self {
        case .primary: .primary
        case .secondary: .secondary
        case .tertiary: .tertiary
        case .quaternary: .quaternary
        }
    }
}

private enum MacLabelStyleOption: DemoOption {
    case automatic, titleAndIcon, titleOnly, iconOnly

    var label: String {
        switch self {
        case .automatic: ".automatic"
        case .titleAndIcon: ".titleAndIcon"
        case .titleOnly: ".titleOnly"
        case .iconOnly: ".iconOnly"
        }
    }
}
