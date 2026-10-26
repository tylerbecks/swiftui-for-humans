---
id: hig-decisions
title: HIG decision rules
summary: The design calls agents most often get wrong, as 36 rules with reasons.
skills: [apple-design, swiftui-review]
platforms: [iOS, iPadOS, macOS]
reviewed: 2026-10-26
---

# HIG decision rules

The design calls agents most often get wrong, as rules with the reason. Paraphrased from Apple's Human Interface Guidelines; follow the links for the full guidance.

## Actions

1. **One prominent action per screen.** `.borderedProminent` / `.glassProminent` marks what people most likely want; two of them cancel out.
2. **Show preference with style, not size.** Same-size buttons read as one set of choices.
3. **Label buttons with a verb.** "Add to Cart" says what happens; "OK" makes people reread.
4. **Give destructive actions `role: .destructive`, never the default.** People tap the prominent button without reading it.
5. **Confirm only loss that's unexpected and permanent.** Deleting what someone just chose to delete needs undo, not an alert.
6. **Every icon-only button gets a label.** `Button("Share", systemImage: "square.and.arrow.up")` with `.labelStyle(.iconOnly)` gives VoiceOver words.
7. **Make targets at least 44×44 pt (28×28 on Mac).** Grow the hit area with padding or `.contentShape(.rect)`, not a bigger icon.
8. **Use `Button` for anything tappable, not `.onTapGesture`.** Buttons get the trait, keyboard focus, and pointer highlight.
9. **Give every gesture a visible alternative.** Swipe and long-press actions also live in a button, menu, or toolbar.

## Presenting

10. **Push for drill-down, sheet for a separate task, full-screen cover for immersive media or a flow that must finish.** Pushes keep the back stack; sheets say "this is temporary".
11. **Sheets that edit get Cancel (leading) and Done/Save (trailing, `.confirmationAction`).** A lone Done hides the way out.
12. **Block swipe-to-dismiss only with unsaved changes** (`.interactiveDismissDisabled(hasChanges)`), then ask.
13. **One sheet at a time.** Close the first before opening another.
14. **Alert for news people must act on; `confirmationDialog` for choosing how to finish an action they started.** Title alerts with what happened, not "Error".
15. **Popovers for small, optional content on iPad and Mac.** Never for warnings; they dismiss on any outside tap.

## Structure

16. **Tab bar for 3–5 top-level sections on iPhone; `.tabViewStyle(.sidebarAdaptable)` when there are more.** Extra tabs hide behind More.
17. **Tabs navigate; they never perform actions.** "New Post" is a toolbar button.
18. **Use `NavigationSplitView` for iPad and Mac browse-and-detail.** It collapses to a stack on iPhone for free.
19. **Lay out by available space, not device.** Size classes and `ViewThatFits`; iPad apps run in narrow windows.
20. **Keep the system back button.** A custom "Back" label makes people stop and check.
21. **Two or three toolbar actions; the rest go in a `Menu`.** Plain SF Symbols, no `.circle` variants under glass.

## Text, color, and symbols

22. **Use text styles (`.body`, `.headline`), never `.system(size:)`.** Fixed sizes ignore Dynamic Type; use `@ScaledMetric` for custom spacing and sizes.
23. **Let text wrap, and stack rows at accessibility sizes.** Check `dynamicTypeSize.isAccessibilitySize`.
24. **Use semantic colors (`.primary`, `.secondary`, system backgrounds).** They adapt to Dark Mode and Increase Contrast; `.black` and `.white` don't.
25. **Never use color as the only signal.** Add a symbol or a word.
26. **Keep text contrast at 4.5:1 or better, checked in both appearances.**
27. **Use SF Symbols with their usual meaning.** `trash` deletes, `square.and.arrow.up` shares.
28. **Liquid Glass on controls, materials on content.** Glass on cards or rows buries the content.

## Motion and feedback

29. **Respect Reduce Motion:** swap slides and zooms for a fade (`@Environment(\.accessibilityReduceMotion)`).
30. **Never make people wait for an animation.** Keep feedback short and interruptible.
31. **Pair every haptic with something visible.** iPad and Mac have none.

## Mac

32. **Settings live in a `Settings` scene** (opened with ⌘,), not a sheet or a tab in the main window.
33. **Every command goes in the menu bar** via `.commands`; disable items that don't apply instead of hiding them.
34. **Keep standard shortcuts standard;** build new ones on ⌘, add ⇧ for variants.
35. **End a command title with "…" when it asks for more input** before acting (Export…).
36. **Title windows with their content, not the app name**, and let the system draw the window chrome.

## Apple HIG

- https://developer.apple.com/design/human-interface-guidelines/buttons.md
- https://developer.apple.com/design/human-interface-guidelines/modality.md
- https://developer.apple.com/design/human-interface-guidelines/alerts.md
- https://developer.apple.com/design/human-interface-guidelines/tab-bars.md
- https://developer.apple.com/design/human-interface-guidelines/accessibility.md
- https://developer.apple.com/design/human-interface-guidelines/typography.md
- https://developer.apple.com/design/human-interface-guidelines/the-menu-bar.md
- https://developer.apple.com/design/human-interface-guidelines/settings.md
