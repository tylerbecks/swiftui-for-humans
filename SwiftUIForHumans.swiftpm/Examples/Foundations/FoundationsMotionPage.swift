import SwiftUI

extension ComponentPage {
    static let motion = ComponentPage(
        id: "motion",
        title: "Motion",
        summary: "Animate to explain what changed, keep it short, and know when to skip it.",
        category: .foundations,
        kind: .concept,
        symbol: "wind",
        availability: ["iOS 17.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/animation",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/motion",
        aliases: ["animation", "transition", "easing", "ease-in-out", "spring", "bounce", "duration", "micro-interactions", "framer motion", "CSS transition", "prefers-reduced-motion", "withAnimation"],
        related: ["spring", "animation-curves", "transitions", "reduce-motion", "symbol-effects", "haptics", "matched-geometry", "phase-animator"],
        notes: [
            "**Springs are the default.** Since iOS 17, `withAnimation` without an argument uses a spring, not ease-in-out.",
            "**A spring can be interrupted.** If someone taps again mid-animation, SwiftUI heads to the new target and keeps the current speed, so nothing jumps.",
        ],
        api: [
            APIItem("`withAnimation(_:_:)`", "Animates the changes in its closure."),
            APIItem("`.animation(_:value:)`", "Animates when one value changes."),
            APIItem("`.spring(duration:bounce:)`", "A spring tuned by feel."),
            APIItem("`.smooth` `.snappy` `.bouncy`", "Ready-made springs."),
            APIItem("`.transition(_:)`", "How a view enters and leaves."),
            APIItem("`\\.accessibilityReduceMotion`", "True when people ask for less motion."),
            APIItem("`.sensoryFeedback(_:trigger:)`", "Plays a haptic with the change."),
        ],
        guidelines: [
            Guideline(
                "Animate with a purpose.",
                "Motion should explain what changed or confirm an action. Motion that's only decoration distracts people and can make some feel unwell.",
                good: "One checkmark confirms the save.",
                bad: "Everything wiggles, all the time."
            ) {
                MotionPurposeSample(isBusy: false)
            } bad: {
                MotionPurposeSample(isBusy: true)
            },
            Guideline(
                "Don't let motion carry the message alone.",
                "Not everyone sees or wants animation. Pair it with text, a symbol, or a haptic so the meaning survives without it.",
                good: "A label says what happened.",
                bad: "Only a pulsing dot."
            ) {
                Label("Uploaded", systemImage: "checkmark.circle.fill")
                    .font(.headline)
                    .foregroundStyle(.green)
            } bad: {
                MotionPulseDot()
            },
            Guideline(
                "Keep feedback brief.",
                "Short, precise motion feels light and often tells people more than a big show. Tie it closely to the action that caused it."
            ),
            Guideline(
                "Go easy on things people do often.",
                "Standard controls already animate. A custom effect on an action people repeat all day soon feels slow."
            ),
            Guideline(
                "Never make people wait for an animation.",
                "Let people keep tapping while things move. SwiftUI animations can be interrupted, so don't block input until one finishes."
            ),
        ],
        sources: [
            "https://developer.apple.com/design/human-interface-guidelines/motion",
            "https://developer.apple.com/documentation/swiftui/animation",
            "https://developer.apple.com/documentation/swiftui/animation/default",
            "https://developer.apple.com/documentation/swiftui/animation/spring(duration:bounce:blendduration:)",
            "https://developer.apple.com/documentation/swiftui/environmentvalues/accessibilityreducemotion",
            "https://developer.apple.com/documentation/swiftui/view/sensoryfeedback(_:trigger:)",
            "https://developer.apple.com/videos/play/wwdc2023/10158/",
        ],
        reviewed: "October 2026"
    ) {
        MotionThumbnail()
            .accessibilityHidden(true)
    } content: { page in
        MotionArticle(page: page)
    }
}

// MARK: - Page

private struct MotionArticle: View {
    let page: ComponentPage

    var body: some View {
        ArticlePage(page: page) {
            Prose("Good motion answers a question: where did that come from, did my tap work, what changed? iOS animates its own controls, so most of your work is choosing **when** to animate your own views, picking a short **spring**, and having a plan for people who turn on **Reduce Motion**.")

            VStack(alignment: .leading, spacing: 16) {
                SectionTitle("Feel the difference")
                MotionFeelDemo()
            }
            .id("demo")

            VStack(alignment: .leading, spacing: 16) {
                SectionTitle("Tune a spring")
                Prose("Apple's advice is to set the **duration** first for the pace, then add **bounce** for character.")
                MotionSpringTuner()
                MotionBounceTable()
            }
            .id("spring")

            VStack(alignment: .leading, spacing: 16) {
                SectionTitle("When to animate")
                MotionWhenTable()
            }
            .id("when")

            VStack(alignment: .leading, spacing: 16) {
                SectionTitle("Examples")
                VStack(alignment: .leading, spacing: 44) {
                    ExampleCard(
                        title: "Animate a change people made",
                        caption: "Wrap the state change in `withAnimation` so the new content slides in instead of popping.",
                        code: """
                        @State private var showDetails = false

                        VStack(alignment: .leading) {
                            Button(showDetails ? "Hide Details" : "Show Details") {
                                withAnimation(.snappy) {
                                    showDetails.toggle()
                                }
                            }
                            if showDetails {
                                Text("Ships in 2–3 days")
                                    .transition(.move(edge: .top).combined(with: .opacity))
                            }
                        }
                        """,
                        minHeight: 140
                    ) {
                        MotionDetailsSample()
                    }

                    ExampleCard(
                        title: "Offer a fade when Reduce Motion is on",
                        caption: "Read `accessibilityReduceMotion` and swap movement for a cross-fade.",
                        code: """
                        @Environment(\\.accessibilityReduceMotion) private var reduceMotion
                        @State private var isShowing = false

                        VStack {
                            Button("Toggle Banner") {
                                withAnimation { isShowing.toggle() }
                            }
                            if isShowing {
                                Text("Back online")
                                    .padding()
                                    .background(.green.opacity(0.2), in: .capsule)
                                    .transition(reduceMotion ? .opacity : .move(edge: .bottom))
                            }
                        }
                        """,
                        minHeight: 140,
                        aside: Aside(.note, "Reduce Motion doesn't mean no animation. Fades and color changes are fine; big moves, zooms, and spins are what to drop.")
                    ) {
                        MotionReduceSample()
                    }

                    ExampleCard(
                        title: "Confirm with a symbol and a haptic",
                        caption: "Use `.symbolEffect` for a small, precise cue and `.sensoryFeedback` so people feel it too.",
                        code: """
                        @State private var likes = 0

                        Button {
                            likes += 1
                        } label: {
                            Label("\\(likes)", systemImage: "heart.fill")
                                .symbolEffect(.bounce, value: likes)
                        }
                        .sensoryFeedback(.increase, trigger: likes)
                        """,
                        minHeight: 120,
                        aside: Aside(.note, "The haptic carries the confirmation for anyone who can't see the bounce, or has motion turned down.")
                    ) {
                        MotionLikeSample()
                    }
                }
            }
            .id("examples")
        }
    }
}

// MARK: - Demo

private enum MotionStyle: String, CaseIterable, Identifiable {
    case none = "None"
    case smooth = "Smooth"
    case snappy = "Snappy"
    case overdone = "Too Much"

    var id: Self { self }

    var animation: Animation? {
        switch self {
        case .none: nil
        case .smooth: .smooth
        case .snappy: .snappy
        case .overdone: .spring(duration: 1.4, bounce: 0.7)
        }
    }

    var code: String {
        switch self {
        case .none: "expanded.toggle()"
        case .smooth: "withAnimation(.smooth) { expanded.toggle() }"
        case .snappy: "withAnimation(.snappy) { expanded.toggle() }"
        case .overdone: "withAnimation(.spring(duration: 1.4, bounce: 0.7)) { … }"
        }
    }

    var verdict: String {
        switch self {
        case .none: "The panel just appears. Fine for tiny changes, but here it's hard to tell where it came from."
        case .smooth: "No bounce. A safe default for most interface changes."
        case .snappy: "Quick, with a hint of bounce. Feels responsive for things people tap."
        case .overdone: "Slow and wobbly. Fun once, tiring by the tenth time."
        }
    }
}

private struct MotionFeelDemo: View {
    @State private var style: MotionStyle = .snappy
    @State private var expanded = false
    @State private var reduceMotion = false

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Pick a style, then tap the card. Turn on the Reduce Motion switch to see the fade people get instead.")
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 0) {
                    Button {
                        let animation = reduceMotion && style != .none ? Animation.easeInOut(duration: 0.2) : style.animation
                        withAnimation(animation) {
                            expanded.toggle()
                        }
                    } label: {
                        HStack {
                            Image(systemName: "shippingbox.fill")
                                .foregroundStyle(.orange)
                            Text("Order #2048")
                                .font(.headline)
                                .foregroundStyle(.primary)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .rotationEffect(.degrees(expanded && !reduceMotion ? 180 : 0))
                                .foregroundStyle(.secondary)
                        }
                        .padding(14)
                        .contentShape(.rect)
                    }
                    .buttonStyle(.plain)
                    if expanded {
                        VStack(alignment: .leading, spacing: 6) {
                            Label("Shipped Tuesday", systemImage: "checkmark.circle.fill")
                            Label("Arrives Friday", systemImage: "calendar")
                        }
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .padding([.horizontal, .bottom], 14)
                        .transition(reduceMotion ? .opacity : .move(edge: .top).combined(with: .opacity))
                    }
                }
                .frame(maxWidth: 300, alignment: .leading)
                .background(Color(.systemBackground), in: .rect(cornerRadius: 14))
                .clipShape(.rect(cornerRadius: 14))
                .overlay {
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(.separator)
                }
                .padding(20)
                .frame(maxWidth: .infinity, minHeight: 170, alignment: .top)
                .background(Surface.preview)
                Divider()
                VStack(alignment: .leading, spacing: 12) {
                    Picker("Animation", selection: $style) {
                        ForEach(MotionStyle.allCases) { style in
                            Text(style.rawValue).tag(style)
                        }
                    }
                    .pickerStyle(.segmented)
                    Toggle("Reduce Motion", isOn: $reduceMotion)
                        .font(.subheadline)
                    Text(style.code)
                        .font(.footnote.monospaced())
                        .padding(8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Surface.code)
                        .clipShape(.rect(cornerRadius: 8))
                    Text(style.verdict)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(14)
            }
            .cardStyle()
        }
    }
}

// MARK: - Spring tuner

private struct MotionSpringTuner: View {
    @State private var duration = 0.5
    @State private var bounce = 0.0
    @State private var atEnd = false

    private var code: String {
        "withAnimation(.spring(duration: \(duration.formatted(.number.precision(.fractionLength(1)))), bounce: \(bounce.formatted(.number.precision(.fractionLength(1)))))) { … }"
    }

    var body: some View {
        VStack(spacing: 0) {
            GeometryReader { proxy in
                Circle()
                    .fill(.tint)
                    .frame(width: 40, height: 40)
                    .offset(x: atEnd ? proxy.size.width - 40 : 0)
            }
            .frame(height: 40)
            .padding(24)
            .background(Surface.preview)
            Divider()
            VStack(alignment: .leading, spacing: 10) {
                MotionSliderRow(title: "Duration", value: $duration, range: 0.2...1.5, step: 0.1, suffix: " s")
                MotionSliderRow(title: "Bounce", value: $bounce, range: 0...0.8, step: 0.1, suffix: "")
                HStack {
                    Text(code)
                        .font(.footnote.monospaced())
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer(minLength: 8)
                    Button("Play") {
                        withAnimation(.spring(duration: duration, bounce: bounce)) {
                            atEnd.toggle()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding(14)
        }
        .cardStyle()
    }
}

private struct MotionSliderRow: View {
    let title: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double
    let suffix: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Text(title)
                    .font(.subheadline.weight(.medium))
                Spacer()
                Text(value.formatted(.number.precision(.fractionLength(1))) + suffix)
                    .font(.subheadline)
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
            }
            Slider(value: $value, in: range, step: step)
                .accessibilityLabel(title)
        }
    }
}

private struct MotionBounceTable: View {
    private let rows: [(String, String)] = [
        ("0", "No overshoot. The safe, all-purpose default."),
        ("About 0.15", "A small bounce with a brisk finish."),
        ("About 0.3", "Clearly bouncy. Good after a drag or for playful apps."),
        ("Over 0.4", "Usually too much for interface elements."),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(rows.enumerated()), id: \.offset) { index, row in
                if index > 0 { Divider() }
                HStack(alignment: .firstTextBaseline, spacing: 12) {
                    Text(row.0)
                        .font(.subheadline.weight(.semibold))
                        .frame(width: 92, alignment: .leading)
                    Text(row.1)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer(minLength: 0)
                }
                .padding(.vertical, 9)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 4)
        .background(.background.secondary, in: .rect(cornerRadius: 16))
    }
}

private struct MotionWhenTable: View {
    private let rows: [(symbol: String, color: Color, situation: String, answer: String)] = [
        ("checkmark.circle.fill", .green, "Content people added, removed, or opened", "Animate with a short spring."),
        ("gearshape.fill", .gray, "Standard controls, pushes, and sheets", "Leave it to the system."),
        ("repeat", .orange, "An action people repeat all day", "Keep it minimal, or skip it."),
        ("hand.thumbsup.fill", .blue, "Confirming that something worked", "A symbol effect plus a haptic."),
        ("figure.walk.motion", .purple, "Big moves, zooms, or parallax", "Fade instead with Reduce Motion."),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(rows.enumerated()), id: \.offset) { index, row in
                if index > 0 { Divider() }
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: row.symbol)
                        .foregroundStyle(row.color)
                        .frame(width: 24)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(row.situation)
                            .font(.subheadline.weight(.semibold))
                        Text(row.answer)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .fixedSize(horizontal: false, vertical: true)
                    Spacer(minLength: 0)
                }
                .padding(.vertical, 10)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 4)
        .background(.background.secondary, in: .rect(cornerRadius: 16))
    }
}

// MARK: - Example views

private struct MotionDetailsSample: View {
    @State private var showDetails = false

    var body: some View {
        VStack(alignment: .leading) {
            Button(showDetails ? "Hide Details" : "Show Details") {
                withAnimation(.snappy) {
                    showDetails.toggle()
                }
            }
            if showDetails {
                Text("Ships in 2–3 days")
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .frame(minHeight: 60, alignment: .top)
    }
}

private struct MotionReduceSample: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isShowing = false

    var body: some View {
        VStack {
            Button("Toggle Banner") {
                withAnimation { isShowing.toggle() }
            }
            if isShowing {
                Text("Back online")
                    .padding()
                    .background(.green.opacity(0.2), in: .capsule)
                    .transition(reduceMotion ? .opacity : .move(edge: .bottom))
            }
        }
        .frame(minHeight: 90, alignment: .top)
    }
}

private struct MotionLikeSample: View {
    @State private var likes = 0

    var body: some View {
        Button {
            likes += 1
        } label: {
            Label("\(likes)", systemImage: "heart.fill")
                .symbolEffect(.bounce, value: likes)
        }
        .sensoryFeedback(.increase, trigger: likes)
        .buttonStyle(.bordered)
        .tint(.pink)
    }
}

// MARK: - Guideline views

private struct MotionPurposeSample: View {
    let isBusy: Bool

    var body: some View {
        HStack(spacing: 14) {
            if isBusy {
                ForEach(["star.fill", "bell.fill", "heart.fill", "checkmark.circle.fill"], id: \.self) { symbol in
                    Image(systemName: symbol)
                        .font(.title2)
                        .foregroundStyle(.tint)
                        .symbolEffect(.wiggle, options: .repeating)
                }
            } else {
                Image(systemName: "star.fill")
                    .font(.title2)
                    .foregroundStyle(.secondary)
                Image(systemName: "bell.fill")
                    .font(.title2)
                    .foregroundStyle(.secondary)
                MotionSavedCheck()
            }
        }
    }
}

/// Bounces once when it appears, like a save confirmation.
private struct MotionSavedCheck: View {
    @State private var trigger = false

    var body: some View {
        Label("Saved", systemImage: "checkmark.circle.fill")
            .font(.title3.weight(.semibold))
            .foregroundStyle(.green)
            .symbolEffect(.bounce, value: trigger)
            .onAppear { trigger.toggle() }
    }
}

private struct MotionPulseDot: View {
    var body: some View {
        Image(systemName: "circle.fill")
            .font(.title)
            .foregroundStyle(.green)
            .symbolEffect(.pulse, options: .repeating)
    }
}

private struct MotionThumbnail: View {
    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<4) { index in
                Circle()
                    .fill(Color.accentColor.opacity(0.25 + Double(index) * 0.25))
                    .frame(width: 26, height: 26)
                    .offset(y: [18, 6, -4, -10][index])
            }
        }
        .frame(height: 80)
    }
}
