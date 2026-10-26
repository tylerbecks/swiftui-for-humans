---
id: window-group
title: WindowGroup
platforms: [macOS]
availability: macOS 11.0+
docs: https://developer.apple.com/documentation/swiftui/windowgroup.md
hig: https://developer.apple.com/design/human-interface-guidelines/windows.md
---

# WindowGroup

The scene for your app's main windows, where people can open as many as they need.

Also called: window, windows, multiple windows, new window, File > New Window, scene, WindowGroup(for:), open in new window, state restoration, restorationBehavior.

## Contents

- Use when
- Built from
- Rules
- Pitfalls
- Key APIs
- Variants
- Related

## Use when

- `WindowGroup` is the scene most Mac apps start with.
- Its content is a template: every window people open from it gets its own copy of the view, with its own state.
- On the Mac you get File > New Window, a list of open windows in the Window menu, and windows that people can merge into tabs, without writing any code.
- For a window there should only ever be one of, use `Window` instead.

## Built from

App
├── WindowGroup          main windows
└── WindowGroup(for:)    one per value
    └── $value binding

## Rules

- **Call it a window.** The system calls every window a window. Words like “scene” or “view” for the same thing only confuse people.
- **Open new windows when they help, not by default.** A second window is great for comparing or keeping context, like a draft beside your inbox. Opening one for every click fills the screen and makes the app harder to follow.
- **Offer “Open in New Window” as a choice.** Put it in the item's context menu or the File menu, so people who want a separate window can have one.
- **Make windows work at any size.** People resize and arrange windows constantly on the Mac. Set a sensible minimum size and let the layout grow from there.

## Pitfalls

- **Closing the last window doesn't quit the app.** An app built on a `WindowGroup` keeps running with no windows open. One whose only scene is a `Window` quits when it closes.
- **Each window starts with fresh `@State`.** Keep data that every window should see in a shared model, passed in through the environment.

## Key APIs

- `WindowGroup { }`: Main windows. People can open many.
- `WindowGroup(for:) { $value in }`: One window per value, like a note's ID.
- `WindowGroup(_:id:)`: A title for menus, and an ID to open it by.
- `defaultValue:`: The value File > New Window passes instead of `nil`.
- `@Environment(\.openWindow)`: Opens a window from your code.
- `.navigationTitle(_:)`: Each window's own title.
- `.restorationBehavior(.disabled)`: Keeps a scene's windows from reopening at launch.

## Variants

### Usage

```swift
@main
struct NotesApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

### Every window has its own state

SwiftUI gives each new window fresh storage for its `@State`. Count in one window, and the other doesn't change.

```swift
struct ContentView: View {
    @State private var count = 0

    var body: some View {
        Stepper("Cups of tea: \(count)", value: $count)
            .padding()
    }
}
```

### A window per item

`WindowGroup(for:)` opens one window per value, like a note's ID. Open a note twice, and its window comes forward.

```swift
@main
struct NotesApp: App {
    var body: some Scene {
        WindowGroup {
            NoteList()
        }
        WindowGroup("Note", for: Note.ID.self) { $noteID in
            NoteView(noteID: noteID)
        }
    }
}

struct NoteRow: View {
    let note: Note
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        Text(note.title)
            .contextMenu {
                Button("Open in New Window") {
                    openWindow(value: note.id)
                }
            }
    }
}
```

**Note:** The value must be `Hashable` and `Codable`. Pass an ID rather than the whole model: SwiftUI saves the value to restore the window later.

### New windows and restoring

```swift
WindowGroup("Note", for: Note.ID.self) { $noteID in
    NoteView(noteID: noteID)
} defaultValue: {
    store.makeNote().id
}
```

## Related

[window](window.md), [opening-windows](opening-windows.md), [document-group](document-group.md), [window-style](window-style.md), [windows-tabs](windows-tabs.md)
