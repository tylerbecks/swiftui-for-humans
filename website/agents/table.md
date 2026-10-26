---
id: table
title: Table
platforms: [macOS]
availability: macOS 12.0+, Column customization macOS 14.0+
docs: https://developer.apple.com/documentation/swiftui/table.md
hig: https://developer.apple.com/design/human-interface-guidelines/lists-and-tables.md
---

# Table

Rows of data in columns that people sort, resize, and select, like Finder's list view.

## Contents

- Use when
- Don't use when
- Default code
- Built from
- Rules
- Pitfalls
- Key APIs
- Variants
- Related

## Use when

- `Table` shows a collection as rows, with one `TableColumn` per property.
- People can click a column header to sort, drag column edges to resize, and select one row or many.
- Use it when each item has several values worth comparing side by side.

## Don't use when

- For one value per row, a [List](list-styles.md) is simpler.

## Default code

```swift
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
    TableColumn("Name", value: \.name)
    TableColumn("Kind", value: \.kind)
}
```

**Note:** Each row needs a stable `id`: selection stores ids, not rows. The other snippets on this page reuse this `FileRow`.

## Built from

Table(files, selection:, sortOrder:)
├── TableColumn("Name", value: \.name)
├── TableColumn("Kind", value: \.kind)
└── TableColumn("Size", value: \.size)

## Rules

- **Let people sort by clicking a column header.** Clicking the header of the column that's already sorted should sort it again in the opposite direction.
- **Let people resize columns.** Values vary in width. Resizing lets people read clipped text or focus on the columns they care about.
- **Consider striped rows in a wide table.** Alternating row colors help the eye follow one row across many columns.
- **Name columns with short nouns, without punctuation.** Headings like “Name” and “Date Modified” say what's below them. Skip trailing colons.
- **Use an outline for data that nests.** If rows contain other rows, like folders and files, show them with disclosure triangles in an [outline](outline.md).

## Pitfalls

- **Sorting is your job.** The table shows which column is sorted and in which direction, but you sort the data yourself when `sortOrder` changes.
- **A `Table` scrolls on its own.** Don't wrap it in a `ScrollView`; give it a frame, or let the window size it.

## Key APIs

`Table(_:selection:sortOrder:)`, `TableColumn(_:value:)`, `KeyPathComparator(_:)`, `.width(min:ideal:max:)`, `.contextMenu(forSelectionType:)`, `.customizationID(_:)`, `.tableStyle(_:)`, `.alternatingRowBackgrounds()`

## Variants

### Right-click and double-click selected rows

`.contextMenu(forSelectionType:)` builds a menu for the rows people clicked, and `primaryAction` runs when they double-click.

```swift
@State private var files = FileRow.samples
@State private var selection = Set<FileRow.ID>()

Table(files, selection: $selection) {
    TableColumn("Name", value: \.name)
    TableColumn("Kind", value: \.kind)
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
```

**Note:** Right-clicking empty space gives the menu an empty set, even when rows are selected. That's where “New File” goes.

### Columns people can hide and reorder

Give each column a `.customizationID` and pass a `TableColumnCustomization`, stored with `@SceneStorage` so the layout comes back with the window.

```swift
@SceneStorage("FilesTable") private var columns = TableColumnCustomization<FileRow>()

Table(FileRow.samples, columnCustomization: $columns) {
    TableColumn("Name", value: \.name)
        .customizationID("name")
    TableColumn("Kind", value: \.kind)
        .customizationID("kind")
    TableColumn("Size") { file in
        Text(file.size, format: .byteCount(style: .file))
    }
    .customizationID("size")
}
```

**Note:** A column without a customization ID can't be hidden or moved. You can also hide one from code: `columns[visibility: "size"] = .hidden`.

### Columns with sensible widths

`.width(min:ideal:max:)` sets how far people can resize a column, and a fixed `.width(_:)` suits short values like a size.

```swift
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
```

## Related

[list-styles](list-styles.md), [outline](outline.md), [context-menu](context-menu.md), [inspector](inspector.md)
