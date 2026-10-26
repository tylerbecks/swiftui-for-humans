---
id: hardened-runtime
title: Hardened Runtime
platforms: [macOS]
docs: https://developer.apple.com/documentation/security/hardened-runtime.md
reviewed: October 2026
---

# Hardened Runtime

Runtime protections Apple requires before it notarizes your Mac app.

Also called: ENABLE_HARDENED_RUNTIME, --options=runtime, runtime exceptions, com.apple.security.cs.allow-jit, allow-unsigned-executable-memory, disable-library-validation, allow-dyld-environment-variables, JIT, code injection, dylib hijacking.

## Rules

- **Add only the exceptions you need.** Each exception turns off one protection. Some, like Disable Executable Memory Protection, remove core security barriers, so pick the narrowest one that works.

## Pitfalls

- **New Mac projects have it already.** Xcode adds the Hardened Runtime capability when you create a macOS app from a template.
- **Entitlements go on executables only.** Frameworks, shared libraries, and in-process plug-ins inherit the entitlements of the app that loads them.
- **Leave out what's false.** These entitlements default to false, so include one only when its value is true, as Xcode does.

## Guide

The Hardened Runtime is a set of restrictions the system enforces on your app. Together with System Integrity Protection, it blocks whole classes of attacks, like injecting code, hijacking a dynamic library, or tampering with the app's memory. Most apps run the same with it on.

### When you need it

- Outside the Mac App Store: **Required.** Apple notarizes only apps with the Hardened Runtime on, and Developer ID software must be notarized. See [Developer ID & Notarization](developer-id-notarization.md).
- On the Mac App Store: You don't notarize App Store apps, because the submission process includes equivalent checks. Apple ties the Hardened Runtime requirement to notarization.

**Note:** On the store, Guideline 2.4.5(i) requires the App Sandbox. See [App Sandbox](app-sandbox.md).

### Turn it on

1. Select your app's target in Xcode and open **Signing & Capabilities**.
2. Click **+ Capability** and choose **Hardened Runtime**. The build setting behind it is `ENABLE_HARDENED_RUNTIME`.
3. If your app needs one, check a **Runtime Exception** or a **Resource Access** item. Xcode adds the entitlement, set to true.
4. Archive and notarize. Without it, notarization fails with “The executable does not have the hardened runtime enabled.”

### Build your entitlements

Check what your app needs. The file below shows only the keys you checked, the way Xcode writes them.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<plist version="1.0">
<dict>
    <!-- No exceptions: every protection stays on. -->
</dict>
</plist>
```

### Resource access still asks first

A resource access entitlement, like Camera or Location, only lets your app ask. People still see the system's permission prompt, and your `Info.plist` still needs a purpose string. See [Privacy & Permissions](privacy-permissions.md).

### Check a signed app

```swift
# Verify the signature as strictly as notarization does
codesign -vvv --deep --strict "Trips.app"

# List the entitlements the app was signed with
codesign -d --entitlements :- "Trips.app"
```

## Related

[developer-id-notarization](developer-id-notarization.md), [app-sandbox](app-sandbox.md), [privacy-permissions](privacy-permissions.md), [updates-outside-store](updates-outside-store.md)
