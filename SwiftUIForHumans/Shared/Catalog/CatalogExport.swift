import SwiftUI

// A plain-text export of every page, for tools outside the app (the agent
// skills, the website). Nothing here changes how a page looks or behaves.
//
// Page metadata comes straight from `ComponentPage`. Body text comes from
// the page's views: while `exportsCatalogText` is true in the environment,
// `SectionTitle`, `Prose`, `ExampleCard`, `Aside`, `CodeBlock`, `Checklist`,
// `ConnectSteps`, `ConnectFacts`, and `DemoPage`'s Usage each report one
// `ExportBlock` through a preference, in document order. A view that reports
// replaces whatever its children reported, so an example's code and aside
// arrive once, inside the example. Sections built from metadata (header,
// guidelines, Key APIs, notes, related, sources, about, composition) report
// nothing, since the metadata already carries them.
//
// `ExportCatalogTests` renders each page offscreen inside `ExportCollecting`
// and writes the result as JSON. See scripts/export-catalog.sh.

/// One edition's pages, as written to `<edition>.json`.
struct ExportCatalog: Codable, Sendable {
    /// "ios" or "macos".
    let edition: String
    let pages: [ExportPage]
}

/// Everything a page says, without its live previews.
struct ExportPage: Codable, Sendable {
    struct Category: Codable, Sendable {
        /// The case name, like "textInput".
        let id: String
        /// As shown in the sidebar, like "Text Input".
        let title: String
    }

    struct API: Codable, Sendable {
        /// Markdown, with the API in backticks.
        let name: String
        let detail: String
    }

    struct Guideline: Codable, Sendable {
        let title: String
        let detail: String
        /// Captions of the live Do / Don't pair, when the guideline has one.
        let doCaption: String?
        let dontCaption: String?
    }

    let id: String
    let title: String
    let summary: String
    let category: Category
    /// The tab's raw value: "design", "components" (shown as Build), or "ship".
    let tab: String
    /// "Component", "Modifier", "Concept", "Reference", or "Block".
    let kind: String
    let symbol: String
    let availability: [String]
    let docsURL: String?
    let higURL: String?
    let aliases: [String]
    let related: [String]
    let notes: [String]
    let about: String?
    let composition: String?
    let api: [API]
    let guidelines: [Guideline]
    let isNew: Bool
    let sources: [String]
    let reviewed: String?
    /// The page's own content, in reading order.
    let blocks: [ExportBlock]

    init(_ page: ComponentPage, blocks: [ExportBlock]) {
        id = page.id
        title = page.title
        summary = page.summary
        category = Category(id: String(describing: page.category), title: page.category.rawValue)
        tab = page.category.tab.rawValue
        kind = page.kind.rawValue
        symbol = page.symbol
        availability = page.availability
        docsURL = page.docsURL?.absoluteString
        higURL = page.higURL?.absoluteString
        aliases = page.aliases
        related = page.related
        notes = page.notes
        about = page.about
        composition = page.composition
        api = page.api.map { API(name: $0.name, detail: $0.detail) }
        guidelines = page.guidelines.map {
            Guideline(title: $0.title, detail: $0.detail, doCaption: $0.pair?.goodCaption, dontCaption: $0.pair?.badCaption)
        }
        isNew = page.isNew
        sources = page.sources.map(\.absoluteString)
        reviewed = page.reviewed
        self.blocks = blocks
    }
}

/// One piece of a page's body. `type` says which fields are set; the rest
/// are left out of the JSON.
struct ExportBlock: Codable, Equatable, Sendable {
    enum Kind: String, Codable, Sendable {
        /// `text`: a `SectionTitle`.
        case heading
        /// `text`: a paragraph of `Prose`, in inline Markdown.
        case prose
        /// `title`, `caption`, `code`, `aside`: an `ExampleCard`.
        case example
        /// `code` (as shown under Usage), `generatedCode` (the demo's code
        /// for its starting configuration), `aside`: a `DemoPage`'s Usage.
        case usage
        /// `aside`: a standalone `Aside` or `Callout`.
        case aside
        /// `code`: a standalone `CodeBlock`.
        case code
        /// `items`: a `Checklist`.
        case checklist
        /// `steps`: numbered `ConnectSteps`.
        case steps
        /// `facts`: a `ConnectFacts` card.
        case facts
    }

    struct Note: Codable, Equatable, Sendable {
        /// "note" or "important".
        let style: String
        let text: String

        init(_ aside: Aside) {
            style = aside.kind == .note ? "note" : "important"
            text = aside.text
        }
    }

    struct Item: Codable, Equatable, Sendable {
        let title: String
        let detail: String
        /// A page that explains the item.
        let page: String?
    }

    struct Fact: Codable, Equatable, Sendable {
        let label: String
        let value: String
    }

    let type: Kind
    var text: String?
    var title: String?
    var caption: String?
    var code: String?
    var generatedCode: String?
    var aside: Note?
    var items: [Item]?
    var steps: [String]?
    var facts: [Fact]?

    static func heading(_ text: String) -> Self { Self(type: .heading, text: text) }
    static func prose(_ text: String) -> Self { Self(type: .prose, text: text) }
    static func aside(_ aside: Aside) -> Self { Self(type: .aside, aside: Note(aside)) }
    static func code(_ code: String) -> Self { Self(type: .code, code: code) }
    static func steps(_ steps: [String]) -> Self { Self(type: .steps, steps: steps) }

    static func example(title: String, caption: String?, code: String, aside: Aside?) -> Self {
        Self(type: .example, title: title, caption: caption, code: code, aside: aside.map(Note.init))
    }

    static func usage(code: String, generatedCode: String, note: Aside?) -> Self {
        Self(type: .usage, code: code, generatedCode: generatedCode, aside: note.map(Note.init))
    }

    static func checklist(_ items: [ChecklistItem]) -> Self {
        Self(type: .checklist, items: items.map { Item(title: $0.title, detail: $0.detail, page: $0.pageID) })
    }

    static func facts(_ rows: [(label: String, value: String)]) -> Self {
        Self(type: .facts, facts: rows.map { Fact(label: $0.label, value: $0.value) })
    }
}

/// The blocks reported by a subtree, in document order.
struct ExportBlocksKey: PreferenceKey {
    static let defaultValue: [ExportBlock] = []

    static func reduce(value: inout [ExportBlock], nextValue: () -> [ExportBlock]) {
        value += nextValue()
    }
}

extension EnvironmentValues {
    /// True only while `ExportCollecting` renders a page for the export.
    /// Views report nothing, and compute nothing extra, otherwise.
    @Entry var exportsCatalogText = false
}

extension View {
    /// Reports `block` for the export, replacing anything the view's
    /// children reported. `block` runs only while exporting.
    func exportBlock(_ block: @escaping () -> ExportBlock) -> some View {
        modifier(ExportBlocksWriter { [block()] })
    }

    /// Hides this subtree from the export, for sections the page's metadata
    /// already covers.
    func exportSkipped() -> some View {
        modifier(ExportBlocksWriter { [] })
    }
}

private struct ExportBlocksWriter: ViewModifier {
    let blocks: () -> [ExportBlock]
    @Environment(\.exportsCatalogText) private var isExporting

    func body(content: Content) -> some View {
        if isExporting {
            let value = blocks()
            content.transformPreference(ExportBlocksKey.self) { $0 = value }
        } else {
            content
        }
    }
}

/// Receives the blocks `ExportCollecting` gathers.
@MainActor
final class ExportCollector {
    private(set) var blocks: [ExportBlock] = []

    fileprivate func update(_ blocks: [ExportBlock]) {
        self.blocks = blocks
    }
}

/// Renders `content` with the export switched on and hands every block it
/// reports to `collector`. Render it offscreen, for example with
/// `ImageRenderer`; after rendering, `collector.blocks` holds the page.
struct ExportCollecting<Content: View>: View {
    let collector: ExportCollector
    @ViewBuilder let content: Content

    var body: some View {
        content
            .environment(\.exportsCatalogText, true)
            .overlayPreferenceValue(ExportBlocksKey.self) { blocks in
                ExportSink(blocks: blocks, collector: collector)
            }
    }
}

/// Copies the blocks out as part of rendering, so the collector is filled
/// as soon as the renderer returns, with no later callback to wait for.
private struct ExportSink: View {
    let blocks: [ExportBlock]
    let collector: ExportCollector

    var body: some View {
        collector.update(blocks)
        return Color.clear
    }
}
