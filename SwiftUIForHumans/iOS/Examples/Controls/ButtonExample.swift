import SwiftUI

extension ComponentPage {
    static let button = ComponentPage(
        id: "button",
        title: "Button",
        summary: "A control that runs an action when tapped.",
        category: .controls,
        symbol: "button.horizontal.top.press",
        availability: ["iOS 13.0+", "macOS 10.15+", "visionOS 1.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/button",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/buttons",
        aliases: ["cta", "call to action", "submit", "tap", "click", "onClick", "action", "pressable"],
        related: ["toggle", "menu", "link"],
        notes: [
            "**Set a style once for a whole group.** `.buttonStyle(_:)` applies to every button inside a container, so put it on the `VStack` or `HStack` instead of each button.",
            "**In a `List` or `Form`, buttons become rows.** They draw as tappable rows with tinted text, not the bordered styles above.",
        ],
        api: [
            APIItem("`Button(_:action:)`", "A text button. Add `systemImage:` for an icon, or use `label:` to pass any view."),
            APIItem("`.buttonStyle(_:)`", "The look: `.borderedProminent`, `.bordered`, `.glass`, and more."),
            APIItem("`.controlSize(_:)`", "From `.mini` to `.extraLarge`."),
            APIItem("`.buttonBorderShape(_:)`", "`.capsule`, `.roundedRectangle`, or `.circle`."),
            APIItem("`role:`", "`.destructive` turns the button red. `.cancel`, `.confirm`, and `.close` tell alerts and sheets where it goes."),
            APIItem("`.disabled(_:)`", "Dims the button and ignores taps."),
        ],
        guidelines: [
            Guideline(
                "Use one prominent button per screen.",
                "The filled `.borderedProminent` style marks the action people most likely want. Several of them compete, and none stands out.",
                good: "One filled button for the main action.",
                bad: "Three filled buttons fight for attention."
            ) {
                VStack(spacing: 10) {
                    Button("Continue") {}.buttonStyle(.borderedProminent)
                    Button("Not Now") {}.buttonStyle(.borderless)
                }
            } bad: {
                VStack(spacing: 10) {
                    Button("Continue") {}.buttonStyle(.borderedProminent)
                    Button("Save Draft") {}.buttonStyle(.borderedProminent)
                    Button("Not Now") {}.buttonStyle(.borderedProminent)
                }
            },
            Guideline(
                "Use style, not size, to show the preferred choice.",
                "Buttons of the same size read as one set of options. Make the preferred one more prominent instead of bigger.",
                good: "Same size, different prominence.",
                bad: "Mixed sizes look inconsistent."
            ) {
                HStack {
                    Button("Cancel") {}.buttonStyle(.bordered)
                    Button("Save") {}.buttonStyle(.borderedProminent)
                }
                .controlSize(.large)
            } bad: {
                HStack {
                    Button("Cancel") {}.buttonStyle(.bordered).controlSize(.small)
                    Button("Save") {}.buttonStyle(.bordered).controlSize(.extraLarge)
                }
            },
            Guideline(
                "Start labels with a verb.",
                "A label like “Add to Cart” says what will happen. A noun or “OK” makes people guess.",
                good: "The label says what happens.",
                bad: "A noun leaves people guessing."
            ) {
                Button("Add to Cart", systemImage: "cart.badge.plus") {}
                    .buttonStyle(.borderedProminent)
            } bad: {
                Button("Cart", systemImage: "cart") {}
                    .buttonStyle(.borderedProminent)
            },
            Guideline(
                "Make every button at least 44 × 44 points.",
                "Smaller targets are easy to miss. The system styles handle this; for a custom label, add padding or `.contentShape(.rect)` to grow the tappable area."
            ),
            Guideline(
                "Never make a destructive action the default.",
                "People tap the prominent button without reading it. Keep Delete in a regular style with `role: .destructive`, and confirm before it runs."
            ),
        ]
    ) {
        VStack(spacing: 10) {
            Button("Sign In") {}
                .buttonStyle(.borderedProminent)
            Button("Cancel") {}
                .buttonStyle(.bordered)
        }
        .controlSize(.large)
    } content: { page in
        ButtonDemo(page: page)
    }
}

private struct ButtonConfig {
    var title = "Sign In"
    var content: ButtonContent = .text
    var style: ButtonStyleOption = .borderedProminent
    var size: ButtonSizeOption = .large
    var shape: ButtonShapeOption = .automatic
    var role: ButtonRoleOption = .none
    var isDisabled = false
    var tapCount = 0
}

private struct ButtonDemo: View {
    let page: ComponentPage

    var body: some View {
        DemoPage(
            page: page,
            initial: ButtonConfig(),
            usage: """
            Button("Sign In") {
                signIn()
            }
            .buttonStyle(.borderedProminent)
            """,
            usageNote: Aside(.note, "The trailing closure is the action. For a custom look, use `Button { … } label: { … }` and pass any view as the label.")
        ) { $config in
            VStack(spacing: 16) {
                Button(role: config.role.role) {
                    config.tapCount += 1
                } label: {
                    switch config.content {
                    case .text: Text(config.title)
                    case .textAndIcon: Label(config.title, systemImage: "person.crop.circle")
                    case .iconOnly: Label(config.title, systemImage: "person.crop.circle").labelStyle(.iconOnly)
                    }
                }
                .styled(config.style)
                .controlSize(config.size.size)
                .buttonBorderShape(config.shape.shape)
                .disabled(config.isDisabled)

                Text(config.tapCount == 0 ? "Tap the button" : "Tapped \(config.tapCount) time\(config.tapCount == 1 ? "" : "s")")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .contentTransition(.numericText())
                    .animation(.snappy, value: config.tapCount)
            }
        } controls: { $config in
            Section("Content") {
                TextField("Title", text: $config.title)
                OptionPicker("Label", selection: $config.content)
            }
            Section("Appearance") {
                OptionPicker("Style", selection: $config.style)
                OptionPicker("Size", selection: $config.size)
                OptionPicker("Shape", selection: $config.shape)
                OptionPicker("Role", selection: $config.role)
                Toggle("Disabled", isOn: $config.isDisabled)
            }
        } code: { config in
            var lines: [String] = []
            let roleArg = config.role == .none ? "" : "role: \(config.role.label), "
            let title = swiftString(config.title)
            switch config.content {
            case .text where config.role == .none:
                lines.append("Button(\(title)) {")
            case .text:
                lines.append("Button(\(title), \(roleArg)action: {")
            case .textAndIcon, .iconOnly:
                lines.append("Button(\(title), systemImage: \"person.crop.circle\", \(roleArg)action: {")
            }
            lines.append("    // Your action")
            lines.append(config.content == .text && config.role == .none ? "}" : "})")
            if config.content == .iconOnly {
                lines.append(".labelStyle(.iconOnly)")
            }
            if config.style != .automatic {
                lines.append(".buttonStyle(\(config.style.label))")
            }
            if config.size != .regular {
                lines.append(".controlSize(\(config.size.label))")
            }
            if config.shape != .automatic {
                lines.append(".buttonBorderShape(\(config.shape.label))")
            }
            if config.isDisabled {
                lines.append(".disabled(true)")
            }
            return lines.enumerated()
                .map { index, line in index > 0 && line.hasPrefix(".") ? "    " + line : line }
                .joined(separator: "\n")
        } examples: {
            ButtonExamples()
        }
    }
}

// MARK: - Examples

private struct ButtonExamples: View {
    @State private var isFavorite = false
    @State private var showsConfirm = false
    @State private var isDeleted = false
    @State private var isCheckingOut = false

    var body: some View {
        ExampleCard(
            title: "Full-width button",
            caption: "Put `.frame(maxWidth: .infinity)` on the label, not the button, so the whole bar fills and responds to taps.",
            code: """
            Button {
                // Continue
            } label: {
                Text("Continue")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            """
        ) {
            Button {
            } label: {
                Text("Continue")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .frame(maxWidth: 380)
        }

        ExampleCard(
            title: "Icon button",
            caption: "Use a `Label` with `.labelStyle(.iconOnly)`, so VoiceOver still reads the title.",
            code: """
            @State private var isFavorite = false

            Button {
                isFavorite.toggle()
            } label: {
                Label("Favorite", systemImage: isFavorite ? "heart.fill" : "heart")
                    .labelStyle(.iconOnly)
                    .contentTransition(.symbolEffect(.replace))
            }
            .buttonStyle(.bordered)
            .buttonBorderShape(.circle)
            .controlSize(.large)
            .tint(.pink)
            """
        ) {
            Button {
                isFavorite.toggle()
            } label: {
                Label("Favorite", systemImage: isFavorite ? "heart.fill" : "heart")
                    .labelStyle(.iconOnly)
                    .contentTransition(.symbolEffect(.replace))
            }
            .buttonStyle(.bordered)
            .buttonBorderShape(.circle)
            .controlSize(.large)
            .tint(.pink)
        }

        ExampleCard(
            title: "Loading state",
            caption: "Show a `ProgressView` in the label while work runs, and disable the button so it can't be tapped twice.",
            code: """
            @State private var isCheckingOut = false

            Button {
                isCheckingOut = true
                Task {
                    await checkOut()
                    isCheckingOut = false
                }
            } label: {
                if isCheckingOut {
                    HStack {
                        ProgressView()
                        Text("Checking Out…")
                    }
                } else {
                    Text("Check Out")
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(isCheckingOut)
            """
        ) {
            Button {
                isCheckingOut = true
                Task {
                    try? await Task.sleep(for: .seconds(2))
                    isCheckingOut = false
                }
            } label: {
                if isCheckingOut {
                    HStack {
                        ProgressView()
                        Text("Checking Out…")
                    }
                } else {
                    Text("Check Out")
                }
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(isCheckingOut)
        }

        ExampleCard(
            title: "Destructive with confirmation",
            caption: "Give risky actions `role: .destructive`, and confirm them with `.confirmationDialog`.",
            code: """
            @State private var showsConfirm = false

            Button("Delete Account", role: .destructive) {
                showsConfirm = true
            }
            .buttonStyle(.bordered)
            .confirmationDialog("Delete your account?", isPresented: $showsConfirm, titleVisibility: .visible) {
                Button("Delete", role: .destructive) {
                    // Delete it
                }
            } message: {
                Text("This can't be undone.")
            }
            """,
            aside: Aside(.note, "The dialog adds a Cancel button for you, and its destructive button turns red.")
        ) {
            VStack(spacing: 12) {
                Button("Delete Account", role: .destructive) {
                    showsConfirm = true
                }
                .buttonStyle(.bordered)
                .confirmationDialog("Delete your account?", isPresented: $showsConfirm, titleVisibility: .visible) {
                    Button("Delete", role: .destructive) {
                        isDeleted = true
                    }
                } message: {
                    Text("This can't be undone.")
                }
                Text(isDeleted ? "Deleted (not really)" : "Tap to see the confirmation")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - Options

private enum ButtonContent: String, DemoOption {
    case text, textAndIcon, iconOnly

    var label: String {
        switch self {
        case .text: "Text"
        case .textAndIcon: "Text and icon"
        case .iconOnly: "Icon only"
        }
    }
}

private enum ButtonStyleOption: DemoOption {
    case automatic, bordered, borderedProminent, borderless, plain, glass, glassProminent

    var label: String {
        switch self {
        case .automatic: ".automatic"
        case .bordered: ".bordered"
        case .borderedProminent: ".borderedProminent"
        case .borderless: ".borderless"
        case .plain: ".plain"
        case .glass: ".glass"
        case .glassProminent: ".glassProminent"
        }
    }
}

private enum ButtonSizeOption: DemoOption {
    case mini, small, regular, large, extraLarge

    var label: String {
        switch self {
        case .mini: ".mini"
        case .small: ".small"
        case .regular: ".regular"
        case .large: ".large"
        case .extraLarge: ".extraLarge"
        }
    }

    var size: ControlSize {
        switch self {
        case .mini: .mini
        case .small: .small
        case .regular: .regular
        case .large: .large
        case .extraLarge: .extraLarge
        }
    }
}

private enum ButtonShapeOption: DemoOption {
    case automatic, capsule, roundedRectangle, circle

    var label: String {
        switch self {
        case .automatic: ".automatic"
        case .capsule: ".capsule"
        case .roundedRectangle: ".roundedRectangle"
        case .circle: ".circle"
        }
    }

    var shape: ButtonBorderShape {
        switch self {
        case .automatic: .automatic
        case .capsule: .capsule
        case .roundedRectangle: .roundedRectangle
        case .circle: .circle
        }
    }
}

private enum ButtonRoleOption: DemoOption {
    case none, destructive, cancel, confirm, close

    var label: String {
        switch self {
        case .none: "None"
        case .destructive: ".destructive"
        case .cancel: ".cancel"
        case .confirm: ".confirm"
        case .close: ".close"
        }
    }

    var role: ButtonRole? {
        switch self {
        case .none: nil
        case .destructive: .destructive
        case .cancel: .cancel
        case .confirm: .confirm
        case .close: .close
        }
    }
}

private extension View {
    /// `.buttonStyle` takes a different concrete type per style, so switch here.
    @ViewBuilder
    func styled(_ style: ButtonStyleOption) -> some View {
        switch style {
        case .automatic: buttonStyle(.automatic)
        case .bordered: buttonStyle(.bordered)
        case .borderedProminent: buttonStyle(.borderedProminent)
        case .borderless: buttonStyle(.borderless)
        case .plain: buttonStyle(.plain)
        case .glass: buttonStyle(.glass)
        case .glassProminent: buttonStyle(.glassProminent)
        }
    }
}
