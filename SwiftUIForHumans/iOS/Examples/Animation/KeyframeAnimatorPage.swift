import SwiftUI

extension ComponentPage {
    static let keyframeAnimator = ComponentPage(
        id: "keyframe-animator",
        title: "KeyframeAnimator",
        summary: "Animates several properties on their own timelines, like a jump that squashes, spins, and lands.",
        category: .animation,
        kind: .modifier,
        symbol: "timeline.selection",
        availability: ["iOS 17.0+", "macOS 14.0+", "visionOS 1.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/keyframeanimator",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/motion",
        aliases: ["@keyframes", "CSS keyframes", "timeline", "CAKeyframeAnimation", "choreography", "squash and stretch", "multi-property animation", "lottie"],
        related: ["phase-animator", "spring", "animation-curves"],
        notes: [
            "**Like CSS `@keyframes`, but per property.** Each `KeyframeTrack` animates one property of your value struct on its own timeline, and all tracks run at the same time.",
            "**Make the tracks the same length.** Add up each track's durations to the same total, so every property finishes together.",
        ],
        api: [
            APIItem("`.keyframeAnimator(initialValue:trigger:)`", "Plays the keyframes once each time `trigger` changes."),
            APIItem("`repeating: true`", "Loops the keyframes while the view is on screen."),
            APIItem("`KeyframeTrack(_:)`", "One property's timeline, picked by key path."),
            APIItem("`CubicKeyframe`", "Moves smoothly to the value."),
            APIItem("`SpringKeyframe`", "Springs to the value, with physics."),
            APIItem("`LinearKeyframe`", "Moves at a constant speed."),
            APIItem("`MoveKeyframe`", "Jumps to the value instantly."),
        ],
        guidelines: [
            Guideline(
                "Rest between loops.",
                "A looping animation with a pause reads as a gentle reminder. Without one it feels frantic and pulls attention from everything else.",
                good: "A ring, then a second of rest.",
                bad: "Ringing nonstop never lets up."
            ) {
                BellSample(rest: 1)
            } bad: {
                BellSample(rest: 0)
            },
            Guideline(
                "Save choreography for special moments.",
                "A multi-step animation suits a reward or a first launch. On something people do all day, it slows them down."
            ),
            Guideline(
                "Keep it optional.",
                "When Reduce Motion is on, skip the keyframes or show the end state, and make sure the meaning comes through without them."
            ),
        ]
    ) {
        KeyframeThumbnail()
    } content: { page in
        KeyframeAnimatorDemo(page: page)
    }
}

// MARK: - Model

private struct JumpValues {
    var scale = 1.0
    var verticalStretch = 1.0
    var verticalOffset = 0.0
    var angle = Angle.zero
}

private enum KeyframeRun: DemoOption {
    case onTap, repeating

    var label: String {
        switch self {
        case .onTap: "On trigger"
        case .repeating: "Repeat"
        }
    }
}

private struct KeyframeConfig {
    var height = 80.0
    var stretches = true
    var spins = true
    var run: KeyframeRun = .onTap
    var count = 0
}

/// The keyframes used by the demo. Disabled tracks hold a neutral value, so
/// the preview matches code that leaves those tracks out.
@KeyframesBuilder<JumpValues>
private func jumpKeyframes(_ config: KeyframeConfig) -> some Keyframes<JumpValues> {
    KeyframeTrack(\.verticalOffset) {
        LinearKeyframe(0, duration: 0.1)
        SpringKeyframe(-config.height, duration: 0.3, spring: .bouncy)
        CubicKeyframe(-config.height, duration: 0.2)
        SpringKeyframe(0, duration: 0.4, spring: .bouncy)
    }
    KeyframeTrack(\.verticalStretch) {
        CubicKeyframe(config.stretches ? 0.6 : 1, duration: 0.1)
        CubicKeyframe(config.stretches ? 1.3 : 1, duration: 0.15)
        CubicKeyframe(1, duration: 0.45)
        CubicKeyframe(config.stretches ? 0.8 : 1, duration: 0.1)
        CubicKeyframe(1, duration: 0.2)
    }
    KeyframeTrack(\.angle) {
        CubicKeyframe(.zero, duration: 0.15)
        CubicKeyframe(config.spins ? .degrees(360) : .zero, duration: 0.5)
        MoveKeyframe(.zero)
    }
}

// MARK: - Demo

private struct KeyframeAnimatorDemo: View {
    let page: ComponentPage

    var body: some View {
        DemoPage(
            page: page,
            initial: KeyframeConfig(),
            previewHeight: 300,
            usage: """
            @State private var rings = 0

            Image(systemName: "bell.fill")
                .font(.largeTitle)
                .onTapGesture { rings += 1 }
                .keyframeAnimator(initialValue: 0.0, trigger: rings) { content, angle in
                    content.rotationEffect(.degrees(angle), anchor: .top)
                } keyframes: { _ in
                    KeyframeTrack {
                        CubicKeyframe(20, duration: 0.1)
                        CubicKeyframe(-15, duration: 0.15)
                        SpringKeyframe(0, duration: 0.3)
                    }
                }
            """,
            usageNote: Aside(.note, "To animate several properties, use a struct as `initialValue` and add one `KeyframeTrack(\\.property)` per property, as in the demo's code.")
        ) { $config in
            VStack(spacing: 16) {
                ZStack(alignment: .bottom) {
                    Capsule()
                        .fill(.fill.secondary)
                        .frame(width: 120, height: 6)
                    animatedStar(config)
                        .id("\(config.run)-\(config.height)-\(config.stretches)-\(config.spins)")
                        .padding(.bottom, 6)
                }
                .frame(height: 170, alignment: .bottom)

                OffsetTimeline(config: config)
                    .frame(height: 44)
                    .frame(maxWidth: 360)

                if config.run == .onTap {
                    Button("Jump", systemImage: "arrow.up") { config.count += 1 }
                        .buttonStyle(.borderedProminent)
                }
            }
        } controls: { $config in
            Section("Keyframes") {
                ValueSlider("Jump height", value: $config.height, in: 20...120, step: 5)
                Toggle("Squash and stretch", isOn: $config.stretches)
                Toggle("Spin", isOn: $config.spins)
            }
            Section("Runs") {
                Picker("Runs", selection: $config.run) {
                    ForEach(KeyframeRun.allCases) { Text($0.label).tag($0) }
                }
                .pickerStyle(.segmented)
            }
        } code: { config in
            keyframeCode(config)
        } examples: {
            ExampleCard(
                title: "Shake on a wrong passcode",
                caption: "Animate one `KeyframeTrack` on the x offset, and end with a `SpringKeyframe` to settle in the center.",
                code: """
                @State private var attempts = 0

                VStack(spacing: 16) {
                    HStack(spacing: 14) {
                        ForEach(0..<4) { _ in
                            Circle().frame(width: 14, height: 14)
                        }
                    }
                    .foregroundStyle(.red)
                    .keyframeAnimator(initialValue: 0.0, trigger: attempts) { content, x in
                        content.offset(x: x)
                    } keyframes: { _ in
                        KeyframeTrack {
                            CubicKeyframe(-16, duration: 0.07)
                            CubicKeyframe(14, duration: 0.07)
                            CubicKeyframe(-10, duration: 0.07)
                            CubicKeyframe(6, duration: 0.07)
                            SpringKeyframe(0, duration: 0.2)
                        }
                    }
                    Button("Try passcode") { attempts += 1 }
                }
                """,
                minHeight: 140,
                aside: Aside(.note, "Keyframe values only change how the view draws, not its layout, so the shaking dots don't push other views around.")
            ) {
                PasscodeShake()
            }

            ExampleCard(
                title: "Ringing bell",
                caption: "Pass `repeating: true` to loop the keyframes, and end with a still `LinearKeyframe` as a pause.",
                code: """
                Image(systemName: "bell.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(.orange)
                    .keyframeAnimator(initialValue: 0.0, repeating: true) { content, degrees in
                        content.rotationEffect(.degrees(degrees), anchor: .top)
                    } keyframes: { _ in
                        KeyframeTrack {
                            CubicKeyframe(20, duration: 0.1)
                            CubicKeyframe(-18, duration: 0.15)
                            CubicKeyframe(12, duration: 0.15)
                            CubicKeyframe(-6, duration: 0.15)
                            CubicKeyframe(0, duration: 0.1)
                            LinearKeyframe(0, duration: 1)
                        }
                    }
                """,
                minHeight: 120
            ) {
                RingingBell()
            }
        }
    }

    @ViewBuilder
    private func animatedStar(_ config: KeyframeConfig) -> some View {
        let star = Image(systemName: "star.fill")
            .font(.system(size: 56))
            .foregroundStyle(.yellow.gradient)
        if config.run == .repeating {
            star.keyframeAnimator(initialValue: JumpValues(), repeating: true) { content, value in
                content.jumpEffect(value)
            } keyframes: { _ in
                jumpKeyframes(config)
            }
        } else {
            star.keyframeAnimator(initialValue: JumpValues(), trigger: config.count) { content, value in
                content.jumpEffect(value)
            } keyframes: { _ in
                jumpKeyframes(config)
            }
        }
    }
}

private extension View {
    nonisolated func jumpEffect(_ value: JumpValues) -> some View {
        rotationEffect(value.angle)
            .scaleEffect(y: value.verticalStretch, anchor: .bottom)
            .offset(y: value.verticalOffset)
    }
}

private func keyframeCode(_ config: KeyframeConfig) -> String {
    let height = swiftNumber(config.height)
    var lines = [
        "struct JumpValues {",
    ]
    if config.stretches { lines.append("    var verticalStretch = 1.0") }
    lines.append("    var verticalOffset = 0.0")
    if config.spins { lines.append("    var angle = Angle.zero") }
    lines += ["}", ""]
    if config.run == .onTap {
        lines += ["@State private var jumps = 0", ""]
    }
    lines += [
        "VStack(spacing: 24) {",
        "    Image(systemName: \"star.fill\")",
        "        .font(.system(size: 56))",
        "        .foregroundStyle(.yellow.gradient)",
        config.run == .onTap
            ? "        .keyframeAnimator(initialValue: JumpValues(), trigger: jumps) { content, value in"
            : "        .keyframeAnimator(initialValue: JumpValues(), repeating: true) { content, value in",
        "            content",
    ]
    if config.spins { lines.append("                .rotationEffect(value.angle)") }
    if config.stretches { lines.append("                .scaleEffect(y: value.verticalStretch, anchor: .bottom)") }
    lines += [
        "                .offset(y: value.verticalOffset)",
        "        } keyframes: { _ in",
        "            KeyframeTrack(\\.verticalOffset) {",
        "                LinearKeyframe(0, duration: 0.1)",
        "                SpringKeyframe(-\(height), duration: 0.3, spring: .bouncy)",
        "                CubicKeyframe(-\(height), duration: 0.2)",
        "                SpringKeyframe(0, duration: 0.4, spring: .bouncy)",
        "            }",
    ]
    if config.stretches {
        lines += [
            "            KeyframeTrack(\\.verticalStretch) {",
            "                CubicKeyframe(0.6, duration: 0.1)",
            "                CubicKeyframe(1.3, duration: 0.15)",
            "                CubicKeyframe(1, duration: 0.45)",
            "                CubicKeyframe(0.8, duration: 0.1)",
            "                CubicKeyframe(1, duration: 0.2)",
            "            }",
        ]
    }
    if config.spins {
        lines += [
            "            KeyframeTrack(\\.angle) {",
            "                CubicKeyframe(.zero, duration: 0.15)",
            "                CubicKeyframe(.degrees(360), duration: 0.5)",
            "                MoveKeyframe(.zero)",
            "            }",
        ]
    }
    lines.append("        }")
    if config.run == .onTap {
        lines += ["", "    Button(\"Jump\") { jumps += 1 }"]
    }
    lines.append("}")
    return lines.joined(separator: "\n")
}

// MARK: - Pieces

/// Graphs the vertical offset track over time using `KeyframeTimeline`.
private struct OffsetTimeline: View {
    let config: KeyframeConfig

    var body: some View {
        let timeline = KeyframeTimeline(initialValue: JumpValues()) {
            jumpKeyframes(config)
        }
        Canvas { context, size in
            let duration = max(timeline.duration, 0.01)
            let samples = 120
            var path = Path()
            for i in 0...samples {
                let t = duration * Double(i) / Double(samples)
                let value = timeline.value(time: t).verticalOffset
                let point = CGPoint(
                    x: size.width * Double(i) / Double(samples),
                    y: size.height * (1 + value / 130) - 1
                )
                if i == 0 { path.move(to: point) } else { path.addLine(to: point) }
            }
            var baseline = Path()
            baseline.move(to: CGPoint(x: 0, y: size.height - 1))
            baseline.addLine(to: CGPoint(x: size.width, y: size.height - 1))
            context.stroke(baseline, with: .style(.separator), lineWidth: 1)
            context.stroke(path, with: .color(.orange), style: StrokeStyle(lineWidth: 2, lineCap: .round))
        }
        .overlay(alignment: .topLeading) {
            Text("verticalOffset over \(swiftNumber(timeline.duration))s")
                .font(.caption2.monospaced())
                .foregroundStyle(.secondary)
        }
        .accessibilityLabel("Graph of the vertical offset keyframes")
    }
}

private struct PasscodeShake: View {
    @State private var attempts = 0

    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 14) {
                ForEach(0..<4) { _ in
                    Circle().frame(width: 14, height: 14)
                }
            }
            .foregroundStyle(.red)
            .keyframeAnimator(initialValue: 0.0, trigger: attempts) { content, x in
                content.offset(x: x)
            } keyframes: { _ in
                KeyframeTrack {
                    CubicKeyframe(-16, duration: 0.07)
                    CubicKeyframe(14, duration: 0.07)
                    CubicKeyframe(-10, duration: 0.07)
                    CubicKeyframe(6, duration: 0.07)
                    SpringKeyframe(0, duration: 0.2)
                }
            }
            Button("Try passcode") { attempts += 1 }
                .buttonStyle(.bordered)
        }
    }
}

private struct RingingBell: View {
    var body: some View {
        Image(systemName: "bell.fill")
            .font(.system(size: 48))
            .foregroundStyle(.orange)
            .keyframeAnimator(initialValue: 0.0, repeating: true) { content, degrees in
                content.rotationEffect(.degrees(degrees), anchor: .top)
            } keyframes: { _ in
                KeyframeTrack {
                    CubicKeyframe(20, duration: 0.1)
                    CubicKeyframe(-18, duration: 0.15)
                    CubicKeyframe(12, duration: 0.15)
                    CubicKeyframe(-6, duration: 0.15)
                    CubicKeyframe(0, duration: 0.1)
                    LinearKeyframe(0, duration: 1)
                }
            }
            .accessibilityLabel("Ringing bell")
    }
}

/// A ringing bell that rests for `rest` seconds between rings.
private struct BellSample: View {
    let rest: Double

    var body: some View {
        Image(systemName: "bell.fill")
            .font(.system(size: 44))
            .foregroundStyle(.orange)
            .keyframeAnimator(initialValue: 0.0, repeating: true) { content, degrees in
                content.rotationEffect(.degrees(degrees), anchor: .top)
            } keyframes: { _ in
                KeyframeTrack {
                    CubicKeyframe(20, duration: 0.1)
                    CubicKeyframe(-18, duration: 0.15)
                    CubicKeyframe(12, duration: 0.15)
                    CubicKeyframe(-6, duration: 0.15)
                    CubicKeyframe(0, duration: 0.1)
                    LinearKeyframe(0, duration: max(rest, 0.01))
                }
            }
    }
}

private struct KeyframeThumbnail: View {
    var body: some View {
        HStack(alignment: .bottom, spacing: 14) {
            ForEach(Array([(0.0, 0.75, 0.0), (-46.0, 1.2, 140.0), (0.0, 1.0, 360.0)].enumerated()), id: \.offset) { index, item in
                Image(systemName: "star.fill")
                    .font(.system(size: 34))
                    .foregroundStyle(.yellow.gradient)
                    .opacity(index == 2 ? 1 : 0.5)
                    .rotationEffect(.degrees(item.2))
                    .scaleEffect(y: item.1, anchor: .bottom)
                    .offset(y: item.0)
            }
        }
        .frame(height: 110, alignment: .bottom)
    }
}
