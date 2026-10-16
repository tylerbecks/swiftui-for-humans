import SwiftUI

extension ComponentPage {
    static let animationCurves = ComponentPage(
        id: "animation-curves",
        title: "Animation Curves",
        summary: "Animate any state change, and pick a curve for how it speeds up and slows down.",
        category: .animation,
        kind: .concept,
        symbol: "chart.line.uptrend.xyaxis",
        availability: ["iOS 13.0+", "macOS 10.15+", "visionOS 1.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/animation",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/motion",
        aliases: ["easing", "ease-in-out", "transition-timing-function", "cubic-bezier", "CSS transition", "timing function", "UIView.animate", "duration", "delay", "withAnimation"],
        related: ["spring", "transitions", "phase-animator", "content-transition"],
        notes: [
            "**You animate state, not views.** Change a value inside `withAnimation`, and every view that reads it moves from the old look to the new one.",
            "**`withAnimation` versus `.animation(_:value:)`.** `withAnimation` animates everything the change touches. The modifier animates only its own view, and only when `value` changes.",
            "**The default is a spring.** Since iOS 17, `withAnimation { }` with no argument uses a smooth spring, not ease-in-out. Pass `.easeInOut(duration:)` when you need an exact duration.",
        ],
        api: [
            APIItem("`withAnimation(_:_:)`", "Animates every view the state change affects."),
            APIItem("`.animation(_:value:)`", "Animates only this view, when `value` changes."),
            APIItem("`.easeInOut(duration:)`", "Slow start and end. Also `.easeIn`, `.easeOut`, and `.linear`."),
            APIItem("`.delay(_:)`", "Waits before the animation starts."),
            APIItem("`.repeatForever(autoreverses:)`", "Loops the animation until the view goes away."),
            APIItem("`withAnimation(_:_:completion:)`", "Runs code when the animation finishes (iOS 17+)."),
            APIItem("`\\.accessibilityReduceMotion`", "True when the person turned on Reduce Motion."),
        ],
        guidelines: [
            Guideline(
                "Keep feedback animations short.",
                "A quick response feels light and tells people their tap worked. A slow one makes them wait for the interface to catch up.",
                good: "About a quarter of a second. Tap to try it.",
                bad: "A second and a half feels sluggish."
            ) {
                DurationSample(duration: 0.25)
            } bad: {
                DurationSample(duration: 1.5)
            },
            Guideline(
                "Animate with a purpose.",
                "Motion should explain what changed or where something went. Decoration that moves for its own sake distracts, and can make some people feel unwell."
            ),
            Guideline(
                "Make motion optional.",
                "Check Reduce Motion and swap big movement for a fade or no animation, so nothing important is shown only through motion."
            ),
            Guideline(
                "Don't animate actions people repeat all the time.",
                "System controls already have subtle motion. Extra animation on something tapped dozens of times a day gets tiresome fast."
            ),
        ]
    ) {
        CurvesThumbnail()
    } content: { page in
        AnimationCurvesDemo(page: page)
    }
}

// MARK: - Model

private enum CurveOption: DemoOption {
    case easeInOut, easeIn, easeOut, linear

    var label: String {
        switch self {
        case .easeInOut: "easeInOut"
        case .easeIn: "easeIn"
        case .easeOut: "easeOut"
        case .linear: "linear"
        }
    }

    var unitCurve: UnitCurve {
        switch self {
        case .easeInOut: .easeInOut
        case .easeIn: .easeIn
        case .easeOut: .easeOut
        case .linear: .linear
        }
    }

    var color: Color {
        switch self {
        case .easeInOut: .blue
        case .easeIn: .orange
        case .easeOut: .green
        case .linear: .purple
        }
    }

    func animation(duration: Double) -> Animation {
        switch self {
        case .easeInOut: .easeInOut(duration: duration)
        case .easeIn: .easeIn(duration: duration)
        case .easeOut: .easeOut(duration: duration)
        case .linear: .linear(duration: duration)
        }
    }

    func code(duration: Double) -> String {
        ".\(label)(duration: \(swiftNumber(duration)))"
    }
}

private enum TriggerOption: DemoOption {
    case withAnimation, modifier

    var label: String {
        switch self {
        case .withAnimation: "withAnimation"
        case .modifier: ".animation(value:)"
        }
    }
}

private struct CurvesConfig {
    var curve: CurveOption = .easeInOut
    var duration = 0.8
    var delay = 0.0
    var trigger: TriggerOption = .withAnimation
    var isMoved = false

    var animation: Animation {
        let base = curve.animation(duration: duration)
        return delay > 0 ? base.delay(delay) : base
    }

    var animationCode: String {
        curve.code(duration: duration) + (delay > 0 ? ".delay(\(swiftNumber(delay)))" : "")
    }
}

// MARK: - Demo

private struct AnimationCurvesDemo: View {
    let page: ComponentPage

    var body: some View {
        DemoPage(
            page: page,
            initial: CurvesConfig(),
            previewHeight: 280,
            usage: """
            @State private var isExpanded = false

            RoundedRectangle(cornerRadius: 12)
                .fill(.blue)
                .frame(height: isExpanded ? 200 : 80)
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isExpanded.toggle()
                    }
                }
            """,
            usageNote: Aside(.important, "Always pass `value:` to `.animation(_:value:)`. The old version without it is deprecated and animates changes you didn't mean to.")
        ) { $config in
            VStack(spacing: 18) {
                CurveGraph(curve: config.curve.unitCurve, color: config.curve.color)
                    .frame(height: 110)

                MovingDot(isMoved: config.isMoved, color: config.curve.color)
                    .animation(config.trigger == .modifier ? config.animation : nil, value: config.isMoved)

                HStack {
                    Text(config.trigger == .withAnimation ? "withAnimation" : ".animation(value:)")
                        .font(.footnote.monospaced())
                        .foregroundStyle(.secondary)
                    Spacer()
                    Button("Play", systemImage: "play.fill") {
                        if config.trigger == .withAnimation {
                            withAnimation(config.animation) { config.isMoved.toggle() }
                        } else {
                            config.isMoved.toggle()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(config.curve.color)
                }
            }
            .frame(maxWidth: 480)
        } controls: { $config in
            Section("Curve") {
                OptionPicker("Curve", selection: $config.curve)
                ValueSlider("Duration", value: $config.duration, in: 0.1...2)
                ValueSlider("Delay", value: $config.delay, in: 0...1)
            }
            Section {
                Picker("Trigger", selection: $config.trigger) {
                    ForEach(TriggerOption.allCases) { Text($0.label).tag($0) }
                }
                .pickerStyle(.segmented)
            } header: {
                Text("How it's triggered")
            } footer: {
                Text("Both look the same here. The difference is which views animate: everything the change touches, or just the one with the modifier.")
            }
        } code: { config in
            switch config.trigger {
            case .withAnimation:
                """
                @State private var isMoved = false

                VStack(spacing: 20) {
                    Circle()
                        .fill(.\(config.curve.colorName))
                        .frame(width: 44, height: 44)
                        .frame(maxWidth: .infinity, alignment: isMoved ? .trailing : .leading)

                    Button("Play") {
                        withAnimation(\(config.animationCode)) {
                            isMoved.toggle()
                        }
                    }
                }
                """
            case .modifier:
                """
                @State private var isMoved = false

                VStack(spacing: 20) {
                    Circle()
                        .fill(.\(config.curve.colorName))
                        .frame(width: 44, height: 44)
                        .frame(maxWidth: .infinity, alignment: isMoved ? .trailing : .leading)
                        .animation(\(config.animationCode), value: isMoved)

                    Button("Play") {
                        isMoved.toggle()
                    }
                }
                """
            }
        } examples: {
            ExampleCard(
                title: "Curves side by side",
                caption: "Give each view its own `.animation(_:value:)` curve; only the curve differs between these four dots.",
                code: """
                @State private var isMoved = false

                let curves: [(String, Animation)] = [
                    ("linear", .linear(duration: 1)),
                    ("easeIn", .easeIn(duration: 1)),
                    ("easeOut", .easeOut(duration: 1)),
                    ("easeInOut", .easeInOut(duration: 1)),
                ]

                VStack {
                    ForEach(curves, id: \\.0) { name, animation in
                        Circle()
                            .frame(width: 28, height: 28)
                            .frame(maxWidth: .infinity, alignment: isMoved ? .trailing : .leading)
                            .animation(animation, value: isMoved)
                    }
                    Button("Race") { isMoved.toggle() }
                }
                """,
                aside: Aside(.note, "Ease-out (fast start, gentle stop) feels the most responsive for things appearing on screen. Linear looks mechanical, so save it for spinners and progress.")
            ) {
                CurveRace()
            }

            ExampleCard(
                title: "Repeat forever",
                caption: "Add `.repeatForever(autoreverses: true)` and flip the state in `.onAppear` for an endless pulse.",
                code: """
                @State private var isPulsing = false

                Circle()
                    .fill(.red)
                    .frame(width: 16, height: 16)
                    .scaleEffect(isPulsing ? 1.4 : 1)
                    .opacity(isPulsing ? 0.4 : 1)
                    .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: isPulsing)
                    .onAppear { isPulsing = true }
                """,
                minHeight: 120,
                aside: Aside(.note, "A repeating animation never ends on its own. Keep it for live status like recording, and skip it when Reduce Motion is on.")
            ) {
                PulsingDot()
            }

            ExampleCard(
                title: "Run code when it finishes",
                caption: "Pass a `completion:` closure to `withAnimation` to chain a next step or clean up afterward.",
                code: """
                @State private var isExpanded = false
                @State private var status = "Ready"

                VStack(spacing: 16) {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.teal)
                        .frame(width: isExpanded ? 220 : 80, height: 44)
                    Text(status)
                    Button("Animate") {
                        status = "Animating…"
                        withAnimation(.easeOut(duration: 0.6)) {
                            isExpanded.toggle()
                        } completion: {
                            status = "Done!"
                        }
                    }
                }
                """
            ) {
                CompletionDemo()
            }

            ExampleCard(
                title: "Respect Reduce Motion",
                caption: "Read `\\.accessibilityReduceMotion` and pass `nil` to `withAnimation` to skip the movement.",
                code: """
                @Environment(\\.accessibilityReduceMotion) private var reduceMotion
                @State private var isExpanded = false

                RoundedRectangle(cornerRadius: 12)
                    .fill(.indigo)
                    .frame(width: isExpanded ? 220 : 80, height: 44)
                    .onTapGesture {
                        withAnimation(reduceMotion ? nil : .easeOut(duration: 0.4)) {
                            isExpanded.toggle()
                        }
                    }
                """,
                minHeight: 140,
                aside: Aside(.note, "Turn it on in Settings > Accessibility > Motion to test. A short fade is often a better fallback than no animation at all.")
            ) {
                ReduceMotionDemo()
            }
        }
    }
}

private extension CurveOption {
    var colorName: String {
        switch self {
        case .easeInOut: "blue"
        case .easeIn: "orange"
        case .easeOut: "green"
        case .linear: "purple"
        }
    }
}

// MARK: - Pieces

/// A track with a dot that sits at the leading or trailing end.
private struct MovingDot: View {
    let isMoved: Bool
    let color: Color
    var size: CGFloat = 44

    var body: some View {
        Capsule()
            .fill(.fill.tertiary)
            .frame(height: size + 12)
            .overlay {
                Circle()
                    .fill(color)
                    .frame(width: size, height: size)
                    .frame(maxWidth: .infinity, alignment: isMoved ? .trailing : .leading)
                    .padding(.horizontal, 6)
            }
    }
}

/// Plots progress (up) against time (right) for a timing curve.
private struct CurveGraph: View {
    let curve: UnitCurve
    let color: Color

    var body: some View {
        Canvas { context, size in
            var axes = Path()
            axes.move(to: CGPoint(x: 0, y: 0))
            axes.addLine(to: CGPoint(x: 0, y: size.height))
            axes.addLine(to: CGPoint(x: size.width, y: size.height))
            context.stroke(axes, with: .style(.separator), lineWidth: 1)

            var diagonal = Path()
            diagonal.move(to: CGPoint(x: 0, y: size.height))
            diagonal.addLine(to: CGPoint(x: size.width, y: 0))
            context.stroke(diagonal, with: .style(.tertiary), style: StrokeStyle(lineWidth: 1, dash: [4, 4]))

            var path = Path()
            let samples = 100
            for i in 0...samples {
                let t = Double(i) / Double(samples)
                let point = CGPoint(x: size.width * t, y: size.height * (1 - curve.value(at: t)))
                if i == 0 { path.move(to: point) } else { path.addLine(to: point) }
            }
            context.stroke(path, with: .color(color), style: StrokeStyle(lineWidth: 2.5, lineCap: .round))
        }
        .overlay(alignment: .bottomTrailing) {
            Text("time →")
                .font(.caption2)
                .foregroundStyle(.secondary)
                .padding(.bottom, 4)
        }
        .overlay(alignment: .topLeading) {
            Text("progress")
                .font(.caption2)
                .foregroundStyle(.secondary)
                .padding(.leading, 6)
        }
        .accessibilityLabel("Timing curve graph")
    }
}

private struct CurveRace: View {
    @State private var isMoved = false

    var body: some View {
        VStack(spacing: 10) {
            ForEach([CurveOption.linear, .easeIn, .easeOut, .easeInOut]) { curve in
                HStack(spacing: 10) {
                    Text(curve.label)
                        .font(.caption.monospaced())
                        .foregroundStyle(.secondary)
                        .frame(width: 72, alignment: .leading)
                    MovingDot(isMoved: isMoved, color: curve.color, size: 24)
                        .animation(curve.animation(duration: 1), value: isMoved)
                }
            }
            Button("Race", systemImage: "flag.checkered") { isMoved.toggle() }
                .buttonStyle(.bordered)
                .padding(.top, 4)
        }
        .frame(maxWidth: 420)
    }
}

private struct PulsingDot: View {
    @State private var isPulsing = false

    var body: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(.red)
                .frame(width: 16, height: 16)
                .scaleEffect(isPulsing ? 1.4 : 1)
                .opacity(isPulsing ? 0.4 : 1)
                .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: isPulsing)
                .onAppear { isPulsing = true }
            Text("Live")
                .font(.headline)
        }
    }
}

private struct CompletionDemo: View {
    @State private var isExpanded = false
    @State private var status = "Ready"

    var body: some View {
        VStack(spacing: 16) {
            RoundedRectangle(cornerRadius: 12)
                .fill(.teal)
                .frame(width: isExpanded ? 220 : 80, height: 44)
            Text(status)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Button("Animate") {
                status = "Animating…"
                withAnimation(.easeOut(duration: 0.6)) {
                    isExpanded.toggle()
                } completion: {
                    status = "Done!"
                }
            }
            .buttonStyle(.bordered)
        }
    }
}

private struct ReduceMotionDemo: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isExpanded = false

    var body: some View {
        VStack(spacing: 14) {
            RoundedRectangle(cornerRadius: 12)
                .fill(.indigo)
                .frame(width: isExpanded ? 220 : 80, height: 44)
                .onTapGesture {
                    withAnimation(reduceMotion ? nil : .easeOut(duration: 0.4)) {
                        isExpanded.toggle()
                    }
                }
            Text(reduceMotion ? "Reduce Motion is on: no animation" : "Tap the bar. Reduce Motion is off.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
}

/// A bar that grows when tapped, for the "keep it short" guideline.
private struct DurationSample: View {
    let duration: Double
    @State private var isExpanded = false

    var body: some View {
        VStack(spacing: 12) {
            Capsule()
                .fill(.tint)
                .frame(width: isExpanded ? 200 : 60, height: 28)
                .frame(width: 200, alignment: .leading)
            Button("Tap") {
                withAnimation(.easeOut(duration: duration)) { isExpanded.toggle() }
            }
            .buttonStyle(.bordered)
        }
    }
}

private struct CurvesThumbnail: View {
    var body: some View {
        ZStack {
            ForEach([CurveOption.linear, .easeIn, .easeOut, .easeInOut]) { curve in
                CurveGraph(curve: curve.unitCurve, color: curve.color)
            }
        }
        .frame(width: 170, height: 100)
    }
}
