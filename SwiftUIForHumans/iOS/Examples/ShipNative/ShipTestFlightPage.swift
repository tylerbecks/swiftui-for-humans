import SwiftUI

extension ComponentPage {
    static let shipTestFlight = ComponentPage(
        id: "testflight",
        title: "TestFlight",
        summary: "Share beta builds with your team and up to 10,000 outside testers.",
        category: .testAndRelease,
        kind: .reference,
        symbol: "airplane",
        availability: [],
        docsURL: "https://developer.apple.com/help/app-store-connect/test-a-beta-version/testflight-overview/",
        aliases: [
            "beta", "beta testing", "beta testers", "staging", "preview build",
            "internal testers", "external testers", "public link", "build expired",
            "TestFlight App Review", "Guideline 2.2",
        ],
        related: ["app-review", "releasing", "submission-checklist"],
        notes: [
            "**Testers get up to 30 devices.** Each tester can install your beta on up to 30 of their devices.",
            "**Rating prompts don't show in TestFlight.** `requestReview` has no effect in TestFlight builds, so test it in development instead.",
            "**Review has a daily limit.** As of 2026, you can submit up to six builds for TestFlight App Review in 24 hours.",
        ],
        guidelines: [
            Guideline(
                "Use TestFlight for betas, not the App Store.",
                "Guideline 2.2 says demos, betas, and trial versions don't belong on the App Store. A TestFlight build should still be meant for public release and follow the guidelines."
            ),
            Guideline(
                "Don't pay testers.",
                "Guideline 2.2 doesn't allow giving TestFlight builds in exchange for any compensation, including as a reward for crowdfunding."
            ),
            Guideline(
                "Tell testers what to test.",
                "The What to Test notes appear in the TestFlight app. Specific requests get specific feedback.",
                good: "Specific: what changed and where to look.",
                bad: "Vague: testers don't know where to start."
            ) {
                TestFlightNotes(text: "New: checkout with Apple Pay. Try buying something, then check the receipt in Orders.")
            } bad: {
                TestFlightNotes(text: "Bug fixes and improvements.")
            },
        ],
        sources: [
            "https://developer.apple.com/testflight/",
            "https://developer.apple.com/help/app-store-connect/test-a-beta-version/testflight-overview/",
            "https://developer.apple.com/help/app-store-connect/test-a-beta-version/add-internal-testers/",
            "https://developer.apple.com/help/app-store-connect/test-a-beta-version/invite-external-testers/",
            "https://developer.apple.com/help/app-store-connect/test-a-beta-version/provide-test-information/",
            "https://developer.apple.com/app-store/review/guidelines/#beta-testing",
            "https://developer.apple.com/documentation/storekit/requestreviewaction",
        ],
        reviewed: "October 2026"
    ) {
        TestFlightThumbnail()
    } content: { page in
        TestFlightArticle(page: page)
    }
}

// MARK: - Thumbnail

private struct TestFlightThumbnail: View {
    var body: some View {
        HStack(spacing: 18) {
            count("100", "internal")
            count("10,000", "external")
        }
    }

    private func count(_ value: String, _ label: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.title2.bold().monospacedDigit())
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Page

private struct TestFlightArticle: View {
    let page: ComponentPage

    var body: some View {
        ArticlePage(page: page) {
            Prose("TestFlight is Apple's beta testing service. You upload a build to App Store Connect, add testers, and they install it with the free TestFlight app and send feedback with screenshots. It's also the easiest way to test on the real devices App Review will use.")

            SectionTitle("Internal vs. external testers")
            TestFlightComparison()
            Aside(.note, "To create an external group, you first need an internal group. Builds you upload as TestFlight Internal Only can only go to internal groups.")

            SectionTitle("How to set it up")
            TestFlightSteps(steps: [
                "Upload a build from Xcode to App Store Connect.",
                "In your app's TestFlight tab, enter test information. External testing needs a beta app description and a feedback email.",
                "Create an internal group and add people from your team.",
                "Create an external group and add a build. The first build goes to TestFlight App Review automatically.",
                "Once it's approved, invite testers by email or share a public link.",
                "Read feedback and crashes in the TestFlight section of App Store Connect.",
            ])

            SectionTitle("Builds expire after 90 days")
            Prose("Each build can be tested for up to 90 days. Upload a new build before then to keep testing. Pick an upload date to estimate when a build expires:")
            TestFlightExpiry()
            Aside(.important, "If you don't expire a build yourself, testers can keep using it after the same version goes live on the App Store, until the 90 days are up.")
        }
    }
}

private struct TestFlightComparison: View {
    private let rows: [(String, String, String)] = [
        ("Who", "Your App Store Connect users", "Anyone with an invite"),
        ("How many", "Up to 100", "Up to 10,000 per app"),
        ("Invite by", "Adding them to a group", "Email or a public link"),
        ("Review", "None", "First build reviewed; later builds may not be"),
        ("New builds", "Can be sent automatically", "Sent after review"),
    ]

    var body: some View {
        Grid(alignment: .leading, horizontalSpacing: 12, verticalSpacing: 0) {
            GridRow {
                Text("")
                Text("Internal").font(.subheadline.weight(.semibold))
                Text("External").font(.subheadline.weight(.semibold))
            }
            .padding(.vertical, 10)
            ForEach(rows, id: \.0) { row in
                Divider()
                GridRow(alignment: .firstTextBaseline) {
                    Text(row.0)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.secondary)
                    Text(row.1)
                    Text(row.2)
                }
                .font(.subheadline)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.vertical, 10)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 4)
        .cardStyle()
    }
}

/// Numbered steps, used for App Store Connect instructions.
private struct TestFlightSteps: View {
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

private struct TestFlightExpiry: View {
    @State private var uploaded = Date.now

    private var expires: Date {
        Calendar.current.date(byAdding: .day, value: 90, to: uploaded) ?? uploaded
    }

    private var daysLeft: Int {
        let start = Calendar.current.startOfDay(for: .now)
        let end = Calendar.current.startOfDay(for: expires)
        return Calendar.current.dateComponents([.day], from: start, to: end).day ?? 0
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            DatePicker("Uploaded", selection: $uploaded, in: ...Date.now, displayedComponents: .date)
            Divider()
            HStack {
                Text("Expires")
                Spacer()
                Text(expires, format: .dateTime.month(.wide).day().year())
                    .foregroundStyle(daysLeft <= 0 ? .red : .primary)
            }
            ProgressView(value: Double(min(max(90 - daysLeft, 0), 90)), total: 90) {
                Text(daysLeft > 0 ? "\(daysLeft) days left" : "Expired. Testers can't open this build.")
                    .font(.subheadline)
                    .foregroundStyle(daysLeft > 0 ? Color.secondary : Color.red)
            }
            .tint(daysLeft <= 14 ? .orange : .accentColor)
        }
        .padding(16)
        .cardStyle()
    }
}

private struct TestFlightNotes: View {
    let text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("What to Test")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
            Text(text)
                .font(.subheadline)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .frame(maxWidth: 280, alignment: .leading)
        .background(.fill.tertiary, in: .rect(cornerRadius: 12))
    }
}
