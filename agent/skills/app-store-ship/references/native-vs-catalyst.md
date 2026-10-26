---
id: native-vs-catalyst
title: Native, Catalyst, or iPad App
platforms: [macOS]
docs: https://developer.apple.com/documentation/xcode/configuring-a-multiplatform-app-target.md
hig: https://developer.apple.com/design/human-interface-guidelines/designing-for-macos.md
reviewed: October 2026
---

# Native, Catalyst, or iPad App

Three ways onto the Mac: a native Mac app, Mac Catalyst, or your iPad app as it is.

Also called: Mac Catalyst, Catalyst, UIKit for Mac, Designed for iPad, iPad app on Mac, iOS apps on Mac, Apple silicon, multiplatform, supported destinations, port to Mac.

## Rules

- **Check that your app makes sense on a Mac.** Apps that depend on a gyroscope, an accelerometer, the rear camera, HealthKit, or ARKit, or that exist mainly for marking up, handwriting, or navigation, may not suit the Mac.
- **Don't offer two versions on the Mac.** Apple lists an existing Mac version, built with AppKit or Catalyst, as a reason to stop offering your iPad app on the Mac.
- **Whichever path you pick, design for the Mac.** Even with Catalyst, Apple says to go beyond showing your iPad layout in a Mac window: menus, toolbars, and resizable windows are what people expect.

## Pitfalls

- **Your iPad app may already be on the Mac App Store.** Apple offers compatible iPhone and iPad apps on Macs with Apple silicon unless you turn that off in App Store Connect.
- **A native Mac app replaces it.** If your iPad app is on the Mac App Store and you add the macOS platform, releasing the Mac app takes its place, and existing users move to the Mac app.
- **Catalyst adds the sandbox for you.** Turning on Mac Catalyst adds the App Sandbox entitlement to the Mac build only.

## Guide

In Xcode, an app target's **Supported Destinations** offers three kinds of Mac destination. Each one is a different way to get onto the Mac, with different work and a different result.

### Compare the three

- What it is: A new Mac app built against the macOS SDK. It's the default Mac destination for multiplatform apps.
- Built with: SwiftUI and AppKit, with every macOS API available.
- Looks like: A Mac app: checkboxes, pop-up buttons, the menu bar, and Mac sizes.
- App Store: Add the macOS platform to your app record to sell it with your iOS app as one purchase.

### Which one to pick

- Your app is SwiftUI, or it's new: **Mac.** Apple suggests one multiplatform target when you use SwiftUI on both platforms. You get every macOS API, and the controls are real Mac controls.
- You have a large UIKit iPad app: **Mac Catalyst.** You keep one codebase and build it for the Mac, then adjust menus, toolbars, and layout.
- You want something on the Mac today: **Designed for iPad.** No porting at all, but it only runs on Macs with Apple silicon and keeps the iPad's look.
- UIKit on iPad, AppKit on the Mac: **Mac**, in its own target. Apple suggests separate targets when the two apps share little code.

### Catalyst's two looks

A Catalyst app starts with **Scale Interface to Match iPad**: iPad views and text shrink to 77%, so 17-point body text shows at 13 points. Switch to **Optimize Interface for Mac** for full-size text, sharper artwork, and controls that look and behave like AppKit's, then plan time to fix the layout.

**Important:** In the Mac idiom, a few UIKit controls change or go away. `UIPageControl` isn't available, and showing it throws an exception.

## Variants

### Add Mac-only scenes

In a multiplatform target, one `App` serves every platform, and `#if os(macOS)` adds Mac-only scenes like `Settings`.

```swift
@main
struct TripsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        #if os(macOS)
        Settings {
            SettingsView()
        }
        #endif
    }
}
```

**Note:** Apple's own example adds a `MenuBarExtra` the same way. Use `#if canImport(ARKit)` for a framework the Mac doesn't have.

## Related

[great-mac-app](great-mac-app.md), [ipad-app-in-window](ipad-app-in-window.md), [universal-purchase](universal-purchase.md), [app-sandbox](app-sandbox.md)
