---
id: full-screen
title: Full screen
platforms: [macOS]
availability: macOS 15.0+
docs: https://developer.apple.com/documentation/swiftui/view/windowtoolbarfullscreenvisibility(_:).md
hig: https://developer.apple.com/design/human-interface-guidelines/going-full-screen.md
reviewed: October 2026
---

# Full screen

Let a window fill the screen for focused work, and keep what people need in reach.

Also called: full-screen mode, Enter Full Screen, ⌃⌘F, green button, zoom, presentation mode, distraction free, windowToolbarFullScreenVisibility, windowFullScreenBehavior, appearsActive.

## Rules

- **Offer full screen where focus helps.** Games, photos, video, slideshows, and deep work like writing benefit most from filling the screen.
- **Use the system's full screen.** The green button, View > Enter Full Screen, and ⌃⌘F already work and handle things like the camera housing on some Macs. Don't add a menu of your own window modes.
- **Adjust the layout, not the window.** Use the extra room for the content, with subtle changes so switching modes isn't jarring. Never resize the window from code.
- **Keep essential controls in reach.** People should finish their task without leaving full screen, like playback controls that are always there or easy to reveal.
- **Hide toolbars when content is the point, and bring them back on request.** For reading or viewing, tuck controls away, and show them when people move the pointer to the top of the screen.
- **Let people decide when to leave, and pause when they look away.** Don't end full screen on your own when something finishes. If people switch away, pause a game or slideshow so they don't miss anything.

## Pitfalls

- **Full screen comes with the window.** SwiftUI decides from the scene and its modifiers. With `.windowResizability`, the content's maximum size also decides whether a window can go full screen.
- **Option-click the green button to zoom instead.** The window grows to its maximum size, or as large as the display allows.

## Guide

Any Mac window that can grow can usually fill the screen in a space of its own: people click the green window button, choose **View > Enter Full Screen**, or press ⌃⌘F. The menu bar hides until the pointer reaches the top of the screen, and by default the window's toolbar stays at the top, above the content.

SwiftUI windows get this for free. Your part is the layout, deciding what to hide, and pausing when people switch away.

Open the slideshow, then click its green button. Its toolbar hides until you move the pointer to the top. Switch to another app and the slideshow pauses.

## Key APIs

- `.windowToolbarFullScreenVisibility(_:)`: Shows the toolbar only on hover in full screen.
- `.windowFullScreenBehavior(.disabled)`: Keeps a window out of full screen.
- `\.appearsActive`: False when the window isn't the active one.
- `.toolbarVisibility(_:for:)`: Hides the window's toolbar entirely.

## Variants

### Tuck the toolbar away in full screen

`.windowToolbarFullScreenVisibility(.onHover)` hides the toolbar in full screen until the pointer moves to the top.

```swift
SlideshowView()
    .toolbar {
        Button("Pause", systemImage: "pause") { }
    }
    .windowToolbarFullScreenVisibility(.onHover)
```

**Note:** It only affects the window it's in. The slideshow above uses it; the preview draws the result.

### Pause when the window isn't active

Run the timer only while `appearsActive` is true; it turns false when people switch to another window or app.

```swift
@Environment(\.appearsActive) private var appearsActive
@State private var slide = 0

Text("Slide \(slide + 1)")
    .task(id: appearsActive) {
        guard appearsActive else { return }
        while !Task.isCancelled {
            try? await Task.sleep(for: .seconds(2))
            slide = (slide + 1) % 5
        }
    }
```

### Keep a utility window out of full screen

Add `.windowFullScreenBehavior(.disabled)` to a small panel's content, like a color mixer, that has no use for the whole screen.

```swift
Window("Color Mixer", id: "mixer") {
    ColorMixer()
        .windowFullScreenBehavior(.disabled)
}
```

## Related

[windows-tabs](windows-tabs.md), [toolbars-pattern](toolbars-pattern.md), [menu-bar-conventions](menu-bar-conventions.md), `window-style` (swiftui-build skill)
