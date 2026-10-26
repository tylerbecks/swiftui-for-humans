---
id: motion
title: Motion
platforms: [iOS, iPadOS, macOS]
availability: iOS 17.0+
docs: https://developer.apple.com/documentation/swiftui/animation.md
hig: https://developer.apple.com/design/human-interface-guidelines/motion.md
reviewed: October 2026
---

# Motion

Animate to explain what changed, keep it short, and know when to skip it.

## Contents

- Rules
- Pitfalls
- Guide
- Key APIs
- Variants
- On macOS
- Related

## Rules

- **Animate with a purpose.** Motion should explain what changed or confirm an action. Motion that's only decoration distracts people and can make some feel unwell.
- **Don't let motion carry the message alone.** Not everyone sees or wants animation. Pair it with text, a symbol, or a haptic so the meaning survives without it.
- **Keep feedback brief.** Short, precise motion feels light and often tells people more than a big show. Tie it closely to the action that caused it.
- **Go easy on things people do often.** Standard controls already animate. A custom effect on an action people repeat all day soon feels slow.
- **Never make people wait for an animation.** Let people keep tapping while things move. SwiftUI animations can be interrupted, so don't block input until one finishes.

## Pitfalls

- **Springs are the default.** Since iOS 17, `withAnimation` without an argument uses a spring, not ease-in-out.
- **A spring can be interrupted.** If someone taps again mid-animation, SwiftUI heads to the new target and keeps the current speed, so nothing jumps.

## Guide

Good motion answers a question: where did that come from, did my tap work, what changed? iOS animates its own controls, so most of your work is choosing **when** to animate your own views, picking a short **spring**, and having a plan for people who turn on **Reduce Motion**.

### Tune a spring

Apple's advice is to set the **duration** first for the pace, then add **bounce** for character.

## Key APIs

`withAnimation(_:_:)`, `.animation(_:value:)`, `.spring(duration:bounce:)`, `.smooth` `.snappy` `.bouncy`, `.transition(_:)`, `\.accessibilityReduceMotion`, `.sensoryFeedback(_:trigger:)`

## Variants

### Animate a change people made

Wrap the state change in `withAnimation` so the new content slides in instead of popping.

```swift
@State private var showDetails = false

VStack(alignment: .leading) {
    Button(showDetails ? "Hide Details" : "Show Details") {
        withAnimation(.snappy) {
            showDetails.toggle()
        }
    }
    if showDetails {
        Text("Ships in 2–3 days")
            .transition(.move(edge: .top).combined(with: .opacity))
    }
}
```

## On macOS

Animate to explain a change, keep it brief, and tone it down for Reduce Motion.

### Rules

- **Keep feedback short and precise.** A quick animation tied exactly to what someone did reads instantly. A long or showy one gets in the way.
- **Match the motion to the action.** If a panel slides down to appear, it should slide back up to leave, not off to the side. Motion that contradicts the action disorients.
- **Don't rely on motion alone.** Some people turn motion down or miss it. Say what happened in another way too, like a label or a changed state.
- **Tone it down for Reduce Motion.** Cut automatic and repeating animations, zooming, and scaling. Swap slides for fades, tighten springs so they don't bounce, and don't animate blurs or depth.

### Pitfalls

- **Many system components already animate.** Use them as they are, and add your own motion only to custom views, following the same rules.
- **Test with Reduce Motion on.** Turn it on in the Mac's Accessibility settings and walk through your app: anything that still zooms, slides, or bounces on its own needs a quieter version.

### Key APIs

`.contentTransition(.numericText())`, `.symbolEffect(_:value:)`

### Variants

#### Animate a change people made

Wrap the state change in `withAnimation(.snappy)` so a new row eases in where it lands.

```swift
@State private var stops = ["Alfama", "Belém"]

VStack(alignment: .leading) {
    ForEach(stops, id: \.self) { stop in
        Label(stop, systemImage: "mappin")
    }
    Button("Add Stop") {
        withAnimation(.snappy) {
            stops.append("Stop \(stops.count + 1)")
        }
    }
}
```

#### Fade instead of slide for Reduce Motion

Read `accessibilityReduceMotion` and pick an `.opacity` transition when it's on.

```swift
@Environment(\.accessibilityReduceMotion) private var reduceMotion
@State private var showsBanner = false

VStack {
    Button(showsBanner ? "Hide Banner" : "Show Banner") {
        withAnimation { showsBanner.toggle() }
    }
    if showsBanner {
        Text("Your trip is saved.")
            .padding(10)
            .background(.fill.tertiary, in: .rect(cornerRadius: 8))
            .transition(reduceMotion ? .opacity : .move(edge: .top).combined(with: .opacity))
    }
}
```

More variants, left out to keep this file short: Offer a fade when Reduce Motion is on, Confirm with a symbol and a haptic, Let numbers roll (macOS). Apple's docs: https://developer.apple.com/documentation/swiftui/animation.md

## Related

[spring](spring.md), [animation-curves](animation-curves.md), [transitions](transitions.md), [reduce-motion](reduce-motion.md), [symbol-effects](symbol-effects.md), [haptics](haptics.md), [matched-geometry](matched-geometry.md), [phase-animator](phase-animator.md), [animation](animation.md), [sf-symbols](sf-symbols.md), [materials](materials.md)
