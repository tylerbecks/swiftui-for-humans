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
    @Environment(\.horizontalSizeClass) private var sizeClass

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionTitle("Key APIs")
            if sizeClass == .regular {
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

/// Side by side on iPad, stacked on iPhone.
private struct DoDontView: View {
    let pair: DoDontPair
    @Environment(\.horizontalSizeClass) private var sizeClass

    var body: some View {
        let layout = sizeClass == .regular
            ? AnyLayout(HStackLayout(alignment: .top, spacing: 12))
            : AnyLayout(VStackLayout(spacing: 12))
        layout {
            DoDontCard(isGood: true, caption: pair.goodCaption, content: pair.good)
            DoDontCard(isGood: false, caption: pair.badCaption, content: pair.bad)
        }
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
