import SwiftUI

extension ComponentPage {
    static let stacksGrid = ComponentPage(
        id: "stacks-grid",
        title: "Stacks & Grid",
        summary: "Line views up in rows, columns, layers, and tables that grow with the window.",
        category: .layout,
        symbol: "square.grid.3x3",
        availability: ["macOS 10.15+", "Grid macOS 13.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/layout-fundamentals",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/layout",
        aliases: [
            "HStack", "VStack", "ZStack", "Grid", "GridRow", "Spacer", "flexbox", "flex", "css grid",
            "row", "column", "NSStackView", "NSGridView", "alignment", "spacing", "layoutPriority",
            "gridColumnAlignment", "gridCellColumns", "overlay",
        ],
        related: ["form", "view-that-fits", "windows-layout"],
        notes: [
            "**A stack is only as big as its content until something flexible is inside.** Add a `Spacer` or `.frame(maxWidth: .infinity)` and it takes all the width the window offers.",
            "**`Grid` lays out every cell up front.** That's how it lines up columns. For hundreds of cells inside a `ScrollView`, use `LazyVGrid` instead.",
        ],
        api: [
            APIItem("`HStack(alignment:spacing:)`", "Lays views out left to right."),
            APIItem("`VStack(alignment:spacing:)`", "Lays views out top to bottom."),
            APIItem("`ZStack(alignment:)`", "Layers views on top of each other."),
            APIItem("`Spacer()`", "Flexible space that pushes its neighbors apart."),
            APIItem("`Grid` and `GridRow`", "Rows whose cells line up in columns."),
            APIItem("`.gridColumnAlignment(_:)`", "Aligns one whole grid column."),
            APIItem("`.gridCellColumns(_:)`", "Lets a cell span several columns."),
            APIItem("`.layoutPriority(_:)`", "Decides which view shrinks last."),
        ],
        guidelines: [
            Guideline(
                "Line up labels and fields so the eye can scan down them.",
                "People read aligned items as related. A `Grid` with a trailing-aligned label column keeps every field starting at the same edge.",
                good: "Labels end at one edge; fields start at the next.",
                bad: "Each row's field starts wherever its label ends."
            ) {
                Grid(alignment: .leadingFirstTextBaseline, horizontalSpacing: 8, verticalSpacing: 8) {
                    GridRow {
                        Text("Name:").gridColumnAlignment(.trailing)
                        TextField("Name", text: .constant("Ada"))
                            .labelsHidden()
                            .frame(width: 120)
                    }
                    GridRow {
                        Text("Email address:")
                        TextField("Email", text: .constant("ada@example.com"))
                            .labelsHidden()
                            .frame(width: 120)
                    }
                }
            } bad: {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Text("Name:")
                        TextField("Name", text: .constant("Ada"))
                            .labelsHidden()
                            .frame(width: 120)
                    }
                    HStack(spacing: 8) {
                        Text("Email address:")
                        TextField("Email", text: .constant("ada@example.com"))
                            .labelsHidden()
                            .frame(width: 120)
                    }
                }
            },
            Guideline(
                "Put the most important things at the top leading corner.",
                "People usually read a window from top to bottom and from the leading side, so that's where they look first."
            ),
            Guideline(
                "Group related items with space before you reach for lines and boxes.",
                "Extra space between groups already says what belongs together. Separators and containers are for when space isn't enough."
            ),
            Guideline(
                "Keep important controls away from the bottom of the window.",
                "People often drag a Mac window partly below the bottom of the screen, which hides whatever sits along its lower edge."
            ),
        ]
    ) {
        Grid(horizontalSpacing: 6, verticalSpacing: 6) {
            GridRow {
                StackTile(color: .blue).frame(width: 60, height: 34)
                StackTile(color: .teal).frame(width: 34, height: 34)
            }
            GridRow {
                StackTile(color: .orange)
                    .frame(height: 34)
                    .gridCellColumns(2)
            }
        }
        .frame(width: 100)
    } content: { page in
        MacStacksGridDemo(page: page)
    }
}

// MARK: - Demo

private struct MacStacksConfig {
    var container: StackContainerOption = .hStack
    var alignment: StackAlignmentOption = .center
    var spacing: StackSpacingOption = .standard
}

private struct MacStacksGridDemo: View {
    let page: ComponentPage

    var body: some View {
        DemoPage(
            page: page,
            initial: MacStacksConfig(),
            usage: """
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "doc.text")
                    .font(.title)
                VStack(alignment: .leading) {
                    Text("Quarterly Report")
                        .font(.headline)
                    Text("Edited yesterday")
                        .foregroundStyle(.secondary)
                }
            }
            """,
            usageNote: Aside(.note, "Stacks nest: an `HStack` of an icon and a `VStack` of two lines is the most common row on the Mac, like `display: flex` inside `display: flex`.")
        ) { $config in
            StackPreview(config: config)
                .animation(.snappy, value: config.container)
                .animation(.snappy, value: config.alignment)
                .animation(.snappy, value: config.spacing)
        } controls: { $config in
            Section("Layout") {
                OptionPicker("Container", selection: $config.container)
                OptionPicker("Alignment", selection: $config.alignment)
                if config.container != .zStack {
                    OptionPicker("Spacing", selection: $config.spacing)
                }
            }
        } code: { config in
            var arguments: [String] = []
            if config.alignment != .center {
                arguments.append("alignment: \(config.alignment.code(for: config.container))")
            }
            if config.container != .zStack, let spacing = config.spacing.value {
                arguments.append("spacing: \(swiftNumber(spacing))")
            }
            let open = arguments.isEmpty ? "\(config.container.label) {" : "\(config.container.label)(\(arguments.joined(separator: ", "))) {"
            return """
            \(open)
                RoundedRectangle(cornerRadius: 8).fill(.blue)
                    .frame(width: 120, height: 80)
                RoundedRectangle(cornerRadius: 8).fill(.teal)
                    .frame(width: 80, height: 56)
                RoundedRectangle(cornerRadius: 8).fill(.orange)
                    .frame(width: 44, height: 32)
            }
            """
        } examples: {
            MacStacksGridExamples()
        }
    }
}

private struct StackPreview: View {
    let config: MacStacksConfig

    var body: some View {
        let spacing = config.spacing.value.map { CGFloat($0) }
        Group {
            switch config.container {
            case .hStack:
                HStack(alignment: config.alignment.vertical, spacing: spacing) { tiles }
            case .vStack:
                VStack(alignment: config.alignment.horizontal, spacing: spacing) { tiles }
            case .zStack:
                ZStack(alignment: config.alignment.both) { tiles }
            }
        }
        .padding(8)
        .overlay {
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(.secondary.opacity(0.5), style: StrokeStyle(lineWidth: 1, dash: [4, 3]))
        }
    }

    @ViewBuilder private var tiles: some View {
        StackTile(color: .blue).frame(width: 120, height: 80)
        StackTile(color: .teal).frame(width: 80, height: 56)
        StackTile(color: .orange).frame(width: 44, height: 32)
    }
}

private struct StackTile: View {
    let color: Color

    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(color.gradient)
    }
}

// MARK: - Examples

private struct MacStacksGridExamples: View {
    @State private var barWidth = 420.0
    @State private var rowWidth = 300.0
    @State private var name = "Ada Lovelace"
    @State private var asksFirst = true

    var body: some View {
        ExampleCard(
            title: "Push items apart with Spacer",
            caption: "A `Spacer` grows to fill the row, so the count stays left and the button stays right at any window width. Drag the slider to resize.",
            code: """
            HStack {
                Text("12 items")
                    .foregroundStyle(.secondary)
                Spacer()
                Button("Add Item", systemImage: "plus") { }
            }
            .padding(.horizontal)
            """,
            minHeight: 150
        ) {
            VStack(spacing: 16) {
                HStack {
                    Text("12 items")
                        .foregroundStyle(.secondary)
                    Spacer()
                    Button("Add Item", systemImage: "plus") {}
                }
                .padding(.horizontal)
                .frame(width: barWidth, height: 40)
                .background(.background, in: .rect(cornerRadius: 8))
                .overlay(RoundedRectangle(cornerRadius: 8).strokeBorder(.separator))
                WidthSlider(width: $barWidth, range: 260...460)
            }
        }

        ExampleCard(
            title: "Labels and fields in a Grid",
            caption: "In a `Grid`, `.gridColumnAlignment(.trailing)` right-aligns the label column, and `.gridCellColumns(2)` lets the checkbox span the field and button columns.",
            code: """
            @State private var name = "Ada Lovelace"
            @State private var asksFirst = true

            Grid(alignment: .leadingFirstTextBaseline) {
                GridRow {
                    Text("Name:")
                        .gridColumnAlignment(.trailing)
                    TextField("Name", text: $name)
                        .labelsHidden()
                    Button("Reset") { }
                }
                GridRow {
                    Text("Save to:")
                    Text("Downloads")
                    Button("Choose…") { }
                }
                GridRow {
                    Color.clear
                        .gridCellUnsizedAxes([.horizontal, .vertical])
                    Toggle("Ask before saving", isOn: $asksFirst)
                        .gridCellColumns(2)
                }
            }
            """,
            minHeight: 160
        ) {
            Grid(alignment: .leadingFirstTextBaseline) {
                GridRow {
                    Text("Name:")
                        .gridColumnAlignment(.trailing)
                    TextField("Name", text: $name)
                        .labelsHidden()
                        .frame(width: 180)
                    Button("Reset") { name = "Ada Lovelace" }
                }
                GridRow {
                    Text("Save to:")
                    Text("Downloads")
                    Button("Choose…") {}
                }
                GridRow {
                    Color.clear
                        .gridCellUnsizedAxes([.horizontal, .vertical])
                    Toggle("Ask before saving", isOn: $asksFirst)
                        .gridCellColumns(2)
                }
            }
        }

        ExampleCard(
            title: "Choose what shrinks first",
            caption: "When the window gets narrow, `.layoutPriority(1)` keeps the file name whole and lets the folder path truncate instead.",
            code: """
            HStack {
                Text("Budget 2027.numbers")
                    .bold()
                    .layoutPriority(1)
                Text("~/Documents/Finance/Planning")
                    .foregroundStyle(.secondary)
            }
            .lineLimit(1)
            """,
            minHeight: 140,
            aside: Aside(.note, "Every view starts at priority 0, and siblings share the space evenly. A higher priority gets its space before the others.")
        ) {
            VStack(spacing: 16) {
                HStack {
                    Text("Budget 2027.numbers")
                        .bold()
                        .layoutPriority(1)
                    Text("~/Documents/Finance/Planning")
                        .foregroundStyle(.secondary)
                }
                .lineLimit(1)
                .frame(width: rowWidth, alignment: .leading)
                .padding(8)
                .overlay(RoundedRectangle(cornerRadius: 8).strokeBorder(.separator))
                WidthSlider(width: $rowWidth, range: 200...460)
            }
        }

        ExampleCard(
            title: "A caption over a photo with ZStack",
            caption: "`ZStack(alignment: .bottomLeading)` draws later views on top and pins them to the corner you choose.",
            code: """
            ZStack(alignment: .bottomLeading) {
                Image("photo")
                    .resizable()
                    .scaledToFill()
                Text("Lake Tahoe")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding(8)
                    .background(.black.opacity(0.5), in: .rect(cornerRadius: 6))
                    .padding(10)
            }
            .frame(width: 300, height: 180)
            .clipShape(.rect(cornerRadius: 12))
            """,
            minHeight: 220
        ) {
            ZStack(alignment: .bottomLeading) {
                SceneryView(.lake)
                Text("Lake Tahoe")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding(8)
                    .background(.black.opacity(0.5), in: .rect(cornerRadius: 6))
                    .padding(10)
            }
            .frame(width: 300, height: 180)
            .clipShape(.rect(cornerRadius: 12))
        }
    }
}

/// A slider that stands in for resizing the window.
private struct WidthSlider: View {
    @Binding var width: Double
    let range: ClosedRange<Double>

    var body: some View {
        HStack {
            Image(systemName: "arrow.left.and.right")
                .foregroundStyle(.secondary)
            Slider(value: $width, in: range) {
                Text("Width")
            }
            .labelsHidden()
            .frame(width: 180)
            Text("\(Int(width)) pt")
                .monospacedDigit()
                .foregroundStyle(.secondary)
                .frame(width: 52, alignment: .trailing)
        }
        .font(.callout)
    }
}

// MARK: - Options

private enum StackContainerOption: DemoOption {
    case hStack, vStack, zStack

    var label: String {
        switch self {
        case .hStack: "HStack"
        case .vStack: "VStack"
        case .zStack: "ZStack"
        }
    }
}

private enum StackAlignmentOption: DemoOption {
    case start, center, end

    var label: String {
        switch self {
        case .start: "Start"
        case .center: "Center"
        case .end: "End"
        }
    }

    var vertical: VerticalAlignment {
        switch self {
        case .start: .top
        case .center: .center
        case .end: .bottom
        }
    }

    var horizontal: HorizontalAlignment {
        switch self {
        case .start: .leading
        case .center: .center
        case .end: .trailing
        }
    }

    var both: Alignment {
        switch self {
        case .start: .topLeading
        case .center: .center
        case .end: .bottomTrailing
        }
    }

    func code(for container: StackContainerOption) -> String {
        switch (container, self) {
        case (.hStack, .start): ".top"
        case (.hStack, .end): ".bottom"
        case (.vStack, .start): ".leading"
        case (.vStack, .end): ".trailing"
        case (.zStack, .start): ".topLeading"
        case (.zStack, .end): ".bottomTrailing"
        default: ".center"
        }
    }
}

private enum StackSpacingOption: DemoOption {
    case standard, none, small, large

    var label: String {
        switch self {
        case .standard: "Default"
        case .none: "0"
        case .small: "8"
        case .large: "24"
        }
    }

    var value: Double? {
        switch self {
        case .standard: nil
        case .none: 0
        case .small: 8
        case .large: 24
        }
    }
}
