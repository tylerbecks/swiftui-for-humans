---
id: feedback
title: Feedback
platforms: [iOS, iPadOS]
availability: iOS 17.0+
docs: https://developer.apple.com/documentation/swiftui/view/sensoryfeedback(_:trigger:).md
hig: https://developer.apple.com/design/human-interface-guidelines/feedback.md
reviewed: October 2026
---

# Feedback

Tell people what happened, with an interruption that matches how much it matters.

## Contents

- Rules
- Pitfalls
- Guide
- Key APIs
- Variants
- Related

## Rules

- **Match the interruption to the importance.** Status and minor problems belong in the screen, near what they describe. Save alerts for things people must act on.
- **Say what happened and what to do next.** A specific title and a way forward help people recover. “Error” or a code number helps no one.
- **Don't rely on color alone.** Add a symbol and a short message to the red, so the problem is clear to everyone.
- **Don't warn about what people expect.** Deleting an email is what someone asked for, so it needs no alert, especially if they can [undo](undo-redo.md). Warn only before loss that's unexpected and can't be undone.
- **Confirm only what matters.** People assume things worked. Confirm big moments, like a payment, and always tell people when something failed and why.
- **Use haptics for their meaning, alongside the visuals.** `.success` means success everywhere. A haptic backs up what's on screen; it's never the only signal. See [Haptics](haptics.md).

## Pitfalls

- **Toasts are up to you.** For a web-style toast or snackbar, show a small banner with `.safeAreaInset`, or put the status in the toolbar.
- **Feedback has to reach everyone.** Pair color with words or a symbol, so it still works with the sound off, eyes elsewhere, or VoiceOver on.

## Guide

Feedback tells people the status of something, whether an action worked, or that something needs their attention. The rule of thumb: the more it matters, the more it may interrupt. Most feedback should be quiet and sit right next to what it's about.

## Key APIs

`.sensoryFeedback(_:trigger:)`, `.alert(_:isPresented:)`, `.safeAreaInset(edge:)`, `ToolbarItem(placement: .status)`, `ContentUnavailableView`

## Variants

### Inline validation

Check a field when people leave it, and show the problem right under it with a symbol and words.

```swift
@State private var email = ""
@FocusState private var isEditing: Bool

var isValid: Bool {
    email.contains("@") && email.contains(".")
}

VStack(alignment: .leading, spacing: 6) {
    TextField("Email", text: $email)
        .keyboardType(.emailAddress)
        .textInputAutocapitalization(.never)
        .focused($isEditing)
        .padding(10)
        .background(.fill.tertiary, in: .rect(cornerRadius: 10))
    if !isEditing && !email.isEmpty && !isValid {
        Label("Enter a complete email address.", systemImage: "exclamationmark.circle")
            .font(.footnote)
            .foregroundStyle(.red)
    }
}
```

**Note:** Waiting until people leave the field avoids flagging an address they're still typing. See [Entering Data](entering-data.md).

### Success you can feel

Swap the button's label when a big task finishes, and add `.sensoryFeedback(.success, trigger:)` to back it up.

```swift
@State private var isPaid = false

Button {
    isPaid = true
} label: {
    Label(isPaid ? "Paid" : "Pay $24.00",
          systemImage: isPaid ? "checkmark.circle.fill" : "creditcard")
        .frame(maxWidth: .infinity)
}
.buttonStyle(.borderedProminent)
.tint(isPaid ? .green : .accentColor)
.disabled(isPaid)
.sensoryFeedback(.success, trigger: isPaid)
```

### Banner for a problem that doesn't block

Pin a short message with `.safeAreaInset(edge: .top)` and keep showing what you have.

```swift
@State private var isOffline = true

List(["Groceries", "Errands", "Work"], id: \.self) { list in
    Text(list)
}
.safeAreaInset(edge: .top) {
    if isOffline {
        Label("You're offline. Showing saved lists.", systemImage: "wifi.slash")
            .font(.subheadline)
            .padding(10)
            .frame(maxWidth: .infinity)
            .background(.yellow.opacity(0.25))
    }
}
```

### Alert for what can't wait

Use `.alert` when people must decide something now. Name the problem and give a specific way out.

```swift
@State private var saveFailed = false

Button("Save Draft") { saveFailed = true }
    .alert("Couldn't Save Draft", isPresented: $saveFailed) {
        Button("Cancel", role: .cancel) { }
        Button("Try Again") { }
    } message: {
        Text("The server didn't respond. Your text is still here.")
    }
```

**Note:** Button titles say what happens, like Try Again or Delete. Use “OK” only in alerts that just inform. See [Alert](alert.md).

More variants, left out to keep this file short: Status in the toolbar. Apple's docs: https://developer.apple.com/documentation/swiftui/view/sensoryfeedback(_:trigger:).md

## Related

[haptics](haptics.md), [alert](alert.md), [confirmation-dialog](confirmation-dialog.md), [text-field](text-field.md), [entering-data](entering-data.md), [undo-redo](undo-redo.md)
