import SwiftUI

extension ComponentPage {
    static let textEditor = ComponentPage(
        id: "text-editor",
        title: "TextEditor",
        summary: "A scrolling area for long, multi-line text, plain or styled.",
        category: .textInput,
        symbol: "text.alignleft",
        availability: ["macOS 11.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/texteditor",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/text-views",
        aliases: ["textarea", "<textarea>", "NSTextView", "multiline", "multi-line text", "notes", "rich text", "styled text", "AttributedString", "find and replace", "find bar", "findNavigator", "bold"],
        related: ["text-field", "focus-keyboard", "text-label", "typography"],
        notes: [
            "**A `String` gives plain text; an `AttributedString` gives styled text.** Bind an attributed string and the editor's context menu offers formatting controls.",
            "**Find applies to the editors in the view.** With more than one `TextEditor` under `.findNavigator`, which one shows the find bar isn't guaranteed.",
        ],
        api: [
            APIItem("`TextEditor(text:)`", "Edits a `String` or an `AttributedString`."),
            APIItem("`TextEditor(text:selection:)`", "Also binds the selection, for your own controls."),
            APIItem("`.findNavigator(isPresented:)`", "Shows or hides the find and replace bar."),
            APIItem("`.findDisabled()`", "Turns off find, and replace with it."),
            APIItem("`.replaceDisabled()`", "Keeps find, turns off replace."),
            APIItem("`.autocorrectionDisabled()`", "Stops corrections, for code or names."),
            APIItem("`.lineSpacing(_:)`", "Adds space between lines."),
        ],
        guidelines: [
            Guideline(
                "Use a text editor for long text.",
                "Notes, messages, and descriptions need room for several lines. A single-line field cuts them off.",
                good: "The whole note is visible and editable.",
                bad: "A text field shows one line of it."
            ) {
                MacNoteSample(isEditor: true)
            } bad: {
                MacNoteSample(isEditor: false)
            },
            Guideline(
                "Keep the text easy to read.",
                "You can mix fonts, colors, and alignment, but readability comes first. Check your text with accessibility settings such as Increase Contrast turned on."
            ),
        ]
    ) {
        TextEditor(text: .constant("Pick up the photos from the lab, then call about the frames."))
            .font(.callout)
            .scrollDisabled(true)
            .frame(width: 180, height: 70)
            .clipShape(.rect(cornerRadius: 6))
            .overlay(RoundedRectangle(cornerRadius: 6).strokeBorder(.separator))
    } content: { page in
        MacTextEditorDemo(page: page)
    }
}

private let sampleNote = """
Trip ideas

Drive up the coast on Saturday and stop at the lighthouse. Book the cabin near the lake before the weekend fills up.
"""

private struct MacTextEditorConfig {
    var text = sampleNote
    var font: MacEditorFontOption = .body
    var lineSpacing = 0.0
    var isFinding = false
    var findDisabled = false
    var correctionDisabled = false
    var isDisabled = false
}

private struct MacTextEditorDemo: View {
    let page: ComponentPage

    var body: some View {
        DemoPage(
            page: page,
            initial: MacTextEditorConfig(),
            previewHeight: 300,
            usage: """
            @State private var notes = ""

            TextEditor(text: $notes)
                .frame(minHeight: 120)
            """,
            usageNote: Aside(.note, "A `TextEditor` scrolls when the text is longer than its frame, like a `<textarea>`. Give it a frame that fits a few lines.")
        ) { $config in
            VStack(alignment: .leading, spacing: 12) {
                TextEditor(text: $config.text)
                    .font(config.font.font)
                    .lineSpacing(config.lineSpacing)
                    .autocorrectionDisabled(config.correctionDisabled)
                    .findDisabled(config.findDisabled)
                    .findNavigator(isPresented: $config.isFinding)
                    .disabled(config.isDisabled)
                    .frame(width: 340, height: 170)
                    .clipShape(.rect(cornerRadius: 6))
                    .overlay(RoundedRectangle(cornerRadius: 6).strokeBorder(.separator))

                HStack {
                    Button(config.isFinding ? "Hide Find" : "Find…", systemImage: "magnifyingglass") {
                        config.isFinding.toggle()
                    }
                    .disabled(config.findDisabled)
                    Spacer()
                    MacTextReadout("\(config.text.count) characters")
                }
                .frame(width: 340)
            }
        } controls: { $config in
            Section("Text") {
                OptionPicker("Font", selection: $config.font)
                ValueSlider("Line spacing", value: $config.lineSpacing, in: 0...10, step: 1)
            }
            Section("Behavior") {
                Toggle("Find disabled", isOn: $config.findDisabled)
                Toggle("Autocorrection off", isOn: $config.correctionDisabled)
                Toggle("Disabled", isOn: $config.isDisabled)
            }
        } code: { config in
            var lines = [
                "@State private var notes = \"\"",
            ]
            if !config.findDisabled {
                lines.append("@State private var isFinding = \(config.isFinding)")
            }
            lines += ["", "TextEditor(text: $notes)"]
            if config.font != .body {
                lines.append("    .font(\(config.font.label))")
            }
            if config.lineSpacing > 0 {
                lines.append("    .lineSpacing(\(swiftNumber(config.lineSpacing)))")
            }
            if config.correctionDisabled {
                lines.append("    .autocorrectionDisabled()")
            }
            if config.findDisabled {
                lines.append("    .findDisabled()")
            } else {
                lines.append("    .findNavigator(isPresented: $isFinding)")
            }
            if config.isDisabled {
                lines.append("    .disabled(true)")
            }
            lines.append("    .frame(height: 170)")
            return lines.joined(separator: "\n")
        } examples: {
            MacTextEditorExamples()
        }
    }
}

// MARK: - Examples

private struct MacTextEditorExamples: View {
    var body: some View {
        ExampleCard(
            title: "Find and replace",
            caption: "Bind `.findNavigator(isPresented:)` to show the find bar from a button. It stays in sync when people close it themselves.",
            code: """
            @State private var text = "Bring snacks, bring water, bring a map."
            @State private var isFinding = false

            VStack(alignment: .leading) {
                Button("Find…", systemImage: "magnifyingglass") {
                    isFinding.toggle()
                }
                TextEditor(text: $text)
                    .font(.body)
                    .findNavigator(isPresented: $isFinding)
                    .frame(width: 320, height: 120)
            }
            """,
            minHeight: 200,
            aside: Aside(.important, "Put `.findDisabled()` or `.replaceDisabled()` closer to the editor than `.findNavigator`, or they won't apply.")
        ) {
            MacFindSample()
        }

        ExampleCard(
            title: "Styled text",
            caption: "Bind an `AttributedString` for rich text. Add a `selection` binding to build your own controls, like a Bold button.",
            code: """
            struct StyledNoteEditor: View {
                @State private var text = AttributedString("Select a word, then click Bold.")
                @State private var selection = AttributedTextSelection()
                @Environment(\\.fontResolutionContext) private var fontContext

                var body: some View {
                    VStack(alignment: .leading) {
                        Button("Bold", systemImage: "bold") {
                            let font = selection.typingAttributes(in: text).font ?? .default
                            let makeBold = !font.resolve(in: fontContext).isBold
                            text.transformAttributes(in: &selection) {
                                $0.font = ($0.font ?? .default).bold(makeBold)
                            }
                        }
                        TextEditor(text: $text, selection: $selection)
                            .frame(width: 320, height: 100)
                    }
                }
            }
            """,
            minHeight: 180,
            aside: Aside(.note, "Right-click selected text for the system's own formatting controls. They work on the same `AttributedString`.")
        ) {
            MacStyledEditorSample()
        }

        ExampleCard(
            title: "A code editor",
            caption: "Use a monospaced font and `.autocorrectionDisabled()` where corrections would get in the way, like code or names.",
            code: """
            @State private var source = "let greeting = \\"Hello\\"\\nprint(greeting)"

            TextEditor(text: $source)
                .font(.body.monospaced())
                .autocorrectionDisabled()
                .frame(width: 320, height: 100)
            """,
            minHeight: 150
        ) {
            MacCodeEditorSample()
        }

        ExampleCard(
            title: "A limit with a counter",
            caption: "Watch the text with `.onChange` to cap its length, and show the count under the editor.",
            code: """
            @State private var bio = ""
            let limit = 140

            VStack(alignment: .trailing) {
                TextEditor(text: $bio)
                    .font(.body)
                    .frame(width: 320, height: 80)
                    .onChange(of: bio) {
                        if bio.count > limit {
                            bio = String(bio.prefix(limit))
                        }
                    }
                Text("\\(bio.count) of \\(limit)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }
            """,
            minHeight: 150
        ) {
            MacLimitedEditorSample()
        }
    }
}

/// The editor in the examples: a hairline border, like a field.
private struct MacEditorBorder: ViewModifier {
    func body(content: Content) -> some View {
        content
            .clipShape(.rect(cornerRadius: 6))
            .overlay(RoundedRectangle(cornerRadius: 6).strokeBorder(.separator))
    }
}

private struct MacFindSample: View {
    @State private var text = "Bring snacks, bring water, bring a map."
    @State private var isFinding = false

    var body: some View {
        VStack(alignment: .leading) {
            Button("Find…", systemImage: "magnifyingglass") {
                isFinding.toggle()
            }
            TextEditor(text: $text)
                .font(.body)
                .findNavigator(isPresented: $isFinding)
                .frame(width: 320, height: 120)
                .modifier(MacEditorBorder())
        }
    }
}

private struct MacStyledEditorSample: View {
    @State private var text = AttributedString("Select a word, then click Bold.")
    @State private var selection = AttributedTextSelection()
    @Environment(\.fontResolutionContext) private var fontContext

    var body: some View {
        VStack(alignment: .leading) {
            Button("Bold", systemImage: "bold") {
                let font = selection.typingAttributes(in: text).font ?? .default
                let makeBold = !font.resolve(in: fontContext).isBold
                text.transformAttributes(in: &selection) {
                    $0.font = ($0.font ?? .default).bold(makeBold)
                }
            }
            TextEditor(text: $text, selection: $selection)
                .frame(width: 320, height: 100)
                .modifier(MacEditorBorder())
        }
    }
}

private struct MacCodeEditorSample: View {
    @State private var source = "let greeting = \"Hello\"\nprint(greeting)"

    var body: some View {
        TextEditor(text: $source)
            .font(.body.monospaced())
            .autocorrectionDisabled()
            .frame(width: 320, height: 100)
            .modifier(MacEditorBorder())
    }
}

private struct MacLimitedEditorSample: View {
    @State private var bio = "Photographer and coffee enthusiast."
    private let limit = 140

    var body: some View {
        VStack(alignment: .trailing) {
            TextEditor(text: $bio)
                .font(.body)
                .frame(width: 320, height: 80)
                .modifier(MacEditorBorder())
                .onChange(of: bio) {
                    if bio.count > limit {
                        bio = String(bio.prefix(limit))
                    }
                }
            Text("\(bio.count) of \(limit)")
                .font(.caption)
                .foregroundStyle(.secondary)
                .monospacedDigit()
        }
    }
}

/// A note in an editor or a field, for the long-text guideline.
private struct MacNoteSample: View {
    let isEditor: Bool
    private let note = "Call the venue about parking, then send the guest list to Sam by Friday."

    var body: some View {
        Group {
            if isEditor {
                TextEditor(text: .constant(note))
                    .font(.body)
                    .scrollDisabled(true)
                    .modifier(MacEditorBorder())
            } else {
                TextField("Note", text: .constant(note))
                    .labelsHidden()
            }
        }
        .frame(width: 200, height: isEditor ? 80 : nil)
    }
}

// MARK: - Options

private enum MacEditorFontOption: DemoOption {
    case body, monospaced, serif, title3

    var label: String {
        switch self {
        case .body: ".body"
        case .monospaced: ".body.monospaced()"
        case .serif: ".system(.body, design: .serif)"
        case .title3: ".title3"
        }
    }

    var font: Font {
        switch self {
        case .body: .body
        case .monospaced: .body.monospaced()
        case .serif: .system(.body, design: .serif)
        case .title3: .title3
        }
    }
}
