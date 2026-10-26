---
id: text-field
title: TextField
platforms: [iOS, iPadOS, macOS]
availability: iOS 13.0+, macOS 10.15+, visionOS 1.0+
docs: https://developer.apple.com/documentation/swiftui/textfield.md
hig: https://developer.apple.com/design/human-interface-guidelines/text-fields.md
---

# TextField

A box people type a short piece of text or a number into.

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
@State private var name = ""

TextField("Name", text: $name)
    .textFieldStyle(.roundedBorder)
```

**Important:** Outside a `Form` or `List`, the default style has no border, so the field can look invisible. Add `.textFieldStyle(.roundedBorder)` or a background of your own.

## Rules

- **Keep a visible label once people start typing.** The placeholder disappears with the first keystroke. A label beside or above the field still says what each value is.
- **Show the keyboard that fits the content.** An email field with `.emailAddress` puts @ on the first screen, and a price with `.decimalPad` shows only digits. It saves taps and typos.
- **Validate at the right moment.** Check an email address when people leave the field, not on the first letter. Show the problem right under the field, in words.
- **Size the field to the text you expect.** A short field for a ZIP code and a wide one for a street address tell people how much to type.

## Pitfalls

- **The field edits a string you own.** Pass a `@State` property with `$`, like a controlled `<input>` in React. It updates on every keystroke.
- **Let it grow for longer text.** `TextField(_:text:axis: .vertical)` wraps onto new lines as people type; cap it with `.lineLimit(1...5)`. For a full page of text, use [TextEditor](text-editor.md).
- **Focus and the keyboard are state too.** To move between fields on Return or hide the keyboard, see [Keyboard & Focus](focus-state.md).

## Key APIs

`TextField(_:text:)`, `TextField(_:value:format:)`, `axis: .vertical`, `.textFieldStyle(_:)`, `.keyboardType(_:)`, `.textContentType(_:)`, `.autocorrectionDisabled()`, `.onSubmit { }`

## Variants

### In a Form

Inside a `Form`, fields need no style. Wrap one in `LabeledContent` to show a label beside it.

```swift
@State private var name = "Taylor"
@State private var city = ""

Form {
    TextField("Name", text: $name)
    LabeledContent("City") {
        TextField("Required", text: $city)
            .multilineTextAlignment(.trailing)
    }
}
```

## On macOS

A single-line field for short text, like a name, an email address, or a number.

### Default code

```swift
@State private var name = ""

TextField("Name", text: $name, prompt: Text("Jane Appleseed"))
    .onSubmit {
        print("Hello, \(name)")
    }
```

**Note:** The binding updates on every keystroke, like a controlled `<input>`. `onSubmit` runs when people press Return.

### Rules

- **Size the field for what goes in it.** The width hints at how much to type. A ZIP code needs a short field; a street address needs a long one.
- **Keep a label next to the field.** Placeholder text disappears as soon as people type, so a label beside the field keeps reminding them what it's for.
- **Check input at the right moment.** Check an email address when people move to the next field. Check a new user name before they move on, so they can fix it right away.
- **Let Tab move through fields in order.** People expect focus to go top to bottom and leading to trailing. SwiftUI does this for you; see [Focus & keyboard navigation](focus-keyboard.md) when you need more.

### Pitfalls

- **A `String` updates as people type; other values wait.** A field bound with `value:format:` changes its value only when people commit the edit, such as by pressing Return.
- **On macOS 27 and later, use `.bordered` for a border.** It replaces `.roundedBorder`; pair it with `.textInputBorderShape(_:)`, such as `.capsule`, to choose the shape.

### Key APIs

`TextField(_:text:prompt:)`, `TextField(_:text:axis:)`, `.textInputSuggestions { }`

### Variants

#### Labels in a form

In a `Form`, the Mac puts each field's label at the leading edge and shows the `prompt` inside the field.

```swift
@State private var name = ""
@State private var email = ""

Form {
    TextField(text: $name, prompt: Text("Required")) {
        Text("Name")
    }
    TextField(text: $email, prompt: Text("Optional")) {
        Text("Email")
    }
}
```

#### Add an item with Return

Use `.onSubmit` to act when people press Return, then clear the field so they can type the next one.

```swift
@State private var newTag = ""
@State private var tags = ["Travel", "Family"]

VStack(alignment: .leading) {
    TextField("New Tag", text: $newTag)
        .onSubmit {
            let tag = newTag.trimmingCharacters(in: .whitespaces)
            guard !tag.isEmpty else { return }
            tags.append(tag)
            newTag = ""
        }
    Text(tags.joined(separator: ", "))
        .foregroundStyle(.secondary)
}
.frame(width: 260)
```

More variants, left out to keep this file short: Email with validation, Numbers and currency, Search field with clear button, A price with a format (macOS), A field that grows (macOS), Suggestions as people type (macOS). Apple's docs: https://developer.apple.com/documentation/swiftui/textfield.md

## Related

[secure-field](secure-field.md), [text-editor](text-editor.md), [focus-state](focus-state.md), [form](form.md), [focus-keyboard](focus-keyboard.md), [labeled-content](labeled-content.md), [search](search.md)
