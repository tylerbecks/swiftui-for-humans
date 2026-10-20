import SwiftUI

extension ComponentPage {
    static let reduceMotion = ComponentPage(
        id: "reduce-motion",
        title: "Reduce Motion",
        summary: "Swap big movement for fades when people ask for less motion.",
        category: .accessibility,
        kind: .concept,
        symbol: "circle.dotted.and.circle",
        availability: ["iOS 14.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/environmentvalues/accessibilityreducemotion",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/motion",
        aliases: ["prefers-reduced-motion", "reduced motion", "motion sickness", "vestibular", "autoplay", "parallax", "accessibilityReduceMotion", "UIAccessibility.isReduceMotionEnabled"],
        related: ["transitions", "spring", "animation-curves", "accessibility", "symbol-effects"],
        notes: [
            "**It's `prefers-reduced-motion` for SwiftUI.** Read it from the environment, and SwiftUI updates the view when the setting changes.",
            "**Focus on your own animations.** Apple's standard components can adjust their motion for accessibility settings themselves. Custom transitions and springs are up to you.",
        ],
        api: [
            APIItem("`\\.accessibilityReduceMotion`", "True when Reduce Motion is on."),
            APIItem("`.transition(.opacity)`", "A fade, the usual stand-in for movement."),
            APIItem("`withAnimation(_:_:)`", "Pick a calmer animation, or `nil` for none."),
            APIItem("`.animation(_:value:)`", "Same choice for implicit animations."),
            APIItem("`\\.accessibilityPlayAnimatedImages`", "False when animated images shouldn't autoplay."),
        ],
        guidelines: [
            Guideline(
                "Replace motion with a fade, don't just delete it.",
                "If an animation shows where something went, like an item landing in a cart, keep that meaning with a dissolve, highlight, or color change."
            ),
            Guideline(
                "Cut zooming, spinning, and depth effects.",
                "Parallax, big scale changes, spins, and animated blur cause the most discomfort. Turn them off or replace them when the setting is on."
            ),
            Guideline(
                "Let people pause anything that moves on its own.",
                "Carousels, looping backgrounds, and autoplaying video should stop with Reduce Motion, or at least have a visible pause button.",
                good: "Auto-advancing, with a pause button.",
                bad: "Moves forever with no way to stop it."
            ) {
                ReduceMotionPromo(showsPause: true)
            } bad: {
                ReduceMotionPromo(showsPause: false)
            },
            Guideline(
                "Don't make people wait for an animation.",
                "Keep feedback short, and let people act before it finishes, especially for something they'll see many times."
            ),
            Guideline(
                "Never use motion as the only signal.",
                "Some people turn motion down or don't notice it. Pair it with text, a color or shape change, or a haptic."
            ),
        ],
        sources: [
            "https://developer.apple.com/design/human-interface-guidelines/accessibility",
            "https://developer.apple.com/design/human-interface-guidelines/motion",
            "https://developer.apple.com/documentation/swiftui/environmentvalues/accessibilityreducemotion",
            "https://developer.apple.com/documentation/swiftui/environmentvalues/accessibilityplayanimatedimages",
            "https://developer.apple.com/help/app-store-connect/manage-app-accessibility/reduced-motion-evaluation-criteria",
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
        ReduceMotionArticle(page: page)
    }
}

// MARK: - Page

private struct ReduceMotionArticle: View {
    let page: ComponentPage
    @Environment(\.accessibilityReduceMotion) private var systemReduceMotion

    var body: some View {
        ArticlePage(page: page) {
            Prose("**Reduce Motion** is a setting for people who get dizzy, nauseous, or distracted by movement on screen. When it's on, turn off motion that's only decoration, and replace motion that carries meaning with something calmer, like a fade. Don't strip every animation: an app with no transitions at all can be more confusing.")

            VStack(alignment: .leading, spacing: 16) {
                SectionTitle("Try it")
                ReduceMotionPlayground()
            }
            .id("demo")

            VStack(alignment: .leading, spacing: 16) {
                SectionTitle("What to change")
                Prose("When the setting is on, check every custom animation:")
                VStack(alignment: .leading, spacing: 10) {
                    ReduceMotionRow(symbol: "arrow.up.left.and.arrow.down.right", title: "Zoom and scale", fix: "Fade instead")
                    ReduceMotionRow(symbol: "arrow.left.and.right", title: "Big slides across the screen", fix: "Fade or dissolve")
                    ReduceMotionRow(symbol: "arrow.trianglehead.2.clockwise.rotate.90", title: "Spins and swirls", fix: "Turn off")
                    ReduceMotionRow(symbol: "square.3.layers.3d", title: "Parallax, depth, animated blur", fix: "Turn off")
                    ReduceMotionRow(symbol: "waveform.path", title: "Bouncy springs", fix: "Use a smooth curve")
                    ReduceMotionRow(symbol: "play.rectangle.on.rectangle", title: "Autoplay and loops", fix: "Stop, or add Pause")
                }
                .padding(14)
                .background(.background.secondary, in: .rect(cornerRadius: 16))
            }
            .id("what-to-change")

            VStack(alignment: .leading, spacing: 16) {
                SectionTitle("Examples")
                VStack(alignment: .leading, spacing: 44) {
                    ExampleCard(
                        title: "Swap a slide for a fade",
                        caption: "Read `accessibilityReduceMotion` from the environment and pick the transition with it.",
                        code: """
                        @Environment(\\.accessibilityReduceMotion) private var reduceMotion
                        @State private var showsBanner = false

                        VStack {
                            if showsBanner {
                                Text("Saved to Favorites")
                                    .padding()
                                    .background(.green.opacity(0.2), in: .capsule)
                                    .transition(reduceMotion ? .opacity : .move(edge: .top))
                            }
                            Button("Save") {
                                withAnimation { showsBanner.toggle() }
                            }
                        }
                        """,
                        minHeight: 160,
                        aside: Aside(.note, "On this device, Reduce Motion is \(systemReduceMotion ? "on" : "off"), so the preview shows the \(systemReduceMotion ? "fade" : "slide").")
                    ) {
                        ReduceMotionBannerExample()
                    }

                    ExampleCard(
                        title: "Calm a spring",
                        caption: "Pass a smooth curve to `withAnimation` instead of a bouncy spring, so things settle without overshooting.",
                        code: """
                        @Environment(\\.accessibilityReduceMotion) private var reduceMotion
                        @State private var isExpanded = false

                        RoundedRectangle(cornerRadius: 16)
                            .fill(.blue.gradient)
                            .frame(width: isExpanded ? 200 : 100, height: 80)
                            .onTapGesture {
                                withAnimation(reduceMotion ? .easeInOut : .bouncy(extraBounce: 0.3)) {
                                    isExpanded.toggle()
                                }
                            }
                        """,
                        minHeight: 140
                    ) {
                        ReduceMotionSpringExample()
                    }

                    ExampleCard(
                        title: "Stop autoplay",
                        caption: "Only run the timer while playing and Reduce Motion is off. `.task(id:)` restarts it when either changes.",
                        code: """
                        @Environment(\\.accessibilityReduceMotion) private var reduceMotion
                        @State private var page = 0
                        @State private var isPlaying = true

                        TabView(selection: $page) {
                            ForEach(0..<3, id: \\.self) { index in
                                Text("Deal \\(index + 1)").tag(index)
                            }
                        }
                        .tabViewStyle(.page)
                        .task(id: isPlaying && !reduceMotion) {
                            guard isPlaying && !reduceMotion else { return }
                            while !Task.isCancelled {
                                try? await Task.sleep(for: .seconds(3))
                                withAnimation { page = (page + 1) % 3 }
                            }
                        }
                        """,
                        minHeight: 200,
                        aside: Aside(.important, "Add a visible Pause button anyway. Some people who are bothered by motion never turn the setting on.")
                    ) {
                        ReduceMotionCarousel()
                    }
                }
            }
            .id("examples")
        }
    }
}

// MARK: - Playground

private struct ReduceMotionPlayground: View {
    @State private var reduceMotion = false
    @State private var inCart = false
    @State private var count = 0
    @State private var flash = false

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Add the item to the cart, then turn on Reduce Motion and try again.")
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            VStack(spacing: 0) {
                PreviewCard(minHeight: 260, isAttached: true) {
                    VStack(spacing: 20) {
                        HStack {
                            Spacer()
                            Image(systemName: "cart.fill")
                                .font(.title2)
                                .foregroundStyle(.tint)
                                .overlay(alignment: .topTrailing) {
                                    if count > 0 {
                                        Text("\(count)")
                                            .font(.caption2.bold())
                                            .foregroundStyle(.white)
                                            .padding(5)
                                            .background(.red, in: .circle)
                                            .offset(x: 10, y: -10)
                                            .contentTransition(.numericText())
                                    }
                                }
                                .symbolEffect(.bounce, value: reduceMotion ? 0 : count)
                                .background {
                                    Circle()
                                        .fill(.tint.opacity(flash ? 0.25 : 0))
                                        .frame(width: 52, height: 52)
                                }
                        }
                        .frame(height: 44)
                        ZStack {
                            if !inCart {
                                Label("AirPods Pro", systemImage: "airpodspro")
                                    .font(.headline)
                                    .padding(16)
                                    .frame(maxWidth: 240)
                                    .background(.background.secondary, in: .rect(cornerRadius: 14))
                                    .transition(reduceMotion
                                        ? AnyTransition.opacity
                                        : AnyTransition.scale(scale: 0.2, anchor: .topTrailing).combined(with: .offset(x: 80, y: -90)).combined(with: .opacity))
                            } else {
                                Text("Added to cart")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .transition(.opacity)
                            }
                        }
                        .frame(height: 60)
                        Button(inCart ? "Reset" : "Add to Cart") {
                            if inCart {
                                withAnimation(.default) { inCart = false }
                            } else {
                                withAnimation(reduceMotion ? .easeInOut(duration: 0.3) : .bouncy(duration: 0.6, extraBounce: 0.2)) {
                                    inCart = true
                                    count += 1
                                }
                                if reduceMotion {
                                    withAnimation(.easeInOut(duration: 0.3)) { flash = true }
                                    Task {
                                        try? await Task.sleep(for: .seconds(0.7))
                                        withAnimation(.easeInOut(duration: 0.4)) { flash = false }
                                    }
                                }
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .frame(maxWidth: 320)
                }
                Divider()
                FlowLayout(spacing: 8) {
                    A11ySimToggle(title: "Reduce Motion", symbol: "circle.dotted.and.circle", isOn: $reduceMotion)
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                Divider()
                CodeBlock(code: code, isCollapsible: true, isAttached: true)
            }
            .cardStyle()
        }
    }

    private var code: String {
        """
        @Environment(\\.accessibilityReduceMotion) private var reduceMotion

        // The item flies into the cart, or fades out.
        .transition(reduceMotion
            ? .opacity
            : .scale(scale: 0.2, anchor: .topTrailing).combined(with: .opacity))

        // The cart bounces, or gets a soft highlight.
        withAnimation(reduceMotion ? .easeInOut : .bouncy) {
            inCart = true
        }
        """
    }
}

private struct ReduceMotionRow: View {
    let symbol: String
    let title: String
    let fix: String

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            Image(systemName: symbol)
                .foregroundStyle(.tint)
                .frame(width: 24)
                .accessibilityHidden(true)
            Text(title)
            Spacer(minLength: 8)
            Text(fix)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.trailing)
        }
        .font(.subheadline)
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Example views

private struct ReduceMotionBannerExample: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var showsBanner = false

    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                if showsBanner {
                    Text("Saved to Favorites")
                        .padding()
                        .background(.green.opacity(0.2), in: .capsule)
                        .transition(reduceMotion ? .opacity : .move(edge: .top))
                }
            }
            .frame(height: 56)
            .clipped()
            Button(showsBanner ? "Hide" : "Save") {
                withAnimation { showsBanner.toggle() }
            }
            .buttonStyle(.bordered)
        }
    }
}

private struct ReduceMotionSpringExample: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isExpanded = false

    var body: some View {
        VStack(spacing: 10) {
            RoundedRectangle(cornerRadius: 16)
                .fill(.blue.gradient)
                .frame(width: isExpanded ? 200 : 100, height: 80)
                .onTapGesture {
                    withAnimation(reduceMotion ? .easeInOut : .bouncy(extraBounce: 0.3)) {
                        isExpanded.toggle()
                    }
                }
                .accessibilityAddTraits(.isButton)
                .accessibilityLabel(isExpanded ? "Collapse" : "Expand")
            Text("Tap the shape")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
}

private struct ReduceMotionCarousel: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var page = 0
    @State private var isPlaying = true
    private let colors: [Color] = [.orange, .pink, .indigo]

    var body: some View {
        VStack(spacing: 10) {
            TabView(selection: $page) {
                ForEach(0..<3, id: \.self) { index in
                    Text("Deal \(index + 1)")
                        .font(.title2.bold())
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(colors[index].gradient, in: .rect(cornerRadius: 16))
                        .padding(.horizontal, 4)
                        .tag(index)
                }
            }
            .tabViewStyle(.page)
            .frame(width: 260, height: 130)
            .task(id: isPlaying && !reduceMotion) {
                guard isPlaying && !reduceMotion else { return }
                while !Task.isCancelled {
                    try? await Task.sleep(for: .seconds(3))
                    guard !Task.isCancelled else { return }
                    withAnimation { page = (page + 1) % 3 }
                }
            }
            Button(isPlaying ? "Pause" : "Play", systemImage: isPlaying ? "pause.fill" : "play.fill") {
                isPlaying.toggle()
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
        }
    }
}

/// For the guideline pair: a looping promo, with or without a pause button.
private struct ReduceMotionPromo: View {
    let showsPause: Bool
    @State private var isPaused = false

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "sparkles")
                .font(.title)
                .foregroundStyle(.orange)
                .symbolEffect(.wiggle, options: .repeat(.continuous), isActive: !isPaused)
                .accessibilityHidden(true)
            Text("Summer Sale")
                .font(.headline)
            if showsPause {
                Button(isPaused ? "Play" : "Pause", systemImage: isPaused ? "play.fill" : "pause.fill") {
                    isPaused.toggle()
                }
                .labelStyle(.iconOnly)
                .buttonStyle(.bordered)
                .buttonBorderShape(.circle)
                .controlSize(.small)
            }
        }
    }
}
