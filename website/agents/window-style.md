---
id: window-style
title: Window style & sizing
platforms: [macOS]
availability: macOS 11.0+
docs: https://developer.apple.com/documentation/swiftui/windows.md
hig: https://developer.apple.com/design/human-interface-guidelines/windows.md
---

# Window style & sizing

Scene modifiers for a window's title bar, toolbar style, size, and position.

Also called: windowStyle, hiddenTitleBar, title bar, titlebar, transparent title bar, windowToolbarStyle, unified toolbar, expanded toolbar, defaultSize, window size.

## Contents

- Use when
- Rules
- Pitfalls
- Key APIs
- Variants
- Related

## Use when

- These modifiers go on a scene in your `App`, like a `WindowGroup`, not on a view.
- They decide how new windows start out.
- People can still move and resize them, within the limits you set.
- A few window behaviors are view modifiers instead, like `.containerBackground(_:for:)` with `.window`, so you can set them from inside the window.

## Rules

- **Keep the system's window frame.** People know how standard windows look and behave. A homemade frame or window buttons that don't match exactly make the app feel broken.
- **Let windows adapt to any size.** People arrange windows side by side and resize them all the time. Set a minimum that keeps your layout intact, and let it grow from there.
- **Keep important things out of a bottom bar.** People often move a window so its bottom edge is off screen. Use a bottom bar only for a little status, like Finder's item count.
- **Keep the system's look for each window state.** People tell the active window apart by its colored window buttons and materials. Standard backgrounds and controls change with the state; custom ones have to do it themselves.

## Pitfalls

- **Settings windows fit their content by default.** With `.automatic` resizability, a `Settings` window uses `.contentSize` and every other scene uses `.contentMinSize`.
- **These are starting values.** When the system restores a window, it comes back at the size and place people left it.

## Key APIs

- `.defaultSize(width:height:)`: The size a new window opens at.
- `.windowResizability(.contentSize)`: Sizes the window from its content's frame.
- `.defaultPosition(.topTrailing)`: Where the first window appears on screen.
- `.windowStyle(.hiddenTitleBar)`: Hides the title and the title bar's backing.
- `.windowToolbarStyle(.unified)`: How the toolbar and title bar combine.
- `.containerBackground(_:for:)`: With `.window`, the window's background.
- `WindowDragGesture()`: Lets people drag the window by a view.
- `.windowResizeBehavior(.disabled)`: Turns off resizing from inside the window.

## Variants

### Usage

```swift
@main
struct LibraryApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 480, minHeight: 320)
        }
        .defaultSize(width: 900, height: 600)
    }
}
```

### A minimum size and a starting size

A `frame(minWidth:minHeight:)` on the content sets how small the window can get. `.defaultSize` sets the size it opens at.

```swift
WindowGroup {
    ContentView()
        .frame(minWidth: 320, minHeight: 180)
}
.defaultSize(width: 440, height: 260)
```

**Note:** A default size outside what the window allows is clamped to fit.

### A window that fits its content

`.windowResizability(.contentSize)` takes the window's limits from the content's frame. A fixed frame makes a window people can't resize.

```swift
Window("About Notes", id: "about") {
    AboutView()
        .frame(width: 440, height: 560)
}
.windowResizability(.contentSize)
.defaultPosition(.center)
```

**Note:** To turn off resizing, minimizing, or full screen from inside a window, set `.windowResizeBehavior`, `.windowMinimizeBehavior`, and `.windowFullScreenBehavior` to `.disabled`, as the Timer window does.

### Where the window opens

The first window opens in the center of the screen. `.defaultPosition` picks another spot, given as a `UnitPoint`.

```swift
WindowGroup {
    ContentView()
}
.defaultPosition(.topTrailing)
```

### Toolbar styles

`.windowToolbarStyle` sets how the title and toolbar share the top of the window. Pick a style to compare.

```swift
WindowGroup {
    ContentView()
}
.windowToolbarStyle(.unifiedCompact)
```

### Hide the title bar

`.windowStyle(.hiddenTitleBar)` hides the title and the title bar's backing, so more of the content shows.

```swift
WindowGroup {
    PlayerView()
}
.windowStyle(.hiddenTitleBar)
.windowBackgroundDragBehavior(.enabled)
```

**Important:** Without a title bar, people need another place to grab the window. Set `.windowBackgroundDragBehavior` to `.enabled` so they can drag it by its background.

### A see-through window

From inside the window, `.containerBackground(_:for:)` with `.window` sets its background, and you can hide the toolbar's title and backing.

```swift
struct NowPlayingView: View {
    var body: some View {
        VStack {
            Text("Now Playing")
                .font(.title)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .containerBackground(.thinMaterial, for: .window)
        .toolbarBackgroundVisibility(.hidden, for: .windowToolbar)
        .toolbar(removing: .title)
        .gesture(WindowDragGesture())
        .allowsWindowActivationEvents()
    }
}
```

**Note:** `WindowDragGesture` lets people move the window by dragging the view. `.allowsWindowActivationEvents()` lets the drag work even while the window is in the background.

## Related

[window-group](window-group.md), [window](window.md), [toolbar](toolbar.md), [materials](materials.md), [full-screen](full-screen.md), [windows-layout](windows-layout.md)
