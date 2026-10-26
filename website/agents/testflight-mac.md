---
id: testflight-mac
title: TestFlight for Mac
platforms: [macOS]
docs: https://developer.apple.com/help/app-store-connect/test-a-beta-version/testflight-overview
reviewed: October 2026
---

# TestFlight for Mac

Send Mac builds to testers with TestFlight, the same way as iPhone builds.

Also called: TestFlight, beta, beta testing, testers, internal testers, external testers, public link, Beta App Review, build number, Organizer.

## Pitfalls

- **Builds expire after 90 days.** Upload a new one before testers lose access.
- **Testers can send screenshots.** With TestFlight 2.3 or later on the Mac, testers send feedback from the TestFlight app or by taking a screenshot in your app.
- **Notarized builds are another option.** Apple also suggests giving testers an Apple-notarized build before you ship on the App Store.

## Guide

TestFlight works for Mac apps as it does on iPhone: upload a build, add testers, and they install it with the TestFlight app on their Mac. Build your Mac app with Xcode 13 or later.

Guideline **2.2** says demos and betas belong in TestFlight, not on the App Store, and a TestFlight build should be meant for public release and follow the guidelines.

### Upload a Mac build

1. In Xcode, choose **My Mac** as the run destination, then **Product > Archive**. A Catalyst app needs its own Mac archive.
2. In the Organizer that opens, select the archive and click **Distribute App**.
3. Choose **TestFlight & App Store**, or **TestFlight Internal Only** to keep the build to your team, then click **Distribute**.
4. Wait for the email that says processing finished. The build then shows up in the TestFlight tab in App Store Connect.

**Important:** Each upload needs a new build string; App Store Connect uses it to tell builds apart. Mac builds can have their own version and build numbers, separate from iOS.

### Testers

- Who: Up to 100 members of your team with the Account Holder, Admin, App Manager, Developer, or Marketing role.
- Review: Only builds for external testers go to App Review. You can send new builds to internal testers automatically.
- Devices: Each tester can install on up to 30 devices.

### Set up the test

1. In the **TestFlight** tab, add **Test Information**: a beta app description, what to test, and an email for feedback.
2. Create a group and add the Mac build to it.
3. Invite testers by email, or turn on a **public link**. You can limit who joins a public link, for example by device type and OS version.
4. Testers install **TestFlight** on their Mac, accept the invitation, and install your app.
5. Read feedback, crash reports, and screenshots in App Store Connect, filtered by platform if you like.

### Before you invite testers

- **The build is sandboxed**: Test the same entitlements you'll ship. ([app-sandbox](app-sandbox.md))
- **A new build number**: Every upload needs its own.
- **Test Information filled in**: Description, what to test, and a feedback email.
- **Beta App Review information ready**: Required before external testers can join.
- **What to Test says what changed**: Point testers at the Mac-specific features.

## Related

[universal-purchase](universal-purchase.md), [mac-app-review](mac-app-review.md), [developer-id-notarization](developer-id-notarization.md), [app-sandbox](app-sandbox.md)
