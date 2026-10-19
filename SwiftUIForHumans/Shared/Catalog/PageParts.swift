import SwiftUI

// Building blocks for pages. A page is a `PageScaffold` (header, your content,
// notes, related links) filled with `Prose`, `ExampleCard`, `PreviewCard`,
// `Callout`, and `DeviceFrame`. `DemoPage` and `ArticlePage` wrap the scaffold
// for the two common page shapes.

/// Scrollable page layout shared by every page: header, content, then the
/// page's notes and related links.
///
/// Give any view `.id("name")` and launch with `-scrollTo name` to open the
/// page scrolled to it (handy for screenshots). Built-in anchors: "code",
/// "examples", "notes".
struct PageScaffold<Content: View>: View {
    let page: ComponentPage
    @ViewBuilder let content: Content
    @Environment(\.isCompactLayout) private var isCompact
    @State private var position = ScrollPosition(edge: .top)
    @State private var scroll = PageScrollModel()

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 44) {
                    PageHeader(page: page)
                    content
                    if !page.guidelines.isEmpty {
                        GuidelinesSection(guidelines: page.guidelines, higURL: page.higURL)
                            .id("guidelines")
                    }
                    if !page.api.isEmpty {
                        APISection(items: page.api)
                            .id("api")
                    }
                    if !page.notes.isEmpty {
                        NotesSection(notes: page.notes)
                            .id("notes")
                    }
                    if !page.related.isEmpty {
                        RelatedSection(ids: page.related)
                    }
                    VStack(alignment: .leading, spacing: 20) {
                        if !page.sources.isEmpty || page.reviewed != nil || !page.availability.isEmpty {
                            SourcesSection(sources: page.sources, reviewed: page.reviewed, availability: page.availability)
                        }
                        PageFooterLinks(id: page.id)
                    }
                }
                .frame(maxWidth: 760, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.top, 4)
                .padding(.bottom, 48)
                .frame(maxWidth: .infinity)
                .coordinateSpace(.named(PageScrubber.contentSpace))
                #if os(iOS)
                .background {
                    if isCompact {
                        LargeTitleExpander()
                    }
                }
                #endif
            }
            .scrollPosition($position)
            .onAppear { Engagement.shared.recordPageView(page.id) }
            .onScrollGeometryChange(for: PageScrollMetrics.self) { geometry in
                PageScrollMetrics(geometry)
            } action: { _, metrics in
                scroll.metrics = metrics
                if scroll.isLong != metrics.isLong {
                    scroll.isLong = metrics.isLong
                }
            }
            .scrollIndicators(scroll.isLong ? .hidden : .automatic)
            .onPreferenceChange(OutlineEntriesKey.self) { entries in
                scroll.entries = entries
            }
            .overlay {
                PageScrubber(title: page.title, model: scroll) { y in
                    position.scrollTo(y: y)
                } jumpTo: { title in
                    withAnimation(.smooth) {
                        if let title {
                            proxy.scrollTo(OutlineEntry.anchor(for: title), anchor: .top)
                        } else {
                            position.scrollTo(edge: .top)
                        }
                    }
                } scrubEnded: {
                    // Drop the offset the scrub set; while it's held, the
                    // ScrollView keeps returning to it and later jumps
                    // don't stick.
                    position = ScrollPosition(idType: String.self)
                }
            }
            .task {
                if let anchor = LaunchOptions.takeValue(for: "-scrollTo", page: page.id) {
                    // Right after launch, layout is still settling and the
                    // first jump can be lost. Repeat it a few times.
                    for delay in [300, 500, 700] {
                        try? await Task.sleep(for: .milliseconds(delay))
                        proxy.scrollTo(anchor, anchor: .top)
                    }
                }
            }
        }
        .navigationTitle(page.title)
        .catalogPageTitle()
        .toolbar {
            ToolbarItem(placement: .catalogTrailing) {
                PreviewSchemeMenu()
            }
        }
    }
}

/// Previous and next pages in sidebar order, like the links at the bottom
/// of a shadcn page.
private struct PageFooterLinks: View {
    let id: ComponentPage.ID

    var body: some View {
        let neighbors = Catalog.neighbors(of: id)
        // Two equal halves; a missing neighbor leaves its half empty, so a
        // lone card keeps its size and side.
        HStack(spacing: 12) {
            if let previous = neighbors.previous {
                FooterLink(page: previous, isNext: false)
            } else {
                Color.clear.frame(maxWidth: .infinity, maxHeight: 1)
            }
            if let next = neighbors.next {
                FooterLink(page: next, isNext: true)
            } else {
                Color.clear.frame(maxWidth: .infinity, maxHeight: 1)
            }
        }
    }
}

private struct FooterLink: View {
    let page: ComponentPage
    let isNext: Bool
    @Environment(\.openPage) private var openPage

    var body: some View {
        Button {
            openPage(page.id)
        } label: {
            VStack(alignment: isNext ? .trailing : .leading, spacing: 4) {
                Label(isNext ? "Next" : "Previous", systemImage: isNext ? "arrow.right" : "arrow.left")
                    .labelStyle(FooterLabelStyle(iconAfter: isNext))
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                Text(page.title)
                    .font(.body.weight(.semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity, alignment: isNext ? .trailing : .leading)
            .padding(14)
            .contentShape(.rect)
            .overlay {
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(.separator)
            }
        }
        .buttonStyle(.plain)
        .catalogHover(.highlight)
        .accessibilityLabel("\(isNext ? "Next" : "Previous"): \(page.title)")
    }
}

/// Puts the arrow after the text for "Next →".
private struct FooterLabelStyle: LabelStyle {
    let iconAfter: Bool

    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 4) {
            if iconAfter {
                configuration.title
                configuration.icon
            } else {
                configuration.icon
                configuration.title
            }
        }
    }
}

/// Sets light, dark, or system appearance for every preview in the app.
struct PreviewSchemeMenu: View {
    @AppStorage(PreviewScheme.storageKey) private var scheme: PreviewScheme = .system

    var body: some View {
        Menu {
            Picker("Preview Appearance", selection: $scheme) {
                ForEach(PreviewScheme.allCases) { option in
                    Label(option.rawValue, systemImage: option.symbol)
                        .tag(option)
                }
            }
            .pickerStyle(.inline)
        } label: {
            Label("Preview Appearance", systemImage: scheme.symbol)
        }
    }
}

/// A page without live controls: concepts, references, and blocks. Fill it
/// with `Prose`, `ExampleCard`, and anything else.
/// The page title is the navigation bar's large title; `PageHeader` shows
/// what goes under it.
struct ArticlePage<Content: View>: View {
    let page: ComponentPage
    @ViewBuilder let content: Content

    var body: some View {
        PageScaffold(page: page) {
            content
        }
    }
}

struct PageHeader: View {
    let page: ComponentPage

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if CatalogPlatform.showsTitleInContent {
                Text(page.title)
                    .font(.largeTitle.bold())
                    .padding(.top, 12)
            }
            Text(page.summary)
                .font(.title3)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
                // Room for the page scrubber's handle at the right edge.
                .padding(.trailing, 20)

            HStack(spacing: 18) {
                if page.isNew {
                    NewBadge()
                }
                if let docsURL = page.docsURL {
                    Link(destination: docsURL) {
                        Label("Apple docs", systemImage: "book")
                    }
                }
                if let higURL = page.higURL {
                    Link(destination: higURL) {
                        Label("Design guidelines", systemImage: "paintbrush.pointed")
                    }
                }
            }
            .font(.subheadline.weight(.medium))
            .padding(.top, 4)
        }
    }
}

/// A bordered card that shows a live preview. Its appearance (light, dark,
/// or system) follows the page's `PreviewSchemeMenu`.
struct PreviewCard<Content: View>: View {
    /// Kept for older call sites; previews no longer show a title bar.
    var title: String = "Preview"
    var minHeight: CGFloat = 220
    /// Drops the card border so the preview can sit above attached code.
    var isAttached = false
    @ViewBuilder let content: Content

    @AppStorage(PreviewScheme.storageKey) private var scheme: PreviewScheme = .system
    @Environment(\.colorScheme) private var systemScheme

    var body: some View {
        let preview = content
            .padding(24)
            .frame(maxWidth: .infinity, minHeight: minHeight)
            .background(Surface.preview)
            .environment(\.colorScheme, scheme.colorScheme ?? systemScheme)
            // Demos of Link and openURL should behave as they would in a
            // real app, not open the catalog's in-app browser.
            .environment(\.openURL, OpenURLAction { _ in .systemAction })
        if isAttached {
            preview
        } else {
            preview.cardStyle()
        }
    }
}

/// A titled example: a live preview with its code underneath, in one card.
/// Use several on a page to show variations, like shadcn's "Examples".
struct ExampleCard<Content: View>: View {
    let title: String
    var caption: String? = nil
    let code: String
    var minHeight: CGFloat = 180
    /// A note or warning about this example, shown right under it.
    var aside: Aside? = nil
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.title3.bold())
                    .accessibilityAddTraits(.isHeader)
                    .outlineEntry(title, level: 2)
                if let caption {
                    RichText(caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            VStack(spacing: 0) {
                PreviewCard(minHeight: minHeight, isAttached: true) {
                    content
                }
                Divider()
                CodeBlock(code: code, isCollapsible: true, isAttached: true)
            }
            .cardStyle()
            if let aside {
                aside
            }
        }
    }
}

/// Body copy. Supports inline Markdown such as `code` and **bold**.
struct Prose: View {
    let text: String

    init(_ text: String) {
        self.text = text
    }

    var body: some View {
        RichText(text)
            .font(.body)
            .lineSpacing(3)
            .fixedSize(horizontal: false, vertical: true)
    }
}

/// A section heading inside a page's content.
struct SectionTitle: View {
    let text: String

    init(_ text: String) {
        self.text = text
    }

    var body: some View {
        Text(text)
            .font(.title2.bold())
            .padding(.top, 4)
            .accessibilityAddTraits(.isHeader)
            .outlineEntry(text)
    }
}

/// Older name for `Aside`: `.tip` is a note, `.warning` is important.
struct Callout: View {
    enum Style {
        case tip, warning
    }

    let style: Style
    let text: String

    init(_ style: Style = .tip, _ text: String) {
        self.style = style
        self.text = text
    }

    var body: some View {
        Aside(style == .tip ? .note : .important, text)
    }
}

/// A phone-shaped container for previews that need a whole screen, such as
/// NavigationStack, TabView, or full blocks. Content gets a 300×560pt screen.
struct DeviceFrame<Content: View>: View {
    var width: CGFloat = 300
    var height: CGFloat = 560
    @ViewBuilder let content: Content

    var body: some View {
        content
            .frame(width: width, height: height)
            .background(.background)
            .clipShape(.rect(cornerRadius: 38))
            .padding(7)
            .background(Color(white: 0.12), in: .rect(cornerRadius: 45))
            .overlay {
                RoundedRectangle(cornerRadius: 45)
                    .strokeBorder(Color(white: 0.3), lineWidth: 1)
            }
    }
}

struct NewBadge: View {
    var body: some View {
        Text("New")
            .font(.caption2.weight(.semibold))
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .foregroundStyle(.white)
            .background(.blue, in: .capsule)
    }
}

struct NotesSection: View {
    let notes: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionTitle("Good to know")
            VStack(alignment: .leading, spacing: 14) {
                ForEach(notes, id: \.self) { note in
                    Prose(note)
                }
            }
        }
    }
}

/// Links to related pages. Unknown IDs are skipped.
struct RelatedSection: View {
    let ids: [ComponentPage.ID]
    @Environment(\.openPage) private var openPage

    var body: some View {
        let pages = ids.compactMap { Catalog.page(id: $0) }
        if !pages.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                SectionTitle("Related")
                FlowLayout(spacing: 8) {
                    ForEach(pages) { page in
                        Button {
                            openPage(page.id)
                        } label: {
                            Label(page.title, systemImage: page.symbol)
                                .font(.subheadline.weight(.medium))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(.fill.tertiary, in: .capsule)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}

/// Lays out children left to right, wrapping onto new lines.
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let rows = arrange(subviews: subviews, width: proposal.width ?? .infinity)
        let height = rows.last.map { $0.y + $0.height } ?? 0
        let width = rows.map(\.width).max() ?? 0
        return CGSize(width: proposal.width ?? width, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let rows = arrange(subviews: subviews, width: bounds.width)
        for row in rows {
            var x = bounds.minX
            for index in row.indices {
                let size = subviews[index].sizeThatFits(.unspecified)
                subviews[index].place(at: CGPoint(x: x, y: bounds.minY + row.y), proposal: ProposedViewSize(size))
                x += size.width + spacing
            }
        }
    }

    private struct Row {
        var indices: [Int] = []
        var y: CGFloat = 0
        var width: CGFloat = 0
        var height: CGFloat = 0
    }

    private func arrange(subviews: Subviews, width: CGFloat) -> [Row] {
        var rows = [Row()]
        for index in subviews.indices {
            let size = subviews[index].sizeThatFits(.unspecified)
            let needed = rows[rows.count - 1].indices.isEmpty ? size.width : rows[rows.count - 1].width + spacing + size.width
            if needed > width, !rows[rows.count - 1].indices.isEmpty {
                let previous = rows[rows.count - 1]
                rows.append(Row(y: previous.y + previous.height + spacing))
            }
            var row = rows[rows.count - 1]
            row.width = row.indices.isEmpty ? size.width : row.width + spacing + size.width
            row.height = max(row.height, size.height)
            row.indices.append(index)
            rows[rows.count - 1] = row
        }
        return rows
    }
}

enum PreviewScheme: String, CaseIterable, Identifiable {
    static let storageKey = "previewScheme"

    case system = "System"
    case light = "Light"
    case dark = "Dark"

    var id: Self { self }

    var symbol: String {
        switch self {
        case .system: "circle.lefthalf.filled"
        case .light: "sun.max"
        case .dark: "moon"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }
}

/// Card colors, picked per color scheme like shadcn's: previews sit on the
/// page color and code on a slightly tinted panel. (Inside the catalog's
/// split view, the semantic `.background` styles resolve to grouped grays.)
struct Surface: View {
    enum Kind { case preview, code }

    static var preview: Surface { Surface(kind: .preview) }
    static var code: Surface { Surface(kind: .code) }

    let kind: Kind
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        let isDark = colorScheme == .dark
        switch kind {
        case .preview:
            #if os(macOS)
            // The real window background, so previews look as they would in a window.
            Color(nsColor: .windowBackgroundColor)
            #else
            isDark ? Color.black : Color.white
            #endif
        case .code: isDark ? Color(white: 0.09) : Color(white: 0.965)
        }
    }
}

extension View {
    /// The bordered, rounded card look used by previews and code blocks.
    func cardStyle() -> some View {
        background(.background.secondary)
            .clipShape(.rect(cornerRadius: 16))
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(.separator)
            }
    }
}
