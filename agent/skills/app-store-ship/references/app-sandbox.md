---
id: app-sandbox
title: App Sandbox
platforms: [macOS]
docs: https://developer.apple.com/documentation/security/app-sandbox.md
reviewed: October 2026
---

# App Sandbox

Every Mac App Store app runs in a sandbox, with only the access it asks for.

Also called: sandbox, sandboxing, entitlements, entitlement, com.apple.security.app-sandbox, container, Library/Containers, Operation not permitted, file access, security-scoped.

## Contents

- Rules
- Pitfalls
- Guide
- Key APIs
- Variants
- Related

## Rules

- **Ask only for the access you use.** The sandbox works by keeping your app to the smallest set of privileges it needs. Turn on what a feature uses, and turn it off when the feature goes.
- **Reach people's files through the open and save panels.** The sandbox keeps your app in its own container. A file people pick in a panel is the normal way to read or write anywhere else.

## Pitfalls

- **Your Debug builds are sandboxed too.** The entitlements apply whenever the app is signed, so you find missing access while developing, not in review.
- **Asking for an entitlement isn't the same as getting access.** Camera, microphone, and location still show the system's permission prompt.

## Guide

Guideline **2.4.5(i)** says apps on the Mac App Store must be appropriately sandboxed. Turn on the App Sandbox, then turn on only the access your features need: the network, files people pick, the camera, and so on.

The sandbox limits what a compromised app can do. If someone tricks your app into running bad code, it can still only reach its own folder and what you declared.

### Turn it on

1. In Xcode, select your app's target and open **Signing & Capabilities**.
2. Click **+ Capability** and add **App Sandbox**. Xcode adds `com.apple.security.app-sandbox` to your entitlements file.
3. Under App Sandbox, check each resource you use, like **Outgoing Connections (Client)** for network requests.
4. For **User Selected File**, choose **Read Only** or **Read/Write** if people open or save files.
5. Run the app, open Activity Monitor, and choose View > Columns > Sandbox. Your app should say **Yes**.

### What the entitlements file looks like

This app's own entitlements: the sandbox, outgoing network connections for photos and maps, and files people pick.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<plist version="1.0">
<dict>
    <key>com.apple.security.app-sandbox</key>
    <true/>
    <key>com.apple.security.network.client</key>
    <true/>
    <key>com.apple.security.files.user-selected.read-write</key>
    <true/>
</dict>
</plist>
```

### Where your files live

- Your container: `~/Library/Containers/<bundle ID>`. The system makes it on first launch, and only your app can read and write it.
- Downloads, Pictures, and other folders: Off limits unless you add the matching entitlement. Without it you get “Operation not permitted.”
- Files people pick: Readable or writable when you add the user-selected file entitlement and they choose the file in a panel.

### Before you submit

- **App Sandbox is on**: `com.apple.security.app-sandbox` is in your entitlements.
- **Only the entitlements you use**: Remove leftovers from features you cut.
- **Network access if you load anything**: Outgoing Connections (Client) for images, APIs, and maps.
- **Files go through open and save panels**: Plus the user-selected file entitlement.
- **Activity Monitor shows Sandbox: Yes**: Check the build you're about to submit.

## Key APIs

- `com.apple.security.app-sandbox`: Turns the sandbox on. Required for the Mac App Store.
- `com.apple.security.network.client`: Outgoing connections, like loading images.
- `…files.user-selected.read-write`: Files people pick in an open or save panel.
- `.fileImporter(isPresented:…)`: Shows an open panel from SwiftUI.
- `startAccessingSecurityScopedResource()`: Opens access to a file people picked.

## Variants

### Read a file from an open panel

`.fileImporter` shows the open panel. Wrap your reads in `startAccessingSecurityScopedResource()` and its matching stop call.

```swift
import SwiftUI
import UniformTypeIdentifiers

struct OpenTextButton: View {
    @State private var isImporting = false
    @State private var text = ""

    var body: some View {
        Button("Open Text File…") { isImporting = true }
            .fileImporter(isPresented: $isImporting, allowedContentTypes: [.plainText]) { result in
                guard case .success(let url) = result else { return }
                let didAccess = url.startAccessingSecurityScopedResource()
                defer { if didAccess { url.stopAccessingSecurityScopedResource() } }
                text = (try? String(contentsOf: url, encoding: .utf8)) ?? ""
            }
    }
}
```

**Important:** Without the user-selected file entitlement, the open panel still appears, but reading the file fails.

## Related

`settings-scene` (swiftui-build skill)
