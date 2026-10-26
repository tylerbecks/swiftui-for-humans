---
id: settings-scene
title: Settings
platforms: [macOS]
availability: macOS 11.0+
docs: https://developer.apple.com/documentation/swiftui/settings.md
hig: https://developer.apple.com/design/human-interface-guidelines/settings.md
---

# Settings

The app's Settings window, opened from the app menu or with ⌘,.

Also called: preferences, settings window, command comma, ⌘,, SettingsLink, openSettings, NSPreferences, options.

## Contents

- Use when
- Built from
- Rules
- Pitfalls
- Key APIs
- Variants
- Related

## Use when

- `Settings` is a scene, like `WindowGroup`.
- It gives your app one Settings window, the Settings… item in the app menu, and ⌘, to open it.
- Put a `Form` inside for a single pane, or a `TabView` to split settings into panes that switch from the window's toolbar.

## Built from

Settings
└── TabView
    ├── Tab("General")
    │   └── Form
    └── Tab("Advanced")
        └── Form

## Rules

- **Open settings from the app menu, not a toolbar button.** People look for Settings… in the app menu and press ⌘,. A gear in the toolbar takes space from the commands people use all the time.
- **Keep it short, and keep task options with the task.** Settings are for things people change rarely. Options like sorting or showing a sidebar belong in the window they affect.
- **Reopen the pane people used last.** People often come back to change a related setting. Store the selected tab with `@AppStorage`, as in the example below.
- **Don't repeat system settings.** Appearance, scrolling, and accessibility belong to System Settings. A copy in your app suggests the system choice doesn't apply.

## Pitfalls

- **You get the menu item and ⌘, for free.** Adding a `Settings` scene puts Settings… in the app menu and wires up the shortcut.
- **Settings is a window like any other.** Use `@AppStorage` so a change shows up in every open window right away.

## Key APIs

- `Settings { }`: The scene for the app's Settings window.
- `TabView`: Inside `Settings`, a toolbar of panes.
- `SettingsLink`: A button that opens the Settings window.
- `@Environment(\.openSettings)`: Opens Settings from your own code.
- `@AppStorage`: Saves a setting and keeps windows in sync.
- `.formStyle(.grouped)`: Rows in rounded groups, like System Settings.

## Variants

### Usage

```swift
@main
struct ReaderApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        Settings {
            SettingsView()
        }
    }
}
```

### One pane

With a handful of settings, use a single grouped `Form` and give the window a fixed width.

```swift
struct SettingsView: View {
    @AppStorage("showsPreview") private var showsPreview = true
    @AppStorage("fontSize") private var fontSize = 14.0

    var body: some View {
        Form {
            Toggle("Show preview", isOn: $showsPreview)
            Slider(value: $fontSize, in: 10...24) {
                Text("Font size")
            }
        }
        .formStyle(.grouped)
        .frame(width: 400)
    }
}
```

**Note:** With one pane, the HIG suggests titling the window “App Name Settings”.

### Panes that remember where you were

A `TabView` inside `Settings` becomes the toolbar of panes. Bind it to `@AppStorage` so it reopens on the last pane.

```swift
enum SettingsPane: String {
    case general, advanced
}

struct SettingsView: View {
    @AppStorage("settingsPane") private var pane = SettingsPane.general

    var body: some View {
        TabView(selection: $pane) {
            Tab("General", systemImage: "gearshape", value: .general) {
                Form { Toggle("Show preview", isOn: .constant(true)) }
            }
            Tab("Advanced", systemImage: "gearshape.2", value: .advanced) {
                Form { Toggle("Enable logging", isOn: .constant(false)) }
            }
        }
        .frame(width: 440)
    }
}
```

### Open Settings from your own UI

Use `SettingsLink` for a button, or `@Environment(\.openSettings)` from code, like a link in an empty state.

```swift
ContentUnavailableView {
    Label("No Accounts", systemImage: "person.crop.circle")
} description: {
    Text("Add an account in Settings to start syncing.")
} actions: {
    SettingsLink {
        Text("Open Settings")
    }
}
```

## Related

[toggle](toggle.md)
