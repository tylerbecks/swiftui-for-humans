import SwiftUI

extension ComponentPage {
    static let transitions = ComponentPage(
        id: "transitions",
        title: "Transitions",
        summary: "Control how a view animates in when it's added and out when it's removed.",
        category: .animation,
        kind: .modifier,
        symbol: "rectangle.righthalf.inset.filled.arrow.right",
        availability: ["iOS 13.0+", "macOS 10.15+", "visionOS 1.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/anytransition",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/motion",
        aliases: ["enter animation", "exit animation", "fade in", "slide in", "AnimatePresence", "v-if transition", "show hide", "appear", "insertion", "removal"],
        related: ["animation-curves", "matched-geometry", "content-transition", "spring"],
        notes: [
            "**Like `AnimatePresence`, built in.** On the web you keep an element mounted until its exit animation ends. In SwiftUI, removing it inside an animated change is enough.",
            "**The default is `.opacity`.** A view inside an animated `if` fades in and out even without a `.transition` modifier.",
        ],
        api: [
            APIItem("`.transition(_:)`", "How this view enters and leaves."),
            APIItem("`.opacity`, `.scale`, `.slide`", "Fade, grow from the center, or slide across."),
            APIItem("`.move(edge:)`", "Slides in from an edge and out the same way."),
            APIItem("`.push(from:)`", "Pushes in from one edge while the old view leaves the other."),
            APIItem("`.combined(with:)`", "Runs two transitions at once, like move and fade."),
            APIItem("`.asymmetric(insertion:removal:)`", "Different transitions for entering and leaving."),
            APIItem("`.blurReplace`", "Blurs and fades, good for swapping content (iOS 17+)."),
        ],
        guidelines: [
            Guideline(
                "Leave the way you came in.",
                "A banner that drops from the top should go back up. Leaving in a new direction breaks the sense of where it lives.",
                good: "Enters and leaves through the top.",
                bad: "Drops in from the top, then exits sideways."
            ) {
                ExitSample(removal: .move(edge: .top).combined(with: .opacity))
            } bad: {
                ExitSample(removal: .move(edge: .trailing).combined(with: .opacity))
            },
            Guideline(
                "Keep transitions quick and subtle.",
                "A short fade or slide shows what changed without making people watch it. Save big entrances for rare moments."
            ),
            Guideline(
                "Fall back to a fade with Reduce Motion.",
                "Sliding and scaling can be uncomfortable for some people. When `accessibilityReduceMotion` is on, use `.opacity` instead."
            ),
        ]
    ) {
        TransitionsThumbnail()
    } content: { page in
        TransitionsDemo(page: page)
    }
}

// MARK: - Model

private enum TransitionOption: DemoOption {
    case opacity, slide, move, scale, push, blurReplace, combined, asymmetric

    var label: String {
        switch self {
        case .opacity: ".opacity"
        case .slide: ".slide"
        case .move: ".move(edge:)"
        case .scale: ".scale"
        case .push: ".push(from:)"
        case .blurReplace: ".blurReplace"
        case .combined: "scale + opacity"
        case .asymmetric: "asymmetric"
        }
    }

    var usesEdge: Bool { self == .move || self == .push }

    func transition(edge: Edge) -> AnyTransition {
        switch self {
        case .opacity: .opacity
        case .slide: .slide
        case .move: .move(edge: edge)
        case .scale: .scale
        case .push: .push(from: edge)
        case .blurReplace: AnyTransition(.blurReplace)
        case .combined: .scale.combined(with: .opacity)
        case .asymmetric: .asymmetric(insertion: .move(edge: .bottom), removal: .opacity)
        }
    }

    func code(edge: EdgeOption) -> String {
        switch self {
        case .move: ".move(edge: \(edge.label))"
        case .push: ".push(from: \(edge.label))"
        case .combined: ".scale.combined(with: .opacity)"
        case .asymmetric: ".asymmetric(insertion: .move(edge: .bottom), removal: .opacity)"
        default: label
        }
    }
}

private enum EdgeOption: DemoOption {
    case leading, trailing, top, bottom

    var label: String {
        switch self {
        case .leading: ".leading"
        case .trailing: ".trailing"
        case .top: ".top"
        case .bottom: ".bottom"
        }
    }

    var edge: Edge {
        switch self {
        case .leading: .leading
        case .trailing: .trailing
        case .top: .top
        case .bottom: .bottom
        }
    }
}

private enum TransitionAnimation: DemoOption {
    case smooth, bouncy, easeInOut, slow

    var label: String {
        switch self {
        case .smooth: ".smooth"
        case .bouncy: ".bouncy"
        case .easeInOut: ".easeInOut"
        case .slow: ".easeInOut(duration: 1.2)"
        }
    }

    var animation: Animation {
        switch self {
        case .smooth: .smooth
        case .bouncy: .bouncy
        case .easeInOut: .easeInOut
        case .slow: .easeInOut(duration: 1.2)
        }
    }
}

private struct TransitionsConfig {
    var kind: TransitionOption = .move
    var edge: EdgeOption = .leading
    var timing: TransitionAnimation = .smooth
    var clips = true
    var isShown = true
}

// MARK: - Demo

private struct TransitionsDemo: View {
    let page: ComponentPage

    var body: some View {
        DemoPage(
            page: page,
            initial: TransitionsConfig(),
            previewHeight: 280,
            usage: """
            @State private var isShown = false

            VStack {
                Button("Show Details") {
                    withAnimation { isShown.toggle() }
                }
                if isShown {
                    Text("Arrives Thursday")
                        .transition(.scale.combined(with: .opacity))
                }
            }
            """,
            usageNote: Aside(.important, "A transition runs only when a view is added or removed, as in `if isShown { }`, and only when that change is animated. Changing a view's properties is a normal animation.")
        ) { $config in
            VStack(spacing: 20) {
                ZStack {
                    if config.isShown {
                        Label("New message", systemImage: "message.fill")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .padding()
                            .background(.green.gradient, in: .rect(cornerRadius: 16))
                            .transition(config.kind.transition(edge: config.edge.edge))
                            // A view keeps the transition it was inserted with,
                            // so recreate it when the setup changes.
                            .id("\(config.kind)-\(config.edge)")
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 130)
                .modifier(ClipsIf(isOn: config.clips))
                .overlay {
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(.separator, style: StrokeStyle(lineWidth: 1, dash: [5, 5]))
                }

                Button(config.isShown ? "Hide" : "Show", systemImage: config.isShown ? "eye.slash" : "eye") {
                    withAnimation(config.timing.animation) {
                        config.isShown.toggle()
                    }
                }
                .buttonStyle(.borderedProminent)
                .contentTransition(.identity)
            }
            .frame(maxWidth: 420)
        } controls: { $config in
            Section("Transition") {
                OptionPicker("Transition", selection: $config.kind)
                if config.kind.usesEdge {
                    OptionPicker("Edge", selection: $config.edge)
                }
                OptionPicker("Animation", selection: $config.timing)
            }
            Section {
                Toggle("Clip to container", isOn: $config.clips)
            } footer: {
                Text("Turn this off to see sliding views draw outside their box.")
            }
        } code: { config in
            var lines = [
                "@State private var isShown = true",
                "",
                "VStack(spacing: 20) {",
                "    ZStack {",
                "        if isShown {",
                "            Label(\"New message\", systemImage: \"message.fill\")",
                "                .font(.headline)",
                "                .foregroundStyle(.white)",
                "                .padding()",
                "                .background(.green.gradient, in: .rect(cornerRadius: 16))",
                "                .transition(\(config.kind.code(edge: config.edge)))",
                "        }",
                "    }",
                "    .frame(maxWidth: .infinity)",
                "    .frame(height: 130)",
            ]
            if config.clips {
                lines.append("    .clipped()")
            }
            lines += [
                "",
                "    Button(isShown ? \"Hide\" : \"Show\") {",
                "        withAnimation(\(config.timing.label)) {",
                "            isShown.toggle()",
                "        }",
                "    }",
                "}",
            ]
            return lines.joined(separator: "\n")
        } examples: {
            ExampleCard(
                title: "Expandable details",
                caption: "Combine `.move(edge: .top)` with `.opacity` so extra details unfold beneath a row.",
                code: """
                @State private var isExpanded = false

                VStack(alignment: .leading, spacing: 12) {
                    Button {
                        withAnimation(.snappy) { isExpanded.toggle() }
                    } label: {
                        HStack {
                            Text("Shipping details").font(.headline)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .rotationEffect(.degrees(isExpanded ? 180 : 0))
                        }
                    }
                    .buttonStyle(.plain)

                    if isExpanded {
                        Text("Arrives Thursday. Free returns within 30 days.")
                            .foregroundStyle(.secondary)
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }
                }
                .padding()
                .background(.fill.tertiary, in: .rect(cornerRadius: 16))
                .clipped()
                """,
                aside: Aside(.note, "Moving views can draw outside their container. `.clipped()` on the container hides them until they're inside it.")
            ) {
                DisclosureExample()
            }

            ExampleCard(
                title: "Toast from the top",
                caption: "Use `.asymmetric(insertion:removal:)` so the toast drops in from the top and shrinks away when it leaves.",
                code: """
                @State private var showsToast = false

                VStack {
                    if showsToast {
                        Label("Saved to Photos", systemImage: "checkmark.circle.fill")
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(.regularMaterial, in: .capsule)
                            .transition(.asymmetric(
                                insertion: .move(edge: .top).combined(with: .opacity),
                                removal: .scale(scale: 0.8).combined(with: .opacity)
                            ))
                    }
                    Spacer()
                    Button("Save") {
                        withAnimation(.bouncy) { showsToast = true }
                        Task {
                            try? await Task.sleep(for: .seconds(1.5))
                            withAnimation(.smooth) { showsToast = false }
                        }
                    }
                }
                .frame(height: 150)
                """,
                minHeight: 200
            ) {
                ToastExample()
            }

            ExampleCard(
                title: "Swap content with .push",
                caption: "Use `.push(from:)` with a new `.id` per step, so the old step leaves as the next pushes in.",
                code: """
                @State private var step = 1

                VStack(spacing: 16) {
                    Text("Step \\(step)")
                        .font(.largeTitle.bold())
                        .id(step)
                        .transition(.push(from: .trailing))
                    Button("Next") {
                        withAnimation(.smooth) { step = step % 3 + 1 }
                    }
                }
                .clipped()
                """,
                aside: Aside(.important, "Without `.id(step)`, SwiftUI keeps the same `Text` and only changes its string, so no transition runs.")
            ) {
                PushExample()
            }
        }
    }
}

// MARK: - Pieces

private struct ClipsIf: ViewModifier {
    let isOn: Bool

    func body(content: Content) -> some View {
        if isOn {
            content.clipped()
        } else {
            content
        }
    }
}

private struct ToastExample: View {
    @State private var showsToast = false

    var body: some View {
        VStack {
            if showsToast {
                Label("Saved to Photos", systemImage: "checkmark.circle.fill")
                    .font(.subheadline.weight(.medium))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(.regularMaterial, in: .capsule)
                    .overlay { Capsule().strokeBorder(.separator) }
                    .transition(.asymmetric(
                        insertion: .move(edge: .top).combined(with: .opacity),
                        removal: .scale(scale: 0.8).combined(with: .opacity)
                    ))
            }
            Spacer()
            Button("Save", systemImage: "square.and.arrow.down") {
                withAnimation(.bouncy) { showsToast = true }
                Task {
                    try? await Task.sleep(for: .seconds(1.5))
                    withAnimation(.smooth) { showsToast = false }
                }
            }
            .buttonStyle(.bordered)
        }
        .frame(height: 150)
    }
}

private struct DisclosureExample: View {
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button {
                withAnimation(.snappy) { isExpanded.toggle() }
            } label: {
                HStack {
                    Text("Shipping details").font(.headline)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                }
                .contentShape(.rect)
            }
            .buttonStyle(.plain)

            if isExpanded {
                Text("Arrives Thursday. Free returns within 30 days.")
                    .foregroundStyle(.secondary)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .padding()
        .background(.fill.tertiary, in: .rect(cornerRadius: 16))
        .clipped()
        .frame(maxWidth: 360)
    }
}

private struct PushExample: View {
    @State private var step = 1

    var body: some View {
        VStack(spacing: 16) {
            Text("Step \(step)")
                .font(.largeTitle.bold())
                .id(step)
                .transition(.push(from: .trailing))
            Button("Next", systemImage: "arrow.right") {
                withAnimation(.smooth) { step = step % 3 + 1 }
            }
            .buttonStyle(.bordered)
        }
        .frame(maxWidth: .infinity)
        .clipped()
    }
}

/// A banner that drops in from the top and leaves with `removal`.
private struct ExitSample: View {
    let removal: AnyTransition
    @State private var isShown = true

    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                if isShown {
                    Label("Saved", systemImage: "checkmark.circle.fill")
                        .font(.subheadline.weight(.medium))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(.regularMaterial, in: .capsule)
                        .overlay { Capsule().strokeBorder(.separator) }
                        .transition(.asymmetric(
                            insertion: .move(edge: .top).combined(with: .opacity),
                            removal: removal
                        ))
                }
            }
            .frame(width: 220, height: 56, alignment: .top)
            .clipped()
            Button(isShown ? "Hide" : "Show") {
                withAnimation(.smooth) { isShown.toggle() }
            }
            .buttonStyle(.bordered)
        }
    }
}

private struct TransitionsThumbnail: View {
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<3) { i in
                RoundedRectangle(cornerRadius: 12)
                    .fill(.blue.gradient)
                    .frame(width: 44, height: 64)
                    .opacity([0.25, 0.6, 1][i])
                    .scaleEffect([0.7, 0.85, 1][i])
            }
            Image(systemName: "arrow.right")
                .font(.title3.weight(.semibold))
                .foregroundStyle(.secondary)
        }
    }
}
