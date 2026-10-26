---
id: scroll-view
title: ScrollView
platforms: [iOS, iPadOS, macOS]
availability: iOS 13.0+, macOS 10.15+, visionOS 1.0+, ScrollPosition macOS 15.0+
docs: https://developer.apple.com/documentation/swiftui/scrollview.md
hig: https://developer.apple.com/design/human-interface-guidelines/scroll-views.md
---

# ScrollView

Lets content that's bigger than the screen scroll, vertically or sideways.

## Contents

- Use when
- Don't use when
- Default code
- Built from
- Rules
- Pitfalls
- Key APIs
- On macOS
- Related

## Use when

- `ScrollView` shows content that's bigger than the space it has and lets people drag through it.
- It's as big as its parent offers, and its content is as long as it needs to be.
- Use it for custom layouts like cards, carousels, and feeds.

## Don't use when

- For rows of data with swipe actions, selection, and separators, use a [List](list.md), which scrolls on its own.

## Default code

```swift
ScrollView {
    LazyVStack(spacing: 12) {
        ForEach(1...100, id: \.self) { i in
            Text("Row \(i)")
        }
    }
    .padding()
}
```

**Note:** A plain `VStack` inside builds every row up front. Use `LazyVStack` or `LazyHStack` for long content so rows are created as they scroll in.

## Built from

ScrollView(.horizontal)
├── LazyHStack
│   ├── ForEach → cards
│   └── .scrollTargetLayout()
├── .scrollTargetBehavior
├── .scrollPosition(id:)
└── .contentMargins

## Rules

- **Show that there's more to scroll.** Scroll bars aren't always visible. Let the next card peek in from the edge so people know they can swipe.
- **Don't nest scroll views on the same axis.** A vertical scroll view inside another vertical one is hard to control. A horizontal row inside a vertical feed is fine.
- **Pair paging with a page indicator.** When content scrolls a page at a time, show which page people are on, and hide the scroll bar on that axis so there aren't two indicators.

## Pitfalls

- **Snapping is CSS `scroll-snap`.** `.viewAligned` snaps to each view in a `.scrollTargetLayout()`; `.paging` snaps a whole screen at a time.
- **Pad the content, not the scroll view.** `.contentMargins` adds space that scrolls with the content, so cards can peek in from the edges. Plain `.padding` clips them.

## Key APIs

`ScrollView(_:)`, `.scrollTargetBehavior(_:)`, `.scrollTargetLayout()`, `.scrollPosition(id:)`, `.contentMargins(_:_:for:)`, `.scrollIndicators(_:)`, `.refreshable { }`, `.scrollTransition { }`

## On macOS

Scrolls content that's bigger than its frame, in one direction or both.

### Default code

```swift
ScrollView {
    VStack(alignment: .leading) {
        ForEach(1...50, id: \.self) { number in
            Text("Row \(number)")
        }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding()
}
```

**Note:** A `ScrollView` takes all the space it's offered, like a `<div>` with `overflow: auto`. Give it a frame, or put it where its parent sets the size.

### Rules

- **Don't put a scroll view inside one that scrolls the same way.** Two vertical scroll views fight over every swipe. A horizontal row inside a vertical page is fine.
- **Scroll for people only when it helps them find their place.** Bring a search result or a new selection into view, and scroll only as far as it takes to show it.
- **Keep the standard scrolling gestures and keys.** People expect the gestures and keyboard shortcuts they scroll with everywhere else to work in your app too. If you build custom scrolling, keep the elastic bounce at the edges.

### Pitfalls

- **On the Mac, scroll bars follow the person's settings.** Whether they always show or appear only while scrolling depends on the Show scroll bars setting and on whether a mouse is connected, not just on your code.
- **Lists, tables, forms, and text editors already scroll.** Don't wrap them in a `ScrollView`; give them a frame instead.

### Key APIs

`.scrollIndicators(_:axes:)`, `.scrollPosition(_:anchor:)`, `.defaultScrollAnchor(_:)`

### Variants

#### Jump to a row with scrollPosition

Bind `.scrollPosition` to a `ScrollPosition` to scroll from code and to read which row is at the top.

```swift
struct Message: Identifiable {
    let id: Int
    var text: String { "Message \(id)" }
}

@State private var position = ScrollPosition(idType: Int.self)
private let messages = (1...100).map(Message.init)

VStack {
    ScrollView {
        LazyVStack(alignment: .leading) {
            ForEach(messages) { Text($0.text) }
        }
        .scrollTargetLayout()
    }
    .scrollPosition($position)
    .frame(height: 140)

    HStack {
        Button("Top") { position.scrollTo(edge: .top) }
        Button("Message 50") { position.scrollTo(id: 50) }
        Button("Bottom") { position.scrollTo(edge: .bottom) }
    }
}
```

More variants, left out to keep this file short: Carousel with peeking cards, Scroll to top, Pull to refresh, Start in the middle of a canvas (macOS), A horizontal row with room at the edges (macOS), Keep scroll bars inside rounded corners (macOS). Apple's docs: https://developer.apple.com/documentation/swiftui/scrollview.md

## Related

[lazy-grids](lazy-grids.md), [stacks](stacks.md), [geometry-reader](geometry-reader.md), [list](list.md), [list-styles](list-styles.md), [table](table.md), [stacks-grid](stacks-grid.md)
