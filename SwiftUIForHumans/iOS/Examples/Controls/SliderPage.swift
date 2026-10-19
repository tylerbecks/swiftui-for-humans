import SwiftUI

extension ComponentPage {
    static let slider = ComponentPage(
        id: "slider",
        title: "Slider",
        summary: "A control for picking a number from a range by dragging a thumb along a track.",
        category: .controls,
        symbol: "slider.horizontal.below.rectangle",
        availability: ["iOS 13.0+", "macOS 10.15+", "visionOS 1.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/slider",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/sliders",
        aliases: ["range", "input type=range", "range input", "UISlider", "volume", "scrubber", "knob", "seek bar"],
        related: ["stepper", "progress-view", "gauge", "state"],
        notes: [
            "**The value is a `Double`, not an `Int`.** For whole numbers, add `step: 1` and convert with `Int(value)`, or use a [Stepper](catalog://stepper).",
        ],
        api: [
            APIItem("`Slider(value:in:)`", "Binds to a `Double` within a range; `0...1` by default."),
            APIItem("`step:`", "Snaps to steps and draws tick marks."),
            APIItem("`minimumValueLabel:` / `maximumValueLabel:`", "Icons at each end of the track."),
            APIItem("`onEditingChanged:`", "Called with `true` when a drag starts and `false` when it ends."),
            APIItem("`neutralValue:`", "Fills the track from this value, like a center point."),
            APIItem("`.tint(_:)`", "The color of the filled part of the track."),
        ],
        guidelines: [
            Guideline(
                "Show what each end means.",
                "Small icons at the ends, like a small and a large sun, tell people which way is more without reading a label.",
                good: "Icons show which way is brighter.",
                bad: "A bare track leaves people guessing."
            ) {
                Slider(value: .constant(0.6)) {
                    Text("Brightness")
                } minimumValueLabel: {
                    Image(systemName: "sun.min")
                } maximumValueLabel: {
                    Image(systemName: "sun.max.fill")
                }
                .frame(width: 240)
            } bad: {
                Slider(value: .constant(0.6)) {
                    Text("Brightness")
                }
                .frame(width: 240)
            },
            Guideline(
                "Put the minimum on the left.",
                "People expect less on the leading side and more on the trailing side, in every app. Don't flip it.",
                good: "Small on the left, large on the right.",
                bad: "Reversed ends feel backward."
            ) {
                Slider(value: .constant(0.6)) {
                    Text("Text Size")
                } minimumValueLabel: {
                    Image(systemName: "textformat.size.smaller")
                } maximumValueLabel: {
                    Image(systemName: "textformat.size.larger")
                }
                .frame(width: 240)
            } bad: {
                Slider(value: .constant(0.6)) {
                    Text("Text Size")
                } minimumValueLabel: {
                    Image(systemName: "textformat.size.larger")
                } maximumValueLabel: {
                    Image(systemName: "textformat.size.smaller")
                }
                .frame(width: 240)
            },
            Guideline(
                "Show the exact value when it matters.",
                "Dragging is quick but imprecise. Display the number, and add a `Stepper` or `TextField` if people need a specific value."
            ),
            Guideline(
                "Give live feedback as the value changes.",
                "Update the preview while people drag, like text growing as they adjust its size, so they can stop at the right spot."
            ),
        ]
    ) {
        VStack(spacing: 18) {
            Slider(value: .constant(0.65)) {
                Text("Volume")
            } minimumValueLabel: {
                Image(systemName: "speaker.fill")
            } maximumValueLabel: {
                Image(systemName: "speaker.wave.3.fill")
            }
            Slider(value: .constant(0.3))
                .tint(.orange)
        }
        .foregroundStyle(.secondary)
        .frame(width: 200)
    } content: { page in
        SliderDemo(page: page)
    }
}

private struct SliderConfig {
    var value = 50.0
    var range: SliderRangeOption = .hundred
    var step: SliderStepOption = .none
    var showsEndLabels = false
    var tint: SliderTintOption = .automatic
    var isDisabled = false
    var isEditing = false
}

private struct SliderDemo: View {
    let page: ComponentPage

    var body: some View {
        DemoPage(
            page: page,
            initial: SliderConfig(),
            usage: """
            @State private var opacity = 0.8

            Slider(value: $opacity, in: 0...1) {
                Text("Opacity")
            }
            """,
            usageNote: Aside(.note, "Without `step:`, the value is continuous, so expect numbers like `0.7342`. Add `step: 0.1` or `step: 1` to snap to round values.")
        ) { $config in
            VStack(spacing: 20) {
                ConfiguredSlider(config: $config)
                .tint(config.tint.color)
                .disabled(config.isDisabled)
                .frame(maxWidth: 380)

                HStack(spacing: 6) {
                    Text("value = \(config.value.formatted(.number.precision(.fractionLength(0...2)).grouping(.never)))")
                        .monospacedDigit()
                    if config.isEditing {
                        Text("editing")
                            .foregroundStyle(.tint)
                    }
                }
                .font(.footnote.monospaced())
                .foregroundStyle(.secondary)
            }
        } controls: { $config in
            Section("Value") {
                OptionPicker("Range", selection: Binding(
                    get: { config.range },
                    set: { new in
                        config.range = new
                        config.value = new.range.lowerBound + (new.range.upperBound - new.range.lowerBound) / 2
                    }
                ))
                OptionPicker("Step", selection: Binding(
                    get: { config.step },
                    set: { new in
                        config.step = new
                        // Snap to the new step, like a drag would.
                        if let step = new.value {
                            let low = config.range.range.lowerBound
                            config.value = low + ((config.value - low) / step).rounded() * step
                        }
                    }
                ))
            }
            Section("Appearance") {
                Toggle("End labels", isOn: $config.showsEndLabels)
                OptionPicker("Tint", selection: $config.tint)
                Toggle("Disabled", isOn: $config.isDisabled)
            }
        } code: { config in
            sliderCode(config)
        } examples: {
            SliderExamples()
        }
    }
}

/// `step:` can't be "none", so build the slider with or without it.
private struct ConfiguredSlider: View {
    @Binding var config: SliderConfig

    var body: some View {
        let editing: (Bool) -> Void = { config.isEditing = $0 }
        switch (config.step.value, config.showsEndLabels) {
        case (let step?, true):
            Slider(value: $config.value, in: config.range.range, step: step) {
                Text("Volume")
            } minimumValueLabel: {
                Image(systemName: "speaker.fill")
            } maximumValueLabel: {
                Image(systemName: "speaker.wave.3.fill")
            } onEditingChanged: { editing($0) }
        case (let step?, false):
            Slider(value: $config.value, in: config.range.range, step: step) {
                Text("Volume")
            } onEditingChanged: { editing($0) }
        case (nil, true):
            Slider(value: $config.value, in: config.range.range) {
                Text("Volume")
            } minimumValueLabel: {
                Image(systemName: "speaker.fill")
            } maximumValueLabel: {
                Image(systemName: "speaker.wave.3.fill")
            } onEditingChanged: { editing($0) }
        case (nil, false):
            Slider(value: $config.value, in: config.range.range) {
                Text("Volume")
            } onEditingChanged: { editing($0) }
        }
    }
}

private func sliderCode(_ config: SliderConfig) -> String {
    var lines = ["@State private var volume = \(doubleLiteral(config.value.rounded(toPlaces: 2)))", ""]
    var args = "value: $volume"
    // `step:` is only accepted together with `in:`.
    if config.range != .one || config.step.value != nil {
        args += ", in: \(config.range.label)"
    }
    if let step = config.step.value {
        args += ", step: \(swiftNumber(step))"
    }
    if config.showsEndLabels {
        lines += [
            "Slider(\(args)) {",
            "    Text(\"Volume\")",
            "} minimumValueLabel: {",
            "    Image(systemName: \"speaker.fill\")",
            "} maximumValueLabel: {",
            "    Image(systemName: \"speaker.wave.3.fill\")",
            "}",
        ]
    } else {
        lines += ["Slider(\(args)) {", "    Text(\"Volume\")", "}"]
    }
    if config.tint != .automatic {
        lines.append("    .tint(\(config.tint.label))")
    }
    if config.isDisabled {
        lines.append("    .disabled(true)")
    }
    return lines.joined(separator: "\n")
}

private extension Double {
    func rounded(toPlaces places: Int) -> Double {
        let factor = pow(10, Double(places))
        return (self * factor).rounded() / factor
    }
}

// MARK: - Examples

private struct SliderExamples: View {
    @State private var brightness = 0.7
    @State private var fontSize = 17.0
    @State private var price = 40.0
    @State private var committed = 40.0
    @State private var speed = 1.0
    @State private var exposure = 0.0

    var body: some View {
        ExampleCard(
            title: "With a title and value",
            caption: "Put a title and the current value in an `HStack` above the slider, like a row in Settings.",
            code: """
            @State private var fontSize = 17.0

            VStack(alignment: .leading) {
                HStack {
                    Text("Text Size")
                    Spacer()
                    Text("\\(Int(fontSize)) pt")
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                }
                Slider(value: $fontSize, in: 12...32, step: 1) {
                    Text("Text Size")
                }
                Text("The quick brown fox")
                    .font(.system(size: fontSize))
                    .frame(height: 44, alignment: .leading)
            }
            """,
            minHeight: 200,
            aside: Aside(.important, "On iOS, the slider's own label isn't drawn. VoiceOver reads it, but you need to show a visible title yourself.")
        ) {
            VStack(alignment: .leading) {
                HStack {
                    Text("Text Size")
                    Spacer()
                    Text("\(Int(fontSize)) pt")
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                }
                Slider(value: $fontSize, in: 12...32, step: 1) {
                    Text("Text Size")
                }
                Text("The quick brown fox")
                    .font(.system(size: fontSize))
                    .frame(height: 44, alignment: .leading)
            }
            .frame(maxWidth: 380)
        }

        ExampleCard(
            title: "Brightness with icons",
            caption: "Use `minimumValueLabel:` and `maximumValueLabel:` for icons that show what each end means.",
            code: """
            @State private var brightness = 0.7

            Slider(value: $brightness) {
                Text("Brightness")
            } minimumValueLabel: {
                Image(systemName: "sun.min")
            } maximumValueLabel: {
                Image(systemName: "sun.max.fill")
            }
            .tint(.yellow)

            RoundedRectangle(cornerRadius: 12)
                .fill(.yellow.opacity(brightness))
                .frame(height: 60)
            """
        ) {
            VStack(spacing: 16) {
                Slider(value: $brightness) {
                    Text("Brightness")
                } minimumValueLabel: {
                    Image(systemName: "sun.min")
                } maximumValueLabel: {
                    Image(systemName: "sun.max.fill")
                }
                .tint(.yellow)

                RoundedRectangle(cornerRadius: 12)
                    .fill(.yellow.opacity(brightness))
                    .frame(height: 60)
            }
            .frame(maxWidth: 380)
        }

        ExampleCard(
            title: "Act when the drag ends",
            caption: "Use `onEditingChanged:` to run expensive work, like a search, once when the finger lifts.",
            code: """
            @State private var price = 40.0
            @State private var committed = 40.0

            VStack {
                Text("Max price: $\\(Int(price))")
                Slider(value: $price, in: 0...100, step: 5) {
                    Text("Max price")
                } onEditingChanged: { isEditing in
                    if !isEditing {
                        committed = price // e.g. run the search here
                    }
                }
                Text("Searching under $\\(Int(committed))")
                    .foregroundStyle(.secondary)
            }
            """,
            aside: Aside(.note, "The binding still updates on every frame, so the label above stays live while the search waits.")
        ) {
            VStack(spacing: 10) {
                Text("Max price: $\(Int(price))")
                    .monospacedDigit()
                Slider(value: $price, in: 0...100, step: 5) {
                    Text("Max price")
                } onEditingChanged: { isEditing in
                    if !isEditing {
                        committed = price
                    }
                }
                Text("Searching under $\(Int(committed))")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }
            .frame(maxWidth: 380)
        }

        ExampleCard(
            title: "Tick marks",
            caption: "Since iOS 26, a slider with `step:` draws a tick at every step, so people see where it snaps.",
            code: """
            @State private var speed = 1.0

            VStack {
                Text("Playback speed: \\(speed.formatted())×")
                Slider(value: $speed, in: 0.5...2, step: 0.25) {
                    Text("Playback speed")
                }
            }
            """,
            aside: Aside(.note, "Keep the number of steps small. Dozens of ticks blur into a solid line.")
        ) {
            VStack(spacing: 10) {
                Text("Playback speed: \(speed.formatted())×")
                    .monospacedDigit()
                Slider(value: $speed, in: 0.5...2, step: 0.25) {
                    Text("Playback speed")
                }
            }
            .frame(maxWidth: 380)
        }

        ExampleCard(
            title: "Fill from the middle",
            caption: "Use `neutralValue:` (iOS 26) to fill the track from a center value, for adjustments that go either way.",
            code: """
            @State private var exposure = 0.0

            VStack {
                Text("Exposure: \\(exposure.formatted(.number.precision(.fractionLength(1))))")
                Slider(value: $exposure, in: -2...2, neutralValue: 0) {
                    Text("Exposure")
                }
            }
            """
        ) {
            VStack(spacing: 10) {
                Text("Exposure: \(exposure.formatted(.number.precision(.fractionLength(1))))")
                    .monospacedDigit()
                Slider(value: $exposure, in: -2...2, neutralValue: 0) {
                    Text("Exposure")
                }
            }
            .frame(maxWidth: 380)
        }
    }
}

// MARK: - Options

private enum SliderRangeOption: DemoOption {
    case one, hundred, temperature

    var label: String {
        switch self {
        case .one: "0...1"
        case .hundred: "0...100"
        case .temperature: "-10...40"
        }
    }

    var range: ClosedRange<Double> {
        switch self {
        case .one: 0...1
        case .hundred: 0...100
        case .temperature: -10...40
        }
    }
}

private enum SliderStepOption: DemoOption {
    case none, tenth, one, ten

    var label: String {
        switch self {
        case .none: "None (continuous)"
        case .tenth: "0.1"
        case .one: "1"
        case .ten: "10"
        }
    }

    var value: Double? {
        switch self {
        case .none: nil
        case .tenth: 0.1
        case .one: 1
        case .ten: 10
        }
    }
}

private enum SliderTintOption: DemoOption {
    case automatic, orange, green, pink

    var label: String {
        switch self {
        case .automatic: "Default"
        case .orange: ".orange"
        case .green: ".green"
        case .pink: ".pink"
        }
    }

    var color: Color? {
        switch self {
        case .automatic: nil
        case .orange: .orange
        case .green: .green
        case .pink: .pink
        }
    }
}

/// A number literal that Swift infers as `Double` ("50.0", not "50").
private func doubleLiteral(_ value: Double) -> String {
    let text = swiftNumber(value)
    return text.contains(".") ? text : text + ".0"
}
