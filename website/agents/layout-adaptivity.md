---
id: layout-adaptivity
title: Layout & Adaptivity
platforms: [iOS, iPadOS]
availability: iOS 16.0+
docs: https://developer.apple.com/documentation/swiftui/environmentvalues/horizontalsizeclass.md
hig: https://developer.apple.com/design/human-interface-guidelines/layout.md
reviewed: October 2026
---

# Layout & Adaptivity

Build layouts that fit any screen, window size, orientation, and text size.

## Contents

- Rules
- Pitfalls
- Guide
- Key APIs
- Variants
- Related

## Rules

- **Decide by available space, not by device.** Size classes and `ViewThatFits` describe the room you really have. Checking for iPad or landscape breaks as soon as a window gets resized.
- **Keep every feature at every size.** A narrow window can show fewer buttons, but the actions should move into a menu, not disappear.
- **Keep content inside the safe area.** The Dynamic Island, the Home indicator, and bars cover the screen's edges. Let backgrounds run edge to edge, but keep text and controls inside.
- **Make room for larger text.** With big Dynamic Type sizes, side-by-side text runs out of room. Stack it vertically instead of cutting it off.
- **Test the extremes first.** Check the smallest and largest layouts, then other languages and text sizes. Problems show up at the edges.

## Pitfalls

- **Full-screen-only iPad apps are going away.** As of iPadOS 26, the `UIRequiresFullScreen` key is deprecated. Starting in iOS 27 and iPadOS 27, apps built with the iOS 27 SDK generally can't use it to opt out of resizing.
- **Size classes can change while your app runs.** Rotating, resizing a window, or opening another app beside yours can flip them, so never read them once and cache the result.

## Guide

Your app never gets one fixed screen. It runs on phones of different sizes, in portrait and landscape, and in iPad windows that people resize at will. Like responsive design on the web, you describe how the layout **adapts**, and SwiftUI does the measuring. The difference: you react to the space you're given, not to the device.

### Size classes

iOS sums up the space in each direction as one of two **size classes**: `compact` (narrow or short) or `regular` (wide or tall). They're the closest thing to a media query breakpoint, and built-in views like `NavigationSplitView` already use them.

**Note:** The device, its orientation, and iPad multitasking all set the size class. Read it, but don't try to guess it from the device.

## Key APIs

`\.horizontalSizeClass`, `ViewThatFits`, `AnyLayout`, `GridItem(.adaptive)`, `.containerRelativeFrame(_:)`, `.onGeometryChange(for:)`

## Variants

### Switch layouts with the size class

Read `horizontalSizeClass` and use `AnyLayout` to stack vertically when compact and side by side when regular.

```swift
@Environment(\.horizontalSizeClass) private var sizeClass

let layout = sizeClass == .regular
    ? AnyLayout(HStackLayout(spacing: 12))
    : AnyLayout(VStackLayout(alignment: .leading, spacing: 8))
layout {
    Image(systemName: "photo")
        .font(.title)
        .frame(width: 80, height: 56)
        .background(.fill.tertiary, in: .rect(cornerRadius: 8))
    Text("Trip to Lisbon")
        .font(.headline)
}
```

**Note:** `AnyLayout` keeps the children's state when it switches, unlike an `if` that swaps an `HStack` for a `VStack`.

### Show the version that fits

List options from largest to smallest in `ViewThatFits`, and SwiftUI shows the first one with room.

```swift
ViewThatFits(in: .horizontal) {
    HStack {
        Button("Reply", systemImage: "arrowshape.turn.up.left") {}
        Button("Forward", systemImage: "arrowshape.turn.up.right") {}
    }
    HStack {
        Button("Reply", systemImage: "arrowshape.turn.up.left") {}
        Button("Forward", systemImage: "arrowshape.turn.up.right") {}
    }
    .labelStyle(.iconOnly)
}
.buttonStyle(.bordered)
```

**Note:** Both versions keep the same actions. The narrow one just drops the words.

### Let a grid pick its columns

Use an adaptive `GridItem` to fit as many columns as the width allows, with no size checks.

```swift
LazyVGrid(columns: [GridItem(.adaptive(minimum: 70))]) {
    ForEach(0..<6) { index in
        RoundedRectangle(cornerRadius: 10)
            .fill(.blue.gradient)
            .frame(height: 50)
            .overlay { Text("\(index + 1)").foregroundStyle(.white) }
    }
}
```

### Size cards to the screen

Use `.containerRelativeFrame` to make each card a share of the scroll view's width, on any screen.

```swift
ScrollView(.horizontal) {
    HStack(spacing: 12) {
        ForEach(0..<5) { index in
            RoundedRectangle(cornerRadius: 12)
                .fill(.orange.gradient)
                .frame(height: 90)
                .containerRelativeFrame(.horizontal, count: 2, spacing: 12)
        }
    }
}
.contentMargins(.horizontal, 16)
```

**Note:** With `count: 2`, two cards fill the width on iPhone and on a wide iPad window alike. Raise the count for regular widths if you want more.

## Related

[safe-area](safe-area.md), [view-that-fits](view-that-fits.md), [stacks](stacks.md), [grid](grid.md), [lazy-grids](lazy-grids.md), [navigation-split-view](navigation-split-view.md), [dynamic-type](dynamic-type.md), [geometry-reader](geometry-reader.md)
