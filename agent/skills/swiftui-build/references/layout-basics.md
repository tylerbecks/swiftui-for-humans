---
id: layout-basics
title: How Layout Works
platforms: [iOS, iPadOS]
availability: iOS 13.0+, macOS 10.15+, visionOS 1.0+
docs: https://developer.apple.com/documentation/swiftui/layout-fundamentals.md
hig: https://developer.apple.com/design/human-interface-guidelines/layout.md
---

# How Layout Works

A parent offers its child a size, the child picks its own, and the parent places it.

Also called: box model, css layout, width 100%, sizing, auto layout, constraints, flexbox, proposed size.

## Contents

- Rules
- Pitfalls
- Guide
- Key APIs
- Variants
- Related

## Rules

- **Let text set its own size.** People can make text much larger with Dynamic Type. A hard-coded width or height cuts it off; a flexible frame lets it wrap.
- **Base layout on the space you have, not the device.** An iPhone app can run in a narrow iPad window or rotate. Read the size class or use `ViewThatFits` instead of checking the model.

## Pitfalls

- **Shapes and colors are greedy.** `Color.blue` and `Rectangle()` take all the space they're offered, so give them a `.frame` or put them in a `.background`.
- **Write your own container with the `Layout` protocol.** When stacks and grids aren't enough, it's the same propose, choose, place conversation, in code.

## Guide

Forget the CSS box model for a moment. SwiftUI layout is a short conversation between a parent and each child, in three steps:

### See it happen

Drag the slider to change the offer (the dashed box). The colored outline is the size the child chose. Each child answers the same offer differently.

```swift
Text("Hello, layout")
    .frame(width: 240, height: 120) // the parent's offer
```

**Note:** The child always has the last word on its size. That's why `Text` hugs its words while `Color` fills everything it's offered.

## Key APIs

- `.frame(maxWidth: .infinity)`: Fills the offered width, like `width: 100%`.
- `.frame(width:height:)`: Offers its child an exact size.
- `.padding(_:)`: Offers less space in, reports a bigger size out.
- `.fixedSize()`: Ignores the offer and uses the view's ideal size.
- `.layoutPriority(_:)`: Gives a sibling first claim on space in a stack.
- `Layout`: A protocol for writing your own container.

## Variants

### Fill the width

Views hug their content, so use `.frame(maxWidth: .infinity)` to get CSS's `width: 100%`.

```swift
Text("Full width")
    .padding()
    .frame(maxWidth: .infinity)
    .background(.blue.opacity(0.2), in: .rect(cornerRadius: 10))
```

**Note:** Pass an `alignment:` such as `.leading` to keep the text at one edge of the wider frame.

### Text wraps when offered less

`Text` fits the width it's offered, wrapping onto more lines and growing taller.

```swift
Text("SwiftUI lays out text to fit the space it's offered.")
    .frame(width: 140)
    .border(.blue)
```

### Ignore the offer with fixedSize

`.fixedSize()` makes a view use its ideal size, so this text overflows instead of wrapping.

```swift
Text("This line never wraps, even when it is too long")
    .fixedSize()
    .frame(width: 140)
    .border(.blue)
```

**Note:** Pass `horizontal: false, vertical: true` to let text wrap onto more lines but never truncate.

### Modifiers are parents too

Each modifier wraps the view above it, so `.padding(20)` offers its child 40 points less.

```swift
// Each modifier wraps the line above it
Text("Padded")
    .foregroundStyle(.black)
    .padding(20)
    .background(.yellow)
    .border(.blue)
```

**Note:** That's why order matters: the background here covers the padding. See [Modifier Order](modifier-order.md).

## Related

[stacks](stacks.md), [frame](frame.md), [padding](padding.md), [modifier-order](modifier-order.md)
