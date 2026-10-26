---
id: drag-drop
title: Drag and drop
platforms: [macOS]
availability: macOS 26.0+
docs: https://developer.apple.com/documentation/swiftui/drag-and-drop.md
hig: https://developer.apple.com/design/human-interface-guidelines/drag-and-drop.md
---

# Drag and drop

Let people drag content within a window, between windows, and to other apps.

## Use when

- `.draggable` turns a view into something people can drag, and `.dropDestination` makes a view accept drops.
- Both work with `Transferable` types, so the same code handles drags inside a window, between your app's windows, and to and from other apps.
- A type's transfer representations decide what it becomes: your own data when it lands in your app, and plain text or a file in apps that don't know your type.

## Rules

- **Support drag and drop wherever people might try it.** Most people know it and try it everywhere. Text fields and text views already support it.
- **Offer another way to do the same thing.** Some people can't or don't drag. Back every drag with menu commands, like Copy and Paste or Move To.
- **Show whether a destination accepts the drop.** Highlight a destination only while content is over it and only if it can take it. Remove the highlight as soon as the pointer leaves.
- **Move within a container, copy between containers.** Dropping in the same place, like reordering a list, moves the content. Dropping somewhere else copies it, and a drop into another app always copies.
- **Let people drag content to the Finder.** Give it a file format your app can open again, the way Calendar drags an event out as an .ics file.
- **Offer the richest version first.** List your type's representations from highest fidelity to lowest, so each destination takes the best one it understands.

## Pitfalls

- **Common types already work.** `String`, `URL`, and many other system types conform to `Transferable`, so you can drag them without extra code.
- **A drag offers a copy unless you allow a move.** Pass `DragConfiguration(allowMove: true)` to `.dragConfiguration(_:)`. People can then hold ⌘ to move, or ⌥ to copy.
- **This `.dropDestination` is new in macOS 26.** It replaces the version with an `isTargeted:` closure, which is deprecated.

## Guide

`.draggable` turns a view into something people can drag, and `.dropDestination` makes a view accept drops. Both work with `Transferable` types, so the same code handles drags inside a window, between your app's windows, and to and from other apps.

A type's transfer representations decide what it becomes: your own data when it lands in your app, and plain text or a file in apps that don't know your type.

### Usage

```swift
@State private var basket: [String] = []

Text("Sunflowers")
    .draggable("Sunflowers")

BasketView(items: basket)
    .dropDestination(for: String.self) { names, session in
        basket.append(contentsOf: names)
    }
```

## Key APIs

`.draggable(_:)`, `.draggable(_:preview:)`, `.dropDestination(for:)`, `.onDropSessionUpdated(_:)`, `Transferable`, `CodableRepresentation`, `ProxyRepresentation`, `.dragConfiguration(_:)`

## Variants

### Drag text onto a target

Make each chip `.draggable` and the box a `.dropDestination`, and highlight the box with `.onDropSessionUpdated` during a drag.

```swift
@State private var basket: [String] = []
@State private var isTargeted = false

HStack {
    ForEach(["Sunflowers", "Tulips", "Ferns"], id: \.self) { plant in
        Text(plant)
            .padding(8)
            .background(.tint.opacity(0.15), in: .capsule)
            .draggable(plant)
    }
}

Text(basket.isEmpty ? "Drop here" : basket.joined(separator: ", "))
    .frame(width: 300, height: 90)
    .background(isTargeted ? Color.accentColor.opacity(0.15) : .clear)
    .dropDestination(for: String.self) { plants, _ in
        basket.append(contentsOf: plants)
    }
    .onDropSessionUpdated { session in
        switch session.phase {
        case .entering, .active: isTargeted = true
        default: isTargeted = false
        }
    }
```

**Note:** Text from other apps works too: select a word in Notes or TextEdit and drag it into the box. Or open a second window above and drag between the two.

More variants, left out to keep this file short: Drag your own type, Accept files from the Finder. Apple's docs: https://developer.apple.com/documentation/swiftui/drag-and-drop.md

## Related

[copy-paste](copy-paste.md), [file-import-export](file-import-export.md), [share-link](share-link.md), [hover](hover.md), [list-styles](list-styles.md)
