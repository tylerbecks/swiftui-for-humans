import SwiftUI

extension ComponentPage {
    static let scrollView = ComponentPage(
        id: "scroll-view",
        title: "ScrollView",
        summary: "Scrolls content that's bigger than its frame, in one direction or both.",
        category: .layout,
        symbol: "scroll",
        availability: ["macOS 10.15+", "ScrollPosition macOS 15.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/scrollview",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/scroll-views",
        aliases: [
            "scroll", "scroll bar", "scrollbar", "NSScrollView", "overflow: auto", "overflow", "scrollIndicators",
            "scrollPosition", "ScrollPosition", "contentMargins", "defaultScrollAnchor", "ScrollViewReader",
            "scrollTo", "canvas", "horizontal scroll",
        ],
        related: ["list-styles", "table", "stacks-grid"],
        notes: [
            "**On the Mac, scroll bars follow the person's settings.** Whether they always show or appear only while scrolling depends on the Show scroll bars setting and on whether a mouse is connected, not just on your code.",
            "**Lists, tables, forms, and text editors already scroll.** Don't wrap them in a `ScrollView`; give them a frame instead.",
        ],
        api: [
            APIItem("`ScrollView(_:)`", "Scrolls `.vertical`, `.horizontal`, or both."),
            APIItem("`.scrollIndicators(_:axes:)`", "Asks to show or hide the scroll bars."),
            APIItem("`.scrollPosition(_:anchor:)`", "Reads and sets where it's scrolled."),
            APIItem("`.scrollTargetLayout()`", "Marks the views `scrollPosition` tracks."),
            APIItem("`.defaultScrollAnchor(_:)`", "Where it starts, like `.center` or `.bottom`."),
            APIItem("`.contentMargins(_:_:for:)`", "Insets the content or the scroll bars."),
        ],
        guidelines: [
            Guideline(
                "Show that there's more to scroll.",
                "Scroll bars aren't always visible on the Mac. Let the last item peek in at the edge so people can see the row continues.",
                good: "A cut-off card hints at more.",
                bad: "The cards end exactly at the edge."
            ) {
                ShelfSample(cardWidth: 74)
            } bad: {
                ShelfSample(cardWidth: 82)
            },
            Guideline(
                "Don't put a scroll view inside one that scrolls the same way.",
                "Two vertical scroll views fight over every swipe. A horizontal row inside a vertical page is fine."
            ),
            Guideline(
                "Scroll for people only when it helps them find their place.",
                "Bring a search result or a new selection into view, and scroll only as far as it takes to show it."
            ),
            Guideline(
                "Keep the standard scrolling gestures and keys.",
                "People expect the gestures and keyboard shortcuts they scroll with everywhere else to work in your app too. If you build custom scrolling, keep the elastic bounce at the edges."
            ),
        ]
    ) {
        VStack(spacing: 5) {
            ForEach(0..<4) { index in
                RoundedRectangle(cornerRadius: 4)
                    .fill(.fill.secondary)
                    .frame(height: 16)
            }
        }
        .padding(8)
        .frame(width: 120, height: 80, alignment: .top)
        .overlay(alignment: .trailing) {
            Capsule()
                .fill(.secondary)
                .frame(width: 5, height: 28)
                .padding(.trailing, 3)
                .offset(y: -18)
        }
        .clipShape(.rect(cornerRadius: 8))
        .overlay(RoundedRectangle(cornerRadius: 8).strokeBorder(.separator))
    } content: { page in
        MacScrollViewDemo(page: page)
    }
}

// MARK: - Demo

private struct MacScrollViewConfig {
    var axes: ScrollAxesOption = .vertical
    var indicators: ScrollIndicatorsOption = .automatic
    var margins: ScrollMarginsOption = .none
}

private struct MacScrollViewDemo: View {
    let page: ComponentPage

    var body: some View {
        DemoPage(
            page: page,
            initial: MacScrollViewConfig(),
            usage: """
            ScrollView {
                VStack(alignment: .leading) {
                    ForEach(1...50, id: \\.self) { number in
                        Text("Row \\(number)")
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            }
            """,
            usageNote: Aside(.note, "A `ScrollView` takes all the space it's offered, like a `<div>` with `overflow: auto`. Give it a frame, or put it where its parent sets the size.")
        ) { $config in
            ScrollPreview(config: config)
        } controls: { $config in
            Section("Scrolling") {
                OptionPicker("Axes", selection: $config.axes)
                OptionPicker("Scroll bars", selection: $config.indicators)
                OptionPicker("Margins", selection: $config.margins)
            }
        } code: { config in
            var lines: [String] = []
            let open = config.axes == .vertical ? "ScrollView {" : "ScrollView(\(config.axes.label)) {"
            lines.append(open)
            switch config.axes {
            case .vertical:
                lines += [
                    "    VStack(alignment: .leading) {",
                    "        ForEach(1...50, id: \\.self) { Text(\"Row \\($0)\") }",
                    "    }",
                    "    .frame(maxWidth: .infinity, alignment: .leading)",
                    "    .padding(.horizontal, 12)",
                ]
            case .horizontal:
                lines += [
                    "    HStack {",
                    "        ForEach(1...20, id: \\.self) { number in",
                    "            RoundedRectangle(cornerRadius: 8).fill(.teal)",
                    "                .frame(width: 90, height: 120)",
                    "        }",
                    "    }",
                ]
            case .both:
                lines += [
                    "    Grid {",
                    "        ForEach(0..<12, id: \\.self) { row in",
                    "            GridRow {",
                    "                ForEach(0..<12, id: \\.self) { column in",
                    "                    Text(\"\\(row),\\(column)\")",
                    "                        .frame(width: 56, height: 36)",
                    "                }",
                    "            }",
                    "        }",
                    "    }",
                ]
            }
            lines.append("}")
            lines.append(".frame(width: 320, height: 200)")
            if config.indicators != .automatic {
                lines.append(".scrollIndicators(\(config.indicators.label))")
            }
            if let margin = config.margins.value {
                lines.append(".contentMargins(\(swiftNumber(margin)))")
            }
            return lines.joined(separator: "\n")
        } examples: {
            MacScrollViewExamples()
        }
    }
}

private struct ScrollPreview: View {
    let config: MacScrollViewConfig

    var body: some View {
        Group {
            switch config.axes {
            case .vertical:
                ScrollView {
                    VStack(alignment: .leading) {
                        ForEach(1...50, id: \.self) { Text("Row \($0)") }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 12)
                }
            case .horizontal:
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(1...20, id: \.self) { number in
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.teal.gradient)
                                .frame(width: 90, height: 120)
                                .overlay { Text("\(number)").font(.title2.bold()).foregroundStyle(.white) }
                        }
                    }
                }
            case .both:
                ScrollView([.horizontal, .vertical]) {
                    Grid {
                        ForEach(0..<12, id: \.self) { row in
                            GridRow {
                                ForEach(0..<12, id: \.self) { column in
                                    Text("\(row),\(column)")
                                        .font(.caption.monospacedDigit())
                                        .frame(width: 56, height: 36)
                                        .background(.fill.tertiary, in: .rect(cornerRadius: 6))
                                }
                            }
                        }
                    }
                }
            }
        }
        .scrollIndicators(config.indicators.visibility)
        .contentMargins(config.margins.value.map { CGFloat($0) } ?? 0)
        .frame(width: 320, height: 200)
        .background(.background)
        .overlay(RoundedRectangle(cornerRadius: 6).strokeBorder(.separator))
        .id(config.axes)
    }
}

// MARK: - Examples

private struct Message: Identifiable {
    let id: Int
    var text: String { "Message \(id)" }
}

private struct MacScrollViewExamples: View {
    @State private var position = ScrollPosition(idType: Int.self)
    private let messages = (1...100).map(Message.init)

    var body: some View {
        ExampleCard(
            title: "Jump to a row with scrollPosition",
            caption: "Bind `.scrollPosition` to a `ScrollPosition` to scroll from code and to read which row is at the top.",
            code: """
            struct Message: Identifiable {
                let id: Int
                var text: String { "Message \\(id)" }
            }

            @State private var position = ScrollPosition(idType: Int.self)
            private let messages = (1...100).map(Message.init)

            VStack {
                ScrollView {
                    LazyVStack(alignment: .leading) {
                        ForEach(messages) { Text($0.text) }
                    }
                    .scrollTargetLayout()
                }
                .scrollPosition($position)
                .frame(height: 140)

                HStack {
                    Button("Top") { position.scrollTo(edge: .top) }
                    Button("Message 50") { position.scrollTo(id: 50) }
                    Button("Bottom") { position.scrollTo(edge: .bottom) }
                }
            }
            """,
            minHeight: 230
        ) {
            VStack(spacing: 12) {
                ScrollView {
                    LazyVStack(alignment: .leading) {
                        ForEach(messages) { Text($0.text) }
                    }
                    .scrollTargetLayout()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 10)
                }
                .scrollPosition($position)
                .frame(width: 300, height: 140)
                .background(.background)
                .overlay(RoundedRectangle(cornerRadius: 6).strokeBorder(.separator))

                HStack {
                    Button("Top") { withAnimation { position.scrollTo(edge: .top) } }
                    Button("Message 50") { withAnimation { position.scrollTo(id: 50) } }
                    Button("Bottom") { withAnimation { position.scrollTo(edge: .bottom) } }
                }
                Text(position.viewID(type: Int.self).map { "Top row: Message \($0)" } ?? "Top row: Message 1")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
        }

        ExampleCard(
            title: "Start in the middle of a canvas",
            caption: "Scroll in both directions with `[.horizontal, .vertical]`, and start centered with `.defaultScrollAnchor(.center)`.",
            code: """
            ScrollView([.horizontal, .vertical]) {
                Circle()
                    .fill(.orange.gradient)
                    .frame(width: 120, height: 120)
                    .frame(width: 900, height: 700)
                    .background(.fill.tertiary)
            }
            .defaultScrollAnchor(.center)
            .frame(width: 320, height: 200)
            """,
            minHeight: 240
        ) {
            ScrollView([.horizontal, .vertical]) {
                Circle()
                    .fill(.orange.gradient)
                    .frame(width: 120, height: 120)
                    .frame(width: 900, height: 700)
                    .background(.fill.tertiary)
            }
            .defaultScrollAnchor(.center)
            .frame(width: 320, height: 200)
            .overlay(RoundedRectangle(cornerRadius: 6).strokeBorder(.separator))
        }

        ExampleCard(
            title: "A horizontal row with room at the edges",
            caption: "Use `.contentMargins` with `for: .scrollContent` to inset the first and last cards without clipping them while they scroll.",
            code: """
            ScrollView(.horizontal) {
                HStack {
                    ForEach(1...12, id: \\.self) { number in
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.indigo.gradient)
                            .frame(width: 120, height: 90)
                    }
                }
            }
            .contentMargins(.horizontal, 20, for: .scrollContent)
            .scrollIndicators(.hidden)
            """,
            minHeight: 160,
            aside: Aside(.important, "`.hidden` is only a preference: with a mouse connected, the Mac still shows scroll bars. Use `.never` to hide them for good, and make sure people can still scroll another way.")
        ) {
            ScrollView(.horizontal) {
                HStack {
                    ForEach(1...12, id: \.self) { number in
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.indigo.gradient)
                            .frame(width: 120, height: 90)
                            .overlay { Text("\(number)").font(.title2.bold()).foregroundStyle(.white) }
                    }
                }
            }
            .contentMargins(.horizontal, 20, for: .scrollContent)
            .scrollIndicators(.hidden)
            .frame(maxWidth: 480)
        }

        ExampleCard(
            title: "Keep scroll bars inside rounded corners",
            caption: "After `.clipShape`, add `.contentMargins` with `for: .scrollIndicators` so the rounded corners don't cut off the scroll bar.",
            code: """
            ScrollView {
                VStack(alignment: .leading) {
                    ForEach(1...40, id: \\.self) { Text("Item \\($0)") }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            }
            .background(.fill.tertiary)
            .clipShape(.rect(cornerRadius: 20))
            .contentMargins(10, for: .scrollIndicators)
            .frame(width: 260, height: 180)
            """,
            minHeight: 220
        ) {
            ScrollView {
                VStack(alignment: .leading) {
                    ForEach(1...40, id: \.self) { Text("Item \($0)") }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            }
            .background(.fill.tertiary)
            .clipShape(.rect(cornerRadius: 20))
            .contentMargins(10, for: .scrollIndicators)
            .frame(width: 260, height: 180)
        }
    }
}

/// A horizontal row of cards for the "show there's more" guideline.
private struct ShelfSample: View {
    let cardWidth: CGFloat

    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 8) {
                ForEach(0..<8) { index in
                    RoundedRectangle(cornerRadius: 8)
                        .fill(index.isMultiple(of: 2) ? Color.teal.gradient : Color.indigo.gradient)
                        .frame(width: cardWidth, height: 70)
                }
            }
        }
        .scrollIndicators(.never)
        .frame(width: 262)
    }
}

// MARK: - Options

private enum ScrollAxesOption: DemoOption {
    case vertical, horizontal, both

    var label: String {
        switch self {
        case .vertical: ".vertical"
        case .horizontal: ".horizontal"
        case .both: "[.horizontal, .vertical]"
        }
    }
}

private enum ScrollIndicatorsOption: DemoOption {
    case automatic, visible, hidden, never

    var label: String {
        switch self {
        case .automatic: ".automatic"
        case .visible: ".visible"
        case .hidden: ".hidden"
        case .never: ".never"
        }
    }

    var visibility: ScrollIndicatorVisibility {
        switch self {
        case .automatic: .automatic
        case .visible: .visible
        case .hidden: .hidden
        case .never: .never
        }
    }
}

private enum ScrollMarginsOption: DemoOption {
    case none, small, large

    var label: String {
        switch self {
        case .none: "None"
        case .small: "12"
        case .large: "24"
        }
    }

    var value: Double? {
        switch self {
        case .none: nil
        case .small: 12
        case .large: 24
        }
    }
}
