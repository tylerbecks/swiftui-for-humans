import SwiftUI

extension ComponentPage {
    static let list = ComponentPage(
        id: "list",
        title: "List",
        summary: "A scrolling column of rows, like the ones in Settings, Mail, and Contacts.",
        category: .lists,
        symbol: "list.bullet",
        availability: ["iOS 13.0+", "macOS 10.15+", "visionOS 1.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/list",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/lists-and-tables",
        aliases: ["table", "ul", "li", "rows", "UITableView", "UICollectionView", "feed", "map array", "for each", "v-for"],
        related: ["form", "swipe-actions", "navigation-stack", "lazy-grids"],
        notes: [
            "**`List` is lazy.** It only builds the rows on screen, so it handles thousands of items without slowing down.",
            "**Selection on iPhone needs edit mode.** `List(selection:)` with a `Set` shows checkmark circles only while editing; add an `EditButton` to the toolbar.",
            "**Want rows without the list look?** Use a `ScrollView` with a `LazyVStack` for a feed of custom cards.",
        ],
        about: """
        `List` owns scrolling, row separators, section headers, and system behaviors like swipe actions, selection, and pull to refresh. It's the SwiftUI version of `UITableView`, and the backbone of most iPhone screens.

        Use it for rows of text people scan and tap. For editable settings, use [Form](catalog://form). For a grid of images or cards, use a lazy grid inside a `ScrollView`.
        """,
        composition: """
        List
        ├── Section("Header")
        │   └── ForEach(items)
        │       └── Row view
        │           └── .swipeActions
        └── Section
            └── Fixed row
        """,
        api: [
            APIItem("`List(_:rowContent:)`", "One row per item in an `Identifiable` collection."),
            APIItem("`ForEach(_:content:)`", "Data rows mixed with fixed rows and sections."),
            APIItem("`Section(_:content:)`", "Groups rows under a header, with an optional footer."),
            APIItem("`.listStyle(_:)`", "`.insetGrouped`, `.plain`, `.sidebar`, and more."),
            APIItem("`.onDelete(perform:)`", "On a `ForEach`: swipe to delete, plus edit mode."),
            APIItem("`List(selection:)`", "Binds selected rows to an optional or a `Set`."),
            APIItem("`.refreshable { }`", "Pull to refresh, running an `async` action."),
            APIItem("`.listRowSeparator(_:)`", "Hides or shows one row's separator."),
        ],
        guidelines: [
            Guideline(
                "Keep row text short.",
                "Short rows are easy to scan and don't wrap or truncate. Put long text on a detail screen people open from the row.",
                good: "Short titles, scannable at a glance.",
                bad: "Long sentences wrap and slow people down."
            ) {
                ListGuidelineSample(rows: ["Wi-Fi", "Bluetooth", "Cellular"])
            } bad: {
                ListGuidelineSample(rows: ["Wi-Fi network you're connected to", "Bluetooth devices and accessories", "Cellular data and roaming"])
            },
            Guideline(
                "Use a chevron for rows that open a screen.",
                "A `NavigationLink` row adds the chevron for you. Don't use an info button to navigate; it only reveals details about the row."
            ),
            Guideline(
                "Pick the style that fits the content.",
                "Use `.insetGrouped` for settings-like groups and `.plain` for long feeds like messages, where rows run edge to edge.",
                good: "A plain feed runs edge to edge.",
                bad: "Grouped cards waste space in a feed."
            ) {
                ListStyleSample(isPlain: true)
            } bad: {
                ListStyleSample(isPlain: false)
            },
            Guideline(
                "Let people edit lists they own.",
                "People expect to delete and reorder their own items. Add `.onDelete` and `.onMove` and the system handles the gestures."
            ),
        ]
    ) {
        List {
            Section("Favorites") {
                Label("Inbox", systemImage: "tray")
                Label("Drafts", systemImage: "doc")
                Label("Archive", systemImage: "archivebox")
            }
        }
        .scrollDisabled(true)
        .scrollEdgeEffectHidden(true, for: .all)
        .contentMargins(.top, 8, for: .scrollContent)
        .frame(width: 280, height: 196)
        .scaleEffect(0.74)
    } content: { page in
        ListDemo(page: page)
    }
}

// MARK: - Model

private let listFavorites = ["Apple", "Banana", "Cherry"]
private let listOthers = ["Kiwi", "Lemon", "Plum"]

private struct ListConfig {
    var style: ListStyleOption = .automatic
    var sections = true
    var selection: ListSelectionOption = .none
    var hideSeparators = false
    var headerProminence = false
    var single: String?
    var multiple: Set<String> = []
}

private struct ListDemo: View {
    let page: ComponentPage

    var body: some View {
        DemoPage(
            page: page,
            initial: ListConfig(),
            previewHeight: 440,
            usage: """
            let fruits = ["Apple", "Banana", "Cherry"]

            List {
                Section("Favorites") {
                    ForEach(fruits, id: \\.self) { fruit in
                        Label(fruit, systemImage: "leaf")
                    }
                }
            }
            """,
            usageNote: Aside(.important, "Each item needs a stable identity. Make your model `Identifiable` or pass `id: \\.someKey`; array indexes break animations when rows move.")
        ) { $config in
            VStack(spacing: 12) {
                ListPreview(config: $config)
                    .frame(maxWidth: 420)
                    .frame(height: 360)
                    .clipShape(.rect(cornerRadius: 14))
                    .overlay {
                        RoundedRectangle(cornerRadius: 14)
                            .strokeBorder(.separator)
                    }
                Text(selectionSummary(config))
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .contentTransition(.numericText())
                    .animation(.snappy, value: selectionSummary(config))
            }
        } controls: { $config in
            Section("Appearance") {
                OptionPicker("Style", selection: $config.style)
                Toggle("Sections", isOn: $config.sections)
                Toggle("Hide row separators", isOn: $config.hideSeparators)
                Toggle("Prominent headers", isOn: $config.headerProminence)
                    .disabled(!config.sections)
            }
            Section {
                OptionPicker("Selection", selection: $config.selection)
            } footer: {
                Text("Multiple selection turns on edit mode so the checkmark circles appear.")
            }
        } code: { config in
            code(for: config)
        } examples: {
            ListExamples()
        }
    }

    private func selectionSummary(_ config: ListConfig) -> String {
        switch config.selection {
        case .none: "Selection is off"
        case .single: config.single.map { "Selected: \($0)" } ?? "Tap a row to select it"
        case .multiple: config.multiple.isEmpty ? "Tap rows to select them" : "\(config.multiple.count) selected: \(config.multiple.sorted().joined(separator: ", "))"
        }
    }

    private func code(for config: ListConfig) -> String {
        var lines: [String] = []
        switch config.selection {
        case .none: break
        case .single: lines.append("@State private var selection: String?")
        case .multiple: lines.append("@State private var selection = Set<String>()")
        }
        if config.sections {
            lines.append("let favorites = [\"Apple\", \"Banana\", \"Cherry\"]")
            lines.append("let others = [\"Kiwi\", \"Lemon\", \"Plum\"]")
        } else {
            lines.append("let fruits = [\"Apple\", \"Banana\", \"Cherry\", \"Kiwi\", \"Lemon\", \"Plum\"]")
        }
        lines.append("")
        lines.append(config.selection == .none ? "List {" : "List(selection: $selection) {")
        func forEach(_ data: String, _ indent: String) -> [String] {
            var out = ["\(indent)ForEach(\(data), id: \\.self) { fruit in",
                       "\(indent)    Label(fruit, systemImage: \"leaf\")"]
            if config.hideSeparators {
                out.append("\(indent)        .listRowSeparator(.hidden)")
            }
            out.append("\(indent)}")
            return out
        }
        if config.sections {
            for (title, data) in [("Favorites", "favorites"), ("More fruit", "others")] {
                lines.append("    Section(\"\(title)\") {")
                lines += forEach(data, "        ")
                lines.append("    }")
                if config.headerProminence {
                    lines.append("    .headerProminence(.increased)")
                }
            }
        } else {
            lines += forEach("fruits", "    ")
        }
        lines.append("}")
        if config.style != .automatic {
            lines.append(".listStyle(\(config.style.label))")
        }
        if config.selection == .multiple {
            lines.append(".environment(\\.editMode, .constant(.active))")
        }
        return lines.joined(separator: "\n")
    }
}

/// The live list. Selection needs a different binding type per mode, so the
/// three variants are built separately around the same rows.
private struct ListPreview: View {
    @Binding var config: ListConfig

    var body: some View {
        Group {
            switch config.selection {
            case .none:
                List { rows }
            case .single:
                List(selection: $config.single) { rows }
            case .multiple:
                List(selection: $config.multiple) { rows }
                    .environment(\.editMode, .constant(.active))
            }
        }
        .listStyled(config.style)
        .animation(.default, value: config.sections)
    }

    @ViewBuilder
    private var rows: some View {
        if config.sections {
            Section("Favorites") {
                ForEach(listFavorites, id: \.self) { row($0) }
            }
            .headerProminence(config.headerProminence ? .increased : .standard)
            Section("More fruit") {
                ForEach(listOthers, id: \.self) { row($0) }
            }
            .headerProminence(config.headerProminence ? .increased : .standard)
        } else {
            ForEach(listFavorites + listOthers, id: \.self) { row($0) }
        }
    }

    private func row(_ fruit: String) -> some View {
        Label(fruit, systemImage: "leaf")
            .listRowSeparator(config.hideSeparators ? .hidden : .automatic)
            .tag(fruit)
    }
}

// MARK: - Examples

private struct ListExamples: View {
    @State private var messages = ListMessage.samples
    @State private var items: [String] = []
    @State private var fruits = ["Apple", "Banana", "Cherry", "Kiwi"]

    var body: some View {
        ExampleCard(
            title: "Rows from data",
            caption: "Pass an `Identifiable` array to `List`, like `items.map(item => <li>…</li>)` on the web.",
            code: """
            struct Message: Identifiable {
                let id = UUID()
                let sender: String
                let preview: String
            }

            @State private var messages = [
                Message(sender: "Maya", preview: "Are we still on for lunch tomorrow?"),
                Message(sender: "Leo", preview: "Sent you the photos from the trip"),
            ]

            List(messages) { message in
                VStack(alignment: .leading) {
                    Text(message.sender)
                        .font(.headline)
                    Text(message.preview)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            .listStyle(.plain)
            """
        ) {
            List(messages) { message in
                VStack(alignment: .leading) {
                    Text(message.sender)
                        .font(.headline)
                    Text(message.preview)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            .listStyle(.plain)
            .frame(height: 200)
            .scrollDisabled(true)
        }

        ExampleCard(
            title: "Swipe to delete",
            caption: "Add `.onDelete` to the `ForEach`, and every row gets a swipe-to-delete action for free.",
            code: """
            @State private var fruits = ["Apple", "Banana", "Cherry", "Kiwi"]

            List {
                ForEach(fruits, id: \\.self) { fruit in
                    Text(fruit)
                }
                .onDelete { offsets in
                    fruits.remove(atOffsets: offsets)
                }
            }
            """,
            aside: Aside(.important, "`.onDelete` goes on the `ForEach`, not the `List`. For other swipe buttons, use [Swipe Actions](catalog://swipe-actions).")
        ) {
            VStack(spacing: 12) {
                List {
                    ForEach(fruits, id: \.self) { fruit in
                        Text(fruit)
                    }
                    .onDelete { offsets in
                        fruits.remove(atOffsets: offsets)
                    }
                }
                .frame(height: 230)
                .scrollDisabled(true)
                Button("Reset", systemImage: "arrow.counterclockwise") {
                    withAnimation { fruits = ["Apple", "Banana", "Cherry", "Kiwi"] }
                }
                .buttonStyle(.bordered)
                .disabled(fruits.count == 4)
            }
        }

        ExampleCard(
            title: "Empty state",
            caption: "Show `ContentUnavailableView` in an `.overlay` when the data is empty. Tap Add to fill the list.",
            code: """
            @State private var items: [String] = []

            List(items, id: \\.self) { item in
                Text(item)
            }
            .overlay {
                if items.isEmpty {
                    ContentUnavailableView(
                        "No Items",
                        systemImage: "tray",
                        description: Text("Items you add appear here.")
                    )
                }
            }
            """
        ) {
            VStack(spacing: 12) {
                List(items, id: \.self) { item in
                    Text(item)
                }
                .overlay {
                    if items.isEmpty {
                        ContentUnavailableView(
                            "No Items",
                            systemImage: "tray",
                            description: Text("Items you add appear here.")
                        )
                    }
                }
                .frame(height: 220)
                HStack {
                    Button("Add", systemImage: "plus") {
                        withAnimation { items.append("Item \(items.count + 1)") }
                    }
                    Button("Clear", systemImage: "trash", role: .destructive) {
                        withAnimation { items.removeAll() }
                    }
                    .disabled(items.isEmpty)
                }
                .buttonStyle(.bordered)
            }
        }

        ExampleCard(
            title: "Custom row styling",
            caption: "Put `.listRowBackground`, `.listRowInsets`, and `.listRowSeparatorTint` on each row, not on the list.",
            code: """
            List {
                ForEach(["Low", "Medium", "High"], id: \\.self) { level in
                    Text(level)
                        .listRowBackground(Color.orange.opacity(0.15))
                        .listRowInsets(.init(top: 14, leading: 24, bottom: 14, trailing: 24))
                        .listRowSeparatorTint(.orange)
                }
            }
            """
        ) {
            List {
                ForEach(["Low", "Medium", "High"], id: \.self) { level in
                    Text(level)
                        .listRowBackground(Color.orange.opacity(0.15))
                        .listRowInsets(.init(top: 14, leading: 24, bottom: 14, trailing: 24))
                        .listRowSeparatorTint(.orange)
                }
            }
            .frame(height: 210)
            .scrollDisabled(true)
        }
    }
}

private struct ListMessage: Identifiable {
    let id = UUID()
    let sender: String
    let preview: String

    static let samples = [
        ListMessage(sender: "Maya", preview: "Are we still on for lunch tomorrow?"),
        ListMessage(sender: "Design Team", preview: "New mockups for the onboarding flow are up"),
        ListMessage(sender: "Leo", preview: "Sent you the photos from the trip"),
    ]
}

// MARK: - Options

private enum ListSelectionOption: DemoOption {
    case none, single, multiple

    var label: String {
        switch self {
        case .none: "None"
        case .single: "Single"
        case .multiple: "Multiple"
        }
    }
}

private enum ListStyleOption: DemoOption {
    case automatic, insetGrouped, grouped, inset, plain, sidebar

    var label: String {
        switch self {
        case .automatic: ".automatic"
        case .insetGrouped: ".insetGrouped"
        case .grouped: ".grouped"
        case .inset: ".inset"
        case .plain: ".plain"
        case .sidebar: ".sidebar"
        }
    }
}

private extension View {
    @ViewBuilder
    func listStyled(_ style: ListStyleOption) -> some View {
        switch style {
        case .automatic: listStyle(.automatic)
        case .insetGrouped: listStyle(.insetGrouped)
        case .grouped: listStyle(.grouped)
        case .inset: listStyle(.inset)
        case .plain: listStyle(.plain)
        case .sidebar: listStyle(.sidebar)
        }
    }
}
// MARK: - Guideline samples

/// A small list for the row-length guideline.
private struct ListGuidelineSample: View {
    let rows: [String]

    var body: some View {
        List(rows, id: \.self) { row in
            NavigationLinkLookalike(title: row)
        }
        .listStyle(.plain)
        .scrollDisabled(true)
        .frame(width: 260, height: 200)
    }
}

/// A message feed in `.plain` or `.insetGrouped` style, for the style guideline.
private struct ListStyleSample: View {
    let isPlain: Bool

    var body: some View {
        Group {
            if isPlain {
                List { rows }.listStyle(.plain)
            } else {
                List { rows }.listStyle(.insetGrouped)
            }
        }
        .scrollDisabled(true)
        .frame(width: 260, height: 170)
    }

    @ViewBuilder
    private var rows: some View {
        ForEach(["Maya", "Leo", "Design Team"], id: \.self) { name in
            VStack(alignment: .leading, spacing: 2) {
                Text(name).font(.subheadline.bold())
                Text("See you at 6?").font(.caption).foregroundStyle(.secondary)
            }
        }
    }
}

/// Looks like a `NavigationLink` row without pushing onto the catalog's stack.
private struct NavigationLinkLookalike: View {
    let title: String

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.tertiary)
        }
    }
}
