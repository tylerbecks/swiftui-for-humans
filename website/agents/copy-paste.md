---
id: copy-paste
title: Copy & paste
platforms: [macOS]
availability: macOS 13.0+
docs: https://developer.apple.com/documentation/swiftui/clipboard.md
hig: https://developer.apple.com/design/human-interface-guidelines/edit-menus.md
---

# Copy & paste

Connect the Edit menu's Cut, Copy, Paste, and Delete to your own views.

Also called: clipboard, pasteboard, NSPasteboard, copyable, cuttable, pasteDestination, onCopyCommand, onPasteCommand, onCutCommand, onDeleteCommand.

## Contents

- Use when
- Rules
- Pitfalls
- Guide
- Key APIs
- Variants
- Related

## Use when

- Every Mac app has an Edit menu with Cut, Copy, Paste, Delete, and Select All, and text fields support them without any code.
- For your own views, `.copyable`, `.cuttable`, and `.pasteDestination` connect those menu items and their shortcuts to your data.
- They use `Transferable`, like drag and drop, so what people copy from your app pastes into other apps, and the other way around.

## Rules

- **Let the Edit menu do the work.** People expect Copy and Paste in the Edit menu and on ⌘C and ⌘V. Extra buttons for the same commands crowd the window.
- **Let people copy text they can't edit.** Content like a caption or an address is often worth pasting somewhere else. Make that text selectable, but not the labels of controls.
- **Call it Delete, not Erase or Clear.** Edit > Delete does what the Delete key does. Unlike Cut, it doesn't put anything on the Clipboard.
- **Support undo.** Menu commands act without asking first. Undo lets people recover from a paste or delete they didn't mean.

## Pitfalls

- **The commands follow focus.** Edit > Copy turns on when the focused view has something to copy, so people click the list first, then press ⌘C.
- **Prefer `Transferable` to item providers.** `.onCopyCommand` and `.onPasteCommand` work with `NSItemProvider`. Apple recommends the `Transferable` modifiers when you can use them.

## Guide

Every Mac app has an Edit menu with Cut, Copy, Paste, Delete, and Select All, and text fields support them without any code. For your own views, `.copyable`, `.cuttable`, and `.pasteDestination` connect those menu items and their shortcuts to your data.

They use `Transferable`, like drag and drop, so what people copy from your app pastes into other apps, and the other way around.

### Usage

```swift
@State private var plants = ["Sunflowers", "Tulips", "Ferns"]
@State private var selection = Set<String>()

List(plants, id: \.self, selection: $selection) { plant in
    Text(plant)
}
.copyable(plants.filter { selection.contains($0) })
.pasteDestination(for: String.self) { pasted in
    plants.append(contentsOf: pasted)
}
```

## Key APIs

- `.copyable(_:)`: The items Edit > Copy puts on the Clipboard.
- `.cuttable(for:action:)`: Removes items and returns them for Cut.
- `.pasteDestination(for:action:)`: Accepts items from Edit > Paste.
- `.onDeleteCommand(perform:)`: Edit > Delete and the Delete key.
- `PasteButton(payloadType:)`: A Paste button for the Clipboard.
- `.textSelection(.enabled)`: Lets people select and copy a `Text`.

## Variants

### Cut, copy, and paste list rows

Give a selectable `List` all three modifiers, and let the `.pasteDestination` validator drop unwanted items, like empty lines.

```swift
@State private var plants = ["Sunflowers", "Tulips", "Ferns", "Basil"]
@State private var selection = Set<String>()

List(plants, id: \.self, selection: $selection) { plant in
    Text(plant)
}
.copyable(plants.filter { selection.contains($0) })
.cuttable(for: String.self) {
    let cut = plants.filter { selection.contains($0) }
    plants.removeAll { selection.contains($0) }
    return cut
}
.pasteDestination(for: String.self) { pasted in
    plants.append(contentsOf: pasted)
} validator: { pasted in
    pasted
        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        .filter { !$0.isEmpty }
}
```

**Note:** Click the list, select a row, and press ⌘C. Paste it into Notes, or copy a word from another app and press ⌘V here.

### The Delete key and Edit > Delete

`.onDeleteCommand` runs when people choose Edit > Delete or press Delete while the view has focus.

```swift
@State private var tags = ["garden", "summer", "seeds", "watering"]
@State private var selection = Set<String>()

List(tags, id: \.self, selection: $selection) { tag in
    Text(tag)
}
.onDeleteCommand {
    tags.removeAll { selection.contains($0) }
}
```

### A Paste button

`PasteButton` reads the Clipboard when clicked and hands you the values of the type you ask for.

```swift
@State private var pasted = ""

PasteButton(payloadType: String.self) { strings in
    pasted = strings.joined(separator: " ")
}
```

**Note:** Add one only where a visible button helps; people look for Edit > Paste and ⌘V first. For a Copy item of your own, like in a context menu, write to `NSPasteboard.general`, since SwiftUI's modifiers only answer the system's Copy command.

### Selectable text

`.textSelection(.enabled)` lets people select a `Text` and copy it with ⌘C or the Edit menu.

```swift
VStack(alignment: .leading) {
    Text("Order number")
        .foregroundStyle(.secondary)
    Text("W-48213-7")
        .font(.title2.monospaced())
        .textSelection(.enabled)
}
```

## Related

[drag-drop](drag-drop.md), [commands](commands.md), [keyboard-shortcuts](keyboard-shortcuts.md), [undo-redo](undo-redo.md), [text-label](text-label.md)
