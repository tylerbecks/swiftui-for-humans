---
id: grid
title: Grid
platforms: [iOS, iPadOS]
availability: iOS 16.0+, macOS 13.0+, visionOS 1.0+
docs: https://developer.apple.com/documentation/swiftui/grid.md
hig: https://developer.apple.com/design/human-interface-guidelines/layout.md
---

# Grid

Lines views up in rows and columns, sizing each column to its widest cell.

Also called: css grid, table, colspan, grid-column span, rows and columns, spreadsheet, UICollectionView, key value.

## Contents

- Default code
- Rules
- Pitfalls
- Key APIs
- Variants
- Related

## Default code

```swift
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
```

**Note:** `Grid` works like a set of `HStack`s in a `VStack`, except every column is as wide as its widest cell.

## Rules

- **Line values up in a column.** Aligned values are quick to scan and compare. Separate rows of text start wherever each label ends.
- **Use a list for long text.** A grid suits short, structured data. For many rows of text that people scroll, tap, or edit, a `List` is easier to read and use.

## Pitfalls

- **`Grid` isn't lazy.** It measures every cell up front so columns line up. For long or scrolling collections, use [Lazy Grids](lazy-grids.md).
- **A view outside a `GridRow` spans every column.** That's how a `Divider` stretches across the whole grid.
- **Set alignment at three levels.** `Grid(alignment:)` for everything, `.gridColumnAlignment(_:)` for a column, and `.gridCellAnchor(_:)` for one cell.

## Key APIs

- `Grid(alignment:)`: The container. Also takes `horizontalSpacing` and `verticalSpacing`.
- `GridRow`: A row; each child view is one cell.
- `.gridCellColumns(_:)`: Spans a cell across columns, like `colspan`.
- `.gridColumnAlignment(_:)`: Aligns a whole column. Put it on any one cell.
- `.gridCellUnsizedAxes(_:)`: Stops a cell from widening its column or row.

## Variants

### Label and value pairs

Use `.gridColumnAlignment(.trailing)` on one label to right-align the whole label column.

```swift
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
```

### Dashboard tiles with a wide cell

Flexible tiles share the width evenly, and `.gridCellColumns(2)` makes one tile twice as wide.

```swift
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
```

**Note:** Each tile fills the height it's offered, so give the grid a fixed `.frame(height:)`.

## Related

[lazy-grids](lazy-grids.md), [stacks](stacks.md), [view-that-fits](view-that-fits.md)
