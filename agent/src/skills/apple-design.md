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

{{index}}
