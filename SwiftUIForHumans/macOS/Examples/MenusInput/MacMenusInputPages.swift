import SwiftUI

extension Catalog {
    /// This group's pages, in sidebar order within each category.
    static let menusInputPages: [ComponentPage] = [
        // Menus & Commands
        .commands,
        .keyboardShortcuts,
        .contextMenu,
        // Presentation
        .sheet,
        .alert,
        .popover,
        .tooltips,
        // Pointer & Input
        .hover,
        .dragDrop,
        .copyPaste,
        .trackpadGestures,
        // Files & Sharing
        .fileImportExport,
        .shareLink,
    ]

    /// Windows this group's pages open with `OpenDemoWindowButton`.
    static let menusInputDemoWindows: [DemoWindow] = [
        dragDropDemoWindow,
    ]
}
