---
id: sheet
title: Sheet
platforms: [iOS, iPadOS, macOS]
availability: iOS 13.0+, macOS 10.15+, visionOS 1.0+
docs: https://developer.apple.com/documentation/swiftui/view/sheet(ispresented:ondismiss:content:).md
hig: https://developer.apple.com/design/human-interface-guidelines/sheets.md
---

# Sheet

Slides a view up over the current screen for a focused task, at full or partial height.

## Contents

- Use when
- Don't use when
- Default code
- Built from
- Rules
- Pitfalls
- Key APIs
- On macOS
- Related

## Use when

- A sheet slides a view up over the current screen for a focused task, like composing a message or editing a record.
- It's driven by state: set a `Bool` to `true` to show it, and swiping down sets it back to `false`.

## Don't use when

- Use a push in a [NavigationStack](navigation-stack.md) to drill deeper, an [Alert](alert.md) for a short question, and `.fullScreenCover` for long or immersive tasks like a camera.

## Default code

```swift
@State private var isPresented = false

Button("Show Details") {
    isPresented = true
}
.sheet(isPresented: $isPresented) {
    Text("Details")
        .presentationDetents([.medium, .large])
}
```

**Important:** Put `.sheet` on a view that stays on screen, like the button. If the view it's attached to disappears, the sheet closes with it.

## Built from

.sheet(isPresented:)
└── NavigationStack
    └── Sheet content
        ├── .toolbar
        │   ├── Cancel
        │   └── Done
        └── .presentationDetents

## Rules

- **Pair Done with Cancel.** Cancel on the leading side lets people leave without saving. A lone Done makes finishing the task feel like the only way out.
- **Use the medium detent for quick content.** A half-height sheet keeps the screen behind it in view, like the share sheet. Use full height for writing, like a new message.
- **Show one sheet at a time.** A sheet over a sheet makes people lose their place. Close the first one before opening another.
- **Let people swipe to dismiss.** People expect it. If there are unsaved changes, block the swipe with `.interactiveDismissDisabled` and ask before discarding.

## Pitfalls

- **On iPad a sheet floats as a card.** `.presentationSizing` (iOS 18) sets its size, like `.form` or `.page`.
- **A sheet's content is a new screen.** It doesn't inherit the parent's navigation bar, so wrap it in a `NavigationStack` for a title and buttons.

## Key APIs

`.sheet(isPresented:)`, `.sheet(item:)`, `@Environment(\.dismiss)`, `.presentationDetents(_:)`, `.presentationDragIndicator(_:)`, `.interactiveDismissDisabled(_:)`, `.fullScreenCover(isPresented:)`

## On macOS

A card attached to its window, for a short task like adding an item.

### Default code

```swift
@State private var isAdding = false

Button("New Event…") { isAdding = true }
    .sheet(isPresented: $isAdding) {
        NewEventForm()
    }

struct NewEventForm: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""

    var body: some View {
        VStack(alignment: .trailing) {
            TextField("Title", text: $title)
            HStack {
                Button("Cancel", role: .cancel) { dismiss() }
                    .keyboardShortcut(.cancelAction)
                Button("Add") { dismiss() }
                    .keyboardShortcut(.defaultAction)
            }
        }
        .padding()
        .frame(width: 360)
    }
}
```

**Note:** End the button's title with … because it opens a sheet that asks for more. Return and Escape run Add and Cancel through their shortcuts.

### Rules

- **Pair the confirming button with Cancel.** A sheet with only Add or Done suggests finishing is the only way out. Cancel lets people leave without saving.
- **Open at a size that fits the content.** People don't usually resize sheets, so pick a sensible size. Allow resizing when the content benefits from more room.
- **Use a window or panel for long or repeated work.** A sheet suits a quick, self-contained task. For editing at length, open a window. For input people give again and again while watching the result, use a panel.

### Pitfalls

- **A sheet blocks only its own window.** The window behind it dims and waits, but people can still switch to your app's other windows.
- **Call `dismiss` from inside the sheet.** Read `@Environment(\.dismiss)` in the sheet's own view. Read in the view that presents the sheet, it would dismiss that view instead.

### Key APIs

`.presentationSizing(_:)`, `.frame(width:height:)`, `.keyboardShortcut(.defaultAction)`

More variants, left out to keep this file short: Cancel and Done buttons, Sheet for a tapped item, Small sheet that fits its content, Edit an item (macOS), A sheet people can resize (macOS). Apple's docs: https://developer.apple.com/documentation/swiftui/view/sheet(ispresented:ondismiss:content:).md

## Related

[alert](alert.md), [popover](popover.md), [confirmation-dialog](confirmation-dialog.md), [navigation-stack](navigation-stack.md), [window](window.md), [opening-windows](opening-windows.md), [keyboard-shortcuts](keyboard-shortcuts.md)
