---
id: settings-pattern
title: What goes in Settings
platforms: [macOS]
availability: macOS 11.0+
docs: https://developer.apple.com/documentation/swiftui/settings.md
hig: https://developer.apple.com/design/human-interface-guidelines/settings.md
reviewed: October 2026
---

# What goes in Settings

Keep rare, app-wide options in Settings, and task options in the window they affect.

Also called: preferences, options, app settings, settings window, ⌘,, Command-Comma, view options, defaults, configuration, document settings.

## Contents

- Rules
- Pitfalls
- Guide
- Key APIs
- Variants
- Related

## Rules

- **Pick defaults that work for most people.** With good defaults, most people never need to open Settings before they get going.
- **Keep Settings short.** Every option makes the window harder to scan and the app feel less approachable. Cut the ones few people change.
- **Keep task options with the task.** Sorting, filtering, and showing parts of a view belong in the window, where people see the result right away.
- **Don't copy system settings.** Appearance, scrolling, and accessibility are set for the whole Mac. A copy in your app suggests the system choice doesn't apply.
- **Don't ask for what you can find out.** Read whether the Mac is in Dark Mode, or which devices are connected, instead of making people tell you.

## Pitfalls

- **Building the window is a separate page.** Settings (`settings-scene`, swiftui-build skill) shows the `Settings` scene, panes, and `SettingsLink` in code.
- **People already know ⌘,.** It opens Settings in nearly every Mac app, and adding a `Settings` scene wires it up for you.

## Guide

A Mac app's **Settings window** opens from Settings… in the app menu or with ⌘,. It's for general options that affect the whole app and that people change rarely, like accounts or the default font for new documents. People have to stop what they're doing to open it, so anything they adjust while working belongs in the window instead.

### Where does it go?

Pick a home for each option in a notes app.

### The Settings window itself

When you do need one, the HIG asks for a few things on the Mac:

- Open it from the app menu: Put Settings… in the app menu, with ⌘, as its shortcut, rather than a button in the toolbar.
- Panes in a toolbar that stays put: Switch between groups of settings with toolbar buttons that people can't customize, and always show which pane is active.
- Title it after the pane: Show the current pane's name, or “App Name Settings” for a window with one pane.
- Come back to the last pane: People often adjust related settings more than once.
- Dim minimize and zoom: People reopen it quickly with ⌘,, and it sizes itself to the pane.

## Key APIs

- `Settings { }`: The scene behind Settings… and ⌘,.
- `@AppStorage`: Saves a setting and updates every window.
- `SettingsLink`: A button that opens the Settings window.
- `CommandGroup(after: .saveItem)`: A home for document options in File.
- `\.colorScheme`: Detects light or dark instead of asking.

## Variants

### View options in the toolbar

Put a `Picker` in a toolbar `Menu`, so people change the sort order where they see the result.

```swift
enum SortOrder: String, CaseIterable {
    case date = "Date Edited"
    case title = "Title"
}

@State private var sort = SortOrder.date

NavigationStack {
    NotesList(sort: sort)
        .toolbar {
            Menu("Sort", systemImage: "arrow.up.arrow.down") {
                Picker("Sort By", selection: $sort) {
                    ForEach(SortOrder.allCases, id: \.self) { order in
                        Text(order.rawValue)
                    }
                }
            }
        }
}
```

**Note:** A real `.toolbar` here would land in this app's own toolbar, so the preview draws the window.

### Document options in the File menu

Put options that belong to one document in the File menu with `CommandGroup(after: .saveItem)`, not in Settings.

```swift
DocumentGroup(newDocument: NoteDocument()) { file in
    NoteEditor(document: file.$document)
}
.commands {
    CommandGroup(after: .saveItem) {
        Button("Document Settings…") { }
    }
}
```

### Detect instead of asking

Read `colorScheme` and follow the Mac's appearance, rather than adding a light and dark choice of your own.

```swift
@Environment(\.colorScheme) private var colorScheme

Label(
    colorScheme == .dark ? "Night chart" : "Day chart",
    systemImage: colorScheme == .dark ? "moon.stars" : "sun.max"
)
```

## Related

`settings-scene` (swiftui-build skill), [menu-bar-conventions](menu-bar-conventions.md), [toolbars-pattern](toolbars-pattern.md), `onboarding` (swiftui-build skill)
