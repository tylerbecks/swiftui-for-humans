---
id: accessibility
title: Accessibility
platforms: [iOS, iPadOS]
docs: https://developer.apple.com/documentation/swiftui/view-accessibility.md
hig: https://developer.apple.com/design/human-interface-guidelines/accessibility.md
reviewed: October 2026
---

# Accessibility

What to support from day one so everyone can use your app.

Also called: a11y, accessible, screen reader, aria, WCAG, inclusive design, disability, assistive technology, Accessibility Nutrition Labels.

## Rules

- **Make controls at least 44 × 44 points.** Small targets are hard to hit, especially with limited dexterity. Grow the tappable area with padding or a frame, even if the icon stays small.
- **Leave room between controls.** Spacing matters as much as size. About 12 points around controls with a background, and about 24 around plain icons, keeps people from tapping the wrong one.
- **Offer a button for every gesture.** If a swipe deletes or a long press opens options, give people another way to do it too, such as a visible button or menu.
- **Don't hide things on a timer.** Messages that dismiss themselves can vanish before someone using VoiceOver or reading slowly gets to them. Let people close them.

## Pitfalls

- **Accessibility Inspector finds problems for you.** It ships with Xcode and highlights missing labels, small targets, and low contrast while your app runs.
- **As of October 2026, Accessibility Nutrition Labels are voluntary.** You declare in App Store Connect which features your app supports, and they show on your product page. Apple says they'll become required for new apps and updates over time, without a date yet.

## Guide

People use iPhone in many ways: listening with **VoiceOver**, reading at a much larger text size, with motion turned down, or without telling certain colors apart. SwiftUI's standard controls handle a lot of this for you. Your work is mostly in the custom parts: icon-only buttons, fixed sizes, your own animations, and color choices.

```swift
struct DeliveryCard: View {
    @Environment(\.dynamicTypeSize) private var typeSize
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var bounce = false

    var body: some View {
        let layout = typeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading))
            : AnyLayout(HStackLayout())
        layout {
            Image(systemName: "box.truck.fill")
                .font(.title2)
                .offset(y: bounce && !reduceMotion ? -4 : 0)
                .accessibilityHidden(true)
            VStack(alignment: .leading) {
                Text("Order 1042").font(.headline)
                Label("Out for delivery", systemImage: "shippingbox.circle.fill")
                    .font(.subheadline)
                Text("Arrives today by 6 PM")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .accessibilityElement(children: .combine)
        .onAppear {
            withAnimation(.easeInOut.repeatForever()) { bounce = true }
        }
    }
}
```

**Note:** The switches here only change this preview. Your app reads the real settings from the environment, as in the code above.

### Start here

Check these off as you build. Each one links to a page that shows how.

- **Label every icon-only button**: Give it a short name VoiceOver can read, like “Share”. ([voiceover](voiceover.md))
- **Hide decorative images**: Use `Image(decorative:)` or `.accessibilityHidden(true)`. ([voiceover](voiceover.md))
- **Use text styles, not fixed sizes**: `.font(.body)` grows with the person's text size. ([dynamic-type](dynamic-type.md))
- **Check the largest text sizes**: Text should wrap, not overlap or cut off. ([dynamic-type](dynamic-type.md))
- **Swap big motion for fades**: Do it when Reduce Motion is on, and add Pause to anything that loops. ([reduce-motion](reduce-motion.md))
- **Meet 4.5:1 contrast for text**: In light and dark mode. ([color-and-contrast](color-and-contrast.md))
- **Never rely on color alone**: Add an icon, shape, or word to every status. ([color-and-contrast](color-and-contrast.md))
- **Make targets at least 44 × 44 pt**: Add padding around small icons. ([button](button.md))
- **Tell the App Store what you support**: Accessibility Nutrition Labels in App Store Connect. ([accessibility-labels](accessibility-labels.md))

## Key APIs

- `.accessibilityLabel(_:)`: What VoiceOver says for a view.
- `.font(.body)`: A text style that grows with Dynamic Type.
- `\.accessibilityReduceMotion`: True when people turn on Reduce Motion.
- `\.colorSchemeContrast`: `.increased` when Increase Contrast is on.
- `\.dynamicTypeSize`: The text size people picked in Settings.

## Related

[voiceover](voiceover.md), [dynamic-type](dynamic-type.md), [reduce-motion](reduce-motion.md), [color-and-contrast](color-and-contrast.md), [accessibility-labels](accessibility-labels.md), [typography](typography.md)
