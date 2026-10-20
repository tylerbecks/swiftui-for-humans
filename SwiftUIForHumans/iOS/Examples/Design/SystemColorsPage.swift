import SwiftUI
import UIKit // UIPasteboard, for copy to clipboard

extension ComponentPage {
    static let systemColors = ComponentPage(
        id: "system-colors",
        title: "System Colors",
        summary: "Colors that adapt to light mode, dark mode, and accessibility settings for you.",
        category: .foundations,
        kind: .reference,
        symbol: "swatchpalette",
        availability: ["iOS 13.0+", "macOS 10.15+", "visionOS 1.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/color",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/color",
        aliases: ["palette", "theme", "dark mode", "css variables", "design tokens", "UIColor", "label color", "background color", "colour", "hex"],
        related: ["foreground-style", "gradients", "materials", "typography"],
        notes: [
            "**Semantic colors describe a job, not a value.** `Color(.label)` and `Color(.systemBackground)` flip in dark mode on their own, like CSS custom properties under `prefers-color-scheme`.",
            "**Put custom colors in the asset catalog.** Add a Color Set with Any and Dark appearances, then use it as `Color(\"Brand\")`. The `AccentColor` set there tints the whole app.",
        ],
        api: [
            APIItem("`Color(.systemBackground)`", "Any UIKit semantic color, wrapped for SwiftUI."),
            APIItem("`.foregroundStyle(.secondary)`", "Text levels, from `.primary` down to `.quaternary`."),
            APIItem("`.background(.background)`", "The screen's own background, as a style."),
            APIItem("`Color.red`", "A standard color, tuned for light and dark mode."),
            APIItem("`.tint(_:)`", "The accent color for controls inside a view."),
            APIItem("`Color(\"Brand\")`", "A custom color from the asset catalog."),
            APIItem("`@Environment(\\.colorScheme)`", "Reads whether the view is `.light` or `.dark`."),
        ],
        guidelines: [
            Guideline(
                "Use semantic colors instead of fixed ones.",
                "`.white` and `.black` never change, so a card that looks right in light mode glows in dark mode.",
                good: "Semantic colors adapt to both modes.",
                bad: "`.white` and `.black` stay the same in dark mode."
            ) {
                SchemePair { InboxCard(isSemantic: true) }
            } bad: {
                SchemePair { InboxCard(isSemantic: false) }
            },
            Guideline(
                "Don't rely on color alone.",
                "Some people can't tell red from green. Pair color with a symbol or a word so the meaning survives.",
                good: "A symbol and a word carry the status.",
                bad: "Only the dot's color tells them apart."
            ) {
                InvoiceStatusList(usesLabels: true)
            } bad: {
                InvoiceStatusList(usesLabels: false)
            },
            Guideline(
                "Use each semantic color for its job.",
                "Don't use `separator` for text or `secondaryLabel` as a fill. Each one is tuned for its role, and borrowed colors break in other modes."
            ),
            Guideline(
                "Save the accent color for things people can tap.",
                "If plain text uses the same color as buttons, people can't tell what's interactive."
            ),
        ]
    ) {
        SystemColorsThumbnail()
    } content: { page in
        SystemColorsArticle(page: page)
    }
}

// MARK: - Data

private struct SwatchColor: Identifiable {
    enum Display { case text, fill }

    let name: String
    let code: String
    let use: String
    let color: Color
    var display: Display = .fill

    var id: String { code }
}

private enum SwatchGroups {
    static let labels: [SwatchColor] = [
        SwatchColor(name: "label", code: "Color(.label)", use: "Primary text", color: Color(.label), display: .text),
        SwatchColor(name: "secondaryLabel", code: "Color(.secondaryLabel)", use: "Subtitles", color: Color(.secondaryLabel), display: .text),
        SwatchColor(name: "tertiaryLabel", code: "Color(.tertiaryLabel)", use: "Placeholder text", color: Color(.tertiaryLabel), display: .text),
        SwatchColor(name: "quaternaryLabel", code: "Color(.quaternaryLabel)", use: "Disabled text", color: Color(.quaternaryLabel), display: .text),
        SwatchColor(name: "placeholderText", code: "Color(.placeholderText)", use: "Text field hints", color: Color(.placeholderText), display: .text),
        SwatchColor(name: "link", code: "Color(.link)", use: "Links", color: Color(.link), display: .text),
    ]

    static let backgrounds: [SwatchColor] = [
        SwatchColor(name: "systemBackground", code: "Color(.systemBackground)", use: "Screen background", color: Color(.systemBackground)),
        SwatchColor(name: "secondarySystemBackground", code: "Color(.secondarySystemBackground)", use: "Cards on a screen", color: Color(.secondarySystemBackground)),
        SwatchColor(name: "tertiarySystemBackground", code: "Color(.tertiarySystemBackground)", use: "Inside cards", color: Color(.tertiarySystemBackground)),
        SwatchColor(name: "systemGroupedBackground", code: "Color(.systemGroupedBackground)", use: "Behind grouped lists", color: Color(.systemGroupedBackground)),
        SwatchColor(name: "secondarySystemGroupedBackground", code: "Color(.secondarySystemGroupedBackground)", use: "Grouped list rows", color: Color(.secondarySystemGroupedBackground)),
        SwatchColor(name: "separator", code: "Color(.separator)", use: "Divider lines", color: Color(.separator)),
        SwatchColor(name: "systemFill", code: "Color(.systemFill)", use: "Thin shapes, tracks", color: Color(.systemFill)),
        SwatchColor(name: "tertiarySystemFill", code: "Color(.tertiarySystemFill)", use: "Chips, search fields", color: Color(.tertiarySystemFill)),
    ]

    static let standard: [SwatchColor] = [
        SwatchColor(name: "red", code: ".red", use: "Errors, delete", color: .red),
        SwatchColor(name: "orange", code: ".orange", use: "Warnings", color: .orange),
        SwatchColor(name: "yellow", code: ".yellow", use: "Highlights", color: .yellow),
        SwatchColor(name: "green", code: ".green", use: "Success, on", color: .green),
        SwatchColor(name: "mint", code: ".mint", use: "", color: .mint),
        SwatchColor(name: "teal", code: ".teal", use: "", color: .teal),
        SwatchColor(name: "cyan", code: ".cyan", use: "", color: .cyan),
        SwatchColor(name: "blue", code: ".blue", use: "Default tint", color: .blue),
        SwatchColor(name: "indigo", code: ".indigo", use: "", color: .indigo),
        SwatchColor(name: "purple", code: ".purple", use: "", color: .purple),
        SwatchColor(name: "pink", code: ".pink", use: "", color: .pink),
        SwatchColor(name: "brown", code: ".brown", use: "", color: .brown),
        SwatchColor(name: "gray", code: ".gray", use: "Neutral", color: .gray),
    ]
}

/// The hex value a color resolves to in a given environment, using SwiftUI's
/// `Color.resolve(in:)`. Copying the viewer's environment keeps settings like
/// Increase Contrast, and only the color scheme is swapped.
private func hexString(_ color: Color, in environment: EnvironmentValues) -> String {
    let resolved = color.resolve(in: environment)
    func byte(_ v: Float) -> Int { Int((min(max(v, 0), 1) * 255).rounded()) }
    let hex = String(format: "#%02X%02X%02X", byte(resolved.red), byte(resolved.green), byte(resolved.blue))
    return resolved.opacity < 0.995 ? "\(hex) \(Int((resolved.opacity * 100).rounded()))%" : hex
}

// MARK: - Page

private struct SystemColorsArticle: View {
    let page: ComponentPage
    @State private var copied: String?

    var body: some View {
        ArticlePage(page: page) {
            Prose("Each swatch shows one color in **light** mode (left) and **dark** mode (right). You write one name and iOS picks the value. Tap a swatch to copy its code.")

            swatchSection(
                "Text",
                intro: "For text and symbols, from most to least important.",
                colors: SwatchGroups.labels
            )
            .id("labels")

            swatchSection(
                "Backgrounds and fills",
                intro: "Layer these from back to front. In dark mode the higher layers get *lighter*, so cards still stand out.",
                colors: SwatchGroups.backgrounds
            )
            .id("backgrounds")

            VStack(alignment: .leading, spacing: 16) {
                swatchSection(
                    "Standard colors",
                    intro: "For accents and meaning. Write them as `.red` or `Color.red`.",
                    colors: SwatchGroups.standard
                )
                Aside(.note, "Standard colors shift slightly in dark mode and again with Increase Contrast. Use the name, never a hex value copied from a screenshot.")
            }
            .id("standard")

            VStack(alignment: .leading, spacing: 16) {
                SectionTitle("Examples")
                VStack(alignment: .leading, spacing: 44) {
                    hierarchySection
                    tintExample
                }
            }
            .id("examples")
        }
        .overlay(alignment: .bottom) {
            copiedToast
        }
        .sensoryFeedback(.success, trigger: copied) { _, new in new != nil }
    }

    private var tintExample: some View {
        ExampleCard(
            title: "Brand color with tint",
            caption: "Set `.tint(_:)` on a container to recolor every button, toggle, and link inside it.",
            code: """
            @State private var isOn = true

            VStack(spacing: 16) {
                Toggle("Notifications", isOn: $isOn)
                Button("Continue") {}
                    .buttonStyle(.borderedProminent)
                Link("Privacy Policy", destination: URL(string: "https://example.com")!)
            }
            .tint(.orange)
            """,
            aside: Aside(.note, "To change the accent color for the whole app, set the `AccentColor` in the asset catalog instead.")
        ) {
            TintSample()
        }
    }

    @ViewBuilder
    private var copiedToast: some View {
            if let copied {
                Label("Copied \(copied)", systemImage: "checkmark.circle.fill")
                    .font(.subheadline.weight(.semibold))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .glassEffect()
                    .padding(.bottom, 24)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
    }

    private var hierarchySection: some View {
        ExampleCard(
            title: "Text levels with hierarchical styles",
            caption: "Ask `.foregroundStyle(.secondary)` for a level instead of naming a label color; SwiftUI picks the shade.",
            code: """
            VStack(alignment: .leading) {
                Text("Primary").foregroundStyle(.primary)
                Text("Secondary").foregroundStyle(.secondary)
                Text("Tertiary").foregroundStyle(.tertiary)
                Text("Quaternary").foregroundStyle(.quaternary)
            }
            .font(.title3.bold())
            """,
            minHeight: 160,
            aside: Aside(.note, "On a [material](catalog://materials), these levels turn vibrant and blend with the blur. A fixed color like `.gray` doesn't.")
        ) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Primary").foregroundStyle(.primary)
                Text("Secondary").foregroundStyle(.secondary)
                Text("Tertiary").foregroundStyle(.tertiary)
                Text("Quaternary").foregroundStyle(.quaternary)
            }
            .font(.title3.bold())
        }
    }

    private func swatchSection(_ title: String, intro: String, colors: [SwatchColor]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionTitle(title)
            Prose(intro)
                .foregroundStyle(.secondary)
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 160), spacing: 12, alignment: .top)], spacing: 16) {
                ForEach(colors) { color in
                    Button {
                        UIPasteboard.general.string = color.code
                        withAnimation(.snappy) { copied = color.code }
                        Task {
                            try? await Task.sleep(for: .seconds(1.6))
                            withAnimation(.snappy) {
                                if copied == color.code { copied = nil }
                            }
                        }
                    } label: {
                        SwatchTile(color: color)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("\(color.name). Copy \(color.code)")
                }
            }
        }
    }
}

private struct SwatchTile: View {
    let color: SwatchColor
    @Environment(\.self) private var environment

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 0) {
                half(.light)
                half(.dark)
            }
            .frame(height: 68)
            .clipShape(.rect(cornerRadius: 12))
            .overlay {
                RoundedRectangle(cornerRadius: 12).strokeBorder(.separator)
            }

            // One line when it fits; otherwise break after "Color(." so a
            // long name never leaves a lone ")" on its own line.
            ViewThatFits(in: .horizontal) {
                Text(color.code)
                    .lineLimit(1)
                Text(color.code.replacingOccurrences(of: "(.", with: "(\n."))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .font(.caption.monospaced().weight(.medium))
            if !color.use.isEmpty {
                Text(color.use)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .contentShape(.rect)
    }

    private func half(_ scheme: ColorScheme) -> some View {
        var schemeEnvironment = environment
        schemeEnvironment.colorScheme = scheme
        return ZStack(alignment: .bottomLeading) {
            Rectangle().fill(.background)
            switch color.display {
            case .fill:
                color.color
            case .text:
                Text("Aa")
                    .font(.title2.bold())
                    .foregroundStyle(color.color)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.bottom, 10)
            }
            Text(hexString(color.color, in: schemeEnvironment))
                .font(.system(size: 9, weight: .medium, design: .monospaced))
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
                .padding(.horizontal, 5)
                .padding(.vertical, 2)
                .background(.background.opacity(0.75), in: .capsule)
                .padding(4)
        }
        .environment(\.colorScheme, scheme)
    }
}

// MARK: - Samples

private struct TintSample: View {
    @State private var isOn = true

    var body: some View {
        VStack(spacing: 16) {
            Toggle("Notifications", isOn: $isOn)
            Button("Continue") {}
                .buttonStyle(.borderedProminent)
            Link("Privacy Policy", destination: URL(string: "https://example.com")!)
        }
        .tint(.orange)
        .frame(maxWidth: 280)
    }
}

/// Shows the same content in light mode and dark mode, side by side.
private struct SchemePair<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        HStack(spacing: 0) {
            half(.light)
            half(.dark)
        }
        .clipShape(.rect(cornerRadius: 12))
        .overlay { RoundedRectangle(cornerRadius: 12).strokeBorder(.separator) }
    }

    private func half(_ scheme: ColorScheme) -> some View {
        content
            .padding(8)
            .frame(maxWidth: .infinity)
            .background(.background)
            .environment(\.colorScheme, scheme)
    }
}

/// The same card, with semantic or fixed colors.
private struct InboxCard: View {
    let isSemantic: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Inbox")
                .font(.subheadline.bold())
                .foregroundStyle(isSemantic ? AnyShapeStyle(.primary) : AnyShapeStyle(.black))
            Text("2 new")
                .font(.footnote)
                .foregroundStyle(isSemantic ? AnyShapeStyle(.secondary) : AnyShapeStyle(.gray))
        }
        .lineLimit(1)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(8)
        .background(isSemantic ? Color(.secondarySystemBackground) : .white, in: .rect(cornerRadius: 10))
    }
}

private struct InvoiceStatusList: View {
    let usesLabels: Bool

    var body: some View {
        VStack(spacing: 10) {
            row("Invoice 1042", paid: true)
            Divider()
            row("Invoice 1043", paid: false)
        }
        .frame(maxWidth: 260)
    }

    private func row(_ title: String, paid: Bool) -> some View {
        HStack {
            Text(title)
                .font(.subheadline)
            Spacer(minLength: 8)
            if usesLabels {
                Label(paid ? "Paid" : "Overdue", systemImage: paid ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(paid ? .green : .red)
                    .fixedSize()
            } else {
                Circle()
                    .fill(paid ? .green : .red)
                    .frame(width: 10, height: 10)
            }
        }
    }
}

// MARK: - Thumbnail

private struct SystemColorsThumbnail: View {
    private let colors: [Color] = [.red, .orange, .yellow, .green, .teal, .blue, .indigo, .purple, .pink]

    var body: some View {
        HStack(spacing: 0) {
            column(.light)
            column(.dark)
        }
        .frame(width: 200, height: 112)
        .clipShape(.rect(cornerRadius: 14))
        .overlay { RoundedRectangle(cornerRadius: 14).strokeBorder(.separator) }
    }

    private func column(_ scheme: ColorScheme) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(scheme == .light ? "Light" : "Dark")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            LazyVGrid(columns: Array(repeating: GridItem(.fixed(20), spacing: 7), count: 3), spacing: 7) {
                ForEach(colors.indices, id: \.self) { index in
                    Circle().fill(colors[index]).frame(width: 20, height: 20)
                }
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(.background)
        .environment(\.colorScheme, scheme)
    }
}
