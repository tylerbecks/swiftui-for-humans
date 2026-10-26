---
id: toggle
title: Toggle
platforms: [iOS, iPadOS, macOS]
availability: iOS 13.0+, macOS 10.15+, visionOS 1.0+
docs: https://developer.apple.com/documentation/swiftui/toggle.md
hig: https://developer.apple.com/design/human-interface-guidelines/toggles.md
---

# Toggle

A control that switches between on and off.

## Contents

- Default code
- Rules
- Pitfalls
- Key APIs
- Variants
- On macOS
- Related

## Default code

```swift
@State private var wifiOn = true

Form {
    Toggle("Wi-Fi", isOn: $wifiOn)
}
```

**Note:** Pass the binding with `$`. The toggle writes the new value back to your `@State`, like a controlled `<input>` that updates its own state.

## Rules

- **Use a switch only in a list or form row.** A switch floating on its own looks out of place. Outside a list, use `.toggleStyle(.button)` instead, like a filter button.
- **Name the setting, not its state.** The switch already shows on or off. A label like “Wi-Fi” stays true either way; “Turn On Wi-Fi” is wrong half the time.
- **Change the tint only when you need to.** The default green reads well everywhere. If you use your accent color, check it still stands out from the gray off state.
- **Show the state with more than color.** For a button-style toggle, also switch the symbol, like `star` to `star.fill`, so people who can't see the color difference can still tell.

## Pitfalls

- **Always give a toggle a real label.** `.labelsHidden()` hides it on screen but VoiceOver still reads it, so a toggle without one is a mystery switch.

## Key APIs

`Toggle(_:isOn:)`, `Toggle(_:systemImage:isOn:)`, `.toggleStyle(_:)`, `.tint(_:)`, `.labelsHidden()`, `ToggleStyle`

## Variants

### Settings list

Inside a `Form`, each toggle becomes a row. Use `.disabled(_:)` on a setting that depends on another.

```swift
@State private var notifications = true
@State private var sounds = false

Form {
    Toggle("Notifications", systemImage: "bell.badge", isOn: $notifications)
    Toggle("Sounds", systemImage: "speaker.wave.2", isOn: $sounds)
        .disabled(!notifications)
}
```

### Formatting buttons

Use `.toggleStyle(.button)` outside a list. The button stays highlighted while on, like Bold in a text editor.

```swift
@State private var isBold = true
@State private var isItalic = false

HStack {
    Toggle("Bold", systemImage: "bold", isOn: $isBold)
    Toggle("Italic", systemImage: "italic", isOn: $isItalic)
}
.toggleStyle(.button)
.labelStyle(.iconOnly)
```

## On macOS

A checkbox, switch, or button that turns a setting on or off.

### Default code

```swift
@State private var showsInMenuBar = true

Toggle("Show in menu bar", isOn: $showsInMenuBar)
```

**Note:** Pass the binding with `$`. The toggle writes the new value back to your `@State`, like a controlled `<input type=checkbox>`.

### Rules

- **Keep checkboxes and switches in the window body.** They belong next to the content they change, not in a toolbar. In a toolbar, use a button-style toggle instead.
- **Use checkboxes to show a hierarchy of settings.** Checkboxes line up along their leading edge, so indenting the ones that depend on another shows how they're related.
- **Save switches for settings that carry weight.** A switch looks heavier than a checkbox, so it suits a setting that turns on a whole feature or a group of other settings. Don't swap an existing checkbox for one.
- **Show a mixed state when sub-options disagree.** A checkbox that controls several others should show a dash when some are on and some are off. `Toggle(sources:isOn:)` does it for you.

### Pitfalls

- **The default style depends on where the toggle is.** It's a checkbox in most places, and a switch in a grouped `Form`. Set `.toggleStyle(_:)` when you need one or the other.
- **Clicking the label toggles it too.** The title is part of the checkbox, so people don't have to aim for the small box.

### Key APIs

`.toggleStyle(.checkbox)`, `.toggleStyle(.switch)`, `.toggleStyle(.button)`, `Toggle(sources:isOn:)`, `.controlSize(_:)`

### Variants

#### Settings with dependencies

Outside a grouped form, toggles are checkboxes. Indent the ones that depend on another, and disable them while it's off.

```swift
@State private var showsWarnings = true
@State private var includesMinor = false
@State private var playsSound = true

VStack(alignment: .leading) {
    Toggle("Show warnings", isOn: $showsWarnings)
    Group {
        Toggle("Include minor issues", isOn: $includesMinor)
        Toggle("Play a sound", isOn: $playsSound)
    }
    .padding(.leading, 20)
    .disabled(!showsWarnings)
}
```

More variants, left out to keep this file short: Checkbox-style agreement, Select all, with a mixed state (macOS), Switches in a grouped form (macOS), A toggle in the toolbar (macOS). Apple's docs: https://developer.apple.com/documentation/swiftui/toggle.md

## Related

[button](button.md), [form](form.md), [state](state.md), [binding](binding.md)
