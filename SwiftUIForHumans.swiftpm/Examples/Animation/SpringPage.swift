import SwiftUI

extension ComponentPage {
    static let spring = ComponentPage(
        id: "spring",
        title: "Spring",
        summary: "A natural, physics-based animation set by how long it takes and how much it bounces.",
        category: .animation,
        symbol: "point.bottomleft.forward.to.arrow.triangle.scurvepath",
        availability: ["iOS 17.0+", "macOS 14.0+", "visionOS 1.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/spring",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/motion",
        aliases: ["bounce", "easing", "physics", "react-spring", "damping", "stiffness", "usingSpringWithDamping", "animation curve", "snappy"],
        related: ["animation-curves", "transitions", "keyframe-animator", "haptics"],
        notes: [
            "**`duration` and `bounce` replace stiffness and damping.** If you know react-spring or UIKit's damping ratio, think \"how long\" and \"how springy\" instead; SwiftUI converts for you.",
            "**Springs are the default.** `withAnimation { }` with no argument already uses a smooth spring, so reach for a preset before tuning numbers.",
        ],
        api: [
            APIItem("`.spring(duration:bounce:)`", "A spring with your own settle time and bounce."),
            APIItem("`.smooth`", "No overshoot. A calm default for most changes."),
            APIItem("`.snappy`", "A little overshoot. Quick and responsive."),
            APIItem("`.bouncy`", "The most overshoot. Playful moments only."),
            APIItem("`.bouncy(duration:extraBounce:)`", "Tunes a preset without leaving it."),
            APIItem("`.interactiveSpring()`", "A fast spring for views that track a finger."),
            APIItem("`Spring.settlingDuration`", "How long a spring really takes to come to rest."),
        ],
        guidelines: [
            Guideline(
                "Keep the bounce small in everyday UI.",
                "A little overshoot feels lively and confirms the change. A lot of it looks cartoonish and slows people down.",
                good: "`bounce: 0.15` settles quickly. Tap Play.",
                bad: "`bounce: 0.8` wobbles long after the tap."
            ) {
                BounceSample(bounce: 0.15)
            } bad: {
                BounceSample(bounce: 0.8)
            },
            Guideline(
                "Make motion match the gesture.",
                "A card dragged down should settle back down, and a view that slid in from the bottom should leave the same way. Motion that contradicts the gesture disorients people."
            ),
            Guideline(
                "Never make people wait for an animation.",
                "Keep the interface usable while things move. Springs pick up from wherever they are when interrupted, so you rarely need to block input."
            ),
        ]
    ) {
        SpringCurve(spring: .bouncy)
            .frame(width: 180, height: 90)
    } content: { page in
        SpringDemo(page: page)
    }
}

private struct SpringConfig {
    var duration = 0.5
    var bounce = 0.3
    var isMoved = false
}

private struct SpringDemo: View {
    let page: ComponentPage

    var body: some View {
        DemoPage(
            page: page,
            initial: SpringConfig(),
            usage: """
            @State private var isLiked = false

            Image(systemName: isLiked ? "heart.fill" : "heart")
                .font(.largeTitle)
                .foregroundStyle(.pink)
                .scaleEffect(isLiked ? 1.2 : 1)
                .onTapGesture {
                    withAnimation(.spring(duration: 0.4, bounce: 0.5)) {
                        isLiked.toggle()
                    }
                }
            """,
            usageNote: Aside(.note, "`bounce` runs from `0` (no overshoot) to just under `1`. Negative values make the spring slower and heavier, with no overshoot.")
        ) { $config in
            let spring = Spring(duration: config.duration, bounce: config.bounce)
            VStack(spacing: 20) {
                SpringCurve(spring: spring)
                    .frame(height: 140)

                Capsule()
                    .fill(.fill.tertiary)
                    .frame(height: 56)
                    .overlay(alignment: config.isMoved ? .trailing : .leading) {
                        Circle()
                            .fill(.tint)
                            .padding(6)
                    }

                HStack {
                    Text("Settles in about \(swiftNumber(spring.settlingDuration))s")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                    Spacer()
                    Button("Play", systemImage: "play.fill") {
                        withAnimation(.spring(spring)) {
                            config.isMoved.toggle()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .frame(maxWidth: 480)
        } controls: { $config in
            Section("Parameters") {
                ValueSlider("Duration", value: $config.duration, in: 0.1...2)
                ValueSlider("Bounce", value: $config.bounce, in: -1...0.95)
            }
            Section("Presets") {
                ForEach(SpringPreset.allCases) { preset in
                    Button(preset.label) {
                        withAnimation {
                            config.duration = preset.duration
                            config.bounce = preset.bounce
                        }
                    }
                }
            }
        } code: { config in
            let animation = SpringPreset.matching(config)
                .map { ".\($0.label)" }
                ?? ".spring(duration: \(swiftNumber(config.duration)), bounce: \(swiftNumber(config.bounce)))"
            return """
            @State private var isMoved = false

            VStack(spacing: 20) {
                Circle()
                    .fill(.tint)
                    .frame(width: 44, height: 44)
                    .frame(maxWidth: .infinity, alignment: isMoved ? .trailing : .leading)

                Button("Play") {
                    withAnimation(\(animation)) {
                        isMoved.toggle()
                    }
                }
            }

            // Or animate one view whenever a value changes:
            // .animation(\(animation), value: isMoved)
            """
        } examples: {
            ExampleCard(
                title: "The presets, side by side",
                caption: "Use the `.smooth`, `.snappy`, and `.bouncy` presets; they take the same time and differ only in overshoot.",
                code: """
                @State private var isMoved = false

                VStack {
                    Circle().frame(width: 28, height: 28)
                        .frame(maxWidth: .infinity, alignment: isMoved ? .trailing : .leading)
                        .animation(.smooth, value: isMoved)
                    Circle().frame(width: 28, height: 28)
                        .frame(maxWidth: .infinity, alignment: isMoved ? .trailing : .leading)
                        .animation(.snappy, value: isMoved)
                    Circle().frame(width: 28, height: 28)
                        .frame(maxWidth: .infinity, alignment: isMoved ? .trailing : .leading)
                        .animation(.bouncy, value: isMoved)
                    Button("Play") { isMoved.toggle() }
                }
                """,
                aside: Aside(.note, "Start with `.smooth` for layout changes and `.snappy` for taps. Save `.bouncy` for playful moments like a like or a reward.")
            ) {
                PresetRace()
            }

            ExampleCard(
                title: "Drag and snap back",
                caption: "Track a `DragGesture` directly, then let `.spring(duration:bounce:)` carry the card home on release.",
                code: """
                @State private var offset = CGSize.zero

                RoundedRectangle(cornerRadius: 20)
                    .fill(.indigo.gradient)
                    .frame(width: 120, height: 120)
                    .offset(offset)
                    .gesture(
                        DragGesture()
                            .onChanged { offset = $0.translation }
                            .onEnded { _ in
                                withAnimation(.spring(duration: 0.5, bounce: 0.4)) {
                                    offset = .zero
                                }
                            }
                    )
                """,
                minHeight: 260,
                aside: Aside(.note, "Springs keep their momentum when interrupted. Grab the card while it's still moving and it follows your finger without a jump.")
            ) {
                DragSnapBack()
            }

            ExampleCard(
                title: "Springy press effect",
                caption: "Scale a custom `ButtonStyle` on `isPressed`, and let `.animation(_:value:)` spring it back on release.",
                code: """
                struct SquishyButtonStyle: ButtonStyle {
                    func makeBody(configuration: Configuration) -> some View {
                        configuration.label
                            .padding(.horizontal, 24)
                            .padding(.vertical, 14)
                            .background(.pink.gradient, in: .capsule)
                            .foregroundStyle(.white)
                            .scaleEffect(configuration.isPressed ? 0.88 : 1)
                            .animation(.bouncy(duration: 0.3, extraBounce: 0.2), value: configuration.isPressed)
                    }
                }

                Button("Hold me") {}
                    .buttonStyle(SquishyButtonStyle())
                """,
                minHeight: 120
            ) {
                Button("Hold me") {}
                    .font(.headline)
                    .buttonStyle(SquishyButtonStyle())
            }
        }
    }
}

private enum SpringPreset: DemoOption {
    case smooth, snappy, bouncy

    var label: String {
        switch self {
        case .smooth: "smooth"
        case .snappy: "snappy"
        case .bouncy: "bouncy"
        }
    }

    var duration: Double { 0.5 }

    var bounce: Double {
        switch self {
        case .smooth: 0
        case .snappy: 0.15
        case .bouncy: 0.3
        }
    }

    static func matching(_ config: SpringConfig) -> SpringPreset? {
        allCases.first {
            abs($0.duration - config.duration) < 0.001 && abs($0.bounce - config.bounce) < 0.001
        }
    }
}

/// Plots the spring's value over time: it starts at 0 and settles at the
/// target (the dashed line). Overshoot above the line is the bounce.
private struct SpringCurve: View {
    let spring: Spring

    var body: some View {
        Canvas { context, size in
            let end = min(max(spring.settlingDuration, 0.1) * 1.1, 4)
            let samples = 160
            let values = (0...samples).map { i in
                spring.value(target: 1.0, time: end * Double(i) / Double(samples))
            }
            let low = min(0, values.min() ?? 0)
            let high = max(1, values.max() ?? 1)

            // Inset so the stroke at the peak and the start isn't clipped.
            let inset = 3.0
            func y(_ value: Double) -> CGFloat {
                inset + (size.height - inset * 2) * (1 - (value - low) / (high - low))
            }

            var target = Path()
            target.move(to: CGPoint(x: 0, y: y(1)))
            target.addLine(to: CGPoint(x: size.width, y: y(1)))
            context.stroke(target, with: .style(.secondary), style: StrokeStyle(lineWidth: 1, dash: [4, 4]))

            var curve = Path()
            for (i, value) in values.enumerated() {
                let point = CGPoint(x: size.width * Double(i) / Double(samples), y: y(value))
                if i == 0 { curve.move(to: point) } else { curve.addLine(to: point) }
            }
            context.stroke(curve, with: .style(.tint), style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
        }
        .accessibilityLabel("Spring curve")
    }
}

// MARK: - Examples

private struct PresetRace: View {
    @State private var isMoved = false

    var body: some View {
        VStack(spacing: 10) {
            ForEach(SpringPreset.allCases) { preset in
                HStack(spacing: 10) {
                    Text(".\(preset.label)")
                        .font(.caption.monospaced())
                        .foregroundStyle(.secondary)
                        .frame(width: 64, alignment: .leading)
                    Capsule()
                        .fill(.fill.tertiary)
                        .frame(height: 36)
                        .overlay {
                            Circle()
                                .fill(.tint)
                                .frame(width: 28, height: 28)
                                .frame(maxWidth: .infinity, alignment: isMoved ? .trailing : .leading)
                                .padding(.horizontal, 4)
                                .animation(.spring(duration: preset.duration, bounce: preset.bounce), value: isMoved)
                        }
                }
            }
            Button("Play", systemImage: "play.fill") { isMoved.toggle() }
                .buttonStyle(.bordered)
                .padding(.top, 4)
        }
        .frame(maxWidth: 420)
    }
}

private struct DragSnapBack: View {
    @State private var offset = CGSize.zero

    var body: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(.indigo.gradient)
            .frame(width: 120, height: 120)
            .overlay {
                Image(systemName: "hand.draw.fill")
                    .font(.largeTitle)
                    .foregroundStyle(.white.opacity(0.9))
            }
            .offset(offset)
            .gesture(
                DragGesture()
                    .onChanged { offset = $0.translation }
                    .onEnded { _ in
                        withAnimation(.spring(duration: 0.5, bounce: 0.4)) {
                            offset = .zero
                        }
                    }
            )
            .accessibilityLabel("Draggable card")
    }
}

private struct SquishyButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            .background(.pink.gradient, in: .capsule)
            .foregroundStyle(.white)
            .scaleEffect(configuration.isPressed ? 0.88 : 1)
            .animation(.bouncy(duration: 0.3, extraBounce: 0.2), value: configuration.isPressed)
    }
}

/// A dot on a track with its own Play button, for the bounce guideline.
private struct BounceSample: View {
    let bounce: Double
    @State private var isMoved = false

    var body: some View {
        VStack(spacing: 12) {
            Capsule()
                .fill(.fill.tertiary)
                .frame(width: 200, height: 36)
                .overlay {
                    Circle()
                        .fill(.tint)
                        .frame(width: 28, height: 28)
                        .frame(maxWidth: .infinity, alignment: isMoved ? .trailing : .leading)
                        .padding(.horizontal, 4)
                }
            Button("Play", systemImage: "play.fill") {
                withAnimation(.spring(duration: 0.6, bounce: bounce)) { isMoved.toggle() }
            }
            .buttonStyle(.bordered)
        }
    }
}
