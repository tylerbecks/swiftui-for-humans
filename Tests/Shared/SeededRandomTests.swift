import Testing
@testable import SwiftUIForHumans

/// Wallpapers must look the same on every launch, so the generator has to
/// give the same numbers for the same seed, every time.
struct SeededRandomTests {
    @Test func sameSeedGivesSameSequence() {
        var first = SeededRandom("components")
        var second = SeededRandom("components")
        for _ in 0..<100 {
            #expect(first.next() == second.next())
        }
    }

    @Test func differentSeedsDiffer() {
        var components = SeededRandom("components")
        var design = SeededRandom("design")
        #expect(components.next() != design.next())
    }

    @Test func staysInUnitRange() {
        var random = SeededRandom("range")
        for _ in 0..<1_000 {
            let value = random.next()
            #expect(value >= 0 && value < 1)
        }
    }

    /// Pins the first value so a change to the algorithm, which would
    /// reshuffle every wallpaper, can't slip in unnoticed.
    @Test func firstValueIsStable() {
        var random = SeededRandom("components")
        #expect(random.next() == SeededRandomTests.firstComponentsValue)
    }

    static let firstComponentsValue = 0.9396178626202601
}
