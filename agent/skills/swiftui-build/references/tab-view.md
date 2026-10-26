---
id: tab-view
title: TabView
platforms: [iOS, iPadOS]
availability: iOS 13.0+, macOS 10.15+, visionOS 1.0+
docs: https://developer.apple.com/documentation/swiftui/tabview.md
hig: https://developer.apple.com/design/human-interface-guidelines/tab-bars.md
---

# TabView

Switches between top-level sections with a tab bar, or swipes through pages like a carousel.

Also called: tab bar, tabs, bottom navigation, UITabBarController, carousel, pager, swiper, page control, onboarding pages, bottom nav.

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

- `TabView` owns the app's top-level sections and the tab bar that switches between them.
- Each tab keeps its own state, so people can leave a tab and come back to the same place.
- Use it for three to five main areas, like Home, Search, and Profile.
- With `.tabViewStyle(.page)`, the same view becomes a swipeable carousel.

## Default code

```swift
TabView {
    Tab("Home", systemImage: "house") {
        NavigationStack {
            Text("Home")
                .navigationTitle("Home")
        }
    }
    Tab("Profile", systemImage: "person.crop.circle") {
        Text("Profile")
    }
}
```

**Important:** Put a `NavigationStack` inside each tab, not one around the `TabView`, so every tab keeps its own back history.

## Built from

TabView(selection:)
├── Tab("Home")
│   └── NavigationStack
│       └── Root view
├── Tab("Inbox")
│   └── NavigationStack
└── Tab(role: .search)

## Rules

- **Use tabs to navigate, not to act.** A tab switches sections. An action like New Post belongs in a toolbar button, where people expect to find it.
- **Label tabs with one word.** Short labels fit on every iPhone and are quick to read. Pair each with a filled SF Symbol.
- **Keep the tab bar visible.** Hiding it makes people forget where they are. Only a sheet or full-screen cover should cover it.
- **Use five tabs or fewer on iPhone.** Extra tabs end up behind a More tab, where people rarely find them. Offer a sidebar with `.sidebarAdaptable` for bigger apps.
- **Save badges for things that need attention.** A badge on every tab turns into noise. Use one for unread messages, not for marketing.

## Pitfalls

- **Prefer `Tab` over `.tabItem`.** The `Tab` type (iOS 18) supports search tabs, sections, and sidebars. The older `.tabItem` modifier still works but can't do those.
- **The tab bar floats as Liquid Glass.** `.tabBarMinimizeBehavior(.onScrollDown)` shrinks it while people scroll, and `.tabViewBottomAccessory` adds a bar above it, like Music's mini player.

## Key APIs

- `Tab(_:systemImage:content:)`: One tab with a label and an SF Symbol.
- `TabView(selection:)`: Binds the current tab, so you can switch in code.
- `.badge(_:)`: A red count on a tab.
- `Tab(role: .search)`: A separate search tab at the trailing end.
- `TabSection(_:content:)`: Groups tabs in the iPad sidebar.
- `.tabViewStyle(_:)`: `.sidebarAdaptable` for iPad, or `.page` for a carousel.
- `.tabBarMinimizeBehavior(_:)`: Shrinks the tab bar while people scroll.
- `.tabViewBottomAccessory { }`: A bar above the tabs, like a mini player.

## Variants

### A stack in every tab

Give each `Tab` its own `NavigationStack`, so pushing in one tab doesn't affect the others.

```swift
TabView {
    Tab("Inbox", systemImage: "tray") {
        NavigationStack {
            List(["Lunch on Friday?", "Your order shipped"], id: \.self) { subject in
                NavigationLink(subject) { Text(subject) }
            }
            .navigationTitle("Inbox")
        }
    }
    .badge(2)
    Tab("Settings", systemImage: "gear") {
        NavigationStack {
            List {
                NavigationLink("Notifications") { Text("Notifications") }
            }
            .navigationTitle("Settings")
        }
    }
}
```

**Note:** Push a message in Inbox, switch to Settings and back: Inbox is still on the message.

### Image carousel

Use `.tabViewStyle(.page)` with a fixed height for a swipeable gallery anywhere on a screen.

```swift
TabView {
    ForEach(["mountain.2.fill", "water.waves", "sun.horizon.fill"], id: \.self) { symbol in
        Image(systemName: symbol)
            .font(.system(size: 56))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.teal.gradient)
            .foregroundStyle(.white)
    }
}
.tabViewStyle(.page)
.indexViewStyle(.page(backgroundDisplayMode: .always))
.frame(height: 200)
.clipShape(.rect(cornerRadius: 20))
```

**Note:** `.indexViewStyle(.page(backgroundDisplayMode: .always))` puts a backdrop behind the dots so they show on light images.

### Sidebar on iPad

Use `.tabViewStyle(.sidebarAdaptable)` and `TabSection` to let iPad users turn the tabs into a sidebar.

```swift
TabView {
    Tab("Listen Now", systemImage: "play.circle") {
        Text("Listen Now")
    }
    TabSection("Library") {
        Tab("Artists", systemImage: "music.mic") {
            Text("Artists")
        }
        Tab("Albums", systemImage: "square.stack") {
            Text("Albums")
        }
    }
}
.tabViewStyle(.sidebarAdaptable)
```

## Related

[navigation-stack](navigation-stack.md), [navigation-split-view](navigation-split-view.md), [onboarding](onboarding.md), [toolbar](toolbar.md)
