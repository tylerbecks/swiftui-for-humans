---
name: app-store-ship
description: Gets iOS and macOS apps through App Review and into the App Store and TestFlight, with exact App Review Guideline numbers, common rejection causes and fixes, App Store Connect forms (privacy details, privacy manifest, age rating, encryption, screenshots, accessibility labels), account deletion, Sign in with Apple, in-app purchase paywalls, rating prompts, release options, and build numbers. Use when preparing an app for submission, answering or fixing an App Review rejection, adding sign-in, purchases, or review prompts, filling in App Store Connect, or shipping a TestFlight beta. Trigger keywords include App Store, App Review, rejection, guideline 2.1, 4.2, 4.8, 5.1.1, 3.1.1, TestFlight, App Store Connect, privacy manifest, PrivacyInfo.xcprivacy, privacy nutrition label, account deletion, Sign in with Apple, StoreKit, paywall, in-app purchase, requestReview, screenshots, and submit for review.
---

# App Store ship

What App Review checks and what App Store Connect asks for, with the guideline numbers reviewers cite. Paraphrased; each reference links Apple's source. Rules change, so each reference carries the date it was last checked. When precision matters, confirm against the live App Review Guidelines.

## Workflow

1. Before submitting, work through `references/submission-checklist.md`, then the reference for each feature the app has (accounts, purchases, sign-in, ratings).
2. For a rejection, find the cited number in `references/rejection-guide.md`, then fix the cause, not only the symptom. Reply in App Store Connect when the reviewer misunderstood.
3. For App Store Connect forms, read `references/privacy-details.md` and `references/store-forms.md`.

## Top rules

1. Ship a complete app: no crashes, placeholders, broken links, or features that need setup reviewers can't do. Give reviewers a working demo account and notes (2.1).
2. The listing matches the app: description, screenshots, and privacy answers are accurate (2.3).
3. The app does more than a repackaged website or a set of links (4.2). See `references/native-not-web.md`.
4. If people can create an account in the app, they can delete it in the app (5.1.1(v)).
5. Third-party or social login also needs an equivalent private login option, such as Sign in with Apple (4.8).
6. Link a privacy policy in the app and in App Store Connect (5.1.1(i)), and every permission prompt says why (5.1.1(ii)).
7. Digital features and content are sold with In-App Purchase (3.1.1), and purchases are complete and visible for review.
8. Ask for ratings only with the system prompt (`requestReview`), never a custom "Rate us" alert (5.6.1), and never lock features behind a rating.
9. Declare required-reason APIs (such as `UserDefaults`, reason `CA92.1`) in `PrivacyInfo.xcprivacy`, and keep the privacy details in step with what the app and its SDKs collect.
10. Every upload needs a new build number, built with the SDK Apple currently requires.

## Index

### Start Here

- `references/submission-checklist.md`: Everything to check before you tap Submit for Review, in one list.
- `references/rejection-guide.md`: The guidelines apps break most often, what each means, and how to fix it.
- `references/native-vs-catalyst.md` (macOS only): Three ways onto the Mac: a native Mac app, Mac Catalyst, or your iPad app as it is.
- `references/great-mac-app.md` (macOS only): Menus, the keyboard, windows, Settings, and drag and drop: what people expect on a Mac.

### Feels Native

- `references/native-not-web.md`: What makes an app feel like a website in a frame, and how to fix it.
- `references/appearance-check.md`: Before you submit, check every screen in Dark Mode and at the largest text size.
- `references/states-check.md`: Give every screen an empty, loading, and error state, and ship no placeholders.

### Test & Release

- `references/testflight.md`: Share beta builds with your team and up to 10,000 outside testers.
- `references/app-review.md`: What reviewers need from you, how long review takes, and what to do if you're rejected.
- `references/releasing.md`: Choose when an approved version goes live, roll updates out slowly, and number builds right.
- `references/testflight-mac.md` (macOS only): Send Mac builds to testers with TestFlight, the same way as iPhone builds.
- `references/hardened-runtime.md` (macOS only): Runtime protections Apple requires before it notarizes your Mac app.
- `references/developer-id-notarization.md` (macOS only): Ship outside the Mac App Store: sign with Developer ID, notarize, and staple the ticket.
- `references/updates-outside-store.md` (macOS only): Apps you distribute yourself deliver their own updates; Mac App Store apps must not.

### Required by Apple

- `references/sign-in-with-apple.md`: Apple's sign-in button, and when App Review expects you to offer it.
- `references/delete-account.md`: If people can create an account in your app, they must be able to delete it there too.
- `references/paywall.md`: Sell digital features with StoreKit's ready-made store views, and show what Apple requires.
- `references/request-review.md`: Ask for an App Store rating with the system prompt, at a good moment, and never for a reward.
- `references/app-sandbox.md` (macOS only): Every Mac App Store app runs in a sandbox, with only the access it asks for.
- `references/privacy-permissions.md` (macOS only): Purpose strings, the privacy manifest, App Privacy answers, and the Mac's permission prompts.
- `references/mac-app-review.md` (macOS only): Guideline 2.4.5's extra Mac App Store rules, and the issues that most often stall review.

### App Store Connect

- `references/screenshots.md`: The screenshot sizes App Store Connect requires, and how to make clean ones.
- `references/privacy-details.md`: Tell Apple what data your app collects, and why it uses certain APIs.
- `references/accessibility-labels.md`: Accessibility Nutrition Labels show which accessibility features your app supports.
- `references/store-forms.md`: Age rating, encryption, EU trader status, content rights, and the Xcode you need.
- `references/universal-purchase.md` (macOS only): One App Store listing and one purchase for your iPhone, iPad, and Mac apps.
- `references/mac-screenshots.md` (macOS only): Mac screenshot sizes, app previews, and the text on your Mac product page.
- `references/pricing-category.md` (macOS only): Set your Mac app's category in Xcode and App Store Connect, then its price and countries.

### Feels Like a Mac

- `references/mac-native-checklist.md` (macOS only): The details Mac users and reviewers notice, in one list to check before you ship.
- `references/ipad-app-in-window.md` (macOS only): The signs of a port that wasn't adapted to the Mac, and what to do instead.
