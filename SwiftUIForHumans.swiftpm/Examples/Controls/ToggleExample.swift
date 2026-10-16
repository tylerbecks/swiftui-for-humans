import SwiftUI

extension ComponentPage {
    static let toggle = ComponentPage(
        id: "toggle",
        title: "Toggle",
        summary: "A control that switches between on and off.",
        category: .controls,
        symbol: "switch.2",
        availability: ["iOS 13.0+", "macOS 10.15+", "visionOS 1.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/toggle",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/toggles",
        aliases: ["switch", "checkbox", "on off", "boolean", "flag", "UISwitch", "input type=checkbox", "toggle button"],
        related: ["button", "form", "state", "binding"],
        notes: [
            "**Always give a toggle a real label.** `.labelsHidden()` hides it on screen but VoiceOver still reads it, so a toggle without one is a mystery switch.",
        ],
        api: [
            APIItem("`Toggle(_:isOn:)`", "A labeled switch bound to a `Bool`."),
            APIItem("`Toggle(_:systemImage:isOn:)`", "Adds an SF Symbol next to the label."),
            APIItem("`.toggleStyle(_:)`", "`.switch` on iOS by default, or `.button` for a highlight button."),
            APIItem("`.tint(_:)`", "The color of the switch when it's on."),
            APIItem("`.labelsHidden()`", "Hides the label but keeps it for VoiceOver."),
            APIItem("`ToggleStyle`", "A protocol for drawing your own toggle, like a checkbox."),
        ],
        guidelines: [
            Guideline(
                "Use a switch only in a list or form row.",
                "A switch floating on its own looks out of place. Outside a list, use `.toggleStyle(.button)` instead, like a filter button.",
                good: "A button-style toggle outside a list.",
                bad: "A lone switch in the middle of content."
            ) {
                Toggle("Favorites", systemImage: "star.fill", isOn: .constant(true))
                    .toggleStyle(.button)
            } bad: {
                Toggle("Favorites", isOn: .constant(true))
                    .frame(width: 200)
            },
            Guideline(
                "Name the setting, not its state.",
                "The switch already shows on or off. A label like “Wi-Fi” stays true either way; “Turn On Wi-Fi” is wrong half the time.",
                good: "The label names what it controls.",
                bad: "The label repeats the state."
            ) {
                Toggle("Wi-Fi", isOn: .constant(true))
                    .frame(width: 220)
            } bad: {
                Toggle("Wi-Fi Is On", isOn: .constant(true))
                    .frame(width: 220)
            },
            Guideline(
                "Change the tint only when you need to.",
                "The default green reads well everywhere. If you use your accent color, check it still stands out from the gray off state.",
                good: "Green or a strong accent stands out.",
                bad: "A pale tint looks almost off."
            ) {
                Toggle("Sync", isOn: .constant(true))
                    .frame(width: 220)
            } bad: {
                Toggle("Sync", isOn: .constant(true))
                    .tint(Color(white: 0.85))
                    .frame(width: 220)
            },
            Guideline(
                "Show the state with more than color.",
                "For a button-style toggle, also switch the symbol, like `star` to `star.fill`, so people who can't see the color difference can still tell."
            ),
        ]
    ) {
        VStack(spacing: 14) {
            Toggle("Wi-Fi", isOn: .constant(true))
            Toggle("Bluetooth", isOn: .constant(false))
        }
        .frame(width: 180)
    } content: { page in
        ToggleDemo(page: page)
    }
}

private struct ToggleConfig {
    var title = "Wi-Fi"
    var showsIcon = false
    var isOn = true
    var style: ToggleStyleOption = .automatic
    var tint: TintOption = .automatic
    var hidesLabel = false
    var isDisabled = false
}

private struct ToggleDemo: View {
    let page: ComponentPage

    var body: some View {
        DemoPage(
            page: page,
            initial: ToggleConfig(),
            usage: """
            @State private var wifiOn = true

            Form {
                Toggle("Wi-Fi", isOn: $wifiOn)
            }
            """,
            usageNote: Aside(.note, "Pass the binding with `$`. The toggle writes the new value back to your `@State`, like a controlled `<input>` that updates its own state.")
        ) { $config in
            VStack(spacing: 16) {
                Group {
                    if config.showsIcon {
                        Toggle(config.title, systemImage: "wifi", isOn: $config.isOn)
                    } else {
                        Toggle(config.title, isOn: $config.isOn)
                    }
                }
                .styled(config.style)
                .tint(config.tint.color)
                .modifier(HidesLabel(isHidden: config.hidesLabel))
                .disabled(config.isDisabled)
                .frame(maxWidth: 320)

                Text("isOn = \(config.isOn ? "true" : "false")")
                    .font(.footnote.monospaced())
                    .foregroundStyle(.secondary)
            }
        } controls: { $config in
            Section("Content") {
                TextField("Title", text: $config.title)
                Toggle("Show icon", isOn: $config.showsIcon)
                Toggle("Is on", isOn: $config.isOn)
            }
            Section("Appearance") {
                OptionPicker("Style", selection: $config.style)
                OptionPicker("Tint", selection: $config.tint)
                Toggle("Hide label", isOn: $config.hidesLabel)
                Toggle("Disabled", isOn: $config.isDisabled)
            }
        } code: { config in
            var lines = ["@State private var isOn = \(config.isOn)", ""]
            let title = swiftString(config.title)
            lines.append(config.showsIcon
                ? "Toggle(\(title), systemImage: \"wifi\", isOn: $isOn)"
                : "Toggle(\(title), isOn: $isOn)")
            if config.style != .automatic {
                lines.append("    .toggleStyle(\(config.style.label))")
            }
            if config.tint != .automatic {
                lines.append("    .tint(\(config.tint.label))")
            }
            if config.hidesLabel {
                lines.append("    .labelsHidden()")
            }
            if config.isDisabled {
                lines.append("    .disabled(true)")
            }
            return lines.joined(separator: "\n")
        } examples: {
            ToggleExamples()
        }
    }
}

// MARK: - Examples

private struct ToggleExamples: View {
    @State private var notifications = true
    @State private var sounds = false
    @State private var isBold = true
    @State private var isItalic = false
    @State private var agrees = false

    var body: some View {
        ExampleCard(
            title: "Settings list",
            caption: "Inside a `Form`, each toggle becomes a row. Use `.disabled(_:)` on a setting that depends on another.",
            code: """
            @State private var notifications = true
            @State private var sounds = false

            Form {
                Toggle("Notifications", systemImage: "bell.badge", isOn: $notifications)
                Toggle("Sounds", systemImage: "speaker.wave.2", isOn: $sounds)
                    .disabled(!notifications)
            }
            """,
            minHeight: 160
        ) {
            Form {
                Toggle("Notifications", systemImage: "bell.badge", isOn: $notifications)
                Toggle("Sounds", systemImage: "speaker.wave.2", isOn: $sounds)
                    .disabled(!notifications)
            }
            .scrollDisabled(true)
            .frame(height: 170)
            .frame(maxWidth: 420)
            .scrollContentBackground(.hidden)
        }

        ExampleCard(
            title: "Formatting buttons",
            caption: "Use `.toggleStyle(.button)` outside a list. The button stays highlighted while on, like Bold in a text editor.",
            code: """
            @State private var isBold = true
            @State private var isItalic = false

            HStack {
                Toggle("Bold", systemImage: "bold", isOn: $isBold)
                Toggle("Italic", systemImage: "italic", isOn: $isItalic)
            }
            .toggleStyle(.button)
            .labelStyle(.iconOnly)
            """
        ) {
            VStack(spacing: 14) {
                HStack {
                    Toggle("Bold", systemImage: "bold", isOn: $isBold)
                    Toggle("Italic", systemImage: "italic", isOn: $isItalic)
                }
                .toggleStyle(.button)
                .labelStyle(.iconOnly)
                Text("The quick brown fox")
                    .bold(isBold)
                    .italic(isItalic)
            }
        }

        ExampleCard(
            title: "Checkbox-style agreement",
            caption: "iOS has no checkbox style, so write a `ToggleStyle` that draws one from `configuration.isOn`.",
            code: """
            struct CheckboxStyle: ToggleStyle {
                func makeBody(configuration: Configuration) -> some View {
                    Button {
                        configuration.isOn.toggle()
                    } label: {
                        Label {
                            configuration.label
                        } icon: {
                            Image(systemName: configuration.isOn ? "checkmark.square.fill" : "square")
                                .foregroundStyle(configuration.isOn ? Color.accentColor : .secondary)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }

            @State private var agrees = false

            Toggle("I agree to the terms", isOn: $agrees)
                .toggleStyle(CheckboxStyle())
            """,
            aside: Aside(.note, "Save checkboxes for agreements and checklists. For settings, people expect the standard switch.")
        ) {
            Toggle("I agree to the terms", isOn: $agrees)
                .toggleStyle(CheckboxStyle())
        }
    }
}

private struct CheckboxStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            Label {
                configuration.label
            } icon: {
                Image(systemName: configuration.isOn ? "checkmark.square.fill" : "square")
                    .foregroundStyle(configuration.isOn ? Color.accentColor : .secondary)
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Options

private enum ToggleStyleOption: DemoOption {
    case automatic, `switch`, button

    var label: String {
        switch self {
        case .automatic: ".automatic"
        case .switch: ".switch"
        case .button: ".button"
        }
    }
}

private enum TintOption: DemoOption {
    case automatic, blue, orange, pink, purple

    var label: String {
        switch self {
        case .automatic: "Default"
        case .blue: ".blue"
        case .orange: ".orange"
        case .pink: ".pink"
        case .purple: ".purple"
        }
    }

    var color: Color? {
        switch self {
        case .automatic: nil
        case .blue: .blue
        case .orange: .orange
        case .pink: .pink
        case .purple: .purple
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
    func styled(_ style: ToggleStyleOption) -> some View {
        switch style {
        case .automatic: toggleStyle(.automatic)
        case .switch: toggleStyle(.switch)
        case .button: toggleStyle(.button)
        }
    }
}
