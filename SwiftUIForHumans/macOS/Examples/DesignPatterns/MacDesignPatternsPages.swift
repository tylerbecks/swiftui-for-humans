import SwiftUI

extension Catalog {
    /// This group's pages, in sidebar order within each category.
    static let designPatternsPages: [ComponentPage] = [
        // Accessibility
        .keyboardAccess,
        .voiceOver,
        .contrastTransparency,
        .reduceMotion,
        // Patterns
        .menuBarConventions,
        .settingsPattern,
        .undoRedo,
        .windowsTabs,
        .toolbarsPattern,
        .onboarding,
        .fullScreen,
    ]

    /// Windows this group's pages open with `OpenDemoWindowButton`.
    static let designPatternsDemoWindows: [DemoWindow] =
        windowsTabsDemoWindows + [
            toolbarsPatternDemoWindow,
            onboardingDemoWindow,
            fullScreenDemoWindow,
        ]
}
