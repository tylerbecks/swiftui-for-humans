---
id: settings-window
title: Settings window
platforms: [macOS]
availability: macOS 15.0+
docs: https://developer.apple.com/documentation/swiftui/settings.md
hig: https://developer.apple.com/design/human-interface-guidelines/settings.md
---

# Settings window

A Settings window with a toolbar of panes, ready to copy into your app.

Also called: preferences, preferences window, settings panes, settings tabs, ⌘,, command comma, AppStorage, UserDefaults, options, NSPreferencePane.

## Contents

- Built from
- Rules
- Pitfalls
- Key APIs
- Variants
- Related

## Built from

Settings
└── SettingsView
    └── TabView(selection:)
        ├── Tab("General")
        │   └── Form
        ├── Tab("Accounts")
        │   └── List + add and remove
        └── Tab("Advanced")
            └── Form

## Rules

- **Don't copy system settings.** Scrolling, accessibility, and sign-in methods belong to System Settings. A copy in your app suggests the system choice doesn't apply.
- **Offer as few settings as you can.** Good defaults mean most people never open the window. Every extra option makes the one people want harder to find.
- **Keep the toolbar of panes still.** Don't let people customize it or hide it, and always show which pane is active. People find settings by where they are.
- **Reopen the last pane.** People often come back to adjust a related setting. Bind the `TabView` to `@AppStorage`, as the block does.
- **Leave task options in the window.** Sorting, filters, and showing a sidebar belong next to the content they change, not in Settings.

## Pitfalls

- **`@AppStorage` keeps every window in sync.** A setting changed here shows up in your other windows right away, and it's saved for the next launch.
- **The `TabView` becomes the toolbar.** Inside `Settings`, its tabs turn into the toolbar of panes, so you don't build that toolbar yourself.

## Key APIs

`Settings { }`, `TabView(selection:)`, `Tab(_:systemImage:value:)`, `@AppStorage`, `.formStyle(.grouped)`, `SettingsLink`

## Variants

### General, Accounts, and Advanced

Add `Settings { SettingsView() }` to your `App`. The `TabView` inside becomes the toolbar of panes.

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

enum SettingsPane: String {
    case general, accounts, advanced
}

struct SettingsView: View {
    @AppStorage("settingsPane") private var pane = SettingsPane.general

    var body: some View {
        TabView(selection: $pane) {
            Tab("General", systemImage: "gearshape", value: .general) {
                GeneralSettingsView()
            }
            Tab("Accounts", systemImage: "at", value: .accounts) {
                AccountsSettingsView()
            }
            Tab("Advanced", systemImage: "gearshape.2", value: .advanced) {
                AdvancedSettingsView()
            }
        }
        .frame(width: 460)
    }
}

enum RefreshInterval: String, CaseIterable, Identifiable {
    case hourly = "Every hour"
    case daily = "Every day"
    case manually = "Manually"

    var id: Self { self }
}

struct GeneralSettingsView: View {
    @AppStorage("refreshInterval") private var refreshInterval = RefreshInterval.hourly
    @AppStorage("opensLinksInBackground") private var opensLinksInBackground = false
    @AppStorage("fontSize") private var fontSize = 14.0

    var body: some View {
        Form {
            Picker("Check for new articles", selection: $refreshInterval) {
                ForEach(RefreshInterval.allCases) { interval in
                    Text(interval.rawValue).tag(interval)
                }
            }
            Toggle("Open links in the background", isOn: $opensLinksInBackground)
            Slider(value: $fontSize, in: 10...24) {
                Text("Font size")
            }
        }
        .formStyle(.grouped)
    }
}

struct AccountsSettingsView: View {
    @State private var accounts = ["sam@example.com", "work@example.com"]
    @State private var selection: String?

    var body: some View {
        Form {
            Section {
                List(accounts, id: \.self, selection: $selection) { account in
                    Label(account, systemImage: "person.crop.circle")
                }
                .frame(height: 120)
            } footer: {
                HStack {
                    Button("Add Account", systemImage: "plus") {
                        accounts.append("new@example.com")
                    }
                    Button("Remove Account", systemImage: "minus") {
                        accounts.removeAll { $0 == selection }
                    }
                    .disabled(selection == nil)
                }
                .labelStyle(.iconOnly)
                .buttonStyle(.borderless)
            }
        }
        .formStyle(.grouped)
    }
}

struct AdvancedSettingsView: View {
    @AppStorage("showsDebugMenu") private var showsDebugMenu = false

    var body: some View {
        Form {
            Toggle("Show Debug menu", isOn: $showsDebugMenu)
            LabeledContent("Cache") {
                Button("Clear Cache") { }
            }
        }
        .formStyle(.grouped)
    }
}
```

### Open a pane from elsewhere

```swift
struct AddAccountButton: View {
    @AppStorage("settingsPane") private var pane = SettingsPane.general
    @Environment(\.openSettings) private var openSettings

    var body: some View {
        Button("Add an Account…") {
            pane = .accounts
            openSettings()
        }
    }
}
```

## Related

[settings-scene](settings-scene.md), `settings-pattern` (apple-design skill), [form](form.md), [toggle](toggle.md), [picker](picker.md)
