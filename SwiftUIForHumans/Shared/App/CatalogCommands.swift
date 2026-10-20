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
    /// Back, Forward, and Enclosing Level, where the window keeps a
    /// history (the Mac). Without it the Go menu leaves them out.
    var history: History? = nil

    struct History {
        let canGoBack: Bool
        let canGoForward: Bool
        let canGoUp: Bool
        let back: @MainActor () -> Void
        let forward: @MainActor () -> Void
        let up: @MainActor () -> Void
    }
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
            if let history = navigator?.history {
                Divider()
                Button("Back", systemImage: "chevron.backward") { history.back() }
                    .keyboardShortcut("[")
                    .disabled(!history.canGoBack)
                Button("Forward", systemImage: "chevron.forward") { history.forward() }
                    .keyboardShortcut("]")
                    .disabled(!history.canGoForward)
                Button("Enclosing Level", systemImage: "arrow.up") { history.up() }
                    .keyboardShortcut(.upArrow)
                    .disabled(!history.canGoUp)
            }
            Divider()
            Button("Previous Page", systemImage: "arrow.left") {
                if let id = navigator?.previous { navigator?.open(id) }
            }
            .keyboardShortcut("[", modifiers: CatalogPlatform.pageStepModifiers)
            .disabled(navigator?.previous == nil)
            Button("Next Page", systemImage: "arrow.right") {
                if let id = navigator?.next { navigator?.open(id) }
            }
            .keyboardShortcut("]", modifiers: CatalogPlatform.pageStepModifiers)
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
                    openWindow(id: ComponentPage.windowGroupID, value: id)
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
                openWindow(id: ComponentPage.windowGroupID, value: id)
            }
        }
    }
}

extension ComponentPage {
    /// The id of the window group that shows a page in a window of its
    /// own. The Mac's demo windows also take a `String`, so `openWindow`
    /// needs this to pick the page group.
    static let windowGroupID = "page"
}
