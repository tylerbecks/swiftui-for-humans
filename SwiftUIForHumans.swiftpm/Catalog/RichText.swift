import SwiftUI

/// Inline Markdown (`code`, **bold**, *italic*, [links](…)) where code spans
/// get a rounded chip behind them, like inline code on the web.
///
/// Plain `Text(.init(markdown))` only switches code to a monospaced font,
/// which is easy to miss. Here each code run is tagged with a custom text
/// attribute, and a `TextRenderer` draws a rounded background behind it,
/// so chips wrap across lines with the text.
struct RichText: View {
    private let markdown: String
    @Environment(\.colorScheme) private var colorScheme

    init(_ markdown: String) {
        self.markdown = markdown
    }

    var body: some View {
        Self.text(markdown)
            .textRenderer(InlineCodeRenderer(fill: colorScheme == .dark ? Color(white: 0.2) : Color(white: 0.92)))
    }

    /// Builds the text: code runs are monospaced and tagged `InlineCode`.
    static func text(_ markdown: String) -> Text {
        let options = AttributedString.MarkdownParsingOptions(interpretedSyntax: .inlineOnlyPreservingWhitespace)
        guard let parsed = try? AttributedString(markdown: markdown, options: options) else {
            return Text(markdown)
        }
        var result = Text(verbatim: "")
        let runs = Array(parsed.runs)
        for (index, run) in runs.enumerated() {
            let piece = parsed[run.range]
            if run.inlinePresentationIntent?.contains(.code) == true {
                // A thin space on each side keeps the chip from touching
                // the words around it.
                if index > 0 {
                    result = Text("\(result)\(Text(verbatim: "\u{2009}"))")
                }
                // The zero-width space is a line-break opportunity. Without
                // it, Unicode line breaking won't break before a leading
                // "." (as in `.labelStyle`), so the word before the code
                // wraps to the next line with it.
                // Nothing comes before a chip that starts the text, so it gets
                // no break opportunity (which would leave an empty first line).
                let code = Text(verbatim: (index > 0 ? "\u{200B}" : "") + String(piece.characters))
                    .monospaced()
                    .customAttribute(InlineCode())
                result = Text("\(result)\(code)")
                if index < runs.count - 1 {
                    result = Text("\(result)\(Text(verbatim: "\u{2009}"))")
                }
            } else {
                result = Text("\(result)\(Text(AttributedString(piece)))")
            }
        }
        return result
    }
}

/// Marks a run of text as inline code.
private struct InlineCode: TextAttribute {}

/// Draws a rounded chip behind inline-code runs, then the text on top.
private struct InlineCodeRenderer: TextRenderer {
    let fill: Color

    func draw(layout: Text.Layout, in context: inout GraphicsContext) {
        for line in layout {
            for run in line where run[InlineCode.self] != nil {
                // When a chip wraps whole onto the next line, its leading
                // zero-width space stays behind; don't draw an empty chip.
                guard run.typographicBounds.width > 1 else { continue }
                let rect = run.typographicBounds.rect.insetBy(dx: -3, dy: -1)
                context.fill(Path(roundedRect: rect, cornerRadius: 5), with: .color(fill))
            }
        }
        for line in layout {
            context.draw(line)
        }
    }
}
