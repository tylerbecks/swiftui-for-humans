---
id: window
title: Window
platforms: [macOS]
availability: macOS 13.0+
docs: https://developer.apple.com/documentation/swiftui/window.md
hig: https://developer.apple.com/design/human-interface-guidelines/panels.md
---

# Window

A single, unique window, like an activity viewer or a floating palette.

Also called: single window, singleton window, one window, auxiliary window, secondary window, UtilityWindow, utility window, floating window, palette, panel.

## Contents

- Use when
- Built from
- Rules
- Pitfalls
- Key APIs
- Variants
- Related

## Use when

- `Window` opens one window, never two.
- Asking for it again brings the open window to the front, and the Window menu lists it by title.
- `UtilityWindow` (macOS 15) is a kind of `Window` for tool palettes and inspectors: it floats above your main windows, hides when your app isn't active, and adds an item to show and hide it in the View menu.

## Built from

App
├── WindowGroup      main windows
├── Window           exactly one
└── UtilityWindow    floating palette

## Rules

- **Leave “panel” out of the menu item.** Name the command after the panel's title, as in Show Inspector or Show Colors. Short noun titles are easy to spot in a menu and on screen.
- **Use a panel for controls that follow the selection.** An inspector updates as people select different items. A window that always shows the same thing, like an Info window, should be a regular window.
- **Prefer sliders and steppers in panels.** Panels work best with direct adjustments. Typing text or picking items to act on takes extra steps in a small floating window.
- **Hide panels with your app, and skip the minimize button.** Panels appear when needed and disappear when your app isn't active. `UtilityWindow` does both for you.

## Pitfalls

- **Every scene ID must be unique.** `Window` and `WindowGroup` share one set of IDs, and `openWindow(id:)` uses it to find the scene.
- **The Window menu lists it for you.** People can bring a `Window` back from the Window menu by its title, so it doesn't need its own menu item.

## Key APIs

- `Window(_:id:) { }`: One unique window, listed in the Window menu.
- `UtilityWindow(_:id:) { }`: A floating palette that follows the active window.
- `openWindow(id:)`: Shows the window, or brings it to the front.
- `@Environment(\.dismiss)`: Closes the window from inside it.
- `@FocusedValue`: Reads the focused main window's selection.
- `.windowLevel(.floating)`: Keeps any window above normal windows.
- `.defaultLaunchBehavior(.presented)`: Opens it at launch, like a welcome window.

## Variants

### Usage

```swift
@main
struct PhotosApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        Window("Activity", id: "activity") {
            ActivityView()
        }
    }
}
```

### Show it from a button

Call `openWindow(id:)` with the window's ID. If the window is already open, it comes to the front.

```swift
struct ShowActivityButton: View {
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        Button("Show Activity") {
            openWindow(id: "activity")
        }
    }
}
```

### A floating palette

`UtilityWindow` floats above your main windows. Read the active window's selection with `@FocusedValue`, and it updates as people switch windows.

```swift
extension FocusedValues {
    @Entry var selectedPhotoCount: Int?
}

@main
struct PhotosApp: App {
    var body: some Scene {
        WindowGroup {
            PhotoGrid()
        }
        UtilityWindow("Photo Info", id: "photo-info") {
            PhotoInfo()
        }
    }
}

struct PhotoGrid: View {
    @State private var selection = Set<Int>()

    var body: some View {
        Text("\(selection.count) photos selected")
            .focusedSceneValue(\.selectedPhotoCount, selection.count)
    }
}

struct PhotoInfo: View {
    @FocusedValue(\.selectedPhotoCount) private var count

    var body: some View {
        Text("\(count ?? 0) photos selected")
            .padding()
    }
}
```

**Note:** A utility window isn't minimizable by default, and when it's focused, Esc closes it. It takes focus only when it needs to, like when people click its title bar or a text field in it.

### A window as the whole app

For an app that should never have two windows, like one built around the camera, make a `Window` the only scene.

```swift
@main
struct VideoCallApp: App {
    var body: some Scene {
        Window("Video Call", id: "main") {
            CallView()
        }
    }
}
```

**Important:** When that window closes, the app quits. For most apps, start with a `WindowGroup` instead, and add a `Window` beside it.

## Related

[window-group](window-group.md), [opening-windows](opening-windows.md), [settings-scene](settings-scene.md), [window-style](window-style.md), [menu-bar-extra](menu-bar-extra.md)
