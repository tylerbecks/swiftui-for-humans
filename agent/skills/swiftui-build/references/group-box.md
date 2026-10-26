---
id: group-box
title: GroupBox & DisclosureGroup
platforms: [macOS]
availability: macOS 10.15+, DisclosureGroup macOS 11.0+
docs: https://developer.apple.com/documentation/swiftui/groupbox.md
hig: https://developer.apple.com/design/human-interface-guidelines/boxes.md
---

# GroupBox & DisclosureGroup

Box related controls together, and tuck advanced ones under a disclosure triangle.

Also called: GroupBox, DisclosureGroup, box, NSBox, fieldset, <fieldset>, <details>, <summary>, disclosure triangle, expand.

## Contents

- Use when
- Default code
- Built from
- Rules
- Pitfalls
- Key APIs
- Variants
- Related

## Use when

- `GroupBox` draws a rounded background around related content, with an optional title above it.
- `DisclosureGroup` shows a label with a triangle that hides or shows its content.
- Use a box to set a few controls apart inside a larger window, and a disclosure group to keep advanced options out of the way until someone asks for them.

## Default code

```swift
@State private var includesMetadata = true

GroupBox("Export") {
    DisclosureGroup("Advanced Options") {
        Toggle("Include metadata", isOn: $includesMetadata)
    }
}
```

## Built from

GroupBox("Export")
└── VStack
    ├── Picker("Format")
    └── DisclosureGroup
        ├── Toggle
        └── Toggle

## Rules

- **Show subgroups with space, not boxes inside boxes.** Every box adds a border. Nest them and the window starts to feel busy and cramped; padding and alignment can do the same job.
- **Name a disclosure triangle after what it reveals.** A label like “Advanced Options” tells people what they'll find before they open it. “More” makes them click to find out.
- **Keep a box small next to the window around it.** A box that fills most of the window stops looking like a group and just crowds everything else.
- **Title a box with a short phrase in sentence case.** Skip ending punctuation, except in a settings pane, where Mac box titles end with a colon.
- **Leave the everyday controls outside the triangle.** Put what most people need where they can see it, and hide only the advanced options.

## Pitfalls

- **On the Mac, a box's title sits above the box.** Pass a string or a `Label`; the box sets its content apart from the window around it.
- **For a tree of data, don't nest disclosure groups by hand.** `List(children:)` and `OutlineGroup` build the triangles for you; see [Outline lists](outline.md).

## Key APIs

- `GroupBox(_:content:)`: A box with a text title.
- `GroupBox { } label: { }`: A box with any title view, like a `Label`.
- `DisclosureGroup(_:content:)`: Content behind a disclosure triangle.
- `DisclosureGroup(_:isExpanded:)`: Lets you open or close it from code.
- `.disclosureGroupStyle(_:)`: Replaces the triangle with your own look.

## Variants

### Titled boxes in a settings pane

Two small `GroupBox`es split a settings pane into topics, each titled with a colon, as Mac settings panes do.

```swift
@State private var opensLastWindow = true
@State private var checksUpdates = true
@State private var syncsBookmarks = true
@State private var syncsHistory = false

VStack(alignment: .leading, spacing: 16) {
    GroupBox("At startup:") {
        VStack(alignment: .leading) {
            Toggle("Reopen last window", isOn: $opensLastWindow)
            Toggle("Check for updates", isOn: $checksUpdates)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    GroupBox("Sync:") {
        VStack(alignment: .leading) {
            Toggle("Bookmarks", isOn: $syncsBookmarks)
            Toggle("History", isOn: $syncsHistory)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
.frame(width: 280)
```

### A box with an icon and a summary

Pass a `Label` as the box's title when a symbol helps people find it at a glance.

```swift
GroupBox {
    VStack(alignment: .leading, spacing: 6) {
        ProgressView(value: 0.62)
        Text("310 GB of 500 GB used")
            .font(.callout)
            .foregroundStyle(.secondary)
    }
} label: {
    Label("Storage", systemImage: "internaldrive")
}
.frame(width: 280)
```

### Advanced options in a form

Inside a grouped `Form`, a `DisclosureGroup` becomes a row that opens to more rows, below the setting most people need.

```swift
@State private var quality = 0.8
@State private var keepsOriginal = true
@State private var stripsLocation = false

Form {
    Slider(value: $quality, in: 0...1) {
        Text("Quality")
    }
    DisclosureGroup("Advanced Options") {
        Toggle("Keep original", isOn: $keepsOriginal)
        Toggle("Remove location", isOn: $stripsLocation)
    }
}
.formStyle(.grouped)
```

### Open the way people left it

Bind `isExpanded` to `@AppStorage` so a disclosure group stays open or closed the next time the window opens.

```swift
@AppStorage("showsDetails") private var showsDetails = false

DisclosureGroup("Details", isExpanded: $showsDetails) {
    LabeledContent("Created", value: "March 3, 2026")
    LabeledContent("Size", value: "2.4 MB")
}
.frame(width: 260)
```

## Related

[form](form.md), [outline](outline.md), [stacks-grid](stacks-grid.md)
