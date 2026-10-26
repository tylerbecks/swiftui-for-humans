---
id: menu-bar-conventions
title: The menu bar
platforms: [macOS]
availability: macOS 11.0+
docs: https://developer.apple.com/documentation/swiftui/building-and-customizing-the-menu-bar-with-swiftui.md
hig: https://developer.apple.com/design/human-interface-guidelines/the-menu-bar.md
reviewed: October 2026
---

# The menu bar

The standard menus, their order, and which commands belong in each.

Also called: main menu, NSMenu, app menu, File menu, Edit menu, View menu, Window menu, Help menu, Format menu, CommandMenu.

## Contents

- Rules
- Pitfalls
- Guide
- Key APIs
- Variants
- Related

## Rules

- **Keep the standard menus, in the standard order.** People expect App, File, Edit, Format, View, your menus, Window, and Help. Many standard items work without any code from you.
- **Disable items instead of hiding them.** A menu that keeps the same items teaches people what the app can do, even when a command doesn't apply right now.
- **Put every command in a menu.** Even rare and advanced commands. In a menu, people can find them, see their shortcuts, and reach them with Full Keyboard Access.
- **Use short, one-word menu titles.** The menu bar shares its space with menu bar extras and may truncate long titles. One word is quick to scan.
- **Name show and hide items for what they'll do.** When the toolbar is showing, the item says Hide Toolbar; when it's hidden, Show Toolbar.
- **Keep a Window menu, even with one window.** Its Minimize and Zoom items give keyboard users a way to do what the window buttons do.

## Pitfalls

- **People learn your app from its menus.** Opening each menu is how many people find out what an app can do, so a command that's only in a toolbar or a context menu is easy to miss.
- **This app's Go menu is a `CommandMenu`.** The system put it after View, where app-specific menus go.

## Guide

The menu bar is how people learn what a Mac app can do and find its commands. Every app uses the same menus in the same order, so people know where to look before they've opened yours: your app's menu, **File**, **Edit**, **Format**, **View**, any menus of your own, **Window**, and **Help**. The Apple menu sits before them, and menu bar extras sit at the far end.

### What goes where

Click a menu to see the items the HIG lists for it, in order. The app here is a notes app.

### What SwiftUI adds for you

Each scene brings its own menu items. Add the optional ones with `.commands`.

- WindowGroup: Hiding and quitting the app, Copy and Paste, and window management.
- Settings: The **Settings…** item in the app menu. See [Settings](settings-scene.md).
- DocumentGroup: Document items like Save and Duplicate.
- SidebarCommands, ToolbarCommands, InspectorCommands: Items for the sidebar, the toolbar, and the inspector. Add the ones your windows have.
- TextFormattingCommands: The Format menu, for apps that edit styled text.

**Note:** A real `.commands` here would change this app's own menu bar, so the previews draw the menus.

## Key APIs

- `.commands { }`: Adds menus and items to a scene.
- `CommandMenu(_:)`: Your own menu, placed after View.
- `CommandGroup(after:)`: Adds items next to a standard group.
- `CommandGroup(replacing:)`: Swaps out a standard group, like Help.
- `SidebarCommands()`: The menu item that shows or hides the sidebar.
- `TextFormattingCommands()`: The Format menu, for styled text.
- `@FocusedValue`: Lets a command act on the frontmost window.

## Variants

### Add a menu of your own

`CommandMenu` adds a menu after View: fill it with buttons, and give only the frequent ones a shortcut.

```swift
WindowGroup {
    ContentView()
}
.commands {
    CommandMenu("Note") {
        Button("Pin Note") { }
        Button("Duplicate Note") { }
            .keyboardShortcut("d")
        Divider()
        Button("Show Note Info") { }
            .keyboardShortcut("i")
    }
}
```

### Add to a standard menu

`CommandGroup(after:)` puts items next to a standard group, like after New in the File menu.

```swift
.commands {
    CommandGroup(after: .newItem) {
        Button("New Note from Clipboard") { }
    }
}
```

### Turn on the standard extras

If a window has a sidebar or a customizable toolbar, add `SidebarCommands` and `ToolbarCommands` for their menu items.

```swift
WindowGroup {
    ContentView()
}
.commands {
    SidebarCommands()
    ToolbarCommands()
}
```

### Act on the frontmost window

Publish the window's model with `.focusedSceneValue`, read it with `@FocusedValue`, and disable the item when there isn't one.

```swift
@Observable
final class NoteModel {
    var isPinned = false
}

struct NoteCommands: Commands {
    @FocusedValue(NoteModel.self) private var note

    var body: some Commands {
        CommandMenu("Note") {
            Button("Pin Note") { note?.isPinned.toggle() }
                .disabled(note == nil)
        }
    }
}

// In the window's view:
// .focusedSceneValue(model)
```

## Related

[commands](commands.md), [keyboard-shortcuts](keyboard-shortcuts.md), [context-menu](context-menu.md), [settings-pattern](settings-pattern.md), [undo-redo](undo-redo.md), [keyboard-access](keyboard-access.md)
