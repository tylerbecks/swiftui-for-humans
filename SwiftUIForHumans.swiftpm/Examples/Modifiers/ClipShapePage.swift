import SwiftUI

extension ComponentPage {
    static let clipShape = ComponentPage(
        id: "clip-shape",
        title: "clipShape",
        summary: "Cuts a view to a shape, like rounded corners or a circle, and hides the rest.",
        category: .modifiers,
        kind: .modifier,
        symbol: "scissors",
        availability: ["iOS 13.0+", "macOS 10.15+", "visionOS 1.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/view/clipshape(_:style:)",
        aliases: ["border-radius", "rounded corners", "cornerRadius", "corner radius", "mask", "overflow: hidden", "circle image", "clip-path", "clipped", "squircle"],
        related: ["shapes", "background-overlay", "shadow", "modifier-order"],
        notes: [
            "**`.cornerRadius(_:)` is deprecated.** Use `.clipShape(.rect(cornerRadius: 12))`, or `.background(color, in: .rect(cornerRadius: 12))` when you only need a rounded fill.",
            "**Rounded rectangles use smooth corners.** `.rect(cornerRadius:)` draws Apple's continuous \"squircle\" curve, the same as app icons, by default.",
            "**Add a shadow after the clip.** A `.shadow` before `.clipShape` gets cut off along with everything else outside the shape.",
        ],
        api: [
            APIItem("`.clipShape(.rect(cornerRadius:))`", "Rounded corners, like CSS `border-radius` with `overflow: hidden`."),
            APIItem("`.clipShape(.circle)`", "A circle, for avatars and round buttons."),
            APIItem("`.clipShape(.capsule)`", "Fully rounded ends, for pills."),
            APIItem("`.rect(topLeadingRadius:…)`", "A different radius on each corner."),
            APIItem("`.clipped()`", "Cuts off anything outside the view's frame."),
            APIItem("`.contentShape(_:)`", "Sets the tappable area to match the visible shape."),
        ]
    ) {
        HStack(spacing: 14) {
            ClipSwatch()
                .frame(width: 74, height: 74)
                .clipShape(.rect(cornerRadius: 18))
            ClipSwatch()
                .frame(width: 74, height: 74)
                .clipShape(.circle)
            ClipSwatch()
                .frame(width: 50, height: 74)
                .clipShape(.capsule)
        }
    } content: { page in
        ClipShapeDemo(page: page)
    }
}

/// A colorful stand-in for a photo.
private struct ClipSwatch: View {
    var body: some View {
        LinearGradient(colors: [.orange, .pink, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)
            .overlay {
                Image(systemName: "mountain.2.fill")
                    .font(.system(size: 34))
                    .foregroundStyle(.white.opacity(0.9))
            }
    }
}

private struct ClipConfig {
    var shape: ClipShapeOption = .roundedRect
    var radius = 24.0
    var bottomRadius = 0.0
}

private enum ClipShapeOption: DemoOption {
    case none, roundedRect, unevenRect, circle, capsule, ellipse

    var label: String {
        switch self {
        case .none: "None"
        case .roundedRect: ".rect(cornerRadius:)"
        case .unevenRect: "Different corners"
        case .circle: ".circle"
        case .capsule: ".capsule"
        case .ellipse: ".ellipse"
        }
    }
}

private extension View {
    @ViewBuilder
    func demoClip(_ config: ClipConfig) -> some View {
        switch config.shape {
        case .none: self
        case .roundedRect: clipShape(.rect(cornerRadius: config.radius))
        case .unevenRect:
            clipShape(.rect(
                topLeadingRadius: config.radius,
                bottomLeadingRadius: config.bottomRadius,
                bottomTrailingRadius: config.bottomRadius,
                topTrailingRadius: config.radius
            ))
        case .circle: clipShape(.circle)
        case .capsule: clipShape(.capsule)
        case .ellipse: clipShape(.ellipse)
        }
    }
}

private struct ClipShapeDemo: View {
    let page: ComponentPage

    var body: some View {
        DemoPage(
            page: page,
            initial: ClipConfig(),
            usage: """
            Image(systemName: "photo.fill")
                .font(.largeTitle)
                .foregroundStyle(.white)
                .frame(width: 160, height: 120)
                .background(.indigo.gradient)
                .clipShape(.rect(cornerRadius: 16))
            """,
            usageNote: Aside(.note, "Set the size with `.frame` first, then clip. The clip uses whatever size the view has at that point in the chain.")
        ) { $config in
            ClipSwatch()
                .frame(width: 220, height: 160)
                .demoClip(config)
                .animation(.snappy, value: config.radius)
                .animation(.snappy, value: config.bottomRadius)
        } controls: { $config in
            Section("Shape") {
                OptionPicker("Shape", selection: $config.shape)
                if config.shape == .roundedRect {
                    ValueSlider("Corner radius", value: $config.radius, in: 0...80, step: 1)
                }
                if config.shape == .unevenRect {
                    ValueSlider("Top corners", value: $config.radius, in: 0...80, step: 1)
                    ValueSlider("Bottom corners", value: $config.bottomRadius, in: 0...80, step: 1)
                }
            }
        } code: { config in
            var lines = [
                "LinearGradient(colors: [.orange, .pink, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)",
                "    .overlay {",
                "        Image(systemName: \"mountain.2.fill\")",
                "            .font(.system(size: 34))",
                "            .foregroundStyle(.white.opacity(0.9))",
                "    }",
                "    .frame(width: 220, height: 160)",
            ]
            let top = swiftNumber(config.radius)
            let bottom = swiftNumber(config.bottomRadius)
            switch config.shape {
            case .none: break
            case .roundedRect: lines.append("    .clipShape(.rect(cornerRadius: \(top)))")
            case .unevenRect:
                lines += [
                    "    .clipShape(.rect(",
                    "        topLeadingRadius: \(top),",
                    "        bottomLeadingRadius: \(bottom),",
                    "        bottomTrailingRadius: \(bottom),",
                    "        topTrailingRadius: \(top)",
                    "    ))",
                ]
            case .circle: lines.append("    .clipShape(.circle)")
            case .capsule: lines.append("    .clipShape(.capsule)")
            case .ellipse: lines.append("    .clipShape(.ellipse)")
            }
            return lines.joined(separator: "\n")
        } examples: {
            ExampleCard(
                title: "Circular profile photo",
                caption: "Use `.clipShape(.circle)` after a square `.frame` for a round profile photo.",
                code: """
                Image(systemName: "person.fill")
                    .resizable()
                    .scaledToFill()
                    .padding(18)
                    .foregroundStyle(.white)
                    .frame(width: 88, height: 88)
                    .background(.teal.gradient)
                    .clipShape(.circle)
                """,
                aside: Aside(.note, "For a real photo, use `.resizable()` and `.scaledToFill()` so it crops to the circle instead of squashing.")
            ) {
                Image(systemName: "person.fill")
                    .resizable()
                    .scaledToFill()
                    .padding(18)
                    .foregroundStyle(.white)
                    .frame(width: 88, height: 88)
                    .background(.teal.gradient)
                    .clipShape(.circle)
            }

            ExampleCard(
                title: "Rounded fill without clipping",
                caption: "Use `.background(_:in:)` when you only need a rounded fill, without clipping anything.",
                code: """
                Text("Rounded background")
                    .padding()
                    .background(.blue.opacity(0.15), in: .rect(cornerRadius: 12))
                """,
                aside: Aside(.note, "Nothing gets cut off, so a badge or shadow can still hang outside the shape.")
            ) {
                Text("Rounded background")
                    .padding()
                    .background(.blue.opacity(0.15), in: .rect(cornerRadius: 12))
            }

            ExampleCard(
                title: "Match the tap area",
                caption: "Add `.contentShape(.circle)` so only taps inside the visible circle count.",
                code: """
                Button {
                    // Play
                } label: {
                    Image(systemName: "play.fill")
                        .font(.title)
                        .foregroundStyle(.white)
                        .frame(width: 72, height: 72)
                        .background(.pink)
                        .clipShape(.circle)
                        .contentShape(.circle)
                }
                .buttonStyle(.plain)
                """,
                aside: Aside(.important, "Clipping is only visual. Without `contentShape`, taps in the square corners outside the circle still trigger the button.")
            ) {
                Button {
                } label: {
                    Image(systemName: "play.fill")
                        .font(.title)
                        .foregroundStyle(.white)
                        .frame(width: 72, height: 72)
                        .background(.pink)
                        .clipShape(.circle)
                        .contentShape(.circle)
                }
                .buttonStyle(.plain)
            }

            ExampleCard(
                title: "Concentric corners",
                caption: "Use `ConcentricRectangle` inside a `.containerShape` so inner corners keep an even gap.",
                code: """
                VStack {
                    ConcentricRectangle()
                        .fill(.blue.gradient)
                        .frame(height: 90)
                }
                .padding(10)
                .background(.fill.tertiary)
                .containerShape(.rect(cornerRadius: 32))
                .clipShape(.rect(cornerRadius: 32))
                """,
                aside: Aside(.note, "`ConcentricRectangle` is new in iOS 26. It subtracts the padding from the outer radius for you.")
            ) {
                VStack {
                    ConcentricRectangle()
                        .fill(.blue.gradient)
                        .frame(height: 90)
                }
                .padding(10)
                .background(.fill.tertiary)
                .containerShape(.rect(cornerRadius: 32))
                .clipShape(.rect(cornerRadius: 32))
                .frame(maxWidth: 260)
            }
        }
    }
}
