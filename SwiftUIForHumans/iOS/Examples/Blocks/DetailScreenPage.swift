import SwiftUI

extension ComponentPage {
    static let detailScreen = ComponentPage(
        id: "detail-screen",
        title: "Detail Screen",
        summary: "A listing page with a full-bleed hero, a glass toolbar, and a floating Reserve bar.",
        category: .blocks,
        kind: .block,
        symbol: "photo.on.rectangle.angled",
        availability: ["iOS 26.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/view/glasseffect(_:in:)",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/toolbars",
        aliases: ["product page", "detail view", "item page", "listing", "hero image", "sticky footer", "position: sticky", "call to action", "airbnb"],
        related: ["liquid-glass", "toolbar", "sheet", "async-image"],
        notes: [
            "**`.safeAreaInset(edge: .bottom)` pins a bar and makes room for it.** The scroll content ends above the bar instead of hiding behind it, like a fixed footer plus matching padding on the web.",
            "**Use `.glassEffect()` only on floating controls.** Keep it off the content itself; glass layered on glass looks muddy.",
        ],
        guidelines: [
            Guideline(
                "Keep the toolbar to a few actions.",
                "Each extra button makes the others harder to find and tap. Move rarely used actions into a More menu.",
                good: "Two clear actions.",
                bad: "Five icons push out the title and spill into an overflow menu."
            ) {
                ToolbarSample(isCrowded: false)
            } bad: {
                ToolbarSample(isCrowded: true)
            },
            Guideline(
                "Use plain system symbols for toolbar buttons.",
                "Familiar symbols like `heart` and `square.and.arrow.up` read at a glance, and the glass already gives each one a container, so skip the outlined `.circle` versions."
            ),
            Guideline(
                "Use the standard Back button.",
                "People know what the system chevron does. A custom back button or a text label that says Back makes them stop and check."
            ),
        ]
    ) {
        BlockThumbnail {
            DetailScreen()
        }
    } content: { page in
        BlockShowcase(
            page: page,
            tryIt: "Try it: scroll the screen to see the hero slide under the glass toolbar, tap the heart to save, then tap **Reserve** to open the booking sheet.",
            code: detailScreenSource,
            components: ["liquid-glass", "toolbar", "async-image", "sheet", "safe-area", "date-picker", "stepper"]
        ) {
            DetailScreen()
        } notes: {
            Aside(.note, "The hero is an [AsyncImage](catalog://async-image) that runs under the navigation bar thanks to `.ignoresSafeArea(edges: .top)` (see [safe area](catalog://safe-area)). In iOS 26 the bar is transparent and its buttons float on [Liquid Glass](catalog://liquid-glass).")
            Aside(.note, "The heart and share buttons sit in the [toolbar](catalog://toolbar), and `ToolbarSpacer(.fixed)` splits them into separate glass groups.")
            Aside(.note, "The price bar is a `.safeAreaInset` with `.glassEffect`. **Reserve** presents a [sheet](catalog://sheet) with a [DatePicker](catalog://date-picker) and a [Stepper](catalog://stepper) at a medium detent.")
        }
    }
}

/// Guideline preview: a short screen whose toolbar holds two or five buttons.
private struct ToolbarSample: View {
    let isCrowded: Bool

    var body: some View {
        PhoneScreen(width: 270, height: 120) {
            Color.clear
                .navigationTitle("Cabin")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    if isCrowded {
                        ToolbarItemGroup(placement: .topBarTrailing) {
                            Button("Map", systemImage: "map") {}
                            Button("Notes", systemImage: "note.text") {}
                            Button("Message", systemImage: "message") {}
                            Button("Share", systemImage: "square.and.arrow.up") {}
                            Button("Save", systemImage: "heart") {}
                        }
                    } else {
                        ToolbarItemGroup(placement: .topBarTrailing) {
                            Button("Share", systemImage: "square.and.arrow.up") {}
                            Button("Save", systemImage: "heart") {}
                        }
                    }
                }
        }
    }
}

// <block-source>
private struct DetailScreen: View {
    @State private var isSaved = false
    @State private var showsBooking = false
    @State private var checkIn = Date.now
    @State private var guests = 2

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // A fixed-size frame with the image in an overlay, so the
                // filled image can't make the whole screen wider.
                Color.clear
                    .frame(height: 260)
                    .overlay {
                        AsyncImage(url: URL(string: "https://picsum.photos/seed/cabin/800/600")) { image in
                            image.resizable().scaledToFill()
                        } placeholder: {
                            Rectangle()
                                .fill(.fill.tertiary)
                                .overlay { ProgressView() }
                        }
                    }
                    .clipped()

                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Lakeside Cabin")
                            .font(.title.bold())
                        Label("Lake Tahoe, California", systemImage: "mappin.and.ellipse")
                            .foregroundStyle(.secondary)
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .foregroundStyle(.yellow)
                            Text("4.92")
                                .fontWeight(.semibold)
                            Text("· 318 reviews")
                                .foregroundStyle(.secondary)
                        }
                        .font(.subheadline)
                    }

                    HStack {
                        stat("6", "Guests", symbol: "person.2")
                        Divider()
                        stat("3", "Bedrooms", symbol: "bed.double")
                        Divider()
                        stat("2", "Baths", symbol: "shower")
                    }
                    .padding(.vertical, 12)
                    .background(.fill.quaternary, in: .rect(cornerRadius: 16))

                    VStack(alignment: .leading, spacing: 8) {
                        Text("About")
                            .font(.headline)
                        Text("A quiet timber cabin a short walk from the shore. Wake up to lake views, spend the afternoon on the kayaks, and finish the day by the fireplace.")
                            .foregroundStyle(.secondary)
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Amenities")
                            .font(.headline)
                        Label("Fast Wi-Fi", systemImage: "wifi")
                        Label("Wood fireplace", systemImage: "fireplace")
                        Label("Two kayaks", systemImage: "figure.water.fitness")
                        Label("Free parking", systemImage: "car")
                    }
                }
                .padding(.horizontal, 20)
            }
            .padding(.bottom, 20)
        }
        .ignoresSafeArea(edges: .top)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                ShareLink(item: URL(string: "https://example.com/stays/lakeside-cabin")!)
            }
            ToolbarSpacer(.fixed, placement: .topBarTrailing)
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isSaved.toggle()
                } label: {
                    Label("Save", systemImage: isSaved ? "heart.fill" : "heart")
                }
                .tint(isSaved ? .pink : nil)
                .symbolEffect(.bounce, value: isSaved)
            }
        }
        .safeAreaInset(edge: .bottom) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(Text("$289").font(.title3.bold())) night")
                    Text("Oct 24 – 27")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Button("Reserve") {
                    showsBooking = true
                }
                .buttonStyle(.glassProminent)
                .controlSize(.large)
                .fontWeight(.semibold)
            }
            .padding(.leading, 20)
            .padding(.trailing, 8)
            .padding(.vertical, 8)
            .glassEffect(.regular, in: .capsule)
            .padding(.horizontal, 12)
            .padding(.bottom, 8)
        }
        .sheet(isPresented: $showsBooking) {
            NavigationStack {
                Form {
                    DatePicker("Check-in", selection: $checkIn, displayedComponents: .date)
                    Stepper("Guests: \(guests)", value: $guests, in: 1...6)
                    LabeledContent("Total", value: "$867")
                }
                .navigationTitle("Reserve")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel", systemImage: "xmark") { showsBooking = false }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Confirm", systemImage: "checkmark") { showsBooking = false }
                    }
                }
            }
            .presentationDetents([.medium])
        }
    }

    private func stat(_ value: String, _ title: String, symbol: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: symbol)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.headline)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}
// </block-source>

// <block-code>
private let detailScreenSource = #"""
import SwiftUI

struct DetailScreen: View {
    @State private var isSaved = false
    @State private var showsBooking = false
    @State private var checkIn = Date.now
    @State private var guests = 2

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // A fixed-size frame with the image in an overlay, so the
                // filled image can't make the whole screen wider.
                Color.clear
                    .frame(height: 260)
                    .overlay {
                        AsyncImage(url: URL(string: "https://picsum.photos/seed/cabin/800/600")) { image in
                            image.resizable().scaledToFill()
                        } placeholder: {
                            Rectangle()
                                .fill(.fill.tertiary)
                                .overlay { ProgressView() }
                        }
                    }
                    .clipped()

                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Lakeside Cabin")
                            .font(.title.bold())
                        Label("Lake Tahoe, California", systemImage: "mappin.and.ellipse")
                            .foregroundStyle(.secondary)
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .foregroundStyle(.yellow)
                            Text("4.92")
                                .fontWeight(.semibold)
                            Text("· 318 reviews")
                                .foregroundStyle(.secondary)
                        }
                        .font(.subheadline)
                    }

                    HStack {
                        stat("6", "Guests", symbol: "person.2")
                        Divider()
                        stat("3", "Bedrooms", symbol: "bed.double")
                        Divider()
                        stat("2", "Baths", symbol: "shower")
                    }
                    .padding(.vertical, 12)
                    .background(.fill.quaternary, in: .rect(cornerRadius: 16))

                    VStack(alignment: .leading, spacing: 8) {
                        Text("About")
                            .font(.headline)
                        Text("A quiet timber cabin a short walk from the shore. Wake up to lake views, spend the afternoon on the kayaks, and finish the day by the fireplace.")
                            .foregroundStyle(.secondary)
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Amenities")
                            .font(.headline)
                        Label("Fast Wi-Fi", systemImage: "wifi")
                        Label("Wood fireplace", systemImage: "fireplace")
                        Label("Two kayaks", systemImage: "figure.water.fitness")
                        Label("Free parking", systemImage: "car")
                    }
                }
                .padding(.horizontal, 20)
            }
            .padding(.bottom, 20)
        }
        .ignoresSafeArea(edges: .top)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                ShareLink(item: URL(string: "https://example.com/stays/lakeside-cabin")!)
            }
            ToolbarSpacer(.fixed, placement: .topBarTrailing)
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isSaved.toggle()
                } label: {
                    Label("Save", systemImage: isSaved ? "heart.fill" : "heart")
                }
                .tint(isSaved ? .pink : nil)
                .symbolEffect(.bounce, value: isSaved)
            }
        }
        .safeAreaInset(edge: .bottom) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(Text("$289").font(.title3.bold())) night")
                    Text("Oct 24 – 27")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Button("Reserve") {
                    showsBooking = true
                }
                .buttonStyle(.glassProminent)
                .controlSize(.large)
                .fontWeight(.semibold)
            }
            .padding(.leading, 20)
            .padding(.trailing, 8)
            .padding(.vertical, 8)
            .glassEffect(.regular, in: .capsule)
            .padding(.horizontal, 12)
            .padding(.bottom, 8)
        }
        .sheet(isPresented: $showsBooking) {
            NavigationStack {
                Form {
                    DatePicker("Check-in", selection: $checkIn, displayedComponents: .date)
                    Stepper("Guests: \(guests)", value: $guests, in: 1...6)
                    LabeledContent("Total", value: "$867")
                }
                .navigationTitle("Reserve")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel", systemImage: "xmark") { showsBooking = false }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Confirm", systemImage: "checkmark") { showsBooking = false }
                    }
                }
            }
            .presentationDetents([.medium])
        }
    }

    private func stat(_ value: String, _ title: String, symbol: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: symbol)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.headline)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    NavigationStack {
        DetailScreen()
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
