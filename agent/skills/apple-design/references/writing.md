---
id: writing
title: Writing
platforms: [iOS, iPadOS, macOS]
hig: https://developer.apple.com/design/human-interface-guidelines/writing.md
reviewed: October 2026
---

# Writing

Short, specific words for buttons, alerts, errors, and empty screens.

## Rules

- **Label buttons with verbs.** Say what happens when people tap. Clever or cute labels make them stop and think.
- **Name the action in alert buttons.** "OK" can mean "go ahead" or "got it". Use the verb, and always call the way out "Cancel".
- **Say how to fix an error.** Show the message next to the problem, don't blame, and skip "Oops". Tell people what will work.
- **Skip "we".** It's unclear who "we" is, especially in an error. Describe what happened instead.
- **Give empty screens a next step.** An empty list is a chance to explain what goes there and offer the button that fills it.
- **Write for the device.** On iPhone and iPad, people tap, not click. Use the gestures and words that match what's in their hand.

## Pitfalls

- **Keep a word list.** Write down what you call things ("Library" or "Collection"? "Remove" or "Delete"?) and use the same word everywhere.
- **Read it out loud.** If a sentence sounds stiff or long when spoken, cut it down. Fewer words are almost always clearer.

## Guide

The words in your app are part of the interface. A clear button label saves a tap on the wrong thing, and a good error message saves a support email. Pick a **voice** that fits your app, then adjust the **tone** to the moment: calm for a failed payment, warm for a finished goal.

### Capitalization

Pick title case or sentence case for each kind of text, and stick to it. For buttons and alerts, Apple uses these rules:

## Key APIs

`.alert(_:isPresented:actions:)`, `Button(_:role:action:)`, `ContentUnavailableView`, `TextField(_:text:prompt:)`, `Section { } footer: { }`

## Variants

### A clear alert

Give `.alert` a specific title, a short message only if it helps, and buttons named after their action.

```swift
@State private var isConfirming = false

Button("Delete Photos", role: .destructive) {
    isConfirming = true
}
.alert("Delete 3 Photos?", isPresented: $isConfirming) {
    Button("Delete", role: .destructive) { }
    Button("Cancel", role: .cancel) { }
} message: {
    Text("This can't be undone.")
}
```

**Note:** Skip alerts for things people can undo, like deleting one email. Save them for actions that can't be reversed.

## On macOS

Menu and button names people recognize: verbs, title case, and an ellipsis when more is needed.

### Rules

- **Add an ellipsis when a command needs more input.** The … tells people a window or panel will ask for something before the command finishes, like a file name for Export. Use the ellipsis character, not three periods.
- **Use title case in menus.** Capitalize every word except articles, coordinating conjunctions, and short prepositions, and always capitalize the last word: Bring All to Front.
- **Start actions with a verb.** A button or menu item that does something should say what it does. Plain beats clever.
- **Let a toggled item say what it will do.** Instead of two items, one item can switch between Show Map and Hide Map. For an attribute that's on, like a text style, a checkmark works better.
- **Write errors that help.** Show the message next to the problem, don't blame anyone, and say how to fix it. Skip “Oops” and avoid “we”: it's never clear who that is.
- **Describe the Mac's own actions.** People click, double-click, and press keys on a Mac. Saying tap, or describing a gesture the Mac doesn't have, sounds like an app from another device.

### Pitfalls

- **Pick a capitalization style and stick to it.** Menus use title case on the Mac. For other text, like headings and alerts, choose title or sentence case per kind of element and use it everywhere.
- **Say window, not scene.** People see windows. Scene, view, and other words from your code don't belong in the interface.

### Key APIs

`Button("Export…")`, `CommandGroup(after:)`, `CommandMenu(_:)`, `.keyboardShortcut(_:modifiers:)`, `.help(_:)`, `String(localized:)`

More variants, left out to keep this file short: An error next to the field, An empty state with a way forward, A setting that explains itself, Name menu commands the Mac way (macOS), A label that follows the state (macOS), An error next to the field (macOS), A button that opens more (macOS).

## Related

`alert` (swiftui-build skill), `confirmation-dialog` (swiftui-build skill), `empty-state` (swiftui-build skill), `text-field` (swiftui-build skill), `button` (swiftui-build skill), [voiceover](voiceover.md), `commands` (swiftui-build skill), [menu-bar-conventions](menu-bar-conventions.md), `keyboard-shortcuts` (swiftui-build skill), `empty-states` (swiftui-build skill)
