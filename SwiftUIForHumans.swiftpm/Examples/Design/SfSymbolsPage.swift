import SwiftUI
import UIKit

extension ComponentPage {
    static let sfSymbols = ComponentPage(
        id: "sf-symbols",
        title: "SF Symbols",
        summary: "Thousands of built-in icons that match the system font and scale with text.",
        category: .design,
        symbol: "star.square.on.square",
        availability: ["iOS 13.0+", "macOS 11.0+", "visionOS 1.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/image/init(systemname:)",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/sf-symbols",
        aliases: ["icon", "icons", "font awesome", "material icons", "heroicons", "lucide", "glyph", "svg icon", "systemImage", "emoji"],
        related: ["image", "label", "symbol-effects", "typography"],
        notes: [
            "**Find names in the SF Symbols app.** It's free for Mac and shows each symbol's minimum iOS version. An unknown name draws nothing and logs a warning.",
            "**To animate a symbol, see [Symbol Effects](catalog://symbol-effects).** Bounce, pulse, and replace work on any symbol.",
        ],
        api: [
            APIItem("`Image(systemName:)`", "Draws a symbol by name."),
            APIItem("`Label(_:systemImage:)`", "A title with a symbol. Most controls take `systemImage:` too."),
            APIItem("`.font(_:)`", "Sets a symbol's size and weight, like text."),
            APIItem("`.imageScale(_:)`", "`.small`, `.medium`, or `.large`, relative to the font."),
            APIItem("`.symbolRenderingMode(_:)`", "`.hierarchical`, `.palette`, or `.multicolor`."),
            APIItem("`.symbolVariant(_:)`", "Switches to the `.fill`, `.circle`, or `.slash` version."),
            APIItem("`Image(systemName:variableValue:)`", "Fills a symbol's layers from 0 to 1."),
        ],
        guidelines: [
            Guideline(
                "Let symbols match the text beside them.",
                "Symbols come in the same weights as San Francisco. Set the size and weight with `.font` so the icon and its label look like one piece.",
                good: "The symbol takes its weight from the font.",
                bad: "A thin symbol beside bold text looks mismatched."
            ) {
                Label("Downloads", systemImage: "arrow.down.circle")
                    .font(.title3.bold())
            } bad: {
                Label {
                    Text("Downloads")
                } icon: {
                    Image(systemName: "arrow.down.circle")
                        .fontWeight(.ultraLight)
                }
                .font(.title3.bold())
            },
            Guideline(
                "Use variable color for change, not depth.",
                "A variable value shows a level that changes over time, like signal or volume. To give a symbol depth, use `.hierarchical` instead."
            ),
            Guideline(
                "Use a symbol for its usual meaning.",
                "People know `trash` means delete and `square.and.arrow.up` means share. Reusing them for something else confuses people."
            ),
            Guideline(
                "Check the rendering mode at small sizes.",
                "Fine layers in `.multicolor` or `.palette` can blur together in a toolbar. Use `.monochrome` if details get lost."
            ),
        ]
    ) {
        SymbolsThumbnail()
    } content: { page in
        SymbolsDemo(page: page)
    }
}

// MARK: - Options

private enum SymbolChoice: DemoOption {
    case wifi, speaker, cloud, person, heart, chart

    var label: String { name }

    var name: String {
        switch self {
        case .wifi: "wifi"
        case .speaker: "speaker.wave.3.fill"
        case .cloud: "cloud.sun.rain.fill"
        case .person: "person.crop.circle.badge.plus"
        case .heart: "heart.text.square.fill"
        case .chart: "chart.bar.fill"
        }
    }

    var supportsVariableValue: Bool {
        self == .wifi || self == .speaker || self == .chart
    }
}

private enum RenderingOption: DemoOption {
    case monochrome, hierarchical, palette, multicolor

    var label: String {
        switch self {
        case .monochrome: ".monochrome"
        case .hierarchical: ".hierarchical"
        case .palette: ".palette"
        case .multicolor: ".multicolor"
        }
    }

    var mode: SymbolRenderingMode {
        switch self {
        case .monochrome: .monochrome
        case .hierarchical: .hierarchical
        case .palette: .palette
        case .multicolor: .multicolor
        }
    }
}

private enum SymbolColorOption: DemoOption {
    case blue, pink, orange, green, primary

    var label: String {
        switch self {
        case .blue: ".blue"
        case .pink: ".pink"
        case .orange: ".orange"
        case .green: ".green"
        case .primary: ".primary"
        }
    }

    var color: Color {
        switch self {
        case .blue: .blue
        case .pink: .pink
        case .orange: .orange
        case .green: .green
        case .primary: .primary
        }
    }
}

private enum SymbolWeightOption: DemoOption {
    case ultraLight, light, regular, semibold, bold, black

    var label: String {
        switch self {
        case .ultraLight: ".ultraLight"
        case .light: ".light"
        case .regular: ".regular"
        case .semibold: ".semibold"
        case .bold: ".bold"
        case .black: ".black"
        }
    }

    var weight: Font.Weight {
        switch self {
        case .ultraLight: .ultraLight
        case .light: .light
        case .regular: .regular
        case .semibold: .semibold
        case .bold: .bold
        case .black: .black
        }
    }
}

private enum SymbolScaleOption: DemoOption {
    case small, medium, large

    var label: String {
        switch self {
        case .small: ".small"
        case .medium: ".medium"
        case .large: ".large"
        }
    }

    var scale: Image.Scale {
        switch self {
        case .small: .small
        case .medium: .medium
        case .large: .large
        }
    }
}

private struct SymbolsConfig {
    var symbol: SymbolChoice = .wifi
    var rendering: RenderingOption = .hierarchical
    var color: SymbolColorOption = .blue
    var secondColor: SymbolColorOption = .orange
    var weight: SymbolWeightOption = .regular
    var scale: SymbolScaleOption = .medium
    var size = 96.0
    var useVariableValue = true
    var variableValue = 0.6
    var drawMode = false
    var gradient = false
}

// MARK: - Demo

private struct SymbolsDemo: View {
    let page: ComponentPage

    var body: some View {
        DemoPage(
            page: page,
            initial: SymbolsConfig(),
            usage: """
            Image(systemName: "heart.fill")
                .font(.title)
                .foregroundStyle(.pink)

            Label("Favorites", systemImage: "heart.fill")
            """,
            usageNote: Aside(.important, "Size a symbol with `.font`, not `.resizable()` and `.frame`. That keeps it aligned with text and at the right weight.")
        ) { $config in
            VStack(spacing: 16) {
                symbol(config)
                    .frame(height: 150)
                    .animation(.snappy, value: config.variableValue)
                if config.symbol.supportsVariableValue && config.useVariableValue {
                    Slider(value: $config.variableValue, in: 0...1)
                        .frame(maxWidth: 240)
                        .accessibilityLabel("Variable value")
                }
            }
        } controls: { $config in
            Section("Symbol") {
                OptionPicker("Symbol", selection: $config.symbol)
                ValueSlider("Size", value: $config.size, in: 24...140, step: 1)
                OptionPicker("Weight", selection: $config.weight)
                OptionPicker("Scale", selection: $config.scale)
            }
            Section("Color") {
                OptionPicker("Rendering", selection: $config.rendering)
                if config.rendering != .multicolor {
                    OptionPicker(config.rendering == .palette ? "First color" : "Color", selection: $config.color)
                }
                if config.rendering == .palette {
                    OptionPicker("Second color", selection: $config.secondColor)
                }
                Toggle("Gradient (iOS 26)", isOn: $config.gradient)
            }
            if config.symbol.supportsVariableValue {
                Section {
                    Toggle("Variable value", isOn: $config.useVariableValue)
                    if config.useVariableValue {
                        ValueSlider("Value", value: $config.variableValue, in: 0...1, step: 0.05)
                        Toggle("Draw mode (iOS 26)", isOn: $config.drawMode)
                    }
                } header: {
                    Text("Variable value")
                } footer: {
                    Text("Draw mode reveals the symbol's strokes progressively instead of dimming layers.")
                }
            }
        } code: { config in
            code(config)
        } examples: {
            ExampleCard(
                title: "Symbols next to text",
                caption: "Use `Label` to pair a symbol with text, or put an `Image` right inside a `Text`.",
                code: """
                VStack(alignment: .leading, spacing: 12) {
                    Label("Settings", systemImage: "gearshape.fill")
                    Label("Downloads", systemImage: "arrow.down.circle")
                        .font(.title2.bold())
                    Text("Rated \\(Image(systemName: "star.fill")) 4.8")
                        .foregroundStyle(.orange)
                }
                """,
                minHeight: 160,
                aside: Aside(.note, "An `Image` inside `Text` flows and wraps like a word, which suits ratings and inline hints.")
            ) {
                VStack(alignment: .leading, spacing: 12) {
                    Label("Settings", systemImage: "gearshape.fill")
                    Label("Downloads", systemImage: "arrow.down.circle")
                        .font(.title2.bold())
                    Text("Rated \(Image(systemName: "star.fill")) 4.8")
                        .foregroundStyle(.orange)
                }
            }

            ExampleCard(
                title: "Variants",
                caption: "`.symbolVariant` switches every symbol inside a view to its filled, circled, or slashed version.",
                code: """
                HStack(spacing: 24) {
                    Image(systemName: "bell")
                    Image(systemName: "bell").symbolVariant(.fill)
                    Image(systemName: "bell").symbolVariant(.circle)
                    Image(systemName: "bell").symbolVariant(.slash)
                }
                .font(.largeTitle)
                """,
                minHeight: 120,
                aside: Aside(.note, "Tab bars apply `.fill` for you, so give a `Tab` the outline name and iOS picks the right one.")
            ) {
                HStack(spacing: 24) {
                    Image(systemName: "bell")
                    Image(systemName: "bell").symbolVariant(.fill)
                    Image(systemName: "bell").symbolVariant(.circle)
                    Image(systemName: "bell").symbolVariant(.slash)
                }
                .font(.largeTitle)
            }

            SymbolBrowser()
                .id("browser")
        }
    }

    private func symbol(_ config: SymbolsConfig) -> some View {
        let value = config.symbol.supportsVariableValue && config.useVariableValue ? config.variableValue : nil
        return Image(systemName: config.symbol.name, variableValue: value)
            .symbolRenderingMode(config.rendering.mode)
            .modifier(SymbolTint(config: config))
            .symbolVariableValueMode(config.drawMode && value != nil ? .draw : nil)
            .symbolColorRenderingMode(config.gradient ? .gradient : nil)
            .font(.system(size: config.size, weight: config.weight.weight))
            .imageScale(config.scale.scale)
    }

    private func code(_ config: SymbolsConfig) -> String {
        let usesValue = config.symbol.supportsVariableValue && config.useVariableValue
        var lines: [String] = []
        if usesValue {
            lines.append("Image(systemName: \"\(config.symbol.name)\", variableValue: \(swiftNumber(config.variableValue)))")
        } else {
            lines.append("Image(systemName: \"\(config.symbol.name)\")")
        }
        if config.rendering != .monochrome {
            lines.append("    .symbolRenderingMode(\(config.rendering.label))")
        }
        switch config.rendering {
        case .multicolor: break
        case .palette: lines.append("    .foregroundStyle(\(config.color.label), \(config.secondColor.label))")
        default: lines.append("    .foregroundStyle(\(config.color.label))")
        }
        if usesValue && config.drawMode {
            lines.append("    .symbolVariableValueMode(.draw)")
        }
        if config.gradient {
            lines.append("    .symbolColorRenderingMode(.gradient)")
        }
        let weight = config.weight == .regular ? "" : ", weight: \(config.weight.label)"
        lines.append("    .font(.system(size: \(swiftNumber(config.size))\(weight)))")
        if config.scale != .medium {
            lines.append("    .imageScale(\(config.scale.label))")
        }
        return lines.joined(separator: "\n")
    }
}

private struct SymbolTint: ViewModifier {
    let config: SymbolsConfig

    func body(content: Content) -> some View {
        switch config.rendering {
        case .multicolor: content
        case .palette: content.foregroundStyle(config.color.color, config.secondColor.color)
        default: content.foregroundStyle(config.color.color)
        }
    }
}

// MARK: - Browser

private struct SymbolEntry: Identifiable {
    let name: String
    let keywords: String
    var id: String { name }
}

private let usefulSymbols: [SymbolEntry] = [
    ("house.fill", "home"), ("magnifyingglass", "search find"), ("gearshape.fill", "settings preferences cog"),
    ("person.crop.circle", "user profile avatar account"), ("person.2.fill", "users people team group"),
    ("bell.fill", "notification alert"), ("heart.fill", "like love favorite"), ("star.fill", "favorite rating"),
    ("bookmark.fill", "save"), ("trash", "delete remove bin"), ("pencil", "edit"), ("square.and.pencil", "compose new edit"),
    ("square.and.arrow.up", "share export"), ("square.and.arrow.down", "download save"), ("plus", "add new"),
    ("plus.circle.fill", "add new"), ("minus", "remove subtract"), ("xmark", "close cancel dismiss x"),
    ("xmark.circle.fill", "clear close cancel"), ("checkmark", "done check ok tick"), ("checkmark.circle.fill", "done success complete"),
    ("info.circle", "information help about"), ("exclamationmark.triangle.fill", "warning error caution"),
    ("questionmark.circle", "help faq"), ("chevron.left", "back previous arrow"), ("chevron.right", "next forward disclosure arrow"),
    ("chevron.down", "expand dropdown arrow"), ("arrow.clockwise", "refresh reload retry"), ("arrow.up.arrow.down", "sort"),
    ("ellipsis", "more menu dots"), ("ellipsis.circle", "more menu options"), ("line.3.horizontal", "menu hamburger"),
    ("line.3.horizontal.decrease", "filter"), ("slider.horizontal.3", "filter settings adjust"), ("list.bullet", "list"),
    ("square.grid.2x2", "grid apps gallery"), ("calendar", "date schedule"), ("clock", "time history"),
    ("timer", "stopwatch countdown"), ("envelope.fill", "mail email message"), ("paperplane.fill", "send"),
    ("message.fill", "chat sms bubble"), ("phone.fill", "call"), ("video.fill", "camera facetime"),
    ("camera.fill", "photo picture"), ("photo", "image picture gallery"), ("mic.fill", "microphone record voice audio"),
    ("play.fill", "start media"), ("pause.fill", "media"), ("speaker.wave.2.fill", "volume sound audio"),
    ("music.note", "song audio"), ("globe", "web world internet language"), ("map", "maps directions"),
    ("mappin.and.ellipse", "pin location place"), ("location.fill", "gps navigation arrow"), ("cart.fill", "shopping basket buy"),
    ("bag.fill", "shopping store"), ("creditcard.fill", "payment card wallet"), ("gift.fill", "present"),
    ("tag.fill", "label price"), ("lock.fill", "password secure private"), ("key.fill", "password login"),
    ("eye", "show visible view password"), ("eye.slash", "hide hidden password"), ("faceid", "face id biometric login"),
    ("wifi", "network internet signal"), ("battery.100", "power charge"), ("bolt.fill", "lightning power flash"),
    ("sun.max.fill", "light mode weather day"), ("moon.fill", "dark mode night sleep"), ("cloud.fill", "weather"),
    ("flame.fill", "fire hot trending"), ("leaf.fill", "nature eco"), ("doc.text", "document file page"),
    ("folder.fill", "directory files"), ("paperclip", "attachment attach"), ("link", "url chain"),
    ("qrcode", "scan code"), ("sparkles", "ai magic new"), ("hand.thumbsup.fill", "like approve"),
    ("flag.fill", "report"), ("airplane", "travel flight"), ("car.fill", "drive transport"),
    ("figure.walk", "walk fitness activity"), ("fork.knife", "food restaurant eat"), ("cup.and.saucer.fill", "coffee cafe"),
].map { SymbolEntry(name: $0.0, keywords: $0.1) }

private struct SymbolBrowser: View {
    @State private var query = ""
    @State private var copied: String?

    private var results: [SymbolEntry] {
        let q = query.trimmingCharacters(in: .whitespaces).lowercased()
        guard !q.isEmpty else { return usefulSymbols }
        return usefulSymbols.filter { $0.name.contains(q) || $0.keywords.contains(q) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Find a symbol")
                    .font(.title3.bold())
                Text("Some useful symbols, searchable by what you'd call them on the web (try \"close\", \"settings\", or \"menu\"). Tap one to copy its name.")
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            VStack(spacing: 0) {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)
                    TextField("Search symbols", text: $query)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    if !query.isEmpty {
                        Button("Clear", systemImage: "xmark.circle.fill") { query = "" }
                            .labelStyle(.iconOnly)
                            .foregroundStyle(.secondary)
                            .buttonStyle(.plain)
                    }
                }
                .padding(10)
                .background(.fill.tertiary, in: .rect(cornerRadius: 10))
                .padding(12)

                Divider()

                ScrollView {
                    if results.isEmpty {
                        ContentUnavailableView.search(text: query)
                            .padding(.top, 20)
                    }
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 84), spacing: 8)], spacing: 8) {
                        ForEach(results) { entry in
                            Button {
                                UIPasteboard.general.string = entry.name
                                withAnimation(.snappy) { copied = entry.name }
                            } label: {
                                VStack(spacing: 8) {
                                    Image(systemName: entry.name)
                                        .font(.title2)
                                        .frame(height: 30)
                                    Text(entry.name)
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                        .multilineTextAlignment(.center)
                                        .lineLimit(2, reservesSpace: true)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 4)
                                .background(copied == entry.name ? AnyShapeStyle(.tint.opacity(0.15)) : AnyShapeStyle(.clear), in: .rect(cornerRadius: 10))
                                .contentShape(.rect)
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel(entry.name)
                        }
                    }
                    .padding(12)
                }
                .frame(height: 340)
                .background(.background)

                Divider()

                HStack {
                    Image(systemName: copied == nil ? "hand.tap" : "checkmark.circle.fill")
                        .foregroundStyle(copied == nil ? AnyShapeStyle(.secondary) : AnyShapeStyle(.green))
                    if let copied {
                        Text("Copied \"\(copied)\"")
                            .font(.footnote.monospaced())
                    } else {
                        Text("Tap a symbol to copy its name")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Text("\(results.count) shown")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                }
                .padding(12)
            }
            .cardStyle()
            .sensoryFeedback(.success, trigger: copied) { _, new in new != nil }
        }
    }
}

// MARK: - Thumbnail

private struct SymbolsThumbnail: View {
    var body: some View {
        HStack(spacing: 18) {
            Image(systemName: "cloud.sun.rain.fill")
                .symbolRenderingMode(.multicolor)
            Image(systemName: "wifi", variableValue: 0.6)
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.blue)
            Image(systemName: "heart.fill")
                .foregroundStyle(.pink)
        }
        .font(.system(size: 38))
    }
}
