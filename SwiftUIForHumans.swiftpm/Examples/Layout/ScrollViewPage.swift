import SwiftUI

extension ComponentPage {
    static let scrollView = ComponentPage(
        id: "scroll-view",
        title: "ScrollView",
        summary: "Lets content that's bigger than the screen scroll, vertically or sideways.",
        category: .layout,
        symbol: "scroll",
        availability: ["iOS 13.0+", "macOS 10.15+", "visionOS 1.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/scrollview",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/scroll-views",
        aliases: ["overflow scroll", "overflow-x", "carousel", "swiper", "UIScrollView", "scroll snap", "paging", "scrollIntoView"],
        related: ["lazy-grids", "stacks", "geometry-reader", "list"],
        notes: [
            "**Snapping is CSS `scroll-snap`.** `.viewAligned` snaps to each view in a `.scrollTargetLayout()`; `.paging` snaps a whole screen at a time.",
            "**Pad the content, not the scroll view.** `.contentMargins` adds space that scrolls with the content, so cards can peek in from the edges. Plain `.padding` clips them.",
        ],
        about: """
        `ScrollView` shows content that's bigger than the space it has and lets people drag through it. It's as big as its parent offers, and its content is as long as it needs to be.

        Use it for custom layouts like cards, carousels, and feeds. For rows of data with swipe actions, selection, and separators, use a [List](catalog://list), which scrolls on its own.
        """,
        composition: """
        ScrollView(.horizontal)
        ├── LazyHStack
        │   ├── ForEach → cards
        │   └── .scrollTargetLayout()
        ├── .scrollTargetBehavior
        ├── .scrollPosition(id:)
        └── .contentMargins
        """,
        api: [
            APIItem("`ScrollView(_:)`", "Scrolls its content. Pass `.horizontal` to scroll sideways."),
            APIItem("`.scrollTargetBehavior(_:)`", "Snaps with `.viewAligned` or `.paging`."),
            APIItem("`.scrollTargetLayout()`", "Marks the stack whose children are snap and position targets."),
            APIItem("`.scrollPosition(id:)`", "Reads and sets which child is showing, like `scrollIntoView`."),
            APIItem("`.contentMargins(_:_:for:)`", "Insets the content without clipping it."),
            APIItem("`.scrollIndicators(_:)`", "Hides or shows the scroll bars."),
            APIItem("`.refreshable { }`", "Adds pull to refresh, running your `async` work."),
            APIItem("`.scrollTransition { }`", "Changes each child as it scrolls in and out."),
        ],
        guidelines: [
            Guideline(
                "Show that there's more to scroll.",
                "Scroll bars aren't always visible. Let the next card peek in from the edge so people know they can swipe.",
                good: "The next card peeks in.",
                bad: "One card fills the width; nothing hints at more."
            ) {
                SVPeekSample(peeks: true)
            } bad: {
                SVPeekSample(peeks: false)
            },
            Guideline(
                "Don't nest scroll views on the same axis.",
                "A vertical scroll view inside another vertical one is hard to control. A horizontal row inside a vertical feed is fine."
            ),
            Guideline(
                "Pair paging with a page indicator.",
                "When content scrolls a page at a time, show which page people are on, and hide the scroll bar on that axis so there aren't two indicators."
            ),
        ]
    ) {
        ScrollViewThumbnail()
    } content: { page in
        ScrollViewDemo(page: page)
    }
}

// MARK: - Shared

private let scrollColors: [Color] = [.blue, .purple, .pink, .orange, .teal, .indigo, .green, .red, .mint, .cyan]

private struct SVCard: View {
    let index: Int

    var body: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(scrollColors[index % scrollColors.count].gradient)
            .overlay {
                Text("\(index + 1)")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.white)
            }
    }
}

// MARK: - Thumbnail

private struct ScrollViewThumbnail: View {
    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                RoundedRectangle(cornerRadius: 12).fill(scrollColors[0].gradient).frame(width: 24)
                RoundedRectangle(cornerRadius: 12).fill(scrollColors[1].gradient).frame(width: 120)
                RoundedRectangle(cornerRadius: 12).fill(scrollColors[2].gradient).frame(width: 30)
            }
            .frame(height: 80)
            HStack(spacing: 6) {
                Circle().fill(.tertiary).frame(width: 6, height: 6)
                Circle().fill(.primary).frame(width: 6, height: 6)
                Circle().fill(.tertiary).frame(width: 6, height: 6)
            }
        }
        .frame(width: 188)
    }
}

// MARK: - Config

private struct ScrollConfig {
    var axis: SVAxis = .horizontal
    var behavior: SVBehavior = .viewAligned
    var showsIndicators = true
    var margins = true
    var trackPosition = true
    var position: Int? = 0
}

private enum SVAxis: DemoOption {
    case vertical, horizontal

    var label: String {
        switch self {
        case .vertical: ".vertical"
        case .horizontal: ".horizontal"
        }
    }
}

private enum SVBehavior: DemoOption {
    case none, viewAligned, paging

    var label: String {
        switch self {
        case .none: "Free"
        case .viewAligned: ".viewAligned"
        case .paging: ".paging"
        }
    }
}

// MARK: - Demo

private struct ScrollViewDemo: View {
    let page: ComponentPage

    var body: some View {
        DemoPage(
            page: page,
            initial: ScrollConfig(),
            previewHeight: 300,
            usage: """
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(1...100, id: \\.self) { i in
                        Text("Row \\(i)")
                    }
                }
                .padding()
            }
            """,
            usageNote: Aside(.note, "A plain `VStack` inside builds every row up front. Use `LazyVStack` or `LazyHStack` for long content so rows are created as they scroll in.")
        ) { $config in
            VStack(spacing: 14) {
                ScrollPreview(config: $config)
                    .id("\(config.axis)-\(config.behavior)-\(config.margins)")
                    .frame(height: 200)

                if config.trackPosition {
                    HStack {
                        Button("Previous", systemImage: "chevron.left") {
                            withAnimation { config.position = max((config.position ?? 0) - 1, 0) }
                        }
                        .labelStyle(.iconOnly)
                        .disabled((config.position ?? 0) == 0)
                        Text("Showing card \((config.position ?? 0) + 1) of 10")
                            .font(.footnote.monospacedDigit())
                            .foregroundStyle(.secondary)
                            .frame(minWidth: 160)
                        Button("Next", systemImage: "chevron.right") {
                            withAnimation { config.position = min((config.position ?? 0) + 1, 9) }
                        }
                        .labelStyle(.iconOnly)
                        .disabled((config.position ?? 0) == 9)
                    }
                    .buttonStyle(.bordered)
                    .buttonBorderShape(.circle)
                }
            }
        } controls: { $config in
            Section("Scrolling") {
                Picker("Axis", selection: $config.axis) {
                    ForEach(SVAxis.allCases) { Text($0.label).tag($0) }
                }
                .pickerStyle(.segmented)
                Picker("Snapping", selection: $config.behavior) {
                    ForEach(SVBehavior.allCases) { Text($0.label).tag($0) }
                }
                .pickerStyle(.segmented)
                Toggle("Show indicators", isOn: $config.showsIndicators)
                Toggle("Content margins", isOn: $config.margins)
            }
            Section("Position") {
                Toggle("Track scrollPosition", isOn: $config.trackPosition)
            }
        } code: { config in
            scrollCode(config)
        } examples: {
            ExampleCard(
                title: "Carousel with peeking cards",
                caption: "Cards 85% of the width snap with `.viewAligned`, and `.scrollTransition` fades them as they leave.",
                code: """
                ScrollView(.horizontal) {
                    LazyHStack(spacing: 12) {
                        ForEach(0..<8, id: \\.self) { i in
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(hue: Double(i) / 8, saturation: 0.6, brightness: 0.9).gradient)
                                .containerRelativeFrame(.horizontal) { width, _ in width * 0.85 }
                                .scrollTransition { content, phase in
                                    content
                                        .scaleEffect(phase.isIdentity ? 1 : 0.9)
                                        .opacity(phase.isIdentity ? 1 : 0.6)
                                }
                        }
                    }
                    .scrollTargetLayout()
                }
                .scrollTargetBehavior(.viewAligned)
                .contentMargins(.horizontal, 20, for: .scrollContent)
                .scrollIndicators(.hidden)
                .frame(height: 180)
                """,
                aside: Aside(.important, "Put `.scrollTargetLayout()` on the stack that holds the cards. On a wrapper around it, snapping can't find the cards.")
            ) {
                ScrollView(.horizontal) {
                    LazyHStack(spacing: 12) {
                        ForEach(0..<8, id: \.self) { i in
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(hue: Double(i) / 8, saturation: 0.6, brightness: 0.9).gradient)
                                .containerRelativeFrame(.horizontal) { width, _ in width * 0.85 }
                                .scrollTransition { content, phase in
                                    content
                                        .scaleEffect(phase.isIdentity ? 1 : 0.9)
                                        .opacity(phase.isIdentity ? 1 : 0.6)
                                }
                        }
                    }
                    .scrollTargetLayout()
                }
                .scrollTargetBehavior(.viewAligned)
                .contentMargins(.horizontal, 20, for: .scrollContent)
                .scrollIndicators(.hidden)
                .frame(height: 180)
            }

            ExampleCard(
                title: "Scroll to top",
                caption: "Bind `.scrollPosition(id:)` to an optional ID, then set it in `withAnimation` to scroll there.",
                code: """
                @State private var position: Int?

                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 12) {
                        ForEach(0..<40, id: \\.self) { i in
                            Text("Row \\(i + 1)")
                        }
                    }
                    .scrollTargetLayout()
                }
                .scrollPosition(id: $position)
                .frame(height: 200)
                .overlay(alignment: .bottomTrailing) {
                    Button("Top", systemImage: "arrow.up") {
                        withAnimation { position = 0 }
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(8)
                }
                """,
                aside: Aside(.note, "The IDs come from the `ForEach`. `.scrollTargetLayout()` on the stack is what lets the scroll view see them.")
            ) {
                ScrollToTopDemo()
            }

            ExampleCard(
                title: "Pull to refresh",
                caption: "Add `.refreshable` for the system pull-to-refresh spinner, which stays until your `async` work finishes.",
                code: """
                @State private var refreshes = 0

                ScrollView {
                    VStack(spacing: 12) {
                        Text("Pull down to refresh")
                        Text("Refreshed \\(refreshes) times")
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 40)
                }
                .refreshable {
                    try? await Task.sleep(for: .seconds(1))
                    refreshes += 1
                }
                .frame(height: 200)
                """
            ) {
                RefreshDemo()
            }
        }
    }

    private func scrollCode(_ config: ScrollConfig) -> String {
        let horizontal = config.axis == .horizontal
        var lines: [String] = []
        if config.trackPosition {
            lines += ["@State private var position: Int? = 0", ""]
        }
        lines.append(horizontal ? "ScrollView(.horizontal) {" : "ScrollView {")
        let spacing = config.behavior == .paging ? 0 : 12
        lines.append(horizontal ? "    LazyHStack(spacing: \(spacing)) {" : "    LazyVStack(spacing: \(spacing)) {")
        lines.append("        ForEach(0..<10, id: \\.self) { i in")
        lines.append("            RoundedRectangle(cornerRadius: 16)")
        lines.append("                .fill(.blue.gradient)")
        lines.append("                .overlay { Text(\"\\(i + 1)\").foregroundStyle(.white) }")
        if config.behavior == .paging {
            lines.append("                .containerRelativeFrame(\(horizontal ? ".horizontal" : ".vertical"))")
        } else {
            lines.append(horizontal ? "                .frame(width: 160)" : "                .frame(height: 120)")
        }
        lines.append("        }")
        lines.append("    }")
        if config.behavior == .viewAligned || config.trackPosition {
            lines.append("    .scrollTargetLayout()")
        }
        lines.append("}")
        switch config.behavior {
        case .none: break
        case .viewAligned: lines.append(".scrollTargetBehavior(.viewAligned)")
        case .paging: lines.append(".scrollTargetBehavior(.paging)")
        }
        if config.trackPosition { lines.append(".scrollPosition(id: $position, anchor: .center)") }
        if !config.showsIndicators { lines.append(".scrollIndicators(.hidden)") }
        if config.margins && config.behavior != .paging {
            lines.append(".contentMargins(\(horizontal ? ".horizontal" : ".vertical"), 20, for: .scrollContent)")
        }
        lines.append(".frame(height: 200)")
        return lines.joined(separator: "\n")
    }
}

/// The live, configurable scroll view in the demo.
private struct ScrollPreview: View {
    @Binding var config: ScrollConfig

    var body: some View {
        let horizontal = config.axis == .horizontal
        // Pages must be exactly one container wide, so paging uses no spacing.
        let spacing: CGFloat = config.behavior == .paging ? 0 : 12
        ScrollView(horizontal ? .horizontal : .vertical) {
            // scrollTargetLayout must sit on the stack itself, not on a
            // wrapper, or snapping and scrollPosition can't see the cards.
            if horizontal {
                LazyHStack(spacing: spacing) { cards }
                    .scrollTargetLayout()
            } else {
                LazyVStack(spacing: spacing) { cards }
                    .scrollTargetLayout()
            }
        }
        .modifier(SnapModifier(behavior: config.behavior))
        .scrollPosition(id: $config.position, anchor: .center)
        .scrollIndicators(config.showsIndicators ? .automatic : .hidden)
        .contentMargins(horizontal ? .horizontal : .vertical, config.margins && config.behavior != .paging ? 20 : 0, for: .scrollContent)
        .background(.fill.quaternary, in: .rect(cornerRadius: 12))
        .clipShape(.rect(cornerRadius: 12))
    }

    private var cards: some View {
        ForEach(0..<10, id: \.self) { i in
            SVCard(index: i)
                .modifier(CardSize(axis: config.axis, paging: config.behavior == .paging))
        }
    }
}

private struct CardSize: ViewModifier {
    let axis: SVAxis
    let paging: Bool

    func body(content: Content) -> some View {
        if paging {
            content.containerRelativeFrame(axis == .horizontal ? .horizontal : .vertical)
        } else if axis == .horizontal {
            content.frame(width: 160)
        } else {
            content.frame(height: 120)
        }
    }
}

private struct SnapModifier: ViewModifier {
    let behavior: SVBehavior

    func body(content: Content) -> some View {
        switch behavior {
        case .none: content
        case .viewAligned: content.scrollTargetBehavior(.viewAligned)
        case .paging: content.scrollTargetBehavior(.paging)
        }
    }
}

private struct ScrollToTopDemo: View {
    @State private var position: Int?

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 12) {
                ForEach(0..<40, id: \.self) { i in
                    Text("Row \(i + 1)")
                }
            }
            .scrollTargetLayout()
        }
        .scrollPosition(id: $position)
        .frame(height: 200)
        .overlay(alignment: .bottomTrailing) {
            Button("Top", systemImage: "arrow.up") {
                withAnimation { position = 0 }
            }
            .buttonStyle(.borderedProminent)
            .padding(8)
        }
    }
}

private struct RefreshDemo: View {
    @State private var refreshes = 0

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                Text("Pull down to refresh")
                Text("Refreshed \(refreshes) times")
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 40)
        }
        .refreshable {
            try? await Task.sleep(for: .seconds(1))
            refreshes += 1
        }
        .frame(height: 200)
    }
}

// MARK: - Guideline samples

/// A horizontal row of cards, with or without the next one peeking in.
private struct SVPeekSample: View {
    let peeks: Bool

    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 10) {
                ForEach(0..<5, id: \.self) { i in
                    SVCard(index: i)
                        .containerRelativeFrame(.horizontal) { width, _ in
                            peeks ? width * 0.8 : width
                        }
                }
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.viewAligned)
        .scrollIndicators(.hidden)
        .contentMargins(.horizontal, peeks ? 16 : 0, for: .scrollContent)
        .frame(width: 240, height: 110)
    }
}
