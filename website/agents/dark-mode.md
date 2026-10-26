---
id: dark-mode
title: Dark Mode
platforms: [iOS, iPadOS, macOS]
availability: iOS 13.0+
docs: https://developer.apple.com/documentation/uikit/supporting-dark-mode-in-your-interface.md
hig: https://developer.apple.com/design/human-interface-guidelines/dark-mode.md
reviewed: October 2026
---

# Dark Mode

Use colors that adapt, so your app looks right in light and dark.

## Contents

- Rules
- Pitfalls
- Guide
- Key APIs
- Variants
- On macOS
- Related

## Rules

- **Use colors that adapt.** System styles like `.primary` and `.secondary` switch with the appearance. A fixed value like `.black` stays black, even on a black background.
- **Follow the system setting.** Skip an in-app Light / Dark switch. People already chose in Settings, and an app that ignores it can look broken.
- **Let sheets and popovers lift.** In dark mode, iOS gives views in front a slightly lighter, elevated background. Use the system backgrounds so a sheet separates from the screen behind it.
- **Tone down bright images.** A photo with a white background glows on a dark screen. Darken it slightly in dark mode.
- **Check contrast in both modes.** Text needs at least 4.5:1 contrast with its background, and Apple suggests aiming for 7:1 with custom colors in small text. A gray that works on white often fails on black.

## Pitfalls

- **Dark isn't light turned upside down.** Apple's dark palette uses dimmer backgrounds and brighter foregrounds, and many colors aren't simple inversions. Pick each dark value on purpose.
- **Leave people's own colors alone.** If someone picks a color for their content, like ink in a drawing, keep it in both modes. Adaptive colors are for your app's chrome.

## Guide

Many people run their iPhone in dark mode, and some let it switch automatically through the day, even while your app is open. If you build with **system colors and styles**, most of your app adapts for free. The work is in the colors, images, and backgrounds you pick yourself.

### Test both appearances

Check every screen in light and dark before you ship:

```swift
#Preview("Light") { ContentView() }
#Preview("Dark") {
    ContentView()
        .preferredColorScheme(.dark)
}
```

## Key APIs

`.foregroundStyle(.secondary)`, `Color("Brand")`, `\.colorScheme`, `.preferredColorScheme(_:)`, `\.colorSchemeContrast`

## Variants

### Use semantic styles

Use `.primary`, `.secondary`, and the system backgrounds instead of fixed colors, and dark mode comes for free.

```swift
HStack(spacing: 12) {
    Image(systemName: "figure.run")
        .foregroundStyle(.tint)
    VStack(alignment: .leading) {
        Text("Morning Run")
            .foregroundStyle(.primary)
        Text("5.2 km")
            .foregroundStyle(.secondary)
    }
}
.padding()
.background(Color(.secondarySystemBackground),
            in: .rect(cornerRadius: 12))
```

### Add your own color with a dark variant

Add a Color Set to your asset catalog with a light and a dark value, then use it by name.

```swift
// Brand: a Color Set with a Dark variant
Text("Pro")
    .font(.caption.bold())
    .padding(.horizontal, 10)
    .padding(.vertical, 4)
    .foregroundStyle(.white)
    .background(Color("Brand"), in: .capsule)
```

**Note:** The color switches on its own: no `if` in your view. Pick a brighter dark value so it still stands out on a dark background.

## On macOS

Build from colors that adapt, so your app looks right in light, dark, and Auto.

### Rules

- **Check contrast in both appearances.** Text needs a contrast ratio of at least 4.5:1, and Apple suggests 7:1 for custom colors in small text. A gray that works on white often fails on a dark gray.
- **Let system views draw text.** Text fields and text views adjust for the appearance and for vibrancy on their own. Drawing text yourself means doing that work too.
- **Stay dark only when content calls for it.** A viewer for photos or video can stay dark so the interface recedes. Everything else should follow the person's choice.

### Pitfalls

- **Dark isn't light turned inside out.** The dark palette uses dimmer backgrounds and brighter foregrounds, and many colors aren't simple inversions. Pick each dark value on purpose.
- **Appearance can change while your app runs.** With Auto, the Mac switches during the day. Read colors when you draw, never once at launch.

### Key APIs

`.fill.tertiary`

### Variants

#### Use semantic styles

Use `.primary`, `.secondary`, `.tint`, and translucent fills instead of fixed colors, and Dark Mode comes for free.

```swift
HStack(spacing: 10) {
    Image(systemName: "airplane")
        .foregroundStyle(.tint)
    VStack(alignment: .leading) {
        Text("Flight to Lisbon")
        Text("Gate B12 · 9:40 AM")
            .foregroundStyle(.secondary)
    }
}
.padding(10)
.background(.fill.tertiary, in: .rect(cornerRadius: 8))
```

#### Your own color, with a dark variant

Add a Color Set to the asset catalog with an Any and a Dark value, then use it by name.

```swift
// Brand: a Color Set with a Dark Appearance variant
Text("Pro")
    .font(.caption.bold())
    .padding(.horizontal, 10)
    .padding(.vertical, 4)
    .foregroundStyle(.white)
    .background(Color("Brand"), in: .capsule)
```

**Note:** The color switches on its own: no `if` in your view. Pick a brighter dark value so it still stands out on a dark window.

More variants, left out to keep this file short: Adjust an image for dark mode, Keep a media screen dark, Keep a media window dark (macOS). Apple's docs: https://developer.apple.com/documentation/uikit/supporting-dark-mode-in-your-interface.md

## Related

[system-colors](system-colors.md), [materials](materials.md), [color-and-contrast](color-and-contrast.md), [sf-symbols](sf-symbols.md), [foreground-style](foreground-style.md), [image](image.md), [color](color.md), [contrast-transparency](contrast-transparency.md), [settings-pattern](settings-pattern.md)
