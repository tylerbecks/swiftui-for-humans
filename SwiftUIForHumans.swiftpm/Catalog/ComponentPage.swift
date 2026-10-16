import SwiftUI

/// Sidebar sections, in display order.
enum ComponentCategory: String, CaseIterable, Identifiable, Sendable {
    case controls = "Controls"
    case textInput = "Text Input"
    case textAndImages = "Text & Images"
    case layout = "Layout"
    case lists = "Lists & Navigation"
    case presentation = "Presentation"
    case modifiers = "Modifiers"
    case dataFlow = "Data Flow"
    case animation = "Animation & Effects"
    case design = "Design System"
    case frameworks = "Charts & Maps"
    case blocks = "Blocks"

    var id: Self { self }

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
        case .design: "paintpalette"
        case .frameworks: "chart.xyaxis.line"
        case .blocks: "square.stack.3d.up"
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
        case .design: "Apple's colors, type, materials, and Liquid Glass."
        case .frameworks: "Swift Charts and MapKit, used from SwiftUI."
        case .blocks: "Whole screens built from the pieces above. Copy and adapt."
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

    /// The first alias containing `query`, if the title and summary don't.
    func aliasMatch(for query: String) -> String? {
        guard !title.localizedCaseInsensitiveContains(query) else { return nil }
        return aliases.first { $0.localizedCaseInsensitiveContains(query) }
    }

    func matches(_ query: String) -> Bool {
        title.localizedCaseInsensitiveContains(query)
            || summary.localizedCaseInsensitiveContains(query)
            || aliases.contains { $0.localizedCaseInsensitiveContains(query) }
    }

    static func == (lhs: Self, rhs: Self) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
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
