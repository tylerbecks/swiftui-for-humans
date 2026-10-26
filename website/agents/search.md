---
id: search
title: Search
platforms: [macOS]
availability: macOS 12.0+
docs: https://developer.apple.com/documentation/swiftui/adding-a-search-interface-to-your-app.md
hig: https://developer.apple.com/design/human-interface-guidelines/search-fields.md
---

# Search

A search field in the toolbar or sidebar, with suggestions and tokens.

## Contents

- Use when
- Built from
- Rules
- Pitfalls
- Key APIs
- Variants
- Related

## Use when

- Add `.searchable(text:)` to a `NavigationSplitView` or `NavigationStack`, or a view inside one, and a search field appears at the trailing edge of the window's toolbar.
- You own the text, and filter your data with it; SwiftUI draws and manages the field.
- With `placement: .sidebar`, the field sits at the top of the sidebar instead, which suits search that filters the sidebar itself.

## Built from

NavigationSplitView
├── sidebar
├── detail
└── .searchable(text:)
    └── .searchSuggestions { }

## Rules

- **Say what people can search for.** Placeholder text like “Songs, Artists, Albums” tells people what the field covers before they type.
- **Put search at the trailing end of the toolbar.** It's the familiar spot in apps like Mail and Notes, and people can browse results while their selection stays visible in the detail.
- **Use the top of the sidebar for filtering the sidebar.** When search narrows down the sidebar's own items, like System Settings, a field at its top makes the link clear.
- **Suggest searches, and pair tokens with suggestions.** Recent or likely searches help people search faster, and suggestions teach which tokens exist.

## Pitfalls

- **Search as people type.** Filtering on every keystroke feels responsive. For slow searches, like ones over the network, wait for Return with `.onSubmit(of: .search)`.
- **This app does it.** Its sidebar search uses `placement: .sidebar`, and Go > Search (⌘F) focuses the field with `searchFocused`.

## Key APIs

`.searchable(text:prompt:)`, `placement: .sidebar`, `.searchSuggestions { }`, `.searchCompletion(_:)`, `.searchable(text:tokens:)`, `.searchFocused(_:)`, `.onSubmit(of: .search)`

## Variants

### Usage

```swift
@State private var query = ""
let fruits = ["Apple", "Banana", "Cherry", "Mango"]

NavigationStack {
    List(fruits.filter { query.isEmpty || $0.localizedStandardContains(query) },
         id: \.self) { fruit in
        Text(fruit)
    }
    .searchable(text: $query, prompt: "Fruit")
}
```

### Filter as people type

Bind `.searchable` to a string and filter with it. `localizedStandardContains` ignores case and accents, as people expect.

```swift
@State private var query = ""
let books = ["Emma", "Dracula", "Middlemarch", "Persuasion", "Ulysses"]

var results: [String] {
    query.isEmpty ? books : books.filter { $0.localizedStandardContains(query) }
}

NavigationStack {
    List(results, id: \.self) { book in
        Label(book, systemImage: "book")
    }
    .searchable(text: $query, prompt: "Titles")
}
```

**Note:** A real search field in a page would join this app's own toolbar, so the preview draws the window around a live field. The Library window above is the real thing.

### Suggest searches

`.searchSuggestions` lists views below the field, and each one's `searchCompletion` is the text it fills in. Click the field to see them.

```swift
@State private var query = ""

NavigationStack {
    List { Text("Results") }
        .searchable(text: $query, prompt: "Titles")
        .searchSuggestions {
            Section("Recent") {
                Label("Emma", systemImage: "clock").searchCompletion("Emma")
                Label("Dracula", systemImage: "clock").searchCompletion("Dracula")
            }
        }
}
```

### Tokens

With `searchable(text:tokens:)`, a search term becomes a token people can remove as one piece. Offer tokens as suggestions so people find them.

```swift
enum Genre: String, Identifiable, CaseIterable {
    case novel, poetry, drama
    var id: Self { self }
}

@State private var query = ""
@State private var genres: [Genre] = []

NavigationStack {
    List { Text("Results") }
        .searchable(text: $query, tokens: $genres, prompt: "Titles") { genre in
            Text(genre.rawValue.capitalized)
        }
        .searchSuggestions {
            ForEach(Genre.allCases) { genre in
                Text(genre.rawValue.capitalized).searchCompletion(genre)
            }
        }
}
```

More variants, left out to keep this file short: Focus the field with a shortcut. Apple's docs: https://developer.apple.com/documentation/swiftui/adding-a-search-interface-to-your-app.md

## Related

[toolbar](toolbar.md), [navigation-split-view](navigation-split-view.md), [text-field](text-field.md), [focus-keyboard](focus-keyboard.md), [keyboard-shortcuts](keyboard-shortcuts.md), [list-styles](list-styles.md)
