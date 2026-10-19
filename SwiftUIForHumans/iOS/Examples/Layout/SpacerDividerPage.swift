import SwiftUI

extension ComponentPage {
    static let spacerDivider = ComponentPage(
        id: "spacer-divider",
        title: "Spacer & Divider",
        summary: "Spacer pushes views apart in a stack; Divider draws a thin line between them.",
        category: .layout,
        symbol: "arrow.left.and.right",
        availability: ["iOS 13.0+", "macOS 10.15+", "visionOS 1.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/spacer",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/layout",
        aliases: ["justify-content", "space-between", "margin auto", "flex-grow", "hr", "separator", "line", "gap"],
        related: ["stacks", "layout-basics", "frame"],
        notes: [
            "**Several spacers split the free space evenly.** One before, between, and after the views gives you `space-evenly`.",
            "**A spacer keeps a small gap by default.** Use `Spacer(minLength: 0)` when the views should be allowed to touch.",
            "**Lists and forms draw their own separators.** Don't add a `Divider` between `List` or `Form` rows.",
        ],
        api: [
            APIItem("`Spacer()`", "Takes all the free space along the stack's axis."),
            APIItem("`Spacer(minLength:)`", "Sets the smallest gap the spacer keeps."),
            APIItem("`Divider()`", "A thin line: horizontal in a `VStack`, vertical in an `HStack`."),
            APIItem("`.frame(maxWidth:alignment:)`", "Pushes a view to one edge without a spacer."),
            APIItem("`.fixedSize(horizontal:vertical:)`", "Keeps a row with dividers only as tall as its content."),
        ],
        guidelines: [
            Guideline(
                "Group with space before you reach for lines.",
                "Extra space between groups already shows structure. A divider under every row adds noise without adding meaning.",
                good: "Space separates the two groups.",
                bad: "A line under every row."
            ) {
                SDGroupSample(usesDividers: false)
            } bad: {
                SDGroupSample(usesDividers: true)
            },
            Guideline(
                "Put the main item on the leading side.",
                "People read from the leading edge, so put the title there and push secondary actions to the trailing edge with a `Spacer`."
            ),
        ]
    ) {
        SpacerDividerThumbnail()
    } content: { page in
        SpacerDividerDemo(page: page)
    }
}

// MARK: - Thumbnail

private struct SpacerDividerThumbnail: View {
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                SDChip(text: "A", color: .blue)
                Spacer()
                SDChip(text: "B", color: .purple)
            }
            .padding(8)
            .background(.fill.quaternary, in: .rect(cornerRadius: 10))
            Divider()
            HStack {
                SDChip(text: "A", color: .blue)
                Divider()
                SDChip(text: "B", color: .purple)
                Spacer()
            }
            .fixedSize(horizontal: false, vertical: true)
            .padding(8)
            .background(.fill.quaternary, in: .rect(cornerRadius: 10))
        }
        .frame(width: 200)
    }
}

private struct SDChip: View {
    let text: String
    let color: Color

    var body: some View {
        Text(text)
            .font(.headline)
            .foregroundStyle(.white)
            .frame(width: 44, height: 36)
            .background(color.gradient, in: .rect(cornerRadius: 8))
    }
}

// MARK: - Config

private struct SpacerConfig {
    var axis: SpacerAxis = .horizontal
    var placement: SpacerPlacement = .between
    var minLength: SpacerMinLength = .automatic
    var showDivider = false
}

private enum SpacerAxis: DemoOption {
    case horizontal, vertical

    var label: String {
        switch self {
        case .horizontal: "HStack"
        case .vertical: "VStack"
        }
    }
}

private enum SpacerPlacement: DemoOption {
    case none, before, between, after, evenly

    var label: String {
        switch self {
        case .none: "None"
        case .before: "Before A"
        case .between: "Between"
        case .after: "After B"
        case .evenly: "Around each"
        }
    }

    var cssName: String {
        switch self {
        case .none: "Like justify-content: center, because the stack hugs its children and the frame centers it."
        case .before: "Like justify-content: flex-end. The spacer takes the free space on the leading side."
        case .between: "Like justify-content: space-between. The spacer pushes A and B to the edges."
        case .after: "Like justify-content: flex-start. The spacer takes the free space on the trailing side."
        case .evenly: "Like justify-content: space-evenly. Three spacers split the free space equally."
        }
    }
}

private enum SpacerMinLength: DemoOption {
    case automatic, zero, forty

    var label: String {
        switch self {
        case .automatic: "Default"
        case .zero: "0"
        case .forty: "40"
        }
    }

    var value: CGFloat? {
        switch self {
        case .automatic: nil
        case .zero: 0
        case .forty: 40
        }
    }
}

// MARK: - Demo

private struct SpacerDividerDemo: View {
    let page: ComponentPage

    var body: some View {
        DemoPage(
            page: page,
            initial: SpacerConfig(),
            usage: """
            HStack {
                Text("Recent")
                    .font(.headline)
                Spacer()
                Button("See All") {}
            }
            """,
            usageNote: Aside(.important, "A `Spacer` only works inside a stack. It grows along the stack's axis: sideways in an `HStack`, up and down in a `VStack`.")
        ) { $config in
            VStack(spacing: 14) {
                Group {
                    if config.axis == .horizontal {
                        HStack { content(config) }
                            .frame(height: 60)
                    } else {
                        VStack { content(config) }
                            .frame(height: 200)
                    }
                }
                .padding(8)
                .frame(maxWidth: config.axis == .horizontal ? .infinity : nil)
                .background(.fill.quaternary, in: .rect(cornerRadius: 12))
                .animation(.snappy, value: config.placement)
                .animation(.snappy, value: config.minLength)
                .animation(.snappy, value: config.showDivider)

                Text(config.placement.cssName)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: 420)
        } controls: { $config in
            Section("Stack") {
                Picker("Axis", selection: $config.axis) {
                    ForEach(SpacerAxis.allCases) { Text($0.label).tag($0) }
                }
                .pickerStyle(.segmented)
            }
            Section("Spacer") {
                OptionPicker("Placement", selection: $config.placement)
                if config.placement != .none {
                    Picker("minLength", selection: $config.minLength) {
                        ForEach(SpacerMinLength.allCases) { Text($0.label).tag($0) }
                    }
                    .pickerStyle(.segmented)
                }
            }
            Section("Divider") {
                Toggle("Divider between A and B", isOn: $config.showDivider)
            }
        } code: { config in
            let stack = config.axis == .horizontal ? "HStack" : "VStack"
            let spacer = config.minLength.value.map { "Spacer(minLength: \(Int($0)))" } ?? "Spacer()"
            var body: [String] = []
            if config.placement == .before || config.placement == .evenly { body.append(spacer) }
            body += chip("A", "blue")
            if config.showDivider { body.append("Divider()") }
            if config.placement == .between || config.placement == .evenly { body.append(spacer) }
            body += chip("B", "purple")
            if config.placement == .after || config.placement == .evenly { body.append(spacer) }

            var lines = ["\(stack) {"]
            lines += body.map { "    " + $0 }
            lines.append("}")
            lines.append(config.axis == .horizontal ? ".frame(height: 60)" : ".frame(height: 200)")
            lines.append(".padding(8)")
            if config.axis == .horizontal { lines.append(".frame(maxWidth: .infinity)") }
            lines.append(".background(.fill.quaternary, in: .rect(cornerRadius: 12))")
            lines.append(".font(.headline)")
            lines.append(".foregroundStyle(.white)")
            return lines.joined(separator: "\n")
        } examples: {
            ExampleCard(
                title: "Pin a button to the bottom",
                caption: "A `Spacer` in a `VStack` pushes the button down, like a welcome screen's Continue button.",
                code: """
                VStack(spacing: 12) {
                    Image(systemName: "hand.wave.fill")
                        .font(.system(size: 44))
                        .foregroundStyle(.tint)
                    Text("Welcome")
                        .font(.title2.bold())
                    Spacer()
                    Button("Continue") {}
                        .buttonStyle(.borderedProminent)
                }
                .padding()
                .frame(height: 240)
                """
            ) {
                VStack(spacing: 12) {
                    Image(systemName: "hand.wave.fill")
                        .font(.system(size: 44))
                        .foregroundStyle(.tint)
                    Text("Welcome")
                        .font(.title2.bold())
                    Spacer()
                    Button("Continue") {}
                        .buttonStyle(.borderedProminent)
                }
                .padding()
                .frame(height: 240)
            }

            ExampleCard(
                title: "Stats with vertical dividers",
                caption: "In an `HStack`, a `Divider` is vertical and stretches to the stack's full height.",
                code: """
                HStack(spacing: 20) {
                    VStack {
                        Text("128").font(.title3.bold())
                        Text("Posts").font(.caption)
                    }
                    Divider()
                    VStack {
                        Text("4.2k").font(.title3.bold())
                        Text("Followers").font(.caption)
                    }
                    Divider()
                    VStack {
                        Text("310").font(.title3.bold())
                        Text("Following").font(.caption)
                    }
                }
                .fixedSize(horizontal: false, vertical: true)
                """,
                aside: Aside(.important, "Without `.fixedSize` on the vertical axis, the dividers grow as tall as the space offered. With it, the row is only as tall as its text.")
            ) {
                HStack(spacing: 20) {
                    SDStat(value: "128", label: "Posts")
                    Divider()
                    SDStat(value: "4.2k", label: "Followers")
                    Divider()
                    SDStat(value: "310", label: "Following")
                }
                .fixedSize(horizontal: false, vertical: true)
            }

            ExampleCard(
                title: "\"Or\" separator",
                caption: "Wrap each `Divider` in a `VStack` so it stays horizontal beside the word \"or\".",
                code: """
                HStack(spacing: 12) {
                    VStack { Divider() }
                    Text("or")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    VStack { Divider() }
                }
                """
            ) {
                HStack(spacing: 12) {
                    VStack { Divider() }
                    Text("or")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    VStack { Divider() }
                }
            }
        }
    }

    private func chip(_ text: String, _ color: String) -> [String] {
        [
            "Text(\"\(text)\")",
            "    .frame(width: 44, height: 36)",
            "    .background(.\(color).gradient, in: .rect(cornerRadius: 8))",
        ]
    }

    @ViewBuilder
    private func content(_ config: SpacerConfig) -> some View {
        let minLength = config.minLength.value
        if config.placement == .before || config.placement == .evenly { Spacer(minLength: minLength) }
        SDChip(text: "A", color: .blue)
        if config.showDivider { Divider() }
        if config.placement == .between || config.placement == .evenly { Spacer(minLength: minLength) }
        SDChip(text: "B", color: .purple)
        if config.placement == .after || config.placement == .evenly { Spacer(minLength: minLength) }
    }
}

private struct SDStat: View {
    let value: String
    let label: String

    var body: some View {
        VStack {
            Text(value).font(.title3.bold())
            Text(label).font(.caption)
        }
    }
}

// MARK: - Guideline samples

/// Two groups of rows, separated by space or by a line under every row.
private struct SDGroupSample: View {
    let usesDividers: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: usesDividers ? 6 : 24) {
            group(["Wi-Fi", "Bluetooth"])
            if usesDividers { Divider() }
            group(["Notifications", "Sounds"])
        }
        .frame(width: 220)
    }

    private func group(_ rows: [String]) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(Array(rows.enumerated()), id: \.offset) { index, row in
                if usesDividers && index > 0 { Divider() }
                Text(row)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}
