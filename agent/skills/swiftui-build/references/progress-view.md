---
id: progress-view
title: ProgressView
platforms: [iOS, iPadOS]
availability: iOS 14.0+, macOS 11.0+, visionOS 1.0+
docs: https://developer.apple.com/documentation/swiftui/progressview.md
hig: https://developer.apple.com/design/human-interface-guidelines/progress-indicators.md
---

# ProgressView

Shows that work is happening, as a spinning indicator or a filling bar.

Also called: spinner, loading, loader, activity indicator, progress bar, <progress>, UIActivityIndicatorView, UIProgressView, throbber.

## Contents

- Default code
- Rules
- Pitfalls
- Key APIs
- Variants
- Related

## Default code

```swift
// Unknown length: a spinner
ProgressView("Loading messages")

// Known progress: a bar from 0 to 1
ProgressView(value: 0.4)
```

**Important:** On iOS, `.circular` is always a spinner, even with a value. For a ring that fills, use a [Gauge](gauge.md) with the `.accessoryCircularCapacity` style.

## Rules

- **Use a bar when you know how far along you are.** A spinner only says “wait”. A bar tells people how long, so they can decide whether to do something else.
- **Say what's happening.** A specific label like “Importing 240 photos” is more useful than “Loading…”, which people learn to ignore.
- **Let people cancel long tasks.** Add a Cancel button next to the progress, and confirm first if canceling throws away work.
- **Don't switch from a spinner to a bar mid-task.** They're different shapes and sizes, so the swap jumps. Pick one, or start with an empty bar.

## Pitfalls

- **Skip the spinner for very short waits.** If work finishes in under a second, a flash of spinner makes the app feel slower, not faster.

## Key APIs

- `ProgressView()`: A spinner, for work of unknown length.
- `ProgressView(value:total:)`: A bar that fills; `total` defaults to 1.
- `label:` / `currentValueLabel:`: Text above and below the bar.
- `ProgressView(timerInterval:)`: Fills or empties between two dates by itself.
- `.controlSize(_:)`: Spinner size, from `.small` to `.extraLarge`.
- `.tint(_:)`: The color of the bar or spinner.

## Variants

### Button that shows it's busy

Swap a button's label for a `ProgressView` while work runs, and ignore taps until it's done.

```swift
@State private var isLoading = false

Button {
    guard !isLoading else { return }
    isLoading = true
    Task {
        try? await Task.sleep(for: .seconds(2))
        isLoading = false
    }
} label: {
    ZStack {
        Text("Save").opacity(isLoading ? 0 : 1)
        if isLoading {
            ProgressView()
                .tint(.white)
        }
    }
    .frame(width: 80)
}
.buttonStyle(.borderedProminent)
.controlSize(.large)
```

**Note:** The text stays in the `ZStack` at zero opacity, so the button keeps its width when the spinner appears.

### Counts with a total

Pass `total:` when progress is a count, like photos uploaded, instead of dividing yourself.

```swift
@State private var uploaded = 3.0

VStack(spacing: 16) {
    ProgressView(value: uploaded, total: 8) {
        Text("Uploading photos")
    } currentValueLabel: {
        Text("\(Int(uploaded)) of 8")
    }
    .animation(.default, value: uploaded)
    Button(uploaded < 8 ? "Upload one more" : "Start over") {
        uploaded = uploaded < 8 ? uploaded + 1 : 0
    }
}
```

### Countdown that runs by itself

Use `ProgressView(timerInterval:)` to animate between two dates with no timer code.

```swift
@State private var countdown = Date.now...Date.now.addingTimeInterval(30)

VStack(spacing: 16) {
    ProgressView(timerInterval: countdown) {
        Text("Code expires")
    }
    Button("Restart") {
        countdown = Date.now...Date.now.addingTimeInterval(30)
    }
}
.onAppear {
    countdown = Date.now...Date.now.addingTimeInterval(30)
}
```

**Note:** Pass `countsDown: false` to fill up instead. The same view works in widgets and Live Activities.

### Loading overlay

Put a large spinner in an `.overlay` on a material, so the layout doesn't jump while content loads.

```swift
RoundedRectangle(cornerRadius: 16)
    .fill(.fill.tertiary)
    .frame(height: 140)
    .overlay {
        ProgressView("Loading photos")
            .controlSize(.large)
            .padding(20)
            .background(.regularMaterial, in: .rect(cornerRadius: 14))
    }
```

## Related

[gauge](gauge.md), [slider](slider.md), [async-image](async-image.md)
