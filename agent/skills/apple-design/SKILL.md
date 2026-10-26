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

Each id is a file, `references/<id>.md`. (macOS) marks Mac-only topics.

### Start here

- `hig-decisions` — The design calls agents most often get wrong
- `liquid-glass` — Liquid Glass rules, default code

### Foundations

- `system-colors` — Colors that adapt to light mode
- `typography` — Apple's built-in text styles
- `materials` — Frosted, blurred backgrounds that let the content
- `sf-symbols` — Thousands of built-in icons that match the system
- `dark-mode` — Use colors that adapt
- `layout-adaptivity` — Build layouts that fit any screen
- `motion` — Animate to explain what changed
- `app-icons` — Design one layered icon that the system turns
- `writing` — Short, specific words for buttons, alerts, errors
- `windows-layout` (macOS) — Lay out windows that people move, resize
- `color` (macOS) — Semantic colors that adapt

### Accessibility

- `accessibility` — What to support from day one so everyone
- `voiceover` — Labels, traits, and grouping that tell the screen
- `dynamic-type` — Let text grow to the size people choose
- `reduce-motion` — Swap big movement for fades when people ask
- `color-and-contrast` — Readable contrast, Increase Contrast support
- `keyboard-access` (macOS) — Let people reach every control and command
- `contrast-transparency` (macOS) — Stay readable when people turn on Increase Contrast

### Patterns

- `launching` — Open fast, look like your first screen
- `loading` — Show something right away
- `feedback` — Tell people what happened
- `entering-data` — Ask for less, show the right keyboard
- `modality` — When to use a sheet, full-screen cover
- `undo-redo` — Let people take back what they did
- `requesting-permission` — Ask for access when a feature needs it
- `menu-bar-conventions` (macOS) — The standard menus, their order
- `settings-pattern` (macOS) — Keep rare, app-wide options in Settings
- `windows-tabs` (macOS) — More than one window
- `toolbars-pattern` (macOS) — Which commands earn a place in the toolbar
- `full-screen` (macOS) — Let a window fill the screen for focused
