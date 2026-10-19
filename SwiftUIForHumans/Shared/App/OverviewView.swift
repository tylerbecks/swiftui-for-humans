import SwiftUI

/// A tab's home page: every page in the tab as a grid of live thumbnails,
/// grouped by category, with chips to jump to a single category.
struct OverviewView: View {
    let tab: AppTab
    @Environment(\.openPage) private var openPage
    @State private var filter: ComponentCategory?
    @State private var scroll = ListScroll()
    @Environment(\.isCompactLayout) private var isCompact

    private var categories: [ComponentCategory] {
        tab.categories.filter { !Catalog.pages(in: $0).isEmpty }
    }

    var body: some View {
        ScrollViewReader { proxy in
            scrollView
                .task {
                    // `-scrollTo <category>` (e.g. "Blocks") or `-scrollTo card-<page id>`.
                    // With `-open`, the flag is meant for that page, not this one.
                    guard LaunchOptions.value(for: "-open") == nil,
                          let anchor = LaunchOptions.takeValue(for: "-scrollTo") else { return }
                    try? await Task.sleep(for: .milliseconds(300))
                    // Cards sit in lazy grids and only exist once their
                    // section is on screen, so reach the section first.
                    if anchor.hasPrefix("card-"),
                       let page = Catalog.page(id: String(anchor.dropFirst(5))) {
                        proxy.scrollTo(page.category.rawValue, anchor: .top)
                        try? await Task.sleep(for: .milliseconds(300))
                    }
                    proxy.scrollTo(anchor, anchor: .top)
                }
        }
        .background(alignment: .top) {
            // On iPad the overview is the tab's first screen, so it carries
            // the tab's wallpaper, scrolling with the content and dimmed
            // behind the title and intro; on iPhone that's the list, one
            // step back.
            if !isCompact {
                HeroBackdrop(tab: tab, scroll: scroll, background: .catalogBackground)
            }
        }
        .navigationTitle(tab.title)
        .catalogPageTitle()
    }

    private var scrollView: some View {
        ScrollView {

            VStack(alignment: .leading, spacing: 36) {
                hero
                if categories.isEmpty {
                    ComingSoonView(tab: tab)
                        .padding(.top, 40)
                } else {
                    chips
                }
                ForEach(categories.filter { filter == nil || $0 == filter }) { category in
                    CategorySection(category: category) { openPage($0) }
                        .id(category.rawValue)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 4)
            .padding(.bottom, 28)
            .frame(maxWidth: 1100, alignment: .leading)
            .frame(maxWidth: .infinity)
        }
        .onScrollGeometryChange(for: ListScroll.Reading.self) {
            ListScroll.Reading(offset: $0.contentOffset.y + $0.contentInsets.top, underBar: $0.contentInsets.top)
        } action: { _, new in
            scroll.reading = new
        }
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: 12) {
            if CatalogPlatform.showsTitleInContent {
                Text(tab.title)
                    .font(.largeTitle.bold())
                    .padding(.top, 12)
            }
            Text(tab.intro)
                .font(.title3)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            let pages = Catalog.pages(in: tab)
            if !pages.isEmpty {
                HStack(spacing: 16) {
                    stat(count: pages.count, label: "pages")
                    let concepts = pages.filter { $0.kind == .concept }.count
                    if concepts > 0 {
                        stat(count: concepts, label: "concepts")
                    }
                    let blocks = pages.filter { $0.kind == .block }.count
                    if blocks > 0 {
                        stat(count: blocks, label: "blocks")
                    }
                }
                .padding(.top, 4)
            }
        }
    }

    private func stat(count: Int, label: String) -> some View {
        HStack(spacing: 4) {
            Text("\(count)")
                .fontWeight(.semibold)
                .monospacedDigit()
            Text(label)
                .foregroundStyle(.secondary)
        }
        .font(.subheadline)
    }

    private var chips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                chip("All", symbol: "square.grid.2x2", isOn: filter == nil) { filter = nil }
                ForEach(categories) { category in
                    chip(category.rawValue, symbol: category.symbol, isOn: filter == category) {
                        filter = filter == category ? nil : category
                    }
                }
            }
        }
        .scrollClipDisabled()
    }

    private func chip(_ title: String, symbol: String, isOn: Bool, action: @escaping () -> Void) -> some View {
        Button {
            withAnimation(.snappy) { action() }
        } label: {
            Label(title, systemImage: symbol)
                .font(.subheadline.weight(.medium))
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .foregroundStyle(isOn ? AnyShapeStyle(.background) : AnyShapeStyle(.primary))
                .background(isOn ? AnyShapeStyle(.primary) : AnyShapeStyle(.fill.tertiary), in: .capsule)
        }
        .buttonStyle(.plain)
    }
}

private struct CategorySection: View {
    let category: ComponentCategory
    let open: (ComponentPage.ID) -> Void
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    /// One card per row at accessibility sizes, where two columns leave
    /// room for only a few words per line.
    private var columns: [GridItem] {
        dynamicTypeSize.isAccessibilitySize
            ? [GridItem(.flexible(), spacing: 14)]
            : [GridItem(.adaptive(minimum: 220), spacing: 14)]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                Label(category.rawValue, systemImage: category.symbol)
                    .font(.title2.bold())
                Text(category.blurb)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            LazyVGrid(columns: columns, spacing: 14) {
                ForEach(Catalog.pages(in: category)) { page in
                    Button {
                        open(page.id)
                    } label: {
                        GalleryCard(page: page)
                    }
                    .buttonStyle(CardButtonStyle())
                    .catalogHover(.lift)
                    .contextMenu {
                        OpenInNewWindowButton(id: page.id)
                    }
                    .accessibilityIdentifier("card-\(page.id)")
                    .id("card-\(page.id)")
                }
            }
        }
    }
}

/// A thumbnail card. The thumbnail is the real component, shown in a
/// 150pt-tall box and not interactive.
struct GalleryCard: View {
    let page: ComponentPage
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            page.makeThumbnail()
                // The thumbnail is a picture in a fixed box and hidden from
                // VoiceOver, so its text stops growing at a size that fits.
                .dynamicTypeSize(...DynamicTypeSize.large)
                // `minWidth: 0` keeps a wide thumbnail from widening the
                // card past its grid column; the extra is clipped.
                .frame(minWidth: 0, maxWidth: .infinity)
                .frame(height: 150)
                .clipped()
                .allowsHitTesting(false)
                .accessibilityHidden(true)
                .background(.background.secondary)

            Divider()

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(page.title)
                        .font(.headline)
                    if page.isNew {
                        NewBadge()
                    }
                    Spacer(minLength: 0)
                }
                Text(page.summary)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    // At accessibility sizes two lines hold only a few words,
                    // and with one card per row there's no neighbor to match.
                    .lineLimit(dynamicTypeSize.isAccessibilitySize ? 5 : 2, reservesSpace: !dynamicTypeSize.isAccessibilitySize)
                    .multilineTextAlignment(.leading)
            }
            .padding(12)
        }
        .background(.background)
        .clipShape(.rect(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(.separator)
        }
        .contentShape(.rect(cornerRadius: 16))
    }
}

private struct CardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .opacity(configuration.isPressed ? 0.85 : 1)
            .animation(.snappy(duration: 0.2), value: configuration.isPressed)
    }
}
