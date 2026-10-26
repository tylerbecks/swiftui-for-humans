---
id: library-window
title: Library window
platforms: [macOS]
availability: macOS 14.0+
docs: https://developer.apple.com/documentation/swiftui/navigationsplitview.md
hig: https://developer.apple.com/design/human-interface-guidelines/sidebars.md
---

# Library window

A sidebar, a sortable table, and an inspector: the classic window for browsing a library.

## Built from

NavigationSplitView
├── sidebar: List(selection:)
│   ├── Section("Library")
│   └── Section("Playlists")
└── detail: Table(selection:sortOrder:)
    ├── .searchable(text:)
    ├── .toolbar { … }
    └── .inspector(isPresented:)
        └── Form

## Rules

- **Use familiar symbols in the sidebar.** A symbol next to each item helps people scan the list and find a place again. Leave their color to the accent color people chose.
- **Keep the sidebar to two levels.** Use short section headers for the groups. If your data goes deeper, add a content column between the sidebar and the details.
- **Let people hide the side panes, but show them at first.** Some people want room for the content, so offer a toolbar button and a View menu command. Start with the sidebar visible so people find it.
- **Don't put key actions at the bottom of the sidebar.** People often move windows so the bottom edge is off screen.

## Pitfalls

- **The table doesn't sort for you.** It shows the sort in its headers and updates `sortOrder`, and you sort your array when that changes.
- **The inspector remembers itself.** A trailing-column inspector has its shown or hidden state restored for you.
- **Add the standard commands.** `SidebarCommands()` adds the built-in sidebar commands, and `InspectorCommands()` adds one that shows and hides the inspector with ⌃⌘I.

## Key APIs

`NavigationSplitView { } detail: { }`, `List(selection:)`, `Table(_:selection:sortOrder:)`, `TableColumn(_:value:)`, `.inspector(isPresented:)`, `.navigationSplitViewColumnWidth`, `SidebarCommands()`, `InspectorCommands()`

More variants, left out to keep this file short: Sidebar, table, and inspector, Add it to your app. Apple's docs: https://developer.apple.com/documentation/swiftui/navigationsplitview.md

## Related

[navigation-split-view](navigation-split-view.md), [table](table.md), [inspector](inspector.md), [search](search.md), [toolbar](toolbar.md), [empty-states](empty-states.md)
