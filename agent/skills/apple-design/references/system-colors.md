---
id: system-colors
title: System Colors
platforms: [iOS, iPadOS]
availability: iOS 13.0+, macOS 10.15+, visionOS 1.0+
docs: https://developer.apple.com/documentation/swiftui/color.md
hig: https://developer.apple.com/design/human-interface-guidelines/color.md
---

# System Colors

Colors that adapt to light mode, dark mode, and accessibility settings for you.

Also called: palette, theme, dark mode, css variables, design tokens, UIColor, label color, background color, colour, hex.

## Rules

- **Use semantic colors instead of fixed ones.** `.white` and `.black` never change, so a card that looks right in light mode glows in dark mode.
- **Don't rely on color alone.** Some people can't tell red from green. Pair color with a symbol or a word so the meaning survives.
- **Use each semantic color for its job.** Don't use `separator` for text or `secondaryLabel` as a fill. Each one is tuned for its role, and borrowed colors break in other modes.
- **Save the accent color for things people can tap.** If plain text uses the same color as buttons, people can't tell what's interactive.

## Pitfalls

- **Semantic colors describe a job, not a value.** `Color(.label)` and `Color(.systemBackground)` flip in dark mode on their own, like CSS custom properties under `prefers-color-scheme`.
- **Put custom colors in the asset catalog.** Add a Color Set with Any and Dark appearances, then use it as `Color("Brand")`. The `AccentColor` set there tints the whole app.

## Guide

Each swatch shows one color in **light** mode (left) and **dark** mode (right). You write one name and iOS picks the value. Tap a swatch to copy its code.

### Text

For text and symbols, from most to least important.

### Backgrounds and fills

Layer these from back to front. In dark mode the higher layers get *lighter*, so cards still stand out.

### Standard colors

For accents and meaning. Write them as `.red` or `Color.red`.

**Note:** Standard colors shift slightly in dark mode and again with Increase Contrast. Use the name, never a hex value copied from a screenshot.

## Key APIs

- `Color(.systemBackground)`: Any UIKit semantic color, wrapped for SwiftUI.
- `.foregroundStyle(.secondary)`: Text levels, from `.primary` down to `.quaternary`.
- `.background(.background)`: The screen's own background, as a style.
- `Color.red`: A standard color, tuned for light and dark mode.
- `.tint(_:)`: The accent color for controls inside a view.
- `Color("Brand")`: A custom color from the asset catalog.
- `@Environment(\.colorScheme)`: Reads whether the view is `.light` or `.dark`.

## Variants

### Text levels with hierarchical styles

Ask `.foregroundStyle(.secondary)` for a level instead of naming a label color; SwiftUI picks the shade.

```swift
VStack(alignment: .leading) {
    Text("Primary").foregroundStyle(.primary)
    Text("Secondary").foregroundStyle(.secondary)
    Text("Tertiary").foregroundStyle(.tertiary)
    Text("Quaternary").foregroundStyle(.quaternary)
}
.font(.title3.bold())
```

**Note:** On a [material](materials.md), these levels turn vibrant and blend with the blur. A fixed color like `.gray` doesn't.

### Brand color with tint

Set `.tint(_:)` on a container to recolor every button, toggle, and link inside it.

```swift
@State private var isOn = true

VStack(spacing: 16) {
    Toggle("Notifications", isOn: $isOn)
    Button("Continue") {}
        .buttonStyle(.borderedProminent)
    Link("Privacy Policy", destination: URL(string: "https://example.com")!)
}
.tint(.orange)
```

**Note:** To change the accent color for the whole app, set the `AccentColor` in the asset catalog instead.

## Related

`foreground-style` (swiftui-build skill), `gradients` (swiftui-build skill), [materials](materials.md), [typography](typography.md)
