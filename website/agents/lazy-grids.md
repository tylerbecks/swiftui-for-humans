---
id: lazy-grids
title: Lazy Grids
platforms: [iOS, iPadOS]
availability: iOS 14.0+, macOS 11.0+, visionOS 1.0+
docs: https://developer.apple.com/documentation/swiftui/lazyvgrid.md
hig: https://developer.apple.com/design/human-interface-guidelines/collections.md
---

# Lazy Grids

Scrolling grids of many items, like a photo library, built only as they appear.

Also called: UICollectionView, collection view, photo grid, gallery, grid-template-columns, auto-fill, minmax, masonry, tiles.

## Contents

- Default code
- Rules
- Pitfalls
- Key APIs
- Variants
- Related

## Default code

```swift
let columns = [GridItem(.adaptive(minimum: 100))]

ScrollView {
    LazyVGrid(columns: columns, spacing: 12) {
        ForEach(1...100, id: \.self) { i in
            RoundedRectangle(cornerRadius: 10)
                .fill(.blue.gradient)
                .frame(height: 100)
                .overlay { Text("\(i)").foregroundStyle(.white) }
        }
    }
    .padding()
}
```

**Important:** Lazy grids don't scroll on their own. Put a `LazyVGrid` in a `ScrollView`, and a `LazyHGrid` in a `ScrollView(.horizontal)`.

## Rules

- **Show text in a list, not a grid.** Grids are best for images. Text in tiles is harder to scan than the same text in rows.
- **Keep to a simple, regular grid.** People know how a grid of equal tiles works. An unusual layout draws attention to itself instead of the content.
- **Don't change the layout while people are using it.** Changing the column count mid-scroll makes people lose their place. Change it only when they ask, like with a zoom control.

## Pitfalls

- **`.adaptive` is CSS `auto-fill`.** `GridItem(.adaptive(minimum: 100))` works like CSS `auto-fill` with `minmax(100px, 1fr)`: as many columns as fit.
- **Columns can't size to their content.** A lazy grid doesn't measure every cell. For a small table whose columns fit their text, use [Grid](grid.md).

## Key APIs

- `LazyVGrid(columns:spacing:)`: Scrolls vertically; you describe the columns.
- `LazyHGrid(rows:spacing:)`: Scrolls sideways; you describe the rows.
- `GridItem(.flexible())`: One column that shares the width equally.
- `GridItem(.adaptive(minimum:))`: As many columns as fit, each at least this wide.
- `GridItem(.fixed(_:))`: One column of an exact width.
- `pinnedViews: [.sectionHeaders]`: Makes `Section` headers stick while scrolling.

## Variants

### Photo grid

Use `.adaptive` columns, 2-point spacing, and `.aspectRatio(1, contentMode: .fit)` for square photo cells.

```swift
let columns = [GridItem(.adaptive(minimum: 80), spacing: 2)]

ScrollView {
    LazyVGrid(columns: columns, spacing: 2) {
        ForEach(0..<30, id: \.self) { i in
            Color(hue: Double(i) / 30, saturation: 0.5, brightness: 0.9)
                .aspectRatio(1, contentMode: .fit)
        }
    }
}
.frame(height: 240)
```

**Note:** Adaptive columns adjust themselves, so the grid gains columns when you rotate the phone or widen an iPad window.

### Sticky section headers

Wrap items in a `Section` and pass `pinnedViews: [.sectionHeaders]` so each header sticks while you scroll.

```swift
ScrollView {
    LazyVGrid(
        columns: [GridItem(.adaptive(minimum: 60))],
        pinnedViews: [.sectionHeaders]
    ) {
        ForEach(["Fruit", "Vegetables", "Snacks"], id: \.self) { name in
            Section {
                ForEach(0..<8, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.fill.secondary)
                        .frame(height: 60)
                }
            } header: {
                Text(name)
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 6)
                    .background(.background)
            }
        }
    }
}
.frame(height: 240)
```

**Note:** Give a pinned header a background, or the cells scroll visibly behind its text.

### Two-row shelf

A `LazyHGrid` with two `.flexible()` rows scrolls sideways, like an App Store shelf.

```swift
let rows = [GridItem(.flexible()), GridItem(.flexible())]

ScrollView(.horizontal) {
    LazyHGrid(rows: rows, spacing: 12) {
        ForEach(0..<16, id: \.self) { i in
            Label("App \(i + 1)", systemImage: "app.fill")
                .frame(width: 140, alignment: .leading)
        }
    }
    .padding(.horizontal)
}
.scrollIndicators(.hidden)
.frame(height: 90)
```

## Related

[grid](grid.md), [scroll-view](scroll-view.md), [stacks](stacks.md)
