import SwiftUI

extension ComponentPage {
    static let table = ComponentPage(
        id: "table",
        title: "Table",
        summary: "Rows of data in columns that people sort, resize, and select, like Finder's list view.",
        category: .lists,
        symbol: "tablecells",
        availability: ["macOS 12.0+", "Column customization macOS 14.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/table",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/lists-and-tables",
        aliases: [
            "Table", "TableColumn", "NSTableView", "data grid", "spreadsheet", "<table>", "columns", "sort",
            "sortOrder", "KeyPathComparator", "SortComparator", "multiple selection", "contextMenu",
            "TableColumnCustomization", "column visibility", "reorder columns", "tableStyle",
        ],
        related: ["list-styles", "outline", "context-menu", "inspector"],
        notes: [
            "**Sorting is your job.** The table shows which column is sorted and in which direction, but you sort the data yourself when `sortOrder` changes.",
            "**A `Table` scrolls on its own.** Don't wrap it in a `ScrollView`; give it a frame, or let the window size it.",
        ],
        about: "`Table` shows a collection as rows, with one `TableColumn` per property. People can click a column header to sort, drag column edges to resize, and select one row or many.\n\nUse it when each item has several values worth comparing side by side. For one value per row, a [List](catalog://list-styles) is simpler.",
        composition: """
        Table(files, selection:, sortOrder:)
        ├── TableColumn("Name", value: \\.name)
        ├── TableColumn("Kind", value: \\.kind)
        └── TableColumn("Size", value: \\.size)
        """,
        api: [
            APIItem("`Table(_:selection:sortOrder:)`", "Rows from data, selectable and sortable."),
            APIItem("`TableColumn(_:value:)`", "A column that shows and sorts by a key path."),
            APIItem("`KeyPathComparator(_:)`", "Describes one sort: a key path and order."),
            APIItem("`.width(min:ideal:max:)`", "Limits how wide a column can get."),
            APIItem("`.contextMenu(forSelectionType:)`", "A menu and double-click for selected rows."),
            APIItem("`.customizationID(_:)`", "Lets people hide and reorder a column."),
            APIItem("`.tableStyle(_:)`", "`.inset` or `.bordered`."),
            APIItem("`.alternatingRowBackgrounds()`", "Stripes every other row."),
        ],
        guidelines: [
            Guideline(
                "Let people sort by clicking a column header.",
                "Clicking the header of the column that's already sorted should sort it again in the opposite direction."
            ),
            Guideline(
                "Let people resize columns.",
                "Values vary in width. Resizing lets people read clipped text or focus on the columns they care about."
            ),
            Guideline(
                "Consider striped rows in a wide table.",
                "Alternating row colors help the eye follow one row across many columns."
            ),
            Guideline(
                "Name columns with short nouns, without punctuation.",
                "Headings like “Name” and “Date Modified” say what's below them. Skip trailing colons.",
                good: "Short noun headings.",
                bad: "Headings with colons and questions."
            ) {
                HeaderSample(titles: ["Name", "Size", "Kind"])
            } bad: {
                HeaderSample(titles: ["Name:", "How big?", "Kind:"])
            },
            Guideline(
                "Use an outline for data that nests.",
                "If rows contain other rows, like folders and files, show them with disclosure triangles in an [outline](catalog://outline)."
            ),
        ]
    ) {
        Grid(alignment: .leading, horizontalSpacing: 10, verticalSpacing: 4) {
            GridRow {
                Text("Name").bold()
                Text("Size").bold()
            }
            .font(.caption)
            Divider()
            ForEach(["Report.pdf", "Photo.heic", "Notes.txt"], id: \.self) { name in
                GridRow {
                    Text(name)
                    Text(name == "Photo.heic" ? "3 MB" : "12 KB").foregroundStyle(.secondary)
                }
                .font(.caption)
            }
        }
        .frame(width: 140)
    } content: { page in
        MacTableDemo(page: page)
    }
}

// MARK: - Sample data

private struct FileRow: Identifiable, Hashable {
    let name: String
    let kind: String
    let size: Int64
    var id: String { name }

    static let samples: [FileRow] = [
        FileRow(name: "Budget.numbers", kind: "Numbers", size: 412_000),
        FileRow(name: "Cover.png", kind: "PNG image", size: 2_300_000),
        FileRow(name: "Notes.txt", kind: "Plain text", size: 4_000),
        FileRow(name: "Report.pdf", kind: "PDF document", size: 1_250_000),
        FileRow(name: "Slides.key", kind: "Keynote", size: 18_400_000),
        FileRow(name: "Trip.heic", kind: "HEIC image", size: 3_100_000),
    ]
}

// MARK: - Demo

private struct MacTableConfig {
    var style: TableStyleOption = .automatic
    var selection: TableSelectionOption = .multiple
    var alternates = true
    var showsHeaders = true
}

private struct MacTableDemo: View {
    let page: ComponentPage

    var body: some View {
        DemoPage(
            page: page,
            initial: MacTableConfig(),
            previewHeight: 280,
            usage: """
            struct FileRow: Identifiable {
                let name: String
                let kind: String
                let size: Int64
                var id: String { name }

                static let samples = [
                    FileRow(name: "Report.pdf", kind: "PDF document", size: 1_250_000),
                    FileRow(name: "Notes.txt", kind: "Plain text", size: 4_000),
                ]
            }

            @State private var selection = Set<FileRow.ID>()

            Table(FileRow.samples, selection: $selection) {
                TableColumn("Name", value: \\.name)
                TableColumn("Kind", value: \\.kind)
            }
            """,
            usageNote: Aside(.note, "Each row needs a stable `id`: selection stores ids, not rows. The other snippets on this page reuse this `FileRow`.")
        ) { $config in
            TablePreview(config: config)
        } controls: { $config in
            Section("Appearance") {
                OptionPicker("Style", selection: $config.style)
                Toggle("Alternating rows", isOn: $config.alternates)
                Toggle("Column headers", isOn: $config.showsHeaders)
            }
            Section("Selection") {
                OptionPicker("Select", selection: $config.selection)
            }
        } code: { config in
            var lines = ["@State private var files = FileRow.samples"]
            switch config.selection {
            case .none: break
            case .single: lines.append("@State private var selection: FileRow.ID?")
            case .multiple: lines.append("@State private var selection = Set<FileRow.ID>()")
            }
            lines.append("@State private var sortOrder = [KeyPathComparator(\\FileRow.name)]")
            lines.append("")
            let selection = config.selection == .none ? "" : ", selection: $selection"
            lines += [
                "Table(files\(selection), sortOrder: $sortOrder) {",
                "    TableColumn(\"Name\", value: \\.name)",
                "    TableColumn(\"Kind\", value: \\.kind)",
                "    TableColumn(\"Size\", value: \\.size) { file in",
                "        Text(file.size, format: .byteCount(style: .file))",
                "    }",
                "}",
                ".onChange(of: sortOrder) { _, newOrder in",
                "    files.sort(using: newOrder)",
                "}",
            ]
            if config.style != .automatic {
                lines.append(".tableStyle(\(config.style.label))")
            }
            if !config.alternates {
                lines.append(".alternatingRowBackgrounds(.disabled)")
            }
            if !config.showsHeaders {
                lines.append(".tableColumnHeaders(.hidden)")
            }
            return lines.joined(separator: "\n")
        } examples: {
            MacTableExamples()
        }
    }
}

private struct TablePreview: View {
    let config: MacTableConfig
    @State private var files = FileRow.samples
    @State private var single: FileRow.ID? = "Report.pdf"
    @State private var multiple: Set<FileRow.ID> = ["Report.pdf"]
    @State private var sortOrder = [KeyPathComparator(\FileRow.name)]

    var body: some View {
        styled(table)
            .alternatingRowBackgrounds(config.alternates ? .enabled : .disabled)
            .tableColumnHeaders(config.showsHeaders ? .visible : .hidden)
            .onChange(of: sortOrder) { _, newOrder in
                files.sort(using: newOrder)
            }
            .frame(height: 230)
            .frame(maxWidth: 520)
            .id("\(config.style)-\(config.selection)")
    }

    @ViewBuilder private var table: some View {
        switch config.selection {
        case .none:
            Table(files, sortOrder: $sortOrder) {
                TableColumn("Name", value: \.name)
                TableColumn("Kind", value: \.kind)
                TableColumn("Size", value: \.size) { file in
                    Text(file.size, format: .byteCount(style: .file))
                }
            }
        case .single:
            Table(files, selection: $single, sortOrder: $sortOrder) {
                TableColumn("Name", value: \.name)
                TableColumn("Kind", value: \.kind)
                TableColumn("Size", value: \.size) { file in
                    Text(file.size, format: .byteCount(style: .file))
                }
            }
        case .multiple:
            Table(files, selection: $multiple, sortOrder: $sortOrder) {
                TableColumn("Name", value: \.name)
                TableColumn("Kind", value: \.kind)
                TableColumn("Size", value: \.size) { file in
                    Text(file.size, format: .byteCount(style: .file))
                }
            }
        }
    }

    @ViewBuilder
    private func styled(_ table: some View) -> some View {
        switch config.style {
        case .automatic: table.tableStyle(.automatic)
        case .inset: table.tableStyle(.inset)
        case .bordered: table.tableStyle(.bordered)
        }
    }
}

// MARK: - Examples

private struct MacTableExamples: View {
    var body: some View {
        ExampleCard(
            title: "Right-click and double-click selected rows",
            caption: "`.contextMenu(forSelectionType:)` builds a menu for the rows people clicked, and `primaryAction` runs when they double-click.",
            code: """
            @State private var files = FileRow.samples
            @State private var selection = Set<FileRow.ID>()

            Table(files, selection: $selection) {
                TableColumn("Name", value: \\.name)
                TableColumn("Kind", value: \\.kind)
            }
            .contextMenu(forSelectionType: FileRow.ID.self) { ids in
                if ids.isEmpty {
                    Button("New File") { }
                } else {
                    Button("Open") { }
                    Button("Move to Trash", role: .destructive) {
                        files.removeAll { ids.contains($0.id) }
                    }
                }
            } primaryAction: { ids in
                // Open each double-clicked file.
            }
            """,
            minHeight: 260,
            aside: Aside(.note, "Right-clicking empty space gives the menu an empty set, even when rows are selected. That's where “New File” goes.")
        ) {
            ContextMenuTableSample()
        }

        ExampleCard(
            title: "Columns people can hide and reorder",
            caption: "Give each column a `.customizationID` and pass a `TableColumnCustomization`, stored with `@SceneStorage` so the layout comes back with the window.",
            code: """
            @SceneStorage("FilesTable") private var columns = TableColumnCustomization<FileRow>()

            Table(FileRow.samples, columnCustomization: $columns) {
                TableColumn("Name", value: \\.name)
                    .customizationID("name")
                TableColumn("Kind", value: \\.kind)
                    .customizationID("kind")
                TableColumn("Size") { file in
                    Text(file.size, format: .byteCount(style: .file))
                }
                .customizationID("size")
            }
            """,
            minHeight: 230,
            aside: Aside(.note, "A column without a customization ID can't be hidden or moved. You can also hide one from code: `columns[visibility: \"size\"] = .hidden`.")
        ) {
            CustomizableTableSample()
        }

        ExampleCard(
            title: "Columns with sensible widths",
            caption: "`.width(min:ideal:max:)` sets how far people can resize a column, and a fixed `.width(_:)` suits short values like a size.",
            code: """
            Table(FileRow.samples) {
                TableColumn("Name", value: \\.name)
                    .width(min: 120, ideal: 180)
                TableColumn("Kind", value: \\.kind)
                    .width(min: 80, max: 160)
                TableColumn("Size") { file in
                    Text(file.size, format: .byteCount(style: .file))
                        .monospacedDigit()
                }
                .width(70)
            }
            """,
            minHeight: 220
        ) {
            Table(FileRow.samples) {
                TableColumn("Name", value: \.name)
                    .width(min: 120, ideal: 180)
                TableColumn("Kind", value: \.kind)
                    .width(min: 80, max: 160)
                TableColumn("Size") { file in
                    Text(file.size, format: .byteCount(style: .file))
                        .monospacedDigit()
                }
                .width(70)
            }
            .frame(width: 440, height: 190)
        }
    }
}

private struct ContextMenuTableSample: View {
    @State private var files = FileRow.samples
    @State private var selection = Set<FileRow.ID>()
    @State private var lastAction = "Right-click a row, or double-click to open."

    var body: some View {
        VStack(spacing: 10) {
            Table(files, selection: $selection) {
                TableColumn("Name", value: \.name)
                TableColumn("Kind", value: \.kind)
            }
            .contextMenu(forSelectionType: FileRow.ID.self) { ids in
                if ids.isEmpty {
                    Button("New File") { lastAction = "New File" }
                } else {
                    Button("Open") { lastAction = "Opened \(ids.sorted().joined(separator: ", "))" }
                    Button("Move to Trash", role: .destructive) {
                        files.removeAll { ids.contains($0.id) }
                    }
                }
            } primaryAction: { ids in
                lastAction = "Opened \(ids.sorted().joined(separator: ", "))"
            }
            .frame(width: 420, height: 190)
            Text(lastAction)
                .font(.callout)
                .foregroundStyle(.secondary)
        }
    }
}

private struct CustomizableTableSample: View {
    @State private var customization = TableColumnCustomization<FileRow>()

    var body: some View {
        VStack(spacing: 10) {
            Table(FileRow.samples, columnCustomization: $customization) {
                TableColumn("Name", value: \.name)
                    .customizationID("name")
                TableColumn("Kind", value: \.kind)
                    .customizationID("kind")
                TableColumn("Size") { file in
                    Text(file.size, format: .byteCount(style: .file))
                }
                .customizationID("size")
            }
            .frame(width: 420, height: 196)
            Toggle("Show Size column", isOn: Binding {
                customization[visibility: "size"] != .hidden
            } set: { isShown in
                customization[visibility: "size"] = isShown ? .visible : .hidden
            })
        }
    }
}

/// A row of column headings for the naming guideline.
private struct HeaderSample: View {
    let titles: [String]

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                ForEach(titles, id: \.self) { title in
                    Text(title)
                        .font(.callout.weight(.medium))
                        .lineLimit(1)
                        .padding(.horizontal, 8)
                        .frame(width: 80, height: 26, alignment: .leading)
                    if title != titles.last {
                        Divider().frame(height: 16)
                    }
                }
            }
            Divider()
            HStack(spacing: 0) {
                ForEach(["Notes.txt", "4 KB", "Text"], id: \.self) { value in
                    Text(value)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 8)
                        .frame(width: 81, height: 26, alignment: .leading)
                }
            }
        }
        .fixedSize()
        .overlay(RoundedRectangle(cornerRadius: 6).strokeBorder(.separator))
    }
}

// MARK: - Options

private enum TableStyleOption: DemoOption {
    case automatic, inset, bordered

    var label: String {
        switch self {
        case .automatic: ".automatic"
        case .inset: ".inset"
        case .bordered: ".bordered"
        }
    }
}

private enum TableSelectionOption: DemoOption {
    case none, single, multiple

    var label: String {
        switch self {
        case .none: "None"
        case .single: "One row"
        case .multiple: "Several rows"
        }
    }
}
