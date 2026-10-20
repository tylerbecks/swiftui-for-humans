import SwiftUI

/// A Mac window: a sidebar of one tab's pages beside the open page.
///
/// The Mac has no tab bar. Design, Build, and Ship switch with the
/// control at the top of the sidebar (like Xcode's navigators) or ⌘1–⌘3,
/// and the search field at the top of the sidebar searches all three.
struct MacContentView: View {
    /// The page this window was opened for with "Open in New Window".
    var windowPage: ComponentPage.ID? = nil
    @State private var tab: AppTab = .design
    @State private var componentsSelection: String?
    @State private var designSelection: String?
    @State private var shipSelection: String?
    /// Saved per window, so relaunching returns to the last tab and page.
    /// Kept apart from the state above because scene storage only works in
    /// a real scene, and launch snapshots draw the view without one.
    @SceneStorage("tab") private var savedTab: AppTab = .design
    @SceneStorage("selection") private var savedComponents: String?
    @SceneStorage("selection.design") private var savedDesign: String?
    @SceneStorage("selection.ship") private var savedShip: String?
    @State private var searchText = ""
    @FocusState private var isSearchFocused: Bool
    @State private var columns = NavigationSplitViewVisibility.all
    @State private var didRestore = false

    var body: some View {
        NavigationSplitView(columnVisibility: $columns) {
            MacSidebar(tab: $tab, selection: selection(for: tab), searchText: $searchText, open: open)
                .navigationSplitViewColumnWidth(min: 220, ideal: 250, max: 340)
        } detail: {
            NavigationStack {
                if let page = Catalog.page(id: selection(for: tab).wrappedValue) {
                    page.makeContent()
                        .id(page.id)
                } else {
                    OverviewView(tab: tab)
                }
            }
            // With no title in the toolbar, this keeps the page's buttons
            // at the trailing edge, where Mac toolbars put them.
            .toolbar {
                ToolbarSpacer(.flexible)
            }
        }
        .searchable(text: $searchText, placement: .sidebar, prompt: "Search")
        .searchFocused($isSearchFocused)
        // The page shows its title as a large heading, so the toolbar
        // doesn't repeat it. The window keeps it for the Window menu and
        // Mission Control.
        .navigationTitle(windowTitle)
        .toolbar(removing: .title)
        .environment(\.openPage, OpenPageAction { id in
            open(id)
        })
        .environment(\.makeRoomForInspector, MakeRoomAction {
            withAnimation { columns = .detailOnly }
        })
        .environment(\.openURL, OpenURLAction { url in
            // `catalog://<page id>` opens a page here; every other link
            // opens in the default browser.
            if url.scheme == "catalog", let id = url.host(), Catalog.page(id: id) != nil {
                open(id)
                return .handled
            }
            return .systemAction
        })
        .focusedSceneValue(\.catalogNavigator, navigator)
        .modifier(ReviewPrompt())
        .onAppear(perform: restore)
        .onChange(of: tab) { savedTab = tab }
        .onChange(of: componentsSelection) { savedComponents = componentsSelection }
        .onChange(of: designSelection) { savedDesign = designSelection }
        .onChange(of: shipSelection) { savedShip = shipSelection }
    }

    private var windowTitle: String {
        Catalog.page(id: selection(for: tab).wrappedValue)?.title ?? tab.title
    }

    /// For the Go menu and its keyboard shortcuts.
    private var navigator: CatalogNavigator {
        let current = selection(for: tab).wrappedValue
        let neighbors = current.map { Catalog.neighbors(of: $0) }
        return CatalogNavigator(
            tab: tab,
            previous: neighbors?.previous?.id,
            next: neighbors?.next?.id,
            select: { newTab in
                if newTab == .search {
                    isSearchFocused = true
                } else {
                    // A search replaces the sidebar's page list, so end it
                    // to show the section ⌘1–⌘3 asked for.
                    searchText = ""
                    tab = newTab
                }
            },
            open: { open($0) }
        )
    }

    private func selection(for tab: AppTab) -> Binding<ComponentPage.ID?> {
        switch tab {
        case .design: $designSelection
        case .ship: $shipSelection
        default: $componentsSelection
        }
    }

    private func open(_ id: ComponentPage.ID) {
        guard let page = Catalog.page(id: id) else { return }
        let pageTab = page.category.tab
        selection(for: pageTab).wrappedValue = id
        tab = pageTab
    }

    /// Picks the first tab and page: `-tab`, `-open <id>`, and `-search`
    /// (used when testing), then the restored state. Each tab starts on
    /// its overview.
    private func restore() {
        guard !didRestore else { return }
        didRestore = true
        tab = savedTab == .search ? .design : savedTab
        componentsSelection = savedComponents
        designSelection = savedDesign
        shipSelection = savedShip
        #if DEBUG
        // A snapshot shows the page column alone: the sidebar's Liquid
        // Glass needs the window server to draw.
        if LaunchSnapshot.isRequested { columns = .detailOnly }
        #endif
        for contentTab in AppTab.contentTabs {
            let current = selection(for: contentTab)
            let isValid = current.wrappedValue.map { Catalog.page(id: $0)?.category.tab == contentTab || $0 == Catalog.overviewID } ?? false
            if !isValid {
                current.wrappedValue = Catalog.overviewID
            }
        }
        if let windowPage {
            open(windowPage)
            return
        }
        // Launch flags set up the first window only, not ones opened later.
        guard !LaunchOptions.didApplyToWindow else { return }
        LaunchOptions.didApplyToWindow = true
        if let name = LaunchOptions.value(for: "-tab"), let launchTab = AppTab(rawValue: name), launchTab != .search {
            tab = launchTab
        }
        if let id = LaunchOptions.value(for: "-open") {
            if id == Catalog.overviewID {
                selection(for: tab).wrappedValue = id
            } else {
                open(id)
            }
        }
        if let query = LaunchOptions.value(for: "-search") {
            searchText = query
        }
    }
}

/// The sidebar: the tab switcher, then either the tab's pages by category
/// or, while searching, matches from every tab.
private struct MacSidebar: View {
    @Binding var tab: AppTab
    @Binding var selection: ComponentPage.ID?
    @Binding var searchText: String
    let open: (ComponentPage.ID) -> Void
    @Environment(\.openWindow) private var openWindow

    private var query: String {
        searchText.trimmingCharacters(in: .whitespaces)
    }

    var body: some View {
        Group {
            if query.isEmpty {
                pageList
            } else {
                SearchResults(query: query, open: open)
            }
        }
        .safeAreaInset(edge: .top, spacing: 0) {
            Picker("Section", selection: $tab) {
                ForEach(AppTab.contentTabs) { tab in
                    Label(tab.title, systemImage: tab.symbol)
                        .tag(tab)
                }
            }
            .pickerStyle(.segmented)
            .labelsHidden()
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .disabled(!query.isEmpty)
        }
    }

    private var pageList: some View {
        List(selection: $selection) {
            Label("Overview", systemImage: "square.grid.2x2")
                .tag(Catalog.overviewID)
                .accessibilityIdentifier("row-overview")
            ForEach(tab.categories) { category in
                let pages = Catalog.pages(in: category)
                if !pages.isEmpty {
                    Section(category.rawValue) {
                        ForEach(pages) { page in
                            SidebarRow(page: page)
                                .tag(page.id)
                                .accessibilityIdentifier("row-\(page.id)")
                        }
                    }
                }
            }
        }
        .openInNewWindowMenu()
    }
}

/// Matches from every tab, grouped by tab, with the alias that matched
/// when the title didn't.
private struct SearchResults: View {
    let query: String
    let open: (ComponentPage.ID) -> Void
    @State private var selection: ComponentPage.ID?

    private var matches: [ComponentPage] {
        Catalog.pages.filter { $0.matches(query) }
    }

    var body: some View {
        List(selection: $selection) {
            ForEach(AppTab.contentTabs) { tab in
                let pages = matches.filter { $0.category.tab == tab }
                if !pages.isEmpty {
                    Section(tab.title) {
                        ForEach(pages) { page in
                            SidebarRow(page: page, detail: detail(for: page))
                                .tag(page.id)
                                .accessibilityIdentifier("row-\(page.id)")
                        }
                    }
                }
            }
        }
        .openInNewWindowMenu()
        .onChange(of: selection) { _, id in
            if let id { open(id) }
        }
        .overlay {
            if matches.isEmpty {
                ContentUnavailableView.search(text: query)
            }
        }
    }

    private func detail(for page: ComponentPage) -> String {
        if let alias = page.aliasMatch(for: query) {
            return "\(page.category.rawValue) · Matches “\(alias)”"
        }
        return page.category.rawValue
    }
}

