import SwiftUI

extension ComponentPage {
    static let toggle = ComponentPage(
        id: "toggle",
        title: "Toggle",
        summary: "A checkbox, switch, or button that turns a setting on or off.",
        category: .controls,
        symbol: "checkmark.square",
        availability: ["macOS 10.15+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/toggle",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/toggles",
        aliases: ["checkbox", "switch", "on off", "boolean", "NSButton", "NSSwitch", "input type=checkbox", "mixed state", "select all", "toggle button"],
        related: [],
        notes: [
            "**The default style depends on where the toggle is.** It's a checkbox in most places, and a switch in a grouped `Form`. Set `.toggleStyle(_:)` when you need one or the other.",
            "**Clicking the label toggles it too.** The title is part of the checkbox, so people don't have to aim for the small box.",
        ],
        api: [
            APIItem("`Toggle(_:isOn:)`", "A labeled toggle bound to a `Bool`."),
            APIItem("`.toggleStyle(.checkbox)`", "The Mac default: a box with a checkmark."),
            APIItem("`.toggleStyle(.switch)`", "A switch, for settings worth emphasizing."),
            APIItem("`.toggleStyle(.button)`", "A button that stays highlighted while on."),
            APIItem("`Toggle(sources:isOn:)`", "One toggle for many; shows a dash when mixed."),
            APIItem("`.controlSize(_:)`", "`.mini` switches fit grouped form rows."),
        ],
        guidelines: [
            Guideline(
                "Keep checkboxes and switches in the window body.",
                "They belong next to the content they change, not in a toolbar. In a toolbar, use a button-style toggle instead.",
                good: "A button-style toggle in the toolbar.",
                bad: "A checkbox in the toolbar."
            ) {
                ToolbarSample {
                    Toggle("Show Hidden", systemImage: "eye", isOn: .constant(true))
                        .toggleStyle(.button)
                        .labelStyle(.iconOnly)
                }
            } bad: {
                ToolbarSample {
                    Toggle("Show Hidden", isOn: .constant(true))
                        .toggleStyle(.checkbox)
                }
            },
            Guideline(
                "Use checkboxes to show a hierarchy of settings.",
                "Checkboxes line up along their leading edge, so indenting the ones that depend on another shows how they're related.",
                good: "Indented checkboxes show what depends on what.",
                bad: "A column of switches hides the hierarchy."
            ) {
                VStack(alignment: .leading, spacing: 6) {
                    Toggle("Show warnings", isOn: .constant(true))
                    Toggle("Include minor issues", isOn: .constant(false))
                        .padding(.leading, 20)
                    Toggle("Play a sound", isOn: .constant(true))
                        .padding(.leading, 20)
                }
                .toggleStyle(.checkbox)
            } bad: {
                VStack(alignment: .trailing, spacing: 6) {
                    Toggle("Show warnings", isOn: .constant(true))
                    Toggle("Include minor issues", isOn: .constant(false))
                    Toggle("Play a sound", isOn: .constant(true))
                }
                .toggleStyle(.switch)
                .frame(width: 220)
            },
            Guideline(
                "Save switches for settings that carry weight.",
                "A switch looks heavier than a checkbox, so it suits a setting that turns on a whole feature or a group of other settings. Don't swap an existing checkbox for one."
            ),
            Guideline(
                "Show a mixed state when sub-options disagree.",
                "A checkbox that controls several others should show a dash when some are on and some are off. `Toggle(sources:isOn:)` does it for you."
            ),
        ]
    ) {
        VStack(alignment: .leading, spacing: 10) {
            Toggle("Show in menu bar", isOn: .constant(true))
            Toggle("Open at login", isOn: .constant(false))
            Toggle("iCloud Sync", isOn: .constant(true))
                .toggleStyle(.switch)
        }
        .toggleStyle(.checkbox)
    } content: { page in
        MacToggleDemo(page: page)
    }
}

private struct MacToggleConfig {
    var title = "Show in menu bar"
    var isOn = true
    var style: MacToggleStyleOption = .automatic
    var size: MacControlSizeOption = .regular
    var hidesLabel = false
    var isDisabled = false
}

private struct MacToggleDemo: View {
    let page: ComponentPage

    var body: some View {
        DemoPage(
            page: page,
            initial: MacToggleConfig(),
            usage: """
            @State private var showsInMenuBar = true

            Toggle("Show in menu bar", isOn: $showsInMenuBar)
            """,
            usageNote: Aside(.note, "Pass the binding with `$`. The toggle writes the new value back to your `@State`, like a controlled `<input type=checkbox>`.")
        ) { $config in
            VStack(spacing: 16) {
                Toggle(config.title, systemImage: "menubar.rectangle", isOn: $config.isOn)
                    .styled(config.style)
                    .controlSize(config.size.size)
                    .modifier(HidesLabel(isHidden: config.hidesLabel))
                    .disabled(config.isDisabled)

                Text("isOn = \(config.isOn ? "true" : "false")")
                    .font(.footnote.monospaced())
                    .foregroundStyle(.secondary)
            }
        } controls: { $config in
            Section("Content") {
                TextField("Title", text: $config.title)
                Toggle("Is on", isOn: $config.isOn)
            }
            Section("Appearance") {
                OptionPicker("Style", selection: $config.style)
                OptionPicker("Size", selection: $config.size)
                Toggle("Hide label", isOn: $config.hidesLabel)
                Toggle("Disabled", isOn: $config.isDisabled)
            }
        } code: { config in
            var lines = ["@State private var isOn = \(config.isOn)", ""]
            lines.append("Toggle(\(swiftString(config.title)), systemImage: \"menubar.rectangle\", isOn: $isOn)")
            if config.style != .automatic {
                lines.append("    .toggleStyle(\(config.style.label))")
            }
            if config.size != .regular {
                lines.append("    .controlSize(\(config.size.label))")
            }
            if config.hidesLabel {
                lines.append("    .labelsHidden()")
            }
            if config.isDisabled {
                lines.append("    .disabled(true)")
            }
            return lines.joined(separator: "\n")
        } examples: {
            MacToggleExamples()
        }
    }
}

// MARK: - Examples

private struct MacToggleExamples: View {
    @State private var showsWarnings = true
    @State private var includesMinor = false
    @State private var playsSound = true
    @State private var styles = [
        TextStyleSetting(name: "Bold", isOn: true),
        TextStyleSetting(name: "Italic", isOn: false),
        TextStyleSetting(name: "Underline", isOn: true),
    ]
    @State private var syncsWithICloud = true
    @State private var syncsDesktop = true
    @State private var syncsDocuments = false
    @State private var showsHidden = false

    var body: some View {
        ExampleCard(
            title: "Settings with dependencies",
            caption: "Outside a grouped form, toggles are checkboxes. Indent the ones that depend on another, and disable them while it's off.",
            code: """
            @State private var showsWarnings = true
            @State private var includesMinor = false
            @State private var playsSound = true

            VStack(alignment: .leading) {
                Toggle("Show warnings", isOn: $showsWarnings)
                Group {
                    Toggle("Include minor issues", isOn: $includesMinor)
                    Toggle("Play a sound", isOn: $playsSound)
                }
                .padding(.leading, 20)
                .disabled(!showsWarnings)
            }
            """,
            minHeight: 140
        ) {
            VStack(alignment: .leading) {
                Toggle("Show warnings", isOn: $showsWarnings)
                Group {
                    Toggle("Include minor issues", isOn: $includesMinor)
                    Toggle("Play a sound", isOn: $playsSound)
                }
                .padding(.leading, 20)
                .disabled(!showsWarnings)
            }
        }

        ExampleCard(
            title: "Select all, with a mixed state",
            caption: "`Toggle(sources:isOn:)` turns a group on or off together, and shows a dash when they don't match.",
            code: """
            struct TextStyleSetting: Identifiable {
                let name: String
                var isOn: Bool
                var id: String { name }
            }

            @State private var styles = [
                TextStyleSetting(name: "Bold", isOn: true),
                TextStyleSetting(name: "Italic", isOn: false),
                TextStyleSetting(name: "Underline", isOn: true),
            ]

            VStack(alignment: .leading) {
                Toggle(sources: $styles, isOn: \\.isOn) {
                    Text("All styles")
                }
                ForEach($styles) { $style in
                    Toggle(style.name, isOn: $style.isOn)
                        .padding(.leading, 20)
                }
            }
            """,
            minHeight: 160
        ) {
            VStack(alignment: .leading) {
                Toggle(sources: $styles, isOn: \.isOn) {
                    Text("All styles")
                }
                ForEach($styles) { $style in
                    Toggle(style.name, isOn: $style.isOn)
                        .padding(.leading, 20)
                }
            }
        }

        ExampleCard(
            title: "Switches in a grouped form",
            caption: "Use a regular `.switch` for the main setting and `.controlSize(.mini)` switches for the rows under it, like System Settings.",
            code: """
            @State private var syncsWithICloud = true
            @State private var syncsDesktop = true
            @State private var syncsDocuments = false

            Form {
                Toggle("iCloud Sync", isOn: $syncsWithICloud)
                Section {
                    Toggle("Desktop", isOn: $syncsDesktop)
                    Toggle("Documents", isOn: $syncsDocuments)
                }
                .controlSize(.mini)
                .disabled(!syncsWithICloud)
            }
            .formStyle(.grouped)
            .toggleStyle(.switch)
            """,
            minHeight: 220
        ) {
            Form {
                Toggle("iCloud Sync", isOn: $syncsWithICloud)
                Section {
                    Toggle("Desktop", isOn: $syncsDesktop)
                    Toggle("Documents", isOn: $syncsDocuments)
                }
                .controlSize(.mini)
                .disabled(!syncsWithICloud)
            }
            .formStyle(.grouped)
            .toggleStyle(.switch)
            .scrollDisabled(true)
            .frame(maxWidth: 420, minHeight: 210)
        }

        ExampleCard(
            title: "A toggle in the toolbar",
            caption: "Use `.toggleStyle(.button)` for a toolbar toggle. It stays highlighted while on, like a view option in Finder.",
            code: """
            @State private var showsHidden = false

            NavigationStack {
                Text("Files")
                    .toolbar {
                        Toggle("Show Hidden Files", systemImage: "eye", isOn: $showsHidden)
                            .toggleStyle(.button)
                    }
            }
            """,
            aside: Aside(.note, "A real `.toolbar` here would land in this window's own toolbar, so the preview draws one.")
        ) {
            MacWindowFrame(title: "Files", width: 360, height: 150) {
                Text(showsHidden ? "Showing hidden files" : "Files")
                    .foregroundStyle(.secondary)
            } toolbar: {
                Toggle("Show Hidden Files", systemImage: "eye", isOn: $showsHidden)
                    .toggleStyle(.button)
                    .labelStyle(.iconOnly)
            }
        }
    }
}

private struct TextStyleSetting: Identifiable {
    let name: String
    var isOn: Bool
    var id: String { name }
}

/// A small window toolbar for the toolbar guideline's previews.
private struct ToolbarSample<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        MacWindowFrame(title: "Library", width: 230, height: 90) {
            Color.clear
        } toolbar: {
            content
        }
    }
}

// MARK: - Options

private enum MacToggleStyleOption: DemoOption {
    case automatic, checkbox, `switch`, button

    var label: String {
        switch self {
        case .automatic: ".automatic"
        case .checkbox: ".checkbox"
        case .switch: ".switch"
        case .button: ".button"
        }
    }
}

private enum MacControlSizeOption: DemoOption {
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

private struct HidesLabel: ViewModifier {
    let isHidden: Bool

    func body(content: Content) -> some View {
        if isHidden {
            content.labelsHidden()
        } else {
            content
        }
    }
}

private extension View {
    @ViewBuilder
    func styled(_ style: MacToggleStyleOption) -> some View {
        switch style {
        case .automatic: toggleStyle(.automatic)
        case .checkbox: toggleStyle(.checkbox)
        case .switch: toggleStyle(.switch)
        case .button: toggleStyle(.button)
        }
    }
}
