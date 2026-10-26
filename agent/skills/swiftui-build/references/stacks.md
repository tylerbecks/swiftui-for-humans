---
id: stacks
title: Stacks
platforms: [iOS, iPadOS]
availability: iOS 13.0+, macOS 10.15+, visionOS 1.0+
docs: https://developer.apple.com/documentation/swiftui/building-layouts-with-stack-views.md
hig: https://developer.apple.com/design/human-interface-guidelines/layout.md
---

# Stacks

Arrange views in a column, a row, or layered on top of each other.

Also called: flexbox, flex-direction, row, column, div, UIStackView, z-index, position absolute, gap, align-items.

## Contents

- Default code
- Rules
- Pitfalls
- Key APIs
- Variants
- Related

## Default code

```swift
VStack(alignment: .leading) {
    Text("Alex Chen")
        .font(.headline)
    Text("Online now")
        .foregroundStyle(.secondary)
}
```

**Note:** A stack is only as big as its children. To fill the screen's width, add `.frame(maxWidth: .infinity)` or a `Spacer`.

## Rules

- **Line related text up on one edge.** A shared leading edge is easy to scan. Centered text of different lengths makes the eye jump around.
- **Use space to show what belongs together.** Keep related items close and put more room between groups, so people see the structure without lines or boxes.
- **Leave room for larger text.** People can make text much bigger with Dynamic Type. Let rows grow taller, and switch an `HStack` to a `VStack` when it no longer fits.

## Pitfalls

- **Leave out `spacing` to get the system default.** SwiftUI picks spacing that suits the views and platform. Pass `0` only when children should touch.
- **`alignment` works across the stack's axis.** A `VStack` takes a horizontal alignment like `.leading`; an `HStack` takes a vertical one like `.top`.
- **Stacks are like flexbox with `flex-direction`.** `VStack` is a column, `HStack` a row, and `spacing` is `gap`. There's no wrapping; use [Lazy Grids](lazy-grids.md) or [ViewThatFits](view-that-fits.md) instead.

## Key APIs

- `VStack(alignment:spacing:)`: A column. Alignment is `.leading`, `.center`, or `.trailing`.
- `HStack(alignment:spacing:)`: A row. Alignment is `.top`, `.center`, `.bottom`, or a baseline.
- `ZStack(alignment:)`: Layers children; later ones draw on top.
- `LazyVStack` / `LazyHStack`: Create children only as they scroll on screen.
- `.frame(maxWidth: .infinity)`: Stretches a stack to fill the width, like `width: 100%`.
- `.overlay(alignment:)`: Puts one view on top of another, sized to the base view.

## Variants

### Profile row

The most common iOS layout: an `HStack` with an icon, a leading `VStack` of text, and a `Spacer`.

```swift
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
```

### Badge on an icon

A `ZStack` with `.topTrailing` alignment pins a badge to the icon's corner, drawn on top.

```swift
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
```

**Note:** When one view only decorates another, `.overlay(alignment: .topTrailing)` does the same job and sizes itself to the icon instead of the larger of the two.

### Line up text on its baseline

Align an `HStack` on `.firstTextBaseline` so text of different sizes sits on one line, like a price.

```swift
HStack(alignment: .firstTextBaseline, spacing: 4) {
    Text("$")
        .font(.title3)
    Text("249")
        .font(.system(size: 56, weight: .bold))
    Text("/ year")
        .foregroundStyle(.secondary)
}
```

### Long scrolling column

Put a `LazyVStack` in a `ScrollView` so rows are created only as they scroll into view.

```swift
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
```

**Note:** For rows with swipe actions, selection, and separators, use a [List](list.md) instead.

## Related

[layout-basics](layout-basics.md), [spacer-divider](spacer-divider.md), [grid](grid.md), [lazy-grids](lazy-grids.md)
