import Foundation
import Testing
@testable import SwiftUIForHumans

struct RegistryTests {
    @Test func pageIDsAreUnique() {
        var seen: Set<String> = []
        for page in Catalog.pages {
            #expect(seen.insert(page.id).inserted, "Duplicate page id \(page.id)")
        }
        #expect(!seen.contains(Catalog.overviewID))
    }

    @Test func relatedIDsExist() {
        let ids = Set(Catalog.pages.map(\.id))
        for page in Catalog.pages {
            for related in page.related {
                #expect(ids.contains(related), "\(page.id) links to missing page \(related)")
            }
            #expect(!page.related.contains(page.id), "\(page.id) links to itself")
        }
    }

    @Test func everyPageIsReachableFromATab() {
        let reachable = AppTab.contentTabs.flatMap { Catalog.pages(in: $0) }
        #expect(reachable.count == Catalog.pages.count)
    }

    @Test func linksAreHTTPS() {
        for page in Catalog.pages {
            for url in [page.docsURL, page.higURL].compactMap(\.self) + page.sources {
                #expect(url.scheme == "https", "\(page.id) has non-HTTPS link \(url)")
            }
        }
    }

    @Test func neighborsStayInTab() {
        for page in Catalog.pages {
            let (previous, next) = Catalog.neighbors(of: page.id)
            #expect(previous.map { $0.category.tab == page.category.tab } ?? true)
            #expect(next.map { $0.category.tab == page.category.tab } ?? true)
        }
    }
}
