---
id: universal-purchase
title: Universal Purchase
platforms: [macOS]
docs: https://developer.apple.com/help/app-store-connect/create-an-app-record/add-platforms
reviewed: October 2026
---

# Universal Purchase

One App Store listing and one purchase for your iPhone, iPad, and Mac apps.

Also called: add platform, macOS platform, same bundle ID, bundle identifier, one listing, cross-platform purchase, app record, multiplatform, Mac App Store and App Store.

## Pitfalls

- **In-app purchases come along.** Universal Purchase lets people use your app and its in-app purchases on every platform after one purchase.
- **App Privacy answers are shared.** They're set once for the app record, so cover what every platform collects.
- **It's permanent.** Once two platform versions are approved, the app stays a universal purchase, and you can't remove a platform from the record.

## Guide

With Universal Purchase, your iOS and Mac apps live in one app record in App Store Connect. People buy once and get both, with one product page. You set it up by adding the **macOS** platform to your existing iOS app.

### What has to match

- Bundle ID: **The same** as the iOS app's. The macOS version also shares its Apple ID (the app identifier) and SKU.
- Version and build: **Can differ.** The Mac app has its own version number and build string.
- Mac Catalyst apps: Supported when built with Xcode 11.4 or later.
- Separate records: Can't be merged. Keep one, remove the others from sale, and add their platforms to the one you kept.

**Important:** Removing an app from sale makes its product page unavailable. You can't update it for existing users, and its ratings and reviews don't move to the new page.

### Add the macOS platform

1. In App Store Connect, open **Apps** and select your iOS app. You need the Account Holder, Admin, or App Manager role.
2. Click **Add Platform** in the sidebar.
3. Choose **macOS** and click **Add**. A macOS version 1.0 appears in the sidebar; change the number under App Information if you like.
4. Fill in the Mac version's metadata. Everything carries over from iOS except the **promotional text**, **description**, and **screenshots**.
5. In Xcode, set the Mac target's bundle ID to the iOS app's, then archive and upload the Mac build.
6. Submit the Mac version for review. Once App Review approves both platforms, the app is a universal purchase.

### The same bundle ID in Xcode

Whether the Mac app is its own target or a destination in a multiplatform target, check the bundle ID it builds with. In build settings:

```swift
// iOS target
PRODUCT_BUNDLE_IDENTIFIER = com.example.trips
MARKETING_VERSION = 2.4

// Mac target: same ID, its own version
PRODUCT_BUNDLE_IDENTIFIER = com.example.trips
MARKETING_VERSION = 1.0
```

### If your iPad app is already on the Mac

Apple offers compatible iPhone and iPad apps on Macs with Apple silicon. When you add the macOS platform and release the Mac app, it **replaces** the iOS app on the Mac App Store, and existing users of the iOS app are updated to the Mac app.

### Before you submit

- **One app record, macOS added**: Not a second record for the Mac.
- **Mac build uses the iOS bundle ID**: Check the archived build, not just the target.
- **Mac description and promotional text written**: They don't carry over from iOS.
- **Mac screenshots uploaded**: In a 16:10 size. ([mac-screenshots](mac-screenshots.md))
- **App Privacy answers cover the Mac**: One set of answers for every platform. ([privacy-permissions](privacy-permissions.md))
- **In-app purchases work on the Mac**: Buy on one platform, check it unlocks on the other.

## Related

[native-vs-catalyst](native-vs-catalyst.md), [mac-screenshots](mac-screenshots.md), [pricing-category](pricing-category.md), [testflight-mac](testflight-mac.md), [privacy-permissions](privacy-permissions.md)
