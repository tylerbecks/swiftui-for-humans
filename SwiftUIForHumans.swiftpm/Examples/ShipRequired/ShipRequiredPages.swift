import SwiftUI

// Pages in the Ship: Required by Apple group, in sidebar order. Only this group edits this file.
extension Catalog {
    static let shipRequiredPages: [ComponentPage] = [
        .shipSignInWithApple,
        .shipDeleteAccount,
        .shipPaywall,
        .shipRequestReview,
    ]
}
