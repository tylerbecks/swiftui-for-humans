---
id: image
title: Image
platforms: [iOS, iPadOS]
availability: iOS 13.0+, macOS 10.15+, visionOS 1.0+
docs: https://developer.apple.com/documentation/swiftui/image.md
hig: https://developer.apple.com/design/human-interface-guidelines/image-views.md
---

# Image

Shows a picture or an SF Symbol, and controls how it fills its frame.

Also called: <img>, img, picture, photo, UIImageView, object-fit, background-size: cover, contain, icon, aspect ratio.

## Contents

- Default code
- Rules
- Pitfalls
- Key APIs
- Variants
- Related

## Default code

```swift
Image("landscape")
    .resizable()
    .scaledToFill()
    .frame(width: 300, height: 200)
    .clipShape(.rect(cornerRadius: 16))
```

**Important:** Without `.resizable()`, an image draws at its own size and ignores the frame. Put it first, right after `Image(...)`.

## Rules

- **Keep text over images readable.** A busy photo can hide white text. Put a dark gradient or a material behind the text so it always contrasts.
- **Use SF Symbols for icons.** Symbols scale with Dynamic Type, match the text weight, and take the tint color. Save bitmap images for photos and art.
- **Make tappable images buttons.** Put the image in a `Button` label instead of adding `.onTapGesture`. It gets a pressed state and VoiceOver treats it as a button.
- **Provide images at @2x and @3x.** iPhone screens have two or three pixels per point. A single small bitmap looks blurry; a PDF or SVG asset scales cleanly.

## Pitfalls

- **Fit or fill, like CSS `object-fit`.** `.scaledToFit()` is `contain`: the whole image shows, with gaps. `.scaledToFill()` is `cover`: no gaps, but the edges overflow until you clip them.
- **Describe meaningful images for VoiceOver.** Add `.accessibilityLabel`, or use `Image(decorative:)` for images that are only decoration.
- **For an image from a URL, use [AsyncImage](async-image.md).** `Image` only shows images that are already in your app or in memory.

## Key APIs

- `Image(_:)`: An image from your asset catalog, by name.
- `Image(systemName:)`: An SF Symbol, sized and colored like text.
- `.resizable()`: Lets the image stretch to its frame. Must come first.
- `.scaledToFit()`: Shows the whole image inside the frame.
- `.scaledToFill()`: Fills the frame, cropping the edges once clipped.
- `.aspectRatio(_:contentMode:)`: Keeps a set width-to-height ratio.
- `.clipShape(_:)`: Clips to a shape: `.circle`, `.rect(cornerRadius:)`, and more.
- `.accessibilityLabel(_:)`: What VoiceOver says for the image.

## Variants

### Avatar

Fill a square with `.scaledToFill()`, clip it with `.clipShape(.circle)`, and add a ring overlay.

```swift
Image("profile")
    .resizable()
    .scaledToFill()
    .frame(width: 88, height: 88)
    .clipShape(.circle)
    .overlay {
        Circle().stroke(.background, lineWidth: 3)
    }
    .shadow(radius: 4)
```

### Cover image with a fixed aspect ratio

Size a `Color.clear` box with `.aspectRatio(16 / 9)` and fill its overlay with the image.

```swift
Color.clear
    .aspectRatio(16 / 9, contentMode: .fit)
    .overlay {
        Image("landscape")
            .resizable()
            .scaledToFill()
    }
    .clipShape(.rect(cornerRadius: 16))
```

**Important:** A filled image is wider than its frame until it's clipped, and it can push the layout around. The overlay keeps the box in charge of the size.

### Sizing SF Symbols

Size an `Image(systemName:)` with `.font`, not `.resizable()`, so it lines up with nearby text.

```swift
HStack(alignment: .firstTextBaseline, spacing: 20) {
    Image(systemName: "heart.fill").font(.body)
    Image(systemName: "heart.fill").font(.title)
    Image(systemName: "heart.fill").font(.largeTitle)
    Image(systemName: "heart.fill").font(.system(size: 56))
}
.foregroundStyle(.pink)
```

**Note:** Browse every symbol, and its rendering modes, in SF Symbols (`sf-symbols`, apple-design skill).

### Text over a photo

Add the caption in an `.overlay` with a dark `LinearGradient` behind it, so it stays readable.

```swift
Image("landscape")
    .resizable()
    .scaledToFill()
    .frame(height: 200)
    .overlay(alignment: .bottomLeading) {
        Text("Lake Bled at sunset")
            .font(.headline)
            .foregroundStyle(.white)
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.linearGradient(colors: [.clear, .black.opacity(0.6)], startPoint: .top, endPoint: .bottom))
    }
    .clipShape(.rect(cornerRadius: 16))
```

## Related

[async-image](async-image.md), `sf-symbols` (apple-design skill), [clip-shape](clip-shape.md), [frame](frame.md)
