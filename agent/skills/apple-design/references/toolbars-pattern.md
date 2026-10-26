---
id: toolbars-pattern
title: Toolbars
platforms: [macOS]
availability: macOS 13.0+
docs: https://developer.apple.com/documentation/swiftui/toolbars.md
hig: https://developer.apple.com/design/human-interface-guidelines/toolbars.md
reviewed: October 2026
---

# Toolbars

Which commands earn a place in the toolbar, how to group them, and letting people customize.

Also called: NSToolbar, toolbar items, customize toolbar, toolbar customization, toolbar(id:), ToolbarItem, ToolbarSpacer, toolbar placement, window title, overflow menu.

## Contents

- Rules
- Pitfalls
- Guide
- Key APIs
- Variants
- Related

## Rules

- **Put the commands people use most in the toolbar.** Not every menu item needs a button. Pick the frequent ones, or the ones for the most important things people work with.
- **Make every toolbar item a menu command too.** People can hide or customize the toolbar, so it can't be the only place a command lives.
- **Use plain symbols.** Toolbar items don't need outlines or circles: the toolbar already groups them, and the system draws hover and selection.
- **Title the window with its content, not your app's name.** The title tells people where they are and tells windows apart. Keep it short, under about 15 characters.
- **Keep groups few and logical.** Group items by what they do, and aim for no more than three groups. Separate text buttons with space so they don't read as one.
- **Let people customize toolbars in apps they live in.** If you offer many items, or people use the app for hours, let them choose what's in the center.

## Pitfalls

- **On the Mac, `.primaryAction` sits at the leading edge.** On iPhone and iPad it's at the trailing edge, so check placements when you bring an iPad toolbar over.
- **Overflow is automatic.** When a window gets too narrow, the system moves center items into an overflow menu. Don't build your own.

## Guide

On the Mac, the toolbar sits at the top of the window, in or below the title bar. It holds the window's title, controls for getting around, and the actions people use most. Because people can hide it or customize it, the toolbar is a shortcut to commands that also live in the menu bar, never the only way to reach them.

### Three areas

Pick an area to see what the HIG puts there.

### Try a real one

This window's toolbar can be customized. Control-click the toolbar and choose **Customize Toolbar…**, then drag items in and out.

**Note:** A real `.toolbar` here would land in this app's own toolbar, so the previews draw the window. The editor above uses the first example's code.

## Key APIs

- `.toolbar(id:content:)`: A toolbar people can customize.
- `ToolbarItem(id:placement:)`: One item, with an ID for customization.
- `ToolbarSpacer(.fixed)`: A gap between groups of items, from macOS 26.
- `.navigation`: Leading edge, before the title.
- `.principal`: The center of the toolbar.
- `ToolbarCommands()`: Adds the toolbar's menu items, like Customize.

## Variants

### A toolbar people can customize

Use `.toolbar(id:)`, give each `ToolbarItem` an ID, and separate the groups with `ToolbarSpacer(.fixed)`.

```swift
@State private var text = ""
@State private var isBold = false
@State private var isItalic = false

TextEditor(text: $text)
    .toolbar(id: "editor") {
        ToolbarItem(id: "bold") {
            Toggle("Bold", systemImage: "bold", isOn: $isBold)
        }
        ToolbarItem(id: "italic") {
            Toggle("Italic", systemImage: "italic", isOn: $isItalic)
        }
        ToolbarSpacer(.fixed)
        ToolbarItem(id: "share") {
            Button("Share", systemImage: "square.and.arrow.up") { }
        }
    }
    .navigationTitle("Trip Notes")
```

**Note:** To offer customization in the menu bar too, add `ToolbarCommands()` to the scene's `.commands`.

### Place items by role

`.navigation` goes at the leading edge, before the title, and `.principal` in the center.

```swift
Text("Page")
    .toolbar {
        ToolbarItem(placement: .navigation) {
            Button("Back", systemImage: "chevron.backward") { }
        }
        ToolbarItem(placement: .principal) {
            Picker("View", selection: .constant(0)) {
                Text("Day").tag(0)
                Text("Week").tag(1)
            }
            .pickerStyle(.segmented)
        }
    }
```

### The same command in the menu bar

Give each toolbar action a menu item, with a shortcut if it's frequent, so it works with the toolbar hidden.

```swift
.commands {
    CommandMenu("Note") {
        Button("Share Note…") { }
        Button("Show Note Info") { }
            .keyboardShortcut("i")
    }
}
```

## Related

`toolbar` (swiftui-build skill), [menu-bar-conventions](menu-bar-conventions.md), `search` (swiftui-build skill), `inspector` (swiftui-build skill), [full-screen](full-screen.md)
