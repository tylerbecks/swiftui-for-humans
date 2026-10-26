---
id: submission-checklist
title: Submission Checklist
platforms: [iOS, iPadOS]
reviewed: October 2026
---

# Submission Checklist

Everything to check before you tap Submit for Review, in one list.

Also called: pre-submit, before you submit, launch checklist, app store checklist, preflight, ready to ship, submit for review, Guideline 2.1, Guideline 2.3, Guideline 4.2.

## Pitfalls

- **Your checkmarks stay on this device.** Come back before every submission and tap Reset when you start the next version.
- **Updates get reviewed too.** Every new version goes through App Review, so run the list again for updates, not only for your first release.

## Guide

App Review checks your app, its App Store listing, and the information you give reviewers. This list collects the common missteps Apple says slow down review or cause a rejection. Tick each item off, and tap **Read** for the details.

**Important:** As of 2026, Apple says over 40% of unresolved review issues fall under guideline 2.1, App Completeness: crashes, placeholder content, broken links, and missing review information.

### The app

- **Test on a real device**: Fix crashes and bugs on the latest iOS. Reviewers use real devices and real networks. ([testflight](testflight.md))
- **Try it on iPad**: iPhone apps can run on iPad in compatibility mode, so make sure nothing breaks there.
- **Remove placeholder content**: No lorem ipsum, test images, or empty “coming soon” screens. ([states-check](states-check.md))
- **Handle empty, loading, and error states**: No blank screens or raw error codes. ([states-check](states-check.md))
- **Check that every link works**: Including your support and privacy policy links.
- **Make it more than a website**: A repackaged website or a collection of links fails guideline 4.2. ([native-not-web](native-not-web.md))
- **Test Dark Mode and the largest text**: Every screen should stay readable in both. ([appearance-check](appearance-check.md))
- **Include a launch screen**: As of iOS 27, Apple's TN3192 says it's required for App Store submission. (`launching` (apple-design skill))

### Accounts, privacy, and payments

- **Let people delete their account**: Required in the app if people can create an account there. Guideline 5.1.1(v). ([delete-account](delete-account.md))
- **Offer an equivalent login option**: If you use a third-party or social login. Guideline 4.8. ([sign-in-with-apple](sign-in-with-apple.md))
- **Link your privacy policy**: In the app and in App Store Connect. Guideline 5.1.1(i). ([privacy-details](privacy-details.md))
- **Explain every permission request**: Each purpose string says clearly why you need the data. Guideline 5.1.1(ii). (`requesting-permission` (apple-design skill))
- **Sell digital content with In-App Purchase**: Not license keys or your own checkout. Guideline 3.1.1. ([paywall](paywall.md))

### App Store Connect

- **Make the listing match the app**: Description, screenshots, and previews show what the app really does. Guideline 2.3. ([rejection-guide](rejection-guide.md))
- **Add a support URL with real contact details**: People and App Review need a way to reach you.
- **Answer the privacy questions accurately**: Your privacy information is metadata too. Guideline 2.3. ([privacy-details](privacy-details.md))
- **Build with the required SDK**: As of April 28, 2026, uploads must use Xcode 26 or later and the iOS 26 SDK. ([releasing](releasing.md))

### Review information

- **Add a working demo account**: If the app has a login. The credentials must not expire. ([app-review](app-review.md))
- **Write clear review notes**: Explain non-obvious features, hardware, and in-app purchases. ([app-review](app-review.md))
- **Keep your backend running**: Servers must be live and reachable during review. ([app-review](app-review.md))
- **Check your contact details**: A name, email, and phone number App Review can use. ([app-review](app-review.md))
- **Pick a release option**: Manual, automatic, or automatic after a date. ([releasing](releasing.md))

## Related

[rejection-guide](rejection-guide.md), [app-review](app-review.md), [testflight](testflight.md), [releasing](releasing.md)
