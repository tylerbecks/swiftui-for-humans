---
id: keyframe-animator
title: KeyframeAnimator
platforms: [iOS, iPadOS]
availability: iOS 17.0+, macOS 14.0+, visionOS 1.0+
docs: https://developer.apple.com/documentation/swiftui/keyframeanimator.md
hig: https://developer.apple.com/design/human-interface-guidelines/motion.md
---

# KeyframeAnimator

Animates several properties on their own timelines, like a jump that squashes, spins, and lands.

Also called: @keyframes, CSS keyframes, timeline, CAKeyframeAnimation, choreography, squash and stretch, multi-property animation, lottie.

## Contents

- Default code
- Rules
- Pitfalls
- Key APIs
- Variants
- Related

## Default code

```swift
@State private var rings = 0

Image(systemName: "bell.fill")
    .font(.largeTitle)
    .onTapGesture { rings += 1 }
    .keyframeAnimator(initialValue: 0.0, trigger: rings) { content, angle in
        content.rotationEffect(.degrees(angle), anchor: .top)
    } keyframes: { _ in
        KeyframeTrack {
            CubicKeyframe(20, duration: 0.1)
            CubicKeyframe(-15, duration: 0.15)
            SpringKeyframe(0, duration: 0.3)
        }
    }
```

**Note:** To animate several properties, use a struct as `initialValue` and add one `KeyframeTrack(\.property)` per property, as in the demo's code.

## Rules

- **Rest between loops.** A looping animation with a pause reads as a gentle reminder. Without one it feels frantic and pulls attention from everything else.
- **Save choreography for special moments.** A multi-step animation suits a reward or a first launch. On something people do all day, it slows them down.
- **Keep it optional.** When Reduce Motion is on, skip the keyframes or show the end state, and make sure the meaning comes through without them.

## Pitfalls

- **Like CSS `@keyframes`, but per property.** Each `KeyframeTrack` animates one property of your value struct on its own timeline, and all tracks run at the same time.
- **Make the tracks the same length.** Add up each track's durations to the same total, so every property finishes together.

## Key APIs

- `.keyframeAnimator(initialValue:trigger:)`: Plays the keyframes once each time `trigger` changes.
- `repeating: true`: Loops the keyframes while the view is on screen.
- `KeyframeTrack(_:)`: One property's timeline, picked by key path.
- `CubicKeyframe`: Moves smoothly to the value.
- `SpringKeyframe`: Springs to the value, with physics.
- `LinearKeyframe`: Moves at a constant speed.
- `MoveKeyframe`: Jumps to the value instantly.

## Variants

### Shake on a wrong passcode

Animate one `KeyframeTrack` on the x offset, and end with a `SpringKeyframe` to settle in the center.

```swift
@State private var attempts = 0

VStack(spacing: 16) {
    HStack(spacing: 14) {
        ForEach(0..<4) { _ in
            Circle().frame(width: 14, height: 14)
        }
    }
    .foregroundStyle(.red)
    .keyframeAnimator(initialValue: 0.0, trigger: attempts) { content, x in
        content.offset(x: x)
    } keyframes: { _ in
        KeyframeTrack {
            CubicKeyframe(-16, duration: 0.07)
            CubicKeyframe(14, duration: 0.07)
            CubicKeyframe(-10, duration: 0.07)
            CubicKeyframe(6, duration: 0.07)
            SpringKeyframe(0, duration: 0.2)
        }
    }
    Button("Try passcode") { attempts += 1 }
}
```

**Note:** Keyframe values only change how the view draws, not its layout, so the shaking dots don't push other views around.

### Ringing bell

Pass `repeating: true` to loop the keyframes, and end with a still `LinearKeyframe` as a pause.

```swift
Image(systemName: "bell.fill")
    .font(.system(size: 48))
    .foregroundStyle(.orange)
    .keyframeAnimator(initialValue: 0.0, repeating: true) { content, degrees in
        content.rotationEffect(.degrees(degrees), anchor: .top)
    } keyframes: { _ in
        KeyframeTrack {
            CubicKeyframe(20, duration: 0.1)
            CubicKeyframe(-18, duration: 0.15)
            CubicKeyframe(12, duration: 0.15)
            CubicKeyframe(-6, duration: 0.15)
            CubicKeyframe(0, duration: 0.1)
            LinearKeyframe(0, duration: 1)
        }
    }
```

## Related

[phase-animator](phase-animator.md), [spring](spring.md), [animation-curves](animation-curves.md)
