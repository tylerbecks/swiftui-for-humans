import SwiftUI

extension Catalog {
    /// This group's pages, in sidebar order within each category.
    static let shipPages: [ComponentPage] = [
        // Start Here
        .nativeVsCatalyst,
        .greatMacApp,
        // Feels Like a Mac
        .macNativeChecklist,
        .iPadAppInWindow,
        // Required by Apple
        .appSandbox,
        .privacyPermissions,
        .macAppReview,
        // App Store Connect
        .universalPurchase,
        .macScreenshots,
        .pricingCategory,
        // Test & Release
        .testFlightMac,
        .hardenedRuntime,
        .developerIDNotarization,
        .updatesOutsideStore,
    ]

    /// Windows this group's pages open with `OpenDemoWindowButton`.
    static let shipDemoWindows: [DemoWindow] = [
        shipSidebarDemoWindow,
    ]
}
