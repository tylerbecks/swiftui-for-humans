import SwiftUI

// Pages in the Navigation group, in sidebar order. Only this group edits this file.
extension Catalog {
    static let navigationPages: [ComponentPage] = [
        .list,
        .form,
        .navigationStack,
        .navigationSplitView,
        .tabView,
        .toolbar,
        .searchable,
        .swipeActions,
        .sheet,
        .alert,
        .confirmationDialog,
        .popover,
        .contextMenu,
    ]
}
