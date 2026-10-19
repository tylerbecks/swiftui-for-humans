import SwiftUI

extension ComponentPage {
    static let button = ComponentPage(
        id: "button",
        title: "Button",
        summary: "A push button that runs an action when someone clicks it.",
        category: .controls,
        symbol: "button.horizontal.top.press",
        availability: ["macOS 10.15+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/button",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/buttons",
        aliases: ["push button", "NSButton", "default button", "cancel button", "return key", "escape key", "onClick", "cta", "submit", "<button>", "borderedProminent", "link button", "scope bar", "accessoryBar", "destructive"],
        related: ["toggle", "menu", "control-group", "link", "keyboard-shortcuts", "alert", "sheet", "tooltips"],
        notes: [
            "**A style on a container reaches every button inside it.** Put `.buttonStyle(_:)` on an `HStack` or a `Form` instead of on each button.",
            "**Give icon-only buttons a title anyway.** `Button(_:systemImage:action:)` with `.labelStyle(.iconOnly)` shows just the symbol, and VoiceOver still reads the title.",
        ],
        api: [
            APIItem("`Button(_:action:)`", "A push button with a text label."),
            APIItem("`Button(_:systemImage:action:)`", "A label with a title and an SF Symbol."),
            APIItem("`Button(_:role:action:)`", "Marks it as `.destructive` or `.cancel`."),
            APIItem("`.buttonStyle(_:)`", "Picks the look for every button inside."),
            APIItem("`.keyboardShortcut(.defaultAction)`", "Return clicks it; it's tinted as the default."),
            APIItem("`.keyboardShortcut(.cancelAction)`", "Escape clicks it."),
            APIItem("`.controlSize(_:)`", "From `.mini` up to `.extraLarge`."),
            APIItem("`.help(_:)`", "The tooltip that appears on hover."),
        ],
        guidelines: [
            Guideline(
                "Mark the preferred choice with style, not size.",
                "Buttons of the same size read as one set of choices. Give the likely one a more prominent style instead of making it bigger.",
                good: "Same size; the default button stands out by its style.",
                bad: "Different sizes make the pair look mismatched."
            ) {
                HStack {
                    Button("Cancel") {}
                    Button("Save") {}
                        .buttonStyle(.borderedProminent)
                }
            } bad: {
                HStack {
                    Button("Cancel") {}
                        .controlSize(.small)
                    Button("Save") {}
                        .controlSize(.large)
                }
            },
            Guideline(
                "Never make a destructive button the default.",
                "People often press Return or click the highlighted button without reading it. Make the safe choice the default so a quick Return doesn't delete anything.",
                good: "Cancel is the default; Delete needs a deliberate click.",
                bad: "Return would delete the file."
            ) {
                HStack {
                    Button("Delete", role: .destructive) {}
                    Button("Cancel") {}
                        .buttonStyle(.borderedProminent)
                }
            } bad: {
                HStack {
                    Button("Delete", role: .destructive) {}
                        .buttonStyle(.borderedProminent)
                    Button("Cancel") {}
                }
            },
            Guideline(
                "End the title with an ellipsis when it opens another window.",
                "On the Mac, “…” tells people they'll be asked for more before anything happens, as in Export… or Choose Folder….",
                good: "The ellipsis says a dialog comes next.",
                bad: "Without it, people expect the export to start right away."
            ) {
                Button("Export…") {}
            } bad: {
                Button("Export") {}
            },
            Guideline(
                "Label buttons with a verb.",
                "A short title that starts with a verb, like Add to Library, says what will happen. For a familiar action like sharing, a familiar SF Symbol works too."
            ),
        ]
    ) {
        VStack(spacing: 12) {
            Button("Add to Library") {}
                .buttonStyle(.borderedProminent)
            HStack {
                Button("Cancel") {}
                Button("Export…") {}
            }
        }
    } content: { page in
        MacButtonDemo(page: page)
    }
}

private struct MacButtonConfig {
    var title = "Add to Library"
    var showsIcon = false
    var style: MacButtonStyleOption = .automatic
    var role: MacButtonRoleOption = .none
    var shortcut: MacButtonShortcutOption = .none
    var size: MacButtonSizeOption = .regular
    var isDisabled = false
}

private struct MacButtonDemo: View {
    let page: ComponentPage
    @State private var clicks = 0

    var body: some View {
        DemoPage(
            page: page,
            initial: MacButtonConfig(),
            usage: """
            Button("Add to Library") {
                addToLibrary()
            }
            """,
            usageNote: Aside(.note, "The action is a closure, like an `onClick` handler. With an icon, use `Button(_:systemImage:action:)` so toolbars and menus can show the right parts.")
        ) { $config in
            VStack(spacing: 16) {
                MacStyledButton(config: config) { clicks += 1 }
                Text(clicks == 1 ? "Clicked once" : "Clicked \(clicks) times")
                    .font(.footnote.monospacedDigit())
                    .foregroundStyle(.secondary)
            }
        } controls: { $config in
            Section("Content") {
                TextField("Title", text: $config.title)
                Toggle("Show icon", isOn: $config.showsIcon)
            }
            Section("Appearance") {
                OptionPicker("Style", selection: $config.style)
                OptionPicker("Role", selection: $config.role)
                OptionPicker("Size", selection: $config.size)
            }
            Section("Behavior") {
                OptionPicker("Shortcut", selection: $config.shortcut)
                Toggle("Disabled", isOn: $config.isDisabled)
            }
        } code: { config in
            var head = "Button(\(swiftString(config.title))"
            if config.showsIcon {
                head += ", systemImage: \"plus\""
            }
            if config.role != .none {
                head += ", role: \(config.role.label)"
            }
            var lines = [head + ") {", "    addToLibrary()", "}"]
            if config.style != .automatic {
                lines.append(".buttonStyle(\(config.style.label))")
            }
            if config.size != .regular {
                lines.append(".controlSize(\(config.size.label))")
            }
            if config.shortcut != .none {
                lines.append(".keyboardShortcut(\(config.shortcut.label))")
            }
            if config.isDisabled {
                lines.append(".disabled(true)")
            }
            return lines.joined(separator: "\n")
        } examples: {
            MacButtonExamples()
        }
    }
}

/// The demo's button, built from the current options.
private struct MacStyledButton: View {
    let config: MacButtonConfig
    let action: () -> Void

    var body: some View {
        Group {
            if config.showsIcon {
                Button(config.title, systemImage: "plus", role: config.role.role, action: action)
            } else {
                Button(config.title, role: config.role.role, action: action)
            }
        }
        .styled(config.style)
        .controlSize(config.size.size)
        .modifier(MacShortcut(option: config.shortcut))
        .disabled(config.isDisabled)
    }
}

// MARK: - Examples

private struct MacButtonExamples: View {
    @State private var dialogResult = "Press Return or Escape, or click a button."
    @State private var items = ["Inbox", "Drafts", "Archive"]
    @State private var selection: String?
    @State private var scope = "All"

    var body: some View {
        ExampleCard(
            title: "Default and cancel buttons",
            caption: "Add `.keyboardShortcut(.defaultAction)` to the button people want most: Return clicks it, and it's tinted. `.cancelAction` maps Escape.",
            code: """
            HStack {
                Button("Cancel", role: .cancel) {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)

                Button("Save") {
                    save()
                }
                .keyboardShortcut(.defaultAction)
            }
            """,
            minHeight: 170,
            aside: Aside(.note, "If more than one button has `.defaultAction`, only the first gets the tint.")
        ) {
            VStack(alignment: .trailing, spacing: 18) {
                Text("Save changes to “Trip Notes”?")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                HStack {
                    Button("Cancel", role: .cancel) {
                        dialogResult = "Canceled"
                    }
                    .keyboardShortcut(.cancelAction)
                    Button("Save") {
                        dialogResult = "Saved"
                    }
                    .keyboardShortcut(.defaultAction)
                }
                Text(dialogResult)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: 320)
        }

        ExampleCard(
            title: "Destructive actions",
            caption: "Give a delete button `role: .destructive` so the system can style it as dangerous wherever it appears, including menus.",
            code: """
            HStack {
                Button("Delete Project", role: .destructive) {
                    deleteProject()
                }
                Button("Keep Project", role: .cancel) {
                    dismiss()
                }
            }
            """,
            minHeight: 140
        ) {
            HStack {
                Button("Delete Project", role: .destructive) {}
                Button("Keep Project", role: .cancel) {}
            }
        }

        ExampleCard(
            title: "Small buttons that act on a list",
            caption: "Use `.buttonStyle(.borderless)` for symbol buttons right under the view they change, like adding and removing rows.",
            code: """
            @State private var items = ["Inbox", "Drafts", "Archive"]
            @State private var selection: String?

            VStack(alignment: .leading, spacing: 0) {
                List(items, id: \\.self, selection: $selection) { item in
                    Text(item)
                }
                .frame(height: 110)
                HStack(spacing: 12) {
                    Button("Add Mailbox", systemImage: "plus") {
                        items.append("Mailbox \\(items.count + 1)")
                    }
                    Button("Remove Mailbox", systemImage: "minus") {
                        items.removeAll { $0 == selection }
                    }
                    .disabled(selection == nil)
                }
                .labelStyle(.iconOnly)
                .buttonStyle(.borderless)
                .padding(8)
            }
            """,
            minHeight: 200
        ) {
            VStack(alignment: .leading, spacing: 0) {
                List(items, id: \.self, selection: $selection) { item in
                    Text(item)
                }
                .frame(height: 110)
                HStack(spacing: 12) {
                    Button("Add Mailbox", systemImage: "plus") {
                        items.append("Mailbox \(items.count + 1)")
                    }
                    Button("Remove Mailbox", systemImage: "minus") {
                        items.removeAll { $0 == selection }
                    }
                    .disabled(selection == nil)
                }
                .labelStyle(.iconOnly)
                .buttonStyle(.borderless)
                .padding(8)
            }
            .frame(width: 260)
            .overlay {
                RoundedRectangle(cornerRadius: 6)
                    .strokeBorder(.separator)
            }
        }

        ExampleCard(
            title: "A button that looks like a link",
            caption: "Use `.buttonStyle(.link)` for a quiet action inside text-heavy content, like a hint under a sign-in form.",
            code: """
            VStack(spacing: 8) {
                Button("Sign In") {
                    signIn()
                }
                Button("Forgot Password?") {
                    resetPassword()
                }
                .buttonStyle(.link)
            }
            """,
            minHeight: 140,
            aside: Aside(.note, "To open a web page, use [Link](catalog://link) instead. It opens the URL in the person's default browser.")
        ) {
            VStack(spacing: 8) {
                Button("Sign In") {}
                Button("Forgot Password?") {}
                    .buttonStyle(.link)
            }
        }

        ExampleCard(
            title: "Scope bar buttons",
            caption: "`.buttonStyle(.accessoryBar)` is for a scope bar: a row of buttons that narrows a search to one kind of result.",
            code: """
            @State private var scope = "All"

            HStack(spacing: 4) {
                ForEach(["All", "Documents", "Images"], id: \\.self) { option in
                    Toggle(option, isOn: Binding(
                        get: { scope == option },
                        set: { if $0 { scope = option } }
                    ))
                    .toggleStyle(.button)
                }
            }
            .buttonStyle(.accessoryBar)
            """,
            minHeight: 140
        ) {
            VStack(spacing: 12) {
                HStack(spacing: 4) {
                    ForEach(["All", "Documents", "Images"], id: \.self) { option in
                        Toggle(option, isOn: Binding(
                            get: { scope == option },
                            set: { if $0 { scope = option } }
                        ))
                        .toggleStyle(.button)
                    }
                }
                .buttonStyle(.accessoryBar)
                Text("Searching \(scope.lowercased())")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - Options

private enum MacButtonStyleOption: DemoOption {
    case automatic, bordered, borderedProminent, borderless, link, accessoryBar, plain

    var label: String {
        switch self {
        case .automatic: ".automatic"
        case .bordered: ".bordered"
        case .borderedProminent: ".borderedProminent"
        case .borderless: ".borderless"
        case .link: ".link"
        case .accessoryBar: ".accessoryBar"
        case .plain: ".plain"
        }
    }
}

private enum MacButtonRoleOption: DemoOption {
    case none, destructive, cancel

    var label: String {
        switch self {
        case .none: "None"
        case .destructive: ".destructive"
        case .cancel: ".cancel"
        }
    }

    var role: ButtonRole? {
        switch self {
        case .none: nil
        case .destructive: .destructive
        case .cancel: .cancel
        }
    }
}

private enum MacButtonShortcutOption: DemoOption {
    case none, defaultAction, cancelAction

    var label: String {
        switch self {
        case .none: "None"
        case .defaultAction: ".defaultAction"
        case .cancelAction: ".cancelAction"
        }
    }
}

private enum MacButtonSizeOption: DemoOption {
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

private struct MacShortcut: ViewModifier {
    let option: MacButtonShortcutOption

    func body(content: Content) -> some View {
        switch option {
        case .none: content
        case .defaultAction: content.keyboardShortcut(.defaultAction)
        case .cancelAction: content.keyboardShortcut(.cancelAction)
        }
    }
}

private extension View {
    @ViewBuilder
    func styled(_ style: MacButtonStyleOption) -> some View {
        switch style {
        case .automatic: buttonStyle(.automatic)
        case .bordered: buttonStyle(.bordered)
        case .borderedProminent: buttonStyle(.borderedProminent)
        case .borderless: buttonStyle(.borderless)
        case .link: buttonStyle(.link)
        case .accessoryBar: buttonStyle(.accessoryBar)
        case .plain: buttonStyle(.plain)
        }
    }
}
