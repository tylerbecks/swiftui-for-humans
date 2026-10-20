import SwiftUI

/// Every page in one category as a scannable list, like Mail's message
/// list: ↑/↓ to move, Return or double-click to open.
struct MacCategoryList: View {
    let category: ComponentCategory
    let nav: WindowNavigator
    @State private var selection: ComponentPage.ID?

    private var pages: [ComponentPage] { Catalog.pages(in: category) }

    var body: some View {
        List(selection: $selection) {
            Section {
                ForEach(pages) { page in
                    MacPageRow(page: page)
                        .tag(page.id)
                        .accessibilityIdentifier("row-\(page.id)")
                }
            } header: {
                VStack(alignment: .leading, spacing: 6) {
                    Label {
                        Text(category.rawValue)
                    } icon: {
                        Image(systemName: category.symbol)
                            .foregroundStyle(category.tab.tint)
                    }
                    .font(.largeTitle.bold())
                    .foregroundStyle(.primary)
                    Text(category.blurb)
                        .font(.title3)
                        .foregroundStyle(.secondary)
                    Text("\(pages.count) pages in \(category.tab.title)")
                        .font(.subheadline)
                        .foregroundStyle(.tertiary)
                }
                .textCase(nil)
                .padding(.bottom, 12)
            }
        }
        .listStyle(.inset)
        .alternatingRowBackgrounds(.disabled)
        .scrollContentBackground(.hidden)
        .background(alignment: .top) { AreaGlow(tab: category.tab) }
        .contextMenu(forSelectionType: ComponentPage.ID.self) { ids in
            if let id = ids.first {
                Button("Open") { nav.open(id) }
                OpenInNewWindowButton(id: id)
            }
        } primaryAction: { ids in
            if let id = ids.first { nav.open(id) }
        }
        .onAppear {
            // Coming back from a page selects it, so ↑/↓ pick up from there.
            if let last = nav.lastPage(in: category.tab), last.category == category {
                selection = last.id
            } else {
                selection = pages.first?.id
            }
        }
    }
}

/// A page as a list row: a live thumbnail, the title, why it matched (in
/// search), and a two-line summary.
struct MacPageRow: View {
    let page: ComponentPage
    var match: String? = nil

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            page.makeThumbnail()
                .frame(width: 240, height: 136)
                .scaleEffect(0.5)
                .frame(width: 120, height: 68)
                .clipped()
                .allowsHitTesting(false)
                .accessibilityHidden(true)
                .background(.background.secondary)
                .clipShape(.rect(cornerRadius: 8))
                .overlay {
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(.separator)
                }
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text(page.title)
                        .font(.headline)
                    if page.isNew {
                        NewBadge()
                    }
                }
                if let match {
                    RichText(match)
                        .font(.callout)
                        .foregroundStyle(page.category.tab.tint)
                }
                Text(page.summary)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            Spacer(minLength: 0)
        }
        .padding(.vertical, 6)
        .accessibilityElement(children: .combine)
    }
}

/// A faint wash of the area's color at the top of lists and search, so the
/// area still reads at a glance without the full wallpaper.
struct AreaGlow: View {
    let tab: AppTab

    var body: some View {
        LinearGradient(colors: [tab.tint.opacity(0.18), .clear], startPoint: .top, endPoint: .bottom)
            .frame(height: 220)
            .ignoresSafeArea()
            .allowsHitTesting(false)
    }
}
