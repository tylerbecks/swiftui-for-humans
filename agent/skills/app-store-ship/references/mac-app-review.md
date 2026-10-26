---
id: mac-app-review
title: Mac App Review
platforms: [macOS]
docs: https://developer.apple.com/distribute/app-review/
reviewed: October 2026
---

# Mac App Review

Guideline 2.4.5's extra Mac App Store rules, and the issues that most often stall review.

## Rules

- **Open to your app, not a license screen.** Guideline 2.4.5(vi) rules out license screens at launch, license keys, and your own copy protection. The Mac App Store handles purchases; use In-App Purchase to unlock more.
- **Ask before starting at login.** Guideline 2.4.5(iii) needs consent before your app or its helpers run at startup or keep running after people quit. Make it a setting that's off until people turn it on.

## Pitfalls

- **2.1 is the big one.** Apple says over 40% of unresolved issues come from Guideline 2.1, App Completeness: crashes, placeholder content, and missing information.
- **Plug-ins are an exception to In-App Purchase.** Mac App Store apps may host plug-ins or extensions that are unlocked some other way.

## Guide

Mac apps go through the same App Review as iPhone apps, under the same guidelines. Guideline **2.4.5** adds nine rules for apps on the Mac App Store. Here they are in plain words.

### Guideline 2.4.5, in full

- (i) Sandboxed: Appropriately sandboxed, following the macOS file system documentation. Change other apps' data, like bookmarks, contacts, or calendar events, only through the APIs made for it. See [App Sandbox](app-sandbox.md).
- (ii) Packaged with Xcode: Packaged and submitted with Xcode's tools, with no third-party installers. One self-contained app bundle that installs nothing in shared locations.
- (iii) Nothing runs without consent: No launching at startup or login, and no processes left running after quit, unless people agree. Don't add yourself to the Dock or leave shortcuts on the desktop.
- (iv) No downloaded features: Don't download or install other apps, kernel extensions, code, or resources that add features or change what App Review saw.
- (v) No root: Don't ask for root privileges or use setuid attributes.
- (vi) No licensing of your own: No license screen at launch, no license keys, and no custom copy protection.
- (vii) Updates through the store: The Mac App Store delivers every update; no other update mechanism. See [Updates Outside the Store](updates-outside-store.md).
- (viii) Current macOS, current tech: Run on the currently shipping macOS, without deprecated or optionally installed technologies such as Java.
- (ix) Every language in one bundle: All localizations ship inside the single app bundle.

### Issues Apple sees most

Apple lists the most common reasons submissions get stuck. None are Mac-only, and Mac apps run into them just the same:

- Crashes and bugs · 2.1: Test thoroughly on the latest macOS and fix bugs before you submit.
- Broken links · 2.1, 5.1: Support and privacy policy links must work, in the app and in App Store Connect.
- Placeholder content · 2.1: Finish every image and every piece of text before you submit.
- Incomplete information · 2.1: Give App Review a demo account and any setup steps in App Review Information.
- Unclear data requests · 5.1.1(ii): Every protected resource needs a purpose string that clearly explains the use. See [Privacy & Permissions](privacy-permissions.md).
- Inaccurate screenshots · 2.3.3: Show the app in use, not a title screen or splash. See [Screenshots & Metadata](mac-screenshots.md).
- Not enough lasting value · 4.2: Offer enough features and content to be useful. A repackaged website or a set of links isn't enough.

### Rules Mac apps often meet elsewhere

- 2.5.1 Public APIs only: And the app must run on the currently shipping macOS.
- 2.5.2 Self-contained: Read and write only inside your container, and don't download code that changes your app's features.
- 3.1.1 In-App Purchase: Unlock features with In-App Purchase, not license keys or codes of your own.

### Before you submit

- **App Sandbox is on**: With only the entitlements you use. ([app-sandbox](app-sandbox.md))
- **Archived and uploaded with Xcode**: No installer package of your own.
- **Nothing starts at login without consent**: Login items are an opt-in setting.
- **No update checker in the store build**: Updates come from the Mac App Store. ([updates-outside-store](updates-outside-store.md))
- **No license keys or license screens**: Use In-App Purchase to unlock features. ([pricing-category](pricing-category.md))
- **Tested on the current macOS**: No deprecated or optionally installed technologies.
- **App Review Information is complete**: Demo account, notes, and a contact who answers.

More variants, left out to keep this file short: An Open at Login setting. Apple's docs: https://developer.apple.com/distribute/app-review/

## Related

[app-sandbox](app-sandbox.md), [updates-outside-store](updates-outside-store.md), [privacy-permissions](privacy-permissions.md), [mac-screenshots](mac-screenshots.md), [pricing-category](pricing-category.md), [testflight-mac](testflight-mac.md)
