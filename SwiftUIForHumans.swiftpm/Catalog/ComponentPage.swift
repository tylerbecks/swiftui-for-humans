import SwiftUI

/// The app's tabs. Every category belongs to one of the first three; the
/// search tab searches all of them.
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

    /// One line at the top of the tab's overview.
    var intro: String {
        switch self {
        case .components: "Every SwiftUI component, live. Change it, see it, copy the code."
        case .design: "Apple's Human Interface Guidelines in plain language."
        case .ship: "What Apple checks before your app goes live."
        case .search: ""
        }
    }

    /// Categories in this tab, in sidebar order.
    var categories: [ComponentCategory] {
        ComponentCategory.allCases.filter { $0.tab == self }
    }
}

/// Sidebar sections, in display order. Each one belongs to a tab.
enum ComponentCategory: String, CaseIterable, Identifiable, Sendable {
    // Components
    case controls = "Controls"
    case textInput = "Text Input"
    case textAndImages = "Text & Images"
    case layout = "Layout"
    case lists = "Lists & Navigation"
    case presentation = "Presentation"
    case modifiers = "Modifiers"
    case dataFlow = "Data Flow"
    case animation = "Animation & Effects"
    case graphics = "Shapes & Gradients"
    case frameworks = "Charts & Maps"
    case blocks = "Blocks"
    // Design
    case foundations = "Foundations"
    case accessibility = "Accessibility"
    case patterns = "Patterns"
    // Ship
    case startHere = "Start Here"
    case feelsNative = "Feels Native"
    case requiredByApple = "Required by Apple"
    case appStoreConnect = "App Store Connect"
    case testAndRelease = "Test & Release"

    var id: Self { self }

    var tab: AppTab {
        switch self {
        case .foundations, .accessibility, .patterns: .design
        case .startHere, .feelsNative, .requiredByApple, .appStoreConnect, .testAndRelease: .ship
        default: .components
        }
    }

    var symbol: String {
        switch self {
        case .controls: "slider.horizontal.3"
        case .textInput: "character.cursor.ibeam"
        case .textAndImages: "textformat"
        case .layout: "square.split.2x2"
        case .lists: "list.bullet.rectangle"
        case .presentation: "rectangle.portrait.on.rectangle.portrait"
        case .modifiers: "wand.and.stars"
        case .dataFlow: "arrow.triangle.branch"
        case .animation: "sparkles"
        case .graphics: "square.on.circle"
        case .frameworks: "chart.xyaxis.line"
        case .blocks: "square.stack.3d.up"
        case .foundations: "paintpalette"
        case .accessibility: "accessibility"
        case .patterns: "rectangle.3.group"
        case .startHere: "flag"
        case .feelsNative: "iphone"
        case .requiredByApple: "checkmark.seal"
        case .appStoreConnect: "app.badge"
        case .testAndRelease: "airplane.departure"
        }
    }

    /// One line shown under the section title on the overview.
    var blurb: String {
        switch self {
        case .controls: "Buttons, toggles, pickers, and everything people tap or drag."
        case .textInput: "Fields and editors for typing."
        case .textAndImages: "Showing text, labels, and images."
        case .layout: "Stacks, grids, and scroll views that arrange everything else."
        case .lists: "Lists, forms, and moving between screens."
        case .presentation: "Sheets, alerts, menus, and popovers."
        case .modifiers: "The dot-methods that style and position views, and why their order matters."
        case .dataFlow: "How state moves through your app and keeps views up to date."
        case .animation: "Springs, transitions, and motion that make an app feel alive."
        case .graphics: "Shapes, paths, and gradients for drawing your own graphics."
        case .frameworks: "Swift Charts and MapKit, used from SwiftUI."
        case .blocks: "Whole screens built from the pieces above. Copy and adapt."
        case .foundations: "Apple's colors, type, materials, symbols, and Liquid Glass."
        case .accessibility: "Making your app work for everyone, including VoiceOver and larger text."
        case .patterns: "Common tasks, like onboarding, search, and settings, done the Apple way."
        case .startHere: "What App Review is, and the path from code to the App Store."
        case .feelsNative: "The details that make an app feel at home on iPhone."
        case .requiredByApple: "Rules your app must follow to pass App Review."
        case .appStoreConnect: "Setting up your listing, privacy labels, and pricing."
        case .testAndRelease: "TestFlight, submitting for review, and what to do if you're rejected."
        }
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
