---
id: text
title: Text
platforms: [iOS, iPadOS]
availability: iOS 13.0+, macOS 10.15+, visionOS 1.0+
docs: https://developer.apple.com/documentation/swiftui/text.md
hig: https://developer.apple.com/design/human-interface-guidelines/typography.md
---

# Text

Shows read-only text, styled with fonts and colors, with built-in Markdown and formatting.

Also called: label, <p>, <span>, paragraph, string, UILabel, font, text-overflow, ellipsis, markdown.

## Contents

- Default code
- Rules
- Pitfalls
- Key APIs
- Variants
- Related

## Default code

```swift
VStack(alignment: .leading, spacing: 4) {
    Text("Weekend in Lisbon")
        .font(.headline)
    Text("3 nights · Arrives Friday at 6:40 PM")
        .font(.subheadline)
        .foregroundStyle(.secondary)
}
```

**Note:** A bold title over a smaller, secondary line is the most common text pair in iOS apps.

## Rules

- **Use text styles, not fixed sizes.** `.headline` and `.body` grow with the person's text size setting. `.font(.system(size: 15))` stays the same and gets hard to read.
- **Show hierarchy with size, weight, and color.** A bold title over a smaller, secondary line tells people what to read first. Same-looking lines run together.
- **Avoid light weights for small text.** Thin strokes fade at small sizes. Use Regular or heavier for anything at body size or below.
- **Let important text wrap instead of truncating.** With larger text sizes, a one-line limit cuts off words people need. Truncate only when they can open the full text.

## Pitfalls

- **Text wraps by default.** It takes as many lines as it needs. `.lineLimit(2)` caps it and adds “…”, like CSS `text-overflow: ellipsis`.
- **Style a whole group at once.** `.font`, `.foregroundStyle`, and `.multilineTextAlignment` on a `VStack` apply to every `Text` inside it.
- **For fonts and the type scale, see Typography (`typography`, apple-design skill).** It shows every text style at its real size.

## Key APIs

- `Text(_:)`: Shows a string. Literals support Markdown and are localized.
- `.font(_:)`: A text style like `.headline`, which scales with Dynamic Type.
- `.bold()`, `.italic()`: Quick weight and style changes. `.fontWeight(_:)` for others.
- `.foregroundStyle(_:)`: The color, such as `.secondary` for less important text.
- `.lineLimit(_:)`: The most lines to show before truncating.
- `.multilineTextAlignment(_:)`: `.leading`, `.center`, or `.trailing` for wrapped lines.
- `Text(_:format:)`: Formats a number or date for the person's locale.
- `.textSelection(.enabled)`: Lets people select and copy the text.

## Variants

### Markdown

A string literal in `Text` renders inline Markdown: bold, italic, code, strikethrough, and links.

```swift
Text("**Bold**, *italic*, `code`, ~~strike~~, and a [link](https://developer.apple.com).")
```

**Important:** Only literals are parsed. A `String` variable shows its asterisks as-is; use `Text(LocalizedStringKey(string))` to render its Markdown.

### Dates and numbers

Pass a value and a `format:` to `Text`, and it formats the value for the person's locale.

```swift
let price = 1299.0
let date = Date.now

VStack(alignment: .leading, spacing: 8) {
    Text(price, format: .currency(code: "USD"))
    Text(0.427, format: .percent.precision(.fractionLength(1)))
    Text(1_250_000, format: .number.notation(.compactName))
    Text(date, format: .dateTime.weekday(.wide).month().day())
    Text(date, style: .time)
    Text(date.addingTimeInterval(-90), style: .relative)
}
```

**Note:** The `.relative` and `.timer` styles update themselves every second, with no timer code.

### Mixing styles in one line

Interpolate a styled `Text` inside another to style part of a sentence. It still wraps as one paragraph.

```swift
Text("Your order is \(Text("on its way").bold().foregroundStyle(.green)) and arrives \(Text("tomorrow").italic()).")
```

### Selectable text

Add `.textSelection(.enabled)` so people can long-press to copy an order number or address.

```swift
VStack(alignment: .leading, spacing: 4) {
    Text("Order number")
        .font(.subheadline)
        .foregroundStyle(.secondary)
    Text("W-48213-7790")
        .font(.title3.monospaced())
}
.textSelection(.enabled)
```

## Related

[font](font.md), `typography` (apple-design skill), [label](label.md), [text-field](text-field.md)
