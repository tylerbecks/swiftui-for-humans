---
id: share-link
title: ShareLink
platforms: [iOS, iPadOS, macOS]
availability: iOS 16.0+, macOS 13.0+, visionOS 1.0+
docs: https://developer.apple.com/documentation/swiftui/sharelink.md
hig: https://developer.apple.com/design/human-interface-guidelines/activity-views.md
---

# ShareLink

A button that opens the share sheet to send a link, text, or image.

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
let article = URL(string: "https://www.swift.org")!

ShareLink(item: article)

ShareLink(item: article) {
    Label("Share Article", systemImage: "square.and.arrow.up")
}
```

**Important:** Only `URL` and `String` items work without a preview. For an `Image` or your own type, also pass a `preview:` made with `SharePreview`.

## Rules

- **Use the standard Share symbol.** People look for `square.and.arrow.up` when they want to send something. A different icon makes them hunt for it.
- **Don't rebuild actions the share sheet already has.** Copy, Print, AirDrop, and Save to Files are built in. Your own versions would sit next to them and confuse people.
- **Give shared items a clear preview.** A `SharePreview` with a title and image shows people what they're about to send at the top of the sheet.

## Pitfalls

- **You can share anything `Transferable`.** `URL`, `String`, `Image`, and `Data` work out of the box; make your own types conform to share them too.

## Key APIs

`ShareLink(item:)`, `ShareLink(item:preview:)`, `SharePreview(_:image:)`, `subject:` / `message:`, `ShareLink(items:)`, `label:`

## Variants

### Share button in a toolbar

Put a `ShareLink` in `.toolbar` on a detail screen, where people look for sharing first.

```swift
NavigationStack {
    Text("Article")
        .navigationTitle("Article")
        .toolbar {
            ShareLink(item: URL(string: "https://www.swift.org")!)
        }
}
```

**Note:** In a toolbar, `ShareLink` shows only its icon. It's the same button people see in Safari and Photos.

### Share an image

Pass an `Image` as `item:` with a `SharePreview` that names it and shows a thumbnail in the sheet.

```swift
let photo = Image(systemName: "mountain.2.fill")

VStack {
    photo
        .font(.system(size: 60))
        .foregroundStyle(.teal)
    ShareLink(
        item: photo,
        preview: SharePreview("Mountains", image: photo)
    ) {
        Label("Share Photo", systemImage: "photo")
    }
    .buttonStyle(.bordered)
}
```

## On macOS

A Share button that sends a link, text, or your own data to other apps.

### Default code

```swift
ShareLink(item: URL(string: "https://developer.apple.com/xcode/swiftui/")!)
```

**Note:** `ShareLink` makes the button and shows the system's sharing services when people click it. You only supply what to share.

### Rules

- **Use the standard Share button.** People know its symbol and what it does. `ShareLink` gives you that button, so don't build another way to reach the same services.
- **Put Share where Mac users look for it.** On the Mac, people find sharing in a window's toolbar and in the context menu of the item they want to share.
- **Share the richest data you have.** List your type's representations from most to least specific. Each service picks the best one it understands.

### Pitfalls

- **Some services want a file.** Mail, Messages, AirDrop, and Notes may not appear for every data type. If one is missing, add a `FileRepresentation` to your type.
- **A preview skips the wait.** For a URL, the system fetches the page's title and icon over the network. A `SharePreview` you supply shows right away.

### Key APIs

`ShareLink(_:item:)`, `subject:`, `message:`, `Transferable`

### Variants

#### In the toolbar

Put a `ShareLink` in the toolbar for whatever the window shows, icon-only with a `.help` tooltip.

```swift
.toolbar {
    ShareLink(item: photo, preview: SharePreview("Sunset", image: photo))
        .help("Share this photo")
}
```

**Note:** A real `.toolbar` here would land in this window's own toolbar, so the preview draws one. The Share button is real.

#### In a context menu

A `ShareLink` works as a context menu item too, so people can share the item they Control-click.

```swift
NoteCard(note)
    .contextMenu {
        Button("Duplicate") { duplicate(note) }
        ShareLink(item: note.text)
    }
```

#### Share your own type

Make your type `Transferable`, like this tip, which shares as plain text with a title in the preview.

```swift
struct GardenTip: Transferable {
    let title: String
    let body: String

    static var transferRepresentation: some TransferRepresentation {
        ProxyRepresentation { tip in "\(tip.title)\n\n\(tip.body)" }
    }
}

ShareLink(item: tip, preview: SharePreview(tip.title, image: Image(systemName: "leaf")))
```

More variants, left out to keep this file short: Share several items. Apple's docs: https://developer.apple.com/documentation/swiftui/sharelink.md

## Related

[link](link.md), [button](button.md), [toolbar](toolbar.md), [image](image.md), [drag-drop](drag-drop.md), [copy-paste](copy-paste.md), [file-import-export](file-import-export.md), [context-menu](context-menu.md)
