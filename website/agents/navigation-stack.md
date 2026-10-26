---
id: navigation-stack
title: NavigationStack
platforms: [iOS, iPadOS, macOS]
availability: iOS 16.0+, macOS 13.0+, visionOS 1.0+
docs: https://developer.apple.com/documentation/swiftui/navigationstack.md
hig: https://developer.apple.com/design/human-interface-guidelines/navigation-and-search.md
---

# NavigationStack

Pushes screens on top of each other with a back button, like drilling into a folder.

## Contents

- Use when
- Default code
- Built from
- Rules
- Pitfalls
- Key APIs
- Variants
- On macOS
- Related

## Use when

- `NavigationStack` owns a stack of screens and the navigation bar above them.
- Each push slides a new screen in with a Back button, and the stack remembers the way back.
- Use it for drill-down hierarchies like Settings or Mail.
- For a sidebar on iPad, use `NavigationSplitView`.
- For top-level sections, put one stack in each tab of a `TabView`.

## Default code

```swift
NavigationStack {
    List(fruits, id: \.self) { fruit in
        NavigationLink(fruit, value: fruit)
    }
    .navigationTitle("Fruits")
    .navigationDestination(for: String.self) { fruit in
        Text(fruit)
    }
}
```

**Important:** Put `.navigationTitle`, `.toolbar`, and `.navigationDestination` on the views inside the stack, not on the `NavigationStack` itself.

## Built from

NavigationStack
└── Root view (a List)
    ├── NavigationLink(value:)
    ├── .navigationTitle
    ├── .toolbar
    └── .navigationDestination
        └── Destination view

## Rules

- **Keep titles short.** Aim for a word or two, under 15 characters, so the bar has room for buttons. Don't use your app's name as a title; it doesn't tell people where they are.
- **Use a large title at the top of a hierarchy.** It tells people where they are, and it shrinks into the bar as they scroll. Pushed screens usually use `.inline`.
- **Keep the standard Back button.** People know it retraces their steps. Don't replace it with a custom “Back” label or hide it unless the screen offers another way out.
- **Put only the most important actions in the bar.** iPhone has room for a few. Move the rest into a More menu with `Menu` in the toolbar.

## Pitfalls

- **Navigate in code with a path.** Bind the stack to an array: append to push, `removeLast()` to go back, and set it to `[]` to pop to the root. A deep link is just a path.
- **Use one stack per tab, and never nest them.** A `NavigationStack` inside another one leads to double bars and links that don't work.
- **`NavigationView` is deprecated.** Use `NavigationStack`, or `NavigationSplitView` for a sidebar.

## Key APIs

`NavigationStack(path:)`, `NavigationLink(_:value:)`, `.navigationDestination(for:)`, `.navigationDestination(item:)`, `.navigationTitle(_:)`, `.navigationBarTitleDisplayMode(_:)`, `.toolbar { }`

## Variants

### Routes with an enum

Model each screen as an enum case, and map them all in one `.navigationDestination`, like a route table.

```swift
enum Route: Hashable {
    case profile(String)
    case settings
}

@State private var path: [Route] = []

NavigationStack(path: $path) {
    List {
        NavigationLink("Maya's profile", value: Route.profile("Maya"))
        NavigationLink("Settings", value: Route.settings)
    }
    .navigationTitle("Home")
    .navigationDestination(for: Route.self) { route in
        switch route {
        case .profile(let name): Text("Profile of \(name)")
        case .settings: Text("Settings")
        }
    }
}
```

**Important:** Every value type you push needs a matching `.navigationDestination(for:)` inside the stack. Without one, the link does nothing.

### Present a detail from a selection

Use `.navigationDestination(item:)` when a button, not a link, decides where to go.

```swift
@State private var selected: String?

NavigationStack {
    VStack(spacing: 12) {
        Button("Open Report") { selected = "Report" }
        Button("Open Invoice") { selected = "Invoice" }
    }
    .buttonStyle(.bordered)
    .navigationTitle("Documents")
    .navigationDestination(item: $selected) { name in
        Text(name)
            .font(.largeTitle)
    }
}
```

## On macOS

Push views inside a window, with a Back button in the toolbar.

### Rules

- **Use the standard Back button.** People know it from every other app. Use the system's symbol, not a text label that says Back.
- **Give every level a short title.** The title tells people where they are as they drill down. Aim for a word or two.

### Pitfalls

- **A link needs a destination for its type.** `NavigationLink(value:)` does nothing until a `navigationDestination(for:)` for that type is somewhere in the stack.
- **Save the path to restore it.** If every value is `Codable`, `NavigationPath.codable` gives you something to store and decode at the next launch.

### Key APIs

`NavigationStack { }`, `NavigationPath`, `path.removeLast()`

### Variants

#### Usage

```swift
let parks = ["Yosemite", "Zion", "Acadia"]

NavigationStack {
    List(parks, id: \.self) { park in
        NavigationLink(park, value: park)
    }
    .navigationDestination(for: String.self) { park in
        Text(park)
            .navigationTitle(park)
    }
    .navigationTitle("Parks")
}
```

More variants, left out to keep this file short: Push with links and destinations (macOS), Control the stack with a path (macOS), Different kinds of values (macOS), In a split view (macOS). Apple's docs: https://developer.apple.com/documentation/swiftui/navigationstack.md

## Related

[navigation-split-view](navigation-split-view.md), [list](list.md), [toolbar](toolbar.md), [tab-view](tab-view.md), [state-binding](state-binding.md), [opening-windows](opening-windows.md)
