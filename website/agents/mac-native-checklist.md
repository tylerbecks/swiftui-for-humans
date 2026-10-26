---
id: mac-native-checklist
title: Mac-Native Checklist
platforms: [macOS]
hig: https://developer.apple.com/design/human-interface-guidelines/designing-for-macos.md
reviewed: October 2026
---

# Mac-Native Checklist

The details Mac users and reviewers notice, in one list to check before you ship.

Also called: checklist, Mac polish, pre-flight, menu bar, Window menu, View menu, context menu, full keyboard access, undo, full screen.

## Pitfalls

- **Check with the keyboard only.** Turn on Full Keyboard Access in System Settings, then try to reach every control and menu item without the pointer.
- **Open your app next to a Mac app you like.** Compare the menus item by item. Gaps show up fast.

## Guide

Each item comes from the macOS Human Interface Guidelines. None of them is an App Review rule on its own, but together they're the difference between an app that feels at home on the Mac and one that doesn't. Your checkmarks are saved on this Mac.

### Menu bar

- **Standard menus, in order**: Your app's menu, File, Edit, Format, View, your own menus, Window, Help. Leave out File and Format if they don't apply. ([commands](commands.md))
- **Every command is in a menu**: Even commands that also have a toolbar button or a context menu item.
- **Unavailable items are dimmed, not hidden**: The menus show the same items every time.
- **About comes first in the app menu**: With a short app name and no version number in the item's title.
- **A Window menu, even with one window**: With Minimize and Zoom, so Full Keyboard Access can reach them.
- **View menu items say what they'll do**: Show Sidebar when it's hidden, Hide Sidebar when it's showing.
- **A Help menu at the end**: Point it to your help or support page.

### Keyboard

- **Standard shortcuts work**: ⌘C, ⌘V, ⌘Z, ⌘W, ⌘Q, and the rest do what they do everywhere. ([keyboard-shortcuts](keyboard-shortcuts.md))
- **Custom shortcuts only for frequent commands**: And never a standard shortcut reused for something else.
- **Modifiers listed as ⌃⌥⇧⌘**: Control, Option, Shift, Command, in that order.
- **Every control works with Full Keyboard Access**: Tab and the arrow keys reach everything. ([keyboard-access](keyboard-access.md))

### Windows

- **Windows resize smoothly**: The layout adapts to any reasonable size, not one fixed iPad-sized frame. ([window-group](window-group.md))
- **Content can open in its own window**: Where that helps people work on two things at once.
- **Full screen works**: Enter Full Screen in the View menu. ([full-screen](full-screen.md))
- **The system's window frame and controls**: No custom title bars or imitation window buttons.
- **Nothing critical in a bottom bar**: People often move windows partly off screen.

### Input and editing

- **Objects have context menus**: Mac users expect a Control-click on almost anything to offer actions. ([context-menu](context-menu.md))
- **Drag and drop works, including to the Finder**: With another way to do the same thing. ([drag-drop](drag-drop.md))
- **Undo and Redo in the Edit menu**: With the action's name, like Undo Paste. ([undo-redo](undo-redo.md))
- **Buttons sit near the content, not at screen edges**: Ergonomic bottom bars from the iPad don't apply on a Mac.

### Settings and system

- **Settings… in the app menu with ⌘,**: Only app-wide options. Window options stay in the window. ([settings-scene](settings-scene.md))
- **Light and dark appearances both look right**: Use system colors and materials. ([dark-mode](dark-mode.md))
- **A Mac version of your app icon**: Not the iPad icon. ([app-icons](app-icons.md))
- **No assumptions about who's signed in**: With fast user switching, several people can be active on one Mac.

## Related

[great-mac-app](great-mac-app.md), [ipad-app-in-window](ipad-app-in-window.md), [commands](commands.md), [keyboard-shortcuts](keyboard-shortcuts.md), [context-menu](context-menu.md), [settings-scene](settings-scene.md), [undo-redo](undo-redo.md), [full-screen](full-screen.md), [keyboard-access](keyboard-access.md), [drag-drop](drag-drop.md)
