import SwiftUI

extension Catalog {
    /// This group's pages, in sidebar order within each category.
    static let designPages: [ComponentPage] = [
        .windowsLayout,
        .typography,
        .color,
        .materials,
        .sfSymbols,
        .darkMode,
        .appIcons,
        .writing,
        .motion,
    ]

    /// Windows this group's pages open with `OpenDemoWindowButton`.
    static let designDemoWindows: [DemoWindow] = [
        windowsLayoutDemoWindow,
    ]
}
