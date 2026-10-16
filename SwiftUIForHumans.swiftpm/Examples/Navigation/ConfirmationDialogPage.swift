import SwiftUI

extension ComponentPage {
    static let confirmationDialog = ComponentPage(
        id: "confirmation-dialog",
        title: "Confirmation Dialog",
        summary: "Asks people to pick from a few actions, or confirm a destructive one.",
        category: .presentation,
        symbol: "list.bullet.below.rectangle",
        availability: ["iOS 15.0+", "macOS 12.0+", "visionOS 1.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/view/confirmationdialog(_:ispresented:titlevisibility:actions:message:)",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/action-sheets",
        aliases: ["action sheet", "ActionSheet", "UIAlertController actionSheet", "confirm", "are you sure", "choose an option", "bottom menu"],
        related: ["alert", "menu", "sheet", "context-menu"],
        notes: [
            "**It replaces `ActionSheet`.** In iOS 26 it appears as a glass popover next to the button that opened it, instead of sliding up from the bottom.",
            "**You don't need a Cancel button.** Tapping outside dismisses it. If you add a `role: .cancel` button, the system decides where it goes.",
        ],
        api: [
            APIItem("`.confirmationDialog(_:isPresented:)`", "Shows a list of actions while a `Bool` is `true`."),
            APIItem("`titleVisibility:`", "`.visible` shows the title, hidden by default on iOS."),
            APIItem("`presenting:`", "Passes a value, like the item to delete, to the actions."),
            APIItem("`message: { }`", "A short line under the title."),
            APIItem("`Button(role: .destructive)`", "Turns the action red."),
        ],
        guidelines: [
            Guideline(
                "Use a dialog, not an alert, for choices about an action.",
                "When people close a draft, a dialog offers Delete or Save right where they tapped. An alert is for unexpected news.",
                good: "Choices appear next to the button.",
                bad: "An alert with three choices feels like an error."
            ) {
                DialogGuidelineSample(usesDialog: true)
            } bad: {
                DialogGuidelineSample(usesDialog: false)
            },
            Guideline(
                "Make the destructive choice red.",
                "`role: .destructive` makes it stand out, so nobody deletes something by accident."
            ),
            Guideline(
                "Keep the title to one line, and skip the message if you can.",
                "The button people just tapped already explains most of the context."
            ),
            Guideline(
                "Offer only a few actions.",
                "A dialog that needs to scroll is slow to read. Use a [Menu](catalog://menu) or a sheet for long lists."
            ),
        ]
    ) {
        DialogThumbnail()
    } content: { page in
        DialogDemo(page: page)
    }
}

private struct DialogConfig {
    var title = "Discard this draft?"
    var titleVisibility: DialogTitleVisibility = .visible
    var message = true
    var extraAction = true
    var isPresented = false
    var result = "Tap the button"
}

private struct DialogDemo: View {
    let page: ComponentPage

    var body: some View {
        DemoPage(
            page: page,
            initial: DialogConfig(),
            previewHeight: 220,
            usage: """
            @State private var isPresented = false

            Button("Discard Draft", role: .destructive) {
                isPresented = true
            }
            .confirmationDialog("Discard this draft?", isPresented: $isPresented, titleVisibility: .visible) {
                Button("Discard Draft", role: .destructive) {
                    // Discard
                }
                Button("Save Draft") {}
            }
            """,
            usageNote: Aside(.important, "The title is hidden by default on iOS. Pass `titleVisibility: .visible` to show it and the message.")
        ) { $config in
            VStack(spacing: 14) {
                Button("Discard Draft", role: .destructive) {
                    config.isPresented = true
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                .confirmationDialog(config.title, isPresented: $config.isPresented, titleVisibility: config.titleVisibility.value) {
                    Button("Discard Draft", role: .destructive) { config.result = "Tapped Discard Draft" }
                    if config.extraAction {
                        Button("Save Draft") { config.result = "Tapped Save Draft" }
                    }
                } message: {
                    if config.message {
                        Text("You can't undo this action.")
                    }
                }
                Text(config.result)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        } controls: { $config in
            Section("Title") {
                TextField("Title", text: $config.title)
                OptionPicker("Title visibility", selection: $config.titleVisibility)
                Toggle("Message", isOn: $config.message)
            }
            Section("Actions") {
                Toggle("Save Draft action", isOn: $config.extraAction)
            }
        } code: { config in
            code(for: config)
        } examples: {
            DialogExamples()
        }
    }

    private func code(for config: DialogConfig) -> String {
        var lines = [
            "@State private var isPresented = false",
            "",
            "Button(\"Discard Draft\", role: .destructive) {",
            "    isPresented = true",
            "}",
            ".buttonStyle(.bordered)",
        ]
        let visibility = config.titleVisibility == .automatic ? "" : ", titleVisibility: \(config.titleVisibility.label)"
        lines.append(".confirmationDialog(\(swiftString(config.title)), isPresented: $isPresented\(visibility)) {")
        lines += ["    Button(\"Discard Draft\", role: .destructive) {", "        // Discard", "    }"]
        if config.extraAction {
            lines.append("    Button(\"Save Draft\") {}")
        }
        if config.message {
            lines += ["} message: {", "    Text(\"You can't undo this action.\")"]
        }
        lines.append("}")
        return lines.joined(separator: "\n")
    }
}

private struct DialogThumbnail: View {
    var body: some View {
        VStack(spacing: 0) {
            Text("Discard this draft?")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.secondary)
                .padding(.vertical, 10)
            Divider()
            Text("Discard Draft")
                .foregroundStyle(.red)
                .padding(.vertical, 10)
            Divider()
            Text("Save Draft")
                .padding(.vertical, 10)
        }
        .font(.callout)
        .frame(width: 200)
        .glassEffect(.regular, in: .rect(cornerRadius: 22))
    }
}

// MARK: - Examples

private struct DialogExamples: View {
    @State private var fileToDelete: String?
    @State private var showDelete = false
    @State private var showShareOptions = false

    var body: some View {
        ExampleCard(
            title: "Confirm deleting a specific item",
            caption: "Use `presenting:` to pass the item into the actions, so the button knows what to delete.",
            code: """
            @State private var fileToDelete: String?
            @State private var showDelete = false

            Button("Delete Report.pdf", role: .destructive) {
                fileToDelete = "Report.pdf"
                showDelete = true
            }
            .confirmationDialog("Delete file?", isPresented: $showDelete, titleVisibility: .visible, presenting: fileToDelete) { file in
                Button("Delete \\(file)", role: .destructive) {
                    // Delete the file
                }
            }
            """,
            minHeight: 140
        ) {
            Button("Delete Report.pdf", role: .destructive) {
                fileToDelete = "Report.pdf"
                showDelete = true
            }
            .buttonStyle(.bordered)
            .confirmationDialog("Delete file?", isPresented: $showDelete, titleVisibility: .visible, presenting: fileToDelete) { file in
                Button("Delete \(file)", role: .destructive) {}
            }
        }

        ExampleCard(
            title: "Choose between actions",
            caption: "Leave the title hidden, and `.confirmationDialog` reads like a quick list of choices.",
            code: """
            @State private var showOptions = false

            Button("Add Photo", systemImage: "photo.badge.plus") {
                showOptions = true
            }
            .confirmationDialog("Add Photo", isPresented: $showOptions) {
                Button("Take Photo") {}
                Button("Choose from Library") {}
                Button("Browse Files") {}
            }
            """,
            minHeight: 140
        ) {
            Button("Add Photo", systemImage: "photo.badge.plus") {
                showShareOptions = true
            }
            .buttonStyle(.bordered)
            .confirmationDialog("Add Photo", isPresented: $showShareOptions) {
                Button("Take Photo") {}
                Button("Choose from Library") {}
                Button("Browse Files") {}
            }
        }
    }
}

/// A Close Draft button that asks with a dialog or an alert, for the guideline.
private struct DialogGuidelineSample: View {
    let usesDialog: Bool
    @State private var isPresented = false

    var body: some View {
        VStack(spacing: 10) {
            Button("Close Draft") { isPresented = true }
                .buttonStyle(.bordered)
                .confirmationDialog("Close this draft?", isPresented: usesDialog ? $isPresented : .constant(false)) {
                    Button("Delete Draft", role: .destructive) {}
                    Button("Save Draft") {}
                }
                .alert("Close this draft?", isPresented: usesDialog ? .constant(false) : $isPresented) {
                    Button("Delete Draft", role: .destructive) {}
                    Button("Save Draft") {}
                    Button("Cancel", role: .cancel) {}
                }
            Text("Tap to try it")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Options

private enum DialogTitleVisibility: DemoOption {
    case automatic, visible, hidden

    var label: String {
        switch self {
        case .automatic: ".automatic"
        case .visible: ".visible"
        case .hidden: ".hidden"
        }
    }

    var value: Visibility {
        switch self {
        case .automatic: .automatic
        case .visible: .visible
        case .hidden: .hidden
        }
    }
}