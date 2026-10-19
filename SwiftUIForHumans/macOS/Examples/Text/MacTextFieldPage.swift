import SwiftUI

extension ComponentPage {
    static let textField = ComponentPage(
        id: "text-field",
        title: "TextField",
        summary: "A single-line field for short text, like a name, an email address, or a number.",
        category: .textInput,
        symbol: "character.cursor.ibeam",
        availability: ["macOS 10.15+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/textfield",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/text-fields",
        aliases: ["input", "text input", "<input type=text>", "NSTextField", "text box", "placeholder", "prompt", "onSubmit", "return key", "number field", "formatter", "combo box", "autocomplete", "suggestions"],
        related: ["secure-field", "text-editor", "focus-keyboard", "form", "labeled-content", "search"],
        notes: [
            "**A `String` updates as people type; other values wait.** A field bound with `value:format:` changes its value only when people commit the edit, such as by pressing Return.",
            "**On macOS 27, use `.bordered` for a border.** Pair it with `.textInputBorderShape(_:)`, such as `.capsule`, to choose the shape.",
        ],
        api: [
            APIItem("`TextField(_:text:prompt:)`", "A field bound to a `String`."),
            APIItem("`TextField(_:value:format:)`", "Edits a number, date, or other value."),
            APIItem("`.textFieldStyle(_:)`", "`.roundedBorder`, `.squareBorder`, or `.plain`."),
            APIItem("`.onSubmit { }`", "Runs when people press Return."),
            APIItem("`TextField(_:text:axis:)`", "With `.vertical`, grows onto more lines."),
            APIItem("`.textInputSuggestions { }`", "Completions listed under the field."),
            APIItem("`.textContentType(_:)`", "Tells the system what to suggest."),
        ],
        guidelines: [
            Guideline(
                "Size the field for what goes in it.",
                "The width hints at how much to type. A ZIP code needs a short field; a street address needs a long one.",
                good: "A short field for a short value.",
                bad: "A wide field for five digits."
            ) {
                MacZipSample(width: 70)
            } bad: {
                MacZipSample(width: 200)
            },
            Guideline(
                "Keep a label next to the field.",
                "Placeholder text disappears as soon as people type, so a label beside the field keeps reminding them what it's for.",
                good: "The label stays after typing.",
                bad: "With only a placeholder, the purpose is gone."
            ) {
                HStack {
                    Text("Email:")
                    TextField("Email", text: .constant("jo@example.com"))
                        .labelsHidden()
                        .frame(width: 160)
                }
            } bad: {
                HStack {
                    TextField("Email", text: .constant("jo@example.com"))
                        .labelsHidden()
                        .frame(width: 160)
                }
            },
            Guideline(
                "Check input at the right moment.",
                "Check an email address when people move to the next field. Check a new user name before they move on, so they can fix it right away."
            ),
            Guideline(
                "Let Tab move through fields in order.",
                "People expect focus to go top to bottom and leading to trailing. SwiftUI does this for you; see [Focus & keyboard navigation](catalog://focus-keyboard) when you need more."
            ),
        ]
    ) {
        VStack(spacing: 8) {
            TextField("Name", text: .constant("Jane Appleseed"))
            TextField("Email", text: .constant(""), prompt: Text("Optional"))
        }
        .textFieldStyle(.roundedBorder)
        .frame(width: 170)
    } content: { page in
        MacTextFieldDemo(page: page)
    }
}

private struct MacTextFieldConfig {
    var title = "Name"
    var prompt = "Jane Appleseed"
    var text = ""
    var submitted: String?
    var style: MacTextFieldStyleOption = .automatic
    var size: MacTextControlSize = .regular
    var isDisabled = false
}

private struct MacTextFieldDemo: View {
    let page: ComponentPage

    var body: some View {
        DemoPage(
            page: page,
            initial: MacTextFieldConfig(),
            usage: """
            @State private var name = ""

            TextField("Name", text: $name, prompt: Text("Jane Appleseed"))
                .onSubmit {
                    print("Hello, \\(name)")
                }
            """,
            usageNote: Aside(.note, "The binding updates on every keystroke, like a controlled `<input>`. `onSubmit` runs when people press Return.")
        ) { $config in
            VStack(spacing: 14) {
                TextField(config.title, text: $config.text, prompt: config.prompt.isEmpty ? nil : Text(config.prompt))
                    .macTextFieldStyle(config.style)
                    .controlSize(config.size.size)
                    .disabled(config.isDisabled)
                    .frame(width: 260)
                    .onSubmit {
                        config.submitted = config.text
                    }

                MacTextReadout("text = \(swiftString(config.text))")
                MacTextReadout(config.submitted.map { "onSubmit: \(swiftString($0))" } ?? "Press Return to submit")
            }
        } controls: { $config in
            Section("Content") {
                TextField("Title", text: $config.title)
                TextField("Prompt", text: $config.prompt)
            }
            Section("Appearance") {
                OptionPicker("Style", selection: $config.style)
                OptionPicker("Size", selection: $config.size)
                Toggle("Disabled", isOn: $config.isDisabled)
            }
        } code: { config in
            var lines = ["@State private var text = \"\"", ""]
            if config.prompt.isEmpty {
                lines.append("TextField(\(swiftString(config.title)), text: $text)")
            } else {
                lines.append("TextField(\(swiftString(config.title)), text: $text, prompt: Text(\(swiftString(config.prompt))))")
            }
            if config.style != .automatic {
                lines.append("    .textFieldStyle(\(config.style.label))")
            }
            if config.size != .regular {
                lines.append("    .controlSize(\(config.size.label))")
            }
            if config.isDisabled {
                lines.append("    .disabled(true)")
            }
            return lines.joined(separator: "\n")
        } examples: {
            MacTextFieldExamples()
        }
    }
}

// MARK: - Examples

private struct MacTextFieldExamples: View {
    @State private var name = ""
    @State private var email = ""
    @State private var newTag = ""
    @State private var tags = ["Travel", "Family"]
    @State private var price = 19.99
    @State private var notes = ""
    @State private var venue = ""

    private let venues = ["Apple Park", "Apple Fifth Avenue", "Apple Regent Street"]

    var body: some View {
        ExampleCard(
            title: "Labels in a form",
            caption: "In a `Form`, the Mac puts each field's label at the leading edge and shows the `prompt` inside the field.",
            code: """
            @State private var name = ""
            @State private var email = ""

            Form {
                TextField(text: $name, prompt: Text("Required")) {
                    Text("Name")
                }
                TextField(text: $email, prompt: Text("Optional")) {
                    Text("Email")
                }
            }
            """,
            minHeight: 130
        ) {
            Form {
                TextField(text: $name, prompt: Text("Required")) {
                    Text("Name")
                }
                TextField(text: $email, prompt: Text("Optional")) {
                    Text("Email")
                }
            }
            .frame(width: 320)
        }

        ExampleCard(
            title: "Add an item with Return",
            caption: "Use `.onSubmit` to act when people press Return, then clear the field so they can type the next one.",
            code: """
            @State private var newTag = ""
            @State private var tags = ["Travel", "Family"]

            VStack(alignment: .leading) {
                TextField("New Tag", text: $newTag)
                    .onSubmit {
                        let tag = newTag.trimmingCharacters(in: .whitespaces)
                        guard !tag.isEmpty else { return }
                        tags.append(tag)
                        newTag = ""
                    }
                Text(tags.joined(separator: ", "))
                    .foregroundStyle(.secondary)
            }
            .frame(width: 260)
            """,
            minHeight: 130
        ) {
            VStack(alignment: .leading) {
                TextField("New Tag", text: $newTag)
                    .onSubmit {
                        let tag = newTag.trimmingCharacters(in: .whitespaces)
                        guard !tag.isEmpty else { return }
                        tags.append(tag)
                        newTag = ""
                    }
                Text(tags.joined(separator: ", "))
                    .foregroundStyle(.secondary)
            }
            .frame(width: 260)
        }

        ExampleCard(
            title: "A price with a format",
            caption: "Bind a number with `value:format:`. The field shows it as currency and parses what people type back into a `Double`.",
            code: """
            @State private var price = 19.99

            VStack(alignment: .leading) {
                TextField("Price", value: $price, format: .currency(code: "USD"))
                    .frame(width: 120)
                Text("Three cost \\(price * 3, format: .currency(code: "USD"))")
                    .foregroundStyle(.secondary)
            }
            """,
            minHeight: 130,
            aside: Aside(.important, "The value changes when people press Return, not while they type. Text the format can't parse leaves the value as it was.")
        ) {
            VStack(alignment: .leading) {
                TextField("Price", value: $price, format: .currency(code: "USD"))
                    .frame(width: 120)
                Text("Three cost \(price * 3, format: .currency(code: "USD"))")
                    .foregroundStyle(.secondary)
            }
        }

        ExampleCard(
            title: "A field that grows",
            caption: "Pass `axis: .vertical` and a `.lineLimit` range. The field grows as people type, then scrolls past the last line.",
            code: """
            @State private var notes = ""

            TextField("Notes", text: $notes, axis: .vertical)
                .lineLimit(2...4)
                .frame(width: 280)
            """,
            minHeight: 140
        ) {
            TextField("Notes", text: $notes, axis: .vertical)
                .lineLimit(2...4)
                .frame(width: 280)
        }

        ExampleCard(
            title: "Suggestions as people type",
            caption: "On the Mac, `.textInputSuggestions` lists choices under the field. `.textInputCompletion` sets the text each choice fills in.",
            code: """
            @State private var venue = ""
            let venues = ["Apple Park", "Apple Fifth Avenue", "Apple Regent Street"]

            TextField("Venue", text: $venue)
                .textInputSuggestions {
                    ForEach(venues.filter { $0.localizedStandardContains(venue) }, id: \\.self) { name in
                        Text(name)
                            .textInputCompletion(name)
                    }
                }
                .frame(width: 240)
            """,
            minHeight: 130,
            aside: Aside(.note, "Type “fifth” in the field to see the list. Choosing a suggestion replaces the field's text.")
        ) {
            TextField("Venue", text: $venue)
                .textInputSuggestions {
                    ForEach(venues.filter { $0.localizedStandardContains(venue) }, id: \.self) { name in
                        Text(name)
                            .textInputCompletion(name)
                    }
                }
                .frame(width: 240)
        }
    }
}

/// A labeled ZIP code field for the field-width guideline.
private struct MacZipSample: View {
    let width: CGFloat

    var body: some View {
        HStack {
            Text("ZIP Code:")
            TextField("ZIP Code", text: .constant("95014"))
                .labelsHidden()
                .frame(width: width)
        }
    }
}
