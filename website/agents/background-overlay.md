---
id: background-overlay
title: background & overlay
platforms: [iOS, iPadOS]
availability: iOS 15.0+, macOS 12.0+, visionOS 1.0+
docs: https://developer.apple.com/documentation/swiftui/view/background(alignment:content:).md
---

# background & overlay

Layers a color, shape, or view behind or on top of a view, sized to match it.

Also called: background-color, bg, z-index, position: absolute, badge, layer, border, ZStack, ::before, ::after.

## Contents

- Default code
- Pitfalls
- Key APIs
- Variants
- Related

## Default code

```swift
Label("Inbox", systemImage: "tray.fill")
    .padding()
    .background(.blue.opacity(0.15), in: .capsule)
    .overlay(alignment: .topTrailing) {
        Circle()
            .fill(.red)
            .frame(width: 12, height: 12)
    }
```

**Note:** `.background(_:in:)` fills a shape in one step, without clipping the content the way `.clipShape` would.

## Pitfalls

- **A background or overlay never changes the view's size.** Unlike a `ZStack`, it takes the size of the view it's attached to, so it's ideal for decoration.
- **A color background spreads under the safe area.** When `.background(Color)` touches the screen edge, it extends behind the status bar. Pass `ignoresSafeAreaEdges: []` to stop it.

## Key APIs

- `.background(_:in:)`: Fills a shape behind the view, like `.capsule`.
- `.background { }`: Puts any view behind, sized to match.
- `.overlay(alignment:) { }`: Puts any view on top, pinned to an edge or corner.
- `.overlay { Shape().strokeBorder() }`: Draws an outline that lines up with the fill.
- `.background(.ultraThinMaterial)`: A blurred, translucent backdrop.

## Variants

### Avatar with a status dot

Use `.overlay(alignment:)` to pin a status dot to an avatar's corner.

```swift
Image(systemName: "person.crop.circle.fill")
    .font(.system(size: 64))
    .foregroundStyle(.gray)
    .overlay(alignment: .bottomTrailing) {
        Circle()
            .fill(.green)
            .frame(width: 18, height: 18)
            .padding(3)
            .background(.background, in: .circle)
    }
```

**Note:** The `.background(.background, in: .circle)` behind the dot draws a ring in the page color, so the dot stands out in light and dark.

### Notification badge

Pin a count to a corner with `.overlay(alignment: .topTrailing)`, then nudge it with `.offset`.

```swift
Image(systemName: "envelope.fill")
    .font(.system(size: 30))
    .foregroundStyle(.white)
    .frame(width: 64, height: 64)
    .background(.blue.gradient, in: .rect(cornerRadius: 16))
    .overlay(alignment: .topTrailing) {
        Text("3")
            .font(.callout.bold())
            .foregroundStyle(.white)
            .frame(width: 26, height: 26)
            .background(.red, in: .circle)
            .offset(x: 8, y: -8)
    }
```

### Caption over an image

Put text in an `.overlay` with a dark gradient behind it, so it stays readable on any photo.

```swift
LinearGradient(colors: [.teal, .indigo], startPoint: .topLeading, endPoint: .bottomTrailing)
    .frame(height: 140)
    .overlay(alignment: .bottomLeading) {
        Text("Big Sur, California")
            .font(.headline)
            .foregroundStyle(.white)
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.linearGradient(colors: [.clear, .black.opacity(0.6)], startPoint: .top, endPoint: .bottom))
    }
    .clipShape(.rect(cornerRadius: 16))
```

**Important:** White text straight on a photo disappears on bright areas. Always add a scrim or a material behind it.

### Outline with a stroke overlay

Pair a fill with an `.overlay` of `Capsule().strokeBorder()` for an outlined pill.

```swift
Text("Outlined")
    .padding(.horizontal, 20)
    .padding(.vertical, 10)
    .background(.blue.opacity(0.1), in: .capsule)
    .overlay {
        Capsule()
            .strokeBorder(.blue, lineWidth: 1.5)
    }
```

**Note:** `strokeBorder` draws inside the shape's edge. `stroke` straddles it, so half the line hangs outside the fill.

## Related

[modifier-order](modifier-order.md), [clip-shape](clip-shape.md), [shapes](shapes.md), [materials](materials.md)
