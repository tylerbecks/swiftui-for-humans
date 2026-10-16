import SwiftUI

extension ComponentPage {
    static let phaseAnimator = ComponentPage(
        id: "phase-animator",
        title: "PhaseAnimator",
        summary: "Steps a view through a list of states, either in a loop or each time a value changes.",
        category: .animation,
        kind: .modifier,
        symbol: "circle.dotted.and.circle",
        availability: ["iOS 17.0+", "macOS 14.0+", "visionOS 1.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/phaseanimator",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/motion",
        aliases: ["loop animation", "multi-step animation", "sequence", "CSS animation", "animation-iteration-count", "infinite", "pulse", "shake", "attention"],
        related: ["keyframe-animator", "animation-curves", "symbol-effects", "spring"],
        notes: [
            "**Phases are whole states.** Use numbers for one property, or an `enum` with computed properties when several change together.",
            "**Phases or keyframes?** Use `PhaseAnimator` when each step is a state. Use [KeyframeAnimator](catalog://keyframe-animator) when properties need their own exact timing, like CSS `@keyframes`.",
        ],
        api: [
            APIItem("`.phaseAnimator(_:content:animation:)`", "Loops through the phases forever."),
            APIItem("`.phaseAnimator(_:trigger:content:animation:)`", "Plays the phases once each time `trigger` changes."),
            APIItem("`content:`", "Gets the view and current phase; apply modifiers here."),
            APIItem("`animation:`", "Picks the animation into each phase."),
            APIItem("`PhaseAnimator`", "The same thing as a view, wrapping its content."),
        ],
        guidelines: [
            Guideline(
                "Loop only what's truly ongoing.",
                "One pulsing indicator says \"this is live.\" When several things move at once, nothing stands out and the screen feels restless.",
                good: "Only the live item pulses.",
                bad: "Everything pulses, so nothing stands out."
            ) {
                PulseRowSample(pulsingCount: 1)
            } bad: {
                PulseRowSample(pulsingCount: 3)
            },
            Guideline(
                "Don't rely on motion alone.",
                "A shake or bounce is a hint. Pair it with text, like an error message, so people who miss the motion still get the point."
            ),
            Guideline(
                "Keep feedback short.",
                "A triggered animation should finish in well under a second, so people can keep going without waiting."
            ),
        ]
    ) {
        PhaseThumbnail()
    } content: { page in
        PhaseAnimatorDemo(page: page)
    }
}

// MARK: - Model

private enum PhaseEffect: DemoOption {
    case pulse, wiggle, hop, fade

    var label: String {
        switch self {
        case .pulse: "Pulse"
        case .wiggle: "Wiggle"
        case .hop: "Hop"
        case .fade: "Fade"
        }
    }

    var phases: [Double] {
        switch self {
        case .pulse: [1, 1.25]
        case .wiggle: [0, -15, 15, 0]
        case .hop: [0, -30, 0]
        case .fade: [1, 0.3]
        }
    }

    var phasesCode: String {
        switch self {
        case .pulse: "[1, 1.25]"
        case .wiggle: "[0.0, -15, 15, 0]"
        case .hop: "[0.0, -30, 0]"
        case .fade: "[1, 0.3]"
        }
    }

    var modifierCode: String {
        switch self {
        case .pulse: "content.scaleEffect(phase)"
        case .wiggle: "content.rotationEffect(.degrees(phase))"
        case .hop: "content.offset(y: phase)"
        case .fade: "content.opacity(phase)"
        }
    }
}

private enum PhaseCurve: DemoOption {
    case easeInOut, bouncy, snappy, slow

    var label: String {
        switch self {
        case .easeInOut: ".easeInOut"
        case .bouncy: ".bouncy"
        case .snappy: ".snappy"
        case .slow: ".easeInOut(duration: 1)"
        }
    }

    var animation: Animation {
        switch self {
        case .easeInOut: .easeInOut
        case .bouncy: .bouncy
        case .snappy: .snappy
        case .slow: .easeInOut(duration: 1)
        }
    }
}

private enum PhaseTrigger: DemoOption {
    case forever, onTap

    var label: String {
        switch self {
        case .forever: "Loop forever"
        case .onTap: "On trigger"
        }
    }
}

private struct PhaseConfig {
    var effect: PhaseEffect = .pulse
    var curve: PhaseCurve = .easeInOut
    var trigger: PhaseTrigger = .forever
    var count = 0
}

// MARK: - Demo

private struct PhaseAnimatorDemo: View {
    let page: ComponentPage

    var body: some View {
        DemoPage(
            page: page,
            initial: PhaseConfig(),
            usage: """
            @State private var count = 0

            Button("Add to Cart", systemImage: "cart") {
                count += 1
            }
            .buttonStyle(.borderedProminent)
            .phaseAnimator([1.0, 1.2], trigger: count) { content, scale in
                content.scaleEffect(scale)
            }
            """,
            usageNote: Aside(.note, "Leave out `trigger:` and the phases loop forever. With a trigger, they play once each time the value changes, then return to the first phase.")
        ) { $config in
            VStack(spacing: 24) {
                Group {
                    if config.trigger == .forever {
                        heart.phaseAnimator(config.effect.phases) { content, phase in
                            content.apply(config.effect, phase)
                        } animation: { _ in
                            config.curve.animation
                        }
                    } else {
                        heart.phaseAnimator(config.effect.phases, trigger: config.count) { content, phase in
                            content.apply(config.effect, phase)
                        } animation: { _ in
                            config.curve.animation
                        }
                    }
                }
                // Restart the animator whenever its setup changes.
                .id("\(config.effect)-\(config.curve)-\(config.trigger)")
                .frame(height: 110)

                if config.trigger == .onTap {
                    Button("Play", systemImage: "play.fill") { config.count += 1 }
                        .buttonStyle(.borderedProminent)
                } else {
                    Text("Phases: \(config.effect.phasesCode)")
                        .font(.footnote.monospaced())
                        .foregroundStyle(.secondary)
                }
            }
        } controls: { $config in
            Section("Phases") {
                OptionPicker("Effect", selection: $config.effect)
                OptionPicker("Animation", selection: $config.curve)
            }
            Section {
                Picker("Runs", selection: $config.trigger) {
                    ForEach(PhaseTrigger.allCases) { Text($0.label).tag($0) }
                }
                .pickerStyle(.segmented)
            } header: {
                Text("Runs")
            } footer: {
                Text("A trigger runs the phases once each time a value changes.")
            }
        } code: { config in
            let call = config.trigger == .forever
                ? ".phaseAnimator(\(config.effect.phasesCode))"
                : ".phaseAnimator(\(config.effect.phasesCode), trigger: count)"
            var lines: [String] = []
            if config.trigger == .onTap {
                lines += ["@State private var count = 0", ""]
                lines.append("VStack(spacing: 24) {")
            }
            let indent = config.trigger == .onTap ? "    " : ""
            lines += [
                "Image(systemName: \"heart.fill\")",
                "    .font(.system(size: 72))",
                "    .foregroundStyle(.pink)",
                "    \(call) { content, phase in",
                "        \(config.effect.modifierCode)",
                "    } animation: { _ in",
                "        \(config.curve.label)",
                "    }",
            ].map { indent + $0 }
            if config.trigger == .onTap {
                lines += [
                    "",
                    "    Button(\"Play\") { count += 1 }",
                    "}",
                ]
            }
            return lines.joined(separator: "\n")
        } examples: {
            ExampleCard(
                title: "Shake on error",
                caption: "Pass the attempt count as `trigger:` to shake the field each time sign-in fails.",
                code: """
                @State private var attempts = 0

                VStack(spacing: 16) {
                    SecureField("Password", text: .constant("1234"))
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 220)
                        .phaseAnimator([0.0, -12, 12, -8, 8, 0], trigger: attempts) { content, offset in
                            content.offset(x: offset)
                        } animation: { _ in
                            .linear(duration: 0.06)
                        }
                    Button("Sign In") { attempts += 1 }
                        .buttonStyle(.borderedProminent)
                }
                """,
                minHeight: 140,
                aside: Aside(.note, "A shake alone is easy to miss. Show an error message too, and skip the shake when Reduce Motion is on.")
            ) {
                ShakeExample()
            }

            ExampleCard(
                title: "Steps as an enum",
                caption: "Describe each step as an `enum` case when scale and rotation change together.",
                code: """
                enum LikePhase: CaseIterable {
                    case idle, grow, settle

                    var scale: Double {
                        switch self {
                        case .idle: 1
                        case .grow: 1.4
                        case .settle: 1.1
                        }
                    }
                    var angle: Double { self == .grow ? -12 : 0 }
                }

                @State private var likes = 0

                Button {
                    likes += 1
                } label: {
                    Label("\\(likes)", systemImage: "hand.thumbsup.fill")
                }
                .buttonStyle(.bordered)
                .phaseAnimator(LikePhase.allCases, trigger: likes) { content, phase in
                    content
                        .scaleEffect(phase.scale)
                        .rotationEffect(.degrees(phase.angle))
                } animation: { phase in
                    phase == .grow ? .snappy(duration: 0.15) : .bouncy
                }
                """,
                minHeight: 140,
                aside: Aside(.note, "The `animation:` closure gets the phase it's animating to, so the quick grow and the bouncy settle each get their own curve.")
            ) {
                LikeExample()
            }

            ExampleCard(
                title: "Loading dots",
                caption: "Without a `trigger:`, `.phaseAnimator` loops on its own, so three delayed dots need no state.",
                code: """
                HStack(spacing: 8) {
                    ForEach(0..<3) { index in
                        Circle()
                            .frame(width: 12, height: 12)
                            .phaseAnimator([0.3, 1]) { content, phase in
                                content.opacity(phase).scaleEffect(phase)
                            } animation: { _ in
                                .easeInOut(duration: 0.5).delay(Double(index) * 0.15)
                            }
                    }
                }
                .foregroundStyle(.secondary)
                """,
                minHeight: 100,
                aside: Aside(.note, "For a standard spinner, use `ProgressView`. Custom loaders are best kept for branded moments.")
            ) {
                LoadingDots()
            }
        }
    }

    private var heart: some View {
        Image(systemName: "heart.fill")
            .font(.system(size: 72))
            .foregroundStyle(.pink)
    }
}

private extension View {
    @ViewBuilder
    func apply(_ effect: PhaseEffect, _ phase: Double) -> some View {
        switch effect {
        case .pulse: scaleEffect(phase)
        case .wiggle: rotationEffect(.degrees(phase))
        case .hop: offset(y: phase)
        case .fade: opacity(phase)
        }
    }
}

// MARK: - Examples

private enum LikePhase: CaseIterable {
    case idle, grow, settle

    var scale: Double {
        switch self {
        case .idle: 1
        case .grow: 1.4
        case .settle: 1.1
        }
    }

    var angle: Double { self == .grow ? -12 : 0 }
}

private struct LikeExample: View {
    @State private var likes = 0

    var body: some View {
        Button {
            likes += 1
        } label: {
            Label("\(likes)", systemImage: "hand.thumbsup.fill")
                .contentTransition(.numericText(value: Double(likes)))
        }
        .buttonStyle(.bordered)
        .controlSize(.large)
        .phaseAnimator(LikePhase.allCases, trigger: likes) { content, phase in
            content
                .scaleEffect(phase.scale)
                .rotationEffect(.degrees(phase.angle))
        } animation: { phase in
            phase == .grow ? .snappy(duration: 0.15) : .bouncy
        }
    }
}

private struct LoadingDots: View {
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<3) { index in
                Circle()
                    .frame(width: 12, height: 12)
                    .phaseAnimator([0.3, 1]) { content, phase in
                        content.opacity(phase).scaleEffect(phase)
                    } animation: { _ in
                        .easeInOut(duration: 0.5).delay(Double(index) * 0.15)
                    }
            }
        }
        .foregroundStyle(.secondary)
        .accessibilityLabel("Loading")
    }
}

private struct ShakeExample: View {
    @State private var attempts = 0

    var body: some View {
        VStack(spacing: 16) {
            SecureField("Password", text: .constant("1234"))
                .textFieldStyle(.roundedBorder)
                .frame(width: 220)
                .phaseAnimator([0.0, -12, 12, -8, 8, 0], trigger: attempts) { content, offset in
                    content.offset(x: offset)
                } animation: { _ in
                    .linear(duration: 0.06)
                }
            Button("Sign In") { attempts += 1 }
                .buttonStyle(.borderedProminent)
        }
    }
}

/// Three status icons, some pulsing, for the "loop only what's ongoing" guideline.
private struct PulseRowSample: View {
    let pulsingCount: Int
    private let symbols = ["record.circle", "arrow.down.circle", "bell"]

    var body: some View {
        HStack(spacing: 28) {
            ForEach(Array(symbols.enumerated()), id: \.offset) { index, symbol in
                let icon = Image(systemName: symbol)
                    .font(.system(size: 34))
                    .foregroundStyle(index == 0 ? Color.red : Color.accentColor)
                if index < pulsingCount {
                    icon.phaseAnimator([1.0, 0.35]) { content, opacity in
                        content.opacity(opacity)
                    } animation: { _ in
                        .easeInOut(duration: 0.8)
                    }
                } else {
                    icon
                }
            }
        }
    }
}

private struct PhaseThumbnail: View {
    var body: some View {
        HStack(spacing: 18) {
            ForEach(Array([0.8, 1.0, 1.25].enumerated()), id: \.offset) { index, scale in
                Image(systemName: "heart.fill")
                    .font(.system(size: 34))
                    .foregroundStyle(.pink.opacity(0.45 + Double(index) * 0.27))
                    .scaleEffect(scale)
            }
        }
    }
}
