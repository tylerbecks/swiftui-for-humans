import SwiftUI

extension ComponentPage {
    static let inboxList = ComponentPage(
        id: "inbox-list",
        title: "Inbox List",
        summary: "A mail-style list with unread dots, swipe actions, a filter menu, and search.",
        category: .blocks,
        kind: .block,
        symbol: "tray.full",
        availability: ["iOS 17.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/view/swipeactions(edge:allowsfullswipe:content:)",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/lists-and-tables",
        aliases: ["email list", "messages", "mail", "notifications list", "swipe to delete", "feed", "table view", "UITableView", "ul li"],
        related: ["list", "swipe-actions", "searchable", "navigation-stack"],
        notes: [
            "**A destructive swipe doesn't delete your data.** `Button(role: .destructive)` turns red and slides the row away on a full swipe, but you still remove the item from your array.",
            "**Make your model `Identifiable`.** With a stable `id`, SwiftUI animates inserts and deletes instead of redrawing the whole list.",
        ],
        guidelines: [
            Guideline(
                "Keep row text short, and let the detail view hold the rest.",
                "Rows of the same height are quick to scan. Cap the preview with `.lineLimit(2)` and show the full message when the row opens.",
                good: "The preview stops after two lines.",
                bad: "The whole message stretches the row."
            ) {
                InboxRowSample(isTrimmed: true)
            } bad: {
                InboxRowSample(isTrimmed: false)
            },
            Guideline(
                "Put gentle swipe actions on the leading edge.",
                "Mark as Read on the left and Archive or Delete on the right is the layout people know from Mail, so destructive actions are never a stray swipe away."
            ),
            Guideline(
                "Use the plain list style for a feed.",
                "Edge-to-edge rows suit a long run of similar items like messages. Save the grouped, inset style for settings-like content."
            ),
        ]
    ) {
        BlockThumbnail {
            InboxScreen()
        }
    } content: { page in
        BlockShowcase(
            page: page,
            tryIt: "Try it: swipe a row right to mark it read or unread, swipe left to archive or delete, filter to **Unread Only**, or search for “invoice”. Opening a message in the small frame covers this page, so use **Open Full Screen** to read one like in a real app.",
            code: inboxListSource,
            components: ["list", "swipe-actions", "searchable", "menu", "navigation-stack", "toolbar"]
        ) {
            InboxScreen()
        } notes: {
            Aside(.note, "A plain [List](catalog://list) of `NavigationLink` rows inside a [NavigationStack](catalog://navigation-stack). Each row has its own [swipe actions](catalog://swipe-actions), one set per edge, not one set on the `List`.")
            Aside(.note, "[.searchable](catalog://searchable) adds the search field, and a [Menu](catalog://menu) in the [toolbar](catalog://toolbar) holds the Unread Only toggle. Both filter the array `ForEach` shows, and `ContentUnavailableView.search` appears when nothing matches.")
        }
    }
}

/// Guideline preview: one inbox row, with its preview text capped or not.
private struct InboxRowSample: View {
    let isTrimmed: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Text("Maya Chen")
                    .font(.headline)
                Spacer()
                Text("9:41 AM")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Text("Trip photos")
                .font(.subheadline)
            Text("I finally sorted the photos from the lake. The sunset ones came out great, and there is a funny one of the kayak. Let me know which you want printed before Friday.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(isTrimmed ? 2 : nil)
        }
        .padding(12)
        .frame(width: 270, alignment: .leading)
        .background(.background, in: .rect(cornerRadius: 12))
    }
}

// <block-source>
private struct InboxScreen: View {
    @State private var messages = InboxMessage.samples
    @State private var searchText = ""
    @State private var showsUnreadOnly = false

    private var visibleMessages: [InboxMessage] {
        messages.filter { message in
            let matchesFilter = !showsUnreadOnly || message.isUnread
            let matchesSearch = searchText.isEmpty
                || message.sender.localizedStandardContains(searchText)
                || message.subject.localizedStandardContains(searchText)
                || message.preview.localizedStandardContains(searchText)
            return matchesFilter && matchesSearch
        }
    }

    var body: some View {
        List {
            ForEach(visibleMessages) { message in
                NavigationLink {
                    MessageView(message: message)
                        .onAppear { setUnread(false, for: message) }
                } label: {
                    InboxRow(message: message)
                }
                .swipeActions(edge: .leading) {
                    Button {
                        setUnread(!message.isUnread, for: message)
                    } label: {
                        Label(message.isUnread ? "Read" : "Unread",
                              systemImage: message.isUnread ? "envelope.open" : "envelope.badge")
                    }
                    .tint(.blue)
                }
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                        remove(message)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                    Button {
                        remove(message)
                    } label: {
                        Label("Archive", systemImage: "archivebox")
                    }
                    .tint(.indigo)
                }
            }
        }
        .listStyle(.plain)
        .animation(.default, value: visibleMessages)
        .navigationTitle("Inbox")
        .searchable(text: $searchText, prompt: "Search")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Toggle("Unread Only", systemImage: "envelope.badge", isOn: $showsUnreadOnly)
                } label: {
                    Label("Filter", systemImage: showsUnreadOnly
                          ? "line.3.horizontal.decrease.circle.fill"
                          : "line.3.horizontal.decrease.circle")
                }
            }
        }
        .overlay {
            if visibleMessages.isEmpty {
                if searchText.isEmpty {
                    ContentUnavailableView("No Mail", systemImage: "tray",
                                           description: Text("New messages will show up here."))
                } else {
                    ContentUnavailableView.search(text: searchText)
                }
            }
        }
    }

    private func setUnread(_ isUnread: Bool, for message: InboxMessage) {
        if let index = messages.firstIndex(where: { $0.id == message.id }) {
            messages[index].isUnread = isUnread
        }
    }

    private func remove(_ message: InboxMessage) {
        messages.removeAll { $0.id == message.id }
    }
}

private struct InboxRow: View {
    let message: InboxMessage

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Circle()
                .fill(message.isUnread ? Color.blue : .clear)
                .frame(width: 9, height: 9)
                .padding(.top, 6)
            VStack(alignment: .leading, spacing: 3) {
                HStack(alignment: .firstTextBaseline) {
                    Text(message.sender)
                        .font(.headline)
                        .lineLimit(1)
                    Spacer()
                    Text(message.time)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Text(message.subject)
                    .font(.subheadline)
                    .fontWeight(message.isUnread ? .semibold : .regular)
                    .lineLimit(1)
                Text(message.preview)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(message.isUnread ? "Unread, \(message.sender), \(message.subject)" : "\(message.sender), \(message.subject)")
    }
}

private struct MessageView: View {
    let message: InboxMessage

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(message.subject)
                    .font(.title2.bold())
                HStack {
                    Text(message.sender)
                        .fontWeight(.semibold)
                    Spacer()
                    Text(message.time)
                        .foregroundStyle(.secondary)
                }
                .font(.subheadline)
                Divider()
                Text(message.preview)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct InboxMessage: Identifiable, Equatable {
    let id = UUID()
    let sender: String
    let subject: String
    let preview: String
    let time: String
    var isUnread: Bool

    static let samples = [
        InboxMessage(sender: "Priya Raman", subject: "Design review moved to Thursday",
                     preview: "Hey team, the room was double booked so I moved us to Thursday at 2pm. Same agenda, bring the latest mockups.",
                     time: "9:41 AM", isUnread: true),
        InboxMessage(sender: "Northwind Bank", subject: "Your October statement is ready",
                     preview: "Your statement for the account ending in 4821 is now available to view and download.",
                     time: "8:15 AM", isUnread: true),
        InboxMessage(sender: "Marcus Lee", subject: "Invoice #1042 for September",
                     preview: "Attached is the invoice for September's work. Payment terms are net 30 as usual. Thanks again!",
                     time: "Yesterday", isUnread: false),
        InboxMessage(sender: "Trailhead Outfitters", subject: "Your order has shipped",
                     preview: "Good news! Your trail runners are on the way and should arrive by Friday.",
                     time: "Yesterday", isUnread: true),
        InboxMessage(sender: "Sofia García", subject: "Photos from the weekend",
                     preview: "Finally got around to editing these. The sunset ones came out great, let me know which you want printed.",
                     time: "Mon", isUnread: false),
        InboxMessage(sender: "City Library", subject: "Reminder: 2 books due soon",
                     preview: "The Overstory and Project Hail Mary are due on October 18. Renew online to keep them longer.",
                     time: "Sun", isUnread: false),
    ]
}
// </block-source>

// <block-code>
private let inboxListSource = #"""
import SwiftUI

struct InboxScreen: View {
    @State private var messages = InboxMessage.samples
    @State private var searchText = ""
    @State private var showsUnreadOnly = false

    private var visibleMessages: [InboxMessage] {
        messages.filter { message in
            let matchesFilter = !showsUnreadOnly || message.isUnread
            let matchesSearch = searchText.isEmpty
                || message.sender.localizedStandardContains(searchText)
                || message.subject.localizedStandardContains(searchText)
                || message.preview.localizedStandardContains(searchText)
            return matchesFilter && matchesSearch
        }
    }

    var body: some View {
        List {
            ForEach(visibleMessages) { message in
                NavigationLink {
                    MessageView(message: message)
                        .onAppear { setUnread(false, for: message) }
                } label: {
                    InboxRow(message: message)
                }
                .swipeActions(edge: .leading) {
                    Button {
                        setUnread(!message.isUnread, for: message)
                    } label: {
                        Label(message.isUnread ? "Read" : "Unread",
                              systemImage: message.isUnread ? "envelope.open" : "envelope.badge")
                    }
                    .tint(.blue)
                }
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                        remove(message)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                    Button {
                        remove(message)
                    } label: {
                        Label("Archive", systemImage: "archivebox")
                    }
                    .tint(.indigo)
                }
            }
        }
        .listStyle(.plain)
        .animation(.default, value: visibleMessages)
        .navigationTitle("Inbox")
        .searchable(text: $searchText, prompt: "Search")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Toggle("Unread Only", systemImage: "envelope.badge", isOn: $showsUnreadOnly)
                } label: {
                    Label("Filter", systemImage: showsUnreadOnly
                          ? "line.3.horizontal.decrease.circle.fill"
                          : "line.3.horizontal.decrease.circle")
                }
            }
        }
        .overlay {
            if visibleMessages.isEmpty {
                if searchText.isEmpty {
                    ContentUnavailableView("No Mail", systemImage: "tray",
                                           description: Text("New messages will show up here."))
                } else {
                    ContentUnavailableView.search(text: searchText)
                }
            }
        }
    }

    private func setUnread(_ isUnread: Bool, for message: InboxMessage) {
        if let index = messages.firstIndex(where: { $0.id == message.id }) {
            messages[index].isUnread = isUnread
        }
    }

    private func remove(_ message: InboxMessage) {
        messages.removeAll { $0.id == message.id }
    }
}

private struct InboxRow: View {
    let message: InboxMessage

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Circle()
                .fill(message.isUnread ? Color.blue : .clear)
                .frame(width: 9, height: 9)
                .padding(.top, 6)
            VStack(alignment: .leading, spacing: 3) {
                HStack(alignment: .firstTextBaseline) {
                    Text(message.sender)
                        .font(.headline)
                        .lineLimit(1)
                    Spacer()
                    Text(message.time)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Text(message.subject)
                    .font(.subheadline)
                    .fontWeight(message.isUnread ? .semibold : .regular)
                    .lineLimit(1)
                Text(message.preview)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(message.isUnread ? "Unread, \(message.sender), \(message.subject)" : "\(message.sender), \(message.subject)")
    }
}

private struct MessageView: View {
    let message: InboxMessage

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(message.subject)
                    .font(.title2.bold())
                HStack {
                    Text(message.sender)
                        .fontWeight(.semibold)
                    Spacer()
                    Text(message.time)
                        .foregroundStyle(.secondary)
                }
                .font(.subheadline)
                Divider()
                Text(message.preview)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct InboxMessage: Identifiable, Equatable {
    let id = UUID()
    let sender: String
    let subject: String
    let preview: String
    let time: String
    var isUnread: Bool

    static let samples = [
        InboxMessage(sender: "Priya Raman", subject: "Design review moved to Thursday",
                     preview: "Hey team, the room was double booked so I moved us to Thursday at 2pm. Same agenda, bring the latest mockups.",
                     time: "9:41 AM", isUnread: true),
        InboxMessage(sender: "Northwind Bank", subject: "Your October statement is ready",
                     preview: "Your statement for the account ending in 4821 is now available to view and download.",
                     time: "8:15 AM", isUnread: true),
        InboxMessage(sender: "Marcus Lee", subject: "Invoice #1042 for September",
                     preview: "Attached is the invoice for September's work. Payment terms are net 30 as usual. Thanks again!",
                     time: "Yesterday", isUnread: false),
        InboxMessage(sender: "Trailhead Outfitters", subject: "Your order has shipped",
                     preview: "Good news! Your trail runners are on the way and should arrive by Friday.",
                     time: "Yesterday", isUnread: true),
        InboxMessage(sender: "Sofia García", subject: "Photos from the weekend",
                     preview: "Finally got around to editing these. The sunset ones came out great, let me know which you want printed.",
                     time: "Mon", isUnread: false),
        InboxMessage(sender: "City Library", subject: "Reminder: 2 books due soon",
                     preview: "The Overstory and Project Hail Mary are due on October 18. Renew online to keep them longer.",
                     time: "Sun", isUnread: false),
    ]
}

#Preview {
    NavigationStack {
        InboxScreen()
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
