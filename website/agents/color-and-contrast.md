---
id: color-and-contrast
title: Color & Contrast
platforms: [iOS, iPadOS]
availability: iOS 14.0+
docs: https://developer.apple.com/documentation/swiftui/environmentvalues/colorschemecontrast.md
hig: https://developer.apple.com/design/human-interface-guidelines/color.md
reviewed: October 2026
---

# Color & Contrast

Readable contrast, Increase Contrast support, and never using color as the only signal.

Also called: contrast ratio, WCAG, AA, 4.5:1, color blind, colour blind, colorblind, high contrast, prefers-contrast, Increase Contrast.

## Contents

- Rules
- Pitfalls
- Guide
- Key APIs
- Variants
- Related

## Rules

- **Never use color as the only signal.** Some people can't tell red from green. Add a shape, icon, or word so the meaning survives without color.
- **Give text at least 4.5:1 contrast.** Light text on a light fill washes out, especially outdoors or for people with low vision.
- **Check dark mode separately.** Contrast that passes in light mode can fail in dark mode. Dim gray on black is a common miss.
- **Prefer system colors.** Colors like `.primary`, `.secondary`, and `.blue` already have versions for dark mode and Increase Contrast. Custom colors need each version from you.

## Pitfalls

- **The ratio runs from 1:1 to 21:1.** It compares the relative brightness of two colors. Don't round it up: 4.49:1 doesn't pass 4.5:1.
- **Test in grayscale.** Turn on the Grayscale color filter in the Accessibility settings. It isn't what color-blind people see, but if you can't use your app in gray, something relies on color alone.

## Guide

Three things make color work for everyone: enough **contrast** between text and its background, support for the **Increase Contrast** setting, and never using **color alone** to say something. System colors and styles help with the first two, so most of the work is in your own colors.

### Minimum contrast

Accessibility Inspector checks your colors against these WCAG AA ratios:

**Note:** For icons, borders, and other parts of a control that aren't text, 3:1 is the common minimum.

## Key APIs

- `\.colorSchemeContrast`: `.increased` when Increase Contrast is on.
- `\.accessibilityDifferentiateWithoutColor`: True when people ask for shapes, not just color.
- `.foregroundStyle(.secondary)`: System styles adapt to contrast and dark mode.
- `Label(_:systemImage:)`: Text plus an icon, an easy second cue.

## Variants

### Respond to Increase Contrast

Read `colorSchemeContrast` and strengthen custom colors and borders when it's `.increased`.

```swift
@Environment(\.colorSchemeContrast) private var contrast

Text("Beta")
    .font(.caption.bold())
    .padding(.horizontal, 10)
    .padding(.vertical, 4)
    .foregroundStyle(contrast == .increased ? .white : .purple)
    .background(.purple.opacity(contrast == .increased ? 1 : 0.15), in: .capsule)
```

**Note:** If you only need different colors, add a High Contrast variant to the color in your asset catalog instead. It switches on its own.

### Give every status a shape

Pair each color with its own symbol in a `Label`, and keep the text in the primary color.

```swift
VStack(alignment: .leading) {
    Label {
        Text("Paid")
    } icon: {
        Image(systemName: "checkmark.circle.fill")
            .foregroundStyle(.green)
    }
    Label {
        Text("Failed")
    } icon: {
        Image(systemName: "xmark.octagon.fill")
            .foregroundStyle(.red)
    }
}
```

**Note:** Colored text is often too light to read. Tint the icon and leave the words in `.primary`.

### Explain errors in words

A red border alone is easy to miss. Add a message with an icon under the field.

```swift
@State private var email = "maya@"

VStack(alignment: .leading, spacing: 6) {
    TextField("Email", text: $email)
        .padding(10)
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(.red)
        }
    Label("Enter a full email address.", systemImage: "exclamationmark.circle.fill")
        .font(.footnote)
        .foregroundStyle(.red)
}
```

### Add shapes when people ask

When `accessibilityDifferentiateWithoutColor` is true, swap color-only marks for symbols.

```swift
@Environment(\.accessibilityDifferentiateWithoutColor) private var noColorOnly

HStack {
    Image(systemName: noColorOnly ? "checkmark.circle.fill" : "circle.fill")
        .foregroundStyle(.green)
    Text("Available")
}
```

**Important:** Treat this as a fallback. Apple's guidance is to design without color-only cues from the start.

## Related

[system-colors](system-colors.md), [accessibility](accessibility.md), [foreground-style](foreground-style.md), [label](label.md)
