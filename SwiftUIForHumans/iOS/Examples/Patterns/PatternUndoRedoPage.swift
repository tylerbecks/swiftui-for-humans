import SwiftUI

extension ComponentPage {
    static let patternUndoRedo = ComponentPage(
        id: "undo-redo",
        title: "Undo and Redo",
        summary: "Let people take back what they did, instead of asking “Are you sure?” first.",
        category: .patterns,
        kind: .concept,
        symbol: "arrow.uturn.backward.circle",
        availability: ["iOS 13.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/environmentvalues/undomanager",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/undo-and-redo",
        aliases: ["undo", "redo", "UndoManager", "shake to undo", "cmd+z", "ctrl+z", "history", "revert", "are you sure", "confirm delete"],
        related: ["confirmation-dialog", "alert", "list", "swipe-actions", "toolbar", "feedback"],
        notes: [
            "**Register undo for your own changes.** Deleting or moving rows can't be undone unless you register it. Text fields manage typing themselves, so try shake to undo in yours to confirm it behaves as you expect.",
            "**`undoManager` can be `nil`.** It is where undo isn't supported, so call it with `?.` and skip registering.",
            "**Still confirm what can't be undone.** For a rare, permanent action, like deleting an account, a [confirmation dialog](catalog://confirmation-dialog) is still the right call.",
        ],
        api: [
            APIItem("`@Environment(\\.undoManager)`", "The window's undo manager, or `nil`."),
            APIItem("`registerUndo(withTarget:handler:)`", "Records how to reverse a change."),
            APIItem("`setActionName(_:)`", "Names it: “Undo Delete Bread”."),
            APIItem("`undo()` and `redo()`", "Steps back or forward."),
            APIItem("`canUndo` and `canRedo`", "Whether there's anything to step to."),
            APIItem("`beginUndoGrouping()`", "Groups several changes into one undo."),
            APIItem("`removeAllActions(withTarget:)`", "Clears undo for a model you're done with."),
        ],
        guidelines: [
            Guideline(
                "Offer undo instead of asking first.",
                "For everyday deletes, just do it and let people undo. A confirmation every time slows people down, and they soon tap through it without reading.",
                good: "Delete right away; undo is there.",
                bad: "An alert for every delete."
            ) {
                UndoMiniList()
            } bad: {
                PatternMockAlert(title: "Delete “Bread”?", message: "Are you sure?", buttons: ["Cancel", "Delete"], destructiveIndex: 1)
            },
            Guideline(
                "Say what will be undone.",
                "On iPhone, shaking shows an alert titled “Undo” plus your action name. One or two words, like “Delete Bread”, tell people exactly what comes back.",
                good: "A named action.",
                bad: "No action name."
            ) {
                PatternMockAlert(title: "Undo Delete Bread", buttons: ["Cancel", "Undo"], boldIndex: 1)
            } bad: {
                PatternMockAlert(title: "Undo", buttons: ["Cancel", "Undo"], boldIndex: 1)
            },
            Guideline(
                "Show what changed.",
                "If the undone change is off screen, scroll to it or highlight it. Otherwise people think nothing happened and undo again."
            ),
            Guideline(
                "Let people undo many times.",
                "Don't cap the history without a reason. People expect to step back through everything since they opened or saved their work."
            ),
            Guideline(
                "Keep the system gestures, and add buttons only if needed.",
                "Don't reuse shake or the three-finger swipe for anything else. If you add Undo and Redo buttons, put them in the toolbar with the standard symbols."
            ),
        ],
        sources: [
            "https://developer.apple.com/design/human-interface-guidelines/undo-and-redo",
            "https://developer.apple.com/design/human-interface-guidelines/alerts",
            "https://developer.apple.com/documentation/swiftui/environmentvalues/undomanager",
            "https://developer.apple.com/documentation/foundation/undomanager",
            "https://developer.apple.com/documentation/uikit/uiapplication/applicationsupportsshaketoedit",
        ],
        reviewed: "October 2026"
    ) {
        UndoThumbnail()
    } content: { page in
        UndoArticle(page: page)
    }
}

// MARK: - Article

private struct UndoArticle: View {
    let page: ComponentPage

    var body: some View {
        ArticlePage(page: page) {
            Prose("Undo lets people try things without fear. People shake their iPhone, swipe with three fingers, or press ⌘Z on an iPad keyboard. SwiftUI hands you the window's `UndoManager`, and you tell it how to reverse each change.")

            VStack(alignment: .leading, spacing: 12) {
                SectionTitle("Try it")
                Prose("Delete a few items, then tap **Undo** and **Redo**. The button shows the name you set with `setActionName`.")
                UndoDemo()
                Aside(.important, "`registerUndo` needs a class to call back, so keep the data in an `@Observable` class, not in `@State` structs. Register the reverse step inside the undo handler, too, or Redo stays grayed out.")
            }
            .id("playground")
        }
    }
}

// MARK: - Model

@MainActor @Observable
private final class UndoGroceries {
    var items = ["Apples", "Bread", "Coffee", "Eggs", "Milk"]

    func remove(_ item: String, undoManager: UndoManager?) {
        guard let index = items.firstIndex(of: item) else { return }
        items.remove(at: index)
        undoManager?.registerUndo(withTarget: self) { list in
            list.insert(item, at: index, undoManager: undoManager)
        }
        undoManager?.setActionName("Delete \(item)")
    }

    func insert(_ item: String, at index: Int, undoManager: UndoManager?) {
        items.insert(item, at: index)
        undoManager?.registerUndo(withTarget: self) { list in
            list.remove(item, undoManager: undoManager)
        }
        undoManager?.setActionName("Delete \(item)")
    }
}

// MARK: - Try it

private struct UndoDemo: View {
    @Environment(\.undoManager) private var environmentUndo
    @State private var groceries = UndoGroceries()
    /// Used only if the environment has no undo manager.
    @State private var fallbackUndo = UndoManager()
    /// UndoManager isn't observable; bump this to redraw the buttons.
    @State private var changes = 0

    private var undoManager: UndoManager { environmentUndo ?? fallbackUndo }

    var body: some View {
        VStack(spacing: 0) {
            PreviewCard(minHeight: 300, isAttached: true) {
                VStack(spacing: 14) {
                    VStack(spacing: 0) {
                        ForEach(groceries.items, id: \.self) { item in
                            if item != groceries.items.first {
                                Divider().padding(.leading, 12)
                            }
                            HStack {
                                Text(item)
                                Spacer()
                                Button("Delete \(item)", systemImage: "trash", role: .destructive) {
                                    groceries.remove(item, undoManager: undoManager)
                                    changes += 1
                                }
                                .labelStyle(.iconOnly)
                                .buttonStyle(.borderless)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .transition(.opacity.combined(with: .move(edge: .leading)))
                        }
                        if groceries.items.isEmpty {
                            Text("All gone. Tap Undo.")
                                .foregroundStyle(.secondary)
                                .padding(.vertical, 12)
                        }
                    }
                    .background(.background.secondary, in: .rect(cornerRadius: 12))
                    .animation(.snappy, value: groceries.items)

                    HStack {
                        Button {
                            undoManager.undo()
                            changes += 1
                        } label: {
                            Label(undoManager.canUndo ? undoManager.undoMenuItemTitle : "Undo", systemImage: "arrow.uturn.backward")
                        }
                        .disabled(!undoManager.canUndo)
                        Spacer()
                        Button {
                            undoManager.redo()
                            changes += 1
                        } label: {
                            Label("Redo", systemImage: "arrow.uturn.forward")
                        }
                        .disabled(!undoManager.canRedo)
                    }
                    .buttonStyle(.bordered)
                    .id(changes)
                }
                .frame(maxWidth: 340)
            }
            Divider()
            CodeBlock(code: Self.code, isCollapsible: true, isAttached: true)
        }
        .cardStyle()
        .onDisappear {
            undoManager.removeAllActions(withTarget: groceries)
        }
    }

    static let code = """
    @MainActor @Observable
    final class Groceries {
        var items = ["Apples", "Bread", "Coffee", "Eggs"]

        func remove(_ item: String, undoManager: UndoManager?) {
            guard let index = items.firstIndex(of: item) else { return }
            items.remove(at: index)
            undoManager?.registerUndo(withTarget: self) { list in
                list.insert(item, at: index, undoManager: undoManager)
            }
            undoManager?.setActionName("Delete \\(item)")
        }

        func insert(_ item: String, at index: Int, undoManager: UndoManager?) {
            items.insert(item, at: index)
            // Registering here is what makes Redo work.
            undoManager?.registerUndo(withTarget: self) { list in
                list.remove(item, undoManager: undoManager)
            }
            undoManager?.setActionName("Delete \\(item)")
        }
    }

    struct GroceryList: View {
        @State private var groceries = Groceries()
        @Environment(\\.undoManager) private var undoManager

        var body: some View {
            List {
                ForEach(groceries.items, id: \\.self) { item in
                    Text(item)
                }
                .onDelete { offsets in
                    for item in offsets.map({ groceries.items[$0] }) {
                        groceries.remove(item, undoManager: undoManager)
                    }
                }
            }
        }
    }
    """
}

// MARK: - Do / Don't

private struct UndoMiniList: View {
    var body: some View {
        VStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(["Apples", "Coffee", "Eggs"], id: \.self) { Text($0).font(.subheadline) }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(10)
            .background(.background.secondary, in: .rect(cornerRadius: 10))
            HStack {
                Label("Undo Delete Bread", systemImage: "arrow.uturn.backward")
                    .font(.caption.weight(.medium))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(.fill.secondary, in: .capsule)
                Spacer()
            }
        }
        .frame(width: 210)
    }
}

// MARK: - Thumbnail

private struct UndoThumbnail: View {
    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: "arrow.uturn.backward")
            Image(systemName: "arrow.uturn.forward").foregroundStyle(.tertiary)
        }
        .font(.system(size: 34, weight: .semibold))
        .foregroundStyle(.tint)
        .padding(.horizontal, 22)
        .padding(.vertical, 14)
        .background(.fill.tertiary, in: .capsule)
    }
}
