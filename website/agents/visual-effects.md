---
id: visual-effects
title: Visual Effects
platforms: [iOS, iPadOS]
availability: iOS 13.0+, macOS 10.15+, visionOS 1.0+
docs: https://developer.apple.com/documentation/swiftui/view-graphics-and-rendering.md
---

# Visual Effects

Fade, blur, scale, rotate, move, and desaturate a view without changing its layout.

Also called: opacity, blur, transform, scale, rotate, translate, filter: grayscale, CSS transform, CGAffineTransform, alpha.

## Contents

- Default code
- Pitfalls
- Key APIs
- Variants
- Related

## Default code

```swift
@State private var isDimmed = false

Image(systemName: "star.fill")
    .font(.largeTitle)
    .opacity(isDimmed ? 0.3 : 1)
    .scaleEffect(isDimmed ? 0.8 : 1)
    .onTapGesture {
        withAnimation { isDimmed.toggle() }
    }
```

**Note:** Like CSS `transform` and `filter`, these change how a view is drawn, not where it sits in the layout. Its neighbors never move.

## Pitfalls

- **Use `offset` for nudges, not layout.** To really move something, change the layout with `padding`, stacks, or `frame(alignment:)`.
- **`opacity(0)` still takes up space.** Remove the view with `if` when it should be gone from the layout.
- **Everything here animates.** Change the value inside `withAnimation` and SwiftUI blends between the old and new values.

## Key APIs

- `.opacity(_:)`: Fades the view, from `0` (invisible) to `1`.
- `.blur(radius:)`: Blurs the view, like CSS `filter: blur()`.
- `.scaleEffect(_:anchor:)`: Grows or shrinks the drawing around an anchor point.
- `.rotationEffect(_:anchor:)`: Rotates the drawing, by default around the center.
- `.offset(x:y:)`: Moves the drawing without moving its layout slot.
- `.grayscale(_:)`: Removes color, from `0` (none) to `1` (full gray).

## Variants

### Press to shrink

Use `.scaleEffect` in a custom `ButtonStyle` so the button shrinks while it's pressed.

```swift
struct PressScaleStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(.blue, in: .capsule)
            .scaleEffect(configuration.isPressed ? 0.92 : 1)
            .opacity(configuration.isPressed ? 0.8 : 1)
            .animation(.snappy, value: configuration.isPressed)
    }
}

Button("Press me") {}
    .buttonStyle(PressScaleStyle())
```

**Note:** `configuration.isPressed` is `true` while a finger is down. Press and hold to see it.

### Tap to reveal

Animate `.blur(radius:)` to hide a spoiler until someone taps it.

```swift
@State private var isRevealed = false

Text("The butler did it.")
    .font(.title3.weight(.semibold))
    .blur(radius: isRevealed ? 0 : 8)
    .onTapGesture {
        withAnimation { isRevealed.toggle() }
    }
```

### Rotating chevron

Animate `.rotationEffect` on a chevron to show that a section is expanded.

```swift
@State private var isExpanded = false

Button {
    withAnimation(.snappy) { isExpanded.toggle() }
} label: {
    HStack {
        Text("Details")
        Spacer()
        Image(systemName: "chevron.right")
            .rotationEffect(.degrees(isExpanded ? 90 : 0))
    }
}
```

### Unavailable item

Combine `.grayscale(1)` and `.opacity(0.5)` to show that an item isn't available.

```swift
HStack(spacing: 24) {
    Label("In stock", systemImage: "bag.fill")
        .font(.title2.bold())
        .foregroundStyle(.orange)
    Label("Sold out", systemImage: "bag.fill")
        .font(.title2.bold())
        .foregroundStyle(.orange)
        .grayscale(1)
        .opacity(0.5)
}
```

**Important:** This only changes the look. For a control people shouldn't use, add `.disabled(true)` so it also ignores taps and VoiceOver reports it as dimmed.

## Related

[modifier-order](modifier-order.md), [spring](spring.md), [transitions](transitions.md), [shadow](shadow.md)
