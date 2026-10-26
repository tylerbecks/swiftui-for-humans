---
id: split-views
title: Split views
platforms: [macOS]
availability: macOS 10.15+
docs: https://developer.apple.com/documentation/swiftui/hsplitview.md
hig: https://developer.apple.com/design/human-interface-guidelines/split-views.md
---

# Split views

Panes people resize by dragging the divider between them, side by side or stacked.

Also called: HSplitView, VSplitView, split view, NSSplitView, NSSplitViewController, pane, panes, divider, resizable panel, splitter.

## Contents

- Use when
- Don't use when
- Built from
- Rules
- Pitfalls
- Key APIs
- Variants
- Related

## Use when

- `HSplitView` puts its children side by side and `VSplitView` stacks them, each with a divider people drag to resize the panes.
- Nest one in the other for an editor with a file list on the left and a console underneath.
- It brings the sidebar look and the toolbar's sidebar button.

## Don't use when

- For sidebar navigation, with a list that picks what the detail shows, use [NavigationSplitView](navigation-split-view.md) instead.

## Built from

HSplitView
├── FileList
└── VSplitView
    ├── Editor
    └── Console

## Rules

- **Give every pane a minimum and maximum size.** If a pane can shrink to nothing, its divider seems to disappear and people can't find it to drag back. A `minWidth` keeps it in reach.
- **Let people hide a pane, and give them more than one way back.** Someone editing may want the console gone. Offer a toolbar button and a menu command with a keyboard shortcut to show it again.
- **Keep the selection highlighted in each pane.** When a choice in one pane decides what the next one shows, a lasting highlight tells people how they got there.
- **Consider drag and drop between panes.** Panes show different levels of your content at once, so dragging an item to another pane is a natural way to move it.

## Pitfalls

- **`HSplitView` and `VSplitView` are Mac only.** If you share the view with another platform, give it another layout there.
- **They add nothing to the toolbar.** Unlike `NavigationSplitView`, there's no sidebar button. If a pane can hide, add your own toolbar button and menu command for it.

**Note:** Put a `minWidth` on each pane. Without one, people can drag a divider until the pane next to it is gone.

## Key APIs

- `HSplitView { }`: Side-by-side panes with draggable dividers.
- `VSplitView { }`: Stacked panes with draggable dividers.
- `.frame(minWidth:idealWidth:maxWidth:)`: Limits how far a pane resizes.
- `NavigationSplitView`: Sidebar and detail columns for navigation.

## Variants

### Usage

```swift
@State private var text = ""

HSplitView {
    List(["README.md", "App.swift"], id: \.self) { Text($0) }
        .frame(minWidth: 150, idealWidth: 200, maxWidth: 320)
    TextEditor(text: $text)
        .frame(minWidth: 300)
}
```

### A list beside an editor

`HSplitView` puts a divider between its children that people drag, and each pane's minimum and maximum width stops it.

```swift
HSplitView {
    List(["README.md", "App.swift", "Model.swift"], id: \.self) {
        Text($0)
    }
    .frame(minWidth: 120, idealWidth: 160, maxWidth: 240)
    Text("App.swift")
        .frame(minWidth: 200, maxWidth: .infinity, maxHeight: .infinity)
}
```

### An editor over a console

`VSplitView` stacks its children with a horizontal divider, so people choose how much room the console gets.

```swift
VSplitView {
    Text("App.swift")
        .frame(maxWidth: .infinity, minHeight: 80, maxHeight: .infinity)
    Text("Build succeeded")
        .font(.callout.monospaced())
        .frame(maxWidth: .infinity, minHeight: 50, maxHeight: .infinity, alignment: .topLeading)
        .padding(8)
}
```

### A pane people can hide

Leave a pane out with `if` and toggle it from a toolbar button, plus a matching menu command so people have another way back.

```swift
@State private var showsConsole = true

VSplitView {
    Text("App.swift")
        .frame(maxWidth: .infinity, minHeight: 80, maxHeight: .infinity)
    if showsConsole {
        Text("Build succeeded")
            .frame(maxWidth: .infinity, minHeight: 50, maxHeight: .infinity)
    }
}
.toolbar {
    Toggle("Console", systemImage: "rectangle.bottomthird.inset.filled", isOn: $showsConsole)
}
```

**Note:** A real `.toolbar` here would land in this window's own toolbar, so the preview draws one. The panes demo window has the real thing.

## Related

[navigation-split-view](navigation-split-view.md), [inspector](inspector.md), [stacks-grid](stacks-grid.md), `windows-layout` (apple-design skill)
