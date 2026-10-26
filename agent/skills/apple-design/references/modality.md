---
id: modality
title: Modality
platforms: [iOS, iPadOS]
availability: iOS 15.0+
docs: https://developer.apple.com/documentation/swiftui/view/fullscreencover(ispresented:ondismiss:content:).md
hig: https://developer.apple.com/design/human-interface-guidelines/modality.md
reviewed: October 2026
---

# Modality

When to use a sheet, full-screen cover, alert, or popover, and how people get out.

## Contents

- Rules
- Pitfalls
- Guide
- Key APIs
- Variants
- Related

## Rules

- **Always give an obvious way out.** People look for buttons at the top of a sheet, and expect to swipe it down. If there's a Done button, pair it with Cancel so finishing isn't the only exit.
- **Ask before throwing away work.** If closing would lose what people typed, whether by button or by swipe, ask first and offer to keep editing or discard.
- **Keep it short, and name the task.** A modal is a quick detour. A clear title, like “New Event”, helps people remember why they're there; a deep hierarchy inside makes them forget.
- **Show one at a time.** Close a sheet before you open another. Only an alert may appear on top of a modal, and never two alerts at once.
- **Use popovers on iPad, sheets on iPhone.** A popover is for a few options in a wide layout. On iPhone, SwiftUI shows a popover as a sheet, which is usually what you want.

## Pitfalls

- **Push for drill-down, present for a side task.** Use a NavigationStack (`navigation-stack`, swiftui-build skill) push to go deeper into content, and a modal to step aside for a moment, like opening a `<dialog>` on the web.
- **`dismiss` closes whatever presented the view.** Read `@Environment(\.dismiss)` inside the sheet or cover, not in the view that opened it.

## Guide

A modal view takes people out of what they were doing until they finish or close it. That focus is useful for a short task or a critical choice, and annoying for anything else. Present modally only when it clearly helps, and always make the way out obvious.

## Key APIs

`.sheet(isPresented:)`, `.fullScreenCover(isPresented:)`, `.popover(isPresented:)`, `.confirmationDialog(...)`, `@Environment(\.dismiss)`, `.interactiveDismissDisabled()`, `Button(role: .confirm)`

## Variants

### Sheet with Cancel and Done

Put Cancel on the leading side and Done on the trailing side, using the `.cancellationAction` and `.confirmationAction` placements.

```swift
struct NewEventSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""

    var body: some View {
        NavigationStack {
            Form {
                TextField("Title", text: $title)
            }
            .navigationTitle("New Event")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done", role: .confirm) { dismiss() }
                        .disabled(title.isEmpty)
                }
            }
        }
    }
}

// In the presenting view:
// .sheet(isPresented: $isAdding) { NewEventSheet() }
```

### Protect unsaved changes

Block the swipe with `.interactiveDismissDisabled`, and ask with a `.confirmationDialog` before Cancel throws away text.

```swift
struct NoteSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var text = ""
    @State private var confirmDiscard = false

    var body: some View {
        NavigationStack {
            TextEditor(text: $text)
                .navigationTitle("New Note")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel", role: .cancel) {
                            if text.isEmpty { dismiss() } else { confirmDiscard = true }
                        }
                        .confirmationDialog("Discard this note?", isPresented: $confirmDiscard) {
                            Button("Discard Note", role: .destructive) { dismiss() }
                            Button("Keep Editing", role: .cancel) { }
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save", role: .confirm) { dismiss() }
                    }
                }
        }
        .interactiveDismissDisabled(!text.isEmpty)
    }
}
```

More variants, left out to keep this file short: Full-screen cover, Popover that adapts. Apple's docs: https://developer.apple.com/documentation/swiftui/view/fullscreencover(ispresented:ondismiss:content:).md

## Related

`sheet` (swiftui-build skill), `alert` (swiftui-build skill), `popover` (swiftui-build skill), `confirmation-dialog` (swiftui-build skill), [feedback](feedback.md), `navigation-stack` (swiftui-build skill)
