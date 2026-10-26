---
name: swiftui-review
description: Reviews SwiftUI code for iOS, iPadOS, and macOS with a bundled linter and a checklist, catching deprecated APIs (NavigationView, ObservableObject, foregroundColor, cornerRadius, one-parameter onChange, PreviewProvider, Text concatenation, UIScreen.main), missing availability checks, accessibility gaps, Dynamic Type problems, and Human Interface Guidelines mistakes such as several prominent buttons or icon-only buttons with no label. Fixes what it finds rather than only listing it. Use when reviewing, auditing, modernizing, or finishing SwiftUI code, before a commit or pull request, or when asked whether SwiftUI code follows current best practices or the HIG. Trigger keywords include review, code review, audit, lint, modernize, migrate, deprecated, deprecation warning, best practices, SwiftUI review, HIG check, and accessibility check.
---

# SwiftUI review

A review pass for SwiftUI changes: a deterministic linter first, then a checklist for what a linter can't see. Fix what you find; don't only report it.

## Workflow

1. **Lint.** Run the bundled linter on the changed files or folders, passing the real deployment target so it skips fixes the target can't use:

   ```sh
   python3 scripts/check_swift.py --target "iOS 17" path/to/Sources
   ```

   `scripts/check-swift.sh` is the same thing as a shell wrapper. Paths are relative to this skill's folder. Output is `file:line: id — message`, and the exit status is 1 when anything is found. Add `--json` for machine-readable output and `--min-severity warning` to hide judgment calls. `--list` prints every rule.
2. **Fix** every `error` and `warning`. Judge each `info` and `hig` finding. For a deliberate exception, add `// check-swift:ignore <id>` on that line with the reason.
3. **Check** the rest with `references/review-checklist.md`: availability fallbacks, accessibility, Dynamic Type, previews, state, and design decisions.
4. **Build** with zero new warnings, then try the largest text size, Dark Mode, and VoiceOver on the screens you changed.
5. **Report** briefly: what you fixed, what you left on purpose and why, and anything that needs a person (copy, design calls).

## Severity

- `error`: deprecated, and the compiler already warns. Always fix.
- `warning`: deprecated by Apple or clearly replaced, though many don't warn yet. Fix in new code, and in old code you touch.
- `info`: often wrong, sometimes right. Decide case by case.
- `hig`: a design smell from the Human Interface Guidelines. Check the screen.

## Top rules

1. No `NavigationView`, `tabItem`, `ActionSheet`, `Alert(title:)`, or `presentationMode`.
2. No `foregroundColor`, `cornerRadius`, `accentColor(_:)`, or `edgesIgnoringSafeArea`.
3. New models use `@Observable`, not `ObservableObject` with `@Published`, `@StateObject`, or `@EnvironmentObject`.
4. `onChange` uses the two-parameter or zero-parameter closure, and `.animation` always takes `value:`.
5. Interpolate styled `Text` instead of `Text + Text`.
6. Every API newer than the deployment target sits behind `#available` with a real fallback.
7. Icon-only controls have text labels, tappable things are `Button`s, and targets are at least 44×44 pt.
8. Text uses text styles, and nothing truncates at the largest accessibility size.
9. One prominent action per screen, and destructive actions use `role: .destructive`.
10. `#Preview` instead of `PreviewProvider`, covering empty, loading, and error states.

## Index

Each id is a file, `references/<id>.md`.

### Start here

- `deprecated-apis` — Every outdated SwiftUI API models still write
- `hig-decisions` — The design calls agents most often get wrong
- `review-checklist` — The review pass
