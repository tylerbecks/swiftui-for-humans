---
id: view-that-fits
title: ViewThatFits
platforms: [iOS, iPadOS, macOS]
availability: iOS 16.0+, macOS 13.0+, visionOS 1.0+
docs: https://developer.apple.com/documentation/swiftui/viewthatfits.md
hig: https://developer.apple.com/design/human-interface-guidelines/layout.md
---

# ViewThatFits

Give it a few versions of a view, and it shows the first one that fits.

## Contents

- Default code
- Rules
- Pitfalls
- Key APIs
- Variants
- On macOS
- Related

## Default code

```swift
ViewThatFits(in: .horizontal) {
    Text("Free shipping on orders over $50")
    Text("Free shipping over $50")
    Text("Free shipping")
}
.font(.headline)
```

**Note:** List the options from largest to smallest. Each is measured at its ideal size, so text is checked on one line, unwrapped.

## Rules

- **Stack side-by-side items when they don't fit.** With large text or a narrow window, a row gets cramped. Switching to a column keeps every label on one line.
- **Show less, but keep every feature.** When space is tight, move actions into a menu rather than dropping them, so the app works the same at every size.

## Pitfalls

- **It's a container query, not a media query.** It reacts to the space its parent offers, not the screen. To adapt to the whole window, read the `horizontalSizeClass` environment value.
- **If nothing fits, you get the last option.** Make the last one the smallest, so it fits almost anywhere.

## Key APIs

`ViewThatFits { }`, `ViewThatFits(in: .horizontal)`, `.fixedSize()`, `\.horizontalSizeClass`, `AnyLayout`

## Variants

### Side by side, else stacked

Put an `HStack` first and a `VStack` second, so buttons sit in a row only when there's room.

```swift
ViewThatFits {
    HStack {
        Button("Not now") {}
            .buttonStyle(.bordered)
        Button("Turn on notifications") {}
            .buttonStyle(.borderedProminent)
    }
    VStack {
        Button("Turn on notifications") {}
            .buttonStyle(.borderedProminent)
        Button("Not now") {}
            .buttonStyle(.bordered)
    }
}
```

### Scroll only when needed

Use `ViewThatFits(in: .vertical)` with a `ScrollView` fallback, so only text that's too tall scrolls.

```swift
let terms = Text("By continuing you agree to the terms…")
    .font(.subheadline)
    .foregroundStyle(.secondary)

ViewThatFits(in: .vertical) {
    terms
    ScrollView { terms }
}
.frame(height: 120)
```

**Note:** The short text on top doesn't scroll or bounce. The long text below falls back to the `ScrollView`.

## On macOS

Adapt a layout to the window's actual width, since Mac windows resize freely.

### Rules

- **Keep every feature available at every size.** A narrow window can show fewer controls at once, but the rest should move into a menu, not disappear.
- **Plan for very wide and very narrow windows.** People resize Mac windows to any shape. Check your layout at the smallest size you allow and at the largest.
- **Change the layout in ways people recognize.** When space runs out, rearrange what's there, like stacking side-by-side items, rather than switching to a different design.

### Pitfalls

- **Size classes don't help on the Mac.** The horizontal size class there is always `.regular`, however narrow the window gets.
- **Keep geometry work light.** Geometry can change on every frame of a scroll or resize. Return a small value, like a `Bool`, so the action runs only when it flips.

### Key APIs

`ViewThatFits(in:)`, `.onGeometryChange(for:of:action:)`, `HStackLayout`, `VStackLayout`, `.frame(minWidth:minHeight:)`, `.defaultSize(width:height:)`

### Variants

#### Labels, then icons, then a menu

`ViewThatFits(in: .horizontal)` shows the first child whose ideal width fits; drag the slider to narrow the space.

```swift
ViewThatFits(in: .horizontal) {
    HStack {
        Button("New Note", systemImage: "square.and.pencil") { }
        Button("Share", systemImage: "square.and.arrow.up") { }
        Button("Delete", systemImage: "trash") { }
    }
    HStack {
        Button("New Note", systemImage: "square.and.pencil") { }
        Button("Share", systemImage: "square.and.arrow.up") { }
        Button("Delete", systemImage: "trash") { }
    }
    .labelStyle(.iconOnly)
    Menu("Actions", systemImage: "ellipsis.circle") {
        Button("New Note", systemImage: "square.and.pencil") { }
        Button("Share", systemImage: "square.and.arrow.up") { }
        Button("Delete", systemImage: "trash") { }
    }
    .fixedSize()
}
```

**Note:** List the children in order of preference, usually widest first. `in: .horizontal` checks only the width, so a child that's taller still counts as fitting.

More variants, left out to keep this file short: Stack the columns below a width you choose (macOS). Apple's docs: https://developer.apple.com/documentation/swiftui/viewthatfits.md

## Related

[geometry-reader](geometry-reader.md), [stacks](stacks.md), [layout-basics](layout-basics.md), [stacks-grid](stacks-grid.md), [split-views](split-views.md), [window-group](window-group.md), `windows-layout` (apple-design skill)
