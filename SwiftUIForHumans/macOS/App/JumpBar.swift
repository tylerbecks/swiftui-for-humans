import SwiftUI

/// Where a page sits, in the toolbar: Area › Category › Page. Each part is
/// a menu of its siblings, so any page in the category is two clicks away,
/// even with the sidebar hidden in a narrow window beside Xcode.
struct JumpBar: View {
    let page: ComponentPage
    let nav: WindowNavigator

    private var area: AppTab { page.category.tab }
    private var siblings: [ComponentPage] { Catalog.pages(in: page.category) }

    var body: some View {
        HStack(spacing: 2) {
            Menu {
                ForEach(AppTab.contentTabs) { tab in
                    Button(tab.title, systemImage: tab.symbol) {
                        nav.show(.area(tab))
                    }
                }
            } label: {
                Label(area.title, systemImage: area.symbol)
            }
            .accessibilityIdentifier("jump-area")
            separator
            Menu {
                ForEach(area.categories.filter { !Catalog.pages(in: $0).isEmpty }) { category in
                    Button {
                        nav.show(.category(category))
                    } label: {
                        Label("\(category.rawValue)  \(Catalog.pages(in: category).count)", systemImage: category.symbol)
                    }
                }
            } label: {
                Label(page.category.rawValue, systemImage: page.category.symbol)
            }
            .accessibilityIdentifier("jump-category")
            separator
            Menu {
                Picker("Page", selection: pageBinding) {
                    ForEach(siblings) { sibling in
                        Text(sibling.title).tag(sibling.id)
                    }
                }
                .pickerStyle(.inline)
                .labelsHidden()
                Divider()
                Button("Show All \(page.category.rawValue)") {
                    nav.goUp()
                }
            } label: {
                Text(page.title)
            }
            .accessibilityIdentifier("jump-page")
        }
        .menuStyle(.button)
        .buttonStyle(.borderless)
        .menuIndicator(.visible)
        .labelStyle(.titleAndIcon)
        .fixedSize()
    }

    private var separator: some View {
        Image(systemName: "chevron.forward")
            .font(.caption.weight(.semibold))
            .foregroundStyle(.tertiary)
            .accessibilityHidden(true)
    }

    private var pageBinding: Binding<ComponentPage.ID> {
        Binding {
            page.id
        } set: { id in
            nav.open(id)
        }
    }
}
