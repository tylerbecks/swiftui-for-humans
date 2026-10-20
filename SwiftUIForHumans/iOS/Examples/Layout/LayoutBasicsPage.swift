import SwiftUI

extension ComponentPage {
    static let layoutBasics = ComponentPage(
        id: "layout-basics",
        title: "How Layout Works",
        summary: "A parent offers its child a size, the child picks its own, and the parent places it.",
        category: .layout,
        kind: .concept,
        symbol: "rectangle.3.group",
        availability: ["iOS 13.0+", "macOS 10.15+", "visionOS 1.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/layout-fundamentals",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/layout",
        aliases: ["box model", "css layout", "width 100%", "sizing", "auto layout", "constraints", "flexbox", "proposed size"],
        related: ["stacks", "frame", "padding", "modifier-order"],
        notes: [
            "**Shapes and colors are greedy.** `Color.blue` and `Rectangle()` take all the space they're offered, so give them a `.frame` or put them in a `.background`.",
            "**Write your own container with the `Layout` protocol.** When stacks and grids aren't enough, it's the same propose, choose, place conversation, in code.",
        ],
        api: [
            APIItem("`.frame(maxWidth: .infinity)`", "Fills the offered width, like `width: 100%`."),
            APIItem("`.frame(width:height:)`", "Offers its child an exact size."),
            APIItem("`.padding(_:)`", "Offers less space in, reports a bigger size out."),
            APIItem("`.fixedSize()`", "Ignores the offer and uses the view's ideal size."),
            APIItem("`.layoutPriority(_:)`", "Gives a sibling first claim on space in a stack."),
            APIItem("`Layout`", "A protocol for writing your own container."),
        ],
        guidelines: [
            Guideline(
                "Let text set its own size.",
                "People can make text much larger with Dynamic Type. A hard-coded width or height cuts it off; a flexible frame lets it wrap.",
                good: "A flexible width lets the text wrap.",
                bad: "A fixed height cuts the text off."
            ) {
                LayoutTextSample(isFixed: false)
            } bad: {
                LayoutTextSample(isFixed: true)
            },
            Guideline(
                "Base layout on the space you have, not the device.",
                "An iPhone app can run in a narrow iPad window or rotate. Read the size class or use `ViewThatFits` instead of checking the model."
            ),
        ]
    ) {
        LayoutBasicsThumbnail()
    } content: { page in
        ArticlePage(page: page) {
            LayoutBasicsArticle()
        }
    }
}

// MARK: - Thumbnail

private struct LayoutBasicsThumbnail: View {
    var body: some View {
        VStack(spacing: 6) {
            Text("180 × 70 offered")
                .font(.caption2.monospaced())
                .foregroundStyle(.secondary)
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(.secondary, style: StrokeStyle(lineWidth: 1.5, dash: [5, 4]))
                    .frame(width: 180, height: 70)
                Text("Hello")
                    .font(.headline)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Color.accentColor.opacity(0.15), in: .rect(cornerRadius: 8))
                    .overlay {
                        RoundedRectangle(cornerRadius: 8).strokeBorder(Color.accentColor, lineWidth: 2)
                    }
            }
            Text("67 × 36 chosen")
                .font(.caption2.monospaced())
                .foregroundStyle(Color.accentColor)
        }
    }
}

// MARK: - Article

private struct LayoutBasicsArticle: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            VStack(alignment: .leading, spacing: 12) {
                Prose("Forget the CSS box model for a moment. SwiftUI layout is a short conversation between a parent and each child, in three steps:")
                StepRow(number: 1, title: "Parent proposes", text: "The parent offers the child a size: \"you can have up to this much.\"")
                StepRow(number: 2, title: "Child chooses", text: "The child picks its own size. It can take all of it, part of it, or more.")
                StepRow(number: 3, title: "Parent places", text: "The parent positions the child inside its bounds, using its alignment.")
            }

            VStack(alignment: .leading, spacing: 12) {
                SectionTitle("See it happen")
                Prose("Drag the slider to change the offer (the dashed box). The colored outline is the size the child chose. Each child answers the same offer differently.")
                ProposalPlayground()
                    .id("playground")
                Aside(.note, "The child always has the last word on its size. That's why `Text` hugs its words while `Color` fills everything it's offered.")
            }

            VStack(alignment: .leading, spacing: 28) {
                SectionTitle("Examples")

                ExampleCard(
                    title: "Fill the width",
                    caption: "Views hug their content, so use `.frame(maxWidth: .infinity)` to get CSS's `width: 100%`.",
                    code: """
                    Text("Full width")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(.blue.opacity(0.2), in: .rect(cornerRadius: 10))
                    """,
                    aside: Aside(.note, "Pass an `alignment:` such as `.leading` to keep the text at one edge of the wider frame.")
                ) {
                    Text("Full width")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(.blue.opacity(0.2), in: .rect(cornerRadius: 10))
                }

                ExampleCard(
                    title: "Text wraps when offered less",
                    caption: "`Text` fits the width it's offered, wrapping onto more lines and growing taller.",
                    code: """
                    Text("SwiftUI lays out text to fit the space it's offered.")
                        .frame(width: 140)
                        .border(.blue)
                    """
                ) {
                    Text("SwiftUI lays out text to fit the space it's offered.")
                        .frame(width: 140)
                        .border(.blue)
                }

                ExampleCard(
                    title: "Ignore the offer with fixedSize",
                    caption: "`.fixedSize()` makes a view use its ideal size, so this text overflows instead of wrapping.",
                    code: """
                    Text("This line never wraps, even when it is too long")
                        .fixedSize()
                        .frame(width: 140)
                        .border(.blue)
                    """,
                    aside: Aside(.note, "Pass `horizontal: false, vertical: true` to let text wrap onto more lines but never truncate.")
                ) {
                    Text("This line never wraps, even when it is too long")
                        .fixedSize()
                        .frame(width: 140)
                        .border(.blue)
                }

                ExampleCard(
                    title: "Modifiers are parents too",
                    caption: "Each modifier wraps the view above it, so `.padding(20)` offers its child 40 points less.",
                    code: """
                    // Each modifier wraps the line above it
                    Text("Padded")
                        .foregroundStyle(.black)
                        .padding(20)
                        .background(.yellow)
                        .border(.blue)
                    """,
                    aside: Aside(.note, "That's why order matters: the background here covers the padding. See [Modifier Order](catalog://modifier-order).")
                ) {
                    Text("Padded")
                        .foregroundStyle(.black)
                        .padding(20)
                        .background(.yellow)
                        .border(.blue)
                }
            }
        }
    }
}

private struct StepRow: View {
    let number: Int
    let title: String
    let text: String

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            Text("\(number)")
                .font(.subheadline.bold().monospacedDigit())
                .frame(width: 26, height: 26)
                .background(Color.accentColor.opacity(0.15), in: .circle)
                .foregroundStyle(Color.accentColor)
                .alignmentGuide(.firstTextBaseline) { $0[VerticalAlignment.center] + 5 }
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.headline)
                Text(text)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

// MARK: - Guideline samples

/// A short bio in a flexible frame, or in a fixed-height one that clips it.
private struct LayoutTextSample: View {
    let isFixed: Bool

    var body: some View {
        Text("Maya designs apps for people who read with large text.")
            .font(.title3)
            .frame(width: 220, height: isFixed ? 30 : nil, alignment: .topLeading)
            .fixedSize(horizontal: false, vertical: !isFixed)
            .clipped()
            .padding(8)
            .border(.secondary)
    }
}

// MARK: - Interactive playground

private enum ProposalChild: String, CaseIterable, Identifiable {
    case text = "Text"
    case color = "Color"
    case fixed = "frame(width: 120)"
    case maxWidth = "frame(maxWidth: .infinity)"

    var id: Self { self }

    var shortLabel: String {
        switch self {
        case .text: "Text"
        case .color: "Color"
        case .fixed: "Fixed"
        case .maxWidth: "Fill"
        }
    }

    var explanation: String {
        switch self {
        case .text: "`Text` takes only what it needs. Offer it less, and it wraps or truncates."
        case .color: "`Color` is greedy. It takes the whole offer in both directions."
        case .fixed: "A fixed `frame` ignores the offer, even if that means sticking out of its parent."
        case .maxWidth: "`.frame(maxWidth: .infinity)` grows to fill the offered width, but keeps the content's height."
        }
    }

    var code: String {
        switch self {
        case .text: "Text(\"Hello, layout\")"
        case .color: "Color.blue.opacity(0.35)"
        case .fixed: "Text(\"Hello, layout\")\n    .frame(width: 120)"
        case .maxWidth: "Text(\"Hello, layout\")\n    .frame(maxWidth: .infinity)"
        }
    }
}

private struct ProposalPlayground: View {
    @State private var offeredWidth: Double = 240
    @State private var child: ProposalChild = .text
    @State private var chosen: CGSize = .zero

    private let offeredHeight: CGFloat = 120

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            PreviewCard(title: "Propose, choose, place", minHeight: 200) {
                VStack(spacing: 16) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .strokeBorder(.secondary, style: StrokeStyle(lineWidth: 1.5, dash: [5, 4]))
                        childView
                            .onGeometryChange(for: CGSize.self) { $0.size } action: { chosen = $0 }
                            .overlay {
                                Rectangle()
                                    .strokeBorder(Color.accentColor, lineWidth: 2)
                            }
                    }
                    .frame(width: offeredWidth, height: offeredHeight)
                    .animation(.snappy, value: child)

                    HStack(spacing: 16) {
                        legend(color: .secondary, dashed: true, text: "Offered \(Int(offeredWidth)) × \(Int(offeredHeight))")
                        legend(color: .accentColor, dashed: false, text: "Chosen \(Int(chosen.width.rounded())) × \(Int(chosen.height.rounded()))")
                    }
                    .font(.caption.monospacedDigit())
                }
                .frame(maxWidth: .infinity)
            }

            Picker("Child", selection: $child) {
                ForEach(ProposalChild.allCases) { option in
                    Text(option.shortLabel).tag(option)
                }
            }
            .pickerStyle(.segmented)

            HStack {
                Text("Offered width")
                Slider(value: $offeredWidth, in: 60...280, step: 1)
                    .accessibilityIdentifier("offered-width")
            }
            .font(.subheadline)

            RichText(child.explanation)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            CodeBlock(code: "\(child.code)\n    .frame(width: \(Int(offeredWidth)), height: \(Int(offeredHeight))) // the parent's offer")
        }
    }

    @ViewBuilder
    private var childView: some View {
        switch child {
        case .text:
            Text("Hello, layout")
        case .color:
            Color.blue.opacity(0.35)
        case .fixed:
            Text("Hello, layout")
                .frame(width: 120)
        case .maxWidth:
            Text("Hello, layout")
                .frame(maxWidth: .infinity)
        }
    }

    private func legend(color: Color, dashed: Bool, text: String) -> some View {
        HStack(spacing: 6) {
            RoundedRectangle(cornerRadius: 2)
                .strokeBorder(color, style: StrokeStyle(lineWidth: 1.5, dash: dashed ? [3, 2] : []))
                .frame(width: 14, height: 10)
            Text(text)
                .foregroundStyle(.secondary)
        }
    }
}
