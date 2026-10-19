import SwiftUI

extension ComponentPage {
    static let motion = ComponentPage(
        id: "motion",
        title: "Motion",
        summary: "Animate to explain a change, keep it brief, and tone it down for Reduce Motion.",
        category: .foundations,
        kind: .concept,
        symbol: "wind",
        availability: [],
        docsURL: "https://developer.apple.com/documentation/swiftui/animation",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/motion",
        aliases: ["animation", "animations", "transition", "reduce motion", "prefers-reduced-motion", "spring", "easing", "withAnimation", "bounce", "fade", "NSAnimationContext", "accessibilityReduceMotion"],
        related: ["animation", "reduce-motion", "sf-symbols", "materials"],
        notes: [
            "**Many system components already animate.** Use them as they are, and add your own motion only to custom views, following the same rules.",
            "**Test with Reduce Motion on.** Turn it on in the Mac's Accessibility settings and walk through your app: anything that still zooms, slides, or bounces on its own needs a quieter version.",
        ],
        api: [
            APIItem("`withAnimation(_:_:)`", "Animates the changes a state update causes."),
            APIItem("`.animation(_:value:)`", "Animates a view when one value changes."),
            APIItem("`.transition(_:)`", "How a view enters and leaves."),
            APIItem("`.contentTransition(.numericText())`", "Rolls digits when a number changes."),
            APIItem("`\\.accessibilityReduceMotion`", "True when Reduce Motion is on."),
            APIItem("`.symbolEffect(_:value:)`", "A short symbol animation as feedback."),
        ],
        guidelines: [
            Guideline(
                "Animate with a purpose.",
                "Motion should explain something, like where a new item came from. Animation added for its own sake distracts, and it can make some people feel unwell."
            ),
            Guideline(
                "Keep feedback short and precise.",
                "A quick animation tied exactly to what someone did reads instantly. A long or showy one gets in the way."
            ),
            Guideline(
                "Never make people wait for an animation.",
                "Skip custom motion on things people do over and over, like selecting rows, and let them keep working or cancel while something moves."
            ),
            Guideline(
                "Match the motion to the action.",
                "If a panel slides down to appear, it should slide back up to leave, not off to the side. Motion that contradicts the action disorients."
            ),
            Guideline(
                "Don't rely on motion alone.",
                "Some people turn motion down or miss it. Say what happened in another way too, like a label or a changed state."
            ),
            Guideline(
                "Tone it down for Reduce Motion.",
                "Cut automatic and repeating animations, zooming, and scaling. Swap slides for fades, tighten springs so they don't bounce, and don't animate blurs or depth."
            ),
        ],
        sources: [
            "https://developer.apple.com/design/human-interface-guidelines/motion",
            "https://developer.apple.com/design/human-interface-guidelines/accessibility",
            "https://developer.apple.com/documentation/swiftui/animation",
            "https://developer.apple.com/documentation/swiftui/environmentvalues/accessibilityreducemotion",
            "https://developer.apple.com/documentation/swiftui/view/contenttransition(_:)",
        ],
        reviewed: "October 2026"
    ) {
        HStack(spacing: 8) {
            ForEach(0..<4, id: \.self) { index in
                RoundedRectangle(cornerRadius: 6)
                    .fill(.tint.opacity(0.25 + Double(index) * 0.25))
                    .frame(width: 22, height: 22)
                    .offset(y: Double(index) * -6)
            }
        }
    } content: { page in
        MacMotionArticle(page: page)
    }
}

// MARK: - Page

private struct MacMotionArticle: View {
    let page: ComponentPage

    var body: some View {
        ArticlePage(page: page) {
            Prose("Good motion shows people what changed and where it went. Many system components animate on their own and adjust for settings like Reduce Motion. Add your own sparingly: short, tied to what someone did, and always with a calmer version for people who turn on **Reduce Motion**.")

            VStack(alignment: .leading, spacing: 16) {
                SectionTitle("Try it")
                    .id("demo")
                MacMotionDemo()
            }

            VStack(alignment: .leading, spacing: 16) {
                SectionTitle("In SwiftUI")
                    .id("examples")
                VStack(alignment: .leading, spacing: 44) {
                    ExampleCard(
                        title: "Animate a change people made",
                        caption: "Wrap the state change in `withAnimation(.snappy)` so a new row eases in where it lands.",
                        code: """
                        @State private var stops = ["Alfama", "Belém"]

                        VStack(alignment: .leading) {
                            ForEach(stops, id: \\.self) { stop in
                                Label(stop, systemImage: "mappin")
                            }
                            Button("Add Stop") {
                                withAnimation(.snappy) {
                                    stops.append("Stop \\(stops.count + 1)")
                                }
                            }
                        }
                        """,
                        minHeight: 180
                    ) {
                        MacAddStopSample()
                    }

                    ExampleCard(
                        title: "Fade instead of slide for Reduce Motion",
                        caption: "Read `accessibilityReduceMotion` and pick an `.opacity` transition when it's on.",
                        code: """
                        @Environment(\\.accessibilityReduceMotion) private var reduceMotion
                        @State private var showsBanner = false

                        VStack {
                            Button(showsBanner ? "Hide Banner" : "Show Banner") {
                                withAnimation { showsBanner.toggle() }
                            }
                            if showsBanner {
                                Text("Your trip is saved.")
                                    .padding(10)
                                    .background(.fill.tertiary, in: .rect(cornerRadius: 8))
                                    .transition(reduceMotion ? .opacity : .move(edge: .top).combined(with: .opacity))
                            }
                        }
                        """,
                        minHeight: 150
                    ) {
                        MacReduceMotionSample()
                    }

                    ExampleCard(
                        title: "Let numbers roll",
                        caption: "`.contentTransition(.numericText())` animates only the digits that change, so a count updates without a jump.",
                        code: """
                        @State private var travelers = 2

                        HStack {
                            Text("\\(travelers) travelers")
                                .contentTransition(.numericText())
                            Stepper("Travelers", value: $travelers.animation(), in: 1...9)
                                .labelsHidden()
                        }
                        """,
                        minHeight: 110
                    ) {
                        MacNumericSample()
                    }
                }
            }
        }
    }
}

// MARK: - Demo

private enum MacMotionStyle: String, CaseIterable, Identifiable {
    case none = "None"
    case snappy = "Snappy"
    case bouncy = "Bouncy"

    var id: Self { self }

    var animation: Animation? {
        switch self {
        case .none: nil
        case .snappy: .snappy
        case .bouncy: .bouncy
        }
    }
}

/// Add and remove a card with different animations, and see what Reduce
/// Motion should turn it into.
private struct MacMotionDemo: View {
    @State private var style = MacMotionStyle.snappy
    @State private var simulatesReduceMotion = false
    @State private var stops = [1, 2]

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 14) {
                HStack(spacing: 10) {
                    ForEach(stops, id: \.self) { stop in
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.tint.opacity(0.2))
                            .overlay {
                                Text("Stop \(stop)")
                            }
                            .frame(width: 90, height: 64)
                            .transition(simulatesReduceMotion ? .opacity : .scale(scale: 0.6).combined(with: .opacity))
                    }
                }
                .frame(height: 70)
                HStack {
                    Button("Add Stop") {
                        withAnimation(animation) {
                            stops.append((stops.max() ?? 0) + 1)
                        }
                    }
                    .disabled(stops.count >= 5)
                    Button("Remove Stop") {
                        withAnimation(animation) {
                            _ = stops.popLast()
                        }
                    }
                    .disabled(stops.isEmpty)
                }
            }
            .padding(24)
            .frame(maxWidth: .infinity, minHeight: 190)
            .background(Surface.preview)
            Divider()
            HStack(spacing: 20) {
                Picker("Animation", selection: $style) {
                    ForEach(MacMotionStyle.allCases) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
                .pickerStyle(.segmented)
                .fixedSize()
                Toggle("Simulate Reduce Motion", isOn: $simulatesReduceMotion)
                Spacer(minLength: 0)
            }
            .padding(14)
            Divider()
            CodeBlock(code: code, isAttached: true)
        }
        .cardStyle()
    }

    /// Under Reduce Motion, a bouncy spring becomes a plain ease.
    private var animation: Animation? {
        if simulatesReduceMotion, style == .bouncy {
            return .easeInOut
        }
        return style.animation
    }

    private var code: String {
        let transition = simulatesReduceMotion ? ".opacity" : ".scale(scale: 0.6).combined(with: .opacity)"
        let add = "stops.append((stops.max() ?? 0) + 1)"
        let call: String
        switch (style, simulatesReduceMotion) {
        case (.none, _): call = add
        case (.bouncy, true): call = "withAnimation(.easeInOut) { \(add) }"
        default: call = "withAnimation(.\(style.rawValue.lowercased())) { \(add) }"
        }
        return """
        @State private var stops = [1, 2]

        VStack {
            HStack {
                ForEach(stops, id: \\.self) { stop in
                    Text("Stop \\(stop)")
                        .frame(width: 90, height: 64)
                        .background(.tint.opacity(0.2), in: .rect(cornerRadius: 10))
                        .transition(\(transition))
                }
            }
            Button("Add Stop") {
                \(call)
            }
        }
        """
    }
}

// MARK: - Samples

private struct MacAddStopSample: View {
    @State private var stops = ["Alfama", "Belém"]

    var body: some View {
        VStack(alignment: .leading) {
            ForEach(stops, id: \.self) { stop in
                Label(stop, systemImage: "mappin")
            }
            Button("Add Stop") {
                withAnimation(.snappy) {
                    stops.append("Stop \(stops.count + 1)")
                }
            }
            .disabled(stops.count >= 5)
        }
    }
}

private struct MacReduceMotionSample: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var showsBanner = false

    var body: some View {
        VStack {
            Button(showsBanner ? "Hide Banner" : "Show Banner") {
                withAnimation { showsBanner.toggle() }
            }
            if showsBanner {
                Text("Your trip is saved.")
                    .padding(10)
                    .background(.fill.tertiary, in: .rect(cornerRadius: 8))
                    .transition(reduceMotion ? .opacity : .move(edge: .top).combined(with: .opacity))
            }
        }
        .frame(height: 90, alignment: .top)
    }
}

private struct MacNumericSample: View {
    @State private var travelers = 2

    var body: some View {
        HStack {
            Text("\(travelers) travelers")
                .contentTransition(.numericText())
            Stepper("Travelers", value: $travelers.animation(), in: 1...9)
                .labelsHidden()
        }
    }
}
