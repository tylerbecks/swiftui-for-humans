---
id: clip-shape
title: clipShape
platforms: [iOS, iPadOS]
availability: iOS 13.0+, macOS 10.15+, visionOS 1.0+
docs: https://developer.apple.com/documentation/swiftui/view/clipshape(_:style:).md
---

# clipShape

Cuts a view to a shape, like rounded corners or a circle, and hides the rest.

Also called: border-radius, rounded corners, cornerRadius, corner radius, mask, overflow: hidden, circle image, clip-path, clipped, squircle.

## Contents

- Default code
- Pitfalls
- Key APIs
- Variants
- Related

## Default code

```swift
Image(systemName: "photo.fill")
    .font(.largeTitle)
    .foregroundStyle(.white)
    .frame(width: 160, height: 120)
    .background(.indigo.gradient)
    .clipShape(.rect(cornerRadius: 16))
```

**Note:** Set the size with `.frame` first, then clip. The clip uses whatever size the view has at that point in the chain.

## Pitfalls

- **`.cornerRadius(_:)` is deprecated.** Use `.clipShape(.rect(cornerRadius: 12))`, or `.background(color, in: .rect(cornerRadius: 12))` when you only need a rounded fill.
- **Rounded rectangles use smooth corners.** `.rect(cornerRadius:)` draws Apple's continuous "squircle" curve, the same as app icons, by default.
- **Add a shadow after the clip.** A `.shadow` before `.clipShape` gets cut off along with everything else outside the shape.

## Key APIs

- `.clipShape(.rect(cornerRadius:))`: Rounded corners, like CSS `border-radius` with `overflow: hidden`.
- `.clipShape(.circle)`: A circle, for avatars and round buttons.
- `.clipShape(.capsule)`: Fully rounded ends, for pills.
- `.rect(topLeadingRadius:…)`: A different radius on each corner.
- `.clipped()`: Cuts off anything outside the view's frame.
- `.contentShape(_:)`: Sets the tappable area to match the visible shape.

## Variants

### Circular profile photo

Use `.clipShape(.circle)` after a square `.frame` for a round profile photo.

```swift
Image(systemName: "person.fill")
    .resizable()
    .scaledToFill()
    .padding(18)
    .foregroundStyle(.white)
    .frame(width: 88, height: 88)
    .background(.teal.gradient)
    .clipShape(.circle)
```

**Note:** For a real photo, use `.resizable()` and `.scaledToFill()` so it crops to the circle instead of squashing.

### Rounded fill without clipping

Use `.background(_:in:)` when you only need a rounded fill, without clipping anything.

```swift
Text("Rounded background")
    .padding()
    .background(.blue.opacity(0.15), in: .rect(cornerRadius: 12))
```

**Note:** Nothing gets cut off, so a badge or shadow can still hang outside the shape.

### Match the tap area

Add `.contentShape(.circle)` so only taps inside the visible circle count.

```swift
Button {
    // Play
} label: {
    Image(systemName: "play.fill")
        .font(.title)
        .foregroundStyle(.white)
        .frame(width: 72, height: 72)
        .background(.pink)
        .clipShape(.circle)
        .contentShape(.circle)
}
.buttonStyle(.plain)
```

**Important:** Clipping is only visual. Without `contentShape`, taps in the square corners outside the circle still trigger the button.

### Concentric corners

Use `ConcentricRectangle` inside a `.containerShape` so inner corners keep an even gap.

```swift
VStack {
    ConcentricRectangle()
        .fill(.blue.gradient)
        .frame(height: 90)
}
.padding(10)
.background(.fill.tertiary)
.containerShape(.rect(cornerRadius: 32))
.clipShape(.rect(cornerRadius: 32))
```

**Note:** `ConcentricRectangle` is new in iOS 26. It subtracts the padding from the outer radius for you.

## Related

[shapes](shapes.md), [background-overlay](background-overlay.md), [shadow](shadow.md), [modifier-order](modifier-order.md)
