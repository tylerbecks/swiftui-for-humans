---
id: commands
title: Commands & menu bar
platforms: [macOS]
availability: macOS 11.0+
docs: https://developer.apple.com/documentation/swiftui/building-and-customizing-the-menu-bar-with-swiftui.md
hig: https://developer.apple.com/design/human-interface-guidelines/the-menu-bar.md
---

# Commands & menu bar

Add your own menus and menu items to the Mac's menu bar.

Also called: menu bar, menubar, main menu, CommandMenu, CommandGroup, Commands, FocusedValue, focusedSceneValue, NSMenu, NSMenuItem.

## Contents

- Use when
- Built from
- Rules
- Pitfalls
- Key APIs
- Variants
- Related

## Use when

- `.commands` adds menus and items to the menu bar from your `App`.
- `CommandMenu` makes a new menu, which the system puts between View and Window.
- `CommandGroup` adds items to a menu the system already has, or replaces some of them.
- Commands aren't inside any window, so they read `@FocusedValue` to find out what's in front and act on it.

## Built from

WindowGroup
└── .commands
    ├── CommandMenu("Story")
    │   ├── Button
    │   ├── Divider
    │   └── Toggle
    └── CommandGroup(after: .newItem)
        └── Button

## Rules

- **Dim commands that don't apply. Don't hide them.** A menu that keeps the same items teaches people what the app can do, even when a command isn't available right now.
- **End a command with an ellipsis when it asks for more.** The … tells people a window or dialog opens next, so choosing the item doesn't act right away.
- **Put every command in the menu bar.** People look there first when they're learning an app. A command in the menu bar can have a shortcut and works with Full Keyboard Access, even if it's also in a toolbar or context menu.
- **Keep menu titles short, and in the usual order.** One word fits best. Custom menus sit between View and Window, from the most general to the most specific.

## Pitfalls

- **Scenes bring the standard menus.** A `WindowGroup` already has Copy, Paste, and the window commands, and a `Settings` scene adds Settings… to the app menu. Add only what's yours.
- **Values in `FocusedValues` are always optional.** A value is `nil` while no focused window or view publishes it, which is your cue to disable the command.

**Note:** `CommandGroup(replacing:)` removes the system's items in that group. Replacing `.newItem` removes File > New.

## Key APIs

`.commands { }`, `CommandMenu(_:)`, `CommandGroup(after:)`, `CommandGroup(replacing:)`, `@FocusedValue`, `.focusedSceneValue(_:_:)`, `.focusedValue(_:_:)`, `SidebarCommands()`

## Variants

### Usage

```swift
@main
struct WriterApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .commands {
            CommandMenu("Story") {
                Button("New Chapter") { }
                    .keyboardShortcut("n", modifiers: [.command, .option])
            }
        }
    }
}
```

### A menu of your own

`CommandMenu` holds buttons, toggles, and `Menu` submenus, and shows each item's shortcut beside it.

```swift
@State private var showsWordCount = true

var body: some Scene {
    WindowGroup {
        ContentView()
    }
    .commands {
        CommandMenu("Story") {
            Button("New Chapter") { }
                .keyboardShortcut("n", modifiers: [.command, .option])
            Button("Split Chapter") { }
                .keyboardShortcut("k", modifiers: [.command, .shift])
            Divider()
            Toggle("Show Word Count", isOn: $showsWordCount)
            Menu("Export As") {
                Button("PDF…") { }
                Button("Plain Text…") { }
            }
        }
    }
}
```

**Note:** The preview draws a menu bar, and its Story menu is a real `Menu` with the same items. While this page is open, ⌥⌘N and ⇧⌘K run them too.

### More code

```swift
.commands {
    CommandGroup(after: .newItem) {
        Button("New from Clipboard") { }
    }
    CommandGroup(replacing: .help) {
        Button("Writer User Guide") { }
    }
}
```

### Act on what's in focus

Publish a value with `.focusedSceneValue` or `.focusedValue`, and read it in your commands with `@FocusedValue`.

```swift
extension FocusedValues {
    @Entry var note: Note?
}

struct NoteEditor: View {
    @State private var note = Note()

    var body: some View {
        TextEditor(text: $note.text)
            .focusedSceneValue(\.note, note)
    }
}

struct NoteCommands: Commands {
    @FocusedValue(\.note) private var note

    var body: some Commands {
        CommandMenu("Note") {
            Button("Pin Note") { note?.pin() }
                .keyboardShortcut("p", modifiers: [.command, .shift])
                .disabled(note == nil)
        }
    }
}
```

**Note:** Click a field, then the button: it stands in for a menu item and reads the same kind of `@FocusedValue`, so it's dimmed until a field has focus. `.focusedSceneValue` would keep the value while focus moves elsewhere in the window.

## Related

[keyboard-shortcuts](keyboard-shortcuts.md), [context-menu](context-menu.md), [menu](menu.md), [menu-bar-conventions](menu-bar-conventions.md), [settings-scene](settings-scene.md)
