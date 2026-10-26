---
id: swipe-actions
title: Swipe Actions & Editing
platforms: [iOS, iPadOS]
availability: iOS 15.0+, macOS 12.0+, visionOS 1.0+
docs: https://developer.apple.com/documentation/swiftui/view/swipeactions(edge:allowsfullswipe:content:).md
hig: https://developer.apple.com/design/human-interface-guidelines/lists-and-tables.md
---

# Swipe Actions & Editing

Lets people swipe rows for actions, delete and reorder them, and pull to refresh.

Also called: swipe to delete, slide to delete, drag to reorder, sortable, pull to refresh, onDelete, edit mode, UIContextualAction, trailingSwipeActions.

## Default code

```swift
@State private var names = ["Maya", "Leo", "Priya"]

List(names, id: \.self) { name in
    Text(name)
        .swipeActions {
            Button("Delete", systemImage: "trash", role: .destructive) {
                names.removeAll { $0 == name }
            }
        }
}
```

**Important:** Once a row has `.swipeActions`, its `.onDelete` swipe stops showing. Add your own Delete button with `role: .destructive`, as here.

## Rules

- **Make the full swipe the expected action.** A full swipe runs the first button without a second tap. Use it for something people do often and can undo, like Delete in Mail or Archive.
- **Keep swipe actions to a few per side.** One to three buttons stay readable. More get squeezed into narrow, hard-to-tap targets.
- **Offer the same actions somewhere visible.** Swipes are hidden until people try them. Repeat important actions in a [context menu](context-menu.md), the toolbar, or the detail screen.
- **Let people reorder and delete their own items.** Lists people build, like playlists or reminders, feel broken without editing. `.onMove` and `.onDelete` add it in two lines.

## Pitfalls

- **These only work in a `List`.** Swipe actions, `.onDelete`, and `.onMove` need list rows. `.refreshable` also works on a `ScrollView`.

## Key APIs

- `.swipeActions(edge:)`: Buttons revealed by swiping a row; `.leading` or `.trailing`.
- `allowsFullSwipe:`: Runs the first button on a full swipe. On by default.
- `Button(role: .destructive)`: A red button that animates the row away.
- `.tint(_:)`: The color of any other swipe button.
- `.onDelete(perform:)`: On a `ForEach`: swipe to delete, plus edit mode.
- `.onMove(perform:)`: On a `ForEach`: drag to reorder in edit mode.
- `EditButton()`: Toggles edit mode from the toolbar.
- `.refreshable { }`: Pull to refresh with an `async` action.

## Variants

### Delete and reorder

Add `.onDelete` and `.onMove` to the `ForEach`, and an `EditButton` to show the controls.

```swift
@State private var reminders = ["Buy milk", "Call Mom", "Book flights"]

NavigationStack {
    List {
        ForEach(reminders, id: \.self) { Text($0) }
            .onDelete { reminders.remove(atOffsets: $0) }
            .onMove { reminders.move(fromOffsets: $0, toOffset: $1) }
    }
    .navigationTitle("Reminders")
    .toolbar { EditButton() }
}
```

**Note:** Drag handles only appear in edit mode. Swipe to delete works either way.

### Pull to refresh

Add `.refreshable` to a `List`; the spinner stays until its `async` closure returns.

```swift
@State private var updated: Date?

List {
    Text(updated.map { "Updated \($0.formatted(date: .omitted, time: .shortened))" } ?? "Pull down to refresh")
}
.refreshable {
    try? await Task.sleep(for: .seconds(1)) // Load new data here
    updated = .now
}
```

## Related

[list](list.md), [context-menu](context-menu.md), [toolbar](toolbar.md)
