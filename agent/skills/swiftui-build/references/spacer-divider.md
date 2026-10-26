---
id: spacer-divider
title: Spacer & Divider
platforms: [iOS, iPadOS]
availability: iOS 13.0+, macOS 10.15+, visionOS 1.0+
docs: https://developer.apple.com/documentation/swiftui/spacer.md
hig: https://developer.apple.com/design/human-interface-guidelines/layout.md
---

# Spacer & Divider

Spacer pushes views apart in a stack; Divider draws a thin line between them.

Also called: justify-content, space-between, margin auto, flex-grow, hr, separator, line, gap.

## Contents

- Default code
- Rules
- Pitfalls
- Key APIs
- Variants
- Related

## Default code

```swift
HStack {
    Text("Recent")
        .font(.headline)
    Spacer()
    Button("See All") {}
}
```

**Important:** A `Spacer` only works inside a stack. It grows along the stack's axis: sideways in an `HStack`, up and down in a `VStack`.

## Rules

- **Group with space before you reach for lines.** Extra space between groups already shows structure. A divider under every row adds noise without adding meaning.
- **Put the main item on the leading side.** People read from the leading edge, so put the title there and push secondary actions to the trailing edge with a `Spacer`.

## Pitfalls

- **Several spacers split the free space evenly.** One before, between, and after the views gives you `space-evenly`.
- **A spacer keeps a small gap by default.** Use `Spacer(minLength: 0)` when the views should be allowed to touch.
- **Lists and forms draw their own separators.** Don't add a `Divider` between `List` or `Form` rows.

## Key APIs

- `Spacer()`: Takes all the free space along the stack's axis.
- `Spacer(minLength:)`: Sets the smallest gap the spacer keeps.
- `Divider()`: A thin line: horizontal in a `VStack`, vertical in an `HStack`.
- `.frame(maxWidth:alignment:)`: Pushes a view to one edge without a spacer.
- `.fixedSize(horizontal:vertical:)`: Keeps a row with dividers only as tall as its content.

## Variants

### Pin a button to the bottom

A `Spacer` in a `VStack` pushes the button down, like a welcome screen's Continue button.

```swift
VStack(spacing: 12) {
    Image(systemName: "hand.wave.fill")
        .font(.system(size: 44))
        .foregroundStyle(.tint)
    Text("Welcome")
        .font(.title2.bold())
    Spacer()
    Button("Continue") {}
        .buttonStyle(.borderedProminent)
}
.padding()
.frame(height: 240)
```

### Stats with vertical dividers

In an `HStack`, a `Divider` is vertical and stretches to the stack's full height.

```swift
HStack(spacing: 20) {
    VStack {
        Text("128").font(.title3.bold())
        Text("Posts").font(.caption)
    }
    Divider()
    VStack {
        Text("4.2k").font(.title3.bold())
        Text("Followers").font(.caption)
    }
    Divider()
    VStack {
        Text("310").font(.title3.bold())
        Text("Following").font(.caption)
    }
}
.fixedSize(horizontal: false, vertical: true)
```

**Important:** Without `.fixedSize` on the vertical axis, the dividers grow as tall as the space offered. With it, the row is only as tall as its text.

### "Or" separator

Wrap each `Divider` in a `VStack` so it stays horizontal beside the word "or".

```swift
HStack(spacing: 12) {
    VStack { Divider() }
    Text("or")
        .font(.footnote)
        .foregroundStyle(.secondary)
    VStack { Divider() }
}
```

## Related

[stacks](stacks.md), [layout-basics](layout-basics.md), [frame](frame.md)
