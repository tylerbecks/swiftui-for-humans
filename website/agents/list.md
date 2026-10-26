---
id: list
title: List
platforms: [iOS, iPadOS]
availability: iOS 13.0+, macOS 10.15+, visionOS 1.0+
docs: https://developer.apple.com/documentation/swiftui/list.md
hig: https://developer.apple.com/design/human-interface-guidelines/lists-and-tables.md
---

# List

A scrolling column of rows, like the ones in Settings, Mail, and Contacts.

Also called: table, ul, li, rows, UITableView, UICollectionView, feed, map array, for each, v-for.

## Contents

- Use when
- Don't use when
- Default code
- Built from
- Rules
- Pitfalls
- Key APIs
- Variants
- Related

## Use when

- `List` owns scrolling, row separators, section headers, and system behaviors like swipe actions, selection, and pull to refresh.
- It's the SwiftUI version of `UITableView`, and the backbone of most iPhone screens.
- Use it for rows of text people scan and tap.
- For a grid of images or cards, use a lazy grid inside a `ScrollView`.

## Don't use when

- For editable settings, use [Form](form.md).

## Default code

```swift
let fruits = ["Apple", "Banana", "Cherry"]

List {
    Section("Favorites") {
        ForEach(fruits, id: \.self) { fruit in
            Label(fruit, systemImage: "leaf")
        }
    }
}
```

**Important:** Each item needs a stable identity. Make your model `Identifiable` or pass `id: \.someKey`; array indexes break animations when rows move.

## Built from

List
├── Section("Header")
│   └── ForEach(items)
│       └── Row view
│           └── .swipeActions
└── Section
    └── Fixed row

## Rules

- **Keep row text short.** Short rows are easy to scan and don't wrap or truncate. Put long text on a detail screen people open from the row.
- **Use a chevron for rows that open a screen.** A `NavigationLink` row adds the chevron for you. Don't use an info button to navigate; it only reveals details about the row.
- **Pick the style that fits the content.** Use `.insetGrouped` for settings-like groups and `.plain` for long feeds like messages, where rows run edge to edge.
- **Let people edit lists they own.** People expect to delete and reorder their own items. Add `.onDelete` and `.onMove` and the system handles the gestures.

## Pitfalls

- **`List` is lazy.** It only builds the rows on screen, so it handles thousands of items without slowing down.
- **Selection on iPhone needs edit mode.** `List(selection:)` with a `Set` shows checkmark circles only while editing; add an `EditButton` to the toolbar.
- **Want rows without the list look?** Use a `ScrollView` with a `LazyVStack` for a feed of custom cards.

## Key APIs

- `List(_:rowContent:)`: One row per item in an `Identifiable` collection.
- `ForEach(_:content:)`: Data rows mixed with fixed rows and sections.
- `Section(_:content:)`: Groups rows under a header, with an optional footer.
- `.listStyle(_:)`: `.insetGrouped`, `.plain`, `.sidebar`, and more.
- `.onDelete(perform:)`: On a `ForEach`: swipe to delete, plus edit mode.
- `List(selection:)`: Binds selected rows to an optional or a `Set`.
- `.refreshable { }`: Pull to refresh, running an `async` action.
- `.listRowSeparator(_:)`: Hides or shows one row's separator.

## Variants

### Rows from data

Pass an `Identifiable` array to `List`, like `items.map(item => <li>…</li>)` on the web.

```swift
struct Message: Identifiable {
    let id = UUID()
    let sender: String
    let preview: String
}

@State private var messages = [
    Message(sender: "Maya", preview: "Are we still on for lunch tomorrow?"),
    Message(sender: "Leo", preview: "Sent you the photos from the trip"),
]

List(messages) { message in
    VStack(alignment: .leading) {
        Text(message.sender)
            .font(.headline)
        Text(message.preview)
            .foregroundStyle(.secondary)
            .lineLimit(1)
    }
}
.listStyle(.plain)
```

### Swipe to delete

Add `.onDelete` to the `ForEach`, and every row gets a swipe-to-delete action for free.

```swift
@State private var fruits = ["Apple", "Banana", "Cherry", "Kiwi"]

List {
    ForEach(fruits, id: \.self) { fruit in
        Text(fruit)
    }
    .onDelete { offsets in
        fruits.remove(atOffsets: offsets)
    }
}
```

**Important:** `.onDelete` goes on the `ForEach`, not the `List`. For other swipe buttons, use [Swipe Actions](swipe-actions.md).

### Empty state

Show `ContentUnavailableView` in an `.overlay` when the data is empty. Tap Add to fill the list.

```swift
@State private var items: [String] = []

List(items, id: \.self) { item in
    Text(item)
}
.overlay {
    if items.isEmpty {
        ContentUnavailableView(
            "No Items",
            systemImage: "tray",
            description: Text("Items you add appear here.")
        )
    }
}
```

### Custom row styling

Put `.listRowBackground`, `.listRowInsets`, and `.listRowSeparatorTint` on each row, not on the list.

```swift
List {
    ForEach(["Low", "Medium", "High"], id: \.self) { level in
        Text(level)
            .listRowBackground(Color.orange.opacity(0.15))
            .listRowInsets(.init(top: 14, leading: 24, bottom: 14, trailing: 24))
            .listRowSeparatorTint(.orange)
    }
}
```

## Related

[form](form.md), [swipe-actions](swipe-actions.md), [navigation-stack](navigation-stack.md), [lazy-grids](lazy-grids.md)
