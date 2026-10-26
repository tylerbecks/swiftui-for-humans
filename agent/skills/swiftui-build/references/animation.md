---
id: animation
title: Animation
platforms: [macOS]
availability: macOS 14.0+
docs: https://developer.apple.com/documentation/swiftui/animations.md
hig: https://developer.apple.com/design/human-interface-guidelines/motion.md
---

# Animation

Springs and transitions that stay quick and quiet under a pointer and in big windows.

Also called: withAnimation, spring, transition, animate, ease in out, CSS transition, keyframes, hover, onHover, Reduce Motion.

## Contents

- Default code
- Rules
- Pitfalls
- Key APIs
- Variants
- Related

## Default code

```swift
@State private var showsDetails = false

VStack {
    Button(showsDetails ? "Hide Details" : "Show Details") {
        withAnimation(.snappy) {
            showsDetails.toggle()
        }
    }
    if showsDetails {
        Text("Recorded on October 12")
            .transition(.opacity)
    }
}
```

**Note:** Change state inside `withAnimation`, not the view. SwiftUI works out what moved and animates it, like a CSS transition on whatever the change affects.

## Rules

- **Add motion for a reason.** Use it to show where something came from or that something changed. Motion just for show distracts people and can make some of them feel unwell.
- **Skip motion on things people do all the time.** Standard controls already animate on their own. A pointer passes over custom rows constantly, so keep their hover feedback brief or leave the motion out.
- **Never make people wait for an animation.** Let them click again, or move on, while it plays. Springs handle an interruption smoothly, so don't block input until one finishes.
- **Make motion optional.** With Reduce Motion on, swap slides and zooms for fades and calm the bounce. Don't let motion be the only way people learn something happened.

## Pitfalls

- **Springs keep their speed when interrupted.** Click again mid-move and the next spring starts from where the view is, moving as fast as it was.
- **`withAnimation` animates what the change touches.** Every view that redraws because of the state you change inside it animates, wherever it is in the window.

## Key APIs

`withAnimation(.snappy) { }`, `.animation(_:value:)`, `.spring(duration:bounce:)`, `.smooth`, `.snappy`, `.bouncy`, `.transition(_:)`, `.onHover { }`, `.contentTransition(_:)`, `\.accessibilityReduceMotion`

## Variants

### Quiet hover feedback

Use `.onHover` with a short `.animation(_:value:)` to highlight what's under the pointer. Keep it subtle: people pass over it all the time.

```swift
struct ProjectCard: View {
    let name: String
    @State private var isHovering = false

    var body: some View {
        Label(name, systemImage: "folder")
            .frame(width: 140, height: 60)
            .background(isHovering ? AnyShapeStyle(.fill.secondary) : AnyShapeStyle(.fill.quaternary),
                        in: .rect(cornerRadius: 10))
            .animation(.easeOut(duration: 0.12), value: isHovering)
            .onHover { isHovering = $0 }
    }
}

HStack {
    ProjectCard(name: "Website")
    ProjectCard(name: "App")
    ProjectCard(name: "Docs")
}
```

### Slide a panel in and out

Give the panel a `.transition`, then toggle it inside `withAnimation`. A move from the trailing edge matches where inspectors live.

```swift
@State private var showsInspector = true

HStack(spacing: 0) {
    Text("Canvas")
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    if showsInspector {
        Text("Inspector")
            .frame(width: 140)
            .frame(maxHeight: .infinity)
            .background(.background.secondary)
            .transition(.move(edge: .trailing))
    }
}
.clipped()

Button("Toggle Inspector", systemImage: "sidebar.right") {
    withAnimation(.snappy) {
        showsInspector.toggle()
    }
}
```

### Numbers that roll

`.contentTransition(.numericText(value:))` animates digits as a count changes, like a downloads badge or a timer.

```swift
@State private var downloads = 3

HStack {
    Text("\(downloads) downloads")
        .contentTransition(.numericText(value: Double(downloads)))
        .monospacedDigit()
    Stepper("Downloads", value: $downloads.animation(.snappy), in: 0...99)
        .labelsHidden()
}
```

### Fade instead of slide with Reduce Motion

Read `accessibilityReduceMotion` and pick a calmer transition when it's on. The checkbox here stands in for the system setting.

```swift
@Environment(\.accessibilityReduceMotion) private var reduceMotion
@State private var showsBanner = false

VStack {
    Button("Show Banner") {
        withAnimation(.snappy) { showsBanner.toggle() }
    }
    if showsBanner {
        Label("Export finished", systemImage: "checkmark.circle.fill")
            .padding(10)
            .background(.fill.secondary, in: .capsule)
            .transition(reduceMotion ? .opacity : .move(edge: .bottom).combined(with: .opacity))
    }
}
```

**Note:** To test the real setting, turn on Reduce motion in the Accessibility section of System Settings.

## Related

[hover](hover.md), `reduce-motion` (apple-design skill), `motion` (apple-design skill), [state-binding](state-binding.md)
