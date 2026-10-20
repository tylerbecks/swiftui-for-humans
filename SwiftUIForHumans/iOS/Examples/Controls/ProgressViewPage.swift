import SwiftUI

extension ComponentPage {
    static let progressView = ComponentPage(
        id: "progress-view",
        title: "ProgressView",
        summary: "Shows that work is happening, as a spinning indicator or a filling bar.",
        category: .controls,
        symbol: "progress.indicator",
        availability: ["iOS 14.0+", "macOS 11.0+", "visionOS 1.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/progressview",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/progress-indicators",
        aliases: ["spinner", "loading", "loader", "activity indicator", "progress bar", "<progress>", "UIActivityIndicatorView", "UIProgressView", "throbber"],
        related: ["gauge", "slider", "async-image"],
        notes: [
            "**Skip the spinner for very short waits.** If work finishes in under a second, a flash of spinner makes the app feel slower, not faster.",
        ],
        api: [
            APIItem("`ProgressView()`", "A spinner, for work of unknown length."),
            APIItem("`ProgressView(value:total:)`", "A bar that fills; `total` defaults to 1."),
            APIItem("`label:` / `currentValueLabel:`", "Text above and below the bar."),
            APIItem("`ProgressView(timerInterval:)`", "Fills or empties between two dates by itself."),
            APIItem("`.controlSize(_:)`", "Spinner size, from `.small` to `.extraLarge`."),
            APIItem("`.tint(_:)`", "The color of the bar or spinner."),
        ],
        guidelines: [
            Guideline(
                "Use a bar when you know how far along you are.",
                "A spinner only says “wait”. A bar tells people how long, so they can decide whether to do something else.",
                good: "A bar shows how much is left.",
                bad: "A spinner for a known amount of work."
            ) {
                ProgressView(value: 0.6) {
                    Text("Downloading files")
                }
                .frame(width: 240)
            } bad: {
                ProgressView("Downloading files")
            },
            Guideline(
                "Say what's happening.",
                "A specific label like “Importing 240 photos” is more useful than “Loading…”, which people learn to ignore.",
                good: "The label names the task.",
                bad: "A vague label adds nothing."
            ) {
                ProgressView("Importing 240 photos")
            } bad: {
                ProgressView("Loading…")
            },
            Guideline(
                "Let people cancel long tasks.",
                "Add a Cancel button next to the progress, and confirm first if canceling throws away work."
            ),
            Guideline(
                "Don't switch from a spinner to a bar mid-task.",
                "They're different shapes and sizes, so the swap jumps. Pick one, or start with an empty bar."
            ),
        ]
    ) {
        VStack(spacing: 22) {
            ProgressView()
                .controlSize(.large)
            ProgressView(value: 0.6)
                .frame(width: 180)
        }
    } content: { page in
        ProgressViewDemo(page: page)
    }
}

private struct ProgressViewConfig {
    var isDeterminate = true
    var value = 0.6
    var style: ProgressStyleOption = .automatic
    var showsLabel = true
    var showsCurrentValue = true
    var size: ProgressSizeOption = .regular
    var tint: ProgressTintOption = .automatic
}

private struct ProgressViewDemo: View {
    let page: ComponentPage

    var body: some View {
        DemoPage(
            page: page,
            initial: ProgressViewConfig(),
            previewHeight: 200,
            usage: """
            // Unknown length: a spinner
            ProgressView("Loading messages")

            // Known progress: a bar from 0 to 1
            ProgressView(value: 0.4)
            """,
            usageNote: Aside(.important, "On iOS, `.circular` is always a spinner, even with a value. For a ring that fills, use a [Gauge](catalog://gauge) with the `.accessoryCircularCapacity` style.")
        ) { $config in
            Group {
                if config.isDeterminate {
                    if config.showsLabel {
                        ProgressView(value: config.value) {
                            Text("Downloading")
                        } currentValueLabel: {
                            if config.showsCurrentValue {
                                Text(config.value.formatted(.percent.precision(.fractionLength(0))))
                            }
                        }
                    } else {
                        ProgressView(value: config.value)
                    }
                } else if config.showsLabel {
                    ProgressView("Loading")
                } else {
                    ProgressView()
                }
            }
            .styled(config.style)
            .controlSize(config.size.size)
            .tint(config.tint.color)
            .frame(maxWidth: 360)
            .animation(.default, value: config.value)
        } controls: { $config in
            Section("Progress") {
                Toggle("Determinate (has a value)", isOn: $config.isDeterminate)
                if config.isDeterminate {
                    ValueSlider("Value", value: $config.value, in: 0...1, step: 0.01)
                }
            }
            Section("Appearance") {
                OptionPicker("Style", selection: $config.style)
                OptionPicker("Size", selection: $config.size)
                OptionPicker("Tint", selection: $config.tint)
                Toggle("Label", isOn: $config.showsLabel)
                if config.isDeterminate && config.showsLabel {
                    Toggle("Current value label", isOn: $config.showsCurrentValue)
                }
            }
        } code: { config in
            progressCode(config)
        } examples: {
            ProgressViewExamples()
        }
    }
}

private func progressCode(_ config: ProgressViewConfig) -> String {
    var lines: [String] = []
    if config.isDeterminate {
        lines += ["@State private var progress = \(doubleLiteral(config.value))", ""]
        if config.showsLabel {
            lines += ["ProgressView(value: progress) {", "    Text(\"Downloading\")"]
            if config.showsCurrentValue {
                lines += [
                    "} currentValueLabel: {",
                    "    Text(progress.formatted(.percent.precision(.fractionLength(0))))",
                ]
            }
            lines.append("}")
        } else {
            lines.append("ProgressView(value: progress)")
        }
    } else {
        lines.append(config.showsLabel ? "ProgressView(\"Loading\")" : "ProgressView()")
    }
    if config.style != .automatic {
        lines.append("    .progressViewStyle(\(config.style.label))")
    }
    if config.size != .regular {
        lines.append("    .controlSize(\(config.size.label))")
    }
    if config.tint != .automatic {
        lines.append("    .tint(\(config.tint.label))")
    }
    return lines.joined(separator: "\n")
}

// MARK: - Examples

private struct ProgressViewExamples: View {
    @State private var isLoading = false
    @State private var countdown = Date.now...Date.now.addingTimeInterval(30)
    @State private var uploaded = 3.0

    var body: some View {
        ExampleCard(
            title: "Button that shows it's busy",
            caption: "Swap a button's label for a `ProgressView` while work runs, and ignore taps until it's done.",
            code: """
            @State private var isLoading = false

            Button {
                guard !isLoading else { return }
                isLoading = true
                Task {
                    try? await Task.sleep(for: .seconds(2))
                    isLoading = false
                }
            } label: {
                ZStack {
                    Text("Save").opacity(isLoading ? 0 : 1)
                    if isLoading {
                        ProgressView()
                            .tint(.white)
                    }
                }
                .frame(width: 80)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            """,
            aside: Aside(.note, "The text stays in the `ZStack` at zero opacity, so the button keeps its width when the spinner appears.")
        ) {
            Button {
                guard !isLoading else { return }
                isLoading = true
                Task {
                    try? await Task.sleep(for: .seconds(2))
                    isLoading = false
                }
            } label: {
                ZStack {
                    Text("Save").opacity(isLoading ? 0 : 1)
                    if isLoading {
                        ProgressView()
                            .tint(.white)
                    }
                }
                .frame(width: 80)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }

        ExampleCard(
            title: "Counts with a total",
            caption: "Pass `total:` when progress is a count, like photos uploaded, instead of dividing yourself.",
            code: """
            @State private var uploaded = 3.0

            VStack(spacing: 16) {
                ProgressView(value: uploaded, total: 8) {
                    Text("Uploading photos")
                } currentValueLabel: {
                    Text("\\(Int(uploaded)) of 8")
                }
                .animation(.default, value: uploaded)
                Button(uploaded < 8 ? "Upload one more" : "Start over") {
                    uploaded = uploaded < 8 ? uploaded + 1 : 0
                }
            }
            """
        ) {
            VStack(spacing: 16) {
                ProgressView(value: uploaded, total: 8) {
                    Text("Uploading photos")
                } currentValueLabel: {
                    Text("\(Int(uploaded)) of 8")
                }
                .animation(.default, value: uploaded)
                Button(uploaded < 8 ? "Upload one more" : "Start over") {
                    uploaded = uploaded < 8 ? uploaded + 1 : 0
                }
            }
            .frame(maxWidth: 360)
        }

        ExampleCard(
            title: "Countdown that runs by itself",
            caption: "Use `ProgressView(timerInterval:)` to animate between two dates with no timer code.",
            code: """
            @State private var countdown = Date.now...Date.now.addingTimeInterval(30)

            VStack(spacing: 16) {
                ProgressView(timerInterval: countdown) {
                    Text("Code expires")
                }
                Button("Restart") {
                    countdown = Date.now...Date.now.addingTimeInterval(30)
                }
            }
            .onAppear {
                countdown = Date.now...Date.now.addingTimeInterval(30)
            }
            """,
            aside: Aside(.note, "Pass `countsDown: false` to fill up instead. The same view works in widgets and Live Activities.")
        ) {
            VStack(spacing: 16) {
                ProgressView(timerInterval: countdown) {
                    Text("Code expires")
                }
                Button("Restart") {
                    countdown = Date.now...Date.now.addingTimeInterval(30)
                }
            }
            .onAppear {
                countdown = Date.now...Date.now.addingTimeInterval(30)
            }
            .frame(maxWidth: 360)
        }

        ExampleCard(
            title: "Loading overlay",
            caption: "Put a large spinner in an `.overlay` on a material, so the layout doesn't jump while content loads.",
            code: """
            RoundedRectangle(cornerRadius: 16)
                .fill(.fill.tertiary)
                .frame(height: 140)
                .overlay {
                    ProgressView("Loading photos")
                        .controlSize(.large)
                        .padding(20)
                        .background(.regularMaterial, in: .rect(cornerRadius: 14))
                }
            """
        ) {
            RoundedRectangle(cornerRadius: 16)
                .fill(.fill.tertiary)
                .frame(height: 140)
                .overlay {
                    ProgressView("Loading photos")
                        .controlSize(.large)
                        .padding(20)
                        .background(.regularMaterial, in: .rect(cornerRadius: 14))
                }
                .frame(maxWidth: 360)
        }
    }
}

// MARK: - Options

private enum ProgressStyleOption: DemoOption {
    case automatic, linear, circular

    var label: String {
        switch self {
        case .automatic: ".automatic"
        case .linear: ".linear"
        case .circular: ".circular"
        }
    }
}

private enum ProgressSizeOption: DemoOption {
    case small, regular, large, extraLarge

    var label: String {
        switch self {
        case .small: ".small"
        case .regular: ".regular"
        case .large: ".large"
        case .extraLarge: ".extraLarge"
        }
    }

    var size: ControlSize {
        switch self {
        case .small: .small
        case .regular: .regular
        case .large: .large
        case .extraLarge: .extraLarge
        }
    }
}

private enum ProgressTintOption: DemoOption {
    case automatic, green, orange, pink

    var label: String {
        switch self {
        case .automatic: "Default"
        case .green: ".green"
        case .orange: ".orange"
        case .pink: ".pink"
        }
    }

    var color: Color? {
        switch self {
        case .automatic: nil
        case .green: .green
        case .orange: .orange
        case .pink: .pink
        }
    }
}

private extension View {
    @ViewBuilder
    func styled(_ style: ProgressStyleOption) -> some View {
        switch style {
        case .automatic: progressViewStyle(.automatic)
        case .linear: progressViewStyle(.linear)
        case .circular: progressViewStyle(.circular)
        }
    }
}

/// A number literal that Swift infers as `Double` ("50.0", not "50").
private func doubleLiteral(_ value: Double) -> String {
    let text = swiftNumber(value)
    return text.contains(".") ? text : text + ".0"
}
