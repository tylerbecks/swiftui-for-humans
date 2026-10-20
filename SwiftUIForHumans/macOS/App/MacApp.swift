import SwiftUI

@main
struct SwiftUIForHumansMacApp: App {
    @NSApplicationDelegateAdaptor private var appDelegate: MacAppDelegate

    var body: some Scene {
        // "Open in New Window" opens a page in a window of its own. The
        // app's first window has no page and restores its last one.
        WindowGroup(for: ComponentPage.ID.self) { $pageID in
            #if DEBUG
            // A snapshot draws its own window; this one stays empty so it
            // doesn't use up the launch flags first.
            if LaunchSnapshot.isRequested {
                Color.clear
            } else {
                MacContentView(windowPage: pageID)
            }
            #else
            MacContentView(windowPage: pageID)
            #endif
        }
        .defaultSize(width: 1180, height: 820)
        .commands {
            CatalogCommands()
            MacCommands()
        }

        Settings {
            SettingsView()
        }

        Window("About \(AppInfo.name)", id: AboutWindow.id) {
            AboutView()
                .frame(width: 440, height: 560)
        }
        .windowResizability(.contentSize)
        .defaultPosition(.center)

        // Real windows that pages open for their demos.
        WindowGroup(id: DemoWindow.sceneID, for: DemoWindow.ID.self) { $id in
            DemoWindowRoot(id: id)
        }
        // The window fits its content: each demo opens at its own size
        // (`DemoWindow.size`, see `DemoWindowRoot`), then can be resized.
        .windowResizability(.contentMinSize)
    }
}

enum AboutWindow {
    static let id = "about"
}

/// Launch-time setup that has to happen before any window draws.
final class MacAppDelegate: NSObject, NSApplicationDelegate {
    /// `-appearance light` or `-appearance dark` sets the whole app's look,
    /// for screenshots. Without it the app follows the system.
    func applicationWillFinishLaunching(_ notification: Notification) {
        switch LaunchOptions.value(for: "-appearance") {
        case "dark": NSApp.appearance = NSAppearance(named: .darkAqua)
        case "light": NSApp.appearance = NSAppearance(named: .aqua)
        default: break
        }
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        #if DEBUG
        LaunchSnapshot.runIfRequested()
        #endif
    }
}
