---
id: gauge
title: Gauge
platforms: [iOS, iPadOS]
availability: iOS 16.0+, macOS 13.0+, watchOS 7.0+, visionOS 1.0+
docs: https://developer.apple.com/documentation/swiftui/gauge.md
hig: https://developer.apple.com/design/human-interface-guidelines/gauges.md
---

# Gauge

Shows where a value sits within a range, like a battery level or a speedometer.

Also called: meter, <meter>, ring, progress ring, dial, speedometer, battery, level indicator, donut.

## Contents

- Default code
- Rules
- Key APIs
- Variants
- Related

## Default code

```swift
Gauge(value: 21, in: 0...40) {
    Text("Temperature")
} currentValueLabel: {
    Text("21°")
}
.gaugeStyle(.accessoryCircular)
```

**Note:** The `accessory` styles are sized for widgets and the Lock Screen. On an app screen, keep them next to text or enlarge them with `.scaleEffect(_:)`.

## Rules

- **Label the value and both ends.** Short labels tell people what the range means, and VoiceOver reads them for people who can't see the gauge.
- **Use a gradient when the color carries meaning.** Blue to red for cold to hot, or green to purple for air quality, tells people whether a value is good before they read it.
- **Use a gauge to show a value, not to set one.** People can't drag a gauge. When they should change the value, use a [Slider](slider.md).

## Key APIs

- `Gauge(value:in:label:)`: Shows a value in a range; `0...1` by default.
- `currentValueLabel:`: The value as text, often in the middle of a ring.
- `minimumValueLabel:` / `maximumValueLabel:`: Labels for the two ends.
- `.gaugeStyle(_:)`: A bar, a ring, or a widget-style look.
- `.tint(_:)`: A color, or a `Gradient` across the range.

## Variants

### Battery ring

Use the `.accessoryCircularCapacity` style for a ring that fills, with the value in the middle.

```swift
@State private var battery = 0.8

VStack(spacing: 20) {
    Gauge(value: battery) {
        Image(systemName: "iphone")
    } currentValueLabel: {
        Text(battery.formatted(.percent.precision(.fractionLength(0))))
    }
    .gaugeStyle(.accessoryCircularCapacity)
    .tint(battery < 0.2 ? .red : .green)
    .scaleEffect(1.4)

    Slider(value: $battery)
}
```

**Note:** This is the filling ring people often expect from `ProgressView`. On iOS, a circular `ProgressView` only spins.

### Storage bar

Use `.gaugeStyle(.linearCapacity)` for a labeled bar that shows usage, like storage or a data plan.

```swift
@State private var storage = 182.0

Gauge(value: storage, in: 0...256) {
    Text("iPhone Storage")
} currentValueLabel: {
    Text("\(Int(storage)) GB of 256 GB used")
}
.gaugeStyle(.linearCapacity)
.tint(.orange)
```

### Air quality scale

Use `.accessoryLinear` with a `Gradient` tint, so the marker's color shows whether a value is good.

```swift
Gauge(value: 42, in: 0...200) {
    Text("AQI")
} currentValueLabel: {
    Text("42")
} minimumValueLabel: {
    Text("Good")
} maximumValueLabel: {
    Text("Poor")
}
.gaugeStyle(.accessoryLinear)
.tint(Gradient(colors: [.green, .yellow, .orange, .red, .purple]))
```

## Related

[progress-view](progress-view.md), [slider](slider.md), [charts](charts.md)
