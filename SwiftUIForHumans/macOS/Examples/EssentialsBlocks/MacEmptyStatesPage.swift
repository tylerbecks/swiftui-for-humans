import SwiftUI

extension ComponentPage {
    static let emptyStates = ComponentPage(
        id: "empty-states",
        title: "Empty states",
        summary: "What a sidebar, table, or search shows when there's nothing to show yet.",
        category: .blocks,
        kind: .block,
        symbol: "tray",
        availability: ["macOS 14.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/contentunavailableview",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/writing",
        aliases: [
            "ContentUnavailableView", "empty state", "no results", "no items", "blank slate", "zero state",
            "placeholder", "nothing selected", "no selection", "error state", "try again", "search no results",
        ],
        related: ["library-window", "search", "table", "navigation-split-view", "writing"],
        notes: [
            "**Overlay it, don't replace the list.** Put `ContentUnavailableView` in an `.overlay` on the empty `List` or `Table`, so the column headers, toolbar, and search field stay put.",
            "**`.search` fills in the words for you.** `ContentUnavailableView.search(text:)` builds a no-results message that quotes what people typed.",
        ],
        api: [
            APIItem("`ContentUnavailableView(_:systemImage:)`", "A title and symbol, for simple cases."),
            APIItem("`ContentUnavailableView { } description: { }`", "Adds a line about what to do."),
            APIItem("`actions: { Button… }`", "Buttons under the message."),
            APIItem("`.search(text:)`", "The standard no-results message."),
            APIItem("`.overlay { }`", "Shows it on top of the empty list or table."),
        ],
        guidelines: [
            Guideline(
                "Say what to do next, and give a button for it.",
                "An empty window is daunting when the next step isn't clear. Name the action and put it right there.",
                good: "One click to make the first playlist.",
                bad: "People have to find the command."
            ) {
                MacEmptyPlaylistsSample(showsAction: true)
            } bad: {
                MacEmptyPlaylistsSample(showsAction: false)
            },
            Guideline(
                "Show progress while loading, not an empty state.",
                "“No Items” while data is still on its way looks like a problem. Show a progress indicator until you know the list is empty."
            ),
            Guideline(
                "Keep important information out of it.",
                "An empty state goes away as soon as there's content, and anything in it goes too."
            ),
        ]
    ) {
        ContentUnavailableView("No Playlists", systemImage: "music.note.list")
            .scaleEffect(0.8)
    } content: { page in
        MacEmptyStatesArticle(page: page)
    }
}

extension Catalog {
    /// A real window with a searchable table, to try the no-results state.
    static let emptyStatesDemoWindow = DemoWindow(
        id: "empty-states-search",
        title: "Contacts",
        size: CGSize(width: 560, height: 380)
    ) {
        MacContactsSearchWindow()
    }
}

// MARK: - Sample data

private struct MacContact: Identifiable {
    let id = UUID()
    let name: String
    let email: String

    static let samples = [
        MacContact(name: "Ana Torres", email: "ana@example.com"),
        MacContact(name: "Ben Okafor", email: "ben@example.com"),
        MacContact(name: "Chloe Martin", email: "chloe@example.com"),
        MacContact(name: "Dev Patel", email: "dev@example.com"),
    ]
}

// MARK: - Page

private struct MacEmptyStatesArticle: View {
    let page: ComponentPage

    var body: some View {
        ArticlePage(page: page) {
            Prose("Every list starts empty: a new library, a search with no matches, a detail pane with nothing selected. `ContentUnavailableView` gives each of those a consistent look, a symbol, a title, a line of help, and a button, centered in the space it has.")
            Prose("The examples below are drawn in window frames so you can see them in place. For a real search, open the Contacts window and type a name that isn't there.")
            OpenDemoWindowButton(id: "empty-states-search", label: "Open the Contacts Window")
                .controlSize(.large)

            SectionTitle("Examples")
                .id("examples")
            MacEmptyStatesExamples()
        }
    }
}

private struct MacEmptyStatesExamples: View {
    @State private var playlists: [String] = []
    @State private var contacts: [MacContact] = []
    @State private var searchText = "Zoe"

    private var searchResults: [MacContact] {
        MacContact.samples.filter { searchText.isEmpty || $0.name.localizedStandardContains(searchText) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 44) {
            ExampleCard(
                title: "An empty sidebar",
                caption: "Give a first-run sidebar a title, a short description, and the button that fills it. Click New Playlist to see the list take over.",
                code: """
                @State private var playlists: [String] = []

                List(playlists, id: \\.self) { name in
                    Label(name, systemImage: "music.note.list")
                }
                .overlay {
                    if playlists.isEmpty {
                        ContentUnavailableView {
                            Label("No Playlists", systemImage: "music.note.list")
                        } description: {
                            Text("Playlists you make appear here.")
                        } actions: {
                            Button("New Playlist") {
                                playlists.append("Untitled Playlist")
                            }
                        }
                    }
                }
                """,
                minHeight: 300
            ) {
                MacWindowFrame(title: "Music", width: 420, height: 270) {
                    HStack(spacing: 0) {
                        List(playlists, id: \.self) { name in
                            Label(name, systemImage: "music.note.list")
                        }
                        .scrollContentBackground(.hidden)
                        .overlay {
                            if playlists.isEmpty {
                                ContentUnavailableView {
                                    Label("No Playlists", systemImage: "music.note.list")
                                } description: {
                                    Text("Playlists you make appear here.")
                                } actions: {
                                    Button("New Playlist") {
                                        withAnimation { playlists.append("Untitled Playlist") }
                                    }
                                }
                                .controlSize(.small)
                            }
                        }
                        .frame(width: 200)
                        .background(.fill.quaternary)
                        Divider()
                        Text(playlists.isEmpty ? "" : "Untitled Playlist")
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                } toolbar: {
                    if !playlists.isEmpty {
                        Button("Clear", systemImage: "arrow.counterclockwise") {
                            withAnimation { playlists.removeAll() }
                        }
                        .labelStyle(.iconOnly)
                        .buttonStyle(.borderless)
                    }
                }
            }

            ExampleCard(
                title: "An empty table",
                caption: "Overlay the empty state on the `Table`, so its column headers stay in place and people can see what will fill it.",
                code: """
                @State private var contacts: [Contact] = []

                Table(contacts) {
                    TableColumn("Name", value: \\.name)
                    TableColumn("Email", value: \\.email)
                }
                .overlay {
                    if contacts.isEmpty {
                        ContentUnavailableView {
                            Label("No Contacts", systemImage: "person.2")
                        } description: {
                            Text("Import a file or add someone by hand.")
                        } actions: {
                            Button("Import Contacts…") { }
                        }
                    }
                }
                """,
                minHeight: 300
            ) {
                MacWindowFrame(title: "Contacts", width: 420, height: 270) {
                    Table(contacts) {
                        TableColumn("Name", value: \.name)
                        TableColumn("Email", value: \.email)
                    }
                    .overlay {
                        if contacts.isEmpty {
                            ContentUnavailableView {
                                Label("No Contacts", systemImage: "person.2")
                            } description: {
                                Text("Import a file or add someone by hand.")
                            } actions: {
                                Button("Import Contacts…") {
                                    withAnimation { contacts = MacContact.samples }
                                }
                            }
                        }
                    }
                } toolbar: {
                    if !contacts.isEmpty {
                        Button("Clear", systemImage: "arrow.counterclockwise") {
                            withAnimation { contacts.removeAll() }
                        }
                        .labelStyle(.iconOnly)
                        .buttonStyle(.borderless)
                    }
                }
            }

            ExampleCard(
                title: "No search results",
                caption: "When a search finds nothing, show `ContentUnavailableView.search(text:)`. Clear the field, or type Ana, to bring rows back.",
                code: """
                struct Contact: Identifiable {
                    let id = UUID()
                    let name: String
                    let email: String
                }

                struct ContactsView: View {
                    let contacts: [Contact]
                    @State private var searchText = ""

                    private var results: [Contact] {
                        contacts.filter { searchText.isEmpty || $0.name.localizedStandardContains(searchText) }
                    }

                    var body: some View {
                        NavigationStack {
                            Table(results) {
                                TableColumn("Name", value: \\.name)
                                TableColumn("Email", value: \\.email)
                            }
                            .overlay {
                                if results.isEmpty {
                                    ContentUnavailableView.search(text: searchText)
                                }
                            }
                            .searchable(text: $searchText)
                        }
                    }
                }
                """,
                minHeight: 300,
                aside: Aside(.note, "The drawing uses a text field in place of `.searchable`, which would put its field in this app's own toolbar. The Contacts window has the real one.")
            ) {
                MacWindowFrame(title: "Contacts", width: 420, height: 270) {
                    Table(searchResults) {
                        TableColumn("Name", value: \.name)
                        TableColumn("Email", value: \.email)
                    }
                    .overlay {
                        if searchResults.isEmpty {
                            ContentUnavailableView.search(text: searchText)
                        }
                    }
                } toolbar: {
                    TextField("Search", text: $searchText)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 150)
                }
            }

            ExampleCard(
                title: "Nothing selected",
                caption: "In the detail column of a split view, say what's missing in a few words. No button needed: the next step is clicking the list.",
                code: """
                ContentUnavailableView("No Message Selected", systemImage: "envelope")
                """,
                minHeight: 240
            ) {
                MacWindowFrame(title: "Inbox", width: 420, height: 210) {
                    HStack(spacing: 0) {
                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(["Weekly update", "Lunch on Friday?", "Your receipt"], id: \.self) { subject in
                                Text(subject)
                                    .lineLimit(1)
                                Divider()
                            }
                        }
                        .padding(12)
                        .frame(width: 160)
                        .frame(maxHeight: .infinity, alignment: .top)
                        Divider()
                        ContentUnavailableView("No Message Selected", systemImage: "envelope")
                    }
                }
            }

            ExampleCard(
                title: "Something went wrong",
                caption: "For a failed load, explain it plainly and offer Try Again in `actions:`. Keep the details short; people want the way out.",
                code: """
                ContentUnavailableView {
                    Label("Couldn't Load Photos", systemImage: "wifi.exclamationmark")
                } description: {
                    Text("Check your internet connection, then try again.")
                } actions: {
                    Button("Try Again") { }
                        .buttonStyle(.borderedProminent)
                }
                """,
                minHeight: 220
            ) {
                ContentUnavailableView {
                    Label("Couldn't Load Photos", systemImage: "wifi.exclamationmark")
                } description: {
                    Text("Check your internet connection, then try again.")
                } actions: {
                    Button("Try Again") {}
                        .buttonStyle(.borderedProminent)
                }
            }
        }
    }
}

/// An empty playlist sidebar, with or without its action, for the
/// guideline pair.
private struct MacEmptyPlaylistsSample: View {
    let showsAction: Bool

    var body: some View {
        ContentUnavailableView {
            Label("No Playlists", systemImage: "music.note.list")
        } description: {
            Text("Playlists you make appear here.")
        } actions: {
            if showsAction {
                Button("New Playlist") {}
            }
        }
        .controlSize(.small)
        .frame(width: 260, height: 210)
    }
}

/// The demo window: a real searchable table.
private struct MacContactsSearchWindow: View {
    @State private var searchText = ""

    private var results: [MacContact] {
        MacContact.samples.filter { searchText.isEmpty || $0.name.localizedStandardContains(searchText) }
    }

    var body: some View {
        NavigationStack {
            Table(results) {
                TableColumn("Name", value: \.name)
                TableColumn("Email", value: \.email)
            }
            .overlay {
                if results.isEmpty {
                    ContentUnavailableView.search(text: searchText)
                }
            }
            .searchable(text: $searchText)
        }
    }
}
