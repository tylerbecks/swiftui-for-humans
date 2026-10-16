import SwiftUI

extension ComponentPage {
    static let foregroundStyle = ComponentPage(
        id: "foreground-style",
        title: "foregroundStyle & tint",
        summary: "Colors text, symbols, and shapes, and sets the accent color of controls.",
        category: .modifiers,
        kind: .modifier,
        symbol: "paintbrush.fill",
        availability: ["iOS 15.0+", "macOS 12.0+", "visionOS 1.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/view/foregroundstyle(_:)",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/color",
        aliases: ["color", "text color", "font color", "foregroundColor", "accentColor", "brand color", "secondary text", "muted", "gray text", "tintColor"],
        related: ["system-colors", "font", "gradients", "sf-symbols"],
        notes: [
            "**`.foregroundColor(_:)` is deprecated.** `foregroundStyle` takes any style: a color, a gradient, a material, or a level like `.secondary`.",
            "**Both modifiers flow down to every child.** Set them once on a container, like CSS `color` inherited by nested elements.",
            "**`tint` replaces `accentColor`.** Set it once near the root of your app to give every control your brand color.",
        ],
        api: [
            APIItem("`.foregroundStyle(_:)`", "Colors text, symbols, and shapes inside the view."),
            APIItem("`.secondary` / `.tertiary`", "Dimmer levels of the current style, for supporting text."),
            APIItem("`.foregroundStyle(_:_:)`", "Colors the layers of a multi-layer SF Symbol."),
            APIItem("`.tint(_:)`", "The accent color of buttons, toggles, sliders, and links."),
            APIItem("`.tint`", "A style that means \"the current tint\", for your own views."),
        ],
        guidelines: [
            Guideline(
                "Save your tint color for things people can tap.",
                "If titles and plain text use the same color as buttons, people can't tell what's interactive.",
                good: "Only the button uses the tint.",
                bad: "Tinted text looks tappable."
            ) {
                FGTintSample(tintsTitle: false)
            } bad: {
                FGTintSample(tintsTitle: true)
            },
            Guideline(
                "Don't rely on color alone.",
                "Some people can't tell red from green. Pair a status color with a symbol or a word so everyone gets the message.",
                good: "A symbol and a word back up the color.",
                bad: "Only the dot's color shows the status."
            ) {
                FGStatusSample(showsLabel: true)
            } bad: {
                FGStatusSample(showsLabel: false)
            },
            Guideline(
                "Use semantic styles instead of fixed colors.",
                "`.primary`, `.secondary`, and system colors adjust for dark mode and Increase Contrast. A hard-coded gray or hex value doesn't."
            ),
        ]
    ) {
        VStack(spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: "paintpalette.fill")
                    .font(.title)
                    .foregroundStyle(.linearGradient(colors: [.pink, .orange], startPoint: .top, endPoint: .bottom))
                VStack(alignment: .leading, spacing: 2) {
                    Text("Primary").font(.headline)
                    Text("Secondary").font(.subheadline).foregroundStyle(.secondary)
                }
            }
            Toggle("Tint", isOn: .constant(true))
                .labelsHidden()
                .tint(.pink)
        }
    } content: { page in
        ForegroundStyleDemo(page: page)
    }
}

private struct FGConfig {
    var style: FGStyle = .primary
    var tint: FGTint = .automatic
    var isOn = true
    var volume = 0.6
}

private enum FGStyle: DemoOption {
    case primary, secondary, tertiary, color, gradient

    var label: String {
        switch self {
        case .primary: ".primary"
        case .secondary: ".secondary"
        case .tertiary: ".tertiary"
        case .color: ".indigo"
        case .gradient: "Gradient"
        }
    }

    var style: AnyShapeStyle {
        switch self {
        case .primary: AnyShapeStyle(.primary)
        case .secondary: AnyShapeStyle(.secondary)
        case .tertiary: AnyShapeStyle(.tertiary)
        case .color: AnyShapeStyle(.indigo)
        case .gradient: AnyShapeStyle(.linearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing))
        }
    }

    var code: String {
        switch self {
        case .gradient: ".linearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing)"
        default: label
        }
    }
}

private enum FGTint: DemoOption {
    case automatic, pink, green, orange, purple

    var label: String {
        switch self {
        case .automatic: "Default (accent)"
        case .pink: ".pink"
        case .green: ".green"
        case .orange: ".orange"
        case .purple: ".purple"
        }
    }

    var color: Color? {
        switch self {
        case .automatic: nil
        case .pink: .pink
        case .green: .green
        case .orange: .orange
        case .purple: .purple
        }
    }
}

private struct ForegroundStyleDemo: View {
    let page: ComponentPage

    var body: some View {
        DemoPage(
            page: page,
            initial: FGConfig(),
            previewHeight: 280,
            usage: """
            VStack(alignment: .leading) {
                Text("Downloads")
                    .font(.headline)
                Text("12 files, 2.4 GB")
                    .foregroundStyle(.secondary)
                Button("Download All") {}
                    .buttonStyle(.borderedProminent)
            }
            .tint(.green)
            """,
            usageNote: Aside(.note, "`foregroundStyle` is for content like text and icons. `tint` is for controls. Setting `foregroundStyle` on a button doesn't change its fill.")
        ) { $config in
            VStack(spacing: 24) {
                VStack(spacing: 6) {
                    Label("Downloads", systemImage: "arrow.down.circle.fill")
                        .font(.title2.bold())
                    Text("12 files, 2.4 GB")
                }
                .foregroundStyle(config.style.style)

                VStack(spacing: 14) {
                    Toggle("Wi-Fi only", isOn: $config.isOn)
                    Slider(value: $config.volume)
                    Button("Download All") {}
                        .buttonStyle(.borderedProminent)
                }
                .frame(maxWidth: 280)
                .tint(config.tint.color)
            }
        } controls: { $config in
            Section("foregroundStyle") {
                OptionPicker("Style", selection: $config.style)
            }
            Section("tint") {
                OptionPicker("Tint", selection: $config.tint)
            }
        } code: { config in
            var lines = [
                "@State private var isOn = true",
                "@State private var volume = 0.6",
                "",
                "VStack(spacing: 24) {",
                "    VStack(spacing: 6) {",
                "        Label(\"Downloads\", systemImage: \"arrow.down.circle.fill\")",
                "            .font(.title2.bold())",
                "        Text(\"12 files, 2.4 GB\")",
                "    }",
            ]
            if config.style != .primary {
                lines.append("    .foregroundStyle(\(config.style.code))")
            }
            lines += [
                "",
                "    VStack(spacing: 14) {",
                "        Toggle(\"Wi-Fi only\", isOn: $isOn)",
                "        Slider(value: $volume)",
                "        Button(\"Download All\") {}",
                "            .buttonStyle(.borderedProminent)",
                "    }",
                "    .frame(maxWidth: 280)",
            ]
            if config.tint != .automatic {
                lines.append("    .tint(\(config.tint.label))")
            }
            lines.append("}")
            return lines.joined(separator: "\n")
        } examples: {
            ExampleCard(
                title: "Hierarchy levels",
                caption: "Use `.secondary`, `.tertiary`, and `.quaternary` for supporting text instead of picking grays.",
                code: """
                VStack(alignment: .leading) {
                    Text("Primary").foregroundStyle(.primary)
                    Text("Secondary").foregroundStyle(.secondary)
                    Text("Tertiary").foregroundStyle(.tertiary)
                    Text("Quaternary").foregroundStyle(.quaternary)
                }
                .font(.title3.weight(.semibold))
                """,
                aside: Aside(.note, "These levels adapt to light mode, dark mode, and Increase Contrast automatically.")
            ) {
                VStack(alignment: .leading) {
                    Text("Primary").foregroundStyle(.primary)
                    Text("Secondary").foregroundStyle(.secondary)
                    Text("Tertiary").foregroundStyle(.tertiary)
                    Text("Quaternary").foregroundStyle(.quaternary)
                }
                .font(.title3.weight(.semibold))
            }

            ExampleCard(
                title: "Levels follow the parent style",
                caption: "Set a color once on the container, and `.secondary` inside becomes a dimmer version of it.",
                code: """
                VStack(alignment: .leading, spacing: 2) {
                    Text("Workout complete")
                        .font(.headline)
                    Text("32 min, 410 kcal")
                        .foregroundStyle(.secondary)
                }
                .foregroundStyle(.green)
                """
            ) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Workout complete")
                        .font(.headline)
                    Text("32 min, 410 kcal")
                        .foregroundStyle(.secondary)
                }
                .foregroundStyle(.green)
            }

            ExampleCard(
                title: "Brand color for controls",
                caption: "Set `.tint` on a container to recolor every toggle, slider, and prominent button inside.",
                code: """
                @State private var isOn = true

                VStack {
                    Toggle("Notifications", isOn: $isOn)
                    Button("Save") {}
                        .buttonStyle(.borderedProminent)
                }
                .tint(.orange)
                """
            ) {
                FGTintExample()
            }

            ExampleCard(
                title: "Two-color symbols",
                caption: "Pass two styles to `.foregroundStyle(_:_:)` to color the layers of a multi-layer SF Symbol.",
                code: """
                Image(systemName: "person.crop.circle.badge.plus")
                    .font(.system(size: 56))
                    .foregroundStyle(.blue, .gray)
                """
            ) {
                Image(systemName: "person.crop.circle.badge.plus")
                    .font(.system(size: 56))
                    .foregroundStyle(.blue, .gray)
            }

            ExampleCard(
                title: "Gradient text",
                caption: "Pass a gradient to `.foregroundStyle` for colorful headline text; any `ShapeStyle` works.",
                code: """
                Text("Hello, gradient")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.linearGradient(colors: [.orange, .pink], startPoint: .leading, endPoint: .trailing))
                """
            ) {
                Text("Hello, gradient")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.linearGradient(colors: [.orange, .pink], startPoint: .leading, endPoint: .trailing))
            }
        }
    }
}

private struct FGTintExample: View {
    @State private var isOn = true

    var body: some View {
        VStack {
            Toggle("Notifications", isOn: $isOn)
            Button("Save") {}
                .buttonStyle(.borderedProminent)
        }
        .tint(.orange)
        .frame(maxWidth: 280)
    }
}

// MARK: - Guideline samples

private struct FGTintSample: View {
    let tintsTitle: Bool

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Trip to Lisbon")
                    .font(.headline)
                    .foregroundStyle(tintsTitle ? AnyShapeStyle(.tint) : AnyShapeStyle(.primary))
                Text("May 4 – 9")
                    .font(.subheadline)
                    .foregroundStyle(tintsTitle ? AnyShapeStyle(.tint) : AnyShapeStyle(.secondary))
            }
            Spacer()
            Button("Edit") {}
        }
        .frame(width: 220)
    }
}

private struct FGStatusSample: View {
    let showsLabel: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            row("Order #1042", ok: true)
            row("Order #1043", ok: false)
        }
        .frame(width: 220)
    }

    private func row(_ title: String, ok: Bool) -> some View {
        HStack {
            Text(title)
            Spacer()
            if showsLabel {
                Label(ok ? "Shipped" : "Failed", systemImage: ok ? "checkmark.circle.fill" : "xmark.octagon.fill")
                    .font(.subheadline)
                    .foregroundStyle(ok ? .green : .red)
            } else {
                Circle()
                    .fill(ok ? .green : .red)
                    .frame(width: 12, height: 12)
            }
        }
    }
}
