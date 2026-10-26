---
id: windows-layout
title: Windows & Layout
platforms: [macOS]
docs: https://developer.apple.com/documentation/swiftui/windows.md
hig: https://developer.apple.com/design/human-interface-guidelines/layout.md
reviewed: October 2026
---

# Windows & Layout

Lay out windows that people move, resize, and stack beside other apps.

## Contents

- Rules
- Pitfalls
- Guide
- Key APIs
- Variants
- Related

## Rules

- **Keep important controls away from the bottom edge.** People often drag a window partly below the screen, which hides whatever sits at its bottom. Put actions in the toolbar or near the top.
- **Put what matters most at the top leading corner.** People read a window from the top and from the leading side, so the first thing they should see goes there.
- **Use a bottom bar only for a little status.** A bottom bar suits a short summary of the window, like a count of items. If you have more to show, use an inspector instead.
- **Let the system draw the window.** People know the standard frame, buttons, and title bar. A custom copy that doesn't match exactly makes the whole app feel broken.
- **Open new windows when they help, not by default.** A second window is great for comparing or keeping context, like a draft beside the message it answers. Offer Open in New Window in the File menu or a context menu instead of opening one every time.
- **Call it a window.** In anything people read, say window, whatever kind it is. Words like scene describe your code, not what people see.

## Pitfalls

- **Try the smallest and largest sizes first.** Apple suggests testing the extremes before the sizes in between, since that's where clipping shows up.
- **People decide where windows go.** People typically run several apps at once, so don't count on your window filling the screen or staying where it opened.

## Guide

On the Mac, people keep several apps open at once. They move, resize, minimize, and stack windows to suit their work, so your layout has to hold up at any size you allow, next to windows from other apps.

### Parts of a window

- Frame: The top of the window, with the close, minimize, and zoom buttons and often a toolbar. People drag it to move the window.
- Body: Your content. People can usually resize the window by dragging its edges.
- Bottom bar: Rare. A thin strip under the content for a little status, like Finder's count of items and free space.

### Window states

Only one window takes your typing at a time. The Mac draws the three states differently, so people can tell which window is in front and which one gets their input.

- Key: The window that receives keyboard input. Its close, minimize, and zoom buttons are in color. Only one window on screen is key.
- Main: The app's frontmost window. It's usually also key, unless a panel such as Fonts is taking input.
- Inactive: Any window in the background. Its window buttons turn gray and it drops its materials, so it looks farther away.

**Note:** System controls switch appearance on their own. Custom views can read `appearsActive`, as in the last example below.

## Key APIs

`.defaultSize(width:height:)`, `.windowResizability(_:)`, `.frame(minWidth:minHeight:)`, `.scenePadding()`, `ViewThatFits`, `\.appearsActive`, `.backgroundExtensionEffect()`

## Variants

### Choose a starting size and a minimum

Use `.defaultSize(width:height:)` on the scene for the first launch, and a minimum `.frame` on the content so the layout never breaks.

```swift
@main
struct TripsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 480, minHeight: 320)
        }
        .defaultSize(width: 900, height: 600)
    }
}
```

### Size the window to its content

Use `.windowResizability(.contentSize)` for a window that should stay the size of what's inside, like a small utility window.

```swift
Window("Converter", id: "converter") {
    ConverterView()
        .frame(width: 320, height: 160)
}
.windowResizability(.contentSize)
```

### Use the Mac's margins

Apply `.scenePadding()` to a window's root view for the recommended space around its content, instead of picking a number.

```swift
VStack(alignment: .leading, spacing: 8) {
    Text("Lisbon")
        .font(.title2)
    Text("4 nights · 2 travelers")
        .foregroundStyle(.secondary)
}
.frame(maxWidth: .infinity, alignment: .leading)
.scenePadding()
```

More variants, left out to keep this file short: Rearrange when the window narrows, Tone down custom accents in inactive windows. Apple's docs: https://developer.apple.com/documentation/swiftui/windows.md

## Related

[window-group](window-group.md), [window-style](window-style.md), [opening-windows](opening-windows.md), [split-views](split-views.md), [view-that-fits](view-that-fits.md), [toolbar](toolbar.md), [full-screen](full-screen.md)
