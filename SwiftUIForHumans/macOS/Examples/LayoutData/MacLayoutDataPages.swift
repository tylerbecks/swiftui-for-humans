import SwiftUI

extension Catalog {
    /// This group's pages, in sidebar order within each category.
    static let layoutDataPages: [ComponentPage] = [
        // Layout
        .stacksGrid,
        .form,
        .groupBox,
        .splitViews,
        .scrollView,
        .viewThatFits,
        // Lists & Tables
        .listStyles,
        .table,
        .outline,
        // Navigation
        .inspector,
    ]

    /// Windows this group's pages open with `OpenDemoWindowButton`.
    static let layoutDataDemoWindows: [DemoWindow] = [
        splitViewsPanesDemoWindow,
        splitViewsNavigationDemoWindow,
        inspectorDemoWindow,
        viewThatFitsDemoWindow,
    ]
}
