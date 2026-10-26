---
id: opening-windows
title: Opening windows
platforms: [macOS]
availability: macOS 13.0+
docs: https://developer.apple.com/documentation/swiftui/openwindowaction.md
hig: https://developer.apple.com/design/human-interface-guidelines/windows.md
---

# Opening windows

Open, bring forward, and close windows from your own code.

Also called: openWindow, OpenWindowAction, dismissWindow, DismissWindowAction, dismiss, pushWindow, close window, show window, new window, open in new window.

## Contents

- Use when
- Rules
- Pitfalls
- Guide
- Key APIs
- Variants
- Related

## Use when

- Read `openWindow` from the environment and call it with a scene's ID, a value, or both.
- A `Window` comes to the front.
- A `WindowGroup` opens a new window, unless one is already showing that value.
- To close a window, call `dismiss` from a view inside it, or `dismissWindow` with the scene's ID from anywhere in your app.

## Rules

- **Pick the moments that deserve a window.** A new window helps people compare or keep context, like a draft next to the inbox. Opening one for everything clutters the screen.
- **Make “Open in New Window” easy to find.** Offer it in the item's context menu or the File menu, so it's there for people who want it.

## Pitfalls

- **Opening the same value twice doesn't make two windows.** If a window already shows that value, SwiftUI brings it to the front.
- **`pushWindow` is visionOS only.** It swaps one window for another there. On the Mac, open the new window and dismiss the old one.

## Guide

Read `openWindow` from the environment and call it with a scene's ID, a value, or both. A `Window` comes to the front. A `WindowGroup` opens a new window, unless one is already showing that value.

To close a window, call `dismiss` from a view inside it, or `dismissWindow` with the scene's ID from anywhere in your app.

### Usage

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

### Two groups, one type

If two window groups take the same type, like a `UUID` for both messages and accounts, give each an `id` and pass both to `openWindow`.

```swift
WindowGroup("Message", id: "message", for: UUID.self) { $id in
    MessageView(id: id)
}
WindowGroup("Account", id: "account", for: UUID.self) { $id in
    AccountView(id: id)
}

// Elsewhere:
openWindow(id: "account", value: account.id)
```

## Key APIs

- `@Environment(\.openWindow)`: The action that opens windows.
- `openWindow(id:)`: Opens a scene by its ID.
- `openWindow(value:)`: Opens the window group for that value's type.
- `openWindow(id:value:)`: Picks between groups that take the same type.
- `@Environment(\.dismiss)`: Closes the window this view is in.
- `@Environment(\.dismissWindow)`: Closes a window by ID or value.

## Variants

### Open and close by value

These buttons open real windows. Open a note twice and its window comes forward; close it with `dismissWindow(value:)`.

```swift
struct NoteControls: View {
    let note: Note
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow

    var body: some View {
        HStack {
            Button("Open") {
                openWindow(value: note.id)
            }
            Button("Close") {
                dismissWindow(value: note.id)
            }
        }
    }
}
```

### Close the window you're in

Inside a window, `dismiss` closes that window. Each note window above has a Close button that does this.

```swift
struct NoteView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack {
            Text("Groceries")
            Button("Close") {
                dismiss()
            }
            .keyboardShortcut(.cancelAction)
        }
        .padding()
    }
}
```

**Important:** Called from a sheet or popover, `dismiss` closes that presentation, not the window.

### Open a window from the menu bar

Menu commands can read `openWindow` too. This app's About item in the app menu opens its About window this way.

```swift
struct AboutCommands: Commands {
    @Environment(\.openWindow) private var openWindow

    var body: some Commands {
        CommandGroup(replacing: .appInfo) {
            Button("About Notes") {
                openWindow(id: "about")
            }
        }
    }
}

// In your App:
// WindowGroup { … }
//     .commands { AboutCommands() }
```

## Related

[window-group](window-group.md), [window](window.md), [commands](commands.md), [context-menu](context-menu.md), [keyboard-shortcuts](keyboard-shortcuts.md)
