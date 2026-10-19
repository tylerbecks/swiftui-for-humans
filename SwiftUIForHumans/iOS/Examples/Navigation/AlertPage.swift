import SwiftUI

extension ComponentPage {
    static let alert = ComponentPage(
        id: "alert",
        title: "Alert",
        summary: "Interrupts with an important message and asks for a quick decision.",
        category: .presentation,
        symbol: "exclamationmark.bubble",
        availability: ["iOS 15.0+", "macOS 12.0+", "visionOS 1.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/view/alert(_:ispresented:actions:message:)",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/alerts",
        aliases: ["window.alert", "confirm()", "prompt()", "modal", "popup", "dialog", "UIAlertController", "error message", "are you sure"],
        related: ["confirmation-dialog", "sheet", "button"],
        notes: [
            "**Any button closes the alert.** It sets the binding back to `false` for you. With no buttons at all, SwiftUI adds an OK button.",
            "**Pick the right interruption.** Use an alert for something people must see now, a [Confirmation Dialog](catalog://confirmation-dialog) for a choice of actions, and inline text for anything that can wait.",
        ],
        api: [
            APIItem("`.alert(_:isPresented:actions:message:)`", "Shows a title, message, and buttons."),
            APIItem("`.alert(_:isPresented:presenting:)`", "Passes a value, like the item to delete."),
            APIItem("`.alert(isPresented:error:)`", "Builds the alert from a `LocalizedError`."),
            APIItem("`Button(role: .cancel)`", "Goes in the cancel spot."),
            APIItem("`Button(role: .destructive)`", "Turns the button red."),
            APIItem("`TextField` in the actions", "Asks for text, like JavaScript's `prompt()`."),
        ],
        guidelines: [
            Guideline(
                "Name the action on the button.",
                "“Delete” says exactly what will happen. “Yes” or “OK” makes people reread the title to find out.",
                good: "The button says what it does.",
                bad: "Yes and No make people reread."
            ) {
                AlertGuidelineSample(isGood: true)
            } bad: {
                AlertGuidelineSample(isGood: false)
            },
            Guideline(
                "Write a title that says what happened.",
                "“Upload Failed” tells people the problem. “Error” or an error code doesn't help them fix it."
            ),
            Guideline(
                "Use alerts sparingly.",
                "Each one interrupts. Skip them for actions people can undo, like deleting an email, and for information that isn't actionable."
            ),
            Guideline(
                "Don't show an alert at launch.",
                "People opened the app to do something. Show problems like a lost connection inline instead."
            ),
        ]
    ) {
        AlertThumbnail()
    } content: { page in
        AlertDemo(page: page)
    }
}

private struct AlertConfig {
    var title = "Delete Photo?"
    var message = true
    var buttons: AlertButtons = .cancelDelete
    var textField = false
    var isPresented = false
    var name = ""
    var result = "Tap the button"
}

private struct AlertDemo: View {
    let page: ComponentPage

    var body: some View {
        DemoPage(
            page: page,
            initial: AlertConfig(),
            previewHeight: 200,
            usage: """
            @State private var isPresented = false

            Button("Delete Photo", role: .destructive) {
                isPresented = true
            }
            .alert("Delete Photo?", isPresented: $isPresented) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    // Delete the photo
                }
            } message: {
                Text("This photo will be deleted from all your devices.")
            }
            """,
            usageNote: Aside(.note, "Roles place the buttons for you: `.cancel` goes in the cancel spot and `.destructive` turns red. You don't order them by hand.")
        ) { $config in
            VStack(spacing: 14) {
                Button("Show Alert") {
                    config.name = ""
                    config.isPresented = true
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                Text(config.result)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .alert(config.title, isPresented: $config.isPresented) {
                if config.textField {
                    TextField("Name", text: $config.name)
                }
                switch config.buttons {
                case .none:
                    EmptyView()
                case .ok:
                    Button("OK") { config.result = "Tapped OK" }
                case .cancelDelete:
                    Button("Cancel", role: .cancel) { config.result = "Tapped Cancel" }
                    Button("Delete", role: .destructive) { config.result = "Tapped Delete" }
                case .three:
                    Button("Save") { config.result = "Tapped Save" }
                    Button("Don't Save", role: .destructive) { config.result = "Tapped Don't Save" }
                    Button("Cancel", role: .cancel) { config.result = "Tapped Cancel" }
                }
            } message: {
                if config.message {
                    Text("This photo will be deleted from all your devices.")
                }
            }
        } controls: { $config in
            Section("Content") {
                TextField("Title", text: $config.title)
                Toggle("Message", isOn: $config.message)
                Toggle("Text field", isOn: $config.textField)
            }
            Section("Buttons") {
                OptionPicker("Buttons", selection: $config.buttons)
            }
        } code: { config in
            code(for: config)
        } examples: {
            AlertExamples()
        }
    }

    private func code(for config: AlertConfig) -> String {
        var lines = ["@State private var isPresented = false"]
        if config.textField {
            lines.append("@State private var name = \"\"")
        }
        lines += [
            "",
            "Button(\"Show Alert\") {",
            "    isPresented = true",
            "}",
            ".buttonStyle(.borderedProminent)",
        ]
        var actions: [String] = []
        if config.textField {
            actions.append("TextField(\"Name\", text: $name)")
        }
        switch config.buttons {
        case .none: break
        case .ok:
            actions.append("Button(\"OK\") {}")
        case .cancelDelete:
            actions += ["Button(\"Cancel\", role: .cancel) {}", "Button(\"Delete\", role: .destructive) {", "    // Delete the photo", "}"]
        case .three:
            actions += ["Button(\"Save\") {}", "Button(\"Don't Save\", role: .destructive) {}", "Button(\"Cancel\", role: .cancel) {}"]
        }
        let title = swiftString(config.title)
        if actions.isEmpty && !config.message {
            lines.append(".alert(\(title), isPresented: $isPresented) {}")
        } else {
            lines.append(".alert(\(title), isPresented: $isPresented) {")
            lines += actions.map { "    " + $0 }
            if config.message {
                lines += ["} message: {", "    Text(\"This photo will be deleted from all your devices.\")"]
            }
            lines.append("}")
        }
        return lines.joined(separator: "\n")
    }
}

private struct AlertThumbnail: View {
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 4) {
                Text("Delete Photo?")
                    .font(.headline)
                Text("This can't be undone.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 14)
            HStack(spacing: 8) {
                Text("Cancel")
                    .frame(maxWidth: .infinity, minHeight: 34)
                    .background(.fill.secondary, in: .capsule)
                Text("Delete")
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, minHeight: 34)
                    .background(.fill.secondary, in: .capsule)
            }
            .font(.subheadline.weight(.semibold))
            .padding([.horizontal, .bottom], 12)
        }
        .frame(width: 210)
        .glassEffect(.regular, in: .rect(cornerRadius: 26))
    }
}

// MARK: - Examples

private struct AlertExamples: View {
    @State private var photoToDelete: String?
    @State private var showDelete = false
    @State private var error: AlertError?
    @State private var showRename = false
    @State private var fileName = "Untitled"
    @State private var draftName = ""

    var body: some View {
        ExampleCard(
            title: "Confirm for a specific item",
            caption: "Use `presenting:` to hand the tapped item to the alert's buttons and message.",
            code: """
            @State private var photoToDelete: String?
            @State private var showDelete = false

            HStack {
                ForEach(["Beach", "Forest"], id: \\.self) { photo in
                    Button("Delete \\(photo)") {
                        photoToDelete = photo
                        showDelete = true
                    }
                }
            }
            .alert("Delete Photo?", isPresented: $showDelete, presenting: photoToDelete) { photo in
                Button("Delete", role: .destructive) {
                    // Delete photo
                }
            } message: { photo in
                Text("“\\(photo)” will be deleted from all your devices.")
            }
            """,
            minHeight: 120,
            aside: Aside(.note, "With only a destructive button, the alert adds Cancel for you.")
        ) {
            HStack {
                ForEach(["Beach", "Forest"], id: \.self) { photo in
                    Button("Delete \(photo)") {
                        photoToDelete = photo
                        showDelete = true
                    }
                }
            }
            .buttonStyle(.bordered)
            .alert("Delete Photo?", isPresented: $showDelete, presenting: photoToDelete) { _ in
                Button("Delete", role: .destructive) {}
            } message: { photo in
                Text("“\(photo)” will be deleted from all your devices.")
            }
        }

        ExampleCard(
            title: "Show an error",
            caption: "Use `.alert(isPresented:error:)` to build the alert from a `LocalizedError`.",
            code: """
            struct UploadError: LocalizedError {
                var errorDescription: String? { "Upload Failed" }
                var recoverySuggestion: String? { "Check your connection and try again." }
            }

            @State private var error: UploadError?

            Button("Upload") { error = UploadError() }
                .alert(
                    isPresented: Binding(get: { error != nil }, set: { if !$0 { error = nil } }),
                    error: error
                ) { _ in
                    Button("OK") {}
                } message: { error in
                    Text(error.recoverySuggestion ?? "")
                }
            """,
            minHeight: 120,
            aside: Aside(.important, "Set the error back to `nil` when the alert closes, as the binding here does, or it can't show again.")
        ) {
            Button("Upload") { error = AlertError() }
                .buttonStyle(.bordered)
                .alert(
                    isPresented: Binding(get: { error != nil }, set: { if !$0 { error = nil } }),
                    error: error
                ) { _ in
                    Button("OK") {}
                } message: { error in
                    Text(error.recoverySuggestion ?? "")
                }
        }

        ExampleCard(
            title: "Rename prompt",
            caption: "Put a `TextField` in the actions to ask for a short piece of text, like a new name.",
            code: """
            @State private var showRename = false
            @State private var fileName = "Untitled"
            @State private var draftName = ""

            Button("Rename \\(fileName)") {
                draftName = fileName
                showRename = true
            }
            .alert("Rename File", isPresented: $showRename) {
                TextField("Name", text: $draftName)
                Button("Cancel", role: .cancel) {}
                Button("Rename") { fileName = draftName }
            }
            """,
            minHeight: 120,
            aside: Aside(.note, "Edit a copy of the name, so Cancel leaves the original alone.")
        ) {
            Button("Rename \(fileName)") {
                draftName = fileName
                showRename = true
            }
            .buttonStyle(.bordered)
            .alert("Rename File", isPresented: $showRename) {
                TextField("Name", text: $draftName)
                Button("Cancel", role: .cancel) {}
                Button("Rename") { fileName = draftName }
            }
        }
    }
}

private struct AlertError: LocalizedError {
    var errorDescription: String? { "Upload Failed" }
    var recoverySuggestion: String? { "Check your connection and try again." }
}

/// A button that shows a well- or badly-worded alert, for the button guideline.
private struct AlertGuidelineSample: View {
    let isGood: Bool
    @State private var isPresented = false

    var body: some View {
        VStack(spacing: 10) {
            Button("Delete Photo", role: .destructive) { isPresented = true }
                .buttonStyle(.bordered)
            Text("Tap to see the alert")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .alert(isGood ? "Delete Photo?" : "Are you sure?", isPresented: $isPresented) {
            if isGood {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {}
            } else {
                Button("No", role: .cancel) {}
                Button("Yes") {}
            }
        } message: {
            Text(isGood ? "This photo will be deleted from all your devices." : "Do you want to continue?")
        }
    }
}

// MARK: - Options

private enum AlertButtons: DemoOption {
    case none, ok, cancelDelete, three

    var label: String {
        switch self {
        case .none: "None (automatic OK)"
        case .ok: "OK"
        case .cancelDelete: "Cancel + Delete"
        case .three: "Save, Don't Save, Cancel"
        }
    }
}