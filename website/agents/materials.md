---
id: materials
title: Materials
platforms: [iOS, iPadOS, macOS]
availability: iOS 15.0+, macOS 12.0+, visionOS 1.0+, macOS 26.0+
docs: https://developer.apple.com/documentation/swiftui/material.md
hig: https://developer.apple.com/design/human-interface-guidelines/materials.md
reviewed: October 2026
---

# Materials

Frosted, blurred backgrounds that let the content behind them show through.

## Contents

- Default code
- Rules
- Pitfalls
- Key APIs
- Variants
- On macOS
- Related

## Default code

```swift
VStack(alignment: .leading) {
    Text("Now Playing")
        .font(.headline)
    Text("Midnight City")
        .foregroundStyle(.secondary)
}
.padding()
.background(.regularMaterial, in: .rect(cornerRadius: 16))
```

**Note:** A material blurs whatever is behind the view, so it only shows over an image or color. On a plain background it looks like a gray fill.

## Rules

- **Use vibrant text styles on materials.** `.secondary` and `.tertiary` pick up the colors behind the blur and stay readable. A fixed `.gray` looks flat and muddy.
- **Use thicker materials behind text.** Thin materials keep more of the background visible, which helps people keep their place. Thicker ones give text and fine details more contrast.
- **Keep materials in the content layer.** Use them for cards, captions, and overlays. Floating controls and bars get Liquid Glass instead.
- **Pick a material for its purpose, not its color.** Its tint changes with the mode and accessibility settings, so don't count on a particular shade.

## Pitfalls

- **A material is a `ShapeStyle`.** Use it anywhere a color goes: `.background(.thinMaterial)`, `.fill`, or `.presentationBackground` on a sheet.
- **It's CSS `backdrop-filter: blur()` with extras.** It also adapts to light and dark mode and adds a tint so text stays readable.
- **For controls and bars, use [Liquid Glass](liquid-glass.md).** Since iOS 26, materials are for backgrounds inside your content.

## Key APIs

`.background(.regularMaterial)`, `.background(_:in:)`, `.ultraThinMaterial`, `.ultraThickMaterial`, `.foregroundStyle(.secondary)`, `.presentationBackground(_:)`

## Variants

### Caption over a photo

Put `.ultraThinMaterial` behind a caption so it stays readable on any image, light or dark.

```swift
Image("photo")
    .resizable()
    .scaledToFill()
    .frame(height: 220)
    .overlay(alignment: .bottom) {
        VStack(alignment: .leading) {
            Text("Photo of the Day").font(.headline)
            Text("Readable on any image").foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.ultraThinMaterial)
    }
    .clipShape(.rect(cornerRadius: 20))
```

### Floating badge

Use `.background(.thinMaterial, in: .capsule)` for counts, tags, and status that sit above content.

```swift
Label("3 new", systemImage: "bell.fill")
    .font(.subheadline.weight(.semibold))
    .padding(.horizontal, 14)
    .padding(.vertical, 8)
    .background(.thinMaterial, in: .capsule)
```

## On macOS

Liquid Glass for controls that float above content, standard materials within it.

### Rules

- **Keep Liquid Glass out of the content.** Glass marks the layer of controls and navigation that floats above your content. Glass cards and backgrounds inside the content blur that line; use a standard material there instead.
- **Use glass sparingly on your own controls.** Glass draws attention to what's beneath it. Save it for the few custom controls that matter most, like the playback controls over a video.
- **Use clear glass only over rich media.** The clear variant lets photos and video show through. Over bright content, add a dark layer at about 35% opacity behind it so labels stay readable.
- **Use vibrant colors on materials.** Hierarchical styles like `.secondary` blend with a material for contrast. A fixed color, like `.gray`, turns that blending off.

### Pitfalls

- **Standard components already use Liquid Glass.** Toolbars, sidebars, and system controls pick it up on their own in macOS 26. Reach for `.glassEffect` only for your own controls.
- **A material blurs your app, not the desktop.** SwiftUI's materials blur the content inside your window, not what's behind it on screen.

### Key APIs

`.glassEffect(_:in:)`, `GlassEffectContainer`, `.buttonStyle(.glass)`, `.buttonStyle(.glassProminent)`, `.glassEffect(.clear)`, `\.accessibilityReduceTransparency`

### Variants

#### Glass buttons over media

Use `.buttonStyle(.glass)` for controls that float over a photo or video, and wrap them in a `GlassEffectContainer`.

```swift
ZStack(alignment: .bottom) {
    Image("photo")
        .resizable()
        .scaledToFill()
    GlassEffectContainer {
        HStack {
            Button("Previous", systemImage: "backward.fill") { }
            Button("Play", systemImage: "play.fill") { }
            Button("Next", systemImage: "forward.fill") { }
        }
        .labelStyle(.iconOnly)
        .buttonStyle(.glass)
    }
    .padding()
}
.frame(width: 360, height: 200)
.clipped()
```

More variants, left out to keep this file short: Progress overlay, Clear glass with a dimming layer (macOS), A material in the content (macOS), Respect Reduce Transparency (macOS). Apple's docs: https://developer.apple.com/documentation/swiftui/material.md

## Related

[liquid-glass](liquid-glass.md), [background-overlay](background-overlay.md), [system-colors](system-colors.md), [visual-effects](visual-effects.md), [color](color.md), [dark-mode](dark-mode.md), [contrast-transparency](contrast-transparency.md), [toolbar](toolbar.md), [navigation-split-view](navigation-split-view.md)
