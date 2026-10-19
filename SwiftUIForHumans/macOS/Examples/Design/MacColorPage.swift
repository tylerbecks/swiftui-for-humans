import AppKit
import SwiftUI

extension ComponentPage {
    static let color = ComponentPage(
        id: "color",
        title: "Color & Accent",
        summary: "Semantic colors that adapt, and an accent color people choose for every app.",
        category: .foundations,
        kind: .concept,
        symbol: "paintpalette",
        availability: [],
        docsURL: "https://developer.apple.com/documentation/swiftui/color",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/color",
        aliases: ["accent color", "tint", "AccentColor", "brand color", "theme", "system colors", "semantic colors", "NSColor", "labelColor", "controlAccentColor", "windowBackgroundColor", "multicolor", "colour", "palette", "css variables"],
        related: ["dark-mode", "materials", "color-picker", "button", "contrast-transparency"],
        notes: [
            "**Never hard-code a system color's value.** Apple adjusts them between releases and for each appearance. Use `Color.red`, not the RGB numbers it has today.",
            "**Your accent shows only with Multicolor.** Check your app with a few other accent colors chosen in System Settings, since anyone who picks one sees your app that way.",
        ],
        api: [
            APIItem("`Color.accentColor`", "The person's accent color, or yours with Multicolor."),
            APIItem("`.tint(_:)`", "A color with meaning that's always respected."),
            APIItem("`.foregroundStyle(.secondary)`", "Label colors that adapt: `.primary` to `.quaternary`."),
            APIItem("`.separator`, `.link`, `.selection`", "Semantic styles for lines, links, and selection."),
            APIItem("`Color(nsColor:)`", "AppKit's semantic colors, like `.textBackgroundColor`."),
            APIItem("`.listItemTint(_:)`", "A fixed color for one sidebar icon."),
            APIItem("`ColorPicker`", "The system's color well and Colors panel."),
        ],
        guidelines: [
            Guideline(
                "Use semantic colors for what they're named for.",
                "Each one is defined by its job, so it adapts correctly. Don't borrow the separator color for text, or a label color for a background.",
                good: "Secondary text uses `.secondary`.",
                bad: "Secondary text uses `.separator`."
            ) {
                MacColorDetailRow(usesSeparator: false)
            } bad: {
                MacColorDetailRow(usesSeparator: true)
            },
            Guideline(
                "Don't rely on color alone.",
                "Pair color with a symbol or a word, so people who can't tell the colors apart still get the message.",
                good: "Each status has a symbol and a name.",
                bad: "Only the dot's color tells them apart."
            ) {
                MacColorStatusList(showsLabels: true)
            } bad: {
                MacColorStatusList(showsLabels: false)
            },
            Guideline(
                "Let the person's accent color lead.",
                "People can pick an accent color that applies to every app. Use `Color.accentColor` and the default control styles, so buttons and selection follow their choice."
            ),
            Guideline(
                "Give each color one meaning.",
                "If your brand color marks things people can click, don't also use it for plain text. Mixed meanings make people guess."
            ),
            Guideline(
                "Use color sparingly on Liquid Glass.",
                "Toolbars and sidebars look best monochrome. To call out the main action, color its background, as a prominent button does, rather than its symbol or text."
            ),
            Guideline(
                "Use the system color picker.",
                "If people choose colors in your app, `ColorPicker` opens the standard Colors panel, where their saved colors are waiting."
            ),
        ],
        sources: [
            "https://developer.apple.com/design/human-interface-guidelines/color",
            "https://developer.apple.com/design/human-interface-guidelines/sidebars",
            "https://developer.apple.com/documentation/swiftui/color/accentcolor",
            "https://developer.apple.com/documentation/swiftui/view/tint(_:)",
            "https://developer.apple.com/documentation/swiftui/view/listitemtint(_:)",
            "https://developer.apple.com/documentation/swiftui/color/init(nscolor:)",
            "https://developer.apple.com/documentation/appkit/nscolor",
        ],
        reviewed: "October 2026"
    ) {
        HStack(spacing: 6) {
            ForEach([Color.red, .orange, .yellow, .green, .blue, .purple], id: \.self) { color in
                Circle()
                    .fill(color)
                    .frame(width: 20, height: 20)
            }
        }
    } content: { page in
        MacColorArticle(page: page)
    }
}

// MARK: - Page

private struct MacColorArticle: View {
    let page: ComponentPage

    var body: some View {
        ArticlePage(page: page) {
            Prose("Mac colors are named for what they do, not how they look: label, separator, window background, selected content. Each one has values for light, dark, and Increase Contrast, so a window built from them adapts on its own. On top of that, people choose an **accent color** in System Settings, and it shows up in every app's buttons, selection, and sidebar icons.")

            VStack(alignment: .leading, spacing: 16) {
                SectionTitle("Your accent color or theirs")
                ConnectFacts(rows: [
                    ("Multicolor", "When people leave the accent color on Multicolor, the system uses your app's accent color, from the `AccentColor` set in your asset catalog."),
                    ("Any other choice", "Their color replaces yours everywhere: buttons, selection, and sidebar icons. A sidebar icon you gave a fixed color keeps it."),
                    ("`.tint(_:)`", "Always respected. Use it when a color carries meaning, like red for a destructive action, not to force your brand."),
                ])
            }

            VStack(alignment: .leading, spacing: 16) {
                SectionTitle("Semantic colors")
                    .id("demo")
                Prose("Live, in light and dark. The first ones are SwiftUI styles; the rest come from AppKit's `NSColor`.")
                MacSemanticSwatches()
            }

            VStack(alignment: .leading, spacing: 16) {
                SectionTitle("System colors")
                Prose("Each has its own light and dark value, tuned for contrast. Use them by name.")
                MacSystemSwatches()
            }

            VStack(alignment: .leading, spacing: 16) {
                SectionTitle("In SwiftUI")
                    .id("examples")
                VStack(alignment: .leading, spacing: 44) {
                    ExampleCard(
                        title: "Use the accent color",
                        caption: "A `.borderedProminent` button fills with `Color.accentColor`: yours with Multicolor, the person's choice otherwise.",
                        code: """
                        HStack {
                            Button("Cancel") { }
                            Button("Book Trip") { }
                                .buttonStyle(.borderedProminent)
                        }
                        """,
                        minHeight: 110,
                        aside: Aside(.note, "Set your accent in the asset catalog's `AccentColor` color set. Xcode's templates name it for you.")
                    ) {
                        HStack {
                            Button("Cancel") { }
                            Button("Book Trip") { }
                                .buttonStyle(.borderedProminent)
                        }
                    }

                    ExampleCard(
                        title: "Give a control a fixed meaning",
                        caption: "`.tint(.red)` keeps a destructive button red whatever accent color people pick.",
                        code: """
                        HStack {
                            Button("Keep Trip") { }
                            Button("Delete Trip", role: .destructive) { }
                                .buttonStyle(.borderedProminent)
                                .tint(.red)
                        }
                        """,
                        minHeight: 110,
                        aside: Aside(.note, "On the Mac, `.borderedProminent` tints the button's background, and `.bordered` doesn't tint at all.")
                    ) {
                        HStack {
                            Button("Keep Trip") { }
                            Button("Delete Trip", role: .destructive) { }
                                .buttonStyle(.borderedProminent)
                                .tint(.red)
                        }
                    }

                    ExampleCard(
                        title: "Keep one sidebar icon's color",
                        caption: "Sidebar icons follow the accent color. Use `.listItemTint(_:)` for the rare icon whose color means something.",
                        code: """
                        List {
                            Label("Inbox", systemImage: "tray")
                            Label("Important", systemImage: "star")
                                .listItemTint(.yellow)
                            Label("Sent", systemImage: "paperplane")
                        }
                        .listStyle(.sidebar)
                        """,
                        minHeight: 170
                    ) {
                        List {
                            Label("Inbox", systemImage: "tray")
                            Label("Important", systemImage: "star")
                                .listItemTint(.yellow)
                            Label("Sent", systemImage: "paperplane")
                        }
                        .listStyle(.sidebar)
                        .scrollDisabled(true)
                        .frame(width: 220, height: 120)
                    }

                    ExampleCard(
                        title: "Use AppKit's semantic colors",
                        caption: "`Color(nsColor:)` brings in Mac colors SwiftUI doesn't name, like `.textBackgroundColor` behind editable text.",
                        code: """
                        Text("Bring a light jacket for the evenings.")
                            .padding(10)
                            .frame(width: 260, height: 70, alignment: .topLeading)
                            .background(Color(nsColor: .textBackgroundColor))
                            .border(.separator)
                        """,
                        minHeight: 130
                    ) {
                        Text("Bring a light jacket for the evenings.")
                            .padding(10)
                            .frame(width: 260, height: 70, alignment: .topLeading)
                            // AppKit's semantic color: SwiftUI has no text background style.
                            .background(Color(nsColor: .textBackgroundColor))
                            .border(.separator)
                    }
                }
            }
        }
    }
}

// MARK: - Swatches

private struct MacColorSpec: Identifiable {
    let name: String
    let use: String
    let style: AnyShapeStyle
    var id: String { name }
}

/// Semantic colors, each drawn once forced light and once forced dark.
private struct MacSemanticSwatches: View {
    // AppKit's semantic colors: SwiftUI has no styles for most of these.
    private let specs: [MacColorSpec] = [
        MacColorSpec(name: ".primary", use: "Main text", style: AnyShapeStyle(.primary)),
        MacColorSpec(name: ".secondary", use: "Subheadings and details", style: AnyShapeStyle(.secondary)),
        MacColorSpec(name: ".tertiary", use: "Less important text", style: AnyShapeStyle(.tertiary)),
        MacColorSpec(name: ".separator", use: "Lines between content", style: AnyShapeStyle(.separator)),
        MacColorSpec(name: ".link", use: "Links", style: AnyShapeStyle(.link)),
        MacColorSpec(name: ".windowBackground", use: "A window's background", style: AnyShapeStyle(.windowBackground)),
        MacColorSpec(name: ".controlBackgroundColor", use: "Tables and other large controls", style: AnyShapeStyle(Color(nsColor: .controlBackgroundColor))),
        MacColorSpec(name: ".textBackgroundColor", use: "Behind editable text", style: AnyShapeStyle(Color(nsColor: .textBackgroundColor))),
        MacColorSpec(name: ".underPageBackgroundColor", use: "Behind a document's pages", style: AnyShapeStyle(Color(nsColor: .underPageBackgroundColor))),
        MacColorSpec(name: ".selectedContentBackgroundColor", use: "Selection in the key window", style: AnyShapeStyle(Color(nsColor: .selectedContentBackgroundColor))),
        MacColorSpec(name: ".findHighlightColor", use: "Find results", style: AnyShapeStyle(Color(nsColor: .findHighlightColor))),
    ]

    var body: some View {
        Grid(alignment: .leading, horizontalSpacing: 14, verticalSpacing: 10) {
            GridRow {
                Text("Light")
                Text("Dark")
                Text("Name")
                Text("Use for")
            }
            .font(.subheadline.weight(.medium))
            .foregroundStyle(.secondary)
            ForEach(specs) { spec in
                GridRow {
                    MacSwatch(style: spec.style, scheme: .light)
                    MacSwatch(style: spec.style, scheme: .dark)
                    Text(spec.name)
                        .font(.callout.monospaced())
                    Text(spec.use)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle()
    }
}

private struct MacSystemSwatches: View {
    private let colors: [(String, Color)] = [
        ("red", .red), ("orange", .orange), ("yellow", .yellow), ("green", .green),
        ("mint", .mint), ("teal", .teal), ("cyan", .cyan), ("blue", .blue),
        ("indigo", .indigo), ("purple", .purple), ("pink", .pink), ("brown", .brown),
    ]

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 96), spacing: 12)], spacing: 14) {
            ForEach(colors, id: \.0) { name, color in
                VStack(spacing: 6) {
                    HStack(spacing: 4) {
                        MacSwatch(style: AnyShapeStyle(color), scheme: .light)
                        MacSwatch(style: AnyShapeStyle(color), scheme: .dark)
                    }
                    Text(".\(name)")
                        .font(.callout.monospaced())
                }
            }
        }
        .padding(20)
        .cardStyle()
    }
}

/// A rounded square of a style, resolved in the given appearance and drawn
/// on that appearance's window background.
private struct MacSwatch: View {
    let style: AnyShapeStyle
    let scheme: ColorScheme

    var body: some View {
        RoundedRectangle(cornerRadius: 6)
            .fill(style)
            .frame(width: 30, height: 30)
            .padding(4)
            .background(.windowBackground, in: .rect(cornerRadius: 9))
            .overlay {
                RoundedRectangle(cornerRadius: 9)
                    .strokeBorder(.separator)
            }
            .environment(\.colorScheme, scheme)
    }
}

// MARK: - Guideline samples

private struct MacColorDetailRow: View {
    let usesSeparator: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Weekly Planning")
                .font(.headline)
            Text("Today, 9:41 AM")
                .foregroundStyle(usesSeparator ? AnyShapeStyle(.separator) : AnyShapeStyle(.secondary))
        }
    }
}

private struct MacColorStatusList: View {
    let showsLabels: Bool

    private let rows: [(String, String, Color, String)] = [
        ("Flight", "checkmark.circle.fill", .green, "Confirmed"),
        ("Hotel", "clock.fill", .orange, "Pending"),
        ("Car", "xmark.circle.fill", .red, "Canceled"),
    ]

    var body: some View {
        Grid(alignment: .leading, horizontalSpacing: 12, verticalSpacing: 8) {
            ForEach(rows, id: \.0) { item, symbol, color, status in
                GridRow {
                    Text(item)
                    if showsLabels {
                        Label(status, systemImage: symbol)
                            .foregroundStyle(color)
                    } else {
                        Circle()
                            .fill(color)
                            .frame(width: 10, height: 10)
                    }
                }
            }
        }
    }
}
