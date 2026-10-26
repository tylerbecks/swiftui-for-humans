---
id: launching
title: Launching
platforms: [iOS, iPadOS]
availability: iOS 14.0+
docs: https://developer.apple.com/documentation/xcode/specifying-your-apps-launch-screen.md
hig: https://developer.apple.com/design/human-interface-guidelines/launching.md
reviewed: October 2026
---

# Launching

Open fast, look like your first screen, and pick up where people left off.

Also called: launch screen, splash screen, LaunchScreen.storyboard, UILaunchScreen, app startup, app launch, cold start, startup time, state restoration, restore state.

## Contents

- Rules
- Pitfalls
- Guide
- Key APIs
- Variants
- Related

## Rules

- **Make the launch screen match your first screen.** Use the same background and bars, without the content. It makes the app feel ready at once, with no flash when your real screen appears.
- **Leave out text and logos.** The launch screen can't be localized, and it isn't a branding spot. Show a logo only if it's a fixed part of your first screen.
- **Launch instantly; no splash delays.** People want to start right away. If you need a splash, show it as the first step of `onboarding` (swiftui-build skill), not as a timer on every launch.
- **Restore where people left off.** Reopen the same tab, screen, and scroll position, so nobody has to retrace their steps.
- **Don't greet people with an alert or a prompt.** Show problems, like being offline, inside the screen, and ask for [permissions](requesting-permission.md) when a feature needs them.

## Pitfalls

- **The launch screen isn't SwiftUI.** It's an Info.plist entry or a storyboard that the system draws before any of your code runs, so it can't animate or show live data.
- **Slow launches get killed.** On iOS, the system's watchdog ends an app that takes too long to launch. Move work out of `init` and into `.task`.
- **Every app needs one.** As of iOS 27 and iPadOS 27, Apple's technote TN3192 says a launch screen is required for App Store submission.
- **`@SceneStorage` is for small UI state.** Keep model data and anything sensitive out of it. It's also gone if people close the window or remove it from the app switcher.

## Guide

Launching runs from the tap on your icon until your first screen is ready. iOS shows your launch screen instantly, then swaps in your first screen. The goal is for that swap to go unnoticed: a launch screen that looks like the app, a first screen that shows up fast, and the same place people left.

## Key APIs

- `UILaunchScreen`: Info.plist launch screen: color, image, bars.
- `UILaunchStoryboardName`: A storyboard launch screen instead.
- `@SceneStorage`: Restores small UI state per window.
- `.task { }`: Starts loading after the first frame.
- `@Environment(\.scenePhase)`: Tells you when the app goes inactive.

## Variants

### A launch screen in Info.plist

Add a `UILaunchScreen` dictionary with your background color and the bars your first screen has.

```xml
<!-- Info.plist -->
<key>UILaunchScreen</key>
<dict>
    <key>UIColorName</key>
    <string>LaunchBackground</string>
    <key>UINavigationBar</key>
    <dict/>
    <key>UITabBar</key>
    <dict/>
</dict>
```

**Note:** `UIColorName` names a color in your asset catalog. Leave it out and the system uses the standard background, which follows light and dark mode.

### Restore the last tab

Use `@SceneStorage` instead of `@State` for the selected tab, and SwiftUI brings it back on the next launch.

```swift
@SceneStorage("selectedTab") private var selectedTab = "today"

TabView(selection: $selectedTab) {
    Tab("Today", systemImage: "sun.max", value: "today") {
        Text("Today")
    }
    Tab("Library", systemImage: "books.vertical", value: "library") {
        Text("Library")
    }
}
```

### Show the screen, then load

Draw the first screen right away and start slow work in `.task`, with [placeholders](loading.md) while it runs.

```swift
struct ExpensesScreen: View {
    @State private var expenses: [String] = []
    @State private var isLoading = true

    var body: some View {
        List(isLoading ? ["Placeholder row", "Placeholder row"] : expenses, id: \.self) {
            Text($0)
        }
        .redacted(reason: isLoading ? .placeholder : [])
        .task {
            // Not in init: the screen is already on display.
            try? await Task.sleep(for: .seconds(1))
            expenses = ["Lunch", "Train ticket"]
            isLoading = false
        }
    }
}
```

## Related

`onboarding` (swiftui-build skill), [loading](loading.md), [requesting-permission](requesting-permission.md), `tab-view` (swiftui-build skill), `lifecycle` (swiftui-build skill)
