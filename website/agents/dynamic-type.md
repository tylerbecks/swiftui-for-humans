---
id: dynamic-type
title: Dynamic Type
platforms: [iOS, iPadOS]
availability: iOS 15.0+
docs: https://developer.apple.com/documentation/swiftui/dynamictypesize.md
hig: https://developer.apple.com/design/human-interface-guidelines/typography.md
reviewed: October 2026
---

# Dynamic Type

Let text grow to the size people choose, and keep layouts readable when it does.

Also called: larger text, text size, font scaling, rem, zoom, responsive text, accessibility sizes, ScaledMetric, UIContentSizeCategory, preferredFont.

## Contents

- Rules
- Pitfalls
- Guide
- Key APIs
- Variants
- Related

## Rules

- **Let text wrap instead of cutting it off.** At large sizes, a one-line limit hides most of the text. Let it take as many lines as it needs, especially in scrolling content.
- **Stack side-by-side items at large sizes.** A label and a value on one line crowd each other when text is huge. Put the value under the label instead.
- **Grow meaningful icons with the text.** An icon that carries meaning should stay as easy to see as the words next to it. SF Symbols scale with the font automatically.
- **Keep the most important things at the top.** When text grows, the layout gets longer. Keep the order the same so people don't lose track of the main content.
- **Support at least 200 percent.** Apple asks for text that can reach about twice its default size. On iPhone, the accessibility sizes go past 200 percent at `accessibility3` and past 300 percent at `accessibility5`.

## Pitfalls

- **There are 12 sizes.** Seven standard ones, from `xSmall` to `xxxLarge`, plus five accessibility sizes, `accessibility1` to `accessibility5`. The default is `large`, where `.body` is 17 points.
- **Try it in Settings.** Accessibility > Display & Text Size > Larger Text, with Larger Accessibility Sizes turned on, unlocks the five biggest sizes.

## Guide

**Dynamic Type** is the text size people pick in Settings. It works like `rem` on the web: text set with a text style, such as `.font(.body)`, scales with it. There are 12 sizes, and the largest makes text more than three times its default size, so your layouts need room to grow.

```swift
@Environment(\.dynamicTypeSize) private var typeSize

let layout = typeSize.isAccessibilitySize
    ? AnyLayout(VStackLayout(alignment: .leading))
    : AnyLayout(HStackLayout(alignment: .firstTextBaseline))

layout {
    Text("Maya Chen")
        .font(.headline)
    Spacer(minLength: 0)
    Text("9:41 AM")
        .font(.subheadline)
        .foregroundStyle(.secondary)
}
Text("Are we still on for lunch tomorrow?")
    .font(.subheadline)
```

**Important:** `.font(.system(size: 17))` is a fixed size, like `px`, and never grows. Use a text style, or `@ScaledMetric` for your own numbers.

## Key APIs

- `.font(.body)`: A text style. All of them scale.
- `@ScaledMetric`: Scales your own numbers, like an icon size.
- `\.dynamicTypeSize`: The current size, to adapt a layout.
- `.isAccessibilitySize`: True for the five largest sizes.
- `ViewThatFits`: Picks the first layout that fits.
- `.dynamicTypeSize(_:)`: Sets or limits the size for a view.
- `.accessibilityShowsLargeContentViewer()`: A big popup for items that must stay small.

## Variants

### Scale your own sizes

`@ScaledMetric` grows a number, like an avatar size or padding, in step with a text style.

```swift
@ScaledMetric(relativeTo: .body) private var avatar = 40.0

HStack {
    Circle()
        .fill(.blue.gradient)
        .frame(width: avatar, height: avatar)
    Text("Maya Chen")
}
```

### Switch layout at accessibility sizes

Read `dynamicTypeSize` and check `.isAccessibilitySize` to turn a row into a column.

```swift
@Environment(\.dynamicTypeSize) private var typeSize

let layout = typeSize.isAccessibilitySize
    ? AnyLayout(VStackLayout(alignment: .leading))
    : AnyLayout(HStackLayout())

layout {
    Text("Pickup")
    Spacer(minLength: 0)
    Text("Today, 4:30 PM")
        .foregroundStyle(.secondary)
}
```

**Note:** `AnyLayout` swaps the container without rebuilding the views inside, so their state survives the switch.

### Let SwiftUI pick the layout

`ViewThatFits` tries each child in order and shows the first that fits, here buttons side by side, then stacked.

```swift
ViewThatFits(in: .horizontal) {
    HStack {
        Button("Not Now") {}
            .buttonStyle(.bordered)
        Button("Turn On Notifications") {}
            .buttonStyle(.borderedProminent)
    }
    VStack {
        Button("Turn On Notifications") {}
            .buttonStyle(.borderedProminent)
        Button("Not Now") {}
            .buttonStyle(.bordered)
    }
}
```

### Items that must stay small

For chrome that can't grow, like a custom tab bar, add `.accessibilityShowsLargeContentViewer()`: a long press shows a big version.

```swift
HStack(spacing: 32) {
    Label("Home", systemImage: "house")
    Label("Library", systemImage: "books.vertical")
}
.labelStyle(.iconOnly)
.dynamicTypeSize(...DynamicTypeSize.xxxLarge)
.accessibilityShowsLargeContentViewer()
```

**Important:** Use this only for small, repeated chrome. Never cap the size of body text or the main content.

### Preview a big size

Put `.dynamicTypeSize(_:)` on a preview to check a large size without changing Settings.

```swift
#Preview {
    ContentView()
        .dynamicTypeSize(.accessibility3)
}
```

## Related

[typography](typography.md), [font](font.md), [view-that-fits](view-that-fits.md), [accessibility](accessibility.md), [sf-symbols](sf-symbols.md)
