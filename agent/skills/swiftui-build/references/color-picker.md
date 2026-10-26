---
id: color-picker
title: ColorPicker
platforms: [iOS, iPadOS, macOS]
availability: iOS 14.0+, macOS 11.0+, visionOS 1.0+
docs: https://developer.apple.com/documentation/swiftui/colorpicker.md
hig: https://developer.apple.com/design/human-interface-guidelines/color-wells.md
---

# ColorPicker

A swatch that opens the system color picker so people can choose any color.

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
@State private var accent = Color.blue

ColorPicker("Accent Color", selection: $accent)
```

## Rules

- **Use the system color picker.** People already know it, and it keeps their saved colors across apps. A custom picker throws that away.
- **Offer a few swatches when the choices are fixed.** For five tag colors, a row of circles is faster than a full spectrum. Use a picker with `.palette` style or your own buttons.

## Pitfalls

- **`Color` isn't `Codable`.** To save a choice, store `color.resolve(in: environment)`, a `Color.Resolved` that is (iOS 17+).
- **You can't customize the sheet.** The grid, spectrum, sliders, and eyedropper are the system's; for your own UI, build swatches with buttons.

## Key APIs

`ColorPicker(_:selection:)`, `supportsOpacity:`, `.labelsHidden()`, `Color.resolve(in:)`, `Color(_: Color.Resolved)`

## Variants

### Theme a card

Bind each `ColorPicker` to a `Color` in `@State`, and use it right away for a live preview.

```swift
@State private var background = Color.orange
@State private var textColor = Color.white

VStack {
    Text("Hello!")
        .font(.title.bold())
        .foregroundStyle(textColor)
        .frame(maxWidth: .infinity, minHeight: 80)
        .background(background.gradient, in: .rect(cornerRadius: 16))
    Form {
        ColorPicker("Background", selection: $background)
        ColorPicker("Text", selection: $textColor, supportsOpacity: false)
    }
}
```

**Note:** The text picker passes `supportsOpacity: false`, since see-through text is rarely what people want.

### Just the swatch

Use `.labelsHidden()` to show only the round swatch, next to the thing it colors.

```swift
@State private var highlight = Color.yellow

HStack {
    Text("Highlight")
        .padding(.horizontal, 6)
        .background(highlight.opacity(0.5), in: .rect(cornerRadius: 4))
    Spacer()
    ColorPicker("Highlight color", selection: $highlight)
        .labelsHidden()
}
```

**Note:** Give it a real label anyway, like “Highlight color”. VoiceOver reads it so people know what the swatch changes.

## On macOS

A color well that opens the system color panel to pick a color.

### Default code

```swift
@State private var highlight = Color.yellow

ColorPicker("Highlight", selection: $highlight)
```

**Note:** Click the well to open the system color panel. When people choose a color there, the well and your binding update to match.

### Pitfalls

- **Color wells take drag and drop.** People can drag a color from one well to another, or from the color panel onto a well.

### Key APIs

`supportsOpacity: false`, `ColorPicker(selection:label:)`

### Variants

#### Colors in an inspector

Put a few labeled wells in a `Form`, each its own `ColorPicker` with its own binding.

```swift
@State private var fill = Color.teal
@State private var stroke = Color.indigo

Form {
    ColorPicker("Fill", selection: $fill)
    ColorPicker("Stroke", selection: $stroke)
}
```

#### Solid colors only

Pass `supportsOpacity: false` when a see-through color makes no sense, like a label color, and the panel leaves out its opacity controls.

```swift
@State private var labelColor = Color.orange

ColorPicker("Label color", selection: $labelColor, supportsOpacity: false)
```

**Note:** It also strips opacity from colors you set in code and from people's saved colors.

#### Saving the color

`Color` isn't `Codable`, so call `resolve(in:)` for a `Color.Resolved`, which you can save as JSON.

```swift
@State private var tagColor = Color.mint
@Environment(\.self) private var environment
@AppStorage("tagColor") private var savedTag = ""

ColorPicker("Tag color", selection: $tagColor)
    .onChange(of: tagColor) {
        let resolved = tagColor.resolve(in: environment)
        if let data = try? JSONEncoder().encode(resolved) {
            savedTag = String(decoding: data, as: UTF8.self)
        }
    }
```

More variants, left out to keep this file short: Read the components. Apple's docs: https://developer.apple.com/documentation/swiftui/colorpicker.md

## Related

`system-colors` (apple-design skill), [picker](picker.md), [form](form.md), `color` (apple-design skill), [labeled-content](labeled-content.md), [inspector](inspector.md)
