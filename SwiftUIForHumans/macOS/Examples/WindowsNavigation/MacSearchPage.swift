import SwiftUI

extension ComponentPage {
    static let search = ComponentPage(
        id: "search",
        title: "Search",
        summary: "A search field in the toolbar or sidebar, with suggestions and tokens.",
        category: .navigation,
        symbol: "magnifyingglass",
        availability: ["macOS 12.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/adding-a-search-interface-to-your-app",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/search-fields",
        aliases: [
            "searchable", "search field", "search bar", "NSSearchField", "filter", "find",
            "Command-F", "⌘F", "searchSuggestions", "searchCompletion", "search tokens",
            "searchFocused", "input type=search", "autocomplete", "typeahead",
        ],
        related: ["toolbar", "navigation-split-view", "text-field", "focus-keyboard", "keyboard-shortcuts", "list-styles"],
        notes: [
            "**Search as people type.** Filtering on every keystroke feels responsive. For slow searches, like ones over the network, wait for Return with `.onSubmit(of: .search)`.",
            "**This app does it.** Its sidebar search uses `placement: .sidebar`, and Go > Search (⌘F) focuses the field with `searchFocused`.",
        ],
        about: "Add `.searchable(text:)` to a `NavigationSplitView` or `NavigationStack`, or a view inside one, and a search field appears at the trailing edge of the window's toolbar. You own the text, and filter your data with it; SwiftUI draws and manages the field.\n\nWith `placement: .sidebar`, the field sits at the top of the sidebar instead, which suits search that filters the sidebar itself.",
        composition: """
        NavigationSplitView
        ├── sidebar
        ├── detail
        └── .searchable(text:)
            └── .searchSuggestions { }
        """,
        api: [
            APIItem("`.searchable(text:prompt:)`", "Adds a search field bound to your text."),
            APIItem("`placement: .sidebar`", "Puts the field at the top of the sidebar."),
            APIItem("`.searchSuggestions { }`", "Suggestions shown below the field."),
            APIItem("`.searchCompletion(_:)`", "The text a suggestion fills in."),
            APIItem("`.searchable(text:tokens:)`", "Search terms as removable tokens."),
            APIItem("`.searchFocused(_:)`", "Focuses the field from code (macOS 15)."),
            APIItem("`.onSubmit(of: .search)`", "Runs when people press Return."),
        ],
        guidelines: [
            Guideline(
                "Say what people can search for.",
                "Placeholder text like “Songs, Artists, Albums” tells people what the field covers before they type.",
                good: "The prompt says what's searchable.",
                bad: "A bare prompt leaves people guessing."
            ) {
                SearchFieldSample(prompt: "Songs, Artists, Albums")
            } bad: {
                SearchFieldSample(prompt: "Search")
            },
            Guideline(
                "Put search at the trailing end of the toolbar.",
                "It's the familiar spot in apps like Mail and Notes, and people can browse results while their selection stays visible in the detail."
            ),
            Guideline(
                "Use the top of the sidebar for filtering the sidebar.",
                "When search narrows down the sidebar's own items, like System Settings, a field at its top makes the link clear."
            ),
            Guideline(
                "Suggest searches, and pair tokens with suggestions.",
                "Recent or likely searches help people search faster, and suggestions teach which tokens exist."
            ),
        ]
    ) {
        HStack(spacing: 6) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            Text("Search")
                .foregroundStyle(.tertiary)
            Spacer()
        }
        .font(.callout)
        .padding(.horizontal, 8)
        .frame(width: 170, height: 26)
        .background(.fill.tertiary, in: .capsule)
    } content: { page in
        MacSearchArticle(page: page)
    }
}

extension Catalog {
    /// A real searchable window with suggestions, tokens, and a shortcut
    /// that focuses the field.
    static let searchDemoWindow = DemoWindow(id: "search-library", title: "Library", size: CGSize(width: 560, height: 400)) {
        SearchWindowSample()
    }
}

// MARK: - Page

private struct MacSearchArticle: View {
    let page: ComponentPage

    var body: some View {
        ArticlePage(page: page) {
            if let about = page.about {
                AboutSection(text: about)
            }
            OpenDemoWindowButton(id: "search-library", label: "Open the Library Window")
                .controlSize(.large)

            SectionTitle("Usage")
                .id("code")
            CodeBlock(code: """
            @State private var query = ""
            let fruits = ["Apple", "Banana", "Cherry", "Mango"]

            NavigationStack {
                List(fruits.filter { query.isEmpty || $0.localizedStandardContains(query) },
                     id: \\.self) { fruit in
                    Text(fruit)
                }
                .searchable(text: $query, prompt: "Fruit")
            }
            """)

            if let composition = page.composition {
                CompositionSection(tree: composition)
            }

            SectionTitle("Examples")
                .id("examples")
            ExampleCard(
                title: "Filter as people type",
                caption: "Bind `.searchable` to a string and filter with it. `localizedStandardContains` ignores case and accents, as people expect.",
                code: """
                @State private var query = ""
                let books = ["Emma", "Dracula", "Middlemarch", "Persuasion", "Ulysses"]

                var results: [String] {
                    query.isEmpty ? books : books.filter { $0.localizedStandardContains(query) }
                }

                NavigationStack {
                    List(results, id: \\.self) { book in
                        Label(book, systemImage: "book")
                    }
                    .searchable(text: $query, prompt: "Titles")
                }
                """,
                minHeight: 250,
                aside: Aside(.note, "A real search field in a page would join this app's own toolbar, so the preview draws the window around a live field. The Library window above is the real thing.")
            ) {
                FilterSketch()
            }

            ExampleCard(
                title: "Suggest searches",
                caption: "`.searchSuggestions` lists views below the field, and each one's `searchCompletion` is the text it fills in. Click the field to see them.",
                code: """
                @State private var query = ""

                NavigationStack {
                    List { Text("Results") }
                        .searchable(text: $query, prompt: "Titles")
                        .searchSuggestions {
                            Section("Recent") {
                                Label("Emma", systemImage: "clock").searchCompletion("Emma")
                                Label("Dracula", systemImage: "clock").searchCompletion("Dracula")
                            }
                        }
                }
                """,
                minHeight: 260
            ) {
                SuggestionsSketch()
            }

            ExampleCard(
                title: "Tokens",
                caption: "With `searchable(text:tokens:)`, a search term becomes a token people can remove as one piece. Offer tokens as suggestions so people find them.",
                code: """
                enum Genre: String, Identifiable, CaseIterable {
                    case novel, poetry, drama
                    var id: Self { self }
                }

                @State private var query = ""
                @State private var genres: [Genre] = []

                NavigationStack {
                    List { Text("Results") }
                        .searchable(text: $query, tokens: $genres, prompt: "Titles") { genre in
                            Text(genre.rawValue.capitalized)
                        }
                        .searchSuggestions {
                            ForEach(Genre.allCases) { genre in
                                Text(genre.rawValue.capitalized).searchCompletion(genre)
                            }
                        }
                }
                """,
                minHeight: 200
            ) {
                TokensSketch()
            }

            ExampleCard(
                title: "Focus the field with a shortcut",
                caption: "`.searchFocused` binds the field's focus to a `@FocusState`. Publish an action that sets it, and call it from a Find command.",
                code: """
                struct FindAction {
                    let perform: @MainActor () -> Void
                }

                extension FocusedValues {
                    @Entry var findAction: FindAction?
                }

                struct FindCommands: Commands {
                    @FocusedValue(\\.findAction) private var findAction

                    var body: some Commands {
                        CommandGroup(after: .textEditing) {
                            Button("Find…") { findAction?.perform() }
                                .keyboardShortcut("f")
                                .disabled(findAction == nil)
                        }
                    }
                }

                struct LibraryView: View {
                    @State private var query = ""
                    @FocusState private var isSearchFocused: Bool

                    var body: some View {
                        NavigationStack {
                            List { Text("Results") }
                                .searchable(text: $query)
                                .searchFocused($isSearchFocused)
                        }
                        .focusedSceneValue(\\.findAction, FindAction { isSearchFocused = true })
                    }
                }
                """,
                minHeight: 140,
                aside: Aside(.note, "The Mac's standard shortcuts list ⌘F for Find and ⌥⌘F for jumping to the search field. The Library window uses ⌥⌘F, because this app's own Go > Search already takes ⌘F.")
            ) {
                VStack(spacing: 12) {
                    OpenDemoWindowButton(id: "search-library", label: "Open the Library Window")
                    Text("Then press ⌥⌘F to jump to its search field.")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

// MARK: - Samples

private let sampleBooks = ["Emma", "Dracula", "Middlemarch", "Persuasion", "Ulysses", "Frankenstein"]

/// A drawn search field around a live text field.
private struct ToolbarSearchField: View {
    @Binding var text: String
    var prompt = "Titles"
    var width: CGFloat = 160

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            TextField(prompt, text: $text)
                .textFieldStyle(.plain)
            if !text.isEmpty {
                Button("Clear", systemImage: "xmark.circle.fill") { text = "" }
                    .labelStyle(.iconOnly)
                    .buttonStyle(.borderless)
                    .foregroundStyle(.secondary)
            }
        }
        .font(.callout)
        .imageScale(.medium)
        .padding(.horizontal, 8)
        .frame(width: width, height: 26)
        .background(.fill.tertiary, in: .capsule)
    }
}

private struct FilterSketch: View {
    @State private var query = ""

    private var results: [String] {
        query.isEmpty ? sampleBooks : sampleBooks.filter { $0.localizedStandardContains(query) }
    }

    var body: some View {
        MacWindowFrame(title: "Library", width: 440, height: 230) {
            VStack(alignment: .leading, spacing: 0) {
                if results.isEmpty {
                    ContentUnavailableView.search(text: query)
                } else {
                    ForEach(results, id: \.self) { book in
                        Label(book, systemImage: "book")
                            .padding(.horizontal, 14)
                            .padding(.vertical, 5)
                    }
                    Spacer(minLength: 0)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .padding(.top, 6)
        } toolbar: {
            ToolbarSearchField(text: $query)
        }
    }
}

/// A drawn field that lists recent searches while it's focused and empty.
private struct SuggestionsSketch: View {
    @State private var query = ""
    @FocusState private var isFocused: Bool

    var body: some View {
        MacWindowFrame(title: "Library", width: 440, height: 240) {
            Text(query.isEmpty ? "Click the search field." : "Results for “\(query)”")
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } toolbar: {
            ToolbarSearchField(text: $query)
                .focused($isFocused)
        }
        .overlay(alignment: .topTrailing) {
            if isFocused && query.isEmpty {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Recent")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.top, 4)
                    ForEach(["Emma", "Dracula"], id: \.self) { suggestion in
                        Button {
                            query = suggestion
                        } label: {
                            Label(suggestion, systemImage: "clock")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .contentShape(.rect)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(4)
                .frame(width: 160)
                .background(.background, in: .rect(cornerRadius: 8))
                .overlay {
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(.separator)
                }
                .shadow(color: .black.opacity(0.15), radius: 6, y: 2)
                .padding(.top, 40)
                .padding(.trailing, 14)
            }
        }
    }
}

private enum SketchGenre: String, CaseIterable, Identifiable {
    case novel, poetry, drama
    var id: Self { self }
}

/// A drawn field with tokens: click a genre to add it, and the token's
/// button to remove it.
private struct TokensSketch: View {
    @State private var genres: [SketchGenre] = [.novel]

    var body: some View {
        VStack(spacing: 14) {
            HStack(spacing: 5) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                ForEach(genres) { genre in
                    Button {
                        genres.removeAll { $0 == genre }
                    } label: {
                        HStack(spacing: 3) {
                            Text(genre.rawValue.capitalized)
                            Image(systemName: "xmark")
                                .font(.caption2.bold())
                        }
                        .padding(.horizontal, 6)
                        .padding(.vertical, 1)
                        .background(Color.accentColor.opacity(0.2), in: .rect(cornerRadius: 4))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Remove \(genre.rawValue)")
                }
                Text("Titles")
                    .foregroundStyle(.tertiary)
                Spacer(minLength: 0)
            }
            .font(.callout)
            .padding(.horizontal, 8)
            .frame(width: 300, height: 28)
            .background(.fill.tertiary, in: .capsule)
            .animation(.snappy, value: genres)

            HStack(spacing: 8) {
                Text("Suggestions:")
                    .foregroundStyle(.secondary)
                ForEach(SketchGenre.allCases) { genre in
                    Button(genre.rawValue.capitalized) {
                        if !genres.contains(genre) { genres.append(genre) }
                    }
                    .disabled(genres.contains(genre))
                }
            }
        }
    }
}

/// A plain search field drawing for the prompt guideline.
private struct SearchFieldSample: View {
    let prompt: String

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            Text(prompt)
                .foregroundStyle(.tertiary)
            Spacer(minLength: 0)
        }
        .font(.callout)
        .padding(.horizontal, 8)
        .frame(width: 210, height: 26)
        .background(.fill.tertiary, in: .capsule)
    }
}

// MARK: - Demo window

private enum LibraryGenre: String, CaseIterable, Identifiable {
    case novel, gothic, satire
    var id: Self { self }
}

private struct LibraryBook: Identifiable {
    let title: String
    let genre: LibraryGenre
    var id: String { title }

    static let all = [
        LibraryBook(title: "Emma", genre: .novel),
        LibraryBook(title: "Dracula", genre: .gothic),
        LibraryBook(title: "Middlemarch", genre: .novel),
        LibraryBook(title: "Frankenstein", genre: .gothic),
        LibraryBook(title: "Gulliver's Travels", genre: .satire),
        LibraryBook(title: "Persuasion", genre: .novel),
    ]
}

/// The real thing: `.searchable` with tokens and suggestions, and ⌥⌘F to
/// focus the field.
private struct SearchWindowSample: View {
    @State private var query = ""
    @State private var genres: [LibraryGenre] = []
    @FocusState private var isSearchFocused: Bool

    private var results: [LibraryBook] {
        LibraryBook.all.filter { book in
            (query.isEmpty || book.title.localizedStandardContains(query))
                && (genres.isEmpty || genres.contains(book.genre))
        }
    }

    var body: some View {
        NavigationStack {
            List(results) { book in
                LabeledContent {
                    Text(book.genre.rawValue.capitalized)
                } label: {
                    Label(book.title, systemImage: "book")
                }
            }
            .overlay {
                if results.isEmpty {
                    ContentUnavailableView.search(text: query)
                }
            }
            .searchable(text: $query, tokens: $genres, prompt: "Titles") { genre in
                Text(genre.rawValue.capitalized)
            }
            .searchSuggestions {
                if query.isEmpty {
                    Section("Genres") {
                        ForEach(LibraryGenre.allCases) { genre in
                            Label(genre.rawValue.capitalized, systemImage: "tag")
                                .searchCompletion(genre)
                        }
                    }
                }
            }
            .searchFocused($isSearchFocused)
            .toolbar {
                Button("Jump to Search", systemImage: "magnifyingglass") {
                    isSearchFocused = true
                }
                .keyboardShortcut("f", modifiers: [.option, .command])
                .help("Jump to Search (⌥⌘F)")
            }
        }
    }
}
