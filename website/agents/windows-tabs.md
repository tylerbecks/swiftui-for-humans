---
id: windows-tabs
title: Windows & tabs
platforms: [macOS]
availability: macOS 13.0+
docs: https://developer.apple.com/documentation/swiftui/windowgroup.md
hig: https://developer.apple.com/design/human-interface-guidelines/windows.md
reviewed: October 2026
---

# Windows & tabs

More than one window, tabs that gather them, and windows that come back after a relaunch.

Also called: multiple windows, new window, open in new window, window tabs, tabbed windows, state restoration, SceneStorage, openWindow, WindowGroup, NSWindow.

## Contents

- Rules
- Pitfalls
- Guide
- Key APIs
- Variants
- Related

## Rules

- **Open a new window when it helps, not by default.** A second window is great for comparing or keeping context, like a draft beside the inbox. Opening one for everything buries people in clutter.
- **Offer Open in New Window.** Let people choose to see an item on its own, from a context menu or the File menu.
- **Call it a window.** People know windows. Scene is a word for your code, not for menus and help.
- **Use the system's windows.** People rely on the real title bar, buttons, and active and inactive looks. A homemade frame that's slightly off makes the app feel broken.
- **Bring windows back the way people left them.** After a relaunch, reopen windows in the same place and state, down to the scroll position, so people pick up where they stopped.
- **Keep important things out of a bottom bar.** People often push a window's bottom edge off screen. Use a bottom bar only for a little status about the window's content.

## Pitfalls

- **This app does it too.** Control-click a page in the sidebar and choose Open in New Window. Each window remembers its own tab and page with `@SceneStorage`.
- **Keep `@SceneStorage` small.** It's for things like a selection or a scroll position. The system decides when to save it, and throws it away when the window is closed.

## Guide

Mac users keep several windows open, move between them, and resize them to suit the job. A `WindowGroup` gives your app that for free: people can open more than one window, each with its own state, gather them into **tabs** in a single window, and find them all in the Window menu.

Your part is deciding when content deserves its own window, titling each one, and saving what each window needs to come back after a relaunch.

Open both note windows. Click a button again and the window that's already open comes to the front instead of a copy. People can merge windows like these into one tabbed window, for example with Window > Merge All Windows.

## Key APIs

- `WindowGroup(for:)`: A group of windows, one per value.
- `@Environment(\.openWindow)`: Opens a window from your code.
- `.navigationTitle(_:)`: Titles the window and its Window menu item.
- `@SceneStorage`: Per-window state that's restored on relaunch.
- `.restorationBehavior(.disabled)`: Keeps a window from reopening at launch.
- `\.supportsMultipleWindows`: Whether opening another window is possible.

## Variants

### Open an item in its own window

Give `WindowGroup` a value type, then call `openWindow(value:)` from a context menu to open that item's window.

```swift
struct Note: Identifiable, Hashable, Codable {
    var id: String
    var title: String
}

// In the App:
WindowGroup("Note", for: Note.ID.self) { $noteID in
    NoteView(noteID: noteID)
}

// In the list:
@Environment(\.openWindow) private var openWindow

List(notes) { note in
    Text(note.title)
        .contextMenu {
            Button("Open in New Window") {
                openWindow(value: note.id)
            }
        }
}
```

**Note:** If a window for that value is already open, `openWindow` brings it forward instead of opening a second one.

### Bring each window back as it was

`@SceneStorage` works like `@State`, but each window saves its own value and gets it back after a relaunch.

```swift
struct NoteView: View {
    @SceneStorage("draft") private var draft = ""

    var body: some View {
        TextEditor(text: $draft)
            .navigationTitle("Trip Notes")
    }
}
```

**Note:** Window restoration is a systemwide choice in System Settings. SwiftUI follows it unless you say otherwise for a window.

### Don't reopen short-lived windows

For a window that's only useful in the moment, like a connection test, add `.restorationBehavior(.disabled)` to its scene.

```swift
Window("Connection Test", id: "connection-test") {
    ConnectionTestView()
}
.restorationBehavior(.disabled)
```

## Related

[window-group](window-group.md), [opening-windows](opening-windows.md), [window](window.md), [document-group](document-group.md), [full-screen](full-screen.md), [onboarding](onboarding.md)
