import SwiftUI

// Pages in the Ship tab's Start Here, Feels Native, and Test & Release
// groups, in sidebar order. Only this group edits this file.
extension Catalog {
    static let shipNativePages: [ComponentPage] = [
        // Start Here
        .shipSubmissionChecklist,
        .shipRejectionGuide,
        // Feels Native
        .shipNativeNotWeb,
        .shipAppearanceCheck,
        .shipStatesCheck,
        // Test & Release
        .shipTestFlight,
        .shipAppReview,
        .shipReleasing,
    ]
}
