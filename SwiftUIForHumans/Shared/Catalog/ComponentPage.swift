import SwiftUI

/// The app's tabs. Every category belongs to one of the first three; the
/// search tab searches all of them.
///
/// Each edition (iOS, macOS) supplies its own `ComponentCategory` enum,
/// `Catalog.pages`, and `AppTab.intro` in its `Edition.swift`.
enum AppTab: String, CaseIterable, Identifiable, Sendable {
    case components
    case design
    case ship
    case search

    var id: Self { self }

    /// The tabs that hold pages, in tab bar order.
    static let contentTabs: [AppTab] = [.components, .design, .ship]

    var title: String {
        switch self {
        case .components: "Components"
        case .design: "Design"
        case .ship: "Ship"
        case .search: "Search"
        }
    }

    /// Outline symbols: the tab bar fills them in when selected.
    var symbol: String {
        switch self {
        case .components: "square.grid.2x2"
        case .design: "paintpalette"
        case .ship: "paperplane"
        case .search: "magnifyingglass"
        }
    }

    /// Categories in this tab, in sidebar order.
    var categories: [ComponentCategory] {
        ComponentCategory.allCases.filter { $0.tab == self }
    }
}

/// What kind of page this is. Shown as a small tag in the page header.
enum PageKind: String, Sendable {
    case component = "Component"
    case modifier = "Modifier"
    case concept = "Concept"
    case reference = "Reference"
    case block = "Block"
}

/// One entry in the catalog: the metadata shown in the sidebar, overview, and
/// page header, plus a live thumbnail and the page itself.
struct ComponentPage: Identifiable, Hashable, Sendable {
    let id: String
    let title: String
    let summary: String
    let category: ComponentCategory
    let kind: PageKind
    let symbol: String
    let availability: [String]
    let docsURL: URL?
    let higURL: URL?
    /// Words people search for when they don't know the SwiftUI name,
    /// e.g. "dropdown" for Picker or "modal" for sheet.
    let aliases: [String]
    /// IDs of other pages to link to at the bottom of this one.
    let related: [String]
    /// Page-wide tips shown under "Good to know", each starting with a bold
    /// lead sentence. Tips about one example go in that example's `aside`.
    let notes: [String]
    /// Two or three sentences under the demo: what the component handles and
    /// when to use it. Paragraphs are separated by a blank line.
    let about: String?
    /// How the parts nest, as a tree drawn with ├── and └──.
    let composition: String?
    /// The few initializers and modifiers people use most.
    let api: [APIItem]
    /// Human Interface Guidelines best practices, in our own words.
    let guidelines: [Guideline]
    /// Marks APIs introduced in the latest iOS release.
    let isNew: Bool
    /// Official pages this page is based on (Apple docs, HIG, App Review
    /// Guidelines). Shown as "Sources" at the bottom of the page.
    let sources: [URL]
    /// When the page was last checked against those sources, e.g.
    /// "October 2026". Rules and deadlines change; Ship pages need it.
    let reviewed: String?
    private let thumbnail: @MainActor @Sendable () -> AnyView
    private let content: @MainActor @Sendable (ComponentPage) -> AnyView

    init<Thumbnail: View, Content: View>(
        id: String,
        title: String,
        summary: String,
        category: ComponentCategory,
        kind: PageKind = .component,
        symbol: String,
        availability: [String],
        docsURL: String?,
        higURL: String? = nil,
        aliases: [String] = [],
        related: [String] = [],
        notes: [String] = [],
        about: String? = nil,
        composition: String? = nil,
        api: [APIItem] = [],
        guidelines: [Guideline] = [],
        isNew: Bool = false,
        sources: [String] = [],
        reviewed: String? = nil,
        @ViewBuilder thumbnail: @escaping @MainActor @Sendable () -> Thumbnail,
        @ViewBuilder content: @escaping @MainActor @Sendable (ComponentPage) -> Content
    ) {
        self.id = id
        self.title = title
        self.summary = summary
        self.category = category
        self.kind = kind
        self.symbol = symbol
        self.availability = availability
        self.docsURL = docsURL.flatMap(URL.init(string:))
        self.higURL = higURL.flatMap(URL.init(string:))
        self.aliases = aliases
        self.related = related
        self.notes = notes
        self.about = about
        self.composition = composition
        self.api = api
        self.guidelines = guidelines
        self.isNew = isNew
        self.sources = sources.compactMap(URL.init(string:))
        self.reviewed = reviewed
        self.thumbnail = { AnyView(thumbnail()) }
        self.content = { AnyView(content($0)) }
    }

    @MainActor
    func makeThumbnail() -> AnyView {
        thumbnail()
    }

    @MainActor
    func makeContent() -> AnyView {
        content(self)
    }

    /// The first alias that matches `query`, if the title doesn't.
    func aliasMatch(for query: String) -> String? {
        guard !title.localizedCaseInsensitiveContains(query) else { return nil }
        return aliases.first { SearchQuery.alias($0, matches: query) }
    }

    func matches(_ query: String) -> Bool {
        if SearchQuery.isGuidelineNumber(query) {
            // "2.1" should find guideline 2.1 and 2.1(a), not 12.1 or iOS 2.1.
            return aliases.contains { SearchQuery.alias($0, matches: query) }
        }
        return title.localizedCaseInsensitiveContains(query)
            || summary.localizedCaseInsensitiveContains(query)
            || aliases.contains { SearchQuery.alias($0, matches: query) }
    }

    static func == (lhs: Self, rhs: Self) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

/// Text matching for search, including App Review Guideline numbers such
/// as "4.0", "2.1", or "5.1.1(v)" in a page's aliases.
enum SearchQuery {
    /// A guideline number: digits and dots, with an optional letter or
    /// roman numeral in parentheses, like "5.1.1(v)". Spaces are ignored.
    static func isGuidelineNumber(_ text: String) -> Bool {
        compact(text).wholeMatch(of: /\d+(\.\d+)*(\([a-z0-9]+\))?/) != nil
    }

    static func alias(_ alias: String, matches query: String) -> Bool {
        guard isGuidelineNumber(query) else {
            return alias.localizedCaseInsensitiveContains(query)
        }
        // Compare guideline numbers whole, or as a parent section:
        // "5.1" matches "5.1.1(v)", and "4" matches "4.0".
        let number = compact(query)
        return guidelineNumbers(in: alias).contains { candidate in
            candidate == number
                || candidate.hasPrefix(number + ".")
                || candidate.hasPrefix(number + "(")
        }
    }

    /// Guideline-like numbers in an alias, e.g. "Guideline 5.1.1(v)" gives
    /// ["5.1.1(v)"].
    private static func guidelineNumbers(in alias: String) -> [String] {
        compact(alias).matches(of: /\d+(\.\d+)+(\([a-z0-9]+\))?|\d+(\([a-z0-9]+\))?/).map { String($0.output.0) }
    }

    private static func compact(_ text: String) -> String {
        text.lowercased().filter { !$0.isWhitespace }
    }
}

/// Navigates to another page by ID. Read it with `@Environment(\.openPage)`.
struct OpenPageAction: Sendable {
    let handler: @MainActor @Sendable (ComponentPage.ID) -> Void

    @MainActor
    func callAsFunction(_ id: ComponentPage.ID) {
        handler(id)
    }
}

/// Hides the sidebar so an inspector doesn't cover a narrow page (iPad in
/// portrait). Read it with `@Environment(\.makeRoomForInspector)`.
struct MakeRoomAction: Sendable {
    let handler: @MainActor @Sendable () -> Void

    @MainActor
    func callAsFunction() {
        handler()
    }
}

extension EnvironmentValues {
    @Entry var openPage = OpenPageAction { _ in }
    @Entry var makeRoomForInspector = MakeRoomAction {}
}
