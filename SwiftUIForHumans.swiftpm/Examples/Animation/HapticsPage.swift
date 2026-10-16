import SwiftUI

extension ComponentPage {
    static let haptics = ComponentPage(
        id: "haptics",
        title: "Haptics",
        summary: "Play a tap, buzz, or click on the device when something happens.",
        category: .animation,
        kind: .modifier,
        symbol: "iphone.radiowaves.left.and.right",
        availability: ["iOS 17.0+", "macOS 14.0+", "watchOS 10.0+", "visionOS 26.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/sensoryfeedback",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/playing-haptics",
        aliases: ["vibrate", "vibration", "taptic", "navigator.vibrate", "UIImpactFeedbackGenerator", "UINotificationFeedbackGenerator", "feedback", "buzz", "rumble"],
        related: ["button", "toggle", "picker", "symbol-effects"],
        notes: [
            "**You change state; SwiftUI plays the haptic.** Unlike `navigator.vibrate()`, you don't call anything. The feedback plays whenever its `trigger` value changes.",
            "**Some types only play on other devices.** `.start` and `.stop` play only on Apple Watch, `.increase` and `.decrease` on Apple Watch and Vision Pro, and `.levelChange` on a Mac.",
        ],
        api: [
            APIItem("`.sensoryFeedback(_:trigger:)`", "Plays feedback each time `trigger` changes."),
            APIItem("`.sensoryFeedback(_:trigger:condition:)`", "Plays only when your closure returns `true`."),
            APIItem("`.sensoryFeedback(trigger:_:)`", "Picks the feedback, or `nil`, from the old and new values."),
            APIItem("`.success`, `.warning`, `.error`", "The outcome of a task."),
            APIItem("`.selection`", "A light tick as a value changes."),
            APIItem("`.impact(weight:)`", "A bump, from `.light` to `.heavy`."),
            APIItem("`.alignment`", "A crisp tick when something snaps into place."),
        ],
        guidelines: [
            Guideline(
                "Pair every haptic with something people can see.",
                "Many people never feel haptics: iPad has none, and anyone can turn them off. The screen should tell the same story.",
                good: "The button shows the result too.",
                bad: "Only a haptic says it worked."
            ) {
                SaveFeedbackSample(showsResult: true)
            } bad: {
                SaveFeedbackSample(showsResult: false)
            },
            Guideline(
                "Use each type for what it means.",
                "People learn that `.success` means done and `.error` means failed. Playing them for anything else muddles the signal."
            ),
            Guideline(
                "Use haptics sparingly.",
                "A haptic on every tap gets tiresome. Toggles, pickers, and pull to refresh already play their own, so don't add another on top."
            ),
        ]
    ) {
        HapticsThumbnail()
    } content: { page in
        HapticsDemo(page: page)
    }
}

// MARK: - Model

private enum FeedbackOption: DemoOption {
    case success, warning, error, selection, increase, decrease, start, stop, impactLight, impactMedium, impactHeavy, impactSoft, impactRigid, alignment, levelChange

    var label: String {
        switch self {
        case .success: ".success"
        case .warning: ".warning"
        case .error: ".error"
        case .selection: ".selection"
        case .increase: ".increase"
        case .decrease: ".decrease"
        case .start: ".start"
        case .stop: ".stop"
        case .impactLight: ".impact(weight: .light)"
        case .impactMedium: ".impact(weight: .medium)"
        case .impactHeavy: ".impact(weight: .heavy)"
        case .impactSoft: ".impact(flexibility: .soft)"
        case .impactRigid: ".impact(flexibility: .rigid)"
        case .alignment: ".alignment"
        case .levelChange: ".levelChange"
        }
    }

    var feedback: SensoryFeedback {
        switch self {
        case .success: .success
        case .warning: .warning
        case .error: .error
        case .selection: .selection
        case .increase: .increase
        case .decrease: .decrease
        case .start: .start
        case .stop: .stop
        case .impactLight: .impact(weight: .light)
        case .impactMedium: .impact(weight: .medium)
        case .impactHeavy: .impact(weight: .heavy)
        case .impactSoft: .impact(flexibility: .soft)
        case .impactRigid: .impact(flexibility: .rigid)
        case .alignment: .alignment
        case .levelChange: .levelChange
        }
    }

    var meaning: String {
        switch self {
        case .success: "A task finished successfully."
        case .warning: "Something needs attention."
        case .error: "Something failed."
        case .selection: "The selection changed, like ticking through a picker."
        case .increase: "A value went up."
        case .decrease: "A value went down."
        case .start: "An activity started."
        case .stop: "An activity stopped."
        case .impactLight, .impactMedium, .impactHeavy: "Something collided. Heavier weights feel bigger."
        case .impactSoft, .impactRigid: "Something collided. Soft feels squishy, rigid feels sharp."
        case .alignment: "A dragged item snapped into alignment."
        case .levelChange: "Crossed into a new level, like a pressure threshold."
        }
    }

    /// Where the feedback actually plays, when it isn't iPhone.
    var platformNote: String? {
        switch self {
        case .start, .stop: "Only plays on Apple Watch."
        case .increase, .decrease: "Only plays on Apple Watch and Vision Pro."
        case .levelChange: "Only plays on a Mac trackpad."
        default: nil
        }
    }

    var symbol: String {
        switch self {
        case .success: "checkmark.circle.fill"
        case .warning: "exclamationmark.triangle.fill"
        case .error: "xmark.octagon.fill"
        case .selection: "hand.point.up.left.fill"
        case .increase: "plus.circle.fill"
        case .decrease: "minus.circle.fill"
        case .start: "play.circle.fill"
        case .stop: "stop.circle.fill"
        case .alignment: "align.horizontal.center.fill"
        case .levelChange: "gauge.with.dots.needle.67percent"
        default: "hand.tap.fill"
        }
    }

    var color: Color {
        switch self {
        case .success: .green
        case .warning: .orange
        case .error: .red
        default: .blue
        }
    }
}

private struct HapticsConfig {
    var feedback: FeedbackOption = .success
    var count = 0
}

// MARK: - Demo

private struct HapticsDemo: View {
    let page: ComponentPage

    var body: some View {
        DemoPage(
            page: page,
            initial: HapticsConfig(),
            previewHeight: 280,
            usage: """
            @State private var saveCount = 0

            Button("Save") {
                saveCount += 1
            }
            .buttonStyle(.borderedProminent)
            .sensoryFeedback(.success, trigger: saveCount)
            """,
            usageNote: Aside(.important, "Haptics only play on a real iPhone or Apple Watch. The Simulator and iPad stay silent, so test on a device. The demo shows a visual pulse instead.")
        ) { $config in
            VStack(spacing: 20) {
                HapticPulse(count: config.count, color: config.feedback.color, symbol: config.feedback.symbol)
                    .frame(height: 120)

                VStack(spacing: 6) {
                    Text(config.feedback.meaning)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    if let note = config.feedback.platformNote {
                        Label(note, systemImage: "info.circle")
                            .font(.footnote.weight(.medium))
                            .foregroundStyle(.orange)
                    }
                }
                .multilineTextAlignment(.center)
                .frame(minHeight: 44)

                Button("Play feedback", systemImage: "waveform") {
                    config.count += 1
                }
                .buttonStyle(.borderedProminent)
                .tint(config.feedback.color)
                .sensoryFeedback(config.feedback.feedback, trigger: config.count)
            }
            .frame(maxWidth: 360)
        } controls: { $config in
            Section {
                Picker("Feedback", selection: $config.feedback) {
                    ForEach(FeedbackOption.allCases) { Text($0.label).tag($0) }
                }
            } header: {
                Text("Feedback")
            } footer: {
                Text("You feel these on a real device, not the Simulator. Watch the pulse instead.")
            }
        } code: { config in
            """
            @State private var count = 0

            Button("Play feedback") {
                count += 1
            }
            .buttonStyle(.borderedProminent)
            .sensoryFeedback(\(config.feedback.label), trigger: count)
            """
        } examples: {
            ExampleCard(
                title: "Success or error from one trigger",
                caption: "Use `.sensoryFeedback(trigger:_:)` to pick `.success`, `.error`, or `nil` from the new value.",
                code: """
                enum SaveResult { case none, saved, failed }
                @State private var result = SaveResult.none

                HStack {
                    Button("Save") { result = .saved }
                    Button("Fail", role: .destructive) { result = .failed }
                }
                .buttonStyle(.bordered)
                .sensoryFeedback(trigger: result) { _, newValue in
                    switch newValue {
                    case .saved: .success
                    case .failed: .error
                    case .none: nil
                    }
                }
                """,
                minHeight: 120
            ) {
                ResultExample()
            }

            ExampleCard(
                title: "Ticks on a custom control",
                caption: "Play `.selection`, the light tick of a picker wheel, each time a custom rating changes.",
                code: """
                @State private var rating = 3

                HStack {
                    ForEach(1...5, id: \\.self) { star in
                        Image(systemName: star <= rating ? "star.fill" : "star")
                            .foregroundStyle(.yellow)
                            .onTapGesture { rating = star }
                    }
                }
                .font(.title)
                .sensoryFeedback(.selection, trigger: rating)
                """,
                minHeight: 120,
                aside: Aside(.note, "System pickers, toggles, and sliders already play their own haptics. Add `.selection` only to controls you build yourself.")
            ) {
                ScrubExample()
            }

            ExampleCard(
                title: "Snap into alignment",
                caption: "Drag the circle across the guide; `.alignment` ticks the moment it snaps to the center.",
                code: """
                @State private var offset: CGFloat = -90
                @State private var dragStart: CGFloat?
                private var isCentered: Bool { abs(offset) < 12 }

                ZStack {
                    Capsule()
                        .fill(isCentered ? Color.indigo : Color.secondary.opacity(0.4))
                        .frame(width: 3, height: 90)
                    Circle()
                        .fill(.indigo.gradient)
                        .frame(width: 56, height: 56)
                        .offset(x: isCentered ? 0 : offset)
                        .animation(.snappy, value: isCentered)
                        .gesture(
                            DragGesture()
                                .onChanged { drag in
                                    let start = dragStart ?? offset
                                    dragStart = start
                                    offset = min(max(start + drag.translation.width, -110), 110)
                                }
                                .onEnded { _ in dragStart = nil }
                        )
                }
                .sensoryFeedback(.alignment, trigger: isCentered) { _, centered in centered }
                """,
                minHeight: 140,
                aside: Aside(.note, "The `condition:` closure returns `true` only when the circle snaps in, so nothing plays as it leaves the guide.")
            ) {
                AlignmentExample()
            }
        }
    }
}

// MARK: - Pieces

/// A visual stand-in for the haptic: rings expand each time `count` changes.
private struct HapticPulse: View {
    let count: Int
    let color: Color
    let symbol: String

    var body: some View {
        ZStack {
            ForEach(0..<2) { ring in
                Circle()
                    .stroke(color.opacity(0.5), lineWidth: 2)
                    .frame(width: 80, height: 80)
                    .keyframeAnimator(initialValue: 0.0, trigger: count) { content, progress in
                        content
                            .scaleEffect(1 + progress * 0.7)
                            .opacity(progress == 0 ? 0 : 1 - progress)
                    } keyframes: { _ in
                        KeyframeTrack {
                            MoveKeyframe(0.001)
                            LinearKeyframe(0.001, duration: Double(ring) * 0.12)
                            CubicKeyframe(1, duration: 0.6)
                            MoveKeyframe(0)
                        }
                    }
            }
            Image(systemName: symbol)
                .font(.system(size: 52))
                .foregroundStyle(color)
                .symbolEffect(.bounce, value: count)
                .contentTransition(.symbolEffect(.replace))
        }
        .accessibilityHidden(true)
    }
}

private enum SaveResult { case none, saved, failed }

private struct ResultExample: View {
    @State private var result = SaveResult.none

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Button("Save") { result = .saved }
                Button("Fail", role: .destructive) { result = .failed }
            }
            .buttonStyle(.bordered)
            .sensoryFeedback(trigger: result) { _, newValue in
                switch newValue {
                case .saved: .success
                case .failed: .error
                case .none: nil
                }
            }
            Text(result == .none ? "Tap a button" : result == .saved ? "Played .success" : "Played .error")
                .font(.footnote.monospaced())
                .foregroundStyle(.secondary)
        }
    }
}

private struct ScrubExample: View {
    @State private var rating = 3

    var body: some View {
        HStack {
            ForEach(1...5, id: \.self) { star in
                Image(systemName: star <= rating ? "star.fill" : "star")
                    .foregroundStyle(.yellow)
                    .onTapGesture { rating = star }
                    .accessibilityLabel("\(star) stars")
                    .accessibilityAddTraits(.isButton)
            }
        }
        .font(.title)
        .sensoryFeedback(.selection, trigger: rating)
    }
}

/// A Save button that does or doesn't show its result, for the
/// "pair with something visible" guideline.
private struct SaveFeedbackSample: View {
    let showsResult: Bool
    @State private var saves = 0

    var body: some View {
        Button {
            saves += 1
        } label: {
            if showsResult && saves > 0 {
                Label("Saved", systemImage: "checkmark")
            } else {
                Text("Save")
            }
        }
        .buttonStyle(.borderedProminent)
        .tint(showsResult && saves > 0 ? .green : .accentColor)
        .sensoryFeedback(.success, trigger: saves)
    }
}

private struct AlignmentExample: View {
    @State private var offset: CGFloat = -90
    @State private var dragStart: CGFloat?
    private var isCentered: Bool { abs(offset) < 12 }

    var body: some View {
        ZStack {
            Capsule()
                .fill(isCentered ? Color.indigo : Color.secondary.opacity(0.4))
                .frame(width: 3, height: 90)
            Circle()
                .fill(.indigo.gradient)
                .frame(width: 56, height: 56)
                .overlay {
                    Image(systemName: "arrow.left.and.right")
                        .font(.headline)
                        .foregroundStyle(.white)
                }
                .offset(x: isCentered ? 0 : offset)
                .animation(.snappy, value: isCentered)
                .gesture(
                    DragGesture()
                        .onChanged { drag in
                            let start = dragStart ?? offset
                            dragStart = start
                            offset = min(max(start + drag.translation.width, -110), 110)
                        }
                        .onEnded { _ in dragStart = nil }
                )
                .accessibilityLabel("Draggable circle")
        }
        .frame(maxWidth: .infinity)
        .sensoryFeedback(.alignment, trigger: isCentered) { _, centered in centered }
    }
}

private struct HapticsThumbnail: View {
    var body: some View {
        ZStack {
            ForEach(0..<3) { ring in
                Circle()
                    .stroke(.tint.opacity(0.5 - Double(ring) * 0.15), lineWidth: 2)
                    .frame(width: 66 + CGFloat(ring) * 28, height: 66 + CGFloat(ring) * 28)
            }
            Image(systemName: "iphone.radiowaves.left.and.right")
                .font(.system(size: 40))
                .foregroundStyle(.tint)
        }
    }
}
