---
id: releasing
title: Releasing
platforms: [iOS, iPadOS]
docs: https://developer.apple.com/help/app-store-connect/manage-your-apps-availability/select-an-app-store-version-release-option/
reviewed: October 2026
---

# Releasing

Choose when an approved version goes live, roll updates out slowly, and number builds right.

Also called: release, launch, go live, publish, deploy, phased release, staged rollout, gradual rollout, version number, build number.

## Rules

- **Ask for ratings after people succeed, not at launch.** The HIG suggests asking after someone completes a task or level. On first launch they haven't formed an opinion yet.

## Pitfalls

- **You can't roll back.** If a release has a problem, fix it in a new version and submit that. App Store Connect has no way to go back to the previous one.
- **Use the required SDK.** As of April 28, 2026, apps uploaded to App Store Connect must be built with Xcode 26 or later and the iOS 26 SDK.
- **Updates need What's New text.** It's required for every version after the first, up to 4,000 characters. Guideline 2.3.12 asks you to list significant changes there.

## Guide

Approval doesn't have to mean going live. In App Store Connect, each version has a release option, and updates can roll out to a few people at a time.

### When it goes live

Set this in the **App Store Version Release** section of the version before you submit. Pick an option to see what happens after approval:

**Note:** If a version sits in Pending Developer Release for more than 30 days, Apple emails you a reminder.

### Phased release for updates

For an update, you can turn on **phased release**. Over 7 days, the update goes to a growing random share of people who have automatic updates on. Drag through the week:

**Important:** Anyone can still download the update from the App Store by hand during the rollout. Phased release only slows automatic updates.

You can pause for up to 30 days in total if you spot a problem, and release to everyone at any time.

### Version and build numbers

Every upload has two numbers. The **version** is what people see on the App Store, written as three numbers like `1.2.0`. Its Info.plist key is `CFBundleShortVersionString`. The **build**, `CFBundleVersion`, identifies each upload. Increase the build every time you upload, and the version for each release.

### After launch

Then keep an eye on ratings and reviews in App Store Connect. You can post one public response per review; it can take up to 24 hours to appear.

## Key APIs

- `CFBundleShortVersionString`: The version people see, like 1.2.0.
- `CFBundleVersion`: The build string; unique per upload.
- `\.requestReview`: Asks StoreKit to show a rating prompt.

## Variants

### Show the version in Settings

Read both numbers from `Bundle.main` so people and your support team can tell which build they have.

```swift
let info = Bundle.main.infoDictionary
let version = info?["CFBundleShortVersionString"] as? String ?? "?"
let build = info?["CFBundleVersion"] as? String ?? "?"

Section {
    LabeledContent("Version", value: "\(version) (\(build))")
}
```

### Ask for a rating at the right moment

Read `requestReview` from the environment and call it after someone succeeds. StoreKit decides whether the prompt actually appears.

```swift
import StoreKit

@Environment(\.requestReview) private var requestReview
@State private var finishedTrips = 0

Button("Finish Trip") {
    finishedTrips += 1
}
.onChange(of: finishedTrips) { _, count in
    if count == 3 {
        requestReview()
    }
}
```

**Note:** As of 2026, StoreKit shows the prompt at most three times in 365 days to someone who hasn't rated the app on that device. The preview only shows when the call would happen.

## Related

[app-review](app-review.md), [testflight](testflight.md), [submission-checklist](submission-checklist.md)
