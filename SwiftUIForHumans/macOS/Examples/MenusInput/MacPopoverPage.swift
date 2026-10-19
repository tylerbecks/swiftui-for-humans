import SwiftUI

extension ComponentPage {
    static let popover = ComponentPage(
        id: "popover",
        title: "Popover",
        summary: "A small panel that points at its control and closes when people click away.",
        category: .presentation,
        kind: .modifier,
        symbol: "bubble.middle.top",
        availability: ["macOS 10.15+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/view/popover(ispresented:attachmentanchor:arrowedge:content:)",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/popovers",
        aliases: ["NSPopover", "callout", "bubble", "flyout", "popup", "pop-up", "arrowEdge", "attachmentAnchor", "tooltip panel", "dropdown panel"],
        related: ["sheet", "tooltips", "menu", "toolbar"],
        notes: [
            "**Clicking outside closes it.** A popover doesn't block the window, so it goes away as soon as people click elsewhere.",
            "**The Mac respects `arrowEdge`.** Leave it out to let the system pick the side that fits.",
        ],
        api: [
            APIItem("`.popover(isPresented:)`", "Shows the popover while a `Bool` is true."),
            APIItem("`arrowEdge:`", "The edge of the control the arrow sits on."),
            APIItem("`attachmentAnchor:`", "Where it points: the view's bounds or a point."),
            APIItem("`.popover(item:)`", "Shows a popover for an item."),
            APIItem("`@Environment(\\.dismiss)`", "Closes it from inside, like after a choice."),
        ],
        guidelines: [
            Guideline(
                "Keep it small, with a few related controls.",
                "A popover is for a quick look or change, like an event's time. Make it only as big as its content."
            ),
            Guideline(
                "Save changes when it closes.",
                "People close popovers by clicking away, often by accident. Keep their edits, and discard them only when they click an explicit Cancel."
            ),
            Guideline(
                "Point at the control that opened it.",
                "Aim the arrow straight at it, and avoid covering it or content people need while the popover is open."
            ),
            Guideline(
                "Show one at a time, and nothing on top.",
                "Close an open popover before showing another. Only an alert should ever appear over one."
            ),
            Guideline(
                "Don't put a warning in a popover.",
                "People can miss it or close it by accident. Use an alert for anything they must read."
            ),
        ]
    ) {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Design Review")
                    .font(.caption.bold())
                Text("Tue, 10:00 – 11:00")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .padding(10)
            .background(.background, in: .rect(cornerRadius: 8))
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(.separator)
            }
            Image(systemName: "arrowtriangle.down.fill")
                .font(.caption)
                .foregroundStyle(.separator)
                .offset(y: -3)
            Image(systemName: "calendar")
                .font(.title)
                .foregroundStyle(.tint)
        }
    } content: { page in
        MacPopoverDemo(page: page)
    }
}

private struct MacPopoverConfig {
    var edge: PopoverEdgeOption = .automatic
    var isPresented = false
    var isAllDay = false
    var calendar = "Work"
}

private struct MacPopoverDemo: View {
    let page: ComponentPage

    var body: some View {
        DemoPage(
            page: page,
            initial: MacPopoverConfig(),
            previewHeight: 150,
            usage: """
            @State private var isShowingDetails = false

            Button("Details", systemImage: "info.circle") {
                isShowingDetails = true
            }
            .popover(isPresented: $isShowingDetails) {
                EventDetails()
                    .padding()
            }
            """,
            usageNote: Aside(.note, "Keep the state the popover edits outside it, in the view that shows it. Then clicking away, which closes the popover, never loses a change.")
        ) { $config in
            VStack(spacing: 14) {
                Button("Details", systemImage: "info.circle") {
                    config.isPresented = true
                }
                .controlSize(.large)
                .modifier(DemoPopover(config: $config))
                Text("\(config.calendar) · \(config.isAllDay ? "All day" : "10:00 – 11:00")")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        } controls: { $config in
            Section("Popover") {
                OptionPicker("Arrow edge", selection: $config.edge)
            }
        } code: { config in
            let edge = config.edge == .automatic ? "" : ", arrowEdge: \(config.edge.label)"
            return """
            @State private var isShowingDetails = false

            Button("Details", systemImage: "info.circle") {
                isShowingDetails = true
            }
            .popover(isPresented: $isShowingDetails\(edge)) {
                EventDetails()
                    .padding()
            }
            """
        } examples: {
            MacPopoverExamples()
        }
    }
}

private struct DemoPopover: ViewModifier {
    @Binding var config: MacPopoverConfig

    func body(content: Content) -> some View {
        if let edge = config.edge.edge {
            content.popover(isPresented: $config.isPresented, arrowEdge: edge) {
                EventDetailsForm(isAllDay: $config.isAllDay, calendar: $config.calendar)
            }
        } else {
            content.popover(isPresented: $config.isPresented) {
                EventDetailsForm(isAllDay: $config.isAllDay, calendar: $config.calendar)
            }
        }
    }
}

/// The popover's content. Changes apply right away, so clicking outside
/// never loses them.
private struct EventDetailsForm: View {
    @Binding var isAllDay: Bool
    @Binding var calendar: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Design Review")
                .font(.headline)
            Toggle("All-day", isOn: $isAllDay)
            Picker("Calendar", selection: $calendar) {
                ForEach(["Work", "Home", "Family"], id: \.self) { Text($0) }
            }
            .fixedSize()
        }
        .padding()
    }
}

// MARK: - Examples

private struct MacPopoverExamples: View {
    @State private var isShowingFilters = false
    @State private var showsUnread = true
    @State private var showsFlagged = false
    @State private var isPickingLabel = false
    @State private var label = "Work"

    var body: some View {
        ExampleCard(
            title: "From a toolbar button",
            caption: "A `.popover` suits a toolbar button with a few options, like filters, that apply as soon as people change them.",
            code: """
            @State private var isShowingFilters = false
            @State private var showsUnread = true
            @State private var showsFlagged = false

            .toolbar {
                Button("Filter", systemImage: "line.3.horizontal.decrease.circle") {
                    isShowingFilters = true
                }
                .popover(isPresented: $isShowingFilters, arrowEdge: .bottom) {
                    VStack(alignment: .leading) {
                        Toggle("Unread", isOn: $showsUnread)
                        Toggle("Flagged", isOn: $showsFlagged)
                    }
                    .padding()
                }
            }
            """,
            minHeight: 220,
            aside: Aside(.note, "A real `.toolbar` here would land in this window's own toolbar, so the preview draws one. The button and popover are real.")
        ) {
            MacWindowFrame(title: "Inbox", width: 380, height: 180) {
                VStack(spacing: 4) {
                    Text(filterSummary)
                        .foregroundStyle(.secondary)
                }
            } toolbar: {
                Button("Filter", systemImage: "line.3.horizontal.decrease.circle") {
                    isShowingFilters = true
                }
                .labelStyle(.iconOnly)
                .buttonStyle(.borderless)
                .help("Filter messages")
                .popover(isPresented: $isShowingFilters, arrowEdge: .bottom) {
                    VStack(alignment: .leading) {
                        Toggle("Unread", isOn: $showsUnread)
                        Toggle("Flagged", isOn: $showsFlagged)
                    }
                    .padding()
                }
            }
        }

        ExampleCard(
            title: "Close it after a choice",
            caption: "When people pick one thing, close the popover for them: call `dismiss` from `@Environment(\\.dismiss)` inside it.",
            code: """
            @State private var isPickingLabel = false
            @State private var label = "Work"

            Button(label, systemImage: "tag") { isPickingLabel = true }
                .popover(isPresented: $isPickingLabel) {
                    LabelPicker(selection: $label)
                }

            struct LabelPicker: View {
                @Binding var selection: String
                @Environment(\\.dismiss) private var dismiss

                var body: some View {
                    VStack(alignment: .leading) {
                        ForEach(["Work", "Home", "Travel"], id: \\.self) { name in
                            Button(name) {
                                selection = name
                                dismiss()
                            }
                        }
                    }
                    .buttonStyle(.borderless)
                    .padding()
                }
            }
            """,
            minHeight: 150
        ) {
            Button(label, systemImage: "tag") { isPickingLabel = true }
                .popover(isPresented: $isPickingLabel) {
                    PopoverLabelPicker(selection: $label)
                }
        }

        VStack(alignment: .leading, spacing: 14) {
            Text("Popover or sheet?")
                .font(.title3.bold())
                .outlineEntry("Popover or sheet?", level: 2)
            RichText("Both show extra content over a window. Choose by how much attention the task needs.")
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            ConnectFacts(rows: [
                ("Popover", "Points at a control and closes when people click outside it. For a quick look or a small change, while the rest of the window stays in view."),
                ("Sheet", "Attached to the window, which waits until people finish or cancel. For a task with a clear end, like adding an event. See [Sheet](catalog://sheet)."),
            ])
        }
    }

    private var filterSummary: String {
        switch (showsUnread, showsFlagged) {
        case (true, true): "Unread and flagged messages"
        case (true, false): "Unread messages"
        case (false, true): "Flagged messages"
        case (false, false): "All messages"
        }
    }
}

private struct PopoverLabelPicker: View {
    @Binding var selection: String
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading) {
            ForEach(["Work", "Home", "Travel"], id: \.self) { name in
                Button(name) {
                    selection = name
                    dismiss()
                }
            }
        }
        .buttonStyle(.borderless)
        .padding()
    }
}

// MARK: - Options

private enum PopoverEdgeOption: DemoOption {
    case automatic, top, bottom, leading, trailing

    var label: String {
        switch self {
        case .automatic: "Automatic"
        case .top: ".top"
        case .bottom: ".bottom"
        case .leading: ".leading"
        case .trailing: ".trailing"
        }
    }

    var edge: Edge? {
        switch self {
        case .automatic: nil
        case .top: .top
        case .bottom: .bottom
        case .leading: .leading
        case .trailing: .trailing
        }
    }
}
