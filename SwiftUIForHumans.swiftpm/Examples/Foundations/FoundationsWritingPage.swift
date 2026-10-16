import SwiftUI

extension ComponentPage {
    static let writing = ComponentPage(
        id: "writing",
        title: "Writing",
        summary: "Short, specific words for buttons, alerts, errors, and empty screens.",
        category: .foundations,
        kind: .concept,
        symbol: "text.quote",
        availability: [],
        docsURL: nil,
        higURL: "https://developer.apple.com/design/human-interface-guidelines/writing",
        aliases: ["UX writing", "microcopy", "copywriting", "copy", "button labels", "error messages", "empty state", "tone", "voice", "capitalization", "title case", "sentence case", "content design", "wording"],
        related: ["alert", "confirmation-dialog", "empty-state", "text-field", "button", "voiceover"],
        notes: [
            "**Keep a word list.** Write down what you call things (\"Library\" or \"Collection\"? \"Remove\" or \"Delete\"?) and use the same word everywhere.",
            "**Read it out loud.** If a sentence sounds stiff or long when spoken, cut it down. Fewer words are almost always clearer.",
        ],
        api: [
            APIItem("`.alert(_:isPresented:actions:)`", "A title, a message, and buttons."),
            APIItem("`Button(_:role:action:)`", "`.destructive` and `.cancel` roles."),
            APIItem("`ContentUnavailableView`", "Title, explanation, and action for empty screens."),
            APIItem("`TextField(_:text:prompt:)`", "A prompt shows the expected format."),
            APIItem("`Section { } footer: { }`", "Explains a setting under it."),
        ],
        guidelines: [
            Guideline(
                "Label buttons with verbs.",
                "Say what happens when people tap. Clever or cute labels make them stop and think.",
                good: "\"Save Draft\" says exactly what it does.",
                bad: "\"Sounds Good!\" leaves people guessing."
            ) {
                WritingButtonSample(title: "Save Draft")
            } bad: {
                WritingButtonSample(title: "Sounds Good!")
            },
            Guideline(
                "Name the action in alert buttons.",
                "\"OK\" can mean \"go ahead\" or \"got it\". Use the verb, and always call the way out \"Cancel\".",
                good: "\"Delete\" and \"Cancel\".",
                bad: "\"OK\" could mean anything."
            ) {
                WritingAlertMock(title: "Delete 3 Photos?", message: "This can't be undone.", primary: "Delete", isDestructive: true)
            } bad: {
                WritingAlertMock(title: "Are you sure?", message: "Click OK to continue.", primary: "OK", isDestructive: false)
            },
            Guideline(
                "Say how to fix an error.",
                "Show the message next to the problem, don't blame, and skip \"Oops\". Tell people what will work.",
                good: "States the rule people need.",
                bad: "Scolds without helping."
            ) {
                WritingErrorField(message: "Use at least 8 characters.")
            } bad: {
                WritingErrorField(message: "Oops! Invalid password.")
            },
            Guideline(
                "Skip \"we\".",
                "It's unclear who \"we\" is, especially in an error. Describe what happened instead.",
                good: "Plain and specific.",
                bad: "Who is \"we\"?"
            ) {
                WritingBanner(text: "Unable to Load Messages")
            } bad: {
                WritingBanner(text: "We're having trouble with your messages")
            },
            Guideline(
                "Give empty screens a next step.",
                "An empty list is a chance to explain what goes there and offer the button that fills it.",
                good: "Explains, then offers the action.",
                bad: "A dead end."
            ) {
                WritingEmptyState(helpful: true)
            } bad: {
                WritingEmptyState(helpful: false)
            },
            Guideline(
                "Write for the device.",
                "On iPhone and iPad, people tap, not click. Use the gestures and words that match what's in their hand."
            ),
        ],
        sources: [
            "https://developer.apple.com/design/human-interface-guidelines/writing",
            "https://developer.apple.com/design/human-interface-guidelines/alerts",
            "https://developer.apple.com/documentation/swiftui/contentunavailableview",
        ],
        reviewed: "October 2026"
    ) {
        VStack(spacing: 8) {
            Text("Delete Draft?")
                .font(.headline)
            HStack(spacing: 8) {
                Text("Cancel")
                    .frame(width: 70, height: 30)
                    .background(.fill.tertiary, in: .capsule)
                Text("Delete")
                    .foregroundStyle(.red)
                    .frame(width: 70, height: 30)
                    .background(.fill.tertiary, in: .capsule)
            }
            .font(.subheadline.weight(.semibold))
        }
        .padding(16)
        .background(.background, in: .rect(cornerRadius: 22))
        .overlay {
            RoundedRectangle(cornerRadius: 22)
                .strokeBorder(.separator)
        }
        .accessibilityHidden(true)
    } content: { page in
        WritingArticle(page: page)
    }
}

// MARK: - Page

private struct WritingArticle: View {
    let page: ComponentPage

    var body: some View {
        ArticlePage(page: page) {
            Prose("The words in your app are part of the interface. A clear button label saves a tap on the wrong thing, and a good error message saves a support email. Pick a **voice** that fits your app, then adjust the **tone** to the moment: calm for a failed payment, warm for a finished goal.")

            VStack(alignment: .leading, spacing: 16) {
                SectionTitle("Before and after")
                WritingRewriteTable()
            }
            .id("rewrites")

            VStack(alignment: .leading, spacing: 16) {
                SectionTitle("Capitalization")
                Prose("Pick title case or sentence case for each kind of text, and stick to it. For buttons and alerts, Apple uses these rules:")
                WritingCaseTable()
            }
            .id("capitalization")

            VStack(alignment: .leading, spacing: 16) {
                SectionTitle("In SwiftUI")
                VStack(alignment: .leading, spacing: 44) {
                    ExampleCard(
                        title: "A clear alert",
                        caption: "Give `.alert` a specific title, a short message only if it helps, and buttons named after their action.",
                        code: """
                        @State private var isConfirming = false

                        Button("Delete Photos", role: .destructive) {
                            isConfirming = true
                        }
                        .alert("Delete 3 Photos?", isPresented: $isConfirming) {
                            Button("Delete", role: .destructive) { }
                            Button("Cancel", role: .cancel) { }
                        } message: {
                            Text("This can't be undone.")
                        }
                        """,
                        minHeight: 120,
                        aside: Aside(.note, "Skip alerts for things people can undo, like deleting one email. Save them for actions that can't be reversed.")
                    ) {
                        WritingAlertExample()
                    }

                    ExampleCard(
                        title: "An error next to the field",
                        caption: "Show the format in the `prompt`, and put any error right under the field with what to do next.",
                        code: """
                        @State private var email = "maya@"

                        VStack(alignment: .leading, spacing: 6) {
                            TextField("Email", text: $email, prompt: Text("name@example.com"))
                                .textFieldStyle(.roundedBorder)
                            Label("Enter the full address, like name@example.com.", systemImage: "exclamationmark.circle")
                                .font(.footnote)
                                .foregroundStyle(.red)
                        }
                        """,
                        minHeight: 130
                    ) {
                        WritingEmailField()
                            .frame(maxWidth: 300)
                    }

                    ExampleCard(
                        title: "An empty state with a way forward",
                        caption: "Use `ContentUnavailableView` with a title, one line of explanation, and the button that fixes it.",
                        code: """
                        ContentUnavailableView {
                            Label("No Trips Yet", systemImage: "suitcase")
                        } description: {
                            Text("Trips you plan show up here.")
                        } actions: {
                            Button("Plan a Trip") { }
                                .buttonStyle(.borderedProminent)
                        }
                        """,
                        minHeight: 240,
                        aside: Aside(.note, "Empty states don't last. Don't put anything there that people need to find again later.")
                    ) {
                        ContentUnavailableView {
                            Label("No Trips Yet", systemImage: "suitcase")
                        } description: {
                            Text("Trips you plan show up here.")
                        } actions: {
                            Button("Plan a Trip") { }
                                .buttonStyle(.borderedProminent)
                        }
                    }

                    ExampleCard(
                        title: "A setting that explains itself",
                        caption: "Give a toggle a plain label, and use the section footer to say what happens when it's on.",
                        code: """
                        @State private var autoPlay = true

                        Form {
                            Section {
                                Toggle("Autoplay Videos", isOn: $autoPlay)
                            } footer: {
                                Text("Videos in your feed start playing without sound.")
                            }
                        }
                        """,
                        minHeight: 170,
                        aside: Aside(.note, "Describe the \"on\" state only. People can work out what \"off\" does.")
                    ) {
                        WritingSettingSample()
                    }
                }
            }
            .id("examples")
        }
    }
}

// MARK: - Tables

private struct WritingRewriteTable: View {
    private let rows: [(before: String, after: String)] = [
        ("OK", "Delete"),
        ("Error", "Can't Connect to Server"),
        ("Oops! Invalid email.", "Enter an email like name@example.com."),
        ("We couldn't save your note", "Unable to Save Note"),
        ("Click here to learn more", "Learn More About Backups"),
        ("Your Favorites", "Favorites"),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(rows.enumerated()), id: \.offset) { index, row in
                if index > 0 { Divider() }
                VStack(alignment: .leading, spacing: 4) {
                    Label {
                        Text(row.before)
                            .strikethrough(color: .secondary)
                            .foregroundStyle(.secondary)
                    } icon: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.red)
                    }
                    Label {
                        Text(row.after)
                            .fontWeight(.medium)
                    } icon: {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                    }
                }
                .font(.subheadline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 10)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Instead of \(row.before), write \(row.after)")
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 4)
        .background(.background.secondary, in: .rect(cornerRadius: 16))
    }
}

private struct WritingCaseTable: View {
    private let rows: [(what: String, rule: String, example: String)] = [
        ("Button", "Title case, no period", "Add to Library"),
        ("Alert title, a fragment", "Title case, no period", "Unable to Send Message"),
        ("Alert title, a sentence", "Sentence case, with punctuation", "Delete this playlist?"),
        ("Alert message", "Full sentences, sentence case", "You can't undo this action."),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(rows.enumerated()), id: \.offset) { index, row in
                if index > 0 { Divider() }
                VStack(alignment: .leading, spacing: 3) {
                    Text(row.what)
                        .font(.subheadline.weight(.semibold))
                    Text(row.rule)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text("“\(row.example)”")
                        .font(.subheadline.italic())
                        .foregroundStyle(.tint)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 10)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 4)
        .background(.background.secondary, in: .rect(cornerRadius: 16))
    }
}

// MARK: - Example views

private struct WritingAlertExample: View {
    @State private var isConfirming = false

    var body: some View {
        Button("Delete Photos", role: .destructive) {
            isConfirming = true
        }
        .buttonStyle(.bordered)
        .alert("Delete 3 Photos?", isPresented: $isConfirming) {
            Button("Delete", role: .destructive) { }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This can't be undone.")
        }
    }
}

private struct WritingEmailField: View {
    @State private var email = "maya@"

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            TextField("Email", text: $email, prompt: Text("name@example.com"))
                .textFieldStyle(.roundedBorder)
                .textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)
            Label("Enter the full address, like name@example.com.", systemImage: "exclamationmark.circle")
                .font(.footnote)
                .foregroundStyle(.red)
        }
    }
}

private struct WritingSettingSample: View {
    @State private var autoPlay = true

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Toggle("Autoplay Videos", isOn: $autoPlay)
                .padding(.horizontal, 16)
                .padding(.vertical, 11)
                .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 12))
            Text("Videos in your feed start playing without sound.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 16)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .frame(maxWidth: 320)
        .background(Color(.systemGroupedBackground), in: .rect(cornerRadius: 16))
    }
}

// MARK: - Guideline views

private struct WritingButtonSample: View {
    let title: String

    var body: some View {
        VStack(spacing: 10) {
            Text("Leave without sending?")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Button(title) { }
                .buttonStyle(.borderedProminent)
        }
    }
}

/// A static drawing of an alert, so a pair can show two side by side.
private struct WritingAlertMock: View {
    let title: String
    let message: String
    let primary: String
    let isDestructive: Bool

    var body: some View {
        VStack(spacing: 12) {
            VStack(spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(message)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .multilineTextAlignment(.center)
            HStack(spacing: 8) {
                Text("Cancel")
                    .frame(maxWidth: .infinity, minHeight: 34)
                    .background(.fill.tertiary, in: .capsule)
                Text(primary)
                    .foregroundStyle(isDestructive ? AnyShapeStyle(.red) : AnyShapeStyle(.tint))
                    .frame(maxWidth: .infinity, minHeight: 34)
                    .background(.fill.tertiary, in: .capsule)
            }
            .font(.subheadline.weight(.semibold))
        }
        .padding(16)
        .frame(width: 230)
        .background(Color(.secondarySystemBackground), in: .rect(cornerRadius: 24))
        .accessibilityElement(children: .combine)
    }
}

private struct WritingErrorField: View {
    let message: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("••••")
                Spacer()
            }
            .padding(10)
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(.red)
            }
            Label(message, systemImage: "exclamationmark.circle")
                .font(.footnote)
                .foregroundStyle(.red)
        }
        .frame(width: 230)
    }
}

private struct WritingBanner: View {
    let text: String

    var body: some View {
        Label(text, systemImage: "exclamationmark.triangle.fill")
            .font(.subheadline.weight(.medium))
            .foregroundStyle(.primary)
            .padding(12)
            .frame(width: 250, alignment: .leading)
            .background(.orange.opacity(0.15), in: .rect(cornerRadius: 12))
    }
}

private struct WritingEmptyState: View {
    let helpful: Bool

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "note.text")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            if helpful {
                Text("No Notes Yet")
                    .font(.headline)
                Text("Notes you write show up here.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                Button("New Note") { }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
            } else {
                Text("Nothing here.")
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }
        }
        .multilineTextAlignment(.center)
    }
}
