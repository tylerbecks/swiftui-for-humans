---
id: privacy-details
title: Privacy Details
platforms: [iOS, iPadOS]
docs: https://developer.apple.com/documentation/bundleresources/privacy-manifest-files.md
hig: https://developer.apple.com/design/human-interface-guidelines/privacy.md
reviewed: October 2026
---

# Privacy Details

Tell Apple what data your app collects, and why it uses certain APIs.

## Rules

- **Make the privacy policy easy to find.** Guideline 5.1.1(i) wants a link in App Store Connect and inside the app. A row in Settings is the usual place.
- **Ask only for data you need.** Guideline 5.1.1(iii) and the HIG both say to collect only what a feature needs. Prefer a system picker over full access to Photos or Contacts.
- **Get permission before you share data, including with AI.** Guideline 5.1.2(i) says to disclose where personal data goes, including third-party AI services, and get explicit permission first.
- **Don't lock features behind a permission.** Under 5.1.2(i), you can't require people to allow notifications, location, or tracking to use your app.

## Pitfalls

- **You can change your answers without an update.** Edit App Privacy whenever your data use changes; it isn't tied to a build.
- **Purpose strings count too.** Guideline 5.1.1(ii) says each permission prompt must explain clearly and completely how you use the data.

## Guide

Apple needs three privacy pieces before your app ships: a **privacy policy** link (Guideline 5.1.1(i)), **App Privacy answers** in App Store Connect, which become the privacy label on your product page, and a **privacy manifest** if your code or SDKs use certain APIs.

People read the label before they download, and the manifest stops apps from quietly fingerprinting devices.

### The privacy label

You answer questions about each type of data you or your SDKs collect. **Collect** means sending data off the device and keeping it longer than it takes to handle the request. Data that never leaves the device doesn't count.

**Important:** SDKs count as yours. If an analytics or ad SDK collects data, you declare it, even if you never look at that data.

### Fill it in

1. In App Store Connect, open your app and choose **App Privacy** in the sidebar.
2. Click **Get Started** and say whether you or your partners collect data.
3. Pick every data type you collect, then answer how each one is used, whether it's linked to the person, and whether it's used for tracking.
4. Next to **Privacy Policy**, click Edit and enter your policy's URL.
5. Click **Publish**. The label appears on your product page.

### The privacy manifest

`PrivacyInfo.xcprivacy` is a property list in your app target. In Xcode, choose File > New File and pick **App Privacy**. It lists the data you collect, your tracking domains, and any **required reason APIs** you call, with a code for why.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<plist version="1.0">
<dict>
    <key>NSPrivacyTracking</key>
    <false/>
    <key>NSPrivacyAccessedAPITypes</key>
    <array>
        <dict>
            <key>NSPrivacyAccessedAPIType</key>
            <string>NSPrivacyAccessedAPICategoryUserDefaults</string>
            <key>NSPrivacyAccessedAPITypeReasons</key>
            <array>
                <string>CA92.1</string>
            </array>
        </dict>
    </array>
</dict>
</plist>
```

**Important:** `@AppStorage` reads and writes `UserDefaults`, so almost every SwiftUI app needs this entry. `CA92.1` means only your app reads and writes the values. Since May 1, 2024, App Store Connect doesn't accept uploads that use these APIs without a declared reason.

### Required reason APIs

These are the five categories, with the reason most apps use. Pick the code that matches what your app actually does; Apple's docs list the rest.

- User defaults: `CA92.1`: your own app's settings. Use `1C8F.1` for an App Group.
- File timestamps: `C617.1`: files in your app's container.
- System boot time: `35F9.1`: measuring time between events.
- Disk space: `E174.1`: checking for room before writing.
- Active keyboards: `54BD.1`: adapting your UI to the keyboard.

### Third-party SDKs

Each SDK reports its own data use and required reason APIs in its own manifest; it can't rely on yours. Xcode combines all the manifests into one report to help you fill in the label.

**Note:** Apple keeps a list of commonly used SDKs, such as Firebase modules, Alamofire, and SDWebImage. A new app, or an update that adds one, must include that SDK's manifest, and a signature if you add it as a binary.

## Key APIs

`PrivacyInfo.xcprivacy`, `NSPrivacyAccessedAPITypes`, `NSPrivacyCollectedDataTypes`, `NSPrivacyTracking`, `Link`

More variants, left out to keep this file short: Privacy policy row. Guide sections left out to keep this file short: Before you submit. Apple's docs: https://developer.apple.com/documentation/bundleresources/privacy-manifest-files.md

## Related

[settings-screen](settings-screen.md), [requesting-permission](requesting-permission.md), [store-forms](store-forms.md), [submission-checklist](submission-checklist.md), [rejection-guide](rejection-guide.md)
