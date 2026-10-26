---
id: popover
title: Popover
platforms: [iOS, iPadOS, macOS]
availability: iOS 13.0+, macOS 10.15+, visionOS 1.0+
docs: https://developer.apple.com/documentation/swiftui/view/popover(ispresented:attachmentanchor:arrowedge:content:).md
hig: https://developer.apple.com/design/human-interface-guidelines/popovers.md
---

# Popover

Shows extra content in a bubble that points at the button that opened it.

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
@State private var showTip = false

Button("Info", systemImage: "info.circle") {
    showTip = true
}
.popover(isPresented: $showTip) {
    Text("Prices include tax.")
        .padding()
        .presentationCompactAdaptation(.popover)
}
```

**Important:** On iPhone a popover becomes a sheet by default. To keep the bubble, add `.presentationCompactAdaptation` inside the content, as here.

## Rules

- **Keep popovers small.** A popover is for a tip or a few options. If the content needs scrolling, use a sheet.
- **Don't use a popover for warnings.** People can miss it or tap it away. Use an [Alert](alert.md) for anything they must see.
- **Show one popover at a time.** Never open a popover from another popover. Close the first one before showing the next.
- **Save changes when it closes.** Tapping outside closes a popover, often by accident. Keep what people entered unless they tap Cancel.

## Pitfalls

- **The popover hugs its content.** Size it yourself with `.padding` or `.frame(width:)`; long text needs a width to wrap.
- **For a list of commands, use a [Menu](menu.md).** A popover is for custom content, like a color grid or a short form.

## Key APIs

`.popover(isPresented:)`, `.popover(item:)`, `.presentationCompactAdaptation(_:)`, `arrowEdge:`

## Variants

### Help next to a field

Put an info `Button` beside a label and keep its explanation in a small `.popover`.

```swift
@State private var showHelp = false

HStack {
    Text("Routing number")
    Button("What's this?", systemImage: "info.circle") {
        showHelp = true
    }
    .labelStyle(.iconOnly)
    .popover(isPresented: $showHelp) {
        Text("The 9-digit number at the bottom left of a check.")
            .padding()
            .frame(width: 240)
            .presentationCompactAdaptation(.popover)
    }
}
```

### Popover on iPad, sheet on iPhone

Leave out the adaptation for bigger content: `.popover` floats on iPad and becomes a sheet on iPhone.

```swift
@State private var showSort = false
@State private var sort = "Date"

Button("Sort", systemImage: "arrow.up.arrow.down") {
    showSort = true
}
.popover(isPresented: $showSort) {
    Form {
        Picker("Sort by", selection: $sort) {
            ForEach(["Date", "Name", "Size"], id: \.self) { Text($0) }
        }
        .pickerStyle(.inline)
    }
    .frame(minWidth: 280, minHeight: 220)
    .presentationDetents([.medium])
}
```

**Note:** `.presentationDetents` only applies when the popover turns into a sheet, so it's safe to add for iPhone.

## On macOS

A small panel that points at its control and closes when people click away.

### Default code

```swift
@State private var isShowingDetails = false

Button("Details", systemImage: "info.circle") {
    isShowingDetails = true
}
.popover(isPresented: $isShowingDetails) {
    EventDetails()
        .padding()
}
```

**Note:** Keep the state the popover edits outside it, in the view that shows it. Then clicking away, which closes the popover, never loses a change.

### Rules

- **Keep it small, with a few related controls.** A popover is for a quick look or change, like an event's time. Make it only as big as its content.
- **Point at the control that opened it.** Aim the arrow straight at it, and avoid covering it or content people need while the popover is open.
- **Show one at a time, and nothing on top.** Close an open popover before showing another. Only an alert should ever appear over one.
- **Don't put a warning in a popover.** People can miss it or close it by accident. Use an alert for anything they must read.

### Pitfalls

- **Clicking outside closes it.** A popover doesn't block the window, so it goes away as soon as people click elsewhere.
- **The Mac respects `arrowEdge`.** Leave it out to let the system pick the side that fits.

### Key APIs

`attachmentAnchor:`, `@Environment(\.dismiss)`

### Variants

#### From a toolbar button

A `.popover` suits a toolbar button with a few options, like filters, that apply as soon as people change them.

```swift
@State private var isShowingFilters = false
@State private var showsUnread = true
@State private var showsFlagged = false

.toolbar {
    Button("Filter", systemImage: "line.3.horizontal.decrease.circle") {
        isShowingFilters = true
    }
    .popover(isPresented: $isShowingFilters, arrowEdge: .bottom) {
        VStack(alignment: .leading) {
            Toggle("Unread", isOn: $showsUnread)
            Toggle("Flagged", isOn: $showsFlagged)
        }
        .padding()
    }
}
```

**Note:** A real `.toolbar` here would land in this window's own toolbar, so the preview draws one. The button and popover are real.

More variants, left out to keep this file short: Close it after a choice (macOS). Apple's docs: https://developer.apple.com/documentation/swiftui/view/popover(ispresented:attachmentanchor:arrowedge:content:).md

## Related

[sheet](sheet.md), [menu](menu.md), [context-menu](context-menu.md), [tooltips](tooltips.md), [toolbar](toolbar.md)
