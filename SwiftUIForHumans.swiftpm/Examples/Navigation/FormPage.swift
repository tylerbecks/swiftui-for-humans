import SwiftUI

extension ComponentPage {
    static let form = ComponentPage(
        id: "form",
        title: "Form",
        summary: "A container that lays out controls as grouped rows, like the Settings app.",
        category: .lists,
        symbol: "list.bullet.rectangle.portrait",
        availability: ["iOS 13.0+", "macOS 10.15+", "visionOS 1.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/form",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/entering-data",
        aliases: ["settings", "preferences", "fieldset", "form element", "input group", "grouped table", "LabeledContent", "key value"],
        related: ["list", "toggle", "picker", "settings-screen"],
        notes: [
            "**A form doesn't submit anything.** Each control writes to its own `@State` as it changes, so there's no `onSubmit` for the whole form. Add a Save button if you need one.",
            "**Show read-only values with `LabeledContent`.** It puts a label on the left and a value on the right, like “Version 2.1” in Settings.",
        ],
        about: """
        `Form` is a `List` that restyles the controls inside it for data entry: toggles get a trailing switch, pickers become menu rows, and buttons become tappable rows. You get the grouped Settings look without styling anything.

        Use it for settings, sign-up, and edit screens. For rows of content people browse, use [List](catalog://list).
        """,
        composition: """
        Form
        ├── Section("Header")
        │   ├── TextField
        │   ├── Toggle
        │   └── Picker
        └── Section
            ├── LabeledContent
            └── footer: Text
        """,
        api: [
            APIItem("`Form { }`", "Grouped rows that style the controls inside."),
            APIItem("`Section(_:content:)`", "A group of rows with a header."),
            APIItem("`Section { } footer: { }`", "Adds a short explanation under a group."),
            APIItem("`LabeledContent(_:value:)`", "A read-only row: label left, value right."),
            APIItem("`.pickerStyle(_:)`", "`.menu` by default; `.inline` lists options as rows."),
            APIItem("`.disabled(_:)`", "Dims a row, a section, or the whole form."),
        ],
        guidelines: [
            Guideline(
                "Offer choices instead of typing.",
                "Picking from a short list is faster than typing and can't go wrong. Use a `Picker`, `Toggle`, or `Stepper` when the answers are known.",
                good: "A picker offers the valid sizes.",
                bad: "A text field makes people type and guess."
            ) {
                FormGuidelineSample(usesPicker: true)
            } bad: {
                FormGuidelineSample(usesPicker: false)
            },
            Guideline(
                "Validate as people type.",
                "Show problems right away and keep the Continue button disabled until the required fields are filled, so nobody has to go back and fix things."
            ),
            Guideline(
                "Explain settings in a section footer.",
                "A sentence under a group tells people what a switch does before they change it. Keep the row labels themselves short."
            ),
            Guideline(
                "Use `SecureField` for passwords, and never prefill one.",
                "It hides each character as people type. Prefilling a password exposes it to anyone holding the phone."
            ),
        ]
    ) {
        Form {
            Section {
                Toggle("Wi-Fi", isOn: .constant(true))
                LabeledContent("Network", value: "Home")
            }
        }
        .scrollDisabled(true)
        .scrollEdgeEffectHidden(true, for: .all)
        .frame(width: 280, height: 170)
        .scaleEffect(0.85)
    } content: { page in
        FormDemo(page: page)
    }
}

private struct FormConfig {
    var headers = true
    var footers = true
    var labeledContent = true
    var pickerStyle: FormPickerOption = .menu
    var disabled = false
    // Live values the form edits.
    var name = "Taylor"
    var notifications = true
    var volume = 0.6
    var theme = "System"
    var reminders = 2
}

private struct FormDemo: View {
    let page: ComponentPage

    var body: some View {
        DemoPage(
            page: page,
            initial: FormConfig(),
            previewHeight: 560,
            usage: """
            @State private var name = ""
            @State private var notifications = true

            Form {
                Section("Profile") {
                    TextField("Name", text: $name)
                    Toggle("Notifications", isOn: $notifications)
                }
                Section("About") {
                    LabeledContent("Version", value: "2.1")
                }
            }
            """,
            usageNote: Aside(.note, "On iPhone, a `Form` fills the screen like a `List`. Wrap it in a `NavigationStack` to give it a title.")
        ) { $config in
            FormPreview(config: $config)
                .frame(maxWidth: 420)
                .frame(height: 500)
                .clipShape(.rect(cornerRadius: 14))
                .overlay {
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(.separator)
                }
        } controls: { $config in
            Section("Sections") {
                Toggle("Headers", isOn: $config.headers)
                Toggle("Footers", isOn: $config.footers)
            }
            Section("Rows") {
                Toggle("LabeledContent row", isOn: $config.labeledContent)
                OptionPicker("Picker style", selection: $config.pickerStyle)
                Toggle("Disable the form", isOn: $config.disabled)
            }
        } code: { config in
            code(for: config)
        } examples: {
            FormExamples()
        }
    }

    private func code(for config: FormConfig) -> String {
        var lines = [
            "@State private var name = \"Taylor\"",
            "@State private var notifications = true",
            "@State private var volume = 0.6",
            "@State private var theme = \"System\"",
            "@State private var reminders = 2",
            "",
            "Form {",
        ]
        func section(_ header: String, _ footer: String, _ rows: [String]) {
            switch (config.headers, config.footers) {
            case (true, true):
                lines.append("    Section {")
            case (true, false):
                lines.append("    Section(\"\(header)\") {")
            case (false, _):
                lines.append("    Section {")
            }
            lines += rows.map { "        " + $0 }
            if config.headers && config.footers {
                lines.append("    } header: {")
                lines.append("        Text(\"\(header)\")")
                lines.append("    } footer: {")
                lines.append("        Text(\"\(footer)\")")
            } else if config.footers {
                lines.append("    } footer: {")
                lines.append("        Text(\"\(footer)\")")
            }
            lines.append("    }")
        }
        section("Profile", "Shown to people you share with.", ["TextField(\"Name\", text: $name)"])
        var pickerRows = [
            "Toggle(\"Notifications\", isOn: $notifications)",
            "Picker(\"Theme\", selection: $theme) {",
            "    ForEach([\"System\", \"Light\", \"Dark\"], id: \\.self) { Text($0) }",
            "}",
        ]
        if config.pickerStyle != .menu {
            pickerRows.append(".pickerStyle(\(config.pickerStyle.label))")
        }
        pickerRows += [
            "Stepper(\"Reminders: \\(reminders)\", value: $reminders, in: 0...5)",
            "Slider(value: $volume) {",
            "    Text(\"Volume\")",
            "} minimumValueLabel: {",
            "    Image(systemName: \"speaker\")",
            "} maximumValueLabel: {",
            "    Image(systemName: \"speaker.wave.3\")",
            "}",
        ]
        section("Preferences", "Reminders repeat every morning at 9:00.", pickerRows)
        if config.labeledContent {
            section("About", "Read-only rows use LabeledContent.", [
                "LabeledContent(\"Version\", value: \"2.1\")",
                "LabeledContent(\"Storage\") {",
                "    Text(\"12.4 GB\")",
                "}",
            ])
        }
        lines.append("}")
        if config.disabled {
            lines.append(".disabled(true)")
        }
        return lines.joined(separator: "\n")
    }
}

private struct FormPreview: View {
    @Binding var config: FormConfig

    var body: some View {
        Form {
            section("Profile", "Shown to people you share with.") {
                TextField("Name", text: $config.name)
            }
            section("Preferences", "Reminders repeat every morning at 9:00.") {
                Toggle("Notifications", isOn: $config.notifications)
                Picker("Theme", selection: $config.theme) {
                    ForEach(["System", "Light", "Dark"], id: \.self) { Text($0) }
                }
                .formPickerStyle(config.pickerStyle)
                Stepper("Reminders: \(config.reminders)", value: $config.reminders, in: 0...5)
                Slider(value: $config.volume) {
                    Text("Volume")
                } minimumValueLabel: {
                    Image(systemName: "speaker")
                } maximumValueLabel: {
                    Image(systemName: "speaker.wave.3")
                }
            }
            if config.labeledContent {
                section("About", "Read-only rows use LabeledContent.") {
                    LabeledContent("Version", value: "2.1")
                    LabeledContent("Storage") {
                        Text("12.4 GB")
                    }
                }
            }
        }
        .disabled(config.disabled)
        .animation(.default, value: config.labeledContent)
        .animation(.default, value: config.pickerStyle)
    }

    @ViewBuilder
    private func section<Rows: View>(_ header: String, _ footer: String, @ViewBuilder rows: () -> Rows) -> some View {
        Section {
            rows()
        } header: {
            if config.headers { Text(header) }
        } footer: {
            if config.footers { Text(footer) }
        }
    }
}

// MARK: - Examples

private struct FormExamples: View {
    @State private var email = ""
    @State private var agreed = false
    @State private var plan = "Monthly"

    var body: some View {
        ExampleCard(
            title: "Sign-up form with validation",
            caption: "Keep the submit `Button` disabled with `.disabled(_:)` until the input is valid.",
            code: """
            @State private var email = ""
            @State private var agreed = false

            Form {
                Section("Account") {
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                    Toggle("I agree to the terms", isOn: $agreed)
                }
                Section {
                    Button("Create Account") {
                        // Submit
                    }
                    .disabled(!email.contains("@") || !agreed)
                }
            }
            """,
            minHeight: 260,
            aside: Aside(.note, "A `Button` in a form is just another row, drawn as tinted text.")
        ) {
            Form {
                Section("Account") {
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                    Toggle("I agree to the terms", isOn: $agreed)
                }
                Section {
                    Button("Create Account") {}
                        .disabled(!email.contains("@") || !agreed)
                }
            }
            .frame(height: 250)
            .scrollDisabled(true)
        }

        ExampleCard(
            title: "Inline picker",
            caption: "Use `.pickerStyle(.inline)` to show each option as a row with a checkmark, like Settings.",
            code: """
            @State private var plan = "Monthly"

            Form {
                Picker("Plan", selection: $plan) {
                    ForEach(["Monthly", "Yearly", "Lifetime"], id: \\.self) {
                        Text($0)
                    }
                }
                .pickerStyle(.inline)
            }
            """,
            minHeight: 230
        ) {
            Form {
                Picker("Plan", selection: $plan) {
                    ForEach(["Monthly", "Yearly", "Lifetime"], id: \.self) {
                        Text($0)
                    }
                }
                .pickerStyle(.inline)
            }
            .frame(height: 230)
            .scrollDisabled(true)
        }

        ExampleCard(
            title: "Rows that open other screens",
            caption: "Use a `NavigationLink` row with `LabeledContent` to show the current value beside a chevron.",
            code: """
            NavigationStack {
                Form {
                    NavigationLink {
                        Text("Language settings")
                    } label: {
                        LabeledContent("Language", value: "English")
                    }
                    NavigationLink("Privacy") {
                        Text("Privacy settings")
                    }
                }
                .navigationTitle("Settings")
            }
            """,
            minHeight: 400,
            aside: Aside(.important, "The chevron and the push only work inside a `NavigationStack`.")
        ) {
            FormPushPreview { open in
                Form {
                    FormLinkRow(action: open) {
                        LabeledContent("Language", value: "English")
                    }
                    FormLinkRow(action: open) {
                        Text("Privacy")
                    }
                }
                .navigationTitle("Settings")
            } screen: {
                NavigationStack {
                    Form {
                        NavigationLink {
                            Text("Language settings")
                        } label: {
                            LabeledContent("Language", value: "English")
                        }
                        NavigationLink("Privacy") {
                            Text("Privacy settings")
                        }
                    }
                    .navigationTitle("Settings")
                }
            }
        }
    }
}

// MARK: - Options

private enum FormPickerOption: DemoOption {
    case menu, inline, segmented

    var label: String {
        switch self {
        case .menu: ".menu"
        case .inline: ".inline"
        case .segmented: ".segmented"
        }
    }
}

private extension View {
    @ViewBuilder
    func formPickerStyle(_ style: FormPickerOption) -> some View {
        switch style {
        case .menu: pickerStyle(.menu)
        case .inline: pickerStyle(.inline)
        case .segmented: pickerStyle(.segmented)
        }
    }
}

// MARK: - Push preview

/// A row that looks like a `NavigationLink` but runs an action instead.
private struct FormLinkRow<Label: View>: View {
    let action: () -> Void
    @ViewBuilder let label: Label

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                label
                    .frame(maxWidth: .infinity, alignment: .leading)
                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
            .contentShape(.rect)
        }
        .tint(Color.primary)
    }
}

/// Shows a screen live inside a phone frame, plus the real stack full screen.
/// Pushes can't run inside the frame: a `NavigationLink` there would push onto
/// the catalog's own stack. A full-screen cover starts a fresh navigation
/// context, exactly like the root of a real app.
private struct FormPushPreview<Inline: View, Screen: View>: View {
    @ViewBuilder let inline: (_ open: @escaping () -> Void) -> Inline
    @ViewBuilder let screen: () -> Screen
    @State private var isPresented = false

    var body: some View {
        VStack(spacing: 14) {
            PhoneScreen(height: 300) {
                inline { isPresented = true }
            }
            Button("Try It Full Screen", systemImage: "arrow.up.left.and.arrow.down.right") {
                isPresented = true
            }
            .buttonStyle(.borderedProminent)
        }
        .fullScreenCover(isPresented: $isPresented) {
            screen()
                .overlay(alignment: .bottom) {
                    Button("Close Demo", systemImage: "xmark") {
                        isPresented = false
                    }
                    .buttonStyle(.glassProminent)
                    .controlSize(.large)
                    .padding(.bottom, 8)
                }
        }
    }
}
// MARK: - Guideline samples

/// A one-row form asking for a size, as a picker or as free text.
private struct FormGuidelineSample: View {
    let usesPicker: Bool
    @State private var size = "Medium"
    @State private var typed = ""

    var body: some View {
        Form {
            if usesPicker {
                Picker("Size", selection: $size) {
                    ForEach(["Small", "Medium", "Large"], id: \.self) { Text($0) }
                }
            } else {
                TextField("Size (S, M, or L)", text: $typed)
            }
        }
        .scrollDisabled(true)
        .frame(width: 260, height: 110)
    }
}
