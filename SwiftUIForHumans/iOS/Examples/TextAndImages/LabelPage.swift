import SwiftUI

extension ComponentPage {
    static let label = ComponentPage(
        id: "label",
        title: "Label",
        summary: "An icon and a title together, which adapts its look to where it's used.",
        category: .textAndImages,
        symbol: "tag",
        availability: ["iOS 14.0+", "macOS 11.0+", "visionOS 1.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/label",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/labels",
        aliases: ["icon with text", "icon text", "list item", "menu item", "badge", "chip", "tag", "labelStyle"],
        related: ["text", "sf-symbols", "image", "list"],
        notes: [
            "**Prefer `Label` over an `HStack` of `Image` and `Text`.** Lists, menus, toolbars, and tab bars know how to lay it out, and VoiceOver reads the title.",
            "**Controls build labels for you.** `Button(\"Delete\", systemImage: \"trash\")`, `Toggle`, and `Menu` take a title and a `systemImage:` directly.",
        ],
        api: [
            APIItem("`Label(_:systemImage:)`", "A title with an SF Symbol."),
            APIItem("`Label(_:image:)`", "A title with an image from your asset catalog."),
            APIItem("`Label { } icon: { }`", "Any views as the title and icon."),
            APIItem("`.labelStyle(_:)`", "`.titleAndIcon`, `.titleOnly`, or `.iconOnly`."),
            APIItem("`LabelStyle`", "A protocol for your own reusable label layout."),
            APIItem("`.symbolRenderingMode(_:)`", "Colors the symbol: `.hierarchical`, `.multicolor`, and more."),
        ],
        guidelines: [
            Guideline(
                "Pick a symbol that means the same as the title.",
                "People recognize the standard symbols, like `square.and.arrow.up` for Share. A loose match makes them read twice.",
                good: "The familiar Share symbol.",
                bad: "An arrow that could mean anything."
            ) {
                Label("Share", systemImage: "square.and.arrow.up")
                    .font(.title3)
            } bad: {
                Label("Share", systemImage: "arrow.right.circle")
                    .font(.title3)
            },
            Guideline(
                "Keep a title even when you show only the icon.",
                "Use `.labelStyle(.iconOnly)` instead of a bare `Image`. VoiceOver reads the title, and toolbars can show it when there's room."
            ),
            Guideline(
                "Use the system colors to rank importance.",
                "Primary for the title, secondary for details. The colors adapt to Dark Mode and higher-contrast settings for you."
            ),
        ]
    ) {
        VStack(alignment: .leading, spacing: 12) {
            Label("Favorites", systemImage: "star.fill")
            Label("Downloads", systemImage: "arrow.down.circle")
            Label("Shared", systemImage: "person.2")
        }
        .font(.headline)
        .frame(width: 180, alignment: .leading)
    } content: { page in
        LabelDemo(page: page)
    }
}

private struct LabelConfig {
    var title = "Favorites"
    var symbol: LabelSymbolOption = .star
    var style: LabelStyleOption = .automatic
    var font: LabelFontOption = .title3
    var rendering: LabelRenderingOption = .monochrome
    var tinted = true
}

private struct LabelDemo: View {
    let page: ComponentPage

    var body: some View {
        DemoPage(
            page: page,
            initial: LabelConfig(),
            previewHeight: 180,
            usage: """
            Label("Favorites", systemImage: "star.fill")

            // Icon only, but VoiceOver still reads "Favorites"
            Label("Favorites", systemImage: "star.fill")
                .labelStyle(.iconOnly)
            """
        ) { $config in
            Label(config.title, systemImage: config.symbol.name)
                .lbStyled(config.style)
                .font(config.font.font)
                .symbolRenderingMode(config.rendering.mode)
                .foregroundStyle(config.tinted ? AnyShapeStyle(.tint) : AnyShapeStyle(.primary))
        } controls: { $config in
            Section("Content") {
                TextField("Title", text: $config.title)
                OptionPicker("Symbol", selection: $config.symbol)
            }
            Section("Appearance") {
                OptionPicker("Style", selection: $config.style)
                OptionPicker("Font", selection: $config.font)
                OptionPicker("Rendering", selection: $config.rendering)
                Toggle("Tint color", isOn: $config.tinted)
            }
        } code: { config in
            var lines = ["Label(\(swiftString(config.title)), systemImage: \"\(config.symbol.name)\")"]
            if config.style != .automatic {
                lines.append("    .labelStyle(\(config.style.label))")
            }
            if config.font != .body {
                lines.append("    .font(\(config.font.label))")
            }
            if config.rendering != .monochrome {
                lines.append("    .symbolRenderingMode(\(config.rendering.label))")
            }
            if config.tinted {
                lines.append("    .foregroundStyle(.tint)")
            }
            return lines.joined(separator: "\n")
        } examples: {
            ExampleCard(
                title: "In a List",
                caption: "Put `Label`s in a `List` and the icons line up in one column, even at different widths.",
                code: """
                List {
                    Label("Wi-Fi", systemImage: "wifi")
                    Label("Bluetooth", systemImage: "point.3.connected.trianglepath.dotted")
                    Label("Battery", systemImage: "battery.100")
                }
                """
            ) {
                List {
                    Label("Wi-Fi", systemImage: "wifi")
                    Label("Bluetooth", systemImage: "point.3.connected.trianglepath.dotted")
                    Label("Battery", systemImage: "battery.100")
                }
                .scrollDisabled(true)
                .contentMargins(.vertical, 8, for: .scrollContent)
                .frame(height: 190)
                .clipShape(.rect(cornerRadius: 12))
            }
            ExampleCard(
                title: "In buttons and menus",
                caption: "`Button` and `Menu` take a title and `systemImage:` and build the `Label` for you.",
                code: """
                Menu("Options", systemImage: "ellipsis.circle") {
                    Button("Duplicate", systemImage: "plus.square.on.square") {}
                    Button("Rename", systemImage: "pencil") {}
                    Button("Delete", systemImage: "trash", role: .destructive) {}
                }

                Button("Share", systemImage: "square.and.arrow.up") {}
                    .buttonStyle(.bordered)
                """,
                minHeight: 140,
                aside: Aside(.note, "Menus show the icon after the title, and toolbars show only the icon. The same `Label` adapts to each place.")
            ) {
                HStack(spacing: 20) {
                    Menu("Options", systemImage: "ellipsis.circle") {
                        Button("Duplicate", systemImage: "plus.square.on.square") {}
                        Button("Rename", systemImage: "pencil") {}
                        Button("Delete", systemImage: "trash", role: .destructive) {}
                    }
                    Button("Share", systemImage: "square.and.arrow.up") {}
                        .buttonStyle(.bordered)
                }
            }
            ExampleCard(
                title: "Settings-style icon",
                caption: "Use `Label { } icon: { }` to build any icon, such as a white symbol on a colored square.",
                code: """
                Label {
                    Text("Notifications")
                } icon: {
                    Image(systemName: "bell.badge.fill")
                        .font(.footnote)
                        .foregroundStyle(.white)
                        .frame(width: 28, height: 28)
                        .background(.red, in: .rect(cornerRadius: 7))
                }
                """,
                minHeight: 120
            ) {
                VStack(alignment: .leading, spacing: 14) {
                    SettingsIconLabel(title: "Notifications", symbol: "bell.badge.fill", color: .red)
                    SettingsIconLabel(title: "Focus", symbol: "moon.fill", color: .indigo)
                    SettingsIconLabel(title: "Screen Time", symbol: "hourglass", color: .purple)
                }
            }
            ExampleCard(
                title: "Custom label style",
                caption: "Conform to `LabelStyle` to define a layout once and reuse it, here an icon over its title.",
                code: """
                struct VerticalLabelStyle: LabelStyle {
                    func makeBody(configuration: Configuration) -> some View {
                        VStack(spacing: 6) {
                            configuration.icon
                                .font(.title2)
                            configuration.title
                                .font(.caption)
                        }
                    }
                }

                HStack(spacing: 28) {
                    Label("Camera", systemImage: "camera")
                    Label("Photos", systemImage: "photo")
                    Label("Files", systemImage: "folder")
                }
                .labelStyle(VerticalLabelStyle())
                """,
                minHeight: 120
            ) {
                HStack(spacing: 28) {
                    Label("Camera", systemImage: "camera")
                    Label("Photos", systemImage: "photo")
                    Label("Files", systemImage: "folder")
                }
                .labelStyle(VerticalLabelStyle())
                .foregroundStyle(.tint)
            }
        }
    }
}

private struct SettingsIconLabel: View {
    let title: String
    let symbol: String
    let color: Color

    var body: some View {
        Label {
            Text(title)
        } icon: {
            Image(systemName: symbol)
                .font(.footnote)
                .foregroundStyle(.white)
                .frame(width: 28, height: 28)
                .background(color, in: .rect(cornerRadius: 7))
        }
    }
}

private struct VerticalLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack(spacing: 6) {
            configuration.icon
                .font(.title2)
            configuration.title
                .font(.caption)
        }
    }
}

// MARK: - Options

private enum LabelSymbolOption: DemoOption {
    case star, heart, folder, bell, cloud, person

    var name: String {
        switch self {
        case .star: "star.fill"
        case .heart: "heart.fill"
        case .folder: "folder.badge.plus"
        case .bell: "bell.badge"
        case .cloud: "cloud.sun.rain.fill"
        case .person: "person.crop.circle.badge.checkmark"
        }
    }

    var label: String { name }
}

private enum LabelStyleOption: DemoOption {
    case automatic, titleAndIcon, titleOnly, iconOnly

    var label: String { ".\(String(describing: self))" }
}

private enum LabelFontOption: DemoOption {
    case body, headline, title3, title, largeTitle

    var label: String { ".\(String(describing: self))" }

    var font: Font {
        switch self {
        case .body: .body
        case .headline: .headline
        case .title3: .title3
        case .title: .title
        case .largeTitle: .largeTitle
        }
    }
}

private enum LabelRenderingOption: DemoOption {
    case monochrome, hierarchical, multicolor

    var label: String { ".\(String(describing: self))" }

    var mode: SymbolRenderingMode {
        switch self {
        case .monochrome: .monochrome
        case .hierarchical: .hierarchical
        case .multicolor: .multicolor
        }
    }
}

private extension View {
    @ViewBuilder
    func lbStyled(_ style: LabelStyleOption) -> some View {
        switch style {
        case .automatic: labelStyle(.automatic)
        case .titleAndIcon: labelStyle(.titleAndIcon)
        case .titleOnly: labelStyle(.titleOnly)
        case .iconOnly: labelStyle(.iconOnly)
        }
    }
}
