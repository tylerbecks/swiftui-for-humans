import SwiftUI

extension ComponentPage {
    static let profile = ComponentPage(
        id: "profile",
        title: "Profile Screen",
        summary: "A social profile with an avatar, stats, Follow and Message buttons, and a photo grid.",
        category: .blocks,
        kind: .block,
        symbol: "person.crop.circle",
        availability: ["iOS 26.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/lazyvgrid",
        aliases: ["user profile", "account page", "avatar", "bio", "followers", "photo grid", "instagram profile", "about me", "css grid"],
        related: ["lazy-grids", "async-image", "picker", "content-transition"],
        notes: [
            "**`AsyncImage` doesn't cache.** Photos can download again when they scroll back into view. That's fine for a demo; real apps usually add a caching image loader.",
            "**Roll numbers with `.contentTransition(.numericText(value:))`.** Change the count inside `withAnimation` and the digits roll like an odometer.",
        ]
    ) {
        BlockThumbnail {
            ProfileScreen()
        }
    } content: { page in
        BlockShowcase(
            page: page,
            tryIt: "Try it: tap **Follow** and watch the follower count roll, switch between **Posts** and **Saved**, or open the **⋯** menu.",
            code: profileSource,
            components: ["async-image", "lazy-grids", "picker", "content-transition", "menu", "share-link"]
        ) {
            ProfileScreen()
        } notes: {
            Aside(.note, "The photos are [AsyncImage](catalog://async-image) views with placeholders, laid out in a three-column [LazyVGrid](catalog://lazy-grids) under a segmented [Picker](catalog://picker).")
            Aside(.important, "Square tiles need a trick. Put `Color.clear.aspectRatio(1, contentMode: .fit)` in each cell, draw the image in an `.overlay`, then `.clipped()`, or wide photos stretch the grid.")
            Aside(.note, "The follower count uses a numeric [content transition](catalog://content-transition). The toolbar [Menu](catalog://menu) holds a [ShareLink](catalog://share-link) and a destructive Block action.")
            Aside(.note, "**Why iOS 26?** Only the Liquid Glass button styles need it. Change `.glassProminent` to `.borderedProminent` and `.glass` to `.bordered`, and the screen runs on iOS 17.")
        }
    }
}

// <block-source>
private struct ProfileScreen: View {
    @State private var isFollowing = false
    @State private var followers = 1_284
    @State private var tab = "Posts"

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 2), count: 3)

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                header
                stats
                actions
                Picker("Content", selection: $tab) {
                    Text("Posts").tag("Posts")
                    Text("Saved").tag("Saved")
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                LazyVGrid(columns: columns, spacing: 2) {
                    ForEach(0..<12, id: \.self) { index in
                        Color.clear
                            .aspectRatio(1, contentMode: .fit)
                            .overlay {
                                AsyncImage(url: URL(string: "https://picsum.photos/seed/\(tab)\(index)/300")) { image in
                                    image.resizable().scaledToFill()
                                } placeholder: {
                                    Rectangle().fill(.fill.tertiary)
                                }
                            }
                            .clipped()
                    }
                }
            }
            .padding(.top, 8)
        }
        .navigationTitle("mayachen")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    ShareLink(item: URL(string: "https://example.com/@mayachen")!)
                    Button("Copy Profile Link", systemImage: "link") {}
                    Button("Block", systemImage: "hand.raised", role: .destructive) {}
                } label: {
                    Label("More", systemImage: "ellipsis")
                }
            }
        }
    }

    private var header: some View {
        VStack(spacing: 12) {
            Text("MC")
                .font(.system(size: 34, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
                .frame(width: 88, height: 88)
                .background(
                    LinearGradient(colors: [.orange, .pink], startPoint: .topLeading, endPoint: .bottomTrailing),
                    in: .circle
                )

            VStack(spacing: 4) {
                Text("Maya Chen")
                    .font(.title2.bold())
                Text("Landscape photographer. Chasing light across the Pacific Northwest.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 24)
        }
    }

    private var stats: some View {
        HStack {
            stat("Posts", value: 248)
            Divider()
            stat("Followers", value: followers)
            Divider()
            stat("Following", value: 312)
        }
        .frame(height: 40)
        .padding(.horizontal)
    }

    private func stat(_ title: String, value: Int) -> some View {
        VStack(spacing: 2) {
            Text(value, format: .number)
                .font(.headline)
                .contentTransition(.numericText(value: Double(value)))
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    private var actions: some View {
        HStack(spacing: 10) {
            Group {
                if isFollowing {
                    Button(action: toggleFollow) {
                        Text("Following")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.glass)
                } else {
                    Button(action: toggleFollow) {
                        Text("Follow")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.glassProminent)
                }
            }
            Button {} label: {
                Text("Message")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.glass)
        }
        .fontWeight(.semibold)
        .lineLimit(1)
        .controlSize(.large)
        .padding(.horizontal)
    }

    private func toggleFollow() {
        withAnimation(.snappy) {
            isFollowing.toggle()
            followers += isFollowing ? 1 : -1
        }
    }
}
// </block-source>

// <block-code>
private let profileSource = #"""
import SwiftUI

struct ProfileScreen: View {
    @State private var isFollowing = false
    @State private var followers = 1_284
    @State private var tab = "Posts"

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 2), count: 3)

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                header
                stats
                actions
                Picker("Content", selection: $tab) {
                    Text("Posts").tag("Posts")
                    Text("Saved").tag("Saved")
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                LazyVGrid(columns: columns, spacing: 2) {
                    ForEach(0..<12, id: \.self) { index in
                        Color.clear
                            .aspectRatio(1, contentMode: .fit)
                            .overlay {
                                AsyncImage(url: URL(string: "https://picsum.photos/seed/\(tab)\(index)/300")) { image in
                                    image.resizable().scaledToFill()
                                } placeholder: {
                                    Rectangle().fill(.fill.tertiary)
                                }
                            }
                            .clipped()
                    }
                }
            }
            .padding(.top, 8)
        }
        .navigationTitle("mayachen")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    ShareLink(item: URL(string: "https://example.com/@mayachen")!)
                    Button("Copy Profile Link", systemImage: "link") {}
                    Button("Block", systemImage: "hand.raised", role: .destructive) {}
                } label: {
                    Label("More", systemImage: "ellipsis")
                }
            }
        }
    }

    private var header: some View {
        VStack(spacing: 12) {
            Text("MC")
                .font(.system(size: 34, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
                .frame(width: 88, height: 88)
                .background(
                    LinearGradient(colors: [.orange, .pink], startPoint: .topLeading, endPoint: .bottomTrailing),
                    in: .circle
                )

            VStack(spacing: 4) {
                Text("Maya Chen")
                    .font(.title2.bold())
                Text("Landscape photographer. Chasing light across the Pacific Northwest.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 24)
        }
    }

    private var stats: some View {
        HStack {
            stat("Posts", value: 248)
            Divider()
            stat("Followers", value: followers)
            Divider()
            stat("Following", value: 312)
        }
        .frame(height: 40)
        .padding(.horizontal)
    }

    private func stat(_ title: String, value: Int) -> some View {
        VStack(spacing: 2) {
            Text(value, format: .number)
                .font(.headline)
                .contentTransition(.numericText(value: Double(value)))
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    private var actions: some View {
        HStack(spacing: 10) {
            Group {
                if isFollowing {
                    Button(action: toggleFollow) {
                        Text("Following")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.glass)
                } else {
                    Button(action: toggleFollow) {
                        Text("Follow")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.glassProminent)
                }
            }
            Button {} label: {
                Text("Message")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.glass)
        }
        .fontWeight(.semibold)
        .lineLimit(1)
        .controlSize(.large)
        .padding(.horizontal)
    }

    private func toggleFollow() {
        withAnimation(.snappy) {
            isFollowing.toggle()
            followers += isFollowing ? 1 : -1
        }
    }
}

#Preview {
    NavigationStack {
        ProfileScreen()
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
