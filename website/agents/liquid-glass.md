---
id: liquid-glass
title: Liquid Glass
platforms: [iOS, iPadOS, macOS]
availability: iOS 26, macOS 26
reviewed: 2026-10-26
---

# Liquid Glass

Liquid Glass is the iOS/macOS 26 material for the **controls layer**: bars, toolbars, tab bars, sheets, menus, and buttons that float above content. Most of it is automatic. Your job is mostly to stop blocking it, and to use it sparingly on your own controls.

## Rules

1. **Build with the current SDK, then delete custom bar chrome.** System bars, toolbars, tab bars, sheets, and menus adopt glass when built with Xcode 26+. Remove `.toolbarBackground(...)`, `UINavigationBarAppearance` / `UITabBarAppearance` setup, and solid `.presentationBackground` on sheets; they hide the glass.
2. **Glass only on the controls layer.** Never on list rows, cards, or content. Content that needs a backdrop gets a material (`.regularMaterial`).
3. **System button styles first.** `.buttonStyle(.glass)` for most, `.glassProminent` for the one main action per screen.
4. **Custom controls:** `.glassEffect(_:in:)`, applied after `.padding()` and `.frame()` (like a background). Default shape is a capsule.
   - `.regular` by default; `.clear` only over busy photos or video; `.identity` turns it off without changing layout.
   - `.tint(_:)` only to carry meaning or mark the primary action. `.interactive()` makes it react to touch (iOS).
5. **Group nearby glass in one `GlassEffectContainer(spacing:)`.** Glass can't sample other glass, so separate effects look wrong side by side. A container also lets shapes blend and morph.
6. **Morph with ids.** Inside a container, give views `.glassEffectID(_:in:)` with a `@Namespace` and change them inside `withAnimation`. `.glassEffectUnion(id:namespace:)` merges distant views into one shape.
7. **Toolbars:** use plain SF Symbols (no `.circle` variants; the glass is the container). Split groups with `ToolbarSpacer(.fixed)` or `ToolbarSpacer(.flexible)`. Take one item out of the shared background with `.sharedBackgroundVisibility(.hidden)`.
8. **Edges:** custom bars go in `.safeAreaBar(edge:)` so the scroll edge effect sees them. `.scrollEdgeEffectStyle(.hard, for: .top)` for dense UI like tables. `.backgroundExtensionEffect()` lets hero art extend under a sidebar or inspector.
9. **Tab bars (iOS):** `.tabBarMinimizeBehavior(.onScrollDown)`, `.tabViewBottomAccessory { }` for a mini player, `Tab(role: .search)` for the search tab.
10. **Concentric corners:** use `ConcentricRectangle()` (or `.rect(corners: .concentric)`) so inner shapes follow the container's radius.
11. **Accessibility:** system glass handles Reduce Transparency and Increase Contrast. Check custom glass with both on, and keep text on glass at a text style, not a fixed size.
12. **The compatibility opt-out is gone.** `UIDesignRequiresCompatibility` is ignored when you build with the 27 SDKs, so fix layouts rather than opting out.

## Default code

```swift ios
struct PhotoControls: View {
    @Namespace private var glass
    @State private var isEditing = false

    var body: some View {
        GlassEffectContainer(spacing: 16) {
            HStack(spacing: 16) {
                if isEditing {
                    Button("Crop", systemImage: "crop") { }
                        .labelStyle(.iconOnly)
                        .padding()
                        .glassEffect(.regular.interactive())
                        .glassEffectID("crop", in: glass)
                }
                Button(isEditing ? "Done" : "Edit", systemImage: "pencil") {
                    withAnimation { isEditing.toggle() }
                }
                .labelStyle(.iconOnly)
                .padding()
                .glassEffect(.regular.interactive())
                .glassEffectID("edit", in: glass)
            }
        }
    }
}
```

## Supporting OS versions before 26

Gate glass and fall back to a material. Keep the shape the same so layout doesn't jump.

```swift
extension View {
    @ViewBuilder
    func floatingBackground() -> some View {
        if #available(iOS 26, macOS 26, *) {
            glassEffect(.regular, in: .capsule)
        } else {
            background(.regularMaterial, in: .capsule)
        }
    }
}
```

## Pitfalls

- Glass on glass (a glass button inside a glass card) looks muddy. One layer.
- Many separate `.glassEffect` views without a container cost more to render and can't blend.
- `.clear` glass over plain backgrounds is nearly invisible; add a dimming layer when the media behind is bright.

## Apple docs

- https://developer.apple.com/documentation/technologyoverviews/adopting-liquid-glass.md
- https://developer.apple.com/documentation/swiftui/applying-liquid-glass-to-custom-views.md
- https://developer.apple.com/documentation/swiftui/view/glasseffect(_:in:).md
- https://developer.apple.com/documentation/swiftui/glasseffectcontainer.md
- https://developer.apple.com/design/human-interface-guidelines/materials.md
