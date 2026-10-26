---
id: foreground-style
title: foregroundStyle & tint
platforms: [iOS, iPadOS]
availability: iOS 15.0+, macOS 12.0+, visionOS 1.0+
docs: https://developer.apple.com/documentation/swiftui/view/foregroundstyle(_:).md
hig: https://developer.apple.com/design/human-interface-guidelines/color.md
---

# foregroundStyle & tint

Colors text, symbols, and shapes, and sets the accent color of controls.

Also called: color, text color, font color, foregroundColor, accentColor, brand color, secondary text, muted, gray text, tintColor.

## Contents

- Default code
- Rules
- Pitfalls
- Key APIs
- Variants
- Related

## Default code

```swift
VStack(alignment: .leading) {
    Text("Downloads")
        .font(.headline)
    Text("12 files, 2.4 GB")
        .foregroundStyle(.secondary)
    Button("Download All") {}
        .buttonStyle(.borderedProminent)
}
.tint(.green)
```

**Note:** `foregroundStyle` is for content like text and icons. `tint` is for controls. Setting `foregroundStyle` on a button doesn't change its fill.

## Rules

- **Save your tint color for things people can tap.** If titles and plain text use the same color as buttons, people can't tell what's interactive.
- **Don't rely on color alone.** Some people can't tell red from green. Pair a status color with a symbol or a word so everyone gets the message.
- **Use semantic styles instead of fixed colors.** `.primary`, `.secondary`, and system colors adjust for dark mode and Increase Contrast. A hard-coded gray or hex value doesn't.

## Pitfalls

- **`.foregroundColor(_:)` is deprecated.** `foregroundStyle` takes any style: a color, a gradient, a material, or a level like `.secondary`.
- **Both modifiers flow down to every child.** Set them once on a container, like CSS `color` inherited by nested elements.
- **`tint` replaces `accentColor`.** Set it once near the root of your app to give every control your brand color.

## Key APIs

- `.foregroundStyle(_:)`: Colors text, symbols, and shapes inside the view.
- `.secondary` / `.tertiary`: Dimmer levels of the current style, for supporting text.
- `.foregroundStyle(_:_:)`: Colors the layers of a multi-layer SF Symbol.
- `.tint(_:)`: The accent color of buttons, toggles, sliders, and links.
- `.tint`: A style that means "the current tint", for your own views.

## Variants

### Hierarchy levels

Use `.secondary`, `.tertiary`, and `.quaternary` for supporting text instead of picking grays.

```swift
VStack(alignment: .leading) {
    Text("Primary").foregroundStyle(.primary)
    Text("Secondary").foregroundStyle(.secondary)
    Text("Tertiary").foregroundStyle(.tertiary)
    Text("Quaternary").foregroundStyle(.quaternary)
}
.font(.title3.weight(.semibold))
```

**Note:** These levels adapt to light mode, dark mode, and Increase Contrast automatically.

### Levels follow the parent style

Set a color once on the container, and `.secondary` inside becomes a dimmer version of it.

```swift
VStack(alignment: .leading, spacing: 2) {
    Text("Workout complete")
        .font(.headline)
    Text("32 min, 410 kcal")
        .foregroundStyle(.secondary)
}
.foregroundStyle(.green)
```

### Brand color for controls

Set `.tint` on a container to recolor every toggle, slider, and prominent button inside.

```swift
@State private var isOn = true

VStack {
    Toggle("Notifications", isOn: $isOn)
    Button("Save") {}
        .buttonStyle(.borderedProminent)
}
.tint(.orange)
```

### Two-color symbols

Pass two styles to `.foregroundStyle(_:_:)` to color the layers of a multi-layer SF Symbol.

```swift
Image(systemName: "person.crop.circle.badge.plus")
    .font(.system(size: 56))
    .foregroundStyle(.blue, .gray)
```

### Gradient text

Pass a gradient to `.foregroundStyle` for colorful headline text; any `ShapeStyle` works.

```swift
Text("Hello, gradient")
    .font(.largeTitle.bold())
    .foregroundStyle(.linearGradient(colors: [.orange, .pink], startPoint: .leading, endPoint: .trailing))
```

## Related

[system-colors](system-colors.md), [font](font.md), [gradients](gradients.md), [sf-symbols](sf-symbols.md)
