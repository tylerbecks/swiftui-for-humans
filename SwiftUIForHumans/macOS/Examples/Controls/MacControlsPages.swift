import SwiftUI

extension Catalog {
    /// This group's pages, in sidebar order within each category.
    static let controlsPages: [ComponentPage] = [
        .toggle,
    ]

    /// Windows this group's pages open with `OpenDemoWindowButton`.
    static let controlsDemoWindows: [DemoWindow] = []
}
