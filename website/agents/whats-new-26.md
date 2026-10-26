---
id: whats-new-26
title: What's new in SwiftUI 26
platforms: [iOS, iPadOS, macOS]
availability: iOS 26, macOS 26 (Xcode 26)
reviewed: 2026-10-26
---

# What's new in SwiftUI 26

APIs from the 2025 releases that models often don't know. Everything here needs iOS 26 / macOS 26 unless noted; gate with `if #available(iOS 26, macOS 26, *)` when you deploy earlier. Liquid Glass has its own topic: `liquid-glass.md`.

## Use these

| Need | API |
|---|---|
| Glass on custom controls | `.glassEffect(_:in:)`, `GlassEffectContainer`, `.buttonStyle(.glass / .glassProminent)` (see `liquid-glass.md`) |
| Space between toolbar groups | `ToolbarSpacer(.fixed)` / `ToolbarSpacer(.flexible)` |
| Search in the bottom toolbar (iPhone) | `DefaultToolbarItem(kind: .search, placement: .bottomBar)` |
| Collapse search to a button | `.searchToolbarBehavior(.minimize)` |
| A subtitle under the title | `.navigationSubtitle(_:)` (macOS had it since 11; iOS 26) |
| Zoom a sheet out of a toolbar button | `.matchedTransitionSource(id:in:)` on the `ToolbarItem` + `.navigationTransition(.zoom(sourceID:in:))` (iOS) |
| Shrink the tab bar on scroll | `.tabBarMinimizeBehavior(.onScrollDown)` (iOS) |
| A mini player above the tab bar | `.tabViewBottomAccessory { }`; read `\.tabViewBottomAccessoryPlacement` to adapt (iOS) |
| A custom bar with the scroll edge effect | `.safeAreaBar(edge:) { }` |
| Crisp or soft scroll edges | `.scrollEdgeEffectStyle(.hard / .soft, for:)` |
| Art that extends under a sidebar | `.backgroundExtensionEffect()` |
| Corners that follow their container | `ConcentricRectangle()`, `.rect(corners: .concentric)` |
| Rich text editing | `TextEditor(text: $attributedString, selection: $selection)` with `AttributedString` and `AttributedTextSelection` |
| A find bar in Mac text views | `.findNavigator(isPresented:)` (iOS since 16, macOS 26), `FindContext` |
| Web content | `WebView(url:)` or `WebView(page)` with an `@Observable` `WebPage` (`import WebKit`) |
| Custom animatable data | `@Animatable` macro on the view or shape; `@AnimatableIgnored` for skipped properties |
| Slider tick marks | automatic when you pass `step:` |
| Multi-item drag | `.draggable(containerItemID:containerNamespace:)` + `.dragContainer(for:itemID:in:_:)` |
| Window resize anchor (macOS, iPadOS) | `.windowResizeAnchor(_:)` |
| Assistive Access scene (iOS) | `AssistiveAccess { }` scene |
| Equal-width buttons | `.buttonSizing(.flexible)` |

## Behavior changes to expect

- System bars, sheets, menus, and controls render in Liquid Glass when built with Xcode 26+. Remove custom bar backgrounds that hide it.
- iPadOS 26 shows a menu bar: commands you add with `.commands { }` appear there, so iPad apps should define them like Mac apps.
- Deprecated in 26: `Text + Text` concatenation (interpolate instead) and `UIScreen.main`. See `deprecated-apis.md`.

## Examples

```swift ios
struct Library: View {
    @State private var query = ""

    var body: some View {
        TabView {
            Tab("Books", systemImage: "books.vertical") {
                NavigationStack {
                    List(0..<50) { Text("Book \($0)") }
                        .navigationTitle("Books")
                        .navigationSubtitle("50 titles")
                }
            }
            Tab(role: .search) {
                NavigationStack {
                    Text("Results for \(query)")
                        .searchable(text: $query)
                }
            }
        }
        .tabBarMinimizeBehavior(.onScrollDown)
        .tabViewBottomAccessory {
            Label("Now Reading", systemImage: "book")
        }
    }
}
```

```swift
@Animatable
struct Wave: Shape {
    var amplitude: Double
    @AnimatableIgnored var label = "wave"

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.midY))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.midY),
            control: CGPoint(x: rect.midX, y: rect.midY - amplitude)
        )
        return path
    }
}
```

## Apple docs

- https://developer.apple.com/documentation/updates/swiftui.md (the June 2025 section)
- https://developer.apple.com/documentation/swiftui/toolbarspacer.md
- https://developer.apple.com/documentation/swiftui/view/tabviewbottomaccessory(content:).md
- https://developer.apple.com/documentation/webkit/webview-swift.struct.md
