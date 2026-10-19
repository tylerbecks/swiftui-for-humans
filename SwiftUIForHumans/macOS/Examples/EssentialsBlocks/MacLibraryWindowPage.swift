import SwiftUI

extension ComponentPage {
    static let libraryWindow = ComponentPage(
        id: "library-window",
        title: "Library window",
        summary: "A sidebar, a sortable table, and an inspector: the classic window for browsing a library.",
        category: .blocks,
        kind: .block,
        symbol: "rectangle.split.3x1",
        availability: ["macOS 14.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/navigationsplitview",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/sidebars",
        aliases: [
            "three pane", "three column", "master detail", "split view", "sidebar table inspector",
            "music library", "Finder", "data browser", "admin panel", "NSSplitViewController", "NSTableView",
        ],
        related: ["navigation-split-view", "table", "inspector", "search", "toolbar", "empty-states"],
        notes: [
            "**The table doesn't sort for you.** It shows the sort in its headers and updates `sortOrder`, and you sort your array when that changes.",
            "**The inspector remembers itself.** A trailing-column inspector has its shown or hidden state restored for you.",
            "**Add the standard commands.** `SidebarCommands()` adds the built-in sidebar commands, and `InspectorCommands()` adds one that shows and hides the inspector with ⌃⌘I.",
        ],
        composition: """
        NavigationSplitView
        ├── sidebar: List(selection:)
        │   ├── Section("Library")
        │   └── Section("Playlists")
        └── detail: Table(selection:sortOrder:)
            ├── .searchable(text:)
            ├── .toolbar { … }
            └── .inspector(isPresented:)
                └── Form
        """,
        api: [
            APIItem("`NavigationSplitView { } detail: { }`", "The sidebar and the content beside it."),
            APIItem("`List(selection:)`", "A sidebar whose selection picks the rows."),
            APIItem("`Table(_:selection:sortOrder:)`", "Rows and columns, selectable and sortable."),
            APIItem("`TableColumn(_:value:)`", "A column, sortable by a key path."),
            APIItem("`.inspector(isPresented:)`", "A trailing column for details."),
            APIItem("`.navigationSplitViewColumnWidth`", "Sets the sidebar's width range."),
            APIItem("`SidebarCommands()`", "The built-in commands for the sidebar."),
            APIItem("`InspectorCommands()`", "Toggles the inspector with ⌃⌘I."),
        ],
        guidelines: [
            Guideline(
                "Use familiar symbols in the sidebar.",
                "A symbol next to each item helps people scan the list and find a place again. Leave their color to the accent color people chose.",
                good: "Symbols make each item quick to spot.",
                bad: "Plain text is harder to scan."
            ) {
                MacSidebarSample(showsSymbols: true)
            } bad: {
                MacSidebarSample(showsSymbols: false)
            },
            Guideline(
                "Keep the sidebar to two levels.",
                "Use short section headers for the groups. If your data goes deeper, add a content column between the sidebar and the details."
            ),
            Guideline(
                "Let people hide the side panes, but show them at first.",
                "Some people want room for the content, so offer a toolbar button and a View menu command. Start with the sidebar visible so people find it."
            ),
            Guideline(
                "Don't put key actions at the bottom of the sidebar.",
                "People often move windows so the bottom edge is off screen."
            ),
        ]
    ) {
        MacLibraryThumbnail()
    } content: { page in
        MacLibraryWindowArticle(page: page)
    }
}

extension Catalog {
    /// The library block, for real: split view, table, inspector, toolbar,
    /// and search.
    static let libraryWindowDemoWindow = DemoWindow(
        id: "library-window",
        title: "Library",
        size: CGSize(width: 980, height: 540)
    ) {
        MacLibraryView()
    }
}

// MARK: - Model

private struct MacSong: Identifiable, Hashable {
    let id = UUID()
    var title: String
    var artist: String
    var album: String
    var seconds: Int
    var isFavorite = false
    var playlist: String? = nil

    static let samples = [
        MacSong(title: "Blue Hour", artist: "The Lanterns", album: "City Lights", seconds: 214, isFavorite: true, playlist: "Focus"),
        MacSong(title: "Northbound", artist: "Mara Quinn", album: "Open Road", seconds: 187, playlist: "Road Trip"),
        MacSong(title: "Paper Boats", artist: "The Lanterns", album: "City Lights", seconds: 241),
        MacSong(title: "Slow Tide", artist: "Okon", album: "Harbor", seconds: 305, isFavorite: true, playlist: "Focus"),
        MacSong(title: "Highway Song", artist: "Mara Quinn", album: "Open Road", seconds: 198, playlist: "Road Trip"),
        MacSong(title: "Late Train", artist: "Okon", album: "Harbor", seconds: 262),
        MacSong(title: "Glasshouse", artist: "Juniper", album: "Seasons", seconds: 223, isFavorite: true),
        MacSong(title: "First Snow", artist: "Juniper", album: "Seasons", seconds: 176, playlist: "Focus"),
    ]
}

private enum MacCollection: String, Hashable, CaseIterable {
    case all = "Songs"
    case favorites = "Favorites"
    case focus = "Focus"
    case roadTrip = "Road Trip"

    var symbol: String {
        switch self {
        case .all: "music.note"
        case .favorites: "star"
        case .focus, .roadTrip: "music.note.list"
        }
    }

    func contains(_ song: MacSong) -> Bool {
        switch self {
        case .all: true
        case .favorites: song.isFavorite
        case .focus, .roadTrip: song.playlist == rawValue
        }
    }
}

// MARK: - Thumbnail

private struct MacLibraryThumbnail: View {
    var body: some View {
        MacWindowFrame(width: 210, height: 120) {
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(0..<4) { _ in
                        Capsule().fill(.fill.secondary).frame(width: 34, height: 5)
                    }
                }
                .padding(8)
                .frame(maxHeight: .infinity, alignment: .top)
                .background(.fill.quaternary)
                VStack(spacing: 7) {
                    ForEach(0..<5) { index in
                        Capsule().fill(index == 1 ? AnyShapeStyle(.tint) : AnyShapeStyle(.fill.tertiary)).frame(height: 5)
                    }
                }
                .padding(8)
                .frame(maxHeight: .infinity, alignment: .top)
                VStack(alignment: .leading, spacing: 6) {
                    RoundedRectangle(cornerRadius: 4).fill(.fill.secondary).frame(width: 30, height: 30)
                    Capsule().fill(.fill.secondary).frame(width: 30, height: 5)
                }
                .padding(8)
                .frame(maxHeight: .infinity, alignment: .top)
                .background(.fill.quaternary)
            }
        }
    }
}

// MARK: - Page

private struct MacLibraryWindowArticle: View {
    let page: ComponentPage

    var body: some View {
        ArticlePage(page: page) {
            Prose("The classic Mac window for browsing lots of things: collections in a sidebar, the items in a table you can sort and search, and details about the selection in an inspector on the right. Many Mac apps that browse a library are built this way.")
            OpenDemoWindowButton(id: "library-window", label: "Open the Library Window")
                .controlSize(.large)

            SectionTitle("The block")
                .id("code")
            ExampleCard(
                title: "Sidebar, table, and inspector",
                caption: "A `NavigationSplitView` with a sidebar `List`, a `Table` in the detail column, and an `.inspector` on the table. The drawing is live; the window is the real thing.",
                code: Self.code,
                minHeight: 320
            ) {
                MacLibraryDrawing()
            }

            if let composition = page.composition {
                CompositionSection(tree: composition)
            }

            SectionTitle("How the parts connect")
            ConnectFacts(rows: [
                ("Sidebar", "`List(selection: $collection)` picks which songs the table shows. Sections give it two levels: Library and Playlists."),
                ("Table", "`selection` is a `Set` of IDs, so people can select several rows. Clicking a header updates `sortOrder`, and `onChange` sorts the array."),
                ("Inspector", "Shows the single selected song and edits it through a binding into the array. With nothing selected, it says so."),
                ("Toolbar and search", "`.searchable` puts the field in the toolbar. The inspector button sits at the trailing end, next to the pane it toggles."),
            ])

            SectionTitle("Add it to your app")
            CodeBlock(code: """
            @main
            struct MusicApp: App {
                var body: some Scene {
                    WindowGroup {
                        LibraryView()
                    }
                    .commands {
                        SidebarCommands()
                        InspectorCommands()
                    }
                }
            }
            """)
        }
    }

    static let code = """
    struct Song: Identifiable, Hashable {
        let id = UUID()
        var title: String
        var artist: String
        var album: String
        var seconds: Int
        var isFavorite = false
    }

    enum Collection: String, Hashable, CaseIterable {
        case all = "Songs"
        case favorites = "Favorites"

        var symbol: String { self == .all ? "music.note" : "star" }
    }

    struct LibraryView: View {
        @State private var songs = [
            Song(title: "Blue Hour", artist: "The Lanterns", album: "City Lights", seconds: 214, isFavorite: true),
            Song(title: "Northbound", artist: "Mara Quinn", album: "Open Road", seconds: 187),
            Song(title: "Slow Tide", artist: "Okon", album: "Harbor", seconds: 305),
        ]
        @State private var collection: Collection? = .all
        @State private var selection = Set<Song.ID>()
        @State private var sortOrder = [KeyPathComparator(\\Song.title)]
        @State private var searchText = ""
        @State private var showsInspector = true

        private var visibleSongs: [Song] {
            songs.filter { song in
                (collection != .favorites || song.isFavorite)
                    && (searchText.isEmpty || song.title.localizedStandardContains(searchText))
            }
        }

        var body: some View {
            NavigationSplitView {
                List(selection: $collection) {
                    Section("Library") {
                        ForEach(Collection.allCases, id: \\.self) { item in
                            Label(item.rawValue, systemImage: item.symbol)
                        }
                    }
                }
                .navigationSplitViewColumnWidth(min: 160, ideal: 200)
            } detail: {
                Table(visibleSongs, selection: $selection, sortOrder: $sortOrder) {
                    TableColumn("Title", value: \\.title)
                    TableColumn("Artist", value: \\.artist)
                    TableColumn("Album", value: \\.album)
                    TableColumn("Time", value: \\.seconds) { song in
                        Text(Duration.seconds(song.seconds), format: .time(pattern: .minuteSecond))
                    }
                    .width(60)
                }
                .onChange(of: sortOrder) {
                    songs.sort(using: sortOrder)
                }
                .searchable(text: $searchText)
                .navigationTitle(collection?.rawValue ?? "Library")
                .inspector(isPresented: $showsInspector) {
                    SongInspector(songs: $songs, selection: selection)
                        .inspectorColumnWidth(min: 220, ideal: 260)
                }
                .toolbar {
                    Button("Inspector", systemImage: "info.circle") {
                        showsInspector.toggle()
                    }
                }
            }
        }
    }

    struct SongInspector: View {
        @Binding var songs: [Song]
        let selection: Set<Song.ID>

        var body: some View {
            if selection.count == 1, let index = songs.firstIndex(where: { selection.contains($0.id) }) {
                Form {
                    TextField("Title", text: $songs[index].title)
                    TextField("Artist", text: $songs[index].artist)
                    TextField("Album", text: $songs[index].album)
                    Toggle("Favorite", isOn: $songs[index].isFavorite)
                }
            } else {
                ContentUnavailableView(
                    selection.isEmpty ? "No Selection" : "\\(selection.count) Songs",
                    systemImage: "music.note"
                )
            }
        }
    }
    """
}

// MARK: - Inline drawing

/// The block drawn in a window frame: a real sidebar list, table, and
/// inspector, laid out side by side because a real split view would take
/// over this app's window.
private struct MacLibraryDrawing: View {
    @State private var songs = MacSong.samples
    @State private var collection: MacCollection? = .all
    @State private var selection: Set<MacSong.ID> = [MacSong.samples[0].id]
    @State private var sortOrder = [KeyPathComparator(\MacSong.title)]

    private var visibleSongs: [MacSong] {
        songs.filter { collection?.contains($0) ?? true }
    }

    var body: some View {
        MacWindowFrame(title: collection?.rawValue ?? "Library", width: 480, height: 300) {
            HStack(spacing: 0) {
                List(selection: $collection) {
                    Section("Library") {
                        ForEach([MacCollection.all, .favorites], id: \.self) { item in
                            Label(item.rawValue, systemImage: item.symbol)
                        }
                    }
                    Section("Playlists") {
                        ForEach([MacCollection.focus, .roadTrip], id: \.self) { item in
                            Label(item.rawValue, systemImage: item.symbol)
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .background(.fill.quaternary)
                .frame(width: 130)
                Divider()
                Table(visibleSongs, selection: $selection, sortOrder: $sortOrder) {
                    TableColumn("Title", value: \.title)
                    TableColumn("Artist", value: \.artist)
                }
                .onChange(of: sortOrder) {
                    songs.sort(using: sortOrder)
                }
                Divider()
                MacSongInspector(songs: $songs, selection: selection)
                    .frame(width: 130)
                    .background(.background.secondary)
            }
        } toolbar: {
            Image(systemName: "magnifyingglass")
            Image(systemName: "info.circle")
        }
    }
}

private struct MacSongInspector: View {
    @Binding var songs: [MacSong]
    let selection: Set<MacSong.ID>
    var isCompact = true

    var body: some View {
        if selection.count == 1, let index = songs.firstIndex(where: { selection.contains($0.id) }) {
            if isCompact {
                VStack(alignment: .leading, spacing: 8) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.accentColor.gradient)
                        .frame(width: 70, height: 70)
                        .overlay {
                            Image(systemName: "music.note")
                                .font(.title)
                                .foregroundStyle(.white)
                        }
                    Text(songs[index].title)
                        .font(.headline)
                    Text(songs[index].artist)
                        .foregroundStyle(.secondary)
                    Toggle("Favorite", isOn: $songs[index].isFavorite)
                        .toggleStyle(.checkbox)
                }
                .font(.callout)
                .padding(10)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            } else {
                Form {
                    TextField("Title", text: $songs[index].title)
                    TextField("Artist", text: $songs[index].artist)
                    TextField("Album", text: $songs[index].album)
                    Toggle("Favorite", isOn: $songs[index].isFavorite)
                }
            }
        } else {
            ContentUnavailableView(
                selection.isEmpty ? "No Selection" : "\(selection.count) Songs",
                systemImage: "music.note"
            )
        }
    }
}

/// A small sidebar, with or without symbols, for the guideline pair.
private struct MacSidebarSample: View {
    let showsSymbols: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Library")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            ForEach([("Songs", "music.note"), ("Albums", "square.stack"), ("Artists", "music.mic"), ("Favorites", "star")], id: \.0) { title, symbol in
                if showsSymbols {
                    Label {
                        Text(title)
                    } icon: {
                        Image(systemName: symbol)
                            .foregroundStyle(.tint)
                    }
                } else {
                    Text(title)
                }
            }
        }
        .frame(width: 150, alignment: .leading)
        .padding(12)
        .background(.fill.quaternary, in: .rect(cornerRadius: 10))
    }
}

// MARK: - Demo window

/// The real block, in its own window.
private struct MacLibraryView: View {
    @State private var songs = MacSong.samples
    @State private var collection: MacCollection? = .all
    @State private var selection = Set<MacSong.ID>()
    @State private var sortOrder = [KeyPathComparator(\MacSong.title)]
    @State private var searchText = ""
    @State private var showsInspector = true

    private var visibleSongs: [MacSong] {
        songs.filter { song in
            (collection?.contains(song) ?? true)
                && (searchText.isEmpty || song.title.localizedStandardContains(searchText))
        }
    }

    var body: some View {
        NavigationSplitView {
            List(selection: $collection) {
                Section("Library") {
                    ForEach([MacCollection.all, .favorites], id: \.self) { item in
                        Label(item.rawValue, systemImage: item.symbol)
                    }
                }
                Section("Playlists") {
                    ForEach([MacCollection.focus, .roadTrip], id: \.self) { item in
                        Label(item.rawValue, systemImage: item.symbol)
                    }
                }
            }
            .navigationSplitViewColumnWidth(min: 160, ideal: 200)
        } detail: {
            Table(visibleSongs, selection: $selection, sortOrder: $sortOrder) {
                TableColumn("Title", value: \.title)
                TableColumn("Artist", value: \.artist)
                TableColumn("Album", value: \.album)
                TableColumn("Time", value: \.seconds) { song in
                    Text(Duration.seconds(song.seconds), format: .time(pattern: .minuteSecond))
                }
                .width(60)
            }
            .onChange(of: sortOrder) {
                songs.sort(using: sortOrder)
            }
            .searchable(text: $searchText)
            .navigationTitle(collection?.rawValue ?? "Library")
            .inspector(isPresented: $showsInspector) {
                MacSongInspector(songs: $songs, selection: selection, isCompact: false)
                    .inspectorColumnWidth(min: 220, ideal: 260)
            }
            .toolbar {
                Button("Inspector", systemImage: "info.circle") {
                    showsInspector.toggle()
                }
            }
        }
    }
}
