---
name: apple-design
description: Applies Apple's Human Interface Guidelines to SwiftUI apps as short decision rules with reasons, covering color, typography, Dark Mode, SF Symbols, materials and Liquid Glass, layout, motion, writing, accessibility (VoiceOver, Dynamic Type, contrast, Reduce Motion), and patterns such as loading, feedback, modality, entering data, undo, launching, and asking for permission, with Mac idioms. Use when designing or critiquing an iOS, iPadOS, or macOS screen, choosing between a sheet, push, alert, or popover, picking colors, fonts, icons, or button prominence, writing UI copy, or making an app accessible. Trigger keywords include HIG, Human Interface Guidelines, design, UX, accessibility, VoiceOver, Dynamic Type, dark mode, contrast, color, typography, SF Symbols, app icon, Liquid Glass, empty state, onboarding, permission prompt, alert, and modal.
---

# Apple design

The Human Interface Guidelines as decisions you can apply while writing SwiftUI: what to choose, and why. Paraphrased from Apple; each reference links the HIG page (add `.md` to any HIG URL for a Markdown copy).

## Workflow

1. Name the decision (which presentation, which color, how prominent, what wording) and read the matching reference below. `references/hig-decisions.md` holds the most-missed rules on one page.
2. Apply the **Rules**, and check the **Pitfalls**.
3. Check the result at the largest Dynamic Type size, in Dark Mode, with Increase Contrast, with Reduce Motion, and with VoiceOver.

## Top rules

1. One prominent action per screen. Show preference with style, not size, and label buttons with a verb.
2. Destructive actions use `role: .destructive` and are never the default button. Prefer undo over "Are you sure?".
3. Push to drill down, use a sheet for a separate task, and a full-screen cover only for immersive or must-finish flows. Editing sheets get Cancel and a confirming action.
4. Alerts only for things people must act on, titled with what happened. Use `confirmationDialog` to choose how to finish an action.
5. Semantic colors and text styles everywhere: they adapt to Dark Mode, Increase Contrast, and Dynamic Type. Never use color as the only signal.
6. Text contrast of at least 4.5:1 in both appearances. Text wraps, and rows stack at accessibility sizes.
7. Every control has a text label for VoiceOver, and targets are at least 44×44 pt (28×28 on Mac).
8. Liquid Glass belongs on controls that float above content. Content gets materials or plain backgrounds.
9. Respect Reduce Motion by swapping movement for fades. Keep animation short, and never make people wait for it.
10. Every screen has empty, loading, and error states, and asks for permission only when a feature needs it, saying why.

## Index

### Start here

- `references/hig-decisions.md`: The design calls agents most often get wrong, as 36 rules with reasons.
- `references/liquid-glass.md`: Liquid Glass rules, default code, and the fallback before 26.

### Foundations

- `references/system-colors.md`: Colors that adapt to light mode, dark mode, and accessibility settings for you.
- `references/typography.md`: Apple's built-in text styles, which resize automatically when people change their text size.
- `references/materials.md`: Frosted, blurred backgrounds that let the content behind them show through.
- `references/sf-symbols.md`: Thousands of built-in icons that match the system font and scale with text.
- `references/dark-mode.md`: Use colors that adapt, so your app looks right in light and dark.
- `references/layout-adaptivity.md`: Build layouts that fit any screen, window size, orientation, and text size.
- `references/motion.md`: Animate to explain what changed, keep it short, and know when to skip it.
- `references/app-icons.md`: Design one layered icon that the system turns into every appearance and size.
- `references/writing.md`: Short, specific words for buttons, alerts, errors, and empty screens.
- `references/windows-layout.md` (macOS only): Lay out windows that people move, resize, and stack beside other apps.
- `references/color.md` (macOS only): Semantic colors that adapt, and an accent color people choose for every app.

### Accessibility

- `references/accessibility.md`: What to support from day one so everyone can use your app.
- `references/voiceover.md`: Labels, traits, and grouping that tell the screen reader what each view is.
- `references/dynamic-type.md`: Let text grow to the size people choose, and keep layouts readable when it does.
- `references/reduce-motion.md`: Swap big movement for fades when people ask for less motion.
- `references/color-and-contrast.md`: Readable contrast, Increase Contrast support, and never using color as the only signal.
- `references/keyboard-access.md` (macOS only): Let people reach every control and command without touching the pointer.
- `references/contrast-transparency.md` (macOS only): Stay readable when people turn on Increase Contrast or Reduce Transparency.

### Patterns

- `references/launching.md`: Open fast, look like your first screen, and pick up where people left off.
- `references/loading.md`: Show something right away, then swap in the content, an empty state, or an error.
- `references/feedback.md`: Tell people what happened, with an interruption that matches how much it matters.
- `references/entering-data.md`: Ask for less, show the right keyboard, and catch mistakes while people type.
- `references/modality.md`: When to use a sheet, full-screen cover, alert, or popover, and how people get out.
- `references/undo-redo.md`: Let people take back what they did, instead of asking “Are you sure?” first.
- `references/requesting-permission.md`: Ask for access when a feature needs it, say why, and handle “no” gracefully.
- `references/menu-bar-conventions.md` (macOS only): The standard menus, their order, and which commands belong in each.
- `references/settings-pattern.md` (macOS only): Keep rare, app-wide options in Settings, and task options in the window they affect.
- `references/windows-tabs.md` (macOS only): More than one window, tabs that gather them, and windows that come back after a relaunch.
- `references/toolbars-pattern.md` (macOS only): Which commands earn a place in the toolbar, how to group them, and letting people customize.
- `references/full-screen.md` (macOS only): Let a window fill the screen for focused work, and keep what people need in reach.
