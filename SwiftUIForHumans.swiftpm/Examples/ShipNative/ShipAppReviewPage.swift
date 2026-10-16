import SwiftUI

extension ComponentPage {
    static let shipAppReview = ComponentPage(
        id: "app-review",
        title: "App Review",
        summary: "What reviewers need from you, how long review takes, and what to do if you're rejected.",
        category: .testAndRelease,
        kind: .reference,
        symbol: "person.text.rectangle",
        availability: [],
        docsURL: "https://developer.apple.com/distribute/app-review/",
        aliases: [
            "submit for review", "review notes", "demo account", "test account",
            "reviewer", "review time", "how long does review take", "rejected",
            "resolution center", "appeal", "App Review Board", "expedited review",
            "unresolved issues", "bug fix submission", "Guideline 2.1",
        ],
        related: ["submission-checklist", "rejection-guide", "testflight", "releasing"],
        notes: [
            "**Book a call if you're unsure.** App Review offers 30-minute video appointments to talk through the guidelines before you submit.",
            "**Already on the store? Bug fixes aren't held up.** If a bug fix update is rejected for an unrelated issue, Apple may let it through and have you fix the issue next time, unless it's a legal or safety problem.",
        ],
        guidelines: [
            Guideline(
                "Write review notes a stranger can follow.",
                "The reviewer has never seen your app. Tell them where things are and how to reach features that need setup.",
                good: "Steps, a working account, and where to look.",
                bad: "Nothing the reviewer can act on."
            ) {
                AppReviewNotesCard(text: "Sign in with the demo account below. To see the new trip planner, tap Trips > New Trip. In-app purchase: Settings > Upgrade. Tested on iPhone 17 with iOS 26.")
            } bad: {
                AppReviewNotesCard(text: "Please approve, thanks!")
            },
            Guideline(
                "Appeal with specifics, not feelings.",
                "Name the guideline, then explain point by point how the app meets it. Apple's own example of an incomplete appeal just asks them to take another look.",
                good: "Cites the guideline and the evidence.",
                bad: "Says it matters, gives no reasons."
            ) {
                AppReviewNotesCard(title: "Appeal", text: "Rejected under 2.1 for missing information. The demo account and setup steps are now in App Review Information, with screenshots of the feature working.")
            } bad: {
                AppReviewNotesCard(title: "Appeal", text: "This app is important to my business. Please look again.")
            },
        ],
        sources: [
            "https://developer.apple.com/distribute/app-review/",
            "https://developer.apple.com/app-store/review/guidelines/#after-you-submit",
            "https://developer.apple.com/help/app-review/before-submitting-for-review/complete-review/",
            "https://developer.apple.com/help/app-review/after-submitting-for-review/review-status/",
            "https://developer.apple.com/help/app-review/after-submitting-for-review/appeal-to-the-app-review-board/",
            "https://developer.apple.com/help/app-review/after-submitting-for-review/request-expedited-review/",
            "https://developer.apple.com/help/app-store-connect/reference/app-information/platform-version-information/",
            "https://developer.apple.com/help/app-store-connect/manage-submissions-to-app-review/submit-an-app/",
            "https://developer.apple.com/help/app-store-connect/reference/app-information/app-and-submission-statuses/",
            "https://developer.apple.com/help/app-store-connect/manage-submissions-to-app-review/reply-to-app-review-messages/",
        ],
        reviewed: "October 2026"
    ) {
        AppReviewThumbnail()
    } content: { page in
        AppReviewArticle(page: page)
    }
}

// MARK: - Thumbnail

private struct AppReviewThumbnail: View {
    var body: some View {
        HStack(spacing: 6) {
            AppReviewStatusPill(title: "Waiting", color: .orange)
            Image(systemName: "chevron.right").font(.caption2).foregroundStyle(.tertiary)
            AppReviewStatusPill(title: "In Review", color: .blue)
            Image(systemName: "chevron.right").font(.caption2).foregroundStyle(.tertiary)
            AppReviewStatusPill(title: "Ready", color: .green)
        }
    }
}

private struct AppReviewStatusPill: View {
    let title: String
    let color: Color

    var body: some View {
        Text(title)
            .font(.caption.weight(.semibold))
            .foregroundStyle(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.14), in: .capsule)
            .fixedSize()
    }
}

// MARK: - Page

private struct AppReviewArticle: View {
    let page: ComponentPage

    var body: some View {
        ArticlePage(page: page) {
            Prose("App Review checks every new app and every update before it reaches the App Store. Your job is to make that check easy: a finished build, a way in, and notes that explain anything that isn't obvious.")

            SectionTitle("What reviewers need")
            Prose("Fill in the **App Review Information** section of your version in App Store Connect. Customers never see it.")
            AppReviewInfoForm()
            Aside(.important, "Use a demo account that won't expire, and keep your servers running during review. If sign-in also needs a code, put it in the notes, or review may wait for a call.")
            Prose("In the notes, Apple asks for your app's concept and audience, what changed in an update, the devices and iOS versions you tested, and any external services it relies on. For auto-renewable subscriptions, include an account with an expired subscription so the reviewer can see the whole purchase flow.")

            SectionTitle("How long it takes")
            Prose("As of 2026, Apple says it aims to review at least half of submissions within 24 hours and 90% within 48 hours. Apps with regulated content, new capabilities, or missing documents take longer. Tap a status to see what it means:")
            AppReviewStatusExplorer()
            Aside(.note, "Facing a critical bug or a dated event? You can request an expedited review after you submit. Save it for real emergencies.")

            SectionTitle("If you're rejected")
            AppReviewSteps(steps: [
                "Read the message in the **App Review** section of App Store Connect. It names the guidelines and explains the problem.",
                "If something is unclear or the reviewer misunderstood, **reply** there. You can attach screenshots and documents.",
                "If only the metadata or your server was wrong, fix it and reply. You can resubmit the same build.",
                "If the build itself was wrong, upload a fixed build and submit it. Fix every listed issue first; resubmitting with open issues just repeats the result.",
                "If you still believe the app follows the guidelines, **appeal** to the App Review Board.",
            ])

            SectionTitle("Appealing")
            Prose("Appeal when you believe the app follows the guidelines, the reviewer misunderstood it, or you were treated unfairly. Reply to the rejection first. Then send **one** appeal per rejected app that covers every cited guideline.")
            Aside(.important, "Resubmitting starts a new review and closes your appeal. Don't do both.")
        }
    }
}

/// A read-only look at the App Review Information fields in App Store Connect.
private struct AppReviewInfoForm: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            group("Sign-In Information") {
                field("User name", "review@example.com")
                field("Password", "••••••••••")
            }
            group("Contact Information") {
                field("Name", "Alex Rivera")
                field("Phone", "+1 555 0100 2233")
                field("Email", "alex@example.com")
            }
            group("Notes") {
                Text("To see the new trip planner, tap Trips > New Trip.")
                    .font(.subheadline)
                    .padding(.vertical, 10)
            }
            group("Attachment") {
                Label("Demo video of the hardware pairing", systemImage: "paperclip")
                    .font(.subheadline)
                    .padding(.vertical, 10)
            }
        }
        .padding(16)
        .cardStyle()
    }

    private func group<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.secondary)
                .padding(.top, 8)
            content()
            Divider()
        }
    }

    private func field(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .font(.subheadline)
        .padding(.vertical, 8)
    }
}

private enum AppReviewStatus: String, CaseIterable, Identifiable {
    case waiting = "Waiting for Review"
    case inReview = "In Review"
    case unresolved = "Unresolved Issues"
    case pending = "Pending Developer Release"
    case ready = "Ready for Distribution"

    var id: Self { self }

    var color: Color {
        switch self {
        case .waiting: .orange
        case .inReview: .blue
        case .unresolved: .red
        case .pending: .purple
        case .ready: .green
        }
    }

    var symbol: String {
        switch self {
        case .waiting: "clock"
        case .inReview: "eye"
        case .unresolved: "exclamationmark.bubble"
        case .pending: "hand.raised"
        case .ready: "checkmark.seal"
        }
    }

    var detail: String {
        switch self {
        case .waiting: "Apple has your submission but hasn't started. You can still edit some information, but not screenshots or previews."
        case .inReview: "A reviewer is looking at it now. You can still cancel the submission."
        case .unresolved: "App Review rejected one or more items. Read the message, then reply, or fix and resubmit."
        case .pending: "Accepted, and waiting for you to release it, because you chose to release it manually."
        case .ready: "Accepted and ready for distribution. After release, it can take up to 24 hours to appear in every storefront."
        }
    }
}

private struct AppReviewStatusExplorer: View {
    @State private var selected = AppReviewStatus.waiting

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            FlowLayout(spacing: 8) {
                ForEach(AppReviewStatus.allCases) { status in
                    Button {
                        withAnimation(.snappy) { selected = status }
                    } label: {
                        Label(status.rawValue, systemImage: status.symbol)
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(selected == status ? .white : status.color)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(selected == status ? AnyShapeStyle(status.color) : AnyShapeStyle(status.color.opacity(0.14)), in: .capsule)
                    }
                    .buttonStyle(.plain)
                }
            }
            Text(selected.detail)
                .fixedSize(horizontal: false, vertical: true)
                .contentTransition(.opacity)
                .id(selected)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle()
    }
}

private struct AppReviewSteps: View {
    let steps: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                HStack(alignment: .firstTextBaseline, spacing: 12) {
                    Text("\(index + 1)")
                        .font(.subheadline.weight(.bold).monospacedDigit())
                        .foregroundStyle(.white)
                        .frame(width: 24, height: 24)
                        .background(Color.accentColor, in: .circle)
                        .alignmentGuide(.firstTextBaseline) { $0[VerticalAlignment.center] + 5 }
                    RichText(step)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }
}

private struct AppReviewNotesCard: View {
    var title = "Notes"
    let text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
            Text(text)
                .font(.subheadline)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .frame(maxWidth: 300, alignment: .leading)
        .background(.fill.tertiary, in: .rect(cornerRadius: 12))
    }
}
