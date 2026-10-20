import Foundation

/// Launch arguments used to open the app in a known state for screenshots:
/// `-tab <components|design|ship|search>`, `-open <page id>`,
/// `-search <text>`, `-showControls`, `-scrollTo <anchor>`, `-showScrubber`.
enum LaunchOptions {
    static func value(for flag: String, in arguments: [String] = ProcessInfo.processInfo.arguments) -> String? {
        guard let index = arguments.firstIndex(of: flag), index + 1 < arguments.count else { return nil }
        return arguments[index + 1]
    }

    static func isSet(_ flag: String) -> Bool {
        ProcessInfo.processInfo.arguments.contains(flag)
    }

    /// Flags that act on a page (`-showControls`, `-scrollTo`) apply to the
    /// first page that asks, not to every page opened after it.
    @MainActor private static var used: Set<String> = []

    /// Set once the first window has applied `-tab`, `-open`, and `-search`.
    @MainActor static var didApplyToWindow = false

    @MainActor static func take(_ flag: String) -> Bool {
        guard isSet(flag), !used.contains(flag) else { return false }
        used.insert(flag)
        return true
    }

    @MainActor static func takeValue(for flag: String) -> String? {
        guard let value = value(for: flag), take(flag) else { return nil }
        return value
    }

    /// Like `take`, but only for the page that `-open` names (any page when
    /// there's no `-open`). Pages restored in other tabs are built too, and
    /// shouldn't use up the flag first.
    @MainActor static func take(_ flag: String, page id: String) -> Bool {
        if let target = value(for: "-open"), target != id { return false }
        return take(flag)
    }

    @MainActor static func takeValue(for flag: String, page id: String) -> String? {
        if let target = value(for: "-open"), target != id { return nil }
        return takeValue(for: flag)
    }
}
