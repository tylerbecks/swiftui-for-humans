---
id: request-review
title: Asking for Reviews
platforms: [iOS, iPadOS]
availability: iOS 16.0+, macOS 13.0+, visionOS 1.0+
docs: https://developer.apple.com/documentation/storekit/requestreviewaction.md
hig: https://developer.apple.com/design/human-interface-guidelines/ratings-and-reviews.md
reviewed: October 2026
---

# Asking for Reviews

Ask for an App Store rating with the system prompt, at a good moment, and never for a reward.

Also called: Guideline 5.6.1, Guideline 3.2.2(x), requestReview, RequestReviewAction, SKStoreReviewController, rate this app, rate us, app rating, review prompt, star rating.

## Contents

- Rules
- Pitfalls
- Guide
- Key APIs
- Variants
- Related

## Rules

- **Ask after people finish something.** Right after a completed task, people have an opinion. On first launch or during onboarding they don't, and may rate you lower.
- **Use the system prompt, not your own.** Guideline 5.6.1 says to use Apple's API and disallows custom review prompts, so don't build your own “Rate us” alert.
- **Never trade rewards for reviews.** Don't lock features behind a rating or pay for one. A plain Write a Review row in Settings is fine.
- **Don't interrupt a task.** Wait for a natural pause, like the end of a level, not the middle of checkout.
- **Space requests out.** The HIG suggests at least a week or two between requests, and asking again only after people use the app more.

## Pitfalls

- **In Xcode it always shows; in TestFlight it never does.** Development builds show the prompt on every call so you can test it. TestFlight builds ignore the call.
- **People can turn these prompts off.** A setting stops review requests from every app, so your call may do nothing at all.

## Guide

### What Apple requires

As of 2026, the App Review Guidelines say:

• **5.6.1:** ask for reviews with Apple's API. Custom review prompts aren't allowed.

• **3.2.2(x):** never make people rate or review your app to use a feature or see content.

• **Section 3:** manipulating reviews with paid, incentivized, filtered, or fake feedback can get you removed from the Developer Program.

### Why

Ratings help people choose apps only if they're honest. The system prompt lets people rate in one tap without leaving your app, and it limits how often anyone is asked.

### How often it shows

You only *request* a review. As of 2026, the system decides whether to show it:

• At most **three times in 365 days** for someone who hasn't rated your app on that device.

• After they've rated, only for a **new version**, and only when more than 365 days have passed.

**Important:** Because the prompt may not appear, don't call it from a button like “Rate This App”. That button would do nothing most of the time. Link to the App Store instead.

### Before you submit

- **Only the system prompt**: No homemade “Rate us” alert (5.6.1).
- **Nothing is locked behind a rating**: Features and content work without one (3.2.2(x)).
- **No rewards for reviews**: No coins, unlocks, or discounts for rating.
- **Asked after a success, not at launch**: And never in the middle of a task.
- **No requestReview on a button tap**: Use a Write a Review link instead.
- **Asked at most once per version**: Store the version you last asked in.

## Key APIs

- `@Environment(\.requestReview)`: Gets the review action.
- `requestReview()`: Asks the system to show the prompt, if it allows it.
- `action=write-review`: Add to your product page URL to open the review form.
- `@AppStorage`: Remember counts and the last version you asked in.

## Variants

### Ask after a completed task

Read `requestReview` from the environment, count finished tasks, and ask once per version after a short pause.

```swift
@Environment(\.requestReview) private var requestReview
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
```

### A Write a Review link

For a button people can always tap, open your product page with `action=write-review` added to the URL.

```swift
// Your App Store product page, plus ?action=write-review
Link("Write a Review", destination: URL(string: "https://apps.apple.com/app/id1234567890?action=write-review")!)
```

## Related

[delete-account](delete-account.md), [paywall](paywall.md), `settings-screen` (swiftui-build skill), `alert` (swiftui-build skill)
