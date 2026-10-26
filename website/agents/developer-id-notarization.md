---
id: developer-id-notarization
title: Developer ID & Notarization
platforms: [macOS]
docs: https://developer.apple.com/documentation/security/notarizing-macos-software-before-distribution.md
reviewed: October 2026
---

# Developer ID & Notarization

Ship outside the Mac App Store: sign with Developer ID, notarize, and staple the ticket.

Also called: Developer ID, notarization, notarize, notarytool, stapler, staple, Gatekeeper, direct distribution, outside the App Store, DMG.

## Pitfalls

- **Notarization isn't App Review.** It's an automated scan for malicious content and code signing problems. Most uploads finish within 5 minutes, and 98% within 15.
- **It protects you too.** If your Developer ID key leaks, Apple can revoke the tickets for versions you didn't make.
- **`altool` no longer works.** Since November 1, 2023, the notary service accepts uploads only from `notarytool` or Xcode 14 and later.

## Guide

You can sell or give away a Mac app from your own website. Gatekeeper checks apps from outside the Mac App Store for a **Developer ID** signature, and since macOS 10.15, Developer ID software built after June 1, 2019 must also be **notarized** by Apple to run.

### Store or direct

- App Sandbox: Required on the Mac App Store. Recommended outside it.
- Hosting and updates: Apple hosts App Store apps and their updates. Outside, you host both.
- In-App Purchase and Game Center: Available only on the Mac App Store.
- Payments and support: On the store, Apple processes payments and supports customers with billing and downloads. Outside, both are yours.
- Notarization: Required outside the store. Not needed for the store, whose submission does equivalent checks.

### What the notary service needs

- Signed code: Every executable you ship has a valid code signature.
- A Developer ID certificate: Developer ID Application, or Developer ID Installer for packages. Not a Mac Distribution or development certificate. Only the Account Holder can create one.
- Hardened Runtime: Turned on for your app and command-line targets. See [Hardened Runtime](hardened-runtime.md).
- A secure timestamp: Xcode's distribution workflow adds it for you.
- No get-task-allow: `com.apple.security.get-task-allow` must not be true. Xcode strips it when you export.

### The easy way: Xcode

1. Choose **Product > Archive**. The Organizer opens with your archive selected.
2. Click **Distribute App** and choose **Direct Distribution**, or **Custom** then **Developer ID**.
3. Choose to **upload** to the notary service. Scanning usually takes less than an hour.
4. When it's done, Xcode staples the ticket to your archive. **Export** it to get the app to ship.

### From the command line

Scripts and CI use `notarytool` and `stapler`, both included with Xcode. You can't upload an `.app` directly: zip it, or use a disk image or flat installer package.

```swift
# Once: save an app-specific password to the keychain
xcrun notarytool store-credentials "notary" \
    --apple-id "you@example.com" --team-id "TEAMID" \
    --password "app-specific-password"

# Zip the exported app and submit it
ditto -c -k --keepParent "Trips.app" "Trips.zip"
xcrun notarytool submit "Trips.zip" --keychain-profile "notary" --wait

# If it fails, read the log
xcrun notarytool log <submission-id> --keychain-profile "notary"

# Staple the ticket to the app, then zip it again to ship
xcrun stapler staple "Trips.app"
```

**Important:** You can't staple a ticket to a zip file. Staple the app inside, then make a new zip. Disk images and installer packages can be stapled directly.

**Note:** Gatekeeper also finds the ticket online, but stapling lets it check without a network connection.

### Before you ship

- **Signed with a Developer ID certificate**: Not Mac Distribution or Apple Development.
- **Hardened Runtime on**: With only the exceptions you need. ([hardened-runtime](hardened-runtime.md))
- **Notarization status is Accepted**: And the log has no warnings worth fixing.
- **Ticket stapled**: To the app, disk image, or package you ship.
- **Tested like a customer**: Download it on another Mac and open it.
- **An update path**: Every update needs signing and notarizing too. ([updates-outside-store](updates-outside-store.md))

## Related

[hardened-runtime](hardened-runtime.md), [updates-outside-store](updates-outside-store.md), [app-sandbox](app-sandbox.md), [testflight-mac](testflight-mac.md)
