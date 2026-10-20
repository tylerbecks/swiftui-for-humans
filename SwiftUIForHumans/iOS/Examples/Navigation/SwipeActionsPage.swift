import SwiftUI

extension ComponentPage {
    static let swipeActions = ComponentPage(
        id: "swipe-actions",
        title: "Swipe Actions & Editing",
        summary: "Lets people swipe rows for actions, delete and reorder them, and pull to refresh.",
        category: .lists,
        kind: .modifier,
        symbol: "hand.draw",
        availability: ["iOS 15.0+", "macOS 12.0+", "visionOS 1.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/view/swipeactions(edge:allowsfullswipe:content:)",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/lists-and-tables",
        aliases: ["swipe to delete", "slide to delete", "drag to reorder", "sortable", "pull to refresh", "onDelete", "edit mode", "UIContextualAction", "trailingSwipeActions"],
        related: ["list", "context-menu", "toolbar"],
        notes: [
            "**These only work in a `List`.** Swipe actions, `.onDelete`, and `.onMove` need list rows. `.refreshable` also works on a `ScrollView`.",
        ],
        api: [
            APIItem("`.swipeActions(edge:)`", "Buttons revealed by swiping a row; `.leading` or `.trailing`."),
            APIItem("`allowsFullSwipe:`", "Runs the first button on a full swipe. On by default."),
            APIItem("`Button(role: .destructive)`", "A red button that animates the row away."),
            APIItem("`.tint(_:)`", "The color of any other swipe button."),
            APIItem("`.onDelete(perform:)`", "On a `ForEach`: swipe to delete, plus edit mode."),
            APIItem("`.onMove(perform:)`", "On a `ForEach`: drag to reorder in edit mode."),
            APIItem("`EditButton()`", "Toggles edit mode from the toolbar."),
            APIItem("`.refreshable { }`", "Pull to refresh with an `async` action."),
        ],
        guidelines: [
            Guideline(
                "Make the full swipe the expected action.",
                "A full swipe runs the first button without a second tap. Use it for something people do often and can undo, like Delete in Mail or Archive."
            ),
            Guideline(
                "Keep swipe actions to a few per side.",
                "One to three buttons stay readable. More get squeezed into narrow, hard-to-tap targets."
            ),
            Guideline(
                "Offer the same actions somewhere visible.",
                "Swipes are hidden until people try them. Repeat important actions in a [context menu](catalog://context-menu), the toolbar, or the detail screen."
            ),
            Guideline(
                "Let people reorder and delete their own items.",
                "Lists people build, like playlists or reminders, feel broken without editing. `.onMove` and `.onDelete` add it in two lines."
            ),
        ]
    ) {
        SwipeThumbnail()
    } content: { page in
        SwipeDemo(page: page)
    }
}

private let swipeInitial = ["Maya", "Leo", "Design Team", "Priya", "Sam", "Jordan"]

private struct SwipeConfig {
    var trailing = true
    var leading = true
    var fullSwipe = true
    var onDelete = true
    var onMove = true
    var refreshable = true
    var messages = swipeInitial
    var flagged: Set<String> = ["Leo"]
    var refreshCount = 0
    var editMode = EditMode.inactive
}

private struct SwipeDemo: View {
    let page: ComponentPage

    var body: some View {
        DemoPage(
            page: page,
            initial: SwipeConfig(),
            previewHeight: 560,
            usage: """
            @State private var names = ["Maya", "Leo", "Priya"]

            List(names, id: \\.self) { name in
                Text(name)
                    .swipeActions {
                        Button("Delete", systemImage: "trash", role: .destructive) {
                            names.removeAll { $0 == name }
                        }
                    }
            }
            """,
            usageNote: Aside(.important, "Once a row has `.swipeActions`, its `.onDelete` swipe stops showing. Add your own Delete button with `role: .destructive`, as here.")
        ) { $config in
            VStack(spacing: 12) {
                PhoneScreen(height: 460) {
                    SwipeScreen(config: $config)
                }
                .id("phone")
                HStack(spacing: 10) {
                    Text(config.refreshCount == 0 ? "Swipe a row, or pull down to refresh" : "Refreshed \(config.refreshCount)×")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    Button("Restore rows") {
                        withAnimation { config.messages = swipeInitial }
                    }
                    .font(.footnote)
                    .disabled(config.messages == swipeInitial)
                }
            }
        } controls: { $config in
            Section("Swipe actions") {
                Toggle("Trailing (Delete, Archive)", isOn: $config.trailing)
                Toggle("Leading (Flag)", isOn: $config.leading)
                Toggle("Full swipe", isOn: $config.fullSwipe)
            }
            Section {
                Toggle("onDelete", isOn: $config.onDelete)
                Toggle("onMove", isOn: $config.onMove)
                Toggle("refreshable", isOn: $config.refreshable)
            } header: {
                Text("Editing")
            } footer: {
                Text("Tap Edit in the preview to see the delete circles and drag handles.")
            }
        } code: { config in
            code(for: config)
        } examples: {
            SwipeExamples()
        }
    }

    private func code(for config: SwipeConfig) -> String {
        var lines = [
            "@State private var messages = [\"Maya\", \"Leo\", \"Design Team\", \"Priya\", \"Sam\", \"Jordan\"]",
        ]
        if config.leading {
            lines.append("@State private var flagged: Set<String> = [\"Leo\"]")
        }
        let editing = config.onDelete || config.onMove
        lines += ["", "NavigationStack {", "    List {", "        ForEach(messages, id: \\.self) { name in"]
        if config.leading {
            lines += [
                "            Label(name, systemImage: flagged.contains(name) ? \"flag.fill\" : \"person.circle\")",
            ]
        } else {
            lines.append("            Label(name, systemImage: \"person.circle\")")
        }
        let full = config.fullSwipe ? "" : "(allowsFullSwipe: false)"
        if config.trailing {
            lines += [
                "                .swipeActions\(full) {",
                "                    Button(\"Delete\", systemImage: \"trash\", role: .destructive) {",
                "                        messages.removeAll { $0 == name }",
                "                    }",
                "                    Button(\"Archive\", systemImage: \"archivebox\") {",
                "                        messages.removeAll { $0 == name }",
                "                    }",
                "                    .tint(.indigo)",
                "                }",
            ]
        }
        if config.leading {
            let args = config.fullSwipe ? "edge: .leading" : "edge: .leading, allowsFullSwipe: false"
            lines += [
                "                .swipeActions(\(args)) {",
                "                    Button(\"Flag\", systemImage: \"flag\") {",
                "                        if flagged.contains(name) { flagged.remove(name) } else { flagged.insert(name) }",
                "                    }",
                "                    .tint(.orange)",
                "                }",
            ]
        }
        lines.append("        }")
        if config.onDelete {
            lines.append("        .onDelete { messages.remove(atOffsets: $0) }")
        }
        if config.onMove {
            lines.append("        .onMove { messages.move(fromOffsets: $0, toOffset: $1) }")
        }
        lines.append("    }")
        if config.refreshable {
            lines += [
                "    .refreshable {",
                "        try? await Task.sleep(for: .seconds(1)) // Load new data here",
                "    }",
            ]
        }
        lines.append("    .navigationTitle(\"Inbox\")")
        if editing {
            lines += ["    .toolbar {", "        EditButton()", "    }"]
        }
        lines.append("}")
        return lines.joined(separator: "\n")
    }
}

private struct SwipeScreen: View {
    @Binding var config: SwipeConfig

    var body: some View {
        List {
            ForEach(config.messages, id: \.self) { name in
                row(name)
            }
            .onDelete(perform: config.onDelete ? { config.messages.remove(atOffsets: $0) } : nil)
            .onMove(perform: config.onMove ? { config.messages.move(fromOffsets: $0, toOffset: $1) } : nil)
        }
        .modifier(SwipeRefresh(isOn: config.refreshable) {
            try? await Task.sleep(for: .seconds(1))
            config.refreshCount += 1
        })
        .navigationTitle("Inbox")
        .toolbar {
            if config.onDelete || config.onMove {
                EditButton()
            }
        }
        // A real NavigationStack provides edit mode; the frame doesn't.
        .environment(\.editMode, $config.editMode)
    }

    @ViewBuilder
    private func row(_ name: String) -> some View {
        let isFlagged = config.leading && config.flagged.contains(name)
        Label(name, systemImage: isFlagged ? "flag.fill" : "person.circle")
            .swipeActions(edge: .trailing, allowsFullSwipe: config.fullSwipe) {
                if config.trailing {
                    Button("Delete", systemImage: "trash", role: .destructive) {
                        config.messages.removeAll { $0 == name }
                    }
                    Button("Archive", systemImage: "archivebox") {
                        config.messages.removeAll { $0 == name }
                    }
                    .tint(.indigo)
                }
            }
            .swipeActions(edge: .leading, allowsFullSwipe: config.fullSwipe) {
                if config.leading {
                    Button("Flag", systemImage: "flag") {
                        if config.flagged.contains(name) {
                            config.flagged.remove(name)
                        } else {
                            config.flagged.insert(name)
                        }
                    }
                    .tint(.orange)
                }
            }
    }
}

private struct SwipeRefresh: ViewModifier {
    let isOn: Bool
    let action: @MainActor () async -> Void

    func body(content: Content) -> some View {
        if isOn {
            content.refreshable { await action() }
        } else {
            content
        }
    }
}

private struct SwipeThumbnail: View {
    var body: some View {
        VStack(spacing: 0) {
            row("Maya")
            Divider()
            HStack(spacing: 0) {
                Label("Leo", systemImage: "person.circle")
                    .padding(.horizontal, 14)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                    .background(.background)
                Image(systemName: "archivebox.fill")
                    .foregroundStyle(.white)
                    .frame(width: 52, height: 44)
                    .background(.indigo)
                Image(systemName: "trash.fill")
                    .foregroundStyle(.white)
                    .frame(width: 52, height: 44)
                    .background(.red)
            }
            .frame(height: 44)
            Divider()
            row("Priya")
        }
        .foregroundStyle(.primary)
        .frame(width: 220)
        .background(.background)
        .clipShape(.rect(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(.separator)
        }
    }

    private func row(_ name: String) -> some View {
        Label(name, systemImage: "person.circle")
            .padding(.horizontal, 14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: 44)
    }
}

// MARK: - Examples

private struct SwipeExamples: View {
    @State private var reminders = ["Buy milk", "Call Mom", "Book flights", "Water plants"]
    @State private var editMode = EditMode.inactive
    @State private var updated: Date?

    var body: some View {
        ExampleCard(
            title: "Delete and reorder",
            caption: "Add `.onDelete` and `.onMove` to the `ForEach`, and an `EditButton` to show the controls.",
            code: """
            @State private var reminders = ["Buy milk", "Call Mom", "Book flights"]

            NavigationStack {
                List {
                    ForEach(reminders, id: \\.self) { Text($0) }
                        .onDelete { reminders.remove(atOffsets: $0) }
                        .onMove { reminders.move(fromOffsets: $0, toOffset: $1) }
                }
                .navigationTitle("Reminders")
                .toolbar { EditButton() }
            }
            """,
            minHeight: 360,
            aside: Aside(.note, "Drag handles only appear in edit mode. Swipe to delete works either way.")
        ) {
            PhoneScreen(height: 340) {
                List {
                    ForEach(reminders, id: \.self) { Text($0) }
                        .onDelete { reminders.remove(atOffsets: $0) }
                        .onMove { reminders.move(fromOffsets: $0, toOffset: $1) }
                }
                .navigationTitle("Reminders")
                .toolbar { EditButton() }
                // A real NavigationStack provides edit mode; the frame doesn't.
                .environment(\.editMode, $editMode)
            }
        }

        ExampleCard(
            title: "Pull to refresh",
            caption: "Add `.refreshable` to a `List`; the spinner stays until its `async` closure returns.",
            code: """
            @State private var updated: Date?

            List {
                Text(updated.map { "Updated \\($0.formatted(date: .omitted, time: .shortened))" } ?? "Pull down to refresh")
            }
            .refreshable {
                try? await Task.sleep(for: .seconds(1)) // Load new data here
                updated = .now
            }
            """,
            minHeight: 220
        ) {
            List {
                Text(updated.map { "Updated \($0.formatted(date: .omitted, time: .shortened))" } ?? "Pull down to refresh")
            }
            .refreshable {
                try? await Task.sleep(for: .seconds(1))
                updated = .now
            }
            .frame(height: 200)
        }
    }
}
