---
id: text-label
title: Text & Label
platforms: [macOS]
availability: macOS 10.15+
docs: https://developer.apple.com/documentation/swiftui/text.md
hig: https://developer.apple.com/design/human-interface-guidelines/labels.md
---

# Text & Label

Shows read-only text, and pairs a short title with an icon in a label.

Also called: label, string, <p>, <span>, NSTextField, font, text style, bold, markdown, AttributedString.

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
    Text("Quarterly Report")
        .font(.headline)
    Text("Updated today")
        .foregroundStyle(.secondary)
    Label("Shared with 3 people", systemImage: "person.2")
}
```

**Note:** `Text` is like a `<span>`: it takes only the space it needs and wraps when its width is limited.

## Rules

- **Rank text with the label colors.** Primary for the main information, secondary for supporting details, tertiary for something unavailable. People see what matters first.
- **Avoid light weights, especially in small text.** Ultralight, Thin, and Light are hard to read at small sizes. Regular, Medium, Semibold, and Bold hold up.
- **Let people copy useful text.** Error messages, serial numbers, and addresses are often needed somewhere else. Make them selectable.
- **Prefer the system font and its text styles.** Text styles give you a consistent hierarchy of sizes and weights. Keep the number of typefaces small, even in a custom design.

## Pitfalls

- **Text styles have fixed sizes on the Mac.** `.body` is 13 points and `.largeTitle` is 26. The Mac doesn't support Dynamic Type.
- **A container can choose how a `Label` looks.** On the Mac, a toolbar shows only a label's icon unless you set `.labelStyle(.titleAndIcon)`.

## Key APIs

- `Text(_:)`: Read-only text, one or more lines.
- `.font(_:)`: A text style such as `.headline` or `.caption`.
- `.foregroundStyle(.secondary)`: Ranks text with the system's label colors.
- `.textSelection(.enabled)`: Lets people select and copy the text.
- `.lineLimit(_:)`: Caps the lines; the rest is truncated.
- `.truncationMode(_:)`: Where the ellipsis goes: `.head`, `.middle`, `.tail`.
- `Label(_:systemImage:)`: A title with an SF Symbol.
- `.labelStyle(_:)`: `.titleAndIcon`, `.titleOnly`, or `.iconOnly`.

## Variants

### Text people can copy

Add `.textSelection(.enabled)` to details people need elsewhere. They drag to select, then copy with ⌘C.

```swift
Grid(alignment: .leading) {
    GridRow {
        Text("Serial Number").foregroundStyle(.secondary)
        Text("C02XK1JHJG5J")
    }
    GridRow {
        Text("IP Address").foregroundStyle(.secondary)
        Text("192.168.1.24")
    }
}
.textSelection(.enabled)
```

**Note:** Put `.textSelection` on a container to make every `Text` inside it selectable. Buttons don't support selection.

### Dates, sizes, and percentages

Pass a value and a `format:` instead of building strings. The output follows the person's language and region.

```swift
let modified = Date.now

VStack(alignment: .leading) {
    Text(modified, format: .dateTime.month().day().year())
    Text(Int64(2_400_000), format: .byteCount(style: .file))
    Text(0.42, format: .percent)
}
```

### A long path in a short space

Use `.lineLimit(1)` with `.truncationMode(.middle)` so both ends of a path stay visible, and `.help` to show all of it on hover.

```swift
let path = "/Users/jo/Documents/Projects/Catalog/Exports/final-v3.pdf"

Text(path)
    .lineLimit(1)
    .truncationMode(.middle)
    .help(path)
    .frame(width: 240)
```

### Bold and italic inside a sentence

Make an `AttributedString` from Markdown to style part of a sentence. Attributes in the string win over modifiers on the `Text`.

```swift
let note = try! AttributedString(markdown: "Your trial ends **Friday**. Export your work _before then_.")

Text(note)
    .font(.title3)
```

### Label styles

A `Label` pairs a title with an icon. `.labelStyle` shows both, only the title, or only the icon.

```swift
HStack(spacing: 32) {
    Label("Rain", systemImage: "cloud.rain")
        .labelStyle(.titleAndIcon)
    Label("Rain", systemImage: "cloud.rain")
        .labelStyle(.titleOnly)
    Label("Rain", systemImage: "cloud.rain")
        .labelStyle(.iconOnly)
}
```

### A label with your own icon

Use `Label { } icon: { }` to put any view in the icon spot, like a person's initials.

```swift
Label {
    VStack(alignment: .leading) {
        Text("Jordan Lee")
        Text("Designer")
            .font(.subheadline)
            .foregroundStyle(.secondary)
    }
} icon: {
    Circle()
        .fill(.teal)
        .frame(width: 32, height: 32)
        .overlay(Text("JL").font(.caption.bold()).foregroundStyle(.white))
}
```

## Related

[image-symbols](image-symbols.md), [typography](typography.md), [labeled-content](labeled-content.md), [text-field](text-field.md), [writing](writing.md)
