---
id: sf-symbols
title: SF Symbols
platforms: [iOS, iPadOS, macOS]
availability: iOS 13.0+, macOS 11.0+, visionOS 1.0+
docs: https://developer.apple.com/documentation/swiftui/image/init(systemname:).md
hig: https://developer.apple.com/design/human-interface-guidelines/sf-symbols.md
reviewed: October 2026
---

# SF Symbols

Thousands of built-in icons that match the system font and scale with text.

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
Image(systemName: "heart.fill")
    .font(.title)
    .foregroundStyle(.pink)

Label("Favorites", systemImage: "heart.fill")
```

**Important:** Size a symbol with `.font`, not `.resizable()` and `.frame`. That keeps it aligned with text and at the right weight.

## Rules

- **Let symbols match the text beside them.** Symbols come in the same weights as San Francisco. Set the size and weight with `.font` so the icon and its label look like one piece.
- **Use variable color for change, not depth.** A variable value shows a level that changes over time, like signal or volume. To give a symbol depth, use `.hierarchical` instead.
- **Use a symbol for its usual meaning.** People know `trash` means delete and `square.and.arrow.up` means share. Reusing them for something else confuses people.
- **Check the rendering mode at small sizes.** Fine layers in `.multicolor` or `.palette` can blur together in a toolbar. Use `.monochrome` if details get lost.

## Pitfalls

- **Find names in the SF Symbols app.** It's free for Mac and shows each symbol's minimum iOS version. An unknown name draws nothing and logs a warning.
- **To animate a symbol, see Symbol Effects (`symbol-effects`, swiftui-build skill).** Bounce, pulse, and replace work on any symbol.

## Key APIs

`Image(systemName:)`, `Label(_:systemImage:)`, `.font(_:)`, `.imageScale(_:)`, `.symbolRenderingMode(_:)`, `.symbolVariant(_:)`, `Image(systemName:variableValue:)`

## Variants

### Symbols next to text

Use `Label` to pair a symbol with text, or put an `Image` right inside a `Text`.

```swift
VStack(alignment: .leading, spacing: 12) {
    Label("Settings", systemImage: "gearshape.fill")
    Label("Downloads", systemImage: "arrow.down.circle")
        .font(.title2.bold())
    Text("Rated \(Image(systemName: "star.fill")) 4.8")
        .foregroundStyle(.orange)
}
```

**Note:** An `Image` inside `Text` flows and wraps like a word, which suits ratings and inline hints.

## On macOS

Icons drawn to match the system font, for toolbars, sidebars, and menus.

### Rules

- **Let the symbol match the text.** Each symbol weight matches a weight of the system font. Leave the weight to the font, so a symbol and its label look like one piece.
- **Use plain symbols in the toolbar.** Toolbar items already get a shape and hover and selection states from the system. Symbols with a circle or square around them add a second border.
- **In a menu, give every item in a group an icon or none.** Icons help people find common actions faster, but a group where only some items have one looks unbalanced. Skip the icon if no symbol clearly fits.
- **Use the standard symbol for a common action.** Share is `square.and.arrow.up`, Delete is `trash`, and Search is `magnifyingglass` everywhere on the Mac. A different symbol for the same action makes people stop and think.
- **Check the rendering mode at the size you use.** Fine layers that look good large can blur together small or on a busy background. Try another mode if the details get lost.

### Pitfalls

- **Check which system version a symbol needs.** New symbols and features each year don't exist on older releases. The SF Symbols app shows each symbol's availability.
- **Symbols aren't for app icons or logos.** Apple's terms for SF Symbols don't allow them, or look-alikes, in app icons, logos, or other trademarks.

### Key APIs

`.symbolVariant(.fill)`, `.symbolEffect(_:value:)`

### Variants

#### A symbol with its label

Use `Label` so SwiftUI can show the symbol, the title, or both, as a sidebar, toolbar, or menu expects.

```swift
VStack(alignment: .leading, spacing: 8) {
    Label("Downloads", systemImage: "arrow.down.circle")
    Label("Shared", systemImage: "person.2")
    Label("Trash", systemImage: "trash")
}
```

#### Adjust emphasis with the scale

`.imageScale(_:)` makes a symbol smaller or larger than its text without changing the weight they share.

```swift
HStack(spacing: 24) {
    Label("Small", systemImage: "bell")
        .imageScale(.small)
    Label("Medium", systemImage: "bell")
        .imageScale(.medium)
    Label("Large", systemImage: "bell")
        .imageScale(.large)
}
```

More variants, left out to keep this file short: Variants, Add depth with a rendering mode (macOS), Show a level with variable color (macOS), Confirm an action with an animation (macOS). Apple's docs: https://developer.apple.com/documentation/swiftui/image/init(systemname:).md

## Related

`image` (swiftui-build skill), `label` (swiftui-build skill), `symbol-effects` (swiftui-build skill), [typography](typography.md), `image-symbols` (swiftui-build skill), `toolbar` (swiftui-build skill), `menu` (swiftui-build skill), [app-icons](app-icons.md), [motion](motion.md)
