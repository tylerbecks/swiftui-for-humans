import SwiftUI

extension ComponentPage {
    static let modifierOrder = ComponentPage(
        id: "modifier-order",
        title: "Modifier Order",
        summary: "Each modifier wraps the view before it, so changing the order changes the result.",
        category: .modifiers,
        kind: .concept,
        symbol: "list.number",
        availability: ["iOS 13.0+", "macOS 10.15+", "visionOS 1.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/configuring-views",
        aliases: ["chaining", "modifier chain", "css order", "box model", "wrapper", "decorator", "why is my background wrong", "padding vs background"],
        related: ["padding", "background-overlay", "frame", "custom-modifier"],
        notes: [
            "**Read a chain top to bottom as \"take this, then wrap it in that\".** The last modifier is the outermost view.",
            "**When a background looks wrong, check the order first.** Most surprises come from `padding` or `frame` sitting on the wrong side of `background`.",
        ],
        api: [
            APIItem("`.padding(_:)`", "Layout: grows the size that later modifiers see."),
            APIItem("`.frame(width:height:)`", "Layout: proposes a new size for everything after it."),
            APIItem("`.background(_:)`", "Drawing: fills whatever size it's handed."),
            APIItem("`.clipShape(_:)`", "Drawing: cuts off everything before it, shadows included."),
            APIItem("`.font(_:)`", "Environment: flows down, so its position rarely matters."),
        ]
    ) {
        OrderThumbnail()
    } content: { page in
        ModifierOrderArticle(page: page)
    }
}

// MARK: - Model

private enum OrderStep: String, CaseIterable, Identifiable {
    case padding, background, clipShape, border, frame, shadow

    var id: Self { self }

    var code: String {
        switch self {
        case .padding: ".padding(20)"
        case .background: ".background(.orange)"
        case .clipShape: ".clipShape(.capsule)"
        case .border: ".border(.primary, width: 3)"
        case .frame: ".frame(width: 240, height: 110)"
        case .shadow: ".shadow(radius: 10)"
        }
    }

    var role: String {
        switch self {
        case .padding: "Adds space around what it wraps."
        case .background: "Fills the size it is given."
        case .clipShape: "Cuts everything inside to a capsule."
        case .border: "Draws a line around the size it is given."
        case .frame: "Proposes a fixed size and centers the rest in it."
        case .shadow: "Draws a shadow behind everything inside."
        }
    }

    var color: Color {
        switch self {
        case .padding: .blue
        case .background: .orange
        case .clipShape: .purple
        case .border: .green
        case .frame: .pink
        case .shadow: .teal
        }
    }
}

private struct OrderItem: Identifiable, Equatable {
    let step: OrderStep
    var isOn: Bool
    var id: OrderStep { step }
}

private enum OrderPreset: String, CaseIterable, Identifiable {
    case pill = "Pill"
    case backgroundFirst = "Background first"
    case frameFirst = "Frame first"
    case clipLast = "Clip last"

    var id: Self { self }

    var items: [OrderItem] {
        switch self {
        case .pill:
            [.init(step: .padding, isOn: true), .init(step: .background, isOn: true), .init(step: .clipShape, isOn: true),
             .init(step: .border, isOn: false), .init(step: .frame, isOn: false), .init(step: .shadow, isOn: true)]
        case .backgroundFirst:
            [.init(step: .background, isOn: true), .init(step: .padding, isOn: true), .init(step: .clipShape, isOn: true),
             .init(step: .border, isOn: true), .init(step: .frame, isOn: false), .init(step: .shadow, isOn: false)]
        case .frameFirst:
            [.init(step: .frame, isOn: true), .init(step: .padding, isOn: true), .init(step: .background, isOn: true),
             .init(step: .clipShape, isOn: true), .init(step: .border, isOn: true), .init(step: .shadow, isOn: false)]
        case .clipLast:
            [.init(step: .padding, isOn: true), .init(step: .background, isOn: true), .init(step: .border, isOn: true),
             .init(step: .shadow, isOn: true), .init(step: .frame, isOn: false), .init(step: .clipShape, isOn: true)]
        }
    }
}

private let defaultOrder: [OrderItem] = [
    .init(step: .padding, isOn: true),
    .init(step: .background, isOn: true),
    .init(step: .clipShape, isOn: true),
    .init(step: .border, isOn: true),
    .init(step: .frame, isOn: true),
    .init(step: .shadow, isOn: false),
]

private extension View {
    /// Applies one step of the playground chain, optionally outlining the
    /// new wrapper view so the reader can see its bounds.
    @ViewBuilder
    func orderStep(_ step: OrderStep, outlined: Bool) -> some View {
        let wrapped = Group {
            switch step {
            case .padding: self.padding(20)
            case .background: self.background(.orange)
            case .clipShape: self.clipShape(.capsule)
            case .border: self.border(.primary, width: 3)
            case .frame: self.frame(width: 240, height: 110)
            case .shadow: self.shadow(radius: 10)
            }
        }
        if outlined {
            wrapped.overlay {
                Rectangle()
                    .strokeBorder(step.color, style: StrokeStyle(lineWidth: 1.5, dash: [4, 3]))
                    .allowsHitTesting(false)
            }
        } else {
            wrapped
        }
    }
}

/// Builds the chain one modifier at a time, in the order given.
private struct OrderChain: View {
    let items: [OrderItem]
    var outlined = false

    var body: some View {
        items.filter(\.isOn).reduce(AnyView(baseText)) { view, item in
            AnyView(view.orderStep(item.step, outlined: outlined))
        }
    }

    private var baseText: some View {
        Text("Hello")
            .font(.title2.bold())
    }
}

// MARK: - Page

private struct ModifierOrderArticle: View {
    let page: ComponentPage
    @State private var items = defaultOrder
    @State private var showBounds = true

    private var code: String {
        var lines = ["Text(\"Hello\")", "    .font(.title2.bold())"]
        lines += items.filter(\.isOn).map { "    " + $0.step.code }
        return lines.joined(separator: "\n")
    }

    var body: some View {
        ArticlePage(page: page) {
            Prose("In CSS, `padding` and `background` are properties of one box, so their order doesn't matter. In SwiftUI each modifier is a **new view that wraps the one before it**, and `background` paints whatever size it receives. So it matters whether `padding` comes before it or after.")

            VStack(alignment: .leading, spacing: 12) {
                SectionTitle("Playground")
                Prose("Turn modifiers on and off, and move them up or down. The preview and code follow the order you set.")
                PreviewCard(minHeight: 200) {
                    OrderChain(items: items, outlined: showBounds)
                        .animation(.snappy, value: items)
                }
                Toggle("Outline each wrapper view", isOn: $showBounds.animation())
                    .font(.subheadline)
                    .padding(.horizontal, 4)
                stepList
                presets
                CodeBlock(code: code)
            }
            .id("playground")

            VStack(alignment: .leading, spacing: 12) {
                SectionTitle("Why order matters")
                Prose("A modifier doesn't change the view you call it on. It returns a **new view** that contains the old one, so each line adds a layer on the outside, like nesting `<div>`s. Here's the chain above, outermost first:")
                NestingDiagram(items: items)
                    .animation(.snappy, value: items)
                Prose("Each layer only knows the size of the layer directly inside it. A `background` after `padding` sees the padded size and fills it. Before it, the `background` sees only the text, and the padding adds clear space outside.")
                OrderKindsTable()
                Aside(.note, "Environment modifiers aren't order-sensitive. `.font(.title).padding()` and `.padding().font(.title)` look the same, because `font` passes its value down to everything inside.")
            }
            .id("why")

            VStack(alignment: .leading, spacing: 28) {
                SectionTitle("Classic mix-ups")
                ExampleCard(
                    title: "Padding inside or outside the color",
                    caption: "Put `padding` before `background` for a filled chip, and after it for space around the chip.",
                    code: """
                    // In the preview, a dashed line marks the padded area
                    Text("Padding first")
                        .padding()
                        .background(.yellow)
                        .foregroundStyle(.black)

                    Text("Background first")
                        .background(.yellow)
                        .foregroundStyle(.black)
                        .padding()
                    """
                ) {
                    HStack(spacing: 16) {
                        Text("Padding first")
                            .padding()
                            .background(.yellow)
                            .foregroundStyle(.black)
                        Text("Background first")
                            .background(.yellow)
                            .foregroundStyle(.black)
                            .padding()
                            .overlay {
                                Rectangle().strokeBorder(.secondary, style: StrokeStyle(lineWidth: 1, dash: [4, 3]))
                            }
                    }
                    .font(.subheadline)
                }

                ExampleCard(
                    title: "A clipped shadow",
                    caption: "Call `clipShape` before `shadow`, or the clip cuts the shadow off with everything else.",
                    code: """
                    // Shadow is cut off
                    Color.blue
                        .frame(width: 100, height: 70)
                        .shadow(radius: 12)
                        .clipShape(.rect(cornerRadius: 16))

                    // Shadow shows
                    Color.blue
                        .frame(width: 100, height: 70)
                        .clipShape(.rect(cornerRadius: 16))
                        .shadow(radius: 12)
                    """
                ) {
                    HStack(spacing: 32) {
                        Color.blue
                            .frame(width: 100, height: 70)
                            .shadow(radius: 12)
                            .clipShape(.rect(cornerRadius: 16))
                        Color.blue
                            .frame(width: 100, height: 70)
                            .clipShape(.rect(cornerRadius: 16))
                            .shadow(radius: 12)
                    }
                }

                ExampleCard(
                    title: "Frame, then background",
                    caption: "Put `background` after `frame` to fill the whole frame, not just the text inside it.",
                    code: """
                    // In the preview, a dashed line marks the frame
                    Text("Frame first")
                        .frame(width: 140, height: 60)
                        .background(.mint)
                        .foregroundStyle(.black)

                    Text("Background first")
                        .background(.mint)
                        .frame(width: 140, height: 60)
                        .foregroundStyle(.black)
                    """,
                    aside: Aside(.note, "`frame` makes a bigger box but doesn't paint it. The dashed line shows the empty frame.")
                ) {
                    HStack(spacing: 16) {
                        Text("Frame first")
                            .frame(width: 140, height: 60)
                            .background(.mint)
                        Text("Background first")
                            .background(.mint)
                            .frame(width: 140, height: 60)
                            .overlay {
                                Rectangle().strokeBorder(.secondary, style: StrokeStyle(lineWidth: 1, dash: [4, 3]))
                            }
                    }
                    .font(.subheadline)
                    .foregroundStyle(.black)
                }

                ExampleCard(
                    title: "Stacking the same modifier",
                    caption: "Repeat `padding` and `background` to stack layers, like a double border.",
                    code: """
                    Text("Layered")
                        .padding(12)
                        .background(.blue)
                        .padding(8)
                        .background(.blue.opacity(0.3))
                    """
                ) {
                    Text("Layered")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .padding(12)
                        .background(.blue)
                        .padding(8)
                        .background(.blue.opacity(0.3))
                }
            }
            .id("examples")
        }
    }

    // MARK: Step list

    private var stepList: some View {
        VStack(spacing: 0) {
            ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                if index > 0 { Divider().padding(.leading, 52) }
                stepRow(item, index: index)
            }
        }
        .cardStyle()
    }

    private func stepRow(_ item: OrderItem, index: Int) -> some View {
        HStack(spacing: 12) {
            Button {
                withAnimation(.snappy) { items[index].isOn.toggle() }
            } label: {
                Image(systemName: item.isOn ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(item.isOn ? item.step.color : Color.secondary)
                    .frame(width: 28, height: 28)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(item.isOn ? "Turn off \(item.step.rawValue)" : "Turn on \(item.step.rawValue)")

            VStack(alignment: .leading, spacing: 2) {
                Text(item.step.code)
                    .font(.system(.subheadline, design: .monospaced).weight(.medium))
                    .foregroundStyle(item.isOn ? .primary : .secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Text(item.step.role)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 4) {
                moveButton("chevron.up", label: "Move \(item.step.rawValue) up", disabled: index == 0) {
                    items.swapAt(index, index - 1)
                }
                moveButton("chevron.down", label: "Move \(item.step.rawValue) down", disabled: index == items.count - 1) {
                    items.swapAt(index, index + 1)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
    }

    private func moveButton(_ symbol: String, label: String, disabled: Bool, action: @escaping () -> Void) -> some View {
        Button {
            withAnimation(.snappy) { action() }
        } label: {
            Image(systemName: symbol)
                .font(.subheadline.weight(.semibold))
                .frame(width: 34, height: 34)
                .background(.fill.tertiary, in: .circle)
        }
        .buttonStyle(.plain)
        .disabled(disabled)
        .opacity(disabled ? 0.3 : 1)
        .accessibilityLabel(label)
    }

    private var presets: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(OrderPreset.allCases) { preset in
                    Button(preset.rawValue) {
                        withAnimation(.snappy) { items = preset.items }
                    }
                    .buttonStyle(.bordered)
                    .buttonBorderShape(.capsule)
                    .controlSize(.small)
                }
                Button("Reset", systemImage: "arrow.counterclockwise") {
                    withAnimation(.snappy) { items = defaultOrder }
                }
                .buttonStyle(.bordered)
                .buttonBorderShape(.capsule)
                .controlSize(.small)
            }
        }
        .scrollClipDisabled()
    }
}

// MARK: - Nesting diagram

/// Draws the chain as nested boxes: the last modifier is the outer box,
/// the text is in the middle.
private struct NestingDiagram: View {
    let items: [OrderItem]

    var body: some View {
        let active = items.filter(\.isOn).map(\.step)
        layer(active.reversed()[...])
            .frame(maxWidth: .infinity)
            .padding(16)
            .cardStyle()
    }

    private func layer(_ remaining: ArraySlice<OrderStep>) -> AnyView {
        guard let outer = remaining.first else {
            return AnyView(
                Text("Text(\"Hello\")")
                    .font(.system(.caption, design: .monospaced).weight(.semibold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background(.fill.secondary, in: .rect(cornerRadius: 6))
            )
        }
        return AnyView(
            VStack(alignment: .leading, spacing: 6) {
                Text(outer.code)
                    .font(.system(.caption2, design: .monospaced).weight(.semibold))
                    .foregroundStyle(outer.color)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                layer(remaining.dropFirst())
                    .frame(maxWidth: .infinity)
            }
            .padding(8)
            .background(outer.color.opacity(0.08), in: .rect(cornerRadius: 10))
            .overlay {
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(outer.color.opacity(0.6), lineWidth: 1)
            }
        )
    }
}

// MARK: - Kinds of modifiers

/// A small decision table: which kinds of modifiers care about order.
private struct OrderKindsTable: View {
    private let rows: [(kind: String, examples: String, effect: String)] = [
        ("Layout", "`padding`, `frame`", "Changes the size that later modifiers see."),
        ("Drawing", "`background`, `border`, `clipShape`, `shadow`", "Uses whatever size it's handed."),
        ("Effects", "`offset`, `scaleEffect`, `rotationEffect`", "Moves pixels, not layout. Neighbors don't move."),
        ("Environment", "`font`, `foregroundStyle`, `tint`", "Flows down to children. Order rarely matters."),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(rows.enumerated()), id: \.offset) { index, row in
                if index > 0 { Divider() }
                VStack(alignment: .leading, spacing: 4) {
                    Text(row.kind)
                        .font(.headline)
                    RichText(row.examples)
                        .font(.subheadline)
                    Text(row.effect)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .cardStyle()
    }
}

// MARK: - Thumbnail

private struct OrderThumbnail: View {
    var body: some View {
        HStack(spacing: 18) {
            VStack(spacing: 8) {
                Text("Hello")
                    .font(.headline)
                    .padding(12)
                    .background(.orange)
                    .clipShape(.capsule)
                Text(".padding\n.background")
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            Image(systemName: "arrow.left.arrow.right")
                .foregroundStyle(.tertiary)
            VStack(spacing: 8) {
                Text("Hello")
                    .font(.headline)
                    .background(.orange)
                    .padding(12)
                    .clipShape(.capsule)
                    .overlay {
                        Capsule().strokeBorder(.secondary, style: StrokeStyle(lineWidth: 1, dash: [3, 2]))
                    }
                Text(".background\n.padding")
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
    }
}
