---
id: custom-modifier
title: Custom Modifiers
platforms: [iOS, iPadOS]
availability: iOS 13.0+, macOS 10.15+, visionOS 1.0+
docs: https://developer.apple.com/documentation/swiftui/viewmodifier.md
---

# Custom Modifiers

Bundles a set of modifiers under one name, so you can reuse a style everywhere.

Also called: ViewModifier, css class, reusable style, mixin, theme, styled component, helper, extension View, design tokens.

## Contents

- Pitfalls
- Guide
- Key APIs
- Variants
- Related

## Pitfalls

- **Start with a plain `extension View` function.** Reach for a `ViewModifier` struct only when the style needs its own `@State` or reads `@Environment`.
- **Use a style protocol for controls.** `ButtonStyle`, `ToggleStyle`, and `LabelStyle` also know about pressed and disabled states. See [Button](button.md).

## Guide

When the same few modifiers show up on every card, give them a name. It's SwiftUI's version of a CSS class: define the look once, apply it in one line, and change every screen in one place.

These three views share one `.cardStyle()`. Change the style and all three update.

```swift
// 1. Define the style once.
struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.purple.opacity(0.12), in: .rect(cornerRadius: 16))
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(.purple.opacity(0.4))
            }
            .shadow(color: .purple.opacity(0.3), radius: 10, y: 4)
    }
}

// 2. Give it a dot-syntax name.
extension View {
    func cardStyle() -> some View {
        modifier(CardStyle())
    }
}

// 3. Use it anywhere.
Label("Your order shipped", systemImage: "shippingbox.fill")
    .font(.headline)
    .cardStyle()
```

## Key APIs

- `extension View { func … }`: The simplest reusable style: a function that returns the chain.
- `ViewModifier`: A struct that styles any view, and can hold state.
- `body(content:)`: Where a `ViewModifier` applies its modifiers to `content`.
- `.modifier(_:)`: Applies a `ViewModifier` to a view.
- `ButtonStyle`: A reusable look for buttons, with a pressed state.

## Variants

### Just an extension

Write a function in an `extension View` that returns the chain. Often it's all you need.

```swift
extension View {
    func sectionHeaderStyle() -> some View {
        font(.footnote.weight(.semibold))
            .textCase(.uppercase)
            .foregroundStyle(.secondary)
            .tracking(0.5)
    }
}

Text("Recent activity")
    .sectionHeaderStyle()
```

### A ViewModifier that reads the environment

Use a `ViewModifier` struct when the style reads `@Environment`, like this light and dark card.

```swift
struct AdaptiveCard: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        content
            .padding()
            .background(.background.secondary, in: .rect(cornerRadius: 16))
            .shadow(color: .black.opacity(colorScheme == .dark ? 0 : 0.15), radius: 8, y: 4)
            .overlay {
                if colorScheme == .dark {
                    RoundedRectangle(cornerRadius: 16).strokeBorder(.white.opacity(0.15))
                }
            }
    }
}

Text("Adapts to dark mode")
    .modifier(AdaptiveCard())
```

**Note:** `content` stands for whatever view the modifier is applied to. This card uses a shadow in light mode and an outline in dark mode, where shadows are hard to see.

### A modifier with a parameter

Give the modifier properties to pass values in, like this `.loading(_:)` that dims any view.

```swift
struct LoadingOverlay: ViewModifier {
    var isLoading: Bool

    func body(content: Content) -> some View {
        content
            .opacity(isLoading ? 0.4 : 1)
            .disabled(isLoading)
            .overlay {
                if isLoading {
                    ProgressView()
                }
            }
            .animation(.default, value: isLoading)
    }
}

extension View {
    func loading(_ isLoading: Bool) -> some View {
        modifier(LoadingOverlay(isLoading: isLoading))
    }
}

@State private var isLoading = false

Button("Place order") { isLoading.toggle() }
    .buttonStyle(.borderedProminent)
    .loading(isLoading)
```

**Important:** Avoid a catch-all `.if(condition) { … }` helper. Each branch is a different view to SwiftUI, so flipping it resets state instead of animating. Put the condition in the values, like `opacity(isLoading ? 0.4 : 1)` here.

## Related

[modifier-order](modifier-order.md), [background-overlay](background-overlay.md), [button](button.md), [environment](environment.md)
