---
id: safe-area
title: Safe Area
platforms: [iOS, iPadOS]
availability: iOS 14.0+, macOS 11.0+, visionOS 1.0+
docs: https://developer.apple.com/documentation/swiftui/view/ignoressafearea(_:edges:).md
hig: https://developer.apple.com/design/human-interface-guidelines/layout.md
---

# Safe Area

The part of the screen clear of the Dynamic Island, home indicator, bars, and keyboard.

Also called: notch, dynamic island, env(safe-area-inset-top), viewport-fit cover, full screen, edge to edge, home indicator, keyboard avoidance, insets.

## Contents

- Default code
- Rules
- Pitfalls
- Key APIs
- Variants
- Related

## Default code

```swift
ZStack {
    LinearGradient(colors: [.blue, .purple], startPoint: .top, endPoint: .bottom)
        .ignoresSafeArea()
    Text("Welcome")
        .font(.largeTitle.bold())
        .foregroundStyle(.white)
}
```

**Note:** Put `.ignoresSafeArea()` on the background view only, so text stays clear of the edges. A `.background(_:)` modifier already reaches the edges without it.

## Rules

- **Keep text and controls inside the safe area.** The Dynamic Island and home indicator cover the screen's edges. Anything people need to read or tap belongs inside.
- **Run backgrounds all the way to the edges.** Colors and images that stop at the safe area leave bands at the top and bottom, so the screen looks unfinished.

## Pitfalls

- **It's like CSS `env(safe-area-inset-*)`, applied for you.** SwiftUI keeps views inside the safe area by default; you opt out instead of opting in.
- **The keyboard is part of the safe area.** SwiftUI moves content up when it appears. Opt out with `.ignoresSafeArea(.keyboard)`.

## Key APIs

- `.ignoresSafeArea()`: Lets a view extend under the bars, island, and home indicator.
- `.ignoresSafeArea(edges: .top)`: Extends past only some edges.
- `.background(_:)`: Fills behind a view and extends to the edges on its own.
- `.safeAreaInset(edge:)`: Pins a bar to an edge and moves content clear of it.
- `.safeAreaPadding(_:_:)`: Grows the safe area, so scroll content still reaches the edge.
- `.ignoresSafeArea(.keyboard)`: Stops the keyboard from pushing content up.

## Variants

### Full-bleed header

Use `.ignoresSafeArea(edges: .top)` on the header art only, so the title stays inside.

```swift
VStack(alignment: .leading, spacing: 16) {
    ZStack(alignment: .bottomLeading) {
        LinearGradient(colors: [.orange, .pink], startPoint: .topLeading, endPoint: .bottomTrailing)
            .ignoresSafeArea(edges: .top)
        Text("Weekend Trip")
            .font(.title.bold())
            .foregroundStyle(.white)
            .padding()
    }
    .frame(height: 160)
    Text("Saturday, 9:00 AM")
        .foregroundStyle(.secondary)
        .padding(.horizontal)
    Spacer()
}
```

### Floating bottom bar

Use `.safeAreaInset(edge: .bottom)` to pin a button, so the last row can scroll above it.

```swift
ScrollView {
    VStack(spacing: 10) {
        ForEach(1...20, id: \.self) { i in
            Text("Message \(i)")
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(.fill.tertiary, in: .rect(cornerRadius: 12))
        }
    }
    .padding(.horizontal)
}
.safeAreaInset(edge: .bottom) {
    Button("New Message", systemImage: "square.and.pencil") {}
        .buttonStyle(.glassProminent)
        .controlSize(.large)
}
```

**Important:** A plain `.overlay(alignment: .bottom)` would cover the last rows. `safeAreaInset` shrinks the safe area by the bar's height, so nothing is hidden.

### padding vs. safeAreaPadding

Scroll both rows: `.safeAreaPadding` insets the cards but lets them scroll to the edge.

```swift
// Cards get clipped 24pt from the edges
ScrollView(.horizontal) { cards }
    .padding(.horizontal, 24)

// Cards start 24pt in, but scroll to the edges
ScrollView(.horizontal) { cards }
    .safeAreaPadding(.horizontal, 24)
```

**Note:** Plain `.padding` shrinks the scroll view itself, so the top row's cards are cut off at the inset.

## Related

[layout-basics](layout-basics.md), [scroll-view](scroll-view.md), [padding](padding.md), [toolbar](toolbar.md)
