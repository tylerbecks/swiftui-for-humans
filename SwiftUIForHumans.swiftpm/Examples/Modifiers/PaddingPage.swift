import SwiftUI

extension ComponentPage {
    static let padding = ComponentPage(
        id: "padding",
        title: "padding",
        summary: "Adds space around a view, on every edge or only the edges you pick.",
        category: .modifiers,
        kind: .modifier,
        symbol: "square.dashed",
        availability: ["iOS 13.0+", "macOS 10.15+", "visionOS 1.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/view/padding(_:_:)",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/layout",
        aliases: ["margin", "spacing", "inset", "gutter", "padding-left", "EdgeInsets", "whitespace", "layoutMargins"],
        related: ["modifier-order", "frame", "background-overlay", "spacer-divider"],
        notes: [
            "**SwiftUI has no `margin`.** Padding outside a `.background` acts like a margin, and padding inside it acts like CSS padding. See [Modifier Order](catalog://modifier-order).",
            "**Use `leading` and `trailing`, not left and right.** They flip automatically in right-to-left languages like Arabic and Hebrew.",
        ],
        api: [
            APIItem("`.padding()`", "The system default amount on every edge."),
            APIItem("`.padding(_:)`", "A fixed amount in points on every edge."),
            APIItem("`.padding(_:_:)`", "Pick edges, like `.horizontal` or `[.top, .leading]`, and an amount."),
            APIItem("`EdgeInsets`", "A different amount on each of the four edges."),
            APIItem("`.contentMargins(_:for:)`", "Insets the content of a `ScrollView` or `List`."),
        ],
        guidelines: [
            Guideline(
                "Give content room to breathe.",
                "Text pressed against the edge of its card looks cramped and is harder to scan. The default `.padding()` matches the margins people see across iOS.",
                good: "Default padding inside the card.",
                bad: "Text touches the card's edges."
            ) {
                PaddingCardSample(padding: nil)
            } bad: {
                PaddingCardSample(padding: 0)
            },
            Guideline(
                "Use space to group related items.",
                "Keep related items close and put more space between groups, so people see the structure without extra dividers.",
                good: "Tight inside a group, wider between.",
                bad: "Even spacing hides the groups."
            ) {
                PaddingGroupSample(inner: 2, between: 16)
            } bad: {
                PaddingGroupSample(inner: 9, between: 9)
            },
            Guideline(
                "Keep padding consistent across a screen.",
                "Cards and rows with the same insets line up and look like one design. Pick a few values and reuse them."
            ),
        ]
    ) {
        Text("Padding")
            .font(.headline)
            .padding(.horizontal, 6)
            .background(.blue.opacity(0.35), in: .rect(cornerRadius: 4))
            .padding(22)
            .background(.blue.opacity(0.12), in: .rect(cornerRadius: 12))
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(.blue.opacity(0.6), style: StrokeStyle(lineWidth: 1.5, dash: [5, 4]))
            }
    } content: { page in
        PaddingDemo(page: page)
    }
}

private struct PaddingConfig {
    var edges: PaddingEdges = .all
    var useDefault = false
    var amount = 24.0
    var showContent = true
}

private enum PaddingEdges: DemoOption {
    case all, horizontal, vertical, top, leading, bottom, trailing

    var label: String {
        switch self {
        case .all: "All"
        case .horizontal: ".horizontal"
        case .vertical: ".vertical"
        case .top: ".top"
        case .leading: ".leading"
        case .bottom: ".bottom"
        case .trailing: ".trailing"
        }
    }

    var set: Edge.Set {
        switch self {
        case .all: .all
        case .horizontal: .horizontal
        case .vertical: .vertical
        case .top: .top
        case .leading: .leading
        case .bottom: .bottom
        case .trailing: .trailing
        }
    }
}

private struct PaddingDemo: View {
    let page: ComponentPage

    var body: some View {
        DemoPage(
            page: page,
            initial: PaddingConfig(),
            usage: """
            Text("Weekly summary")
                .padding()
                .background(.fill.tertiary, in: .rect(cornerRadius: 12))
            """,
            usageNote: Aside(.note, "`.padding()` with no number uses the system default, usually 16pt on iPhone. Prefer it to a hard-coded value so spacing matches the platform.")
        ) { $config in
            VStack(spacing: 16) {
                Text("Hello, padding")
                    .font(.title3.weight(.semibold))
                    .background(config.showContent ? Color.yellow.opacity(0.5) : .clear)
                    .padding(config.edges.set, config.useDefault ? nil : config.amount)
                    .background(.blue.opacity(0.2))
                    .animation(.snappy, value: config.amount)
                    .animation(.snappy, value: config.edges)
                    .animation(.snappy, value: config.useDefault)

                HStack(spacing: 14) {
                    if config.showContent {
                        legend(.yellow.opacity(0.5), "Text")
                    }
                    legend(.blue.opacity(0.2), "Padding")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
        } controls: { $config in
            Section("Padding") {
                OptionPicker("Edges", selection: $config.edges)
                Toggle("System default amount", isOn: $config.useDefault)
                if !config.useDefault {
                    ValueSlider("Amount", value: $config.amount, in: 0...60, step: 1)
                }
            }
            Section("Visualize") {
                Toggle("Highlight the text", isOn: $config.showContent)
            }
        } code: { config in
            var lines = ["Text(\"Hello, padding\")", "    .font(.title3.weight(.semibold))"]
            if config.showContent {
                lines.append("    .background(.yellow.opacity(0.5))")
            }
            let amount = swiftNumber(config.amount)
            switch (config.edges, config.useDefault) {
            case (.all, true): lines.append("    .padding()")
            case (.all, false): lines.append("    .padding(\(amount))")
            case (let edges, true): lines.append("    .padding(\(edges.label))")
            case (let edges, false): lines.append("    .padding(\(edges.label), \(amount))")
            }
            lines.append("    .background(.blue.opacity(0.2))")
            return lines.joined(separator: "\n")
        } examples: {
            ExampleCard(
                title: "Card content",
                caption: "Put `.padding()` before `.background` so the card's color fills the space around its content.",
                code: """
                VStack(alignment: .leading, spacing: 4) {
                    Text("Weekly summary")
                        .font(.headline)
                    Text("You walked 42 km this week.")
                        .foregroundStyle(.secondary)
                }
                .padding()
                .background(.fill.tertiary, in: .rect(cornerRadius: 16))
                """
            ) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Weekly summary")
                        .font(.headline)
                    Text("You walked 42 km this week.")
                        .foregroundStyle(.secondary)
                }
                .padding()
                .background(.fill.tertiary, in: .rect(cornerRadius: 16))
            }

            ExampleCard(
                title: "Pill with different edges",
                caption: "Chain `.padding(.horizontal, _:)` and `.padding(.vertical, _:)` for a wide tag or chip.",
                code: """
                Text("Design")
                    .font(.subheadline.weight(.medium))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(.blue.opacity(0.15), in: .capsule)
                """
            ) {
                HStack(spacing: 8) {
                    ForEach(["Design", "SwiftUI", "iOS 26"], id: \.self) { tag in
                        Text(tag)
                            .font(.subheadline.weight(.medium))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 6)
                            .background(.blue.opacity(0.15), in: .capsule)
                    }
                }
            }

            ExampleCard(
                title: "Different amount on each edge",
                caption: "Pass `EdgeInsets` to set all four edges in one call, like CSS `padding: 8px 24px 20px 12px`.",
                code: """
                Text("Custom insets")
                    .padding(EdgeInsets(top: 8, leading: 12, bottom: 20, trailing: 24))
                    .background(.orange.opacity(0.25))
                """
            ) {
                Text("Custom insets")
                    .padding(EdgeInsets(top: 8, leading: 12, bottom: 20, trailing: 24))
                    .background(.orange.opacity(0.25))
            }
        }
    }

    private func legend(_ color: Color, _ title: String) -> some View {
        HStack(spacing: 5) {
            RoundedRectangle(cornerRadius: 3)
                .fill(color)
                .frame(width: 12, height: 12)
            Text(title)
        }
    }
}

// MARK: - Guideline samples

private struct PaddingCardSample: View {
    let padding: CGFloat?

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Weekly summary")
                .font(.headline)
            Text("You walked 42 km.")
                .foregroundStyle(.secondary)
        }
        .frame(width: 180, alignment: .leading)
        .padding(.all, padding)
        .background(.fill.tertiary, in: .rect(cornerRadius: 14))
    }
}

private struct PaddingGroupSample: View {
    let inner: CGFloat
    let between: CGFloat

    var body: some View {
        VStack(alignment: .leading, spacing: between) {
            VStack(alignment: .leading, spacing: inner) {
                Text("Anna Lee").font(.headline)
                Text("Product Designer").foregroundStyle(.secondary)
            }
            VStack(alignment: .leading, spacing: inner) {
                Text("Email").font(.headline)
                Text("anna@example.com").foregroundStyle(.secondary)
            }
        }
        .font(.subheadline)
        .frame(width: 200, alignment: .leading)
    }
}
