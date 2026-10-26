---
id: text-editor
title: TextEditor
platforms: [iOS, iPadOS, macOS]
availability: iOS 14.0+, macOS 11.0+, visionOS 1.0+
docs: https://developer.apple.com/documentation/swiftui/texteditor.md
hig: https://developer.apple.com/design/human-interface-guidelines/text-views.md
---

# TextEditor

A scrolling, multi-line area for long text such as notes or a bio.

## Contents

- Default code
- Rules
- Pitfalls
- Key APIs
- Variants
- On macOS
- Related

## Default code

```swift
@State private var notes = ""

TextEditor(text: $notes)
    .frame(height: 150)
```

**Important:** A `TextEditor` takes all the space it's offered. Outside a `Form`, give it a `.frame(height:)` or `minHeight`.

## Rules

- **Use a text editor for long text, and a text field for short text.** A bio or a note needs room to see several lines at once. A one-line field hides most of what people wrote.
- **Keep the text readable at every size.** Use a text style like `.body` rather than a fixed point size, so the editor follows Dynamic Type.
- **Tell people what to write when it's empty.** An empty box gives no hint. Add a placeholder, and a counter if there's a limit.

## Pitfalls

- **Hide the default background before adding your own.** `.background` alone has no effect until you add `.scrollContentBackground(.hidden)`.
- **Text modifiers style all of the text.** `.font`, `.foregroundStyle`, and `.lineSpacing` apply to the whole editor. For styled runs, bind an `AttributedString`.

## Key APIs

`TextEditor(text:)`, `.frame(height:)`, `.scrollContentBackground(.hidden)`, `.font(_:)`, `.lineSpacing(_:)`, `.onChange(of:)`

## Variants

### Placeholder

`TextEditor` has no placeholder, so overlay a `Text` and hide it once there's text.

```swift
@State private var notes = ""

TextEditor(text: $notes)
    .overlay(alignment: .topLeading) {
        if notes.isEmpty {
            Text("Write something…")
                .foregroundStyle(.tertiary)
                .padding(.top, 8)
                .padding(.leading, 5)
                .allowsHitTesting(false)
        }
    }
    .frame(height: 120)
```

**Note:** The padding lines the placeholder up with the editor's first line, and `.allowsHitTesting(false)` lets taps reach the editor.

### Character limit

Trim the text in `.onChange(of:)` to enforce a maximum, and show a counter below the editor.

```swift
@State private var bio = ""
let limit = 80

VStack(alignment: .trailing) {
    TextEditor(text: $bio)
        .frame(height: 100)
        .onChange(of: bio) {
            if bio.count > limit {
                bio = String(bio.prefix(limit))
            }
        }
    Text("\(bio.count)/\(limit)")
        .font(.caption.monospacedDigit())
        .foregroundStyle(bio.count == limit ? .red : .secondary)
}
```

### Rich text

Bind an `AttributedString` and people can make selected text bold, italic, or underlined from the edit menu.

```swift
@State private var text = AttributedString("Select a word, then tap Format to make it bold.")

TextEditor(text: $text)
    .frame(height: 120)
```

**Note:** Rich text editing needs iOS 26 or later. With a `String` binding, the editor stays plain text.

## On macOS

A scrolling area for long, multi-line text, plain or styled.

### Default code

```swift
@State private var notes = ""

TextEditor(text: $notes)
    .frame(minHeight: 120)
```

**Note:** A `TextEditor` scrolls when the text is longer than its frame, like a `<textarea>`. Give it a frame that fits a few lines.

### Rules

- **Use a text editor for long text.** Notes, messages, and descriptions need room for several lines. A single-line field cuts them off.
- **Keep the text easy to read.** You can mix fonts, colors, and alignment, but readability comes first. Check your text with accessibility settings such as Increase Contrast turned on.

### Pitfalls

- **A `String` gives plain text; an `AttributedString` gives styled text.** Bind an attributed string and the editor's context menu offers formatting controls.
- **Find applies to the editors in the view.** With more than one `TextEditor` under `.findNavigator`, which one shows the find bar isn't guaranteed.

### Key APIs

`TextEditor(text:selection:)`, `.findNavigator(isPresented:)`, `.findDisabled()`, `.replaceDisabled()`, `.autocorrectionDisabled()`

### Variants

#### Find and replace

Bind `.findNavigator(isPresented:)` to show the find bar from a button. It stays in sync when people close it themselves.

```swift
@State private var text = "Bring snacks, bring water, bring a map."
@State private var isFinding = false

VStack(alignment: .leading) {
    Button("Find…", systemImage: "magnifyingglass") {
        isFinding.toggle()
    }
    TextEditor(text: $text)
        .font(.body)
        .findNavigator(isPresented: $isFinding)
        .frame(width: 320, height: 120)
}
```

**Important:** Put `.findDisabled()` or `.replaceDisabled()` closer to the editor than `.findNavigator`, or they won't apply.

More variants, left out to keep this file short: Growing TextField instead, Styled text (macOS), A code editor (macOS), A limit with a counter (macOS). Apple's docs: https://developer.apple.com/documentation/swiftui/texteditor.md

## Related

[text-field](text-field.md), [focus-state](focus-state.md), [text](text.md), [focus-keyboard](focus-keyboard.md), [text-label](text-label.md), `typography` (apple-design skill)
