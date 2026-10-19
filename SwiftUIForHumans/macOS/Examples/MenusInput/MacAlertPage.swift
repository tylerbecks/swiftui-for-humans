import SwiftUI

extension ComponentPage {
    static let alert = ComponentPage(
        id: "alert",
        title: "Alert & dialogs",
        summary: "Stop to confirm a risky action or report a problem that needs a decision.",
        category: .presentation,
        kind: .modifier,
        symbol: "exclamationmark.triangle",
        availability: ["macOS 12.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/view/alert(_:ispresented:actions:message:)",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/alerts",
        aliases: ["NSAlert", "confirmationDialog", "confirmation dialog", "action sheet", "dialog", "window.confirm", "confirm()", "are you sure", "do not show again", "don't ask again", "suppression", "dialogSeverity", "critical", "dialogSuppressionToggle", "dialogIcon"],
        related: ["sheet", "popover", "button", "keyboard-shortcuts"],
        notes: [
            "**Every button closes the dialog.** SwiftUI sets the binding back to `false` after the button's action runs.",
            "**A confirmation dialog comes with a way out.** It adds a standard dismiss button; a button with the `.cancel` role takes its place.",
            "**The Mac puts your app icon in the dialog.** Use `.dialogIcon(_:)` to show a different image.",
        ],
        api: [
            APIItem("`.alert(_:isPresented:actions:message:)`", "A title, message, and buttons."),
            APIItem("`.alert(_:isPresented:presenting:)`", "Builds the alert from a value, like an error."),
            APIItem("`.confirmationDialog(_:isPresented:)`", "Confirms an action people started."),
            APIItem("`.dialogSeverity(.critical)`", "Adds a caution symbol for real danger."),
            APIItem("`.dialogSuppressionToggle(isSuppressed:)`", "A checkbox to stop asking."),
            APIItem("`.dialogIcon(_:)`", "Replaces the app icon in the dialog."),
            APIItem("`Button(role: .cancel)`", "The Cancel button, placed for you."),
        ],
        guidelines: [
            Guideline(
                "Name the action on the button.",
                "“Delete” says what happens. “OK” could mean “do it” or “I understand”, so save it for alerts that only inform.",
                good: "The button says what it does.",
                bad: "OK makes people reread the title."
            ) {
                AlertDrawing(confirm: "Delete")
            } bad: {
                AlertDrawing(confirm: "OK")
            },
            Guideline(
                "Use alerts sparingly.",
                "Each one interrupts. Don't ask before common actions people can undo, like deleting an email, and don't use an alert just to inform."
            ),
            Guideline(
                "Write a title that says what happened.",
                "Describe the situation in a line or two. A title like “Error” or an error code doesn't help anyone fix it."
            ),
            Guideline(
                "Mark a button destructive only when people didn't choose that action.",
                "If someone chose Empty Trash, the dialog's Empty Trash button does what they asked, so Return should run it. Use `.destructive` for a side effect they might not expect."
            ),
            Guideline(
                "Save the caution symbol for real danger.",
                "`.dialogSeverity(.critical)` adds it. Used often, it stops meaning anything, so keep it for unexpected data loss, not routine saving or deleting."
            ),
        ]
    ) {
        AlertDrawing(confirm: "Delete")
            .scaleEffect(0.8)
    } content: { page in
        MacAlertDemo(page: page)
    }
}

private struct MacAlertConfig {
    var kind: DialogKindOption = .alert
    var severity: DialogSeverityOption = .automatic
    var hasMessage = true
    var isDestructive = true
    var offersSuppression = false
    var isSuppressed = false
    var isPresented = false
    var result = "Click the button."
}

private struct MacAlertDemo: View {
    let page: ComponentPage

    var body: some View {
        DemoPage(
            page: page,
            initial: MacAlertConfig(),
            previewHeight: 200,
            usage: """
            @State private var isConfirming = false

            Button("Revert…") { isConfirming = true }
                .alert("Revert to the last saved version?", isPresented: $isConfirming) {
                    Button("Cancel", role: .cancel) { }
                    Button("Revert") { revert() }
                } message: {
                    Text("Changes since you last saved will be lost.")
                }
            """,
            usageNote: Aside(.note, "Give Cancel the `.cancel` role instead of ordering buttons by hand. SwiftUI may reorder buttons by their role and prominence.")
        ) { $config in
            VStack(spacing: 14) {
                Button("Delete Project…") {
                    if config.offersSuppression && config.isSuppressed {
                        config.result = "Deleted without asking. Reset to see the alert again."
                    } else {
                        config.isPresented = true
                    }
                }
                .controlSize(.large)
                Text(config.result)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .modifier(DemoDialog(config: $config))
            .modifier(DemoSeverity(severity: config.severity))
            .modifier(DemoSuppression(isOn: config.offersSuppression, isSuppressed: $config.isSuppressed))
        } controls: { $config in
            Section("Dialog") {
                OptionPicker("Kind", selection: $config.kind)
                OptionPicker("Severity", selection: $config.severity)
                Toggle("Message", isOn: $config.hasMessage)
                Toggle("Destructive role", isOn: $config.isDestructive)
                Toggle("Don't ask again", isOn: $config.offersSuppression)
            }
        } code: { config in
            let modifier = config.kind == .alert ? ".alert" : ".confirmationDialog"
            let role = config.isDestructive ? ", role: .destructive" : ""
            var lines = [
                "@State private var isConfirming = false",
            ]
            if config.offersSuppression {
                lines.append("@AppStorage(\"skipDeleteAlert\") private var skipsAlert = false")
            }
            lines.append("")
            if config.offersSuppression {
                lines.append("Button(\"Delete Project…\") {")
                lines.append("    if skipsAlert { deleteProject() } else { isConfirming = true }")
                lines.append("}")
            } else {
                lines.append("Button(\"Delete Project…\") { isConfirming = true }")
            }
            lines.append("    \(modifier)(\"Delete “Garden Plan”?\", isPresented: $isConfirming) {")
            lines.append("        Button(\"Cancel\", role: .cancel) { }")
            lines.append("        Button(\"Delete\"\(role)) { deleteProject() }")
            if config.hasMessage {
                lines.append("    } message: {")
                lines.append("        Text(\"Its files are removed from all your Macs.\")")
            }
            lines.append("    }")
            if config.severity != .automatic {
                lines.append("    .dialogSeverity(\(config.severity.label))")
            }
            if config.offersSuppression {
                lines.append("    .dialogSuppressionToggle(isSuppressed: $skipsAlert)")
            }
            return lines.joined(separator: "\n")
        } examples: {
            MacAlertExamples()
        }
    }
}

/// Presents the demo's alert or confirmation dialog.
private struct DemoDialog: ViewModifier {
    @Binding var config: MacAlertConfig

    private var title: String { "Delete “Garden Plan”?" }

    func body(content: Content) -> some View {
        switch config.kind {
        case .alert:
            content.alert(title, isPresented: $config.isPresented) {
                buttons
            } message: {
                message
            }
        case .confirmationDialog:
            content.confirmationDialog(title, isPresented: $config.isPresented) {
                buttons
            } message: {
                message
            }
        }
    }

    @ViewBuilder private var buttons: some View {
        Button("Cancel", role: .cancel) { config.result = "Canceled." }
        Button("Delete", role: config.isDestructive ? .destructive : nil) {
            config.result = "Deleted “Garden Plan”."
        }
    }

    @ViewBuilder private var message: some View {
        if config.hasMessage {
            Text("Its files are removed from all your Macs.")
        }
    }
}

private struct DemoSeverity: ViewModifier {
    let severity: DialogSeverityOption

    func body(content: Content) -> some View {
        switch severity {
        case .automatic: content
        case .standard: content.dialogSeverity(.standard)
        case .critical: content.dialogSeverity(.critical)
        }
    }
}

private struct DemoSuppression: ViewModifier {
    let isOn: Bool
    @Binding var isSuppressed: Bool

    func body(content: Content) -> some View {
        if isOn {
            content.dialogSuppressionToggle(isSuppressed: $isSuppressed)
        } else {
            content
        }
    }
}

// MARK: - Examples

private struct SaveFailure: Error {
    let documentName: String
}

private struct MacAlertExamples: View {
    @State private var failure: SaveFailure?
    @State private var isShowingFailure = false
    @AppStorage("demo.alert.skipsEmptyAlert") private var skipsEmptyAlert = false
    @State private var isConfirmingEmpty = false
    @State private var emptyResult = "Click Empty Trash."

    var body: some View {
        ExampleCard(
            title: "Report a problem",
            caption: "`.alert(_:isPresented:presenting:)` builds the alert from a value, like the error you caught, and passes it to the buttons and message.",
            code: """
            @State private var failure: SaveFailure?
            @State private var isShowingFailure = false

            Button("Save") {
                failure = SaveFailure(documentName: "Trip Notes")
                isShowingFailure = true
            }
            .alert("Couldn't Save Your Changes", isPresented: $isShowingFailure, presenting: failure) { _ in
                Button("OK") { }
            } message: { failure in
                Text("“\\(failure.documentName)” is on a disk that's full. Free up space and try again.")
            }
            """,
            minHeight: 140,
            aside: Aside(.note, "OK fits here: the alert only informs, and there's nothing to choose.")
        ) {
            Button("Save") {
                failure = SaveFailure(documentName: "Trip Notes")
                isShowingFailure = true
            }
            .alert("Couldn't Save Your Changes", isPresented: $isShowingFailure, presenting: failure) { _ in
                Button("OK") { }
            } message: { failure in
                Text("“\(failure.documentName)” is on a disk that's full. Free up space and try again.")
            }
        }

        ExampleCard(
            title: "Let people stop the question",
            caption: "`.dialogSuppressionToggle` adds a checkbox to the dialog. Save its value with `@AppStorage`, and skip the dialog once it's on.",
            code: """
            @AppStorage("skipsEmptyAlert") private var skipsEmptyAlert = false
            @State private var isConfirming = false

            Button("Empty Trash…") {
                if skipsEmptyAlert { emptyTrash() } else { isConfirming = true }
            }
            .confirmationDialog("Empty the Trash?", isPresented: $isConfirming) {
                Button("Empty Trash") { emptyTrash() }
            } message: {
                Text("You can't undo this.")
            }
            .dialogSuppressionToggle(isSuppressed: $skipsEmptyAlert)
            """,
            minHeight: 160,
            aside: Aside(.note, "Empty Trash isn't marked destructive: people chose it on purpose, so Return confirms it. Offer the checkbox for questions people see often.")
        ) {
            VStack(spacing: 12) {
                Button("Empty Trash…") {
                    if skipsEmptyAlert {
                        emptyResult = "Emptied without asking."
                    } else {
                        isConfirmingEmpty = true
                    }
                }
                .confirmationDialog("Empty the Trash?", isPresented: $isConfirmingEmpty) {
                    Button("Empty Trash") { emptyResult = "Emptied the Trash." }
                } message: {
                    Text("You can't undo this.")
                }
                .dialogSuppressionToggle(isSuppressed: $skipsEmptyAlert)

                Text(emptyResult)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                if skipsEmptyAlert {
                    Button("Ask Again") {
                        skipsEmptyAlert = false
                        emptyResult = "The dialog is back."
                    }
                    .controlSize(.small)
                }
            }
        }
    }
}

/// A still drawing of a two-button alert, for the guideline previews.
private struct AlertDrawing: View {
    let confirm: String

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "app.dashed")
                .font(.system(size: 30))
                .foregroundStyle(.secondary)
            Text("Delete “Garden Plan”?")
                .font(.callout.bold())
            Text("Its files are removed from all your Macs.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            HStack {
                Button("Cancel") {}
                    .frame(maxWidth: .infinity)
                Button(confirm) {}
                    .buttonStyle(.borderedProminent)
                    .frame(maxWidth: .infinity)
            }
            .allowsHitTesting(false)
        }
        .padding(16)
        .frame(width: 230)
        .background(.background.secondary, in: .rect(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(.separator)
        }
        .shadow(color: .black.opacity(0.15), radius: 8, y: 3)
    }
}

// MARK: - Options

private enum DialogKindOption: DemoOption {
    case alert, confirmationDialog

    var label: String {
        switch self {
        case .alert: "Alert"
        case .confirmationDialog: "Confirmation"
        }
    }
}

private enum DialogSeverityOption: DemoOption {
    case automatic, standard, critical

    var label: String {
        switch self {
        case .automatic: ".automatic"
        case .standard: ".standard"
        case .critical: ".critical"
        }
    }
}
