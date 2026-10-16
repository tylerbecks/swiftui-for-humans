import SwiftUI

extension ComponentPage {
    static let focusState = ComponentPage(
        id: "focus-state",
        title: "Keyboard & Focus",
        summary: "Choose which field is active, move between fields on Return, pick the right keyboard, and dismiss it.",
        category: .textInput,
        kind: .concept,
        symbol: "keyboard",
        availability: ["iOS 15.0+", "macOS 12.0+", "visionOS 1.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/focusstate",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/virtual-keyboards",
        aliases: ["focus()", "blur()", "autofocus", "dismiss keyboard", "hide keyboard", "becomeFirstResponder", "resignFirstResponder", "enterkeyhint", "inputmode", "onSubmit"],
        related: ["text-field", "secure-field", "form", "login-form"],
        notes: [
            "**Set focus once the field is on screen.** Setting it in `init` does nothing. Set it in `.onAppear` or `.task` to focus a field when a screen opens.",
            "**In the Simulator, press ⌘K to show the keyboard.** With a hardware keyboard connected, the software one stays hidden.",
        ],
        api: [
            APIItem("`@FocusState`", "Holds which field is focused: a `Bool` or an optional enum."),
            APIItem("`.focused(_:equals:)`", "Ties a field to one value of an enum focus state."),
            APIItem("`.focused(_:)`", "Ties a single field to a `Bool` focus state."),
            APIItem("`.onSubmit { }`", "Runs when people tap Return."),
            APIItem("`.submitLabel(_:)`", "The Return key's title: `.next`, `.done`, `.search`, and more."),
            APIItem("`.keyboardType(_:)`", "The keyboard layout, such as `.emailAddress` or `.numberPad`."),
            APIItem("`.scrollDismissesKeyboard(_:)`", "Hides the keyboard when people scroll."),
            APIItem("`ToolbarItemGroup(placement: .keyboard)`", "Buttons in a bar above the keyboard."),
        ],
        guidelines: [
            Guideline(
                "Match the keyboard to the content.",
                "An email keyboard puts @ up front and a number pad shows only digits. Add `.textContentType` too, so iOS can offer AutoFill."
            ),
            Guideline(
                "Name the Return key for what it does.",
                "“Next” moves to the next field, “Search” runs a search, and “Done” finishes. People know what happens before they tap."
            ),
            Guideline(
                "Move focus in reading order.",
                "Return should go from one field to the one below it, top to bottom, and dismiss the keyboard after the last one."
            ),
            Guideline(
                "Always give people a way to hide the keyboard.",
                "It covers half the screen. Add a Done button, scroll-to-dismiss, or a Return key that ends editing."
            ),
        ]
    ) {
        VStack(spacing: 10) {
            TextField("Name", text: .constant("Taylor"))
                .textFieldStyle(.roundedBorder)
                .overlay {
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(.tint, lineWidth: 2)
                }
            TextField("Email", text: .constant(""))
                .textFieldStyle(.roundedBorder)
            Label("focused = .name", systemImage: "keyboard")
                .font(.caption.monospaced())
                .foregroundStyle(.secondary)
        }
        .frame(width: 200)
    } content: { page in
        ArticlePage(page: page) {
            Prose("On the web you call `input.focus()` and `input.blur()`. In SwiftUI, **focus is state**: declare a `@FocusState` property, attach it to fields with `.focused(_:equals:)`, and read or set it like any other value.")

            VStack(alignment: .leading, spacing: 12) {
                SectionTitle("Focus is state")
                Prose("Use a `Bool` for one field, or an optional enum for several. Tap a field or pick one below: the readout shows `focusedField`, and Return moves to the next field. `nil` means nothing is focused, so the keyboard hides.")
                FocusPlayground()
                Aside(.note, "`.onSubmit` on the container runs for every field inside it, so one `switch` can move focus through the whole form.")
            }

            VStack(alignment: .leading, spacing: 12) {
                SectionTitle("Pick the right keyboard")
                Prose("`.keyboardType` chooses the layout, `.submitLabel` names the Return key, and `.textContentType` lets iOS offer AutoFill. Change them, then tap the field.")
                KeyboardLab()
                Aside(.important, "`.submitLabel` only changes the key's title, and `.keyboardType` is only a hint: people can still paste anything. Do the work in `.onSubmit`, and validate the text.")
            }
            .id("keyboards")

            VStack(alignment: .leading, spacing: 28) {
                VStack(alignment: .leading, spacing: 12) {
                    SectionTitle("Dismissing the keyboard")
                    Prose("iOS doesn't hide the keyboard when people tap elsewhere. Give them at least one of these ways out.")
                }
                ExampleCard(
                    title: "Done button above the keyboard",
                    caption: "Put a button in the `.keyboard` toolbar placement that clears focus. Tap the field, then tap **Done**.",
                    code: """
                    @State private var note = ""
                    @FocusState private var isFocused: Bool

                    TextField("Add a note", text: $note)
                        .textFieldStyle(.roundedBorder)
                        .focused($isFocused)
                        .toolbar {
                            ToolbarItemGroup(placement: .keyboard) {
                                Spacer()
                                Button("Done") {
                                    isFocused = false
                                }
                            }
                        }
                    """,
                    minHeight: 140
                ) {
                    KeyboardToolbarExample()
                }
                ExampleCard(
                    title: "Dismiss by scrolling",
                    caption: "Add `.scrollDismissesKeyboard(.interactively)` so people can drag the keyboard down, like in Messages.",
                    code: """
                    @State private var items = ["Milk", "Eggs", "Coffee"]
                    @State private var newItem = ""

                    List {
                        TextField("New item", text: $newItem)
                            .onSubmit {
                                items.append(newItem)
                                newItem = ""
                            }
                        ForEach(items, id: \\.self) { Text($0) }
                    }
                    .scrollDismissesKeyboard(.interactively)
                    """
                ) {
                    ScrollDismissExample()
                }
                Aside(.important, "Old Stack Overflow answers hide the keyboard with a UIKit `sendAction` trick. You don't need it: set your `@FocusState` to `nil` or `false`.")
            }
            .id("dismissing")
        }
    }
}

// MARK: - Focus playground

private enum PlaygroundField: String, CaseIterable, Hashable {
    case name, email, city
}

private struct FocusPlayground: View {
    @State private var name = ""
    @State private var email = ""
    @State private var city = ""
    @FocusState private var focused: PlaygroundField?

    private var focusText: String {
        focused.map { "focusedField = .\($0.rawValue)" } ?? "focusedField = nil"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            PreviewCard(minHeight: 260) {
                VStack(spacing: 12) {
                    playgroundField("Name", text: $name, field: .name, submit: .next)
                    playgroundField("Email", text: $email, field: .email, submit: .next)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    playgroundField("City", text: $city, field: .city, submit: .done)

                    Text(focusText)
                        .font(.footnote.monospaced())
                        .foregroundStyle(focused == nil ? Color.secondary : Color.accentColor)
                        .padding(.top, 4)

                    Picker("Focus", selection: Binding(get: { focused }, set: { focused = $0 })) {
                        Text("nil").tag(PlaygroundField?.none)
                        ForEach(PlaygroundField.allCases, id: \.self) { field in
                            Text(".\(field.rawValue)").tag(Optional(field))
                        }
                    }
                    .pickerStyle(.segmented)
                }
                .frame(maxWidth: 360)
                .animation(.snappy, value: focused)
            }
            CodeBlock(code: """
            enum Field { case name, email, city }

            @State private var name = ""
            @State private var email = ""
            @State private var city = ""
            @FocusState private var focusedField: Field?

            VStack {
                TextField("Name", text: $name)
                    .focused($focusedField, equals: .name)
                    .submitLabel(.next)
                TextField("Email", text: $email)
                    .focused($focusedField, equals: .email)
                    .submitLabel(.next)
                TextField("City", text: $city)
                    .focused($focusedField, equals: .city)
                    .submitLabel(.done)

                Button("Dismiss Keyboard") {
                    focusedField = nil
                }
            }
            .textFieldStyle(.roundedBorder)
            .onSubmit {
                // Return moves to the next field, then dismisses.
                switch focusedField {
                case .name: focusedField = .email
                case .email: focusedField = .city
                default: focusedField = nil
                }
            }
            """)
        }
    }

    private func playgroundField(_ title: String, text: Binding<String>, field: PlaygroundField, submit: SubmitLabel) -> some View {
        TextField(title, text: text)
            .textFieldStyle(.roundedBorder)
            .focused($focused, equals: field)
            .submitLabel(submit)
            .onSubmit {
                switch field {
                case .name: focused = .email
                case .email: focused = .city
                case .city: focused = nil
                }
            }
            .overlay {
                RoundedRectangle(cornerRadius: 6)
                    .stroke(.tint, lineWidth: focused == field ? 2 : 0)
            }
    }
}

// MARK: - Keyboard lab

private struct KeyboardLab: View {
    @State private var keyboard: KeyboardOption = .emailAddress
    @State private var submit: SubmitOption = .go
    @State private var text = ""
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            PreviewCard(minHeight: 200) {
                VStack(spacing: 14) {
                    TextField(keyboard.placeholder, text: $text)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(keyboard.type)
                        .textContentType(keyboard.contentType)
                        .textInputAutocapitalization(keyboard.disablesCaps ? .never : nil)
                        .autocorrectionDisabled(keyboard.disablesCaps)
                        .submitLabel(submit.label)
                        .focused($isFocused)
                        .id(keyboard)

                    Grid(alignment: .leading, horizontalSpacing: 12, verticalSpacing: 8) {
                        GridRow {
                            Text("Keyboard")
                                .foregroundStyle(.secondary)
                            Picker("Keyboard", selection: $keyboard) {
                                ForEach(KeyboardOption.allCases) { Text($0.code).tag($0) }
                            }
                        }
                        GridRow {
                            Text("Return key")
                                .foregroundStyle(.secondary)
                            Picker("Return key", selection: $submit) {
                                ForEach(SubmitOption.allCases) { Text($0.code).tag($0) }
                            }
                        }
                    }
                    .font(.subheadline)
                }
                .frame(maxWidth: 360)
                .onChange(of: keyboard) {
                    // Reopen the keyboard so the new layout shows right away.
                    if isFocused {
                        isFocused = false
                        Task {
                            try? await Task.sleep(for: .milliseconds(350))
                            isFocused = true
                        }
                    }
                }
            }
            CodeBlock(code: code)
        }
    }

    private var code: String {
        var lines = [
            "@State private var text = \"\"",
            "",
            "TextField(\(swiftString(keyboard.placeholder)), text: $text)",
            "    .keyboardType(\(keyboard.code))",
        ]
        if let type = keyboard.contentTypeCode {
            lines.append("    .textContentType(\(type))")
        }
        if keyboard.disablesCaps {
            lines.append("    .textInputAutocapitalization(.never)")
            lines.append("    .autocorrectionDisabled()")
        }
        if submit != .return {
            lines.append("    .submitLabel(\(submit.code))")
        }
        lines.append("    .onSubmit {")
        lines.append("        // Runs when Return is tapped")
        lines.append("    }")
        return lines.joined(separator: "\n")
    }
}

private enum KeyboardOption: String, CaseIterable, Identifiable {
    case standard, emailAddress, url, numberPad, decimalPad, phonePad

    var id: Self { self }

    var code: String {
        switch self {
        case .standard: ".default"
        case .emailAddress: ".emailAddress"
        case .url: ".URL"
        case .numberPad: ".numberPad"
        case .decimalPad: ".decimalPad"
        case .phonePad: ".phonePad"
        }
    }

    var type: UIKeyboardType {
        switch self {
        case .standard: .default
        case .emailAddress: .emailAddress
        case .url: .URL
        case .numberPad: .numberPad
        case .decimalPad: .decimalPad
        case .phonePad: .phonePad
        }
    }

    var placeholder: String {
        switch self {
        case .standard: "Name"
        case .emailAddress: "Email"
        case .url: "Website"
        case .numberPad: "Verification code"
        case .decimalPad: "Amount"
        case .phonePad: "Phone"
        }
    }

    var contentType: UITextContentType? {
        switch self {
        case .standard: .name
        case .emailAddress: .emailAddress
        case .url: .URL
        case .numberPad: .oneTimeCode
        case .decimalPad: nil
        case .phonePad: .telephoneNumber
        }
    }

    var contentTypeCode: String? {
        switch self {
        case .standard: ".name"
        case .emailAddress: ".emailAddress"
        case .url: ".URL"
        case .numberPad: ".oneTimeCode"
        case .decimalPad: nil
        case .phonePad: ".telephoneNumber"
        }
    }

    var disablesCaps: Bool {
        self == .emailAddress || self == .url
    }
}

private enum SubmitOption: String, CaseIterable, Identifiable {
    case `return`, done, go, next, search, send, join

    var id: Self { self }
    var code: String { ".\(rawValue)" }

    var label: SubmitLabel {
        switch self {
        case .return: .return
        case .done: .done
        case .go: .go
        case .next: .next
        case .search: .search
        case .send: .send
        case .join: .join
        }
    }
}

// MARK: - Dismissing

private struct KeyboardToolbarExample: View {
    @State private var note = ""
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(spacing: 10) {
            TextField("Add a note", text: $note)
                .textFieldStyle(.roundedBorder)
                .focused($isFocused)
                .toolbar {
                    if isFocused {
                        ToolbarItemGroup(placement: .keyboard) {
                            Spacer()
                            Button("Done") {
                                isFocused = false
                            }
                        }
                    }
                }
            Text(isFocused ? "isFocused = true" : "isFocused = false")
                .font(.footnote.monospaced())
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: 320)
    }
}

private struct ScrollDismissExample: View {
    @State private var items = ["Milk", "Eggs", "Coffee", "Bread", "Apples", "Rice"]
    @State private var newItem = ""

    var body: some View {
        List {
            TextField("New item", text: $newItem)
                .onSubmit {
                    let trimmed = newItem.trimmingCharacters(in: .whitespaces)
                    if !trimmed.isEmpty { items.insert(trimmed, at: 0) }
                    newItem = ""
                }
            ForEach(items, id: \.self) { Text($0) }
        }
        .scrollDismissesKeyboard(.interactively)
        .frame(height: 220)
        .clipShape(.rect(cornerRadius: 12))
    }
}
