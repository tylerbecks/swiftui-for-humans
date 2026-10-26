---
id: detail-screen
title: Detail Screen
platforms: [iOS, iPadOS]
availability: iOS 26.0+
docs: https://developer.apple.com/documentation/swiftui/view/glasseffect(_:in:).md
hig: https://developer.apple.com/design/human-interface-guidelines/toolbars.md
---

# Detail Screen

A listing page with a full-bleed hero, a glass toolbar, and a floating Reserve bar.

## Rules

- **Keep the toolbar to a few actions.** Each extra button makes the others harder to find and tap. Move rarely used actions into a More menu.
- **Use plain system symbols for toolbar buttons.** Familiar symbols like `heart` and `square.and.arrow.up` read at a glance, and the glass already gives each one a container, so skip the outlined `.circle` versions.
- **Use the standard Back button.** People know what the system chevron does. A custom back button or a text label that says Back makes them stop and check.

## Pitfalls

- **`.safeAreaInset(edge: .bottom)` pins a bar and makes room for it.** The scroll content ends above the bar instead of hiding behind it, like a fixed footer plus matching padding on the web.
- **Use `.glassEffect()` only on floating controls.** Keep it off the content itself; glass layered on glass looks muddy.

**Note:** The hero is an [AsyncImage](async-image.md) that runs under the navigation bar thanks to `.ignoresSafeArea(edges: .top)` (see [safe area](safe-area.md)). In iOS 26 the bar is transparent and its buttons float on [Liquid Glass](liquid-glass.md).

**Note:** The heart and share buttons sit in the [toolbar](toolbar.md), and `ToolbarSpacer(.fixed)` splits them into separate glass groups.

**Note:** The price bar is a `.safeAreaInset` with `.glassEffect`. **Reserve** presents a [sheet](sheet.md) with a [DatePicker](date-picker.md) and a [Stepper](stepper.md) at a medium detent.

More variants, left out to keep this file short: Code. Apple's docs: https://developer.apple.com/documentation/swiftui/view/glasseffect(_:in:).md

## Related

[liquid-glass](liquid-glass.md), [toolbar](toolbar.md), [sheet](sheet.md), [async-image](async-image.md)
