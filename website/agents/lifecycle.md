---
id: lifecycle
title: View Lifecycle
platforms: [iOS, iPadOS]
availability: iOS 17.0+, macOS 14.0+, visionOS 1.0+
docs: https://developer.apple.com/documentation/swiftui/view/onappear(perform:).md
hig: https://developer.apple.com/design/human-interface-guidelines/loading.md
---

# View Lifecycle

Run code when a view appears, load data with task, and react to changes with onChange.

Also called: useEffect, componentDidMount, viewDidLoad, viewWillAppear, mounted, watch, fetch on load, debounce, lifecycle hooks, onDisappear.

## Contents

- Default code
- Rules
- Pitfalls
- Key APIs
- Variants
- Related

## Default code

```swift
@State private var quote = "Loading…"

var body: some View {
    Text(quote)
        .task {
            try? await Task.sleep(for: .seconds(1)) // Pretend to load
            quote = "Less, but better."
        }
}
```

**Note:** `.task` is `useEffect` without the cleanup function. SwiftUI cancels the work for you when the view goes away.

## Rules

- **Show something right away.** A blank screen looks broken. Show the layout with placeholder content, then fill it in when `.task` finishes.
- **Keep the screen usable while it loads.** Load in `.task` so people can still scroll, search, or go back. Don't cover the whole screen with a spinner that blocks every tap.
- **Show progress for longer waits.** Use `ProgressView()` when you can't tell how long it will take, and `ProgressView(value:)` when you can.

## Pitfalls

- **`onAppear` can run many times.** It fires each time the view comes back on screen, such as after switching tabs or navigating back. It isn't a constructor.
- **Keep side effects out of `init` and `body`.** SwiftUI calls them far more often than the view appears, so start work from `.task`, `.onChange`, or a button.

## Key APIs

- `.task { }`: Runs `async` work on appear; cancelled when the view goes away.
- `.task(id:) { }`: Cancels and restarts the work whenever `id` changes.
- `.onAppear { }`: Runs code each time the view appears.
- `.onDisappear { }`: Runs code when the view leaves the screen.
- `.onChange(of:initial:)`: Runs code when a value changes, with old and new values.
- `.refreshable { }`: Adds pull to refresh to a `List` or `ScrollView`.

## Variants

### Load data when a view appears

Show a placeholder, then fill it in from `.task(id:)` so a Reload button can restart it.

```swift
@State private var quote: String?
@State private var reloadID = 0

func loadQuote() async -> String {
    try? await Task.sleep(for: .seconds(1)) // Pretend network call
    return ["Stay hungry.", "Ship it.", "Less, but better."].randomElement()!
}

VStack(spacing: 16) {
    if let quote {
        Text(quote)
            .font(.title3.bold())
    } else {
        ProgressView()
    }
    Button("Reload") { reloadID += 1 }
}
.frame(height: 100)
.task(id: reloadID) {
    quote = nil
    quote = await loadQuote()
}
```

**Note:** Changing the `id` cancels the running task and starts a new one, so a reload never races an older load.

### Search as you type

Use `.task(id: query)` to cancel the previous search each time the text changes.

```swift
@State private var query = ""
@State private var results: [String] = []
let fruits = ["Apple", "Apricot", "Banana", "Blueberry", "Cherry", "Grape", "Mango", "Peach"]

VStack(alignment: .leading, spacing: 10) {
    TextField("Search fruit", text: $query)
        .textFieldStyle(.roundedBorder)
        .autocorrectionDisabled()
    Text(results.isEmpty ? "No matches" : results.joined(separator: ", "))
        .foregroundStyle(.secondary)
}
.frame(maxWidth: 280)
.task(id: query) {
    do {
        try await Task.sleep(for: .milliseconds(400)) // Debounce
    } catch {
        return // Cancelled: the user kept typing
    }
    results = fruits.filter { query.isEmpty || $0.localizedCaseInsensitiveContains(query) }
}
```

**Note:** Sleeping first debounces the search: it runs only once typing pauses. A cancelled sleep throws, which ends the old task.

### Keep related values in sync

Use `.onChange(of:)` to update one value when another changes, like Airplane Mode turning Wi-Fi off.

```swift
@State private var isAirplaneMode = false
@State private var isWiFiOn = true

VStack(spacing: 12) {
    Toggle("Airplane Mode", systemImage: "airplane", isOn: $isAirplaneMode)
    Toggle("Wi-Fi", systemImage: "wifi", isOn: $isWiFiOn)
}
.frame(maxWidth: 280)
.onChange(of: isAirplaneMode) { _, isOn in
    if isOn {
        withAnimation { isWiFiOn = false }
    }
}
```

**Important:** `onChange` doesn't run for the starting value. Pass `initial: true` if it should also run when the view appears.

## Related

[state](state.md), [view-updates](view-updates.md), [searchable](searchable.md), [progress-view](progress-view.md)
