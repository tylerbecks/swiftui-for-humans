import SwiftUI

extension ComponentPage {
    static let gaugeProgress = ComponentPage(
        id: "gauge-progress",
        title: "Gauge & ProgressView",
        summary: "Progress bars and spinners for work under way, and gauges for a level in a range.",
        category: .controls,
        symbol: "gauge.with.dots.needle.33percent",
        availability: ["macOS 11.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/progressview",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/progress-indicators",
        aliases: ["progress bar", "spinner", "activity indicator", "loading", "NSProgressIndicator", "<progress>", "<meter>", "level indicator", "NSLevelIndicator", "capacity", "meter", "Gauge", "ProgressView", "determinate", "indeterminate"],
        related: ["slider", "labeled-content", "toolbar", "button"],
        notes: [
            "**A value makes it determinate.** `ProgressView(value:)` fills a bar; `ProgressView()` with no value animates without an end.",
            "**Gauge is for a level, not a task.** Use it for things like storage or battery that sit somewhere in a range, and `ProgressView` for work that finishes.",
            "**Progress over a time span updates itself.** `ProgressView(timerInterval:)` fills as the clock moves through a date range.",
        ],
        api: [
            APIItem("`ProgressView()`", "Indeterminate: a spinner by default."),
            APIItem("`ProgressView(value:total:)`", "Determinate: a bar that fills."),
            APIItem("`.progressViewStyle(.linear)`", "A bar, even when indeterminate."),
            APIItem("`.progressViewStyle(.circular)`", "A spinner or a filling circle."),
            APIItem("`Gauge(value:in:label:)`", "A value within a range."),
            APIItem("`.gaugeStyle(.linearCapacity)`", "A bar filled up to the value."),
            APIItem("`.gaugeStyle(.accessoryCircular)`", "A small ring with a marker."),
            APIItem("`.controlSize(.small)`", "A smaller spinner for tight spots."),
        ],
        guidelines: [
            Guideline(
                "Show how far along it is whenever you can.",
                "A determinate bar lets people decide whether to wait or come back later. Switch an indeterminate bar to a determinate one as soon as you know the total."
            ),
            Guideline(
                "Keep it moving, and keep it honest.",
                "A stalled indicator looks like a frozen app. Advance at an even pace instead of racing to 90% and crawling through the rest."
            ),
            Guideline(
                "Don't label a spinner.",
                "A spinner usually appears right after people start something, so they know what it's for. It's small enough for a background task or a spot next to a control.",
                good: "A small spinner beside the button that started it.",
                bad: "“Loading…” adds words that say nothing new."
            ) {
                HStack(spacing: 8) {
                    Button("Check for Updates") {}
                    ProgressView()
                        .controlSize(.small)
                }
            } bad: {
                HStack(spacing: 8) {
                    Button("Check for Updates") {}
                    ProgressView("Loading…")
                        .controlSize(.small)
                }
            },
            Guideline(
                "Let people stop long tasks.",
                "Add a Cancel button when stopping has no bad side effects. If it would lose work, ask before you stop."
            ),
            Guideline(
                "Don't switch between a spinner and a bar.",
                "They're different shapes and sizes, so swapping one for the other mid-task looks jumpy. Pick one and keep it."
            ),
        ]
    ) {
        VStack(spacing: 14) {
            ProgressView(value: 0.6)
                .frame(width: 150)
            HStack(spacing: 20) {
                ProgressView()
                    .controlSize(.small)
                Gauge(value: 0.7) {
                    Text("Storage")
                }
                .gaugeStyle(.accessoryCircularCapacity)
                .scaleEffect(0.7)
            }
        }
    } content: { page in
        MacGaugeProgressDemo(page: page)
    }
}

private struct MacGaugeProgressConfig {
    var kind: MacIndicatorOption = .progressBar
    var isDeterminate = true
    var value = 0.6
    var showsLabel = true
    var size: MacIndicatorSizeOption = .regular
}

private struct MacGaugeProgressDemo: View {
    let page: ComponentPage

    var body: some View {
        DemoPage(
            page: page,
            initial: MacGaugeProgressConfig(),
            usage: """
            @State private var progress = 0.6

            ProgressView(value: progress) {
                Text("Exporting photos…")
            }
            """,
            usageNote: Aside(.note, "The default total is `1.0`, so `value` is a fraction. Pass `total:` to count in your own units, like files or bytes.")
        ) { $config in
            MacIndicator(config: config)
                .frame(maxWidth: 300)
        } controls: { $config in
            Section("Content") {
                OptionPicker("Kind", selection: $config.kind)
                Toggle("Determinate", isOn: $config.isDeterminate)
                    .disabled(config.kind.isGauge)
                ValueSlider("Value", value: $config.value, in: 0...1)
                    .disabled(!config.isDeterminate && !config.kind.isGauge)
                Toggle("Label", isOn: $config.showsLabel)
            }
            Section("Appearance") {
                OptionPicker("Size", selection: $config.size)
            }
        } code: { config in
            let value = swiftNumber(config.value)
            var lines: [String] = []
            if config.kind.isGauge {
                lines.append("Gauge(value: \(value)) {")
                lines.append(config.showsLabel ? "    Text(\"Storage\")" : "    EmptyView()")
                lines.append("} currentValueLabel: {")
                lines.append("    Text(\"\(Int(config.value * 100))%\")")
                lines.append("}")
                lines.append(".gaugeStyle(\(config.kind.style))")
            } else {
                let args = config.isDeterminate ? "value: \(value)" : ""
                if config.showsLabel {
                    lines.append("ProgressView(\(args)) {")
                    lines.append("    Text(\"Exporting photos…\")")
                    lines.append("}")
                } else {
                    lines.append("ProgressView(\(args))")
                }
                lines.append(".progressViewStyle(\(config.kind.style))")
            }
            if config.size != .regular {
                lines.append(".controlSize(\(config.size.label))")
            }
            return lines.joined(separator: "\n")
        } examples: {
            MacGaugeProgressExamples()
        }
    }
}

/// The demo's indicator, built from the current options.
private struct MacIndicator: View {
    let config: MacGaugeProgressConfig

    var body: some View {
        indicator
            .controlSize(config.size.size)
    }

    @ViewBuilder private var indicator: some View {
        switch config.kind {
        case .progressBar, .spinner:
            Group {
                switch (config.isDeterminate, config.showsLabel) {
                case (true, true):
                    ProgressView(value: config.value) { Text("Exporting photos…") }
                case (true, false):
                    ProgressView(value: config.value)
                case (false, true):
                    ProgressView { Text("Exporting photos…") }
                case (false, false):
                    ProgressView()
                }
            }
            .progressViewStyle(config.kind == .spinner ? AnyProgressViewStyle.circular : .linear)
        case .linearCapacity, .accessoryLinear, .accessoryCircular, .accessoryCircularCapacity:
            Gauge(value: config.value) {
                if config.showsLabel {
                    Text("Storage")
                }
            } currentValueLabel: {
                Text("\(Int(config.value * 100))%")
            }
            .gaugeStyled(config.kind)
        }
    }
}

// MARK: - Examples

private struct MacGaugeProgressExamples: View {
    @State private var copied = 0.0
    @State private var isCopying = false
    @State private var isChecking = false
    @State private var storage = 0.72

    var body: some View {
        ExampleCard(
            title: "A task people can cancel",
            caption: "Show the count in `currentValueLabel` and put a Cancel button beside the bar, so people can stop a long copy.",
            code: """
            @State private var copied = 0.0

            HStack {
                ProgressView(value: copied, total: 120) {
                    Text("Copying photos")
                } currentValueLabel: {
                    Text("\\(Int(copied)) of 120")
                }
                Button("Cancel") {
                    cancelCopy()
                }
            }
            """,
            minHeight: 150
        ) {
            VStack(spacing: 14) {
                HStack(alignment: .center) {
                    ProgressView(value: copied, total: 120) {
                        Text("Copying photos")
                    } currentValueLabel: {
                        Text("\(Int(copied)) of 120")
                    }
                    Button(isCopying ? "Cancel" : "Copy") {
                        isCopying.toggle()
                        if isCopying { copied = 0 }
                    }
                }
                .frame(maxWidth: 360)
            }
            .task(id: isCopying) {
                guard isCopying else { return }
                while copied < 120, !Task.isCancelled {
                    try? await Task.sleep(for: .milliseconds(40))
                    copied += 1
                }
                isCopying = false
            }
        }

        ExampleCard(
            title: "An indeterminate bar",
            caption: "Without a value, `.linear` draws a bar that animates without an end, which the Mac offers alongside the spinner.",
            code: """
            ProgressView {
                Text("Preparing export")
            }
            .progressViewStyle(.linear)
            """,
            minHeight: 120
        ) {
            ProgressView {
                Text("Preparing export")
            }
            .progressViewStyle(.linear)
            .frame(maxWidth: 320)
        }

        ExampleCard(
            title: "A small spinner for background work",
            caption: "`.controlSize(.small)` makes the spinner fit next to a button or in a toolbar while something loads in the background.",
            code: """
            @State private var isChecking = false

            HStack(spacing: 8) {
                Button("Check for Updates") {
                    isChecking = true
                }
                .disabled(isChecking)
                if isChecking {
                    ProgressView()
                        .controlSize(.small)
                }
            }
            """,
            minHeight: 120
        ) {
            HStack(spacing: 8) {
                Button("Check for Updates") {
                    isChecking = true
                }
                .disabled(isChecking)
                if isChecking {
                    ProgressView()
                        .controlSize(.small)
                }
            }
            .task(id: isChecking) {
                guard isChecking else { return }
                try? await Task.sleep(for: .seconds(2))
                isChecking = false
            }
        }

        ExampleCard(
            title: "A capacity gauge",
            caption: "`.linearCapacity` fills a bar up to the value, and `minimumValueLabel` and `maximumValueLabel` show the ends of the range.",
            code: """
            Gauge(value: 0.72) {
                Text("Storage")
            } currentValueLabel: {
                Text("72%")
            } minimumValueLabel: {
                Text("0")
            } maximumValueLabel: {
                Text("1 TB")
            }
            .gaugeStyle(.linearCapacity)
            .tint(.orange)
            """,
            minHeight: 130,
            aside: Aside(.note, "Write labels for the value and both ends even when a style hides some of them: VoiceOver reads them.")
        ) {
            Gauge(value: storage) {
                Text("Storage")
            } currentValueLabel: {
                Text("\(Int(storage * 100))%")
            } minimumValueLabel: {
                Text("0")
            } maximumValueLabel: {
                Text("1 TB")
            }
            .gaugeStyle(.linearCapacity)
            .tint(.orange)
            .frame(maxWidth: 320)
        }

        ExampleCard(
            title: "A small circular gauge",
            caption: "`.accessoryCircular` draws a ring with a marker at the value, and a gradient tint shows what high and low mean.",
            code: """
            Gauge(value: 0.35) {
                Text("CPU")
            } currentValueLabel: {
                Text("35")
            }
            .gaugeStyle(.accessoryCircular)
            .tint(Gradient(colors: [.green, .yellow, .red]))
            """,
            minHeight: 130
        ) {
            Gauge(value: 0.35) {
                Text("CPU")
            } currentValueLabel: {
                Text("35")
            }
            .gaugeStyle(.accessoryCircular)
            .tint(Gradient(colors: [.green, .yellow, .red]))
        }
    }
}

// MARK: - Options

private enum MacIndicatorOption: DemoOption {
    case progressBar, spinner, linearCapacity, accessoryLinear, accessoryCircular, accessoryCircularCapacity

    var label: String {
        switch self {
        case .progressBar: "ProgressView .linear"
        case .spinner: "ProgressView .circular"
        case .linearCapacity: "Gauge .linearCapacity"
        case .accessoryLinear: "Gauge .accessoryLinear"
        case .accessoryCircular: "Gauge .accessoryCircular"
        case .accessoryCircularCapacity: "Gauge .accessoryCircularCapacity"
        }
    }

    var style: String {
        switch self {
        case .progressBar: ".linear"
        case .spinner: ".circular"
        case .linearCapacity: ".linearCapacity"
        case .accessoryLinear: ".accessoryLinear"
        case .accessoryCircular: ".accessoryCircular"
        case .accessoryCircularCapacity: ".accessoryCircularCapacity"
        }
    }

    var isGauge: Bool {
        self != .progressBar && self != .spinner
    }
}

private enum MacIndicatorSizeOption: DemoOption {
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

/// Lets the demo switch progress styles with one modifier.
private enum AnyProgressViewStyle: ProgressViewStyle {
    case linear, circular

    func makeBody(configuration: Configuration) -> some View {
        switch self {
        case .linear: ProgressView(configuration).progressViewStyle(.linear)
        case .circular: ProgressView(configuration).progressViewStyle(.circular)
        }
    }
}

private extension View {
    @ViewBuilder
    func gaugeStyled(_ kind: MacIndicatorOption) -> some View {
        switch kind {
        case .accessoryLinear: gaugeStyle(.accessoryLinear)
        case .accessoryCircular: gaugeStyle(.accessoryCircular)
        case .accessoryCircularCapacity: gaugeStyle(.accessoryCircularCapacity)
        default: gaugeStyle(.linearCapacity)
        }
    }
}
