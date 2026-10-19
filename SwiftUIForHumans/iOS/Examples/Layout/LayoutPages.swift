import SwiftUI

// Pages in the Layout group, in sidebar order. Only this group edits this file.
extension Catalog {
    static let layoutPages: [ComponentPage] = [
        .layoutBasics,
        .stacks,
        .spacerDivider,
        .grid,
        .lazyGrids,
        .scrollView,
        .viewThatFits,
        .geometryReader,
        .safeArea,
    ]
}
