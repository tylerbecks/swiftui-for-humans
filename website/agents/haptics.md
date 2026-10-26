---
id: haptics
title: Haptics
platforms: [iOS, iPadOS]
availability: iOS 17.0+, macOS 14.0+, watchOS 10.0+, visionOS 26.0+
docs: https://developer.apple.com/documentation/swiftui/sensoryfeedback.md
hig: https://developer.apple.com/design/human-interface-guidelines/playing-haptics.md
---

# Haptics

Play a tap, buzz, or click on the device when something happens.

Also called: vibrate, vibration, taptic, navigator.vibrate, UIImpactFeedbackGenerator, UINotificationFeedbackGenerator, feedback, buzz, rumble.

## Contents

- Default code
- Rules
- Pitfalls
- Key APIs
- Variants
- Related

## Default code

```swift
@State private var saveCount = 0

Button("Save") {
    saveCount += 1
}
.buttonStyle(.borderedProminent)
.sensoryFeedback(.success, trigger: saveCount)
```

**Important:** Haptics only play on a real iPhone or Apple Watch. The Simulator and iPad stay silent, so test on a device. The demo shows a visual pulse instead.

## Rules

- **Pair every haptic with something people can see.** Many people never feel haptics: iPad has none, and anyone can turn them off. The screen should tell the same story.
- **Use each type for what it means.** People learn that `.success` means done and `.error` means failed. Playing them for anything else muddles the signal.
- **Use haptics sparingly.** A haptic on every tap gets tiresome. Toggles, pickers, and pull to refresh already play their own, so don't add another on top.

## Pitfalls

- **You change state; SwiftUI plays the haptic.** Unlike `navigator.vibrate()`, you don't call anything. The feedback plays whenever its `trigger` value changes.
- **Some types only play on other devices.** `.start` and `.stop` play only on Apple Watch, `.increase` and `.decrease` on Apple Watch and Vision Pro, and `.levelChange` on a Mac.

## Key APIs

- `.sensoryFeedback(_:trigger:)`: Plays feedback each time `trigger` changes.
- `.sensoryFeedback(_:trigger:condition:)`: Plays only when your closure returns `true`.
- `.sensoryFeedback(trigger:_:)`: Picks the feedback, or `nil`, from the old and new values.
- `.success`, `.warning`, `.error`: The outcome of a task.
- `.selection`: A light tick as a value changes.
- `.impact(weight:)`: A bump, from `.light` to `.heavy`.
- `.alignment`: A crisp tick when something snaps into place.

## Variants

### Success or error from one trigger

Use `.sensoryFeedback(trigger:_:)` to pick `.success`, `.error`, or `nil` from the new value.

```swift
enum SaveResult { case none, saved, failed }
@State private var result = SaveResult.none

HStack {
    Button("Save") { result = .saved }
    Button("Fail", role: .destructive) { result = .failed }
}
.buttonStyle(.bordered)
.sensoryFeedback(trigger: result) { _, newValue in
    switch newValue {
    case .saved: .success
    case .failed: .error
    case .none: nil
    }
}
```

### Ticks on a custom control

Play `.selection`, the light tick of a picker wheel, each time a custom rating changes.

```swift
@State private var rating = 3

HStack {
    ForEach(1...5, id: \.self) { star in
        Image(systemName: star <= rating ? "star.fill" : "star")
            .foregroundStyle(.yellow)
            .onTapGesture { rating = star }
    }
}
.font(.title)
.sensoryFeedback(.selection, trigger: rating)
```

**Note:** System pickers, toggles, and sliders already play their own haptics. Add `.selection` only to controls you build yourself.

### Snap into alignment

Drag the circle across the guide; `.alignment` ticks the moment it snaps to the center.

```swift
@State private var offset: CGFloat = -90
@State private var dragStart: CGFloat?
private var isCentered: Bool { abs(offset) < 12 }

ZStack {
    Capsule()
        .fill(isCentered ? Color.indigo : Color.secondary.opacity(0.4))
        .frame(width: 3, height: 90)
    Circle()
        .fill(.indigo.gradient)
        .frame(width: 56, height: 56)
        .offset(x: isCentered ? 0 : offset)
        .animation(.snappy, value: isCentered)
        .gesture(
            DragGesture()
                .onChanged { drag in
                    let start = dragStart ?? offset
                    dragStart = start
                    offset = min(max(start + drag.translation.width, -110), 110)
                }
                .onEnded { _ in dragStart = nil }
        )
}
.sensoryFeedback(.alignment, trigger: isCentered) { _, centered in centered }
```

**Note:** The `condition:` closure returns `true` only when the circle snaps in, so nothing plays as it leaves the guide.

## Related

[button](button.md), [toggle](toggle.md), [picker](picker.md), [symbol-effects](symbol-effects.md)
