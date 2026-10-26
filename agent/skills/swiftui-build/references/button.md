---
id: button
title: Button
platforms: [iOS, iPadOS, macOS]
availability: iOS 13.0+, macOS 10.15+, visionOS 1.0+
docs: https://developer.apple.com/documentation/swiftui/button.md
hig: https://developer.apple.com/design/human-interface-guidelines/buttons.md
---

# Button

A control that runs an action when tapped.

## Contents

- Don't use when
- Default code
- Rules
- Pitfalls
- Key APIs
- Variants
- On macOS
- Related

## Don't use when

- Moving to another screen: use `NavigationLink(value:)` with `.navigationDestination(for:)`.
- Opening a web page or another app: use `Link`.
- Switching a setting on or off: use `Toggle`.

## Default code

```swift
Button("Sign In") {
    signIn()
}
.buttonStyle(.borderedProminent)
```

**Note:** The trailing closure is the action. For a custom look, use `Button { … } label: { … }` and pass any view as the label.

## Rules

- **Use one prominent button per screen.** The filled `.borderedProminent` style marks the action people most likely want. Several of them compete, and none stands out.
- **Use style, not size, to show the preferred choice.** Buttons of the same size read as one set of options. Make the preferred one more prominent instead of bigger.
- **Start labels with a verb.** A label like “Add to Cart” says what will happen. A noun or “OK” makes people guess.
- **Make every button at least 44 × 44 points.** Smaller targets are easy to miss. The system styles handle this; for a custom label, add padding or `.contentShape(.rect)` to grow the tappable area.
- **Never make a destructive action the default.** People tap the prominent button without reading it. Keep Delete in a regular style with `role: .destructive`, and confirm before it runs.
- **Pick glass styles for floating controls and bordered styles for content.** On iOS and macOS 26+, a button that floats above content uses `.buttonStyle(.glass)`, or `.glassProminent` for the one main action. Buttons inside content keep `.bordered` and `.borderedProminent`. Glass belongs to the controls layer (see `liquid-glass`).

## Pitfalls

- **Set a style once for a whole group.** `.buttonStyle(_:)` applies to every button inside a container, so put it on the `VStack` or `HStack` instead of each button.
- **In a `List` or `Form`, buttons become rows.** They draw as tappable rows with tinted text, not the bordered styles above.

## Key APIs

`Button(_:action:)`, `.buttonStyle(_:)`, `.controlSize(_:)`, `.buttonBorderShape(_:)`, `role:`, `.disabled(_:)`

## Variants

### Full-width button

Put `.frame(maxWidth: .infinity)` on the label, not the button, so the whole bar fills and responds to taps.

```swift
Button {
    // Continue
} label: {
    Text("Continue")
        .frame(maxWidth: .infinity)
}
.buttonStyle(.borderedProminent)
.controlSize(.large)
```

### Icon button

Use a `Label` with `.labelStyle(.iconOnly)`, so VoiceOver still reads the title.

```swift
@State private var isFavorite = false

Button {
    isFavorite.toggle()
} label: {
    Label("Favorite", systemImage: isFavorite ? "heart.fill" : "heart")
        .labelStyle(.iconOnly)
        .contentTransition(.symbolEffect(.replace))
}
.buttonStyle(.bordered)
.buttonBorderShape(.circle)
.controlSize(.large)
.tint(.pink)
```

## On macOS

A push button that runs an action when someone clicks it.

### Default code

```swift
Button("Add to Library") {
    addToLibrary()
}
```

**Note:** The action is a closure, like an `onClick` handler. With an icon, use `Button(_:systemImage:action:)` so toolbars and menus can show the right parts.

### Rules

- **Mark the preferred choice with style, not size.** Buttons of the same size read as one set of choices. Give the likely one a more prominent style instead of making it bigger.
- **Never make a destructive button the default.** People often press Return or click the highlighted button without reading it. Make the safe choice the default so a quick Return doesn't delete anything.
- **End the title with an ellipsis when it opens another window.** On the Mac, “…” tells people they'll be asked for more before anything happens, as in Export… or Choose Folder….
- **Label buttons with a verb.** A short title that starts with a verb, like Add to Library, says what will happen. For a familiar action like sharing, a familiar SF Symbol works too.

### Pitfalls

- **A style on a container reaches every button inside it.** Put `.buttonStyle(_:)` on an `HStack` or a `Form` instead of on each button.
- **Give icon-only buttons a title anyway.** `Button(_:systemImage:action:)` with `.labelStyle(.iconOnly)` shows just the symbol, and VoiceOver still reads the title.

### Key APIs

`Button(_:systemImage:action:)`, `Button(_:role:action:)`, `.keyboardShortcut(.defaultAction)`, `.keyboardShortcut(.cancelAction)`, `.help(_:)`

### Variants

#### Default and cancel buttons

Add `.keyboardShortcut(.defaultAction)` to the likeliest button so Return clicks it and tints it, and `.cancelAction` so Escape cancels.

```swift
HStack {
    Button("Cancel", role: .cancel) {
        dismiss()
    }
    .keyboardShortcut(.cancelAction)

    Button("Save") {
        save()
    }
    .keyboardShortcut(.defaultAction)
}
```

**Note:** If more than one button has `.defaultAction`, only the first gets the tint.

More variants, left out to keep this file short: Loading state, Destructive with confirmation, Destructive actions (macOS), Small buttons that act on a list (macOS), A button that looks like a link (macOS), Scope bar buttons (macOS). Apple's docs: https://developer.apple.com/documentation/swiftui/button.md

## Related

[toggle](toggle.md), [menu](menu.md), [link](link.md), [control-group](control-group.md), [keyboard-shortcuts](keyboard-shortcuts.md), [alert](alert.md), [sheet](sheet.md), [tooltips](tooltips.md)
