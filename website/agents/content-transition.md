---
id: content-transition
title: Content Transitions
platforms: [iOS, iPadOS]
availability: iOS 16.0+, macOS 13.0+, visionOS 1.0+
docs: https://developer.apple.com/documentation/swiftui/contenttransition.md
hig: https://developer.apple.com/design/human-interface-guidelines/motion.md
---

# Content Transitions

Animate content changing in place, like digits rolling on a counter or one icon becoming another.

Also called: counter animation, number ticker, rolling digits, odometer, animate text change, count up, icon swap, crossfade.

## Contents

- Default code
- Rules
- Pitfalls
- Key APIs
- Variants
- Related

## Default code

```swift
@State private var count = 0

VStack {
    Text("\(count)")
        .font(.largeTitle.bold())
        .contentTransition(.numericText(value: Double(count)))
        .animation(.snappy, value: count)
    Button("Add") { count += 1 }
}
```

**Important:** A content transition plays only when the change is animated. Wrap it in `withAnimation`, or add `.animation(_:value:)` as above.

## Rules

- **Keep changing numbers from shifting.** Proportional digits change width as the value changes, so nearby text jumps around. Monospaced digits keep everything still.
- **Animate values people are watching.** A rolling price or score confirms a change they made. For text they're reading, a quiet crossfade or no animation is easier on the eyes.
- **Keep it quick.** A number should settle in a fraction of a second, so people can read the new value right away.

## Pitfalls

- **Same view, new content.** A content transition animates what's drawn inside one view. To animate a view being added or removed, use [Transitions](transitions.md).
- **Like a CSS number ticker, without the library.** On the web you'd reach for a counter package; here one modifier on `Text` does it.

## Key APIs

- `.contentTransition(_:)`: How this view's content animates when it changes.
- `.numericText(value:)`: Rolls digits, up or down depending on `value`.
- `.numericText(countsDown:)`: Rolls digits down when there's no value to compare.
- `.interpolate`: Blends weight, size, and color between the two states.
- `.opacity`: A plain crossfade between old and new content.
- `.identity`: No animation; the content just changes.
- `.symbolEffect(.replace)`: Swaps one SF Symbol for another.

## Variants

### Price that rolls

Use `.numericText(value:)` on formatted currency too; each digit rolls on its own.

```swift
@State private var quantity = 1
let price = 4.99

VStack(spacing: 16) {
    Text(Double(quantity) * price, format: .currency(code: "USD"))
        .font(.largeTitle.bold())
        .contentTransition(.numericText(value: Double(quantity)))
        .animation(.snappy, value: quantity)
    Stepper("Quantity: \(quantity)", value: $quantity, in: 1...20)
        .frame(width: 220)
}
```

**Note:** `value:` tells SwiftUI whether the number went up or down, so the digits roll in the right direction.

### Countdown timer

Redraw with a `TimelineView` each second, and use `.numericText(countsDown: true)` to roll digits down.

```swift
@State private var end = Date.now.addingTimeInterval(90)

TimelineView(.periodic(from: .now, by: 1)) { context in
    let seconds = max(0, Int(end.timeIntervalSince(context.date)))
    Text(String(format: "%d:%02d", seconds / 60, seconds % 60))
        .font(.system(size: 56, weight: .semibold, design: .monospaced))
        .contentTransition(.numericText(countsDown: true))
        .animation(.default, value: seconds)
}
```

### Follow button

Use `.interpolate` to morph a button's label and style in one animated update.

```swift
@State private var isFollowing = false

Button {
    withAnimation(.snappy) { isFollowing.toggle() }
} label: {
    Label(isFollowing ? "Following" : "Follow",
          systemImage: isFollowing ? "checkmark" : "plus")
        .contentTransition(.interpolate)
}
.buttonStyle(.borderedProminent)
.tint(isFollowing ? .gray : .blue)
```

## Related

[symbol-effects](symbol-effects.md), [transitions](transitions.md), [text](text.md), [animation-curves](animation-curves.md)
