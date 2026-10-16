import SwiftUI

extension ComponentPage {
    static let visualEffects = ComponentPage(
        id: "visual-effects",
        title: "Visual Effects",
        summary: "Fade, blur, scale, rotate, move, and desaturate a view without changing its layout.",
        category: .modifiers,
        kind: .modifier,
        symbol: "camera.filters",
        availability: ["iOS 13.0+", "macOS 10.15+", "visionOS 1.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/view-graphics-and-rendering",
        aliases: ["opacity", "blur", "transform", "scale", "rotate", "translate", "filter: grayscale", "CSS transform", "CGAffineTransform", "alpha"],
        related: ["modifier-order", "spring", "transitions", "shadow"],
        notes: [
            "**Use `offset` for nudges, not layout.** To really move something, change the layout with `padding`, stacks, or `frame(alignment:)`.",
            "**`opacity(0)` still takes up space.** Remove the view with `if` when it should be gone from the layout.",
            "**Everything here animates.** Change the value inside `withAnimation` and SwiftUI blends between the old and new values.",
        ],
        api: [
            APIItem("`.opacity(_:)`", "Fades the view, from `0` (invisible) to `1`."),
            APIItem("`.blur(radius:)`", "Blurs the view, like CSS `filter: blur()`."),
            APIItem("`.scaleEffect(_:anchor:)`", "Grows or shrinks the drawing around an anchor point."),
            APIItem("`.rotationEffect(_:anchor:)`", "Rotates the drawing, by default around the center."),
            APIItem("`.offset(x:y:)`", "Moves the drawing without moving its layout slot."),
            APIItem("`.grayscale(_:)`", "Removes color, from `0` (none) to `1` (full gray)."),
        ]
    ) {
        HStack(spacing: 10) {
            VisualTile().opacity(0.4)
            VisualTile().blur(radius: 3)
            VisualTile().rotationEffect(.degrees(-12))
            VisualTile().grayscale(1)
        }
        .scaleEffect(0.95)
    } content: { page in
        VisualEffectsDemo(page: page)
    }
}

/// A small colorful square used by the thumbnail.
private struct VisualTile: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(.linearGradient(colors: [.pink, .orange], startPoint: .topLeading, endPoint: .bottomTrailing))
            .frame(width: 46, height: 46)
            .overlay {
                Image(systemName: "star.fill")
                    .foregroundStyle(.white)
            }
    }
}

private struct VisualConfig: Equatable {
    var opacity = 1.0
    var blur = 0.0
    var scale = 1.0
    var rotation = 0.0
    var offsetX = 0.0
    var offsetY = 0.0
    var grayscale = 0.0
    var showSlot = true
}

private struct VisualEffectsDemo: View {
    let page: ComponentPage

    var body: some View {
        DemoPage(
            page: page,
            initial: VisualConfig(),
            previewHeight: 300,
            usage: """
            @State private var isDimmed = false

            Image(systemName: "star.fill")
                .font(.largeTitle)
                .opacity(isDimmed ? 0.3 : 1)
                .scaleEffect(isDimmed ? 0.8 : 1)
                .onTapGesture {
                    withAnimation { isDimmed.toggle() }
                }
            """,
            usageNote: Aside(.note, "Like CSS `transform` and `filter`, these change how a view is drawn, not where it sits in the layout. Its neighbors never move.")
        ) { $config in
            VStack(spacing: 24) {
                HStack(spacing: 12) {
                    neighbor
                    card
                        .opacity(config.opacity)
                        .blur(radius: config.blur)
                        .scaleEffect(config.scale)
                        .rotationEffect(.degrees(config.rotation))
                        .offset(x: config.offsetX, y: config.offsetY)
                        .grayscale(config.grayscale)
                        .overlay {
                            if config.showSlot {
                                RoundedRectangle(cornerRadius: 20)
                                    .strokeBorder(.secondary, style: StrokeStyle(lineWidth: 1.5, dash: [5, 4]))
                            }
                        }
                    neighbor
                }
                .animation(.snappy, value: config)
                if config.showSlot {
                    Text("The dashed outline is the card's layout slot. Its neighbors never move.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
        } controls: { $config in
            Section("Effects") {
                ValueSlider("opacity", value: $config.opacity, in: 0...1)
                ValueSlider("blur", value: $config.blur, in: 0...20, step: 0.5)
                ValueSlider("scaleEffect", value: $config.scale, in: 0.3...1.6)
                ValueSlider("rotationEffect (degrees)", value: $config.rotation, in: -180...180, step: 1)
                ValueSlider("offset x", value: $config.offsetX, in: -80...80, step: 1)
                ValueSlider("offset y", value: $config.offsetY, in: -80...80, step: 1)
                ValueSlider("grayscale", value: $config.grayscale, in: 0...1)
            }
            Section("Visualize") {
                Toggle("Show layout slot", isOn: $config.showSlot)
            }
        } code: { config in
            var lines = [
                "RoundedRectangle(cornerRadius: 20)",
                "    .fill(.linearGradient(colors: [.pink, .orange], startPoint: .topLeading, endPoint: .bottomTrailing))",
                "    .frame(width: 120, height: 120)",
                "    .overlay {",
                "        Image(systemName: \"star.fill\")",
                "            .font(.largeTitle)",
                "            .foregroundStyle(.white)",
                "    }",
            ]
            if config.opacity != 1 { lines.append("    .opacity(\(swiftNumber(config.opacity)))") }
            if config.blur != 0 { lines.append("    .blur(radius: \(swiftNumber(config.blur)))") }
            if config.scale != 1 { lines.append("    .scaleEffect(\(swiftNumber(config.scale)))") }
            if config.rotation != 0 { lines.append("    .rotationEffect(.degrees(\(swiftNumber(config.rotation))))") }
            if config.offsetX != 0 || config.offsetY != 0 {
                lines.append("    .offset(x: \(swiftNumber(config.offsetX)), y: \(swiftNumber(config.offsetY)))")
            }
            if config.grayscale != 0 { lines.append("    .grayscale(\(swiftNumber(config.grayscale)))") }
            return lines.joined(separator: "\n")
        } examples: {
            ExampleCard(
                title: "Press to shrink",
                caption: "Use `.scaleEffect` in a custom `ButtonStyle` so the button shrinks while it's pressed.",
                code: """
                struct PressScaleStyle: ButtonStyle {
                    func makeBody(configuration: Configuration) -> some View {
                        configuration.label
                            .font(.headline)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(.blue, in: .capsule)
                            .scaleEffect(configuration.isPressed ? 0.92 : 1)
                            .opacity(configuration.isPressed ? 0.8 : 1)
                            .animation(.snappy, value: configuration.isPressed)
                    }
                }

                Button("Press me") {}
                    .buttonStyle(PressScaleStyle())
                """,
                aside: Aside(.note, "`configuration.isPressed` is `true` while a finger is down. Press and hold to see it.")
            ) {
                Button("Press me") {}
                    .buttonStyle(VisualPressScaleStyle())
            }

            ExampleCard(
                title: "Tap to reveal",
                caption: "Animate `.blur(radius:)` to hide a spoiler until someone taps it.",
                code: """
                @State private var isRevealed = false

                Text("The butler did it.")
                    .font(.title3.weight(.semibold))
                    .blur(radius: isRevealed ? 0 : 8)
                    .onTapGesture {
                        withAnimation { isRevealed.toggle() }
                    }
                """
            ) {
                VisualSpoilerExample()
            }

            ExampleCard(
                title: "Rotating chevron",
                caption: "Animate `.rotationEffect` on a chevron to show that a section is expanded.",
                code: """
                @State private var isExpanded = false

                Button {
                    withAnimation(.snappy) { isExpanded.toggle() }
                } label: {
                    HStack {
                        Text("Details")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .rotationEffect(.degrees(isExpanded ? 90 : 0))
                    }
                }
                """
            ) {
                VisualChevronExample()
                    .frame(maxWidth: 260)
            }

            ExampleCard(
                title: "Unavailable item",
                caption: "Combine `.grayscale(1)` and `.opacity(0.5)` to show that an item isn't available.",
                code: """
                HStack(spacing: 24) {
                    Label("In stock", systemImage: "bag.fill")
                        .font(.title2.bold())
                        .foregroundStyle(.orange)
                    Label("Sold out", systemImage: "bag.fill")
                        .font(.title2.bold())
                        .foregroundStyle(.orange)
                        .grayscale(1)
                        .opacity(0.5)
                }
                """,
                aside: Aside(.important, "This only changes the look. For a control people shouldn't use, add `.disabled(true)` so it also ignores taps and VoiceOver reports it as dimmed.")
            ) {
                HStack(spacing: 24) {
                    Label("In stock", systemImage: "bag.fill")
                        .font(.title2.bold())
                        .foregroundStyle(.orange)
                    Label("Sold out", systemImage: "bag.fill")
                        .font(.title2.bold())
                        .foregroundStyle(.orange)
                        .grayscale(1)
                        .opacity(0.5)
                }
            }
        }
    }

    private var card: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(.linearGradient(colors: [.pink, .orange], startPoint: .topLeading, endPoint: .bottomTrailing))
            .frame(width: 120, height: 120)
            .overlay {
                Image(systemName: "star.fill")
                    .font(.largeTitle)
                    .foregroundStyle(.white)
            }
    }

    private var neighbor: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(.fill.tertiary)
            .frame(width: 44, height: 120)
    }
}

private struct VisualPressScaleStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(.blue, in: .capsule)
            .scaleEffect(configuration.isPressed ? 0.92 : 1)
            .opacity(configuration.isPressed ? 0.8 : 1)
            .animation(.snappy, value: configuration.isPressed)
    }
}

private struct VisualSpoilerExample: View {
    @State private var isRevealed = false

    var body: some View {
        Text("The butler did it.")
            .font(.title3.weight(.semibold))
            .blur(radius: isRevealed ? 0 : 8)
            .onTapGesture {
                withAnimation { isRevealed.toggle() }
            }
    }
}

private struct VisualChevronExample: View {
    @State private var isExpanded = false

    var body: some View {
        Button {
            withAnimation(.snappy) { isExpanded.toggle() }
        } label: {
            HStack {
                Text("Details")
                Spacer()
                Image(systemName: "chevron.right")
                    .rotationEffect(.degrees(isExpanded ? 90 : 0))
            }
        }
    }
}
