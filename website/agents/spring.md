---
id: spring
title: Spring
platforms: [iOS, iPadOS]
availability: iOS 17.0+, macOS 14.0+, visionOS 1.0+
docs: https://developer.apple.com/documentation/swiftui/spring.md
hig: https://developer.apple.com/design/human-interface-guidelines/motion.md
---

# Spring

A natural, physics-based animation set by how long it takes and how much it bounces.

Also called: bounce, easing, physics, react-spring, damping, stiffness, usingSpringWithDamping, animation curve, snappy.

## Contents

- Default code
- Rules
- Pitfalls
- Key APIs
- Variants
- Related

## Default code

```swift
@State private var isLiked = false

Image(systemName: isLiked ? "heart.fill" : "heart")
    .font(.largeTitle)
    .foregroundStyle(.pink)
    .scaleEffect(isLiked ? 1.2 : 1)
    .onTapGesture {
        withAnimation(.spring(duration: 0.4, bounce: 0.5)) {
            isLiked.toggle()
        }
    }
```

**Note:** `bounce` runs from `0` (no overshoot) to just under `1`. Negative values make the spring slower and heavier, with no overshoot.

## Rules

- **Keep the bounce small in everyday UI.** A little overshoot feels lively and confirms the change. A lot of it looks cartoonish and slows people down.
- **Make motion match the gesture.** A card dragged down should settle back down, and a view that slid in from the bottom should leave the same way. Motion that contradicts the gesture disorients people.
- **Never make people wait for an animation.** Keep the interface usable while things move. Springs pick up from wherever they are when interrupted, so you rarely need to block input.

## Pitfalls

- **`duration` and `bounce` replace stiffness and damping.** If you know react-spring or UIKit's damping ratio, think "how long" and "how springy" instead; SwiftUI converts for you.
- **Springs are the default.** `withAnimation { }` with no argument already uses a smooth spring, so reach for a preset before tuning numbers.

## Key APIs

- `.spring(duration:bounce:)`: A spring with your own settle time and bounce.
- `.smooth`: No overshoot. A calm default for most changes.
- `.snappy`: A little overshoot. Quick and responsive.
- `.bouncy`: The most overshoot. Playful moments only.
- `.bouncy(duration:extraBounce:)`: Tunes a preset without leaving it.
- `.interactiveSpring()`: A fast spring for views that track a finger.
- `Spring.settlingDuration`: How long a spring really takes to come to rest.

## Variants

### The presets, side by side

Use the `.smooth`, `.snappy`, and `.bouncy` presets; they take the same time and differ only in overshoot.

```swift
@State private var isMoved = false

VStack {
    Circle().frame(width: 28, height: 28)
        .frame(maxWidth: .infinity, alignment: isMoved ? .trailing : .leading)
        .animation(.smooth, value: isMoved)
    Circle().frame(width: 28, height: 28)
        .frame(maxWidth: .infinity, alignment: isMoved ? .trailing : .leading)
        .animation(.snappy, value: isMoved)
    Circle().frame(width: 28, height: 28)
        .frame(maxWidth: .infinity, alignment: isMoved ? .trailing : .leading)
        .animation(.bouncy, value: isMoved)
    Button("Play") { isMoved.toggle() }
}
```

**Note:** Start with `.smooth` for layout changes and `.snappy` for taps. Save `.bouncy` for playful moments like a like or a reward.

### Drag and snap back

Track a `DragGesture` directly, then let `.spring(duration:bounce:)` carry the card home on release.

```swift
@State private var offset = CGSize.zero

RoundedRectangle(cornerRadius: 20)
    .fill(.indigo.gradient)
    .frame(width: 120, height: 120)
    .offset(offset)
    .gesture(
        DragGesture()
            .onChanged { offset = $0.translation }
            .onEnded { _ in
                withAnimation(.spring(duration: 0.5, bounce: 0.4)) {
                    offset = .zero
                }
            }
    )
```

**Note:** Springs keep their momentum when interrupted. Grab the card while it's still moving and it follows your finger without a jump.

### Springy press effect

Scale a custom `ButtonStyle` on `isPressed`, and let `.animation(_:value:)` spring it back on release.

```swift
struct SquishyButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            .background(.pink.gradient, in: .capsule)
            .foregroundStyle(.white)
            .scaleEffect(configuration.isPressed ? 0.88 : 1)
            .animation(.bouncy(duration: 0.3, extraBounce: 0.2), value: configuration.isPressed)
    }
}

Button("Hold me") {}
    .buttonStyle(SquishyButtonStyle())
```

## Related

[animation-curves](animation-curves.md), [transitions](transitions.md), [keyframe-animator](keyframe-animator.md), [haptics](haptics.md)
