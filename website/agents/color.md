---
id: color
title: Color & Accent
platforms: [macOS]
docs: https://developer.apple.com/documentation/swiftui/color.md
hig: https://developer.apple.com/design/human-interface-guidelines/color.md
reviewed: October 2026
---

# Color & Accent

Semantic colors that adapt, and an accent color people choose for every app.

Also called: accent color, tint, AccentColor, brand color, theme, system colors, semantic colors, NSColor, labelColor, controlAccentColor.

## Contents

- Rules
- Pitfalls
- Guide
- Key APIs
- Variants
- Related

## Rules

- **Use semantic colors for what they're named for.** Each one is defined by its job, so it adapts correctly. Don't borrow the separator color for text, or a label color for a background.
- **Don't rely on color alone.** Pair color with a symbol or a word, so people who can't tell the colors apart still get the message.
- **Let the person's accent color lead.** People can pick an accent color that applies to every app. Use `Color.accentColor` and the default control styles, so buttons and selection follow their choice.
- **Give each color one meaning.** If your brand color marks things people can click, don't also use it for plain text. Mixed meanings make people guess.
- **Use color sparingly on Liquid Glass.** Symbols and text in a toolbar are monochrome by default. To call out the main action, color its background, as a prominent button does, rather than its symbol or text.
- **Use the system color picker.** If people choose colors in your app, `ColorPicker` opens the standard Colors panel, where their saved colors are waiting.

## Pitfalls

- **Never hard-code a system color's value.** Apple adjusts them between releases and for each appearance. Use `Color.red`, not the RGB numbers it has today.
- **Your accent shows only with Multicolor.** Check your app with a few other accent colors chosen in System Settings, since anyone who picks one sees your app that way.

## Guide

Mac colors are named for what they do, not how they look: label, separator, window background, selected content. Each one has values for light, dark, and Increase Contrast, so a window built from them adapts on its own. On top of that, people choose an **accent color** in System Settings, and it shows up in every app's buttons, selection, and sidebar icons.

### Your accent color or theirs

- Multicolor: When people leave the accent color on Multicolor, the system uses your app's accent color, from the `AccentColor` set in your asset catalog.
- Any other choice: Their color replaces yours everywhere: buttons, selection, and sidebar icons. A sidebar icon you gave a fixed color keeps it.
- .tint(_:): Always respected. Use it when a color carries meaning, like red for a destructive action, not to force your brand.

### Semantic colors

Live, in light and dark. The first ones are SwiftUI styles; the rest come from AppKit's `NSColor`.

### System colors

Each has its own light and dark value, tuned for contrast. Use them by name.

## Key APIs

- `Color.accentColor`: The person's accent color, or yours with Multicolor.
- `.tint(_:)`: A color with meaning that's always respected.
- `.foregroundStyle(.secondary)`: Label colors that adapt: `.primary` to `.quaternary`.
- `.separator`, `.link`, `.selection`: Semantic styles for lines, links, and selection.
- `Color(nsColor:)`: AppKit's semantic colors, like `.textBackgroundColor`.
- `.listItemTint(_:)`: A fixed color for one sidebar icon.
- `ColorPicker`: The system's color well and Colors panel.

## Variants

### Use the accent color

A `.borderedProminent` button fills with `Color.accentColor`: yours with Multicolor, the person's choice otherwise.

```swift
HStack {
    Button("Cancel") { }
    Button("Book Trip") { }
        .buttonStyle(.borderedProminent)
}
```

**Note:** Set your accent in the asset catalog's `AccentColor` color set. Xcode's templates name it for you.

### Give a control a fixed meaning

`.tint(.red)` keeps a destructive button red whatever accent color people pick.

```swift
HStack {
    Button("Keep Trip") { }
    Button("Delete Trip", role: .destructive) { }
        .buttonStyle(.borderedProminent)
        .tint(.red)
}
```

**Note:** On the Mac, `.borderedProminent` tints the button's background, and `.bordered` doesn't tint at all.

### Keep one sidebar icon's color

Sidebar icons follow the accent color, so save `.listItemTint(_:)` for the rare icon whose color means something.

```swift
List {
    Label("Inbox", systemImage: "tray")
    Label("Important", systemImage: "star")
        .listItemTint(.yellow)
    Label("Sent", systemImage: "paperplane")
}
.listStyle(.sidebar)
```

### Use AppKit's semantic colors

`Color(nsColor:)` brings in Mac colors SwiftUI doesn't name, like `.textBackgroundColor` behind editable text.

```swift
Text("Bring a light jacket for the evenings.")
    .padding(10)
    .frame(width: 260, height: 70, alignment: .topLeading)
    .background(Color(nsColor: .textBackgroundColor))
    .border(.separator)
```

## Related

[dark-mode](dark-mode.md), [materials](materials.md), [color-picker](color-picker.md), [button](button.md), [contrast-transparency](contrast-transparency.md)
