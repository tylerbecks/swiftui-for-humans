---
id: padding
title: padding
platforms: [iOS, iPadOS]
availability: iOS 13.0+, macOS 10.15+, visionOS 1.0+
docs: https://developer.apple.com/documentation/swiftui/view/padding(_:_:).md
hig: https://developer.apple.com/design/human-interface-guidelines/layout.md
---

# padding

Adds space around a view, on every edge or only the edges you pick.

Also called: margin, spacing, inset, gutter, padding-left, EdgeInsets, whitespace, layoutMargins.

## Default code

```swift
Text("Weekly summary")
    .padding()
    .background(.fill.tertiary, in: .rect(cornerRadius: 12))
```

**Note:** `.padding()` with no number uses the system default, usually 16pt on iPhone. Prefer it to a hard-coded value so spacing matches the platform.

## Rules

- **Give content room to breathe.** Text pressed against the edge of its card looks cramped and is harder to scan. The default `.padding()` matches the margins people see across iOS.
- **Use space to group related items.** Keep related items close and put more space between groups, so people see the structure without extra dividers.
- **Keep padding consistent across a screen.** Cards and rows with the same insets line up and look like one design. Pick a few values and reuse them.

## Pitfalls

- **SwiftUI has no `margin`.** Padding outside a `.background` acts like a margin, and padding inside it acts like CSS padding. See [Modifier Order](modifier-order.md).
- **Use `leading` and `trailing`, not left and right.** They flip automatically in right-to-left languages like Arabic and Hebrew.

## Key APIs

- `.padding()`: The system default amount on every edge.
- `.padding(_:)`: A fixed amount in points on every edge.
- `.padding(_:_:)`: Pick edges, like `.horizontal` or `[.top, .leading]`, and an amount.
- `EdgeInsets`: A different amount on each of the four edges.
- `.contentMargins(_:for:)`: Insets the content of a `ScrollView` or `List`.

## Variants

### Card content

Put `.padding()` before `.background` so the card's color fills the space around its content.

```swift
VStack(alignment: .leading, spacing: 4) {
    Text("Weekly summary")
        .font(.headline)
    Text("You walked 42 km this week.")
        .foregroundStyle(.secondary)
}
.padding()
.background(.fill.tertiary, in: .rect(cornerRadius: 16))
```

### Pill with different edges

Chain `.padding(.horizontal, _:)` and `.padding(.vertical, _:)` for a wide tag or chip.

```swift
Text("Design")
    .font(.subheadline.weight(.medium))
    .padding(.horizontal, 14)
    .padding(.vertical, 6)
    .background(.blue.opacity(0.15), in: .capsule)
```

### Different amount on each edge

Pass `EdgeInsets` to set all four edges in one call, like CSS `padding: 8px 24px 20px 12px`.

```swift
Text("Custom insets")
    .padding(EdgeInsets(top: 8, leading: 12, bottom: 20, trailing: 24))
    .background(.orange.opacity(0.25))
```

## Related

[modifier-order](modifier-order.md), [frame](frame.md), [background-overlay](background-overlay.md), [spacer-divider](spacer-divider.md)
