import SwiftUI

extension ComponentPage {
    static let patternEnteringData = ComponentPage(
        id: "entering-data",
        title: "Entering Data",
        summary: "Ask for less, show the right keyboard, and catch mistakes while people type.",
        category: .patterns,
        kind: .concept,
        symbol: "keyboard",
        availability: ["iOS 15.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/view/keyboardtype(_:)",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/entering-data",
        aliases: ["form input", "input type", "inputmode", "autocomplete", "keyboard type", "<input type=\"email\">", "autofill", "one-time code", "form validation", "return key", "enterkeyhint", "UIKeyboardType", "UITextContentType"],
        related: ["form", "text-field", "secure-field", "focus-state", "picker", "date-picker", "login-form", "feedback"],
        notes: [
            "**`.keyboardType` is HTML's `inputmode`, and `.textContentType` is `autocomplete`.** The first picks the keys; the second tells iOS what the field is, so it can offer AutoFill.",
            "**Validate the value, not the keys.** A keyboard type only picks which keys show first. People can still paste anything, so check what arrives.",
        ],
        api: [
            APIItem("`.keyboardType(.emailAddress)`", "Picks the keys: email, numbers, phone."),
            APIItem("`.textContentType(_:)`", "Says what the field is, for AutoFill."),
            APIItem("`.textInputAutocapitalization`", "`.never` turns off the automatic shift key."),
            APIItem("`.autocorrectionDisabled()`", "Stops autocorrect on names and codes."),
            APIItem("`.submitLabel(.next)`", "Changes the Return key's title."),
            APIItem("`.onSubmit { }`", "Runs when people tap Return."),
            APIItem("`TextField(_:value:format:)`", "Edits a number, date, or currency."),
        ],
        guidelines: [
            Guideline(
                "Offer choices instead of typing.",
                "Picking from a short list is faster and can't be misspelled. Use a [Picker](catalog://picker) or [DatePicker](catalog://date-picker) when the answers are known.",
                good: "A picker with the valid sizes.",
                bad: "A field that hopes for S, M, or L."
            ) {
                EnteringSizePicker()
            } bad: {
                EnteringSizeField()
            },
            Guideline(
                "Make clear what goes in each field.",
                "Give each field a label and a sample value in the prompt, like `name@example.com`, so people know the format.",
                good: "A label and an example.",
                bad: "A vague prompt with no label."
            ) {
                EnteringLabeledField(label: "Email", prompt: "name@example.com")
            } bad: {
                EnteringLabeledField(label: nil, prompt: "Enter text")
            },
            Guideline(
                "Check values as soon as people enter them.",
                "Point out a problem next to the field right away, not in a list after they tap Submit. Keep Continue disabled until the required fields are filled in."
            ),
            Guideline(
                "Get it from the system when you can.",
                "Don't ask for what iOS already knows. Content types let people AutoFill names, addresses, passwords, and one-time codes."
            ),
            Guideline(
                "Hide secrets, and never prefill a password.",
                "Use a [SecureField](catalog://secure-field) for passwords, and let people type it or use AutoFill, Face ID, or a passkey."
            ),
        ],
        sources: [
            "https://developer.apple.com/design/human-interface-guidelines/entering-data",
            "https://developer.apple.com/design/human-interface-guidelines/virtual-keyboards",
            "https://developer.apple.com/documentation/swiftui/view/keyboardtype(_:)",
            "https://developer.apple.com/documentation/swiftui/view/textinputautocapitalization(_:)",
            "https://developer.apple.com/documentation/swiftui/view/submitlabel(_:)",
        ],
        reviewed: "October 2026"
    ) {
        EnteringThumbnail()
    } content: { page in
        EnteringDataArticle(page: page)
    }
}

// MARK: - Article

private struct EnteringDataArticle: View {
    let page: ComponentPage

    var body: some View {
        ArticlePage(page: page) {
            Prose("Typing on a phone is slow and easy to get wrong. Ask only for what you can't get another way, offer choices instead of blank fields, and tell iOS what each field is for. It then shows the right keyboard and can fill the value in for people.")

            VStack(alignment: .leading, spacing: 28) {
                SectionTitle("In SwiftUI")

                ExampleCard(
                    title: "The right keyboard for each field",
                    caption: "Pair `.keyboardType` with `.textContentType` so people get the right keys and AutoFill. Tap a field to see its keyboard.",
                    code: """
                    @State private var email = ""
                    @State private var phone = ""
                    @State private var code = ""

                    Form {
                        TextField("Email", text: $email)
                            .keyboardType(.emailAddress)
                            .textContentType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                        TextField("Phone", text: $phone)
                            .keyboardType(.phonePad)
                            .textContentType(.telephoneNumber)
                        TextField("Code", text: $code)
                            .keyboardType(.numberPad)
                            .textContentType(.oneTimeCode)
                    }
                    """,
                    minHeight: 240,
                    aside: Aside(.important, "Turn off capitalization and autocorrect for emails, usernames, and codes. Otherwise iOS “fixes” them as people type.")
                ) {
                    EnteringKeyboardsExample()
                }

                ExampleCard(
                    title: "Choose instead of type",
                    caption: "Use a `DatePicker` or `Picker` when the answers are known. There's nothing to misspell.",
                    code: """
                    @State private var date = Date.now
                    @State private var guests = 2

                    Form {
                        DatePicker("Date", selection: $date, displayedComponents: .date)
                        Picker("Guests", selection: $guests) {
                            ForEach(1...8, id: \\.self) { Text("\\($0)") }
                        }
                    }
                    """,
                    minHeight: 200
                ) {
                    EnteringChoicesExample()
                }

                ExampleCard(
                    title: "Return moves to the next field",
                    caption: "Set `.submitLabel(.next)` and move [focus](catalog://focus-state) in `.onSubmit`, so people never reach for the screen.",
                    code: """
                    enum Field { case name, email }
                    @State private var name = ""
                    @State private var email = ""
                    @FocusState private var focus: Field?

                    Form {
                        TextField("Name", text: $name)
                            .textContentType(.name)
                            .focused($focus, equals: .name)
                            .submitLabel(.next)
                        TextField("Email", text: $email)
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                            .focused($focus, equals: .email)
                            .submitLabel(.done)
                    }
                    .onSubmit {
                        focus = focus == .name ? .email : nil
                    }
                    """,
                    minHeight: 180
                ) {
                    EnteringReturnExample()
                }

                ExampleCard(
                    title: "Numbers and money",
                    caption: "Give `TextField` a `value` and a `format` and it accepts and shows numbers, here as currency.",
                    code: """
                    @State private var amount = 12.5

                    TextField("Amount", value: $amount, format: .currency(code: "USD"))
                        .keyboardType(.decimalPad)
                    """,
                    aside: Aside(.note, "If people type something the format can't read, the bound value stays as it was.")
                ) {
                    EnteringAmountExample()
                }

                ExampleCard(
                    title: "Continue only when ready",
                    caption: "Show problems next to the field, and disable Continue until the required values are valid.",
                    code: """
                    @State private var email = ""
                    @State private var agreed = false

                    var isValid: Bool {
                        email.contains("@") && email.contains(".") && agreed
                    }

                    Form {
                        TextField("Email", text: $email)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                        Toggle("I agree to the terms", isOn: $agreed)
                        Button("Continue") { }
                            .disabled(!isValid)
                    }
                    """,
                    minHeight: 220
                ) {
                    EnteringContinueExample()
                }
            }
        }
    }
}

// MARK: - Examples

private struct EnteringKeyboardsExample: View {
    @State private var email = ""
    @State private var phone = ""
    @State private var code = ""

    var body: some View {
        Form {
            TextField("Email", text: $email)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
            TextField("Phone", text: $phone)
                .keyboardType(.phonePad)
                .textContentType(.telephoneNumber)
            TextField("Code", text: $code)
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
        }
        .scrollDisabled(true)
        .frame(height: 200)
        .frame(maxWidth: 360)
        .clipShape(.rect(cornerRadius: 12))
    }
}

private struct EnteringChoicesExample: View {
    @State private var date = Date.now
    @State private var guests = 2

    var body: some View {
        Form {
            DatePicker("Date", selection: $date, displayedComponents: .date)
            Picker("Guests", selection: $guests) {
                ForEach(1...8, id: \.self) { Text("\($0)") }
            }
        }
        .scrollDisabled(true)
        .frame(height: 150)
        .frame(maxWidth: 360)
        .clipShape(.rect(cornerRadius: 12))
    }
}

private struct EnteringReturnExample: View {
    enum Field { case name, email }
    @State private var name = ""
    @State private var email = ""
    @FocusState private var focus: Field?

    var body: some View {
        Form {
            TextField("Name", text: $name)
                .textContentType(.name)
                .focused($focus, equals: .name)
                .submitLabel(.next)
            TextField("Email", text: $email)
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .focused($focus, equals: .email)
                .submitLabel(.done)
        }
        .onSubmit {
            focus = focus == .name ? .email : nil
        }
        .scrollDisabled(true)
        .frame(height: 150)
        .frame(maxWidth: 360)
        .clipShape(.rect(cornerRadius: 12))
    }
}

private struct EnteringAmountExample: View {
    @State private var amount = 12.5

    var body: some View {
        VStack(spacing: 10) {
            TextField("Amount", value: $amount, format: .currency(code: "USD"))
                .keyboardType(.decimalPad)
                .font(.title2.monospacedDigit())
                .multilineTextAlignment(.center)
                .padding(12)
                .background(.fill.tertiary, in: .rect(cornerRadius: 12))
            Text("Saved value: \(amount, format: .number)")
                .font(.footnote.monospacedDigit())
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: 240)
    }
}

private struct EnteringContinueExample: View {
    @State private var email = ""
    @State private var agreed = false

    private var isValid: Bool { email.contains("@") && email.contains(".") && agreed }

    var body: some View {
        Form {
            TextField("Email", text: $email)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
            Toggle("I agree to the terms", isOn: $agreed)
            Button("Continue") { }
                .disabled(!isValid)
        }
        .scrollDisabled(true)
        .frame(height: 200)
        .frame(maxWidth: 360)
        .clipShape(.rect(cornerRadius: 12))
    }
}

// MARK: - Do / Don't

private struct EnteringSizePicker: View {
    @State private var size = "M"

    var body: some View {
        Picker("Size", selection: $size) {
            ForEach(["S", "M", "L", "XL"], id: \.self) { Text($0) }
        }
        .pickerStyle(.segmented)
        .frame(width: 220)
    }
}

private struct EnteringSizeField: View {
    var body: some View {
        Text("Type a size (S, M, L…)")
            .foregroundStyle(.tertiary)
            .frame(width: 220, alignment: .leading)
            .padding(10)
            .background(.fill.tertiary, in: .rect(cornerRadius: 10))
    }
}

private struct EnteringLabeledField: View {
    let label: String?
    let prompt: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if let label {
                Text(label).font(.subheadline.weight(.medium))
            }
            Text(prompt)
                .foregroundStyle(.tertiary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(10)
                .background(.fill.tertiary, in: .rect(cornerRadius: 10))
        }
        .frame(width: 220)
    }
}

// MARK: - Thumbnail

private struct EnteringThumbnail: View {
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Image(systemName: "envelope").foregroundStyle(.secondary)
                Text("name@example.com").foregroundStyle(.tertiary)
                Spacer()
            }
            .padding(10)
            .background(.fill.tertiary, in: .rect(cornerRadius: 10))
            HStack(spacing: 6) {
                ForEach(["@", ".", ".com"], id: \.self) { key in
                    Text(key)
                        .font(.callout.weight(.medium))
                        .frame(minWidth: 34)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 4)
                        .background(.background, in: .rect(cornerRadius: 6))
                        .shadow(color: .black.opacity(0.15), radius: 0, y: 1)
                }
            }
            .padding(8)
            .background(.fill.secondary, in: .rect(cornerRadius: 10))
        }
        .frame(width: 210)
    }
}
