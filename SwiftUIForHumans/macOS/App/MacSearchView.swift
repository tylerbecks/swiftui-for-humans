import SwiftUI

/// The Search destination: the field sits in the toolbar and takes focus on
/// arrival, as the HIG suggests for an area dedicated to search. Results
/// are grouped by area and say why each page matched.
struct MacSearchView: View {
    @Bindable var nav: WindowNavigator
    @State private var selection: ComponentPage.ID?
    @FocusState private var isFieldFocused: Bool

    private static let suggestions = ["checkbox", "dropdown", "modal", "tooltip", "NSTableView", "notarize", ".pickerStyle", "2.4.5"]

    private var query: String {
        nav.searchText.trimmingCharacters(in: .whitespaces)
    }

    private var results: [SearchResult] {
        guard !query.isEmpty else { return [] }
        return Catalog.pages.compactMap { SearchResult(page: $0, query: query) }
    }

    var body: some View {
        Group {
            if query.isEmpty {
                suggestions
            } else {
                resultList
            }
        }
        .background(alignment: .top) { AreaGlow(tab: nav.shownArea) }
        .searchable(text: $nav.searchText, placement: .toolbarPrincipal, prompt: "Pages, web terms, guideline numbers, APIs")
        .searchScopes($nav.searchScope) {
            ForEach(SearchScope.allCases) { scope in
                Text(scope.title).tag(scope)
            }
        }
        .searchFocused($isFieldFocused)
        .task(id: nav.searchFocusRequest) {
            try? await Task.sleep(for: .milliseconds(100))
            isFieldFocused = true
        }
    }

    // MARK: Before typing

    private var suggestions: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text("Search")
                    .font(.largeTitle.bold())
                Text("Every page in Design, Build, and Ship. Search the way you'd say it: web terms like \u{201C}dropdown\u{201D}, AppKit names like NSTableView, APIs like `.pickerStyle`, or App Review guideline numbers.")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                FlowLayout(spacing: 8) {
                    ForEach(Self.suggestions, id: \.self) { term in
                        Button(term) {
                            nav.searchText = term
                        }
                        .buttonStyle(.glass)
                    }
                }
            }
            .padding(32)
            .frame(maxWidth: 760, alignment: .leading)
            .frame(maxWidth: .infinity)
        }
    }

    // MARK: Results

    private var resultList: some View {
        let shown = results.filter { nav.searchScope.tab == nil || $0.page.category.tab == nav.searchScope.tab }
        return List(selection: $selection) {
            ForEach(AppTab.contentTabs) { tab in
                let group = shown.filter { $0.page.category.tab == tab }
                if !group.isEmpty {
                    Section {
                        ForEach(group) { result in
                            MacPageRow(page: result.page, match: result.reason)
                                .tag(result.page.id)
                                .accessibilityIdentifier("row-\(result.page.id)")
                        }
                    } header: {
                        HStack(spacing: 6) {
                            Circle().fill(tab.tint).frame(width: 7, height: 7)
                            Text("\(tab.title) · \(group.count)")
                        }
                    }
                }
            }
        }
        .listStyle(.inset)
        .scrollContentBackground(.hidden)
        .contextMenu(forSelectionType: ComponentPage.ID.self) { ids in
            if let id = ids.first {
                Button("Open") { nav.open(id) }
                OpenInNewWindowButton(id: id)
            }
        } primaryAction: { ids in
            if let id = ids.first { nav.open(id) }
        }
        .overlay {
            if shown.isEmpty {
                ContentUnavailableView.search(text: query)
            }
        }
        .onChange(of: shown.map(\.page.id), initial: true) { _, ids in
            // The top hit is selected, so Return opens it. This runs when
            // the query or the scope changes what's shown.
            selection = ids.first
        }
    }
}

enum SearchScope: String, CaseIterable, Identifiable {
    case all, design, build, ship

    var id: Self { self }

    var title: String {
        switch self {
        case .all: "All"
        case .design: "Design"
        case .build: "Build"
        case .ship: "Ship"
        }
    }

    var tab: AppTab? {
        switch self {
        case .all: nil
        case .design: .design
        case .build: .build
        case .ship: .ship
        }
    }
}

/// A page that matches the query, with why it matched when the title
/// doesn't say so.
private struct SearchResult: Identifiable {
    let page: ComponentPage
    let reason: String?

    var id: ComponentPage.ID { page.id }

    init?(page: ComponentPage, query: String) {
        self.page = page
        if page.matches(query) {
            if let alias = page.aliasMatch(for: query) {
                reason = SearchQuery.isGuidelineNumber(query) ? alias : "Also called \u{201C}\(alias)\u{201D}"
            } else {
                reason = nil
            }
            return
        }
        // Key APIs, like `.pickerStyle(.menu)` finding Picker.
        let apis = page.api.map { $0.name.replacingOccurrences(of: "`", with: "") }
        if let api = apis.first(where: { $0.localizedCaseInsensitiveContains(query) }) {
            reason = "Key API `\(api)`"
            return
        }
        return nil
    }
}
