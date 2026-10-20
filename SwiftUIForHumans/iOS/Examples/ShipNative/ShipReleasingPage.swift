import SwiftUI

extension ComponentPage {
    static let shipReleasing = ComponentPage(
        id: "releasing",
        title: "Releasing",
        summary: "Choose when an approved version goes live, roll updates out slowly, and number builds right.",
        category: .testAndRelease,
        kind: .reference,
        symbol: "shippingbox",
        availability: [],
        docsURL: "https://developer.apple.com/help/app-store-connect/manage-your-apps-availability/select-an-app-store-version-release-option/",
        aliases: [
            "release", "launch", "go live", "publish", "deploy", "phased release",
            "staged rollout", "gradual rollout", "version number", "build number",
            "CFBundleShortVersionString", "CFBundleVersion", "semver", "what's new",
            "release notes", "rating prompt", "requestReview", "Guideline 2.3.12",
        ],
        related: ["app-review", "testflight", "submission-checklist"],
        notes: [
            "**You can't roll back.** If a release has a problem, fix it in a new version and submit that. App Store Connect has no way to go back to the previous one.",
            "**Use the required SDK.** As of April 28, 2026, apps uploaded to App Store Connect must be built with Xcode 26 or later and the iOS 26 SDK.",
            "**Updates need What's New text.** It's required for every version after the first, up to 4,000 characters. Guideline 2.3.12 asks you to list significant changes there.",
        ],
        api: [
            APIItem("`CFBundleShortVersionString`", "The version people see, like 1.2.0."),
            APIItem("`CFBundleVersion`", "The build string; unique per upload."),
            APIItem("`\\.requestReview`", "Asks StoreKit to show a rating prompt."),
        ],
        guidelines: [
            Guideline(
                "Ask for ratings after people succeed, not at launch.",
                "The HIG suggests asking after someone completes a task or level. On first launch they haven't formed an opinion yet.",
                good: "After a finished trip.",
                bad: "The moment the app opens."
            ) {
                ReleasingRatingMoment(isGood: true)
            } bad: {
                ReleasingRatingMoment(isGood: false)
            },
        ],
        sources: [
            "https://developer.apple.com/help/app-store-connect/manage-your-apps-availability/select-an-app-store-version-release-option/",
            "https://developer.apple.com/help/app-store-connect/update-your-app/release-a-version-update-in-phases/",
            "https://developer.apple.com/help/app-store-connect/update-your-app/create-a-new-version/",
            "https://developer.apple.com/help/app-store-connect/manage-builds/upload-builds/",
            "https://developer.apple.com/help/app-store-connect/reference/app-information/platform-version-information/",
            "https://developer.apple.com/help/app-store-connect/monitor-ratings-and-reviews/respond-to-reviews/",
            "https://developer.apple.com/documentation/bundleresources/information-property-list/cfbundleshortversionstring",
            "https://developer.apple.com/documentation/bundleresources/information-property-list/cfbundleversion",
            "https://developer.apple.com/documentation/storekit/requestreviewaction",
            "https://developer.apple.com/design/human-interface-guidelines/ratings-and-reviews",
            "https://developer.apple.com/news/upcoming-requirements/",
        ],
        reviewed: "October 2026"
    ) {
        ReleasingThumbnail()
    } content: { page in
        ReleasingArticle(page: page)
    }
}

// MARK: - Thumbnail

private struct ReleasingThumbnail: View {
    var body: some View {
        HStack(alignment: .bottom, spacing: 5) {
            ForEach(ReleasingPhase.days, id: \.day) { phase in
                Capsule()
                    .fill(Color.accentColor.gradient)
                    .frame(width: 12, height: max(4, 70 * Double(phase.percent) / 100))
            }
        }
        .frame(height: 70, alignment: .bottom)
    }
}

// MARK: - Data

private struct ReleasingPhase {
    let day: Int
    let percent: Int

    /// Apple's phased release schedule for automatic updates.
    static let days: [ReleasingPhase] = [
        ReleasingPhase(day: 1, percent: 1),
        ReleasingPhase(day: 2, percent: 2),
        ReleasingPhase(day: 3, percent: 5),
        ReleasingPhase(day: 4, percent: 10),
        ReleasingPhase(day: 5, percent: 20),
        ReleasingPhase(day: 6, percent: 50),
        ReleasingPhase(day: 7, percent: 100),
    ]
}

private enum ReleasingOption: String, CaseIterable, Identifiable {
    case manual = "Manual"
    case automatic = "Automatic"
    case scheduled = "After a Date"

    var id: Self { self }

    var steps: [(String, String)] {
        switch self {
        case .manual: [
            ("checkmark.seal", "App Review approves the version."),
            ("hand.raised", "It waits as Pending Developer Release."),
            ("hand.tap", "You tap Release This Version when you're ready."),
            ("app.badge", "It can take up to 24 hours to appear everywhere."),
        ]
        case .automatic: [
            ("checkmark.seal", "App Review approves the version."),
            ("app.badge", "It goes live automatically. Allow up to 24 hours."),
        ]
        case .scheduled: [
            ("checkmark.seal", "App Review approves the version."),
            ("calendar", "If your date hasn't come, it waits as Pending Developer Release."),
            ("app.badge", "It's released on the date and time you picked."),
        ]
        }
    }

    var bestFor: String {
        switch self {
        case .manual: "Coordinating with a launch, press, or a server change."
        case .automatic: "Bug fixes and small updates."
        case .scheduled: "A launch date you know in advance."
        }
    }
}

// MARK: - Page

private struct ReleasingArticle: View {
    let page: ComponentPage

    var body: some View {
        ArticlePage(page: page) {
            Prose("Approval doesn't have to mean going live. In App Store Connect, each version has a release option, and updates can roll out to a few people at a time.")

            SectionTitle("When it goes live")
            Prose("Set this in the **App Store Version Release** section of the version before you submit. Pick an option to see what happens after approval:")
            ReleasingOptionPicker()
            Aside(.note, "If a version sits in Pending Developer Release for more than 30 days, Apple emails you a reminder.")

            SectionTitle("Phased release for updates")
            Prose("For an update, you can turn on **phased release**. Over 7 days, the update goes to a growing random share of people who have automatic updates on. Drag through the week:")
            ReleasingPhasedDemo()
            Aside(.important, "Anyone can still download the update from the App Store by hand during the rollout. Phased release only slows automatic updates.")
            Prose("You can pause for up to 30 days in total if you spot a problem, and release to everyone at any time.")

            SectionTitle("Version and build numbers")
            Prose("Every upload has two numbers. The **version** is what people see on the App Store, written as three numbers like `1.2.0`. Its Info.plist key is `CFBundleShortVersionString`. The **build**, `CFBundleVersion`, identifies each upload. Increase the build every time you upload, and the version for each release.")
            ExampleCard(
                title: "Show the version in Settings",
                caption: "Read both numbers from `Bundle.main` so people and your support team can tell which build they have.",
                code: """
                let info = Bundle.main.infoDictionary
                let version = info?["CFBundleShortVersionString"] as? String ?? "?"
                let build = info?["CFBundleVersion"] as? String ?? "?"

                Section {
                    LabeledContent("Version", value: "\\(version) (\\(build))")
                }
                """,
                minHeight: 120
            ) {
                ReleasingVersionRow()
            }

            SectionTitle("After launch")
            ExampleCard(
                title: "Ask for a rating at the right moment",
                caption: "Read `requestReview` from the environment and call it after someone succeeds. StoreKit decides whether the prompt actually appears.",
                code: """
                import StoreKit

                @Environment(\\.requestReview) private var requestReview
                @State private var finishedTrips = 0

                Button("Finish Trip") {
                    finishedTrips += 1
                }
                .onChange(of: finishedTrips) { _, count in
                    if count == 3 {
                        requestReview()
                    }
                }
                """,
                minHeight: 140,
                aside: Aside(.note, "As of 2026, StoreKit shows the prompt at most three times in 365 days to someone who hasn't rated the app on that device. The preview only shows when the call would happen.")
            ) {
                ReleasingRatingDemo()
            }
            Prose("Then keep an eye on ratings and reviews in App Store Connect. You can post one public response per review; it can take up to 24 hours to appear.")
        }
    }
}

private struct ReleasingOptionPicker: View {
    @State private var option = ReleasingOption.manual

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Picker("Release option", selection: $option.animation(.snappy)) {
                ForEach(ReleasingOption.allCases) { option in
                    Text(option.rawValue).tag(option)
                }
            }
            .pickerStyle(.segmented)

            VStack(alignment: .leading, spacing: 12) {
                ForEach(Array(option.steps.enumerated()), id: \.offset) { _, step in
                    Label {
                        Text(step.1)
                            .fixedSize(horizontal: false, vertical: true)
                    } icon: {
                        Image(systemName: step.0)
                            .foregroundStyle(.tint)
                    }
                }
            }
            .id(option)
            .transition(.opacity)

            Text("Good for: \(option.bestFor)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle()
    }
}

private struct ReleasingPhasedDemo: View {
    @State private var day = 1.0

    var body: some View {
        let current = Int(day)
        let percent = ReleasingPhase.days[current - 1].percent
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .firstTextBaseline) {
                Text("Day \(current)")
                    .font(.headline)
                Spacer()
                Text("\(percent)% of automatic updates")
                    .font(.subheadline.monospacedDigit())
                    .foregroundStyle(.secondary)
                    .contentTransition(.numericText())
            }
            HStack(alignment: .bottom, spacing: 8) {
                ForEach(ReleasingPhase.days, id: \.day) { phase in
                    VStack(spacing: 4) {
                        Text("\(phase.percent)%")
                            .font(.caption2.monospacedDigit())
                            .foregroundStyle(phase.day == current ? .primary : .secondary)
                        RoundedRectangle(cornerRadius: 4)
                            .fill(phase.day <= current ? AnyShapeStyle(Color.accentColor.gradient) : AnyShapeStyle(.fill.tertiary))
                            .frame(height: max(4, 110 * Double(phase.percent) / 100))
                        Text("\(phase.day)")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 150, alignment: .bottom)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Day \(current): \(percent) percent")
            Slider(value: $day.animation(.snappy), in: 1...7, step: 1) {
                Text("Day")
            }
        }
        .padding(16)
        .cardStyle()
    }
}

private struct ReleasingVersionRow: View {
    var body: some View {
        let info = Bundle.main.infoDictionary
        let version = info?["CFBundleShortVersionString"] as? String ?? "?"
        let build = info?["CFBundleVersion"] as? String ?? "?"
        VStack(alignment: .leading, spacing: 0) {
            LabeledContent("Version", value: "\(version) (\(build))")
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(.background.secondary, in: .rect(cornerRadius: 12))
            Text("This app's real numbers.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 16)
                .padding(.top, 6)
        }
        .frame(maxWidth: 320)
    }
}

private struct ReleasingRatingDemo: View {
    @State private var finishedTrips = 0

    var body: some View {
        VStack(spacing: 12) {
            Button("Finish Trip") {
                finishedTrips += 1
            }
            .buttonStyle(.borderedProminent)
            Text(finishedTrips >= 3 ? "Trip 3: requestReview() called" : "Trips finished: \(finishedTrips)")
                .font(.subheadline.monospacedDigit())
                .foregroundStyle(finishedTrips >= 3 ? AnyShapeStyle(.tint) : AnyShapeStyle(.secondary))
                .contentTransition(.numericText())
                .animation(.snappy, value: finishedTrips)
            if finishedTrips > 0 {
                Button("Reset") { finishedTrips = 0 }
                    .font(.footnote)
            }
        }
    }
}

private struct ReleasingRatingMoment: View {
    let isGood: Bool

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: isGood ? "flag.checkered" : "app.dashed")
                .font(.title)
                .foregroundStyle(isGood ? AnyShapeStyle(.tint) : AnyShapeStyle(.secondary))
            Text(isGood ? "Trip complete!" : "Welcome!")
                .font(.headline)
            HStack(spacing: 3) {
                ForEach(0..<5) { _ in
                    Image(systemName: "star")
                }
            }
            .font(.footnote)
            .foregroundStyle(.orange)
            Text("Enjoying the app?")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(14)
        .frame(maxWidth: 220)
        .background(.fill.tertiary, in: .rect(cornerRadius: 12))
    }
}
