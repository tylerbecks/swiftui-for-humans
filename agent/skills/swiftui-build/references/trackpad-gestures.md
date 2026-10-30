---
id: trackpad-gestures
title: Trackpad gestures
platforms: [macOS]
availability: macOS 14.0+
docs: https://developer.apple.com/documentation/swiftui/magnifygesture.md
hig: https://developer.apple.com/design/human-interface-guidelines/pointing-devices.md
---

# Trackpad gestures

Zoom and rotate with trackpad gestures, plus a way to do both with a mouse.

Also called: pinch, zoom, magnify, rotate, MagnifyGesture, RotateGesture, MagnificationGesture, RotationGesture, NSMagnificationGestureRecognizer, multitouch.

## Contents

- Default code
- Rules
- Pitfalls
- Key APIs
- Variants
- Related

## Default code

```swift
@State private var scale = 1.0
@State private var baseScale = 1.0

Image("photo")
    .scaleEffect(scale)
    .gesture(
        MagnifyGesture()
            .onChanged { value in
                scale = baseScale * value.magnification
            }
            .onEnded { _ in
                baseScale = scale
            }
    )
```

**Important:** `value.magnification` starts at 1 for every new pinch. Multiply it by the scale you saved at the end of the last one, or each pinch jumps back to the original size.

## Rules

- **Give mouse users another way.** Pinching and rotating need a trackpad or a touch display. Add buttons or menu commands that zoom and rotate, so everyone can reach the same result.
- **Don't take over system gestures.** People expect gestures like swiping up for Mission Control to work in every app, and they can customize them in System Settings.
- **Make gestures behave as they do elsewhere.** People expect a gesture to do the same thing in every app, like swiping between pages. A familiar gesture with a new meaning surprises them.

## Pitfalls

- **Scrolling needs no code.** A `ScrollView` scrolls with a trackpad or a mouse; you only add gestures for zooming and rotating.
- **`MagnificationGesture` is deprecated.** So is `RotationGesture`. Use `MagnifyGesture` and `RotateGesture` instead.

## Key APIs

- `MagnifyGesture()`: Pinch with two fingers to zoom.
- `RotateGesture()`: Turn two fingers to rotate.
- `value.magnification`: The scale since the gesture began.
- `value.rotation`: The angle since the gesture began.
- `.simultaneously(with:)`: Zoom and rotate in one motion.
- `.onScrollPhaseChange(_:)`: Tells you when scrolling starts and stops.

## Variants

### Rotate and snap to a right angle

Follow `RotateGesture` while the fingers turn, then snap to the nearest 90° when they lift, like straightening a photo.

```swift
@State private var angle = Angle.zero
@State private var baseAngle = Angle.zero

Image("photo")
    .rotationEffect(angle)
    .gesture(
        RotateGesture()
            .onChanged { angle = baseAngle + $0.rotation }
            .onEnded { _ in
                let quarterTurns = (angle.degrees / 90).rounded()
                withAnimation(.snappy) {
                    angle = .degrees(quarterTurns * 90)
                }
                baseAngle = angle
            }
    )
```

### Know when scrolling stops

`.onScrollPhaseChange` reports when a scroll starts and ends, from a trackpad or a mouse wheel alike.

```swift
@State private var isScrolling = false

ScrollView {
    LazyVStack {
        ForEach(1...40, id: \.self) { Text("Row \($0)") }
    }
}
.onScrollPhaseChange { _, phase in
    isScrolling = phase.isScrolling
}
```

## Related

[hover](hover.md), [drag-drop](drag-drop.md), [scroll-view](scroll-view.md), [animation](animation.md)
