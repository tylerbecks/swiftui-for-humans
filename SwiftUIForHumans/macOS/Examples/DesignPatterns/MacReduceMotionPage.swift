import SwiftUI

extension ComponentPage {
    static let reduceMotion = ComponentPage(
        id: "reduce-motion",
        title: "Reduce Motion",
        summary: "Trade sliding, zooming, and bouncing for fades when people ask for less motion.",
        category: .accessibility,
        kind: .concept,
        symbol: "circle.dotted.and.circle",
        availability: ["macOS 10.15+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/environmentvalues/accessibilityreducemotion",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/motion",
        aliases: [
            "prefers-reduced-motion", "reduced motion", "motion sickness", "vestibular", "autoplay",
            "parallax", "accessibilityReduceMotion", "NSWorkspace accessibilityDisplayShouldReduceMotion",
            "animated images", "accessibilityPlayAnimatedImages",
        ],
        related: ["motion", "animation", "contrast-transparency", "keyboard-access"],
        notes: [
            "**It's `prefers-reduced-motion` for SwiftUI.** Read it from the environment, and the view updates when the setting changes.",
            "**Focus on your own animations.** Standard components can adjust their motion themselves. Custom transitions, springs, and anything that moves on its own are up to you.",
        ],
        api: [
            APIItem("`\\.accessibilityReduceMotion`", "True when Reduce Motion is on."),
            APIItem("`.transition(.opacity)`", "A fade, the usual stand-in for movement."),
            APIItem("`withAnimation(_:_:)`", "Pick a calmer animation, or `nil` for none."),
            APIItem("`.animation(_:value:)`", "The same choice for implicit animations."),
            APIItem("`\\.accessibilityPlayAnimatedImages`", "False when animated images shouldn't autoplay."),
        ],
        guidelines: [
            Guideline(
                "Fade instead of moving.",
                "Swap slides along any axis for a dissolve. If the motion showed where something went, keep that meaning with a highlight or a badge."
            ),
            Guideline(
                "Drop zooms, depth, and blur.",
                "Scaling, animating layers toward or away from the viewer, and animating into or out of a blur cause the most discomfort. Turn them off with the setting."
            ),
            Guideline(
                "Tighten springs.",
                "Less bounce means less movement to follow. A smooth curve that settles without overshooting works well."
            ),
            Guideline(
                "Let people stop anything that moves on its own.",
                "Stop carousels and looping backgrounds with Reduce Motion, and give them a visible pause button either way.",
                good: "Rotating tips with a pause button.",
                bad: "Tips that rotate with no way to stop them."
            ) {
                DPRotatingTip(showsPause: true)
            } bad: {
                DPRotatingTip(showsPause: false)
            },
            Guideline(
                "Never use motion as the only signal.",
                "Some people turn motion down, and others miss it. Back it up with text, a sound, or a lasting change on screen."
            ),
            Guideline(
                "Skip motion on things people do all the time.",
                "Standard controls already have subtle animations. Extra animation on a frequent action makes people wait every time."
            ),
        ],
        sources: [
            "https://developer.apple.com/design/human-interface-guidelines/motion",
            "https://developer.apple.com/design/human-interface-guidelines/accessibility",
            "https://developer.apple.com/documentation/swiftui/environmentvalues/accessibilityreducemotion",
            "https://developer.apple.com/documentation/swiftui/environmentvalues/accessibilityplayanimatedimages",
            "https://developer.apple.com/documentation/accessibility/performing-accessibility-testing-for-your-app",
        ],
        reviewed: "October 2026"
    ) {
        HStack(spacing: 16) {
            RoundedRectangle(cornerRadius: 10)
                .fill(.blue.gradient)
                .frame(width: 44, height: 44)
                .rotationEffect(.degrees(-14))
                .offset(y: -6)
            Image(systemName: "arrow.right")
                .foregroundStyle(.secondary)
            RoundedRectangle(cornerRadius: 10)
                .fill(.blue.gradient.opacity(0.45))
                .frame(width: 44, height: 44)
        }
        .accessibilityHidden(true)
    } content: { page in
        MacReduceMotionArticle(page: page)
    }
}

// MARK: - Page

private struct MacReduceMotionArticle: View {
    let page: ComponentPage
    @Environment(\.accessibilityReduceMotion) private var systemReduceMotion

    var body: some View {
        ArticlePage(page: page) {
            Prose("**Reduce Motion**, in System Settings > Accessibility, is for people who get dizzy, sick, or distracted by movement on screen. When it's on, turn off motion that's only decoration, and replace motion that carries meaning with something calmer, like a fade. Don't remove every animation: a window where things change with no transition at all is harder to follow.")

            VStack(alignment: .leading, spacing: 16) {
                SectionTitle("Try it")
                Prose("Move the file to the folder, then turn on Reduce Motion here and try again.")
                DPSystemSetting(name: "Reduce Motion", isOn: systemReduceMotion)
                MotionPlayground()
            }
            .id("demo")

            VStack(alignment: .leading, spacing: 16) {
                SectionTitle("Examples")
                    .id("examples")
                VStack(alignment: .leading, spacing: 44) {
                    ExampleCard(
                        title: "Swap a slide for a fade",
                        caption: "Read `accessibilityReduceMotion` from the environment and pick the transition with it.",
                        code: """
                        @Environment(\\.accessibilityReduceMotion) private var reduceMotion
                        @State private var showsBanner = false

                        VStack {
                            if showsBanner {
                                Text("Saved to Library")
                                    .padding(8)
                                    .background(.green.opacity(0.2), in: .capsule)
                                    .transition(reduceMotion ? .opacity : .move(edge: .top))
                            }
                            Button("Save") {
                                withAnimation { showsBanner.toggle() }
                            }
                        }
                        """,
                        minHeight: 150,
                        aside: Aside(.note, "Reduce Motion is \(systemReduceMotion ? "on" : "off") on this Mac, so the preview \(systemReduceMotion ? "fades" : "slides").")
                    ) {
                        BannerExample()
                    }

                    ExampleCard(
                        title: "Calm a spring",
                        caption: "Pass a smooth curve to `withAnimation` instead of a bouncy spring, so things settle without overshooting.",
                        code: """
                        @Environment(\\.accessibilityReduceMotion) private var reduceMotion
                        @State private var isExpanded = false

                        RoundedRectangle(cornerRadius: 12)
                            .fill(.blue.gradient)
                            .frame(width: isExpanded ? 220 : 110, height: 60)
                            .onTapGesture {
                                withAnimation(reduceMotion ? .easeInOut : .bouncy(extraBounce: 0.3)) {
                                    isExpanded.toggle()
                                }
                            }
                        """,
                        minHeight: 120
                    ) {
                        SpringExample()
                    }

                    ExampleCard(
                        title: "Stop autoplay",
                        caption: "Run the timer only while playing and Reduce Motion is off. `.task(id:)` restarts it when either one changes.",
                        code: """
                        @Environment(\\.accessibilityReduceMotion) private var reduceMotion
                        @State private var index = 0
                        @State private var isPlaying = true
                        let tips = ["Press ⌘N for a new note.", "Drag notes to reorder them.", "Press ⌘F to search."]

                        HStack {
                            Text(tips[index])
                                .id(index)
                                .transition(.opacity)
                            Button(isPlaying ? "Pause" : "Play") { isPlaying.toggle() }
                        }
                        .task(id: isPlaying && !reduceMotion) {
                            guard isPlaying && !reduceMotion else { return }
                            while !Task.isCancelled {
                                try? await Task.sleep(for: .seconds(3))
                                withAnimation { index = (index + 1) % tips.count }
                            }
                        }
                        """,
                        minHeight: 120,
                        aside: Aside(.important, "Keep the Pause button even with the check. Some people who are bothered by motion never turn the setting on.")
                    ) {
                        AutoplayExample()
                    }
                }
            }
        }
    }
}

// MARK: - Playground

/// A file that moves into a folder: flying and shrinking normally, or
/// fading with a badge on the folder when the stand-in toggle is on.
private struct MotionPlayground: View {
    @State private var reduceMotion = false
    @State private var isMoved = false
    @State private var count = 0

    var body: some View {
        VStack(spacing: 0) {
            PreviewCard(minHeight: 220, isAttached: true) {
                HStack(spacing: 120) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(.separator, style: StrokeStyle(lineWidth: 1, dash: [4, 3]))
                            .frame(width: 70, height: 84)
                        if !isMoved {
                            VStack(spacing: 4) {
                                Image(systemName: "doc.richtext.fill")
                                    .font(.system(size: 36))
                                    .foregroundStyle(.blue)
                                Text("Plan.pdf")
                                    .font(.caption)
                            }
                            .transition(reduceMotion
                                ? AnyTransition.opacity
                                : AnyTransition.offset(x: 190).combined(with: .scale(scale: 0.2)).combined(with: .opacity))
                        }
                    }
                    VStack(spacing: 4) {
                        Image(systemName: "folder.fill")
                            .font(.system(size: 44))
                            .foregroundStyle(.cyan)
                            .overlay(alignment: .topTrailing) {
                                if count > 0 {
                                    Text("\(count)")
                                        .font(.caption2.bold())
                                        .foregroundStyle(.white)
                                        .padding(5)
                                        .background(.red, in: .circle)
                                        .offset(x: 8, y: -8)
                                }
                            }
                        Text("Projects")
                            .font(.caption)
                    }
                }
            }
            Divider()
            HStack(spacing: 20) {
                Button(isMoved ? "Put It Back" : "Move to Projects") {
                    withAnimation(reduceMotion ? .easeInOut(duration: 0.3) : .spring(duration: 0.6, bounce: 0.3)) {
                        isMoved.toggle()
                        count = isMoved ? 1 : 0
                    }
                }
                Toggle("Reduce Motion", isOn: $reduceMotion)
                    .toggleStyle(.checkbox)
            }
            .padding(14)
            .frame(maxWidth: .infinity)
            .background(Surface.code)
        }
        .cardStyle()
    }
}

// MARK: - Examples

private struct BannerExample: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var showsBanner = false

    var body: some View {
        VStack {
            if showsBanner {
                Text("Saved to Library")
                    .padding(8)
                    .background(.green.opacity(0.2), in: .capsule)
                    .transition(reduceMotion ? .opacity : .move(edge: .top))
            }
            Button("Save") {
                withAnimation { showsBanner.toggle() }
            }
        }
        .frame(height: 90)
        .clipped()
    }
}

private struct SpringExample: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isExpanded = false

    var body: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(.blue.gradient)
            .frame(width: isExpanded ? 220 : 110, height: 60)
            .onTapGesture {
                withAnimation(reduceMotion ? .easeInOut : .bouncy(extraBounce: 0.3)) {
                    isExpanded.toggle()
                }
            }
            .accessibilityAddTraits(.isButton)
            .accessibilityLabel(isExpanded ? "Collapse" : "Expand")
    }
}

private struct AutoplayExample: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var index = 0
    @State private var isPlaying = true
    private let tips = ["Press ⌘N for a new note.", "Drag notes to reorder them.", "Press ⌘F to search."]

    var body: some View {
        HStack {
            Text(tips[index])
                .id(index)
                .transition(.opacity)
                .frame(width: 210, alignment: .leading)
            Button(isPlaying ? "Pause" : "Play") { isPlaying.toggle() }
        }
        .task(id: isPlaying && !reduceMotion) {
            guard isPlaying && !reduceMotion else { return }
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(3))
                withAnimation { index = (index + 1) % tips.count }
            }
        }
    }
}

/// A still drawing of a rotating tip, with or without a pause button.
private struct DPRotatingTip: View {
    let showsPause: Bool

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "lightbulb")
                .foregroundStyle(.yellow)
            Text("Drag notes to reorder them.")
                .font(.callout)
            Spacer(minLength: 0)
            if showsPause {
                Image(systemName: "pause.circle")
                    .foregroundStyle(.secondary)
                    .accessibilityLabel("Pause")
            }
        }
        .padding(10)
        .frame(width: 260)
        .background(.fill.quaternary, in: .rect(cornerRadius: 8))
    }
}
