import SwiftUI

extension ComponentPage {
    static let slider = ComponentPage(
        id: "slider",
        title: "Slider",
        summary: "A track with a thumb for picking a value between a minimum and a maximum.",
        category: .controls,
        symbol: "slider.horizontal.below.rectangle",
        availability: ["macOS 10.15+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/slider",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/sliders",
        aliases: ["range", "input type=range", "NSSlider", "tick marks", "volume", "scrubber", "SliderTick", "onEditingChanged"],
        related: ["stepper", "gauge-progress", "form", "labeled-content", "text-field"],
        notes: [
            "**A `step` adds tick marks.** On the Mac, a slider with a step draws a tick at each one, and the value moves in whole steps.",
            "**The value is a floating-point number.** Bind a `Double` (or another `BinaryFloatingPoint`); round it yourself if you store an integer.",
            "**`step` also sets how far VoiceOver moves it.** When people adjust the slider with VoiceOver, it changes by one step.",
        ],
        api: [
            APIItem("`Slider(value:in:)`", "A slider over a closed range."),
            APIItem("`Slider(value:in:step:)`", "Moves in steps, with a tick at each."),
            APIItem("`minimumValueLabel:`", "A view at the leading end."),
            APIItem("`maximumValueLabel:`", "A view at the trailing end."),
            APIItem("`onEditingChanged:`", "Called when a drag starts and ends."),
            APIItem("`ticks: { SliderTick(…) }`", "Ticks at values you choose (macOS 26)."),
            APIItem("`.controlSize(_:)`", "Smaller sliders for inspectors."),
        ],
        guidelines: [
            Guideline(
                "Put the minimum on the leading side.",
                "People expect a horizontal slider to grow from leading to trailing, like 0% to 100%. Reversing it makes every adjustment feel backward."
            ),
            Guideline(
                "Show the result while people drag.",
                "Update what the slider controls as the value changes, the way the Dock grows while you drag its Size slider. Save heavy work for when the drag ends."
            ),
            Guideline(
                "Use tick marks when exact values matter, and label only what helps.",
                "Ticks show the scale and make specific values easy to hit. Labeling the minimum and maximum is often enough.",
                good: "Labels at the ends are enough to read the scale.",
                bad: "A label on every tick adds clutter, not meaning."
            ) {
                MacTickSlider(labelsEveryTick: false)
            } bad: {
                MacTickSlider(labelsEveryTick: true)
            },
            Guideline(
                "Offer a text field when people need a precise value.",
                "For a wide range, pair the slider with a field, and maybe a [Stepper](catalog://stepper), so people can type the exact number."
            ),
        ]
    ) {
        VStack(spacing: 14) {
            Slider(value: .constant(0.6)) {
                Text("Volume")
            } minimumValueLabel: {
                Image(systemName: "speaker.fill")
            } maximumValueLabel: {
                Image(systemName: "speaker.wave.3.fill")
            }
            .labelsHidden()
            Slider(value: .constant(0.3), in: 0...1, step: 0.25)
                .labelsHidden()
        }
        .frame(width: 190)
    } content: { page in
        MacSliderDemo(page: page)
    }
}

private struct MacSliderConfig {
    var value = 50.0
    var step: MacSliderStepOption = .ten
    var showsValueLabels = true
    var hidesLabel = false
    var size: MacSliderSizeOption = .regular
    var isDisabled = false
}

private struct MacSliderDemo: View {
    let page: ComponentPage
    @State private var isEditing = false

    var body: some View {
        DemoPage(
            page: page,
            initial: MacSliderConfig(),
            usage: """
            @State private var volume = 50.0

            Slider(value: $volume, in: 0...100) {
                Text("Volume")
            }
            """,
            usageNote: Aside(.note, "Like `<input type=range>` with a bound value: the slider reads `volume` and writes it back as people drag.")
        ) { $config in
            VStack(spacing: 16) {
                MacDemoSlider(config: $config, isEditing: $isEditing)
                    .frame(maxWidth: 320)
                Text("value = \(swiftNumber(config.value))\(isEditing ? " (dragging)" : "")")
                    .font(.footnote.monospaced())
                    .foregroundStyle(.secondary)
            }
        } controls: { $config in
            Section("Content") {
                OptionPicker("Step", selection: $config.step)
                Toggle("Min and max labels", isOn: $config.showsValueLabels)
            }
            Section("Appearance") {
                OptionPicker("Size", selection: $config.size)
                Toggle("Hide label", isOn: $config.hidesLabel)
                Toggle("Disabled", isOn: $config.isDisabled)
            }
        } code: { config in
            var lines = ["@State private var volume = \(swiftNumber(config.value))", ""]
            var head = "Slider(value: $volume, in: 0...100"
            if let step = config.step.value {
                head += ", step: \(swiftNumber(step))"
            }
            head += ") {"
            lines.append(head)
            lines.append("    Text(\"Volume\")")
            if config.showsValueLabels {
                lines.append("} minimumValueLabel: {")
                lines.append("    Text(\"0\")")
                lines.append("} maximumValueLabel: {")
                lines.append("    Text(\"100\")")
            }
            lines.append("}")
            if config.size != .regular {
                lines.append(".controlSize(\(config.size.label))")
            }
            if config.hidesLabel {
                lines.append(".labelsHidden()")
            }
            if config.isDisabled {
                lines.append(".disabled(true)")
            }
            return lines.joined(separator: "\n")
        } examples: {
            MacSliderExamples()
        }
    }
}

/// The demo's slider, built from the current options.
private struct MacDemoSlider: View {
    @Binding var config: MacSliderConfig
    @Binding var isEditing: Bool

    var body: some View {
        slider
            .controlSize(config.size.size)
            .modifier(MacSliderHidesLabel(isHidden: config.hidesLabel))
            .disabled(config.isDisabled)
    }

    @ViewBuilder private var slider: some View {
        switch (config.step.value, config.showsValueLabels) {
        case (let step?, true):
            Slider(value: $config.value, in: 0...100, step: step) {
                Text("Volume")
            } minimumValueLabel: {
                Text("0")
            } maximumValueLabel: {
                Text("100")
            } onEditingChanged: { isEditing = $0 }
        case (let step?, false):
            Slider(value: $config.value, in: 0...100, step: step) {
                Text("Volume")
            } onEditingChanged: { isEditing = $0 }
        case (nil, true):
            Slider(value: $config.value, in: 0...100) {
                Text("Volume")
            } minimumValueLabel: {
                Text("0")
            } maximumValueLabel: {
                Text("100")
            } onEditingChanged: { isEditing = $0 }
        case (nil, false):
            Slider(value: $config.value, in: 0...100) {
                Text("Volume")
            } onEditingChanged: { isEditing = $0 }
        }
    }
}

// MARK: - Examples

private struct MacSliderExamples: View {
    @State private var iconSize = 48.0
    @State private var quality = 0.75
    @State private var brightness = 0.5
    @State private var savedBrightness = 0.5
    @State private var opacity = 80.0

    var body: some View {
        ExampleCard(
            title: "Symbols at each end",
            caption: "`minimumValueLabel` and `maximumValueLabel` show what the ends mean, like a small and a large photo for icon size.",
            code: """
            @State private var iconSize = 48.0

            Slider(value: $iconSize, in: 16...128) {
                Text("Icon size")
            } minimumValueLabel: {
                Image(systemName: "photo")
                    .imageScale(.small)
            } maximumValueLabel: {
                Image(systemName: "photo")
                    .imageScale(.large)
            }
            """,
            minHeight: 150
        ) {
            VStack(spacing: 14) {
                Slider(value: $iconSize, in: 16...128) {
                    Text("Icon size")
                } minimumValueLabel: {
                    Image(systemName: "photo")
                        .imageScale(.small)
                } maximumValueLabel: {
                    Image(systemName: "photo")
                        .imageScale(.large)
                }
                .frame(maxWidth: 340)
                Image(systemName: "folder.fill")
                    .font(.system(size: iconSize * 0.5))
                    .foregroundStyle(.tint)
                    .frame(height: 64)
            }
        }

        ExampleCard(
            title: "Tick marks with labels",
            caption: "In macOS 26, pass `ticks:` to place a `SliderTick` at each value that matters, labeling only the ones that help, like the ends.",
            code: """
            @State private var quality = 0.75

            Slider(value: $quality) {
                Text("Quality")
            } ticks: {
                SliderTick(0.0) { Text("Small file") }
                SliderTick(0.25)
                SliderTick(0.5)
                SliderTick(0.75)
                SliderTick(1.0) { Text("Best") }
            }
            """,
            minHeight: 140
        ) {
            Slider(value: $quality) {
                Text("Quality")
            } ticks: {
                SliderTick(0.0) { Text("Small file") }
                SliderTick(0.25)
                SliderTick(0.5)
                SliderTick(0.75)
                SliderTick(1.0) { Text("Best") }
            }
            .frame(maxWidth: 340)
        }

        ExampleCard(
            title: "Live preview, save at the end",
            caption: "Update the preview on every change, and use `onEditingChanged` to save once, when the drag ends.",
            code: """
            @State private var brightness = 0.5
            @State private var savedBrightness = 0.5

            Slider(value: $brightness) {
                Text("Brightness")
            } onEditingChanged: { isEditing in
                if !isEditing {
                    savedBrightness = brightness
                }
            }
            """,
            minHeight: 170
        ) {
            VStack(spacing: 14) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(white: 0.15 + brightness * 0.8))
                    .frame(width: 160, height: 56)
                    .overlay {
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(.separator)
                    }
                Slider(value: $brightness) {
                    Text("Brightness")
                } onEditingChanged: { isEditing in
                    if !isEditing {
                        savedBrightness = brightness
                    }
                }
                .frame(maxWidth: 340)
                Text("Saved: \(Int(savedBrightness * 100))%")
                    .font(.footnote.monospacedDigit())
                    .foregroundStyle(.secondary)
            }
        }

        ExampleCard(
            title: "With a field and a stepper",
            caption: "For a precise value, put a `TextField` and a `Stepper` beside the slider, all three sharing one binding.",
            code: """
            @State private var opacity = 80.0

            LabeledContent("Opacity") {
                HStack {
                    Slider(value: $opacity, in: 0...100)
                    TextField("Opacity", value: $opacity, format: .number.precision(.fractionLength(0)))
                        .frame(width: 44)
                    Stepper("Opacity", value: $opacity, in: 0...100)
                }
                .labelsHidden()
            }
            """,
            minHeight: 120
        ) {
            LabeledContent("Opacity") {
                HStack {
                    Slider(value: $opacity, in: 0...100)
                    TextField("Opacity", value: $opacity, format: .number.precision(.fractionLength(0)))
                        .frame(width: 44)
                    Stepper("Opacity", value: $opacity, in: 0...100)
                }
                .labelsHidden()
            }
            .frame(maxWidth: 380)
        }
    }
}

/// A five-tick slider for the tick label guideline.
private struct MacTickSlider: View {
    let labelsEveryTick: Bool
    @State private var value = 50.0

    var body: some View {
        Slider(value: $value, in: 0...100) {
            Text("Zoom")
        } ticks: {
            SliderTickContentForEach(stride(from: 0.0, through: 100.0, by: 10.0).map { $0 }, id: \.self) { tick in
                if labelsEveryTick || tick == 0 || tick == 100 {
                    SliderTick(tick) { Text("\(Int(tick))") }
                } else {
                    SliderTick(tick)
                }
            }
        }
        .labelsHidden()
        .frame(width: 220)
    }
}

// MARK: - Options

private enum MacSliderStepOption: DemoOption {
    case none, ten, twentyFive

    var label: String {
        switch self {
        case .none: "None"
        case .ten: "10"
        case .twentyFive: "25"
        }
    }

    var value: Double? {
        switch self {
        case .none: nil
        case .ten: 10
        case .twentyFive: 25
        }
    }
}

private enum MacSliderSizeOption: DemoOption {
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

private struct MacSliderHidesLabel: ViewModifier {
    let isHidden: Bool

    func body(content: Content) -> some View {
        if isHidden {
            content.labelsHidden()
        } else {
            content
        }
    }
}
