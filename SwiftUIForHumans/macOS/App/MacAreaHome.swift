import SwiftUI

/// An area's home: the ribbon hero (running under the glass sidebar), the
/// Design → Build → Ship path, Continue, and one shelf per category.
struct MacAreaHome: View {
    let tab: AppTab
    let nav: WindowNavigator
    @State private var scroll = ListScroll()

    private var categories: [ComponentCategory] {
        tab.categories.filter { !Catalog.pages(in: $0).isEmpty }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 40) {
                AreaHero(tab: tab, nav: nav)
                ForEach(categories) { category in
                    CategoryShelf(category: category, nav: nav)
                        .id(category.rawValue)
                }
            }
            .padding(.horizontal, 32)
            .padding(.top, 8)
            .padding(.bottom, 40)
            .frame(maxWidth: 1240, alignment: .leading)
            .frame(maxWidth: .infinity)
        }
        .onScrollGeometryChange(for: ListScroll.Reading.self) {
            ListScroll.Reading(offset: $0.contentOffset.y + $0.contentInsets.top, underBar: $0.contentInsets.top)
        } action: { _, new in
            scroll.reading = new
        }
        .background(alignment: .top) {
            HeroBackdrop(tab: tab, scroll: scroll, background: .catalogBackground)
                // Mirrors the ribbons under the floating sidebar.
                .backgroundExtensionEffect()
                // It's only decoration. The mirrored copy reaches under the
                // toolbar and would otherwise swallow clicks on the sidebar
                // button beside the traffic lights.
                .allowsHitTesting(false)
        }
        .scrollEdgeEffectStyle(.soft, for: .top)
    }
}

// MARK: - Hero

private struct AreaHero: View {
    let tab: AppTab
    let nav: WindowNavigator

    private var pages: [ComponentPage] { Catalog.pages(in: tab) }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            PathStepper(current: tab, nav: nav)
            VStack(alignment: .leading, spacing: 8) {
                Text(tab.title)
                    .font(.system(size: 44, weight: .bold))
                Text(tab.intro)
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            HStack(spacing: 10) {
                continueButton
                secondaryButton
            }
            .controlSize(.large)
            .padding(.top, 4)
            stats
        }
        .padding(.top, 12)
    }

    @ViewBuilder
    private var continueButton: some View {
        if let last = nav.lastPage(in: tab) {
            Button {
                nav.open(last.id)
            } label: {
                Label("Continue · \(last.title)", systemImage: "play.fill")
            }
            .buttonStyle(.glassProminent)
            .tint(tab.tint)
        } else if let first = pages.first {
            Button {
                nav.open(first.id)
            } label: {
                Label("Start · \(first.title)", systemImage: "play.fill")
            }
            .buttonStyle(.glassProminent)
            .tint(tab.tint)
        }
    }

    @ViewBuilder
    private var secondaryButton: some View {
        switch tab {
        case .design:
            Button("Accessibility", systemImage: "accessibility") { nav.show(.category(.accessibility)) }
                .buttonStyle(.glass)
        case .build:
            Button("Browse Blocks", systemImage: "square.stack.3d.up") { nav.show(.category(.blocks)) }
                .buttonStyle(.glass)
        case .ship:
            if Catalog.page(id: "mac-native-checklist") != nil {
                Button("Mac-Native Checklist", systemImage: "checklist") { nav.open("mac-native-checklist") }
                    .buttonStyle(.glass)
            }
        case .search:
            EmptyView()
        }
    }

    private var stats: some View {
        let read = Engagement.shared.viewedPages.intersection(pages.map(\.id)).count
        let categoryCount = tab.categories.filter { !Catalog.pages(in: $0).isEmpty }.count
        return HStack(spacing: 18) {
            stat(pages.count, "pages")
            stat(categoryCount, "categories")
            if read > 0 {
                stat(read, "read")
            }
        }
        .font(.subheadline)
    }

    private func stat(_ count: Int, _ label: String) -> some View {
        HStack(spacing: 4) {
            Text("\(count)")
                .fontWeight(.semibold)
                .monospacedDigit()
            Text(label)
                .foregroundStyle(.secondary)
        }
    }
}

/// Design → Build → Ship, with the current area lit. Each step opens its area.
private struct PathStepper: View {
    let current: AppTab
    let nav: WindowNavigator

    var body: some View {
        HStack(spacing: 6) {
            ForEach(Array(AppTab.contentTabs.enumerated()), id: \.element) { index, tab in
                if index > 0 {
                    Image(systemName: "chevron.forward")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.tertiary)
                }
                Button {
                    nav.show(.area(tab))
                } label: {
                    HStack(spacing: 6) {
                        Text("\(index + 1)")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.white)
                            .frame(width: 18, height: 18)
                            .background(tab == current ? AnyShapeStyle(tab.gradient) : AnyShapeStyle(Color.secondary.opacity(0.45)), in: .circle)
                        Text(tab.title)
                            .font(.subheadline.weight(tab == current ? .semibold : .regular))
                            .foregroundStyle(tab == current ? .primary : .secondary)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .glassEffect(tab == current ? .regular : .clear, in: .capsule)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Step \(index + 1): \(tab.title)")
            }
        }
    }
}

// MARK: - Shelves

/// One category: its name (which opens the category), its blurb, and a
/// horizontal shelf of live cards that pages on hover.
private struct CategoryShelf: View {
    let category: ComponentCategory
    let nav: WindowNavigator
    @State private var position = ScrollPosition(idType: ComponentPage.ID.self)
    @State private var visibleIDs: [ComponentPage.ID] = []
    @State private var isHovering = false

    private var pages: [ComponentPage] { Catalog.pages(in: category) }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                Button {
                    nav.show(.category(category))
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: category.symbol)
                            .foregroundStyle(category.tab.tint)
                        Text(category.rawValue)
                        Image(systemName: "chevron.forward")
                            .font(.headline)
                            .foregroundStyle(.tertiary)
                    }
                    .font(.title2.bold())
                }
                .buttonStyle(.plain)
                Spacer()
                Button("See All \(pages.count)") {
                    nav.show(.category(category))
                }
                .buttonStyle(.link)
            }
            Text(category.blurb)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            shelf
        }
    }

    private var shelf: some View {
        let read = Engagement.shared.viewedPages
        return ScrollView(.horizontal) {
            LazyHStack(spacing: 16) {
                ForEach(pages) { page in
                    Button {
                        nav.open(page.id)
                    } label: {
                        GalleryCard(page: page)
                            .overlay(alignment: .topTrailing) {
                                if read.contains(page.id) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .symbolRenderingMode(.palette)
                                        .foregroundStyle(.white, category.tab.tint)
                                        .font(.title3)
                                        .padding(8)
                                        .accessibilityLabel("Read")
                                }
                            }
                    }
                    .buttonStyle(CardButtonStyle())
                    .frame(width: 250)
                    .contextMenu {
                        OpenInNewWindowButton(id: page.id)
                    }
                    .accessibilityIdentifier("card-\(page.id)")
                    .id(page.id)
                }
            }
            .scrollTargetLayout()
            .padding(.vertical, 4)
        }
        .scrollIndicators(.hidden)
        .scrollTargetBehavior(.viewAligned)
        .scrollPosition($position)
        .scrollClipDisabled()
        .onScrollTargetVisibilityChange(idType: ComponentPage.ID.self) { ids in
            visibleIDs = ids
        }
        .overlay {
            if isHovering && pages.count > 1 {
                HStack {
                    pagerButton("chevron.backward", label: "Previous") { step(-1) }
                    Spacer()
                    pagerButton("chevron.forward", label: "Next") { step(1) }
                }
                .padding(.horizontal, -14)
            }
        }
        .onHover { isHovering = $0 }
    }

    private func pagerButton(_ symbol: String, label: String, action: @escaping () -> Void) -> some View {
        Button(label, systemImage: symbol, action: action)
            .labelStyle(.iconOnly)
            .buttonStyle(.glass)
            .buttonBorderShape(.circle)
            .controlSize(.large)
    }

    /// Scrolls by a shelf's worth of cards.
    private func step(_ direction: Int) {
        let ids = pages.map(\.id)
        let visible = visibleIDs.compactMap { ids.firstIndex(of: $0) }.sorted()
        guard let first = visible.first else { return }
        let jump = max(1, visible.count - 1)
        let target = min(max(first + direction * jump, 0), ids.count - 1)
        withAnimation(.smooth) {
            position.scrollTo(id: ids[target], anchor: .leading)
        }
    }
}
