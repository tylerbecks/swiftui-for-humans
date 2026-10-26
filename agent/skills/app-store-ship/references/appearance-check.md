---
id: appearance-check
title: Dark Mode & Large Text
platforms: [iOS, iPadOS]
docs: https://developer.apple.com/documentation/swiftui/dynamictypesize.md
hig: https://developer.apple.com/design/human-interface-guidelines/dark-mode.md
reviewed: October 2026
---

# Dark Mode & Large Text

Before you submit, check every screen in Dark Mode and at the largest text size.

Also called: dark mode, dark theme, prefers-color-scheme, light mode, dynamic type, font scaling, rem, text size, larger text, accessibility sizes.

## Contents

- Rules
- Pitfalls
- Guide
- Key APIs
- Variants
- Related

## Rules

- **Follow the system appearance.** People set light or dark for the whole phone. An app-only appearance setting means more work for them, and an app that ignores the setting looks broken.
- **Keep contrast high in both modes.** The HIG asks for a contrast ratio of at least 4.5:1, and suggests 7:1 for custom colors, especially in small text. System label colors are a safe start.
- **Don't cut text off at large sizes.** At the largest sizes, show as much text as at the default size. Stack items vertically instead of truncating them.

## Pitfalls

- **Test on a device too.** Turn on Larger Accessibility Sizes in Settings > Accessibility > Display & Text Size > Larger Text, then drag the slider to the end.
- **Increase Contrast changes things again.** The HIG suggests checking Dark Mode with Increase Contrast and Reduce Transparency on, separately and together.

## Guide

People pick Dark Mode and their text size once, for the whole phone, and expect every app to follow. Bugs here are easy to miss, because you probably develop in light mode at the default size. Make these two checks part of every submission.

Switch the screen below between broken and fixed, then turn on Dark Mode and the largest text.

**Important:** Hard-coded `Color.black` text disappears in Dark Mode, and `.system(size:)` fonts stay the same size when people pick larger text (try AX5 above). Both look fine until someone changes a setting.

### Before you submit

- **All text is readable in Dark Mode**: No dark text on a dark background. (`dark-mode` (apple-design skill))
- **Images and icons show up on dark backgrounds**: Check logos and illustrations with transparent edges.
- **Text grows at the largest sizes**: Every label uses a text style, not a fixed point size. (`dynamic-type` (apple-design skill))
- **Nothing important is cut off**: Rows stack, and buttons stay on screen and tappable.
- **The app follows the system setting**: No separate light/dark switch that overrides it.

## Key APIs

- `.dynamicTypeSize(_:)`: Sets or limits the text size for a view.
- `\.dynamicTypeSize`: Reads the person's current text size.
- `.isAccessibilitySize`: True for the five largest sizes.
- `.preferredColorScheme(_:)`: Forces light or dark, for previews.
- `\.colorScheme`: Reads whether the view is light or dark.
- `ViewThatFits`: Picks the first layout that fits.

## Variants

### Preview both in Xcode

Add a second `#Preview` with `.preferredColorScheme(.dark)` and a large `.dynamicTypeSize` to see both while you work.

```swift
#Preview("Light") {
    OrderSummary()
}

#Preview("Dark, largest text") {
    OrderSummary()
        .preferredColorScheme(.dark)
        .dynamicTypeSize(.accessibility3)
}
```

### Colors that adapt

Use `.primary`, `.secondary`, and `.fill` styles instead of fixed colors. They switch automatically between light and dark.

```swift
VStack(alignment: .leading) {
    Text("Deliver to")
    Text("12 Harbour St")
        .foregroundStyle(.secondary)
}
.padding()
.background(.fill.tertiary,
            in: .rect(cornerRadius: 12))
```

### A row that stacks when text is large

Wrap a row in `ViewThatFits`. It uses the side-by-side layout when it fits, and the stacked one when it doesn't.

```swift
ViewThatFits(in: .horizontal) {
    HStack {
        Text("Deliver to")
        Spacer()
        Text("12 Harbour St")
    }
    VStack(alignment: .leading) {
        Text("Deliver to")
        Text("12 Harbour St")
            .foregroundStyle(.secondary)
    }
}
```

**Note:** For bigger changes, read `@Environment(\.dynamicTypeSize)` and check `.isAccessibilitySize` to switch layouts yourself.

## Related

`dark-mode` (apple-design skill), `dynamic-type` (apple-design skill), `system-colors` (apple-design skill), `typography` (apple-design skill), `view-that-fits` (swiftui-build skill), [states-check](states-check.md)
