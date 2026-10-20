import SwiftUI

extension ComponentPage {
    static let navigationSplitView = ComponentPage(
        id: "navigation-split-view",
        title: "NavigationSplitView",
        summary: "Two or three columns, where a selection in the sidebar fills the detail.",
        category: .navigation,
        symbol: "sidebar.left",
        availability: ["macOS 13.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/navigationsplitview",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/sidebars",
        aliases: [
            "sidebar", "split view", "master detail", "master-detail", "two column", "three column",
            "source list", "NSSplitViewController", "NSSplitView", "columnVisibility", "toggle sidebar",
            "hide sidebar", "NavigationView", "column width",
        ],
        related: ["navigation-stack", "split-views", "list-styles", "outline", "toolbar", "search", "inspector"],
        notes: [
            "**The Mac always shows the content column.** In a three-column view, visibility settings can hide the sidebar, but the middle column stays.",
            "**This app is built on one.** The sidebar beside this page is a `NavigationSplitView` sidebar, with its search field at the top.",
        ],
        about: "`NavigationSplitView` gives a window a sidebar on the leading side and a detail area, with an optional content column between them. Bind each column's `List` selection to state, and the next column shows what's selected.\n\nPut it at the root of a window. Changing the selection from code updates both the list's highlight and the detail.",
        composition: """
        NavigationSplitView
        ├── sidebar: List(selection:)
        ├── content: List(selection:)
        └── detail: the selected item
        """,
        api: [
            APIItem("`init(sidebar:detail:)`", "Two columns: sidebar and detail."),
            APIItem("`init(sidebar:content:detail:)`", "Three columns, each driven by the one before."),
            APIItem("`List(_:selection:)`", "A column whose selection drives the next."),
            APIItem("`columnVisibility:`", "Shows or hides columns from code."),
            APIItem("`.navigationSplitViewColumnWidth`", "A column's preferred, minimum, and maximum width."),
            APIItem("`.toolbar(removing: .sidebarToggle)`", "Removes the sidebar button."),
        ],
        guidelines: [
            Guideline(
                "Keep the selection highlighted.",
                "The highlight in each column shows how it leads to the detail, so people always know where they are.",
                good: "The selected mailbox stays highlighted.",
                bad: "Nothing shows what the detail belongs to."
            ) {
                SidebarHighlightSample(selection: "Inbox")
            } bad: {
                SidebarHighlightSample(selection: nil)
            },
            Guideline(
                "Let people hide the sidebar, but show it at first.",
                "Offer a toolbar button and View menu commands to hide and show it. Hiding it by default makes it hard to discover."
            ),
            Guideline(
                "Show at most two levels in a sidebar.",
                "For deeper hierarchies, add a content column between the sidebar and the detail."
            ),
            Guideline(
                "Keep important things away from the sidebar's bottom.",
                "People often move windows so the bottom edge is off screen."
            ),
        ]
    ) {
        MacWindowFrame(title: "", width: 190, height: 110) {
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 6) {
                    Label("Inbox", systemImage: "tray")
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background(.fill.tertiary, in: .rect(cornerRadius: 4))
                    Label("Sent", systemImage: "paperplane")
                    Spacer(minLength: 0)
                }
                .font(.caption2)
                .padding(6)
                .frame(width: 66, alignment: .leading)
                Divider()
                Text("Message")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
    } content: { page in
        MacNavigationSplitViewArticle(page: page)
    }
}

extension Catalog {
    /// Real split views: two columns and three columns.
    static let navigationSplitViewDemoWindows = [
        DemoWindow(id: "split-two-column", title: "Mail", size: CGSize(width: 680, height: 420)) {
            TwoColumnSample()
        },
        DemoWindow(id: "split-three-column", title: "Notes", size: CGSize(width: 820, height: 460)) {
            ThreeColumnSample()
        },
    ]
}

// MARK: - Page

private struct MacNavigationSplitViewArticle: View {
    let page: ComponentPage

    var body: some View {
        ArticlePage(page: page) {
            if let about = page.about {
                AboutSection(text: about)
            }
            HStack(spacing: 12) {
                OpenDemoWindowButton(id: "split-two-column", label: "Open Two Columns")
                OpenDemoWindowButton(id: "split-three-column", label: "Open Three Columns")
            }
            .controlSize(.large)

            SectionTitle("Usage")
                .id("code")
            CodeBlock(code: """
            @State private var selection: String?
            let mailboxes = ["Inbox", "Drafts", "Sent"]

            NavigationSplitView {
                List(mailboxes, id: \\.self, selection: $selection) { mailbox in
                    Text(mailbox)
                }
            } detail: {
                Text(selection ?? "Select a mailbox")
            }
            """)

            if let composition = page.composition {
                CompositionSection(tree: composition)
            }

            SectionTitle("Examples")
                .id("examples")
            ExampleCard(
                title: "Sidebar and detail",
                caption: "The sidebar's `List` is bound to `selection`, and the detail shows the selected mailbox. Click a mailbox to try it.",
                code: """
                struct Mailbox: Identifiable, Hashable {
                    let name: String
                    let symbol: String
                    var id: String { name }
                }

                struct MailView: View {
                    let mailboxes = [
                        Mailbox(name: "Inbox", symbol: "tray"),
                        Mailbox(name: "Drafts", symbol: "doc"),
                        Mailbox(name: "Sent", symbol: "paperplane"),
                    ]
                    @State private var selection: Mailbox.ID? = "Inbox"

                    var body: some View {
                        NavigationSplitView {
                            List(mailboxes, selection: $selection) { mailbox in
                                Label(mailbox.name, systemImage: mailbox.symbol)
                            }
                            .navigationSplitViewColumnWidth(min: 160, ideal: 200, max: 280)
                        } detail: {
                            if let selection {
                                Text(selection).font(.largeTitle)
                            } else {
                                ContentUnavailableView("No Mailbox Selected", systemImage: "tray")
                            }
                        }
                    }
                }
                """,
                minHeight: 250,
                aside: Aside(.note, "A real split view in a page would take over this app's window, so the preview draws the frame. The Open Two Columns button above shows the real one.")
            ) {
                TwoColumnSketch()
            }

            ExampleCard(
                title: "Three columns",
                caption: "Add a `content` column for one more level. The sidebar picks a folder, the middle column lists its notes, and the detail shows one.",
                code: """
                @State private var folder: String? = "Personal"
                @State private var note: String?
                let notes = [
                    "Personal": ["Groceries", "Trip to Lisbon"],
                    "Work": ["Standup", "Launch plan"],
                ]

                NavigationSplitView {
                    List(["Personal", "Work"], id: \\.self, selection: $folder) { folder in
                        Label(folder, systemImage: "folder")
                    }
                } content: {
                    List(notes[folder ?? ""] ?? [], id: \\.self, selection: $note) { note in
                        Text(note)
                    }
                } detail: {
                    Text(note ?? "Select a note")
                }
                """,
                minHeight: 250
            ) {
                ThreeColumnSketch()
            }

            ExampleCard(
                title: "Hide and show the sidebar",
                caption: "Bind `columnVisibility` to state, then set it to `.detailOnly` to hide the sidebar or `.all` to show every column.",
                code: """
                @State private var columns = NavigationSplitViewVisibility.all

                NavigationSplitView(columnVisibility: $columns) {
                    List(["Inbox", "Sent"], id: \\.self) { Text($0) }
                } detail: {
                    Button("Focus on the Message") {
                        columns = .detailOnly
                    }
                }
                """,
                minHeight: 250
            ) {
                ColumnVisibilitySketch()
            }

            SectionTitle("Push inside a column")
            Prose("To drill down within the detail, put a `NavigationStack` in that column. Links in the sidebar replace what the stack shows, and links inside the detail push onto it. See [NavigationStack](catalog://navigation-stack).")
        }
    }
}

// MARK: - Sketches (inline drawings with live lists)

private struct SketchMailbox: Identifiable, Hashable {
    let name: String
    let symbol: String
    let count: Int
    var id: String { name }

    static let all = [
        SketchMailbox(name: "Inbox", symbol: "tray", count: 12),
        SketchMailbox(name: "Drafts", symbol: "doc", count: 2),
        SketchMailbox(name: "Sent", symbol: "paperplane", count: 48),
        SketchMailbox(name: "Archive", symbol: "archivebox", count: 230),
    ]
}

private struct MailboxDetail: View {
    let mailbox: SketchMailbox?

    var body: some View {
        if let mailbox {
            VStack(spacing: 6) {
                Image(systemName: mailbox.symbol)
                    .font(.largeTitle)
                    .foregroundStyle(.tint)
                Text(mailbox.name)
                    .font(.title2.bold())
                Text("\(mailbox.count) messages")
                    .foregroundStyle(.secondary)
            }
        } else {
            ContentUnavailableView("No Mailbox Selected", systemImage: "tray")
        }
    }
}

private struct TwoColumnSketch: View {
    @State private var selection: SketchMailbox.ID? = "Inbox"

    var body: some View {
        MacWindowFrame(title: "Mail", width: 460, height: 230) {
            HStack(spacing: 0) {
                SketchList(rows: SketchMailbox.all.map { ($0.name, $0.symbol) }, selection: $selection)
                    .frame(width: 150)
                Divider()
                MailboxDetail(mailbox: SketchMailbox.all.first { $0.id == selection })
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}

private let sketchNotes = [
    "Personal": ["Groceries", "Trip to Lisbon"],
    "Work": ["Standup", "Launch plan"],
]

private struct ThreeColumnSketch: View {
    @State private var folder: String? = "Personal"
    @State private var note: String? = "Groceries"

    var body: some View {
        MacWindowFrame(title: "Notes", width: 480, height: 230) {
            HStack(spacing: 0) {
                SketchList(rows: [("Personal", "folder"), ("Work", "folder")], selection: $folder)
                    .frame(width: 120)
                Divider()
                SketchList(rows: (sketchNotes[folder ?? ""] ?? []).map { ($0, nil) }, selection: $note)
                    .frame(width: 140)
                Divider()
                Text(note ?? "Select a note")
                    .font(note == nil ? .body : .title3.bold())
                    .foregroundStyle(note == nil ? .secondary : .primary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .onChange(of: folder) {
                note = nil
            }
        }
    }
}

/// A window drawing with a working sidebar button at the leading edge of
/// its toolbar, like the one `NavigationSplitView` adds.
private struct ColumnVisibilitySketch: View {
    @State private var columns = NavigationSplitViewVisibility.all

    private var showsSidebar: Bool { columns != .detailOnly }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                WindowsNavWindowButtons()
                Button {
                    columns = showsSidebar ? .detailOnly : .all
                } label: {
                    Label(showsSidebar ? "Hide Sidebar" : "Show Sidebar", systemImage: "sidebar.left")
                        .labelStyle(.iconOnly)
                        .imageScale(.large)
                }
                .buttonStyle(.borderless)
                .help(showsSidebar ? "Hide Sidebar" : "Show Sidebar")
                Text("Mail")
                    .font(.headline)
                Spacer()
            }
            .padding(.horizontal, 14)
            .frame(height: 44)
            .background(.bar)
            Divider()
            HStack(spacing: 0) {
                if showsSidebar {
                    SketchList(rows: SketchMailbox.all.prefix(2).map { ($0.name, $0.symbol) }, selection: .constant("Inbox"))
                        .frame(width: 140)
                    .transition(.move(edge: .leading))
                    Divider()
                }
                VStack(spacing: 10) {
                    Text("columns = .\(showsSidebar ? "all" : "detailOnly")")
                        .font(.callout.monospaced())
                        .foregroundStyle(.secondary)
                    Button(showsSidebar ? "Focus on the Message" : "Show the Sidebar") {
                        columns = showsSidebar ? .detailOnly : .all
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .clipped()
        }
        .frame(width: 440, height: 210)
        .windowsNavChrome()
        .animation(.snappy, value: showsSidebar)
    }
}

/// A sidebar list with or without a selected row, for the highlight
/// guideline.
private struct SidebarHighlightSample: View {
    let selection: String?

    var body: some View {
        SketchList(rows: [("Inbox", "tray"), ("Drafts", "doc"), ("Sent", "paperplane")], selection: .constant(selection))
            .frame(width: 180, height: 110)
    }
}

/// Rows drawn like a sidebar list, with a click-to-select highlight. The
/// demo windows use a real `List`.
private struct SketchList: View {
    let rows: [(title: String, symbol: String?)]
    @Binding var selection: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            ForEach(rows, id: \.title) { row in
                let isSelected = selection == row.title
                Button {
                    selection = row.title
                } label: {
                    Group {
                        if let symbol = row.symbol {
                            Label(row.title, systemImage: symbol)
                        } else {
                            Text(row.title)
                        }
                    }
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .foregroundStyle(isSelected ? Color.white : Color.primary)
                    .background(isSelected ? Color.accentColor : Color.clear, in: .rect(cornerRadius: 6))
                    .contentShape(.rect)
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(isSelected ? .isSelected : [])
            }
            Spacer(minLength: 0)
        }
        .padding(8)
        .frame(maxHeight: .infinity)
    }
}

// MARK: - Demo windows (real split views)

private struct TwoColumnSample: View {
    @State private var selection: SketchMailbox.ID? = "Inbox"

    var body: some View {
        NavigationSplitView {
            List(SketchMailbox.all, selection: $selection) { mailbox in
                Label(mailbox.name, systemImage: mailbox.symbol)
                    .badge(mailbox.count)
            }
            .navigationSplitViewColumnWidth(min: 160, ideal: 200, max: 280)
        } detail: {
            MailboxDetail(mailbox: SketchMailbox.all.first { $0.id == selection })
                .navigationTitle(selection ?? "Mail")
        }
    }
}

private struct ThreeColumnSample: View {
    @State private var folder: String? = "Personal"
    @State private var note: String?

    var body: some View {
        NavigationSplitView {
            List(["Personal", "Work"], id: \.self, selection: $folder) { folder in
                Label(folder, systemImage: "folder")
            }
            .navigationSplitViewColumnWidth(min: 150, ideal: 180, max: 240)
        } content: {
            List(sketchNotes[folder ?? ""] ?? [], id: \.self, selection: $note) { note in
                Text(note)
            }
            .navigationSplitViewColumnWidth(min: 180, ideal: 220, max: 320)
        } detail: {
            if let note {
                Text(note)
                    .font(.largeTitle.bold())
            } else {
                ContentUnavailableView("No Note Selected", systemImage: "note.text")
            }
        }
        .onChange(of: folder) {
            note = nil
        }
    }
}
