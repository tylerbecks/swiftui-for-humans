---
id: settings-screen
title: Settings Screen
platforms: [iOS, iPadOS]
availability: iOS 16.0+
docs: https://developer.apple.com/documentation/swiftui/form.md
hig: https://developer.apple.com/design/human-interface-guidelines/settings.md
---

# Settings Screen

A grouped settings form with toggles, a picker, a drill-down row, and sign-out confirmation.

## Rules

- **Keep row titles short and explain in the footer.** Short titles scan quickly down the screen, and one footer sentence gives the detail without wrapping every row.
- **Pick defaults that suit most people.** Every setting is a decision someone has to make. Good defaults let most people use the app without ever opening Settings.
- **Offer few settings, and keep task options on the task's screen.** A long settings list is hard to search. Controls like sort order or filters belong on the screen they change, where people can see the result.
- **Put Sign Out in its own section at the bottom.** Keeping it apart from everyday rows prevents accidental taps, and a `confirmationDialog` gives people a second chance.

## Pitfalls

- **Save preferences with `@AppStorage`.** Swap each `@State` for `@AppStorage("key")` and the choice survives relaunches, much like `localStorage` on the web.
- **Use `.pickerStyle(.navigationLink)` for long lists.** A `Picker` in a `Form` opens a menu by default; the navigation-link style pushes a full list instead.

**Note:** The screen is one [Form](form.md) in a [NavigationStack](navigation-stack.md), which gives it the Settings app look. Each row type, from [Toggle](toggle.md) and [Picker](picker.md) to `NavigationLink` and `LabeledContent`, styles itself to match.

**Note:** The colored icons are a [Label](label.md) with a custom icon: an SF Symbol on a rounded, gradient square. Sign Out asks first with a [confirmation dialog](confirmation-dialog.md).

More variants, left out to keep this file short: Code. Apple's docs: https://developer.apple.com/documentation/swiftui/form.md

## Related

[form](form.md), [toggle](toggle.md), [picker](picker.md), [confirmation-dialog](confirmation-dialog.md)
