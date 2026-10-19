import Foundation
import Testing
@testable import SwiftUIForHumans

/// The in-app browser may only show Apple's sites; anything wider would
/// raise the App Store age rating.
struct AppleSitesTests {
    @Test(arguments: [
        "https://developer.apple.com/documentation/swiftui",
        "https://www.apple.com",
        "https://apple.com",
        "https://swift.org/documentation",
    ])
    func allowsAppleSites(_ link: String) throws {
        #expect(AppleSites.contains(try #require(URL(string: link))))
    }

    @Test(arguments: [
        "https://notapple.com",
        "https://apple.com.example.com",
        "https://example.com/apple.com",
        "ftp://developer.apple.com",
        "mailto:hello@apple.com",
    ])
    func blocksEverythingElse(_ link: String) throws {
        #expect(!AppleSites.contains(try #require(URL(string: link))))
    }
}
