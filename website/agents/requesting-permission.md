---
id: requesting-permission
title: Requesting Permission
platforms: [iOS, iPadOS]
availability: iOS 14.0+
docs: https://developer.apple.com/documentation/uikit/requesting-access-to-protected-resources.md
hig: https://developer.apple.com/design/human-interface-guidelines/privacy.md
reviewed: October 2026
---

# Requesting Permission

Ask for access when a feature needs it, say why, and handle “no” gracefully.

Also called: permission prompt, permissions, authorization, purpose string, usage description, Info.plist, NSCameraUsageDescription, camera permission, location permission, pre-permission.

## Contents

- Rules
- Pitfalls
- Guide
- Key APIs
- Variants
- Related

## Rules

- **Ask when people use the feature, not at launch.** A prompt makes sense right after someone taps Scan Receipt. On first launch it's a mystery, unless the app can't work at all without it.
- **Write a purpose string that says exactly why.** The system prompt shows your sentence under its title. Make it one specific, complete sentence about what people get.
- **Give an explanation screen one button: Continue.** If you explain before the prompt, the only button should open it. A button called Allow, or a way to skip, steers people, and the HIG calls that manipulative.
- **Have a plan for “Don't Allow”.** Keep the rest of the app working and offer another way, like typing an address when location is off. As of 2026, App Review Guideline 5.1.1(iv) asks for this.
- **Ask only for what the feature needs.** Don't require the microphone to post a photo. As of 2026, Guideline 5.1.1(iv) forbids pushing people into access a feature doesn't need.

## Pitfalls

- **A missing purpose string is a crash and a rejection.** Without the Info.plist key, the access attempt fails and may crash, and App Review rejects the build. That includes APIs used by SDKs you add.
- **You usually get one prompt.** After people answer, the system remembers and doesn't ask again. Only Settings can change it, and people can change it there at any time.
- **Sometimes a picker beats a permission.** As of 2026, Guideline 5.1.1(iii) asks you to use a system picker or share sheet, like `PhotosPicker`, instead of full access to Photos or Contacts where you can.

## Guide

iOS guards the camera, microphone, location, photos, contacts, and more. The first time your app reaches for one, the system asks people with an alert that shows your own explanation, called a purpose string. Ask at the moment it makes sense, and design for both answers.

Tap **Scan Receipt** and answer the prompt, which is simulated here. Then try **Reset** and say no.

```swift
import AVFoundation
import SwiftUI

struct ScanReceiptButton: View {
    @State private var status = AVCaptureDevice.authorizationStatus(for: .video)
    @Environment(\.openURL) private var openURL

    var body: some View {
        switch status {
        case .authorized:
            Text("Camera ready") // Show your scanner here.
        case .denied, .restricted:
            ContentUnavailableView {
                Label("Camera Access Is Off", systemImage: "video.slash")
            } description: {
                Text("Turn on Camera in Settings to scan receipts, or add a photo instead.")
            } actions: {
                Button("Open Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        openURL(url)
                    }
                }
            }
        default:
            Button("Scan Receipt", systemImage: "camera") {
                Task {
                    _ = await AVCaptureDevice.requestAccess(for: .video)
                    status = AVCaptureDevice.authorizationStatus(for: .video)
                }
            }
        }
    }
}
```

**Important:** Check the status every time the feature opens, not once at launch. People can turn access off in Settings whenever they like.

## Key APIs

`NSCameraUsageDescription`, `authorizationStatus(for:)`, `requestAccess(for:)`, `openSettingsURLString`, `LocationButton`, `PhotosPicker`

## Variants

### The purpose string

Add the usage description key for each resource to Info.plist. The system shows it in the prompt.

```xml
<!-- Info.plist -->
<key>NSCameraUsageDescription</key>
<string>Scan receipts to add expenses automatically.</string>
```

**Note:** In Xcode you can also add it in the target's Info tab, or as the `INFOPLIST_KEY_NSCameraUsageDescription` build setting. Localize it like any other text.

### An explanation screen, if you need one

When the context doesn't explain itself, show one screen with a single Continue button that opens the prompt.

```swift
VStack(spacing: 16) {
    Image(systemName: "doc.viewfinder")
        .font(.system(size: 56))
        .foregroundStyle(.tint)
    Text("Scan Receipts")
        .font(.title2.bold())
    Text("Point your camera at a receipt and Expenses fills in the amount and date for you.")
        .multilineTextAlignment(.center)
        .foregroundStyle(.secondary)
    Button("Continue") {
        Task { await AVCaptureDevice.requestAccess(for: .video) }
    }
    .buttonStyle(.borderedProminent)
}
.padding()
```

**Important:** Don't add Not Now, Close, or Cancel, and don't title the button Allow. As of 2026, the HIG says either one can feel manipulative, and App Review rejects misleading pre-prompt screens for tracking.

### Send people to Settings

When access is off, explain what it's for and open your app's Settings page with `openSettingsURLString`.

```swift
@Environment(\.openURL) private var openURL

Button("Open Settings") {
    if let url = URL(string: UIApplication.openSettingsURLString) {
        openURL(url)
    }
}
```

## Related

[onboarding](onboarding.md), [launching](launching.md), [alert](alert.md), [entering-data](entering-data.md), [privacy-details](privacy-details.md)
