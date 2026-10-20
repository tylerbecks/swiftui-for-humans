import SwiftUI

/// A Mac window, laid out like Podcasts, TV, and Freeform: the sidebar
/// opens with four destinations (Search, Design, Build, Ship), then the
/// current area's categories. Each area has a home, each category a list,
/// and pages open in the detail with Back / Forward and a jump bar in the
/// toolbar.
struct MacContentView: View {
    /// The page this window was opened for with "Open in New Window".
    var windowPage: ComponentPage.ID? = nil
    @State private var nav = WindowNavigator()
    /// Saved per window, so relaunching returns to the same place.
    @SceneStorage("location") private var savedLocation: Data?
    @State private var columns = NavigationSplitViewVisibility.all
    @State private var didRestore = false

    var body: some View {
        NavigationSplitView(columnVisibility: $columns) {
            MacSidebar(nav: nav)
                .navigationSplitViewColumnWidth(min: 220, ideal: 250, max: 320)
                // The system's toggle sits over the floating sidebar, which
                // takes its clicks on macOS 27. Ours leads the toolbar's
                // navigation group instead.
                .toolbar(removing: .sidebarToggle)
        } detail: {
            detail
                .frame(minWidth: 560)
                .toolbar { toolbar }
        }
        // The content shows a large title, so the toolbar doesn't repeat
        // it. The window keeps it for the Window menu and Mission Control.
        .navigationTitle(nav.windowTitle)
        .toolbar(removing: .title)
        .environment(\.openPage, OpenPageAction { id in
            nav.open(id)
        })
        .environment(\.openURL, OpenURLAction { url in
            // `catalog://<page id>` opens a page here; every other link
            // opens in the default browser.
            if url.scheme == "catalog", let id = url.host(), Catalog.page(id: id) != nil {
                nav.open(id)
                return .handled
            }
            return .systemAction
        })
        .focusedSceneValue(\.catalogNavigator, navigator)
        .modifier(ReviewPrompt())
        .onAppear(perform: restore)
        .onChange(of: nav.current) {
            savedLocation = try? JSONEncoder().encode(nav.saved)
        }
    }

    @ViewBuilder
    private var detail: some View {
        if let page = nav.currentPage {
            page.makeContent()
                .id(page.id)
        } else {
            switch nav.current.item {
            case .search:
                MacSearchView(nav: nav)
            case .area(let tab):
                MacAreaHome(tab: tab, nav: nav)
                    .id(tab)
            case .category(let category):
                MacCategoryList(category: category, nav: nav)
                    .id(category)
            }
        }
    }

    @ToolbarContentBuilder
    private var toolbar: some ToolbarContent {
        ToolbarItem(placement: .navigation) {
            let isHidden = columns == .detailOnly
            Button(isHidden ? "Show Sidebar" : "Hide Sidebar", systemImage: "sidebar.leading") {
                withAnimation {
                    columns = isHidden ? .all : .detailOnly
                }
            }
            .help(isHidden ? "Show Sidebar" : "Hide Sidebar")
        }
        ToolbarItemGroup(placement: .navigation) {
            Button("Back", systemImage: "chevron.backward") { nav.goBack() }
                .disabled(!nav.canGoBack)
                .help("Back")
            Button("Forward", systemImage: "chevron.forward") { nav.goForward() }
                .disabled(!nav.canGoForward)
                .help("Forward")
        }
        if let page = nav.currentPage {
            ToolbarSpacer(.fixed, placement: .navigation)
            ToolbarItem(placement: .navigation) {
                JumpBar(page: page, nav: nav)
            }
        }
        // Keeps the page's own buttons at the trailing edge.
        ToolbarSpacer(.flexible)
        if let page = nav.currentPage {
            ToolbarItem(placement: .primaryAction) {
                OpenInNewWindowButton(id: page.id)
                    .help("Open in New Window")
            }
        }
    }

    /// For the Go menu and its keyboard shortcuts.
    private var navigator: CatalogNavigator {
        let neighbors = nav.current.page.map { Catalog.neighbors(of: $0) }
        return CatalogNavigator(
            tab: nav.shownArea,
            previous: neighbors?.previous?.id,
            next: neighbors?.next?.id,
            select: { tab in
                if tab == .search {
                    nav.showSearch()
                } else {
                    nav.show(.area(tab))
                }
            },
            open: { nav.open($0) },
            history: CatalogNavigator.History(
                canGoBack: nav.canGoBack,
                canGoForward: nav.canGoForward,
                canGoUp: nav.canGoUp,
                back: { nav.goBack() },
                forward: { nav.goForward() },
                up: { nav.goUp() }
            )
        )
    }

    /// Picks the first place: the restored location, then the page this
    /// window was opened for, then launch flags (first window only). A
    /// restored page window goes back to where it was last, even if you
    /// moved on from the page it was opened for.
    private func restore() {
        guard !didRestore else { return }
        didRestore = true
        #if DEBUG
        // A snapshot shows the detail alone: the sidebar's Liquid Glass
        // needs the window server to draw.
        if LaunchSnapshot.isRequested { columns = .detailOnly }
        #endif
        if let data = savedLocation, let saved = try? JSONDecoder().decode(SavedWindow.self, from: data) {
            nav.restore(saved.location, shownArea: saved.shownArea)
            if windowPage != nil { return }
        } else if let windowPage, let page = Catalog.page(id: windowPage) {
            nav.restore(Location(item: .category(page.category), page: page.id))
            return
        }
        guard !LaunchOptions.didApplyToWindow else { return }
        LaunchOptions.didApplyToWindow = true
        if let name = LaunchOptions.value(for: "-tab"), let tab = AppTab(rawValue: name) {
            nav.restore(Location(item: tab == .search ? .search : .area(tab)))
        }
        if let name = LaunchOptions.value(for: "-category"),
           let category = ComponentCategory.allCases.first(where: { "\($0)" == name || $0.rawValue == name }) {
            nav.restore(Location(item: .category(category)))
        }
        if let id = LaunchOptions.value(for: "-open") {
            if let page = Catalog.page(id: id) {
                nav.restore(Location(item: .category(page.category), page: id))
            } else if id == Catalog.overviewID {
                nav.restore(Location(item: .area(nav.shownArea)))
            }
        }
        if let query = LaunchOptions.value(for: "-search") {
            nav.searchText = query
            nav.restore(Location(item: .search))
        }
    }
}
