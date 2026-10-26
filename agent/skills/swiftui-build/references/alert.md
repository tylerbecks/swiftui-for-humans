---
id: alert
title: Alert
platforms: [iOS, iPadOS, macOS]
availability: iOS 15.0+, macOS 12.0+, visionOS 1.0+
docs: https://developer.apple.com/documentation/swiftui/view/alert(_:ispresented:actions:message:).md
hig: https://developer.apple.com/design/human-interface-guidelines/alerts.md
---

# Alert

Interrupts with an important message and asks for a quick decision.

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
@State private var isPresented = false

Button("Delete Photo", role: .destructive) {
    isPresented = true
}
.alert("Delete Photo?", isPresented: $isPresented) {
    Button("Cancel", role: .cancel) {}
    Button("Delete", role: .destructive) {
        // Delete the photo
    }
} message: {
    Text("This photo will be deleted from all your devices.")
}
```

**Note:** Roles place the buttons for you: `.cancel` goes in the cancel spot and `.destructive` turns red. You don't order them by hand.

## Rules

- **Name the action on the button.** “Delete” says exactly what will happen. “Yes” or “OK” makes people reread the title to find out.
- **Write a title that says what happened.** “Upload Failed” tells people the problem. “Error” or an error code doesn't help them fix it.
- **Use alerts sparingly.** Each one interrupts. Skip them for actions people can undo, like deleting an email, and for information that isn't actionable.
- **Don't show an alert at launch.** People opened the app to do something. Show problems like a lost connection inline instead.

## Pitfalls

- **Any button closes the alert.** It sets the binding back to `false` for you. With no buttons at all, SwiftUI adds an OK button.
- **Pick the right interruption.** Use an alert for something people must see now, a [Confirmation Dialog](confirmation-dialog.md) for a choice of actions, and inline text for anything that can wait.

## Key APIs

`.alert(_:isPresented:actions:message:)`, `.alert(_:isPresented:presenting:)`, `.alert(isPresented:error:)`, `Button(role: .cancel)`, `Button(role: .destructive)`, `TextField` in the actions

## Variants

### Confirm for a specific item

Use `presenting:` to hand the tapped item to the alert's buttons and message.

```swift
@State private var photoToDelete: String?
@State private var showDelete = false

HStack {
    ForEach(["Beach", "Forest"], id: \.self) { photo in
        Button("Delete \(photo)") {
            photoToDelete = photo
            showDelete = true
        }
    }
}
.alert("Delete Photo?", isPresented: $showDelete, presenting: photoToDelete) { photo in
    Button("Delete", role: .destructive) {
        // Delete photo
    }
} message: { photo in
    Text("“\(photo)” will be deleted from all your devices.")
}
```

**Note:** With only a destructive button, the alert adds Cancel for you.

## On macOS

Stop to confirm a risky action or report a problem that needs a decision.

### Default code

```swift
@State private var isConfirming = false

Button("Revert…") { isConfirming = true }
    .alert("Revert to the last saved version?", isPresented: $isConfirming) {
        Button("Cancel", role: .cancel) { }
        Button("Revert") { revert() }
    } message: {
        Text("Changes since you last saved will be lost.")
    }
```

**Note:** Give Cancel the `.cancel` role instead of ordering buttons by hand. SwiftUI may reorder buttons by their role and prominence.

### Rules

- **Mark a button destructive only when people didn't choose that action.** If someone chose Empty Trash, the dialog's Empty Trash button does what they asked, so Return should run it. Use `.destructive` for a side effect they might not expect.
- **Save the caution symbol for real danger.** `.dialogSeverity(.critical)` adds it. Used often, it stops meaning anything, so keep it for unexpected data loss, not routine saving or deleting.

### Pitfalls

- **Every button closes the dialog.** SwiftUI sets the binding back to `false` after the button's action runs.
- **A confirmation dialog comes with a way out.** It adds a standard dismiss button; a button with the `.cancel` role takes its place.
- **The Mac puts your app icon in the dialog.** Use `.dialogIcon(_:)` to show a different image.

### Key APIs

`.confirmationDialog(_:isPresented:)`, `.dialogSeverity(.critical)`, `.dialogSuppressionToggle(isSuppressed:)`, `.dialogIcon(_:)`

### Variants

#### Report a problem

`.alert(_:isPresented:presenting:)` builds the alert from a value, like the error you caught, and passes it to the buttons and message.

```swift
@State private var failure: SaveFailure?
@State private var isShowingFailure = false

Button("Save") {
    failure = SaveFailure(documentName: "Trip Notes")
    isShowingFailure = true
}
.alert("Couldn't Save Your Changes", isPresented: $isShowingFailure, presenting: failure) { _ in
    Button("OK") { }
} message: { failure in
    Text("“\(failure.documentName)” is on a disk that's full. Free up space and try again.")
}
```

**Note:** OK fits here: the alert reports a problem and offers no choice, so its one button only acknowledges it.

More variants, left out to keep this file short: Show an error, Rename prompt, Let people stop the question (macOS). Apple's docs: https://developer.apple.com/documentation/swiftui/view/alert(_:ispresented:actions:message:).md

## Related

[confirmation-dialog](confirmation-dialog.md), [sheet](sheet.md), [button](button.md), [popover](popover.md), [keyboard-shortcuts](keyboard-shortcuts.md)
