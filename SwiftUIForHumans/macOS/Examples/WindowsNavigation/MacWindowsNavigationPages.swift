import SwiftUI

extension Catalog {
    /// This group's pages, in sidebar order within each category.
    static let windowsNavigationPages: [ComponentPage] = [
        // Windows & Scenes
        .windowGroup,
        .windowScene,
        .settingsScene,
        .menuBarExtra,
        .documentGroup,
        .windowStyle,
        .openingWindows,
        // Navigation
        .navigationSplitView,
        .navigationStack,
        .toolbar,
        .search,
    ]

    /// Windows this group's pages open with `OpenDemoWindowButton`.
    static let windowsNavigationDemoWindows: [DemoWindow] =
        windowGroupDemoWindows
        + [windowSceneDemoWindow, settingsSceneDemoWindow]
        + windowStyleDemoWindows
        + navigationSplitViewDemoWindows
        + [navigationStackDemoWindow]
        + toolbarDemoWindows
        + [searchDemoWindow]
}
