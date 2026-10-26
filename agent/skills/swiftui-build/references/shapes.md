---
id: shapes
title: Shapes
platforms: [iOS, iPadOS]
availability: iOS 13.0+, macOS 10.15+, visionOS 1.0+
docs: https://developer.apple.com/documentation/swiftui/shape.md
---

# Shapes

Rectangles, circles, capsules, and your own paths, ready to fill, stroke, or clip with.

Also called: border-radius, rounded corners, circle, svg, path, pill, div, canvas, draw, UIBezierPath.

## Contents

- Default code
- Pitfalls
- Key APIs
- Variants
- Related

## Default code

```swift
RoundedRectangle(cornerRadius: 24)
    .fill(.blue)
    .frame(width: 240, height: 180)
```

**Note:** A shape fills all the space it's offered, like a `div` at 100% width and height. Give it a size with `.frame`.

## Pitfalls

- **Use shape shorthands wherever a shape is expected.** `.rect(cornerRadius: 12)`, `.capsule`, and `.circle` work in `.clipShape`, `.background(_:in:)`, and `.contentShape`.
- **Corners are continuous by default.** Rounded rectangles use Apple's smooth corner curve, which looks softer than CSS `border-radius`.

## Key APIs

- `RoundedRectangle(cornerRadius:)`: A rectangle with rounded corners.
- `Circle()`, `Capsule()`: A circle, and a pill with fully round ends.
- `.fill(_:)`: Paints the inside with a color or gradient.
- `.strokeBorder(_:lineWidth:)`: Draws an outline inside the edge.
- `.clipShape(_:)`: Cuts any view to a shape.
- `.background(_:in:)`: Puts a shape-filled background behind a view.
- `.trim(from:to:)`: Draws only part of the outline, for rings.
- `Shape`: Your own shape: return a `Path` from `path(in:)`.

## Variants

### Shapes as backgrounds and clips

Usually a shape styles another view, through `.background(_:in:)`, `.clipShape`, or `.overlay`.

```swift
HStack(spacing: 12) {
    Text("Tag")
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(.blue.opacity(0.15), in: .capsule)

    Image(systemName: "person.fill")
        .font(.title)
        .frame(width: 56, height: 56)
        .background(.orange.gradient)
        .foregroundStyle(.white)
        .clipShape(.circle)

    Text("Card")
        .padding()
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(.secondary, lineWidth: 1)
        }
}
```

**Important:** Use `.strokeBorder` for borders. `.stroke` centers the line on the edge, so half of it spills outside and can get clipped.

### Progress ring with trim

Use `.trim(from:to:)` to draw only part of a circle's outline, like a progress ring.

```swift
@State private var progress = 0.65

ZStack {
    Circle()
        .stroke(.fill.tertiary, lineWidth: 14)
    Circle()
        .trim(from: 0, to: progress)
        .stroke(.green, style: StrokeStyle(lineWidth: 14, lineCap: .round))
        .rotationEffect(.degrees(-90))
    Text(progress, format: .percent.precision(.fractionLength(0)))
        .font(.title2.bold())
}
.frame(width: 120, height: 120)
```

### Concentric corners

`ConcentricRectangle` takes its corner radius from its container, so nested corners line up.

```swift
VStack {
    Text("Inner content")
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.blue.opacity(0.2), in: ConcentricRectangle())
}
.padding(10)
.frame(width: 240, height: 140)
.background(.fill.tertiary)
.containerShape(.rect(cornerRadius: 32))
.clipShape(.rect(cornerRadius: 32))
```

**Note:** `ConcentricRectangle` is new in iOS 26. Use it for buttons and cards inside sheets and other rounded containers.

## Related

[clip-shape](clip-shape.md), [gradients](gradients.md), [background-overlay](background-overlay.md), [frame](frame.md)
