import SwiftUI

extension Catalog {
    /// This group's pages, in sidebar order within each category.
    static let windowsNavigationPages: [ComponentPage] = [
        .settingsScene,
    ]

    /// Windows this group's pages open with `OpenDemoWindowButton`.
    static let windowsNavigationDemoWindows: [DemoWindow] = [
        settingsSceneDemoWindow,
    ]
}
