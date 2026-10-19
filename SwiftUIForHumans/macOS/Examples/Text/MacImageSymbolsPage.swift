import SwiftUI

extension ComponentPage {
    static let imageSymbols = ComponentPage(
        id: "image-symbols",
        title: "Image & SF Symbols",
        summary: "Show pictures from your app, and thousands of system symbols that match your text.",
        category: .textAndImages,
        symbol: "photo",
        availability: ["macOS 10.15+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/image",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/sf-symbols",
        aliases: ["<img>", "icon", "icons", "NSImage", "NSImageView", "SF Symbols", "systemName", "symbol", "rendering mode", "hierarchical", "palette", "multicolor", "variable value", "symbol effect", "bounce", "pulse", "animated icon", "resizable", "aspect ratio"],
        related: ["sf-symbols", "text-label", "async-image", "app-icons", "color"],
        notes: [
            "**Image modifiers come first.** `.resizable()` returns an `Image`, so call it before view modifiers like `.frame` or `.padding`.",
            "**Symbols depend on the OS version.** A symbol or effect added in a given year isn't there on older systems. The SF Symbols app shows each one's availability.",
        ],
        api: [
            APIItem("`Image(systemName:)`", "An SF Symbol by name."),
            APIItem("`Image(_:)`", "An image from your asset catalog."),
            APIItem("`.resizable()`", "Lets an image grow or shrink to its frame."),
            APIItem("`.symbolRenderingMode(_:)`", "`.hierarchical`, `.palette`, or `.multicolor`."),
            APIItem("`Image(systemName:variableValue:)`", "Fills a symbol's layers by a 0–1 value."),
            APIItem("`.imageScale(_:)`", "A symbol's size next to its text."),
            APIItem("`.symbolEffect(_:value:)`", "Plays an effect when a value changes."),
            APIItem("`Image(decorative:)`", "An image VoiceOver skips."),
        ],
        guidelines: [
            Guideline(
                "Size symbols with the font, not a frame.",
                "A symbol matches the weight and size of the text beside it. Use `.imageScale` to give it more or less emphasis.",
                good: "The symbol matches the text.",
                bad: "A fixed frame breaks the match."
            ) {
                MacSymbolSizeSample(usesFont: true)
            } bad: {
                MacSymbolSizeSample(usesFont: false)
            },
            Guideline(
                "Check the rendering mode where it's used.",
                "Size and background change how well people can see a symbol's details. Try another mode if a symbol is hard to read."
            ),
            Guideline(
                "Use variable color for change, not depth.",
                "It suits values that change, like volume or signal strength. To show depth, use the hierarchical mode instead."
            ),
            Guideline(
                "Animate symbols with a purpose.",
                "Each effect says something, like a bounce for “this happened.” Too many animations distract people from their work."
            ),
            Guideline(
                "Make a clickable image a button.",
                "On the Mac, an image people click should be a `Button` with an image, not an image with a tap gesture."
            ),
        ]
    ) {
        HStack(spacing: 16) {
            Image(systemName: "cloud.sun.rain.fill")
                .symbolRenderingMode(.multicolor)
            Image(systemName: "speaker.wave.3.fill", variableValue: 0.6)
                .foregroundStyle(.tint)
            Image(systemName: "folder.badge.plus")
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.teal)
        }
        .font(.system(size: 34))
    } content: { page in
        MacImageSymbolsDemo(page: page)
    }
}

private struct MacImageSymbolsConfig {
    var symbol: MacSymbolOption = .cloudSunRain
    var mode: MacRenderingOption = .hierarchical
    var value = 1.0
    var size: MacSymbolFontOption = .big
    var scale: MacImageScaleOption = .medium
    var effect: MacSymbolEffectOption = .none
    var trigger = 0
}

private struct MacImageSymbolsDemo: View {
    let page: ComponentPage

    var body: some View {
        DemoPage(
            page: page,
            initial: MacImageSymbolsConfig(),
            usage: """
            Label("Downloads", systemImage: "arrow.down.circle")

            Image(systemName: "cloud.sun.rain.fill")
                .symbolRenderingMode(.multicolor)
                .font(.largeTitle)
            """,
            usageNote: Aside(.note, "Size a symbol with `.font`, like text. It scales with the font and lines up with text on the same line.")
        ) { $config in
            VStack(spacing: 24) {
                MacSymbolPreview(config: config)
                    .font(config.size.font)
                    .imageScale(config.scale.scale)

                HStack(spacing: 6) {
                    Image(systemName: config.symbol.name, variableValue: config.symbol.isVariable ? config.value : nil)
                        .imageScale(config.scale.scale)
                    Text("Next to body text")
                }
                .symbolRenderingMode(config.mode.mode)
                .foregroundStyle(.secondary)

                if config.effect == .bounce {
                    Button("Play Bounce") { config.trigger += 1 }
                        .controlSize(.small)
                }
            }
        } controls: { $config in
            Section("Symbol") {
                OptionPicker("Symbol", selection: $config.symbol)
                OptionPicker("Rendering", selection: $config.mode)
                if config.symbol.isVariable {
                    ValueSlider("Variable value", value: $config.value, in: 0...1, step: 0.1)
                }
            }
            Section("Size and motion") {
                OptionPicker("Font", selection: $config.size)
                OptionPicker("Scale", selection: $config.scale)
                OptionPicker("Effect", selection: $config.effect)
            }
        } code: { config in
            code(for: config)
        } examples: {
            MacImageSymbolsExamples()
        }
    }

    private func code(for config: MacImageSymbolsConfig) -> String {
        var lines: [String] = []
        if config.effect == .bounce {
            lines += ["@State private var count = 0", ""]
        }
        if config.symbol.isVariable && config.value < 1 {
            lines.append("Image(systemName: \"\(config.symbol.name)\", variableValue: \(swiftNumber(config.value)))")
        } else {
            lines.append("Image(systemName: \"\(config.symbol.name)\")")
        }
        if config.mode != .monochrome {
            lines.append("    .symbolRenderingMode(\(config.mode.label))")
        }
        switch config.mode {
        case .monochrome, .hierarchical: lines.append("    .foregroundStyle(.blue)")
        case .palette: lines.append("    .foregroundStyle(.blue, .orange)")
        case .multicolor: break
        }
        lines.append("    .font(\(config.size.label))")
        if config.scale != .medium {
            lines.append("    .imageScale(\(config.scale.label))")
        }
        switch config.effect {
        case .none: break
        case .bounce: lines.append("    .symbolEffect(.bounce, value: count)")
        case .pulse: lines.append("    .symbolEffect(.pulse)")
        case .breathe: lines.append("    .symbolEffect(.breathe)")
        case .variableColor: lines.append("    .symbolEffect(.variableColor.iterative)")
        }
        return lines.joined(separator: "\n")
    }
}

/// The big symbol in the demo, with the chosen color and effect.
private struct MacSymbolPreview: View {
    let config: MacImageSymbolsConfig

    var body: some View {
        let image = Image(systemName: config.symbol.name, variableValue: config.symbol.isVariable ? config.value : nil)
            .symbolRenderingMode(config.mode.mode)
        Group {
            switch config.mode {
            case .monochrome, .hierarchical: image.foregroundStyle(.blue)
            case .palette: image.foregroundStyle(.blue, .orange)
            case .multicolor: image
            }
        }
        .modifier(MacSymbolEffectModifier(effect: config.effect, trigger: config.trigger))
    }
}

private struct MacSymbolEffectModifier: ViewModifier {
    let effect: MacSymbolEffectOption
    let trigger: Int

    func body(content: Content) -> some View {
        switch effect {
        case .none: content
        case .bounce: content.symbolEffect(.bounce, value: trigger)
        case .pulse: content.symbolEffect(.pulse)
        case .breathe: content.symbolEffect(.breathe)
        case .variableColor: content.symbolEffect(.variableColor.iterative)
        }
    }
}

// MARK: - Examples

private struct MacImageSymbolsExamples: View {
    @State private var volume = 0.5
    @State private var isMuted = false
    @State private var alerts = 0
    @State private var isSyncing = true

    var body: some View {
        ExampleCard(
            title: "Symbols next to text",
            caption: "A symbol takes its size from the font. `.imageScale` makes it smaller or larger than the text without changing the text.",
            code: """
            VStack(alignment: .leading, spacing: 8) {
                Label("Small", systemImage: "heart.fill")
                    .imageScale(.small)
                Label("Medium", systemImage: "heart.fill")
                    .imageScale(.medium)
                Label("Large", systemImage: "heart.fill")
                    .imageScale(.large)
            }
            .foregroundStyle(.pink)
            """,
            minHeight: 130
        ) {
            VStack(alignment: .leading, spacing: 8) {
                Label("Small", systemImage: "heart.fill")
                    .imageScale(.small)
                Label("Medium", systemImage: "heart.fill")
                    .imageScale(.medium)
                Label("Large", systemImage: "heart.fill")
                    .imageScale(.large)
            }
            .foregroundStyle(.pink)
        }

        ExampleCard(
            title: "A level with a variable value",
            caption: "Pass `variableValue:` from 0 to 1 and the symbol fills its layers to match, like a volume indicator.",
            code: """
            @State private var volume = 0.5

            HStack {
                Image(systemName: "speaker.wave.3.fill", variableValue: volume)
                    .frame(width: 24)
                Slider(value: $volume)
                    .frame(width: 180)
            }
            .font(.title2)
            """,
            minHeight: 100
        ) {
            HStack {
                Image(systemName: "speaker.wave.3.fill", variableValue: volume)
                    .frame(width: 24)
                Slider(value: $volume)
                    .frame(width: 180)
            }
            .font(.title2)
        }

        ExampleCard(
            title: "Effects that answer a click",
            caption: "Bounce a symbol each time a value changes with `.symbolEffect(.bounce, value:)`, and swap symbols with a `.replace` transition.",
            code: """
            @State private var alerts = 0
            @State private var isMuted = false

            HStack(spacing: 24) {
                Button("Ring", systemImage: "bell") { alerts += 1 }
                    .symbolEffect(.bounce, value: alerts)
                Button(isMuted ? "Unmute" : "Mute", systemImage: isMuted ? "speaker.slash" : "speaker.wave.2") {
                    isMuted.toggle()
                }
                .contentTransition(.symbolEffect(.replace))
            }
            """,
            minHeight: 100
        ) {
            HStack(spacing: 24) {
                Button("Ring", systemImage: "bell") { alerts += 1 }
                    .symbolEffect(.bounce, value: alerts)
                Button(isMuted ? "Unmute" : "Mute", systemImage: isMuted ? "speaker.slash" : "speaker.wave.2") {
                    isMuted.toggle()
                }
                .contentTransition(.symbolEffect(.replace))
            }
        }

        ExampleCard(
            title: "Show that work is ongoing",
            caption: "Use an effect that repeats, like `.pulse`, with `isActive:` so it stops when the work does.",
            code: """
            @State private var isSyncing = true

            VStack(spacing: 12) {
                Image(systemName: "arrow.triangle.2.circlepath.icloud")
                    .font(.largeTitle)
                    .symbolEffect(.pulse, isActive: isSyncing)
                Toggle("Syncing", isOn: $isSyncing)
            }
            """,
            minHeight: 130
        ) {
            VStack(spacing: 12) {
                Image(systemName: "arrow.triangle.2.circlepath.icloud")
                    .font(.largeTitle)
                    .symbolEffect(.pulse, isActive: isSyncing)
                Toggle("Syncing", isOn: $isSyncing)
            }
        }

        ExampleCard(
            title: "A photo from your asset catalog",
            caption: "Call `.resizable()`, then `.scaledToFill()` and a frame, and clip the overflow so the photo fills the space.",
            code: """
            Image("photo")
                .resizable()
                .scaledToFill()
                .frame(width: 260, height: 150)
                .clipShape(.rect(cornerRadius: 12))
            """,
            minHeight: 190,
            aside: Aside(.note, "For the Mac, give bitmaps @1x and @2x versions, or use PDF or SVG for flat artwork that needs to scale.")
        ) {
            Scenery.lake.image
                .resizable()
                .scaledToFill()
                .frame(width: 260, height: 150)
                .clipShape(.rect(cornerRadius: 12))
        }
    }
}

/// A folder symbol beside body text, sized by the font or by a frame.
private struct MacSymbolSizeSample: View {
    let usesFont: Bool

    var body: some View {
        HStack(spacing: 6) {
            if usesFont {
                Image(systemName: "folder")
            } else {
                Image(systemName: "folder")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
            }
            Text("Projects")
        }
        .foregroundStyle(.secondary)
    }
}

// MARK: - Options

private enum MacSymbolOption: DemoOption {
    case cloudSunRain, speaker, wifi, folderBadge

    var name: String {
        switch self {
        case .cloudSunRain: "cloud.sun.rain.fill"
        case .speaker: "speaker.wave.3.fill"
        case .wifi: "wifi"
        case .folderBadge: "folder.badge.plus"
        }
    }

    var label: String { name }

    var isVariable: Bool {
        self == .speaker || self == .wifi
    }
}

private enum MacRenderingOption: DemoOption {
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

private enum MacSymbolFontOption: DemoOption {
    case body, title, largeTitle, big

    var label: String {
        switch self {
        case .body: ".body"
        case .title: ".title"
        case .largeTitle: ".largeTitle"
        case .big: ".system(size: 64)"
        }
    }

    var font: Font {
        switch self {
        case .body: .body
        case .title: .title
        case .largeTitle: .largeTitle
        case .big: .system(size: 64)
        }
    }
}

private enum MacImageScaleOption: DemoOption {
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

private enum MacSymbolEffectOption: DemoOption {
    case none, bounce, pulse, breathe, variableColor

    var label: String {
        switch self {
        case .none: "None"
        case .bounce: ".bounce"
        case .pulse: ".pulse"
        case .breathe: ".breathe"
        case .variableColor: ".variableColor"
        }
    }
}
