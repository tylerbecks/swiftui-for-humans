import SwiftUI

extension ComponentPage {
    static let colorPicker = ComponentPage(
        id: "color-picker",
        title: "ColorPicker",
        summary: "A swatch that opens the system color picker so people can choose any color.",
        category: .controls,
        symbol: "eyedropper.halffull",
        availability: ["iOS 14.0+", "macOS 11.0+", "visionOS 1.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/colorpicker",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/color-wells",
        aliases: ["color input", "input type=color", "color well", "swatch", "eyedropper", "UIColorWell", "UIColorPickerViewController", "colour picker", "hex"],
        related: ["system-colors", "picker", "form"],
        notes: [
            "**`Color` isn't `Codable`.** To save a choice, store `color.resolve(in: environment)`, a `Color.Resolved` that is (iOS 17+).",
            "**You can't customize the sheet.** The grid, spectrum, sliders, and eyedropper are the system's; for your own UI, build swatches with buttons.",
        ],
        api: [
            APIItem("`ColorPicker(_:selection:)`", "A labeled swatch bound to a `Color`."),
            APIItem("`supportsOpacity:`", "Pass `false` to hide the opacity slider."),
            APIItem("`.labelsHidden()`", "Shows only the swatch; VoiceOver still reads the label."),
            APIItem("`Color.resolve(in:)`", "Gets the red, green, blue, and opacity values."),
            APIItem("`Color(_: Color.Resolved)`", "Turns saved values back into a `Color`."),
        ],
        guidelines: [
            Guideline(
                "Use the system color picker.",
                "People already know it, and it keeps their saved colors across apps. A custom picker throws that away."
            ),
            Guideline(
                "Offer a few swatches when the choices are fixed.",
                "For five tag colors, a row of circles is faster than a full spectrum. Use a picker with `.palette` style or your own buttons."
            ),
        ]
    ) {
        HStack(spacing: 14) {
            RoundedRectangle(cornerRadius: 14)
                .fill(.indigo.gradient)
                .frame(width: 56, height: 56)
            ColorPicker("Accent", selection: .constant(.indigo))
                .frame(width: 104)
        }
    } content: { page in
        ColorPickerDemo(page: page)
    }
}

private struct ColorPickerConfig {
    var color: Color = .indigo
    var title = "Accent Color"
    var supportsOpacity = true
    var hidesLabel = false
    var isDisabled = false
}

private struct ColorPickerDemo: View {
    let page: ComponentPage

    var body: some View {
        DemoPage(
            page: page,
            initial: ColorPickerConfig(),
            usage: """
            @State private var accent = Color.blue

            ColorPicker("Accent Color", selection: $accent)
            """
        ) { $config in
            VStack(spacing: 20) {
                RoundedRectangle(cornerRadius: 16)
                    .fill(config.color)
                    .frame(width: 140, height: 90)
                    .overlay {
                        RoundedRectangle(cornerRadius: 16).strokeBorder(.separator)
                    }

                ColorPicker(config.title, selection: $config.color, supportsOpacity: config.supportsOpacity)
                    .modifier(ColorPickerHidesLabel(isHidden: config.hidesLabel))
                    .disabled(config.isDisabled)
                    .frame(maxWidth: config.hidesLabel ? nil : 300)
            }
        } controls: { $config in
            Section("Content") {
                TextField("Title", text: $config.title)
                Toggle("Supports opacity", isOn: $config.supportsOpacity)
            }
            Section("Appearance") {
                Toggle("Hide label", isOn: $config.hidesLabel)
                Toggle("Disabled", isOn: $config.isDisabled)
            }
        } code: { config in
            var lines = [
                "@State private var color = Color.indigo",
                "",
                "VStack(spacing: 20) {",
                "    RoundedRectangle(cornerRadius: 16)",
                "        .fill(color)",
                "        .frame(width: 140, height: 90)",
                "",
            ]
            lines.append(config.supportsOpacity
                ? "    ColorPicker(\(swiftString(config.title)), selection: $color)"
                : "    ColorPicker(\(swiftString(config.title)), selection: $color, supportsOpacity: false)")
            if config.hidesLabel {
                lines.append("        .labelsHidden()")
            }
            if config.isDisabled {
                lines.append("        .disabled(true)")
            }
            lines.append("}")
            return lines.joined(separator: "\n")
        } examples: {
            ColorPickerExamples()
        }
    }
}

// MARK: - Examples

private struct ColorPickerExamples: View {
    @State private var background = Color.orange
    @State private var textColor = Color.white
    @State private var highlight = Color.yellow
    @Environment(\.self) private var environment

    var body: some View {
        ExampleCard(
            title: "Theme a card",
            caption: "Bind each `ColorPicker` to a `Color` in `@State`, and use it right away for a live preview.",
            code: """
            @State private var background = Color.orange
            @State private var textColor = Color.white

            VStack {
                Text("Hello!")
                    .font(.title.bold())
                    .foregroundStyle(textColor)
                    .frame(maxWidth: .infinity, minHeight: 80)
                    .background(background.gradient, in: .rect(cornerRadius: 16))
                Form {
                    ColorPicker("Background", selection: $background)
                    ColorPicker("Text", selection: $textColor, supportsOpacity: false)
                }
            }
            """,
            minHeight: 300,
            aside: Aside(.note, "The text picker passes `supportsOpacity: false`, since see-through text is rarely what people want.")
        ) {
            VStack(spacing: 12) {
                Text("Hello!")
                    .font(.title.bold())
                    .foregroundStyle(textColor)
                    .frame(maxWidth: .infinity, minHeight: 80)
                    .background(background.gradient, in: .rect(cornerRadius: 16))
                Form {
                    ColorPicker("Background", selection: $background)
                    ColorPicker("Text", selection: $textColor, supportsOpacity: false)
                }
                .scrollDisabled(true)
                .frame(height: 170)
                .scrollContentBackground(.hidden)
            }
            .frame(maxWidth: 380)
        }

        ExampleCard(
            title: "Just the swatch",
            caption: "Use `.labelsHidden()` to show only the round swatch, next to the thing it colors.",
            code: """
            @State private var highlight = Color.yellow

            HStack {
                Text("Highlight")
                    .padding(.horizontal, 6)
                    .background(highlight.opacity(0.5), in: .rect(cornerRadius: 4))
                Spacer()
                ColorPicker("Highlight color", selection: $highlight)
                    .labelsHidden()
            }
            """,
            aside: Aside(.note, "Give it a real label anyway, like “Highlight color”. VoiceOver reads it so people know what the swatch changes.")
        ) {
            HStack {
                Text("Highlight")
                    .padding(.horizontal, 6)
                    .background(highlight.opacity(0.5), in: .rect(cornerRadius: 4))
                Spacer()
                ColorPicker("Highlight color", selection: $highlight)
                    .labelsHidden()
            }
            .frame(maxWidth: 320)
        }

        ExampleCard(
            title: "Read the components",
            caption: "Call `resolve(in:)` to get a color's red, green, and blue values, for example to show a hex code.",
            code: """
            @State private var highlight = Color.yellow
            @Environment(\\.self) private var environment

            let resolved = highlight.resolve(in: environment)
            HStack {
                ColorPicker("Color", selection: $highlight)
                    .labelsHidden()
                Text(String(format: "#%02X%02X%02X",
                            Int(min(max(resolved.red, 0), 1) * 255),
                            Int(min(max(resolved.green, 0), 1) * 255),
                            Int(min(max(resolved.blue, 0), 1) * 255)))
                    .monospaced()
            }
            """,
            aside: Aside(.important, "Picked colors can be wide-gamut, with values below 0 or above 1. Clamp them before converting to hex.")
        ) {
            let resolved = highlight.resolve(in: environment)
            HStack(spacing: 12) {
                ColorPicker("Color", selection: $highlight)
                    .labelsHidden()
                Text(String(format: "#%02X%02X%02X",
                            Int(min(max(resolved.red, 0), 1) * 255),
                            Int(min(max(resolved.green, 0), 1) * 255),
                            Int(min(max(resolved.blue, 0), 1) * 255)))
                    .font(.title3)
                    .monospaced()
            }
        }
    }
}

private struct ColorPickerHidesLabel: ViewModifier {
    let isHidden: Bool

    func body(content: Content) -> some View {
        if isHidden { content.labelsHidden() } else { content }
    }
}
