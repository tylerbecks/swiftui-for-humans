---
id: testflight
title: TestFlight
platforms: [iOS, iPadOS]
docs: https://developer.apple.com/help/app-store-connect/test-a-beta-version/testflight-overview/
reviewed: October 2026
---

# TestFlight

Share beta builds with your team and up to 10,000 outside testers.

Also called: beta, beta testing, beta testers, staging, preview build, internal testers, external testers, public link, build expired, TestFlight App Review.

## Rules

- **Use TestFlight for betas, not the App Store.** Guideline 2.2 says demos, betas, and trial versions don't belong on the App Store. A TestFlight build should still be meant for public release and follow the guidelines.
- **Don't pay testers.** Guideline 2.2 doesn't allow giving TestFlight builds in exchange for any compensation, including as a reward for crowdfunding.
- **Tell testers what to test.** The What to Test notes appear in the TestFlight app. Specific requests get specific feedback.

## Pitfalls

- **Testers get up to 30 devices.** Each tester can install your beta on up to 30 of their devices.
- **Rating prompts don't show in TestFlight.** `requestReview` has no effect in TestFlight builds, so test it in development instead.
- **Review has a daily limit.** As of 2026, you can submit up to six builds for TestFlight App Review in 24 hours.

## Guide

TestFlight is Apple's beta testing service. You upload a build to App Store Connect, add testers, and they install it with the free TestFlight app and send feedback with screenshots. It's also the easiest way to test on the real devices App Review will use.

### Internal vs. external testers

**Note:** To create an external group, you first need an internal group. Builds you upload as TestFlight Internal Only can only go to internal groups.

### Builds expire after 90 days

Each build can be tested for up to 90 days. Upload a new build before then to keep testing. Pick an upload date to estimate when a build expires:

**Important:** If you don't expire a build yourself, testers can keep using it after the same version goes live on the App Store, until the 90 days are up.

## Related

[app-review](app-review.md), [releasing](releasing.md), [submission-checklist](submission-checklist.md)
