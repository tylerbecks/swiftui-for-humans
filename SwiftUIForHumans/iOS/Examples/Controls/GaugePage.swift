import SwiftUI

extension ComponentPage {
    static let gauge = ComponentPage(
        id: "gauge",
        title: "Gauge",
        summary: "Shows where a value sits within a range, like a battery level or a speedometer.",
        category: .controls,
        symbol: "gauge.with.dots.needle.50percent",
        availability: ["iOS 16.0+", "macOS 13.0+", "watchOS 7.0+", "visionOS 1.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/gauge",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/gauges",
        aliases: ["meter", "<meter>", "ring", "progress ring", "dial", "speedometer", "battery", "level indicator", "donut"],
        related: ["progress-view", "slider", "charts"],
        api: [
            APIItem("`Gauge(value:in:label:)`", "Shows a value in a range; `0...1` by default."),
            APIItem("`currentValueLabel:`", "The value as text, often in the middle of a ring."),
            APIItem("`minimumValueLabel:` / `maximumValueLabel:`", "Labels for the two ends."),
            APIItem("`.gaugeStyle(_:)`", "A bar, a ring, or a widget-style look."),
            APIItem("`.tint(_:)`", "A color, or a `Gradient` across the range."),
        ],
        guidelines: [
            Guideline(
                "Label the value and both ends.",
                "Short labels tell people what the range means, and VoiceOver reads them for people who can't see the gauge.",
                good: "The value and the range are clear.",
                bad: "A bare ring with no scale."
            ) {
                Gauge(value: 21, in: 0...40) {
                    Text("°C")
                } currentValueLabel: {
                    Text("21")
                } minimumValueLabel: {
                    Text("0")
                } maximumValueLabel: {
                    Text("40")
                }
                .gaugeStyle(.accessoryCircular)
                .scaleEffect(1.4)
            } bad: {
                Gauge(value: 21, in: 0...40) {
                    Text("°C")
                }
                .gaugeStyle(.accessoryCircular)
                .scaleEffect(1.4)
            },
            Guideline(
                "Use a gradient when the color carries meaning.",
                "Blue to red for cold to hot, or green to purple for air quality, tells people whether a value is good before they read it.",
                good: "The color shows the value is good.",
                bad: "One color says nothing about the scale."
            ) {
                Gauge(value: 42, in: 0...200) {
                    Text("AQI")
                } currentValueLabel: {
                    Text("42")
                }
                .gaugeStyle(.accessoryLinear)
                .tint(Gradient(colors: [.green, .yellow, .orange, .red, .purple]))
                .frame(width: 220)
            } bad: {
                Gauge(value: 42, in: 0...200) {
                    Text("AQI")
                } currentValueLabel: {
                    Text("42")
                }
                .gaugeStyle(.accessoryLinear)
                .tint(.blue)
                .frame(width: 220)
            },
            Guideline(
                "Use a gauge to show a value, not to set one.",
                "People can't drag a gauge. When they should change the value, use a [Slider](catalog://slider)."
            ),
        ]
    ) {
        HStack(spacing: 24) {
            Gauge(value: 0.72) {
                Image(systemName: "bolt.fill")
            } currentValueLabel: {
                Text("72")
            }
            .gaugeStyle(.accessoryCircularCapacity)
            .tint(.green)
            .scaleEffect(1.3)

            Gauge(value: 21, in: 0...40) {
                Text("°C")
            } currentValueLabel: {
                Text("21")
            } minimumValueLabel: {
                Text("0")
            } maximumValueLabel: {
                Text("40")
            }
            .gaugeStyle(.accessoryCircular)
            .tint(Gradient(colors: [.blue, .green, .orange]))
            .scaleEffect(1.3)
        }
    } content: { page in
        GaugeDemo(page: page)
    }
}

private struct GaugeConfig {
    var value = 62.0
    var style: GaugeStyleOption = .accessoryCircular
    var showsCurrentValue = true
    var showsMinMax = true
    var tint: GaugeTintOption = .gradient
}

private struct GaugeDemo: View {
    let page: ComponentPage

    var body: some View {
        DemoPage(
            page: page,
            initial: GaugeConfig(),
            previewHeight: 220,
            usage: """
            Gauge(value: 21, in: 0...40) {
                Text("Temperature")
            } currentValueLabel: {
                Text("21°")
            }
            .gaugeStyle(.accessoryCircular)
            """,
            usageNote: Aside(.note, "The `accessory` styles are sized for widgets and the Lock Screen. On an app screen, keep them next to text or enlarge them with `.scaleEffect(_:)`.")
        ) { $config in
            VStack(spacing: 20) {
                gauge(config)
                    .styled(config.style)
                    .modifier(GaugeTint(option: config.tint))
                    .scaleEffect(config.style.isCircular ? 1.6 : 1)
                    .frame(maxWidth: config.style.isCircular ? nil : 340)
                    .frame(height: config.style.isCircular ? 110 : nil)
                    .animation(.default, value: config.value)

                Text("value = \(Int(config.value)) in 0...100")
                    .font(.footnote.monospaced())
                    .foregroundStyle(.secondary)
            }
        } controls: { $config in
            Section("Value") {
                ValueSlider("Value", value: $config.value, in: 0...100, step: 1)
            }
            Section("Appearance") {
                OptionPicker("Style", selection: $config.style)
                OptionPicker("Tint", selection: $config.tint)
                Toggle("Current value label", isOn: $config.showsCurrentValue)
                Toggle("Min and max labels", isOn: $config.showsMinMax)
            }
        } code: { config in
            gaugeCode(config)
        } examples: {
            GaugeExamples()
        }
    }

    @ViewBuilder
    private func gauge(_ config: GaugeConfig) -> some View {
        switch (config.showsCurrentValue, config.showsMinMax) {
        case (true, true):
            Gauge(value: config.value, in: 0...100) {
                Text("Speed")
            } currentValueLabel: {
                Text("\(Int(config.value))")
            } minimumValueLabel: {
                Text("0")
            } maximumValueLabel: {
                Text("100")
            }
        case (true, false):
            Gauge(value: config.value, in: 0...100) {
                Text("Speed")
            } currentValueLabel: {
                Text("\(Int(config.value))")
            }
        case (false, true):
            Gauge(value: config.value, in: 0...100) {
                Text("Speed")
            } currentValueLabel: {
                EmptyView()
            } minimumValueLabel: {
                Text("0")
            } maximumValueLabel: {
                Text("100")
            }
        case (false, false):
            Gauge(value: config.value, in: 0...100) {
                Text("Speed")
            }
        }
    }
}

private func gaugeCode(_ config: GaugeConfig) -> String {
    var lines = [
        "@State private var speed = \(Int(config.value)).0",
        "",
        "Gauge(value: speed, in: 0...100) {",
        "    Text(\"Speed\")",
    ]
    if config.showsCurrentValue {
        lines += ["} currentValueLabel: {", "    Text(\"\\(Int(speed))\")"]
    } else if config.showsMinMax {
        lines += ["} currentValueLabel: {", "    EmptyView()"]
    }
    if config.showsMinMax {
        lines += ["} minimumValueLabel: {", "    Text(\"0\")", "} maximumValueLabel: {", "    Text(\"100\")"]
    }
    lines.append("}")
    if config.style != .automatic {
        lines.append("    .gaugeStyle(\(config.style.label))")
    }
    if config.tint != .automatic {
        lines.append("    .tint(\(config.tint.code))")
    }
    if config.style.isCircular {
        lines.append("    .scaleEffect(1.6) // accessory styles are widget-sized")
    }
    return lines.joined(separator: "\n")
}

// MARK: - Examples

private struct GaugeExamples: View {
    @State private var battery = 0.8
    @State private var storage = 182.0

    var body: some View {
        ExampleCard(
            title: "Battery ring",
            caption: "Use the `.accessoryCircularCapacity` style for a ring that fills, with the value in the middle.",
            code: """
            @State private var battery = 0.8

            VStack(spacing: 20) {
                Gauge(value: battery) {
                    Image(systemName: "iphone")
                } currentValueLabel: {
                    Text(battery.formatted(.percent.precision(.fractionLength(0))))
                }
                .gaugeStyle(.accessoryCircularCapacity)
                .tint(battery < 0.2 ? .red : .green)
                .scaleEffect(1.4)

                Slider(value: $battery)
            }
            """,
            aside: Aside(.note, "This is the filling ring people often expect from `ProgressView`. On iOS, a circular `ProgressView` only spins.")
        ) {
            VStack(spacing: 20) {
                Gauge(value: battery) {
                    Image(systemName: "iphone")
                } currentValueLabel: {
                    Text(battery.formatted(.percent.precision(.fractionLength(0))))
                }
                .gaugeStyle(.accessoryCircularCapacity)
                .tint(battery < 0.2 ? .red : .green)
                .scaleEffect(1.4)
                .frame(height: 80)

                Slider(value: $battery)
                    .frame(maxWidth: 240)
            }
        }

        ExampleCard(
            title: "Storage bar",
            caption: "Use `.gaugeStyle(.linearCapacity)` for a labeled bar that shows usage, like storage or a data plan.",
            code: """
            @State private var storage = 182.0

            Gauge(value: storage, in: 0...256) {
                Text("iPhone Storage")
            } currentValueLabel: {
                Text("\\(Int(storage)) GB of 256 GB used")
            }
            .gaugeStyle(.linearCapacity)
            .tint(.orange)
            """
        ) {
            Gauge(value: storage, in: 0...256) {
                Text("iPhone Storage")
            } currentValueLabel: {
                Text("\(Int(storage)) GB of 256 GB used")
            }
            .gaugeStyle(.linearCapacity)
            .tint(.orange)
            .frame(maxWidth: 360)
        }

        ExampleCard(
            title: "Air quality scale",
            caption: "Use `.accessoryLinear` with a `Gradient` tint, so the marker's color shows whether a value is good.",
            code: """
            Gauge(value: 42, in: 0...200) {
                Text("AQI")
            } currentValueLabel: {
                Text("42")
            } minimumValueLabel: {
                Text("Good")
            } maximumValueLabel: {
                Text("Poor")
            }
            .gaugeStyle(.accessoryLinear)
            .tint(Gradient(colors: [.green, .yellow, .orange, .red, .purple]))
            """
        ) {
            Gauge(value: 42, in: 0...200) {
                Text("AQI")
            } currentValueLabel: {
                Text("42")
            } minimumValueLabel: {
                Text("Good")
            } maximumValueLabel: {
                Text("Poor")
            }
            .gaugeStyle(.accessoryLinear)
            .tint(Gradient(colors: [.green, .yellow, .orange, .red, .purple]))
            .frame(maxWidth: 300)
        }
    }
}

// MARK: - Options

private enum GaugeStyleOption: DemoOption {
    case automatic, linearCapacity, accessoryLinear, accessoryLinearCapacity, accessoryCircular, accessoryCircularCapacity

    var label: String {
        switch self {
        case .automatic: ".automatic"
        case .linearCapacity: ".linearCapacity"
        case .accessoryLinear: ".accessoryLinear"
        case .accessoryLinearCapacity: ".accessoryLinearCapacity"
        case .accessoryCircular: ".accessoryCircular"
        case .accessoryCircularCapacity: ".accessoryCircularCapacity"
        }
    }

    var isCircular: Bool {
        self == .accessoryCircular || self == .accessoryCircularCapacity
    }
}

private enum GaugeTintOption: DemoOption {
    case automatic, green, orange, gradient

    var label: String {
        switch self {
        case .automatic: "Default"
        case .green: ".green"
        case .orange: ".orange"
        case .gradient: "Gradient"
        }
    }

    var code: String {
        switch self {
        case .automatic: ""
        case .green: ".green"
        case .orange: ".orange"
        case .gradient: "Gradient(colors: [.green, .yellow, .red])"
        }
    }
}

private struct GaugeTint: ViewModifier {
    let option: GaugeTintOption

    func body(content: Content) -> some View {
        switch option {
        case .automatic: content
        case .green: content.tint(.green)
        case .orange: content.tint(.orange)
        case .gradient: content.tint(Gradient(colors: [.green, .yellow, .red]))
        }
    }
}

private extension View {
    @ViewBuilder
    func styled(_ style: GaugeStyleOption) -> some View {
        switch style {
        case .automatic: gaugeStyle(.automatic)
        case .linearCapacity: gaugeStyle(.linearCapacity)
        case .accessoryLinear: gaugeStyle(.accessoryLinear)
        case .accessoryLinearCapacity: gaugeStyle(.accessoryLinearCapacity)
        case .accessoryCircular: gaugeStyle(.accessoryCircular)
        case .accessoryCircularCapacity: gaugeStyle(.accessoryCircularCapacity)
        }
    }
}
