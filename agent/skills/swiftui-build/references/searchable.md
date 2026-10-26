---
id: searchable
title: Searchable
platforms: [iOS, iPadOS]
availability: iOS 15.0+, macOS 12.0+, visionOS 1.0+
docs: https://developer.apple.com/documentation/swiftui/view/searchable(text:placement:prompt:).md
hig: https://developer.apple.com/design/human-interface-guidelines/search-fields.md
---

# Searchable

Adds a system search field to a screen and hands you the text to filter with.

Also called: search bar, search box, filter, input type=search, UISearchController, UISearchBar, autocomplete, typeahead, find.

## Contents

- Default code
- Rules
- Pitfalls
- Key APIs
- Variants
- Related

## Default code

```swift
@State private var searchText = ""

let fruits = ["Apple", "Banana", "Cherry", "Kiwi"]

NavigationStack {
    List(fruits.filter { searchText.isEmpty || $0.localizedStandardContains(searchText) }, id: \.self) { fruit in
        Text(fruit)
    }
    .navigationTitle("Fruit")
    .searchable(text: $searchText, prompt: "Search fruit")
}
```

**Important:** `.searchable` only draws the field; you filter the data yourself. It also needs a `NavigationStack` around it to have a bar to live in.

## Rules

- **Say what people can search for.** A specific prompt like “Search recipes” sets expectations. The default “Search” doesn't tell people what's inside.
- **Update results as people type.** Live results feel fast and help people narrow down. Wait for the Search key only when a search is slow, like a network request.
- **Suggest searches before people type.** Recent or popular searches in `.searchSuggestions` save typing and show what's possible.
- **Start with the broadest scope.** Show all results first and let people narrow them with scopes. Use scopes only for a few clear categories.

## Pitfalls

- **On iPhone the field sits at the bottom.** In iOS 26 that's the default, where thumbs reach it. `.navigationBarDrawer` keeps it under the title instead.
- **For app-wide search, use a search tab.** `Tab(role: .search)` in a [TabView](tab-view.md) keeps search one tap away from every section.

## Key APIs

- `.searchable(text:prompt:)`: Adds the field and binds its text.
- `placement:`: Where the field goes, like `.navigationBarDrawer`.
- `.searchSuggestions { }`: Rows shown while the field is active.
- `.searchCompletion(_:)`: On a suggestion: fills the field when tapped.
- `.searchScopes(_:scopes:)`: A segmented filter under the field.
- `.onSubmit(of: .search)`: Runs when people tap Search on the keyboard.
- `ContentUnavailableView.search(text:)`: The standard “No Results” view.

## Variants

### No results

Show `ContentUnavailableView.search` in an `.overlay` when nothing matches the search text.

```swift
@State private var searchText = ""

let fruits = ["Apple", "Banana", "Cherry", "Kiwi"]

NavigationStack {
    let results = fruits.filter { searchText.isEmpty || $0.localizedStandardContains(searchText) }
    List(results, id: \.self) { Text($0) }
        .navigationTitle("Fruit")
        .searchable(text: $searchText)
        .overlay {
            if results.isEmpty {
                ContentUnavailableView.search(text: searchText)
            }
        }
}
```

### Search when people tap Search

Use `.onSubmit(of: .search)` when a search is slow, like a network request.

```swift
@State private var searchText = ""
@State private var lastSearch = ""

NavigationStack {
    Text(lastSearch.isEmpty ? "Type, then tap Search" : "Results for “\(lastSearch)”")
        .navigationTitle("Store")
        .searchable(text: $searchText)
        .onSubmit(of: .search) {
            lastSearch = searchText
        }
}
```

**Note:** Without it, `searchText` still changes on every keystroke, so you can also debounce in a `.task(id: searchText)`.

### Search tokens

Use `.searchable(text:tokens:)` for filter capsules in the field, like Mail's “From: Maya”.

```swift
struct Tag: Identifiable, Hashable {
    let id: String
}

@State private var text = ""
@State private var tokens: [Tag] = []

NavigationStack {
    List {
        Text(tokens.isEmpty ? "All photos" : "Photos tagged \(tokens.map(\.id).formatted())")
    }
    .navigationTitle("Photos")
    .searchable(text: $text, tokens: $tokens) { tag in
        Label(tag.id, systemImage: "tag")
    }
    .searchSuggestions {
        ForEach([Tag(id: "Beach"), Tag(id: "Dogs")]) { tag in
            Label(tag.id, systemImage: "tag")
                .searchCompletion(tag)
        }
    }
}
```

**Note:** People don't know which tokens exist. Offer them as suggestions with `.searchCompletion(tag)`, as here.

## Related

[list](list.md), [navigation-stack](navigation-stack.md), [text-field](text-field.md), [toolbar](toolbar.md)
