import SwiftUI
import StoreKit

/// The app's root: a tab bar with Components, Design, and Ship, plus a
/// search tab at the trailing edge that searches all three.
///
/// Each tab is its own `NavigationSplitView`: on iPad, a sidebar of that
/// tab's pages beside the page; on iPhone, a list that pushes pages.
///
/// Why `.tabBarOnly` and not `.sidebarAdaptable`: the adaptable style adds
/// a button that turns the tab bar into a sidebar, which on iPad would sit
/// next to (or over) each tab's own page sidebar. The HIG says to use a
/// split view for a sidebar that never becomes a tab bar, so the tabs stay
/// a tab bar: at the bottom on iPhone, floating at the top on iPad.
struct ContentView: View {
    /// The page this window was opened for with "Open in New Window".
    var windowPage: ComponentPage.ID? = nil
    @Environment(\.horizontalSizeClass) private var sizeClass
    /// Restored per window, so relaunching returns to the last tab and page.
    @SceneStorage("tab") private var tab: AppTab = .components
    @SceneStorage("selection") private var componentsSelection: String?
    @SceneStorage("selection.design") private var designSelection: String?
    @SceneStorage("selection.ship") private var shipSelection: String?
    @State private var searchText = ""
    /// Bumped by ⌘F, so the search field gets focus even when the Search
    /// tab is already open.
    @State private var searchFocusRequest = 0
    @State private var didRestore = false

    var body: some View {
        TabView(selection: $tab) {
            ForEach(AppTab.contentTabs) { contentTab in
                Tab(contentTab.title, systemImage: contentTab.symbol, value: contentTab) {
                    CatalogTabView(tab: contentTab, selection: selection(for: contentTab))
                }
            }
            Tab(value: AppTab.search, role: .search) {
                SearchTab(text: $searchText, focusRequest: searchFocusRequest)
            }
        }
        .tabViewStyle(.tabBarOnly)
        // Selecting the search tab focuses its field. Without this, iOS 27
        // keeps the search tab inside the tab group and shows no field.
        .tabViewSearchActivation(.searchTabSelection)
        // Opening a page from anywhere (Related, Next, `catalog://` links)
        // shows it in its own tab.
        .environment(\.openPage, OpenPageAction { id in
            open(id)
        })
        .focusedSceneValue(\.catalogNavigator, navigator)
        .overlay { BuddyOverlay() }
        .modifier(ReviewPrompt())
        .onAppear(perform: restore)
    }

    /// For the Go menu and its keyboard shortcuts.
    private var navigator: CatalogNavigator {
        let current = tab == .search ? nil : selection(for: tab).wrappedValue
        let neighbors = current.map { Catalog.neighbors(of: $0) }
        return CatalogNavigator(
            tab: tab,
            previous: neighbors?.previous?.id,
            next: neighbors?.next?.id,
            select: { newTab in
                tab = newTab
                if newTab == .search { searchFocusRequest += 1 }
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
    /// (used when testing), then the restored state. Wide screens start
    /// each tab on its overview.
    private func restore() {
        guard !didRestore else { return }
        didRestore = true
        for contentTab in AppTab.contentTabs {
            let current = selection(for: contentTab)
            let isValid = current.wrappedValue.map { Catalog.page(id: $0)?.category.tab == contentTab || $0 == Catalog.overviewID } ?? false
            if !isValid {
                current.wrappedValue = sizeClass == .regular ? Catalog.overviewID : nil
            }
        }
        if let windowPage {
            open(windowPage)
            return
        }
        // Launch flags set up the first window only, not ones opened later.
        guard !LaunchOptions.didApplyToWindow else { return }
        LaunchOptions.didApplyToWindow = true
        if let name = LaunchOptions.value(for: "-tab"), let launchTab = AppTab(rawValue: name) {
            tab = launchTab
        }
        if let id = LaunchOptions.value(for: "-open") {
            if id == Catalog.overviewID {
                let current = tab == .search ? AppTab.components : tab
                selection(for: current).wrappedValue = id
                tab = current
            } else {
                open(id)
            }
        }
        if let query = LaunchOptions.value(for: "-search") {
            searchText = query
            tab = .search
        }
    }
}

/// Shows Apple's rating prompt when `Engagement` says it's a good moment,
/// after a beat so it doesn't land on top of the tap that caused it.
private struct ReviewPrompt: ViewModifier {
    @Environment(\.requestReview) private var requestReview

    func body(content: Content) -> some View {
        content
            .onChange(of: Engagement.shared.reviewRequest) {
                Task {
                    try? await Task.sleep(for: .seconds(1.5))
                    requestReview()
                }
            }
    }
}

/// One content tab: the tab's categories and pages beside the open page.
private struct CatalogTabView: View {
    let tab: AppTab
    @Binding var selection: ComponentPage.ID?
    @State private var columns = NavigationSplitViewVisibility.all
    @Environment(\.horizontalSizeClass) private var sizeClass

    var body: some View {
        NavigationSplitView(columnVisibility: $columns) {
            // When the split view collapses (iPhone), the sidebar is the
            // first screen, so it carries the hero board.
            Sidebar(tab: tab, selection: $selection, showsBoard: sizeClass == .compact)
                .navigationTitle(tab.title)
        } detail: {
            NavigationStack {
                if let page = Catalog.page(id: selection) {
                    page.makeContent()
                        .id(page.id)
                } else {
                    OverviewView(tab: tab)
                }
            }
        }
        .navigationSplitViewStyle(.balanced)
        .environment(\.makeRoomForInspector, MakeRoomAction {
            withAnimation { columns = .detailOnly }
        })
        .modifier(CatalogLinks())
    }
}

/// Routes links inside pages: `catalog://<page id>` opens that page, and
/// web links (Apple docs, design guidelines, sources) open in an in-app
/// browser instead of leaving the app.
struct CatalogLinks: ViewModifier {
    @Environment(\.openPage) private var openPage
    @State private var browsing: BrowserPage?

    func body(content: Content) -> some View {
        content
            .environment(\.openURL, OpenURLAction { url in
                if url.scheme == "catalog", let id = url.host(), Catalog.page(id: id) != nil {
                    openPage(id)
                    return .handled
                }
                // Apple's sites open in the in-app browser; anything else in Safari.
                guard AppleSites.contains(url) else { return .systemAction }
                browsing = BrowserPage(url: url)
                return .handled
            })
            .sheet(item: $browsing) { page in
                DocsBrowser(url: page.url)
            }
    }
}

/// Launch arguments used to open the app in a known state for screenshots:
/// `-tab <components|design|ship|search>`, `-open <page id>`,
/// `-search <text>`, `-showControls`, `-scrollTo <anchor>`, `-showScrubber`.
enum LaunchOptions {
    static func value(for flag: String) -> String? {
        let arguments = ProcessInfo.processInfo.arguments
        guard let index = arguments.firstIndex(of: flag), index + 1 < arguments.count else { return nil }
        return arguments[index + 1]
    }

    static func isSet(_ flag: String) -> Bool {
        ProcessInfo.processInfo.arguments.contains(flag)
    }

    /// Flags that act on a page (`-showControls`, `-scrollTo`) apply to the
    /// first page that asks, not to every page opened after it.
    @MainActor private static var used: Set<String> = []

    /// Set once the first window has applied `-tab`, `-open`, and `-search`.
    @MainActor static var didApplyToWindow = false

    @MainActor static func take(_ flag: String) -> Bool {
        guard isSet(flag), !used.contains(flag) else { return false }
        used.insert(flag)
        return true
    }

    @MainActor static func takeValue(for flag: String) -> String? {
        guard let value = value(for: flag), take(flag) else { return nil }
        return value
    }

    /// Like `take`, but only for the page that `-open` names (any page when
    /// there's no `-open`). Pages restored in other tabs are built too, and
    /// shouldn't use up the flag first.
    @MainActor static func take(_ flag: String, page id: String) -> Bool {
        if let target = value(for: "-open"), target != id { return false }
        return take(flag)
    }

    @MainActor static func takeValue(for flag: String, page id: String) -> String? {
        if let target = value(for: "-open"), target != id { return nil }
        return takeValue(for: flag)
    }
}

private struct Sidebar: View {
    let tab: AppTab
    @Binding var selection: ComponentPage.ID?
    var showsBoard = false
    @Environment(\.horizontalSizeClass) private var sizeClass
    @State private var showsAbout = false
    @State private var scroll = ListScroll()

    /// On iPhone this list is the tab's first screen, so the tab's wallpaper
    /// goes here; on iPad it tops the overview instead.
    private var showsHero: Bool { showsBoard && !Catalog.pages(in: tab).isEmpty }
    /// Space between the title and the first row, where the wallpaper shows.
    private static let heroHeight: CGFloat = 36

    var body: some View {
        List(selection: $selection) {
            Section {
                Label("Overview", systemImage: "square.grid.2x2")
                    .tag(Catalog.overviewID)
                    .accessibilityElement(children: .combine)
                    .accessibilityIdentifier("row-overview")
            } header: {
                if showsHero {
                    // Holds the board's place; the board itself is behind
                    // the list, where it can run edge to edge and under the title.
                    Color.clear.frame(height: Self.heroHeight)
                }
            }
            ForEach(tab.categories) { category in
                let pages = Catalog.pages(in: category)
                if !pages.isEmpty {
                    Section(category.rawValue) {
                        ForEach(pages) { page in
                            SidebarRow(page: page)
                                .tag(page.id)
                                .accessibilityElement(children: .combine)
                                .accessibilityIdentifier("row-\(page.id)")
                        }
                    }
                }
            }
            // Like Settings: About sits at the end of the list, in every tab.
            Section {
                Button {
                    showsAbout = true
                } label: {
                    Label("About \(AppInfo.name)", systemImage: "info.circle")
                }
                .accessibilityIdentifier("row-about")
            }
        }
        .scrollContentBackground(showsHero ? .hidden : .automatic)
        .onScrollGeometryChange(for: ListScroll.Reading.self) {
            ListScroll.Reading(offset: $0.contentOffset.y + $0.contentInsets.top, underBar: $0.contentInsets.top)
        } action: { _, new in
            scroll.reading = new
        }
        .background(alignment: .top) {
            if showsHero {
                HeroBackdrop(tab: tab, scroll: scroll)
            }
        }
        .background {
            if showsHero { Color(.systemGroupedBackground).ignoresSafeArea() }
        }
        .openInNewWindowMenu()
        .sheet(isPresented: $showsAbout) {
            AboutView()
        }
        .overlay {
            // On iPad the overview beside the sidebar already says so.
            if Catalog.pages(in: tab).isEmpty && sizeClass == .compact {
                ComingSoonView(tab: tab)
            }
        }
    }
}

/// How far a list has scrolled from rest, and how tall the bars above it are.
/// An observable object rather than state on the list's view, so a scroll
/// redraws only what reads it (the hero backdrop), not the whole list.
@Observable private final class ListScroll {
    struct Reading: Equatable {
        var offset: CGFloat = 0
        var underBar: CGFloat = 0
    }

    var reading = Reading()
}

/// The tab's wallpaper behind the sidebar list, moving with it: full width,
/// up under the large title, and fading out behind the first rows. Scrolling
/// only moves it, so it never rebuilds while the list scrolls.
private struct HeroBackdrop: View {
    let tab: AppTab
    let scroll: ListScroll

    var body: some View {
        let reading = scroll.reading
        Wallpaper(seed: tab.rawValue, tab: tab)
            .mask(WallpaperFade())
            .frame(height: reading.underBar + 260)
            .offset(y: -reading.offset)
            .ignoresSafeArea(edges: [.top, .horizontal])
    }
}

/// Shown in a tab, or a category, that has no pages yet.
struct ComingSoonView: View {
    let tab: AppTab

    var body: some View {
        ContentUnavailableView {
            Label("Coming Soon", systemImage: tab.symbol)
        } description: {
            Text("Pages for \(tab.title) are on the way.")
        }
    }
}

struct SidebarRow: View {
    let page: ComponentPage
    var detail: String? = nil

    var body: some View {
        Label {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(page.title)
                    if page.isNew {
                        NewBadge()
                    }
                }
                if let detail {
                    Text(detail)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        } icon: {
            Image(systemName: page.symbol)
        }
    }
}

#Preview {
    ContentView()
}
