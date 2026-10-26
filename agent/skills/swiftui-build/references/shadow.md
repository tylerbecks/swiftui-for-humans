---
id: shadow
title: shadow
platforms: [iOS, iPadOS]
availability: iOS 13.0+, macOS 10.15+, visionOS 1.0+
docs: https://developer.apple.com/documentation/swiftui/view/shadow(color:radius:x:y:).md
---

# shadow

Draws a soft shadow behind a view to lift it off the background.

Also called: box-shadow, drop shadow, elevation, glow, text-shadow, depth, CALayer shadow.

## Default code

```swift
Text("Balance: $2,480")
    .padding()
    .background {
        RoundedRectangle(cornerRadius: 16)
            .fill(.background)
            .shadow(color: .black.opacity(0.15), radius: 12, y: 6)
    }
```

**Note:** `x` and `y` move the shadow and `radius` blurs it. There is no spread setting like in CSS.

## Pitfalls

- **The default shadow is strong.** It's black at 33% opacity. Most designs use `.black.opacity(0.1)` to `0.2`.
- **Shadows barely show in dark mode.** iOS shows depth there with a lighter fill or a material instead, so don't rely on a shadow alone.

## Key APIs

- `.shadow(radius:)`: A default gray shadow, blurred by `radius`.
- `.shadow(color:radius:x:y:)`: Sets the color and moves the shadow by `x` and `y`.
- `radius:`: The blur amount, like the blur in CSS `box-shadow`.
- `.background { Shape().shadow() }`: Shadows only the card, not its contents.
- `.shadow(.drop(…))`: A shadow as a fill style, for shapes and text.

## Variants

### Shadow on every child

Put `.shadow` on a background shape so only the card casts one, not each piece of text.

```swift
// Every text gets a shadow
VStack {
    Text("Title").font(.headline)
    Text("Subtitle")
}
.shadow(radius: 4)

// Only the card gets a shadow
VStack {
    Text("Title").font(.headline)
    Text("Subtitle")
}
.padding()
.background {
    RoundedRectangle(cornerRadius: 12)
        .fill(.background.secondary)
        .shadow(radius: 4)
}
```

**Important:** A shadow on a container with no background is applied to every child separately, so each line of text gets its own shadow.

### Readable text on a busy image

Use a tight, dark `.shadow` to help white text stand out on a bright photo.

```swift
ZStack {
    LinearGradient(colors: [.yellow, .orange, .pink], startPoint: .top, endPoint: .bottom)
        .clipShape(.rect(cornerRadius: 12))
    Text("Golden hour")
        .font(.largeTitle.bold())
        .foregroundStyle(.white)
        .shadow(color: .black.opacity(0.5), radius: 3, y: 2)
}
.frame(height: 120)
```

### Colored glow

Give `.shadow` the view's own color and no offset, and it reads as a glow.

```swift
Circle()
    .fill(.purple)
    .frame(width: 60, height: 60)
    .shadow(color: .purple.opacity(0.8), radius: 20)
```

## Related

[clip-shape](clip-shape.md), [background-overlay](background-overlay.md), [visual-effects](visual-effects.md), `materials` (apple-design skill)
