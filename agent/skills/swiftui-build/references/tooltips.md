---
id: tooltips
title: Tooltips
platforms: [macOS]
availability: macOS 11.0+
docs: https://developer.apple.com/documentation/swiftui/view/help(_:)-6oiyb.md
hig: https://developer.apple.com/design/human-interface-guidelines/offering-help.md
---

# Tooltips

A short phrase that appears when the pointer rests on a control.

Also called: help tag, toolTip, title attribute, hover text, help(_:), NSView toolTip, hint, icon button.

## Default code

```swift
Button("Restore Defaults", systemImage: "arrow.counterclockwise") {
    restoreDefaults()
}
.labelStyle(.iconOnly)
.help("Restore default settings")
```

**Important:** An icon on its own rarely says what a button does. Give every icon-only button a title for VoiceOver and a `.help` tooltip for everyone else.

## Rules

- **Say what the control does, in a few words.** Start with a verb, and keep it to 60 to 75 characters at most. A sentence fragment without articles is fine.
- **Don't repeat the control's name.** The name is already on screen or in the label. Use the space to explain what happens.
- **Describe only that control.** People hold the pointer over one control to learn about it, not about its neighbors or the whole task.
- **Use sentence case, and match the state.** Write “Pin note”, not “Pin Note”, and skip the final period. If the control changes, like Pin and Unpin, change the tooltip too.

## Pitfalls

- **`.help` is also the VoiceOver hint.** One modifier gives pointer users a tooltip and VoiceOver users a hint.
- **Tooltips wait for the pointer.** They appear only after the pointer rests on a control for a moment, so keep anything people must know in the window itself.

## Key APIs

- `.help(_:)`: Adds a tooltip and an accessibility hint.
- `.help(Text)`: The same, from a `Text`.
- `Button(_:systemImage:action:)`: A button with a title and a symbol.
- `.labelStyle(.iconOnly)`: Shows only a label's icon; the title stays for VoiceOver.

## Variants

### Icon-only toolbar buttons

Add `.help` to each icon-only toolbar button, so people can find out what it does before they click.

```swift
.toolbar {
    Button("New Note", systemImage: "square.and.pencil") { newNote() }
        .help("Create a note")
    Button("Share", systemImage: "square.and.arrow.up") { share() }
        .help("Send this note to someone")
    Button("Delete", systemImage: "trash") { delete() }
        .help("Move this note to the Trash")
}
```

**Note:** Hold the pointer over each symbol in the preview. A real `.toolbar` here would land in this window's own toolbar, so the preview draws one.

### A tooltip that follows the state

When a button switches between two actions, switch its `.help` text too, so it describes the next click.

```swift
@State private var isPinned = false

Button(isPinned ? "Unpin" : "Pin", systemImage: isPinned ? "pin.slash" : "pin") {
    isPinned.toggle()
}
.labelStyle(.iconOnly)
.help(isPinned ? "Unpin this note" : "Pin this note to the top")
```

## Related

[button](button.md), [hover](hover.md), [toolbar](toolbar.md), `voiceover` (apple-design skill)
