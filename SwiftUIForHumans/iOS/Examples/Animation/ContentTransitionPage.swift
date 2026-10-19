import SwiftUI

extension ComponentPage {
    static let contentTransition = ComponentPage(
        id: "content-transition",
        title: "Content Transitions",
        summary: "Animate content changing in place, like digits rolling on a counter or one icon becoming another.",
        category: .animation,
        kind: .modifier,
        symbol: "textformat.123",
        availability: ["iOS 16.0+", "macOS 13.0+", "visionOS 1.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/contenttransition",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/motion",
        aliases: ["counter animation", "number ticker", "rolling digits", "odometer", "animate text change", "count up", "icon swap", "crossfade"],
        related: ["symbol-effects", "transitions", "text", "animation-curves"],
        notes: [
            "**Same view, new content.** A content transition animates what's drawn inside one view. To animate a view being added or removed, use [Transitions](catalog://transitions).",
            "**Like a CSS number ticker, without the library.** On the web you'd reach for a counter package; here one modifier on `Text` does it.",
        ],
        api: [
            APIItem("`.contentTransition(_:)`", "How this view's content animates when it changes."),
            APIItem("`.numericText(value:)`", "Rolls digits, up or down depending on `value`."),
            APIItem("`.numericText(countsDown:)`", "Rolls digits down when there's no value to compare."),
            APIItem("`.interpolate`", "Blends weight, size, and color between the two states."),
            APIItem("`.opacity`", "A plain crossfade between old and new content."),
            APIItem("`.identity`", "No animation; the content just changes."),
            APIItem("`.symbolEffect(.replace)`", "Swaps one SF Symbol for another."),
        ],
        guidelines: [
            Guideline(
                "Keep changing numbers from shifting.",
                "Proportional digits change width as the value changes, so nearby text jumps around. Monospaced digits keep everything still.",
                good: "`.monospacedDigit()` keeps the unit in place.",
                bad: "Proportional digits make the unit jitter."
            ) {
                TickerSample(isMonospaced: true)
            } bad: {
                TickerSample(isMonospaced: false)
            },
            Guideline(
                "Animate values people are watching.",
                "A rolling price or score confirms a change they made. For text they're reading, a quiet crossfade or no animation is easier on the eyes."
            ),
            Guideline(
                "Keep it quick.",
                "A number should settle in a fraction of a second, so people can read the new value right away."
            ),
        ]
    ) {
        ContentTransitionThumbnail()
    } content: { page in
        ContentTransitionDemo(page: page)
    }
}

// MARK: - Model

private enum ContentKind: DemoOption {
    case numericText, interpolate, opacity, identity, symbolReplace

    var label: String {
        switch self {
        case .numericText: ".numericText()"
        case .interpolate: ".interpolate"
        case .opacity: ".opacity"
        case .identity: ".identity"
        case .symbolReplace: ".symbolEffect(.replace)"
        }
    }

    var transition: ContentTransition {
        switch self {
        case .numericText: .numericText()
        case .interpolate: .interpolate
        case .opacity: .opacity
        case .identity: .identity
        case .symbolReplace: .symbolEffect(.replace)
        }
    }
}

private enum ContentAnimation: DemoOption {
    case snappy, smooth, bouncy, slow

    var label: String {
        switch self {
        case .snappy: ".snappy"
        case .smooth: ".smooth"
        case .bouncy: ".bouncy"
        case .slow: ".easeInOut(duration: 1)"
        }
    }

    var animation: Animation {
        switch self {
        case .snappy: .snappy
        case .smooth: .smooth
        case .bouncy: .bouncy
        case .slow: .easeInOut(duration: 1)
        }
    }
}

private struct ContentConfig {
    var kind: ContentKind = .numericText
    var timing: ContentAnimation = .snappy
    var count = 42
    var isOn = false
}

// MARK: - Demo

private struct ContentTransitionDemo: View {
    let page: ComponentPage

    var body: some View {
        DemoPage(
            page: page,
            initial: ContentConfig(),
            usage: """
            @State private var count = 0

            VStack {
                Text("\\(count)")
                    .font(.largeTitle.bold())
                    .contentTransition(.numericText(value: Double(count)))
                    .animation(.snappy, value: count)
                Button("Add") { count += 1 }
            }
            """,
            usageNote: Aside(.important, "A content transition plays only when the change is animated. Wrap it in `withAnimation`, or add `.animation(_:value:)` as above.")
        ) { $config in
            let animation = config.timing.animation
            VStack(spacing: 24) {
                switch config.kind {
                case .numericText:
                    Text("\(config.count)")
                        .font(.system(size: 72, weight: .bold, design: .rounded))
                        .contentTransition(.numericText(value: Double(config.count)))
                    HStack(spacing: 12) {
                        Button("Minus", systemImage: "minus") { withAnimation(animation) { config.count -= 1 } }
                        Button("Plus", systemImage: "plus") { withAnimation(animation) { config.count += 1 } }
                        Button("Random", systemImage: "dice") { withAnimation(animation) { config.count = Int.random(in: 0...999) } }
                    }
                    .labelStyle(.iconOnly)
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                case .symbolReplace:
                    Image(systemName: config.isOn ? "speaker.slash.fill" : "speaker.wave.3.fill")
                        .font(.system(size: 72))
                        .contentTransition(.symbolEffect(.replace))
                    Button(config.isOn ? "Unmute" : "Mute") { withAnimation(animation) { config.isOn.toggle() } }
                        .buttonStyle(.borderedProminent)
                default:
                    Text(config.isOn ? "Following" : "Follow")
                        .font(.system(size: 44, weight: config.isOn ? .black : .light))
                        .foregroundStyle(config.isOn ? .pink : .primary)
                        .contentTransition(config.kind.transition)
                    Button("Change", systemImage: "arrow.triangle.2.circlepath") { withAnimation(animation) { config.isOn.toggle() } }
                        .buttonStyle(.borderedProminent)
                }
            }
        } controls: { $config in
            Section("Content transition") {
                OptionPicker("Transition", selection: $config.kind)
                OptionPicker("Animation", selection: $config.timing)
            }
        } code: { config in
            contentCode(config)
        } examples: {
            ExampleCard(
                title: "Price that rolls",
                caption: "Use `.numericText(value:)` on formatted currency too; each digit rolls on its own.",
                code: """
                @State private var quantity = 1
                let price = 4.99

                VStack(spacing: 16) {
                    Text(Double(quantity) * price, format: .currency(code: "USD"))
                        .font(.largeTitle.bold())
                        .contentTransition(.numericText(value: Double(quantity)))
                        .animation(.snappy, value: quantity)
                    Stepper("Quantity: \\(quantity)", value: $quantity, in: 1...20)
                        .frame(width: 220)
                }
                """,
                minHeight: 150,
                aside: Aside(.note, "`value:` tells SwiftUI whether the number went up or down, so the digits roll in the right direction.")
            ) {
                PriceExample()
            }

            ExampleCard(
                title: "Countdown timer",
                caption: "Redraw with a `TimelineView` each second, and use `.numericText(countsDown: true)` to roll digits down.",
                code: """
                @State private var end = Date.now.addingTimeInterval(90)

                TimelineView(.periodic(from: .now, by: 1)) { context in
                    let seconds = max(0, Int(end.timeIntervalSince(context.date)))
                    Text(String(format: "%d:%02d", seconds / 60, seconds % 60))
                        .font(.system(size: 56, weight: .semibold, design: .monospaced))
                        .contentTransition(.numericText(countsDown: true))
                        .animation(.default, value: seconds)
                }
                """,
                minHeight: 120
            ) {
                CountdownExample()
            }

            ExampleCard(
                title: "Follow button",
                caption: "Use `.interpolate` to morph a button's label and style in one animated update.",
                code: """
                @State private var isFollowing = false

                Button {
                    withAnimation(.snappy) { isFollowing.toggle() }
                } label: {
                    Label(isFollowing ? "Following" : "Follow",
                          systemImage: isFollowing ? "checkmark" : "plus")
                        .contentTransition(.interpolate)
                }
                .buttonStyle(.borderedProminent)
                .tint(isFollowing ? .gray : .blue)
                """,
                minHeight: 110
            ) {
                FollowExample()
            }
        }
    }
}

private func contentCode(_ config: ContentConfig) -> String {
    let animation = config.timing.label
    switch config.kind {
    case .numericText:
        return """
        @State private var count = \(config.count)

        VStack(spacing: 24) {
            Text("\\(count)")
                .font(.system(size: 72, weight: .bold, design: .rounded))
                .contentTransition(.numericText(value: Double(count)))

            HStack(spacing: 12) {
                Button("Minus", systemImage: "minus") {
                    withAnimation(\(animation)) { count -= 1 }
                }
                Button("Plus", systemImage: "plus") {
                    withAnimation(\(animation)) { count += 1 }
                }
                Button("Random", systemImage: "dice") {
                    withAnimation(\(animation)) { count = Int.random(in: 0...999) }
                }
            }
            .labelStyle(.iconOnly)
            .buttonStyle(.bordered)
            .controlSize(.large)
        }
        """
    case .symbolReplace:
        return """
        @State private var isMuted = \(config.isOn)

        VStack(spacing: 24) {
            Image(systemName: isMuted ? "speaker.slash.fill" : "speaker.wave.3.fill")
                .font(.system(size: 72))
                .contentTransition(.symbolEffect(.replace))

            Button(isMuted ? "Unmute" : "Mute") {
                withAnimation(\(animation)) { isMuted.toggle() }
            }
            .buttonStyle(.borderedProminent)
        }
        """
    default:
        return """
        @State private var isOn = \(config.isOn)

        VStack(spacing: 24) {
            Text(isOn ? "Following" : "Follow")
                .font(.system(size: 44, weight: isOn ? .black : .light))
                .foregroundStyle(isOn ? .pink : .primary)
                .contentTransition(\(config.kind.label))

            Button("Change") {
                withAnimation(\(animation)) { isOn.toggle() }
            }
            .buttonStyle(.borderedProminent)
        }
        """
    }
}

// MARK: - Examples

private struct PriceExample: View {
    @State private var quantity = 1
    private let price = 4.99

    var body: some View {
        VStack(spacing: 16) {
            Text(Double(quantity) * price, format: .currency(code: "USD"))
                .font(.largeTitle.bold())
                .contentTransition(.numericText(value: Double(quantity)))
                .animation(.snappy, value: quantity)
            Stepper("Quantity: \(quantity)", value: $quantity, in: 1...20)
                .frame(width: 220)
        }
    }
}

private struct CountdownExample: View {
    @State private var end = Date.now.addingTimeInterval(90)

    var body: some View {
        VStack(spacing: 12) {
            TimelineView(.periodic(from: .now, by: 1)) { context in
                let seconds = max(0, Int(end.timeIntervalSince(context.date)))
                Text(String(format: "%d:%02d", seconds / 60, seconds % 60))
                    .font(.system(size: 56, weight: .semibold, design: .monospaced))
                    .contentTransition(.numericText(countsDown: true))
                    .animation(.default, value: seconds)
            }
            Button("Restart", systemImage: "arrow.counterclockwise") {
                end = .now.addingTimeInterval(90)
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
        }
    }
}

private struct FollowExample: View {
    @State private var isFollowing = false

    var body: some View {
        Button {
            withAnimation(.snappy) { isFollowing.toggle() }
        } label: {
            Label(isFollowing ? "Following" : "Follow", systemImage: isFollowing ? "checkmark" : "plus")
                .contentTransition(.interpolate)
        }
        .buttonStyle(.borderedProminent)
        .tint(isFollowing ? .gray : .blue)
    }
}

/// A number that changes on its own, followed by a unit label.
private struct TickerSample: View {
    let isMonospaced: Bool
    private let values = [111, 888, 141, 808]

    var body: some View {
        TimelineView(.periodic(from: .now, by: 0.8)) { context in
            let index = Int(context.date.timeIntervalSinceReferenceDate / 0.8) % values.count
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("\(values[index])")
                    .font(.system(size: 40, weight: .bold))
                    .monospacedDigit(isMonospaced)
                Text("kcal")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
            .frame(width: 180, alignment: .leading)
        }
    }
}

private extension View {
    @ViewBuilder
    func monospacedDigit(_ isOn: Bool) -> some View {
        if isOn { monospacedDigit() } else { self }
    }
}

private struct ContentTransitionThumbnail: View {
    var body: some View {
        HStack(spacing: 0) {
            Text("4")
            // The last digit mid-roll: 1 leaving upward, 2 arriving from below.
            ZStack {
                Text("1")
                    .offset(y: -38)
                    .opacity(0.5)
                    .blur(radius: 0.5)
                Text("2")
                    .offset(y: 16)
            }
            .frame(height: 120)
            .mask {
                LinearGradient(
                    stops: [.init(color: .clear, location: 0), .init(color: .black, location: 0.3),
                            .init(color: .black, location: 0.75), .init(color: .clear, location: 1)],
                    startPoint: .top, endPoint: .bottom
                )
            }
        }
        .font(.system(size: 64, weight: .bold, design: .rounded))
        .monospacedDigit()
    }
}
