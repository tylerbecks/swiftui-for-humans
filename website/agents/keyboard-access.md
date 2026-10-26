---
id: keyboard-access
title: Keyboard access
platforms: [macOS]
availability: macOS 14.0+
docs: https://developer.apple.com/documentation/swiftui/focus.md
hig: https://developer.apple.com/design/human-interface-guidelines/keyboards.md
reviewed: October 2026
---

# Keyboard access

Let people reach every control and command without touching the pointer.

Also called: Full Keyboard Access, keyboard navigation, tab order, focus order, focus ring, tabindex, FocusState, focusable, focusSection, onKeyPress.

## Contents

- Rules
- Pitfalls
- Guide
- Key APIs
- Variants
- Related

## Rules

- **Don't hide actions behind hover.** A button that only appears under the pointer can't be reached from the keyboard. Show it, put it in a menu, or both.
- **Keep standard shortcuts doing standard things.** People carry ⌘C, ⌘Z, and ⌘W from app to app. Give your own command a new shortcut instead of borrowing one people already know.
- **Build custom shortcuts on Command.** Use ⌘ first, add ⇧ for a related variant, and save ⌥ for rarer commands. Avoid ⌃: the system uses it for moving focus and other features.
- **Give shortcuts only to frequent commands.** A few well-chosen shortcuts are easy to learn. Dozens of new ones make the app feel hard, and every command is still reachable through the menu bar.
- **Let people move focus themselves.** Jumping focus somewhere on its own makes people hunt for it. Move it only in response to what they did, like pressing Return in a field.

## Pitfalls

- **Buttons join the Tab order only when keyboard navigation is on.** That's the Mac convention for button-like views, so test your windows with the setting both on and off.
- **Every menu item is keyboard access for free.** People can reach the menu bar from the keyboard, so a command that lives in a menu works for them even without its own shortcut.

## Guide

Many Mac users keep their hands on the keyboard, and some can't use a pointer at all. **Full Keyboard Access**, in the Accessibility section of System Settings, lets people move through windows, menus, and controls and use them with the keyboard alone. A lighter setting, **Keyboard navigation** in System Settings > Keyboard, lets Tab reach every control. Apple asks apps to support Full Keyboard Access, and SwiftUI does most of the work: standard controls already take part.

Your part is custom views, the order focus moves in, and making sure no action needs the pointer.

Click the Name field, then press Tab and ⇧Tab. The readout shows what has focus. Turn on Keyboard navigation in System Settings > Keyboard and try again: now the swatches and the Save button join in.

### Keys the system already uses

These come from the HIG's list of standard shortcuts. Test your window with them, and don't assign them to anything else.

- Tab and ⇧Tab: Move to the next or previous control.
- ⌃Tab: Move to the next group of controls, or out of a table where Tab moves between cells.
- ⌃F2 and ⌃F5: Move focus to the menu bar, or to the window's toolbar.
- ⌘`: Switch to the app's next window.
- Esc and ⌘.: Cancel the current action.

## Key APIs

- `.focusable(_:interactions:)`: Lets a custom view take keyboard focus.
- `@FocusState`: Reads and moves focus from your code.
- `.focused(_:equals:)`: Ties a view to a `@FocusState` value.
- `.defaultFocus(_:_:)`: Picks what has focus when the window opens.
- `.focusSection()`: Visits a group's views before moving on.
- `.onKeyPress(_:action:)`: Handles a key while the view has focus.
- `.keyboardShortcut(_:modifiers:)`: Gives a button or menu item a shortcut.

## Variants

### Make a custom control focusable

Add `.focusable()` so Tab can reach the view, then `.onKeyPress` to change it with the arrow keys.

```swift
@State private var rating = 3

HStack {
    ForEach(1...5, id: \.self) { star in
        Image(systemName: star <= rating ? "star.fill" : "star")
            .onTapGesture { rating = star }
    }
}
.foregroundStyle(.orange)
.focusable()
.onKeyPress(.leftArrow) {
    rating = max(rating - 1, 1)
    return .handled
}
.onKeyPress(.rightArrow) {
    rating = min(rating + 1, 5)
    return .handled
}
```

**Note:** Click the stars, then press ← and →. Built with the macOS 14 SDK or later, `.focusable()` takes focus even with keyboard navigation off.

### Move to the next field on Return

Tie each field to `@FocusState` with `.focused(_:equals:)`, set it in `.onSubmit`, and pick the first field with `.defaultFocus`.

```swift
enum Field: Hashable {
    case name, email
}

@State private var name = ""
@State private var email = ""
@FocusState private var focus: Field?

Form {
    TextField("Name", text: $name)
        .focused($focus, equals: .name)
        .onSubmit { focus = .email }
    TextField("Email", text: $email)
        .focused($focus, equals: .email)
}
.defaultFocus($focus, .name)
```

### Keep a column together

Tab moves across a row first, so add `.focusSection()` to each column to finish one before the next.

```swift
@State private var shipping = ["", ""]
@State private var billing = ["", ""]

HStack(alignment: .top) {
    VStack {
        TextField("Shipping street", text: $shipping[0])
        TextField("Shipping city", text: $shipping[1])
    }
    .focusSection()
    VStack {
        TextField("Billing street", text: $billing[0])
        TextField("Billing city", text: $billing[1])
    }
    .focusSection()
}
```

**Note:** Without `.focusSection()`, Tab would go from Shipping street to Billing street, across the row.

## Related

[focus-keyboard](focus-keyboard.md), [keyboard-shortcuts](keyboard-shortcuts.md), [commands](commands.md), [voiceover](voiceover.md), [menu-bar-conventions](menu-bar-conventions.md)
