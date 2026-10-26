---
id: labeled-content
title: LabeledContent
platforms: [macOS]
availability: macOS 13.0+
docs: https://developer.apple.com/documentation/swiftui/labeledcontent.md
hig: https://developer.apple.com/design/human-interface-guidelines/labels.md
---

# LabeledContent

A label and a value in one row that lines up with the rest of a form.

Also called: label value, key value, info row, property row, <dl>, definition list, get info, detail row, form row, inspector row.

## Contents

- Default code
- Rules
- Pitfalls
- Key APIs
- Variants
- Related

## Default code

```swift
Form {
    LabeledContent("Version", value: "2.4 (118)")
    LabeledContent("Size", value: 18_400_000, format: .byteCount(style: .file))
}
.formStyle(.grouped)
```

**Note:** Like a `<dt>` and `<dd>` pair, but the layout comes from the container: a `Form`'s style decides where the label goes.

## Rules

- **Show read-only details as text.** A text value is for reading and copying, not editing. When people should change the value, put a text field or another control in the value instead.
- **Let people copy useful details.** Values like an error code, an address, or a version number are worth pasting elsewhere. Pass them as a string or with `format:`, and SwiftUI makes them selectable where it can.
- **Show importance with the system's label colors.** Primary for the main text and secondary for supporting text keep the hierarchy clear in light and dark, as a grouped form does.

## Pitfalls

- **Text values are selectable where possible.** SwiftUI makes a text value selectable, so people can copy a serial number or a path.
- **It's a label for anything.** Any view can be the value: a field and a stepper, a group of checkboxes, or a custom view.

## Key APIs

- `LabeledContent(_:value:)`: A read-only text value.
- `LabeledContent(_:value:format:)`: A value with a format style.
- `LabeledContent(_:content:)`: Any view as the value.
- `LabeledContent(content:label:)`: Any view as the label too.
- `.labelsHidden()`: Hides the label on screen.
- `.labeledContentStyle(_:)`: Your own layout for every row inside.

## Variants

### Details in an inspector

Pass `format:` to show numbers, sizes, and dates the way the person's region writes them.

```swift
let created = Date.now

Form {
    Section("Information") {
        LabeledContent("Kind", value: "JPEG image")
        LabeledContent("Size", value: 2_480_000, format: .byteCount(style: .file))
        LabeledContent("Created", value: created, format: .dateTime.day().month().year())
    }
}
.formStyle(.grouped)
```

### A control as the value

Give any view a label that lines up with the other rows, like a field with a stepper beside it.

```swift
@State private var copies = 1

Form {
    LabeledContent("Copies:") {
        HStack(spacing: 4) {
            TextField("Copies", value: $copies, format: .number)
                .frame(width: 44)
            Stepper("Copies", value: $copies, in: 1...99)
        }
        .labelsHidden()
    }
    Picker("Paper size:", selection: .constant("A4")) {
        Text("A4").tag("A4")
        Text("US Letter").tag("US Letter")
    }
}
```

### Checkboxes under one label

In a grouped form, toggles inside `LabeledContent` become checkboxes stacked under one label, instead of switches.

```swift
@State private var refreshesStatus = true
@State private var fetchesServer = false
@State private var addsFiles = true

Form {
    LabeledContent("Source Control") {
        Toggle("Refresh status automatically", isOn: $refreshesStatus)
        Toggle("Fetch server status", isOn: $fetchesServer)
        Toggle("Add and remove files", isOn: $addsFiles)
    }
}
.formStyle(.grouped)
```

### A label with a subtitle

Give the label two `Text` views: the first is the title, the second a line of detail under it.

```swift
Form {
    LabeledContent {
        Text("4.2 GB")
    } label: {
        Text("Cache")
        Text("Downloaded previews and thumbnails")
    }
}
.formStyle(.grouped)
```

## Related

[form](form.md), [inspector](inspector.md), [toggle](toggle.md), [stepper](stepper.md), [text-label](text-label.md)
