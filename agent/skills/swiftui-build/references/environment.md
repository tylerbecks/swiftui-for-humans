---
id: environment
title: @Environment
platforms: [iOS, iPadOS, macOS]
availability: iOS 13.0+, macOS 10.15+, visionOS 1.0+
docs: https://developer.apple.com/documentation/swiftui/environment.md
---

# @Environment

Reads values the system or an ancestor passes down, like dark mode or the locale.

## Contents

- Default code
- Pitfalls
- Key APIs
- Variants
- On macOS
- Related

## Default code

```swift
@Environment(\.colorScheme) private var colorScheme

var body: some View {
    Text(colorScheme == .dark ? "Good night" : "Good morning")
}
```

**Note:** It works like React's `useContext`: any view reads what an ancestor or the system set, without props through every layer.

## Pitfalls

- **Values flow down, never up.** `.environment(\.key, value)` changes a value for that view and everything inside it, not for parents or siblings. `.font()`, `.tint()`, and `.disabled()` work the same way.
- **Mark environment properties `private`.** The view reads them itself; nobody passes them in.
- **A missing model crashes.** `@Environment(Model.self)` stops the app if no ancestor called `.environment(model)`. Declare it as `Model?` when it might be absent. See [@Observable](observable.md).

## Key APIs

`@Environment(\.colorScheme)`, `.environment(\.key, value)`, `@Entry var name = default`, `.environment(model)`, `@Environment(Model.self)`

## Variants

### Close a sheet with dismiss

Read `dismiss` inside a sheet to close it, without a binding from the parent.

```swift
struct ContentView: View {
    @State private var isShowingSheet = false

    var body: some View {
        Button("Open sheet") { isShowingSheet = true }
            .buttonStyle(.borderedProminent)
            .sheet(isPresented: $isShowingSheet) {
                SheetContent()
            }
    }
}

struct SheetContent: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 16) {
            Text("All set!")
                .font(.title2.bold())
            Button("Done") { dismiss() }
                .buttonStyle(.borderedProminent)
        }
        .presentationDetents([.height(200)])
    }
}
```

**Note:** Some environment values are actions you call like functions, such as `dismiss()` and `openURL(url)`.

## On macOS

Values that flow down from a window to every view inside it, from control size to actions.

### Pitfalls

- **It only flows down.** A value you set applies to that view and the views inside it. Parents and siblings never see it.
- **Prefer the dedicated modifier.** Write `.controlSize(.small)` rather than `.environment(\.controlSize, .small)`, and give your own values a modifier too.
- **Actions live here too.** `openWindow`, `dismissWindow`, and `openSettings` are values you call like functions.

### Key APIs

`@Environment(\.controlSize)`, `\.openWindow`, `\.openSettings`, `\.appearsActive`, `\.dismissWindow`

### Variants

#### Open another window

Read `openWindow` and call it with the ID of a `Window` or `WindowGroup` in your app. This one opens a real window.

```swift
@main
struct ReaderApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        Window("Activity", id: "activity") {
            ActivityView()
        }
    }
}

struct ShowActivityButton: View {
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        Button("Show Activity") {
            openWindow(id: "activity")
        }
    }
}
```

**Note:** A `Window` also gets an item in the Window menu, so people can reopen it without your button.

#### Open Settings from your own button

Call `openSettings` to show your Settings window, for example from an empty state. This one opens this app's Settings.

```swift
struct AccountsEmptyState: View {
    @Environment(\.openSettings) private var openSettings

    var body: some View {
        ContentUnavailableView {
            Label("No Accounts", systemImage: "person.crop.circle")
        } actions: {
            Button("Add an Account…") {
                openSettings()
            }
        }
    }
}
```

#### Look inactive when the window isn't key

Read `appearsActive` in custom views and drop the accent color when it's false. Click another window to see this badge turn gray.

```swift
struct LiveBadge: View {
    @Environment(\.appearsActive) private var appearsActive

    var body: some View {
        Label("Live", systemImage: "dot.radiowaves.left.and.right")
            .font(.callout.weight(.semibold))
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .foregroundStyle(appearsActive ? .white : .secondary)
            .background(appearsActive ? Color.accentColor : Color.secondary.opacity(0.2), in: .capsule)
    }
}
```

**Note:** Selection in lists and tables turns gray on its own. Views and styles you draw yourself need to check `appearsActive`.

More variants, left out to keep this file short: Your own value with @Entry, Respect Reduce Motion, Your own value with @Entry (macOS). Apple's docs: https://developer.apple.com/documentation/swiftui/environment.md

## Related

[observable](observable.md), [choosing-wrappers](choosing-wrappers.md), [binding](binding.md), [sheet](sheet.md), [state-binding](state-binding.md), [opening-windows](opening-windows.md), [settings-scene](settings-scene.md), [button](button.md)
