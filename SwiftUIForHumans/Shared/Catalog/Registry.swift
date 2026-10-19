import SwiftUI

/// Lookups over every page in the app. The list itself, `Catalog.pages`,
/// comes from the edition's `Edition.swift`, which joins one list per group
/// of examples, each declared in that group's `<Group>Pages.swift`.
enum Catalog {
    static let overviewID = "overview"

    static func page(id: ComponentPage.ID?) -> ComponentPage? {
        pages.first { $0.id == id }
    }

    static func pages(in category: ComponentCategory) -> [ComponentPage] {
        pages.filter { $0.category == category }
    }

    static func pages(in tab: AppTab) -> [ComponentPage] {
        tab.categories.flatMap { pages(in: $0) }
    }

    /// The pages before and after `id` in sidebar order, within its tab.
    static func neighbors(of id: ComponentPage.ID) -> (previous: ComponentPage?, next: ComponentPage?) {
        guard let page = page(id: id) else { return (nil, nil) }
        let ordered = pages(in: page.category.tab)
        guard let index = ordered.firstIndex(where: { $0.id == id }) else { return (nil, nil) }
        return (
            index > 0 ? ordered[index - 1] : nil,
            index + 1 < ordered.count ? ordered[index + 1] : nil
        )
    }
}
