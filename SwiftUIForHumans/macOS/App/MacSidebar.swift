import SwiftUI

/// The sidebar: four large destinations (Search, Design, Build, Ship), then
/// the current area's categories. Two levels, as the HIG asks; pages open
/// in the detail and in the toolbar's jump bar.
struct MacSidebar: View {
    let nav: WindowNavigator
    @State private var showsCategories = true

    var body: some View {
        List(selection: selection) {
            Section {
                DestinationRow(title: "Search", symbol: "magnifyingglass", gradient: AppTab.searchGradient)
                    .tag(SidebarItem.search)
                    .accessibilityIdentifier("dest-search")
                ForEach(AppTab.contentTabs) { tab in
                    DestinationRow(title: tab.title, symbol: tab.symbol, gradient: tab.gradient, count: Catalog.pages(in: tab).count)
                        .tag(SidebarItem.area(tab))
                        .accessibilityIdentifier("dest-\(tab.rawValue)")
                }
            }
            Section(isExpanded: $showsCategories) {
                ForEach(nav.shownArea.categories) { category in
                    let count = Catalog.pages(in: category).count
                    if count > 0 {
                        Label {
                            Text(category.rawValue)
                        } icon: {
                            Image(systemName: category.symbol)
                                .foregroundStyle(nav.shownArea.tint)
                        }
                        .badge(count)
                        .tag(SidebarItem.category(category))
                        // On a page its category is already selected, so a
                        // click wouldn't change the selection; this still
                        // goes back to the category's list.
                        .simultaneousGesture(TapGesture().onEnded {
                            nav.show(.category(category))
                        })
                        // The tap gesture hides the label from VoiceOver,
                        // which would read only the count.
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel(category.rawValue)
                        .accessibilityValue("\(count) pages")
                        .accessibilityAddTraits(.isButton)
                        .accessibilityIdentifier("cat-\(category.id)")
                    }
                }
            } header: {
                HStack(spacing: 6) {
                    Circle()
                        .fill(nav.shownArea.tint)
                        .frame(width: 6, height: 6)
                    Text(nav.shownArea.title)
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("\(nav.shownArea.title) categories")
                .accessibilityAddTraits(.isHeader)
            }
            .id(nav.shownArea)
        }
        .listStyle(.sidebar)
        .animation(.snappy, value: nav.shownArea)
    }

    private var selection: Binding<SidebarItem?> {
        Binding {
            nav.sidebarSelection
        } set: { item in
            if let item { nav.show(item) }
        }
    }
}

/// A large colored destination row, like the top of Podcasts or Freeform.
private struct DestinationRow: View {
    let title: String
    let symbol: String
    let gradient: LinearGradient
    var count: Int? = nil

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: symbol)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 26, height: 26)
                .background(gradient, in: .circle)
            Text(title)
                .font(.body.weight(.medium))
            Spacer(minLength: 0)
            if let count {
                Text("\(count)")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }
        }
        .padding(.vertical, 3)
        .accessibilityElement(children: .combine)
    }
}

extension AppTab {
    /// The area's color on the Mac: its sidebar circle, category symbols,
    /// path step, and buttons. It matches the area's wallpaper.
    var tint: Color {
        switch self {
        case .design: Color(hex: 0xF2668B)
        case .build: Color(hex: 0x6E7BFF)
        case .ship: Color(hex: 0x24B89A)
        case .search: .gray
        }
    }

    var gradient: LinearGradient {
        let colors: [Color] = switch self {
        case .design: [Color(hex: 0xFFA36C), Color(hex: 0xEE5A9B)]
        case .build: [Color(hex: 0x5B8CFF), Color(hex: 0x9A6BFF)]
        case .ship: [Color(hex: 0x2EC4B6), Color(hex: 0x34C759)]
        case .search: [Color(hex: 0x9A9AA0), Color(hex: 0x636366)]
        }
        return LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    static var searchGradient: LinearGradient { AppTab.search.gradient }
}
