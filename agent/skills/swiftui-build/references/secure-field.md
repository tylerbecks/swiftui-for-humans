---
id: secure-field
title: SecureField
platforms: [iOS, iPadOS, macOS]
availability: iOS 13.0+, macOS 10.15+, visionOS 1.0+
docs: https://developer.apple.com/documentation/swiftui/securefield.md
hig: https://developer.apple.com/design/human-interface-guidelines/text-fields.md
---

# SecureField

A text field that hides what people type, for passwords and PINs.

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
@State private var password = ""

SecureField("Password", text: $password)
    .textContentType(.password)
    .textFieldStyle(.roundedBorder)
```

**Note:** Use `.password` on a sign-in screen and `.newPassword` on a sign-up screen, so iOS fills in the saved password or suggests a strong one.

## Rules

- **Always hide passwords and other secrets.** Someone nearby can read a plain field over a shoulder or in a screen recording. A `SecureField` shows dots instead.
- **Support AutoFill.** With the right `.textContentType`, people sign in with Face ID instead of typing. Mark the username field too, so both fill at once.
- **Check a new password before people move on.** Show the rules and whether they're met while people type. Finding out after Submit means typing it all again.

## Pitfalls

- **It works like a `TextField`.** It takes the same styles and modifiers, and the string you bind holds the real text. Only the display is hidden.
- **iOS locks it down for you.** Autocorrect, dictation, and copying are off, and each character shows for a moment before it turns into a dot.

## Key APIs

`SecureField(_:text:)`, `.textContentType(.password)`, `.textContentType(.newPassword)`, `.textContentType(.oneTimeCode)`, `.textFieldStyle(_:)`, `.onSubmit { }`

## Variants

### Sign-in form

In a `Form`, fields need no style. Mark them `.username` and `.password` so AutoFill fills both.

```swift
@State private var username = ""
@State private var password = ""

Form {
    TextField("Username", text: $username)
        .textContentType(.username)
        .textInputAutocapitalization(.never)
    SecureField("Password", text: $password)
        .textContentType(.password)
    Button("Sign In") {
        // Sign in
    }
    .disabled(username.isEmpty || password.isEmpty)
}
```

## On macOS

A text field that hides what people type, for passwords and other secrets.

### Default code

```swift
@State private var password = ""

SecureField("Password", text: $password)
    .textContentType(.password)
    .onSubmit {
        print("Signing in…")
    }
```

**Note:** Like `TextField`, the binding updates on every keystroke, so you can check the length or enable a button as people type.

### Rules

- **Never fill in a password for people.** Ask people to type it each time, or use biometric or keychain authentication instead.
- **Turn on Sign In only when it can work.** Keep the button disabled until people fill in the required fields, so it's clear what's missing.
- **Use a secure field for anything sensitive.** Passwords, PINs, and recovery codes belong in a `SecureField`, never a plain `TextField`.

### Pitfalls

- **The field protects its text for you.** It shows a dot for each character, won't let people cut or copy the contents, and shows an indicator while Caps Lock is on.
- **Consider not asking for a password at all.** The HIG suggests Sign in with Apple, or passkeys, before an app-specific password.

### Key APIs

`SecureField(_:text:prompt:)`, `.textContentType(.username)`, `.keyboardShortcut(.defaultAction)`

### Variants

#### A sign-in form

Mark the fields with `.textContentType` so the system can suggest saved accounts, and give Sign In `.keyboardShortcut(.defaultAction)` so Return clicks it.

```swift
@State private var username = ""
@State private var password = ""
@State private var message = ""

Form {
    TextField("User Name", text: $username)
        .textContentType(.username)
    SecureField("Password", text: $password)
        .textContentType(.password)
    Button("Sign In") {
        message = "Signed in as \(username)"
    }
    .keyboardShortcut(.defaultAction)
    .disabled(username.isEmpty || password.isEmpty)
    Text(message)
        .foregroundStyle(.secondary)
}
.frame(width: 320)
```

**Note:** On the Mac, the default button gets special coloring, so people can see that Return clicks it.

More variants, left out to keep this file short: Show / hide password, New password with strength meter, Create a password (macOS), Show the password (macOS). Apple's docs: https://developer.apple.com/documentation/swiftui/securefield.md

## Related

[text-field](text-field.md), [focus-state](focus-state.md), [login-form](login-form.md), [focus-keyboard](focus-keyboard.md), [form](form.md), [keyboard-shortcuts](keyboard-shortcuts.md)
