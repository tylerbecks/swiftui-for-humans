import SwiftUI

extension ComponentPage {
    static let colorPicker = ComponentPage(
        id: "color-picker",
        title: "ColorPicker",
        summary: "A color well that opens the system color panel to pick a color.",
        category: .controls,
        symbol: "paintpalette",
        availability: ["macOS 11.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/colorpicker",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/color-wells",
        aliases: ["color well", "NSColorWell", "NSColorPanel", "colors window", "input type=color", "swatch", "eyedropper", "opacity", "alpha"],
        related: ["color", "labeled-content", "form", "inspector"],
        notes: [
            "**The system panel remembers people's colors.** Colors they save there show up in every app that uses it, which is a good reason not to build your own.",
            "**Color wells take drag and drop.** People can drag a color from one well to another, or from the color panel onto a well.",
        ],
        api: [
            APIItem("`ColorPicker(_:selection:)`", "A labeled color well bound to a `Color`."),
            APIItem("`supportsOpacity: false`", "No opacity control; colors stay solid."),
            APIItem("`ColorPicker(selection:label:)`", "A custom label view."),
            APIItem("`.labelsHidden()`", "Just the well, without its title."),
            APIItem("`Color.resolve(in:)`", "Gets components you can save."),
        ],
        guidelines: [
            Guideline(
                "Use the system color picker.",
                "People already know it, and it keeps the colors they've saved. A custom picker is something new to learn and loses those colors."
            ),
        ]
    ) {
        VStack(alignment: .trailing, spacing: 10) {
            ColorPicker("Text", selection: .constant(Color.indigo))
            ColorPicker("Highlight", selection: .constant(Color.yellow))
        }
        .fixedSize()
    } content: { page in
        MacColorPickerDemo(page: page)
    }
}

private struct MacColorPickerConfig {
    var title = "Highlight"
    var color = Color.yellow
    var supportsOpacity = true
    var hidesLabel = false
    var size: MacColorPickerSizeOption = .regular
    var isDisabled = false
}

private struct MacColorPickerDemo: View {
    let page: ComponentPage

    var body: some View {
        DemoPage(
            page: page,
            initial: MacColorPickerConfig(),
            usage: """
            @State private var highlight = Color.yellow

            ColorPicker("Highlight", selection: $highlight)
            """,
            usageNote: Aside(.note, "Click the well to open the system color panel. When people choose a color there, the well and your binding update to match.")
        ) { $config in
            VStack(spacing: 20) {
                // Black text on a white page, like a highlighter on
                // paper, so it reads the same in light and dark.
                Text("The quick brown fox")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(.black)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(config.color, in: .rect(cornerRadius: 4))
                    .padding(16)
                    .background(.white, in: .rect(cornerRadius: 8))
                    .overlay {
                        RoundedRectangle(cornerRadius: 8)
                            .strokeBorder(.separator)
                    }
                ColorPicker(config.title, selection: $config.color, supportsOpacity: config.supportsOpacity)
                    .modifier(MacColorPickerHidesLabel(isHidden: config.hidesLabel))
                    .controlSize(config.size.size)
                    .disabled(config.isDisabled)
                    .fixedSize()
            }
        } controls: { $config in
            Section("Content") {
                TextField("Title", text: $config.title)
                Toggle("Supports opacity", isOn: $config.supportsOpacity)
            }
            Section("Appearance") {
                OptionPicker("Size", selection: $config.size)
                Toggle("Hide label", isOn: $config.hidesLabel)
                Toggle("Disabled", isOn: $config.isDisabled)
            }
        } code: { config in
            var lines = ["@State private var highlight = Color.yellow", ""]
            if config.supportsOpacity {
                lines.append("ColorPicker(\(swiftString(config.title)), selection: $highlight)")
            } else {
                lines.append("ColorPicker(\(swiftString(config.title)), selection: $highlight, supportsOpacity: false)")
            }
            if config.hidesLabel {
                lines.append("    .labelsHidden()")
            }
            if config.size != .regular {
                lines.append("    .controlSize(\(config.size.label))")
            }
            if config.isDisabled {
                lines.append("    .disabled(true)")
            }
            return lines.joined(separator: "\n")
        } examples: {
            MacColorPickerExamples()
        }
    }
}

// MARK: - Examples

private struct MacColorPickerExamples: View {
    @State private var fill = Color.teal
    @State private var stroke = Color.indigo
    @State private var labelColor = Color.orange
    @State private var tagColor = Color.mint
    @Environment(\.self) private var environment
    @AppStorage("demo.colorPicker.tag") private var savedTag = ""

    var body: some View {
        ExampleCard(
            title: "Colors in an inspector",
            caption: "Put a few labeled wells in a `Form`. Each one is its own `ColorPicker` with its own binding.",
            code: """
            @State private var fill = Color.teal
            @State private var stroke = Color.indigo

            Form {
                ColorPicker("Fill", selection: $fill)
                ColorPicker("Stroke", selection: $stroke)
            }
            """,
            minHeight: 170
        ) {
            HStack(spacing: 32) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(fill)
                    .strokeBorder(stroke, lineWidth: 4)
                    .frame(width: 90, height: 90)
                Form {
                    ColorPicker("Fill", selection: $fill)
                    ColorPicker("Stroke", selection: $stroke)
                }
                .fixedSize()
            }
        }

        ExampleCard(
            title: "Solid colors only",
            caption: "Pass `supportsOpacity: false` when a see-through color makes no sense, like the color of a label. The panel then leaves out its opacity controls.",
            code: """
            @State private var labelColor = Color.orange

            ColorPicker("Label color", selection: $labelColor, supportsOpacity: false)
            """,
            minHeight: 120,
            aside: Aside(.note, "It also strips opacity from colors you set in code and from people's saved colors.")
        ) {
            HStack(spacing: 16) {
                Label("Travel", systemImage: "tag.fill")
                    .foregroundStyle(labelColor)
                ColorPicker("Label color", selection: $labelColor, supportsOpacity: false)
                    .fixedSize()
            }
        }

        ExampleCard(
            title: "Saving the color",
            caption: "`Color` isn't stored directly. `resolve(in:)` gives a `Color.Resolved`, which is `Codable`, so you can save it as JSON.",
            code: """
            @State private var tagColor = Color.mint
            @Environment(\\.self) private var environment
            @AppStorage("tagColor") private var savedTag = ""

            ColorPicker("Tag color", selection: $tagColor)
                .onChange(of: tagColor) {
                    let resolved = tagColor.resolve(in: environment)
                    if let data = try? JSONEncoder().encode(resolved) {
                        savedTag = String(decoding: data, as: UTF8.self)
                    }
                }
            """,
            minHeight: 140
        ) {
            VStack(spacing: 10) {
                ColorPicker("Tag color", selection: $tagColor)
                    .onChange(of: tagColor) {
                        let resolved = tagColor.resolve(in: environment)
                        if let data = try? JSONEncoder().encode(resolved) {
                            savedTag = String(decoding: data, as: UTF8.self)
                        }
                    }
                    .fixedSize()
                Text(savedTag.isEmpty ? "Pick a color to save it" : savedTag)
                    .font(.caption.monospaced())
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                    .frame(maxWidth: 360)
            }
        }
    }
}

// MARK: - Options

private enum MacColorPickerSizeOption: DemoOption {
    case mini, small, regular, large

    var label: String {
        switch self {
        case .mini: ".mini"
        case .small: ".small"
        case .regular: ".regular"
        case .large: ".large"
        }
    }

    var size: ControlSize {
        switch self {
        case .mini: .mini
        case .small: .small
        case .regular: .regular
        case .large: .large
        }
    }
}

private struct MacColorPickerHidesLabel: ViewModifier {
    let isHidden: Bool

    func body(content: Content) -> some View {
        if isHidden {
            content.labelsHidden()
        } else {
            content
        }
    }
}
