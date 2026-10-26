---
id: gauge-progress
title: Gauge & ProgressView
platforms: [macOS]
availability: macOS 11.0+
docs: https://developer.apple.com/documentation/swiftui/progressview.md
hig: https://developer.apple.com/design/human-interface-guidelines/progress-indicators.md
---

# Gauge & ProgressView

Progress bars and spinners for work under way, and gauges for a level in a range.

Also called: progress bar, spinner, activity indicator, loading, NSProgressIndicator, <progress>, <meter>, level indicator, NSLevelIndicator, capacity.

## Contents

- Default code
- Rules
- Pitfalls
- Key APIs
- Variants
- Related

## Default code

```swift
@State private var progress = 0.6

ProgressView(value: progress) {
    Text("Exporting photos…")
}
```

**Note:** The default total is `1.0`, so `value` is a fraction. Pass `total:` to count in your own units, like files or bytes.

## Rules

- **Show how far along it is whenever you can.** A determinate bar lets people decide whether to wait or come back later. Switch an indeterminate bar to a determinate one as soon as you know the total.
- **Keep it moving, and keep it honest.** A stalled indicator looks like a frozen app. Advance at an even pace instead of racing to 90% and crawling through the rest.
- **Don't label a spinner.** A spinner usually appears right after people start something, so they know what it's for. It's small enough for a background task or a spot next to a control.
- **Let people stop long tasks.** Add a Cancel button when stopping has no bad side effects. If it would lose work, ask before you stop.
- **Don't switch between a spinner and a bar.** They're different shapes and sizes, so swapping one for the other mid-task looks jumpy. Pick one and keep it.

## Pitfalls

- **A value makes it determinate.** `ProgressView(value:)` fills a bar; `ProgressView()` with no value animates without an end.
- **Gauge is for a level, not a task.** Use it for things like storage or battery that sit somewhere in a range, and `ProgressView` for work that finishes.
- **Progress over a time span updates itself.** `ProgressView(timerInterval:)` fills as the clock moves through a date range.

## Key APIs

- `ProgressView()`: Indeterminate: a spinner by default.
- `ProgressView(value:total:)`: Determinate: a bar that fills.
- `.progressViewStyle(.linear)`: A bar, even when indeterminate.
- `.progressViewStyle(.circular)`: A spinner or a filling circle.
- `Gauge(value:in:label:)`: A value within a range.
- `.gaugeStyle(.linearCapacity)`: A bar filled up to the value.
- `.gaugeStyle(.accessoryCircular)`: A small ring with a marker.
- `.controlSize(.small)`: A smaller spinner for tight spots.

## Variants

### A task people can cancel

Show the count in `currentValueLabel` and put a Cancel button beside the bar, so people can stop a long copy.

```swift
@State private var copied = 0.0

HStack {
    ProgressView(value: copied, total: 120) {
        Text("Copying photos")
    } currentValueLabel: {
        Text("\(Int(copied)) of 120")
    }
    Button("Cancel") {
        cancelCopy()
    }
}
```

### An indeterminate bar

Without a value, `.linear` draws a bar that animates without an end, which the Mac offers alongside the spinner.

```swift
ProgressView {
    Text("Preparing export")
}
.progressViewStyle(.linear)
```

### A small spinner for background work

`.controlSize(.small)` makes the spinner fit next to a button or in a toolbar while something loads in the background.

```swift
@State private var isChecking = false

HStack(spacing: 8) {
    Button("Check for Updates") {
        isChecking = true
    }
    .disabled(isChecking)
    if isChecking {
        ProgressView()
            .controlSize(.small)
    }
}
```

### A capacity gauge

`.linearCapacity` fills a bar up to the value, and `minimumValueLabel` and `maximumValueLabel` show the ends of the range.

```swift
Gauge(value: 0.72) {
    Text("Storage")
} currentValueLabel: {
    Text("72%")
} minimumValueLabel: {
    Text("0")
} maximumValueLabel: {
    Text("1 TB")
}
.gaugeStyle(.linearCapacity)
.tint(.orange)
```

**Note:** Write labels for the value and both ends even when a style hides some of them: VoiceOver reads them.

### A small circular gauge

`.accessoryCircular` draws a ring with a marker at the value, and a gradient tint shows what high and low mean.

```swift
Gauge(value: 0.35) {
    Text("CPU")
} currentValueLabel: {
    Text("35")
}
.gaugeStyle(.accessoryCircular)
.tint(Gradient(colors: [.green, .yellow, .red]))
```

## Related

[slider](slider.md), [labeled-content](labeled-content.md), [toolbar](toolbar.md), [button](button.md)
