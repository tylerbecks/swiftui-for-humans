---
id: animation-curves
title: Animation Curves
platforms: [iOS, iPadOS]
availability: iOS 13.0+, macOS 10.15+, visionOS 1.0+
docs: https://developer.apple.com/documentation/swiftui/animation.md
hig: https://developer.apple.com/design/human-interface-guidelines/motion.md
---

# Animation Curves

Animate any state change, and pick a curve for how it speeds up and slows down.

Also called: easing, ease-in-out, transition-timing-function, cubic-bezier, CSS transition, timing function, UIView.animate, duration, delay, withAnimation.

## Contents

- Default code
- Rules
- Pitfalls
- Key APIs
- Variants
- Related

## Default code

```swift
@State private var isExpanded = false

RoundedRectangle(cornerRadius: 12)
    .fill(.blue)
    .frame(height: isExpanded ? 200 : 80)
    .onTapGesture {
        withAnimation(.easeInOut(duration: 0.3)) {
            isExpanded.toggle()
        }
    }
```

**Important:** Always pass `value:` to `.animation(_:value:)`. The old version without it is deprecated and animates changes you didn't mean to.

## Rules

- **Keep feedback animations short.** A quick response feels light and tells people their tap worked. A slow one makes them wait for the interface to catch up.
- **Animate with a purpose.** Motion should explain what changed or where something went. Decoration that moves for its own sake distracts, and can make some people feel unwell.
- **Make motion optional.** Check Reduce Motion and swap big movement for a fade or no animation, so nothing important is shown only through motion.
- **Don't animate actions people repeat all the time.** System controls already have subtle motion. Extra animation on something tapped dozens of times a day gets tiresome fast.

## Pitfalls

- **You animate state, not views.** Change a value inside `withAnimation`, and every view that reads it moves from the old look to the new one.
- **`withAnimation` versus `.animation(_:value:)`.** `withAnimation` animates everything the change touches. The modifier animates only its own view, and only when `value` changes.
- **The default is a spring.** Since iOS 17, `withAnimation { }` with no argument uses a smooth spring, not ease-in-out. Pass `.easeInOut(duration:)` when you need an exact duration.

## Key APIs

- `withAnimation(_:_:)`: Animates every view the state change affects.
- `.animation(_:value:)`: Animates only this view, when `value` changes.
- `.easeInOut(duration:)`: Slow start and end. Also `.easeIn`, `.easeOut`, and `.linear`.
- `.delay(_:)`: Waits before the animation starts.
- `.repeatForever(autoreverses:)`: Loops the animation until the view goes away.
- `withAnimation(_:_:completion:)`: Runs code when the animation finishes (iOS 17+).
- `\.accessibilityReduceMotion`: True when the person turned on Reduce Motion.

## Variants

### Curves side by side

Give each view its own `.animation(_:value:)` curve; only the curve differs between these four dots.

```swift
@State private var isMoved = false

let curves: [(String, Animation)] = [
    ("linear", .linear(duration: 1)),
    ("easeIn", .easeIn(duration: 1)),
    ("easeOut", .easeOut(duration: 1)),
    ("easeInOut", .easeInOut(duration: 1)),
]

VStack {
    ForEach(curves, id: \.0) { name, animation in
        Circle()
            .frame(width: 28, height: 28)
            .frame(maxWidth: .infinity, alignment: isMoved ? .trailing : .leading)
            .animation(animation, value: isMoved)
    }
    Button("Race") { isMoved.toggle() }
}
```

**Note:** Ease-out (fast start, gentle stop) feels the most responsive for things appearing on screen. Linear looks mechanical, so save it for spinners and progress.

### Repeat forever

Add `.repeatForever(autoreverses: true)` and flip the state in `.onAppear` for an endless pulse.

```swift
@State private var isPulsing = false

Circle()
    .fill(.red)
    .frame(width: 16, height: 16)
    .scaleEffect(isPulsing ? 1.4 : 1)
    .opacity(isPulsing ? 0.4 : 1)
    .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: isPulsing)
    .onAppear { isPulsing = true }
```

**Note:** A repeating animation never ends on its own. Keep it for live status like recording, and skip it when Reduce Motion is on.

### Run code when it finishes

Pass a `completion:` closure to `withAnimation` to chain a next step or clean up afterward.

```swift
@State private var isExpanded = false
@State private var status = "Ready"

VStack(spacing: 16) {
    RoundedRectangle(cornerRadius: 12)
        .fill(.teal)
        .frame(width: isExpanded ? 220 : 80, height: 44)
    Text(status)
    Button("Animate") {
        status = "Animating…"
        withAnimation(.easeOut(duration: 0.6)) {
            isExpanded.toggle()
        } completion: {
            status = "Done!"
        }
    }
}
```

### Respect Reduce Motion

Read `\.accessibilityReduceMotion` and pass `nil` to `withAnimation` to skip the movement.

```swift
@Environment(\.accessibilityReduceMotion) private var reduceMotion
@State private var isExpanded = false

RoundedRectangle(cornerRadius: 12)
    .fill(.indigo)
    .frame(width: isExpanded ? 220 : 80, height: 44)
    .onTapGesture {
        withAnimation(reduceMotion ? nil : .easeOut(duration: 0.4)) {
            isExpanded.toggle()
        }
    }
```

**Note:** Turn it on in Settings > Accessibility > Motion to test. A short fade is often a better fallback than no animation at all.

## Related

[spring](spring.md), [transitions](transitions.md), [phase-animator](phase-animator.md), [content-transition](content-transition.md)
