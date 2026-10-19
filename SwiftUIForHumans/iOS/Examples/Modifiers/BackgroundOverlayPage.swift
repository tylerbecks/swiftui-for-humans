import SwiftUI

extension ComponentPage {
    static let backgroundOverlay = ComponentPage(
        id: "background-overlay",
        title: "background & overlay",
        summary: "Layers a color, shape, or view behind or on top of a view, sized to match it.",
        category: .modifiers,
        kind: .modifier,
        symbol: "square.2.layers.3d",
        availability: ["iOS 15.0+", "macOS 12.0+", "visionOS 1.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/view/background(alignment:content:)",
        aliases: ["background-color", "bg", "z-index", "position: absolute", "badge", "layer", "border", "ZStack", "::before", "::after"],
        related: ["modifier-order", "clip-shape", "shapes", "materials"],
        notes: [
            "**A background or overlay never changes the view's size.** Unlike a `ZStack`, it takes the size of the view it's attached to, so it's ideal for decoration.",
            "**A color background spreads under the safe area.** When `.background(Color)` touches the screen edge, it extends behind the status bar. Pass `ignoresSafeAreaEdges: []` to stop it.",
        ],
        api: [
            APIItem("`.background(_:in:)`", "Fills a shape behind the view, like `.capsule`."),
            APIItem("`.background { }`", "Puts any view behind, sized to match."),
            APIItem("`.overlay(alignment:) { }`", "Puts any view on top, pinned to an edge or corner."),
            APIItem("`.overlay { Shape().strokeBorder() }`", "Draws an outline that lines up with the fill."),
            APIItem("`.background(.ultraThinMaterial)`", "A blurred, translucent backdrop."),
        ]
    ) {
        Image(systemName: "envelope.fill")
            .font(.system(size: 34))
            .foregroundStyle(.white)
            .frame(width: 76, height: 76)
            .background(.blue.gradient, in: .rect(cornerRadius: 20))
            .overlay(alignment: .topTrailing) {
                Text("3")
                    .font(.callout.bold())
                    .foregroundStyle(.white)
                    .frame(width: 28, height: 28)
                    .background(.red, in: .circle)
                    .offset(x: 9, y: -9)
            }
    } content: { page in
        BackgroundOverlayDemo(page: page)
    }
}

private struct BGConfig {
    var background: BGKind = .shapeFill
    var color: BGColor = .blue
    var overlay: OverlayKind = .badge
    var alignment: OverlayAlignment = .topTrailing
}

private enum BGKind: DemoOption {
    case none, color, shapeFill, gradient, view

    var label: String {
        switch self {
        case .none: "None"
        case .color: "Color"
        case .shapeFill: "Color in a shape"
        case .gradient: "Gradient"
        case .view: "Any view"
        }
    }

    /// Solid fills get white text so the label stays readable.
    var isFilled: Bool { self == .color || self == .shapeFill || self == .gradient }
}

private enum BGColor: DemoOption {
    case blue, orange, green, purple

    var label: String {
        switch self {
        case .blue: ".blue"
        case .orange: ".orange"
        case .green: ".green"
        case .purple: ".purple"
        }
    }

    var color: Color {
        switch self {
        case .blue: .blue
        case .orange: .orange
        case .green: .green
        case .purple: .purple
        }
    }
}

private enum OverlayKind: DemoOption {
    case none, badge, stroke, label

    var label: String {
        switch self {
        case .none: "None"
        case .badge: "Badge"
        case .stroke: "Stroke"
        case .label: "Text label"
        }
    }
}

private enum OverlayAlignment: DemoOption {
    case topLeading, topTrailing, center, bottomLeading, bottomTrailing

    var label: String {
        switch self {
        case .topLeading: ".topLeading"
        case .topTrailing: ".topTrailing"
        case .center: ".center"
        case .bottomLeading: ".bottomLeading"
        case .bottomTrailing: ".bottomTrailing"
        }
    }

    var value: Alignment {
        switch self {
        case .topLeading: .topLeading
        case .topTrailing: .topTrailing
        case .center: .center
        case .bottomLeading: .bottomLeading
        case .bottomTrailing: .bottomTrailing
        }
    }
}

private extension View {
    @ViewBuilder
    func demoBackground(_ config: BGConfig) -> some View {
        let color = config.color.color
        switch config.background {
        case .none: self
        case .color: background(color)
        case .shapeFill: background(color, in: .rect(cornerRadius: 16))
        case .gradient: background(color.gradient, in: .rect(cornerRadius: 16))
        case .view:
            background {
                Circle()
                    .fill(color)
                    .frame(width: 140, height: 140)
                    .blur(radius: 20)
            }
        }
    }

    @ViewBuilder
    func demoOverlay(_ config: BGConfig) -> some View {
        let alignment = config.alignment.value
        switch config.overlay {
        case .none: self
        case .badge:
            overlay(alignment: alignment) {
                Circle()
                    .fill(.red)
                    .frame(width: 16, height: 16)
                    .offset(x: alignment.horizontal == .leading ? -5 : alignment.horizontal == .trailing ? 5 : 0,
                            y: alignment.vertical == .top ? -5 : alignment.vertical == .bottom ? 5 : 0)
            }
        case .stroke:
            overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(.primary, lineWidth: 2)
            }
        case .label:
            overlay(alignment: alignment) {
                Text("NEW")
                    .font(.caption2.bold())
                    .padding(4)
                    .background(.yellow, in: .rect(cornerRadius: 4))
                    .foregroundStyle(.black)
            }
        }
    }
}

private struct BackgroundOverlayDemo: View {
    let page: ComponentPage

    var body: some View {
        DemoPage(
            page: page,
            initial: BGConfig(),
            usage: """
            Label("Inbox", systemImage: "tray.fill")
                .padding()
                .background(.blue.opacity(0.15), in: .capsule)
                .overlay(alignment: .topTrailing) {
                    Circle()
                        .fill(.red)
                        .frame(width: 12, height: 12)
                }
            """,
            usageNote: Aside(.note, "`.background(_:in:)` fills a shape in one step, without clipping the content the way `.clipShape` would.")
        ) { $config in
            Label("Inbox", systemImage: "tray.fill")
                .font(.title2.weight(.semibold))
                .foregroundStyle(config.background.isFilled ? AnyShapeStyle(.white) : AnyShapeStyle(.primary))
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                .demoBackground(config)
                .demoOverlay(config)
                .animation(.snappy, value: config.alignment)
        } controls: { $config in
            Section("Background") {
                OptionPicker("Background", selection: $config.background)
                if config.background != .none {
                    OptionPicker("Color", selection: $config.color)
                }
            }
            Section("Overlay") {
                OptionPicker("Overlay", selection: $config.overlay)
                if config.overlay == .badge || config.overlay == .label {
                    OptionPicker("Alignment", selection: $config.alignment)
                }
            }
        } code: { config in
            var lines = [
                "Label(\"Inbox\", systemImage: \"tray.fill\")",
                "    .font(.title2.weight(.semibold))",
            ]
            if config.background.isFilled {
                lines.append("    .foregroundStyle(.white)")
            }
            lines += ["    .padding(.horizontal, 24)", "    .padding(.vertical, 16)"]
            let c = config.color.label
            switch config.background {
            case .none: break
            case .color: lines.append("    .background(\(c))")
            case .shapeFill: lines.append("    .background(\(c), in: .rect(cornerRadius: 16))")
            case .gradient: lines.append("    .background(\(c).gradient, in: .rect(cornerRadius: 16))")
            case .view:
                lines += [
                    "    .background {",
                    "        Circle()",
                    "            .fill(\(c))",
                    "            .frame(width: 140, height: 140)",
                    "            .blur(radius: 20)",
                    "    }",
                ]
            }
            let alignArg = config.alignment == .center ? "" : "(alignment: \(config.alignment.label))"
            switch config.overlay {
            case .none: break
            case .badge:
                let a = config.alignment.value
                let x = a.horizontal == .leading ? -5 : a.horizontal == .trailing ? 5 : 0
                let y = a.vertical == .top ? -5 : a.vertical == .bottom ? 5 : 0
                lines += [
                    "    .overlay\(alignArg) {",
                    "        Circle()",
                    "            .fill(.red)",
                    "            .frame(width: 16, height: 16)",
                ]
                if x != 0 || y != 0 {
                    lines.append("            .offset(x: \(x), y: \(y))")
                }
                lines.append("    }")
            case .stroke:
                lines += [
                    "    .overlay {",
                    "        RoundedRectangle(cornerRadius: 16)",
                    "            .stroke(.primary, lineWidth: 2)",
                    "    }",
                ]
            case .label:
                lines += [
                    "    .overlay\(alignArg) {",
                    "        Text(\"NEW\")",
                    "            .font(.caption2.bold())",
                    "            .padding(4)",
                    "            .background(.yellow, in: .rect(cornerRadius: 4))",
                    "            .foregroundStyle(.black)",
                    "    }",
                ]
            }
            return lines.joined(separator: "\n")
        } examples: {
            ExampleCard(
                title: "Avatar with a status dot",
                caption: "Use `.overlay(alignment:)` to pin a status dot to an avatar's corner.",
                code: """
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(.gray)
                    .overlay(alignment: .bottomTrailing) {
                        Circle()
                            .fill(.green)
                            .frame(width: 18, height: 18)
                            .padding(3)
                            .background(.background, in: .circle)
                    }
                """,
                aside: Aside(.note, "The `.background(.background, in: .circle)` behind the dot draws a ring in the page color, so the dot stands out in light and dark.")
            ) {
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(.gray)
                    .overlay(alignment: .bottomTrailing) {
                        Circle()
                            .fill(.green)
                            .frame(width: 18, height: 18)
                            .padding(3)
                            .background(.background, in: .circle)
                    }
            }

            ExampleCard(
                title: "Notification badge",
                caption: "Pin a count to a corner with `.overlay(alignment: .topTrailing)`, then nudge it with `.offset`.",
                code: """
                Image(systemName: "envelope.fill")
                    .font(.system(size: 30))
                    .foregroundStyle(.white)
                    .frame(width: 64, height: 64)
                    .background(.blue.gradient, in: .rect(cornerRadius: 16))
                    .overlay(alignment: .topTrailing) {
                        Text("3")
                            .font(.callout.bold())
                            .foregroundStyle(.white)
                            .frame(width: 26, height: 26)
                            .background(.red, in: .circle)
                            .offset(x: 8, y: -8)
                    }
                """
            ) {
                Image(systemName: "envelope.fill")
                    .font(.system(size: 30))
                    .foregroundStyle(.white)
                    .frame(width: 64, height: 64)
                    .background(.blue.gradient, in: .rect(cornerRadius: 16))
                    .overlay(alignment: .topTrailing) {
                        Text("3")
                            .font(.callout.bold())
                            .foregroundStyle(.white)
                            .frame(width: 26, height: 26)
                            .background(.red, in: .circle)
                            .offset(x: 8, y: -8)
                    }
            }

            ExampleCard(
                title: "Caption over an image",
                caption: "Put text in an `.overlay` with a dark gradient behind it, so it stays readable on any photo.",
                code: """
                LinearGradient(colors: [.teal, .indigo], startPoint: .topLeading, endPoint: .bottomTrailing)
                    .frame(height: 140)
                    .overlay(alignment: .bottomLeading) {
                        Text("Big Sur, California")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(.linearGradient(colors: [.clear, .black.opacity(0.6)], startPoint: .top, endPoint: .bottom))
                    }
                    .clipShape(.rect(cornerRadius: 16))
                """,
                aside: Aside(.important, "White text straight on a photo disappears on bright areas. Always add a scrim or a material behind it.")
            ) {
                LinearGradient(colors: [.teal, .indigo], startPoint: .topLeading, endPoint: .bottomTrailing)
                    .frame(height: 140)
                    .overlay(alignment: .bottomLeading) {
                        Text("Big Sur, California")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(.linearGradient(colors: [.clear, .black.opacity(0.6)], startPoint: .top, endPoint: .bottom))
                    }
                    .clipShape(.rect(cornerRadius: 16))
            }

            ExampleCard(
                title: "Outline with a stroke overlay",
                caption: "Pair a fill with an `.overlay` of `Capsule().strokeBorder()` for an outlined pill.",
                code: """
                Text("Outlined")
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(.blue.opacity(0.1), in: .capsule)
                    .overlay {
                        Capsule()
                            .strokeBorder(.blue, lineWidth: 1.5)
                    }
                """,
                aside: Aside(.note, "`strokeBorder` draws inside the shape's edge. `stroke` straddles it, so half the line hangs outside the fill.")
            ) {
                Text("Outlined")
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(.blue.opacity(0.1), in: .capsule)
                    .overlay {
                        Capsule()
                            .strokeBorder(.blue, lineWidth: 1.5)
                    }
            }
        }
    }
}
