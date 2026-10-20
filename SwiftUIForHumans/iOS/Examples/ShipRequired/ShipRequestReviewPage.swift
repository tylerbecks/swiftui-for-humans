import StoreKit
import SwiftUI

extension ComponentPage {
    static let shipRequestReview = ComponentPage(
        id: "request-review",
        title: "Asking for Reviews",
        summary: "Ask for an App Store rating with the system prompt, at a good moment, and never for a reward.",
        category: .requiredByApple,
        kind: .reference,
        symbol: "star.bubble",
        availability: ["iOS 16.0+", "macOS 13.0+", "visionOS 1.0+"],
        docsURL: "https://developer.apple.com/documentation/storekit/requestreviewaction",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/ratings-and-reviews",
        aliases: [
            "Guideline 5.6.1", "Guideline 3.2.2(x)", "requestReview", "RequestReviewAction", "SKStoreReviewController",
            "rate this app", "rate us", "app rating", "review prompt", "star rating", "write a review",
            "App Store reviews", "ratings",
        ],
        related: ["delete-account", "paywall", "settings-screen", "alert"],
        notes: [
            "**In Xcode it always shows; in TestFlight it never does.** Development builds show the prompt on every call so you can test it. TestFlight builds ignore the call.",
            "**People can turn these prompts off.** A setting stops review requests from every app, so your call may do nothing at all.",
        ],
        api: [
            APIItem("`@Environment(\\.requestReview)`", "Gets the review action."),
            APIItem("`requestReview()`", "Asks the system to show the prompt, if it allows it."),
            APIItem("`action=write-review`", "Add to your product page URL to open the review form."),
            APIItem("`@AppStorage`", "Remember counts and the last version you asked in."),
        ],
        guidelines: [
            Guideline(
                "Ask after people finish something.",
                "Right after a completed task, people have an opinion. On first launch or during onboarding they don't, and may rate you lower.",
                good: "After a finished workout.",
                bad: "On the welcome screen."
            ) {
                ReviewMomentSample(isGood: true)
            } bad: {
                ReviewMomentSample(isGood: false)
            },
            Guideline(
                "Use the system prompt, not your own.",
                "Guideline 5.6.1 says to use Apple's API and disallows custom review prompts, so don't build your own “Rate us” alert.",
                good: "The system's own prompt.",
                bad: "A homemade “Rate us” alert."
            ) {
                ReviewSystemPromptSample()
            } bad: {
                ReviewCustomAlertSample()
            },
            Guideline(
                "Never trade rewards for reviews.",
                "Don't lock features behind a rating or pay for one. A plain Write a Review row in Settings is fine.",
                good: "A plain link in Settings.",
                bad: "Coins for a five-star rating."
            ) {
                ShipMiniScreen(title: "Settings") {
                    ShipMiniGroup(rows: [
                        ShipMiniRow(title: "Write a Review", tint: .accentColor),
                        ShipMiniRow(title: "Contact Support", tint: .accentColor),
                    ])
                }
            } bad: {
                ShipMiniScreen(title: "Settings") {
                    ShipMiniGroup(rows: [
                        ShipMiniRow(title: "Rate ★★★★★, get 100 coins", tint: .orange),
                    ])
                }
            },
            Guideline(
                "Don't interrupt a task.",
                "Wait for a natural pause, like the end of a level, not the middle of checkout."
            ),
            Guideline(
                "Space requests out.",
                "The HIG suggests at least a week or two between requests, and asking again only after people use the app more."
            ),
        ],
        sources: [
            "https://developer.apple.com/app-store/review/guidelines/#code-of-conduct",
            "https://developer.apple.com/app-store/review/guidelines/#unacceptable",
            "https://developer.apple.com/app-store/review/guidelines/#business",
            "https://developer.apple.com/design/human-interface-guidelines/ratings-and-reviews",
            "https://developer.apple.com/documentation/storekit/requestreviewaction",
            "https://developer.apple.com/documentation/storekit/requesting-app-store-reviews",
            "https://developer.apple.com/documentation/storekit/skstorereviewcontroller/requestreview(in:)",
        ],
        reviewed: "October 2026"
    ) {
        ReviewThumbnail()
    } content: { page in
        RequestReviewArticle(page: page)
    }
}

// MARK: - Article

private struct RequestReviewArticle: View {
    let page: ComponentPage

    var body: some View {
        ArticlePage(page: page) {
            VStack(alignment: .leading, spacing: 12) {
                SectionTitle("What Apple requires")
                Prose("As of 2026, the App Review Guidelines say:")
                VStack(alignment: .leading, spacing: 8) {
                    Prose("• **5.6.1:** ask for reviews with Apple's API. Custom review prompts aren't allowed.")
                    Prose("• **3.2.2(x):** never make people rate or review your app to use a feature or see content.")
                    Prose("• **Section 3:** manipulating reviews with paid, incentivized, filtered, or fake feedback can get you removed from the Developer Program.")
                }
                .padding(.leading, 8)
            }

            VStack(alignment: .leading, spacing: 12) {
                SectionTitle("Why")
                Prose("Ratings help people choose apps only if they're honest. The system prompt lets people rate in one tap without leaving your app, and it limits how often anyone is asked.")
            }

            VStack(alignment: .leading, spacing: 12) {
                SectionTitle("How often it shows")
                Prose("You only *request* a review. As of 2026, the system decides whether to show it:")
                VStack(alignment: .leading, spacing: 8) {
                    Prose("• At most **three times in 365 days** for someone who hasn't rated your app on that device.")
                    Prose("• After they've rated, only for a **new version**, and only when more than 365 days have passed.")
                }
                .padding(.leading, 8)
                Aside(.important, "Because the prompt may not appear, don't call it from a button like “Rate This App”. That button would do nothing most of the time. Link to the App Store instead.")
            }

            VStack(alignment: .leading, spacing: 28) {
                SectionTitle("In SwiftUI")

                ExampleCard(
                    title: "Ask after a completed task",
                    caption: "Read `requestReview` from the environment, count finished tasks, and ask once per version after a short pause.",
                    code: """
                    @Environment(\\.requestReview) private var requestReview
                    @AppStorage("finishedWorkouts") private var finishedWorkouts = 0
                    @AppStorage("lastVersionAsked") private var lastVersionAsked = ""

                    func workoutFinished() {
                        finishedWorkouts += 1
                        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
                        guard finishedWorkouts >= 3, version != lastVersionAsked else { return }
                        lastVersionAsked = version
                        Task {
                            try? await Task.sleep(for: .seconds(2))
                            requestReview()
                        }
                    }
                    """,
                    minHeight: 300,
                    aside: Aside(.note, "Try it: finish three workouts. This is a development build, so the real system prompt appears every time the conditions are met.")
                ) {
                    ReviewLiveDemo()
                }

                ExampleCard(
                    title: "A Write a Review link",
                    caption: "For a button people can always tap, open your product page with `action=write-review` added to the URL.",
                    code: """
                    // Your App Store product page, plus ?action=write-review
                    Link("Write a Review", destination: URL(string: "https://apps.apple.com/app/id1234567890?action=write-review")!)
                    """
                ) {
                    ShipMiniScreen(title: "Settings", width: 280) {
                        ShipMiniGroup(header: "Feedback", rows: [
                            ShipMiniRow(title: "Write a Review", tint: .accentColor),
                            ShipMiniRow(title: "Contact Support", tint: .accentColor),
                        ])
                    }
                }
            }

            VStack(alignment: .leading, spacing: 12) {
                SectionTitle("Before you submit")
                Checklist(pageID: page.id, items: [
                    ChecklistItem("system-api", "Only the system prompt", "No homemade “Rate us” alert (5.6.1)."),
                    ChecklistItem("no-force", "Nothing is locked behind a rating", "Features and content work without one (3.2.2(x))."),
                    ChecklistItem("no-reward", "No rewards for reviews", "No coins, unlocks, or discounts for rating."),
                    ChecklistItem("timing", "Asked after a success, not at launch", "And never in the middle of a task."),
                    ChecklistItem("not-button", "No requestReview on a button tap", "Use a Write a Review link instead."),
                    ChecklistItem("per-version", "Asked at most once per version", "Store the version you last asked in."),
                ])
            }
            .id("checklist")
        }
    }
}

// MARK: - Live demo

private struct ReviewLiveDemo: View {
    @Environment(\.requestReview) private var requestReview
    @State private var finished = 0
    @State private var asked = false
    @State private var isWorkingOut = false

    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: finished == 0 ? "figure.run" : "checkmark.circle.fill")
                .font(.system(size: 44))
                .foregroundStyle(finished == 0 ? AnyShapeStyle(.tint) : AnyShapeStyle(.green))
                .contentTransition(.symbolEffect(.replace))
            Text("\(finished) of 3 workouts finished")
                .font(.headline)
                .monospacedDigit()
                .contentTransition(.numericText())
            Button {
                finishWorkout()
            } label: {
                if isWorkingOut {
                    ProgressView()
                } else {
                    Text("Finish Workout")
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(isWorkingOut || asked)
            Text(asked ? "Asked for a review. Tap Reset to try again." : "The request waits for three finished workouts.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            if asked {
                Button("Reset") {
                    withAnimation {
                        finished = 0
                        asked = false
                    }
                }
                .font(.footnote)
            }
        }
        .animation(.snappy, value: finished)
    }

    private func finishWorkout() {
        withAnimation { finished += 1 }
        guard finished >= 3 else { return }
        isWorkingOut = true
        asked = true
        Task {
            try? await Task.sleep(for: .seconds(2))
            isWorkingOut = false
            requestReview()
        }
    }
}

// MARK: - Guideline samples

/// A drawing of the system rating prompt as iOS 26 shows it, for
/// side-by-side previews. The live demo above shows the real one.
private struct ReviewSystemPromptSample: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            RoundedRectangle(cornerRadius: 9)
                .fill(.green.gradient)
                .frame(width: 36, height: 36)
                .overlay {
                    Image(systemName: "figure.run").foregroundStyle(.white)
                }
            Text("Enjoying Workouts?")
                .font(.subheadline.weight(.semibold))
            Text("Tap a star to rate it on the App Store.")
                .font(.caption)
                .foregroundStyle(.secondary)
            Divider()
            HStack(spacing: 14) {
                ForEach(0..<5) { _ in
                    Image(systemName: "star")
                        .foregroundStyle(.tint)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 2)
            Text("Not Now")
                .font(.subheadline.weight(.semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(.fill.tertiary, in: .capsule)
        }
        .padding(14)
        .frame(width: 230)
        .background(.regularMaterial, in: .rect(cornerRadius: 24))
        .overlay {
            RoundedRectangle(cornerRadius: 24).strokeBorder(.separator)
        }
    }
}

private struct ReviewCustomAlertSample: View {
    var body: some View {
        VStack(spacing: 10) {
            Text("Love Workouts? 😍")
                .font(.subheadline.weight(.semibold))
            Text("Rate us 5 stars to support us!")
                .font(.caption)
                .foregroundStyle(.secondary)
            Divider()
            HStack {
                Text("Later").frame(maxWidth: .infinity)
                Divider().frame(height: 20)
                Text("Rate 5 ★").bold().frame(maxWidth: .infinity)
            }
            .font(.subheadline)
            .foregroundStyle(.tint)
        }
        .padding(.top, 16)
        .padding(.bottom, 10)
        .frame(width: 230)
        .background(.regularMaterial, in: .rect(cornerRadius: 18))
        .overlay {
            RoundedRectangle(cornerRadius: 18).strokeBorder(.separator)
        }
    }
}

private struct ReviewMomentSample: View {
    let isGood: Bool

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 8) {
                Image(systemName: isGood ? "checkmark.circle.fill" : "hand.wave.fill")
                    .font(.largeTitle)
                    .foregroundStyle(isGood ? AnyShapeStyle(.green) : AnyShapeStyle(.tint))
                Text(isGood ? "Workout Complete" : "Welcome to Workouts")
                    .font(.subheadline.weight(.semibold))
                Text(isGood ? "5.2 km · 28 min" : "Let's set up your first plan.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
            }
            .padding(.top, 16)
            .frame(width: 250, height: 290)
            .background(Color(.systemGroupedBackground), in: .rect(cornerRadius: 20))

            ReviewSystemPromptSample()
                .scaleEffect(0.8, anchor: .bottom)
                .padding(.bottom, 12)
        }
        .allowsHitTesting(false)
    }
}

// MARK: - Thumbnail

private struct ReviewThumbnail: View {
    var body: some View {
        VStack(spacing: 8) {
            Text("Enjoying Workouts?")
                .font(.caption.weight(.semibold))
            HStack(spacing: 4) {
                ForEach(0..<5) { index in
                    Image(systemName: index < 4 ? "star.fill" : "star")
                        .font(.caption)
                        .foregroundStyle(.tint)
                }
            }
            Divider().frame(width: 150)
            Text("Not Now")
                .font(.caption)
                .foregroundStyle(.tint)
        }
        .padding(12)
        .frame(width: 180)
        .background(.regularMaterial, in: .rect(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14).strokeBorder(.separator)
        }
    }
}
