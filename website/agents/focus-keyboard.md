---
id: focus-keyboard
title: Focus & Keyboard Navigation
platforms: [macOS]
availability: macOS 12.0+
docs: https://developer.apple.com/documentation/swiftui/focus.md
hig: https://developer.apple.com/design/human-interface-guidelines/focus-and-selection.md
---

# Focus & Keyboard Navigation

Decide which view gets typed keys, and let people move around with Tab.

## Contents

- Rules
- Pitfalls
- Guide
- Key APIs
- Variants
- Related

## Rules

- **Use the system's focus ring.** People know what it means at a glance, and it's tuned for the Mac. Draw your own focus look only when you really need one.
- **Don't move focus on your own.** People track where they are by where focus is. Change it only in response to something they do.
- **Make content focusable, and let the system handle controls.** Fields, lists, and your custom content should take focus. Full Keyboard Access already lets people reach buttons, toggles, and sliders.
- **Ring fields, highlight rows.** A focus ring suits text and search fields. In a list or collection, highlight the whole row or item instead.

## Pitfalls

- **Custom views take focus.** Built with the macOS 14 SDK or later, a `.focusable()` view can get focus even with keyboard navigation off. Pass `interactions: .activate` for a button-like view that should wait for it.
- **Return `.ignored` to pass a key on.** `.handled` stops the key at your view; `.ignored` lets views further up still get it.

## Guide

Keyboard focus decides which view gets the keys people press. On the Mac, people type into the focused field and press Tab to move to the next one. A focused text field shows a focus ring.

SwiftUI handles the common cases: text fields take focus when clicked, and Tab moves through them in reading order. Use `@FocusState` when you need to read or move focus yourself.

### Keys people use

- Tab and ⇧Tab: Move to the next or previous control.
- ⌃Tab and ⌃⇧Tab: Move to the next or previous group of controls, or to the next table when Tab moves between cells.
- Esc: Cancel the current action.
- Full Keyboard Access: With it on, people can reach every control with the keyboard. It's in the Accessibility section of System Settings.

## Key APIs

`@FocusState`, `.focused(_:equals:)`, `.defaultFocus(_:_:)`, `.focusable()`, `.onKeyPress(_:action:)`, `.focusEffectDisabled()`, `.focusSection()`

## Variants

### Move focus to what needs fixing

Bind each field to a case with `.focused(_:equals:)`. Setting the `@FocusState` moves focus there, here to the first empty field.

```swift
enum Field: Hashable {
    case name, email
}

@State private var name = ""
@State private var email = ""
@FocusState private var focusedField: Field?

Form {
    TextField("Name", text: $name)
        .focused($focusedField, equals: .name)
    TextField("Email", text: $email)
        .focused($focusedField, equals: .email)
    Button("Join") {
        if name.isEmpty {
            focusedField = .name
        } else if email.isEmpty {
            focusedField = .email
        } else {
            focusedField = nil
        }
    }
}
.frame(width: 300)
```

**Important:** Give each field its own value. If two views share one, setting it focuses the first, and SwiftUI warns you at runtime.

### Start focus in the right place

`.defaultFocus` picks where focus goes when the window opens. In a reply, that's the message, not the To field.

```swift
enum ReplyField: Hashable {
    case to, subject, message
}

@State private var to = "sam@example.com"
@State private var subject = "Re: Saturday"
@State private var message = ""
@FocusState private var focus: ReplyField?

VStack {
    Form {
        TextField("To", text: $to)
            .focused($focus, equals: .to)
        TextField("Subject", text: $subject)
            .focused($focus, equals: .subject)
    }
    TextEditor(text: $message)
        .font(.body)
        .focused($focus, equals: .message)
}
.defaultFocus($focus, .message)
```

**Note:** Default focus applies when a window first appears, so open the sample as a window to try it.

### Keys for a custom view

Make a view `.focusable()`, then handle keys with `.onKeyPress`. Click the stars, then press ← or →.

```swift
@State private var rating = 3
@FocusState private var isFocused: Bool

HStack {
    ForEach(1...5, id: \.self) { star in
        Image(systemName: star <= rating ? "star.fill" : "star")
    }
}
.foregroundStyle(.orange)
.padding(6)
.focusable()
.focused($isFocused)
.onTapGesture { isFocused = true }
.onKeyPress(.leftArrow) {
    rating = max(1, rating - 1)
    return .handled
}
.onKeyPress(.rightArrow) {
    rating = min(5, rating + 1)
    return .handled
}
```

More variants, left out to keep this file short: Your own focus look, Tab down a column first. Apple's docs: https://developer.apple.com/documentation/swiftui/focus.md

## Related

[text-field](text-field.md), [secure-field](secure-field.md), [keyboard-shortcuts](keyboard-shortcuts.md), [keyboard-access](keyboard-access.md), [form](form.md)
