import SwiftUI

extension ComponentPage {
    static let shipSubmissionChecklist = ComponentPage(
        id: "submission-checklist",
        title: "Submission Checklist",
        summary: "Everything to check before you tap Submit for Review, in one list.",
        category: .startHere,
        kind: .reference,
        symbol: "checklist",
        availability: [],
        docsURL: nil,
        aliases: [
            "pre-submit", "before you submit", "launch checklist", "app store checklist",
            "preflight", "ready to ship", "submit for review",
            "Guideline 2.1", "Guideline 2.3", "Guideline 4.2", "Guideline 4.8",
            "Guideline 5.1.1", "Guideline 5.1.1(v)", "Guideline 3.1.1",
        ],
        related: ["rejection-guide", "app-review", "testflight", "releasing"],
        notes: [
            "**Your checkmarks stay on this device.** Come back before every submission and tap Reset when you start the next version.",
            "**Updates get reviewed too.** Every new version goes through App Review, so run the list again for updates, not only for your first release.",
        ],
        sources: [
            "https://developer.apple.com/app-store/review/guidelines/",
            "https://developer.apple.com/distribute/app-review/",
            "https://developer.apple.com/help/app-review/before-submitting-for-review/complete-review/",
            "https://developer.apple.com/help/app-review/before-submitting-for-review/test-compatible-devices/",
            "https://developer.apple.com/help/app-store-connect/reference/app-information/platform-version-information/",
            "https://developer.apple.com/news/upcoming-requirements/",
            "https://developer.apple.com/documentation/technotes/tn3192-migrating-your-app-from-the-deprecated-uirequiresfullscreen-key",
        ],
        reviewed: "October 2026"
    ) {
        ShipChecklistThumbnail()
    } content: { page in
        ShipChecklistArticle(page: page)
    }
}

// MARK: - Thumbnail

private struct ShipChecklistThumbnail: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            row("Test on a device", done: true)
            row("Add a demo account", done: true)
            row("Remove placeholders", done: false)
        }
        .font(.subheadline)
    }

    private func row(_ title: String, done: Bool) -> some View {
        HStack(spacing: 8) {
            Image(systemName: done ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(done ? AnyShapeStyle(.tint) : AnyShapeStyle(.tertiary))
            Text(title)
                .strikethrough(done, color: .secondary)
                .foregroundStyle(done ? .secondary : .primary)
        }
    }
}

// MARK: - Page

private struct ShipChecklistArticle: View {
    let page: ComponentPage

    var body: some View {
        ArticlePage(page: page) {
            Prose("App Review checks your app, its App Store listing, and the information you give reviewers. This list collects the common missteps Apple says slow down review or cause a rejection. Tick each item off, and tap **Read** for the details.")

            Aside(.important, "As of 2026, Apple says over 40% of unresolved review issues fall under guideline 2.1, App Completeness: crashes, placeholder content, broken links, and missing review information.")

            SectionTitle("The app")
            Checklist(pageID: page.id, items: [
                ChecklistItem("device", "Test on a real device",
                              "Fix crashes and bugs on the latest iOS. Reviewers use real devices and real networks.",
                              page: "testflight"),
                ChecklistItem("ipad", "Try it on iPad",
                              "iPhone apps can run on iPad in compatibility mode, so make sure nothing breaks there."),
                ChecklistItem("placeholders", "Remove placeholder content",
                              "No lorem ipsum, test images, or empty “coming soon” screens.",
                              page: "states-check"),
                ChecklistItem("states", "Handle empty, loading, and error states",
                              "No blank screens or raw error codes.",
                              page: "states-check"),
                ChecklistItem("links", "Check that every link works",
                              "Including your support and privacy policy links."),
                ChecklistItem("native", "Make it more than a website",
                              "A repackaged website or a collection of links fails guideline 4.2.",
                              page: "native-not-web"),
                ChecklistItem("appearance", "Test Dark Mode and the largest text",
                              "Every screen should stay readable in both.",
                              page: "appearance-check"),
                ChecklistItem("launch-screen", "Include a launch screen",
                              "As of iOS 27, Apple's TN3192 says it's required for App Store submission.",
                              page: "launching"),
            ])

            SectionTitle("Accounts, privacy, and payments")
            Checklist(pageID: page.id, items: [
                ChecklistItem("deletion", "Let people delete their account",
                              "Required in the app if people can create an account there. Guideline 5.1.1(v).",
                              page: "delete-account"),
                ChecklistItem("login", "Offer an equivalent login option",
                              "If you use a third-party or social login. Guideline 4.8.",
                              page: "sign-in-with-apple"),
                ChecklistItem("privacy-policy", "Link your privacy policy",
                              "In the app and in App Store Connect. Guideline 5.1.1(i).",
                              page: "privacy-details"),
                ChecklistItem("purpose-strings", "Explain every permission request",
                              "Each purpose string says clearly why you need the data. Guideline 5.1.1(ii).",
                              page: "requesting-permission"),
                ChecklistItem("iap", "Sell digital content with In-App Purchase",
                              "Not license keys or your own checkout. Guideline 3.1.1.",
                              page: "paywall"),
            ])

            SectionTitle("App Store Connect")
            Checklist(pageID: page.id, items: [
                ChecklistItem("metadata", "Make the listing match the app",
                              "Description, screenshots, and previews show what the app really does. Guideline 2.3.",
                              page: "rejection-guide"),
                ChecklistItem("support-url", "Add a support URL with real contact details",
                              "People and App Review need a way to reach you."),
                ChecklistItem("privacy-labels", "Answer the privacy questions accurately",
                              "Your privacy information is metadata too. Guideline 2.3.",
                              page: "privacy-details"),
                ChecklistItem("sdk", "Build with the required SDK",
                              "As of April 28, 2026, uploads must use Xcode 26 or later and the iOS 26 SDK.",
                              page: "releasing"),
            ])

            SectionTitle("Review information")
            Checklist(pageID: page.id, items: [
                ChecklistItem("demo", "Add a working demo account",
                              "If the app has a login. The credentials must not expire.",
                              page: "app-review"),
                ChecklistItem("notes", "Write clear review notes",
                              "Explain non-obvious features, hardware, and in-app purchases.",
                              page: "app-review"),
                ChecklistItem("backend", "Keep your backend running",
                              "Servers must be live and reachable during review.",
                              page: "app-review"),
                ChecklistItem("contact", "Check your contact details",
                              "A name, email, and phone number App Review can use.",
                              page: "app-review"),
                ChecklistItem("release", "Pick a release option",
                              "Manual, automatic, or automatic after a date.",
                              page: "releasing"),
            ])
        }
    }
}
