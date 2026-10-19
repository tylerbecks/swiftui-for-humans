import SwiftUI

extension Catalog {
    /// This group's pages, in sidebar order within each category.
    static let essentialsBlocksPages: [ComponentPage] = [
        .stateBinding,
        .observable,
        .environment,
        .animation,
        .chartsMaps,
        .libraryWindow,
        .settingsWindow,
        .menuBarUtility,
        .documentEditor,
        .welcomeWindow,
        .emptyStates,
    ]

    /// Windows this group's pages open with `OpenDemoWindowButton`.
    static let essentialsBlocksDemoWindows: [DemoWindow] = [
        observableDemoWindow,
        environmentDemoWindow,
        chartsMapsDemoWindow,
        libraryWindowDemoWindow,
        emptyStatesDemoWindow,
    ]
}
