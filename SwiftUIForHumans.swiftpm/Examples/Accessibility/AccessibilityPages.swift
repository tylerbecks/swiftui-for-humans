import SwiftUI

// Pages in the Accessibility group, in sidebar order. Only this group edits this file.
extension Catalog {
    static let accessibilityPages: [ComponentPage] = [
        .accessibilityOverview,
        .voiceOver,
        .dynamicType,
        .reduceMotion,
        .colorAndContrast,
    ]
}
