import SwiftUI

extension ComponentPage {
    static let textField = ComponentPage(
        id: "text-field",
        title: "TextField",
        summary: "A box people type a short piece of text or a number into.",
        category: .textInput,
        symbol: "character.cursor.ibeam",
        availability: ["iOS 13.0+", "macOS 10.15+", "visionOS 1.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/textfield",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/text-fields",
        aliases: ["input", "<input>", "text box", "textbox", "UITextField", "v-model", "onChange", "form field", "placeholder", "textfeild"],
        related: ["secure-field", "text-editor", "focus-state", "form"],
        notes: [
            "**The field edits a string you own.** Pass a `@State` property with `$`, like a controlled `<input>` in React. It updates on every keystroke.",
            "**Let it grow for longer text.** `TextField(_:text:axis: .vertical)` wraps onto new lines as people type; cap it with `.lineLimit(1...5)`. For a full page of text, use [TextEditor](catalog://text-editor).",
            "**Focus and the keyboard are state too.** To move between fields on Return or hide the keyboard, see [Keyboard & Focus](catalog://focus-state).",
        ],
        api: [
            APIItem("`TextField(_:text:)`", "A field bound to a `String`. The first argument is the placeholder."),
            APIItem("`TextField(_:value:format:)`", "Edits a number, date, or currency, parsed with a format style."),
            APIItem("`axis: .vertical`", "Lets the field grow onto new lines as people type."),
            APIItem("`.textFieldStyle(_:)`", "`.roundedBorder` draws a border; `.plain` draws nothing."),
            APIItem("`.keyboardType(_:)`", "The keyboard layout, such as `.emailAddress` or `.decimalPad`."),
            APIItem("`.textContentType(_:)`", "What the field holds, so iOS can offer AutoFill."),
            APIItem("`.autocorrectionDisabled()`", "Turns off autocorrect. Pair it with `.textInputAutocapitalization(.never)`."),
            APIItem("`.onSubmit { }`", "Runs when people tap Return."),
        ],
        guidelines: [
            Guideline(
                "Keep a visible label once people start typing.",
                "The placeholder disappears with the first keystroke. A label beside or above the field still says what each value is.",
                good: "Labels stay put after the fields are filled.",
                bad: "Filled fields with no labels leave people guessing."
            ) {
                TextFieldLabelSample(showsLabels: true)
            } bad: {
                TextFieldLabelSample(showsLabels: false)
            },
            Guideline(
                "Show the keyboard that fits the content.",
                "An email field with `.emailAddress` puts @ on the first screen, and a price with `.decimalPad` shows only digits. It saves taps and typos."
            ),
            Guideline(
                "Validate at the right moment.",
                "Check an email address when people leave the field, not on the first letter. Show the problem right under the field, in words."
            ),
            Guideline(
                "Size the field to the text you expect.",
                "A short field for a ZIP code and a wide one for a street address tell people how much to type.",
                good: "A short field for a five-digit ZIP code.",
                bad: "The ZIP field is as wide as City."
            ) {
                TextFieldWidthSample(isSized: true)
            } bad: {
                TextFieldWidthSample(isSized: false)
            },
        ]
    ) {
        VStack(alignment: .leading, spacing: 6) {
            Text("Email")
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)
            HStack(spacing: 8) {
                Image(systemName: "envelope")
                    .foregroundStyle(.secondary)
                TextField("Email", text: .constant("sam@example.com"))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(.fill.tertiary, in: .capsule)
        }
        .frame(width: 210)
    } content: { page in
        TextFieldDemo(page: page)
    }
}

private struct TextFieldConfig {
    var placeholder = "Email"
    var text = ""
    var style: TFStyleOption = .roundedBorder
    var axis: TFAxisOption = .horizontal
    var lineLimit: TFLineLimitOption = .range
    var plainInput = true
    var isDisabled = false
}

private struct TextFieldDemo: View {
    let page: ComponentPage

    var body: some View {
        DemoPage(
            page: page,
            initial: TextFieldConfig(),
            previewHeight: 200,
            usage: """
            @State private var name = ""

            TextField("Name", text: $name)
                .textFieldStyle(.roundedBorder)
            """,
            usageNote: Aside(.important, "Outside a `Form` or `List`, the default style has no border, so the field can look invisible. Add `.textFieldStyle(.roundedBorder)` or a background of your own.")
        ) { $config in
            VStack(alignment: .leading, spacing: 14) {
                field($config)
                    .frame(maxWidth: 320)
                HStack(spacing: 4) {
                    Text("text =")
                    Text(swiftString(config.text))
                        .lineLimit(1)
                        .truncationMode(.middle)
                }
                .font(.footnote.monospaced())
                .foregroundStyle(.secondary)
            }
            .frame(maxWidth: 320)
        } controls: { $config in
            Section("Content") {
                TextField("Placeholder", text: $config.placeholder)
                OptionPicker("Axis", selection: $config.axis)
                if config.axis == .vertical {
                    OptionPicker("Line limit", selection: $config.lineLimit)
                }
            }
            Section("Appearance") {
                OptionPicker("Style", selection: $config.style)
                Toggle("No autocorrect or caps", isOn: $config.plainInput)
                Toggle("Disabled", isOn: $config.isDisabled)
            }
        } code: { config in
            var lines = ["@State private var text = \"\"", ""]
            let axis = config.axis == .vertical ? ", axis: .vertical" : ""
            lines.append("TextField(\(swiftString(config.placeholder)), text: $text\(axis))")
            if config.style != .automatic {
                lines.append("    .textFieldStyle(\(config.style.label))")
            }
            if config.axis == .vertical, let limit = config.lineLimit.code {
                lines.append("    .lineLimit(\(limit))")
            }
            if config.plainInput {
                lines.append("    .textInputAutocapitalization(.never)")
                lines.append("    .autocorrectionDisabled()")
            }
            if config.isDisabled {
                lines.append("    .disabled(true)")
            }
            return lines.joined(separator: "\n")
        } examples: {
            ExampleCard(
                title: "In a Form",
                caption: "Inside a `Form`, fields need no style. Wrap one in `LabeledContent` to show a label beside it.",
                code: """
                @State private var name = "Taylor"
                @State private var city = ""

                Form {
                    TextField("Name", text: $name)
                    LabeledContent("City") {
                        TextField("Required", text: $city)
                            .multilineTextAlignment(.trailing)
                    }
                }
                """
            ) {
                FormFieldExample()
            }
            ExampleCard(
                title: "Email with validation",
                caption: "Set `.keyboardType` and `.textContentType` for email, then show a message under the field when the text is wrong.",
                code: """
                @State private var email = ""

                var isValid: Bool {
                    email.isEmpty || email.contains("@")
                }

                VStack(alignment: .leading, spacing: 6) {
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .textContentType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .padding(10)
                        .overlay {
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(isValid ? Color.secondary.opacity(0.4) : .red)
                        }
                    if !isValid {
                        Text("Enter a valid email address.")
                            .font(.footnote)
                            .foregroundStyle(.red)
                    }
                }
                """,
                aside: Aside(.important, "Turn off autocorrect and capitalization for emails, usernames, and codes. Otherwise iOS “fixes” what people type.")
            ) {
                ValidationExample()
            }
            ExampleCard(
                title: "Numbers and currency",
                caption: "Use `TextField(_:value:format:)` to bind a `Double`; SwiftUI parses and formats it for the person's locale.",
                code: """
                @State private var amount = 42.5

                TextField("Amount", value: $amount, format: .currency(code: "USD"))
                    .keyboardType(.decimalPad)
                    .textFieldStyle(.roundedBorder)
                """,
                aside: Aside(.note, "Unlike a `String` binding, the value only updates when editing ends and the text parses.")
            ) {
                CurrencyFieldExample()
            }
            ExampleCard(
                title: "Search field with clear button",
                caption: "Put a plain `TextField` in an `HStack` with an icon, a clear `Button`, and a background.",
                code: """
                @State private var query = ""

                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)
                    TextField("Search", text: $query)
                    if !query.isEmpty {
                        Button("Clear", systemImage: "xmark.circle.fill") {
                            query = ""
                        }
                        .labelStyle(.iconOnly)
                        .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(.fill.tertiary, in: .capsule)
                """,
                aside: Aside(.note, "To search a list in the navigation bar, use [searchable](catalog://searchable) instead. It gives you this field, Cancel, and suggestions for free.")
            ) {
                SearchFieldExample()
            }
        }
    }

    @ViewBuilder
    private func field(_ config: Binding<TextFieldConfig>) -> some View {
        let c = config.wrappedValue
        Group {
            if c.axis == .vertical {
                TextField(c.placeholder, text: config.text, axis: .vertical)
                    .tfLineLimit(c.lineLimit)
            } else {
                TextField(c.placeholder, text: config.text)
            }
        }
        .tfStyled(c.style)
        .textInputAutocapitalization(c.plainInput ? .never : nil)
        .autocorrectionDisabled(c.plainInput)
        .disabled(c.isDisabled)
    }
}

// MARK: - Examples

private struct CurrencyFieldExample: View {
    @State private var amount = 42.5

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            TextField("Amount", value: $amount, format: .currency(code: "USD"))
                .keyboardType(.decimalPad)
                .textFieldStyle(.roundedBorder)
            Text("amount = \(swiftNumber(amount))")
                .font(.footnote.monospaced())
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: 260)
    }
}

private struct SearchFieldExample: View {
    @State private var query = "Coffee"

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            TextField("Search", text: $query)
            if !query.isEmpty {
                Button("Clear", systemImage: "xmark.circle.fill") {
                    query = ""
                }
                .labelStyle(.iconOnly)
                .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(.fill.tertiary, in: .capsule)
        .frame(maxWidth: 300)
    }
}

private struct ValidationExample: View {
    @State private var email = "taylor"

    private var isValid: Bool {
        email.isEmpty || email.contains("@")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            TextField("Email", text: $email)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .padding(10)
                .overlay {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isValid ? Color.secondary.opacity(0.4) : .red)
                }
            if !isValid {
                Text("Enter a valid email address.")
                    .font(.footnote)
                    .foregroundStyle(.red)
            }
        }
        .frame(maxWidth: 300)
        .animation(.snappy, value: isValid)
    }
}

private struct FormFieldExample: View {
    @State private var name = "Taylor"
    @State private var city = ""

    var body: some View {
        Form {
            TextField("Name", text: $name)
            LabeledContent("City") {
                TextField("Required", text: $city)
                    .multilineTextAlignment(.trailing)
            }
        }
        .scrollDisabled(true)
        .contentMargins(.vertical, 8, for: .scrollContent)
        .frame(height: 135)
        .clipShape(.rect(cornerRadius: 12))
    }
}

// MARK: - Guideline samples

/// Two filled fields, with or without labels above them.
private struct TextFieldLabelSample: View {
    let showsLabels: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            field("First name", value: "Taylor")
            field("Phone", value: "555 0134")
        }
        .frame(width: 220)
    }

    private func field(_ label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            if showsLabels {
                Text(label)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
            }
            TextField(label, text: .constant(value))
                .textFieldStyle(.roundedBorder)
        }
    }
}

/// An address row whose field widths do or don't match the text.
private struct TextFieldWidthSample: View {
    let isSized: Bool

    var body: some View {
        VStack(spacing: 8) {
            TextField("Street address", text: .constant(""))
            HStack(spacing: 8) {
                TextField("City", text: .constant(""))
                TextField("ZIP", text: .constant(""))
                    .frame(width: isSized ? 70 : nil)
            }
        }
        .textFieldStyle(.roundedBorder)
        .frame(width: 240)
    }
}

// MARK: - Options

private enum TFStyleOption: DemoOption {
    case automatic, roundedBorder, plain

    var label: String {
        switch self {
        case .automatic: ".automatic"
        case .roundedBorder: ".roundedBorder"
        case .plain: ".plain"
        }
    }
}

private enum TFAxisOption: DemoOption {
    case horizontal, vertical

    var label: String {
        switch self {
        case .horizontal: "Single line"
        case .vertical: "Grows (.vertical)"
        }
    }
}

private enum TFLineLimitOption: DemoOption {
    case none, three, range

    var label: String {
        switch self {
        case .none: "None"
        case .three: "3"
        case .range: "2...5"
        }
    }

    var code: String? {
        switch self {
        case .none: nil
        case .three: "3"
        case .range: "2...5"
        }
    }
}

private extension View {
    @ViewBuilder
    func tfStyled(_ style: TFStyleOption) -> some View {
        switch style {
        case .automatic: textFieldStyle(.automatic)
        case .roundedBorder: textFieldStyle(.roundedBorder)
        case .plain: textFieldStyle(.plain)
        }
    }

    @ViewBuilder
    func tfLineLimit(_ limit: TFLineLimitOption) -> some View {
        switch limit {
        case .none: self
        case .three: lineLimit(3)
        case .range: lineLimit(2...5)
        }
    }
}
