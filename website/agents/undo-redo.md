---
id: undo-redo
title: Undo and Redo
platforms: [iOS, iPadOS, macOS]
availability: iOS 13.0+, macOS 10.15+
docs: https://developer.apple.com/documentation/swiftui/environmentvalues/undomanager.md
hig: https://developer.apple.com/design/human-interface-guidelines/undo-and-redo.md
reviewed: October 2026
---

# Undo and Redo

Let people take back what they did, instead of asking “Are you sure?” first.

## Rules

- **Offer undo instead of asking first.** For everyday deletes, just do it and let people undo. A confirmation every time slows people down, and they soon tap through it without reading.
- **Say what will be undone.** On iPhone, shaking shows an alert titled “Undo” plus your action name. One or two words, like “Delete Bread”, tell people exactly what comes back.
- **Show what changed.** If the undone change is off screen, scroll to it or highlight it. Otherwise people think nothing happened and undo again.
- **Let people undo many times.** Don't cap the history without a reason. People expect to step back through everything since they opened or saved their work.
- **Keep the system gestures, and add buttons only if needed.** Don't reuse shake or the three-finger swipe for anything else. If you add Undo and Redo buttons, put them in the toolbar with the standard symbols.

## Pitfalls

- **Register undo for your own changes.** Deleting or moving rows can't be undone unless you register it. Text fields manage typing themselves, so try shake to undo in yours to confirm it behaves as you expect.
- **`undoManager` can be `nil`.** It is where undo isn't supported, so call it with `?.` and skip registering.
- **Still confirm what can't be undone.** For a rare, permanent action, like deleting an account, a [confirmation dialog](confirmation-dialog.md) is still the right call.

## Guide

Undo lets people try things without fear. People shake their iPhone, swipe with three fingers, or press ⌘Z on an iPad keyboard. SwiftUI hands you the window's `UndoManager`, and you tell it how to reverse each change.

Delete a few items, then tap **Undo** and **Redo**. The button shows the name you set with `setActionName`.

```swift
@MainActor @Observable
final class Groceries {
    var items = ["Apples", "Bread", "Coffee", "Eggs"]

    func remove(_ item: String, undoManager: UndoManager?) {
        guard let index = items.firstIndex(of: item) else { return }
        items.remove(at: index)
        undoManager?.registerUndo(withTarget: self) { list in
            list.insert(item, at: index, undoManager: undoManager)
        }
        undoManager?.setActionName("Delete \(item)")
    }

    func insert(_ item: String, at index: Int, undoManager: UndoManager?) {
        items.insert(item, at: index)
        // Registering here is what makes Redo work.
        undoManager?.registerUndo(withTarget: self) { list in
            list.remove(item, undoManager: undoManager)
        }
        undoManager?.setActionName("Delete \(item)")
    }
}

struct GroceryList: View {
    @State private var groceries = Groceries()
    @Environment(\.undoManager) private var undoManager

    var body: some View {
        List {
            ForEach(groceries.items, id: \.self) { item in
                Text(item)
            }
            .onDelete { offsets in
                for item in offsets.map({ groceries.items[$0] }) {
                    groceries.remove(item, undoManager: undoManager)
                }
            }
        }
    }
}
```

**Important:** `registerUndo` needs a class to call back, so keep the data in an `@Observable` class, not in `@State` structs. Register the reverse step inside the undo handler, too, or Redo stays grayed out.

## Key APIs

`@Environment(\.undoManager)`, `registerUndo(withTarget:handler:)`, `setActionName(_:)`, `undo()` and `redo()`, `canUndo` and `canRedo`, `beginUndoGrouping()`, `removeAllActions(withTarget:)`

The On macOS section was left out to keep this file short. Apple's docs: https://developer.apple.com/documentation/swiftui/environmentvalues/undomanager.md

## Related

[confirmation-dialog](confirmation-dialog.md), [alert](alert.md), [list](list.md), [swipe-actions](swipe-actions.md), [toolbar](toolbar.md), [feedback](feedback.md), [menu-bar-conventions](menu-bar-conventions.md), [keyboard-shortcuts](keyboard-shortcuts.md), [commands](commands.md), [document-editor](document-editor.md)
