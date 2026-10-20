import SwiftUI

extension ComponentPage {
    static let frame = ComponentPage(
        id: "frame",
        title: "frame",
        summary: "Sets a view's size, or lets it stretch to fill the space it's offered.",
        category: .modifiers,
        kind: .modifier,
        symbol: "rectangle.dashed",
        availability: ["iOS 13.0+", "macOS 10.15+", "visionOS 1.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/view/frame(width:height:alignment:)",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/layout",
        aliases: ["width", "height", "size", "full width", "width: 100%", "max-width", "min-height", "flex-grow", "fill", "stretch"],
        related: ["layout-basics", "padding", "spacer-divider", "geometry-reader"],
        notes: [
            "**Only flexible views fill a frame.** Shapes, colors, and `resizable()` images grow to fit it. Text and controls keep their natural size and sit inside at `alignment`.",
            "**Mixing fixed and flexible sizes takes two frames.** A single call can't combine `width:` with `maxHeight:`, so chain `.frame(width: 200).frame(maxHeight: .infinity)`.",
        ],
        api: [
            APIItem("`.frame(width:height:)`", "A fixed size in points. Leave one out to keep it natural."),
            APIItem("`.frame(maxWidth: .infinity)`", "Stretches to fill the width, like CSS `width: 100%`."),
            APIItem("`.frame(minWidth:minHeight:)`", "Never smaller than this, but free to grow."),
            APIItem("`alignment:`", "Where the content sits inside a larger frame."),
            APIItem("`.fixedSize()`", "Keeps the natural size, even if that means overflowing."),
            APIItem("`.containerRelativeFrame(_:)`", "Sizes a view as a fraction of its container."),
        ],
        guidelines: [
            Guideline(
                "Make every tap target at least 44 × 44 points.",
                "Small icons are easy to miss with a finger. Grow the frame with `minWidth` and `minHeight` instead of the icon.",
                good: "The frame grows the target to 44 points.",
                bad: "The tap area is only as big as the icon."
            ) {
                FrameTargetSample(minSize: 44)
            } bad: {
                FrameTargetSample(minSize: nil)
            },
            Guideline(
                "Let text set its own width.",
                "Labels get longer in other languages and at larger text sizes. A fixed width cuts them off, so prefer `maxWidth` or no frame at all.",
                good: "A flexible frame fits the whole label.",
                bad: "A fixed width truncates the label."
            ) {
                FrameLabelSample(fixedWidth: nil)
            } bad: {
                FrameLabelSample(fixedWidth: 110)
            },
            Guideline(
                "Size by the space you have, not the device.",
                "Use flexible frames and `containerRelativeFrame` so the same layout works on every iPhone and in iPad windows."
            ),
        ]
    ) {
        Text("Frame")
            .font(.headline)
            .padding(8)
            .background(.blue.opacity(0.25), in: .rect(cornerRadius: 6))
            .frame(width: 180, height: 100, alignment: .topLeading)
            .padding(4)
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(.pink, style: StrokeStyle(lineWidth: 1.5, dash: [5, 4]))
            }
    } content: { page in
        FrameDemo(page: page)
    }
}

private struct FrameConfig {
    var width: FrameSizeMode = .fixed
    var widthValue = 200.0
    var height: FrameSizeMode = .fixed
    var heightValue = 100.0
    var alignment: FrameAlignment = .center
}

private enum FrameSizeMode: DemoOption {
    case none, fixed, infinity

    var label: String {
        switch self {
        case .none: "Natural"
        case .fixed: "Fixed"
        case .infinity: "Fill (.infinity)"
        }
    }
}

private enum FrameAlignment: DemoOption {
    case topLeading, top, topTrailing, leading, center, trailing, bottomLeading, bottom, bottomTrailing

    var label: String {
        switch self {
        case .topLeading: ".topLeading"
        case .top: ".top"
        case .topTrailing: ".topTrailing"
        case .leading: ".leading"
        case .center: ".center"
        case .trailing: ".trailing"
        case .bottomLeading: ".bottomLeading"
        case .bottom: ".bottom"
        case .bottomTrailing: ".bottomTrailing"
        }
    }

    var value: Alignment {
        switch self {
        case .topLeading: .topLeading
        case .top: .top
        case .topTrailing: .topTrailing
        case .leading: .leading
        case .center: .center
        case .trailing: .trailing
        case .bottomLeading: .bottomLeading
        case .bottom: .bottom
        case .bottomTrailing: .bottomTrailing
        }
    }
}

private extension View {
    /// Applies the configured frame the same way the generated code writes it.
    @ViewBuilder
    func demoFrame(_ config: FrameConfig) -> some View {
        let alignment = config.alignment.value
        switch (config.width, config.height) {
        case (.none, .none):
            self
        case (.fixed, .fixed):
            frame(width: config.widthValue, height: config.heightValue, alignment: alignment)
        case (.fixed, .none):
            frame(width: config.widthValue, alignment: alignment)
        case (.none, .fixed):
            frame(height: config.heightValue, alignment: alignment)
        case (.infinity, .infinity):
            frame(maxWidth: .infinity, maxHeight: .infinity, alignment: alignment)
        case (.infinity, .none):
            frame(maxWidth: .infinity, alignment: alignment)
        case (.none, .infinity):
            frame(maxHeight: .infinity, alignment: alignment)
        case (.fixed, .infinity):
            frame(width: config.widthValue, alignment: alignment)
                .frame(maxHeight: .infinity, alignment: alignment)
        case (.infinity, .fixed):
            frame(height: config.heightValue, alignment: alignment)
                .frame(maxWidth: .infinity, alignment: alignment)
        }
    }
}

private func frameCode(_ config: FrameConfig) -> [String] {
    let w = swiftNumber(config.widthValue)
    let h = swiftNumber(config.heightValue)
    let a = config.alignment == .center ? "" : ", alignment: \(config.alignment.label)"
    switch (config.width, config.height) {
    case (.none, .none): return []
    case (.fixed, .fixed): return [".frame(width: \(w), height: \(h)\(a))"]
    case (.fixed, .none): return [".frame(width: \(w)\(a))"]
    case (.none, .fixed): return [".frame(height: \(h)\(a))"]
    case (.infinity, .infinity): return [".frame(maxWidth: .infinity, maxHeight: .infinity\(a))"]
    case (.infinity, .none): return [".frame(maxWidth: .infinity\(a))"]
    case (.none, .infinity): return [".frame(maxHeight: .infinity\(a))"]
    case (.fixed, .infinity): return [".frame(width: \(w)\(a))", ".frame(maxHeight: .infinity\(a))"]
    case (.infinity, .fixed): return [".frame(height: \(h)\(a))", ".frame(maxWidth: .infinity\(a))"]
    }
}

private struct FrameDemo: View {
    let page: ComponentPage

    var body: some View {
        DemoPage(
            page: page,
            initial: FrameConfig(),
            previewHeight: 240,
            usage: """
            Text("Welcome back")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(.fill.tertiary, in: .rect(cornerRadius: 12))
            """,
            usageNote: Aside(.note, "A frame is a new, invisible box around the view, not the view itself. Add a `.background` after it to see how big it is.")
        ) { $config in
            VStack(spacing: 12) {
                Text("Frame")
                    .font(.headline)
                    .padding(10)
                    .background(.blue.opacity(0.3), in: .rect(cornerRadius: 8))
                    .demoFrame(config)
                    .background(.pink.opacity(0.12))
                    .border(.pink.opacity(0.7))
                    .frame(maxWidth: .infinity, minHeight: 180, maxHeight: 180)
                    .animation(.snappy, value: config.widthValue)
                    .animation(.snappy, value: config.heightValue)
                    .animation(.snappy, value: config.width)
                    .animation(.snappy, value: config.height)
                    .animation(.snappy, value: config.alignment)
                Text("Pink is the frame. Blue is the text inside it.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        } controls: { $config in
            Section("Width") {
                OptionPicker("Width", selection: $config.width)
                if config.width == .fixed {
                    ValueSlider("Points", value: $config.widthValue, in: 40...300, step: 1)
                }
            }
            Section("Height") {
                OptionPicker("Height", selection: $config.height)
                if config.height == .fixed {
                    ValueSlider("Points", value: $config.heightValue, in: 30...180, step: 1)
                }
            }
            Section("Position inside the frame") {
                OptionPicker("Alignment", selection: $config.alignment)
            }
        } code: { config in
            var lines = [
                "Text(\"Frame\")",
                "    .font(.headline)",
                "    .padding(10)",
                "    .background(.blue.opacity(0.3), in: .rect(cornerRadius: 8))",
            ]
            lines += frameCode(config).map { "    " + $0 }
            lines.append("    .background(.pink.opacity(0.12))")
            lines.append("    .border(.pink.opacity(0.7))")
            return lines.joined(separator: "\n")
        } examples: {
            ExampleCard(
                title: "Full-width button",
                caption: "Put `.frame(maxWidth: .infinity)` on the label, not the button, so the whole bar fills.",
                code: """
                Button {
                    // Continue
                } label: {
                    Text("Continue")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                """
            ) {
                Button {
                } label: {
                    Text("Continue")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }

            ExampleCard(
                title: "Leading-aligned text without a Spacer",
                caption: "Use `.frame(maxWidth: .infinity, alignment: .leading)` to line text up on the leading edge.",
                code: """
                VStack(spacing: 8) {
                    Text("Title")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("A longer subtitle line")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                """,
                aside: Aside(.note, "A `VStack` centers its children by default. This is often simpler than wrapping each line in an `HStack` with a `Spacer`.")
            ) {
                VStack(spacing: 8) {
                    Text("Title")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("A longer subtitle line")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }

            ExampleCard(
                title: "Square avatar",
                caption: "Give icons and avatars a fixed `.frame(width:height:)` so they line up at one size.",
                code: """
                Image(systemName: "person.fill")
                    .font(.system(size: 30))
                    .foregroundStyle(.white)
                    .frame(width: 64, height: 64)
                    .background(.indigo.gradient)
                    .clipShape(.circle)
                """,
                aside: Aside(.important, "Clip after the frame. Clipping first cuts the small icon, not the 64-point circle.")
            ) {
                Image(systemName: "person.fill")
                    .font(.system(size: 30))
                    .foregroundStyle(.white)
                    .frame(width: 64, height: 64)
                    .background(.indigo.gradient)
                    .clipShape(.circle)
            }

            ExampleCard(
                title: "Minimum tap target",
                caption: "Use `minWidth` and `minHeight` to keep a small icon button at least 44 points.",
                code: """
                Button {
                    // Close
                } label: {
                    Image(systemName: "xmark")
                        .frame(minWidth: 44, minHeight: 44)
                        .contentShape(.rect)
                }
                """,
                aside: Aside(.note, "`.contentShape(.rect)` makes the empty part of the frame tappable too. The dashed outline shows the target.")
            ) {
                Button {
                } label: {
                    Image(systemName: "xmark")
                        .frame(minWidth: 44, minHeight: 44)
                        .contentShape(.rect)
                }
                .overlay {
                    Rectangle().strokeBorder(.secondary, style: StrokeStyle(lineWidth: 1, dash: [3, 3]))
                }
            }
        }
    }
}

// MARK: - Guideline samples

private struct FrameTargetSample: View {
    let minSize: CGFloat?

    var body: some View {
        Image(systemName: "xmark")
            .font(.body.weight(.semibold))
            .foregroundStyle(.tint)
            .frame(minWidth: minSize, minHeight: minSize)
            .overlay {
                Rectangle().strokeBorder(.secondary, style: StrokeStyle(lineWidth: 1, dash: [3, 3]))
            }
    }
}

private struct FrameLabelSample: View {
    let fixedWidth: CGFloat?

    var body: some View {
        Text("Continue Shopping")
            .lineLimit(1)
            .frame(width: fixedWidth)
            .padding(.vertical, 10)
            .padding(.horizontal, 14)
            .foregroundStyle(.white)
            .background(.blue, in: .capsule)
    }
}
