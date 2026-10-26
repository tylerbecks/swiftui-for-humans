---
id: contrast-transparency
title: Contrast & transparency
platforms: [macOS]
availability: macOS 10.15+
docs: https://developer.apple.com/documentation/swiftui/environmentvalues/colorschemecontrast.md
hig: https://developer.apple.com/design/human-interface-guidelines/accessibility.md
reviewed: October 2026
---

# Contrast & transparency

Stay readable when people turn on Increase Contrast or Reduce Transparency.

Also called: Increase Contrast, Reduce Transparency, high contrast, prefers-contrast, prefers-reduced-transparency, colorSchemeContrast, accessibilityReduceTransparency, Differentiate Without Color, accessibilityDifferentiateWithoutColor, contrast ratio.

## Contents

- Rules
- Pitfalls
- Guide
- Key APIs
- Variants
- Related

## Rules

- **Prefer system colors.** System colors and styles already have versions for light, dark, and Increase Contrast. Custom colors need all of those from you.
- **Meet the minimum contrast.** Small text needs at least 4.5:1 against its background. Faint gray text may look elegant, but many people can't read it.
- **Never rely on color alone.** Some people can't tell red from green. Add a symbol, shape, or word so the meaning survives without the color.
- **Offer more contrast when people ask for it.** If your defaults are subtle, check `colorSchemeContrast` and strengthen borders, dividers, and secondary text when it's `.increased`.
- **Check both appearances.** A pairing that passes in light mode can fail in dark mode. Test each setting in both.

## Pitfalls

- **You can read these settings, not change them.** They belong to the person using the Mac, and SwiftUI redraws your views when they change.
- **Asset catalogs can do it without code.** If a color only needs a stronger version, give the color set a high-contrast variant instead of checking the setting in code.

## Guide

Two display settings change how much of your window people can make out. **Increase Contrast** sharpens the difference between foreground and background, and **Reduce Transparency** asks for solid backgrounds instead of see-through ones. Both are in System Settings > Accessibility > Display.

System colors already have versions for these settings. Read the settings yourself for anything custom: your own colors, borders, and translucent layers.

Turn the two settings on here to see what a custom card should do. The real settings on this Mac:

### Minimum contrast

Accessibility Inspector checks against these ratios, from WCAG level AA. Check them in light and dark.

- Text up to 17 points: At least **4.5:1**.
- Text 18 points and larger: At least **3:1**.
- Bold text at any size: At least **3:1**.

## Key APIs

- `\.colorSchemeContrast`: `.increased` when Increase Contrast is on.
- `\.accessibilityReduceTransparency`: True when backgrounds should be opaque.
- `\.accessibilityDifferentiateWithoutColor`: True when color alone isn't enough.
- `\.colorScheme`: Light or dark, to check alongside contrast.
- `.foregroundStyle(.secondary)`: System styles that adapt on their own.

## Variants

### Strengthen a border

Read `colorSchemeContrast` and draw a heavier, darker outline when it's `.increased`.

```swift
@Environment(\.colorSchemeContrast) private var contrast

Text("Draft")
    .padding(.horizontal, 10)
    .padding(.vertical, 4)
    .overlay {
        Capsule().strokeBorder(
            contrast == .increased ? Color.primary : Color.secondary.opacity(0.4),
            lineWidth: contrast == .increased ? 2 : 1
        )
    }
```

**Note:** On this Mac, Increase Contrast is off, so the preview shows the light border.

### Make a translucent layer solid

Check `accessibilityReduceTransparency` and swap a see-through background for an opaque one.

```swift
@Environment(\.accessibilityReduceTransparency) private var reduceTransparency

Image("photo")
    .resizable()
    .scaledToFill()
    .overlay(alignment: .bottomLeading) {
        Text("Lake at sunset")
            .foregroundStyle(.white)
            .padding(8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.black.opacity(reduceTransparency ? 1 : 0.4))
    }
```

**Note:** On this Mac, Reduce Transparency is off.

### Add shapes when color isn't enough

When `accessibilityDifferentiateWithoutColor` is true, show a distinct symbol for each status, not only a colored dot.

```swift
@Environment(\.accessibilityDifferentiateWithoutColor) private var differentiate

HStack {
    if differentiate {
        Image(systemName: "exclamationmark.triangle.fill")
    } else {
        Circle().frame(width: 10, height: 10)
    }
    Text("Payment failed")
}
.foregroundStyle(.red)
```

## Related

[color](color.md), [materials](materials.md), [dark-mode](dark-mode.md), [voiceover](voiceover.md), [reduce-motion](reduce-motion.md)
