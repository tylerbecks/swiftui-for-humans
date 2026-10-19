import SwiftUI

extension ComponentPage {
    static let typography = ComponentPage(
        id: "typography",
        title: "Typography",
        summary: "Mac text is smaller than iPhone text: 13 points by default, and 10 at the smallest.",
        category: .foundations,
        kind: .concept,
        symbol: "textformat.size",
        availability: [],
        docsURL: "https://developer.apple.com/documentation/swiftui/font",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/typography",
        aliases: ["font", "fonts", "text styles", "text size", "font size", "SF Pro", "San Francisco", "SF Mono", "NSFont", "headline", "body", "caption", "large title", "font-size", "line height", "leading", "monospaced"],
        related: ["text-label", "sf-symbols", "writing", "contrast-transparency"],
        notes: [
            "**Custom fonts follow the same sizes.** Keep body text at 13 points and the smallest text at 10, and go larger if the font is thin.",
        ],
        api: [
            APIItem("`.font(.body)`", "A built-in text style; body is 13 pt on the Mac."),
            APIItem("`.font(.headline)`", "Bold 13 pt, for a heading above body text."),
            APIItem("`.fontWeight(_:)`", "Adds emphasis without a new size."),
            APIItem("`.foregroundStyle(.secondary)`", "Lower-priority text, in a gray that adapts."),
            APIItem("`.monospacedDigit()`", "Digits of equal width, for numbers that change."),
            APIItem("`.font(.body.monospaced())`", "SF Mono, for code and paths."),
            APIItem("`.font(.body.leading(.loose))`", "More space between lines of long text."),
        ],
        guidelines: [
            Guideline(
                "Keep text at 10 points or larger.",
                "13 points is the Mac's default size, and 10 is the smallest Apple recommends. Footnote and caption styles are already 10 points.",
                good: "The detail line uses `.footnote`, 10 pt.",
                bad: "The detail line is set to 8 pt."
            ) {
                MacTypeRow(detailFont: .footnote)
            } bad: {
                MacTypeRow(detailFont: .system(size: 8))
            },
            Guideline(
                "Avoid light weights.",
                "Ultralight, Thin, and Light are hard to read, especially at small sizes. Stay with Regular, Medium, Semibold, or Bold.",
                good: "Regular weight reads clearly.",
                bad: "Ultralight fades into the background."
            ) {
                MacWeightSample(weight: .regular)
            } bad: {
                MacWeightSample(weight: .ultraLight)
            },
            Guideline(
                "Show hierarchy with size, weight, and color.",
                "A heading in `.headline` over body text in `.secondary` gray reads at a glance. Use the built-in styles so your levels match other Mac apps."
            ),
            Guideline(
                "Use as few typefaces as you can.",
                "Mixing several fonts muddies the hierarchy and makes an app look unfinished. The system font in a few styles covers most apps."
            ),
            Guideline(
                "Give long text room between lines.",
                "Loose leading helps people keep their place across wide paragraphs. Tighten it only for one or two lines in a cramped row, never for three or more."
            ),
        ],
        sources: [
            "https://developer.apple.com/design/human-interface-guidelines/typography",
            "https://developer.apple.com/documentation/swiftui/font",
            "https://developer.apple.com/documentation/swiftui/font/body",
            "https://developer.apple.com/documentation/swiftui/font/leading(_:)",
            "https://developer.apple.com/documentation/swiftui/view/fontweight(_:)",
            "https://developer.apple.com/documentation/swiftui/view/monospaceddigit()",
        ],
        reviewed: "October 2026"
    ) {
        VStack(alignment: .leading, spacing: 4) {
            Text("Aa")
                .font(.largeTitle.bold())
            Text("Headline")
                .font(.headline)
            Text("Body text, 13 pt")
                .font(.body)
                .foregroundStyle(.secondary)
        }
    } content: { page in
        MacTypographyArticle(page: page)
    }
}

// MARK: - Page

private struct MacTypographyArticle: View {
    let page: ComponentPage

    var body: some View {
        ArticlePage(page: page) {
            Prose("Text on the Mac is set smaller than on iPhone: the default size is 13 points instead of 17, and the smallest is 10. **SF Pro** is the system font, and SwiftUI's text styles give you a ready-made hierarchy, from a 26-point large title down to 10-point captions.")

            VStack(alignment: .leading, spacing: 16) {
                SectionTitle("The Mac's text styles")
                    .id("demo")
                MacTypeRamp()
                Aside(.note, "Sizes and weights come from Apple's macOS text style table. They're the same on every Mac, because the Mac has no Dynamic Type.")
            }

            VStack(alignment: .leading, spacing: 16) {
                SectionTitle("In SwiftUI")
                    .id("examples")
                VStack(alignment: .leading, spacing: 44) {
                    ExampleCard(
                        title: "Build a hierarchy from text styles",
                        caption: "Use `.headline` for the title, the default `.body` for the main line, and `.subheadline` in `.secondary` for details.",
                        code: """
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Weekly Planning")
                                .font(.headline)
                            Text("Agenda for Monday's meeting")
                            Text("Today, 9:41 AM")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        """,
                        minHeight: 130
                    ) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Weekly Planning")
                                .font(.headline)
                            Text("Agenda for Monday's meeting")
                            Text("Today, 9:41 AM")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }

                    ExampleCard(
                        title: "Emphasize with weight",
                        caption: "Use `.fontWeight(.semibold)` to stress a word or a total without adding another size to the window.",
                        code: """
                        HStack {
                            Text("Total")
                            Spacer()
                            Text("$128.40")
                                .fontWeight(.semibold)
                        }
                        .frame(width: 220)
                        """,
                        minHeight: 110
                    ) {
                        HStack {
                            Text("Total")
                            Spacer()
                            Text("$128.40")
                                .fontWeight(.semibold)
                        }
                        .frame(width: 220)
                    }

                    ExampleCard(
                        title: "Keep changing numbers still",
                        caption: "Add `.monospacedDigit()` to a clock or a column of numbers, so the digits don't shift as the value changes.",
                        code: """
                        TimelineView(.periodic(from: .now, by: 1)) { context in
                            Text(context.date, format: .dateTime.hour().minute().second())
                                .font(.title.monospacedDigit())
                        }
                        """,
                        minHeight: 130
                    ) {
                        MacTimerSample()
                    }

                    ExampleCard(
                        title: "Monospaced text for code",
                        caption: "`Font.monospaced()` switches a text style to SF Mono, for code, file paths, and anything people compare column by column.",
                        code: """
                        Text("~/Library/Containers/")
                            .font(.body.monospaced())
                        """,
                        minHeight: 100
                    ) {
                        Text("~/Library/Containers/")
                            .font(.body.monospaced())
                    }

                    ExampleCard(
                        title: "Loose leading for long passages",
                        caption: "Use `.leading(.loose)` on the font for paragraphs that span a wide window, so the eye finds the next line easily.",
                        code: """
                        Text("The old town is hilly and paved with cobblestones, so pack light and wear good shoes.")
                            .font(.body.leading(.loose))
                            .frame(maxWidth: 360)
                        """,
                        minHeight: 130
                    ) {
                        Text("The old town is hilly and paved with cobblestones, so pack light and wear good shoes.")
                            .font(.body.leading(.loose))
                            .frame(maxWidth: 360)
                    }
                }
            }
        }
    }
}

// MARK: - Demo

private struct MacTextStyleSpec: Identifiable {
    let name: String
    let font: Font
    let api: String
    let size: Int
    let weight: String
    var id: String { name }
}

/// Every macOS text style, live, beside its size and weight from Apple's
/// table. Type a sample to see your own words in each style.
private struct MacTypeRamp: View {
    @State private var sample = "Trips to Lisbon"

    private let styles: [MacTextStyleSpec] = [
        MacTextStyleSpec(name: "Large Title", font: .largeTitle, api: ".largeTitle", size: 26, weight: "Regular"),
        MacTextStyleSpec(name: "Title 1", font: .title, api: ".title", size: 22, weight: "Regular"),
        MacTextStyleSpec(name: "Title 2", font: .title2, api: ".title2", size: 17, weight: "Regular"),
        MacTextStyleSpec(name: "Title 3", font: .title3, api: ".title3", size: 15, weight: "Regular"),
        MacTextStyleSpec(name: "Headline", font: .headline, api: ".headline", size: 13, weight: "Bold"),
        MacTextStyleSpec(name: "Body", font: .body, api: ".body", size: 13, weight: "Regular"),
        MacTextStyleSpec(name: "Callout", font: .callout, api: ".callout", size: 12, weight: "Regular"),
        MacTextStyleSpec(name: "Subheadline", font: .subheadline, api: ".subheadline", size: 11, weight: "Regular"),
        MacTextStyleSpec(name: "Footnote", font: .footnote, api: ".footnote", size: 10, weight: "Regular"),
        MacTextStyleSpec(name: "Caption 1", font: .caption, api: ".caption", size: 10, weight: "Regular"),
        MacTextStyleSpec(name: "Caption 2", font: .caption2, api: ".caption2", size: 10, weight: "Medium"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            Grid(alignment: .leadingFirstTextBaseline, horizontalSpacing: 16, verticalSpacing: 10) {
                ForEach(styles) { style in
                    GridRow {
                        Text(sample.isEmpty ? style.name : sample)
                            .font(style.font)
                            .lineLimit(1)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text(style.api)
                            .font(.callout.monospaced())
                            .foregroundStyle(.secondary)
                        Text("\(style.size) pt")
                            .monospacedDigit()
                            .foregroundStyle(.secondary)
                            .gridColumnAlignment(.trailing)
                        Text(style.weight)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(20)
            .frame(maxWidth: .infinity)
            .background(Surface.preview)
            Divider()
            HStack(spacing: 12) {
                Text("Sample")
                TextField("Sample", text: $sample, prompt: Text("Type something"))
                    .labelsHidden()
                    .frame(maxWidth: 260)
                Spacer()
            }
            .padding(14)
        }
        .cardStyle()
    }
}

private struct MacTimerSample: View {
    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            Text(context.date, format: .dateTime.hour().minute().second())
                .font(.title.monospacedDigit())
        }
    }
}

// MARK: - Guideline samples

private struct MacTypeRow: View {
    let detailFont: Font

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "doc.text")
                .font(.title2)
                .foregroundStyle(.secondary)
            VStack(alignment: .leading, spacing: 2) {
                Text("Itinerary.pdf")
                Text("Edited today · 2.4 MB")
                    .font(detailFont)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

private struct MacWeightSample: View {
    let weight: Font.Weight

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Weekly Planning")
                .font(.title3)
            Text("Agenda for Monday's meeting")
                .foregroundStyle(.secondary)
        }
        .fontWeight(weight)
    }
}
