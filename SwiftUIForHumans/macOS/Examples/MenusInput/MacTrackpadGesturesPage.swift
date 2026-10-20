import SwiftUI

extension ComponentPage {
    static let trackpadGestures = ComponentPage(
        id: "trackpad-gestures",
        title: "Trackpad gestures",
        summary: "Zoom and rotate with trackpad gestures, plus a way to do both with a mouse.",
        category: .input,
        kind: .component,
        symbol: "hand.pinch",
        availability: ["macOS 14.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/magnifygesture",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/pointing-devices",
        aliases: ["pinch", "zoom", "magnify", "rotate", "MagnifyGesture", "RotateGesture", "MagnificationGesture", "RotationGesture", "NSMagnificationGestureRecognizer", "multitouch", "Magic Trackpad", "mouse", "two fingers", "wheel event"],
        related: ["hover", "drag-drop", "scroll-view", "animation"],
        notes: [
            "**Scrolling needs no code.** A `ScrollView` scrolls with a trackpad or a mouse; you only add gestures for zooming and rotating.",
            "**`MagnificationGesture` is deprecated.** So is `RotationGesture`. Use `MagnifyGesture` and `RotateGesture` instead.",
        ],
        api: [
            APIItem("`MagnifyGesture()`", "Pinch with two fingers to zoom."),
            APIItem("`RotateGesture()`", "Turn two fingers to rotate."),
            APIItem("`value.magnification`", "The scale since the gesture began."),
            APIItem("`value.rotation`", "The angle since the gesture began."),
            APIItem("`.simultaneously(with:)`", "Zoom and rotate in one motion."),
            APIItem("`.onScrollPhaseChange(_:)`", "Tells you when scrolling starts and stops."),
        ],
        guidelines: [
            Guideline(
                "Give mouse users another way.",
                "Pinching and rotating need a trackpad. Add buttons or menu commands that zoom and rotate, so everyone can reach the same result."
            ),
            Guideline(
                "Don't take over system gestures.",
                "People expect gestures like swiping up for Mission Control to work in every app, and they can customize them in System Settings."
            ),
            Guideline(
                "Make gestures behave as they do elsewhere.",
                "People expect a gesture to do the same thing in every app, like swiping between pages. A familiar gesture with a new meaning surprises them."
            ),
        ]
    ) {
        ZStack {
            SceneryView(.meadow)
                .frame(width: 150, height: 100)
                .clipShape(.rect(cornerRadius: 8))
                .rotationEffect(.degrees(-8))
            Image(systemName: "hand.pinch")
                .font(.system(size: 34))
                .foregroundStyle(.white)
                .shadow(radius: 3)
        }
    } content: { page in
        MacTrackpadGesturesDemo(page: page)
    }
}

private struct MacTrackpadConfig {
    var magnifies = true
    var rotates = true
    var showsButtons = true
    var scale = 1.0
    var baseScale = 1.0
    var angle = Angle.zero
    var baseAngle = Angle.zero
}

private struct MacTrackpadGesturesDemo: View {
    let page: ComponentPage

    var body: some View {
        DemoPage(
            page: page,
            initial: MacTrackpadConfig(),
            previewHeight: 280,
            usage: """
            @State private var scale = 1.0
            @State private var baseScale = 1.0

            Image("photo")
                .scaleEffect(scale)
                .gesture(
                    MagnifyGesture()
                        .onChanged { value in
                            scale = baseScale * value.magnification
                        }
                        .onEnded { _ in
                            baseScale = scale
                        }
                )
            """,
            usageNote: Aside(.important, "`value.magnification` starts at 1 for every new pinch. Multiply it by the scale you saved at the end of the last one, or each pinch jumps back to the original size.")
        ) { $config in
            VStack(spacing: 12) {
                SceneryView(.meadow)
                    .frame(width: 240, height: 160)
                    .clipShape(.rect(cornerRadius: 10))
                    .scaleEffect(config.scale)
                    .rotationEffect(config.angle)
                    .gesture(gesture($config), isEnabled: config.magnifies || config.rotates)
                    .frame(width: 300, height: 190)
                    .clipped()
                if config.showsButtons {
                    HStack {
                        Button("Zoom Out", systemImage: "minus.magnifyingglass") {
                            withAnimation(.snappy) { zoom(by: 0.8, $config) }
                        }
                        .help("Zoom out")
                        Button("Zoom In", systemImage: "plus.magnifyingglass") {
                            withAnimation(.snappy) { zoom(by: 1.25, $config) }
                        }
                        .help("Zoom in")
                        Button("Rotate Left", systemImage: "rotate.left") {
                            withAnimation(.snappy) {
                                config.angle -= .degrees(90)
                                config.baseAngle = config.angle
                            }
                        }
                        .help("Rotate left")
                    }
                    .labelStyle(.iconOnly)
                }
                Text("\(config.scale, format: .number.precision(.fractionLength(1)))× · \(Int(config.angle.degrees.rounded()))°")
                    .font(.footnote.monospaced())
                    .foregroundStyle(.secondary)
            }
        } controls: { $config in
            Section("Gestures") {
                Toggle("Pinch to zoom", isOn: $config.magnifies)
                Toggle("Rotate", isOn: $config.rotates)
            }
            Section("For a mouse") {
                Toggle("Zoom and rotate buttons", isOn: $config.showsButtons)
            }
        } code: { config in
            var lines: [String] = []
            if config.magnifies || config.showsButtons {
                lines += ["@State private var scale = 1.0", "@State private var baseScale = 1.0"]
            }
            if config.rotates || config.showsButtons {
                lines += ["@State private var angle = Angle.zero", "@State private var baseAngle = Angle.zero"]
            }
            lines.append("")
            lines.append("Image(\"photo\")")
            if config.magnifies || config.showsButtons { lines.append("    .scaleEffect(scale)") }
            if config.rotates || config.showsButtons { lines.append("    .rotationEffect(angle)") }
            let magnify = """
                    MagnifyGesture()
                        .onChanged { scale = baseScale * $0.magnification }
                        .onEnded { _ in baseScale = scale }
            """
            let rotate = """
                    RotateGesture()
                        .onChanged { angle = baseAngle + $0.rotation }
                        .onEnded { _ in baseAngle = angle }
            """
            if config.magnifies && config.rotates {
                lines.append("    .gesture(")
                lines.append(magnify)
                lines.append("        .simultaneously(with:")
                lines.append(rotate.split(separator: "\n").map { "    " + $0 }.joined(separator: "\n"))
                lines.append("        )")
                lines.append("    )")
            } else if config.magnifies {
                lines += ["    .gesture(", magnify, "    )"]
            } else if config.rotates {
                lines += ["    .gesture(", rotate, "    )"]
            }
            if config.showsButtons {
                lines += [
                    "",
                    "HStack {",
                    "    Button(\"Zoom Out\", systemImage: \"minus.magnifyingglass\") {",
                    "        scale *= 0.8; baseScale = scale",
                    "    }",
                    "    Button(\"Zoom In\", systemImage: \"plus.magnifyingglass\") {",
                    "        scale *= 1.25; baseScale = scale",
                    "    }",
                    "    Button(\"Rotate Left\", systemImage: \"rotate.left\") {",
                    "        angle -= .degrees(90); baseAngle = angle",
                    "    }",
                    "}",
                    ".labelStyle(.iconOnly)",
                ]
            }
            return lines.joined(separator: "\n")
        } examples: {
            MacTrackpadExamples()
        }
    }

    private func gesture(_ config: Binding<MacTrackpadConfig>) -> some Gesture {
        let magnify = MagnifyGesture()
            .onChanged { value in
                guard config.wrappedValue.magnifies else { return }
                config.wrappedValue.scale = min(max(config.wrappedValue.baseScale * value.magnification, 0.5), 4)
            }
            .onEnded { _ in config.wrappedValue.baseScale = config.wrappedValue.scale }
        let rotate = RotateGesture()
            .onChanged { value in
                guard config.wrappedValue.rotates else { return }
                config.wrappedValue.angle = config.wrappedValue.baseAngle + value.rotation
            }
            .onEnded { _ in config.wrappedValue.baseAngle = config.wrappedValue.angle }
        return magnify.simultaneously(with: rotate)
    }

    private func zoom(by factor: Double, _ config: Binding<MacTrackpadConfig>) {
        config.wrappedValue.scale = min(max(config.wrappedValue.scale * factor, 0.5), 4)
        config.wrappedValue.baseScale = config.wrappedValue.scale
    }
}

// MARK: - Examples

private struct MacTrackpadExamples: View {
    @State private var angle = Angle.zero
    @State private var baseAngle = Angle.zero
    @State private var isScrolling = false

    var body: some View {
        ExampleCard(
            title: "Rotate and snap to a right angle",
            caption: "Follow `RotateGesture` while the fingers turn, then snap to the nearest 90° when they lift, like straightening a photo.",
            code: """
            @State private var angle = Angle.zero
            @State private var baseAngle = Angle.zero

            Image("photo")
                .rotationEffect(angle)
                .gesture(
                    RotateGesture()
                        .onChanged { angle = baseAngle + $0.rotation }
                        .onEnded { _ in
                            let quarterTurns = (angle.degrees / 90).rounded()
                            withAnimation(.snappy) {
                                angle = .degrees(quarterTurns * 90)
                            }
                            baseAngle = angle
                        }
                )
            """,
            minHeight: 240
        ) {
            SceneryView(.lake)
                .frame(width: 210, height: 140)
                .clipShape(.rect(cornerRadius: 10))
                .rotationEffect(angle)
                .gesture(
                    RotateGesture()
                        .onChanged { angle = baseAngle + $0.rotation }
                        .onEnded { _ in
                            let quarterTurns = (angle.degrees / 90).rounded()
                            withAnimation(.snappy) {
                                angle = .degrees(quarterTurns * 90)
                            }
                            baseAngle = angle
                        }
                )
                .frame(width: 240, height: 220)
        }

        ExampleCard(
            title: "Know when scrolling stops",
            caption: "`.onScrollPhaseChange` reports when a scroll starts and ends, from a trackpad or a mouse wheel alike.",
            code: """
            @State private var isScrolling = false

            ScrollView {
                LazyVStack {
                    ForEach(1...40, id: \\.self) { Text("Row \\($0)") }
                }
            }
            .onScrollPhaseChange { _, phase in
                isScrolling = phase.isScrolling
            }
            """,
            minHeight: 200
        ) {
            VStack(spacing: 10) {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 6) {
                        ForEach(1...40, id: \.self) { Text("Row \($0)") }
                    }
                    .padding(10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .onScrollPhaseChange { _, phase in
                    isScrolling = phase.isScrolling
                }
                .frame(width: 260, height: 140)
                .background(.fill.quaternary, in: .rect(cornerRadius: 10))
                Text(isScrolling ? "Scrolling…" : "Idle")
                    .font(.footnote.monospaced())
                    .foregroundStyle(.secondary)
            }
        }

        VStack(alignment: .leading, spacing: 14) {
            Text("Trackpad or mouse")
                .font(.title3.bold())
                .outlineEntry("Trackpad or mouse", level: 2)
            RichText("Some gestures work on both, and some only on a trackpad. From the Human Interface Guidelines:")
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            ConnectFacts(rows: [
                ("Both", "Click, secondary click for context menus, scrolling, smart zoom, and swiping between pages."),
                ("Trackpad only", "Pinch to zoom, two-finger rotate, tap to click, and force click."),
            ])
        }
    }
}
