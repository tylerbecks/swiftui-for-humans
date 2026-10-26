---
id: stacks-grid
title: Stacks & Grid
platforms: [macOS]
availability: macOS 10.15+, Grid macOS 13.0+
docs: https://developer.apple.com/documentation/swiftui/layout-fundamentals.md
hig: https://developer.apple.com/design/human-interface-guidelines/layout.md
---

# Stacks & Grid

Line views up in rows, columns, layers, and tables that grow with the window.

Also called: HStack, VStack, ZStack, Grid, GridRow, Spacer, flexbox, flex, css grid, row.

## Contents

- Default code
- Rules
- Pitfalls
- Key APIs
- Variants
- Related

## Default code

```swift
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
```

**Note:** Stacks nest: an `HStack` of an icon and a `VStack` of two lines is the most common row on the Mac, like `display: flex` inside `display: flex`.

## Rules

- **Line up labels and fields so the eye can scan down them.** People read aligned items as related. A `Grid` with a trailing-aligned label column keeps every field starting at the same edge.
- **Put the most important things at the top leading corner.** People usually read a window from top to bottom and from the leading side, so that's where they look first.
- **Group related items so people can see what belongs together.** Extra space between groups often says it on its own. A container shape or a separator line can make the grouping clearer.
- **Keep important controls away from the bottom of the window.** People often drag a Mac window partly below the bottom of the screen, which hides whatever sits along its lower edge.

## Pitfalls

- **A stack is only as big as its content until something flexible is inside.** Add a `Spacer` or `.frame(maxWidth: .infinity)` and it takes all the width the window offers.
- **`Grid` lays out every cell up front.** That's how it lines up columns. For hundreds of cells inside a `ScrollView`, use `LazyVGrid` instead.

## Key APIs

- `HStack(alignment:spacing:)`: Lays views out left to right.
- `VStack(alignment:spacing:)`: Lays views out top to bottom.
- `ZStack(alignment:)`: Layers views on top of each other.
- `Spacer()`: Flexible space that pushes its neighbors apart.
- `Grid` and `GridRow`: Rows whose cells line up in columns.
- `.gridColumnAlignment(_:)`: Aligns one whole grid column.
- `.gridCellColumns(_:)`: Lets a cell span several columns.
- `.layoutPriority(_:)`: Decides which view shrinks last.

## Variants

### Push items apart with Spacer

A `Spacer` grows to fill the row, so the count stays left and the button stays right at any width; drag the slider to resize.

```swift
HStack {
    Text("12 items")
        .foregroundStyle(.secondary)
    Spacer()
    Button("Add Item", systemImage: "plus") { }
}
.padding(.horizontal)
```

### Labels and fields in a Grid

In a `Grid`, `.gridColumnAlignment(.trailing)` right-aligns the label column, and `.gridCellColumns(2)` lets the checkbox span the field and button columns.

```swift
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
```

### Choose what shrinks first

When the window gets narrow, `.layoutPriority(1)` keeps the file name whole and lets the folder path truncate instead.

```swift
HStack {
    Text("Budget 2027.numbers")
        .bold()
        .layoutPriority(1)
    Text("~/Documents/Finance/Planning")
        .foregroundStyle(.secondary)
}
.lineLimit(1)
```

**Note:** Every view starts at priority 0, and siblings share the space evenly. A higher priority gets its space before the others.

### A caption over a photo with ZStack

`ZStack(alignment: .bottomLeading)` draws later views on top and pins them to the corner you choose.

```swift
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
```

## Related

[form](form.md), [view-that-fits](view-that-fits.md), `windows-layout` (apple-design skill)
