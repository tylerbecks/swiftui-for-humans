import Testing
@testable import SwiftUIForHumans

struct SearchQueryTests {
    @Test(arguments: ["2.1", "5.1.1(v)", "4", " 5.1 .1 "])
    func recognizesGuidelineNumbers(_ text: String) {
        #expect(SearchQuery.isGuidelineNumber(text))
    }

    @Test(arguments: ["button", "iOS 26", "2.1 sheet", ""])
    func rejectsOtherText(_ text: String) {
        #expect(!SearchQuery.isGuidelineNumber(text))
    }

    @Test func matchesGuidelineNumbersWholeOrAsParent() {
        let alias = "Guideline 5.1.1(v)"
        #expect(SearchQuery.alias(alias, matches: "5.1.1(v)"))
        #expect(SearchQuery.alias(alias, matches: "5.1"))
        #expect(SearchQuery.alias(alias, matches: "5"))
        #expect(!SearchQuery.alias(alias, matches: "1.1"))
        #expect(!SearchQuery.alias("Guideline 12.1", matches: "2.1"))
    }

    @Test func matchesPlainTextIgnoringCase() {
        #expect(SearchQuery.alias("Dropdown", matches: "drop"))
        #expect(!SearchQuery.alias("Dropdown", matches: "modal"))
    }
}
