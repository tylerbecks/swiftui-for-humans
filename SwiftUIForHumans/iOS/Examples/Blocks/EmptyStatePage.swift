import SwiftUI

extension ComponentPage {
    static let emptyState = ComponentPage(
        id: "empty-state",
        title: "Empty States",
        summary: "What to show when a screen has no content, no search results, or an error.",
        category: .blocks,
        kind: .block,
        symbol: "tray",
        availability: ["iOS 17.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/contentunavailableview",
        aliases: ["empty view", "no results", "zero state", "placeholder", "blank slate", "no data", "error screen", "404", "ContentUnavailableView"],
        related: ["list", "searchable", "sf-symbols", "button"],
        notes: [
            "**Use `ContentUnavailableView` instead of building your own.** It replaces the hand-made icon, title, and subtitle stack, with the right fonts, colors, spacing, and Dynamic Type.",
            "**Say why it's empty and offer one next step.** A short reason plus one action, like Browse or Try Again, beats a blank screen. Don't put anything there people need later, since it disappears once content arrives.",
        ]
    ) {
        BlockThumbnail {
            FavoritesScreen()
        }
    } content: { page in
        BlockShowcase(
            page: page,
            tryIt: "Try it: tap **Browse Recipes** to fill the list, search for something that is not there, then tap **Clear** to get back to the empty state.",
            code: emptyStateSource,
            components: ["list", "searchable", "button", "sf-symbols"]
        ) {
            FavoritesScreen()
        } notes: {
            Aside(.note, "One `ContentUnavailableView` sits in an `.overlay` on a [List](catalog://list). When the list is empty it shows the first-run message with a [Button](catalog://button); when [search](catalog://searchable) finds nothing it switches to `ContentUnavailableView.search`.")
            Aside(.important, "Overlay the empty state on the `List` instead of swapping the list out. Otherwise the search field and toolbar disappear along with it.")
        } more: {
            VStack(alignment: .leading, spacing: 24) {
                SectionTitle("Variations")
                ExampleCard(
                    title: "Simple",
                    caption: "Give `ContentUnavailableView` a title, a `systemImage`, and a one-line `description` of what goes here.",
                    code: """
                    ContentUnavailableView(
                        "No Photos",
                        systemImage: "photo.on.rectangle",
                        description: Text("Photos you take will appear here.")
                    )
                    """
                ) {
                    ContentUnavailableView(
                        "No Photos",
                        systemImage: "photo.on.rectangle",
                        description: Text("Photos you take will appear here.")
                    )
                }
                ExampleCard(
                    title: "No search results",
                    caption: "Pass the search text to `.search(text:)` and it writes the “No Results for …” message for you.",
                    code: """
                    @State private var searchText = "zebra"

                    ContentUnavailableView.search(text: searchText)
                    """
                ) {
                    ContentUnavailableView.search(text: "zebra")
                }
                ExampleCard(
                    title: "Error with a retry",
                    caption: "Use the closure form with `actions:` to add a button, such as Try Again after an error.",
                    code: """
                    ContentUnavailableView {
                        Label("You're Offline", systemImage: "wifi.slash")
                    } description: {
                        Text("Check your connection and try again.")
                    } actions: {
                        Button("Try Again") {
                            // reload
                        }
                        .buttonStyle(.bordered)
                    }
                    """
                ) {
                    ContentUnavailableView {
                        Label("You're Offline", systemImage: "wifi.slash")
                    } description: {
                        Text("Check your connection and try again.")
                    } actions: {
                        Button("Try Again") {}
                            .buttonStyle(.bordered)
                    }
                }
            }
        }
    }
}

// <block-source>
private struct FavoritesScreen: View {
    @State private var favorites: [String] = []
    @State private var searchText = ""

    private let recipes = [
        "Lemon Herb Chicken", "Miso Ramen", "Shakshuka",
        "Margherita Pizza", "Thai Green Curry", "Banana Bread",
    ]

    private var results: [String] {
        searchText.isEmpty ? favorites : favorites.filter { $0.localizedStandardContains(searchText) }
    }

    var body: some View {
        List {
            ForEach(results, id: \.self) { recipe in
                Label(recipe, systemImage: "heart.fill")
                    .symbolRenderingMode(.multicolor)
            }
            .onDelete { offsets in
                let removed = offsets.map { results[$0] }
                favorites.removeAll { removed.contains($0) }
            }
        }
        .navigationTitle("Favorites")
        .searchable(text: $searchText, prompt: "Search favorites")
        .overlay {
            if favorites.isEmpty {
                ContentUnavailableView {
                    Label("No Favorites Yet", systemImage: "heart")
                } description: {
                    Text("Tap the heart on any recipe to save it here for later.")
                } actions: {
                    Button("Browse Recipes") {
                        withAnimation { favorites = recipes }
                    }
                    .buttonStyle(.borderedProminent)
                }
            } else if results.isEmpty {
                ContentUnavailableView.search(text: searchText)
            }
        }
        .toolbar {
            if !favorites.isEmpty {
                Button("Clear") {
                    withAnimation { favorites = [] }
                }
            }
        }
    }
}
// </block-source>

// <block-code>
private let emptyStateSource = #"""
import SwiftUI

struct FavoritesScreen: View {
    @State private var favorites: [String] = []
    @State private var searchText = ""

    private let recipes = [
        "Lemon Herb Chicken", "Miso Ramen", "Shakshuka",
        "Margherita Pizza", "Thai Green Curry", "Banana Bread",
    ]

    private var results: [String] {
        searchText.isEmpty ? favorites : favorites.filter { $0.localizedStandardContains(searchText) }
    }

    var body: some View {
        List {
            ForEach(results, id: \.self) { recipe in
                Label(recipe, systemImage: "heart.fill")
                    .symbolRenderingMode(.multicolor)
            }
            .onDelete { offsets in
                let removed = offsets.map { results[$0] }
                favorites.removeAll { removed.contains($0) }
            }
        }
        .navigationTitle("Favorites")
        .searchable(text: $searchText, prompt: "Search favorites")
        .overlay {
            if favorites.isEmpty {
                ContentUnavailableView {
                    Label("No Favorites Yet", systemImage: "heart")
                } description: {
                    Text("Tap the heart on any recipe to save it here for later.")
                } actions: {
                    Button("Browse Recipes") {
                        withAnimation { favorites = recipes }
                    }
                    .buttonStyle(.borderedProminent)
                }
            } else if results.isEmpty {
                ContentUnavailableView.search(text: searchText)
            }
        }
        .toolbar {
            if !favorites.isEmpty {
                Button("Clear") {
                    withAnimation { favorites = [] }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        FavoritesScreen()
    }
}
"""#

// MARK: - Block page parts
// Each Blocks file carries its own private copy of these, so files stay
// independent and nothing leaks into the shared module namespace.

/// The standard block page: live screen in a phone frame, what it is built
/// with (tappable links to those catalog pages), then the full source.
private struct BlockShowcase<Screen: View, Notes: View, More: View>: View {
    let page: ComponentPage
    let tryIt: String
    let code: String
    let components: [ComponentPage.ID]
    let hasNavigationBar: Bool
    let screen: Screen
    let notes: Notes
    let more: More

    @Environment(\.openPage) private var openPage
    @State private var showsFullScreen = false

    init(
        page: ComponentPage,
        tryIt: String,
        code: String,
        components: [ComponentPage.ID],
        hasNavigationBar: Bool = true,
        @ViewBuilder screen: () -> Screen,
        @ViewBuilder notes: () -> Notes,
        @ViewBuilder more: () -> More
    ) {
        self.page = page
        self.tryIt = tryIt
        self.code = code
        self.components = components
        self.hasNavigationBar = hasNavigationBar
        self.screen = screen()
        self.notes = notes()
        self.more = more()
    }

    var body: some View {
        ArticlePage(page: page) {
            VStack(alignment: .leading, spacing: 12) {
                PreviewCard(title: "Live screen", minHeight: 600) {
                    PhoneScreen(hasNavigationBar: hasNavigationBar) {
                        screen
                    }
                }
                Button {
                    showsFullScreen = true
                } label: {
                    Label("Open Full Screen", systemImage: "arrow.up.left.and.arrow.down.right")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                .accessibilityIdentifier("open-full-screen")
                Label {
                    RichText(tryIt)
                        .fixedSize(horizontal: false, vertical: true)
                } icon: {
                    Image(systemName: "hand.tap")
                        .foregroundStyle(.tint)
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
            .id("live")

            VStack(alignment: .leading, spacing: 12) {
                SectionTitle("Built with")
                notes
                FlowLayout(spacing: 8) {
                    ForEach(components.compactMap { Catalog.page(id: $0) }) { linked in
                        Button {
                            openPage(linked.id)
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: linked.symbol)
                                Text(linked.title)
                                Image(systemName: "chevron.right")
                                    .font(.caption2.weight(.bold))
                                    .foregroundStyle(.secondary)
                            }
                            .font(.subheadline.weight(.medium))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(.fill.tertiary, in: .capsule)
                            .contentShape(.capsule)
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("uses-\(linked.id)")
                    }
                }
            }
            // Links written as [Form](catalog://form) in callouts open that page.
            .environment(\.openURL, OpenURLAction { url in
                guard url.scheme == "catalog", let id = url.host(), Catalog.page(id: id) != nil else {
                    return .systemAction
                }
                openPage(id)
                return .handled
            })

            VStack(alignment: .leading, spacing: 12) {
                SectionTitle("Code")
                Prose(hasNavigationBar
                      ? "The complete screen, exactly as it runs above. Paste it into a new SwiftUI file and it compiles as is. Show it inside a `NavigationStack`, as the `#Preview` at the bottom does, so its title and toolbar have a bar to live in."
                      : "The complete screen, exactly as it runs above. Paste it into a new SwiftUI file and it compiles as is; then swap the sample data for your own.")
                CodeBlock(code: code)
            }
            .id("code")

            more
        }
        // A sheet starts a fresh navigation context, so pushes, the search
        // field, and the toolbar all behave exactly as in a real app.
        .sheet(isPresented: $showsFullScreen) {
            Group {
                if hasNavigationBar {
                    NavigationStack { screen }
                } else {
                    screen
                }
            }
            .presentationDragIndicator(.visible)
        }
    }
}

private extension BlockShowcase where More == EmptyView {
    init(
        page: ComponentPage,
        tryIt: String,
        code: String,
        components: [ComponentPage.ID],
        hasNavigationBar: Bool = true,
        @ViewBuilder screen: () -> Screen,
        @ViewBuilder notes: () -> Notes
    ) {
        self.init(page: page, tryIt: tryIt, code: code, components: components,
                  hasNavigationBar: hasNavigationBar, screen: screen, notes: notes) {
            EmptyView()
        }
    }
}

/// The block's real screen, scaled down for the overview card.
private struct BlockThumbnail<Screen: View>: View {
    var hasNavigationBar = true
    @ViewBuilder let screen: Screen

    var body: some View {
        PhoneScreen(hasNavigationBar: hasNavigationBar) {
            screen
        }
        .allowsHitTesting(false)
        .scaleEffect(0.44, anchor: .top)
        .frame(width: 314 * 0.44, height: 136, alignment: .top)
        .padding(.top, 14)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}
