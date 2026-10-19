import SwiftUI

extension ComponentPage {
    static let form = ComponentPage(
        id: "form",
        title: "Form",
        summary: "Groups labeled controls for settings and data entry, in Mac columns or System Settings rows.",
        category: .layout,
        symbol: "list.bullet.rectangle",
        availability: ["macOS 10.15+", "formStyle macOS 13.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/form",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/settings",
        aliases: [
            "form", "settings form", "preferences", "formStyle", "columns", "grouped", "LabeledContent",
            "Section", "label column", "System Settings", "<form>", "fieldset", "NSGridView", "inspector form",
        ],
        related: ["labeled-content", "toggle", "picker", "group-box", "settings-scene"],
        notes: [
            "**Controls change inside a `Form`.** In a grouped form, a toggle becomes a switch and a picker sits at the trailing edge of its row. Put the same controls in a `VStack` and they keep their plain look.",
            "**A grouped form scrolls by itself.** It's a scroll view, like `List`. The columns style doesn't scroll, so wrap a long one in a `ScrollView` or split it into panes.",
        ],
        about: "`Form` arranges labeled controls the Mac way. With the default `.columns` style, labels line up right-aligned in one column and controls left-aligned in the next, like classic Mac settings windows. With `.grouped`, rows sit in rounded sections with the label on the left and the control on the right, like System Settings.\n\nUse it for settings, inspectors, and any data entry. Each control's own title becomes its label, so you rarely write labels by hand.",
        composition: """
        Form
        ├── Section("Editor")
        │   ├── TextField
        │   ├── Picker
        │   └── Toggle
        └── Section("About")
            └── LabeledContent
        """,
        api: [
            APIItem("`Form { }`", "Lays out labeled controls for data entry."),
            APIItem("`.formStyle(.columns)`", "The Mac default: right-aligned labels."),
            APIItem("`.formStyle(.grouped)`", "Rounded sections, like System Settings."),
            APIItem("`Section(_:content:)`", "A titled group of rows."),
            APIItem("`LabeledContent(_:value:)`", "A read-only row with a label."),
            APIItem("`LabeledContent { } label: { }`", "Labels any view, like a custom control."),
        ],
        guidelines: [
            Guideline(
                "Group related settings into sections.",
                "A few small sections are faster to scan than one long run of rows, and a header tells people what each group is for.",
                good: "Two sections, each with a clear job.",
                bad: "Every row in one long group."
            ) {
                Form {
                    Section("Editor") {
                        Toggle("Line numbers", isOn: .constant(true))
                        Toggle("Wrap lines", isOn: .constant(false))
                    }
                    Section("Files") {
                        Toggle("Autosave", isOn: .constant(true))
                    }
                }
                .formStyle(.grouped)
                .scrollDisabled(true)
                .frame(width: 280, height: 230)
            } bad: {
                Form {
                    Section {
                        Toggle("Line numbers", isOn: .constant(true))
                        Toggle("Wrap lines", isOn: .constant(false))
                        Toggle("Autosave", isOn: .constant(true))
                    }
                }
                .formStyle(.grouped)
                .scrollDisabled(true)
                .frame(width: 280, height: 230)
            },
            Guideline(
                "Offer as few settings as you can.",
                "Pick good defaults so most people never need to change anything. Every extra option makes the one people want harder to find."
            ),
            Guideline(
                "Keep options for the current task in its window.",
                "Choices like sorting or showing a column belong next to the content they change, not in a settings form people have to go and open."
            ),
        ]
    ) {
        Form {
            Toggle("Show preview", isOn: .constant(true))
            Picker("Theme", selection: .constant(1)) {
                Text("Light").tag(1)
            }
        }
        .formStyle(.columns)
        .font(.caption)
        .frame(width: 170)
    } content: { page in
        MacFormDemo(page: page)
    }
}

// MARK: - Demo

private struct MacFormConfig {
    var style: FormStyleOption = .automatic
    var hasSections = false
    var name = "Untitled"
    var theme = "System"
    var showsLineNumbers = true
}

private struct MacFormDemo: View {
    let page: ComponentPage

    var body: some View {
        DemoPage(
            page: page,
            initial: MacFormConfig(),
            usage: """
            @State private var name = ""
            @State private var showsLineNumbers = true

            Form {
                TextField("Name", text: $name)
                Toggle("Show line numbers", isOn: $showsLineNumbers)
                LabeledContent("Version", value: "2.4")
            }
            """,
            usageNote: Aside(.note, "On the Mac, a plain `Form` uses `.columns`, not the grouped look of iPhone. Add `.formStyle(.grouped)` when you want rows like System Settings.")
        ) { $config in
            FormPreview(config: $config)
        } controls: { $config in
            Section("Appearance") {
                OptionPicker("Style", selection: $config.style)
                Toggle("Sections", isOn: $config.hasSections)
            }
        } code: { config in
            var lines = [
                "@State private var name = \(swiftString(config.name))",
                "@State private var theme = \(swiftString(config.theme))",
                "@State private var showsLineNumbers = \(config.showsLineNumbers)",
                "",
                "Form {",
            ]
            let rows = [
                "TextField(\"Name\", text: $name)",
                "Picker(\"Theme\", selection: $theme) {",
                "    ForEach([\"System\", \"Light\", \"Dark\"], id: \\.self) { Text($0) }",
                "}",
                "Toggle(\"Show line numbers\", isOn: $showsLineNumbers)",
            ]
            if config.hasSections {
                lines.append("    Section(\"Editor\") {")
                lines += rows.map { "        " + $0 }
                lines.append("    }")
                lines.append("    Section(\"About\") {")
                lines.append("        LabeledContent(\"Version\", value: \"2.4\")")
                lines.append("    }")
            } else {
                lines += rows.map { "    " + $0 }
                lines.append("    LabeledContent(\"Version\", value: \"2.4\")")
            }
            lines.append("}")
            if config.style != .automatic {
                lines.append(".formStyle(\(config.style.label))")
            }
            return lines.joined(separator: "\n")
        } examples: {
            MacFormExamples()
        }
    }
}

private struct FormPreview: View {
    @Binding var config: MacFormConfig

    var body: some View {
        styled(
            Form {
                if config.hasSections {
                    Section("Editor") { rows }
                    Section("About") { version }
                } else {
                    rows
                    version
                }
            }
        )
        .scrollDisabled(true)
        .frame(width: 400, height: config.style == .grouped ? (config.hasSections ? 290 : 220) : nil)
    }

    @ViewBuilder private var rows: some View {
        TextField("Name", text: $config.name)
        Picker("Theme", selection: $config.theme) {
            ForEach(["System", "Light", "Dark"], id: \.self) { Text($0) }
        }
        Toggle("Show line numbers", isOn: $config.showsLineNumbers)
    }

    private var version: some View {
        LabeledContent("Version", value: "2.4")
    }

    @ViewBuilder
    private func styled(_ form: some View) -> some View {
        switch config.style {
        case .automatic: form.formStyle(.automatic)
        case .columns: form.formStyle(.columns)
        case .grouped: form.formStyle(.grouped)
        }
    }
}

// MARK: - Examples

private struct MacFormExamples: View {
    @State private var startsWith = "Last session"
    @State private var fontSize = 13.0
    @State private var opensInTabs = true

    @State private var syncsMail = true
    @State private var syncsNotes = false
    @State private var keepsDays = 30

    @State private var refreshesStatus = true
    @State private var fetchesRemote = false
    @State private var addsFiles = true

    var body: some View {
        ExampleCard(
            title: "A classic Mac columns form",
            caption: "`.formStyle(.columns)` right-aligns each label against its control, and by Mac convention the labels end with a colon.",
            code: """
            @State private var startsWith = "Last session"
            @State private var fontSize = 13.0
            @State private var opensInTabs = true

            Form {
                Picker("Start with:", selection: $startsWith) {
                    Text("Last session").tag("Last session")
                    Text("New document").tag("New document")
                }
                .pickerStyle(.radioGroup)
                Stepper("Font size: \\(Int(fontSize)) pt", value: $fontSize, in: 9...24)
                Toggle("Open documents in tabs", isOn: $opensInTabs)
            }
            .formStyle(.columns)
            """,
            minHeight: 170
        ) {
            Form {
                Picker("Start with:", selection: $startsWith) {
                    Text("Last session").tag("Last session")
                    Text("New document").tag("New document")
                }
                .pickerStyle(.radioGroup)
                Stepper("Font size: \(Int(fontSize)) pt", value: $fontSize, in: 9...24)
                Toggle("Open documents in tabs", isOn: $opensInTabs)
            }
            .formStyle(.columns)
        }

        ExampleCard(
            title: "Grouped, like System Settings",
            caption: "`.formStyle(.grouped)` puts each `Section` in a rounded group, with its header above and an optional footer below.",
            code: """
            @State private var syncsMail = true
            @State private var syncsNotes = false
            @State private var keepsDays = 30

            Form {
                Section("Sync") {
                    Toggle("Mail", isOn: $syncsMail)
                    Toggle("Notes", isOn: $syncsNotes)
                }
                Section {
                    Picker("Keep deleted items", selection: $keepsDays) {
                        Text("7 days").tag(7)
                        Text("30 days").tag(30)
                    }
                } footer: {
                    Text("Deleted items are removed for good after this.")
                }
            }
            .formStyle(.grouped)
            """,
            minHeight: 230
        ) {
            Form {
                Section("Sync") {
                    Toggle("Mail", isOn: $syncsMail)
                    Toggle("Notes", isOn: $syncsNotes)
                }
                Section {
                    Picker("Keep deleted items", selection: $keepsDays) {
                        Text("7 days").tag(7)
                        Text("30 days").tag(30)
                    }
                } footer: {
                    Text("Deleted items are removed for good after this.")
                }
            }
            .formStyle(.grouped)
            .scrollDisabled(true)
            .frame(width: 400, height: 210)
        }

        ExampleCard(
            title: "Read-only rows with LabeledContent",
            caption: "`LabeledContent` shows a read-only value beside its label, and a `format:` handles numbers and byte counts.",
            code: """
            Form {
                LabeledContent("Model", value: "Mac mini")
                LabeledContent("Serial number", value: "C02XL0GHJGH5")
                LabeledContent("Storage", value: 512_000_000_000, format: .byteCount(style: .file))
            }
            .formStyle(.grouped)
            """,
            minHeight: 170,
            aside: Aside(.note, "SwiftUI makes the value text selectable where it can, so people can copy a serial number.")
        ) {
            Form {
                LabeledContent("Model", value: "Mac mini")
                LabeledContent("Serial number", value: "C02XL0GHJGH5")
                LabeledContent("Storage", value: 512_000_000_000, format: .byteCount(style: .file))
            }
            .formStyle(.grouped)
            .scrollDisabled(true)
            .frame(width: 400, height: 140)
        }

        ExampleCard(
            title: "Several checkboxes under one label",
            caption: "Toggles inside `LabeledContent` list under one label and stay checkboxes, even in a grouped form.",
            code: """
            @State private var refreshesStatus = true
            @State private var fetchesRemote = false
            @State private var addsFiles = true

            Form {
                LabeledContent("Source control") {
                    VStack(alignment: .leading) {
                        Toggle("Refresh status automatically", isOn: $refreshesStatus)
                        Toggle("Fetch remote changes", isOn: $fetchesRemote)
                        Toggle("Add new files automatically", isOn: $addsFiles)
                    }
                }
            }
            .formStyle(.grouped)
            """,
            minHeight: 150
        ) {
            Form {
                LabeledContent("Source control") {
                    VStack(alignment: .leading) {
                        Toggle("Refresh status automatically", isOn: $refreshesStatus)
                        Toggle("Fetch remote changes", isOn: $fetchesRemote)
                        Toggle("Add new files automatically", isOn: $addsFiles)
                    }
                }
            }
            .formStyle(.grouped)
            .scrollDisabled(true)
            .frame(width: 420, height: 120)
        }
    }
}

// MARK: - Options

private enum FormStyleOption: DemoOption {
    case automatic, columns, grouped

    var label: String {
        switch self {
        case .automatic: ".automatic"
        case .columns: ".columns"
        case .grouped: ".grouped"
        }
    }
}
