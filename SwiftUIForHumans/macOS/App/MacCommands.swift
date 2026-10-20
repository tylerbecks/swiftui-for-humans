import SwiftUI

/// The Mac's own menu items: About opens the app's About window, and the
/// Help menu links to support, privacy, and feedback.
struct MacCommands: Commands {
    @Environment(\.openWindow) private var openWindow
    @Environment(\.openURL) private var openURL

    var body: some Commands {
        CommandGroup(replacing: .appInfo) {
            Button("About \(AppInfo.name)") {
                openWindow(id: AboutWindow.id)
            }
        }
        CommandGroup(replacing: .help) {
            if let url = AppInfo.supportURL {
                Button("\(AppInfo.name) Support") { openURL(url) }
            }
            if let url = AppInfo.privacyPolicyURL {
                Button("Privacy Policy") { openURL(url) }
            }
            Divider()
            Button("Send Feedback…") {
                openURL(AppInfo.feedbackURL)
            }
        }
    }
}
