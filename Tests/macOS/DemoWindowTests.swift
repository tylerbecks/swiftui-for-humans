import Testing
@testable import SwiftUIForHumans

struct DemoWindowTests {
    @Test func demoWindowIDsAreUnique() {
        var seen: Set<String> = []
        for window in Catalog.demoWindows {
            #expect(seen.insert(window.id).inserted, "Duplicate demo window id \(window.id)")
        }
    }

    @Test func demoWindowsHaveTitles() {
        for window in Catalog.demoWindows {
            #expect(!window.title.isEmpty, "\(window.id) has no title")
        }
    }
}
