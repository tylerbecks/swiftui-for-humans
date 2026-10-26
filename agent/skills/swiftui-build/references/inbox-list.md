---
id: inbox-list
title: Inbox List
platforms: [iOS, iPadOS]
availability: iOS 17.0+
docs: https://developer.apple.com/documentation/swiftui/view/swipeactions(edge:allowsfullswipe:content:).md
hig: https://developer.apple.com/design/human-interface-guidelines/lists-and-tables.md
---

# Inbox List

A mail-style list with unread dots, swipe actions, a filter menu, and search.

## Rules

- **Keep row text short, and let the detail view hold the rest.** Rows of the same height are quick to scan. Cap the preview with `.lineLimit(2)` and show the full message when the row opens.
- **Put gentle swipe actions on the leading edge.** Mark as Read on the left and Archive or Delete on the right is the layout people know from Mail, so destructive actions are never a stray swipe away.
- **Use the plain list style for a feed.** Edge-to-edge rows suit a long run of similar items like messages. Save the grouped, inset style for settings-like content.

## Pitfalls

- **A destructive swipe doesn't delete your data.** `Button(role: .destructive)` turns red and slides the row away on a full swipe, but you still remove the item from your array.
- **Make your model `Identifiable`.** With a stable `id`, SwiftUI animates inserts and deletes instead of redrawing the whole list.

**Note:** A plain [List](list.md) of `NavigationLink` rows inside a [NavigationStack](navigation-stack.md). Each row has its own [swipe actions](swipe-actions.md), one set per edge, not one set on the `List`.

**Note:** [.searchable](searchable.md) adds the search field, and a [Menu](menu.md) in the [toolbar](toolbar.md) holds the Unread Only toggle. Both filter the array `ForEach` shows, and `ContentUnavailableView.search` appears when nothing matches.

More variants, left out to keep this file short: Code. Apple's docs: https://developer.apple.com/documentation/swiftui/view/swipeactions(edge:allowsfullswipe:content:).md

## Related

[list](list.md), [swipe-actions](swipe-actions.md), [searchable](searchable.md), [navigation-stack](navigation-stack.md)
