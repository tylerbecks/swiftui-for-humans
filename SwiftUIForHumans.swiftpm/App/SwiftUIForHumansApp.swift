import SwiftUI

@main
struct SwiftUIForHumansApp: App {
    var body: some Scene {
        // On iPad, "Open in New Window" opens a page in a window of its own.
        // The app's first window has no page and restores its last one.
        WindowGroup(for: ComponentPage.ID.self) { $pageID in
            ContentView(windowPage: pageID)
        }
        .commands {
            CatalogCommands()
        }
    }
}
