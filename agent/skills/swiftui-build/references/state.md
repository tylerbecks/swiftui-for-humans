---
id: state
title: @State
platforms: [iOS, iPadOS]
availability: iOS 13.0+, macOS 10.15+, visionOS 1.0+
docs: https://developer.apple.com/documentation/swiftui/state.md
---

# @State

Stores a value that one view owns, and redraws the view when it changes.

Also called: useState, setState, local state, state variable, reactive variable, variable, store a value, useRef, stateful.

## Contents

- Default code
- Pitfalls
- Key APIs
- Variants
- Related

## Default code

```swift
@State private var count = 0

var body: some View {
    Button("Count: \(count)") {
        count += 1
    }
}
```

**Note:** Unlike React's `useState`, there's no setter function. Assign to the property, and SwiftUI redraws every view that reads it.

## Pitfalls

- **Mark it `private`.** The value belongs to the view that declares it. Children get a plain value to read, or a `$binding` to edit.
- **The view is rebuilt; the state isn't.** SwiftUI recreates view structs all the time, but keeps each `@State` value alive while the view stays on screen.
- **Use it for simple values.** `Bool`, `Int`, `String`, enums, and small structs. For data several screens share, hold an [@Observable](observable.md) class in `@State` instead.

## Key APIs

- `@State private var count = 0`: Declares a value this view owns, with its starting value.
- `count += 1`: Write to it directly. The view redraws on its own.
- `$count`: A `Binding` that controls and child views can write to.
- `withAnimation { }`: Animates the views that change because of the write.
- `@State private var model = Model()`: Owns an `@Observable` class, created once.

## Variants

### Show a sheet

A `Bool` in `@State` drives `.sheet(isPresented:)`, the usual way to show and hide something.

```swift
@State private var isShowingDetails = false

Button("Show details") {
    isShowingDetails = true
}
.buttonStyle(.borderedProminent)
.sheet(isPresented: $isShowingDetails) {
    VStack(spacing: 12) {
        Text("Order #1042")
            .font(.title2.bold())
        Text("Arriving Thursday")
            .foregroundStyle(.secondary)
        Button("Close") {
            isShowingDetails = false
        }
        .buttonStyle(.bordered)
    }
    .presentationDetents([.medium])
}
```

**Note:** You only set it to `true`. When people swipe the sheet down, SwiftUI sets it back to `false` through the binding.

### A struct as state

Group related values in a struct, and bind controls to its fields with `$draft.title`.

```swift
struct Draft {
    var title = ""
    var isUrgent = false
}

@State private var draft = Draft()

VStack(alignment: .leading, spacing: 12) {
    TextField("Title", text: $draft.title)
        .textFieldStyle(.roundedBorder)
    Toggle("Urgent", isOn: $draft.isUrgent)
    Text(draft.isUrgent ? "🔥 \(draft.title)" : draft.title)
        .font(.headline)
}
.frame(maxWidth: 280)
```

**Note:** Changing any field counts as a change to the whole struct, so every view that reads `draft` redraws.

### Gotcha: state ignores later inputs

The child copies the parent's number into its own `@State`, so it stops following the parent.

```swift
struct Parent: View {
    @State private var count = 0

    var body: some View {
        VStack(spacing: 12) {
            Stepper("Parent: \(count)", value: $count)
            Child(count: count)
        }
    }
}

struct Child: View {
    @State var count: Int // ⚠️ Copied once, then ignored

    var body: some View {
        Text("Child: \(count)")
    }
}
```

**Important:** `@State` uses its starting value only once. To follow a value the parent owns, declare `let count: Int`, or `@Binding var count: Int` if the child also changes it.

## Related

[binding](binding.md), [choosing-wrappers](choosing-wrappers.md), [view-updates](view-updates.md), [observable](observable.md)
