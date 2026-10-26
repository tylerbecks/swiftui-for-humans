---
id: entering-data
title: Entering Data
platforms: [iOS, iPadOS]
availability: iOS 15.0+
docs: https://developer.apple.com/documentation/swiftui/view/keyboardtype(_:).md
hig: https://developer.apple.com/design/human-interface-guidelines/entering-data.md
reviewed: October 2026
---

# Entering Data

Ask for less, show the right keyboard, and catch mistakes while people type.

## Contents

- Rules
- Pitfalls
- Guide
- Key APIs
- Variants
- Related

## Rules

- **Offer choices instead of typing.** Picking from a short list is faster and can't be misspelled. Use a [Picker](picker.md) or [DatePicker](date-picker.md) when the answers are known.
- **Make clear what goes in each field.** Give each field a label and a sample value in the prompt, like `name@example.com`, so people know the format.
- **Check values as soon as people enter them.** Point out a problem next to the field right away, not in a list after they tap Submit. Keep Continue disabled until the required fields are filled in.
- **Get it from the system when you can.** Don't ask for what iOS already knows. Content types let people AutoFill names, addresses, passwords, and one-time codes.
- **Hide secrets, and never prefill a password.** Use a [SecureField](secure-field.md) for passwords, and let people type it or use AutoFill, Face ID, or a passkey.

## Pitfalls

- **`.keyboardType` is HTML's `inputmode`, and `.textContentType` is `autocomplete`.** The first picks the keys; the second tells iOS what the field is, so it can offer AutoFill.
- **Validate the value, not the keys.** A keyboard type only picks which keys show first. People can still paste anything, so check what arrives.

## Guide

Typing on a phone is slow and easy to get wrong. Ask only for what you can't get another way, offer choices instead of blank fields, and tell iOS what each field is for. It then shows the right keyboard and can fill the value in for people.

## Key APIs

`.keyboardType(.emailAddress)`, `.textContentType(_:)`, `.textInputAutocapitalization`, `.autocorrectionDisabled()`, `.submitLabel(.next)`, `.onSubmit { }`, `TextField(_:value:format:)`

## Variants

### The right keyboard for each field

Pair `.keyboardType` with `.textContentType` so people get the right keys and AutoFill. Tap a field to see its keyboard.

```swift
@State private var email = ""
@State private var phone = ""
@State private var code = ""

Form {
    TextField("Email", text: $email)
        .keyboardType(.emailAddress)
        .textContentType(.emailAddress)
        .textInputAutocapitalization(.never)
        .autocorrectionDisabled()
    TextField("Phone", text: $phone)
        .keyboardType(.phonePad)
        .textContentType(.telephoneNumber)
    TextField("Code", text: $code)
        .keyboardType(.numberPad)
        .textContentType(.oneTimeCode)
}
```

**Important:** Turn off capitalization and autocorrect for emails, usernames, and codes. Otherwise iOS “fixes” them as people type.

### Choose instead of type

Use a `DatePicker` or `Picker` when the answers are known. There's nothing to misspell.

```swift
@State private var date = Date.now
@State private var guests = 2

Form {
    DatePicker("Date", selection: $date, displayedComponents: .date)
    Picker("Guests", selection: $guests) {
        ForEach(1...8, id: \.self) { Text("\($0)") }
    }
}
```

### Return moves to the next field

Set `.submitLabel(.next)` and move [focus](focus-state.md) in `.onSubmit`, so people never reach for the screen.

```swift
enum Field { case name, email }
@State private var name = ""
@State private var email = ""
@FocusState private var focus: Field?

Form {
    TextField("Name", text: $name)
        .textContentType(.name)
        .focused($focus, equals: .name)
        .submitLabel(.next)
    TextField("Email", text: $email)
        .textContentType(.emailAddress)
        .keyboardType(.emailAddress)
        .focused($focus, equals: .email)
        .submitLabel(.done)
}
.onSubmit {
    focus = focus == .name ? .email : nil
}
```

### Numbers and money

Give `TextField` a `value` and a `format` and it accepts and shows numbers, here as currency.

```swift
@State private var amount = 12.5

TextField("Amount", value: $amount, format: .currency(code: "USD"))
    .keyboardType(.decimalPad)
```

**Note:** If people type something the format can't read, the bound value stays as it was.

### Continue only when ready

Show problems next to the field, and disable Continue until the required values are valid.

```swift
@State private var email = ""
@State private var agreed = false

var isValid: Bool {
    email.contains("@") && email.contains(".") && agreed
}

Form {
    TextField("Email", text: $email)
        .keyboardType(.emailAddress)
        .textInputAutocapitalization(.never)
    Toggle("I agree to the terms", isOn: $agreed)
    Button("Continue") { }
        .disabled(!isValid)
}
```

## Related

[form](form.md), [text-field](text-field.md), [secure-field](secure-field.md), [focus-state](focus-state.md), [picker](picker.md), [date-picker](date-picker.md), [login-form](login-form.md), [feedback](feedback.md)
