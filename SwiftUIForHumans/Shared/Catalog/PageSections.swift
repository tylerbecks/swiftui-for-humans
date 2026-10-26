import SwiftUI

// Optional page sections, filled in from a page's `ComponentPage` data:
// `about`, `composition`, `api`, and `guidelines`. Plus `Aside`, the inline
// note that sits under the example it explains. See docs/content-guide.md for
// when a page should use each one.

// MARK: - Aside

/// A short note under the example or code it explains, like the asides in
/// Apple's documentation. `.note` adds context; `.important` warns about a
/// mistake people actually make.
struct Aside: View {
    enum Kind: Sendable {
        case note, important

        var title: String { self == .note ? "Note" : "Important" }
        var symbol: String { self == .note ? "info.circle" : "exclamationmark.triangle" }
        var tint: Color { self == .note ? .secondary : .orange }
    }

    let kind: Kind
    let text: String

    init(_ kind: Kind = .note, _ text: String) {
        self.kind = kind
        self.text = text
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label(kind.title, systemImage: kind.symbol)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(kind.tint)
            RichText(text)
                .font(.callout)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(kind == .note ? Color.secondary.opacity(0.1) : Color.orange.opacity(0.1), in: .rect(cornerRadius: 12))
        .exportBlock { .aside(self) }
    }
}

// MARK: - About

/// A two- or three-sentence introduction under the demo: what the component
/// is responsible for and when to reach for it.
struct AboutSection: View {
    let text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(text.components(separatedBy: "\n\n"), id: \.self) { paragraph in
                Prose(paragraph)
            }
        }
    }
}

// MARK: - Composition

/// How the parts nest, drawn as a tree:
///
///     NavigationStack
///     └── List
///         └── NavigationLink
struct CompositionSection: View {
    let tree: String

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionTitle("Composition")
            ScrollView(.horizontal, showsIndicators: false) {
                Text(tree)
                    .font(.system(.callout, design: .monospaced))
                    .lineSpacing(4)
                    .padding(16)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Surface.code)
            .cardStyle()
        }
    }
}

// MARK: - Key APIs

/// One row of a page's "Key APIs" table: the 20% of initializers and
/// modifiers people use 80% of the time.
struct APIItem: Sendable {
    /// Markdown; wrap the API in backticks, e.g. "`.buttonStyle(_:)`".
    let name: String
    let detail: String

    init(_ name: String, _ detail: String) {
        self.name = name
        self.detail = detail
    }
}

struct APISection: View {
    let items: [APIItem]
    @Environment(\.isCompactLayout) private var isCompact

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionTitle("Key APIs")
            if !isCompact {
                // Wide: a two-column table.
                Grid(alignment: .leading, horizontalSpacing: 20, verticalSpacing: 12) {
                    ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                        if index > 0 { Divider() }
                        GridRow(alignment: .firstTextBaseline) {
                            RichText(item.name)
                            RichText(item.detail)
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            } else {
                // iPhone: each API above its description, like a definition list.
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                        if index > 0 { Divider() }
                        VStack(alignment: .leading, spacing: 4) {
                            RichText(item.name)
                            RichText(item.detail)
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Guidelines

/// A Human Interface Guidelines best practice, in our own words: a bold
/// lead sentence, one sentence of why, and optionally a live Do / Don't pair.
struct Guideline: Sendable {
    let title: String
    let detail: String
    let pair: DoDontPair?

    init(_ title: String, _ detail: String) {
        self.title = title
        self.detail = detail
        self.pair = nil
    }

    init<Good: View, Bad: View>(
        _ title: String,
        _ detail: String,
        good goodCaption: String,
        bad badCaption: String,
        @ViewBuilder good: @escaping @MainActor @Sendable () -> Good,
        @ViewBuilder bad: @escaping @MainActor @Sendable () -> Bad
    ) {
        self.title = title
        self.detail = detail
        self.pair = DoDontPair(
            goodCaption: goodCaption,
            badCaption: badCaption,
            good: { AnyView(good()) },
            bad: { AnyView(bad()) }
        )
    }
}

/// Live "Do" and "Don't" previews for a guideline.
struct DoDontPair: Sendable {
    let goodCaption: String
    let badCaption: String
    let good: @MainActor @Sendable () -> AnyView
    let bad: @MainActor @Sendable () -> AnyView
}

struct GuidelinesSection: View {
    let guidelines: [Guideline]
    let higURL: URL?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionTitle("Guidelines")
            VStack(alignment: .leading, spacing: 24) {
                ForEach(Array(guidelines.enumerated()), id: \.offset) { _, guideline in
                    VStack(alignment: .leading, spacing: 14) {
                        Prose("**\(guideline.title)** \(guideline.detail)")
                        if let pair = guideline.pair {
                            DoDontView(pair: pair)
                        }
                    }
                }
            }
            if let higURL {
                Link(destination: higURL) {
                    Label("More in the Human Interface Guidelines", systemImage: "paintbrush.pointed")
                }
                .font(.subheadline.weight(.medium))
            }
        }
    }
}

/// Side by side when both fit, stacked otherwise. It goes by the space the
/// page has, not the device: an iPad page column beside the sidebar, or a
/// narrow window, can be as narrow as an iPhone. A pair that doesn't fit
/// would widen the page and push it under the sidebar.
private struct DoDontView: View {
    let pair: DoDontPair
    @Environment(\.isCompactLayout) private var isCompact

    var body: some View {
        if !isCompact {
            ViewThatFits(in: .horizontal) {
                HStack(alignment: .top, spacing: 12) { cards }
                VStack(spacing: 12) { cards }
            }
        } else {
            VStack(spacing: 12) { cards }
        }
    }

    @ViewBuilder private var cards: some View {
        DoDontCard(isGood: true, caption: pair.goodCaption, content: pair.good)
        DoDontCard(isGood: false, caption: pair.badCaption, content: pair.bad)
    }
}

private struct DoDontCard: View {
    let isGood: Bool
    let caption: String
    let content: @MainActor @Sendable () -> AnyView

    var body: some View {
        VStack(spacing: 0) {
            PreviewCard(minHeight: 140, isAttached: true) {
                content()
            }
            Rectangle()
                .fill(isGood ? Color.green : Color.red)
                .frame(height: 3)
            VStack(alignment: .leading, spacing: 4) {
                Label(isGood ? "Do" : "Don't", systemImage: isGood ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(isGood ? .green : .red)
                RichText(caption)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Surface.code)
        }
        .cardStyle()
    }
}

// MARK: - Sources

/// The page's footnote: platforms, how many official sources it's based
/// on, and when they were last checked, on one quiet line. Tap it to list
/// the sources. Rules and deadlines change, so readers can see how fresh a
/// page is and go to the source, without a long list in the way.
struct SourcesSection: View {
    let sources: [URL]
    let reviewed: String?
    let availability: [String]
    @State private var isExpanded = LaunchOptions.value(for: "-scrollTo") == "sources"

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if sources.isEmpty {
                Text(summary)
            } else {
                Button {
                    withAnimation(.snappy) { isExpanded.toggle() }
                } label: {
                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        Text(summary)
                            .multilineTextAlignment(.leading)
                        Image(systemName: "chevron.right")
                            .font(.caption2.weight(.semibold))
                            .rotationEffect(.degrees(isExpanded ? 90 : 0))
                    }
                    .contentShape(.rect)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(summary)
                .accessibilityHint(isExpanded ? "Hides the sources." : "Lists the sources.")
            }
            if isExpanded {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(sources, id: \.self) { url in
                        Link(destination: url) {
                            Label(Self.title(for: url), systemImage: "arrow.up.right")
                                .labelStyle(SourceLabelStyle())
                                .multilineTextAlignment(.leading)
                        }
                    }
                }
                .transition(.opacity)
            }
        }
        .font(.footnote)
        .foregroundStyle(.secondary)
        .frame(maxWidth: .infinity, alignment: .leading)
        .id("sources")
    }

    /// "iOS 15.0+ · 9 sources · Checked October 2026"
    private var summary: String {
        var parts = availability
        if !sources.isEmpty {
            parts.append(sources.count == 1 ? "1 source" : "\(sources.count) sources")
        }
        if let reviewed {
            // When the sources were last checked against Apple's pages.
            parts.append("Checked \(reviewed)")
        }
        return parts.joined(separator: " · ")
    }

    /// A short, readable name for a source URL: "App Review Guidelines",
    /// "HIG: Tab bars", "Docs: searchable", or the host and last path part.
    static func title(for url: URL) -> String {
        if let name = SourceTitles.byURL[url.absoluteString] {
            let path = url.path()
            if path.contains("/human-interface-guidelines/") { return "HIG: \(name)" }
            if path.hasPrefix("/documentation/") { return "Docs: \(name)" }
            if path.hasPrefix("/help/app-store-connect") { return "App Store Connect Help: \(name)" }
            if path.hasPrefix("/help/app-review") { return "App Review Help: \(name)" }
            return name
        }
        let host = (url.host() ?? "").replacingOccurrences(of: "www.", with: "")
        let path = url.path()
        let last = url.lastPathComponent
        func words(_ slug: String) -> String {
            // URLs drop apostrophes: "your-app-s-launch" reads "your app's launch".
            slug.replacingOccurrences(of: "-", with: " ")
                .replacing(/(\w) s\b/) { "\($0.output.1)'s" }
        }
        func readable(_ slug: String) -> String {
            let text = words(slug)
            return text.prefix(1).uppercased() + text.dropFirst()
        }
        if host == "developer.apple.com" {
            if path.hasPrefix("/app-store/review/guidelines") {
                return url.fragment().map { "App Review Guidelines: \(readable($0))" } ?? "App Review Guidelines"
            }
            if path.contains("/human-interface-guidelines/") {
                return "HIG: \(readable(last))"
            }
            if path.hasPrefix("/documentation/") {
                // Symbol pages end in a full signature; the name is enough.
                let name = last.split(separator: "(").first.map(String.init) ?? last
                return "Docs: \(words(name))"
            }
            if path.hasPrefix("/help/app-store-connect") {
                return "App Store Connect Help: \(readable(last))"
            }
            if path.hasPrefix("/help/app-review") {
                // "5-1-1-account-deletion" reads "5.1.1 Account deletion".
                let slug = last.replacing(/^(\d+)-(\d+)-(\d+)-/) { "\($0.output.1).\($0.output.2).\($0.output.3) " }
                return "App Review Help: \(readable(slug))"
            }
            if let match = path.firstMatch(of: /\/videos\/play\/wwdc\d\d(\d\d)\/(\d+)/) {
                return "WWDC\(match.output.1) session \(match.output.2)"
            }
            let names = [
                "testflight": "TestFlight",
                "app-review": "App Review",
                "news": "Apple Developer News",
                "third-party-SDK-requirements": "Third-party SDK requirements",
            ]
            if let name = names[last] { return name }
            if !last.isEmpty, last != "/" { return "Apple Developer: \(readable(last))" }
        }
        if host == "apple.com", path.hasPrefix("/legal/app-store/transparency/") {
            return "App Store Transparency Report \(last)"
        }
        return last.isEmpty || last == "/" ? host : "\(host): \(readable(last))"
    }
}

/// A small link arrow in front of each source, tinted like the link.
private struct SourceLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 6) {
            configuration.icon
                .font(.caption2.weight(.semibold))
            configuration.title
        }
        .foregroundStyle(.tint)
    }
}
