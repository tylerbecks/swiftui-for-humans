---
id: screenshots
title: Screenshots
platforms: [iOS, iPadOS]
docs: https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications/
reviewed: October 2026
---

# Screenshots

The screenshot sizes App Store Connect requires, and how to make clean ones.

Also called: app store screenshots, screenshot sizes, screenshot dimensions, marketing screenshots, store listing, product page, app preview, preview video, promo video, status bar.

## Rules

- **Show the app in use.** Guideline 2.3.3 says screenshots must show your app working, not just a title card, a login screen, or a splash screen.
- **Leave out prices and other platforms.** Guideline 2.3.7 keeps prices out of screenshots, and 2.3.10 keeps out the names and icons of other mobile platforms.
- **Use a clean status bar.** A low battery or a random time pulls attention from your app. Override the Simulator's status bar before you shoot.
- **Use made-up people and data.** Guideline 2.3.9 asks for fictional account details, never a real person's, and you need the rights to every image you show.
- **Keep it suitable for everyone.** Guideline 2.3.8 says screenshots and previews must fit a 4+ rating, even when your app is rated higher.

## Pitfalls

- **The first screenshots do the most work.** When there's no app preview, the first one to three screenshots show in App Store search results, so lead with what your app is for.
- **Consider one Dark Mode screenshot.** If your app supports it, showing it helps. That's our suggestion, not an Apple rule.
- **Upload them per language if your UI is translated.** Screenshots are localizable, so each language can show your app in that language.

## Guide

Every version you submit needs screenshots in App Store Connect. Guideline 2.3.3 says they must show your app in use. They're the first thing people judge your app by, so it pays to make them clean and clear.

### What you must upload

- iPhone (required): At least one screenshot for iPhone with Dynamic Island, medium display: **1206 × 2622** or **1179 × 2556** px in portrait.
- iPad (if your app runs on iPad): At least one for the 13-inch iPad display: **2064 × 2752** or **2048 × 2732** px in portrait.
- How many: 1 to 10 per display size.
- Format: PNG or JPEG, with no transparency.

**Note:** As of October 2026. If your UI is the same across sizes, upload only these and App Store Connect scales them down for smaller iPhones and iPads.

**Note:** Apple's spec page also says screenshots for iPhone Duo become required in April 2027 for apps built with the iOS 27.1 SDK or later.

### Which simulator to use

Take screenshots on a simulator in the required display class. Its screenshots come out at the right pixel size, so you don't need to resize them.

### Clean screenshots from the Simulator

`simctl` comes with Xcode. Boot your simulator, run your app with sample data, then run these in Terminal:

```swift
# A clean status bar: fixed time, full signal and battery
xcrun simctl status_bar booted override --time 9:41 \
  --batteryState charged --batteryLevel 100 \
  --cellularBars 4 --wifiBars 3

# Save a full-size PNG
xcrun simctl io booted screenshot home.png

# Put the status bar back
xcrun simctl status_bar booted clear
```

**Note:** `booted` means the simulator that's running. With several running, pass a device ID from `xcrun simctl list` instead.

### App previews

App previews are optional videos that play before your screenshots. You can add up to three per display size and language. Each one runs 15 to 30 seconds and is up to 500 MB.

Guideline 2.3.4 says a preview may only use screen recordings of your app. You can add narration and text overlays to explain what's happening.

```swift
# Record as H.264. Press Control-C to stop.
xcrun simctl io booted recordVideo \
  --codec=h264 preview.mov
```

**Important:** `recordVideo` saves HEVC by default, and App Store Connect expects H.264 or ProRes 422 (HQ). Pass `--codec=h264`, and trim the video to 15 to 30 seconds before you upload.

## Related

[submission-checklist](submission-checklist.md), [dark-mode](dark-mode.md), [privacy-details](privacy-details.md), [store-forms](store-forms.md), [rejection-guide](rejection-guide.md)
