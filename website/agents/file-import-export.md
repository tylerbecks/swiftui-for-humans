---
id: file-import-export
title: File import & export
platforms: [macOS]
availability: macOS 11.0+
docs: https://developer.apple.com/documentation/swiftui/view/fileimporter(ispresented:allowedcontenttypes:oncompletion:).md
hig: https://developer.apple.com/design/human-interface-guidelines/file-management.md
---

# File import & export

Show the Mac's open and save panels, and read or write the files people pick.

Also called: open panel, save panel, NSOpenPanel, NSSavePanel, file picker, <input type=file>, download, save as, export, import.

## Contents

- Rules
- Pitfalls
- Key APIs
- Variants
- Related

## Rules

- **Use the system's open and save panels.** People know how to browse files from the Finder and other apps. Build your own file browser only for a strong reason.
- **Offer Open and New in the File menu.** People expect File > New and File > Open… with ⌘N and ⌘O, even when your window has buttons for them.
- **Name the main button for the task.** If the panel inserts a file rather than opening it, call the button Insert. `.fileDialogConfirmationLabel` sets it.
- **Save work automatically.** Don't make people choose Save to keep their work. Save as they go, and when they close the window or switch apps.

## Pitfalls

- **Canceling calls nothing.** If people cancel, SwiftUI sets the binding back to `false` and skips `onCompletion`. The file exporter calls `onCancellation` instead.
- **This app does it for real.** It has the user-selected read-write entitlement, so the examples below can read and write what you pick.

**Important:** Apple's docs ask you to pair every start call with a stop call. `defer` makes sure the stop call runs, even when reading fails.

## Key APIs

- `.fileImporter(isPresented:…)`: The open panel.
- `.fileExporter(isPresented:item:)`: The save panel, for a `Transferable` item.
- `.fileMover(isPresented:file:)`: A panel that moves a file somewhere else.
- `startAccessingSecurityScopedResource()`: Opens access to a URL from a panel.
- `.fileDialogConfirmationLabel(_:)`: Renames the panel's main button.
- `.fileDialogMessage(_:)`: A message in the panel, like a title.
- `.fileDialogDefaultDirectory(_:)`: The folder the panel opens in.

## Variants

### Usage

```swift
@State private var isImporting = false
@State private var text = ""

Button("Open…") { isImporting = true }
    .fileImporter(isPresented: $isImporting,
                  allowedContentTypes: [.plainText]) { result in
        guard case .success(let url) = result else { return }
        let didAccess = url.startAccessingSecurityScopedResource()
        defer {
            if didAccess { url.stopAccessingSecurityScopedResource() }
        }
        text = (try? String(contentsOf: url, encoding: .utf8)) ?? ""
    }
```

### Pick several files

Pass `allowsMultipleSelection: true` to get an array of URLs, and set a message and button title that fit the task.

```swift
@State private var isImporting = false
@State private var picked: [String] = []

Button("Add Photos…") { isImporting = true }
    .fileImporter(isPresented: $isImporting,
                  allowedContentTypes: [.image],
                  allowsMultipleSelection: true) { result in
        guard case .success(let urls) = result else { return }
        picked = urls.map(\.lastPathComponent)
    }
    .fileDialogMessage("Choose photos for the garden journal.")
    .fileDialogConfirmationLabel("Add")
```

### Save text to a file

`.fileExporter(isPresented:item:)` saves any `Transferable` value, like this `String`.

```swift
@State private var note = "Plant the tulip bulbs before the first frost."
@State private var isExporting = false

Button("Export…") { isExporting = true }
    .fileExporter(isPresented: $isExporting,
                  item: note,
                  contentTypes: [.plainText],
                  defaultFilename: "Garden Note") { result in
        if case .failure(let error) = result {
            print(error.localizedDescription)
        }
    }
```

### Move a file

`.fileMover` asks where to move a file you already have, like a draft from your app's own folder.

```swift
@State private var draft: URL?
@State private var isMoving = false

Button("Move Draft…") { isMoving = true }
    .fileMover(isPresented: $isMoving, file: draft) { result in
        if case .success(let newURL) = result {
            draft = newURL
        }
    }
```

**Note:** The panel only appears when `file` isn't `nil`. Here the sample file starts in this app's temporary folder.

## Related

[app-sandbox](app-sandbox.md), [drag-drop](drag-drop.md), [share-link](share-link.md), [document-group](document-group.md), [document-editor](document-editor.md)
