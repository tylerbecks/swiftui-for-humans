---
id: review-checklist
title: SwiftUI review checklist
summary: The review pass: linter, availability, accessibility, Dynamic Type, previews, and HIG checks.
skills: [swiftui-review]
platforms: [iOS, iPadOS, macOS]
reviewed: 2026-10-26
---

# SwiftUI review checklist

Run this on any SwiftUI change before calling it done. Copy the list into your notes and tick items as you go. Fix what you find; don't just report it.

## 1. Run the linter

It ships with this skill and needs only `python3`.

```sh
scripts/check-swift.sh --target "iOS 17" path/to/Sources
```

Pass your real deployment target so it skips fixes your OS floor can't use. Fix every `error` and `warning`; judge each `info`. Silence a deliberate exception with `// check-swift:ignore <id>` on that line, and say why in the comment.

## 2. Checklist

```text
Deprecated and outdated APIs
[ ] No NavigationView, tabItem, ActionSheet, Alert(title:), presentationMode
[ ] No foregroundColor, cornerRadius, accentColor(_:), edgesIgnoringSafeArea
[ ] onChange uses the two- or zero-parameter closure
[ ] .animation(_:value:) or withAnimation, never .animation(_:) alone
[ ] No Text + Text; interpolate instead
[ ] No UIScreen.main; no device checks for layout
[ ] New code uses @Observable + @State/@Bindable/@Environment, not ObservableObject
[ ] Async work in .task, not DispatchQueue or Task in onAppear
[ ] #Preview, not PreviewProvider

Availability
[ ] Every API newer than the deployment target sits behind if #available / @available
[ ] Each #available branch has a real fallback (e.g. glass falls back to a material)
[ ] Builds with zero new warnings

Accessibility
[ ] Every icon-only control has a text label (Button("Title", systemImage:) or .accessibilityLabel)
[ ] Tappable things are Buttons, not onTapGesture
[ ] Targets are at least 44×44 pt (28×28 on Mac)
[ ] Decorative images are hidden (Image(decorative:) or .accessibilityHidden(true))
[ ] Section titles have .accessibilityAddTraits(.isHeader)
[ ] Color is never the only signal
[ ] Motion respects accessibilityReduceMotion

Dynamic Type and layout
[ ] Text uses text styles, not .system(size:); custom sizes use @ScaledMetric
[ ] Nothing truncates at the largest accessibility size; rows stack when needed
[ ] No fixed frames on text; layouts adapt to size class, not device
[ ] Content stays inside the safe area; backgrounds may extend past it

Previews and state
[ ] Each new view has a #Preview, with @Previewable @State for bindings
[ ] Previews cover empty, loading, error, and long-text states where they apply
[ ] @State is private; models are injected, not created in init
[ ] List and ForEach use stable Identifiable ids, not indices

HIG decisions
[ ] One prominent action per screen; destructive actions use role: .destructive
[ ] Push vs sheet vs full-screen cover matches the task
[ ] Editing sheets have Cancel and a confirming action
[ ] Alerts only for things people must act on; titles say what happened
[ ] Tabs navigate and never act; five or fewer on iPhone
[ ] Glass only on floating controls; semantic colors and SF Symbols elsewhere
[ ] Mac: commands in the menu bar, Settings scene, standard shortcuts
```

## 3. Verify in the running app

- Build and run on the lowest supported OS and the newest.
- Try the largest Dynamic Type size, Dark Mode, Increase Contrast, Reduce Transparency, and Reduce Motion.
- Turn on VoiceOver and complete the main task once.
- On iPad, try a narrow window; on Mac, resize the window and use only the keyboard.

## More

- `deprecated-apis.md` for every correction and its minimum OS.
- `hig-decisions.md` for the design rules and their reasons.
- `liquid-glass.md`, `whats-new-26.md`, `whats-new-27.md` for newer APIs.
- https://developer.apple.com/design/human-interface-guidelines/accessibility.md
