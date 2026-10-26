---
id: binding
title: @Binding
platforms: [iOS, iPadOS]
availability: iOS 13.0+, macOS 10.15+, visionOS 1.0+
docs: https://developer.apple.com/documentation/swiftui/binding.md
---

# @Binding

Lets a child view read and write a value its parent owns, so both stay in sync.

Also called: props, two-way binding, v-model, lifting state up, callback, pass state to child, inout, shared value, setter.

## Contents

- Default code
- Pitfalls
- Key APIs
- Variants
- Related

## Default code

```swift
struct WiFiRow: View {
    @Binding var isOn: Bool

    var body: some View {
        Toggle("Wi-Fi", isOn: $isOn)
    }
}

// In the parent, which owns it:
// @State private var isOn = true
// WiFiRow(isOn: $isOn)
```

**Note:** Use `@Binding` only when the child changes the value. If it just shows it, declare a plain `let` and pass the value without `$`.

## Pitfalls

- **A binding stores nothing.** It points at a value someone else owns, usually a parent's `@State`, so there's no copy to keep in sync.
- **It's a prop and its setter in one.** Where React passes `value` and `onChange`, SwiftUI passes a single `$value`.
- **Use `.constant(_:)` in previews.** `Toggle("Wi-Fi", isOn: .constant(true))` makes a binding that never changes, handy in `#Preview`.

## Key APIs

- `@Binding var isOn: Bool`: Declares a value the parent owns and this view can change.
- `$isOn`: Passes a binding to a child or a control.
- `$settings.volume`: A binding to one property of a struct.
- `ForEach($items) { $item in }`: A binding to each element of an array.
- `Binding(get:set:)`: A custom binding that converts or validates on the way.
- `.constant(_:)`: A binding that never changes, for previews.

## Variants

### Bind to a property

Write `$settings.volume` to bind a control to one field of a struct in `@State`.

```swift
struct Settings {
    var volume = 0.5
    var isMuted = false
}

@State private var settings = Settings()

VStack(spacing: 12) {
    Slider(value: $settings.volume)
    Toggle("Mute", isOn: $settings.isMuted)
    Text(settings.isMuted ? "Muted" : "Volume \(Int(settings.volume * 100))%")
        .monospacedDigit()
        .foregroundStyle(.secondary)
}
.frame(maxWidth: 280)
```

### A binding for each row

Pass `$tasks` to `ForEach`, and each row gets a binding to its own element.

```swift
struct TodoItem: Identifiable {
    let id = UUID()
    var title: String
    var isDone = false
}

@State private var tasks = [
    TodoItem(title: "Buy milk"),
    TodoItem(title: "Walk the dog", isDone: true),
    TodoItem(title: "Learn SwiftUI"),
]

VStack(alignment: .leading, spacing: 10) {
    Text("\(tasks.filter(\.isDone).count) of \(tasks.count) done")
        .font(.headline)
    ForEach($tasks) { $task in
        Toggle(task.title, isOn: $task.isDone)
    }
}
.frame(maxWidth: 280)
```

**Note:** Writing `{ $task in }` gives you both names: `task` to read, and `$task` to pass to a control.

### A custom binding

Use `Binding(get:set:)` when a control's value is derived, like a Mute toggle backed by `volume == 0`.

```swift
@State private var volume = 0.6

var body: some View {
    let isMuted = Binding {
        volume == 0
    } set: { muted in
        volume = muted ? 0 : 0.6
    }

    VStack(spacing: 12) {
        Toggle("Mute", isOn: isMuted)
        Slider(value: $volume)
    }
    .frame(maxWidth: 280)
}
```

## Related

[state](state.md), [observable](observable.md), [choosing-wrappers](choosing-wrappers.md), [toggle](toggle.md)
