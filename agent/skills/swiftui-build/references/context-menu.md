---
id: context-menu
title: Context Menu
platforms: [iOS, iPadOS, macOS]
availability: iOS 13.0+, macOS 10.15+, visionOS 1.0+
docs: https://developer.apple.com/documentation/swiftui/view/contextmenu(menuitems:).md
hig: https://developer.apple.com/design/human-interface-guidelines/context-menus.md
---

# Context Menu

A menu of actions that appears when people touch and hold a view.

## Contents

- Default code
- Rules
- Pitfalls
- Key APIs
- Variants
- On macOS
- Related

## Default code

```swift
Image(systemName: "photo")
    .font(.largeTitle)
    .contextMenu {
        Button("Copy", systemImage: "doc.on.doc") {}
        Button("Share", systemImage: "square.and.arrow.up") {}
        Button("Delete", systemImage: "trash", role: .destructive) {}
    }
```

**Note:** Items are ordinary `Button`s. Group them with `Section`, and nest a `Menu` for a submenu.

## Rules

- **Hide items that don't apply.** A context menu shows only what you can do right now. Dimmed items make it longer without helping.
- **Offer the same actions somewhere visible.** People can't see a context menu until they find it. Every item should also be in a toolbar, a button, or the detail screen.
- **Keep it short, with the most-used items first.** A few relevant actions are quick to scan. Leave rare and advanced commands out.
- **Use one level of submenu at most.** A submenu inside a submenu is hard to navigate. Give a submenu a title that predicts what's inside, like “Move to”.

## Pitfalls

- **It's the web's right-click menu.** People open it by touching and holding on iPhone, or with a secondary click on iPad with a trackpad.
- **On a `List` row, the whole row lifts.** For multiple selected rows, `.contextMenu(forSelectionType:)` builds one menu for all of them.

## Key APIs

`.contextMenu { }`, `.contextMenu { } preview: { }`, `Section { }`, `Menu(_:content:)`, `Button(role: .destructive)`, `.contextMenu(forSelectionType:)`

## Variants

### Context menu on list rows

Add `.contextMenu` to each row for actions on that item. Touch and hold a name to try it.

```swift
@State private var contacts = ["Maya", "Leo", "Priya"]
@State private var favorites: Set<String> = []

List(contacts, id: \.self) { name in
    Label(name, systemImage: favorites.contains(name) ? "star.fill" : "person")
        .contextMenu {
            Button(favorites.contains(name) ? "Unfavorite" : "Favorite", systemImage: "star") {
                if favorites.contains(name) { favorites.remove(name) } else { favorites.insert(name) }
            }
            Button("Remove", systemImage: "trash", role: .destructive) {
                contacts.removeAll { $0 == name }
            }
        }
}
```

**Note:** The menu can read the row's value, so `name` tells each button which contact to change.

## On macOS

A menu of actions for the item people Control-click or right-click.

### Default code

```swift
FileIcon(file)
    .contextMenu {
        Button("Open") { open(file) }
        Button("Rename…") { rename(file) }
        Divider()
        Button("Move to Trash", role: .destructive) {
            trash(file)
        }
    }
```

**Note:** The menu opens where people click, so it needs no button of its own. That also means people can't see it's there: put the same commands in the menu bar.

### Rules

- **Keep it short, with the commands people need here.** A context menu is a shortcut to the likely next step, not a list of everything. Leave rare and advanced commands in the menu bar.
- **Hide items that don't apply. Don't dim them.** Unlike the menu bar, a context menu shows only what works for this item. Cut, Copy, and Paste are the exception: they can appear dimmed.
- **Leave keyboard shortcuts out.** The context menu is already the shortcut. Show the keys in the menu bar, where people learn them.
- **Put every item in the menu bar too.** A context menu is hidden until people go looking. The same commands belong in the menu bar, where everyone can find them.
- **Keep submenus to one level.** One submenu with a clear title can shorten a menu. A submenu inside a submenu is hard to reach.

### Pitfalls

- **Every way to open it works.** Control-click and a secondary click, on a mouse or a trackpad, open the same menu.
- **An item menu needs a container with selection.** `contextMenu(forSelectionType:)` never opens outside a `List` or `Table` that supports selection.

### Key APIs

`primaryAction:`, `Menu(_:)`, `Divider()`

More variants, left out to keep this file short: Custom preview, Menus for the selection in a list (macOS), Double-click to open a table row (macOS). Apple's docs: https://developer.apple.com/documentation/swiftui/view/contextmenu(menuitems:).md

## Related

[menu](menu.md), [popover](popover.md), [swipe-actions](swipe-actions.md), [confirmation-dialog](confirmation-dialog.md), [commands](commands.md), [list-styles](list-styles.md), [table](table.md)
