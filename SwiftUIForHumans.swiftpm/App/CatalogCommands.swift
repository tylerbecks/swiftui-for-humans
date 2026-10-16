import SwiftUI

/// What the menu bar and keyboard shortcuts can do in the focused window.
/// `ContentView` publishes it with `.focusedSceneValue`, so each window on
/// iPad acts on its own tab and page.
struct CatalogNavigator {
    let tab: AppTab
    let previous: ComponentPage.ID?
    let next: ComponentPage.ID?
    let select: @MainActor (AppTab) -> Void
    let open: @MainActor (ComponentPage.ID) -> Void
}

extension FocusedValues {
    @Entry var catalogNavigator: CatalogNavigator?
}

/// The iPad menu bar (and the list shown when you hold ⌘): a Go menu with
/// tab and page shortcuts, plus the system's sidebar and inspector toggles.
struct CatalogCommands: Commands {
    @FocusedValue(\.catalogNavigator) private var navigator

    var body: some Commands {
        SidebarCommands()
        InspectorCommands()
        CommandMenu("Go") {
            ForEach(Array(AppTab.contentTabs.enumerated()), id: \.element) { index, tab in
                Button(tab.title, systemImage: tab.symbol) {
                    navigator?.select(tab)
                }
                .keyboardShortcut(KeyEquivalent(Character(String(index + 1))))
            }
            Button("Search", systemImage: AppTab.search.symbol) {
                navigator?.select(.search)
            }
            .keyboardShortcut("f")
            Divider()
            Button("Previous Page", systemImage: "arrow.left") {
                if let id = navigator?.previous { navigator?.open(id) }
            }
            .keyboardShortcut("[")
            .disabled(navigator?.previous == nil)
            Button("Next Page", systemImage: "arrow.right") {
                if let id = navigator?.next { navigator?.open(id) }
            }
            .keyboardShortcut("]")
            .disabled(navigator?.next == nil)
        }
    }
}

extension View {
    /// Adds "Open in New Window" to a list's rows, where the device
    /// supports more than one window (iPad, Mac).
    func openInNewWindowMenu() -> some View {
        modifier(OpenInNewWindowMenu())
    }
}

private struct OpenInNewWindowMenu: ViewModifier {
    @Environment(\.supportsMultipleWindows) private var supportsMultipleWindows
    @Environment(\.openWindow) private var openWindow

    func body(content: Content) -> some View {
        content.contextMenu(forSelectionType: ComponentPage.ID.self) { ids in
            if supportsMultipleWindows, let id = ids.first, Catalog.page(id: id) != nil {
                Button("Open in New Window", systemImage: "macwindow.badge.plus") {
                    openWindow(value: id)
                }
            }
        }
    }
}

/// "Open in New Window" for a single page outside a list, like an
/// overview card.
struct OpenInNewWindowButton: View {
    let id: ComponentPage.ID
    @Environment(\.supportsMultipleWindows) private var supportsMultipleWindows
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        if supportsMultipleWindows {
            Button("Open in New Window", systemImage: "macwindow.badge.plus") {
                openWindow(value: id)
            }
        }
    }
}
