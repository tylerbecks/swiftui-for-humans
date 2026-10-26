---
id: symbol-effects
title: Symbol Effects
platforms: [iOS, iPadOS]
availability: iOS 17.0+, macOS 14.0+, visionOS 1.0+
docs: https://developer.apple.com/documentation/swiftui/view/symboleffect(_:options:value:).md
hig: https://developer.apple.com/design/human-interface-guidelines/sf-symbols.md
---

# Symbol Effects

Built-in SF Symbol animations, like bounce, pulse, and wiggle, with one modifier.

Also called: icon animation, animated icon, bounce, pulse, wiggle, spinner icon, lottie, font awesome animation, sfsymbols.

## Contents

- Default code
- Rules
- Pitfalls
- Key APIs
- Variants
- Related

## Default code

```swift
@State private var unread = 0

Button {
    unread += 1
} label: {
    Image(systemName: "bell.fill")
        .symbolEffect(.bounce, value: unread)
}
```

**Note:** Pass `value:` to play the effect once per change, or `isActive:` to keep it running while a flag is true.

## Rules

- **Animate one symbol at a time.** A single moving symbol draws the eye to what changed. When several animate together, they compete and the screen feels busy.
- **Pick the effect that matches the meaning.** People read `.bounce` as "something just happened" and `.pulse` or `.variableColor` as "still working." Using one for the other sends the wrong signal.
- **Fit the effect to your app's tone.** A playful wiggle suits a game or a social app. A finance or health app usually calls for quieter effects.

## Pitfalls

- **One modifier covers a whole group.** `.symbolEffect` animates every symbol inside the view, so you can put it on a `Label`, a button, or a stack.
- **Newer effects need newer iOS.** `.wiggle`, `.breathe`, and `.rotate` need iOS 18, and `.drawOn` and `.drawOff` need iOS 26.

## Key APIs

- `.symbolEffect(_:value:)`: Plays the effect once each time `value` changes.
- `.symbolEffect(_:isActive:)`: Runs the effect continuously while `isActive` is true.
- `.bounce`, `.wiggle`: A quick nudge: something happened, or look here.
- `.pulse`, `.breathe`: A steady throb for ongoing activity.
- `.variableColor.iterative`: Lights the symbol's layers one by one.
- `.contentTransition(.symbolEffect(.replace))`: Animates a change of symbol name.
- `.transition(.symbolEffect(.drawOn))`: Draws a symbol in along its strokes (iOS 26).

## Variants

### Notification badge

Pass the unread count to `.symbolEffect(.bounce, value:)` so the bell bounces on each new notification.

```swift
@State private var unread = 0

Button {
    unread += 1
} label: {
    Image(systemName: "bell.badge.fill")
        .symbolRenderingMode(.palette)
        .foregroundStyle(.red, .primary)
        .font(.largeTitle)
        .symbolEffect(.bounce, value: unread)
}
.buttonStyle(.plain)
```

### Play / pause button

Change the symbol name and add `.contentTransition(.symbolEffect(.replace))` to animate the swap.

```swift
@State private var isPlaying = false

Button {
    isPlaying.toggle()
} label: {
    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
        .font(.largeTitle)
        .contentTransition(.symbolEffect(.replace))
        .frame(width: 72, height: 72)
}
.buttonStyle(.bordered)
.buttonBorderShape(.circle)
```

**Note:** Related symbols, like `bell` and `bell.slash`, morph with Magic Replace. Unrelated ones, like play and pause, scale down and up instead.

### Loading indicator

Use `.symbolEffect(_:isActive:)` to animate a symbol while work runs, and stop when it's done.

```swift
@State private var isSyncing = true

VStack(alignment: .leading, spacing: 16) {
    Label("Syncing…", systemImage: "arrow.triangle.2.circlepath.icloud")
        .symbolEffect(.pulse, isActive: isSyncing)
    Label("Searching", systemImage: "wifi")
        .symbolEffect(.variableColor.iterative, isActive: isSyncing)
}
.font(.title3)
```

**Note:** Set `isActive` back to `false` when the work finishes. The symbol finishes its current cycle and settles.

### Draw on and off

Use `.transition(.symbolEffect(.drawOn))` to trace a symbol along its strokes as it appears.

```swift
@State private var isShown = true

VStack(spacing: 20) {
    ZStack {
        if isShown {
            Image(systemName: "signature")
                .font(.system(size: 64))
                .transition(.symbolEffect(.drawOn))
        }
    }
    .frame(height: 80)

    Button(isShown ? "Erase" : "Sign") {
        withAnimation { isShown.toggle() }
    }
    .buttonStyle(.bordered)
}
```

**Note:** Drawing needs iOS 26 and a symbol that supports it. Check in the SF Symbols app; other symbols fall back to a fade.

## Related

[sf-symbols](sf-symbols.md), [content-transition](content-transition.md), [phase-animator](phase-animator.md), [image](image.md)
