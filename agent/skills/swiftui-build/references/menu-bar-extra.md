---
id: menu-bar-extra
title: MenuBarExtra
platforms: [macOS]
availability: macOS 13.0+
docs: https://developer.apple.com/documentation/swiftui/menubarextra.md
hig: https://developer.apple.com/design/human-interface-guidelines/the-menu-bar.md
---

# MenuBarExtra

A menu bar icon that opens a menu or a small window, whichever app is in front.

Also called: menu bar extra, status item, status bar item, NSStatusItem, NSStatusBar, menu bar app, menulet, tray icon, system tray, LSUIElement.

## Contents

- Use when
- Built from
- Rules
- Pitfalls
- Key APIs
- Variants
- Related

## Use when

- `MenuBarExtra` is a scene that puts an icon at the trailing end of the menu bar.
- It stays there while your app runs, even when another app is in front.
- Clicking it shows a menu, or with `.menuBarExtraStyle(.window)`, a small window of controls.
- Add it beside your `WindowGroup`, or make it the only scene for an app that lives in the menu bar.

## Built from

App
├── WindowGroup
└── MenuBarExtra("Weather", systemImage:)
    └── Button, Toggle, Divider…

## Rules

- **Use a symbol for the icon.** The system tints a symbol or template image so it suits light and dark menu bars and the selected state. A full-color picture can't adapt.
- **Show a menu, not a popover.** A menu is what people expect from a menu bar icon. Save the `.window` style for features too rich for a menu.
- **Let people decide whether it appears.** Add a setting to turn it on or off in your Settings window, and consider offering the choice during setup.
- **Don't count on it being visible.** The system hides menu bar extras when space runs short. Offer the same features somewhere else too, like a Dock menu.

## Pitfalls

- **Removing it quits a menu bar–only app.** If the extra is the app's only scene and someone removes it from the menu bar, the system ends the app.
- **The menu bar is 24 points tall.** Size a custom icon to fit, or use an SF Symbol, which already does.

**Note:** A menu bar extra is a scene, so a page can't add one to this app. The previews below are drawings with live content; the code is the real thing.

## Key APIs

- `MenuBarExtra(_:systemImage:) { }`: An icon and title, with a menu.
- `MenuBarExtra(…, isInserted:)`: Shown only while the binding is true.
- `.menuBarExtraStyle(.menu)`: The content as a menu that pulls down.
- `.menuBarExtraStyle(.window)`: The content in a small, popover-like window.
- `@Environment(\.openWindow)`: Opens one of your app's windows from the menu.
- `LSUIElement`: Info.plist key that hides the Dock icon.

## Variants

### Usage

```swift
@main
struct WeatherApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        MenuBarExtra("Weather", systemImage: "cloud.sun") {
            Button("Refresh") { }
            Divider()
            Button("Open Weather") { }
        }
    }
}
```

### A menu

By default, the content is a menu that pulls down from the icon. Use buttons, toggles, and dividers, as in any menu.

```swift
@State private var isPaused = false

MenuBarExtra("Timer", systemImage: "timer") {
    Button("Start Focus Session") { }
    Toggle("Pause Notifications", isOn: $isPaused)
    Divider()
    SettingsLink {
        Text("Settings…")
    }
}
```

### A small window

With `.menuBarExtraStyle(.window)`, the content shows in a popover-like window, laid out like controls in a normal window.

```swift
MenuBarExtra("Weather", systemImage: "cloud.sun") {
    WeatherPanel()
}
.menuBarExtraStyle(.window)

struct WeatherPanel: View {
    @State private var usesCelsius = true

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("18°  Partly Cloudy", systemImage: "cloud.sun")
                .font(.title2)
            Gauge(value: 0.4) { Text("Rain") }
            Toggle("Celsius", isOn: $usesCelsius)
        }
        .padding()
        .frame(width: 240)
    }
}
```

### Let people turn it off

Pass `isInserted:` a binding, like an `@AppStorage` value, and put a toggle for it in your Settings window.

```swift
@main
struct WeatherApp: App {
    @AppStorage("showsInMenuBar") private var showsInMenuBar = true

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        MenuBarExtra("Weather", systemImage: "cloud.sun", isInserted: $showsInMenuBar) {
            Button("Refresh") { }
        }
        Settings {
            Form {
                Toggle("Show in menu bar", isOn: $showsInMenuBar)
            }
            .padding()
        }
    }
}
```

### An app that lives in the menu bar

```swift
@main
struct ClipboardApp: App {
    var body: some Scene {
        MenuBarExtra("Clipboard", systemImage: "list.clipboard") {
            ClipboardMenu()
        }
    }
}
```

## Related

[menu-bar-utility](menu-bar-utility.md), [settings-scene](settings-scene.md), [window](window.md), [commands](commands.md), `menu-bar-conventions` (apple-design skill)
