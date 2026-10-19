import SwiftUI

extension ComponentPage {
    static let sfSymbols = ComponentPage(
        id: "sf-symbols",
        title: "SF Symbols",
        summary: "Icons drawn to match the system font, for toolbars, sidebars, and menus.",
        category: .foundations,
        kind: .concept,
        symbol: "star.square.on.square",
        availability: [],
        docsURL: "https://developer.apple.com/documentation/swiftui/image/init(systemname:)",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/sf-symbols",
        aliases: ["icons", "icon", "symbols", "systemImage", "systemName", "glyph", "NSImage symbol", "font awesome", "icon font", "rendering mode", "hierarchical", "palette", "multicolor", "symbol effect", "imageScale"],
        related: ["image-symbols", "typography", "toolbar", "menu", "app-icons", "motion"],
        notes: [
            "**Check which system version a symbol needs.** New symbols and features each year don't exist on older releases. The SF Symbols app shows each symbol's availability.",
            "**Symbols aren't for app icons or logos.** Apple's terms for SF Symbols don't allow them, or look-alikes, in app icons, logos, or other trademarks.",
        ],
        api: [
            APIItem("`Label(_:systemImage:)`", "Text with a symbol, laid out for the context."),
            APIItem("`Image(systemName:)`", "A symbol on its own."),
            APIItem("`.imageScale(_:)`", "Small, medium, or large next to text."),
            APIItem("`.symbolRenderingMode(_:)`", "Monochrome, hierarchical, palette, or multicolor."),
            APIItem("`.symbolVariant(.fill)`", "The filled version, for emphasis or selection."),
            APIItem("`.symbolEffect(_:value:)`", "Plays an animation when a value changes."),
            APIItem("`Image(systemName:variableValue:)`", "Fills layers to show a level."),
        ],
        guidelines: [
            Guideline(
                "Let the symbol match the text.",
                "Each symbol weight matches a weight of the system font. Leave the weight to the font, so a symbol and its label look like one piece.",
                good: "The symbol takes the text's weight.",
                bad: "A heavy symbol beside regular text."
            ) {
                MacSymbolRow(symbolWeight: nil)
            } bad: {
                MacSymbolRow(symbolWeight: .black)
            },
            Guideline(
                "Use plain symbols in the toolbar.",
                "Toolbar items already get a shape and hover and selection states from the system. Symbols with a circle or square around them add a second border.",
                good: "Plain `plus` and `trash` symbols.",
                bad: "Circled versions of the same symbols."
            ) {
                MacSymbolToolbar(symbols: ["plus", "trash"])
            } bad: {
                MacSymbolToolbar(symbols: ["plus.circle", "trash.circle"])
            },
            Guideline(
                "In a menu, give every item in a group an icon or none.",
                "Icons help people find common actions faster, but a group where only some items have one looks unbalanced. Skip the icon if no symbol clearly fits.",
                good: "Every item in the group has an icon.",
                bad: "Only some items have one."
            ) {
                MacDesignMenuSample(items: [
                    MacDesignMenuItem(title: "Cut", symbol: "scissors", shortcut: "⌘X"),
                    MacDesignMenuItem(title: "Copy", symbol: "document.on.document", shortcut: "⌘C"),
                    MacDesignMenuItem(title: "Paste", symbol: "document.on.clipboard", shortcut: "⌘V"),
                ], width: 200)
            } bad: {
                MacDesignMenuSample(items: [
                    MacDesignMenuItem(title: "Cut", symbol: "scissors", shortcut: "⌘X"),
                    MacDesignMenuItem(title: "Copy", shortcut: "⌘C"),
                    MacDesignMenuItem(title: "Paste", symbol: "document.on.clipboard", shortcut: "⌘V"),
                ], width: 200)
            },
            Guideline(
                "Use the standard symbol for a common action.",
                "Share is `square.and.arrow.up`, Delete is `trash`, and Search is `magnifyingglass` everywhere on the Mac. A different symbol for the same action makes people stop and think."
            ),
            Guideline(
                "Check the rendering mode at the size you use.",
                "Fine layers that look good large can blur together small or on a busy background. Try another mode if the details get lost."
            ),
        ],
        sources: [
            "https://developer.apple.com/design/human-interface-guidelines/sf-symbols",
            "https://developer.apple.com/design/human-interface-guidelines/icons",
            "https://developer.apple.com/design/human-interface-guidelines/menus",
            "https://developer.apple.com/design/human-interface-guidelines/toolbars",
            "https://developer.apple.com/design/human-interface-guidelines/sidebars",
            "https://developer.apple.com/documentation/swiftui/view/imagescale(_:)",
            "https://developer.apple.com/documentation/swiftui/view/symbolrenderingmode(_:)",
            "https://developer.apple.com/documentation/swiftui/view/symboleffect(_:options:value:)",
            "https://developer.apple.com/sf-symbols/",
        ],
        reviewed: "October 2026"
    ) {
        HStack(spacing: 14) {
            Image(systemName: "folder")
            Image(systemName: "cloud.sun.rain")
                .symbolRenderingMode(.multicolor)
            Image(systemName: "square.and.arrow.up")
        }
        .font(.largeTitle)
        .foregroundStyle(.tint)
    } content: { page in
        MacSFSymbolsArticle(page: page)
    }
}

// MARK: - Page

private struct MacSFSymbolsArticle: View {
    let page: ComponentPage

    var body: some View {
        ArticlePage(page: page) {
            Prose("SF Symbols is a library of thousands of icons drawn to sit beside San Francisco, the system font. Each symbol comes in nine weights and three scales, so it lines up with text at any size. Browse them in the **SF Symbols** app, and use them by name.")

            VStack(alignment: .leading, spacing: 16) {
                SectionTitle("Next to text")
                    .id("demo")
                MacSymbolDemo()
            }

            VStack(alignment: .leading, spacing: 16) {
                SectionTitle("Where symbols go on the Mac")
                ConnectFacts(rows: [
                    ("Toolbars", "Plain outline symbols, with no circle or square around them. The toolbar adds hover and selection states."),
                    ("Sidebars", "Icons take the accent color by default. Their size follows the sidebar icon size people choose in System Settings: small, medium, or large."),
                    ("Menus", "Icons for the most common actions and key features, using the same symbols as the system for actions like Copy, Share, and Delete."),
                    ("Menu bar extras", "A symbol works well: the system colors it to fit a light or dark menu bar, and when it's selected."),
                ])
            }

            VStack(alignment: .leading, spacing: 16) {
                SectionTitle("In SwiftUI")
                    .id("examples")
                VStack(alignment: .leading, spacing: 44) {
                    ExampleCard(
                        title: "A symbol with its label",
                        caption: "Use `Label` so SwiftUI can show the symbol, the title, or both, as a sidebar, toolbar, or menu expects.",
                        code: """
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Downloads", systemImage: "arrow.down.circle")
                            Label("Shared", systemImage: "person.2")
                            Label("Trash", systemImage: "trash")
                        }
                        """,
                        minHeight: 130
                    ) {
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Downloads", systemImage: "arrow.down.circle")
                            Label("Shared", systemImage: "person.2")
                            Label("Trash", systemImage: "trash")
                        }
                    }

                    ExampleCard(
                        title: "Adjust emphasis with the scale",
                        caption: "`.imageScale(_:)` makes a symbol smaller or larger than its text without changing the weight they share.",
                        code: """
                        HStack(spacing: 24) {
                            Label("Small", systemImage: "bell")
                                .imageScale(.small)
                            Label("Medium", systemImage: "bell")
                                .imageScale(.medium)
                            Label("Large", systemImage: "bell")
                                .imageScale(.large)
                        }
                        """,
                        minHeight: 110
                    ) {
                        HStack(spacing: 24) {
                            Label("Small", systemImage: "bell")
                                .imageScale(.small)
                            Label("Medium", systemImage: "bell")
                                .imageScale(.medium)
                            Label("Large", systemImage: "bell")
                                .imageScale(.large)
                        }
                    }

                    ExampleCard(
                        title: "Add depth with a rendering mode",
                        caption: "`.hierarchical` uses one color at several opacities, `.palette` takes a color per layer, and `.multicolor` uses the symbol's own colors.",
                        code: """
                        HStack(spacing: 28) {
                            Image(systemName: "externaldrive.badge.icloud")
                                .symbolRenderingMode(.hierarchical)
                                .foregroundStyle(.tint)
                            Image(systemName: "person.crop.circle.badge.plus")
                                .symbolRenderingMode(.palette)
                                .foregroundStyle(.green, .secondary)
                            Image(systemName: "cloud.sun.rain")
                                .symbolRenderingMode(.multicolor)
                        }
                        .font(.largeTitle)
                        """,
                        minHeight: 130
                    ) {
                        HStack(spacing: 28) {
                            Image(systemName: "externaldrive.badge.icloud")
                                .symbolRenderingMode(.hierarchical)
                                .foregroundStyle(.tint)
                            Image(systemName: "person.crop.circle.badge.plus")
                                .symbolRenderingMode(.palette)
                                .foregroundStyle(.green, .secondary)
                            Image(systemName: "cloud.sun.rain")
                                .symbolRenderingMode(.multicolor)
                        }
                        .font(.largeTitle)
                    }

                    ExampleCard(
                        title: "Show a level with variable color",
                        caption: "`Image(systemName:variableValue:)` colors more of the symbol's layers as the value goes from 0 to 1.",
                        code: """
                        @State private var volume = 0.6

                        HStack {
                            Image(systemName: "speaker.wave.3", variableValue: volume)
                                .frame(width: 28)
                            Slider(value: $volume)
                                .frame(width: 180)
                        }
                        """,
                        minHeight: 110
                    ) {
                        MacVariableSymbolSample()
                    }

                    ExampleCard(
                        title: "Confirm an action with an animation",
                        caption: "`.symbolEffect(.bounce, value:)` plays once each time the value changes, like a quick nod that something happened.",
                        code: """
                        @State private var downloads = 0

                        Button {
                            downloads += 1
                        } label: {
                            Label("Download", systemImage: "arrow.down.circle")
                        }
                        .symbolEffect(.bounce, value: downloads)
                        """,
                        minHeight: 110,
                        aside: Aside(.note, "Keep symbol animations for moments that mean something. See [Motion](catalog://motion).")
                    ) {
                        MacBounceSample()
                    }
                }
            }
        }
    }
}

// MARK: - Demo

private enum MacSymbolFont: String, CaseIterable, Identifiable {
    case caption, body, headline, title2, largeTitle
    var id: Self { self }
    var font: Font {
        switch self {
        case .caption: .caption
        case .body: .body
        case .headline: .headline
        case .title2: .title2
        case .largeTitle: .largeTitle
        }
    }
}

private enum MacSymbolScale: String, CaseIterable, Identifiable {
    case small, medium, large
    var id: Self { self }
    var scale: Image.Scale {
        switch self {
        case .small: .small
        case .medium: .medium
        case .large: .large
        }
    }
}

private enum MacSymbolWeight: String, CaseIterable, Identifiable {
    case regular, medium, semibold, bold
    var id: Self { self }
    var weight: Font.Weight {
        switch self {
        case .regular: .regular
        case .medium: .medium
        case .semibold: .semibold
        case .bold: .bold
        }
    }
}

/// A label whose text style, weight, and symbol scale you can change, with
/// the code for the current choice.
private struct MacSymbolDemo: View {
    @State private var font = MacSymbolFont.body
    @State private var weight = MacSymbolWeight.regular
    @State private var scale = MacSymbolScale.medium

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 10) {
                Label("Downloads", systemImage: "arrow.down.circle")
                Label("Favorites", systemImage: "star")
                Label("Shared", systemImage: "person.2")
            }
            .font(font.font)
            .fontWeight(weight.weight)
            .imageScale(scale.scale)
            .padding(24)
            .frame(maxWidth: .infinity, minHeight: 180)
            .background(Surface.preview)
            Divider()
            HStack(spacing: 20) {
                Picker("Style", selection: $font) {
                    ForEach(MacSymbolFont.allCases) { option in
                        Text(".\(option.rawValue)").tag(option)
                    }
                }
                .fixedSize()
                Picker("Weight", selection: $weight) {
                    ForEach(MacSymbolWeight.allCases) { option in
                        Text(".\(option.rawValue)").tag(option)
                    }
                }
                .fixedSize()
                Picker("Scale", selection: $scale) {
                    ForEach(MacSymbolScale.allCases) { option in
                        Text(".\(option.rawValue)").tag(option)
                    }
                }
                .fixedSize()
                Spacer(minLength: 0)
            }
            .padding(14)
            Divider()
            CodeBlock(code: code, isAttached: true)
        }
        .cardStyle()
    }

    private var code: String {
        var lines = ["Label(\"Downloads\", systemImage: \"arrow.down.circle\")"]
        if font != .body { lines.append("    .font(.\(font.rawValue))") }
        if weight != .regular { lines.append("    .fontWeight(.\(weight.rawValue))") }
        if scale != .medium { lines.append("    .imageScale(.\(scale.rawValue))") }
        return lines.joined(separator: "\n")
    }
}

private struct MacVariableSymbolSample: View {
    @State private var volume = 0.6

    var body: some View {
        HStack {
            Image(systemName: "speaker.wave.3", variableValue: volume)
                .frame(width: 28)
            Slider(value: $volume)
                .frame(width: 180)
        }
    }
}

private struct MacBounceSample: View {
    @State private var downloads = 0

    var body: some View {
        Button {
            downloads += 1
        } label: {
            Label("Download", systemImage: "arrow.down.circle")
        }
        .symbolEffect(.bounce, value: downloads)
    }
}

// MARK: - Guideline samples

private struct MacSymbolRow: View {
    let symbolWeight: Font.Weight?

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "folder")
                .fontWeight(symbolWeight)
            Text("Documents")
        }
        .font(.title3)
    }
}

private struct MacSymbolToolbar: View {
    let symbols: [String]

    var body: some View {
        MacWindowFrame(title: "Notes", width: 230, height: 90) {
            Color.clear
        } toolbar: {
            ForEach(symbols, id: \.self) { symbol in
                Image(systemName: symbol)
            }
        }
    }
}
