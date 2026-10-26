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

More variants, left out to keep this file short: General, Accounts, and Advanced, Open a pane from elsewhere. Apple's docs: https://developer.apple.com/documentation/swiftui/settings.md

## Related

[settings-scene](settings-scene.md), [settings-pattern](settings-pattern.md), [form](form.md), [toggle](toggle.md), [picker](picker.md)
