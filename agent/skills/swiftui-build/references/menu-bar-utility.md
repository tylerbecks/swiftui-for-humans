---
id: menu-bar-utility
title: Menu bar utility
platforms: [macOS]
availability: macOS 14.0+
docs: https://developer.apple.com/documentation/swiftui/menubarextra.md
hig: https://developer.apple.com/design/human-interface-guidelines/the-menu-bar.md
---

# Menu bar utility

A small app that lives in the menu bar and opens a panel when clicked.

## Contents

- Built from
- Rules
- Pitfalls
- Key APIs
- Variants
- Related

## Built from

MenuBarExtra("Focus", systemImage:)
├── .menuBarExtraStyle(.window)
└── FocusPanel
    ├── TimelineView (countdown)
    ├── Picker (length)
    ├── Button("Start")
    └── SettingsLink, Quit

## Rules

- **Use a symbol for the menu bar icon.** A template symbol is drawn in the menu bar's own colors, so it looks right in light and dark menu bars and when it's highlighted.
- **Show a menu unless you need more.** Clicking an extra usually opens a menu. Use the window style only when the feature is too rich for menu items, like this timer.
- **Let people choose to show it.** Put a “Show in menu bar” setting in Settings, and offer it during setup so people find it.
- **Don't count on it being visible.** The system hides extras when the menu bar runs out of room. Make the same features reachable from your app's windows or its Dock menu too.

## Pitfalls

- **No Dock icon.** For an app that lives only in the menu bar, set `LSUIElement` to `YES` in its Info.plist, so it stays out of the Dock and the app switcher.
- **Removing the extra quits the app.** When an app's only scene is a `MenuBarExtra` and people remove it from the menu bar, the system ends the app.

## Key APIs

`MenuBarExtra(_:systemImage:)`, `.menuBarExtraStyle(.window)`, `.menuBarExtraStyle(.menu)`, `MenuBarExtra(…isInserted:)`, `LSUIElement`, `SettingsLink`

## Variants

### A focus timer in the menu bar

`MenuBarExtra` with `.menuBarExtraStyle(.window)` shows your view in a panel under the icon. Start the timer to try it.

```swift
@main
struct FocusApp: App {
    var body: some Scene {
        MenuBarExtra("Focus", systemImage: "timer") {
            FocusPanel()
        }
        .menuBarExtraStyle(.window)

        Settings {
            Text("Focus Settings")
                .padding()
        }
    }
}

struct FocusPanel: View {
    @State private var minutes = 25
    @State private var endDate: Date?

    var body: some View {
        VStack(spacing: 14) {
            TimelineView(.periodic(from: .now, by: 1)) { context in
                Text(remaining(at: context.date), format: .time(pattern: .minuteSecond))
                    .font(.system(size: 44, weight: .semibold, design: .rounded))
                    .monospacedDigit()
            }
            Picker("Length", selection: $minutes) {
                Text("15 min").tag(15)
                Text("25 min").tag(25)
                Text("50 min").tag(50)
            }
            .pickerStyle(.segmented)
            .labelsHidden()
            .disabled(endDate != nil)

            Button(endDate == nil ? "Start" : "Stop") {
                endDate = endDate == nil ? .now.addingTimeInterval(Double(minutes * 60)) : nil
            }
            .buttonStyle(.borderedProminent)
            .keyboardShortcut(.defaultAction)

            Divider()
            HStack {
                SettingsLink {
                    Text("Settings…")
                }
                Spacer()
                Button("Quit Focus") {
                    // Quits through AppKit.
                    NSApplication.shared.terminate(nil)
                }
            }
            .buttonStyle(.borderless)
        }
        .padding()
        .frame(width: 260)
    }

    private func remaining(at date: Date) -> Duration {
        guard let endDate else { return .seconds(minutes * 60) }
        return .seconds(max(0, endDate.timeIntervalSince(date)))
    }
}
```

**Note:** The Quit button calls AppKit's `NSApplication.shared.terminate(nil)`. Without a Dock icon, it's how people quit.

### A plain menu

For a handful of commands, use `.menuBarExtraStyle(.menu)`. Buttons become menu items, and `Divider` separates groups.

```swift
MenuBarExtra("Clipboard", systemImage: "list.clipboard") {
    Button("Paste Last Item") { }
    Button("Clear History") { }
    Divider()
    Button("Quit Clipboard") {
        NSApplication.shared.terminate(nil)
    }
    .keyboardShortcut("q")
}
.menuBarExtraStyle(.menu)
```

### Let people hide it

Pass `isInserted:` a binding to `@AppStorage`, and put the same key behind a checkbox in Settings.

```swift
@main
struct FocusApp: App {
    @AppStorage("showsMenuBarExtra") private var showsMenuBarExtra = true

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        MenuBarExtra("Focus", systemImage: "timer", isInserted: $showsMenuBarExtra) {
            FocusPanel()
        }
        .menuBarExtraStyle(.window)
        Settings {
            Form {
                Toggle("Show in menu bar", isOn: $showsMenuBarExtra)
            }
            .padding()
        }
    }
}
```

## Related

[menu-bar-extra](menu-bar-extra.md), `menu-bar-conventions` (apple-design skill), [settings-scene](settings-scene.md), [popover](popover.md)
