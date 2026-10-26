---
id: loading
title: Loading
platforms: [iOS, iPadOS]
availability: iOS 17.0+
docs: https://developer.apple.com/documentation/swiftui/view/redacted(reason:).md
hig: https://developer.apple.com/design/human-interface-guidelines/loading.md
reviewed: October 2026
---

# Loading

Show something right away, then swap in the content, an empty state, or an error.

Also called: loading state, skeleton, skeleton screen, shimmer, spinner, activity indicator, placeholder, Suspense, useEffect fetch, fetch data.

## Contents

- Rules
- Pitfalls
- Guide
- Key APIs
- Variants
- Related

## Rules

- **Show something right away.** A blank screen looks broken. Draw the layout with placeholders and fill it in as data arrives.
- **Say how long, and what's happening.** When you know the size of the work, use a bar instead of a spinner, and label it with what's happening. A plain “Loading” tells people nothing.
- **Let people keep going while they wait.** Load in the background and keep the rest of the app usable. If stopping is safe, offer a Cancel button.
- **Keep progress moving, and stay on one style.** A frozen bar reads as a frozen app, so explain any stall. Don't morph a spinner into a bar; they're different shapes.

## Pitfalls

- **It's a skeleton screen, built in.** `.redacted(reason: .placeholder)` turns your real layout into gray shapes, so you don't build a second, fake version of the screen.
- **`.task` is `useEffect` with cleanup for free.** It starts before the view appears and SwiftUI cancels it when the view goes away.
- **Refresh on your own, too.** Pull to refresh with `.refreshable` is welcome, but people expect content to update without having to ask every time.

## Guide

Every screen that fetches data has four states: loading, loaded, empty, and failed. Plan all four up front. Show the layout right away with placeholders, then swap in the content, an empty message, or an error with a way to try again.

Tap **Reload** to watch the screen load, or pick a state to see each one.

```swift
enum LoadState<Value> {
    case loading
    case loaded(Value)
    case failed(Error)
}

struct OrdersView: View {
    @State private var state: LoadState<[String]> = .loading

    var body: some View {
        Group {
            switch state {
            case .loading:
                List(0..<4, id: \.self) { _ in
                    Text("Placeholder order")
                }
                .redacted(reason: .placeholder)
            case .loaded(let orders) where orders.isEmpty:
                ContentUnavailableView(
                    "No Orders",
                    systemImage: "bag",
                    description: Text("Orders you place appear here.")
                )
            case .loaded(let orders):
                List(orders, id: \.self) { Text($0) }
            case .failed:
                ContentUnavailableView {
                    Label("Couldn't Load Orders", systemImage: "wifi.exclamationmark")
                } description: {
                    Text("Check your connection and try again.")
                } actions: {
                    Button("Try Again") { Task { await load() } }
                }
            }
        }
        .task { await load() }
    }

    func load() async {
        state = .loading
        do {
            state = .loaded(try await fetchOrders())
        } catch {
            // If the view went away, there's nothing to show.
            if !Task.isCancelled { state = .failed(error) }
        }
    }

    func fetchOrders() async throws -> [String] {
        try await Task.sleep(for: .seconds(1))
        return ["Coffee beans", "Oat milk"]
    }
}
```

**Important:** SwiftUI cancels `.task` when the view disappears, and a fetch that respects cancellation then throws. Check `Task.isCancelled` before you show an error, or people see “Couldn't load” for a screen they just left.

## Key APIs

- `.task { }`: Runs async work as the view appears.
- `.task(id:) { }`: Cancels and restarts the work when `id` changes.
- `.redacted(reason: .placeholder)`: Draws views as gray placeholders.
- `ProgressView(value:total:)`: A bar that fills as work completes.
- `ProgressView()`: A spinner, for work of unknown length.
- `ContentUnavailableView`: Empty and error states with an action.
- `.refreshable { }`: Adds pull to refresh to a `List`.

## Variants

### Placeholders

Add `.redacted(reason: .placeholder)` to real rows with sample data to get a skeleton of the screen.

```swift
@State private var isLoading = true

VStack(alignment: .leading, spacing: 12) {
    Label("Coffee beans, 1 kg", systemImage: "bag")
    Label("Oat milk, 6 pack", systemImage: "bag")
    Label("Paper filters", systemImage: "bag")
}
.redacted(reason: isLoading ? .placeholder : [])

Toggle("Loading", isOn: $isLoading)
```

### Progress you can measure

Use `ProgressView(value:total:)` with a label when you know how much work is left.

```swift
@State private var done = 0

ProgressView(value: Double(done), total: 12) {
    Text("Downloading photos")
} currentValueLabel: {
    Text("\(done) of 12")
}
.task {
    while done < 12 {
        do { try await Task.sleep(for: .seconds(0.4)) } catch { return }
        done += 1
    }
}
```

**Note:** Pace the bar evenly. Jumping to 90% and then sitting there for minutes feels like the app is stuck.

## Related

`progress-view` (swiftui-build skill), `empty-state` (swiftui-build skill), `async-image` (swiftui-build skill), `lifecycle` (swiftui-build skill), [launching](launching.md), [feedback](feedback.md)
