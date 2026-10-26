---
id: control-group
title: ControlGroup
platforms: [macOS]
availability: macOS 12.0+
docs: https://developer.apple.com/documentation/swiftui/controlgroup.md
hig: https://developer.apple.com/design/human-interface-guidelines/toolbars.md
---

# ControlGroup

Related buttons joined into one control, in a toolbar or in content.

Also called: button group, segmented buttons, NSSegmentedControl momentary, back forward, zoom in out, toolbar group, btn-group, controlGroupStyle.

## Contents

- Default code
- Rules
- Pitfalls
- Key APIs
- Variants
- Related

## Default code

```swift
ControlGroup("Zoom", systemImage: "magnifyingglass") {
    Button("Zoom Out", systemImage: "minus.magnifyingglass") {
        zoomOut()
    }
    Button("Zoom In", systemImage: "plus.magnifyingglass") {
        zoomIn()
    }
}
.labelStyle(.iconOnly)
```

**Note:** Like a `.btn-group` of buttons on the web. Each button keeps its own action; the group only changes how they're drawn.

## Rules

- **Group toolbar items by what they do.** Put commands that work together side by side, like zooming out and in. Navigation and critical actions such as Done get their own familiar spots.
- **Keep the number of groups small.** Too many groups make a toolbar look cluttered and hard to scan. Aim for three at most.
- **Use a group for actions and a picker for a choice.** Don't mix buttons that act with segments that stay selected. For one choice among several, use a segmented [Picker](picker.md).

## Pitfalls

- **The label matters in a toolbar.** When a toolbar runs out of room, the group moves into the overflow menu under its label, so give it one.
- **Each button keeps its own title.** Use `Button(_:systemImage:action:)` with `.labelStyle(.iconOnly)`, and VoiceOver still reads each title.

## Key APIs

- `ControlGroup { … }`: Groups the buttons inside it.
- `ControlGroup(_:systemImage:content:)`: With a label for menus and overflow.
- `.controlGroupStyle(.navigation)`: For back and forward buttons.
- `.controlGroupStyle(.menu)`: Shows the buttons as a menu.
- `.controlGroupStyle(.palette)`: Shows the content as a palette.
- `.labelStyle(.iconOnly)`: Symbols only, titles kept for VoiceOver.

## Variants

### Back and forward in a toolbar

Use `.controlGroupStyle(.navigation)` for back and forward, in the toolbar's `.navigation` placement.

```swift
@State private var page = 3

Text("Page \(page)")
    .navigationTitle("Page \(page) of 5")
    .toolbar {
        ToolbarItem(placement: .navigation) {
            ControlGroup("Navigation", systemImage: "arrow.left.arrow.right") {
                Button("Back", systemImage: "chevron.left") { page -= 1 }
                    .disabled(page == 1)
                Button("Forward", systemImage: "chevron.right") { page += 1 }
                    .disabled(page == 5)
            }
            .controlGroupStyle(.navigation)
        }
    }
```

**Note:** A real `.toolbar` here would land in this window's toolbar, so the preview draws one. Open the sample to see the real thing.

### Zoom controls under a view

In content, a group keeps paired actions together, such as zooming out and in below an image.

```swift
@State private var zoom = 100

VStack {
    Image(systemName: "photo")
        .font(.system(size: 48 * Double(zoom) / 100))
    ControlGroup {
        Button("Zoom Out", systemImage: "minus") { zoom -= 25 }
        Button("Actual Size") { zoom = 100 }
        Button("Zoom In", systemImage: "plus") { zoom += 25 }
    }
    .fixedSize()
}
```

### A group as a menu

`.controlGroupStyle(.menu)` folds the buttons into a menu under the group's label, for actions people need now and then.

```swift
ControlGroup("Arrange", systemImage: "square.3.layers.3d") {
    Button("Bring to Front") { bringToFront() }
    Button("Send to Back") { sendToBack() }
}
.controlGroupStyle(.menu)
```

## Related

[button](button.md), [picker](picker.md), [menu](menu.md), [toolbar](toolbar.md), [toolbars-pattern](toolbars-pattern.md)
