---
id: accessibility-labels
title: Accessibility Labels
platforms: [iOS, iPadOS]
docs: https://developer.apple.com/help/app-store-connect/manage-app-accessibility/overview-of-accessibility-nutrition-labels
hig: https://developer.apple.com/design/human-interface-guidelines/accessibility.md
reviewed: October 2026
---

# Accessibility Labels

Accessibility Nutrition Labels show which accessibility features your app supports.

Also called: accessibility label, accessibility nutrition label, App Accessibility, a11y, VoiceOver, Voice Control, Larger Text, Dynamic Type, Dark Interface, Differentiate Without Color.

## Rules

- **Claim a feature only if every common task works.** Apple's rule is that people can finish all the app's common tasks with that feature alone. App Review can ask you to fix misleading labels.
- **Don't rely on color alone.** To claim Differentiate Without Color Alone, pair color with a shape, symbol, or text.
- **Let text grow without cutting it off.** Larger Text means text reaches at least 200% without overlapping or heavy truncation. System Zoom doesn't count.
- **Keep a dark interface dark.** For Dark Interface, every common task has to stay dark. A sudden white screen can hurt someone with light sensitivity.

## Pitfalls

- **Answer per device.** Support can differ between iPhone and iPad, so App Store Connect asks for each one, and you should test on each.
- **Add an accessibility URL.** An optional link on your product page can explain settings, caption languages, or areas that aren't supported yet.
- **Re-check with every update.** Apple asks you to keep the labels accurate as your app changes.

## Guide

Accessibility Nutrition Labels are a section on your App Store product page that lists the accessibility features your app supports, like VoiceOver and Larger Text. People see them on iOS 26 and later, and can even search for them, as in “VoiceOver note taking apps”.

**Note:** As of October 2026 the labels are voluntary. Apple says they'll become required for new apps and updates over time. If you don't answer, your page says you haven't indicated support yet.

### The nine features

Turn on the features your app supports to build a sample of the section. Apple suggests evaluating them in this order, starting with VoiceOver.

### How to evaluate your app

1. List your app's **common tasks**: its main features, plus first launch, login, purchases, and settings.
2. Turn on one feature, starting with VoiceOver, and learn to use it well.
3. Try every common task with only that feature, on each device you support.
4. Claim the feature only if all of them work. Note the gaps and fix them next release.

**Important:** Zoom and Hover Text don't count as Larger Text support. They work in every app already, so your own text has to grow, through Dynamic Type or an in-app size setting.

### Add them in App Store Connect

1. Open your app and choose **App Accessibility** in the sidebar, then **Get Started**.
2. Pick a device, say whether you support any features, and select them.
3. Click **Publish**. You can only publish for devices with a live version, and changes can take 24 hours to show.

## Key APIs

- `.accessibilityLabel(_:)`: What VoiceOver reads for a view.
- `.font(.body)`: Text styles scale with Larger Text.
- `\.dynamicTypeSize`: The person's text size.
- `\.accessibilityReduceMotion`: Reduce Motion is on.

## Variants

### Label icon-only buttons

Use `.accessibilityLabel(_:)` so VoiceOver and Voice Control have a name to read and say.

```swift
Button {
    isFavorite.toggle()
} label: {
    Image(systemName: isFavorite ? "heart.fill" : "heart")
}
.accessibilityLabel("Favorite")
```

### Stack rows at large text sizes

Read `dynamicTypeSize` and stack the row at accessibility sizes, shown second here, so text never overlaps.

```swift
@Environment(\.dynamicTypeSize) private var size

var body: some View {
    let layout = size.isAccessibilitySize
        ? AnyLayout(VStackLayout(alignment: .leading))
        : AnyLayout(HStackLayout())
    layout {
        Text("Delivery")
        Spacer()
        Text("Tomorrow, 9–11 AM")
            .foregroundStyle(.secondary)
    }
}
```

## Related

`accessibility` (apple-design skill), `voiceover` (apple-design skill), `dynamic-type` (apple-design skill), `color-and-contrast` (apple-design skill), `reduce-motion` (apple-design skill), `dark-mode` (apple-design skill)
