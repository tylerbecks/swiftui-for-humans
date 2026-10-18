import SwiftUI

/// The search tab. It sits apart from the other tabs at the trailing edge
/// of the tab bar and searches every tab, including web terms and App
/// Review Guideline numbers in each page's aliases.
///
/// Like the other tabs, it's a split view: results beside the open page on
/// iPad, and a list that pushes pages on iPhone. Pages opened from a result
/// (Next, Related) replace it, so going back returns to the results.
struct SearchTab: View {
    @Binding var text: String
    var focusRequest = 0
    @FocusState private var isSearchFocused: Bool
    @State private var handledFocusRequest = 0
    @State private var selection: ComponentPage.ID?
    @State private var columns = NavigationSplitViewVisibility.all
    @Environment(\.horizontalSizeClass) private var sizeClass

    var body: some View {
        NavigationSplitView(columnVisibility: $columns) {
            SearchResults(text: $text, selection: $selection)
                .navigationTitle("Search")
        } detail: {
            NavigationStack {
                if let page = Catalog.page(id: selection) {
                    page.makeContent()
                        .id(page.id)
                } else {
                    placeholder
                }
            }
        }
        .navigationSplitViewStyle(.balanced)
        // Inside the search tab, as Apple recommends, so the tab bar's
        // search button turns into this field. On iPad it sits above the
        // results, leaving the page's toolbar alone.
        .searchable(text: $text, placement: sizeClass == .regular ? .sidebar : .automatic, prompt: "Search, e.g. “dropdown”")
        .searchFocused($isSearchFocused)
        // Runs on the first appearance too: the tab is only built the
        // first time it opens, often by the same ⌘F.
        .task(id: focusRequest) {
            guard focusRequest != handledFocusRequest else { return }
            handledFocusRequest = focusRequest
            try? await Task.sleep(for: .milliseconds(150))
            isSearchFocused = true
        }
        .environment(\.makeRoomForInspector, MakeRoomAction {
            withAnimation { columns = .detailOnly }
        })
        .modifier(CatalogLinks())
        .environment(\.openPage, OpenPageAction { id in
            selection = id
        })
    }

    /// Beside the results on iPad, before a page is open: a hint to search,
    /// then a count of what matched.
    @ViewBuilder private var placeholder: some View {
        let query = text.trimmingCharacters(in: .whitespaces)
        let count = query.isEmpty ? 0 : Catalog.pages.filter { $0.matches(query) }.count
        if count > 0 {
            ContentUnavailableView("Pick a Result", systemImage: "sidebar.left", description: Text("^[\(count) page](inflect: true) found for “\(query)”."))
        } else {
            ContentUnavailableView("Search Every Tab", systemImage: "magnifyingglass", description: Text("Components, design guidelines, and shipping rules. Try a web term like “dropdown”."))
        }
    }
}

private struct SearchResults: View {
    @Binding var text: String
    @Binding var selection: ComponentPage.ID?

    private static let suggestions = ["dropdown", "modal", "flexbox", "useState", "dark mode"]

    private var query: String {
        text.trimmingCharacters(in: .whitespaces)
    }

    private var matches: [ComponentPage] {
        Catalog.pages.filter { $0.matches(query) }
    }

    var body: some View {
        List(selection: $selection) {
            if query.isEmpty {
                Section("Try searching for") {
                    ForEach(Self.suggestions, id: \.self) { suggestion in
                        Button {
                            text = suggestion
                        } label: {
                            Label(suggestion, systemImage: "magnifyingglass")
                        }
                    }
                }
            } else {
                ForEach(AppTab.contentTabs) { tab in
                    let pages = matches.filter { $0.category.tab == tab }
                    if !pages.isEmpty {
                        Section(tab.title) {
                            ForEach(pages) { page in
                                SidebarRow(page: page, detail: detail(for: page))
                                    .tag(page.id)
                                    .accessibilityElement(children: .combine)
                                    .accessibilityIdentifier("row-\(page.id)")
                            }
                        }
                    }
                }
            }
        }
        .openInNewWindowMenu()
        .overlay {
            if !query.isEmpty && matches.isEmpty {
                ContentUnavailableView.search(text: query)
            }
        }
    }

    /// The category, plus the alias that matched when the title didn't.
    private func detail(for page: ComponentPage) -> String {
        if let alias = page.aliasMatch(for: query) {
            return "\(page.category.rawValue) · Matches “\(alias)”"
        }
        return page.category.rawValue
    }
}
