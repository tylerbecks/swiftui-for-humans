import SwiftUI

/// A copyable, syntax-highlighted Swift code block.
///
/// `isCollapsible` starts collapsed: the first few lines fade out under a
/// "View Code" button. Code attached to a preview always starts collapsed;
/// a page's Usage snippet is shown in full. `isAttached` drops the card border so the block can
/// sit under a preview inside one card (see `ExampleCard`).
struct CodeBlock: View {
    let code: String
    var isCollapsible = false
    var isAttached = false
    @State private var isExpanded = false
    @State private var copied = false
    /// The visible width of the code panel, to tell whether the first
    /// line reaches under the copy button.
    @State private var panelWidth: CGFloat = 0
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    /// Collapsed blocks show about this many lines.
    private static var peekHeight: CGFloat { 112 }

    private var isCollapsed: Bool {
        isCollapsible && !isExpanded
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            Text(SwiftHighlighter.highlight(code, isDark: colorScheme == .dark))
                .font(.system(.callout, design: .monospaced))
                .textSelection(.enabled)
                .padding(16)
                .padding(.top, firstLineNeedsRoom ? 32 : 0)
                .padding(.trailing, 28)
        }
        .onGeometryChange(for: CGFloat.self) { $0.size.width } action: { panelWidth = $0 }
        .scrollDisabled(isCollapsed)
        .frame(maxWidth: .infinity, maxHeight: isCollapsed ? Self.peekHeight : nil, alignment: .topLeading)
        .clipped()
        .overlay {
            if isCollapsed {
                // Fade the peek into the panel, so the first line reads and
                // the rest is only a hint, with the button centered on top.
                Surface.code
                    .mask {
                        LinearGradient(
                            stops: [
                                .init(color: .clear, location: 0),
                                .init(color: .black.opacity(0.55), location: 0.3),
                                .init(color: .black.opacity(0.9), location: 0.6),
                                .init(color: .black, location: 0.9),
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    }
                    .allowsHitTesting(false)
                viewCodeButton
            }
        }
        .overlay(alignment: .topTrailing) {
            if !isCollapsed {
                copyButton
            }
        }
        .background(Surface.code)
        .modifier(CardIfDetached(isAttached: isAttached))
    }

    /// True when the first line is long enough to run under the copy
    /// button, so the code starts below the button instead.
    private var firstLineNeedsRoom: Bool {
        guard !isCollapsed, panelWidth > 0 else { return false }
        let firstLine = code.prefix { $0 != "\n" }
        let size = UIFont.preferredFont(forTextStyle: .callout).pointSize
        let font = UIFont.monospacedSystemFont(ofSize: size, weight: .regular)
        let charWidth = ("M" as NSString).size(withAttributes: [.font: font]).width
        // 16pt of leading padding; the button takes 48pt at the trailing edge.
        return 16 + CGFloat(firstLine.count) * charWidth > panelWidth - 48
    }

    private var viewCodeButton: some View {
        Button {
            withAnimation(.smooth) { isExpanded = true }
        } label: {
            Text("View Code")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.primary)
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(Surface.preview)
                .clipShape(.rect(cornerRadius: 10))
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(.separator)
                }
        }
        .buttonStyle(.plain)
    }

    private var copyButton: some View {
        Button {
            UIPasteboard.general.string = code
            copied = true
            Task {
                try? await Task.sleep(for: .seconds(1.5))
                copied = false
            }
        } label: {
            Image(systemName: copied ? "checkmark" : "doc.on.doc")
                .font(.subheadline)
                .contentTransition(.symbolEffect(.replace))
                .frame(width: 32, height: 32)
                .background(Surface.code)
                .clipShape(.rect(cornerRadius: 8))
        }
        .buttonStyle(.borderless)
        .tint(.secondary)
        .accessibilityLabel(copied ? "Copied" : "Copy code")
        .sensoryFeedback(.success, trigger: copied) { _, new in new }
        .padding(8)
    }
}

private struct CardIfDetached: ViewModifier {
    let isAttached: Bool

    func body(content: Content) -> some View {
        if isAttached {
            content
        } else {
            content.cardStyle()
        }
    }
}

/// A small tokenizer that colors Swift the way Xcode's default theme does.
/// It only needs to handle the snippets the catalog generates.
enum SwiftHighlighter {
    private static let keywords: Set<String> = [
        "let", "var", "func", "struct", "some", "return", "if", "else", "in",
        "true", "false", "nil", "private", "static", "import", "for", "self",
    ]

    static func highlight(_ code: String, isDark: Bool) -> AttributedString {
        let palette = Palette(isDark: isDark)
        var result = AttributedString()
        let chars = Array(code)
        var i = 0

        func append(_ text: String, _ color: Color? = nil) {
            var piece = AttributedString(text)
            if let color { piece.foregroundColor = color }
            result += piece
        }

        while i < chars.count {
            let c = chars[i]

            // Line comment
            if c == "/", i + 1 < chars.count, chars[i + 1] == "/" {
                let start = i
                while i < chars.count, chars[i] != "\n" { i += 1 }
                append(String(chars[start..<i]), palette.comment)
                continue
            }

            // String literal
            if c == "\"" {
                let start = i
                i += 1
                while i < chars.count, chars[i] != "\"" { i += 1 }
                i = min(i + 1, chars.count)
                append(String(chars[start..<i]), palette.string)
                continue
            }

            // Number
            if c.isNumber {
                let start = i
                while i < chars.count, chars[i].isNumber || chars[i] == "." { i += 1 }
                append(String(chars[start..<i]), palette.number)
                continue
            }

            // Attribute like @State
            if c == "@" {
                let start = i
                i += 1
                while i < chars.count, chars[i].isLetter { i += 1 }
                append(String(chars[start..<i]), palette.keyword)
                continue
            }

            // Identifier, keyword, type, or member
            if c.isLetter || c == "_" || c == "$" {
                let start = i
                while i < chars.count, chars[i].isLetter || chars[i].isNumber || chars[i] == "_" || chars[i] == "$" {
                    i += 1
                }
                let word = String(chars[start..<i])
                let previous = start > 0 ? chars[start - 1] : " "
                if keywords.contains(word) {
                    append(word, palette.keyword)
                } else if previous == "." {
                    append(word, palette.member)
                } else if word.first?.isUppercase == true {
                    append(word, palette.type)
                } else {
                    append(word)
                }
                continue
            }

            append(String(c))
            i += 1
        }
        return result
    }

    /// Xcode's default theme colors, for light and dark.
    private struct Palette {
        let isDark: Bool

        var keyword: Color { color(light: 0xAD3DA4, dark: 0xFF7AB2) }
        var string: Color { color(light: 0xD12F1B, dark: 0xFF8170) }
        var number: Color { color(light: 0x272AD8, dark: 0xD9C97C) }
        var type: Color { color(light: 0x703DAA, dark: 0xDABAFF) }
        var member: Color { color(light: 0x3E8087, dark: 0x67B7A4) }
        var comment: Color { color(light: 0x707F8C, dark: 0x7F8C98) }

        private func color(light: UInt32, dark: UInt32) -> Color {
            let hex = isDark ? dark : light
            return Color(
                red: Double((hex >> 16) & 0xFF) / 255,
                green: Double((hex >> 8) & 0xFF) / 255,
                blue: Double(hex & 0xFF) / 255
            )
        }
    }
}
