---
id: toolbar
title: Toolbar
platforms: [iOS, iPadOS, macOS]
availability: iOS 14.0+, macOS 11.0+, visionOS 1.0+
docs: https://developer.apple.com/documentation/swiftui/view/toolbar(content:).md
hig: https://developer.apple.com/design/human-interface-guidelines/toolbars.md
---

# Toolbar

Puts buttons and menus in the bar at the top or bottom of a screen.

## Contents

- Use when
- Default code
- Built from
- Rules
- Pitfalls
- Key APIs
- Variants
- On macOS
- Related

## Use when

- `.toolbar` fills the bars of the screen it's attached to: the navigation bar at the top and an optional bar at the bottom.
- Each screen brings its own items, and they swap as you push and pop.
- A plain `Button` lands in the trailing spot.
- Wrap it in `ToolbarItem(placement:)` to put it somewhere else.

## Default code

```swift
NavigationStack {
    List(1...20, id: \.self) { Text("Note \($0)") }
        .navigationTitle("Notes")
        .toolbar {
            Button("Add", systemImage: "plus") {
                // Add a note
            }
        }
}
```

**Important:** Put `.toolbar` on a view inside the `NavigationStack`, not on the stack itself, or the items won't show.

## Built from

NavigationStack
└── Screen view
    └── .toolbar
        ├── ToolbarItem
        ├── ToolbarSpacer
        ├── ToolbarItem
        └── ToolbarItem(.bottomBar)

## Rules

- **Use symbols for common actions.** Familiar SF Symbols like share and plus are quicker to recognize than words, and leave room for the title. Keep text for actions like Edit that have no clear symbol.
- **Keep the bar uncluttered.** Show the two or three actions people use most, and move the rest into a More menu built with `Menu`.
- **Mark one primary action.** Put Done or Save in `.confirmationAction`, so it's tinted and sits on the trailing side. More than one makes the focus unclear.
- **Keep the standard Back and Close buttons.** People already know what they do. Don't swap them for a text label that says Back or Close.

## Pitfalls

- **Neighboring buttons share one glass capsule.** `ToolbarSpacer(.fixed)` splits them into separate groups, and `ToolbarSpacer(.flexible)` pushes them apart.
- **Add a second line under the title.** `.navigationSubtitle` (iOS 26) shows a smaller line, like Mail's unread count.

## Key APIs

`.toolbar { }`, `ToolbarItem(placement:)`, `.topBarLeading`, `.topBarTrailing`, `.confirmationAction`, `.cancellationAction`, `.bottomBar`, `ToolbarSpacer(_:placement:)`, `.toolbar(_:for:)`

## Variants

### Save and Cancel in a sheet

Use `.cancellationAction` and `.confirmationAction` to put Cancel and Save where people expect them.

```swift
@State private var showEditor = false

Button("New Event") { showEditor = true }
    .sheet(isPresented: $showEditor) {
        NavigationStack {
            Form {
                TextField("Title", text: .constant(""))
            }
            .navigationTitle("New Event")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) { showEditor = false }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add", role: .confirm) { showEditor = false }
                }
            }
        }
    }
```

**Note:** A sheet doesn't get a bar of its own. Wrap its content in a `NavigationStack` to show a title and toolbar.

## On macOS

Commands, controls, and search at the top of a window, placed by what they do.

### Rules

- **Use symbols, not words.** Simple, familiar symbols are quicker to scan and take less space. Text works better only for actions a symbol can't show, like Edit.
- **Title the window after its content, not your app.** A title like the mailbox or document name tells people where they are. The app's name tells them nothing about what's in the window.
- **Put every toolbar command in the menu bar too.** People can hide or customize the toolbar, so it can't be the only home for a command.
- **Keep it to a few groups.** Group items by what they do, and aim for no more than three groups. Too many makes the toolbar feel cluttered.

### Pitfalls

- **Narrow windows move items into an overflow menu.** Choose a few items that matter, so little ends up hidden there.
- **Keep window titles short.** The HIG suggests under 15 characters, so the title leaves room for the toolbar's items.

### Key APIs

`.navigation`, `.principal`, `.primaryAction`, `.toolbar(id:)`, `ToolbarSpacer(.fixed)`, `.navigationSubtitle(_:)`

### Variants

#### Usage

```swift
List(["Lunch on Friday?", "Your receipt"], id: \.self) { subject in
    Text(subject)
}
.navigationTitle("Inbox")
.toolbar {
    Button("New Message", systemImage: "square.and.pencil") { }
}
```

More variants, left out to keep this file short: Menu in the toolbar, Placements (macOS), A toolbar people can customize (macOS), Space between groups (macOS). Apple's docs: https://developer.apple.com/documentation/swiftui/view/toolbar(content:).md

## Related

[navigation-stack](navigation-stack.md), [button](button.md), [menu](menu.md), [searchable](searchable.md), [search](search.md), [navigation-split-view](navigation-split-view.md), [toggle](toggle.md), [commands](commands.md), [toolbars-pattern](toolbars-pattern.md)
