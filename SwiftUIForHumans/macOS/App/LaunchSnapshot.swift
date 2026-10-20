#if DEBUG
import AppKit
import SwiftUI

/// `-snapshot` draws the app's main window into a PNG, writes it to standard
/// output as base64 between `BEGIN SNAPSHOT` and `END SNAPSHOT` lines, and
/// quits. `scripts/mac-shot.sh` uses it.
///
/// Why this way: screenshotting another app's window needs Screen Recording
/// permission, and the sandbox keeps the app's own files out of the shell's
/// reach, but an app can always draw itself. And an app launched from a
/// script isn't activated, so SwiftUI may not open its window at all; the
/// window here is the app's own, kept off screen so it never takes focus.
///
/// `-windowSize 1180x820` sets the window's size (make it tall, like
/// 1180x5000, to get a whole page in one picture: the snapshot can't show a
/// scrolled page), and `-snapshotDelay
/// <seconds>` waits longer for the page to settle. The other launch flags
/// (`-open`, `-tab`, `-showControls`, `-scrollTo`) work as usual.
@MainActor
enum LaunchSnapshot {
    private static var window: NSWindow?

    static var isRequested: Bool { LaunchOptions.isSet("-snapshot") }

    static func runIfRequested() {
        guard isRequested, window == nil else { return }
        let size = LaunchOptions.value(for: "-windowSize")?.split(separator: "x").compactMap { Double($0) } ?? []
        let frame = CGRect(x: -20_000, y: -20_000, width: size.first ?? 1180, height: size.last ?? 820)
        let window = SnapshotWindow(
            contentRect: frame,
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        let hosting = NSHostingView(rootView: MacContentView())
        hosting.sceneBridgingOptions = [.toolbars, .title]
        window.contentView = hosting
        window.setFrame(window.frameRect(forContentRect: frame), display: true)
        window.orderFrontRegardless()
        self.window = window

        let delay = Double(LaunchOptions.value(for: "-snapshotDelay") ?? "") ?? 3
        Task {
            try? await Task.sleep(for: .seconds(delay))
            let view = window.contentView?.superview ?? hosting
            view.layoutSubtreeIfNeeded()
            view.display()
            guard let rep = view.bitmapImageRepForCachingDisplay(in: view.bounds) else { exit(3) }
            view.cacheDisplay(in: view.bounds, to: rep)
            guard let png = rep.representation(using: .png, properties: [:]) else { exit(4) }
            let output = "BEGIN SNAPSHOT\n" + png.base64EncodedString(options: .lineLength76Characters) + "\nEND SNAPSHOT\n"
            FileHandle.standardOutput.write(Data(output.utf8))
            exit(0)
        }
    }
}
/// A window that may be taller than the screen, for whole-page snapshots.
private final class SnapshotWindow: NSWindow {
    override func constrainFrameRect(_ frameRect: NSRect, to screen: NSScreen?) -> NSRect {
        frameRect
    }
}
#endif
