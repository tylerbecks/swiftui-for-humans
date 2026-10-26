---
id: gradients
title: Gradients
platforms: [iOS, iPadOS]
availability: iOS 13.0+, macOS 10.15+, visionOS 1.0+
docs: https://developer.apple.com/documentation/swiftui/gradient.md
hig: https://developer.apple.com/design/human-interface-guidelines/color.md
---

# Gradients

Smooth blends between colors: in a line, outward from a point, around a circle, or across a mesh.

Also called: linear-gradient, radial-gradient, conic-gradient, background-image, mesh, fade, ombre, CAGradientLayer.

## Contents

- Default code
- Rules
- Pitfalls
- Key APIs
- Variants
- Related

## Default code

```swift
RoundedRectangle(cornerRadius: 24)
    .fill(
        LinearGradient(
            colors: [.orange, .pink, .purple],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    )
    .frame(height: 220)
```

## Rules

- **Keep text readable on gradients.** Check contrast at the lightest part of the gradient, not the middle. Add a dark fade or pick deeper colors where text sits.
- **Check gradients in dark mode.** System colors shift between modes, and a gradient that glows on white can feel harsh on black.
- **Don't use a gradient as the only signal.** A green-to-red bar needs a number or a label too, since some people can't tell those colors apart.

## Pitfalls

- **Gradients are `ShapeStyle`s, like colors.** Pass one to `.fill`, `.background`, or `.foregroundStyle` to paint shapes, views, or text.
- **They map to CSS.** `LinearGradient` is `linear-gradient`, `RadialGradient` is `radial-gradient`, and `AngularGradient` is `conic-gradient`.
- **`MeshGradient` needs iOS 18.** It blends a grid of colors; animate its points with `TimelineView` for a living background.

## Key APIs

- `Color.blue.gradient`: A subtle gradient the system tunes for you.
- `LinearGradient`: Blends colors along a line between two points.
- `RadialGradient`: Blends outward from a center point.
- `AngularGradient`: Blends around a center, like a color wheel.
- `MeshGradient`: Blends a grid of colors (iOS 18).
- `Gradient.Stop(color:location:)`: Places a color at an exact spot, from 0 to 1.

## Variants

### Fade for readable text

Lay a clear-to-black `LinearGradient` over a photo so white text reads on any image.

```swift
Image("photo")
    .resizable()
    .scaledToFill()
    .frame(height: 220)
    .overlay {
        LinearGradient(colors: [.clear, .black.opacity(0.7)],
                       startPoint: .center, endPoint: .bottom)
    }
    .overlay(alignment: .bottomLeading) {
        Text("Weekend Getaways")
            .font(.title2.bold())
            .foregroundStyle(.white)
            .padding()
    }
    .clipShape(.rect(cornerRadius: 20))
```

**Note:** Designers call this a scrim. Start it near the middle so the top of the photo stays bright.

### Icon tile with the shorthand

Use `Color.pink.gradient` for a quick, subtle gradient, like the icons in Settings.

```swift
let icons: [(String, Color)] = [("heart.fill", .pink), ("bell.fill", .red), ("gearshape.fill", .gray)]

HStack(spacing: 16) {
    ForEach(icons, id: \.0) { symbol, color in
        Image(systemName: symbol)
            .font(.title2)
            .foregroundStyle(.white)
            .frame(width: 56, height: 56)
            .background(color.gradient, in: .rect(cornerRadius: 14))
    }
}
```

### Gradient text

Pass a gradient to `.foregroundStyle` to paint text and SF Symbols.

```swift
Text("Hello, gradients")
    .font(.largeTitle.bold())
    .foregroundStyle(
        LinearGradient(colors: [.orange, .pink, .purple],
                       startPoint: .leading, endPoint: .trailing)
    )
```

### Hard stops

Put two `Gradient.Stop`s at the same location to get a sharp edge instead of a blend.

```swift
Capsule()
    .fill(LinearGradient(
        stops: [
            .init(color: .green, location: 0),
            .init(color: .green, location: 0.6),
            .init(color: .gray.opacity(0.3), location: 0.6),
            .init(color: .gray.opacity(0.3), location: 1),
        ],
        startPoint: .leading, endPoint: .trailing
    ))
    .frame(height: 16)
```

## Related

`system-colors` (apple-design skill), [shapes](shapes.md), [foreground-style](foreground-style.md), `materials` (apple-design skill)
