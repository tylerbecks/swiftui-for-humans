import SwiftUI

extension ComponentPage {
    static let grid = ComponentPage(
        id: "grid",
        title: "Grid",
        summary: "Lines views up in rows and columns, sizing each column to its widest cell.",
        category: .layout,
        symbol: "square.grid.3x3",
        availability: ["iOS 16.0+", "macOS 13.0+", "visionOS 1.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/grid",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/layout",
        aliases: ["css grid", "table", "colspan", "grid-column span", "rows and columns", "spreadsheet", "UICollectionView", "key value"],
        related: ["lazy-grids", "stacks", "view-that-fits"],
        notes: [
            "**`Grid` isn't lazy.** It measures every cell up front so columns line up. For long or scrolling collections, use [Lazy Grids](catalog://lazy-grids).",
            "**A view outside a `GridRow` spans every column.** That's how a `Divider` stretches across the whole grid.",
            "**Set alignment at three levels.** `Grid(alignment:)` for everything, `.gridColumnAlignment(_:)` for a column, and `.gridCellAnchor(_:)` for one cell.",
        ],
        api: [
            APIItem("`Grid(alignment:)`", "The container. Also takes `horizontalSpacing` and `verticalSpacing`."),
            APIItem("`GridRow`", "A row; each child view is one cell."),
            APIItem("`.gridCellColumns(_:)`", "Spans a cell across columns, like `colspan`."),
            APIItem("`.gridColumnAlignment(_:)`", "Aligns a whole column. Put it on any one cell."),
            APIItem("`.gridCellUnsizedAxes(_:)`", "Stops a cell from widening its column or row."),
        ],
        guidelines: [
            Guideline(
                "Line values up in a column.",
                "Aligned values are quick to scan and compare. Separate rows of text start wherever each label ends.",
                good: "`Grid` gives the values one shared edge.",
                bad: "Separate `HStack`s leave values ragged."
            ) {
                GridAlignSample(usesGrid: true)
            } bad: {
                GridAlignSample(usesGrid: false)
            },
            Guideline(
                "Use a list for long text.",
                "A grid suits short, structured data. For many rows of text that people scroll, tap, or edit, a `List` is easier to read and use."
            ),
        ]
    ) {
        GridThumbnail()
    } content: { page in
        GridDemo(page: page)
    }
}

// MARK: - Thumbnail

private struct GridThumbnail: View {
    var body: some View {
        Grid(horizontalSpacing: 6, verticalSpacing: 6) {
            GridRow {
                cell(.blue).gridCellColumns(2)
                cell(.purple)
            }
            GridRow {
                cell(.pink)
                cell(.orange)
                cell(.teal)
            }
            GridRow {
                cell(.indigo)
                cell(.green).gridCellColumns(2)
            }
        }
        .frame(width: 180, height: 110)
    }

    private func cell(_ color: Color) -> some View {
        RoundedRectangle(cornerRadius: 6).fill(color.gradient)
    }
}

// MARK: - Config

private struct GridConfig {
    var alignment: GridAlignOption = .center
    var horizontalSpacing: Double = 16
    var verticalSpacing: Double = 10
    var trailingPrices = true
    var spanTotal = true
    var showDividers = true
}

private enum GridAlignOption: DemoOption {
    case leading, center, trailing

    var label: String {
        switch self {
        case .leading: ".leading"
        case .center: ".center"
        case .trailing: ".trailing"
        }
    }

    var value: Alignment {
        switch self {
        case .leading: .leading
        case .center: .center
        case .trailing: .trailing
        }
    }
}

private struct GridItemRow: Identifiable {
    let id: String
    let qty: Int
    let price: String

    static let all: [GridItemRow] = [
        GridItemRow(id: "Coffee", qty: 2, price: "$9.00"),
        GridItemRow(id: "Croissant", qty: 1, price: "$3.75"),
        GridItemRow(id: "Tea", qty: 3, price: "$10.50"),
    ]
}

// MARK: - Demo

private struct GridDemo: View {
    let page: ComponentPage

    var body: some View {
        DemoPage(
            page: page,
            initial: GridConfig(),
            usage: """
            Grid(alignment: .leading) {
                GridRow {
                    Text("Coffee")
                    Text("$9.00")
                }
                GridRow {
                    Text("Croissant")
                    Text("$3.75")
                }
            }
            """,
            usageNote: Aside(.note, "`Grid` works like a set of `HStack`s in a `VStack`, except every column is as wide as its widest cell.")
        ) { $config in
            Grid(
                alignment: config.alignment.value,
                horizontalSpacing: config.horizontalSpacing,
                verticalSpacing: config.verticalSpacing
            ) {
                GridRow {
                    Text("Item")
                    Text("Qty")
                    Text("Price")
                        .gridColumnAlignment(config.trailingPrices ? .trailing : config.alignment.value.horizontal)
                }
                .font(.subheadline.bold())
                if config.showDividers { Divider() }
                ForEach(GridItemRow.all) { row in
                    GridRow {
                        Text(row.id)
                        Text("\(row.qty)")
                        Text(row.price)
                    }
                }
                if config.showDividers { Divider() }
                GridRow {
                    if config.spanTotal {
                        Text("Total")
                            .gridCellColumns(2)
                    } else {
                        Text("Total")
                        Text("6")
                    }
                    Text("$23.25")
                }
                .bold()
            }
            .padding()
            .background(.fill.quaternary, in: .rect(cornerRadius: 12))
            .animation(.snappy, value: config.alignment)
            .animation(.snappy, value: config.trailingPrices)
            .animation(.snappy, value: config.spanTotal)
            .animation(.snappy, value: config.showDividers)
        } controls: { $config in
            Section("Grid") {
                OptionPicker("Alignment", selection: $config.alignment)
                ValueSlider("Horizontal spacing", value: $config.horizontalSpacing, in: 0...40, step: 1)
                ValueSlider("Vertical spacing", value: $config.verticalSpacing, in: 0...30, step: 1)
            }
            Section("Cells") {
                Toggle("Right-align the Price column", isOn: $config.trailingPrices)
                Toggle("\"Total\" spans 2 columns", isOn: $config.spanTotal)
                Toggle("Full-width dividers", isOn: $config.showDividers)
            }
        } code: { config in
            var args: [String] = []
            if config.alignment != .center { args.append("alignment: \(config.alignment.label)") }
            args.append("horizontalSpacing: \(swiftNumber(config.horizontalSpacing))")
            args.append("verticalSpacing: \(swiftNumber(config.verticalSpacing))")
            var lines = ["Grid(\(args.joined(separator: ", "))) {"]
            lines.append("    GridRow {")
            lines.append("        Text(\"Item\")")
            lines.append("        Text(\"Qty\")")
            lines.append("        Text(\"Price\")")
            if config.trailingPrices {
                lines.append("            .gridColumnAlignment(.trailing)")
            }
            lines.append("    }")
            lines.append("    .font(.subheadline.bold())")
            if config.showDividers { lines.append("    Divider() // outside a GridRow: full width") }
            for row in GridItemRow.all {
                lines.append("    GridRow {")
                lines.append("        Text(\"\(row.id)\")")
                lines.append("        Text(\"\(row.qty)\")")
                lines.append("        Text(\"\(row.price)\")")
                lines.append("    }")
            }
            if config.showDividers { lines.append("    Divider()") }
            lines.append("    GridRow {")
            if config.spanTotal {
                lines.append("        Text(\"Total\")")
                lines.append("            .gridCellColumns(2)")
            } else {
                lines.append("        Text(\"Total\")")
                lines.append("        Text(\"6\")")
            }
            lines.append("        Text(\"$23.25\")")
            lines.append("    }")
            lines.append("    .bold()")
            lines.append("}")
            lines.append(".padding()")
            lines.append(".background(.fill.quaternary, in: .rect(cornerRadius: 12))")
            return lines.joined(separator: "\n")
        } examples: {
            ExampleCard(
                title: "Label and value pairs",
                caption: "Use `.gridColumnAlignment(.trailing)` on one label to right-align the whole label column.",
                code: """
                Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 8) {
                    GridRow {
                        Text("Name")
                            .foregroundStyle(.secondary)
                            .gridColumnAlignment(.trailing)
                        Text("Ada Lovelace")
                    }
                    GridRow {
                        Text("Role")
                            .foregroundStyle(.secondary)
                        Text("Mathematician")
                    }
                    GridRow {
                        Text("Member since")
                            .foregroundStyle(.secondary)
                        Text("1843")
                    }
                }
                """
            ) {
                Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 8) {
                    GridRow {
                        Text("Name")
                            .foregroundStyle(.secondary)
                            .gridColumnAlignment(.trailing)
                        Text("Ada Lovelace")
                    }
                    GridRow {
                        Text("Role")
                            .foregroundStyle(.secondary)
                        Text("Mathematician")
                    }
                    GridRow {
                        Text("Member since")
                            .foregroundStyle(.secondary)
                        Text("1843")
                    }
                }
            }

            ExampleCard(
                title: "Dashboard tiles with a wide cell",
                caption: "Flexible tiles share the width evenly, and `.gridCellColumns(2)` makes one tile twice as wide.",
                code: """
                Grid(horizontalSpacing: 10, verticalSpacing: 10) {
                    GridRow {
                        Tile(title: "Steps", value: "8,204", color: .orange)
                            .gridCellColumns(2)
                        Tile(title: "Rings", value: "3/3", color: .pink)
                    }
                    GridRow {
                        Tile(title: "Sleep", value: "7h", color: .indigo)
                        Tile(title: "Heart", value: "62", color: .red)
                        Tile(title: "Water", value: "1.2L", color: .blue)
                    }
                }
                .frame(height: 170)

                // At the top level of the file:
                struct Tile: View {
                    let title: String
                    let value: String
                    let color: Color

                    var body: some View {
                        VStack(alignment: .leading) {
                            Text(title).font(.caption)
                            Spacer()
                            Text(value).font(.title3.bold())
                        }
                        .padding(10)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                        .foregroundStyle(.white)
                        .background(color.gradient, in: .rect(cornerRadius: 12))
                    }
                }
                """,
                aside: Aside(.note, "Each tile fills the height it's offered, so give the grid a fixed `.frame(height:)`.")
            ) {
                Grid(horizontalSpacing: 10, verticalSpacing: 10) {
                    GridRow {
                        GridTile(title: "Steps", value: "8,204", color: .orange)
                            .gridCellColumns(2)
                        GridTile(title: "Rings", value: "3/3", color: .pink)
                    }
                    GridRow {
                        GridTile(title: "Sleep", value: "7h", color: .indigo)
                        GridTile(title: "Heart", value: "62", color: .red)
                        GridTile(title: "Water", value: "1.2L", color: .blue)
                    }
                }
                .frame(height: 170)
            }
        }
    }
}

private struct GridTile: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading) {
            Text(title).font(.caption)
            Spacer()
            Text(value).font(.title3.bold())
        }
        .padding(10)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .foregroundStyle(.white)
        .background(color.gradient, in: .rect(cornerRadius: 12))
    }
}

// MARK: - Guideline samples

/// Label and value rows, in a `Grid` or in separate `HStack`s.
private struct GridAlignSample: View {
    let usesGrid: Bool
    private let rows = [("Name", "Ada Lovelace"), ("Role", "Mathematician"), ("Member since", "1843")]

    var body: some View {
        Group {
            if usesGrid {
                Grid(alignment: .leading, horizontalSpacing: 12, verticalSpacing: 6) {
                    ForEach(rows, id: \.0) { label, value in
                        GridRow {
                            Text(label).foregroundStyle(.secondary)
                            Text(value)
                        }
                    }
                }
            } else {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(rows, id: \.0) { label, value in
                        HStack(spacing: 12) {
                            Text(label).foregroundStyle(.secondary)
                            Text(value)
                        }
                    }
                }
            }
        }
        .font(.subheadline)
        .frame(width: 240, alignment: .leading)
    }
}
