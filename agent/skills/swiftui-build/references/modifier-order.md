---
id: modifier-order
title: Modifier Order
platforms: [iOS, iPadOS]
availability: iOS 13.0+, macOS 10.15+, visionOS 1.0+
docs: https://developer.apple.com/documentation/swiftui/configuring-views.md
---

# Modifier Order

Each modifier wraps the view before it, so changing the order changes the result.

Also called: chaining, modifier chain, css order, box model, wrapper, decorator, why is my background wrong, padding vs background.

## Contents

- Pitfalls
- Guide
- Key APIs
- Variants
- Related

## Pitfalls

- **Read a chain top to bottom as "take this, then wrap it in that".** The last modifier is the outermost view.
- **When a background looks wrong, check the order first.** Most surprises come from `padding` or `frame` sitting on the wrong side of `background`.

## Guide

In CSS, `padding` and `background` are properties of one box, so their order doesn't matter. In SwiftUI each modifier is a **new view that wraps the one before it**, and `background` paints whatever size it receives. So it matters whether `padding` comes before it or after.

### Playground

Turn modifiers on and off, and move them up or down. The preview and code follow the order you set.

```swift
Text("Hello")
    .font(.title2.bold())
    .padding(20)
    .background(.orange)
    .clipShape(.capsule)
    .border(.primary, width: 3)
    .frame(width: 240, height: 110)
```

### Why order matters

A modifier doesn't change the view you call it on. It returns a **new view** that contains the old one, so each line adds a layer on the outside, like nesting `<div>`s. Here's the chain above, outermost first:

Each layer only knows the size of the layer directly inside it. A `background` after `padding` sees the padded size and fills it. Before it, the `background` sees only the text, and the padding adds clear space outside.

**Note:** Environment modifiers aren't order-sensitive. `.font(.title).padding()` and `.padding().font(.title)` look the same, because `font` passes its value down to everything inside.

## Key APIs

- `.padding(_:)`: Layout: grows the size that later modifiers see.
- `.frame(width:height:)`: Layout: proposes a new size for everything after it.
- `.background(_:)`: Drawing: fills whatever size it's handed.
- `.clipShape(_:)`: Drawing: cuts off everything before it, shadows included.
- `.font(_:)`: Environment: flows down, so its position rarely matters.

## Variants

### Padding inside or outside the color

Put `padding` before `background` for a filled chip, and after it for space around the chip.

```swift
// In the preview, a dashed line marks the padded area
Text("Padding first")
    .padding()
    .background(.yellow)
    .foregroundStyle(.black)

Text("Background first")
    .background(.yellow)
    .foregroundStyle(.black)
    .padding()
```

### A clipped shadow

Call `clipShape` before `shadow`, or the clip cuts the shadow off with everything else.

```swift
// Shadow is cut off
Color.blue
    .frame(width: 100, height: 70)
    .shadow(radius: 12)
    .clipShape(.rect(cornerRadius: 16))

// Shadow shows
Color.blue
    .frame(width: 100, height: 70)
    .clipShape(.rect(cornerRadius: 16))
    .shadow(radius: 12)
```

### Frame, then background

Put `background` after `frame` to fill the whole frame, not just the text inside it.

```swift
// In the preview, a dashed line marks the frame
Text("Frame first")
    .frame(width: 140, height: 60)
    .background(.mint)
    .foregroundStyle(.black)

Text("Background first")
    .background(.mint)
    .frame(width: 140, height: 60)
    .foregroundStyle(.black)
```

**Note:** `frame` makes a bigger box but doesn't paint it. The dashed line shows the empty frame.

### Stacking the same modifier

Repeat `padding` and `background` to stack layers, like a double border.

```swift
Text("Layered")
    .padding(12)
    .background(.blue)
    .padding(8)
    .background(.blue.opacity(0.3))
```

## Related

[padding](padding.md), [background-overlay](background-overlay.md), [frame](frame.md), [custom-modifier](custom-modifier.md)
