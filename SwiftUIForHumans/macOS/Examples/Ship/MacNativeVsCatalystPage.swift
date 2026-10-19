import SwiftUI

extension ComponentPage {
    static let nativeVsCatalyst = ComponentPage(
        id: "native-vs-catalyst",
        title: "Native, Catalyst, or iPad App",
        summary: "Three ways onto the Mac: a native macOS app, Mac Catalyst, or your iPad app as it is.",
        category: .startHere,
        kind: .concept,
        symbol: "macbook.and.ipad",
        availability: [],
        docsURL: "https://developer.apple.com/documentation/xcode/configuring-a-multiplatform-app-target",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/designing-for-macos",
        aliases: [
            "Mac Catalyst", "Catalyst", "UIKit for Mac", "Designed for iPad", "iPad app on Mac",
            "iOS apps on Mac", "Apple silicon", "multiplatform", "supported destinations",
            "port to Mac", "AppKit", "native Mac app", "Scale Interface to Match iPad",
            "Optimize Interface for Mac", "isiOSAppOnMac",
        ],
        related: ["great-mac-app", "ipad-app-in-window", "universal-purchase", "app-sandbox"],
        notes: [
            "**Your iPad app may already be on the Mac App Store.** Apple offers compatible iPhone and iPad apps on Macs with Apple silicon unless you turn that off in App Store Connect.",
            "**A native Mac app replaces it.** If your iPad app is on the Mac App Store and you add the macOS platform, releasing the Mac app takes its place, and existing users move to the Mac app.",
            "**Catalyst adds the sandbox for you.** Turning on Mac Catalyst adds the App Sandbox entitlement to the Mac build only.",
        ],
        guidelines: [
            Guideline(
                "Check that your app makes sense on a Mac.",
                "Apps built around a gyroscope, accelerometer, rear camera, HealthKit, or ARKit, or around handwriting or turn-by-turn navigation, may not suit the Mac at all."
            ),
            Guideline(
                "Don't offer two versions on the Mac.",
                "Apple lists an existing Mac version, built with AppKit or Catalyst, as a reason to stop offering your iPad app on the Mac."
            ),
            Guideline(
                "Whichever path you pick, design for the Mac.",
                "Even with Catalyst, Apple says to go beyond showing your iPad layout in a Mac window: menus, toolbars, and resizable windows are what people expect."
            ),
        ],
        sources: [
            "https://developer.apple.com/documentation/xcode/configuring-a-multiplatform-app-target",
            "https://developer.apple.com/documentation/uikit/mac-catalyst",
            "https://developer.apple.com/documentation/uikit/creating-a-mac-version-of-your-ipad-app",
            "https://developer.apple.com/documentation/uikit/choosing-a-user-interface-idiom-for-your-mac-app",
            "https://developer.apple.com/documentation/apple-silicon/running-your-ios-apps-in-macos",
            "https://developer.apple.com/design/human-interface-guidelines/mac-catalyst",
            "https://developer.apple.com/design/human-interface-guidelines/designing-for-macos",
            "https://developer.apple.com/help/app-store-connect/manage-your-apps-availability/manage-availability-of-iphone-and-ipad-apps-on-macs-with-apple-silicon",
            "https://developer.apple.com/help/app-store-connect/create-an-app-record/add-platforms",
        ],
        reviewed: "October 2026"
    ) {
        HStack(spacing: 14) {
            ForEach(MacPath.allCases) { path in
                VStack(spacing: 6) {
                    Image(systemName: path.symbol)
                        .font(.title)
                        .foregroundStyle(.tint)
                    Text(path.shortTitle)
                        .font(.caption2.weight(.semibold))
                }
            }
        }
    } content: { page in
        MacNativeVsCatalystArticle(page: page)
    }
}

// MARK: - Page

private struct MacNativeVsCatalystArticle: View {
    let page: ComponentPage
    @State private var path = MacPath.native

    var body: some View {
        ArticlePage(page: page) {
            Prose("In Xcode, an app target's **Supported Destinations** offers three kinds of Mac destination. Each one is a different way to get onto the Mac, with different work and a different result.")

            SectionTitle("Compare the three")
            Picker("Destination", selection: $path) {
                ForEach(MacPath.allCases) { path in
                    Text(path.title).tag(path)
                }
            }
            .pickerStyle(.segmented)
            .labelsHidden()
            .frame(maxWidth: 460)
            ConnectFacts(rows: path.facts)
                .id(path)

            SectionTitle("Which one to pick")
            ConnectFacts(rows: [
                ("Your app is SwiftUI, or it's new", "**Mac.** Apple suggests one multiplatform target when you use SwiftUI on both platforms. You get every macOS API, and the controls are real Mac controls."),
                ("You have a large UIKit iPad app", "**Mac Catalyst.** You keep one codebase and build it for the Mac, then adjust menus, toolbars, and layout."),
                ("You want something on the Mac today", "**Designed for iPad.** No porting at all, but it only runs on Macs with Apple silicon and keeps the iPad's look."),
                ("UIKit on iPad, AppKit on the Mac", "**Mac**, in its own target. Apple suggests separate targets when the two apps share little code."),
            ])

            SectionTitle("One SwiftUI app, both platforms")
            ExampleCard(
                title: "Add Mac-only scenes",
                caption: "In a multiplatform target, one `App` serves iPhone, iPad, and Mac. Wrap Mac-only scenes like `Settings` in `#if os(macOS)`.",
                code: """
                @main
                struct TripsApp: App {
                    var body: some Scene {
                        WindowGroup {
                            ContentView()
                        }
                        #if os(macOS)
                        Settings {
                            SettingsView()
                        }
                        #endif
                    }
                }
                """,
                minHeight: 200,
                aside: Aside(.note, "Apple's own example adds a `MenuBarExtra` the same way. Use `#if canImport(ARKit)` for a framework the Mac doesn't have.")
            ) {
                HStack(alignment: .bottom, spacing: 18) {
                    MacWindowFrame(title: "Trips", width: 220, height: 130) {
                        Label("Lisbon", systemImage: "airplane")
                            .foregroundStyle(.secondary)
                    }
                    MacWindowFrame(title: "Settings", width: 180, height: 100) {
                        Toggle("Sync", isOn: .constant(true))
                            .toggleStyle(.checkbox)
                            .font(.caption)
                    }
                }
            }

            SectionTitle("Catalyst's two looks")
            Prose("A Catalyst app starts with **Scale Interface to Match iPad**: iPad views and text shrink to 77%, so 17-point body text shows at 13 points. Switch to **Optimize Interface for Mac** for full-size text, sharper artwork, and controls that look and behave like AppKit's, then plan time to fix the layout.")
            Aside(.important, "In the Mac idiom, a few UIKit controls change or go away. `UIPageControl` isn't available, and showing it throws an exception.")
        }
    }
}

// MARK: - Data

private enum MacPath: String, CaseIterable, Identifiable {
    case native, catalyst, iPad

    var id: Self { self }

    var title: String {
        switch self {
        case .native: "Mac"
        case .catalyst: "Mac Catalyst"
        case .iPad: "Designed for iPad"
        }
    }

    var shortTitle: String {
        switch self {
        case .native: "Mac"
        case .catalyst: "Catalyst"
        case .iPad: "iPad"
        }
    }

    var symbol: String {
        switch self {
        case .native: "macbook"
        case .catalyst: "macbook.and.ipad"
        case .iPad: "ipad.landscape"
        }
    }

    var facts: [(label: String, value: String)] {
        switch self {
        case .native:
            [
                ("What it is", "A new Mac app built against the macOS SDK. It's the default Mac destination for multiplatform apps."),
                ("Built with", "SwiftUI and AppKit, with every macOS API available."),
                ("Looks like", "A Mac app: checkboxes, pop-up buttons, the menu bar, and Mac sizes."),
                ("App Store", "Add the macOS platform to your app record to sell it with your iOS app as one purchase."),
            ]
        case .catalyst:
            [
                ("What it is", "Your iPad app, built for the Mac from the same project and source code."),
                ("Built with", "UIKit, plus only the AppKit APIs marked available in Mac Catalyst."),
                ("Looks like", "Standard UIKit elements take on a Mac appearance. You choose the iPad or Mac idiom."),
                ("Runs on", "Macs with Apple silicon and Intel-based Macs."),
            ]
        case .iPad:
            [
                ("What it is", "Your unmodified iPhone or iPad app, running as is. There's nothing to port or recompile."),
                ("Built with", "Whatever your iOS app uses. Standard UIKit elements keep their iPad appearance."),
                ("Runs on", "Macs with Apple silicon running macOS 11 or later, from the Mac App Store."),
                ("App Store", "On by default. Opt out in App Store Connect under Pricing and Availability."),
            ]
        }
    }
}
