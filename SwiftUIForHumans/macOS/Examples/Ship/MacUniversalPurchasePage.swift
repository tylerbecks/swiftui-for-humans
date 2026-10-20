import SwiftUI

extension ComponentPage {
    static let universalPurchase = ComponentPage(
        id: "universal-purchase",
        title: "Universal Purchase",
        summary: "One App Store listing and one purchase for your iPhone, iPad, and Mac apps.",
        category: .appStoreConnect,
        kind: .reference,
        symbol: "apps.iphone.badge.plus",
        availability: [],
        docsURL: "https://developer.apple.com/help/app-store-connect/create-an-app-record/add-platforms",
        aliases: [
            "universal purchase", "add platform", "macOS platform", "same bundle ID", "bundle identifier",
            "one listing", "cross-platform purchase", "app record", "multiplatform", "Mac App Store and App Store",
        ],
        related: ["native-vs-catalyst", "mac-screenshots", "pricing-category", "testflight-mac", "privacy-permissions"],
        notes: [
            "**In-app purchases come along.** Universal Purchase lets people use your app and its in-app purchases on every platform after one purchase.",
            "**App Privacy answers are shared.** They're set once for the app record, so cover what every platform collects.",
            "**It's permanent.** Once two platform versions are approved, the app stays a universal purchase, and you can't remove a platform from the record.",
        ],
        sources: [
            "https://developer.apple.com/help/app-store-connect/create-an-app-record/add-platforms",
            "https://developer.apple.com/help/app-store-connect/manage-your-apps-availability/manage-availability-of-iphone-and-ipad-apps-on-macs-with-apple-silicon",
            "https://developer.apple.com/help/app-store-connect/manage-builds/upload-builds",
            "https://developer.apple.com/help/app-store-connect/manage-app-information/manage-app-privacy",
            "https://developer.apple.com/documentation/xcode/configuring-a-multiplatform-app-target",
            "https://developer.apple.com/documentation/xcode/distributing-your-app-for-beta-testing-and-releases",
        ],
        reviewed: "October 2026"
    ) {
        RecordDiagram(isCompact: true)
    } content: { page in
        MacUniversalPurchaseArticle(page: page)
    }
}

// MARK: - Page

private struct MacUniversalPurchaseArticle: View {
    let page: ComponentPage

    var body: some View {
        ArticlePage(page: page) {
            Prose("With Universal Purchase, your iOS and Mac apps live in one app record in App Store Connect. People buy once and get both, with one product page. You set it up by adding the **macOS** platform to your existing iOS app.")

            RecordDiagram(isCompact: false)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)

            SectionTitle("What has to match")
            ConnectFacts(rows: [
                ("Bundle ID", "**The same** as the iOS app's. The macOS version also shares its Apple ID (the app identifier) and SKU."),
                ("Version and build", "**Can differ.** The Mac app has its own version number and build string."),
                ("Mac Catalyst apps", "Supported when built with Xcode 11.4 or later."),
                ("Separate records", "Can't be merged. Keep one, remove the others from sale, and add their platforms to the one you kept."),
            ])
            Aside(.important, "Removing an app from sale makes its product page unavailable. You can't update it for existing users, and its ratings and reviews don't move to the new page.")

            SectionTitle("Add the macOS platform")
            ConnectSteps(steps: [
                "In App Store Connect, open **Apps** and select your iOS app. You need the Account Holder, Admin, or App Manager role.",
                "Click **Add Platform** in the sidebar.",
                "Choose **macOS** and click **Add**. A macOS version 1.0 appears in the sidebar; change the number under App Information if you like.",
                "Fill in the Mac version's metadata. Everything carries over from iOS except the **promotional text**, **description**, and **screenshots**.",
                "In Xcode, set the Mac target's bundle ID to the iOS app's, then archive and upload the Mac build.",
                "Submit the Mac version for review. Once App Review approves both platforms, the app is a universal purchase.",
            ])

            SectionTitle("The same bundle ID in Xcode")
            Prose("Whether the Mac app is its own target or a destination in a multiplatform target, check the bundle ID it builds with. In build settings:")
            CodeBlock(code: """
            // iOS target
            PRODUCT_BUNDLE_IDENTIFIER = com.example.trips
            MARKETING_VERSION = 2.4

            // Mac target: same ID, its own version
            PRODUCT_BUNDLE_IDENTIFIER = com.example.trips
            MARKETING_VERSION = 1.0
            """)

            SectionTitle("If your iPad app is already on the Mac")
            Prose("Apple offers compatible iPhone and iPad apps on Macs with Apple silicon. When you add the macOS platform and release the Mac app, it **replaces** the iOS app on the Mac App Store, and existing users of the iOS app are updated to the Mac app.")

            SectionTitle("Before you submit")
                .id("checklist")
            Checklist(pageID: page.id, items: [
                ChecklistItem("one-record", "One app record, macOS added", "Not a second record for the Mac."),
                ChecklistItem("bundle-id", "Mac build uses the iOS bundle ID", "Check the archived build, not just the target."),
                ChecklistItem("metadata", "Mac description and promotional text written", "They don't carry over from iOS."),
                ChecklistItem("screenshots", "Mac screenshots uploaded", "In a 16:10 size.", page: "mac-screenshots"),
                ChecklistItem("privacy", "App Privacy answers cover the Mac", "One set of answers for every platform.", page: "privacy-permissions"),
                ChecklistItem("iap", "In-app purchases work on the Mac", "Buy on one platform, check it unlocks on the other."),
            ])
        }
    }
}

// MARK: - Diagram

/// One app record with two platform versions underneath, sharing a
/// bundle ID.
private struct RecordDiagram: View {
    let isCompact: Bool

    var body: some View {
        VStack(spacing: isCompact ? 6 : 10) {
            VStack(spacing: 2) {
                Label("Trips", systemImage: "app.badge")
                    .font(isCompact ? .caption.bold() : .headline)
                if !isCompact {
                    Text("com.example.trips")
                        .font(.caption.monospaced())
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.accentColor.opacity(0.15), in: .rect(cornerRadius: 8))
            Image(systemName: "arrow.down")
                .font(.caption.bold())
                .foregroundStyle(.tertiary)
            HStack(spacing: isCompact ? 8 : 14) {
                platform("iPhone & iPad", symbol: "ipad.and.iphone", version: "2.4")
                platform("Mac", symbol: "macbook", version: "1.0")
            }
        }
        .accessibilityElement(children: .combine)
    }

    private func platform(_ name: String, symbol: String, version: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: symbol)
                .font(isCompact ? .title3 : .title)
                .foregroundStyle(.tint)
            Text(name)
                .font(.caption.weight(.semibold))
            if !isCompact {
                Text("Version \(version)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(minWidth: isCompact ? 70 : 110)
        .padding(isCompact ? 6 : 10)
        .background(.fill.quaternary, in: .rect(cornerRadius: 10))
    }
}
