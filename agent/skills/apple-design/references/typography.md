---
id: typography
title: Typography
platforms: [iOS, iPadOS, macOS]
availability: iOS 13.0+, macOS 10.15+, visionOS 1.0+
docs: https://developer.apple.com/documentation/swiftui/font.md
hig: https://developer.apple.com/design/human-interface-guidelines/typography.md
reviewed: October 2026
---

# Typography

Apple's built-in text styles, which resize automatically when people change their text size.

## Contents

- Rules
- Pitfalls
- Guide
- Key APIs
- Variants
- On macOS
- Related

## Rules

- **Use text styles, not fixed point sizes.** Many people raise their text size. A fixed size ignores that setting and stays small.
- **Avoid light weights for small text.** Ultralight, Thin, and Light strokes are hard to see at small sizes. Use Regular or heavier.
- **Let layouts grow with the text.** Allow text to wrap instead of truncating, and stack side-by-side items at accessibility sizes.
- **Use few typefaces.** One family with a few styles and weights shows hierarchy clearly. Mixing many fonts makes a screen feel unplanned.

## Pitfalls

- **Text styles are your type scale.** They work like `h1` and `body` in a CSS reset, but they also follow the person's text size setting, like `rem`.
- **Test big sizes without changing Settings.** Add `.dynamicTypeSize(.accessibility3)` to a preview, or use the Variants button in Xcode's canvas.

## Guide

iOS has eleven **text styles**. Pick one by its *role*, like a title, the body, or a caption, and iOS sets the size, weight, and line spacing. Drag the slider to see each one grow with the person's text size setting.

**Important:** `.font(.system(size: 17))` is a fixed size, like `px` in CSS, and ignores the text size setting. Use a text style, or `.system(.body)`, so it scales like `rem`.

### Weight, design, and width

Start from a text style, then adjust it. Every combination still scales with Dynamic Type. Widths only exist for the default San Francisco design, so they have no effect on `.serif` or `.rounded`.

```swift
Text("Hello, SwiftUI")
    .font(.largeTitle)
    .fontWeight(.bold)
    .fontDesign(.rounded)
```

## Key APIs

`.font(.body)`, `.fontWeight(_:)`, `.fontDesign(_:)`, `.font(.custom(_:size:relativeTo:))`, `@ScaledMetric`, `.monospacedDigit()`, `@Environment(\.dynamicTypeSize)`

## Variants

### Custom font that still scales

Pass `relativeTo:` to `.custom(_:size:relativeTo:)` so your font grows with that text style.

```swift
Text("The quick brown fox")
    .font(.custom("Georgia", size: 20, relativeTo: .title3))
```

**Note:** A bundled font also needs its file listed under `UIAppFonts` in Info.plist. Georgia ships with iOS.

## On macOS

Mac text is smaller than iPhone text: 13 points by default, and 10 at the smallest.

### Rules

- **Keep text at 10 points or larger.** 13 points is the Mac's default size, and 10 is the smallest Apple recommends. Footnote and caption styles are already 10 points.
- **Avoid light weights.** Ultralight, Thin, and Light are hard to read, especially at small sizes. Stay with Regular, Medium, Semibold, or Bold.
- **Show hierarchy with size, weight, and color.** A heading in `.headline` over body text in `.secondary` gray reads at a glance. Use the built-in styles so your levels match other Mac apps.
- **Use as few typefaces as you can.** Mixing several fonts muddies the hierarchy and makes an app look unfinished. The system font in a few styles covers most apps.
- **Give long text room between lines.** Loose leading helps people keep their place across wide paragraphs. Tighten it only for one or two lines in a cramped row, never for three or more.

### Pitfalls

- **Custom fonts follow the same sizes.** Keep body text at 13 points and the smallest text at 10, and go larger if the font is thin.

### Key APIs

`.font(.headline)`, `.foregroundStyle(.secondary)`, `.font(.body.monospaced())`, `.font(.body.leading(.loose))`

### Variants

#### Build a hierarchy from text styles

Use `.headline` for the title, the default `.body` for the main line, and `.subheadline` in `.secondary` for details.

```swift
VStack(alignment: .leading, spacing: 2) {
    Text("Weekly Planning")
        .font(.headline)
    Text("Agenda for Monday's meeting")
    Text("Today, 9:41 AM")
        .font(.subheadline)
        .foregroundStyle(.secondary)
}
```

#### Emphasize with weight

Use `.fontWeight(.semibold)` to stress a word or a total without adding another size to the window.

```swift
HStack {
    Text("Total")
    Spacer()
    Text("$128.40")
        .fontWeight(.semibold)
}
.frame(width: 220)
```

More variants, left out to keep this file short: Stack items at large sizes, Scale your own numbers, Numbers that don't jump, Keep changing numbers still (macOS), Monospaced text for code (macOS), Loose leading for long passages (macOS). Apple's docs: https://developer.apple.com/documentation/swiftui/font.md

## Related

`font` (swiftui-build skill), `text` (swiftui-build skill), [system-colors](system-colors.md), [sf-symbols](sf-symbols.md), `text-label` (swiftui-build skill), [writing](writing.md), [contrast-transparency](contrast-transparency.md)
