---
id: app-icons
title: App Icons
platforms: [iOS, iPadOS, macOS]
availability: iOS 26.0+
docs: https://developer.apple.com/documentation/xcode/creating-your-app-icon-using-icon-composer.md
hig: https://developer.apple.com/design/human-interface-guidelines/app-icons.md
reviewed: October 2026
---

# App Icons

Design one layered icon that the system turns into every appearance and size.

Also called: app icon, icon, favicon, Icon Composer, .icon file, AppIcon, home screen icon, dark icon, tinted icon, clear icon.

## Rules

- **Build around one simple idea.** Pick a single shape that captures your app. Fine details turn to mush at small sizes and under the system's highlights and shadows.
- **Leave the words out.** Your app's name already sits under the icon, and text in the icon can't be read at small sizes or translated. A single letter is fine if it's part of your brand.
- **Hand over square, flat layers.** The system rounds the corners and adds highlights, shadows, and depth. Pre-rounded corners or baked-in effects clash with them and can leave jagged edges.
- **Keep the same features in every appearance.** Dark, clear, and tinted versions should be recognizably the same icon. Swapping elements makes your app hard to find when people change their Home Screen.
- **Draw it; don't photograph it.** Photos, screenshots, and copies of standard controls lose detail when small and split badly into layers. Make an illustration of the idea instead.

## Pitfalls

- **Older iOS versions are covered.** When your app supports releases before the Liquid Glass icon style, Xcode builds matching images for them from the same Icon Composer file at build time.
- **The `.icon` file replaces the asset catalog icon.** Once it's in your project, Xcode uses it instead of an `AppIcon` image set. Keep the asset catalog only if you want the old artwork on older releases.

## Guide

Since iOS 26, app icons are made of **layers** that the system renders in Liquid Glass, with highlights and depth that react to light and movement. You design one icon in **Icon Composer**, and iOS produces every size and every Home Screen appearance from that single file.

### How an icon is built

**Note:** Group your layers into at most four groups. Each group becomes a level of depth, and you can tune its glass effects together.

## Key APIs

- Icon Composer: Apple's tool for layered icons. Ships with Xcode.
- `AppIcon.icon`: The file you add to your Xcode project.
- `supportsAlternateIcons`: Whether the app can switch icons.
- `setAlternateIconName(_:)`: Switches to an alternate icon. UIKit only.

## Variants

### Let people pick an alternate icon

Call `setAlternateIconName` from a settings screen. SwiftUI has no equivalent, so this one is UIKit.

```swift
Button("Use Night Icon") {
    Task {
        guard UIApplication.shared.supportsAlternateIcons else { return }
        try? await UIApplication.shared.setAlternateIconName("NightIcon")
    }
}
```

**Important:** Each alternate icon needs its own dark, clear, and tinted versions, and App Review checks it like your main icon. List the extra icons in the target's Alternate App Icon Sets build setting.

## On macOS

A square, layered icon that the Mac rounds and finishes in Liquid Glass.

### Rules

- **Keep it simple.** Pick one idea that captures your app and draw it with a few bold shapes. Fine details get busy under the system's highlights and disappear at small sizes.
- **Leave out words.** Text in an icon isn't accessible or localized, and it's often too small to read. Add it only when it's essential to your brand; the app's name usually appears nearby.
- **Let the system add the effects.** The Mac adds highlights, shadows, refraction, and translucency that respond to the environment. Baked-in shadows, bevels, and glows fight with them and stay static.
- **Prefer illustrations to photos and screenshots.** Photos are full of detail that falls apart at small sizes and across appearances. Draw a simple picture of what matters instead, and don't copy your app's interface.
- **Keep it recognizable in every appearance.** People can switch their icons to dark, clear, or tinted. Keep the same shapes in each one, so your app is still easy to find.
- **Don't draw Apple hardware.** Apple's products are copyrighted, so don't reproduce a Mac, iPhone, or other device in your icon.

### Pitfalls

- **One Icon Composer file covers every size.** The system scales your icon down for small places, so you don't export a set of sizes anymore.
- **SF Symbols can't be part of your icon.** Apple's terms for SF Symbols don't allow them, or look-alikes, in app icons and logos. Draw your own shapes.

## Related

[liquid-glass](liquid-glass.md), [dark-mode](dark-mode.md), [sf-symbols](sf-symbols.md), [materials](materials.md), [color](color.md), `mac-screenshots` (app-store-ship skill)
