---
id: empty-state
title: Empty States
platforms: [iOS, iPadOS]
availability: iOS 17.0+
docs: https://developer.apple.com/documentation/swiftui/contentunavailableview.md
---

# Empty States

What to show when a screen has no content, no search results, or an error.

Also called: empty view, no results, zero state, placeholder, blank slate, no data, error screen, 404, ContentUnavailableView.

## Contents

- Pitfalls
- Variants
- Related

## Pitfalls

- **Use `ContentUnavailableView` instead of building your own.** It replaces the hand-made icon, title, and subtitle stack, with the right fonts, colors, spacing, and Dynamic Type.
- **Say why it's empty and offer one next step.** A short reason plus one action, like Browse or Try Again, beats a blank screen. Don't put anything there people need later, since it disappears once content arrives.

**Note:** One `ContentUnavailableView` sits in an `.overlay` on a [List](list.md). When the list is empty it shows the first-run message with a [Button](button.md); when [search](searchable.md) finds nothing it switches to `ContentUnavailableView.search`.

**Important:** Overlay the empty state on the `List` instead of swapping the list out. Otherwise the search field and toolbar disappear along with it.

## Variants

### Code

```swift
import SwiftUI

struct FavoritesScreen: View {
    @State private var favorites: [String] = []
    @State private var searchText = ""

    private let recipes = [
        "Lemon Herb Chicken", "Miso Ramen", "Shakshuka",
        "Margherita Pizza", "Thai Green Curry", "Banana Bread",
    ]

    private var results: [String] {
        searchText.isEmpty ? favorites : favorites.filter { $0.localizedStandardContains(searchText) }
    }

    var body: some View {
        List {
            ForEach(results, id: \.self) { recipe in
                Label(recipe, systemImage: "heart.fill")
                    .symbolRenderingMode(.multicolor)
            }
            .onDelete { offsets in
                let removed = offsets.map { results[$0] }
                favorites.removeAll { removed.contains($0) }
            }
        }
        .navigationTitle("Favorites")
        .searchable(text: $searchText, prompt: "Search favorites")
        .overlay {
            if favorites.isEmpty {
                ContentUnavailableView {
                    Label("No Favorites Yet", systemImage: "heart")
                } description: {
                    Text("Tap the heart on any recipe to save it here for later.")
                } actions: {
                    Button("Browse Recipes") {
                        withAnimation { favorites = recipes }
                    }
                    .buttonStyle(.borderedProminent)
                }
            } else if results.isEmpty {
                ContentUnavailableView.search(text: searchText)
            }
        }
        .toolbar {
            if !favorites.isEmpty {
                Button("Clear") {
                    withAnimation { favorites = [] }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        FavoritesScreen()
    }
}
```

### Simple

Give `ContentUnavailableView` a title, a `systemImage`, and a one-line `description` of what goes here.

```swift
ContentUnavailableView(
    "No Photos",
    systemImage: "photo.on.rectangle",
    description: Text("Photos you take will appear here.")
)
```

### No search results

Pass the search text to `.search(text:)` and it writes the “No Results for …” message for you.

```swift
@State private var searchText = "zebra"

ContentUnavailableView.search(text: searchText)
```

### Error with a retry

Use the closure form with `actions:` to add a button, such as Try Again after an error.

```swift
ContentUnavailableView {
    Label("You're Offline", systemImage: "wifi.slash")
} description: {
    Text("Check your connection and try again.")
} actions: {
    Button("Try Again") {
        // reload
    }
    .buttonStyle(.bordered)
}
```

## Related

[list](list.md), [searchable](searchable.md), `sf-symbols` (apple-design skill), [button](button.md)
