import Foundation
import Testing
@testable import SwiftUIForHumans

@MainActor
struct WindowNavigatorTests {
    private func makeNavigator(start: Location = Location(item: .area(.design))) -> WindowNavigator {
        let defaults = UserDefaults(suiteName: "WindowNavigatorTests-\(UUID().uuidString)")!
        return WindowNavigator(start: start, defaults: defaults)
    }

    @Test func openingAPageSelectsItsCategory() {
        let nav = makeNavigator()
        nav.open("toggle")
        #expect(nav.current == Location(item: .category(.controls), page: "toggle"))
        #expect(nav.sidebarSelection == .category(.controls))
        #expect(nav.shownArea == .build)
    }

    @Test func backAndForwardRetraceTheWay() {
        let nav = makeNavigator()
        nav.show(.area(.build))
        nav.open("toggle")
        nav.goBack()
        #expect(nav.current == Location(item: .area(.build)))
        nav.goBack()
        #expect(nav.current == Location(item: .area(.design)))
        #expect(!nav.canGoBack)
        nav.goForward()
        nav.goForward()
        #expect(nav.currentPage?.id == "toggle")
        #expect(!nav.canGoForward)
    }

    @Test func goingSomewhereNewClearsForward() {
        let nav = makeNavigator()
        nav.open("toggle")
        nav.goBack()
        nav.show(.area(.ship))
        #expect(!nav.canGoForward)
    }

    @Test func upClimbsPageThenCategoryThenArea() {
        let nav = makeNavigator()
        nav.open("toggle")
        nav.goUp()
        #expect(nav.current == Location(item: .category(.controls)))
        nav.goUp()
        #expect(nav.current == Location(item: .area(.build)))
        #expect(!nav.canGoUp)
    }

    @Test func searchKeepsTheShownArea() {
        let nav = makeNavigator()
        nav.show(.area(.ship))
        nav.showSearch()
        #expect(nav.current.item == .search)
        #expect(nav.shownArea == .ship)
    }

    @Test func searchKeepsItsQueryAndScopeAcrossAResult() {
        let nav = makeNavigator()
        nav.showSearch()
        nav.searchText = "toggle"
        nav.searchScope = .build
        nav.open("toggle")
        nav.goBack()
        #expect(nav.current.item == .search)
        #expect(nav.searchText == "toggle")
        #expect(nav.searchScope == .build)
    }

    @Test func eachAreaRemembersItsLastPage() {
        let nav = makeNavigator()
        nav.open("toggle")
        nav.open("app-sandbox")
        #expect(nav.lastPage(in: .build)?.id == "toggle")
        #expect(nav.lastPage(in: .ship)?.id == "app-sandbox")
        #expect(nav.lastPage(in: .design) == nil)
    }

    @Test func restoringAMissingPageFallsBackToItsHome() {
        let nav = makeNavigator()
        nav.restore(Location(item: .category(.controls), page: "no-such-page"))
        #expect(nav.current == Location(item: .area(.build)))
        #expect(!nav.canGoBack)
    }

    @Test func restoringSearchKeepsTheSidebarArea() throws {
        let nav = makeNavigator()
        nav.show(.area(.ship))
        nav.showSearch()
        let data = try JSONEncoder().encode(nav.saved)

        let relaunched = makeNavigator()
        let saved = try JSONDecoder().decode(SavedWindow.self, from: data)
        relaunched.restore(saved.location, shownArea: saved.shownArea)
        #expect(relaunched.current.item == .search)
        #expect(relaunched.shownArea == .ship)
    }

    @Test func locationsSurviveEncoding() throws {
        let location = Location(item: .category(.windows), page: "settings-scene")
        let data = try JSONEncoder().encode(location)
        #expect(try JSONDecoder().decode(Location.self, from: data) == location)
    }
}
