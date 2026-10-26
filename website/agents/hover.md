---
id: hover
title: Hover & pointer
platforms: [macOS]
availability: macOS 10.15+
docs: https://developer.apple.com/documentation/swiftui/view/onhover(perform:).md
hig: https://developer.apple.com/design/human-interface-guidelines/pointing-devices.md
---

# Hover & pointer

React when the pointer moves over a view, and show the right pointer.

Also called: :hover, mouseenter, mouseleave, mousemove, cursor, NSCursor, NSTrackingArea, onHover, onContinuousHover, pointerStyle.

## Contents

- Default code
- Rules
- Pitfalls
- Key APIs
- Variants
- Related

## Default code

```swift
@State private var isHovering = false

ProjectRow(project)
    .padding(8)
    .background(isHovering ? Color.secondary.opacity(0.15) : .clear,
                in: .rect(cornerRadius: 8))
    .onHover { isHovering = $0 }
```

**Note:** `.onHover` is like CSS `:hover`, except you store the state yourself and style the view from it.

## Rules

- **Show the pointer that matches what happens.** Each pointer has a meaning people know: a pointing hand for a link, an open hand for content they can pan, like a map, and a crosshair for precise selection. Don't use one for anything else.
- **Let the pointer bring back controls that fade away.** Controls that hide to keep the view calm, like playback controls over a video, should reappear when the pointer moves over them.
- **Keep every way of working consistent.** People switch between the pointer, the keyboard, and gestures without thinking. An action shouldn't work differently, or only work, with one of them.

## Pitfalls

- **The hover area is the view's frame.** Add padding before `.onHover` to make the area bigger.
- **`.pointerStyle` needs macOS 15.** `.onContinuousHover` needs macOS 14, and `.onHover` dates back to macOS 10.15.

## Key APIs

- `.onHover { isHovering in }`: Runs when the pointer enters or leaves.
- `.onContinuousHover { phase in }`: Reports the pointer's location as it moves.
- `.pointerStyle(_:)`: The pointer to show over a view.
- `.link`, `.grabIdle`, `.columnResize`: A few of the built-in pointer styles.
- `.pointerVisibility(.hidden)`: Hides the pointer over a view.

## Variants

### Show actions on the row under the pointer

Use `.onHover` to track the row under the pointer and show its buttons only there, so the list stays calm.

```swift
@State private var hoveredRow: Project.ID?

ForEach(projects) { project in
    HStack {
        Text(project.name)
        Spacer()
        if hoveredRow == project.id {
            Button("Share", systemImage: "square.and.arrow.up") { share(project) }
            Button("Delete", systemImage: "trash") { delete(project) }
        }
    }
    .labelStyle(.iconOnly)
    .buttonStyle(.borderless)
    .contentShape(.rect)
    .onHover { isHovering in
        hoveredRow = isHovering ? project.id : nil
    }
}
```

**Important:** Hover-only buttons are invisible to the keyboard and to VoiceOver until the pointer arrives. Put the same commands in a context menu or the menu bar.

### Follow the pointer

`.onContinuousHover` reports the pointer's location while it moves over a view, and `.ended` when it leaves.

```swift
@State private var spot: CGPoint?

SceneryView(.lake)
    .overlay {
        if let spot {
            Circle()
                .fill(.white.opacity(0.35))
                .frame(width: 60, height: 60)
                .position(spot)
        }
    }
    .onContinuousHover { phase in
        switch phase {
        case .active(let location): spot = location
        case .ended: spot = nil
        }
    }
```

### A resize pointer on a divider

`.pointerStyle(.columnResize)` shows the left-right resize pointer, so people know they can drag the divider.

```swift
@State private var sidebarWidth = 140.0

HStack(spacing: 0) {
    Sidebar()
        .frame(width: sidebarWidth)
    Rectangle()
        .fill(.separator)
        .frame(width: 1)
        .padding(.horizontal, 3)
        .contentShape(.rect)
        .pointerStyle(.columnResize)
        .gesture(DragGesture(coordinateSpace: .named("split")).onChanged { drag in
            sidebarWidth = min(max(drag.location.x, 100), 220)
        })
    Detail()
}
.coordinateSpace(.named("split"))
```

**Note:** For a real sidebar, `NavigationSplitView` gives you the divider and the pointer for free.

## Related

[tooltips](tooltips.md), [trackpad-gestures](trackpad-gestures.md), [drag-drop](drag-drop.md), [button](button.md)
