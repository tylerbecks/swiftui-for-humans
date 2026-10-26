---
id: image-symbols
title: Image & SF Symbols
platforms: [macOS]
availability: macOS 10.15+
docs: https://developer.apple.com/documentation/swiftui/image.md
hig: https://developer.apple.com/design/human-interface-guidelines/sf-symbols.md
---

# Image & SF Symbols

Show pictures from your app, and thousands of system symbols that match your text.

Also called: <img>, icon, icons, NSImage, NSImageView, SF Symbols, systemName, symbol, rendering mode, hierarchical.

## Contents

- Default code
- Rules
- Pitfalls
- Key APIs
- Variants
- Related

## Default code

```swift
Label("Downloads", systemImage: "arrow.down.circle")

Image(systemName: "cloud.sun.rain.fill")
    .symbolRenderingMode(.multicolor)
    .font(.largeTitle)
```

**Note:** Size a symbol with `.font`, like text. It scales with the font and lines up with text on the same line.

## Rules

- **Size symbols with the font, not a frame.** A symbol matches the weight and size of the text beside it. Use `.imageScale` to give it more or less emphasis.
- **Check the rendering mode where it's used.** Size and background change how well people can see a symbol's details. Try another mode if a symbol is hard to read.
- **Use variable color for change, not depth.** It suits values that change, like volume or signal strength. To show depth, use the hierarchical mode instead.
- **Animate symbols with a purpose.** Each effect says something, like a bounce for “this happened.” Too many animations distract people from their work.
- **Make a clickable image a button.** On the Mac, an image people click should be a `Button` with an image, not an image with a tap gesture.

## Pitfalls

- **Image modifiers come first.** `.resizable()` returns an `Image`, so call it before view modifiers like `.frame` or `.padding`.
- **Symbols depend on the OS version.** A symbol or effect added in a given year isn't there on older systems. The SF Symbols app shows each one's availability.

## Key APIs

- `Image(systemName:)`: An SF Symbol by name.
- `Image(_:)`: An image from your asset catalog.
- `.resizable()`: Lets an image grow or shrink to its frame.
- `.symbolRenderingMode(_:)`: `.hierarchical`, `.palette`, or `.multicolor`.
- `Image(systemName:variableValue:)`: Fills a symbol's layers by a 0–1 value.
- `.imageScale(_:)`: A symbol's size next to its text.
- `.symbolEffect(_:value:)`: Plays an effect when a value changes.
- `Image(decorative:)`: An image VoiceOver skips.

## Variants

### Symbols next to text

A symbol takes its size from the font. `.imageScale` makes it smaller or larger than the text without changing the text.

```swift
VStack(alignment: .leading, spacing: 8) {
    Label("Small", systemImage: "heart.fill")
        .imageScale(.small)
    Label("Medium", systemImage: "heart.fill")
        .imageScale(.medium)
    Label("Large", systemImage: "heart.fill")
        .imageScale(.large)
}
.foregroundStyle(.pink)
```

### A level with a variable value

Pass `variableValue:` from 0 to 1 and the symbol fills its layers to match, like a volume indicator.

```swift
@State private var volume = 0.5

HStack {
    Image(systemName: "speaker.wave.3.fill", variableValue: volume)
        .frame(width: 24)
    Slider(value: $volume)
        .frame(width: 180)
}
.font(.title2)
```

### Effects that answer a click

Bounce a symbol each time a value changes with `.symbolEffect(.bounce, value:)`, and swap symbols with a `.replace` transition.

```swift
@State private var alerts = 0
@State private var isMuted = false

HStack(spacing: 24) {
    Button("Ring", systemImage: "bell") { alerts += 1 }
        .symbolEffect(.bounce, value: alerts)
    Button(isMuted ? "Unmute" : "Mute", systemImage: isMuted ? "speaker.slash" : "speaker.wave.2") {
        isMuted.toggle()
    }
    .contentTransition(.symbolEffect(.replace))
}
```

### Show that work is ongoing

Use an effect that repeats, like `.pulse`, with `isActive:` so it stops when the work does.

```swift
@State private var isSyncing = true

VStack(spacing: 12) {
    Image(systemName: "arrow.triangle.2.circlepath.icloud")
        .font(.largeTitle)
        .symbolEffect(.pulse, isActive: isSyncing)
    Toggle("Syncing", isOn: $isSyncing)
}
```

### A photo from your asset catalog

Call `.resizable()`, then `.scaledToFill()` and a frame, and clip the overflow so the photo fills the space.

```swift
Image("photo")
    .resizable()
    .scaledToFill()
    .frame(width: 260, height: 150)
    .clipShape(.rect(cornerRadius: 12))
```

**Note:** For the Mac, give bitmaps @1x and @2x versions, or use PDF or SVG for flat artwork that needs to scale.

## Related

`sf-symbols` (apple-design skill), [text-label](text-label.md), [async-image](async-image.md), `app-icons` (apple-design skill), `color` (apple-design skill)
