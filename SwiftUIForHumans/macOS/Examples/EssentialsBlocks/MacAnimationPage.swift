import SwiftUI

extension ComponentPage {
    static let animation = ComponentPage(
        id: "animation",
        title: "Animation",
        summary: "Springs and transitions that stay quick and quiet under a pointer and in big windows.",
        category: .animation,
        kind: .concept,
        symbol: "wand.and.sparkles",
        availability: ["macOS 10.15+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/animations",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/motion",
        aliases: [
            "withAnimation", "spring", "transition", "animate", "ease in out", "CSS transition",
            "keyframes", "hover", "onHover", "Reduce Motion", "accessibilityReduceMotion",
            "contentTransition", "snappy", "bouncy", "smooth", "NSAnimationContext",
        ],
        related: ["hover", "reduce-motion", "motion", "state-binding"],
        notes: [
            "**Springs keep their speed when interrupted.** Click again mid-move and the next spring starts from where the view is, moving as fast as it was.",
            "**`withAnimation` animates what the change touches.** Every view that redraws because of the state you change inside it animates, wherever it is in the window.",
        ],
        api: [
            APIItem("`withAnimation(.snappy) { }`", "Animates the views a state change affects."),
            APIItem("`.animation(_:value:)`", "Animates one view whenever `value` changes."),
            APIItem("`.spring(duration:bounce:)`", "A spring you tune with two numbers."),
            APIItem("`.smooth`, `.snappy`, `.bouncy`", "Ready-made springs, from calm to lively."),
            APIItem("`.transition(_:)`", "How a view enters and leaves."),
            APIItem("`.onHover { }`", "Runs when the pointer enters or leaves."),
            APIItem("`.contentTransition(_:)`", "Animates text and symbols that change in place."),
            APIItem("`\\.accessibilityReduceMotion`", "True when people turn on Reduce Motion."),
        ],
        guidelines: [
            Guideline(
                "Add motion for a reason.",
                "Use it to show where something came from or that something changed. Motion just for show distracts people and can make some of them feel unwell."
            ),
            Guideline(
                "Keep things people do all the time quiet.",
                "A pointer passes over rows and buttons constantly, so hover feedback should be small and quick. Standard controls already animate on their own."
            ),
            Guideline(
                "Never make people wait for an animation.",
                "Let them click again, or move on, while it plays. Springs handle an interruption smoothly, so don't block input until one finishes."
            ),
            Guideline(
                "Make motion optional.",
                "With Reduce Motion on, swap slides and zooms for fades and calm the bounce. Don't let motion be the only way people learn something happened."
            ),
        ]
    ) {
        MacAnimationThumbnail()
    } content: { page in
        MacAnimationDemo(page: page)
    }
}

// MARK: - Thumbnail

private struct MacAnimationThumbnail: View {
    var body: some View {
        HStack(spacing: 10) {
            ForEach(0..<4) { index in
                RoundedRectangle(cornerRadius: 8)
                    .fill(.tint.opacity(0.25 + Double(index) * 0.25))
                    .frame(width: 26, height: 26)
                    .offset(y: [10, 2, -6, -10][index])
            }
        }
    }
}

// MARK: - Demo

private enum MacCurveOption: DemoOption {
    case smooth, snappy, bouncy, spring, easeInOut, linear

    var label: String {
        switch self {
        case .smooth: ".smooth"
        case .snappy: ".snappy"
        case .bouncy: ".bouncy"
        case .spring: ".spring"
        case .easeInOut: ".easeInOut"
        case .linear: ".linear"
        }
    }

    var hasDuration: Bool { self == .spring || self == .easeInOut || self == .linear }
}

private enum MacEffectOption: DemoOption {
    case move, grow

    var label: String {
        switch self {
        case .move: "Move across"
        case .grow: "Grow"
        }
    }
}

private struct MacAnimationConfig {
    var curve: MacCurveOption = .spring
    var duration = 0.5
    var bounce = 0.3
    var effect: MacEffectOption = .move
    var isChanged = false

    var animation: Animation {
        switch curve {
        case .smooth: .smooth
        case .snappy: .snappy
        case .bouncy: .bouncy
        case .spring: .spring(duration: duration, bounce: bounce)
        case .easeInOut: .easeInOut(duration: duration)
        case .linear: .linear(duration: duration)
        }
    }

    var animationCode: String {
        switch curve {
        case .smooth, .snappy, .bouncy: curve.label
        case .spring: ".spring(duration: \(swiftNumber(duration)), bounce: \(swiftNumber(bounce)))"
        case .easeInOut: ".easeInOut(duration: \(swiftNumber(duration)))"
        case .linear: ".linear(duration: \(swiftNumber(duration)))"
        }
    }
}

private struct MacAnimationDemo: View {
    let page: ComponentPage

    var body: some View {
        DemoPage(
            page: page,
            initial: MacAnimationConfig(),
            usage: """
            @State private var showsDetails = false

            VStack {
                Button(showsDetails ? "Hide Details" : "Show Details") {
                    withAnimation(.snappy) {
                        showsDetails.toggle()
                    }
                }
                if showsDetails {
                    Text("Recorded on October 12")
                        .transition(.opacity)
                }
            }
            """,
            usageNote: Aside(.note, "Change state inside `withAnimation`, not the view. SwiftUI works out what moved and animates it, like a CSS transition on whatever the change affects.")
        ) { $config in
            VStack(spacing: 22) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.fill.tertiary)
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.tint)
                        .frame(width: 56, height: 56)
                        .scaleEffect(config.effect == .grow && config.isChanged ? 1.6 : 1)
                        .frame(maxWidth: .infinity, alignment: config.effect == .move && config.isChanged ? .trailing : config.effect == .move ? .leading : .center)
                        .padding(14)
                }
                .frame(width: 340, height: 110)

                Button(config.isChanged ? "Back" : "Play", systemImage: "play.fill") {
                    withAnimation(config.animation) {
                        config.isChanged.toggle()
                    }
                }
                .controlSize(.large)
            }
        } controls: { $config in
            Section("Animation") {
                OptionPicker("Curve", selection: $config.curve)
                if config.curve.hasDuration {
                    ValueSlider("Duration", value: $config.duration, in: 0.1...1.5)
                }
                if config.curve == .spring {
                    ValueSlider("Bounce", value: $config.bounce, in: 0...0.8)
                }
            }
            Section("Effect") {
                OptionPicker("Change", selection: $config.effect)
            }
        } code: { config in
            var lines = ["@State private var isChanged = false", ""]
            lines.append("RoundedRectangle(cornerRadius: 12)")
            lines.append("    .fill(.tint)")
            lines.append("    .frame(width: 56, height: 56)")
            switch config.effect {
            case .move:
                lines.append("    .frame(maxWidth: .infinity, alignment: isChanged ? .trailing : .leading)")
            case .grow:
                lines.append("    .scaleEffect(isChanged ? 1.6 : 1)")
            }
            lines.append("")
            lines.append("Button(\"Play\") {")
            lines.append("    withAnimation(\(config.animationCode)) {")
            lines.append("        isChanged.toggle()")
            lines.append("    }")
            lines.append("}")
            return lines.joined(separator: "\n")
        } examples: {
            MacAnimationExamples()
        }
    }
}

// MARK: - Examples

private struct MacAnimationExamples: View {
    @State private var showsInspector = true
    @State private var downloads = 3
    @State private var showsBanner = false
    @State private var simulatesReduceMotion = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ExampleCard(
            title: "Quiet hover feedback",
            caption: "Use `.onHover` with a short `.animation(_:value:)` to highlight what's under the pointer. Keep it subtle: people pass over it all the time.",
            code: """
            struct ProjectCard: View {
                let name: String
                @State private var isHovering = false

                var body: some View {
                    Label(name, systemImage: "folder")
                        .frame(width: 140, height: 60)
                        .background(isHovering ? AnyShapeStyle(.fill.secondary) : AnyShapeStyle(.fill.quaternary),
                                    in: .rect(cornerRadius: 10))
                        .animation(.easeOut(duration: 0.12), value: isHovering)
                        .onHover { isHovering = $0 }
                }
            }

            HStack {
                ProjectCard(name: "Website")
                ProjectCard(name: "App")
                ProjectCard(name: "Docs")
            }
            """,
            minHeight: 140
        ) {
            HStack {
                MacProjectCard(name: "Website")
                MacProjectCard(name: "App")
                MacProjectCard(name: "Docs")
            }
        }

        ExampleCard(
            title: "Slide a panel in and out",
            caption: "Give the panel a `.transition`, then toggle it inside `withAnimation`. A move from the trailing edge matches where inspectors live.",
            code: """
            @State private var showsInspector = true

            HStack(spacing: 0) {
                Text("Canvas")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                if showsInspector {
                    Text("Inspector")
                        .frame(width: 140)
                        .frame(maxHeight: .infinity)
                        .background(.background.secondary)
                        .transition(.move(edge: .trailing))
                }
            }
            .clipped()

            Button("Toggle Inspector", systemImage: "sidebar.right") {
                withAnimation(.snappy) {
                    showsInspector.toggle()
                }
            }
            """,
            minHeight: 230
        ) {
            MacWindowFrame(title: "Poster", width: 420, height: 200) {
                HStack(spacing: 0) {
                    Text("Canvas")
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    if showsInspector {
                        Text("Inspector")
                            .foregroundStyle(.secondary)
                            .frame(width: 140)
                            .frame(maxHeight: .infinity)
                            .background(.background.secondary)
                            .transition(.move(edge: .trailing))
                    }
                }
                .clipped()
            } toolbar: {
                Button("Toggle Inspector", systemImage: "sidebar.right") {
                    withAnimation(.snappy) {
                        showsInspector.toggle()
                    }
                }
                .labelStyle(.iconOnly)
                .buttonStyle(.borderless)
            }
        }

        ExampleCard(
            title: "Numbers that roll",
            caption: "`.contentTransition(.numericText(value:))` animates digits as a count changes, like a downloads badge or a timer.",
            code: """
            @State private var downloads = 3

            HStack {
                Text("\\(downloads) downloads")
                    .contentTransition(.numericText(value: Double(downloads)))
                    .monospacedDigit()
                Stepper("Downloads", value: $downloads.animation(.snappy), in: 0...99)
                    .labelsHidden()
            }
            """,
            minHeight: 120
        ) {
            HStack {
                Text("\(downloads) downloads")
                    .font(.title3)
                    .contentTransition(.numericText(value: Double(downloads)))
                    .monospacedDigit()
                Stepper("Downloads", value: $downloads.animation(.snappy), in: 0...99)
                    .labelsHidden()
            }
        }

        ExampleCard(
            title: "Fade instead of slide with Reduce Motion",
            caption: "Read `accessibilityReduceMotion` and pick a calmer transition when it's on. The checkbox here stands in for the system setting.",
            code: """
            @Environment(\\.accessibilityReduceMotion) private var reduceMotion
            @State private var showsBanner = false

            VStack {
                Button("Show Banner") {
                    withAnimation(.snappy) { showsBanner.toggle() }
                }
                if showsBanner {
                    Label("Export finished", systemImage: "checkmark.circle.fill")
                        .padding(10)
                        .background(.fill.secondary, in: .capsule)
                        .transition(reduceMotion ? .opacity : .move(edge: .bottom).combined(with: .opacity))
                }
            }
            """,
            minHeight: 170,
            aside: Aside(.note, "To test the real setting, turn on Reduce motion in the Accessibility section of System Settings.")
        ) {
            let calm = simulatesReduceMotion || reduceMotion
            VStack(spacing: 14) {
                HStack(spacing: 16) {
                    Button(showsBanner ? "Hide Banner" : "Show Banner") {
                        withAnimation(.snappy) { showsBanner.toggle() }
                    }
                    Toggle("Reduce motion", isOn: $simulatesReduceMotion)
                }
                ZStack {
                    if showsBanner {
                        Label("Export finished", systemImage: "checkmark.circle.fill")
                            .padding(10)
                            .background(.fill.secondary, in: .capsule)
                            .transition(calm ? .opacity : .move(edge: .bottom).combined(with: .opacity))
                    }
                }
                .frame(height: 50)
                .clipped()
            }
        }
    }
}

private struct MacProjectCard: View {
    let name: String
    @State private var isHovering = false

    var body: some View {
        Label(name, systemImage: "folder")
            .frame(width: 140, height: 60)
            .background(isHovering ? AnyShapeStyle(.fill.secondary) : AnyShapeStyle(.fill.quaternary), in: .rect(cornerRadius: 10))
            .animation(.easeOut(duration: 0.12), value: isHovering)
            .onHover { isHovering = $0 }
    }
}
