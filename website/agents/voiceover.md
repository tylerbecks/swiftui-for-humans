---
id: voiceover
title: VoiceOver
platforms: [iOS, iPadOS, macOS]
availability: iOS 14.0+, macOS 13.0+
docs: https://developer.apple.com/documentation/swiftui/view-accessibility.md
hig: https://developer.apple.com/design/human-interface-guidelines/voiceover.md
reviewed: October 2026
---

# VoiceOver

Labels, traits, and grouping that tell the screen reader what each view is.

## Contents

- Rules
- Pitfalls
- Guide
- Key APIs
- Variants
- On macOS
- Related

## Rules

- **Label every icon-only button.** Without a label, VoiceOver has nothing useful to say, and people can't tell what the button does.
- **Leave the control type out of the label.** VoiceOver already says “Button” from the trait. Writing it in the label makes it say it twice.
- **Make labels make sense on their own.** People often jump between controls without hearing what's around them. “Remove AirPods” works out of context; three buttons all called “Delete” don't.
- **Hide images that are only decoration.** Skipping them saves people time. Describe images that carry meaning, but only what the image adds beyond nearby text.
- **Mark headings.** VoiceOver users can jump from heading to heading with the rotor, the way sighted people skim. Use the `.isHeader` trait on section titles.
- **Keep hints short and about the result.** A hint like “Saves the recipe” says what happens. Skip the gesture (“Double-tap to…”), which VoiceOver already explains.

## Pitfalls

- **Standard controls are labeled for you.** `Button`, `Toggle`, `Slider`, and `TextField` take their label and value from what they show. Add modifiers where a view has no text.
- **Voice Control uses the same labels.** People say a control's name to tap it, so a missing label also breaks voice commands.
- **Listen to it.** Turn on VoiceOver on a device, or open Accessibility Inspector in Xcode, and swipe through each screen.

## Guide

VoiceOver reads the screen aloud, one element at a time, as people swipe. For each element it speaks a **label** (what it is called), a **value** (its current state), its **traits** (button, heading, selected), and, after a pause, an optional **hint**. Your job is to fill those in where SwiftUI can't guess them.

### Hear it

```swift
Button {
    // Share
} label: {
    Image(systemName: "square.and.arrow.up")
}
```

**Note:** This is a close approximation. The exact wording and pauses depend on the device, the language, and the person's VoiceOver settings.

## Key APIs

`.accessibilityLabel(_:)`, `.accessibilityValue(_:)`, `.accessibilityHint(_:)`, `.accessibilityAddTraits(_:)`, `.accessibilityElement(children:)`, `.accessibilityHidden(true)`, `.accessibilityAction(named:_:)`

## Variants

### Label an icon-only button

Use `Label` with `.labelStyle(.iconOnly)`: the icon shows, and the title becomes the VoiceOver label.

```swift
Button {
    // Share the recipe
} label: {
    Label("Share", systemImage: "square.and.arrow.up")
        .labelStyle(.iconOnly)
}
```

**Note:** For a plain `Image` label, add `.accessibilityLabel("Share")` to the button instead.

## On macOS

Labels, grouping, and rotors that let the screen reader describe your windows.

### Rules

- **Label every key element.** VoiceOver speaks labels people never see. An icon-only button with no label tells them nothing about what it does.
- **Describe images that carry meaning, and hide the rest.** Describe only what the image adds to nearby text. Skipping decoration saves people time.
- **Give windows clear titles and sections real headings.** The title is the first thing VoiceOver reports. Headings let people skim a window the way sighted people scan it.
- **Say how things belong together.** Closeness and alignment show sighted people that a photo and caption go together. Group them so VoiceOver reads them together too.
- **Announce changes people can't see.** When content appears, moves, or finishes loading somewhere else, tell assistive tools, so people's picture of the window stays right.

### Pitfalls

- **Standard controls describe themselves.** `Button`, `Toggle`, `TextField`, and `Picker` take their label and value from what they show. Add modifiers where a view has no text, or where SwiftUI can't guess.
- **Toolbar titles still count.** Hiding a window's title with `.toolbar(removing: .title)` is a visual change; assistive tools still get the title.

### Key APIs

`.accessibilityAddTraits(.isHeader)`, `.accessibilityRotor(_:entries:entryLabel:)`

### Variants

#### Label an icon-only button

Use a `Label` with `.labelStyle(.iconOnly)`: the icon shows, and the title becomes what VoiceOver reads.

```swift
Button {
    // Share the note
} label: {
    Label("Share", systemImage: "square.and.arrow.up")
        .labelStyle(.iconOnly)
}
```

**Note:** With a plain `Image` as the label, add `.accessibilityLabel("Share")` to the button instead.

More variants, left out to keep this file short: Read a row as one stop, Describe a custom control, Name your gestures, Mark section headings, Read a row as one element (macOS), Offer hover-only buttons as actions (macOS), Add a rotor for what people look for (macOS), Announce a change (macOS). Apple's docs: https://developer.apple.com/documentation/swiftui/view-accessibility.md

## Related

[accessibility](accessibility.md), [button](button.md), [label](label.md), [image](image.md), [dynamic-type](dynamic-type.md), [keyboard-access](keyboard-access.md), [contrast-transparency](contrast-transparency.md), [image-symbols](image-symbols.md), [toolbar](toolbar.md)
