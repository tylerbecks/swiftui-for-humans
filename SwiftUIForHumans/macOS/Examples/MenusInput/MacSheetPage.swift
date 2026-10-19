import SwiftUI

extension ComponentPage {
    static let sheet = ComponentPage(
        id: "sheet",
        title: "Sheet",
        summary: "A card attached to its window, for a short task like adding an item.",
        category: .presentation,
        kind: .modifier,
        symbol: "rectangle.portrait.on.rectangle.portrait",
        availability: ["macOS 10.15+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/view/sheet(ispresented:ondismiss:content:)",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/sheets",
        aliases: ["modal", "dialog", "window-modal", "beginSheet", "presentAsSheet", "NSWindow sheet", "dismiss", "presentationSizing", "<dialog>", "modal dialog"],
        related: ["alert", "popover", "window", "opening-windows", "keyboard-shortcuts"],
        notes: [
            "**A sheet blocks only its own window.** The window behind it dims and waits, but people can still switch to your app's other windows.",
            "**Call `dismiss` from inside the sheet.** Read `@Environment(\\.dismiss)` in the sheet's own view. Read in the view that presents the sheet, it would dismiss that view instead.",
        ],
        api: [
            APIItem("`.sheet(isPresented:)`", "Shows the sheet while a `Bool` is true."),
            APIItem("`.sheet(item:)`", "Shows a sheet for an item, like the one to edit."),
            APIItem("`@Environment(\\.dismiss)`", "Closes the sheet from inside it."),
            APIItem("`.presentationSizing(_:)`", "`.form`, `.page`, or `.fitted` to the content."),
            APIItem("`.frame(width:height:)`", "A fixed size; the sheet can't be resized."),
            APIItem("`.keyboardShortcut(.defaultAction)`", "Return runs the main button."),
        ],
        guidelines: [
            Guideline(
                "Pair the confirming button with Cancel.",
                "A sheet with only Add or Done suggests finishing is the only way out. Cancel lets people leave without saving.",
                good: "Cancel and Add, so people can back out.",
                bad: "Add is the only way out."
            ) {
                SheetDrawing(showsCancel: true)
            } bad: {
                SheetDrawing(showsCancel: false)
            },
            Guideline(
                "Open at a size that fits the content.",
                "People don't usually resize sheets, so pick a sensible size. Allow resizing when the content benefits from more room."
            ),
            Guideline(
                "Show one sheet at a time.",
                "Closing a sheet should return people to the window. If a step needs another sheet, close the first one before you show the next."
            ),
            Guideline(
                "Use a window or panel for long or repeated work.",
                "A sheet suits a quick, self-contained task. For editing at length, open a window. For input people give again and again while watching the result, use a panel."
            ),
        ]
    ) {
        MacWindowFrame(title: "Calendar", width: 210, height: 130) {
            SheetDrawing(showsCancel: true)
                .scaleEffect(0.7)
                .frame(maxHeight: .infinity, alignment: .top)
        }
    } content: { page in
        MacSheetDemo(page: page)
    }
}

private struct MacSheetConfig {
    var sizing: SheetSizingOption = .automatic
    var fixedWidth = true
    var isPresented = false
    var result = "No events added yet."
}

private struct MacSheetDemo: View {
    let page: ComponentPage

    var body: some View {
        DemoPage(
            page: page,
            initial: MacSheetConfig(),
            previewHeight: 200,
            usage: """
            @State private var isAdding = false

            Button("New Event…") { isAdding = true }
                .sheet(isPresented: $isAdding) {
                    NewEventForm()
                }

            struct NewEventForm: View {
                @Environment(\\.dismiss) private var dismiss
                @State private var title = ""

                var body: some View {
                    VStack(alignment: .trailing) {
                        TextField("Title", text: $title)
                        HStack {
                            Button("Cancel", role: .cancel) { dismiss() }
                                .keyboardShortcut(.cancelAction)
                            Button("Add") { dismiss() }
                                .keyboardShortcut(.defaultAction)
                        }
                    }
                    .padding()
                    .frame(width: 360)
                }
            }
            """,
            usageNote: Aside(.note, "End the button's title with … because it opens a sheet that asks for more. Return and Escape run Add and Cancel through their shortcuts.")
        ) { $config in
            VStack(spacing: 14) {
                Button("New Event…") { config.isPresented = true }
                    .controlSize(.large)
                Text(config.result)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .sheet(isPresented: $config.isPresented) {
                NewEventSheet(fixedWidth: config.fixedWidth) { title in
                    config.result = "Added “\(title)”."
                }
                .sizing(config.sizing)
            }
        } controls: { $config in
            Section("Size") {
                OptionPicker("Sizing", selection: $config.sizing)
                Toggle("Fixed width", isOn: $config.fixedWidth)
            }
        } code: { config in
            var lines = [
                "@State private var isAdding = false",
                "",
                "Button(\"New Event…\") { isAdding = true }",
                "    .sheet(isPresented: $isAdding) {",
                "        NewEventForm()",
            ]
            if config.fixedWidth {
                lines.append("            .frame(width: 360)")
            }
            if config.sizing != .automatic {
                lines.append("            .presentationSizing(\(config.sizing.label))")
            }
            lines.append("    }")
            return lines.joined(separator: "\n")
        } examples: {
            MacSheetExamples()
        }
    }
}

/// The add-event form shown in the demo's sheet.
private struct NewEventSheet: View {
    var fixedWidth = true
    let onAdd: (String) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var title = "Lunch with Sam"
    @State private var date = Date.now

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("New Event")
                .font(.headline)
            Form {
                TextField("Title", text: $title)
                DatePicker("Starts", selection: $date)
            }
            HStack {
                Spacer()
                Button("Cancel", role: .cancel) { dismiss() }
                    .keyboardShortcut(.cancelAction)
                Button("Add") {
                    onAdd(title)
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
                .disabled(title.isEmpty)
            }
        }
        .padding(20)
        .frame(width: fixedWidth ? 360 : nil)
    }
}

// MARK: - Examples

private struct EventItem: Identifiable {
    let id: Int
    var title: String
}

private struct MacSheetExamples: View {
    @State private var events = [EventItem(id: 1, title: "Design review"), EventItem(id: 2, title: "Dentist")]
    @State private var editing: EventItem?
    @State private var isShowingNotes = false

    var body: some View {
        ExampleCard(
            title: "Edit an item",
            caption: "`.sheet(item:)` shows a sheet for the item you set and clears it when the sheet closes, for “edit this one” tasks.",
            code: """
            @State private var editing: Event?

            VStack {
                ForEach(events) { event in
                    HStack {
                        Text(event.title)
                        Spacer()
                        Button("Edit…") { editing = event }
                    }
                }
            }
            .sheet(item: $editing) { event in
                EventEditor(event: event)
            }
            """,
            minHeight: 170
        ) {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(events) { event in
                    HStack {
                        Text(event.title)
                        Spacer()
                        Button("Edit…") { editing = event }
                    }
                }
            }
            .frame(width: 280)
            .sheet(item: $editing) { event in
                RenameEventSheet(title: event.title) { newTitle in
                    if let index = events.firstIndex(where: { $0.id == event.id }) {
                        events[index].title = newTitle
                    }
                }
            }
        }

        ExampleCard(
            title: "A sheet people can resize",
            caption: "`.presentationSizing(.fitted)` sizes the sheet to its content, and a minimum and maximum frame let people resize it between them.",
            code: """
            .sheet(isPresented: $isShowingNotes) {
                NotesEditor()
                    .frame(minWidth: 320, idealWidth: 420, maxWidth: 700,
                           minHeight: 200, idealHeight: 280, maxHeight: 600)
                    .presentationSizing(.fitted)
            }
            """,
            minHeight: 150,
            aside: Aside(.note, "On the Mac, a `.fitted` sheet can be resized unless you fix its size with `.fixedSize()` or a fixed frame.")
        ) {
            Button("Edit Notes…") { isShowingNotes = true }
                .sheet(isPresented: $isShowingNotes) {
                    ResizableNotesSheet()
                        .frame(minWidth: 320, idealWidth: 420, maxWidth: 700, minHeight: 200, idealHeight: 280, maxHeight: 600)
                        .presentationSizing(.fitted)
                }
        }
    }
}

private struct RenameEventSheet: View {
    @State var title: String
    let onSave: (String) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Edit Event")
                .font(.headline)
            TextField("Title", text: $title)
            HStack {
                Spacer()
                Button("Cancel", role: .cancel) { dismiss() }
                    .keyboardShortcut(.cancelAction)
                Button("Save") {
                    onSave(title)
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding(20)
        .frame(width: 320)
    }
}

private struct ResizableNotesSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var notes = "Drag the sheet's edge to make it bigger."

    var body: some View {
        VStack(alignment: .trailing, spacing: 12) {
            TextEditor(text: $notes)
                .font(.body)
            Button("Done") { dismiss() }
                .keyboardShortcut(.defaultAction)
        }
        .padding(20)
    }
}

/// A still drawing of an add-event sheet, for the guideline previews and
/// the thumbnail.
private struct SheetDrawing: View {
    let showsCancel: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("New Event")
                .font(.headline)
            Text("Lunch with Sam")
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.background, in: .rect(cornerRadius: 5))
                .overlay {
                    RoundedRectangle(cornerRadius: 5)
                        .strokeBorder(.separator)
                }
            HStack {
                Spacer()
                if showsCancel {
                    Button("Cancel") {}
                }
                Button("Add") {}
                    .buttonStyle(.borderedProminent)
            }
            .allowsHitTesting(false)
        }
        .padding(14)
        .frame(width: 230)
        .background(.background.secondary, in: .rect(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(.separator)
        }
        .shadow(color: .black.opacity(0.15), radius: 8, y: 3)
    }
}

// MARK: - Options

private enum SheetSizingOption: DemoOption {
    case automatic, form, page, fitted

    var label: String {
        switch self {
        case .automatic: ".automatic"
        case .form: ".form"
        case .page: ".page"
        case .fitted: ".fitted"
        }
    }
}

private extension View {
    @ViewBuilder
    func sizing(_ option: SheetSizingOption) -> some View {
        switch option {
        case .automatic: presentationSizing(.automatic)
        case .form: presentationSizing(.form)
        case .page: presentationSizing(.page)
        case .fitted: presentationSizing(.fitted)
        }
    }
}
