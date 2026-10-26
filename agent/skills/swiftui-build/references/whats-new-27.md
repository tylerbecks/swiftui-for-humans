---
id: whats-new-27
title: What's new in SwiftUI 27
platforms: [iOS, iPadOS, macOS]
availability: iOS 27, macOS 27 (Xcode 27); some items 27.1
reviewed: 2026-10-26
---

# What's new in SwiftUI 27

The 2026 releases, checked against the iOS 27.1 / macOS 27 SDKs. Gate with `if #available(iOS 27, macOS 27, *)` (or `@available` on a type) when you deploy earlier. Items marked 27.1 need `#available(iOS 27.1, macOS 27.1, *)`.

## Changes you get by building with Xcode 27

- **`@State` is a macro.** A class stored in `@State` is created once, not on every parent update. You can drop workarounds that lazily created `@Observable` models in `.task` or `onAppear`.
- **`@ContentBuilder`** is the one builder for views, toolbars, and commands (today a typealias of `ViewBuilder`). Existing `@ViewBuilder` code keeps working.
- **Item and error alerts:** `.alert(_:item:actions:)`, `.alert(error:actions:)`, and `.confirmationDialog(_:item:titleVisibility:actions:)` drive the dialog from an optional. The `item:` forms back-deploy; `alert(error:)` with a plain `Error` needs 27.
- **Deprecated:** `FileDocument` / `ReferenceFileDocument` (use `Document`) and `RoundedBorderTextFieldStyle` (use `.textFieldStyle(.bordered)` plus `.textInputBorderShape(.roundedRectangle)`). See `deprecated-apis.md`.

## New APIs

| Need | API |
|---|---|
| Drag to reorder in any stack, grid, or layout | `ForEach(...).reorderable()` + `.reorderContainer(for:move:)` |
| Swipe actions outside `List` | `.swipeActions(edge:allowsFullSwipe:content:onPresentationChanged:)` + `.swipeActionsContainer()` on the scroll view |
| Keep key toolbar items when space runs out | `.visibilityPriority(.high)` on toolbar content |
| Secondary actions in the overflow menu (iOS) | `ToolbarOverflowMenu { }` |
| Pin an item to the trailing edge (iOS) | `ToolbarItem(placement: .topBarPinnedTrailing)` |
| Minimize toolbars on scroll | `.toolbarMinimizationBehavior(.onScrollDown, for: .navigationBar)` |
| A tab set apart at the trailing end | `Tab("New", systemImage: "plus", role: .prominent) { }` |
| Cache `AsyncImage` downloads | `.asyncImageURLSession(session)` or `AsyncImage(request:)` |
| A sheet that fades in (iOS) | `.navigationTransition(.crossFade)` on the sheet content |
| URL-based documents | `ReadableDocument`, `WritableDocument`, `Document`; `FileWrapperDocumentReader/Writer`; `URLDocumentConfiguration` |
| Limit gesture input sources | `GestureInputKinds` on tap, drag, long-press, magnify, and rotate gestures |
| Adaptive primary/secondary layout (27.1) | `ArrangementView` + `.arrangementViewStyle(.split)` or `.overlay` |
| Avoid camera housings and hinges (27.1) | `ReservedRegion`, `GeometryProxy.reservedRegions(kind:options:layoutDirectionBehavior:)` |
| Toolbars on the vertical axis (27.1) | `\.toolbarVerticalEdge`, `.toolbarVerticalBehavior(_:)`, `.axisBehavior(_:)` |

## Examples

```swift
@available(iOS 27, macOS 27, *)
struct Board: View {
    struct Card: Identifiable {
        let id = UUID()
        var title: String
    }

    @State private var cards = [Card(title: "Plan"), Card(title: "Build"), Card(title: "Ship")]

    var body: some View {
        VStack {
            ForEach(cards) { Text($0.title) }
                .reorderable()
        }
        .reorderContainer(for: Card.self) { difference in
            let moving = cards.filter { difference.sources.contains($0.id) }
            cards.removeAll { difference.sources.contains($0.id) }
            if case .before(let id) = difference.destination.position,
               let index = cards.firstIndex(where: { $0.id == id }) {
                cards.insert(contentsOf: moving, at: index)
            } else {
                cards.append(contentsOf: moving)
            }
        }
    }
}
```

```swift ios
@available(iOS 27, *)
struct MessageToolbar: View {
    var body: some View {
        NavigationStack {
            List(0..<40) { Text("Message \($0)") }
                .toolbar {
                    ToolbarItem(placement: .topBarPinnedTrailing) {
                        Button("Compose", systemImage: "square.and.pencil") { }
                    }
                    ToolbarItem { Button("Filter", systemImage: "line.3.horizontal.decrease") { } }
                        .visibilityPriority(.high)
                    ToolbarOverflowMenu {
                        Button("Archive All", systemImage: "archivebox") { }
                        Button("Mark All as Read", systemImage: "envelope.open") { }
                    }
                }
                .toolbarMinimizationBehavior(.onScrollDown, for: .navigationBar)
        }
    }
}
```

## Apple docs

- https://developer.apple.com/documentation/updates/swiftui.md (June and September 2026)
- https://developer.apple.com/documentation/swiftui/view/reordercontainer(for:isenabled:move:).md
- https://developer.apple.com/documentation/swiftui/toolbaroverflowmenu.md
- https://developer.apple.com/documentation/swiftui/document.md
- https://developer.apple.com/documentation/swiftui/arrangementview.md
