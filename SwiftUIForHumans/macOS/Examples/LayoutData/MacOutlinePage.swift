import SwiftUI

extension ComponentPage {
    static let outline = ComponentPage(
        id: "outline",
        title: "Outline lists",
        summary: "Folders inside folders: rows with disclosure triangles that open to show their children.",
        category: .lists,
        symbol: "list.bullet.indent",
        availability: ["macOS 11.0+", "Outline Table macOS 14.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/outlinegroup",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/outline-views",
        aliases: [
            "OutlineGroup", "outline view", "NSOutlineView", "tree", "tree view", "hierarchy", "nested list",
            "children", "List children", "disclosure triangle", "Finder list view", "folders", "file browser",
            "DisclosureTableRow",
        ],
        related: ["list-styles", "table", "group-box"],
        notes: [
            "**`children` decides which rows get a triangle.** A row whose children are `nil` is a leaf. An empty array still shows a triangle, like an empty folder.",
            "**`List(_:children:)` is an `OutlineGroup` inside a `List`.** Write `OutlineGroup` yourself only when the tree is one part of a bigger list.",
        ],
        about: "Give a `List` tree-shaped data and a key path to each item's children, and it draws a disclosure triangle on every row that has some. People open and close branches, like folders in Finder's list view.\n\nUse `List(_:children:)` for a whole outline, `OutlineGroup` to put a tree inside one section of a list, and `Table(_:children:)` when each row also needs columns.",
        composition: """
        List(files, children: \\.children)
        └── Label(file.name)
            └── (children, when expanded)
        """,
        api: [
            APIItem("`List(_:children:rowContent:)`", "A whole list built from a tree."),
            APIItem("`OutlineGroup(_:children:)`", "A tree inside a list or section."),
            APIItem("`Table(_:children:columns:)`", "An outline with columns, like Finder."),
            APIItem("`DisclosureGroup(isExpanded:)`", "One branch whose state you control."),
            APIItem("`DisclosureTableRow`", "A table row that opens to more rows."),
        ],
        guidelines: [
            Guideline(
                "Show the hierarchy in the first column only.",
                "Indent and put triangles in the first column. The other columns hold details about each item, like its size or date."
            ),
            Guideline(
                "Use a table when nothing nests.",
                "Triangles on data that has no children only add clutter. A flat collection belongs in a [table](catalog://table) or list."
            ),
            Guideline(
                "Remember what people expanded.",
                "If someone opened three folders to reach a file, show it that way next time instead of making them dig again."
            ),
            Guideline(
                "Give every column of a multicolumn outline a heading.",
                "Use short nouns without punctuation, so people know what each value is."
            ),
            Guideline(
                "Consider a search field for a long outline.",
                "When the outline is the main part of the window, a search field in the toolbar helps people find a value fast."
            ),
        ]
    ) {
        VStack(alignment: .leading, spacing: 4) {
            Label("Documents", systemImage: "chevron.down")
            Label("Report.pdf", systemImage: "doc").padding(.leading, 16)
            Label("Photos", systemImage: "chevron.right")
        }
        .font(.caption)
        .labelStyle(OutlineThumbnailLabelStyle())
        .frame(width: 130, alignment: .leading)
    } content: { page in
        MacOutlineArticle(page: page)
    }
}

private struct OutlineThumbnailLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 5) {
            configuration.icon
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.secondary)
                .frame(width: 10)
            configuration.title
        }
    }
}

// MARK: - Sample data

private struct FileNode: Identifiable, Hashable {
    let name: String
    var size: Int64 = 0
    var children: [FileNode]? = nil
    var id: String { name }

    var symbol: String { children == nil ? "doc" : "folder" }

    /// The total size of a folder's contents.
    var totalSize: Int64 {
        children?.reduce(0) { $0 + $1.totalSize } ?? size
    }

    static let samples: [FileNode] = [
        FileNode(name: "Documents", children: [
            FileNode(name: "Report.pdf", size: 1_250_000),
            FileNode(name: "Budget.numbers", size: 412_000),
            FileNode(name: "Archive", children: [
                FileNode(name: "2025 Taxes.pdf", size: 880_000),
            ]),
        ]),
        FileNode(name: "Photos", children: [
            FileNode(name: "Lake.heic", size: 3_100_000),
            FileNode(name: "City.heic", size: 2_700_000),
        ]),
        FileNode(name: "Downloads", children: []),
        FileNode(name: "Notes.txt", size: 4_000),
    ]
}

// MARK: - Page

private struct MacOutlineArticle: View {
    let page: ComponentPage

    var body: some View {
        ArticlePage(page: page) {
            if let about = page.about {
                AboutSection(text: about)
            }

            SectionTitle("Usage")
                .id("code")
            CodeBlock(code: """
            struct FileNode: Identifiable {
                let name: String
                var children: [FileNode]? = nil
                var id: String { name }
            }

            let files = [
                FileNode(name: "Documents", children: [
                    FileNode(name: "Report.pdf"),
                ]),
                FileNode(name: "Notes.txt"),
            ]

            List(files, children: \\.children) { file in
                Label(file.name, systemImage: file.children == nil ? "doc" : "folder")
            }
            """)
            Aside(.important, "`children` must be optional. Leaves return `nil`; returning `[]` for them shows a triangle that opens to nothing.")

            if let composition = page.composition {
                CompositionSection(tree: composition)
            }

            SectionTitle("Examples")
                .id("examples")
            OutlineExamples()
        }
    }
}

// MARK: - Examples

private struct OutlineExamples: View {

    var body: some View {
        ExampleCard(
            title: "A file tree with List(children:)",
            caption: "Pass the tree and the key path to each item's children. Add `selection:` and people can click any row, at any depth.",
            code: """
            @State private var selection: FileNode.ID?

            List(FileNode.samples, children: \\.children, selection: $selection) { file in
                Label(file.name, systemImage: file.symbol)
            }
            .frame(width: 280, height: 220)
            """,
            minHeight: 260
        ) {
            TreeListSample()
        }

        ExampleCard(
            title: "A tree inside one sidebar section",
            caption: "`OutlineGroup` builds the same triangles inside a `Section`, so a sidebar can mix flat rows with a tree.",
            code: """
            @State private var selection: FileNode.ID?

            List(selection: $selection) {
                Section("Favorites") {
                    Label("Recents", systemImage: "clock")
                    Label("Shared", systemImage: "person.2")
                }
                Section("Locations") {
                    OutlineGroup(FileNode.samples, children: \\.children) { file in
                        Label(file.name, systemImage: file.symbol)
                    }
                }
            }
            .listStyle(.sidebar)
            .frame(width: 240, height: 260)
            """,
            minHeight: 300
        ) {
            SidebarTreeSample()
        }

        ExampleCard(
            title: "Finder-style: an outline with columns",
            caption: "`Table(_:children:)` puts the tree in the first column and details in the others, like Finder's list view.",
            code: """
            @State private var selection = Set<FileNode.ID>()

            Table(FileNode.samples, children: \\.children, selection: $selection) {
                TableColumn("Name") { file in
                    Label(file.name, systemImage: file.symbol)
                }
                TableColumn("Size") { file in
                    Text(file.totalSize, format: .byteCount(style: .file))
                        .foregroundStyle(.secondary)
                }
                .width(90)
            }
            .frame(width: 420, height: 220)
            """,
            minHeight: 260
        ) {
            OutlineTableSample()
        }

        ExampleCard(
            title: "Expansion you keep track of",
            caption: "Build the tree from `DisclosureGroup(isExpanded:)` rows, and keep the open ids in a `Set`. Save that set to reopen the outline as people left it.",
            code: """
            struct FileTree: View {
                let nodes: [FileNode]
                @Binding var expanded: Set<FileNode.ID>

                var body: some View {
                    ForEach(nodes) { node in
                        if let children = node.children {
                            DisclosureGroup(isExpanded: Binding {
                                expanded.contains(node.id)
                            } set: { isOpen in
                                if isOpen { expanded.insert(node.id) } else { expanded.remove(node.id) }
                            }) {
                                FileTree(nodes: children, expanded: $expanded)
                            } label: {
                                Label(node.name, systemImage: node.symbol)
                            }
                        } else {
                            Label(node.name, systemImage: node.symbol)
                        }
                    }
                }
            }

            @State private var expanded: Set<FileNode.ID> = ["Documents"]

            List {
                FileTree(nodes: FileNode.samples, expanded: $expanded)
            }
            """,
            minHeight: 280,
            aside: Aside(.note, "The examples on this page use a `FileNode` like the one in Usage, with a `symbol` property and an optional `children` array.")
        ) {
            ExpansionSample()
        }
    }
}

private struct TreeListSample: View {
    @State private var listSelection: FileNode.ID? = "Report.pdf"
    var body: some View {
        List(FileNode.samples, children: \.children, selection: $listSelection) { file in
            Label(file.name, systemImage: file.symbol)
        }
        .frame(width: 280, height: 220)
        .overlay(RoundedRectangle(cornerRadius: 6).strokeBorder(.separator))
    }
}

private struct SidebarTreeSample: View {
    @State private var sidebarSelection: FileNode.ID?
    var body: some View {
        List(selection: $sidebarSelection) {
            Section("Favorites") {
                Label("Recents", systemImage: "clock")
                Label("Shared", systemImage: "person.2")
            }
            Section("Locations") {
                OutlineGroup(FileNode.samples, children: \.children) { file in
                    Label(file.name, systemImage: file.symbol)
                }
            }
        }
        .listStyle(.sidebar)
        .frame(width: 240, height: 260)
        .overlay(RoundedRectangle(cornerRadius: 6).strokeBorder(.separator))
    }
}

private struct OutlineTableSample: View {
    @State private var tableSelection = Set<FileNode.ID>()
    var body: some View {
        Table(FileNode.samples, children: \.children, selection: $tableSelection) {
            TableColumn("Name") { file in
                Label(file.name, systemImage: file.symbol)
            }
            TableColumn("Size") { file in
                Text(file.totalSize, format: .byteCount(style: .file))
                    .foregroundStyle(.secondary)
            }
            .width(90)
        }
        .frame(width: 420, height: 220)
    }
}

private struct ExpansionSample: View {
    @State private var expanded: Set<FileNode.ID> = ["Documents"]
    var body: some View {
        VStack(spacing: 10) {
            List {
                FileTree(nodes: FileNode.samples, expanded: $expanded)
            }
            .frame(width: 280, height: 240)
            .overlay(RoundedRectangle(cornerRadius: 6).strokeBorder(.separator))
            Text("Open: \(expanded.isEmpty ? "none" : expanded.sorted().joined(separator: ", "))")
                .font(.callout)
                .foregroundStyle(.secondary)
        }
    }
}

private struct FileTree: View {
    let nodes: [FileNode]
    @Binding var expanded: Set<FileNode.ID>

    var body: some View {
        ForEach(nodes) { node in
            if let children = node.children {
                DisclosureGroup(isExpanded: Binding {
                    expanded.contains(node.id)
                } set: { isOpen in
                    if isOpen { expanded.insert(node.id) } else { expanded.remove(node.id) }
                }) {
                    FileTree(nodes: children, expanded: $expanded)
                } label: {
                    Label(node.name, systemImage: node.symbol)
                }
            } else {
                Label(node.name, systemImage: node.symbol)
            }
        }
    }
}
