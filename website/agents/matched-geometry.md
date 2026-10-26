---
id: matched-geometry
title: Matched Geometry
platforms: [iOS, iPadOS]
availability: iOS 14.0+, macOS 11.0+, visionOS 1.0+
docs: https://developer.apple.com/documentation/swiftui/view/matchedgeometryeffect(id:in:properties:anchor:issource:).md
hig: https://developer.apple.com/design/human-interface-guidelines/motion.md
---

# Matched Geometry

Morph one view into another, like a sliding tab highlight or a card growing full screen.

## Contents

- Rules
- Pitfalls
- Key APIs
- Variants
- Related

## Rules

- **Morph only things people see as the same object.** A thumbnail growing into its detail explains where the detail came from. Morphing unrelated views into each other just confuses.
- **Let people go back the way they came.** A screen that zoomed out of a tile should shrink back into it. The zoom transition does this, including swipe to dismiss.
- **Keep it quick.** A hero animation people see every time they open an item should feel instant. Use a short spring like `.snappy`.

## Pitfalls

- **Both views need the same `id` and the same `@Namespace`.** Declare the namespace once in the parent, and pass it to child views as a `Namespace.ID`.
- **It only links frames.** Each view still fades in or out with its own transition while its frame moves, so add `.transition(.identity)` if you see a cross-fade you don't want.

## Key APIs

`@Namespace`, `.matchedGeometryEffect(id:in:)`, `isSource:`, `.matchedTransitionSource(id:in:)`, `.navigationTransition(.zoom(sourceID:in:))`

## Variants

### Sliding tab indicator

Draw one `.matchedGeometryEffect(id:in:)` highlight behind the selected tab, and it slides between tabs.

```swift
@State private var selected = "Music"
@Namespace private var tabs

HStack(spacing: 4) {
    ForEach(["Music", "Podcasts", "Books"], id: \.self) { tab in
        Text(tab)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(selected == tab ? .white : .primary)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background {
                if selected == tab {
                    Capsule()
                        .fill(.indigo)
                        .matchedGeometryEffect(id: "highlight", in: tabs)
                }
            }
            .onTapGesture {
                withAnimation(.snappy) { selected = tab }
            }
    }
}
.padding(4)
.background(.fill.tertiary, in: .capsule)
```

**Important:** The change must happen inside `withAnimation`. Without it, the highlight jumps to the new tab.

### Card that expands

Give each shared piece its own `matchedGeometryEffect` id, so the art and title travel between layouts.

```swift
@State private var isExpanded = false
@Namespace private var card

VStack {
    if isExpanded {
        VStack(alignment: .leading, spacing: 12) {
            RoundedRectangle(cornerRadius: 20)
                .fill(.orange.gradient)
                .matchedGeometryEffect(id: "art", in: card)
                .frame(height: 160)
            Text("Sunset Drive")
                .font(.title2.bold())
                .matchedGeometryEffect(id: "title", in: card)
            Text("A playlist for golden hour.")
                .foregroundStyle(.secondary)
        }
    } else {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 10)
                .fill(.orange.gradient)
                .matchedGeometryEffect(id: "art", in: card)
                .frame(width: 56, height: 56)
            Text("Sunset Drive")
                .font(.headline)
                .matchedGeometryEffect(id: "title", in: card)
            Spacer()
        }
    }
}
.onTapGesture {
    withAnimation(.spring(duration: 0.5, bounce: 0.2)) {
        isExpanded.toggle()
    }
}
```

**Important:** Each id can be on screen only once. If both versions show at the same time, give one `isSource: false`, or SwiftUI warns and the result is unpredictable.

More variants, left out to keep this file short: Zoom transition. Apple's docs: https://developer.apple.com/documentation/swiftui/view/matchedgeometryeffect(id:in:properties:anchor:issource:).md

## Related

[transitions](transitions.md), [navigation-stack](navigation-stack.md), [spring](spring.md), [sheet](sheet.md)
