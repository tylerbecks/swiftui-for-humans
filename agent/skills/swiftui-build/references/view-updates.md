---
id: view-updates
title: How Views Update
platforms: [iOS, iPadOS]
availability: iOS 17.0+, macOS 14.0+, visionOS 1.0+
docs: https://developer.apple.com/documentation/swiftui/model-data.md
---

# How Views Update

See which views run their body again when state changes, and why the rest don't.

Also called: re-render, rerender, render cycle, virtual DOM, reconciliation, diffing, view not updating, refresh, setNeedsDisplay, performance.

## Contents

- Pitfalls
- Guide
- Variants
- Related

## Pitfalls

- **Running `body` isn't redrawing pixels.** SwiftUI compares the result with what's on screen and only touches what's different, much like React's reconciliation.
- **Small views keep updates small.** A child's `body` reruns only when its inputs or the state it reads change, so split big views into parts.

## Guide

A SwiftUI view is a lightweight description, not a thing on screen. When state changes, SwiftUI calls `body` again on the views that depend on it, compares the new description with the old one, and updates only what's different.

**Important:** Keep `body` fast and free of side effects: no network calls and no changing state. SwiftUI may call it at any time, so start work from a button, `.task`, or `.onChange`.

### Debugging updates

When a view updates more than you expect, add `let _ = Self._printChanges()` as the first line of its `body`. Xcode's console then prints what caused each update, such as `Parent: _count changed.`

## Variants

### Values flow down

Each box flashes yellow and counts when its `body` runs; a child reruns only when its input changes.

```swift
struct Parent: View {
    @State private var count = 0
    @State private var name = "Taylor"

    var body: some View {
        VStack {
            HStack {
                Button("count + 1") { count += 1 }
                Button("Rename") { name = name == "Taylor" ? "Sam" : "Taylor" }
            }
            CountView(count: count)
            NameView(name: name)
            Badge()
        }
    }
}

struct CountView: View {
    let count: Int
    var body: some View { Text("count = \(count)") }
}

struct NameView: View {
    let name: String
    var body: some View { Text("name = \(name)") }
}

struct Badge: View {
    var body: some View { Image(systemName: "star.fill") }
}
```

**Note:** The parent reads both values, so it reruns every time. `Badge` takes no inputs, so it never does.

### @Observable tracks what you read

Move the values into an `@Observable` model, and only the view that reads a changed property reruns.

```swift
@Observable
class Model {
    var count = 0
    var name = "Taylor"
}

struct Parent: View {
    @State private var model = Model()

    var body: some View {
        VStack {
            HStack {
                Button("count + 1") { model.count += 1 }
                Button("Rename") { model.name = model.name == "Taylor" ? "Sam" : "Taylor" }
            }
            CountView(model: model) // Reads model.count
            NameView(model: model)  // Reads model.name
        }
    }
}

struct CountView: View {
    let model: Model
    var body: some View { Text("count = \(model.count)") }
}

struct NameView: View {
    let model: Model
    var body: some View { Text("name = \(model.name)") }
}
```

**Note:** The parent passes the model along but never reads `count` or `name` in `body`, so now even the parent stays still.

## Related

[state](state.md), [observable](observable.md), [choosing-wrappers](choosing-wrappers.md), [lifecycle](lifecycle.md)
