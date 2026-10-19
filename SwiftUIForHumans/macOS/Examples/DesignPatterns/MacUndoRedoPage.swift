import Combine
import SwiftUI

extension ComponentPage {
    static let undoRedo = ComponentPage(
        id: "undo-redo",
        title: "Undo and redo",
        summary: "Let people take back any change with ⌘Z, and tell them what they're undoing.",
        category: .patterns,
        kind: .concept,
        symbol: "arrow.uturn.backward",
        availability: ["macOS 10.15+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/environmentvalues/undomanager",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/undo-and-redo",
        aliases: [
            "undo", "redo", "⌘Z", "Command-Z", "UndoManager", "NSUndoManager", "registerUndo",
            "setActionName", "Edit menu", "revert", "history", "ctrl+z",
        ],
        related: ["menu-bar-conventions", "keyboard-shortcuts", "commands", "document-editor"],
        notes: [
            "**The window brings the undo manager.** Read `\\.undoManager` from the environment. It's `nil` where undo isn't supported, so skip registering then.",
            "**Undo registers redo for you.** When an undo runs code that registers its own undo, that becomes the redo. Write each change as a method that registers its opposite.",
        ],
        api: [
            APIItem("`@Environment(\\.undoManager)`", "The window's undo manager, or `nil`."),
            APIItem("`registerUndo(withTarget:handler:)`", "Records how to reverse a change."),
            APIItem("`setActionName(_:)`", "Names it: Undo Delete, Redo Rename."),
            APIItem("`undoMenuItemTitle`", "The full title, like “Undo Delete Milk”."),
            APIItem("`canUndo` / `canRedo`", "Whether there's anything to undo or redo."),
            APIItem("`beginUndoGrouping()`", "Starts a group that undoes as one step."),
        ],
        guidelines: [
            Guideline(
                "Say what will be undone.",
                "People often press ⌘Z several times and lose track. A named action, like Undo Delete Note, tells them what's next.",
                good: "Undo Delete Milk.",
                bad: "Just Undo."
            ) {
                DPMenuDrawing(title: "Edit", items: [
                    .item("Undo Delete Milk", "⌘Z", highlighted: true),
                    .item("Redo", "⇧⌘Z", enabled: false),
                ], width: 230)
            } bad: {
                DPMenuDrawing(title: "Edit", items: [
                    .item("Undo", "⌘Z", highlighted: true),
                    .item("Redo", "⇧⌘Z", enabled: false),
                ], width: 230)
            },
            Guideline(
                "Keep Undo and Redo at the top of the Edit menu.",
                "Mac users look for them there, and press ⌘Z and ⇧⌘Z without looking."
            ),
            Guideline(
                "Show what changed.",
                "If the undone change is out of view, scroll to it or highlight it. Otherwise people think nothing happened and undo again."
            ),
            Guideline(
                "Don't limit undo without reason.",
                "People expect to undo everything since they opened or saved the document."
            ),
            Guideline(
                "Undo a burst of small changes as one.",
                "Dragging a slider makes many tiny changes. Record one undo for the whole drag, so one ⌘Z puts it back."
            ),
            Guideline(
                "Add undo buttons only when you must.",
                "The Edit menu and ⌘Z are where people go. If your app needs buttons too, put them in the toolbar with the standard symbols."
            ),
        ],
        sources: [
            "https://developer.apple.com/design/human-interface-guidelines/undo-and-redo",
            "https://developer.apple.com/design/human-interface-guidelines/the-menu-bar",
            "https://developer.apple.com/documentation/swiftui/environmentvalues/undomanager",
            "https://developer.apple.com/documentation/foundation/undomanager",
            "https://developer.apple.com/documentation/foundation/undomanager/registerundo(withtarget:handler:)",
            "https://developer.apple.com/documentation/foundation/undomanager/undomenuitemtitle",
            "https://developer.apple.com/documentation/foundation/undomanager/beginundogrouping()",
        ],
        reviewed: "October 2026"
    ) {
        VStack(spacing: 12) {
            Image(systemName: "arrow.uturn.backward.circle")
                .font(.system(size: 34))
                .foregroundStyle(.tint)
            DPKeys("⌘", "Z")
        }
        .accessibilityHidden(true)
    } content: { page in
        MacUndoRedoArticle(page: page)
    }
}

// MARK: - Page

private struct MacUndoRedoArticle: View {
    let page: ComponentPage

    var body: some View {
        ArticlePage(page: page) {
            Prose("People try things when they know they can take them back. On the Mac that means **Undo** and **Redo** at the top of the Edit menu, with ⌘Z and ⇧⌘Z, for every change people make to their content. Each window has an `UndoManager`: you tell it how to reverse each change, and it runs the Edit menu for you.")

            VStack(alignment: .leading, spacing: 16) {
                SectionTitle("Try it")
                Prose("Delete a few items, then choose **Edit > Undo** or press ⌘Z. The changes go on this window's real undo manager, so the menu names them too.")
                UndoPlayground()
            }
            .id("demo")

            VStack(alignment: .leading, spacing: 16) {
                SectionTitle("Usage")
                    .id("code")
                Prose("Put each change in a method that also registers its opposite. Undoing a delete calls `add`, which registers a delete again, and that's the redo.")
                CodeBlock(code: """
                @MainActor @Observable
                final class GroceryList {
                    var items = ["Milk", "Eggs", "Bread"]

                    func add(_ item: String, at index: Int, undoManager: UndoManager?) {
                        items.insert(item, at: index)
                        undoManager?.registerUndo(withTarget: self) { list in
                            list.remove(at: index, undoManager: undoManager)
                        }
                        undoManager?.setActionName("Add \\(item)")
                    }

                    func remove(at index: Int, undoManager: UndoManager?) {
                        let item = items.remove(at: index)
                        undoManager?.registerUndo(withTarget: self) { list in
                            list.add(item, at: index, undoManager: undoManager)
                        }
                        undoManager?.setActionName("Delete \\(item)")
                    }
                }

                struct GroceryView: View {
                    @Environment(\\.undoManager) private var undoManager
                    @State private var list = GroceryList()

                    var body: some View {
                        List(Array(list.items.enumerated()), id: \\.offset) { index, item in
                            HStack {
                                Text(item)
                                Spacer()
                                Button("Delete", systemImage: "trash") {
                                    list.remove(at: index, undoManager: undoManager)
                                }
                                .labelStyle(.iconOnly)
                            }
                        }
                    }
                }
                """)
                Aside(.important, "In the handler, use the `list` it passes in, not `self`. The undo manager holds on to the closure, and capturing the target again can keep it alive.")
            }

            VStack(alignment: .leading, spacing: 16) {
                SectionTitle("Examples")
                    .id("examples")
                VStack(alignment: .leading, spacing: 44) {
                    ExampleCard(
                        title: "One undo for a whole drag",
                        caption: "Remember the value when the drag starts in `onEditingChanged`, and register one undo when it ends.",
                        code: """
                        @MainActor @Observable
                        final class Canvas {
                            var zoom = 1.0

                            func setZoom(_ newValue: Double, from oldValue: Double, undoManager: UndoManager?) {
                                zoom = newValue
                                undoManager?.registerUndo(withTarget: self) { canvas in
                                    canvas.setZoom(oldValue, from: newValue, undoManager: undoManager)
                                }
                                undoManager?.setActionName("Zoom")
                            }
                        }

                        @Environment(\\.undoManager) private var undoManager
                        @State private var canvas = Canvas()
                        @State private var startZoom = 1.0

                        Slider(value: $canvas.zoom, in: 0.5...3) { isEditing in
                            if isEditing {
                                startZoom = canvas.zoom
                            } else {
                                canvas.setZoom(canvas.zoom, from: startZoom, undoManager: undoManager)
                            }
                        }
                        """,
                        minHeight: 150,
                        aside: Aside(.note, "Drag the slider a few times, then press ⌘Z. Each drag comes back in one step.")
                    ) {
                        ZoomSample()
                    }

                    ExampleCard(
                        title: "Undo and redo buttons, when you need them",
                        caption: "Read `canUndo` and `undoMenuItemTitle` to enable and name the buttons, and use the standard arrow symbols.",
                        code: """
                        @Environment(\\.undoManager) private var undoManager

                        HStack {
                            Button("Undo", systemImage: "arrow.uturn.backward") {
                                undoManager?.undo()
                            }
                            .disabled(undoManager?.canUndo != true)
                            .help(undoManager?.undoMenuItemTitle ?? "Undo")

                            Button("Redo", systemImage: "arrow.uturn.forward") {
                                undoManager?.redo()
                            }
                            .disabled(undoManager?.canRedo != true)
                            .help(undoManager?.redoMenuItemTitle ?? "Redo")
                        }
                        .labelStyle(.iconOnly)
                        """,
                        minHeight: 120,
                        aside: Aside(.note, "`UndoManager` isn't observable, so SwiftUI doesn't redraw when it changes. To keep the buttons current, also refresh the view when it posts its did-undo, did-redo, and did-close-group notifications, as this preview does.")
                    ) {
                        UndoButtonsSample()
                    }
                }
            }
        }
    }
}

// MARK: - Model

@MainActor @Observable
private final class DPGroceryList {
    var items = ["Milk", "Eggs", "Bread", "Apples", "Coffee"]

    func add(_ item: String, at index: Int, undoManager: UndoManager?) {
        let index = min(index, items.count)
        items.insert(item, at: index)
        undoManager?.registerUndo(withTarget: self) { list in
            list.remove(at: index, undoManager: undoManager)
        }
        undoManager?.setActionName("Add \(item)")
    }

    func remove(at index: Int, undoManager: UndoManager?) {
        guard items.indices.contains(index) else { return }
        let item = items.remove(at: index)
        undoManager?.registerUndo(withTarget: self) { list in
            list.add(item, at: index, undoManager: undoManager)
        }
        undoManager?.setActionName("Delete \(item)")
    }
}

/// Redraws its content whenever the window's undo manager changes, so
/// titles like “Undo Delete Milk” stay current.
private struct UndoObserver<Content: View>: View {
    @Environment(\.undoManager) private var undoManager
    @State private var tick = 0
    @ViewBuilder let content: (UndoManager?, Int) -> Content

    var body: some View {
        content(undoManager, tick)
            .onReceive(NotificationCenter.default.publisher(for: .NSUndoManagerDidCloseUndoGroup)) { _ in tick += 1 }
            .onReceive(NotificationCenter.default.publisher(for: .NSUndoManagerDidUndoChange)) { _ in tick += 1 }
            .onReceive(NotificationCenter.default.publisher(for: .NSUndoManagerDidRedoChange)) { _ in tick += 1 }
    }
}

// MARK: - Playground

private struct UndoPlayground: View {
    @State private var list = DPGroceryList()

    var body: some View {
        UndoObserver { undoManager, _ in
            VStack(spacing: 0) {
                PreviewCard(minHeight: 240, isAttached: true) {
                    VStack(spacing: 0) {
                        ForEach(Array(list.items.enumerated()), id: \.offset) { index, item in
                            if index > 0 { Divider() }
                            HStack {
                                Text(item)
                                Spacer()
                                Button("Delete \(item)", systemImage: "trash") {
                                    list.remove(at: index, undoManager: undoManager)
                                }
                                .labelStyle(.iconOnly)
                                .buttonStyle(.borderless)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 7)
                        }
                        if list.items.isEmpty {
                            Text("Nothing left. Press ⌘Z.")
                                .foregroundStyle(.secondary)
                                .padding(12)
                        }
                    }
                    .frame(width: 300)
                    .background(.background, in: .rect(cornerRadius: 10))
                    .overlay {
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(.separator)
                    }
                }
                Divider()
                HStack(spacing: 16) {
                    Text("Edit menu")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Text(undoManager?.canUndo == true ? undoManager?.undoMenuItemTitle ?? "Undo" : "Undo (dimmed)")
                        .font(.callout.monospaced())
                    Text(undoManager?.canRedo == true ? undoManager?.redoMenuItemTitle ?? "Redo" : "Redo (dimmed)")
                        .font(.callout.monospaced())
                        .foregroundStyle(.secondary)
                }
                .padding(14)
                .frame(maxWidth: .infinity)
                .background(Surface.code)
            }
            .cardStyle()
        }
    }
}

// MARK: - Examples

@MainActor @Observable
private final class DPCanvas {
    var zoom = 1.0

    func setZoom(_ newValue: Double, from oldValue: Double, undoManager: UndoManager?) {
        zoom = newValue
        undoManager?.registerUndo(withTarget: self) { canvas in
            canvas.setZoom(oldValue, from: newValue, undoManager: undoManager)
        }
        undoManager?.setActionName("Zoom")
    }
}

private struct ZoomSample: View {
    @Environment(\.undoManager) private var undoManager
    @State private var canvas = DPCanvas()
    @State private var startZoom = 1.0

    var body: some View {
        VStack(spacing: 12) {
            Slider(value: $canvas.zoom, in: 0.5...3) { isEditing in
                if isEditing {
                    startZoom = canvas.zoom
                } else {
                    canvas.setZoom(canvas.zoom, from: startZoom, undoManager: undoManager)
                }
            }
            .frame(width: 260)
            Text("zoom = \(canvas.zoom, format: .number.precision(.fractionLength(2)))")
                .font(.footnote.monospaced())
                .foregroundStyle(.secondary)
        }
    }
}

private struct UndoButtonsSample: View {
    var body: some View {
        UndoObserver { undoManager, _ in
            HStack {
                Button("Undo", systemImage: "arrow.uturn.backward") {
                    undoManager?.undo()
                }
                .disabled(undoManager?.canUndo != true)
                .help(undoManager?.undoMenuItemTitle ?? "Undo")

                Button("Redo", systemImage: "arrow.uturn.forward") {
                    undoManager?.redo()
                }
                .disabled(undoManager?.canRedo != true)
                .help(undoManager?.redoMenuItemTitle ?? "Redo")
            }
            .labelStyle(.iconOnly)
            .controlSize(.large)
        }
    }
}
