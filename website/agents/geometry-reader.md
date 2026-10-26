---
id: geometry-reader
title: GeometryReader
platforms: [iOS, iPadOS]
availability: iOS 13.0+, macOS 10.15+, visionOS 1.0+
docs: https://developer.apple.com/documentation/swiftui/geometryreader.md
---

# GeometryReader

Three ways to size a view relative to its container or read its size.

Also called: getBoundingClientRect, ResizeObserver, vw, percentage width, measure size, onLayout, container width, containerRelativeFrame, onGeometryChange.

## Contents

- Pitfalls
- Guide
- Key APIs
- Variants
- Related

## Pitfalls

- **Reach for `GeometryReader` last.** `containerRelativeFrame` and `onGeometryChange` cover most needs without changing the layout around them.
- **`onGeometryChange` is new but back-deployed.** It's available from iOS 16, so you can use it in most apps today.

## Guide

Where CSS uses `width: 50%` or a `ResizeObserver`, SwiftUI has three tools. Pick the first one that does the job:

```swift
ScrollView(.horizontal) {
    HStack(spacing: 10) {
        ForEach(0..<6, id: \.self) { i in
            RoundedRectangle(cornerRadius: 12)
                .fill(.blue.gradient)
                .frame(height: 80)
                .containerRelativeFrame(.horizontal, count: 3, span: 1, spacing: 10)
        }
    }
}
```

**Note:** The container is the nearest scroll view, list, or window, never the parent stack. Here it's the horizontal `ScrollView`.

## Key APIs

- `.containerRelativeFrame(_:)`: Sizes a view as a share of its container, with `count` and `span`.
- `.onGeometryChange(for:of:action:)`: Reads a size or position into state.
- `GeometryReader { proxy in }`: Fills the offered space and passes its size to the content.
- `proxy.size`: The size the reader was offered.
- `proxy.frame(in: .global)`: A view's position in another coordinate space.

## Variants

### onGeometryChange

`.onGeometryChange` reads the label's width into `@State` as you type, without changing its layout.

```swift
@State private var name = "Hello"
@State private var width: CGFloat = 0

VStack(spacing: 12) {
    Text(name)
        .font(.title.bold())
        .onGeometryChange(for: CGFloat.self) { proxy in
            proxy.size.width
        } action: { newWidth in
            width = newWidth
        }
    Capsule()
        .fill(.tint)
        .frame(width: width, height: 6)
    Text("\(Int(width)) pt wide")
        .font(.caption.monospacedDigit())
    TextField("Text", text: $name)
        .textFieldStyle(.roundedBorder)
}
```

**Important:** Don't feed a measured size back into the same view's size. That can loop forever. Use it to drive other views.

### GeometryReader

A `GeometryReader` fills the offered space and passes its size to the content as `proxy.size`.

```swift
GeometryReader { proxy in
    let size = proxy.size
    VStack(alignment: .leading) {
        Text("\(Int(size.width)) × \(Int(size.height))")
            .font(.headline.monospacedDigit())
        Capsule()
            .fill(.tint)
            .frame(width: size.width * 0.3, height: 8)
        Text("30% of the width")
            .font(.caption)
    }
}
.frame(height: 120)
.background(.tint.opacity(0.1))
```

**Important:** A `GeometryReader` takes all the space it's offered and puts its content at the top-leading corner. In a `VStack`, it pushes everything else away.

## Related

[view-that-fits](view-that-fits.md), [layout-basics](layout-basics.md), [frame](frame.md), [scroll-view](scroll-view.md)
