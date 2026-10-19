import SwiftUI

extension ComponentPage {
    static let updatesOutsideStore = ComponentPage(
        id: "updates-outside-store",
        title: "Updates Outside the Store",
        summary: "Apps you distribute yourself deliver their own updates; Mac App Store apps must not.",
        category: .testAndRelease,
        kind: .reference,
        symbol: "arrow.triangle.2.circlepath",
        availability: [],
        docsURL: "https://developer.apple.com/macos/distribution/",
        aliases: [
            "updates", "auto-update", "software update", "Check for Updates", "updater", "update feed",
            "appcast", "direct distribution", "compilation condition", "SWIFT_ACTIVE_COMPILATION_CONDITIONS",
            "Guideline 2.4.5(vii)", "Guideline 2.4.5(iv)", "Guideline 2.5.2",
        ],
        related: ["developer-id-notarization", "hardened-runtime", "mac-app-review", "commands"],
        notes: [
            "**Store updates can install themselves.** People can opt in to always getting the latest version of Mac App Store apps automatically.",
            "**Every release goes through the same steps.** Sign each update with Developer ID, notarize it, and staple the ticket, just like the first version.",
        ],
        guidelines: [
            Guideline(
                "Leave Check for Updates out of the store build.",
                "Guideline 2.4.5(vii) says Mac App Store apps get updates only through the store, so the store build can't have an updater of its own.",
                good: "The store build's app menu, with no updater.",
                bad: "The same menu with Check for Updates…"
            ) {
                ShipMenuSketch(title: "Trips", rows: [
                    .item("About Trips"),
                    .separator,
                    .item("Settings…", shortcut: "⌘,"),
                    .separator,
                    .item("Quit Trips", shortcut: "⌘Q"),
                ], width: 200)
            } bad: {
                ShipMenuSketch(title: "Trips", rows: [
                    .item("About Trips"),
                    .item("Check for Updates…"),
                    .separator,
                    .item("Settings…", shortcut: "⌘,"),
                    .separator,
                    .item("Quit Trips", shortcut: "⌘Q"),
                ], width: 200)
            },
        ],
        sources: [
            "https://developer.apple.com/app-store/review/guidelines/#hardware-compatibility",
            "https://developer.apple.com/app-store/review/guidelines/#software-requirements",
            "https://developer.apple.com/macos/distribution/",
            "https://developer.apple.com/documentation/security/notarizing-macos-software-before-distribution",
            "https://developer.apple.com/documentation/xcode/build-settings-reference",
            "https://developer.apple.com/documentation/swiftui/commandgroup",
            "https://developer.apple.com/design/human-interface-guidelines/the-menu-bar",
        ],
        reviewed: "October 2026"
    ) {
        ShipThumbnail(symbol: "arrow.triangle.2.circlepath", caption: "Check for Updates…")
    } content: { page in
        MacUpdatesOutsideStoreArticle(page: page)
    }
}

// MARK: - Page

private struct MacUpdatesOutsideStoreArticle: View {
    let page: ComponentPage

    var body: some View {
        ArticlePage(page: page) {
            Prose("On the Mac App Store, Apple hosts your updates and delivers them. Outside it, Apple's own comparison puts software updates in your hands: you host each new version and get it to people.")

            SectionTitle("The rules on the store")
            ConnectFacts(rows: [
                ("2.4.5(vii)", "Mac App Store apps must use the Mac App Store for updates. Other update mechanisms aren't allowed."),
                ("2.4.5(iv)", "They can't download or install apps, code, or resources that add features or change the app from what App Review saw."),
                ("2.5.2", "Apps stay self-contained and don't download code that changes their features."),
            ])

            SectionTitle("One codebase, two builds")
            Prose("If you ship both ways, compile the updater only into the direct build. Add a flag like `DIRECT` to **Active Compilation Conditions** (`SWIFT_ACTIVE_COMPILATION_CONDITIONS`) in a build configuration you use only for Developer ID builds.")
            ExampleCard(
                title: "A Check for Updates command, direct builds only",
                caption: "`CommandGroup(after: .appInfo)` puts the item under About in the app menu. Wrapping the whole `.commands` in `#if DIRECT` keeps it out of the store build.",
                code: """
                @main
                struct TripsApp: App {
                    var body: some Scene {
                        WindowGroup {
                            ContentView()
                        }
                        #if DIRECT
                        .commands {
                            CommandGroup(after: .appInfo) {
                                CheckForUpdatesButton()
                            }
                        }
                        #endif
                    }
                }
                """,
                minHeight: 200
            ) {
                ShipMenuSketch(title: "Trips", rows: [
                    .item("About Trips"),
                    .item("Check for Updates…"),
                    .separator,
                    .item("Settings…", shortcut: "⌘,"),
                ])
            }

            SectionTitle("A simple update check")
            Prose("The smallest updater asks your server for the latest version and, if it's newer, sends people to your download page. Whatever downloads the new version, it must be signed with your Developer ID and notarized, like every Developer ID release.")
            ExampleCard(
                title: "Compare versions, then open the download page",
                caption: "Read your version from `CFBundleShortVersionString`, compare it with the server's using `.numeric`, and open the page with `openURL`.",
                code: """
                struct Release: Decodable {
                    let version: String
                    let downloadURL: URL
                }

                struct CheckForUpdatesButton: View {
                    @Environment(\\.openURL) private var openURL
                    @State private var isUpToDate = false

                    var body: some View {
                        Button("Check for Updates…") {
                            Task { await check() }
                        }
                        .alert("You're up to date.", isPresented: $isUpToDate) {}
                    }

                    func check() async {
                        let feed = URL(string: "https://example.com/trips/latest.json")!
                        guard let (data, _) = try? await URLSession.shared.data(from: feed),
                              let latest = try? JSONDecoder().decode(Release.self, from: data)
                        else { return }
                        let current = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0"
                        if current.compare(latest.version, options: .numeric) == .orderedAscending {
                            openURL(latest.downloadURL)
                        } else {
                            isUpToDate = true
                        }
                    }
                }
                """,
                minHeight: 200,
                aside: Aside(.note, "The preview compares two versions you type, without a network request.")
            ) {
                VersionCompareSample()
            }

            SectionTitle("Before you release an update")
                .id("checklist")
            Checklist(pageID: page.id, items: [
                ChecklistItem("store-build", "No updater in the Mac App Store build", "Check the app menu of the archive you submit."),
                ChecklistItem("version", "Version number raised", "So the update check sees a newer version."),
                ChecklistItem("signed", "Signed with Developer ID and notarized", "And the ticket stapled.", page: "developer-id-notarization"),
                ChecklistItem("feed", "The update feed points at the new download", "Update it after the download is live, not before."),
                ChecklistItem("old-version", "Tested from the previous version", "Install the last release and update it the way people will."),
            ])
        }
    }
}

// MARK: - Samples

private struct VersionCompareSample: View {
    @State private var current = "1.4"
    @State private var latest = "1.10"

    private var isNewer: Bool {
        current.compare(latest, options: .numeric) == .orderedAscending
    }

    var body: some View {
        VStack(spacing: 14) {
            Form {
                TextField("This version", text: $current)
                TextField("Server's latest", text: $latest)
            }
            .frame(width: 240)
            Label(
                isNewer ? "Update available: open the download page." : "You're up to date.",
                systemImage: isNewer ? "arrow.down.circle.fill" : "checkmark.circle.fill"
            )
            .foregroundStyle(isNewer ? Color.accentColor : .green)
            Text("1.10 is newer than 1.4 with `.numeric`; a plain string comparison gets it wrong.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 340)
        }
    }
}
