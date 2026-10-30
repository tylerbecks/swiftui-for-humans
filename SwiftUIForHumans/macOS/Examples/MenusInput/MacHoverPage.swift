import SwiftUI

extension ComponentPage {
    static let hover = ComponentPage(
        id: "hover",
        title: "Hover & pointer",
        summary: "React when the pointer moves over a view, and show the right pointer.",
        category: .input,
        kind: .modifier,
        symbol: "cursorarrow.motionlines",
        availability: ["macOS 10.15+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/view/onhover(perform:)",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/pointing-devices",
        aliases: [":hover", "mouseenter", "mouseleave", "mousemove", "cursor", "NSCursor", "NSTrackingArea", "onHover", "onContinuousHover", "pointerStyle", "pointing hand", "resize cursor", "mouseover"],
        related: ["tooltips", "trackpad-gestures", "drag-drop", "button"],
        notes: [
            "**The hover area is the view's frame.** Add padding before `.onHover` to make the area bigger.",
            "**`.pointerStyle` needs macOS 15.** `.onContinuousHover` needs macOS 14, and `.onHover` dates back to macOS 10.15.",
        ],
        api: [
            APIItem("`.onHover { isHovering in }`", "Runs when the pointer enters or leaves."),
            APIItem("`.onContinuousHover { phase in }`", "Reports the pointer's location as it moves."),
            APIItem("`.pointerStyle(_:)`", "The pointer to show over a view."),
            APIItem("`.link`, `.grabIdle`, `.columnResize`", "A few of the built-in pointer styles."),
            APIItem("`.pointerVisibility(.hidden)`", "Hides the pointer over a view."),
        ],
        guidelines: [
            Guideline(
                "Show the pointer that matches what happens.",
                "Each pointer has a meaning people know: a pointing hand for a link, an open hand for content they can pan, like a map, and a crosshair for precise selection. Don't use one for anything else."
            ),
            Guideline(
                "Let the pointer bring back controls that fade away.",
                "Controls that hide to keep the view calm, like playback controls over a video, should reappear when the pointer moves over them."
            ),
            Guideline(
                "Give hover-only controls a way in with touch.",
                "On a Mac with a touch display there's no pointer to hover. Show an essential hidden control when someone taps where it lives, and put it in a context menu too."
            ),
            Guideline(
                "Keep every way of working consistent.",
                "People switch between the pointer, the keyboard, and gestures without thinking. An action shouldn't work differently, or only work, with one of them."
            ),
        ]
    ) {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: "folder.fill")
                    .foregroundStyle(.tint)
                Text("Garden Plan")
                Spacer()
                Image(systemName: "ellipsis.circle")
                    .foregroundStyle(.secondary)
            }
            .font(.callout)
            .padding(8)
            .background(.fill.tertiary, in: .rect(cornerRadius: 7))
            Image(systemName: "cursorarrow")
                .font(.title2)
                .offset(x: 110, y: -14)
        }
        .frame(width: 180)
    } content: { page in
        MacHoverDemo(page: page)
    }
}

private struct MacHoverConfig {
    var effect: HoverEffectOption = .highlight
    var pointer: PointerOption = .automatic
    var isHovering = false
}

private struct MacHoverDemo: View {
    let page: ComponentPage

    var body: some View {
        DemoPage(
            page: page,
            initial: MacHoverConfig(),
            previewHeight: 200,
            usage: """
            @State private var isHovering = false

            ProjectRow(project)
                .padding(8)
                .background(isHovering ? Color.secondary.opacity(0.15) : .clear,
                            in: .rect(cornerRadius: 8))
                .onHover { isHovering = $0 }
            """,
            usageNote: Aside(.note, "`.onHover` is like CSS `:hover`, except you store the state yourself and style the view from it.")
        ) { $config in
            VStack(spacing: 14) {
                HoverRow(config: config)
                    .onHover { config.isHovering = $0 }
                Text("isHovering = \(config.isHovering ? "true" : "false")")
                    .font(.footnote.monospaced())
                    .foregroundStyle(.secondary)
            }
        } controls: { $config in
            Section("Hover") {
                OptionPicker("Effect", selection: $config.effect)
                OptionPicker("Pointer", selection: $config.pointer)
            }
        } code: { config in
            var lines = ["@State private var isHovering = false", ""]
            lines.append("ProjectRow(project)")
            switch config.effect {
            case .highlight:
                lines.append("    .padding(8)")
                lines.append("    .background(isHovering ? Color.secondary.opacity(0.15) : .clear,")
                lines.append("                in: .rect(cornerRadius: 8))")
            case .lift:
                lines.append("    .scaleEffect(isHovering ? 1.03 : 1)")
                lines.append("    .shadow(radius: isHovering ? 6 : 0)")
                lines.append("    .animation(.snappy, value: isHovering)")
            case .actions:
                lines.append("    .overlay(alignment: .trailing) {")
                lines.append("        if isHovering {")
                lines.append("            Button(\"More\", systemImage: \"ellipsis.circle\") { }")
                lines.append("                .labelStyle(.iconOnly)")
                lines.append("        }")
                lines.append("    }")
            }
            lines.append("    .onHover { isHovering = $0 }")
            if let code = config.pointer.code {
                lines.append("    .pointerStyle(\(code))")
            }
            return lines.joined(separator: "\n")
        } examples: {
            MacHoverExamples()
        }
    }
}

private struct HoverRow: View {
    let config: MacHoverConfig

    var body: some View {
        let isHovering = config.isHovering
        HStack {
            Image(systemName: "folder.fill")
                .foregroundStyle(.tint)
            VStack(alignment: .leading) {
                Text("Garden Plan")
                Text("Edited today")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            if config.effect == .actions && isHovering {
                Button("More", systemImage: "ellipsis.circle") {}
                    .labelStyle(.iconOnly)
                    .buttonStyle(.borderless)
            }
        }
        .padding(8)
        .frame(width: 260, height: 52)
        .background(config.effect == .highlight && isHovering ? Color.secondary.opacity(0.15) : .clear, in: .rect(cornerRadius: 8))
        .background(config.effect == .lift ? AnyShapeStyle(.background) : AnyShapeStyle(.clear), in: .rect(cornerRadius: 8))
        .scaleEffect(config.effect == .lift && isHovering ? 1.03 : 1)
        .shadow(color: .black.opacity(config.effect == .lift && isHovering ? 0.2 : 0), radius: 6, y: 2)
        .animation(.snappy, value: isHovering)
        .contentShape(.rect)
        .pointerStyle(config.pointer.style)
    }
}

// MARK: - Examples

private struct MacHoverExamples: View {
    @State private var hoveredRow: String?
    @State private var spot: CGPoint?
    @State private var sidebarWidth = 140.0

    var body: some View {
        ExampleCard(
            title: "Show actions on the row under the pointer",
            caption: "Use `.onHover` to track the row under the pointer and show its buttons only there, so the list stays calm.",
            code: """
            @State private var hoveredRow: Project.ID?

            ForEach(projects) { project in
                HStack {
                    Text(project.name)
                    Spacer()
                    if hoveredRow == project.id {
                        Button("Share", systemImage: "square.and.arrow.up") { share(project) }
                        Button("Delete", systemImage: "trash") { delete(project) }
                    }
                }
                .labelStyle(.iconOnly)
                .buttonStyle(.borderless)
                .contentShape(.rect)
                .onHover { isHovering in
                    hoveredRow = isHovering ? project.id : nil
                }
            }
            """,
            minHeight: 170,
            aside: Aside(.important, "Hover-only buttons are invisible to the keyboard and to VoiceOver until the pointer arrives. Put the same commands in a context menu or the menu bar.")
        ) {
            VStack(spacing: 2) {
                ForEach(["Garden Plan", "Trip Notes", "Recipes"], id: \.self) { name in
                    HStack {
                        Text(name)
                        Spacer()
                        if hoveredRow == name {
                            Button("Share", systemImage: "square.and.arrow.up") {}
                                .help("Share \(name)")
                            Button("Delete", systemImage: "trash") {}
                                .help("Delete \(name)")
                        }
                    }
                    .labelStyle(.iconOnly)
                    .buttonStyle(.borderless)
                    .padding(.horizontal, 10)
                    .frame(height: 30)
                    .background(hoveredRow == name ? Color.secondary.opacity(0.12) : .clear, in: .rect(cornerRadius: 6))
                    .contentShape(.rect)
                    .onHover { isHovering in
                        if isHovering {
                            hoveredRow = name
                        } else if hoveredRow == name {
                            hoveredRow = nil
                        }
                    }
                }
            }
            .frame(width: 300)
        }

        ExampleCard(
            title: "Follow the pointer",
            caption: "`.onContinuousHover` reports the pointer's location while it moves over a view, and `.ended` when it leaves.",
            code: """
            @State private var spot: CGPoint?

            SceneryView(.lake)
                .overlay {
                    if let spot {
                        Circle()
                            .fill(.white.opacity(0.35))
                            .frame(width: 60, height: 60)
                            .position(spot)
                    }
                }
                .onContinuousHover { phase in
                    switch phase {
                    case .active(let location): spot = location
                    case .ended: spot = nil
                    }
                }
            """,
            minHeight: 230
        ) {
            VStack(spacing: 8) {
                SceneryView(.lake)
                    .frame(width: 300, height: 200)
                    .overlay {
                        if let spot {
                            Circle()
                                .fill(.white.opacity(0.35))
                                .frame(width: 60, height: 60)
                                .position(spot)
                        }
                    }
                    .clipShape(.rect(cornerRadius: 10))
                    .onContinuousHover { phase in
                        switch phase {
                        case .active(let location): spot = location
                        case .ended: spot = nil
                        }
                    }
                Text(spot.map { "x: \(Int($0.x)), y: \(Int($0.y))" } ?? "Move the pointer over the photo.")
                    .font(.footnote.monospaced())
                    .foregroundStyle(.secondary)
            }
        }

        ExampleCard(
            title: "A resize pointer on a divider",
            caption: "`.pointerStyle(.columnResize)` shows the left-right resize pointer, so people know they can drag the divider.",
            code: """
            @State private var sidebarWidth = 140.0

            HStack(spacing: 0) {
                Sidebar()
                    .frame(width: sidebarWidth)
                Rectangle()
                    .fill(.separator)
                    .frame(width: 1)
                    .padding(.horizontal, 3)
                    .contentShape(.rect)
                    .pointerStyle(.columnResize)
                    .gesture(DragGesture(coordinateSpace: .named("split")).onChanged { drag in
                        sidebarWidth = min(max(drag.location.x, 100), 220)
                    })
                Detail()
            }
            .coordinateSpace(.named("split"))
            """,
            minHeight: 190,
            aside: Aside(.note, "For a real sidebar, `NavigationSplitView` gives you the divider and the pointer for free.")
        ) {
            HStack(spacing: 0) {
                Text("Sidebar")
                    .foregroundStyle(.secondary)
                    .frame(width: sidebarWidth)
                    .frame(maxHeight: .infinity)
                    .background(.fill.quaternary)
                Rectangle()
                    .fill(.separator)
                    .frame(width: 1)
                    .padding(.horizontal, 3)
                    .contentShape(.rect)
                    .pointerStyle(.columnResize)
                    .gesture(DragGesture(coordinateSpace: .named("split")).onChanged { drag in
                        sidebarWidth = min(max(drag.location.x, 100), 220)
                    })
                Text("Drag the divider")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .coordinateSpace(.named("split"))
            .frame(width: 380, height: 150)
            .clipShape(.rect(cornerRadius: 10))
            .overlay {
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(.separator)
            }
        }

        VStack(alignment: .leading, spacing: 14) {
            Text("Which pointer when")
                .font(.title3.bold())
                .outlineEntry("Which pointer when", level: 2)
            RichText("The Human Interface Guidelines give each standard pointer a meaning. These are the `PointerStyle` values for the common ones:")
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            ConnectFacts(rows: [
                (".link", "Pointing hand: the content is a link to a webpage, document, or other item."),
                (".grabIdle, .grabActive", "Open and closed hand: people can drag to move content around in a view, like a map."),
                (".rectSelection", "Crosshair: people can make a precise rectangular selection."),
                (".horizontalText", "I-beam: people can select or insert text."),
                (".columnResize, .rowResize", "Resize: people can drag to resize something left and right, or up and down."),
            ])
        }
    }
}

// MARK: - Options

private enum HoverEffectOption: DemoOption {
    case highlight, lift, actions

    var label: String {
        switch self {
        case .highlight: "Highlight"
        case .lift: "Lift"
        case .actions: "Show button"
        }
    }
}

private enum PointerOption: DemoOption {
    case automatic, link, grabIdle, zoomIn, rectSelection

    var label: String {
        switch self {
        case .automatic: "Default"
        case .link: ".link"
        case .grabIdle: ".grabIdle"
        case .zoomIn: ".zoomIn"
        case .rectSelection: ".rectSelection"
        }
    }

    var code: String? {
        self == .automatic ? nil : label
    }

    var style: PointerStyle? {
        switch self {
        case .automatic: nil
        case .link: .link
        case .grabIdle: .grabIdle
        case .zoomIn: .zoomIn
        case .rectSelection: .rectSelection
        }
    }
}
