---
id: great-mac-app
title: What Makes a Great Mac App
platforms: [macOS]
docs: https://developer.apple.com/documentation/swiftui/commands.md
hig: https://developer.apple.com/design/human-interface-guidelines/designing-for-macos.md
reviewed: October 2026
---

# What Makes a Great Mac App

Menus, the keyboard, windows, Settings, and drag and drop: what people expect on a Mac.

## Contents

- Rules
- Pitfalls
- Guide
- Variants
- Related

## Rules

- **Disable menu items instead of hiding them.** A menu that always shows the same items teaches people what your app can do, even when an item doesn't apply right now.
- **Use the big display.** Show more content with fewer nested levels and fewer modal steps, while keeping the density comfortable to read.
- **Let people shape their windows.** People resize, hide, show, and move windows to fit how they work, and expect full screen for focused work.
- **Reward precise input.** A pointer allows exact selection and editing, so support it alongside the keyboard.
- **Support touch without resizing everything.** Some Macs have touch displays, but touch stays secondary. Keep controls the same size and density, and let standard controls handle bigger tap targets.
- **Let people personalize.** Customizable toolbars, windows that show the views people use most, and their choice of colors and fonts all help.

## Pitfalls

- **Standard menus do a lot of the work.** The system implements many standard menu items for you, so keeping them pays off twice.
- **People switch between apps all day.** Expect your app to be one of several windows on screen, and to move smoothly between active and inactive.

## Guide

A Mac sits on a desk, a foot or three from someone's eyes, with a big display, a keyboard, and a pointer. People keep several apps open and spend anything from minutes to hours in one. Five things make an app feel at home there.

### 1. Every command in the menu bar

People learn what an app does by opening its menus. Keep the standard menus in their usual order, put your own menus between View and Window, and list every command there, even the ones that also have a button. See [Commands](commands.md).

### 2. The keyboard does everything

Standard shortcuts like ⌘C, ⌘Z, and ⌘W should work as they do everywhere else. Add your own only for frequent commands, list modifiers as ⌃⌥⇧⌘, and support Full Keyboard Access so people can reach every control without a pointer. See [Keyboard Shortcuts](keyboard-shortcuts.md).

### 3. Windows people control

Windows should adapt smoothly to any size. Where it helps people multitask, let them open content in a window of its own, the way Mail gives each new message its own window. Keep the system's window frame and controls: a custom imitation that doesn't match them exactly makes an app feel broken. See [WindowGroup](window-group.md).

```swift
WindowGroup(for: Trip.ID.self) { $tripID in
    TripView(tripID: tripID)
}
.defaultSize(width: 900, height: 600)
```

### 4. Settings in the app menu

App-wide options go in a Settings window that opens from the app menu or with ⌘,. A `Settings` scene gives you both. Options for one window, like sorting, stay in that window. See [Settings](settings-scene.md).

### 5. Drag and drop everywhere

People try drag and drop on everything: between your windows, to and from other apps, and into the Finder. Offer another way to do the same thing, like a menu command, for people who can't drag. See [Drag and Drop](drag-drop.md).

## Variants

### Add an app-specific menu

`CommandMenu` adds a menu between View and Window, with shortcuts for the commands people use most.

```swift
WindowGroup {
    ContentView()
}
.commands {
    CommandMenu("Trip") {
        Button("New Stop") { addStop() }
            .keyboardShortcut("n", modifiers: [.shift, .command])
        Button("Show Map") { showMap() }
            .keyboardShortcut("m")
    }
}
```

### A shortcut on a button

`.keyboardShortcut(_:modifiers:)` clicks the button for you while its window is active, so press ⌥⌘K to try it.

```swift
@State private var stops = 0

Button("Add Stop") { stops += 1 }
    .keyboardShortcut("k", modifiers: [.option, .command])
```

### Drag a stop onto the trip

`.draggable(_:)` makes a view a drag source, and `.dropDestination(for:)` accepts what people drop on a view.

```swift
@State private var trip: [String] = []

HStack {
    ForEach(["Lisbon", "Porto", "Faro"], id: \.self) { city in
        Text(city)
            .padding(8)
            .background(.fill.tertiary, in: .capsule)
            .draggable(city)
    }
}
Text(trip.isEmpty ? "Drop stops here" : trip.joined(separator: " → "))
    .frame(maxWidth: .infinity, minHeight: 60)
    .background(.fill.quaternary, in: .rect(cornerRadius: 10))
    .dropDestination(for: String.self) { cities, _ in
        trip.append(contentsOf: cities)
    }
```

## Related

[mac-native-checklist](mac-native-checklist.md), [ipad-app-in-window](ipad-app-in-window.md), [commands](commands.md), [keyboard-shortcuts](keyboard-shortcuts.md), [window-group](window-group.md), [settings-scene](settings-scene.md), [drag-drop](drag-drop.md), [menu-bar-conventions](menu-bar-conventions.md)
