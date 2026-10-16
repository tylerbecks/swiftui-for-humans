import SwiftUI

/// Every page in the app. Each group of examples owns one list, declared in
/// that group's `_Pages.swift` file under `Examples/`.
enum Catalog {
    static let overviewID = "overview"

    static let pages: [ComponentPage] =
        controlsPages
        + textPages
        + layoutPages
        + navigationPages
        + modifierPages
        + dataFlowPages
        + animationPages
        + designPages
        + blockPages

    static func page(id: ComponentPage.ID?) -> ComponentPage? {
        pages.first { $0.id == id }
    }

    static func pages(in category: ComponentCategory) -> [ComponentPage] {
        pages.filter { $0.category == category }
    }

    /// Pages in sidebar order (by category), for previous/next links.
    static let ordered: [ComponentPage] = ComponentCategory.allCases.flatMap { pages(in: $0) }

    /// The pages before and after `id` in sidebar order.
    static func neighbors(of id: ComponentPage.ID) -> (previous: ComponentPage?, next: ComponentPage?) {
        guard let index = ordered.firstIndex(where: { $0.id == id }) else { return (nil, nil) }
        return (
            index > 0 ? ordered[index - 1] : nil,
            index + 1 < ordered.count ? ordered[index + 1] : nil
        )
    }
}
