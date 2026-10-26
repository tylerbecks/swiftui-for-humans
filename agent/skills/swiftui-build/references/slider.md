---
id: slider
title: Slider
platforms: [iOS, iPadOS, macOS]
availability: iOS 13.0+, macOS 10.15+, visionOS 1.0+
docs: https://developer.apple.com/documentation/swiftui/slider.md
hig: https://developer.apple.com/design/human-interface-guidelines/sliders.md
---

# Slider

A control for picking a number from a range by dragging a thumb along a track.

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
@State private var opacity = 0.8

Slider(value: $opacity, in: 0...1) {
    Text("Opacity")
}
```

**Note:** Without `step:`, the value is continuous, so expect numbers like `0.7342`. Add `step: 0.1` or `step: 1` to snap to round values.

## Rules

- **Show what each end means.** Small icons at the ends, like a small and a large sun, tell people which way is more without reading a label.
- **Put the minimum on the left.** People expect less on the leading side and more on the trailing side, in every app. Don't flip it.
- **Show the exact value when it matters.** Dragging is quick but imprecise. Display the number, and add a `Stepper` or `TextField` if people need a specific value.
- **Give live feedback as the value changes.** Update the preview while people drag, like text growing as they adjust its size, so they can stop at the right spot.

## Pitfalls

- **The value is a `Double`, not an `Int`.** For whole numbers, add `step: 1` and convert with `Int(value)`, or use a [Stepper](stepper.md).

## Key APIs

`Slider(value:in:)`, `step:`, `minimumValueLabel:` / `maximumValueLabel:`, `onEditingChanged:`, `neutralValue:`, `.tint(_:)`

## Variants

### With a title and value

Put a title and the current value in an `HStack` above the slider, like a row in Settings.

```swift
@State private var fontSize = 17.0

VStack(alignment: .leading) {
    HStack {
        Text("Text Size")
        Spacer()
        Text("\(Int(fontSize)) pt")
            .foregroundStyle(.secondary)
            .monospacedDigit()
    }
    Slider(value: $fontSize, in: 12...32, step: 1) {
        Text("Text Size")
    }
    Text("The quick brown fox")
        .font(.system(size: fontSize))
        .frame(height: 44, alignment: .leading)
}
```

**Important:** On iOS, the slider's own label isn't drawn. VoiceOver reads it, but you need to show a visible title yourself.

### Brightness with icons

Use `minimumValueLabel:` and `maximumValueLabel:` for icons that show what each end means.

```swift
@State private var brightness = 0.7

Slider(value: $brightness) {
    Text("Brightness")
} minimumValueLabel: {
    Image(systemName: "sun.min")
} maximumValueLabel: {
    Image(systemName: "sun.max.fill")
}
.tint(.yellow)

RoundedRectangle(cornerRadius: 12)
    .fill(.yellow.opacity(brightness))
    .frame(height: 60)
```

## On macOS

A track with a thumb for picking a value between a minimum and a maximum.

### Default code

```swift
@State private var volume = 50.0

Slider(value: $volume, in: 0...100) {
    Text("Volume")
}
```

**Note:** Like `<input type=range>` with a bound value: the slider reads `volume` and writes it back as people drag.

### Rules

- **Put the minimum on the leading side.** People expect a horizontal slider to grow from leading to trailing, like 0% to 100%. Reversing it makes every adjustment feel backward.
- **Show the result while people drag.** Update what the slider controls as the value changes, the way the Dock grows while you drag its Size slider. Save heavy work for when the drag ends.
- **Use tick marks when exact values matter, and label only what helps.** Ticks show the scale and make specific values easy to hit. Labeling the minimum and maximum is often enough.
- **Offer a text field when people need a precise value.** For a wide range, pair the slider with a field, and maybe a [Stepper](stepper.md), so people can type the exact number.

### Pitfalls

- **A `step` adds tick marks.** On the Mac, a slider with a step draws a tick at each one, and the value moves in whole steps.
- **The value is a floating-point number.** Bind a `Double` (or another `BinaryFloatingPoint`); round it yourself if you store an integer.
- **`step` also sets how far VoiceOver moves it.** When people adjust the slider with VoiceOver, it changes by one step.

### Key APIs

`Slider(value:in:step:)`, `minimumValueLabel:`, `maximumValueLabel:`, `ticks: { SliderTick(…) }`, `.controlSize(_:)`

### Variants

#### Symbols at each end

`minimumValueLabel` and `maximumValueLabel` show what the ends mean, like a small and a large photo for icon size.

```swift
@State private var iconSize = 48.0

Slider(value: $iconSize, in: 16...128) {
    Text("Icon size")
} minimumValueLabel: {
    Image(systemName: "photo")
        .imageScale(.small)
} maximumValueLabel: {
    Image(systemName: "photo")
        .imageScale(.large)
}
```

#### Tick marks with labels

In macOS 26, pass `ticks:` to place a `SliderTick` at each value that matters, labeling only the ones that help, like the ends.

```swift
@State private var quality = 0.75

Slider(value: $quality) {
    Text("Quality")
} ticks: {
    SliderTick(0.0) { Text("Small file") }
    SliderTick(0.25)
    SliderTick(0.5)
    SliderTick(0.75)
    SliderTick(1.0) { Text("Best") }
}
```

More variants, left out to keep this file short: Act when the drag ends, Tick marks, Fill from the middle, Live preview, save at the end (macOS), With a field and a stepper (macOS). Apple's docs: https://developer.apple.com/documentation/swiftui/slider.md

## Related

[stepper](stepper.md), [progress-view](progress-view.md), [gauge](gauge.md), [state](state.md), [gauge-progress](gauge-progress.md), [form](form.md), [labeled-content](labeled-content.md), [text-field](text-field.md)
