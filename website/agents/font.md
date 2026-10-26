---
id: font
title: font
platforms: [iOS, iPadOS]
availability: iOS 13.0+, macOS 10.15+, visionOS 1.0+
docs: https://developer.apple.com/documentation/swiftui/view/font(_:).md
hig: https://developer.apple.com/design/human-interface-guidelines/typography.md
---

# font

Sets the size, weight, and design of text, and scales it with the user's text size.

Also called: font-size, font-weight, font-family, bold, typography, text size, Dynamic Type, h1, UIFont, monospace.

## Contents

- Default code
- Rules
- Pitfalls
- Key APIs
- Variants
- Related

## Default code

```swift
VStack(alignment: .leading, spacing: 2) {
    Text("Trip to Lisbon")
        .font(.headline)
    Text("May 4 – 9 · 3 travelers")
        .font(.subheadline)
        .foregroundStyle(.secondary)
}
```

**Important:** `.system(size:)` doesn't grow with Dynamic Type, the text size people pick in Settings. Prefer a text style like `.headline`.

## Rules

- **Show hierarchy with size, weight, and color.** A bold title over secondary detail tells people what to read first. Text that all looks the same makes them read every word.
- **Avoid light weights at small sizes.** Ultralight and Thin strokes get hard to read when text is small. Use Regular or heavier for body and caption text.
- **Use text styles instead of fixed sizes.** Many people change their text size in Settings. Text styles follow that choice, and a hard-coded `.system(size:)` doesn't.
- **Stick to one or two typefaces.** The system font with a rounded or serif accent is plenty. More fonts make a screen look unplanned.

## Pitfalls

- **`.font` flows down to every text inside a container.** The closest one wins, so a child can override it, like CSS `font` inheritance.
- **Adjust a font without replacing it.** `fontWeight`, `fontDesign`, `fontWidth`, and `italic` change the current font, so they combine with a style set further up.

## Key APIs

- `.font(.headline)`: A text style that scales with Dynamic Type.
- `.font(.title.weight(.semibold))`: A text style at a different weight.
- `.fontWeight(_:)` / `.bold()`: Changes the weight of the current font.
- `.fontDesign(_:)`: `.rounded`, `.serif`, or `.monospaced`.
- `.monospacedDigit()`: Equal-width digits, so numbers don't shift.
- `.custom(_:size:relativeTo:)`: A custom font that still scales.

## Variants

### The type scale

Use the built-in text styles, from `.largeTitle` to `.caption2`, like a design system's type ramp.

```swift
VStack(alignment: .leading, spacing: 4) {
    Text("Large Title").font(.largeTitle)
    Text("Title").font(.title)
    Text("Title 2").font(.title2)
    Text("Title 3").font(.title3)
    Text("Headline").font(.headline)
    Text("Body").font(.body)
    Text("Callout").font(.callout)
    Text("Subheadline").font(.subheadline)
    Text("Footnote").font(.footnote)
    Text("Caption").font(.caption)
    Text("Caption 2").font(.caption2)
}
```

### Numbers that don't jiggle

Add `.monospacedDigit()` so timers and counters don't shift sideways as the digits change.

```swift
@State private var start = Date.now

Text(start, style: .timer)
    .font(.largeTitle.weight(.medium))
    .monospacedDigit()
```

### A custom font that still scales

Use `.custom(_:size:relativeTo:)` so a custom font grows with Dynamic Type like a text style.

```swift
Text("Once upon a time")
    .font(.custom("Georgia", size: 24, relativeTo: .title2))
```

**Note:** Fonts you bundle need to be listed in your app's Info.plist under `UIAppFonts` before `.custom` can find them.

### Mixed styles in one line

Write Markdown in a `Text` string literal for inline bold, italic, and code.

```swift
Text("Tap **Save** to keep _all_ your `changes`.")
```

**Important:** Markdown only works on literals. For a `String` variable, use `Text(LocalizedStringKey(value))` or `AttributedString(markdown:)`.

## Related

[typography](typography.md), [text](text.md), [foreground-style](foreground-style.md), [label](label.md)
