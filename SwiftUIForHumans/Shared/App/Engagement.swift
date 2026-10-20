import SwiftUI

/// Counts how much someone uses the app, on this device only, and decides
/// when to ask for a rating and when the buddy may peek out.
///
/// Nothing here leaves the device. The counts live in `UserDefaults`, which
/// the privacy manifest already declares.
///
/// The rules follow the HIG's ratings guidance and App Review 5.6.1:
/// - The rating uses Apple's own prompt, asked at a natural break (opening
///   a page, copying code, ticking a checklist item), never at launch, and
///   at most once per app version. The system also caps it at three times a
///   year and may not show it at all.
/// - The app can't know whether someone rated it, so the buddy's tip ask
///   only comes a while after the rating ask, never because of a rating.
@MainActor @Observable
final class Engagement {
    static let shared = Engagement()

    /// The buddy asks for tips, so it stays off in App Store builds until
    /// the tip products exist in App Store Connect. `-buddy` shows it anyway.
    static let isBuddyEnabled = false

    /// Bumped when it's a good moment for the system rating prompt.
    private(set) var reviewRequest = 0
    /// Whether the buddy is out.
    var isBuddyShown = false

    private let defaults = UserDefaults.standard

    private init() {
        recordActiveDay()
    }

    /// Every page opened on this device, for "read" marks.
    var viewedPages: Set<ComponentPage.ID> {
        Set(defaults.stringArray(forKey: Key.pages) ?? [])
    }

    // MARK: Events

    func recordPageView(_ id: ComponentPage.ID) {
        var pages = Set(defaults.stringArray(forKey: Key.pages) ?? [])
        pages.insert(id)
        defaults.set(Array(pages), forKey: Key.pages)
        considerAsking()
    }

    /// Copying code or ticking off a checklist item: a small success.
    func recordSuccess() {
        defaults.set(defaults.integer(forKey: Key.successes) + 1, forKey: Key.successes)
        considerAsking()
    }

    // MARK: Buddy answers

    /// The buddy tucked away without an answer, or "Maybe later".
    func buddyDismissed() {
        isBuddyShown = false
    }

    func buddyOptOut() {
        defaults.set(true, forKey: Key.buddyOptOut)
        isBuddyShown = false
    }

    func recordTip() {
        defaults.set(true, forKey: Key.hasTipped)
    }

    var hasTipped: Bool { defaults.bool(forKey: Key.hasTipped) }

    /// For `-buddy`: show the buddy now, whatever the counts say.
    func showBuddyForTesting() {
        isBuddyShown = true
    }

    // MARK: Rules

    private var pagesViewed: Int { defaults.stringArray(forKey: Key.pages)?.count ?? 0 }
    private var activeDays: Int { defaults.stringArray(forKey: Key.days)?.count ?? 0 }

    private func considerAsking() {
        if shouldRequestReview {
            defaults.set(AppInfo.shortVersion, forKey: Key.reviewVersion)
            defaults.set(Date.now, forKey: Key.reviewDate)
            reviewRequest += 1
        } else if shouldShowBuddy {
            defaults.set(defaults.integer(forKey: Key.buddyAsks) + 1, forKey: Key.buddyAsks)
            defaults.set(Date.now, forKey: Key.buddyDate)
            isBuddyShown = true
        }
    }

    /// Enough use to have an opinion: a dozen pages over three days, and not
    /// yet asked in this version.
    private var shouldRequestReview: Bool {
        pagesViewed >= 12
            && activeDays >= 3
            && defaults.string(forKey: Key.reviewVersion) != AppInfo.shortVersion
    }

    /// Regular use, at least a week after the rating ask, at most twice ever,
    /// a month apart, and never after a tip or "Don't ask again".
    private var shouldShowBuddy: Bool {
        guard Self.isBuddyEnabled, !isBuddyShown,
              !hasTipped, !defaults.bool(forKey: Key.buddyOptOut),
              defaults.integer(forKey: Key.buddyAsks) < 2,
              pagesViewed >= 20, activeDays >= 4
        else { return false }
        if let asked = defaults.object(forKey: Key.reviewDate) as? Date, asked > .now.addingTimeInterval(-7 * 86_400) {
            return false
        }
        if let shown = defaults.object(forKey: Key.buddyDate) as? Date, shown > .now.addingTimeInterval(-30 * 86_400) {
            return false
        }
        return true
    }

    private func recordActiveDay() {
        let today = Date.now.formatted(.iso8601.year().month().day())
        var days = Set(defaults.stringArray(forKey: Key.days) ?? [])
        guard days.insert(today).inserted else { return }
        defaults.set(Array(days), forKey: Key.days)
    }

    private enum Key {
        static let pages = "engagement.pages"
        static let days = "engagement.days"
        static let successes = "engagement.successes"
        static let reviewVersion = "engagement.reviewVersion"
        static let reviewDate = "engagement.reviewDate"
        static let buddyAsks = "engagement.buddyAsks"
        static let buddyDate = "engagement.buddyDate"
        static let buddyOptOut = "engagement.buddyOptOut"
        static let hasTipped = "engagement.hasTipped"
    }
}
