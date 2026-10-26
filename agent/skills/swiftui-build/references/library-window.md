---
id: library-window
title: Library window
platforms: [macOS]
availability: macOS 14.0+
docs: https://developer.apple.com/documentation/swiftui/navigationsplitview.md
hig: https://developer.apple.com/design/human-interface-guidelines/sidebars.md
---

# Library window

A sidebar, a sortable table, and an inspector: the classic window for browsing a library.

## Contents

- Built from
- Rules
- Pitfalls
- Key APIs
- Variants
- Related

## Built from

NavigationSplitView
├── sidebar: List(selection:)
│   ├── Section("Library")
│   └── Section("Playlists")
└── detail: Table(selection:sortOrder:)
    ├── .searchable(text:)
    ├── .toolbar { … }
    └── .inspector(isPresented:)
        └── Form

## Rules

- **Use familiar symbols in the sidebar.** A symbol next to each item helps people scan the list and find a place again. Leave their color to the accent color people chose.
- **Keep the sidebar to two levels.** Use short section headers for the groups. If your data goes deeper, add a content column between the sidebar and the details.
- **Let people hide the side panes, but show them at first.** Some people want room for the content, so offer a toolbar button and a View menu command. Start with the sidebar visible so people find it.
- **Don't put key actions at the bottom of the sidebar.** People often move windows so the bottom edge is off screen.

## Pitfalls

- **The table doesn't sort for you.** It shows the sort in its headers and updates `sortOrder`, and you sort your array when that changes.
- **The inspector remembers itself.** A trailing-column inspector has its shown or hidden state restored for you.
- **Add the standard commands.** `SidebarCommands()` adds the built-in sidebar commands, and `InspectorCommands()` adds one that shows and hides the inspector with ⌃⌘I.

## Key APIs

`NavigationSplitView { } detail: { }`, `List(selection:)`, `Table(_:selection:sortOrder:)`, `TableColumn(_:value:)`, `.inspector(isPresented:)`, `.navigationSplitViewColumnWidth`, `SidebarCommands()`, `InspectorCommands()`

## Variants

### Sidebar, table, and inspector

A `NavigationSplitView` with a sidebar `List`, a `Table` in the detail column, and an `.inspector` on the table. The drawing is live; the window is the real thing.

```swift
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
    @State private var sortOrder = [KeyPathComparator(\Song.title)]
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
                    ForEach(Collection.allCases, id: \.self) { item in
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
                selection.isEmpty ? "No Selection" : "\(selection.count) Songs",
                systemImage: "music.note"
            )
        }
    }
}
```

More variants, left out to keep this file short: Add it to your app. Apple's docs: https://developer.apple.com/documentation/swiftui/navigationsplitview.md

## Related

[navigation-split-view](navigation-split-view.md), [table](table.md), [inspector](inspector.md), [search](search.md), [toolbar](toolbar.md), [empty-states](empty-states.md)
