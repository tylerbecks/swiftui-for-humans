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

{{index}}
