import SwiftUI

/// A row in the Mac sidebar: the Search destination, one of the three
/// areas, or a category in the current area.
enum SidebarItem: Hashable, Codable, Sendable {
    case search
    case area(AppTab)
    case category(ComponentCategory)
}

/// Where a window is: a sidebar destination, and the page open in it, if any.
struct Location: Hashable, Codable, Sendable {
    var item: SidebarItem
    var page: ComponentPage.ID? = nil
}

/// One window's place in the app, with Back and Forward like Finder or
/// System Settings. A `NavigationStack` can only go back, so the Mac keeps
/// its own history.
///
/// The sidebar highlight never depends on how you got somewhere: a page
/// always selects its category, and only an area's home selects the area.
@MainActor @Observable
final class WindowNavigator {
    private(set) var current: Location
    private var backStack: [Location] = []
    private var forwardStack: [Location] = []
    /// The area whose categories the sidebar lists. It stays put on Search.
    private(set) var shownArea: AppTab
    /// The search field's text, kept while you open a result and come back.
    var searchText = ""
    /// Bumped by ⌘F, so the search field takes focus even when Search is
    /// already open.
    private(set) var searchFocusRequest = 0

    private let defaults: UserDefaults

    init(start: Location = Location(item: .area(.design)), defaults: UserDefaults = .standard) {
        self.defaults = defaults
        current = start
        shownArea = Self.area(of: start) ?? .design
    }

    // MARK: Reading

    var currentPage: ComponentPage? {
        current.page.flatMap { Catalog.page(id: $0) }
    }

    var sidebarSelection: SidebarItem {
        if let page = currentPage { return .category(page.category) }
        return current.item
    }

    var canGoBack: Bool { !backStack.isEmpty }
    var canGoForward: Bool { !forwardStack.isEmpty }

    /// Whether there's an enclosing level: a page's category, or a
    /// category's area.
    var canGoUp: Bool {
        if current.page != nil { return true }
        if case .category = current.item { return true }
        return false
    }

    /// The last page opened in an area, for its home's Continue button. It
    /// lives in `UserDefaults`, so it survives relaunches.
    func lastPage(in tab: AppTab) -> ComponentPage? {
        defaults.string(forKey: Self.lastPageKey(tab)).flatMap { Catalog.page(id: $0) }
    }

    /// The title for the Window menu and Mission Control.
    var windowTitle: String {
        if let page = currentPage { return page.title }
        switch current.item {
        case .search: return "Search"
        case .area(let tab): return tab.title
        case .category(let category): return category.rawValue
        }
    }

    // MARK: Moving

    func go(_ location: Location) {
        guard location != current else { return }
        backStack.append(current)
        forwardStack.removeAll()
        move(to: location)
    }

    func show(_ item: SidebarItem) {
        go(Location(item: item))
    }

    /// Opens a page in its category, wherever it was opened from.
    func open(_ id: ComponentPage.ID) {
        guard let page = Catalog.page(id: id) else { return }
        go(Location(item: .category(page.category), page: id))
    }

    func showSearch() {
        show(.search)
        searchFocusRequest += 1
    }

    func goBack() {
        guard let location = backStack.popLast() else { return }
        forwardStack.append(current)
        move(to: location)
    }

    func goForward() {
        guard let location = forwardStack.popLast() else { return }
        backStack.append(current)
        move(to: location)
    }

    /// The enclosing level: page → category → area home (⌘↑).
    func goUp() {
        if let page = currentPage {
            show(.category(page.category))
        } else if case .category(let category) = current.item {
            show(.area(category.tab))
        }
    }

    /// Puts the window somewhere without adding history, for restoring a
    /// window or applying launch flags. A page that no longer exists falls
    /// back to its area's home.
    func restore(_ location: Location) {
        var location = location
        if let id = location.page, Catalog.page(id: id) == nil {
            location = Location(item: .area(Self.area(of: Location(item: location.item)) ?? .design))
        }
        move(to: location)
    }

    private func move(to location: Location) {
        current = location
        if let area = Self.area(of: location) {
            shownArea = area
        }
        if let page = currentPage {
            defaults.set(page.id, forKey: Self.lastPageKey(page.category.tab))
        }
    }

    // MARK: Helpers

    static func area(of location: Location) -> AppTab? {
        if let id = location.page, let page = Catalog.page(id: id) {
            return page.category.tab
        }
        switch location.item {
        case .area(let tab): return tab
        case .category(let category): return category.tab
        case .search: return nil
        }
    }

    private static func lastPageKey(_ tab: AppTab) -> String {
        "lastPage.\(tab.rawValue)"
    }
}
