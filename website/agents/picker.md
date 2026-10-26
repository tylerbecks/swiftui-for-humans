---
id: picker
title: Picker
platforms: [iOS, iPadOS, macOS]
availability: iOS 13.0+, macOS 10.15+, visionOS 1.0+
docs: https://developer.apple.com/documentation/swiftui/picker.md
hig: https://developer.apple.com/design/human-interface-guidelines/pickers.md
---

# Picker

A control for choosing one value from a list of options.

## Contents

- Default code
- Rules
- Pitfalls
- Key APIs
- On macOS
- Related

## Default code

```swift
@State private var size = "Medium"

Picker("Size", selection: $size) {
    Text("Small").tag("Small")
    Text("Medium").tag("Medium")
    Text("Large").tag("Large")
}
```

**Important:** Each option's `.tag` must be the same type as `selection`. With an optional selection, tag with `Optional("Small")` or nothing shows as selected.

## Rules

- **Use a segmented picker for two to five short options.** More segments get cramped on iPhone and the labels get cut off. For longer lists, use the `.menu` style.
- **Use all text or all icons in one segmented control.** Mixing them makes segments look uneven and hard to compare.
- **Order options so people can guess what's hidden.** Alphabetical, numeric, or by time. A menu or wheel hides most options, so a predictable order makes them quick to find.
- **Use a segmented control to switch views, not whole sections.** Switching between related views on one screen fits. For the app's main sections, use a [TabView](tab-view.md).

## Pitfalls

- **The tag's type must match the selection exactly.** A `String` tag on an `Int` selection compiles, but nothing ever looks selected.
- **The default look depends on where the picker lives.** On its own it's a menu button; in a `Form` it's a row with the value on the right.

## Key APIs

`Picker(_:selection:content:)`, `.tag(_:)`, `.pickerStyle(_:)`, `ForEach(Enum.allCases)`, `.labelsHidden()`, `Menu { Picker }`

## On macOS

A pop-up button, radio group, or segmented control for one choice from a set.

### Default code

```swift
enum SortKey: String, CaseIterable, Identifiable {
    case name, date, size, kind
    var id: Self { self }
}

@State private var sortKey = SortKey.name

Picker("Sort by", selection: $sortKey) {
    ForEach(SortKey.allCases) { order in
        Text(order.rawValue.capitalized)
    }
}
```

**Note:** Like a `<select>`, the picker shows the current choice and writes the new one back to your `@State`.

### Rules

- **Use a pop-up button for choices, not commands.** A pop-up button picks one of several options that affect the content or view. For a list of actions, several selections, or submenus, use a pull-down [Menu](menu.md) instead.
- **Help people predict the options before they click.** A label like “Sort by” tells people what's inside. On its own, a pop-up showing “Name” could mean anything.
- **Start with a useful default.** Preselect the option most people want. If a few people need something unusual, add a Custom… item instead of more controls.
- **Use either text or symbols in a segmented control.** Mixing the two in one control looks disjointed. Keep segments similar in size, and aim for no more than about five to seven of them.
- **Switch the main view with tabs, not a segmented control.** In the body of a window, a `TabView` is the Mac's way to switch views. A segmented control fits a toolbar or an inspector.

### Pitfalls

- **The tag type must match the selection type.** `ForEach` over an `Identifiable` enum tags each row with its `id` for you; anything else needs an explicit `.tag(_:)`.
- **One style on a container sets them all.** `.pickerStyle(_:)` on a `Form` or `VStack` reaches every picker inside it.

### Key APIs

`.pickerStyle(.menu)`, `.pickerStyle(.radioGroup)`, `.pickerStyle(.segmented)`, `.horizontalRadioGroupLayout()`

### Variants

#### Radio buttons in a form

Use `.radioGroup` when seeing every option helps, and inside a `Form` its label lines up with the other rows.

```swift
@State private var format = "Rich Text"
@State private var encoding = "UTF-8"

Form {
    Picker("Format:", selection: $format) {
        Text("Rich Text").tag("Rich Text")
        Text("Plain Text").tag("Plain Text")
    }
    .pickerStyle(.radioGroup)

    Picker("Encoding:", selection: $encoding) {
        Text("UTF-8").tag("UTF-8")
        Text("UTF-16").tag("UTF-16")
    }
}
```

More variants, left out to keep this file short: Segmented filter, In a settings form, Sort menu with checkmarks, Color tags in a menu, Radio buttons in a row (macOS), A segmented control in an inspector (macOS), A Custom… option (macOS). Apple's docs: https://developer.apple.com/documentation/swiftui/picker.md

## Related

[menu](menu.md), [date-picker](date-picker.md), [form](form.md), [toggle](toggle.md), [control-group](control-group.md), [labeled-content](labeled-content.md)
