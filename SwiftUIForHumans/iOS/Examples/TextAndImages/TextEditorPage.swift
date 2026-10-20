import SwiftUI

extension ComponentPage {
    static let textEditor = ComponentPage(
        id: "text-editor",
        title: "TextEditor",
        summary: "A scrolling, multi-line area for long text such as notes or a bio.",
        category: .textInput,
        symbol: "doc.plaintext",
        availability: ["iOS 14.0+", "macOS 11.0+", "visionOS 1.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/texteditor",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/text-views",
        aliases: ["textarea", "<textarea>", "multiline", "UITextView", "notes", "rich text", "contenteditable", "long text"],
        related: ["text-field", "focus-state", "text"],
        notes: [
            "**Hide the default background before adding your own.** `.background` alone has no effect until you add `.scrollContentBackground(.hidden)`.",
            "**Text modifiers style all of the text.** `.font`, `.foregroundStyle`, and `.lineSpacing` apply to the whole editor. For styled runs, bind an `AttributedString`.",
        ],
        api: [
            APIItem("`TextEditor(text:)`", "An editor bound to a `String`, or an `AttributedString` for rich text."),
            APIItem("`.frame(height:)`", "Sets the editor's size. It scrolls when the text is longer."),
            APIItem("`.scrollContentBackground(.hidden)`", "Removes the default background so yours shows."),
            APIItem("`.font(_:)`", "The font for all of the text."),
            APIItem("`.lineSpacing(_:)`", "Extra space between lines, for long passages."),
            APIItem("`.onChange(of:)`", "Reacts to edits, such as to enforce a limit."),
        ],
        guidelines: [
            Guideline(
                "Use a text editor for long text, and a text field for short text.",
                "A bio or a note needs room to see several lines at once. A one-line field hides most of what people wrote.",
                good: "The whole bio is visible while editing.",
                bad: "A one-line field cuts the bio off."
            ) {
                EditorSizeSample(isEditor: true)
            } bad: {
                EditorSizeSample(isEditor: false)
            },
            Guideline(
                "Keep the text readable at every size.",
                "Use a text style like `.body` rather than a fixed point size, so the editor follows Dynamic Type."
            ),
            Guideline(
                "Tell people what to write when it's empty.",
                "An empty box gives no hint. Add a placeholder, and a counter if there's a limit."
            ),
        ]
    ) {
        TextEditor(text: .constant("Pick up milk, eggs, and coffee.\nCall Sam about Saturday.\nBook the dentist."))
            .font(.callout)
            .scrollContentBackground(.hidden)
            .padding(8)
            .background(.fill.tertiary, in: .rect(cornerRadius: 12))
            .scrollDisabled(true)
            .frame(width: 210, height: 110)
    } content: { page in
        TextEditorDemo(page: page)
    }
}

private struct TextEditorConfig {
    var text = "Dear Sam,\n\nThanks for dinner last night. The pasta was perfect and I still can't stop thinking about that tiramisu."
    var font: TEFontOption = .body
    var height = 180.0
    var customBackground = true
    var lineSpacing = 0.0
    var isDisabled = false
}

private struct TextEditorDemo: View {
    let page: ComponentPage

    var body: some View {
        DemoPage(
            page: page,
            initial: TextEditorConfig(),
            previewHeight: 280,
            usage: """
            @State private var notes = ""

            TextEditor(text: $notes)
                .frame(height: 150)
            """,
            usageNote: Aside(.important, "A `TextEditor` takes all the space it's offered. Outside a `Form`, give it a `.frame(height:)` or `minHeight`.")
        ) { $config in
            VStack(alignment: .trailing, spacing: 8) {
                editor($config)
                Text("\(config.text.count) characters")
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: 420)
        } controls: { $config in
            Section("Text") {
                OptionPicker("Font", selection: $config.font)
                ValueSlider("Line spacing", value: $config.lineSpacing, in: 0...12, step: 1)
            }
            Section("Appearance") {
                ValueSlider("Height", value: $config.height, in: 80...320, step: 10)
                Toggle("Custom background", isOn: $config.customBackground)
                Toggle("Disabled", isOn: $config.isDisabled)
            }
        } code: { config in
            var lines = ["@State private var text = \"\"", "", "TextEditor(text: $text)"]
            if config.font != .body {
                lines.append("    .font(\(config.font.label))")
            }
            if config.lineSpacing > 0 {
                lines.append("    .lineSpacing(\(swiftNumber(config.lineSpacing)))")
            }
            if config.customBackground {
                lines.append("    .scrollContentBackground(.hidden)")
                lines.append("    .padding(8)")
                lines.append("    .background(.fill.tertiary, in: .rect(cornerRadius: 12))")
            }
            lines.append("    .frame(height: \(swiftNumber(config.height)))")
            if config.isDisabled {
                lines.append("    .disabled(true)")
            }
            return lines.joined(separator: "\n")
        } examples: {
            ExampleCard(
                title: "Placeholder",
                caption: "`TextEditor` has no placeholder, so overlay a `Text` and hide it once there's text.",
                code: """
                @State private var notes = ""

                TextEditor(text: $notes)
                    .overlay(alignment: .topLeading) {
                        if notes.isEmpty {
                            Text("Write something…")
                                .foregroundStyle(.tertiary)
                                .padding(.top, 8)
                                .padding(.leading, 5)
                                .allowsHitTesting(false)
                        }
                    }
                    .frame(height: 120)
                """,
                aside: Aside(.note, "The padding lines the placeholder up with the editor's first line, and `.allowsHitTesting(false)` lets taps reach the editor.")
            ) {
                PlaceholderEditorExample()
            }
            ExampleCard(
                title: "Character limit",
                caption: "Trim the text in `.onChange(of:)` to enforce a maximum, and show a counter below the editor.",
                code: """
                @State private var bio = ""
                let limit = 80

                VStack(alignment: .trailing) {
                    TextEditor(text: $bio)
                        .frame(height: 100)
                        .onChange(of: bio) {
                            if bio.count > limit {
                                bio = String(bio.prefix(limit))
                            }
                        }
                    Text("\\(bio.count)/\\(limit)")
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(bio.count == limit ? .red : .secondary)
                }
                """
            ) {
                LimitEditorExample()
            }
            ExampleCard(
                title: "Rich text",
                caption: "Bind an `AttributedString` and people can make selected text bold, italic, or underlined from the edit menu.",
                code: """
                @State private var text = AttributedString("Select a word, then tap Format to make it bold.")

                TextEditor(text: $text)
                    .frame(height: 120)
                """,
                aside: Aside(.note, "Rich text editing needs iOS 26 or later. With a `String` binding, the editor stays plain text.")
            ) {
                RichTextEditorExample()
            }
            ExampleCard(
                title: "Growing TextField instead",
                caption: "For a chat-style message box, use `TextField` with `axis: .vertical`. It starts at one line and grows.",
                code: """
                @State private var message = ""

                TextField("Message", text: $message, axis: .vertical)
                    .lineLimit(1...5)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(.fill.tertiary, in: .rect(cornerRadius: 20))
                """
            ) {
                GrowingFieldExample()
            }
        }
    }

    @ViewBuilder
    private func editor(_ config: Binding<TextEditorConfig>) -> some View {
        let c = config.wrappedValue
        if c.customBackground {
            TextEditor(text: config.text)
                .font(c.font.font)
                .lineSpacing(c.lineSpacing)
                .scrollContentBackground(.hidden)
                .padding(8)
                .background(.fill.tertiary, in: .rect(cornerRadius: 12))
                .frame(height: c.height)
                .disabled(c.isDisabled)
        } else {
            TextEditor(text: config.text)
                .font(c.font.font)
                .lineSpacing(c.lineSpacing)
                .frame(height: c.height)
                .disabled(c.isDisabled)
        }
    }
}

// MARK: - Examples

private struct PlaceholderEditorExample: View {
    @State private var notes = ""

    var body: some View {
        TextEditor(text: $notes)
            .overlay(alignment: .topLeading) {
                if notes.isEmpty {
                    Text("Write something…")
                        .foregroundStyle(.tertiary)
                        .padding(.top, 8)
                        .padding(.leading, 5)
                        .allowsHitTesting(false)
                }
            }
            .frame(height: 120)
            .frame(maxWidth: 360)
    }
}

private struct LimitEditorExample: View {
    @State private var bio = "Designer and coffee nerd. Building tiny apps on weekends."
    private let limit = 80

    var body: some View {
        VStack(alignment: .trailing) {
            TextEditor(text: $bio)
                .frame(height: 100)
                .onChange(of: bio) {
                    if bio.count > limit {
                        bio = String(bio.prefix(limit))
                    }
                }
            Text("\(bio.count)/\(limit)")
                .font(.caption.monospacedDigit())
                .foregroundStyle(bio.count == limit ? .red : .secondary)
        }
        .frame(maxWidth: 360)
    }
}

private struct RichTextEditorExample: View {
    @State private var text: AttributedString = {
        var text = AttributedString("Select a word, then tap Format to make it bold. ")
        var bold = AttributedString("Like this.")
        bold.font = .body.bold()
        text.append(bold)
        return text
    }()

    var body: some View {
        TextEditor(text: $text)
            .frame(height: 120)
            .frame(maxWidth: 360)
    }
}

private struct GrowingFieldExample: View {
    @State private var message = "This field grows as you type more lines. Keep going and it stops at five."

    var body: some View {
        TextField("Message", text: $message, axis: .vertical)
            .lineLimit(1...5)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(.fill.tertiary, in: .rect(cornerRadius: 20))
            .frame(maxWidth: 360)
    }
}

// MARK: - Guideline samples

private let sampleBio = "Designer and coffee nerd. I build small apps on weekends and teach pottery."

/// A filled bio in a text editor or squeezed into a one-line field.
private struct EditorSizeSample: View {
    let isEditor: Bool

    var body: some View {
        Group {
            if isEditor {
                TextEditor(text: .constant(sampleBio))
                    .font(.callout)
                    .scrollContentBackground(.hidden)
                    .scrollDisabled(true)
                    .frame(height: 100)
            } else {
                TextField("Bio", text: .constant(sampleBio))
                    .font(.callout)
            }
        }
        .padding(8)
        .background(.fill.tertiary, in: .rect(cornerRadius: 10))
        .frame(width: 230)
    }
}

// MARK: - Options

private enum TEFontOption: DemoOption {
    case body, callout, title3, monospaced, serif

    var label: String {
        switch self {
        case .body: ".body"
        case .callout: ".callout"
        case .title3: ".title3"
        case .monospaced: ".body.monospaced()"
        case .serif: ".system(.body, design: .serif)"
        }
    }

    var font: Font {
        switch self {
        case .body: .body
        case .callout: .callout
        case .title3: .title3
        case .monospaced: .body.monospaced()
        case .serif: .system(.body, design: .serif)
        }
    }
}
