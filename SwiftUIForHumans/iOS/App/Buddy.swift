import SwiftUI

/// A small face, the app icon's `{•‿•}`, that peeks in from the
/// bottom-trailing corner with a question. It's not a modal: the app stays
/// usable behind it, it tucks itself away if ignored, and it can be swiped
/// off the edge.
///
/// Tapping the bubble opens a small card above the face:
/// - "Enjoying the app?" → **Love it** shows the tips, **Not really** asks
///   what to fix (by email).
/// - After a tip, it says thanks and leaves.
///
/// `Engagement` decides when it appears. Launch with `-buddy` to show it
/// right away, and `-sampleTips` to fill in tips without a StoreKit file.
struct BuddyOverlay: View {
    @Environment(\.horizontalSizeClass) private var sizeClass
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var step: Step = .peeking
    @State private var dragOffset: CGFloat = 0
    @State private var tuckTask: Task<Void, Never>?

    private var engagement: Engagement { .shared }

    enum Step { case peeking, asking, tipping, feedback, thanks }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            if engagement.isBuddyShown {
                VStack(alignment: .trailing, spacing: 10) {
                    if step != .peeking {
                        card
                            .transition(cardTransition)
                    }
                    HStack(alignment: .center, spacing: 6) {
                        if step == .peeking {
                            bubble
                                .transition(bubbleTransition)
                        }
                        BuddyFace(mood: step == .thanks ? .happy : .curious)
                            .frame(width: 58, height: 58)
                            .rotationEffect(.degrees(-14))
                            // Half hidden past the edge: peeking, not parked.
                            .offset(x: 22)
                            .onTapGesture { open() }
                            .accessibilityHidden(true)
                    }
                }
                .offset(x: max(0, dragOffset))
                .gesture(swipeAway)
                .padding(.bottom, sizeClass == .compact ? 76 : 24)
                .padding(.trailing, sizeClass == .compact ? 0 : 8)
                .transition(peekTransition)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
        .animation(reduceMotion ? .easeInOut(duration: 0.25) : .spring(duration: 0.5, bounce: 0.35), value: engagement.isBuddyShown)
        .animation(reduceMotion ? .easeInOut(duration: 0.25) : .spring(duration: 0.4, bounce: 0.2), value: step)
        .onChange(of: engagement.isBuddyShown) { _, shown in
            if shown {
                step = .peeking
                scheduleTuck(after: .seconds(8))
            }
        }
        .task {
            if LaunchOptions.isSet("-buddy") {
                try? await Task.sleep(for: .seconds(1))
                engagement.showBuddyForTesting()
                if LaunchOptions.value(for: "-buddy") == "tips" {
                    try? await Task.sleep(for: .seconds(0.8))
                    open()
                    step = .tipping
                }
            }
        }
    }

    // MARK: Pieces

    private var bubble: some View {
        Button(action: open) {
            Text("Psst… enjoying the app?")
                .font(.subheadline.weight(.medium))
                .padding(.horizontal, 14)
                .padding(.vertical, 9)
                .glassEffect(.regular.interactive(), in: .capsule)
        }
        .buttonStyle(.plain)
        .accessibilityHint("Answers a quick question about the app")
        .accessibilityAction(named: "Not now") { tuck() }
    }

    private var card: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .firstTextBaseline) {
                Text(title)
                    .font(.headline)
                Spacer(minLength: 12)
                Button("Close", systemImage: "xmark") { tuck() }
                    .labelStyle(.iconOnly)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .buttonStyle(.plain)
            }
            switch step {
            case .asking:
                HStack(spacing: 10) {
                    Button { step = .tipping } label: {
                        Label("Love it", systemImage: "heart.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.glassProminent)
                    Button { step = .feedback } label: {
                        Text("Not really")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.glass)
                }
                .controlSize(.large)
            case .tipping:
                Text("It's free, and always will be. If it's saved you some time, a tip helps keep the pages up to date.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                TipButtons(compact: true) { thank() }
                HStack {
                    Button("Maybe later") { tuck() }
                        .foregroundStyle(.tint)
                    Spacer()
                    Button("Don't ask again") { engagement.buddyOptOut() }
                        .foregroundStyle(.secondary)
                }
                .font(.subheadline)
                .buttonStyle(.plain)
            case .feedback:
                Text("Sorry to hear that. Tell me what's missing or what's wrong, and I'll fix it.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                Link(destination: AppInfo.feedbackURL) {
                    Label("Email Feedback", systemImage: "envelope")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.glassProminent)
                .controlSize(.large)
                .simultaneousGesture(TapGesture().onEnded { tuck() })
            case .thanks:
                Text("That means a lot. Enjoy the coffee-powered updates.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            case .peeking:
                EmptyView()
            }
        }
        .padding(18)
        .frame(width: 320)
        // Solid, not glass: the card holds text and prices that must stay
        // readable over any page, including busy previews.
        .background(.background, in: .rect(cornerRadius: 26))
        .overlay {
            RoundedRectangle(cornerRadius: 26)
                .strokeBorder(.separator)
        }
        .shadow(color: .black.opacity(0.18), radius: 24, y: 8)
        .padding(.trailing, 16)
    }

    private var title: String {
        switch step {
        case .asking, .peeking: "Enjoying \(AppInfo.name)?"
        case .tipping: "Buy me a coffee?"
        case .feedback: "What should I fix?"
        case .thanks: "Thank you! ☕️"
        }
    }

    // MARK: Behavior

    private func open() {
        tuckTask?.cancel()
        if step == .peeking { step = .asking }
    }

    private func thank() {
        step = .thanks
        scheduleTuck(after: .seconds(3))
    }

    private func tuck() {
        tuckTask?.cancel()
        engagement.buddyDismissed()
        dragOffset = 0
    }

    /// Ignored, it slips back out of sight.
    private func scheduleTuck(after delay: Duration) {
        tuckTask?.cancel()
        tuckTask = Task {
            try? await Task.sleep(for: delay)
            guard !Task.isCancelled else { return }
            tuck()
        }
    }

    private var swipeAway: some Gesture {
        DragGesture(minimumDistance: 12)
            .onChanged { dragOffset = $0.translation.width }
            .onEnded { value in
                if value.translation.width > 60 || value.predictedEndTranslation.width > 140 {
                    tuck()
                } else {
                    withAnimation(.spring) { dragOffset = 0 }
                }
            }
    }

    // MARK: Transitions

    private var peekTransition: AnyTransition {
        reduceMotion ? .opacity : .move(edge: .trailing).combined(with: .opacity)
    }

    private var bubbleTransition: AnyTransition {
        reduceMotion ? .opacity : .scale(scale: 0.4, anchor: .trailing).combined(with: .opacity)
    }

    private var cardTransition: AnyTransition {
        reduceMotion ? .opacity : .scale(scale: 0.6, anchor: .bottomTrailing).combined(with: .opacity)
    }
}

/// The app icon's face: braces, two eyes, and a smile on the icon's
/// gradient. It blinks now and then and leans in when it appears.
struct BuddyFace: View {
    enum Mood { case curious, happy }
    var mood: Mood = .curious

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isBlinking = false
    @State private var lean = false

    var body: some View {
        Canvas { context, size in
            let s = size.width / 100
            func point(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: x * s, y: y * s) }
            let stroke = StrokeStyle(lineWidth: 5.5 * s, lineCap: .round, lineJoin: .round)

            // Braces, as in the icon.
            for side in [CGFloat(1), -1] {
                let cx: CGFloat = side == 1 ? 24 : 76
                var brace = Path()
                brace.move(to: point(cx + 7 * side, 24))
                brace.addQuadCurve(to: point(cx + 1 * side, 30), control: point(cx + 1 * side, 24))
                brace.addLine(to: point(cx + 1 * side, 44))
                brace.addQuadCurve(to: point(cx - 5 * side, 50), control: point(cx + 1 * side, 50))
                brace.addQuadCurve(to: point(cx + 1 * side, 56), control: point(cx + 1 * side, 50))
                brace.addLine(to: point(cx + 1 * side, 70))
                brace.addQuadCurve(to: point(cx + 7 * side, 76), control: point(cx + 1 * side, 76))
                context.stroke(brace, with: .color(.white), style: stroke)
            }

            // Eyes look toward the bubble, on the leading side.
            let eyeHeight: CGFloat = isBlinking ? 1.5 : (mood == .happy ? 5 : 8)
            for x in [38.0, 54.0] {
                let rect = CGRect(x: (x - 4) * s, y: (44 - eyeHeight / 2) * s, width: 8 * s, height: eyeHeight * s)
                if mood == .happy && !isBlinking {
                    var arc = Path()
                    arc.addArc(center: point(x, 46), radius: 4 * s, startAngle: .degrees(200), endAngle: .degrees(340), clockwise: false)
                    context.stroke(arc, with: .color(.white), style: StrokeStyle(lineWidth: 3 * s, lineCap: .round))
                } else {
                    context.fill(Path(ellipseIn: rect), with: .color(.white))
                }
            }

            // Smile, bigger when happy.
            var smile = Path()
            let radius: CGFloat = mood == .happy ? 14 : 11
            smile.addArc(center: point(47, 52), radius: radius * s, startAngle: .degrees(30), endAngle: .degrees(150), clockwise: false)
            context.stroke(smile, with: .color(.white), style: stroke)
        }
        .background(
            LinearGradient(colors: [Color(hex: 0x1E8BFF), Color(hex: 0x5B6CFF)], startPoint: .top, endPoint: .bottom),
            in: .rect(cornerRadius: 15)
        )
        .shadow(color: Color(hex: 0x2A7BFF).opacity(0.35), radius: 10, y: 4)
        .rotationEffect(.degrees(lean ? -6 : 0), anchor: .bottomTrailing)
        .task {
            guard !reduceMotion else { return }
            // Lean in once, as if curious, then blink every few seconds.
            withAnimation(.spring(duration: 0.6, bounce: 0.5).delay(0.3)) { lean = true }
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(Double.random(in: 2.2...4.0)))
                withAnimation(.easeIn(duration: 0.08)) { isBlinking = true }
                try? await Task.sleep(for: .seconds(0.12))
                withAnimation(.easeOut(duration: 0.1)) { isBlinking = false }
            }
        }
    }
}

#Preview {
    BuddyFace()
        .frame(width: 120, height: 120)
}
