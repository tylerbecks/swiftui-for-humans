import SwiftUI

struct ContentView: View {
    @Environment(\.horizontalSizeClass) private var sizeClass
    /// Restored per window, so relaunching returns to the last page.
    @SceneStorage("selection") private var restored: String?
    @State private var selection: ComponentPage.ID?
    @State private var searchText = ""
    @State private var didRestore = false
    @State private var columns = NavigationSplitViewVisibility.all
    @State private var browsing: BrowserPage?

    var body: some View {
        NavigationSplitView(columnVisibility: $columns) {
            Sidebar(selection: $selection, searchText: searchText)
                .navigationTitle("SwiftUI for Humans")
                .searchable(text: $searchText, placement: .sidebar, prompt: "Search, e.g. “dropdown”")
        } detail: {
            NavigationStack {
                detail
            }
        }
        .navigationSplitViewStyle(.balanced)
        .environment(\.openPage, OpenPageAction { id in
            selection = id
        })
        .environment(\.makeRoomForInspector, MakeRoomAction {
            withAnimation { columns = .detailOnly }
        })
        // Web links (Apple docs, design guidelines, links in notes) open in
        // an in-app browser instead of leaving the app.
        .environment(\.openURL, OpenURLAction { url in
            // `catalog://<page id>` links in prose open that page.
            if url.scheme == "catalog", let id = url.host(), Catalog.page(id: id) != nil {
                selection = id
                return .handled
            }
            guard url.scheme == "https" || url.scheme == "http" else { return .systemAction }
            browsing = BrowserPage(url: url)
            return .handled
        })
        .sheet(item: $browsing) { page in
            DocsBrowser(url: page.url)
        }
        .onChange(of: selection) { _, new in
            restored = new
        }
        .onAppear(perform: restore)
    }

    @ViewBuilder
    private var detail: some View {
        if let page = Catalog.page(id: selection) {
            page.makeContent()
                .id(page.id)
        } else {
            OverviewView()
        }
    }

    /// Picks the first page: `-open <id>` (used when testing), then the
    /// restored page, then the overview on wide screens.
    private func restore() {
        guard !didRestore else { return }
        didRestore = true
        if let id = LaunchOptions.value(for: "-open") {
            selection = id
        } else if let restored, Catalog.page(id: restored) != nil || restored == Catalog.overviewID {
            selection = restored
        } else if sizeClass == .regular {
            selection = Catalog.overviewID
        }
        if let query = LaunchOptions.value(for: "-search") {
            searchText = query
        }
    }
}

/// Launch arguments used to open the app in a known state for screenshots:
/// `-open <page id>`, `-search <text>`, `-showControls`, `-scrollTo <anchor>`,
/// `-showScrubber`.
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

    @MainActor static func take(_ flag: String) -> Bool {
        guard isSet(flag), !used.contains(flag) else { return false }
        used.insert(flag)
        return true
    }

    @MainActor static func takeValue(for flag: String) -> String? {
        guard let value = value(for: flag), take(flag) else { return nil }
        return value
    }
}

private struct Sidebar: View {
    @Binding var selection: ComponentPage.ID?
    let searchText: String

    private var query: String {
        searchText.trimmingCharacters(in: .whitespaces)
    }

    private var matches: [ComponentPage] {
        guard !query.isEmpty else { return Catalog.pages }
        return Catalog.pages.filter { $0.matches(query) }
    }

    var body: some View {
        List(selection: $selection) {
            if query.isEmpty {
                Label("Overview", systemImage: "square.grid.2x2")
                    .tag(Catalog.overviewID)
                    .accessibilityElement(children: .combine)
                    .accessibilityIdentifier("row-overview")
            }
            ForEach(ComponentCategory.allCases) { category in
                let pages = matches.filter { $0.category == category }
                if !pages.isEmpty {
                    Section(category.rawValue) {
                        ForEach(pages) { page in
                            SidebarRow(page: page, aliasMatch: query.isEmpty ? nil : page.aliasMatch(for: query))
                                .tag(page.id)
                                .accessibilityElement(children: .combine)
                                .accessibilityIdentifier("row-\(page.id)")
                        }
                    }
                }
            }
        }
        .overlay {
            if matches.isEmpty {
                ContentUnavailableView.search(text: query)
            }
        }
    }
}

private struct SidebarRow: View {
    let page: ComponentPage
    let aliasMatch: String?

    var body: some View {
        Label {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(page.title)
                    if page.isNew {
                        NewBadge()
                    }
                }
                if let aliasMatch {
                    Text("Matches “\(aliasMatch)”")
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
