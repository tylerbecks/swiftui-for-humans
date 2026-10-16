import SwiftUI

extension ComponentPage {
    static let searchable = ComponentPage(
        id: "searchable",
        title: "Searchable",
        summary: "Adds a system search field to a screen and hands you the text to filter with.",
        category: .lists,
        symbol: "magnifyingglass",
        availability: ["iOS 15.0+", "macOS 12.0+", "visionOS 1.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/view/searchable(text:placement:prompt:)",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/search-fields",
        aliases: ["search bar", "search box", "filter", "input type=search", "UISearchController", "UISearchBar", "autocomplete", "typeahead", "find"],
        related: ["list", "navigation-stack", "text-field", "toolbar"],
        notes: [
            "**On iPhone the field sits at the bottom.** In iOS 26 that's the default, where thumbs reach it. `.navigationBarDrawer` keeps it under the title instead.",
            "**For app-wide search, use a search tab.** `Tab(role: .search)` in a [TabView](catalog://tab-view) keeps search one tap away from every section.",
        ],
        api: [
            APIItem("`.searchable(text:prompt:)`", "Adds the field and binds its text."),
            APIItem("`placement:`", "Where the field goes, like `.navigationBarDrawer`."),
            APIItem("`.searchSuggestions { }`", "Rows shown while the field is active."),
            APIItem("`.searchCompletion(_:)`", "On a suggestion: fills the field when tapped."),
            APIItem("`.searchScopes(_:scopes:)`", "A segmented filter under the field."),
            APIItem("`.onSubmit(of: .search)`", "Runs when people tap Search on the keyboard."),
            APIItem("`ContentUnavailableView.search(text:)`", "The standard “No Results” view."),
        ],
        guidelines: [
            Guideline(
                "Say what people can search for.",
                "A specific prompt like “Search recipes” sets expectations. The default “Search” doesn't tell people what's inside.",
                good: "The prompt names what's searchable.",
                bad: "A generic prompt says nothing."
            ) {
                SearchPromptSample(prompt: "Search recipes")
            } bad: {
                SearchPromptSample(prompt: "Search")
            },
            Guideline(
                "Update results as people type.",
                "Live results feel fast and help people narrow down. Wait for the Search key only when a search is slow, like a network request."
            ),
            Guideline(
                "Suggest searches before people type.",
                "Recent or popular searches in `.searchSuggestions` save typing and show what's possible."
            ),
            Guideline(
                "Start with the broadest scope.",
                "Show all results first and let people narrow them with scopes. Use scopes only for a few clear categories."
            ),
        ]
    ) {
        SearchThumbnail()
    } content: { page in
        SearchableDemo(page: page)
    }
}

// MARK: - Model

private enum SearchScope: String, CaseIterable, Hashable {
    case all = "All", red = "Red", yellow = "Yellow", green = "Green"
}

private let searchFruits: [(name: String, color: SearchScope)] = [
    ("Apple", .red), ("Banana", .yellow), ("Cherry", .red), ("Kiwi", .green),
    ("Lemon", .yellow), ("Lime", .green), ("Mango", .yellow), ("Pear", .green),
    ("Raspberry", .red), ("Strawberry", .red),
]

private struct SearchConfig {
    var placement: SearchPlacement = .automatic
    var prompt = "Search fruit"
    var suggestions = true
    var scopes = false
    var text = ""
    var scope: SearchScope = .all
}

private struct SearchableDemo: View {
    let page: ComponentPage

    var body: some View {
        DemoPage(
            page: page,
            initial: SearchConfig(),
            previewHeight: 600,
            usage: """
            @State private var searchText = ""

            let fruits = ["Apple", "Banana", "Cherry", "Kiwi"]

            NavigationStack {
                List(fruits.filter { searchText.isEmpty || $0.localizedStandardContains(searchText) }, id: \\.self) { fruit in
                    Text(fruit)
                }
                .navigationTitle("Fruit")
                .searchable(text: $searchText, prompt: "Search fruit")
            }
            """,
            usageNote: Aside(.important, "`.searchable` only draws the field; you filter the data yourself. It also needs a `NavigationStack` around it to have a bar to live in.")
        ) { $config in
            PhoneScreen {
                SearchScreen(config: $config)
            }
            // Placement can't change on a live search field; rebuild the screen.
            .id(config.placement)
            .background { Color.clear.id("phone") }
        } controls: { $config in
            Section("Field") {
                TextField("Prompt", text: $config.prompt)
                OptionPicker("Placement", selection: $config.placement)
            }
            Section("Extras") {
                Toggle("Suggestions", isOn: $config.suggestions)
                Toggle("Scopes", isOn: $config.scopes)
            }
        } code: { config in
            code(for: config)
        } examples: {
            SearchExamples()
        }
    }

    private func code(for config: SearchConfig) -> String {
        var lines = ["@State private var searchText = \"\""]
        if config.scopes {
            lines.append("@State private var scope = \"All\"")
        }
        let names = searchFruits.map { "\"\($0.name)\"" }
        lines += [
            "",
            "let fruits = [\(names.prefix(5).joined(separator: ", ")),",
            "              \(names.dropFirst(5).joined(separator: ", "))]",
        ]
        if config.scopes {
            lines += [
                "let colors = [\"Apple\": \"Red\", \"Banana\": \"Yellow\", \"Cherry\": \"Red\", \"Kiwi\": \"Green\", \"Lemon\": \"Yellow\",",
                "              \"Lime\": \"Green\", \"Mango\": \"Yellow\", \"Pear\": \"Green\", \"Raspberry\": \"Red\", \"Strawberry\": \"Red\"]",
                "",
                "var results: [String] {",
                "    fruits",
                "        .filter { scope == \"All\" || colors[$0] == scope }",
                "        .filter { searchText.isEmpty || $0.localizedStandardContains(searchText) }",
                "}",
                "",
            ]
        } else {
            lines += [
                "",
                "var results: [String] {",
                "    searchText.isEmpty ? fruits : fruits.filter { $0.localizedStandardContains(searchText) }",
                "}",
                "",
            ]
        }
        lines += [
            "NavigationStack {",
            "    List(results, id: \\.self) { Text($0) }",
            "        .navigationTitle(\"Fruit\")",
        ]
        var args = "text: $searchText"
        if config.placement != .automatic {
            args += ", placement: \(config.placement.label)"
        }
        if !config.prompt.isEmpty {
            args += ", prompt: \(swiftString(config.prompt))"
        }
        lines.append("        .searchable(\(args))")
        if config.suggestions {
            lines += [
                "        .searchSuggestions {",
                "            if searchText.isEmpty {",
                "                Label(\"Strawberry\", systemImage: \"clock\")",
                "                    .searchCompletion(\"Strawberry\")",
                "                Label(\"Mango\", systemImage: \"clock\")",
                "                    .searchCompletion(\"Mango\")",
                "            }",
                "        }",
            ]
        }
        if config.scopes {
            lines += [
                "        .searchScopes($scope) {",
                "            ForEach([\"All\", \"Red\", \"Yellow\", \"Green\"], id: \\.self) { Text($0) }",
                "        }",
            ]
        }
        lines += [
            "        .overlay {",
            "            if results.isEmpty {",
            "                ContentUnavailableView.search(text: searchText)",
            "            }",
            "        }",
            "}",
        ]
        return lines.joined(separator: "\n")
    }
}

private struct SearchScreen: View {
    @Binding var config: SearchConfig

    private var results: [String] {
        searchFruits
            .filter { config.scopes == false || config.scope == .all || $0.color == config.scope }
            .map(\.name)
            .filter { config.text.isEmpty || $0.localizedStandardContains(config.text) }
    }

    var body: some View {
        List(results, id: \.self) { Text($0) }
            .navigationTitle("Fruit")
            .searchablePlaced(text: $config.text, placement: config.placement, prompt: config.prompt)
            .searchSuggestions {
                if config.suggestions && config.text.isEmpty {
                    Label("Strawberry", systemImage: "clock")
                        .searchCompletion("Strawberry")
                    Label("Mango", systemImage: "clock")
                        .searchCompletion("Mango")
                }
            }
            .modifier(SearchScopesModifier(isOn: config.scopes, scope: $config.scope))
            .overlay {
                if results.isEmpty {
                    ContentUnavailableView.search(text: config.text)
                }
            }
    }
}

private struct SearchScopesModifier: ViewModifier {
    let isOn: Bool
    @Binding var scope: SearchScope

    func body(content: Content) -> some View {
        if isOn {
            content.searchScopes($scope) {
                ForEach(SearchScope.allCases, id: \.self) { Text($0.rawValue) }
            }
        } else {
            content
        }
    }
}

private struct SearchThumbnail: View {
    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: "magnifyingglass")
                Text("Search fruit")
                Spacer()
                Image(systemName: "mic.fill")
            }
            .foregroundStyle(.secondary)
            .padding(.horizontal, 14)
            .frame(height: 40)
            .glassEffect(.regular, in: .capsule)
            VStack(alignment: .leading, spacing: 0) {
                ForEach(["Apple", "Apricot"], id: \.self) { name in
                    Label(name, systemImage: "clock")
                        .font(.subheadline)
                        .padding(.vertical, 7)
                    if name == "Apple" { Divider() }
                }
            }
            .padding(.horizontal, 14)
            .background(.background.secondary, in: .rect(cornerRadius: 12))
        }
        .frame(width: 210)
    }
}

// MARK: - Examples

private struct SearchExamples: View {
    var body: some View {
        ExampleCard(
            title: "No results",
            caption: "Show `ContentUnavailableView.search` in an `.overlay` when nothing matches the search text.",
            code: """
            @State private var searchText = ""

            let fruits = ["Apple", "Banana", "Cherry", "Kiwi"]

            NavigationStack {
                let results = fruits.filter { searchText.isEmpty || $0.localizedStandardContains(searchText) }
                List(results, id: \\.self) { Text($0) }
                    .navigationTitle("Fruit")
                    .searchable(text: $searchText)
                    .overlay {
                        if results.isEmpty {
                            ContentUnavailableView.search(text: searchText)
                        }
                    }
            }
            """,
            minHeight: 440
        ) {
            PhoneScreen(height: 420) {
                SearchEmptyExample()
            }
        }

        ExampleCard(
            title: "Search when people tap Search",
            caption: "Use `.onSubmit(of: .search)` when a search is slow, like a network request.",
            code: """
            @State private var searchText = ""
            @State private var lastSearch = ""

            NavigationStack {
                Text(lastSearch.isEmpty ? "Type, then tap Search" : "Results for “\\(lastSearch)”")
                    .navigationTitle("Store")
                    .searchable(text: $searchText)
                    .onSubmit(of: .search) {
                        lastSearch = searchText
                    }
            }
            """,
            minHeight: 340,
            aside: Aside(.note, "Without it, `searchText` still changes on every keystroke, so you can also debounce in a `.task(id: searchText)`.")
        ) {
            PhoneScreen(height: 320) {
                SearchSubmitExample()
            }
        }

        ExampleCard(
            title: "Search tokens",
            caption: "Use `.searchable(text:tokens:)` for filter capsules in the field, like Mail's “From: Maya”.",
            code: """
            struct Tag: Identifiable, Hashable {
                let id: String
            }

            @State private var text = ""
            @State private var tokens: [Tag] = []

            NavigationStack {
                List {
                    Text(tokens.isEmpty ? "All photos" : "Photos tagged \\(tokens.map(\\.id).formatted())")
                }
                .navigationTitle("Photos")
                .searchable(text: $text, tokens: $tokens) { tag in
                    Label(tag.id, systemImage: "tag")
                }
                .searchSuggestions {
                    ForEach([Tag(id: "Beach"), Tag(id: "Dogs")]) { tag in
                        Label(tag.id, systemImage: "tag")
                            .searchCompletion(tag)
                    }
                }
            }
            """,
            minHeight: 440,
            aside: Aside(.note, "People don't know which tokens exist. Offer them as suggestions with `.searchCompletion(tag)`, as here.")
        ) {
            PhoneScreen(height: 420) {
                SearchTokensExample()
            }
        }
    }
}

private struct SearchTag: Identifiable, Hashable {
    let id: String
}

private struct SearchTokensExample: View {
    @State private var text = ""
    @State private var tokens: [SearchTag] = []

    var body: some View {
        List { Text(tokens.isEmpty ? "All photos" : "Photos tagged \(tokens.map(\.id).formatted())") }
            .navigationTitle("Photos")
            .searchable(text: $text, tokens: $tokens) { tag in
                Label(tag.id, systemImage: "tag")
            }
            .searchSuggestions {
                ForEach([SearchTag(id: "Beach"), SearchTag(id: "Dogs")]) { tag in
                    Label(tag.id, systemImage: "tag")
                        .searchCompletion(tag)
                }
            }
    }
}

private struct SearchEmptyExample: View {
    @State private var searchText = "Durian"
    private let fruits = ["Apple", "Banana", "Cherry", "Kiwi"]

    var body: some View {
        let results = fruits.filter { searchText.isEmpty || $0.localizedStandardContains(searchText) }
        List(results, id: \.self) { Text($0) }
            .navigationTitle("Fruit")
            .searchable(text: $searchText)
            .overlay {
                if results.isEmpty {
                    ContentUnavailableView.search(text: searchText)
                }
            }
    }
}

private struct SearchSubmitExample: View {
    @State private var searchText = ""
    @State private var lastSearch = ""

    var body: some View {
        Text(lastSearch.isEmpty ? "Type, then tap Search" : "Results for “\(lastSearch)”")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle("Store")
            .searchable(text: $searchText)
            .onSubmit(of: .search) {
                lastSearch = searchText
            }
    }
}

/// A small screen with an always-visible search field, for the prompt guideline.
private struct SearchPromptSample: View {
    let prompt: String
    @State private var text = ""

    var body: some View {
        PhoneScreen(width: 270, height: 210) {
            List {
                Text("Pasta al limone")
                Text("Green curry")
            }
            .navigationTitle("Recipes")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $text, placement: .navigationBarDrawer(displayMode: .always), prompt: prompt)
        }
    }
}

// MARK: - Options

private enum SearchPlacement: DemoOption {
    case automatic, navigationBarDrawer, toolbar

    var label: String {
        switch self {
        case .automatic: ".automatic"
        case .navigationBarDrawer: ".navigationBarDrawer(displayMode: .always)"
        case .toolbar: ".toolbar"
        }
    }

    var value: SearchFieldPlacement {
        switch self {
        case .automatic: .automatic
        case .navigationBarDrawer: .navigationBarDrawer(displayMode: .always)
        case .toolbar: .toolbar
        }
    }
}

private extension View {
    func searchablePlaced(text: Binding<String>, placement: SearchPlacement, prompt: String) -> some View {
        searchable(text: text, placement: placement.value, prompt: prompt.isEmpty ? nil : Text(prompt))
    }
}