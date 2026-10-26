---
id: keyboard-shortcuts
title: Keyboard shortcuts
platforms: [macOS]
availability: macOS 11.0+
docs: https://developer.apple.com/documentation/swiftui/view/keyboardshortcut(_:modifiers:).md
hig: https://developer.apple.com/design/human-interface-guidelines/keyboards.md
---

# Keyboard shortcuts

Run a button or menu item from the keyboard, like ⌘S for Save.

Also called: hotkey, hot key, key equivalent, keyEquivalent, accelerator, keybinding, key binding, command key, KeyEquivalent, EventModifiers.

## Default code

```swift
Button("Mark as Read") {
    markAsRead()
}
.keyboardShortcut("k", modifiers: [.command, .shift])
```

**Important:** A capital letter adds Shift: `.keyboardShortcut("K")` is ⇧⌘K. Write the letter in lowercase and list the modifiers, so the code says what people press.

## Rules

- **Don't give a standard shortcut a new job.** People expect ⌘C, ⌘Z, ⌘W, and the rest to work the same in every app. Pick a new shortcut for your own command instead.
- **Add shortcuts only for the commands people use most.** A few well-chosen shortcuts speed people up. Too many new ones make the app feel hard to learn.
- **Lead with Command, and add Shift for a related command.** Use Option sparingly, for advanced commands. Avoid Control: the system uses it for moving focus, screenshots, and more.
- **Write modifiers in the order ⌃ ⌥ ⇧ ⌘.** Menus list them that way, so help text and tooltips should too.
- **Don't add a modifier to make an unrelated shortcut.** ⇧⌘Z means Redo because ⌘Z means Undo. Using it for something else breaks the pattern people rely on.

## Pitfalls

- **A shortcut works anywhere in the front window.** Pressing it is the same as clicking the control, even when the control doesn't have focus.
- **The first match wins.** SwiftUI looks in the key window, then the main window, then the menu bar, and runs the first control it finds with that shortcut.
- **Shortcuts adapt to other keyboards.** The system remaps ones that are hard to type on another layout, like ⌘[, and mirrors directional ones for right-to-left languages.

## Key APIs

- `.keyboardShortcut(_:modifiers:)`: A key plus modifiers; ⌘ by default.
- `.keyboardShortcut(.defaultAction)`: Return, for the main button.
- `.keyboardShortcut(.cancelAction)`: Escape, for Cancel.
- `KeyEquivalent`: The key: a character, or `.return`, `.delete`, arrows.
- `EventModifiers`: `.command`, `.shift`, `.option`, `.control`.

## Variants

### Return and Escape in a dialog

`.defaultAction` binds Return to the main button and `.cancelAction` binds Escape to Cancel, like a dialog.

```swift
HStack {
    Button("Cancel", role: .cancel) { dismiss() }
        .keyboardShortcut(.cancelAction)
    Button("Save") { save() }
        .keyboardShortcut(.defaultAction)
}
```

### Shortcuts appear in menus

Add `.keyboardShortcut` to a button in a `Menu` or a `CommandMenu`, and the menu shows the keys beside it.

```swift
Menu("Message") {
    Button("Reply") { reply() }
        .keyboardShortcut("r")
    Button("Forward") { forward() }
        .keyboardShortcut("f", modifiers: [.command, .shift])
    Button("Mark as Unread") { markAsUnread() }
        .keyboardShortcut("u", modifiers: [.command, .shift])
}
```

**Note:** The shortcuts work while the button's window is in front, even with the menu closed. In a real app, put these in a `CommandMenu` so they work from the menu bar.

## Related

[commands](commands.md), [button](button.md), `keyboard-access` (apple-design skill), [focus-keyboard](focus-keyboard.md)
