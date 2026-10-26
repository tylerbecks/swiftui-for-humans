---
id: focus-state
title: Keyboard & Focus
platforms: [iOS, iPadOS]
availability: iOS 15.0+, macOS 12.0+, visionOS 1.0+
docs: https://developer.apple.com/documentation/swiftui/focusstate.md
hig: https://developer.apple.com/design/human-interface-guidelines/virtual-keyboards.md
---

# Keyboard & Focus

Choose which field is active, move between fields on Return, pick the right keyboard, and dismiss it.

Also called: focus(), blur(), autofocus, dismiss keyboard, hide keyboard, becomeFirstResponder, resignFirstResponder, enterkeyhint, inputmode, onSubmit.

## Contents

- Rules
- Pitfalls
- Guide
- Key APIs
- Variants
- Related

## Rules

- **Match the keyboard to the content.** An email keyboard puts @ up front and a number pad shows only digits. Add `.textContentType` too, so iOS can offer AutoFill.
- **Name the Return key for what it does.** “Next” moves to the next field, “Search” runs a search, and “Done” finishes. People know what happens before they tap.
- **Move focus in reading order.** Return should go from one field to the one below it, top to bottom, and dismiss the keyboard after the last one.
- **Always give people a way to hide the keyboard.** It covers half the screen. Add a Done button, scroll-to-dismiss, or a Return key that ends editing.

## Pitfalls

- **Set focus once the field is on screen.** Setting it in `init` does nothing. Set it in `.onAppear` or `.task` to focus a field when a screen opens.
- **In the Simulator, press ⌘K to show the keyboard.** With a hardware keyboard connected, the software one stays hidden.

## Guide

On the web you call `input.focus()` and `input.blur()`. In SwiftUI, **focus is state**: declare a `@FocusState` property, attach it to fields with `.focused(_:equals:)`, and read or set it like any other value.

### Focus is state

Use a `Bool` for one field, or an optional enum for several. Tap a field or pick one below: the readout shows `focusedField`, and Return moves to the next field. `nil` means nothing is focused, so the keyboard hides.

```swift
enum Field { case name, email, city }

@State private var name = ""
@State private var email = ""
@State private var city = ""
@FocusState private var focusedField: Field?

VStack {
    TextField("Name", text: $name)
        .focused($focusedField, equals: .name)
        .submitLabel(.next)
    TextField("Email", text: $email)
        .focused($focusedField, equals: .email)
        .submitLabel(.next)
    TextField("City", text: $city)
        .focused($focusedField, equals: .city)
        .submitLabel(.done)

    Button("Dismiss Keyboard") {
        focusedField = nil
    }
}
.textFieldStyle(.roundedBorder)
.onSubmit {
    // Return moves to the next field, then dismisses.
    switch focusedField {
    case .name: focusedField = .email
    case .email: focusedField = .city
    default: focusedField = nil
    }
}
```

**Note:** `.onSubmit` on the container runs for every field inside it, so one `switch` can move focus through the whole form.

### Pick the right keyboard

`.keyboardType` chooses the layout, `.submitLabel` names the Return key, and `.textContentType` lets iOS offer AutoFill. Change them, then tap the field.

```swift
@State private var text = ""

TextField("Email", text: $text)
    .keyboardType(.emailAddress)
    .textContentType(.emailAddress)
    .textInputAutocapitalization(.never)
    .autocorrectionDisabled()
    .submitLabel(.go)
    .onSubmit {
        // Runs when Return is tapped
    }
```

**Important:** `.submitLabel` only changes the key's title, and `.keyboardType` is only a hint: people can still paste anything. Do the work in `.onSubmit`, and validate the text.

### Dismissing the keyboard

iOS doesn't hide the keyboard when people tap elsewhere. Give them at least one of these ways out.

**Important:** Old Stack Overflow answers hide the keyboard with a UIKit `sendAction` trick. You don't need it: set your `@FocusState` to `nil` or `false`.

## Key APIs

`@FocusState`, `.focused(_:equals:)`, `.focused(_:)`, `.onSubmit { }`, `.submitLabel(_:)`, `.keyboardType(_:)`, `.scrollDismissesKeyboard(_:)`, `ToolbarItemGroup(placement: .keyboard)`

## Variants

### Done button above the keyboard

Put a button in the `.keyboard` toolbar placement that clears focus. Tap the field, then tap **Done**.

```swift
@State private var note = ""
@FocusState private var isFocused: Bool

TextField("Add a note", text: $note)
    .textFieldStyle(.roundedBorder)
    .focused($isFocused)
    .toolbar {
        ToolbarItemGroup(placement: .keyboard) {
            Spacer()
            Button("Done") {
                isFocused = false
            }
        }
    }
```

### Dismiss by scrolling

Add `.scrollDismissesKeyboard(.interactively)` so people can drag the keyboard down, like in Messages.

```swift
@State private var items = ["Milk", "Eggs", "Coffee"]
@State private var newItem = ""

List {
    TextField("New item", text: $newItem)
        .onSubmit {
            items.append(newItem)
            newItem = ""
        }
    ForEach(items, id: \.self) { Text($0) }
}
.scrollDismissesKeyboard(.interactively)
```

## Related

[text-field](text-field.md), [secure-field](secure-field.md), [form](form.md), [login-form](login-form.md)
