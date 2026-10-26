---
id: label
title: Label
platforms: [iOS, iPadOS]
availability: iOS 14.0+, macOS 11.0+, visionOS 1.0+
docs: https://developer.apple.com/documentation/swiftui/label.md
hig: https://developer.apple.com/design/human-interface-guidelines/labels.md
---

# Label

An icon and a title together, which adapts its look to where it's used.

Also called: icon with text, icon text, list item, menu item, badge, chip, tag, labelStyle.

## Contents

- Default code
- Rules
- Pitfalls
- Key APIs
- Variants
- Related

## Default code

```swift
Label("Favorites", systemImage: "star.fill")

// Icon only, but VoiceOver still reads "Favorites"
Label("Favorites", systemImage: "star.fill")
    .labelStyle(.iconOnly)
```

## Rules

- **Pick a symbol that means the same as the title.** People recognize the standard symbols, like `square.and.arrow.up` for Share. A loose match makes them read twice.
- **Keep a title even when you show only the icon.** Use `.labelStyle(.iconOnly)` instead of a bare `Image`. VoiceOver reads the title, and toolbars can show it when there's room.
- **Use the system colors to rank importance.** Primary for the title, secondary for details. The colors adapt to Dark Mode and higher-contrast settings for you.

## Pitfalls

- **Prefer `Label` over an `HStack` of `Image` and `Text`.** Lists, menus, toolbars, and tab bars know how to lay it out, and VoiceOver reads the title.
- **Controls build labels for you.** `Button("Delete", systemImage: "trash")`, `Toggle`, and `Menu` take a title and a `systemImage:` directly.

## Key APIs

- `Label(_:systemImage:)`: A title with an SF Symbol.
- `Label(_:image:)`: A title with an image from your asset catalog.
- `Label { } icon: { }`: Any views as the title and icon.
- `.labelStyle(_:)`: `.titleAndIcon`, `.titleOnly`, or `.iconOnly`.
- `LabelStyle`: A protocol for your own reusable label layout.
- `.symbolRenderingMode(_:)`: Colors the symbol: `.hierarchical`, `.multicolor`, and more.

## Variants

### In a List

Put `Label`s in a `List` and the icons line up in one column, even at different widths.

```swift
List {
    Label("Wi-Fi", systemImage: "wifi")
    Label("Bluetooth", systemImage: "point.3.connected.trianglepath.dotted")
    Label("Battery", systemImage: "battery.100")
}
```

### In buttons and menus

`Button` and `Menu` take a title and `systemImage:` and build the `Label` for you.

```swift
Menu("Options", systemImage: "ellipsis.circle") {
    Button("Duplicate", systemImage: "plus.square.on.square") {}
    Button("Rename", systemImage: "pencil") {}
    Button("Delete", systemImage: "trash", role: .destructive) {}
}

Button("Share", systemImage: "square.and.arrow.up") {}
    .buttonStyle(.bordered)
```

**Note:** Menus show the icon after the title, and toolbars show only the icon. The same `Label` adapts to each place.

### Settings-style icon

Use `Label { } icon: { }` to build any icon, such as a white symbol on a colored square.

```swift
Label {
    Text("Notifications")
} icon: {
    Image(systemName: "bell.badge.fill")
        .font(.footnote)
        .foregroundStyle(.white)
        .frame(width: 28, height: 28)
        .background(.red, in: .rect(cornerRadius: 7))
}
```

### Custom label style

Conform to `LabelStyle` to define a layout once and reuse it, here an icon over its title.

```swift
struct VerticalLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack(spacing: 6) {
            configuration.icon
                .font(.title2)
            configuration.title
                .font(.caption)
        }
    }
}

HStack(spacing: 28) {
    Label("Camera", systemImage: "camera")
    Label("Photos", systemImage: "photo")
    Label("Files", systemImage: "folder")
}
.labelStyle(VerticalLabelStyle())
```

## Related

[text](text.md), `sf-symbols` (apple-design skill), [image](image.md), [list](list.md)
