---
id: empty-states
title: Empty states
platforms: [macOS]
availability: macOS 14.0+
docs: https://developer.apple.com/documentation/swiftui/contentunavailableview.md
hig: https://developer.apple.com/design/human-interface-guidelines/writing.md
---

# Empty states

What a sidebar, table, or search shows when there's nothing to show yet.

Also called: ContentUnavailableView, empty state, no results, no items, blank slate, zero state, placeholder, nothing selected, no selection, error state.

## Contents

- Rules
- Pitfalls
- Key APIs
- Variants
- Related

## Rules

- **Say what to do next, and give a button for it.** An empty window is daunting when the next step isn't clear. Name the action and put it right there.
- **Show progress while loading, not an empty state.** “No Items” while data is still on its way looks like a problem. Show a progress indicator until you know the list is empty.
- **Keep important information out of it.** An empty state goes away as soon as there's content, and anything in it goes too.

## Pitfalls

- **Overlay it, don't replace the list.** Put `ContentUnavailableView` in an `.overlay` on the empty `List` or `Table`, so the column headers, toolbar, and search field stay put.
- **`.search` fills in the words for you.** `ContentUnavailableView.search(text:)` builds a no-results message that quotes what people typed.

## Key APIs

- `ContentUnavailableView(_:systemImage:)`: A title and symbol, for simple cases.
- `ContentUnavailableView { } description: { }`: Adds a line about what to do.
- `actions: { Button… }`: Buttons under the message.
- `.search(text:)`: The standard no-results message.
- `.overlay { }`: Shows it on top of the empty list or table.

## Variants

### An empty sidebar

Give a first-run sidebar a title, a short description, and the button that fills it. Click New Playlist to see the list take over.

```swift
@State private var playlists: [String] = []

List(playlists, id: \.self) { name in
    Label(name, systemImage: "music.note.list")
}
.overlay {
    if playlists.isEmpty {
        ContentUnavailableView {
            Label("No Playlists", systemImage: "music.note.list")
        } description: {
            Text("Playlists you make appear here.")
        } actions: {
            Button("New Playlist") {
                playlists.append("Untitled Playlist")
            }
        }
    }
}
```

### An empty table

Overlay the empty state on the `Table`, so its column headers stay in place and people can see what will fill it.

```swift
@State private var contacts: [Contact] = []

Table(contacts) {
    TableColumn("Name", value: \.name)
    TableColumn("Email", value: \.email)
}
.overlay {
    if contacts.isEmpty {
        ContentUnavailableView {
            Label("No Contacts", systemImage: "person.2")
        } description: {
            Text("Import a file or add someone by hand.")
        } actions: {
            Button("Import Contacts…") { }
        }
    }
}
```

### No search results

When a search finds nothing, show `ContentUnavailableView.search(text:)`. Clear the field, or type Ana, to bring rows back.

```swift
struct Contact: Identifiable {
    let id = UUID()
    let name: String
    let email: String
}

struct ContactsView: View {
    let contacts: [Contact]
    @State private var searchText = ""

    private var results: [Contact] {
        contacts.filter { searchText.isEmpty || $0.name.localizedStandardContains(searchText) }
    }

    var body: some View {
        NavigationStack {
            Table(results) {
                TableColumn("Name", value: \.name)
                TableColumn("Email", value: \.email)
            }
            .overlay {
                if results.isEmpty {
                    ContentUnavailableView.search(text: searchText)
                }
            }
            .searchable(text: $searchText)
        }
    }
}
```

**Note:** The drawing uses a text field in place of `.searchable`, which would put its field in this app's own toolbar. The Contacts window has the real one.

### Nothing selected

In the detail column of a split view, say what's missing in a few words. No button needed: the next step is clicking the list.

```swift
ContentUnavailableView("No Message Selected", systemImage: "envelope")
```

### Something went wrong

For a failed load, explain it plainly and offer Try Again in `actions:`. Keep the details short; people want the way out.

```swift
ContentUnavailableView {
    Label("Couldn't Load Photos", systemImage: "wifi.exclamationmark")
} description: {
    Text("Check your internet connection, then try again.")
} actions: {
    Button("Try Again") { }
        .buttonStyle(.borderedProminent)
}
```

## Related

[library-window](library-window.md), [search](search.md), [table](table.md), [navigation-split-view](navigation-split-view.md), `writing` (apple-design skill)
