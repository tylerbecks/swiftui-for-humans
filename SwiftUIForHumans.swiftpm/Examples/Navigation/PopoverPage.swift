import SwiftUI

extension ComponentPage {
    static let popover = ComponentPage(
        id: "popover",
        title: "Popover",
        summary: "Shows extra content in a bubble that points at the button that opened it.",
        category: .presentation,
        symbol: "bubble.middle.top",
        availability: ["iOS 13.0+", "macOS 10.15+", "visionOS 1.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/view/popover(ispresented:attachmentanchor:arrowedge:content:)",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/popovers",
        aliases: ["tooltip", "popup", "dropdown panel", "callout", "bubble", "UIPopoverPresentationController", "floating panel", "tippy"],
        related: ["sheet", "menu", "context-menu"],
        notes: [
            "**The popover hugs its content.** Size it yourself with `.padding` or `.frame(width:)`; long text needs a width to wrap.",
            "**For a list of commands, use a [Menu](catalog://menu).** A popover is for custom content, like a color grid or a short form.",
        ],
        api: [
            APIItem("`.popover(isPresented:)`", "Shows the bubble while a `Bool` is `true`."),
            APIItem("`.popover(item:)`", "Shows it for an optional `Identifiable` value."),
            APIItem("`.presentationCompactAdaptation(_:)`", "`.popover` keeps the bubble on iPhone."),
            APIItem("`arrowEdge:`", "Which side the arrow prefers to point from."),
        ],
        guidelines: [
            Guideline(
                "Keep popovers small.",
                "A popover is for a tip or a few options. If the content needs scrolling, use a sheet.",
                good: "A short tip that fits the bubble.",
                bad: "A whole article squeezed into a bubble."
            ) {
                PopoverGuidelineSample(isShort: true)
            } bad: {
                PopoverGuidelineSample(isShort: false)
            },
            Guideline(
                "Don't use a popover for warnings.",
                "People can miss it or tap it away. Use an [Alert](catalog://alert) for anything they must see."
            ),
            Guideline(
                "Show one popover at a time.",
                "Never open a popover from another popover. Close the first one before showing the next."
            ),
            Guideline(
                "Save changes when it closes.",
                "Tapping outside closes a popover, often by accident. Keep what people entered unless they tap Cancel."
            ),
        ]
    ) {
        PopoverThumbnail()
    } content: { page in
        PopoverDemo(page: page)
    }
}

private struct PopoverConfig {
    var adaptation: PopoverAdaptation = .popover
    var arrowEdge: PopoverEdge = .automatic
    var content: PopoverContentOption = .text
    var isPresented = false
    var rating = 3
}

private struct PopoverDemo: View {
    let page: ComponentPage

    var body: some View {
        DemoPage(
            page: page,
            initial: PopoverConfig(),
            previewHeight: 260,
            usage: """
            @State private var showTip = false

            Button("Info", systemImage: "info.circle") {
                showTip = true
            }
            .popover(isPresented: $showTip) {
                Text("Prices include tax.")
                    .padding()
                    .presentationCompactAdaptation(.popover)
            }
            """,
            usageNote: Aside(.important, "On iPhone a popover becomes a sheet by default. To keep the bubble, add `.presentationCompactAdaptation` inside the content, as here.")
        ) { $config in
            Button("Show Popover", systemImage: "info.circle") {
                config.isPresented = true
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
            .popover(isPresented: $config.isPresented, arrowEdge: config.arrowEdge.value) {
                PopoverBody(config: $config)
                    .presentationCompactAdaptation(config.adaptation.value)
            }
        } controls: { $config in
            Section("Content") {
                OptionPicker("Content", selection: $config.content)
            }
            Section {
                OptionPicker("On iPhone", selection: $config.adaptation)
                OptionPicker("Arrow edge", selection: $config.arrowEdge)
            } header: {
                Text("Presentation")
            } footer: {
                Text("The arrow edge is a preference. The system flips it when there isn't room.")
            }
        } code: { config in
            code(for: config)
        } examples: {
            PopoverExamples()
        }
    }

    private func code(for config: PopoverConfig) -> String {
        var lines = [
            "@State private var isPresented = false",
        ]
        if config.content == .rating {
            lines.append("@State private var rating = 3")
        }
        lines += [
            "",
            "Button(\"Show Popover\", systemImage: \"info.circle\") {",
            "    isPresented = true",
            "}",
            ".buttonStyle(.bordered)",
        ]
        let edge = config.arrowEdge == .automatic ? "" : ", arrowEdge: \(config.arrowEdge.label)"
        lines.append(".popover(isPresented: $isPresented\(edge)) {")
        switch config.content {
        case .text:
            lines += [
                "    Text(\"Popovers point at the control that opened them.\")",
                "        .padding()",
                "        .frame(width: 240)",
            ]
        case .rating:
            lines += [
                "    VStack(spacing: 12) {",
                "        Text(\"Rate this recipe\")",
                "            .font(.headline)",
                "        HStack {",
                "            ForEach(1...5, id: \\.self) { star in",
                "                Button(\"\\(star) stars\", systemImage: star <= rating ? \"star.fill\" : \"star\") {",
                "                    rating = star",
                "                }",
                "                .labelStyle(.iconOnly)",
                "                .foregroundStyle(.yellow)",
                "            }",
                "        }",
                "        .font(.title2)",
                "    }",
                "    .padding()",
            ]
        }
        if config.adaptation != .automatic {
            lines.append("    .presentationCompactAdaptation(\(config.adaptation.label))")
        }
        lines.append("}")
        return lines.joined(separator: "\n")
    }
}

private struct PopoverBody: View {
    @Binding var config: PopoverConfig

    var body: some View {
        switch config.content {
        case .text:
            Text("Popovers point at the control that opened them.")
                .padding()
                .frame(width: 240)
        case .rating:
            VStack(spacing: 12) {
                Text("Rate this recipe")
                    .font(.headline)
                HStack {
                    ForEach(1...5, id: \.self) { star in
                        Button("\(star) stars", systemImage: star <= config.rating ? "star.fill" : "star") {
                            config.rating = star
                        }
                        .labelStyle(.iconOnly)
                        .foregroundStyle(.yellow)
                    }
                }
                .font(.title2)
            }
            .padding()
        }
    }
}

private struct PopoverThumbnail: View {
    var body: some View {
        VStack(spacing: 0) {
            Text("Popovers point at the control that opened them.")
                .font(.footnote)
                .multilineTextAlignment(.center)
                .padding(12)
                .frame(width: 180)
                .glassEffect(.regular, in: .rect(cornerRadius: 18))
            PopoverArrow()
                .fill(.fill.secondary)
                .frame(width: 18, height: 9)
            Image(systemName: "info.circle")
                .font(.title2)
                .foregroundStyle(.tint)
                .padding(.top, 8)
        }
    }
}

private struct PopoverArrow: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: rect.minX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
            path.closeSubpath()
        }
    }
}

// MARK: - Examples

private struct PopoverExamples: View {
    @State private var showHelp = false
    @State private var showSort = false
    @State private var sort = "Date"

    var body: some View {
        ExampleCard(
            title: "Help next to a field",
            caption: "Put an info `Button` beside a label and keep its explanation in a small `.popover`.",
            code: """
            @State private var showHelp = false

            HStack {
                Text("Routing number")
                Button("What's this?", systemImage: "info.circle") {
                    showHelp = true
                }
                .labelStyle(.iconOnly)
                .popover(isPresented: $showHelp) {
                    Text("The 9-digit number at the bottom left of a check.")
                        .padding()
                        .frame(width: 240)
                        .presentationCompactAdaptation(.popover)
                }
            }
            """,
            minHeight: 200
        ) {
            HStack {
                Text("Routing number")
                Button("What's this?", systemImage: "info.circle") {
                    showHelp = true
                }
                .labelStyle(.iconOnly)
                .popover(isPresented: $showHelp) {
                    Text("The 9-digit number at the bottom left of a check.")
                        .padding()
                        .frame(width: 240)
                        .presentationCompactAdaptation(.popover)
                }
            }
        }

        ExampleCard(
            title: "Popover on iPad, sheet on iPhone",
            caption: "Leave out the adaptation for bigger content: `.popover` floats on iPad and becomes a sheet on iPhone.",
            code: """
            @State private var showSort = false
            @State private var sort = "Date"

            Button("Sort", systemImage: "arrow.up.arrow.down") {
                showSort = true
            }
            .popover(isPresented: $showSort) {
                Form {
                    Picker("Sort by", selection: $sort) {
                        ForEach(["Date", "Name", "Size"], id: \\.self) { Text($0) }
                    }
                    .pickerStyle(.inline)
                }
                .frame(minWidth: 280, minHeight: 220)
                .presentationDetents([.medium])
            }
            """,
            minHeight: 160,
            aside: Aside(.note, "`.presentationDetents` only applies when the popover turns into a sheet, so it's safe to add for iPhone.")
        ) {
            Button("Sort", systemImage: "arrow.up.arrow.down") {
                showSort = true
            }
            .buttonStyle(.bordered)
            .popover(isPresented: $showSort) {
                Form {
                    Picker("Sort by", selection: $sort) {
                        ForEach(["Date", "Name", "Size"], id: \.self) { Text($0) }
                    }
                    .pickerStyle(.inline)
                }
                .frame(minWidth: 280, minHeight: 220)
                .presentationDetents([.medium])
            }
        }
    }
}

/// An info button whose popover holds a short tip or far too much text.
private struct PopoverGuidelineSample: View {
    let isShort: Bool
    @State private var isPresented = false

    var body: some View {
        VStack(spacing: 10) {
            Button("Shipping", systemImage: "info.circle") { isPresented = true }
                .buttonStyle(.bordered)
                .popover(isPresented: $isPresented) {
                    Group {
                        if isShort {
                            Text("Free shipping on orders over $50.")
                        } else {
                            ScrollView {
                                Text("Free shipping applies to orders over $50 before tax. Orders ship within two business days. Express shipping is available at checkout for an extra fee. Some items ship separately. Shipping to Alaska and Hawaii may take longer. Returns are free within 30 days, but the original shipping cost isn't refunded. See our full policy for details.")
                            }
                        }
                    }
                    .padding()
                    .frame(width: 240, height: isShort ? nil : 260)
                    .presentationCompactAdaptation(.popover)
                }
            Text("Tap to see the popover")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Options

private enum PopoverAdaptation: DemoOption {
    case popover, automatic, sheet

    var label: String {
        switch self {
        case .popover: ".popover"
        case .automatic: ".automatic (sheet)"
        case .sheet: ".sheet"
        }
    }

    var value: PresentationAdaptation {
        switch self {
        case .popover: .popover
        case .automatic: .automatic
        case .sheet: .sheet
        }
    }
}

private enum PopoverEdge: DemoOption {
    case automatic, top, bottom, leading, trailing

    var label: String {
        switch self {
        case .automatic: "Automatic"
        case .top: ".top"
        case .bottom: ".bottom"
        case .leading: ".leading"
        case .trailing: ".trailing"
        }
    }

    var value: Edge? {
        switch self {
        case .automatic: nil
        case .top: .top
        case .bottom: .bottom
        case .leading: .leading
        case .trailing: .trailing
        }
    }
}

private enum PopoverContentOption: DemoOption {
    case text, rating

    var label: String {
        switch self {
        case .text: "Text"
        case .rating: "Star rating"
        }
    }
}