import SwiftUI

extension ComponentPage {
    static let keyboardShortcuts = ComponentPage(
        id: "keyboard-shortcuts",
        title: "Keyboard shortcuts",
        summary: "Run a button or menu item from the keyboard, like ⌘S for Save.",
        category: .menus,
        kind: .modifier,
        symbol: "command",
        availability: ["macOS 11.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/view/keyboardshortcut(_:modifiers:)",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/keyboards",
        aliases: ["hotkey", "hot key", "key equivalent", "keyEquivalent", "accelerator", "keybinding", "key binding", "command key", "KeyEquivalent", "EventModifiers", "defaultAction", "cancelAction", "Return key", "Escape key", "accesskey"],
        related: ["commands", "button", "keyboard-access", "focus-keyboard"],
        notes: [
            "**A shortcut works anywhere in the front window.** Pressing it is the same as clicking the control, even when the control doesn't have focus.",
            "**The first match wins.** SwiftUI looks in the key window, then the main window, then the menu bar, and runs the first control it finds with that shortcut.",
            "**Shortcuts adapt to other keyboards.** The system remaps ones that are hard to type on another layout, like ⌘[, and mirrors directional ones for right-to-left languages.",
        ],
        api: [
            APIItem("`.keyboardShortcut(_:modifiers:)`", "A key plus modifiers; ⌘ by default."),
            APIItem("`.keyboardShortcut(.defaultAction)`", "Return, for the main button."),
            APIItem("`.keyboardShortcut(.cancelAction)`", "Escape, for Cancel."),
            APIItem("`KeyEquivalent`", "The key: a character, or `.return`, `.delete`, arrows."),
            APIItem("`EventModifiers`", "`.command`, `.shift`, `.option`, `.control`."),
        ],
        guidelines: [
            Guideline(
                "Don't give a standard shortcut a new job.",
                "People expect ⌘C, ⌘Z, ⌘W, and the rest to work the same in every app. Pick a new shortcut for your own command instead."
            ),
            Guideline(
                "Add shortcuts only for the commands people use most.",
                "A few well-chosen shortcuts speed people up. Too many new ones make the app feel hard to learn."
            ),
            Guideline(
                "Lead with Command, and add Shift for a related command.",
                "Use Option sparingly, for advanced commands. Avoid Control: the system uses it for moving focus, screenshots, and more."
            ),
            Guideline(
                "Write modifiers in the order ⌃ ⌥ ⇧ ⌘.",
                "Menus list them that way, so help text and tooltips should too.",
                good: "Shift comes before Command.",
                bad: "Command first reads differently from every menu."
            ) {
                MenusInputMenuDrawing(title: "Message", rows: [
                    .item("Reply", "⌘R"),
                    .item("Forward", "⇧⌘F"),
                ], width: 190)
            } bad: {
                MenusInputMenuDrawing(title: "Message", rows: [
                    .item("Reply", "⌘R"),
                    .item("Forward", "⌘⇧F"),
                ], width: 190)
            },
            Guideline(
                "Don't add a modifier to make an unrelated shortcut.",
                "⇧⌘Z means Redo because ⌘Z means Undo. Using it for something else breaks the pattern people rely on."
            ),
        ]
    ) {
        HStack(spacing: 6) {
            ForEach(["⇧", "⌘", "K"], id: \.self) { key in
                Text(key)
                    .font(.title2.weight(.medium))
                    .frame(width: 44, height: 44)
                    .background(.background, in: .rect(cornerRadius: 8))
                    .overlay {
                        RoundedRectangle(cornerRadius: 8)
                            .strokeBorder(.separator)
                    }
                    .shadow(color: .black.opacity(0.12), radius: 1, y: 1)
            }
        }
    } content: { page in
        MacKeyboardShortcutsDemo(page: page)
    }
}

private struct MacShortcutConfig {
    var title = "Mark as Read"
    var key: ShortcutKeyOption = .k
    var command = true
    var shift = true
    var option = false
    var control = false
    var presses = 0

    var modifiers: EventModifiers {
        var result: EventModifiers = []
        if control { result.insert(.control) }
        if option { result.insert(.option) }
        if shift { result.insert(.shift) }
        if command { result.insert(.command) }
        return result
    }

    /// The shortcut as a menu shows it, like "⇧⌘K".
    var symbols: String {
        (control ? "⌃" : "") + (option ? "⌥" : "") + (shift ? "⇧" : "") + (command ? "⌘" : "") + key.symbol
    }

    /// The `modifiers:` argument, or nil when it's the default (⌘ alone).
    var modifiersCode: String? {
        var names: [String] = []
        if command { names.append(".command") }
        if shift { names.append(".shift") }
        if option { names.append(".option") }
        if control { names.append(".control") }
        if names == [".command"] { return nil }
        if names.count == 1 { return names[0] }
        return "[\(names.joined(separator: ", "))]"
    }
}

private struct MacKeyboardShortcutsDemo: View {
    let page: ComponentPage

    var body: some View {
        DemoPage(
            page: page,
            initial: MacShortcutConfig(),
            previewHeight: 220,
            usage: """
            Button("Mark as Read") {
                markAsRead()
            }
            .keyboardShortcut("k", modifiers: [.command, .shift])
            """,
            usageNote: Aside(.important, "A capital letter adds Shift: `.keyboardShortcut(\"K\")` is ⇧⌘K. Write the letter in lowercase and list the modifiers, so the code says what people press.")
        ) { $config in
            VStack(spacing: 14) {
                Button(config.title) {
                    config.presses += 1
                }
                .keyboardShortcut(config.key.equivalent, modifiers: config.modifiers)
                .controlSize(.large)

                Text("Press \(config.symbols)")
                    .font(.title3.monospaced().weight(.medium))
                Text(config.presses == 0 ? "Not pressed yet" : "Ran \(config.presses) \(config.presses == 1 ? "time" : "times")")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .contentTransition(.numericText())
                    .animation(.snappy, value: config.presses)
            }
        } controls: { $config in
            Section("Shortcut") {
                OptionPicker("Key", selection: $config.key)
                Toggle("⌘ Command", isOn: $config.command)
                Toggle("⇧ Shift", isOn: $config.shift)
                Toggle("⌥ Option", isOn: $config.option)
                Toggle("⌃ Control", isOn: $config.control)
            }
            Section("Button") {
                TextField("Title", text: $config.title)
            }
        } code: { config in
            var line = "    .keyboardShortcut(\(config.key.code)"
            if let modifiers = config.modifiersCode {
                line += ", modifiers: \(modifiers))"
            } else {
                line += ")"
            }
            if config.modifiers.isEmpty {
                line = "    .keyboardShortcut(\(config.key.code), modifiers: [])"
            }
            return """
            Button(\(swiftString(config.title))) {
                markAsRead()
            }
            \(line)
            """
        } examples: {
            MacKeyboardShortcutsExamples()
        }
    }
}

// MARK: - Examples

private struct MacKeyboardShortcutsExamples: View {
    @State private var lastAction = "Press Return or Escape."
    @State private var lastMessageAction = "Open the menu, or press a shortcut."

    var body: some View {
        ExampleCard(
            title: "Return and Escape in a dialog",
            caption: "`.defaultAction` binds Return to the main button and `.cancelAction` binds Escape to Cancel, like a dialog.",
            code: """
            HStack {
                Button("Cancel", role: .cancel) { dismiss() }
                    .keyboardShortcut(.cancelAction)
                Button("Save") { save() }
                    .keyboardShortcut(.defaultAction)
            }
            """,
            minHeight: 150
        ) {
            VStack(spacing: 14) {
                HStack {
                    Button("Cancel", role: .cancel) { lastAction = "Canceled" }
                        .keyboardShortcut(.cancelAction)
                    Button("Save") { lastAction = "Saved" }
                        .keyboardShortcut(.defaultAction)
                }
                Text(lastAction)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }

        ExampleCard(
            title: "Shortcuts appear in menus",
            caption: "Add `.keyboardShortcut` to a button in a `Menu` or a `CommandMenu`, and the menu shows the keys beside it.",
            code: """
            Menu("Message") {
                Button("Reply") { reply() }
                    .keyboardShortcut("r")
                Button("Forward") { forward() }
                    .keyboardShortcut("f", modifiers: [.command, .shift])
                Button("Mark as Unread") { markAsUnread() }
                    .keyboardShortcut("u", modifiers: [.command, .shift])
            }
            """,
            minHeight: 150,
            aside: Aside(.note, "The shortcuts work while the button's window is in front, even with the menu closed. In a real app, put these in a `CommandMenu` so they work from the menu bar.")
        ) {
            VStack(spacing: 14) {
                Menu("Message") {
                    Button("Reply") { lastMessageAction = "Reply" }
                        .keyboardShortcut("r")
                    Button("Forward") { lastMessageAction = "Forward" }
                        .keyboardShortcut("f", modifiers: [.command, .shift])
                    Button("Mark as Unread") { lastMessageAction = "Mark as Unread" }
                        .keyboardShortcut("u", modifiers: [.command, .shift])
                }
                .fixedSize()
                Text(lastMessageAction)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }

        VStack(alignment: .leading, spacing: 14) {
            Text("Shortcuts people already know")
                .font(.title3.bold())
                .outlineEntry("Shortcuts people already know", level: 2)
            RichText("The Human Interface Guidelines list the standard shortcuts. Support the ones that match your commands, and leave the rest alone. A few of the most common:")
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            ConnectFacts(rows: [
                ("⌘N   ⌘O   ⌘S   ⌘P", "New, Open, Save, and Print."),
                ("⌘Z   ⇧⌘Z", "Undo and Redo."),
                ("⌘X   ⌘C   ⌘V   ⌘A", "Cut, Copy, Paste, and Select All."),
                ("⌘F   ⌘G", "Find, and find the next match."),
                ("⌘W   ⌘M   ⌘H   ⌘Q", "Close the window, minimize it, hide the app, and quit."),
                ("⌘,   ⌘?", "Open Settings, and open the Help menu."),
            ])
        }
    }
}

// MARK: - Options

private enum ShortcutKeyOption: DemoOption {
    case k, l, `return`, delete, upArrow

    var label: String {
        switch self {
        case .k: "K"
        case .l: "L"
        case .return: "Return"
        case .delete: "Delete"
        case .upArrow: "Up Arrow"
        }
    }

    var symbol: String {
        switch self {
        case .k: "K"
        case .l: "L"
        case .return: "↩"
        case .delete: "⌫"
        case .upArrow: "↑"
        }
    }

    var code: String {
        switch self {
        case .k: "\"k\""
        case .l: "\"l\""
        case .return: ".return"
        case .delete: ".delete"
        case .upArrow: ".upArrow"
        }
    }

    var equivalent: KeyEquivalent {
        switch self {
        case .k: "k"
        case .l: "l"
        case .return: .return
        case .delete: .delete
        case .upArrow: .upArrow
        }
    }
}
