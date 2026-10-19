import SwiftUI

extension ComponentPage {
    static let labeledContent = ComponentPage(
        id: "labeled-content",
        title: "LabeledContent",
        summary: "A label and a value in one row that lines up with the rest of a form.",
        category: .controls,
        symbol: "list.bullet.rectangle",
        availability: ["macOS 13.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/labeledcontent",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/labels",
        aliases: ["label value", "key value", "info row", "property row", "<dl>", "definition list", "get info", "detail row", "form row", "inspector row"],
        related: ["form", "inspector", "toggle", "stepper", "text-label"],
        notes: [
            "**Text values are selectable where possible.** SwiftUI makes a text value selectable, so people can copy a serial number or a path.",
            "**It's a label for anything.** Any view can be the value: a field and a stepper, a group of checkboxes, or a custom view.",
        ],
        api: [
            APIItem("`LabeledContent(_:value:)`", "A read-only text value."),
            APIItem("`LabeledContent(_:value:format:)`", "A value with a format style."),
            APIItem("`LabeledContent(_:content:)`", "Any view as the value."),
            APIItem("`LabeledContent(content:label:)`", "Any view as the label too."),
            APIItem("`.labelsHidden()`", "Hides the label on screen."),
            APIItem("`.labeledContentStyle(_:)`", "Your own layout for every row inside."),
        ],
        guidelines: [
            Guideline(
                "Use it for text people read, not edit.",
                "A label shows a small amount of text. When people should change the value, put a text field or another control in the value instead."
            ),
            Guideline(
                "Let people copy useful details.",
                "Values like an error code, an address, or a version number are worth pasting elsewhere. Keep them as `Text` so they stay selectable."
            ),
            Guideline(
                "Show importance with the system's label colors.",
                "Primary for the main value and secondary for supporting text keep the hierarchy clear in light and dark.",
                good: "The value stands out; the label recedes.",
                bad: "Both in one color, so nothing leads."
            ) {
                MacInfoRow(isLayered: true)
            } bad: {
                MacInfoRow(isLayered: false)
            },
        ]
    ) {
        Form {
            LabeledContent("Version", value: "2.4")
            LabeledContent("Size", value: "18 MB")
        }
        .formStyle(.grouped)
        .scrollDisabled(true)
        .frame(width: 200, height: 120)
    } content: { page in
        MacLabeledContentDemo(page: page)
    }
}

private struct MacLabeledContentConfig {
    var label = "Version"
    var value = "2.4 (118)"
    var formStyle: MacFormStyleOption = .grouped
    var hidesLabels = false
}

private struct MacLabeledContentDemo: View {
    let page: ComponentPage

    var body: some View {
        DemoPage(
            page: page,
            initial: MacLabeledContentConfig(),
            usage: """
            Form {
                LabeledContent("Version", value: "2.4 (118)")
                LabeledContent("Size", value: 18_400_000, format: .byteCount(style: .file))
            }
            .formStyle(.grouped)
            """,
            usageNote: Aside(.note, "Like a `<dt>` and `<dd>` pair, but the layout comes from the container: a `Form`'s style decides where the label goes.")
        ) { $config in
            Form {
                LabeledContent(config.label, value: config.value)
                LabeledContent("Size", value: 18_400_000, format: .byteCount(style: .file))
            }
            .styled(config.formStyle)
            .modifier(MacLabeledHidesLabels(isHidden: config.hidesLabels))
            .scrollDisabled(true)
            .frame(maxWidth: 340, minHeight: 140)
        } controls: { $config in
            Section("Content") {
                TextField("Label", text: $config.label)
                TextField("Value", text: $config.value)
            }
            Section("Appearance") {
                OptionPicker("Form style", selection: $config.formStyle)
                Toggle("Hide labels", isOn: $config.hidesLabels)
            }
        } code: { config in
            var lines = [
                "Form {",
                "    LabeledContent(\(swiftString(config.label)), value: \(swiftString(config.value)))",
                "    LabeledContent(\"Size\", value: 18_400_000, format: .byteCount(style: .file))",
                "}",
            ]
            if config.formStyle != .automatic {
                lines.append(".formStyle(\(config.formStyle.label))")
            }
            if config.hidesLabels {
                lines.append(".labelsHidden()")
            }
            return lines.joined(separator: "\n")
        } examples: {
            MacLabeledContentExamples()
        }
    }
}

// MARK: - Examples

private struct MacLabeledContentExamples: View {
    @State private var copies = 1
    @State private var refreshesStatus = true
    @State private var fetchesServer = false
    @State private var addsFiles = true

    private let created = Calendar.current.date(from: DateComponents(year: 2026, month: 3, day: 14)) ?? .now

    var body: some View {
        ExampleCard(
            title: "Details in an inspector",
            caption: "Pass `format:` to show numbers, sizes, and dates the way the person's region writes them.",
            code: """
            let created = Date.now

            Form {
                Section("Information") {
                    LabeledContent("Kind", value: "JPEG image")
                    LabeledContent("Size", value: 2_480_000, format: .byteCount(style: .file))
                    LabeledContent("Created", value: created, format: .dateTime.day().month().year())
                }
            }
            .formStyle(.grouped)
            """,
            minHeight: 220
        ) {
            Form {
                Section("Information") {
                    LabeledContent("Kind", value: "JPEG image")
                    LabeledContent("Size", value: 2_480_000, format: .byteCount(style: .file))
                    LabeledContent("Created", value: created, format: .dateTime.day().month().year())
                }
            }
            .formStyle(.grouped)
            .scrollDisabled(true)
            .frame(maxWidth: 360, minHeight: 200)
        }

        ExampleCard(
            title: "A control as the value",
            caption: "Give any view a label that lines up with the other rows, like a field with a stepper beside it.",
            code: """
            @State private var copies = 1

            Form {
                LabeledContent("Copies:") {
                    HStack(spacing: 4) {
                        TextField("Copies", value: $copies, format: .number)
                            .frame(width: 44)
                        Stepper("Copies", value: $copies, in: 1...99)
                    }
                    .labelsHidden()
                }
                Picker("Paper size:", selection: .constant("A4")) {
                    Text("A4").tag("A4")
                    Text("US Letter").tag("US Letter")
                }
            }
            """,
            minHeight: 140
        ) {
            Form {
                LabeledContent("Copies:") {
                    HStack(spacing: 4) {
                        TextField("Copies", value: $copies, format: .number)
                            .frame(width: 44)
                        Stepper("Copies", value: $copies, in: 1...99)
                    }
                    .labelsHidden()
                }
                Picker("Paper size:", selection: .constant("A4")) {
                    Text("A4").tag("A4")
                    Text("US Letter").tag("US Letter")
                }
            }
            .fixedSize()
        }

        ExampleCard(
            title: "Checkboxes under one label",
            caption: "In a grouped form, toggles are switches. Inside `LabeledContent` they become checkboxes, stacked under one label.",
            code: """
            @State private var refreshesStatus = true
            @State private var fetchesServer = false
            @State private var addsFiles = true

            Form {
                LabeledContent("Source Control") {
                    Toggle("Refresh status automatically", isOn: $refreshesStatus)
                    Toggle("Fetch server status", isOn: $fetchesServer)
                    Toggle("Add and remove files", isOn: $addsFiles)
                }
            }
            .formStyle(.grouped)
            """,
            minHeight: 200
        ) {
            Form {
                LabeledContent("Source Control") {
                    Toggle("Refresh status automatically", isOn: $refreshesStatus)
                    Toggle("Fetch server status", isOn: $fetchesServer)
                    Toggle("Add and remove files", isOn: $addsFiles)
                }
            }
            .formStyle(.grouped)
            .scrollDisabled(true)
            .frame(maxWidth: 460, minHeight: 180)
        }

        ExampleCard(
            title: "A label with a subtitle",
            caption: "Give the label two `Text` views: the first is the title, the second a line of detail under it.",
            code: """
            Form {
                LabeledContent {
                    Text("4.2 GB")
                } label: {
                    Text("Cache")
                    Text("Downloaded previews and thumbnails")
                }
            }
            .formStyle(.grouped)
            """,
            minHeight: 140
        ) {
            Form {
                LabeledContent {
                    Text("4.2 GB")
                } label: {
                    Text("Cache")
                    Text("Downloaded previews and thumbnails")
                }
            }
            .formStyle(.grouped)
            .scrollDisabled(true)
            .frame(maxWidth: 420, minHeight: 110)
        }
    }
}

/// One info row for the label color guideline.
private struct MacInfoRow: View {
    let isLayered: Bool

    var body: some View {
        HStack {
            Text("Serial Number")
                .foregroundStyle(isLayered ? .secondary : .primary)
            Spacer()
            Text("C02XK1JHJG5H")
                .foregroundStyle(.primary)
        }
        .frame(width: 240)
    }
}

// MARK: - Options

private enum MacFormStyleOption: DemoOption {
    case automatic, columns, grouped

    var label: String {
        switch self {
        case .automatic: ".automatic"
        case .columns: ".columns"
        case .grouped: ".grouped"
        }
    }
}

private struct MacLabeledHidesLabels: ViewModifier {
    let isHidden: Bool

    func body(content: Content) -> some View {
        if isHidden {
            content.labelsHidden()
        } else {
            content
        }
    }
}

private extension View {
    @ViewBuilder
    func styled(_ style: MacFormStyleOption) -> some View {
        switch style {
        case .automatic: formStyle(.automatic)
        case .columns: formStyle(.columns)
        case .grouped: formStyle(.grouped)
        }
    }
}
