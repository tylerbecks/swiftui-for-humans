---
id: state-binding
title: State & Binding
platforms: [macOS]
availability: macOS 10.15+
docs: https://developer.apple.com/documentation/swiftui/state.md
---

# State & Binding

@State keeps a value a view owns, and @Binding lets another view change it.

Also called: @State, @Binding, state, binding, useState, props, two-way binding, v-model, source of truth, $.

## Contents

- Pitfalls
- Guide
- Key APIs
- Variants
- Related

## Pitfalls

- **Declare `@State` as `private`.** Apple's docs say so: setting it from an initializer can conflict with the storage SwiftUI manages for it.
- **With Xcode 27, `@State` is a macro.** It creates its starting value only the first time SwiftUI makes the view, so a model object in `@State` isn't rebuilt each time the parent redraws.
- **Only the owner says `@State`.** Every other view gets either a plain value to read or a `Binding` to write. Two `@State` properties for one value means two copies that drift apart.

## Guide

Every value a view shows has one owner, its **source of truth**. Mark it `@State` in the view that owns it, and SwiftUI stores it and redraws whatever reads it when it changes.

When another view needs to change that value, such as a button in the window's toolbar, pass it a **binding** with `$`. The child declares `@Binding` and reads and writes the owner's value directly, like a controlled input in React.

The window owns `isPlaying`. The play button in its toolbar only has a binding, yet clicking it changes what the window shows.

### Which one to use

- This view creates the value and changes it: `@State private var isPlaying = false`
- A child view changes the owner's value: `@Binding var isPlaying: Bool`, passed as `$isPlaying`
- A child view only shows it: A plain property: `let isPlaying: Bool`
- Several windows or many views share it: An [Observable](observable.md) model class, kept in `@State` once

## Key APIs

- `@State private var`: A value this view owns and SwiftUI stores.
- `@Binding var`: Reads and writes a value another view owns.
- `$value`: The binding to a `@State` value, to pass along.
- `$draft.title`: A binding to one property of a struct.
- `ForEach($items) { $item in }`: A binding to each element of an array.
- `.constant(_:)`: A binding that never changes, for previews.

## Variants

### A view option the view owns

Use `@State` for a value only this view needs, like whether a list shows finished tasks. Controls take `$showsCompleted`.

```swift
@State private var showsCompleted = true

let tasks = ["Write outline", "Record intro", "Edit episode"]
let finished: Set = ["Write outline"]

VStack(alignment: .leading) {
    Toggle("Show completed", isOn: $showsCompleted)
    ForEach(tasks, id: \.self) { task in
        if showsCompleted || !finished.contains(task) {
            Label(task, systemImage: finished.contains(task) ? "checkmark.circle.fill" : "circle")
        }
    }
}
```

### Selection is a binding too

`List(selection:)` writes the selected rows into your `@State`. With a `Set`, people can select several rows on the Mac without an edit mode.

```swift
struct Mailbox: Identifiable {
    let id: String
    let name: String
    let symbol: String
}

let mailboxes = [
    Mailbox(id: "inbox", name: "Inbox", symbol: "tray"),
    Mailbox(id: "flagged", name: "Flagged", symbol: "flag"),
    Mailbox(id: "drafts", name: "Drafts", symbol: "doc"),
    Mailbox(id: "sent", name: "Sent", symbol: "paperplane"),
]

@State private var selection: Set<Mailbox.ID> = ["inbox"]

List(mailboxes, selection: $selection) { mailbox in
    Label(mailbox.name, systemImage: mailbox.symbol)
}
Text("\(selection.count) selected")
```

**Note:** Bind to a single optional ID instead of a `Set` when only one row can be selected at a time.

### Bind to one property of a struct

Keep related fields in one struct in `@State`. `$draft.title` is a binding to just that field, so each control edits its own part.

```swift
struct NoteDraft {
    var title = "Weekly review"
    var isPinned = false
    var color = Color.yellow
}

@State private var draft = NoteDraft()

Form {
    TextField("Title", text: $draft.title)
    Toggle("Pin to top", isOn: $draft.isPinned)
    ColorPicker("Color", selection: $draft.color)
}
```

### A binding for each row

`ForEach($tasks) { $task in … }` hands every row a binding to its own element, so a checkbox can tick off one task in the array.

```swift
struct TaskItem: Identifiable {
    let id = UUID()
    var title: String
    var isDone = false
}

@State private var tasks = [
    TaskItem(title: "Export the audio"),
    TaskItem(title: "Write show notes", isDone: true),
    TaskItem(title: "Upload the episode"),
]

VStack(alignment: .leading) {
    ForEach($tasks) { $task in
        Toggle(task.title, isOn: $task.isDone)
    }
    Text("\(tasks.filter(\.isDone).count) of \(tasks.count) done")
        .foregroundStyle(.secondary)
}
```

### Write your own control with @Binding

A reusable control declares `@Binding` and never owns the value. Pass `.constant(_:)` when you only need to show it, as in a preview.

```swift
struct RatingControl: View {
    @Binding var rating: Int

    var body: some View {
        HStack(spacing: 2) {
            ForEach(1...5, id: \.self) { star in
                Button("\(star) stars", systemImage: star <= rating ? "star.fill" : "star") {
                    rating = star
                }
                .labelStyle(.iconOnly)
                .buttonStyle(.borderless)
            }
        }
    }
}

@State private var rating = 3

VStack {
    RatingControl(rating: $rating)
    RatingControl(rating: .constant(5))
        .disabled(true)
}
```

**Important:** Don't add `@State` inside the control to copy the value. The copy stops following the owner, and the two disagree.

## Related

[observable](observable.md), [environment](environment.md), [toggle](toggle.md), [table](table.md)
