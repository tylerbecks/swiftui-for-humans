---
id: profile
title: Profile Screen
platforms: [iOS, iPadOS]
availability: iOS 26.0+
docs: https://developer.apple.com/documentation/swiftui/lazyvgrid.md
---

# Profile Screen

A social profile with an avatar, stats, Follow and Message buttons, and a photo grid.

## Pitfalls

- **`AsyncImage` doesn't cache.** Photos can download again when they scroll back into view. That's fine for a demo; real apps usually add a caching image loader.
- **Roll numbers with `.contentTransition(.numericText(value:))`.** Change the count inside `withAnimation` and the digits roll like an odometer.

**Note:** The photos are [AsyncImage](async-image.md) views with placeholders, laid out in a three-column [LazyVGrid](lazy-grids.md) under a segmented [Picker](picker.md).

**Important:** Square tiles need a trick. Put `Color.clear.aspectRatio(1, contentMode: .fit)` in each cell, draw the image in an `.overlay`, then `.clipped()`, or wide photos stretch the grid.

**Note:** The follower count uses a numeric [content transition](content-transition.md). The toolbar [Menu](menu.md) holds a [ShareLink](share-link.md) and a destructive Block action.

**Note:** **Why iOS 26?** Only the Liquid Glass button styles need it. Change `.glassProminent` to `.borderedProminent` and `.glass` to `.bordered`, and the screen runs on iOS 17.

More variants, left out to keep this file short: Code. Apple's docs: https://developer.apple.com/documentation/swiftui/lazyvgrid.md

## Related

[lazy-grids](lazy-grids.md), [async-image](async-image.md), [picker](picker.md), [content-transition](content-transition.md)
