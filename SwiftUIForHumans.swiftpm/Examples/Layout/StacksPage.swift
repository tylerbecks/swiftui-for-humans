import SwiftUI

extension ComponentPage {
    static let stacks = ComponentPage(
        id: "stacks",
        title: "Stacks",
        summary: "Arrange views in a column, a row, or layered on top of each other.",
        category: .layout,
        symbol: "square.stack",
        availability: ["iOS 13.0+", "macOS 10.15+", "visionOS 1.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/building-layouts-with-stack-views",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/layout",
        aliases: ["flexbox", "flex-direction", "row", "column", "div", "UIStackView", "z-index", "position absolute", "gap", "align-items"],
        related: ["layout-basics", "spacer-divider", "grid", "lazy-grids"],
        notes: [
            "**Leave out `spacing` to get the system default.** SwiftUI picks spacing that suits the views and platform. Pass `0` only when children should touch.",
            "**`alignment` works across the stack's axis.** A `VStack` takes a horizontal alignment like `.leading`; an `HStack` takes a vertical one like `.top`.",
            "**Stacks are like flexbox with `flex-direction`.** `VStack` is a column, `HStack` a row, and `spacing` is `gap`. There's no wrapping; use [Lazy Grids](catalog://lazy-grids) or [ViewThatFits](catalog://view-that-fits) instead.",
        ],
        api: [
            APIItem("`VStack(alignment:spacing:)`", "A column. Alignment is `.leading`, `.center`, or `.trailing`."),
            APIItem("`HStack(alignment:spacing:)`", "A row. Alignment is `.top`, `.center`, `.bottom`, or a baseline."),
            APIItem("`ZStack(alignment:)`", "Layers children; later ones draw on top."),
            APIItem("`LazyVStack` / `LazyHStack`", "Create children only as they scroll on screen."),
            APIItem("`.frame(maxWidth: .infinity)`", "Stretches a stack to fill the width, like `width: 100%`."),
            APIItem("`.overlay(alignment:)`", "Puts one view on top of another, sized to the base view."),
        ],
        guidelines: [
            Guideline(
                "Line related text up on one edge.",
                "A shared leading edge is easy to scan. Centered text of different lengths makes the eye jump around.",
                good: "`VStack(alignment: .leading)` gives one clean edge.",
                bad: "Centered lines of different lengths look ragged."
            ) {
                StackAlignSample(alignment: .leading)
            } bad: {
                StackAlignSample(alignment: .center)
            },
            Guideline(
                "Use space to show what belongs together.",
                "Keep related items close and put more room between groups, so people see the structure without lines or boxes.",
                good: "Tight spacing inside a group, more between groups.",
                bad: "Even spacing hides which lines belong together."
            ) {
                StackGroupSample(grouped: true)
            } bad: {
                StackGroupSample(grouped: false)
            },
            Guideline(
                "Leave room for larger text.",
                "People can make text much bigger with Dynamic Type. Let rows grow taller, and switch an `HStack` to a `VStack` when it no longer fits."
            ),
        ]
    ) {
        StacksThumbnail()
    } content: { page in
        StacksDemo(page: page)
    }
}

// MARK: - Thumbnail

private struct StacksThumbnail: View {
    var body: some View {
        HStack(alignment: .top, spacing: 18) {
            VStack(spacing: 6) {
                ForEach(0..<3, id: \.self) { i in
                    RoundedRectangle(cornerRadius: 5)
                        .fill(StackItem.colors[i].gradient)
                        .frame(width: 44, height: 22)
                }
            }
            HStack(spacing: 6) {
                ForEach(0..<3, id: \.self) { i in
                    RoundedRectangle(cornerRadius: 5)
                        .fill(StackItem.colors[i].gradient)
                        .frame(width: 18, height: 78)
                }
            }
            ZStack {
                ForEach(0..<3, id: \.self) { i in
                    RoundedRectangle(cornerRadius: 6)
                        .fill(StackItem.colors[i].gradient)
                        .frame(width: 60 - CGFloat(i) * 16, height: 78 - CGFloat(i) * 22)
                }
            }
        }
    }
}

// MARK: - Config

private struct StacksConfig {
    var kind: StackKind = .vStack
    var horizontal: HAlignOption = .center
    var vertical: VAlignOption = .center
    var useDefaultSpacing = false
    var spacing: Double = 12
}

private enum StackKind: DemoOption {
    case vStack, hStack, zStack

    var label: String {
        switch self {
        case .vStack: "VStack"
        case .hStack: "HStack"
        case .zStack: "ZStack"
        }
    }
}

private enum HAlignOption: DemoOption {
    case leading, center, trailing

    var label: String {
        switch self {
        case .leading: ".leading"
        case .center: ".center"
        case .trailing: ".trailing"
        }
    }

    var value: HorizontalAlignment {
        switch self {
        case .leading: .leading
        case .center: .center
        case .trailing: .trailing
        }
    }
}

private enum VAlignOption: DemoOption {
    case top, center, bottom, firstTextBaseline

    var label: String {
        switch self {
        case .top: ".top"
        case .center: ".center"
        case .bottom: ".bottom"
        case .firstTextBaseline: ".firstTextBaseline"
        }
    }

    var value: VerticalAlignment {
        switch self {
        case .top: .top
        case .center: .center
        case .bottom: .bottom
        case .firstTextBaseline: .firstTextBaseline
        }
    }
}

/// The three children shown in every stack: different sizes so alignment is visible.
private enum StackItem {
    static let colors: [Color] = [.blue, .purple, .pink]
    static let names = ["One", "Two", "Three"]
    static let fonts: [Font] = [.title2, .body, .caption]
    static let paddings: [CGFloat] = [18, 12, 8]

    /// Two-part `Alignment` name for a ZStack, e.g. `.topLeading`.
    static func zAlignment(_ h: HAlignOption, _ v: VAlignOption) -> (Alignment, String) {
        let alignment = Alignment(horizontal: h.value, vertical: v.value)
        if v == .firstTextBaseline {
            return (alignment, "Alignment(horizontal: \(h.label), vertical: .firstTextBaseline)")
        }
        let vName = String(v.label.dropFirst())
        let hName = String(h.label.dropFirst())
        let name: String = switch (vName, hName) {
        case ("center", "center"): ".center"
        case ("center", _): ".\(hName)"
        case (_, "center"): ".\(vName)"
        default: ".\(vName)\(hName.prefix(1).uppercased())\(hName.dropFirst())"
        }
        return (alignment, name)
    }
}

// MARK: - Demo

private struct StacksDemo: View {
    let page: ComponentPage

    var body: some View {
        DemoPage(
            page: page,
            initial: StacksConfig(),
            usage: """
            VStack(alignment: .leading) {
                Text("Alex Chen")
                    .font(.headline)
                Text("Online now")
                    .foregroundStyle(.secondary)
            }
            """,
            usageNote: Aside(.note, "A stack is only as big as its children. To fill the screen's width, add `.frame(maxWidth: .infinity)` or a `Spacer`.")
        ) { $config in
            let spacing: CGFloat? = config.useDefaultSpacing ? nil : config.spacing
            Group {
                switch config.kind {
                case .vStack:
                    VStack(alignment: config.horizontal.value, spacing: spacing) { items }
                case .hStack:
                    HStack(alignment: config.vertical.value, spacing: spacing) { items }
                case .zStack:
                    ZStack(alignment: StackItem.zAlignment(config.horizontal, config.vertical).0) { items }
                }
            }
            .padding(8)
            .background {
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(.secondary, style: StrokeStyle(lineWidth: 1, dash: [4, 3]))
            }
            .animation(.snappy, value: config.kind)
            .animation(.snappy, value: config.horizontal)
            .animation(.snappy, value: config.vertical)
            .animation(.snappy, value: config.spacing)
        } controls: { $config in
            Section("Stack") {
                Picker("Type", selection: $config.kind) {
                    ForEach(StackKind.allCases) { Text($0.label).tag($0) }
                }
                .pickerStyle(.segmented)
            }
            Section("Alignment") {
                if config.kind != .hStack {
                    OptionPicker("Horizontal", selection: $config.horizontal)
                }
                if config.kind != .vStack {
                    OptionPicker("Vertical", selection: $config.vertical)
                }
            }
            if config.kind != .zStack {
                Section("Spacing") {
                    Toggle("Default spacing", isOn: $config.useDefaultSpacing)
                    if !config.useDefaultSpacing {
                        ValueSlider("Spacing", value: $config.spacing, in: 0...40, step: 1)
                    }
                }
            }
        } code: { config in
            var args: [String] = []
            switch config.kind {
            case .vStack:
                if config.horizontal != .center { args.append("alignment: \(config.horizontal.label)") }
            case .hStack:
                if config.vertical != .center { args.append("alignment: \(config.vertical.label)") }
            case .zStack:
                let name = StackItem.zAlignment(config.horizontal, config.vertical).1
                if name != ".center" { args.append("alignment: \(name)") }
            }
            if config.kind != .zStack, !config.useDefaultSpacing {
                args.append("spacing: \(swiftNumber(config.spacing))")
            }
            let open = args.isEmpty ? "\(config.kind.label) {" : "\(config.kind.label)(\(args.joined(separator: ", "))) {"
            var lines = [open]
            for i in 0..<3 {
                lines.append("    Text(\"\(StackItem.names[i])\")")
                lines.append("        .font(\(fontName(i)))")
                lines.append("        .padding(\(Int(StackItem.paddings[i])))")
                lines.append("        .background(.\(colorName(i)).gradient, in: .rect(cornerRadius: 8))")
            }
            lines.append("}")
            lines.append(".foregroundStyle(.white)")
            return lines.joined(separator: "\n")
        } examples: {
            ExampleCard(
                title: "Profile row",
                caption: "The most common iOS layout: an `HStack` with an icon, a leading `VStack` of text, and a `Spacer`.",
                code: """
                HStack(spacing: 12) {
                    Image(systemName: "person.crop.circle.fill")
                        .font(.largeTitle)
                        .foregroundStyle(.tint)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Alex Chen")
                            .font(.headline)
                        Text("Online now")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.tertiary)
                }
                """
            ) {
                HStack(spacing: 12) {
                    Image(systemName: "person.crop.circle.fill")
                        .font(.largeTitle)
                        .foregroundStyle(.tint)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Alex Chen")
                            .font(.headline)
                        Text("Online now")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.tertiary)
                }
            }

            ExampleCard(
                title: "Badge on an icon",
                caption: "A `ZStack` with `.topTrailing` alignment pins a badge to the icon's corner, drawn on top.",
                code: """
                ZStack(alignment: .topTrailing) {
                    Image(systemName: "bell.fill")
                        .font(.system(size: 44))
                        .foregroundStyle(.secondary)
                    Text("3")
                        .font(.caption.bold())
                        .foregroundStyle(.white)
                        .padding(6)
                        .background(.red, in: .circle)
                        .offset(x: 8, y: -8)
                }
                """,
                aside: Aside(.note, "When one view only decorates another, `.overlay(alignment: .topTrailing)` does the same job and sizes itself to the icon instead of the larger of the two.")
            ) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: "bell.fill")
                        .font(.system(size: 44))
                        .foregroundStyle(.secondary)
                    Text("3")
                        .font(.caption.bold())
                        .foregroundStyle(.white)
                        .padding(6)
                        .background(.red, in: .circle)
                        .offset(x: 8, y: -8)
                }
            }

            ExampleCard(
                title: "Line up text on its baseline",
                caption: "Align an `HStack` on `.firstTextBaseline` so text of different sizes sits on one line, like a price.",
                code: """
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("$")
                        .font(.title3)
                    Text("249")
                        .font(.system(size: 56, weight: .bold))
                    Text("/ year")
                        .foregroundStyle(.secondary)
                }
                """
            ) {
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("$")
                        .font(.title3)
                    Text("249")
                        .font(.system(size: 56, weight: .bold))
                    Text("/ year")
                        .foregroundStyle(.secondary)
                }
            }

            ExampleCard(
                title: "Long scrolling column",
                caption: "Put a `LazyVStack` in a `ScrollView` so rows are created only as they scroll into view.",
                code: """
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 12) {
                        ForEach(1...200, id: \\.self) { i in
                            Text("Message \\(i)")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                                .background(.fill.tertiary, in: .rect(cornerRadius: 10))
                        }
                    }
                    .padding()
                }
                .frame(height: 220)
                """,
                aside: Aside(.note, "For rows with swipe actions, selection, and separators, use a [List](catalog://list) instead.")
            ) {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 12) {
                        ForEach(1...200, id: \.self) { i in
                            Text("Message \(i)")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                                .background(.fill.tertiary, in: .rect(cornerRadius: 10))
                        }
                    }
                    .padding()
                }
                .frame(height: 220)
            }
        }
    }

    @ViewBuilder
    private var items: some View {
        ForEach(0..<3, id: \.self) { i in
            Text(StackItem.names[i])
                .font(StackItem.fonts[i])
                .padding(StackItem.paddings[i])
                .background(StackItem.colors[i].gradient, in: .rect(cornerRadius: 8))
        }
        .foregroundStyle(.white)
    }

    private func fontName(_ i: Int) -> String {
        [".title2", ".body", ".caption"][i]
    }

    private func colorName(_ i: Int) -> String {
        ["blue", "purple", "pink"][i]
    }
}

// MARK: - Guideline samples

/// A small event card, for the alignment guideline.
private struct StackAlignSample: View {
    let alignment: HorizontalAlignment

    var body: some View {
        VStack(alignment: alignment, spacing: 4) {
            Text("Design Review")
                .font(.headline)
            Text("Thursday, 2:00 PM")
                .foregroundStyle(.secondary)
            Text("Room 4B, with Maya and 3 others")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .frame(width: 230, alignment: Alignment(horizontal: alignment, vertical: .center))
    }
}

/// Two groups of text, for the spacing guideline.
private struct StackGroupSample: View {
    let grouped: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: grouped ? 18 : 8) {
            VStack(alignment: .leading, spacing: grouped ? 2 : 8) {
                Text("Shipping").font(.headline)
                Text("Arrives Tuesday").foregroundStyle(.secondary)
            }
            VStack(alignment: .leading, spacing: grouped ? 2 : 8) {
                Text("Payment").font(.headline)
                Text("Visa ending in 4242").foregroundStyle(.secondary)
            }
        }
        .frame(width: 230, alignment: .leading)
    }
}
