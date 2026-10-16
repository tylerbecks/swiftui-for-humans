import SwiftUI

// Pages in the DataFlow group, in sidebar order. Only this group edits this file.
extension Catalog {
    static let dataFlowPages: [ComponentPage] = [
        .choosingWrappers,
        .state,
        .binding,
        .observable,
        .environment,
        .lifecycle,
        .viewUpdates,
    ]
}
