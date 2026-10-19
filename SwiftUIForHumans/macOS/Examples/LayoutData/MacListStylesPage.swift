import SwiftUI

extension ComponentPage {
    static let listStyles = ComponentPage(
        id: "list-styles",
        title: "List styles",
        summary: "Sidebar, inset, and bordered lists, with rows people click to select, one or many.",
        category: .lists,
        symbol: "list.bullet",
        availability: ["macOS 10.15+", "Collapsible sections macOS 14.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/liststyle",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/lists-and-tables",
        aliases: [
            "List", "listStyle", "sidebar", "inset", "bordered", "plain", "NSTableView", "source list",
            "alternatingRowBackgrounds", "zebra stripes", "striped rows", "selection", "multiple selection",
            "onDeleteCommand", "double-click", "<ul>",
        ],
        related: ["table", "outline", "navigation-split-view", "context-menu"],
        notes: [
            "**Selection on the Mac needs no edit mode.** Bind `selection:` to a `Set` and people can select several rows right away, with no Edit button.",
            "**Sidebar section headers can collapse.** In the `.sidebar` style, people can hide a section from its header.",
        ],
        about: "A `List` shows rows in one column and handles selection and scrolling for you. Its style decides the look: `.sidebar` for the source list on the leading edge of a window, `.inset` for content with rounded selection, and `.bordered` for a boxed list inside a form or settings pane.\n\nFor several columns of data, use a [Table](catalog://table). For a hierarchy, see [Outline lists](catalog://outline).",
        api: [
            APIItem("`List(_:selection:rowContent:)`", "Rows from data, optionally selectable."),
            APIItem("`.listStyle(.sidebar)`", "A source list with collapsible sections."),
            APIItem("`.listStyle(.inset)`", "Content rows with inset selection."),
            APIItem("`.listStyle(.bordered)`", "A boxed list for forms and panes."),
            APIItem("`.alternatingRowBackgrounds()`", "Stripes every other row."),
            APIItem("`.onDeleteCommand(perform:)`", "Runs on the Delete key or Delete command."),
            APIItem("`.contextMenu(forSelectionType:)`", "A menu and double-click for selected rows."),
        ],
        guidelines: [
            Guideline(
                "Keep row text short.",
                "Rows are for scanning. Show a title, and put the long text in a detail view people open from the row.",
                good: "Short titles scan at a glance.",
                bad: "Long sentences get cut off."
            ) {
                RowLengthSample(rows: ["Team meeting", "Dentist", "Pick up groceries"])
            } bad: {
                RowLengthSample(rows: [
                    "Team meeting about the quarterly roadmap and hiring",
                    "Dentist appointment, remember to bring the insurance card",
                    "Pick up groceries for the weekend dinner party",
                ])
            },
            Guideline(
                "Keep the selected row highlighted when it drives a detail view.",
                "A lasting highlight shows people where they are. A list of options can instead flash the row and show a checkmark."
            ),
            Guideline(
                "Show at most two levels in a sidebar.",
                "Deeper hierarchies are hard to follow there. Add a content column between the sidebar and the detail instead."
            ),
            Guideline(
                "Let the sidebar's icons follow the accent color.",
                "People pick an accent color for every app. Save fixed colors for the few icons that need to stand out."
            ),
        ]
    ) {
        VStack(alignment: .leading, spacing: 2) {
            ForEach(["Inbox", "Drafts", "Sent"], id: \.self) { name in
                Label(name, systemImage: "tray")
                    .font(.caption)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(name == "Inbox" ? AnyShapeStyle(.tint.opacity(0.25)) : AnyShapeStyle(.clear), in: .rect(cornerRadius: 5))
            }
        }
        .frame(width: 120)
    } content: { page in
        MacListStylesDemo(page: page)
    }
}

// MARK: - Demo

private struct MacListStylesConfig {
    var style: ListStyleOption = .automatic
    var selection: ListSelectionOption = .single
    var alternates = false
    var hasSections = false
}

private struct MacListStylesDemo: View {
    let page: ComponentPage

    var body: some View {
        DemoPage(
            page: page,
            initial: MacListStylesConfig(),
            usage: """
            @State private var selection: String?
            private let fruits = ["Apple", "Banana", "Cherry"]

            List(fruits, id: \\.self, selection: $selection) { fruit in
                Text(fruit)
            }
            """,
            usageNote: Aside(.note, "`selection:` takes an optional for one row at a time, or a `Set` for several. Without it, rows don't highlight when clicked.")
        ) { $config in
            ListStylePreview(config: config)
        } controls: { $config in
            Section("Style") {
                OptionPicker("Style", selection: $config.style)
                Toggle("Alternating rows", isOn: $config.alternates)
                    .disabled(config.style == .sidebar)
                Toggle("Sections", isOn: $config.hasSections)
            }
            Section("Selection") {
                OptionPicker("Select", selection: $config.selection)
            }
        } code: { config in
            var lines: [String] = []
            switch config.selection {
            case .none: break
            case .single: lines += ["@State private var selection: String?", ""]
            case .multiple: lines += ["@State private var selection: Set<String> = []", ""]
            }
            let selectionArgument = config.selection == .none ? "" : "selection: $selection"
            if config.hasSections {
                lines.append(selectionArgument.isEmpty ? "List {" : "List(\(selectionArgument)) {")
                lines.append("    Section(\"Fruit\") {")
                lines.append("        ForEach([\"Apple\", \"Banana\", \"Cherry\"], id: \\.self) { Text($0) }")
                lines.append("    }")
                lines.append("    Section(\"Vegetables\") {")
                lines.append("        ForEach([\"Carrot\", \"Leek\", \"Pepper\"], id: \\.self) { Text($0) }")
                lines.append("    }")
                lines.append("}")
            } else {
                let arguments = ["[\"Apple\", \"Banana\", \"Cherry\", \"Carrot\", \"Leek\", \"Pepper\"]", "id: \\.self"] + (selectionArgument.isEmpty ? [] : [selectionArgument])
                lines.append("List(\(arguments.joined(separator: ", "))) { item in")
                lines.append("    Text(item)")
                lines.append("}")
            }
            if config.style != .automatic {
                lines.append(".listStyle(\(config.style.label))")
            }
            if config.alternates && config.style != .sidebar {
                lines.append(".alternatingRowBackgrounds()")
            }
            return lines.joined(separator: "\n")
        } examples: {
            MacListStylesExamples()
        }
    }
}

private struct ListStylePreview: View {
    let config: MacListStylesConfig
    @State private var single: String? = "Banana"
    @State private var multiple: Set<String> = ["Banana", "Leek"]

    private static let fruit = ["Apple", "Banana", "Cherry"]
    private static let vegetables = ["Carrot", "Leek", "Pepper"]

    var body: some View {
        // A selectable List placed straight in the demo card keeps the
        // card's layout from settling. A fixed-size frame with the list as
        // its overlay avoids that.
        Color.clear
            .frame(width: 300, height: 230)
            .overlay {
                styled(list)
                    .alternatingRowBackgrounds(config.alternates ? .enabled : .disabled)
                    .id("\(config.style)-\(config.selection)-\(config.hasSections)")
            }
            .overlay {
                if config.style != .bordered {
                    RoundedRectangle(cornerRadius: 6).strokeBorder(.separator)
                }
            }
    }

    @ViewBuilder private var list: some View {
        switch config.selection {
        case .none:
            List { rows }
        case .single:
            List(selection: $single) { rows }
        case .multiple:
            List(selection: $multiple) { rows }
        }
    }

    @ViewBuilder private var rows: some View {
        if config.hasSections {
            Section("Fruit") {
                ForEach(Self.fruit, id: \.self) { Text($0) }
            }
            Section("Vegetables") {
                ForEach(Self.vegetables, id: \.self) { Text($0) }
            }
        } else {
            ForEach(Self.fruit + Self.vegetables, id: \.self) { Text($0) }
        }
    }

    @ViewBuilder
    private func styled(_ list: some View) -> some View {
        switch config.style {
        case .automatic: list.listStyle(.automatic)
        case .sidebar: list.listStyle(.sidebar)
        case .inset: list.listStyle(.inset)
        case .bordered: list.listStyle(.bordered)
        case .plain: list.listStyle(.plain)
        }
    }
}

// MARK: - Examples

private struct MacListStylesExamples: View {
    @State private var sidebarSelection: String? = "Inbox"
    @State private var showsFavorites = true
    @State private var showsTags = true

    @State private var blocked = ["spam@example.com", "deals@example.net", "news@example.org", "promo@example.com"]
    @State private var blockedSelection: String?

    @State private var notes = ["Groceries", "Packing list", "Book ideas", "Gift ideas", "Recipes"]
    @State private var noteSelection: Set<String> = []
    @State private var opened = "Double-click a note to open it."

    var body: some View {
        ExampleCard(
            title: "A sidebar with collapsible sections",
            caption: "`.listStyle(.sidebar)` gives the source list look, `Section(isExpanded:)` lets people fold a section, and `.badge` shows a count.",
            code: """
            @State private var selection: String? = "Inbox"
            @State private var showsFavorites = true
            @State private var showsTags = true

            List(selection: $selection) {
                Section("Favorites", isExpanded: $showsFavorites) {
                    Label("Inbox", systemImage: "tray")
                        .badge(12)
                        .tag("Inbox")
                    Label("Flagged", systemImage: "flag")
                        .tag("Flagged")
                }
                Section("Tags", isExpanded: $showsTags) {
                    Label("Work", systemImage: "tag")
                        .tag("Work")
                    Label("Family", systemImage: "tag")
                        .tag("Family")
                }
            }
            .listStyle(.sidebar)
            .frame(width: 220, height: 240)
            """,
            minHeight: 280
        ) {
            List(selection: $sidebarSelection) {
                Section("Favorites", isExpanded: $showsFavorites) {
                    Label("Inbox", systemImage: "tray")
                        .badge(12)
                        .tag("Inbox")
                    Label("Flagged", systemImage: "flag")
                        .tag("Flagged")
                }
                Section("Tags", isExpanded: $showsTags) {
                    Label("Work", systemImage: "tag")
                        .tag("Work")
                    Label("Family", systemImage: "tag")
                        .tag("Family")
                }
            }
            .listStyle(.sidebar)
            .frame(width: 220, height: 240)
            .overlay(RoundedRectangle(cornerRadius: 6).strokeBorder(.separator))
        }

        ExampleCard(
            title: "A bordered list with add and remove buttons",
            caption: "Use `.listStyle(.bordered)` for a short list in a settings pane, with `+` and `−` buttons below and `.onDeleteCommand` for the Delete key.",
            code: """
            struct BlockedSenders: View {
                @State private var blocked = ["spam@example.com", "deals@example.net"]
                @State private var selection: String?

                var body: some View {
                    VStack(alignment: .leading, spacing: 0) {
                        List(blocked, id: \\.self, selection: $selection) { Text($0) }
                            .listStyle(.bordered)
                            .alternatingRowBackgrounds()
                            .onDeleteCommand { removeSelected() }
                        HStack(spacing: 0) {
                            Button("Add", systemImage: "plus") {
                                blocked.append("new@example.com")
                            }
                            Button("Remove", systemImage: "minus") { removeSelected() }
                                .disabled(selection == nil)
                        }
                        .labelStyle(.iconOnly)
                        .buttonStyle(.borderless)
                        .padding(4)
                    }
                    .frame(width: 280, height: 180)
                }

                private func removeSelected() {
                    blocked.removeAll { $0 == selection }
                    selection = nil
                }
            }
            """,
            minHeight: 220
        ) {
            VStack(alignment: .leading, spacing: 0) {
                List(blocked, id: \.self, selection: $blockedSelection) { Text($0) }
                    .listStyle(.bordered)
                    .alternatingRowBackgrounds()
                    .onDeleteCommand { removeBlocked() }
                HStack(spacing: 0) {
                    Button("Add", systemImage: "plus") {
                        blocked.append("new\(blocked.count)@example.com")
                    }
                    Button("Remove", systemImage: "minus") { removeBlocked() }
                        .disabled(blockedSelection == nil)
                }
                .labelStyle(.iconOnly)
                .buttonStyle(.borderless)
                .padding(4)
            }
            .frame(width: 280, height: 180)
        }

        ExampleCard(
            title: "Select several, and double-click to open",
            caption: "Bind `selection:` to a `Set` for multiple selection, and `.contextMenu(forSelectionType:)` adds a menu plus a `primaryAction` for double-click.",
            code: """
            @State private var notes = ["Groceries", "Packing list", "Book ideas"]
            @State private var selection: Set<String> = []
            @Environment(\\.openWindow) private var openWindow

            List(notes, id: \\.self, selection: $selection) { note in
                Text(note)
            }
            .contextMenu(forSelectionType: String.self) { items in
                Button("Open") { }
                Button("Delete", role: .destructive) {
                    notes.removeAll { items.contains($0) }
                }
            } primaryAction: { items in
                for item in items {
                    openWindow(value: item)
                }
            }
            """,
            minHeight: 250,
            aside: Aside(.note, "On the Mac, a single click selects a row and a double click runs the primary action. Opening a window this way needs a `WindowGroup(for: String.self)` scene in your app.")
        ) {
            VStack(spacing: 10) {
                List(notes, id: \.self, selection: $noteSelection) { note in
                    Text(note)
                }
                .contextMenu(forSelectionType: String.self) { items in
                    Button("Open") { opened = "Opened \(items.sorted().joined(separator: ", "))" }
                    Button("Delete", role: .destructive) {
                        notes.removeAll { items.contains($0) }
                    }
                } primaryAction: { items in
                    opened = "Opened \(items.sorted().joined(separator: ", "))"
                }
                .frame(width: 280, height: 160)
                .overlay(RoundedRectangle(cornerRadius: 6).strokeBorder(.separator))
                Text("\(noteSelection.count) selected · \(opened)")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func removeBlocked() {
        blocked.removeAll { $0 == blockedSelection }
        blockedSelection = nil
    }
}

/// A short list for the row-length guideline.
private struct RowLengthSample: View {
    let rows: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(rows, id: \.self) { row in
                Text(row)
                    .lineLimit(1)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Divider()
            }
        }
        .frame(width: 220)
        .overlay(RoundedRectangle(cornerRadius: 6).strokeBorder(.separator))
    }
}

// MARK: - Options

private enum ListStyleOption: DemoOption {
    case automatic, sidebar, inset, bordered, plain

    var label: String {
        switch self {
        case .automatic: ".automatic"
        case .sidebar: ".sidebar"
        case .inset: ".inset"
        case .bordered: ".bordered"
        case .plain: ".plain"
        }
    }
}

private enum ListSelectionOption: DemoOption {
    case none, single, multiple

    var label: String {
        switch self {
        case .none: "None"
        case .single: "One row"
        case .multiple: "Several rows"
        }
    }
}
