import SwiftUI

/// The home page: every page in the catalog as a grid of live thumbnails,
/// grouped by category, with chips to jump to a single category.
struct OverviewView: View {
    @Environment(\.openPage) private var openPage
    @State private var filter: ComponentCategory?
    @Environment(\.horizontalSizeClass) private var sizeClass

    private var categories: [ComponentCategory] {
        ComponentCategory.allCases.filter { !Catalog.pages(in: $0).isEmpty }
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
        .navigationTitle("SwiftUI for Humans")
        .toolbarTitleDisplayMode(.catalogPage(sizeClass))
    }

    private var scrollView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 36) {
                hero
                chips
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
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Every SwiftUI component, live. Change it, see it, copy the code.")
                .font(.title3)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            HStack(spacing: 16) {
                stat(count: Catalog.pages.count, label: "pages")
                stat(count: Catalog.pages.filter { $0.kind == .concept }.count, label: "concepts")
                stat(count: Catalog.pages.filter { $0.kind == .block }.count, label: "blocks")
            }
            .padding(.top, 4)
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

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                Label(category.rawValue, systemImage: category.symbol)
                    .font(.title2.bold())
                Text(category.blurb)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 220), spacing: 14)], spacing: 14) {
                ForEach(Catalog.pages(in: category)) { page in
                    Button {
                        open(page.id)
                    } label: {
                        GalleryCard(page: page)
                    }
                    .buttonStyle(CardButtonStyle())
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

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            page.makeThumbnail()
                .frame(maxWidth: .infinity)
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
                    .lineLimit(2, reservesSpace: true)
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
