import Testing
@testable import SwiftUIForHumans

/// Checks that only hold once an edition's content is written. The Mac
/// edition gets the same checks when its pages are done.
struct IOSEditionTests {
    @Test func everyCategoryHasPages() {
        for category in ComponentCategory.allCases {
            #expect(!Catalog.pages(in: category).isEmpty, "\(category) has no pages")
        }
    }
}
