import SwiftUI

extension ComponentPage {
    static let developerIDNotarization = ComponentPage(
        id: "developer-id-notarization",
        title: "Developer ID & Notarization",
        summary: "Ship outside the Mac App Store: sign with Developer ID, notarize, and staple the ticket.",
        category: .testAndRelease,
        kind: .reference,
        symbol: "checkmark.seal",
        availability: [],
        docsURL: "https://developer.apple.com/documentation/security/notarizing-macos-software-before-distribution",
        aliases: [
            "Developer ID", "notarization", "notarize", "notarytool", "stapler", "staple", "Gatekeeper",
            "direct distribution", "outside the App Store", "DMG", "disk image", "zip", "pkg",
            "Developer ID Application", "secure timestamp", "get-task-allow", "altool",
        ],
        related: ["hardened-runtime", "updates-outside-store", "app-sandbox", "testflight-mac"],
        notes: [
            "**Notarization isn't App Review.** It's an automated scan for malicious content and code signing problems. Most uploads finish within 5 minutes, and 98% within 15.",
            "**It protects you too.** If your Developer ID key leaks, Apple can revoke the tickets for versions you didn't make.",
            "**`altool` no longer works.** Since November 1, 2023, the notary service accepts uploads only from `notarytool` or Xcode 14 and later.",
        ],
        sources: [
            "https://developer.apple.com/developer-id/",
            "https://developer.apple.com/macos/distribution/",
            "https://developer.apple.com/documentation/security/notarizing-macos-software-before-distribution",
            "https://developer.apple.com/documentation/security/customizing-the-notarization-workflow",
            "https://developer.apple.com/documentation/security/resolving-common-notarization-issues",
            "https://developer.apple.com/documentation/xcode/distributing-your-app-for-beta-testing-and-releases",
            "https://developer.apple.com/design/human-interface-guidelines/privacy",
        ],
        reviewed: "October 2026"
    ) {
        ShipThumbnail(symbol: "checkmark.seal", caption: "Developer ID")
    } content: { page in
        MacDeveloperIDArticle(page: page)
    }
}

// MARK: - Page

private struct MacDeveloperIDArticle: View {
    let page: ComponentPage

    var body: some View {
        ArticlePage(page: page) {
            Prose("You can sell or give away a Mac app from your own website. Gatekeeper checks apps from outside the Mac App Store for a **Developer ID** signature, and since macOS 10.15, Developer ID software built after June 1, 2019 must also be **notarized** by Apple to run.")

            ShipFlow(steps: [
                ("archivebox", "Archive"),
                ("signature", "Sign with Developer ID"),
                ("checkmark.shield", "Notarize"),
                ("paperclip", "Staple"),
                ("arrow.down.circle", "Distribute"),
            ])
            .frame(maxWidth: .infinity)
            .padding(.vertical, 4)

            SectionTitle("Store or direct")
            ConnectFacts(rows: [
                ("App Sandbox", "Required on the Mac App Store. Recommended outside it."),
                ("Hosting and updates", "Apple hosts App Store apps and their updates. Outside, you host both."),
                ("In-App Purchase and Game Center", "Available only on the Mac App Store."),
                ("Payments and support", "On the store, Apple processes payments and supports customers with billing and downloads. Outside, both are yours."),
                ("Notarization", "Required outside the store. Not needed for the store, whose submission does equivalent checks."),
            ])

            SectionTitle("What the notary service needs")
            ConnectFacts(rows: [
                ("Signed code", "Every executable you ship has a valid code signature."),
                ("A Developer ID certificate", "Developer ID Application, or Developer ID Installer for packages. Not a Mac Distribution or development certificate. Only the Account Holder can create one."),
                ("Hardened Runtime", "Turned on for your app and command-line targets. See [Hardened Runtime](catalog://hardened-runtime)."),
                ("A secure timestamp", "Xcode's distribution workflow adds it for you."),
                ("No get-task-allow", "`com.apple.security.get-task-allow` must not be true. Xcode strips it when you export."),
            ])

            SectionTitle("The easy way: Xcode")
            ConnectSteps(steps: [
                "Choose **Product > Archive**. The Organizer opens with your archive selected.",
                "Click **Distribute App** and choose **Direct Distribution**, or **Custom** then **Developer ID**.",
                "Choose to **upload** to the notary service. Scanning usually takes less than an hour.",
                "When it's done, Xcode staples the ticket to your archive. **Export** it to get the app to ship.",
            ])

            SectionTitle("From the command line")
            Prose("Scripts and CI use `notarytool` and `stapler`, both included with Xcode. You can't upload an `.app` directly: zip it, or use a disk image or flat installer package.")
            CodeBlock(code: """
            # Once: save an app-specific password to the keychain
            xcrun notarytool store-credentials "notary" \\
                --apple-id "you@example.com" --team-id "TEAMID" \\
                --password "app-specific-password"

            # Zip the exported app and submit it
            ditto -c -k --keepParent "Trips.app" "Trips.zip"
            xcrun notarytool submit "Trips.zip" --keychain-profile "notary" --wait

            # If it fails, read the log
            xcrun notarytool log <submission-id> --keychain-profile "notary"

            # Staple the ticket to the app, then zip it again to ship
            xcrun stapler staple "Trips.app"
            """)
            Aside(.important, "You can't staple a ticket to a zip file. Staple the app inside, then make a new zip. Disk images and installer packages can be stapled directly.")
            Aside(.note, "Gatekeeper also finds the ticket online, but stapling lets it check without a network connection.")

            SectionTitle("Before you ship")
                .id("checklist")
            Checklist(pageID: page.id, items: [
                ChecklistItem("certificate", "Signed with a Developer ID certificate", "Not Mac Distribution or Apple Development."),
                ChecklistItem("runtime", "Hardened Runtime on", "With only the exceptions you need.", page: "hardened-runtime"),
                ChecklistItem("accepted", "Notarization status is Accepted", "And the log has no warnings worth fixing."),
                ChecklistItem("stapled", "Ticket stapled", "To the app, disk image, or package you ship."),
                ChecklistItem("test-download", "Tested like a customer", "Download it on another Mac and open it."),
                ChecklistItem("updates", "An update path", "Every update needs signing and notarizing too.", page: "updates-outside-store"),
            ])
        }
    }
}
