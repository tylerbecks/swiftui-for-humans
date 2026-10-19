import SwiftUI

extension ComponentPage {
    static let controlGroup = ComponentPage(
        id: "control-group",
        title: "ControlGroup",
        summary: "Related buttons joined into one control, in a toolbar or in content.",
        category: .controls,
        symbol: "rectangle.split.3x1",
        availability: ["macOS 12.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/controlgroup",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/toolbars",
        aliases: ["button group", "segmented buttons", "NSSegmentedControl momentary", "back forward", "zoom in out", "toolbar group", "btn-group", "controlGroupStyle"],
        related: ["button", "picker", "menu", "toolbar", "toolbars-pattern"],
        notes: [
            "**The label matters in a toolbar.** When a toolbar runs out of room, the group moves into the overflow menu under its label, so give it one.",
            "**Each button keeps its own title.** Use `Button(_:systemImage:action:)` with `.labelStyle(.iconOnly)`, and VoiceOver still reads each title.",
        ],
        api: [
            APIItem("`ControlGroup { … }`", "Groups the buttons inside it."),
            APIItem("`ControlGroup(_:systemImage:content:)`", "With a label for menus and overflow."),
            APIItem("`.controlGroupStyle(.navigation)`", "For back and forward buttons."),
            APIItem("`.controlGroupStyle(.menu)`", "Shows the buttons as a menu."),
            APIItem("`.controlGroupStyle(.palette)`", "Shows the content as a palette."),
            APIItem("`.labelStyle(.iconOnly)`", "Symbols only, titles kept for VoiceOver."),
        ],
        guidelines: [
            Guideline(
                "Group toolbar items by what they do.",
                "Put commands that work together side by side, like zooming out and in. Navigation and critical actions such as Done get their own familiar spots."
            ),
            Guideline(
                "Keep the number of groups small.",
                "Too many groups make a toolbar look cluttered and hard to scan. Aim for three at most.",
                good: "Two groups: navigation and zoom.",
                bad: "Every button split into its own group."
            ) {
                MacGroupedToolbar(isSplit: false)
            } bad: {
                MacGroupedToolbar(isSplit: true)
            },
            Guideline(
                "Use a group for actions and a picker for a choice.",
                "Don't mix buttons that act with segments that stay selected. For one choice among several, use a segmented [Picker](catalog://picker)."
            ),
        ]
    ) {
        ControlGroup {
            Button("Zoom Out", systemImage: "minus.magnifyingglass") {}
            Button("Zoom In", systemImage: "plus.magnifyingglass") {}
        }
        .labelStyle(.iconOnly)
        .fixedSize()
    } content: { page in
        MacControlGroupDemo(page: page)
    }
}

extension Catalog {
    /// A real window with control groups in its toolbar.
    static let controlGroupDemoWindow = DemoWindow(id: "control-group-toolbar", title: "Photos", size: CGSize(width: 640, height: 360)) {
        MacControlGroupToolbarSample()
    }
}

private struct MacControlGroupConfig {
    var content: MacGroupContentOption = .zoom
    var style: MacControlGroupStyleOption = .automatic
    var iconsOnly = true
    var size: MacControlGroupSizeOption = .regular
    var isDisabled = false
}

private struct MacControlGroupDemo: View {
    let page: ComponentPage
    @State private var zoom = 100

    var body: some View {
        DemoPage(
            page: page,
            initial: MacControlGroupConfig(),
            usage: """
            ControlGroup("Zoom", systemImage: "magnifyingglass") {
                Button("Zoom Out", systemImage: "minus.magnifyingglass") {
                    zoomOut()
                }
                Button("Zoom In", systemImage: "plus.magnifyingglass") {
                    zoomIn()
                }
            }
            .labelStyle(.iconOnly)
            """,
            usageNote: Aside(.note, "Like a `.btn-group` of buttons on the web. Each button keeps its own action; the group only changes how they're drawn.")
        ) { $config in
            VStack(spacing: 16) {
                MacDemoControlGroup(config: config, zoom: $zoom)
                    .fixedSize()
                Text("zoom = \(zoom)%")
                    .font(.footnote.monospaced())
                    .foregroundStyle(.secondary)
            }
        } controls: { $config in
            Section("Content") {
                OptionPicker("Buttons", selection: $config.content)
                Toggle("Icons only", isOn: $config.iconsOnly)
            }
            Section("Appearance") {
                OptionPicker("Style", selection: $config.style)
                OptionPicker("Size", selection: $config.size)
                Toggle("Disabled", isOn: $config.isDisabled)
            }
        } code: { config in
            var lines = ["ControlGroup(\(swiftString(config.content.title)), systemImage: \"\(config.content.symbol)\") {"]
            for item in config.content.items {
                lines.append("    Button(\(swiftString(item.title)), systemImage: \"\(item.symbol)\") {")
                lines.append("        \(item.call)")
                lines.append("    }")
            }
            lines.append("}")
            if config.iconsOnly {
                lines.append(".labelStyle(.iconOnly)")
            }
            if config.style != .automatic {
                lines.append(".controlGroupStyle(\(config.style.label))")
            }
            if config.size != .regular {
                lines.append(".controlSize(\(config.size.label))")
            }
            if config.isDisabled {
                lines.append(".disabled(true)")
            }
            return lines.joined(separator: "\n")
        } examples: {
            MacControlGroupExamples()
        }
    }
}

/// The demo's control group, built from the current options.
private struct MacDemoControlGroup: View {
    let config: MacControlGroupConfig
    @Binding var zoom: Int

    var body: some View {
        ControlGroup(config.content.title, systemImage: config.content.symbol) {
            ForEach(config.content.items, id: \.title) { item in
                Button(item.title, systemImage: item.symbol) {
                    zoom = min(400, max(25, zoom + item.zoomChange))
                }
            }
        }
        .modifier(MacIconsOnly(isOn: config.iconsOnly))
        .styled(config.style)
        .controlSize(config.size.size)
        .disabled(config.isDisabled)
    }
}

// MARK: - Examples

private struct MacControlGroupExamples: View {
    @State private var page = 3
    @State private var zoom = 100

    var body: some View {
        ExampleCard(
            title: "Back and forward in a toolbar",
            caption: "Use `.controlGroupStyle(.navigation)` for back and forward, in the toolbar's `.navigation` placement.",
            code: """
            @State private var page = 3

            Text("Page \\(page)")
                .navigationTitle("Page \\(page) of 5")
                .toolbar {
                    ToolbarItem(placement: .navigation) {
                        ControlGroup("Navigation", systemImage: "arrow.left.arrow.right") {
                            Button("Back", systemImage: "chevron.left") { page -= 1 }
                                .disabled(page == 1)
                            Button("Forward", systemImage: "chevron.right") { page += 1 }
                                .disabled(page == 5)
                        }
                        .controlGroupStyle(.navigation)
                    }
                }
            """,
            minHeight: 190,
            aside: Aside(.note, "A real `.toolbar` here would land in this window's toolbar, so the preview draws one. Open the sample to see the real thing.")
        ) {
            VStack(spacing: 16) {
                MacWindowFrame(width: 380, height: 120) {
                    Text("Page \(page)")
                        .font(.title.weight(.semibold))
                        .foregroundStyle(.secondary)
                } toolbar: {
                    // The navigation placement sits at the leading edge,
                    // right after the window buttons.
                    HStack(spacing: 12) {
                        ControlGroup("Navigation", systemImage: "arrow.left.arrow.right") {
                            Button("Back", systemImage: "chevron.left") { page -= 1 }
                                .disabled(page == 1)
                            Button("Forward", systemImage: "chevron.right") { page += 1 }
                                .disabled(page == 5)
                        }
                        .controlGroupStyle(.navigation)
                        .labelStyle(.iconOnly)
                        .fixedSize()
                        Text("Page \(page) of 5")
                            .font(.headline)
                            .foregroundStyle(.primary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .layoutPriority(1)
                }
                OpenDemoWindowButton(id: "control-group-toolbar", label: "Open the Toolbar Sample")
            }
        }

        ExampleCard(
            title: "Zoom controls under a view",
            caption: "In content, a group keeps paired actions together, such as zooming out and in below an image.",
            code: """
            @State private var zoom = 100

            VStack {
                Image(systemName: "photo")
                    .font(.system(size: 48 * Double(zoom) / 100))
                ControlGroup {
                    Button("Zoom Out", systemImage: "minus") { zoom -= 25 }
                    Button("Actual Size") { zoom = 100 }
                    Button("Zoom In", systemImage: "plus") { zoom += 25 }
                }
                .fixedSize()
            }
            """,
            minHeight: 220
        ) {
            VStack(spacing: 16) {
                Image(systemName: "photo")
                    .font(.system(size: 48 * Double(zoom) / 100))
                    .foregroundStyle(.tint)
                    .frame(height: 110)
                ControlGroup {
                    Button("Zoom Out", systemImage: "minus") { zoom = max(25, zoom - 25) }
                    Button("Actual Size") { zoom = 100 }
                    Button("Zoom In", systemImage: "plus") { zoom = min(200, zoom + 25) }
                }
                .fixedSize()
            }
        }

        ExampleCard(
            title: "A group as a menu",
            caption: "`.controlGroupStyle(.menu)` folds the buttons into a menu under the group's label, for actions people need now and then.",
            code: """
            ControlGroup("Arrange", systemImage: "square.3.layers.3d") {
                Button("Bring to Front") { bringToFront() }
                Button("Send to Back") { sendToBack() }
            }
            .controlGroupStyle(.menu)
            """,
            minHeight: 120
        ) {
            ControlGroup("Arrange", systemImage: "square.3.layers.3d") {
                Button("Bring to Front") {}
                Button("Send to Back") {}
            }
            .controlGroupStyle(.menu)
            .fixedSize()
        }
    }
}

/// The demo window: control groups in a real toolbar.
private struct MacControlGroupToolbarSample: View {
    @State private var page = 1
    @State private var zoom = 100

    var body: some View {
        Image(systemName: "photo.on.rectangle")
            .font(.system(size: 64 * Double(zoom) / 100))
            .foregroundStyle(.tint)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationSubtitle("Photo \(page) of 5")
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    ControlGroup("Navigation", systemImage: "arrow.left.arrow.right") {
                        Button("Back", systemImage: "chevron.left") { page -= 1 }
                            .disabled(page == 1)
                        Button("Forward", systemImage: "chevron.right") { page += 1 }
                            .disabled(page == 5)
                    }
                    .controlGroupStyle(.navigation)
                }
                ToolbarItem {
                    ControlGroup("Zoom", systemImage: "magnifyingglass") {
                        Button("Zoom Out", systemImage: "minus.magnifyingglass") { zoom = max(25, zoom - 25) }
                        Button("Zoom In", systemImage: "plus.magnifyingglass") { zoom = min(200, zoom + 25) }
                    }
                }
            }
    }
}

/// A toolbar drawing for the grouping guideline.
private struct MacGroupedToolbar: View {
    let isSplit: Bool

    var body: some View {
        MacWindowFrame(width: 270, height: 90) {
            Color.clear
        } toolbar: {
            HStack(spacing: 10) {
                if isSplit {
                    ControlGroup { Button("Back", systemImage: "chevron.left") {} }
                    ControlGroup { Button("Forward", systemImage: "chevron.right") {} }
                    Spacer(minLength: 0)
                    ControlGroup { Button("Zoom Out", systemImage: "minus.magnifyingglass") {} }
                    ControlGroup { Button("Zoom In", systemImage: "plus.magnifyingglass") {} }
                } else {
                    ControlGroup {
                        Button("Back", systemImage: "chevron.left") {}
                        Button("Forward", systemImage: "chevron.right") {}
                    }
                    Spacer(minLength: 0)
                    ControlGroup {
                        Button("Zoom Out", systemImage: "minus.magnifyingglass") {}
                        Button("Zoom In", systemImage: "plus.magnifyingglass") {}
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .layoutPriority(1)
        }
        .labelStyle(.iconOnly)
    }
}

// MARK: - Options

private struct MacGroupItem {
    let title: String
    let symbol: String
    let call: String
    let zoomChange: Int
}

private enum MacGroupContentOption: DemoOption {
    case zoom, navigation, rotate

    var label: String {
        switch self {
        case .zoom: "Zoom"
        case .navigation: "Back / Forward"
        case .rotate: "Rotate"
        }
    }

    var title: String {
        switch self {
        case .zoom: "Zoom"
        case .navigation: "Navigation"
        case .rotate: "Rotate"
        }
    }

    var symbol: String {
        switch self {
        case .zoom: "magnifyingglass"
        case .navigation: "arrow.left.arrow.right"
        case .rotate: "rotate.right"
        }
    }

    var items: [MacGroupItem] {
        switch self {
        case .zoom:
            [MacGroupItem(title: "Zoom Out", symbol: "minus.magnifyingglass", call: "zoomOut()", zoomChange: -25),
             MacGroupItem(title: "Zoom In", symbol: "plus.magnifyingglass", call: "zoomIn()", zoomChange: 25)]
        case .navigation:
            [MacGroupItem(title: "Back", symbol: "chevron.left", call: "goBack()", zoomChange: 0),
             MacGroupItem(title: "Forward", symbol: "chevron.right", call: "goForward()", zoomChange: 0)]
        case .rotate:
            [MacGroupItem(title: "Rotate Left", symbol: "rotate.left", call: "rotateLeft()", zoomChange: 0),
             MacGroupItem(title: "Rotate Right", symbol: "rotate.right", call: "rotateRight()", zoomChange: 0)]
        }
    }
}

private enum MacControlGroupStyleOption: DemoOption {
    case automatic, navigation, palette, menu, compactMenu

    var label: String {
        switch self {
        case .automatic: ".automatic"
        case .navigation: ".navigation"
        case .palette: ".palette"
        case .menu: ".menu"
        case .compactMenu: ".compactMenu"
        }
    }
}

private enum MacControlGroupSizeOption: DemoOption {
    case mini, small, regular, large

    var label: String {
        switch self {
        case .mini: ".mini"
        case .small: ".small"
        case .regular: ".regular"
        case .large: ".large"
        }
    }

    var size: ControlSize {
        switch self {
        case .mini: .mini
        case .small: .small
        case .regular: .regular
        case .large: .large
        }
    }
}

private struct MacIconsOnly: ViewModifier {
    let isOn: Bool

    func body(content: Content) -> some View {
        if isOn {
            content.labelStyle(.iconOnly)
        } else {
            content
        }
    }
}

private extension View {
    @ViewBuilder
    func styled(_ style: MacControlGroupStyleOption) -> some View {
        switch style {
        case .automatic: controlGroupStyle(.automatic)
        case .navigation: controlGroupStyle(.navigation)
        case .palette: controlGroupStyle(.palette)
        case .menu: controlGroupStyle(.menu)
        case .compactMenu: controlGroupStyle(.compactMenu)
        }
    }
}
