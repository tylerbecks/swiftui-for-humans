---
id: transitions
title: Transitions
platforms: [iOS, iPadOS]
availability: iOS 13.0+, macOS 10.15+, visionOS 1.0+
docs: https://developer.apple.com/documentation/swiftui/anytransition.md
hig: https://developer.apple.com/design/human-interface-guidelines/motion.md
---

# Transitions

Control how a view animates in when it's added and out when it's removed.

Also called: enter animation, exit animation, fade in, slide in, AnimatePresence, v-if transition, show hide, appear, insertion, removal.

## Contents

- Default code
- Rules
- Pitfalls
- Key APIs
- Variants
- Related

## Default code

```swift
@State private var isShown = false

VStack {
    Button("Show Details") {
        withAnimation { isShown.toggle() }
    }
    if isShown {
        Text("Arrives Thursday")
            .transition(.scale.combined(with: .opacity))
    }
}
```

**Important:** A transition runs only when a view is added or removed, as in `if isShown { }`, and only when that change is animated. Changing a view's properties is a normal animation.

## Rules

- **Leave the way you came in.** A banner that drops from the top should go back up. Leaving in a new direction breaks the sense of where it lives.
- **Keep transitions quick and subtle.** A short fade or slide shows what changed without making people watch it. Save big entrances for rare moments.
- **Fall back to a fade with Reduce Motion.** Sliding and scaling can be uncomfortable for some people. When `accessibilityReduceMotion` is on, use `.opacity` instead.

## Pitfalls

- **Like `AnimatePresence`, built in.** On the web you keep an element mounted until its exit animation ends. In SwiftUI, removing it inside an animated change is enough.
- **The default is `.opacity`.** A view inside an animated `if` fades in and out even without a `.transition` modifier.

## Key APIs

- `.transition(_:)`: How this view enters and leaves.
- `.opacity`, `.scale`, `.slide`: Fade, grow from the center, or slide across.
- `.move(edge:)`: Slides in from an edge and out the same way.
- `.push(from:)`: Pushes in from one edge while the old view leaves the other.
- `.combined(with:)`: Runs two transitions at once, like move and fade.
- `.asymmetric(insertion:removal:)`: Different transitions for entering and leaving.
- `.blurReplace`: Blurs and fades, good for swapping content (iOS 17+).

## Variants

### Expandable details

Combine `.move(edge: .top)` with `.opacity` so extra details unfold beneath a row.

```swift
@State private var isExpanded = false

VStack(alignment: .leading, spacing: 12) {
    Button {
        withAnimation(.snappy) { isExpanded.toggle() }
    } label: {
        HStack {
            Text("Shipping details").font(.headline)
            Spacer()
            Image(systemName: "chevron.down")
                .rotationEffect(.degrees(isExpanded ? 180 : 0))
        }
    }
    .buttonStyle(.plain)

    if isExpanded {
        Text("Arrives Thursday. Free returns within 30 days.")
            .foregroundStyle(.secondary)
            .transition(.move(edge: .top).combined(with: .opacity))
    }
}
.padding()
.background(.fill.tertiary, in: .rect(cornerRadius: 16))
.clipped()
```

**Note:** Moving views can draw outside their container. `.clipped()` on the container hides them until they're inside it.

### Toast from the top

Use `.asymmetric(insertion:removal:)` so the toast drops in from the top and shrinks away when it leaves.

```swift
@State private var showsToast = false

VStack {
    if showsToast {
        Label("Saved to Photos", systemImage: "checkmark.circle.fill")
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(.regularMaterial, in: .capsule)
            .transition(.asymmetric(
                insertion: .move(edge: .top).combined(with: .opacity),
                removal: .scale(scale: 0.8).combined(with: .opacity)
            ))
    }
    Spacer()
    Button("Save") {
        withAnimation(.bouncy) { showsToast = true }
        Task {
            try? await Task.sleep(for: .seconds(1.5))
            withAnimation(.smooth) { showsToast = false }
        }
    }
}
.frame(height: 150)
```

### Swap content with .push

Use `.push(from:)` with a new `.id` per step, so the old step leaves as the next pushes in.

```swift
@State private var step = 1

VStack(spacing: 16) {
    Text("Step \(step)")
        .font(.largeTitle.bold())
        .id(step)
        .transition(.push(from: .trailing))
    Button("Next") {
        withAnimation(.smooth) { step = step % 3 + 1 }
    }
}
.clipped()
```

**Important:** Without `.id(step)`, SwiftUI keeps the same `Text` and only changes its string, so no transition runs.

## Related

[animation-curves](animation-curves.md), [matched-geometry](matched-geometry.md), [content-transition](content-transition.md), [spring](spring.md)
