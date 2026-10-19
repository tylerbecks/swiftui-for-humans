import SwiftUI

extension ComponentPage {
    static let patternLaunching = ComponentPage(
        id: "launching",
        title: "Launching",
        summary: "Open fast, look like your first screen, and pick up where people left off.",
        category: .patterns,
        kind: .concept,
        symbol: "power",
        availability: ["iOS 14.0+"],
        docsURL: "https://developer.apple.com/documentation/xcode/specifying-your-apps-launch-screen",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/launching",
        aliases: ["launch screen", "splash screen", "LaunchScreen.storyboard", "UILaunchScreen", "app startup", "app launch", "cold start", "startup time", "state restoration", "restore state", "SceneStorage", "first paint"],
        related: ["onboarding", "loading", "requesting-permission", "tab-view", "lifecycle"],
        notes: [
            "**The launch screen isn't SwiftUI.** It's an Info.plist entry or a storyboard that the system draws before any of your code runs, so it can't animate or show live data.",
            "**Slow launches get killed.** On iOS, the system's watchdog ends an app that takes too long to launch. Move work out of `init` and into `.task`.",
            "**Every app needs one.** As of iOS 27 and iPadOS 27, Apple's technote TN3192 says a launch screen is required for App Store submission.",
            "**`@SceneStorage` is for small UI state.** Keep model data and anything sensitive out of it. It's also gone if people close the window or remove it from the app switcher.",
        ],
        api: [
            APIItem("`UILaunchScreen`", "Info.plist launch screen: color, image, bars."),
            APIItem("`UILaunchStoryboardName`", "A storyboard launch screen instead."),
            APIItem("`@SceneStorage`", "Restores small UI state per window."),
            APIItem("`.task { }`", "Starts loading after the first frame."),
            APIItem("`@Environment(\\.scenePhase)`", "Tells you when the app goes inactive."),
        ],
        guidelines: [
            Guideline(
                "Make the launch screen match your first screen.",
                "Use the same background and bars, without the content. It makes the app feel ready at once, with no flash when your real screen appears.",
                good: "Just the first screen's frame.",
                bad: "A branded splash with text."
            ) {
                LaunchMiniScreen(isSplash: false)
            } bad: {
                LaunchMiniScreen(isSplash: true)
            },
            Guideline(
                "Leave out text and logos.",
                "The launch screen can't be localized, and it isn't a branding spot. Show a logo only if it's a fixed part of your first screen."
            ),
            Guideline(
                "Launch instantly; no splash delays.",
                "People want to start right away. If you need a splash, show it as the first step of [onboarding](catalog://onboarding), not as a timer on every launch."
            ),
            Guideline(
                "Restore where people left off.",
                "Reopen the same tab, screen, and scroll position, so nobody has to retrace their steps."
            ),
            Guideline(
                "Don't greet people with an alert or a prompt.",
                "Show problems, like being offline, inside the screen, and ask for [permissions](catalog://requesting-permission) when a feature needs them."
            ),
        ],
        sources: [
            "https://developer.apple.com/design/human-interface-guidelines/launching",
            "https://developer.apple.com/design/human-interface-guidelines/alerts",
            "https://developer.apple.com/documentation/xcode/specifying-your-apps-launch-screen",
            "https://developer.apple.com/documentation/bundleresources/information-property-list/uilaunchscreen",
            "https://developer.apple.com/documentation/xcode/reducing-your-app-s-launch-time",
            "https://developer.apple.com/documentation/swiftui/scenestorage",
            "https://developer.apple.com/documentation/swiftui/restoring-your-app-s-state-with-swiftui",
            "https://developer.apple.com/documentation/technotes/tn3192-migrating-your-app-from-the-deprecated-uirequiresfullscreen-key",
        ],
        reviewed: "October 2026"
    ) {
        LaunchThumbnail()
    } content: { page in
        LaunchingArticle(page: page)
    }
}

// MARK: - Article

private struct LaunchingArticle: View {
    let page: ComponentPage

    var body: some View {
        ArticlePage(page: page) {
            Prose("Launching runs from the tap on your icon until your first screen is ready. iOS shows your launch screen instantly, then swaps in your first screen. The goal is for that swap to go unnoticed: a launch screen that looks like the app, a first screen that shows up fast, and the same place people left.")

            VStack(alignment: .leading, spacing: 28) {
                SectionTitle("In SwiftUI")

                ExampleCard(
                    title: "A launch screen in Info.plist",
                    caption: "Add a `UILaunchScreen` dictionary with your background color and the bars your first screen has.",
                    code: """
                    <!-- Info.plist -->
                    <key>UILaunchScreen</key>
                    <dict>
                        <key>UIColorName</key>
                        <string>LaunchBackground</string>
                        <key>UINavigationBar</key>
                        <dict/>
                        <key>UITabBar</key>
                        <dict/>
                    </dict>
                    """,
                    minHeight: 280,
                    aside: Aside(.note, "`UIColorName` names a color in your asset catalog. Leave it out and the system uses the standard background, which follows light and dark mode.")
                ) {
                    HStack(spacing: 16) {
                        VStack(spacing: 8) {
                            LaunchFrame(showsContent: false)
                            Text("Launch screen").font(.caption).foregroundStyle(.secondary)
                        }
                        Image(systemName: "arrow.right").foregroundStyle(.tertiary)
                        VStack(spacing: 8) {
                            LaunchFrame(showsContent: true)
                            Text("First screen").font(.caption).foregroundStyle(.secondary)
                        }
                    }
                }

                ExampleCard(
                    title: "Restore the last tab",
                    caption: "Use `@SceneStorage` instead of `@State` for the selected tab, and SwiftUI brings it back on the next launch.",
                    code: """
                    @SceneStorage("selectedTab") private var selectedTab = "today"

                    TabView(selection: $selectedTab) {
                        Tab("Today", systemImage: "sun.max", value: "today") {
                            Text("Today")
                        }
                        Tab("Library", systemImage: "books.vertical", value: "library") {
                            Text("Library")
                        }
                    }
                    """,
                    minHeight: 340,
                    aside: Aside(.note, "Try it: pick Library, quit this app from the app switcher, and open it again. This catalog restores your tab and page the same way.")
                ) {
                    LaunchRestoreExample()
                }

                ExampleCard(
                    title: "Show the screen, then load",
                    caption: "Draw the first screen right away and start slow work in `.task`, with [placeholders](catalog://loading) while it runs.",
                    code: """
                    struct ExpensesScreen: View {
                        @State private var expenses: [String] = []
                        @State private var isLoading = true

                        var body: some View {
                            List(isLoading ? ["Placeholder row", "Placeholder row"] : expenses, id: \\.self) {
                                Text($0)
                            }
                            .redacted(reason: isLoading ? .placeholder : [])
                            .task {
                                // Not in init: the screen is already on display.
                                try? await Task.sleep(for: .seconds(1))
                                expenses = ["Lunch", "Train ticket"]
                                isLoading = false
                            }
                        }
                    }
                    """,
                    minHeight: 200
                ) {
                    LaunchLoadExample()
                }
            }
        }
    }
}

// MARK: - Examples

/// A small frame with a navigation bar and tab bar, empty or filled.
private struct LaunchFrame: View {
    let showsContent: Bool

    var body: some View {
        PatternMiniScreen(width: 110, height: 200) {
            VStack(spacing: 0) {
                Rectangle().fill(.bar).frame(height: 30)
                VStack(alignment: .leading, spacing: 8) {
                    if showsContent {
                        Text("Today").font(.caption.bold())
                        ForEach(0..<4, id: \.self) { _ in
                            RoundedRectangle(cornerRadius: 4).fill(.fill.secondary).frame(height: 14)
                        }
                    }
                    Spacer()
                }
                .padding(8)
                .frame(maxWidth: .infinity, alignment: .leading)
                HStack {
                    ForEach(0..<3, id: \.self) { index in
                        Circle()
                            .fill(showsContent && index == 0 ? AnyShapeStyle(.tint) : AnyShapeStyle(.tertiary))
                            .frame(width: 10, height: 10)
                            .frame(maxWidth: .infinity)
                    }
                }
                .frame(height: 30)
                .background(.bar)
            }
        }
    }
}

private struct LaunchRestoreExample: View {
    @SceneStorage("patterns.launching.tab") private var selectedTab = "today"

    var body: some View {
        DeviceFrame(width: 260, height: 300) {
            TabView(selection: $selectedTab) {
                Tab("Today", systemImage: "sun.max", value: "today") {
                    Text("Today").font(.title2.bold())
                }
                Tab("Library", systemImage: "books.vertical", value: "library") {
                    Text("Library").font(.title2.bold())
                }
            }
        }
    }
}

private struct LaunchLoadExample: View {
    @State private var expenses: [String] = []
    @State private var isLoading = true
    @State private var run = 0

    var body: some View {
        VStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 10) {
                ForEach(isLoading ? ["Placeholder row", "Placeholder row"] : expenses, id: \.self) {
                    Text($0).frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(12)
            .background(.background.secondary, in: .rect(cornerRadius: 12))
            .redacted(reason: isLoading ? .placeholder : [])
            .animation(.default, value: isLoading)

            Button("Launch Again", systemImage: "arrow.clockwise") { run += 1 }
                .buttonStyle(.bordered)
                .disabled(isLoading)
        }
        .frame(maxWidth: 280)
        .task(id: run) {
            isLoading = true
            do { try await Task.sleep(for: .seconds(1)) } catch { return }
            expenses = ["Lunch", "Train ticket"]
            isLoading = false
        }
    }
}

// MARK: - Do / Don't

private struct LaunchMiniScreen: View {
    let isSplash: Bool

    var body: some View {
        if isSplash {
            PatternMiniScreen(width: 120, height: 210) {
                VStack(spacing: 8) {
                    Image(systemName: "dollarsign.circle.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(.white)
                    Text("Expenses").font(.headline).foregroundStyle(.white)
                    Text("Track every dollar").font(.caption2).foregroundStyle(.white.opacity(0.8))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.indigo.gradient)
            }
        } else {
            LaunchFrame(showsContent: false)
        }
    }
}

// MARK: - Thumbnail

private struct LaunchThumbnail: View {
    var body: some View {
        HStack(spacing: 12) {
            LaunchFrame(showsContent: false)
                .scaleEffect(0.6)
                .frame(width: 70, height: 125)
            Image(systemName: "arrow.right").foregroundStyle(.tertiary)
            LaunchFrame(showsContent: true)
                .scaleEffect(0.6)
                .frame(width: 70, height: 125)
        }
    }
}
