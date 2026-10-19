import SwiftUI

extension ComponentPage {
    static let testFlightMac = ComponentPage(
        id: "testflight-mac",
        title: "TestFlight for Mac",
        summary: "Send Mac builds to testers with TestFlight, the same way as iPhone builds.",
        category: .testAndRelease,
        kind: .reference,
        symbol: "airplane",
        availability: [],
        docsURL: "https://developer.apple.com/help/app-store-connect/test-a-beta-version/testflight-overview",
        aliases: [
            "TestFlight", "beta", "beta testing", "testers", "internal testers", "external testers",
            "public link", "Beta App Review", "build number", "Organizer", "Distribute App",
            "Guideline 2.2",
        ],
        related: ["universal-purchase", "mac-app-review", "developer-id-notarization", "app-sandbox"],
        notes: [
            "**Builds expire after 90 days.** Upload a new one before testers lose access.",
            "**Testers can send screenshots.** With TestFlight 2.3 or later on the Mac, testers send feedback from the TestFlight app or by taking a screenshot in your app.",
            "**Notarized builds are another option.** Apple also suggests giving testers an Apple-notarized build before you ship on the App Store.",
        ],
        sources: [
            "https://developer.apple.com/help/app-store-connect/test-a-beta-version/testflight-overview",
            "https://developer.apple.com/testflight/",
            "https://developer.apple.com/documentation/xcode/distributing-your-app-for-beta-testing-and-releases",
            "https://developer.apple.com/help/app-store-connect/manage-builds/upload-builds",
            "https://developer.apple.com/app-store/review/guidelines/#beta-testing",
        ],
        reviewed: "October 2026"
    ) {
        ShipThumbnail(symbol: "airplane", caption: "TestFlight for Mac")
    } content: { page in
        MacTestFlightArticle(page: page)
    }
}

// MARK: - Page

private struct MacTestFlightArticle: View {
    let page: ComponentPage
    @State private var group = TesterGroup.internal

    var body: some View {
        ArticlePage(page: page) {
            Prose("TestFlight works for Mac apps as it does on iPhone: upload a build, add testers, and they install it with the TestFlight app on their Mac. Build your Mac app with Xcode 13 or later.")
            Prose("Guideline **2.2** says demos and betas belong in TestFlight, not on the App Store, and a TestFlight build should be meant for public release and follow the guidelines.")

            ShipFlow(steps: [
                ("archivebox", "Archive"),
                ("icloud.and.arrow.up", "Upload"),
                ("person.2", "Add testers"),
                ("bubble.left.and.text.bubble.right", "Feedback"),
            ])
            .frame(maxWidth: .infinity)
            .padding(.vertical, 4)

            SectionTitle("Upload a Mac build")
            ConnectSteps(steps: [
                "In Xcode, choose **My Mac** as the run destination, then **Product > Archive**. A Catalyst app needs its own Mac archive.",
                "In the Organizer that opens, select the archive and click **Distribute App**.",
                "Choose **TestFlight & App Store**, or **TestFlight Internal Only** to keep the build to your team, then click **Distribute**.",
                "Wait for the email that says processing finished. The build then shows up in the TestFlight tab in App Store Connect.",
            ])
            Aside(.important, "Each upload needs a new build string; App Store Connect uses it to tell builds apart. Mac builds can have their own version and build numbers, separate from iOS.")

            SectionTitle("Testers")
            Picker("Testers", selection: $group) {
                ForEach(TesterGroup.allCases) { group in
                    Text(group.rawValue).tag(group)
                }
            }
            .pickerStyle(.segmented)
            .labelsHidden()
            .fixedSize()
            ConnectFacts(rows: group.facts)
                .id(group)

            SectionTitle("Set up the test")
            ConnectSteps(steps: [
                "In the **TestFlight** tab, add **Test Information**: a beta app description, what to test, and an email for feedback.",
                "Create a group and add the Mac build to it.",
                "Invite testers by email, or turn on a **public link**. You can limit who joins a public link, for example by device type and OS version.",
                "Testers install **TestFlight** on their Mac, accept the invitation, and install your app.",
                "Read feedback, crash reports, and screenshots in App Store Connect, filtered by platform if you like.",
            ])

            SectionTitle("Before you invite testers")
                .id("checklist")
            Checklist(pageID: page.id, items: [
                ChecklistItem("sandbox", "The build is sandboxed", "Test the same entitlements you'll ship.", page: "app-sandbox"),
                ChecklistItem("build-number", "A new build number", "Every upload needs its own."),
                ChecklistItem("test-info", "Test Information filled in", "Description, what to test, and a feedback email."),
                ChecklistItem("review-info", "Beta App Review information ready", "Required before external testers can join."),
                ChecklistItem("what-to-test", "What to Test says what changed", "Point testers at the Mac-specific features."),
            ])
        }
    }
}

private enum TesterGroup: String, CaseIterable, Identifiable {
    case `internal` = "Internal"
    case external = "External"

    var id: Self { self }

    var facts: [(label: String, value: String)] {
        switch self {
        case .internal:
            [
                ("Who", "Up to 100 members of your team with the Account Holder, Admin, App Manager, Developer, or Marketing role."),
                ("Review", "Only builds for external testers go to App Review. You can send new builds to internal testers automatically."),
                ("Devices", "Each tester can install on up to 30 devices."),
            ]
        case .external:
            [
                ("Who", "Up to 10,000 people, invited by email or a public link."),
                ("Review", "The first build added to a group goes to App Review. Later builds may not need a full review."),
                ("Before inviting", "A beta app description and Beta App Review information are required."),
            ]
        }
    }
}
