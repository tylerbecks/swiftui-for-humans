---
id: reduce-motion
title: Reduce Motion
platforms: [iOS, iPadOS, macOS]
availability: iOS 14.0+, macOS 10.15+
docs: https://developer.apple.com/documentation/swiftui/environmentvalues/accessibilityreducemotion.md
hig: https://developer.apple.com/design/human-interface-guidelines/motion.md
reviewed: October 2026
---

# Reduce Motion

Swap big movement for fades when people ask for less motion.

## Rules

- **Replace motion with a fade, don't just delete it.** If an animation shows where something went, like an item landing in a cart, keep that meaning with a dissolve, highlight, or color change.
- **Cut zooming, spinning, and depth effects.** Parallax, big scale changes, spins, and animated blur cause the most discomfort. Turn them off or replace them when the setting is on.
- **Let people pause anything that moves on its own.** Carousels, looping backgrounds, and autoplaying video should stop with Reduce Motion, or at least have a visible pause button.
- **Don't make people wait for an animation.** Keep feedback short, and let people act before it finishes, especially for something they'll see many times.
- **Never use motion as the only signal.** Some people turn motion down or don't notice it. Pair it with text, a color or shape change, or a haptic.

## Pitfalls

- **It's `prefers-reduced-motion` for SwiftUI.** Read it from the environment, and SwiftUI updates the view when the setting changes.
- **Focus on your own animations.** Apple's standard components can adjust their motion for accessibility settings themselves. Custom transitions and springs are up to you.

## Guide

**Reduce Motion** is a setting for people who get dizzy, nauseous, or distracted by movement on screen. When it's on, turn off motion that's only decoration, and replace motion that carries meaning with something calmer, like a fade. Don't strip every animation: an app with no transitions at all can be more confusing.

```swift
@Environment(\.accessibilityReduceMotion) private var reduceMotion

// The item flies into the cart, or fades out.
.transition(reduceMotion
    ? .opacity
    : .scale(scale: 0.2, anchor: .topTrailing).combined(with: .opacity))

// The cart bounces, or gets a soft highlight.
withAnimation(reduceMotion ? .easeInOut : .bouncy) {
    inCart = true
}
```

### What to change

When the setting is on, check every custom animation:

## Key APIs

`\.accessibilityReduceMotion`, `.transition(.opacity)`, `withAnimation(_:_:)`, `.animation(_:value:)`, `\.accessibilityPlayAnimatedImages`

## On macOS

Trade sliding, zooming, and bouncing for fades when people ask for less motion.

### Rules

- **Fade instead of moving.** Swap slides along any axis for a dissolve. If the motion showed where something went, keep that meaning with a highlight or a badge.
- **Drop zooms, depth, and blur.** Scaling, animating layers toward or away from the viewer, and animating into or out of a blur cause the most discomfort. Turn them off with the setting.
- **Tighten springs.** Less bounce means less movement to follow. A smooth curve that settles without overshooting works well.
- **Let people stop anything that moves on its own.** Stop carousels and looping backgrounds with Reduce Motion, and give them a visible pause button either way.
- **Skip motion on things people do all the time.** Standard controls already have subtle animations. Extra animation on a frequent action makes people wait every time.

### Pitfalls

- **It's `prefers-reduced-motion` for SwiftUI.** Read it from the environment, and the view updates when the setting changes.
- **Focus on your own animations.** Standard components can adjust their motion themselves. Custom transitions, springs, and anything that moves on its own are up to you.

### Variants

#### Swap a slide for a fade

Read `accessibilityReduceMotion` from the environment and pick the transition with it.

```swift
@Environment(\.accessibilityReduceMotion) private var reduceMotion
@State private var showsBanner = false

VStack {
    if showsBanner {
        Text("Saved to Library")
            .padding(8)
            .background(.green.opacity(0.2), in: .capsule)
            .transition(reduceMotion ? .opacity : .move(edge: .top))
    }
    Button("Save") {
        withAnimation { showsBanner.toggle() }
    }
}
```

**Note:** Reduce Motion is off on this Mac, so the preview slides.

More variants, left out to keep this file short: Swap a slide for a fade, Calm a spring, Stop autoplay, Calm a spring (macOS), Stop autoplay (macOS). Apple's docs: https://developer.apple.com/documentation/swiftui/environmentvalues/accessibilityreducemotion.md

## Related

`transitions` (swiftui-build skill), `spring` (swiftui-build skill), `animation-curves` (swiftui-build skill), [accessibility](accessibility.md), `symbol-effects` (swiftui-build skill), [motion](motion.md), `animation` (swiftui-build skill), [contrast-transparency](contrast-transparency.md), [keyboard-access](keyboard-access.md)
