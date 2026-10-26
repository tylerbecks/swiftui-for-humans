---
id: menu
title: Menu
platforms: [iOS, iPadOS, macOS]
availability: iOS 14.0+, macOS 11.0+, visionOS 1.0+
docs: https://developer.apple.com/documentation/swiftui/menu.md
hig: https://developer.apple.com/design/human-interface-guidelines/pull-down-buttons.md
---

# Menu

A button that reveals a list of actions when tapped.

## Contents

- Default code
- Rules
- Pitfalls
- Key APIs
- On macOS
- Related

## Default code

```swift
Menu("Options", systemImage: "ellipsis.circle") {
    Button("Copy", systemImage: "doc.on.doc") { copy() }
    Button("Duplicate", systemImage: "plus.square.on.square") { duplicate() }
    Divider()
    Button("Delete", systemImage: "trash", role: .destructive) { delete() }
}
```

## Rules

- **Don't hide the main action in a menu.** People should see the thing they came to do. Show it as a button, and put the less common actions in a More menu.
- **Put at least three items in a menu.** Opening a menu is an extra step. For one or two actions, show them as buttons instead.
- **Put common items first, and group related ones.** People read menus from the top. Use `Section` or `Divider` to separate groups like editing and sharing.
- **Mark destructive items and confirm them.** Give Delete `role: .destructive` so it turns red, place it last, and ask for confirmation with a `.confirmationDialog`.

## Pitfalls

- **A menu holds controls, not any view.** Inside it, use `Button`, `Toggle`, `Picker`, `Divider`, `Section`, and nested `Menu`s.
- **`Menu` opens from a button; `.contextMenu` opens from content.** Use [Context Menu](context-menu.md) for actions people find by long-pressing an item.

## Key APIs

`Menu(_:systemImage:content:)`, `Menu { } label: { }`, `primaryAction:`, `Section` / `Divider`, `role: .destructive`, `.menuOrder(_:)`

## On macOS

A pull-down button that opens a menu of commands related to it.

### Default code

```swift
Menu("Add") {
    Button("New Folder") { addFolder() }
    Button("New Smart Folder") { addSmartFolder() }
    Divider()
    Button("Import…") { importFiles() }
}
```

**Note:** Each item is an ordinary `Button`. Choosing one runs its action and closes the menu.

### Rules

- **Keep a pull-down's items about the button's job.** An Add button can list what to add; a Sort button can list what to sort by. For picking one of several values, use a pop-up [Picker](picker.md).
- **Don't hide a window's main actions in one menu.** People should see the commands they use most. Keep them as buttons, and save the menu for the rest.
- **Make the menu worth opening.** Opening a menu is an extra step, so aim for at least three items. With one or two, show them as buttons or toggles instead. Very long menus are slow to scan, too.
- **Write items in title case, and add an ellipsis when more input follows.** Start with a verb, leave out articles like “the”, and end with “…” when people must give more input before it can finish, as in Export….
- **Mark destructive items.** Give a delete item `role: .destructive`, and ask people to confirm before you remove anything.

### Pitfalls

- **Menus hold buttons, toggles, and pickers.** Put them in the content closure; `Divider()` and `Section` split them into groups.
- **Choose how a picker shows inside a menu.** `.pickerStyle(.inline)` lists its options right in the menu; `.pickerStyle(.menu)` puts them in a submenu.

### Key APIs

`Menu(_:content:)`, `Menu(content:label:)`, `Menu(_:content:primaryAction:)`, `.menuStyle(.button)`, `.menuIndicator(.hidden)`, `Section`, `Divider()`, `Button(_:role:action:)`

### Variants

#### A split button with a primary action

Add `primaryAction:` so a click on the button runs it right away, while the arrow opens a menu of variations.

```swift
Menu("New Document") {
    Button("From Template…") { newFromTemplate() }
    Button("From Clipboard") { newFromClipboard() }
} primaryAction: {
    newDocument()
}
```

#### Sections, toggles, and a picker

Group items with `Section`, use a `Toggle` for an option that's on or off, and an `.inline` picker to list choices in place.

```swift
@State private var sortKey = "Date"
@State private var showsPreview = true

Menu("View Options", systemImage: "slider.horizontal.3") {
    Section("Sort By") {
        Picker("Sort By", selection: $sortKey) {
            Text("Date").tag("Date")
            Text("Name").tag("Name")
            Text("Size").tag("Size")
        }
        .pickerStyle(.inline)
    }
    Section {
        Toggle("Show Preview", isOn: $showsPreview)
    }
}
```

More variants, left out to keep this file short: More button, Split button with primaryAction, Sections with titles, Items with a subtitle (macOS), A borderless menu (macOS). Apple's docs: https://developer.apple.com/documentation/swiftui/menu.md

## Related

[picker](picker.md), [context-menu](context-menu.md), [button](button.md), [toolbar](toolbar.md), [commands](commands.md), [control-group](control-group.md)
