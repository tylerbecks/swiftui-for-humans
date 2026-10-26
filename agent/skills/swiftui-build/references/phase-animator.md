---
id: phase-animator
title: PhaseAnimator
platforms: [iOS, iPadOS]
availability: iOS 17.0+, macOS 14.0+, visionOS 1.0+
docs: https://developer.apple.com/documentation/swiftui/phaseanimator.md
hig: https://developer.apple.com/design/human-interface-guidelines/motion.md
---

# PhaseAnimator

Steps a view through a list of states, either in a loop or each time a value changes.

Also called: loop animation, multi-step animation, sequence, CSS animation, animation-iteration-count, infinite, pulse, shake, attention.

## Contents

- Default code
- Rules
- Pitfalls
- Key APIs
- Variants
- Related

## Default code

```swift
@State private var count = 0

Button("Add to Cart", systemImage: "cart") {
    count += 1
}
.buttonStyle(.borderedProminent)
.phaseAnimator([1.0, 1.2], trigger: count) { content, scale in
    content.scaleEffect(scale)
}
```

**Note:** Leave out `trigger:` and the phases loop forever. With a trigger, they play once each time the value changes, then return to the first phase.

## Rules

- **Loop only what's truly ongoing.** One pulsing indicator says "this is live." When several things move at once, nothing stands out and the screen feels restless.
- **Don't rely on motion alone.** A shake or bounce is a hint. Pair it with text, like an error message, so people who miss the motion still get the point.
- **Keep feedback short.** A triggered animation should finish in well under a second, so people can keep going without waiting.

## Pitfalls

- **Phases are whole states.** Use numbers for one property, or an `enum` with computed properties when several change together.
- **Phases or keyframes?** Use `PhaseAnimator` when each step is a state. Use [KeyframeAnimator](keyframe-animator.md) when properties need their own exact timing, like CSS `@keyframes`.

## Key APIs

- `.phaseAnimator(_:content:animation:)`: Loops through the phases forever.
- `.phaseAnimator(_:trigger:content:animation:)`: Plays the phases once each time `trigger` changes.
- `content:`: Gets the view and current phase; apply modifiers here.
- `animation:`: Picks the animation into each phase.
- `PhaseAnimator`: The same thing as a view, wrapping its content.

## Variants

### Shake on error

Pass the attempt count as `trigger:` to shake the field each time sign-in fails.

```swift
@State private var attempts = 0

VStack(spacing: 16) {
    SecureField("Password", text: .constant("1234"))
        .textFieldStyle(.roundedBorder)
        .frame(width: 220)
        .phaseAnimator([0.0, -12, 12, -8, 8, 0], trigger: attempts) { content, offset in
            content.offset(x: offset)
        } animation: { _ in
            .linear(duration: 0.06)
        }
    Button("Sign In") { attempts += 1 }
        .buttonStyle(.borderedProminent)
}
```

**Note:** A shake alone is easy to miss. Show an error message too, and skip the shake when Reduce Motion is on.

### Steps as an enum

Describe each step as an `enum` case when scale and rotation change together.

```swift
enum LikePhase: CaseIterable {
    case idle, grow, settle

    var scale: Double {
        switch self {
        case .idle: 1
        case .grow: 1.4
        case .settle: 1.1
        }
    }
    var angle: Double { self == .grow ? -12 : 0 }
}

@State private var likes = 0

Button {
    likes += 1
} label: {
    Label("\(likes)", systemImage: "hand.thumbsup.fill")
}
.buttonStyle(.bordered)
.phaseAnimator(LikePhase.allCases, trigger: likes) { content, phase in
    content
        .scaleEffect(phase.scale)
        .rotationEffect(.degrees(phase.angle))
} animation: { phase in
    phase == .grow ? .snappy(duration: 0.15) : .bouncy
}
```

**Note:** The `animation:` closure gets the phase it's animating to, so the quick grow and the bouncy settle each get their own curve.

### Loading dots

Without a `trigger:`, `.phaseAnimator` loops on its own, so three delayed dots need no state.

```swift
HStack(spacing: 8) {
    ForEach(0..<3) { index in
        Circle()
            .frame(width: 12, height: 12)
            .phaseAnimator([0.3, 1]) { content, phase in
                content.opacity(phase).scaleEffect(phase)
            } animation: { _ in
                .easeInOut(duration: 0.5).delay(Double(index) * 0.15)
            }
    }
}
.foregroundStyle(.secondary)
```

**Note:** For a standard spinner, use `ProgressView`. Custom loaders are best kept for branded moments.

## Related

[keyframe-animator](keyframe-animator.md), [animation-curves](animation-curves.md), [symbol-effects](symbol-effects.md), [spring](spring.md)
