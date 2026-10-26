---
name: swiftui-build
description: Writes current SwiftUI for iOS, iPadOS, and macOS, using the iOS and macOS 26–27 APIs (Liquid Glass, @Observable, NavigationStack, Tab) instead of the deprecated ones models tend to write. Gives default code, variants, pitfalls, and availability fallbacks for each component, plus Mac windows, menus, and settings. Use when creating or changing SwiftUI views, screens, or components, such as buttons, lists, forms, text fields, pickers, navigation, tabs, sheets, alerts, toolbars, search, layout, grids, scroll views, state and data flow, animation, or Mac windows, menus, and settings. Trigger keywords include SwiftUI, SwiftUI view, iOS app, iPad app, macOS app, Xcode, NavigationStack, NavigationSplitView, TabView, List, Form, sheet, toolbar, @State, @Observable, @Binding, Liquid Glass, glassEffect, animation, and Xcode previews.
---

# SwiftUI build

Current SwiftUI for iOS, iPadOS, and macOS 26 and 27 (Xcode 27 SDKs). Your training data likely predates these APIs and is full of deprecated patterns. **Read the matching reference before writing code** rather than relying on memory.

This skill holds judgment: which API, which default, and what goes wrong. For full API detail, use Xcode's `DocumentationSearch` tool when it's available, or fetch Apple's docs as Markdown by adding `.md` to any developer.apple.com documentation URL. Each reference links its page.

## Workflow

1. Find the component in the index below and read `references/<id>.md`. For a Mac app, also read its **On macOS** section; Mac-only topics say `platforms: [macOS]`.
2. Check the deployment target. Anything newer than it goes behind `if #available` with a real fallback. See `references/liquid-glass.md`, `references/whats-new-26.md`, and `references/whats-new-27.md`.
3. Start from the reference's **Default code**, adapt a **Variant** if one fits, and follow its **Rules** and **Pitfalls**.
4. Build with zero new warnings. If the `swiftui-review` skill is installed, run its linter on the files you changed.

## Top rules

1. `NavigationStack` (or `NavigationSplitView` for sidebars and columns), never `NavigationView`. Navigate by value with `.navigationDestination(for:)`.
2. New models are `@Observable` classes held in `@State`, passed as plain properties, `@Bindable` for bindings, or `@Environment(Model.self)`. Don't write `ObservableObject`, `@Published`, `@StateObject`, or `@EnvironmentObject` in new code.
3. Async work goes in `.task { }`, which cancels with the view. Not `DispatchQueue.main.async`, and not `Task { }` in `onAppear`.
4. Icon buttons are `Button("Share", systemImage: "square.and.arrow.up") { }`, with `.labelStyle(.iconOnly)` when the title should be hidden. VoiceOver reads the title.
5. Text uses text styles (`.body`, `.headline`), never `.font(.system(size:))`. Use `@ScaledMetric` for custom sizes.
6. Lay out by available space (`ViewThatFits`, size classes, `containerRelativeFrame`, `onGeometryChange`), never `UIScreen.main` or device checks.
7. System bars, sheets, menus, and button styles adopt Liquid Glass when built with the 26+ SDK. Use `.glassEffect` only on floating controls, never on content, and remove custom bar backgrounds.
8. `ForEach` needs stable identity: make elements `Identifiable`. Avoid `id: \.self` on values that can repeat, and avoid `.indices`.
9. Prefer `@ViewBuilder` and `some View` over `AnyView`. Use one `.animation(_:value:)` per change, or `withAnimation`.
10. Every new view gets a `#Preview`, with `@Previewable @State` for bindings.

{{corrections}}

## Index

{{index}}
