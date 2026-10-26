---
id: privacy-permissions
title: Privacy & Permissions
platforms: [macOS]
docs: https://developer.apple.com/documentation/bundleresources/privacy-manifest-files.md
hig: https://developer.apple.com/design/human-interface-guidelines/privacy.md
reviewed: October 2026
---

# Privacy & Permissions

Purpose strings, the privacy manifest, App Privacy answers, and the Mac's permission prompts.

## Rules

- **Write a purpose string that says what and why.** One short, complete, active sentence about how the app uses the data, with a period at the end. Vague or bossy text gives people no reason to agree.
- **Ask when people reach the feature, not at launch.** A request out of nowhere feels suspicious. Asking when someone clicks Scan makes the reason obvious.
- **Give an explainer one button, and make it open the prompt.** If you show your own window first, give it a single Continue button. A second way out, or a button titled Allow, steers people.
- **Have a plan for No.** Guideline 5.1.1(iv) asks for an alternative where possible, like typing an address when someone declines Location.

## Pitfalls

- **One set of App Privacy answers covers every platform.** With Universal Purchase, answer for whichever platform collects the most.
- **Required-reason APIs are an iOS-family rule.** The privacy manifest lists them for iOS, iPadOS, tvOS, visionOS, and watchOS; the data your app collects goes in it on every platform, the Mac included.
- **Several people can share one Mac.** With fast user switching, don't assume who's signed in.

## Guide

Guideline **5.1.1** sets the rules. Link a privacy policy in App Store Connect and inside the app **(i)**. Get consent before you collect data, and write purpose strings that clearly and completely explain the use **(ii)**. Ask only for data your core features need **(iii)**, and respect people's choices without tricking or pressuring them **(iv)**.

Under **5.1.2(i)**, you can't use or share personal data without permission, and you must say clearly when it goes to a third party, third-party AI included.

### Four places privacy shows up

- In the permission prompt: Your purpose string, from `Info.plist`, appears when the system asks for access.
- In the app bundle: `PrivacyInfo.xcprivacy`, the privacy manifest, records the data your app and its SDKs collect.
- On the product page: Your App Privacy answers in App Store Connect, shown to people before they download.
- In your privacy policy: Required for Mac apps: a link in App Store Connect and one inside the app.

### Camera, microphone, and friends

On the Mac, protected hardware and data need two things before you ask: a purpose string in `Info.plist` and the matching entitlement under App Sandbox (or Hardened Runtime).

- Camera: `NSCameraUsageDescription` + `com.apple.security.device.camera`
- Microphone: `NSMicrophoneUsageDescription` + `com.apple.security.device.audio-input`
- Contacts: `NSContactsUsageDescription` + `…personal-information.addressbook`
- Photos: `NSPhotoLibraryUsageDescription` + `…personal-information.photos-library`

**Important:** For the camera and microphone, Apple says the system ends your app if the key or the entitlement is missing when it asks for access or starts capturing.

### Permissions people grant in System Settings

People review and change every choice in **System Settings > Privacy & Security**. Some lists, like **Full Disk Access** and **Accessibility**, let people add an app themselves with the add button. If a feature needs one of those, tell people exactly where to go, and keep the rest of the app working without it.

### The privacy manifest

Choose File > New File, then **App Privacy** under Resource. Xcode names it `PrivacyInfo.xcprivacy`, the name the system requires. Record the data types you collect, and whether you track. Each third-party SDK can ship its own.

```xml
<key>NSPrivacyTracking</key>
<false/>
<key>NSPrivacyCollectedDataTypes</key>
<array>
    <dict>
        <key>NSPrivacyCollectedDataType</key>
        <string>NSPrivacyCollectedDataTypeEmailAddress</string>
        <key>NSPrivacyCollectedDataTypeLinked</key>
        <true/>
        <key>NSPrivacyCollectedDataTypeTracking</key>
        <false/>
        <key>NSPrivacyCollectedDataTypePurposes</key>
        <array>
            <string>NSPrivacyCollectedDataTypePurposeAppFunctionality</string>
        </array>
    </dict>
</array>
```

### App Privacy answers

1. In App Store Connect, open your app and click **App Privacy** in the sidebar.
2. Click **Get Started** and say whether you or your partners collect data.
3. If you do, pick every data type you and your third-party partners collect, then answer the questions for each.
4. Check the **Product Page Preview**, then click **Publish**. Update the answers whenever your app's data practices change.

More variants, left out to keep this file short: Ask when the feature starts. Guide sections left out to keep this file short: Before you submit. Apple's docs: https://developer.apple.com/documentation/bundleresources/privacy-manifest-files.md

## Related

[app-sandbox](app-sandbox.md), [mac-app-review](mac-app-review.md), [universal-purchase](universal-purchase.md), [onboarding](onboarding.md)
