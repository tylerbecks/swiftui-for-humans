---
id: async-image
title: AsyncImage
platforms: [iOS, iPadOS, macOS]
availability: iOS 15.0+, macOS 12.0+, visionOS 1.0+
docs: https://developer.apple.com/documentation/swiftui/asyncimage.md
hig: https://developer.apple.com/design/human-interface-guidelines/image-views.md
---

# AsyncImage

Downloads and shows an image from a URL, with a placeholder while it loads.

## Contents

- Default code
- Rules
- Pitfalls
- Key APIs
- Variants
- On macOS
- Related

## Default code

```swift
let url = URL(string: "https://example.com/photo.jpg")

AsyncImage(url: url) { image in
    image
        .resizable()
        .scaledToFill()
} placeholder: {
    ProgressView()
}
.frame(width: 200, height: 200)
.clipShape(.rect(cornerRadius: 12))
```

**Important:** `.resizable()` and `.scaledToFill()` belong to `Image`, so they go on the `image` inside the closure, not on `AsyncImage`.

## Rules

- **Reserve the image's space before it loads.** A placeholder at the final size keeps text from jumping when the photo arrives, so people don't lose their place.
- **Show a clear failure state.** An empty box looks like the app is still loading. Say the image couldn't load, and offer a way to try again.
- **Keep text over remote images readable.** You don't know what the photo will look like. Put a gradient or material behind any text on top of it.

## Pitfalls

- **Use the `phase` version to handle errors.** It hands you `.empty` while loading, `.success(image)`, and `.failure(error)`, so you can show a real error state.
- **Fade images in instead of popping.** Pass `transaction: Transaction(animation: .easeInOut)` and the image animates in when it arrives.

## Key APIs

`AsyncImage(url:)`, `AsyncImage(url:content:placeholder:)`, `AsyncImage(url:transaction:content:)`, `AsyncImagePhase`, `.frame(width:height:)`, `.id(_:)`

## Variants

### Avatar

Give `AsyncImage` a fixed `.frame` and a person symbol as the placeholder, then clip it to a circle.

```swift
AsyncImage(url: URL(string: "https://picsum.photos/seed/avatar/200")) { image in
    image
        .resizable()
        .scaledToFill()
} placeholder: {
    Image(systemName: "person.fill")
        .font(.title)
        .foregroundStyle(.secondary)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.fill.tertiary)
}
.frame(width: 72, height: 72)
.clipShape(.circle)
```

### Photo grid

Make square cells in a `LazyVGrid` with `Color.clear` and `.aspectRatio(1)`, then fill each with an image.

```swift
let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 3)

LazyVGrid(columns: columns, spacing: 4) {
    ForEach(1...6, id: \.self) { index in
        Color.clear
            .aspectRatio(1, contentMode: .fit)
            .overlay {
                AsyncImage(url: URL(string: "https://picsum.photos/seed/grid\(index)/300")) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Rectangle().fill(.fill.tertiary)
                }
            }
            .clipped()
    }
}
.clipShape(.rect(cornerRadius: 12))
```

**Important:** `AsyncImage` doesn't cache images itself. Cells that scroll away and back may download again, so large grids often use a caching library.

## On macOS

### Rules

- **Keep text over images readable.** You can't predict what a downloaded photo looks like. Put a scrim or material behind text that sits on it.
- **Make a clickable image a button.** On the Mac, show an image people click inside a `Button`, rather than as a plain image with a gesture.
- **Use a symbol for an icon.** SF Symbols are vector images you can tint with the accent color, so they suit interface icons better than downloaded pictures.

### Pitfalls

- **A sandboxed app needs the network entitlement.** Turn on Outgoing Connections (Client), `com.apple.security.network.client`, under App Sandbox, or every image fails to load.
- **In macOS 27 and later, `AsyncImage` caches downloads.** To change the cache policy, pass a `URLRequest` with `AsyncImage(request:)`.

### Variants

#### Avatar in a row

Give `AsyncImage` a fixed `.frame` and a person symbol as the placeholder, then clip it to a circle.

```swift
HStack(spacing: 10) {
    AsyncImage(url: URL(string: "https://picsum.photos/seed/avatar/200")) { image in
        image
            .resizable()
            .scaledToFill()
    } placeholder: {
        Image(systemName: "person.fill")
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.fill.tertiary)
    }
    .frame(width: 40, height: 40)
    .clipShape(.circle)
    VStack(alignment: .leading) {
        Text("Jordan Lee")
            .font(.headline)
        Text("Photographer")
            .foregroundStyle(.secondary)
    }
}
```

#### Photo grid

Make square cells in a `LazyVGrid` with `Color.clear` and `.aspectRatio(1)`, then fill each with an image.

```swift
let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 4)

LazyVGrid(columns: columns, spacing: 4) {
    ForEach(1...8, id: \.self) { index in
        Color.clear
            .aspectRatio(1, contentMode: .fit)
            .overlay {
                AsyncImage(url: URL(string: "https://picsum.photos/seed/grid\(index)/300")) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Rectangle().fill(.fill.tertiary)
                }
            }
            .clipped()
    }
}
.clipShape(.rect(cornerRadius: 10))
.frame(maxWidth: 420)
```

More variants, left out to keep this file short: Failure with retry, Failure with retry (macOS). Apple's docs: https://developer.apple.com/documentation/swiftui/asyncimage.md

## Related

[image](image.md), [progress-view](progress-view.md), [lazy-grids](lazy-grids.md), [list](list.md), [image-symbols](image-symbols.md), [app-sandbox](app-sandbox.md), [privacy-permissions](privacy-permissions.md), [stacks-grid](stacks-grid.md)
