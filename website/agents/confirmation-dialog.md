---
id: confirmation-dialog
title: Confirmation Dialog
platforms: [iOS, iPadOS]
availability: iOS 15.0+, macOS 12.0+, visionOS 1.0+
docs: https://developer.apple.com/documentation/swiftui/view/confirmationdialog(_:ispresented:titlevisibility:actions:message:).md
hig: https://developer.apple.com/design/human-interface-guidelines/action-sheets.md
---

# Confirmation Dialog

Asks people to pick from a few actions, or confirm a destructive one.

Also called: action sheet, ActionSheet, UIAlertController actionSheet, confirm, are you sure, choose an option, bottom menu.

## Default code

```swift
@State private var isPresented = false

Button("Discard Draft", role: .destructive) {
    isPresented = true
}
.confirmationDialog("Discard this draft?", isPresented: $isPresented, titleVisibility: .visible) {
    Button("Discard Draft", role: .destructive) {
        // Discard
    }
    Button("Save Draft") {}
}
```

**Important:** The title is hidden by default on iOS. Pass `titleVisibility: .visible` to show it and the message.

## Rules

- **Use a dialog, not an alert, for choices about an action.** When people close a draft, a dialog offers Delete or Save right where they tapped. An alert is for unexpected news.
- **Make the destructive choice red.** `role: .destructive` makes it stand out, so nobody deletes something by accident.
- **Keep the title to one line, and skip the message if you can.** The button people just tapped already explains most of the context.
- **Offer only a few actions.** A dialog that needs to scroll is slow to read. Use a [Menu](menu.md) or a sheet for long lists.

## Pitfalls

- **It replaces `ActionSheet`.** In iOS 26 it appears as a glass popover next to the button that opened it, instead of sliding up from the bottom.
- **You don't need a Cancel button.** Tapping outside dismisses it. If you add a `role: .cancel` button, the system decides where it goes.

## Key APIs

- `.confirmationDialog(_:isPresented:)`: Shows a list of actions while a `Bool` is `true`.
- `titleVisibility:`: `.visible` shows the title, hidden by default on iOS.
- `presenting:`: Passes a value, like the item to delete, to the actions.
- `message: { }`: A short line under the title.
- `Button(role: .destructive)`: Turns the action red.

## Variants

### Confirm deleting a specific item

Use `presenting:` to pass the item into the actions, so the button knows what to delete.

```swift
@State private var fileToDelete: String?
@State private var showDelete = false

Button("Delete Report.pdf", role: .destructive) {
    fileToDelete = "Report.pdf"
    showDelete = true
}
.confirmationDialog("Delete file?", isPresented: $showDelete, titleVisibility: .visible, presenting: fileToDelete) { file in
    Button("Delete \(file)", role: .destructive) {
        // Delete the file
    }
}
```

### Choose between actions

Leave the title hidden, and `.confirmationDialog` reads like a quick list of choices.

```swift
@State private var showOptions = false

Button("Add Photo", systemImage: "photo.badge.plus") {
    showOptions = true
}
.confirmationDialog("Add Photo", isPresented: $showOptions) {
    Button("Take Photo") {}
    Button("Choose from Library") {}
    Button("Browse Files") {}
}
```

## Related

[alert](alert.md), [menu](menu.md), [sheet](sheet.md), [context-menu](context-menu.md)
