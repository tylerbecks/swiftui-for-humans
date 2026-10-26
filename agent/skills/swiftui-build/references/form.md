---
id: form
title: Form
platforms: [iOS, iPadOS, macOS]
availability: iOS 13.0+, macOS 10.15+, visionOS 1.0+, formStyle macOS 13.0+
docs: https://developer.apple.com/documentation/swiftui/form.md
hig: https://developer.apple.com/design/human-interface-guidelines/entering-data.md
---

# Form

A container that lays out controls as grouped rows, like the Settings app.

## Contents

- Use when
- Don't use when
- Default code
- Built from
- Rules
- Pitfalls
- Key APIs
- Variants
- On macOS
- Related

## Use when

- `Form` is a `List` that restyles the controls inside it for data entry: toggles get a trailing switch, pickers become menu rows, and buttons become tappable rows.
- You get the grouped Settings look without styling anything.
- Use it for settings, sign-up, and edit screens.

## Don't use when

- For rows of content people browse, use [List](list.md).

## Default code

```swift
@State private var name = ""
@State private var notifications = true

Form {
    Section("Profile") {
        TextField("Name", text: $name)
        Toggle("Notifications", isOn: $notifications)
    }
    Section("About") {
        LabeledContent("Version", value: "2.1")
    }
}
```

**Note:** On iPhone, a `Form` fills the screen like a `List`. Wrap it in a `NavigationStack` to give it a title.

## Built from

Form
├── Section("Header")
│   ├── TextField
│   ├── Toggle
│   └── Picker
└── Section
    ├── LabeledContent
    └── footer: Text

## Rules

- **Offer choices instead of typing.** Picking from a short list is faster than typing and can't go wrong. Use a `Picker`, `Toggle`, or `Stepper` when the answers are known.
- **Validate as people type.** Show problems right away and keep the Continue button disabled until the required fields are filled, so nobody has to go back and fix things.
- **Explain settings in a section footer.** A sentence under a group tells people what a switch does before they change it. Keep the row labels themselves short.
- **Use `SecureField` for passwords, and never prefill one.** It hides each character as people type. Prefilling a password exposes it to anyone holding the phone.

## Pitfalls

- **A form doesn't submit anything.** Each control writes to its own `@State` as it changes, so there's no `onSubmit` for the whole form. Add a Save button if you need one.
- **Show read-only values with `LabeledContent`.** It puts a label on the left and a value on the right, like “Version 2.1” in Settings.

## Key APIs

`Form { }`, `Section(_:content:)`, `Section { } footer: { }`, `LabeledContent(_:value:)`, `.pickerStyle(_:)`, `.disabled(_:)`

## Variants

### Sign-up form with validation

Keep the submit `Button` disabled with `.disabled(_:)` until the input is valid.

```swift
@State private var email = ""
@State private var agreed = false

Form {
    Section("Account") {
        TextField("Email", text: $email)
            .keyboardType(.emailAddress)
            .textInputAutocapitalization(.never)
        Toggle("I agree to the terms", isOn: $agreed)
    }
    Section {
        Button("Create Account") {
            // Submit
        }
        .disabled(!email.contains("@") || !agreed)
    }
}
```

**Note:** A `Button` in a form is just another row, drawn as tinted text.

## On macOS

Groups labeled controls for settings and data entry, in Mac columns or System Settings rows.

### Default code

```swift
@State private var name = ""
@State private var showsLineNumbers = true

Form {
    TextField("Name", text: $name)
    Toggle("Show line numbers", isOn: $showsLineNumbers)
    LabeledContent("Version", value: "2.4")
}
```

**Note:** On the Mac, a plain `Form` uses `.columns`, not the grouped look of iPhone. Add `.formStyle(.grouped)` when you want rows like System Settings.

### Rules

- **Group related settings into sections.** A few small sections are faster to scan than one long run of rows, and a header tells people what each group is for.
- **Offer as few settings as you can.** Pick good defaults so most people never need to change anything. Every extra option makes the one people want harder to find.
- **Keep options for the current task in its window.** Choices like sorting or showing a column belong next to the content they change, not in a settings form people have to go and open.

### Pitfalls

- **Controls change inside a `Form`.** In a grouped form, a toggle becomes a switch and a picker sits at the trailing edge of its row. Put the same controls in a `VStack` and they keep their plain look.
- **A grouped form scrolls by itself.** It's a scroll view, like `List`. The columns style doesn't scroll, so wrap a long one in a `ScrollView` or split it into panes.

### Key APIs

`.formStyle(.columns)`, `.formStyle(.grouped)`, `LabeledContent { } label: { }`

### Variants

#### A classic Mac columns form

`.formStyle(.columns)` right-aligns each label against its control, and by Mac convention the labels end with a colon.

```swift
@State private var startsWith = "Last session"
@State private var fontSize = 13.0
@State private var opensInTabs = true

Form {
    Picker("Start with:", selection: $startsWith) {
        Text("Last session").tag("Last session")
        Text("New document").tag("New document")
    }
    .pickerStyle(.radioGroup)
    Stepper("Font size: \(Int(fontSize)) pt", value: $fontSize, in: 9...24)
    Toggle("Open documents in tabs", isOn: $opensInTabs)
}
.formStyle(.columns)
```

More variants, left out to keep this file short: Inline picker, Rows that open other screens, Grouped, like System Settings (macOS), Read-only rows with LabeledContent (macOS), Several checkboxes under one label (macOS). Apple's docs: https://developer.apple.com/documentation/swiftui/form.md

## Related

[list](list.md), [toggle](toggle.md), [picker](picker.md), [settings-screen](settings-screen.md), [labeled-content](labeled-content.md), [group-box](group-box.md), [settings-scene](settings-scene.md)
