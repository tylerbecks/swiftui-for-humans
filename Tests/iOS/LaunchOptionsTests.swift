import Testing
@testable import SwiftUIForHumans

struct LaunchOptionsTests {
    let arguments = ["app", "-open", "button", "-showControls", "-tab"]

    @Test func readsAFlagsValue() {
        #expect(LaunchOptions.value(for: "-open", in: arguments) == "button")
    }

    @Test func ignoresAFlagWithNoValue() {
        #expect(LaunchOptions.value(for: "-tab", in: arguments) == nil)
    }

    @Test func ignoresMissingFlags() {
        #expect(LaunchOptions.value(for: "-search", in: arguments) == nil)
    }
}
