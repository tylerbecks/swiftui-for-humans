---
id: frame
title: frame
platforms: [iOS, iPadOS]
availability: iOS 13.0+, macOS 10.15+, visionOS 1.0+
docs: https://developer.apple.com/documentation/swiftui/view/frame(width:height:alignment:).md
hig: https://developer.apple.com/design/human-interface-guidelines/layout.md
---

# frame

Sets a view's size, or lets it stretch to fill the space it's offered.

Also called: width, height, size, full width, width: 100%, max-width, min-height, flex-grow, fill, stretch.

## Contents

- Default code
- Rules
- Pitfalls
- Key APIs
- Variants
- Related

## Default code

```swift
Text("Welcome back")
    .font(.headline)
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding()
    .background(.fill.tertiary, in: .rect(cornerRadius: 12))
```

**Note:** A frame is a new, invisible box around the view, not the view itself. Add a `.background` after it to see how big it is.

## Rules

- **Make every tap target at least 44 × 44 points.** Small icons are easy to miss with a finger. Grow the frame with `minWidth` and `minHeight` instead of the icon.
- **Let text set its own width.** Labels get longer in other languages and at larger text sizes. A fixed width cuts them off, so prefer `maxWidth` or no frame at all.
- **Size by the space you have, not the device.** Use flexible frames and `containerRelativeFrame` so the same layout works on every iPhone and in iPad windows.

## Pitfalls

- **Only flexible views fill a frame.** Shapes, colors, and `resizable()` images grow to fit it. Text and controls keep their natural size and sit inside at `alignment`.
- **Mixing fixed and flexible sizes takes two frames.** A single call can't combine `width:` with `maxHeight:`, so chain `.frame(width: 200).frame(maxHeight: .infinity)`.

## Key APIs

- `.frame(width:height:)`: A fixed size in points. Leave one out to keep it natural.
- `.frame(maxWidth: .infinity)`: Stretches to fill the width, like CSS `width: 100%`.
- `.frame(minWidth:minHeight:)`: Never smaller than this, but free to grow.
- `alignment:`: Where the content sits inside a larger frame.
- `.fixedSize()`: Keeps the natural size, even if that means overflowing.
- `.containerRelativeFrame(_:)`: Sizes a view as a fraction of its container.

## Variants

### Full-width button

Put `.frame(maxWidth: .infinity)` on the label, not the button, so the whole bar fills.

```swift
Button {
    // Continue
} label: {
    Text("Continue")
        .frame(maxWidth: .infinity)
}
.buttonStyle(.borderedProminent)
.controlSize(.large)
```

### Leading-aligned text without a Spacer

Use `.frame(maxWidth: .infinity, alignment: .leading)` to line text up on the leading edge.

```swift
VStack(spacing: 8) {
    Text("Title")
        .font(.headline)
        .frame(maxWidth: .infinity, alignment: .leading)
    Text("A longer subtitle line")
        .frame(maxWidth: .infinity, alignment: .leading)
}
```

**Note:** A `VStack` centers its children by default. This is often simpler than wrapping each line in an `HStack` with a `Spacer`.

### Square avatar

Give icons and avatars a fixed `.frame(width:height:)` so they line up at one size.

```swift
Image(systemName: "person.fill")
    .font(.system(size: 30))
    .foregroundStyle(.white)
    .frame(width: 64, height: 64)
    .background(.indigo.gradient)
    .clipShape(.circle)
```

**Important:** Clip after the frame. Clipping first cuts the small icon, not the 64-point circle.

### Minimum tap target

Use `minWidth` and `minHeight` to keep a small icon button at least 44 points.

```swift
Button {
    // Close
} label: {
    Image(systemName: "xmark")
        .frame(minWidth: 44, minHeight: 44)
        .contentShape(.rect)
}
```

**Note:** `.contentShape(.rect)` makes the empty part of the frame tappable too. The dashed outline shows the target.

## Related

[layout-basics](layout-basics.md), [padding](padding.md), [spacer-divider](spacer-divider.md), [geometry-reader](geometry-reader.md)
