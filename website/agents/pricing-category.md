---
id: pricing-category
title: Pricing & Category
platforms: [macOS]
docs: https://developer.apple.com/documentation/bundleresources/information-property-list/lsapplicationcategorytype.md
reviewed: October 2026
---

# Pricing & Category

Set your Mac app's category in Xcode and App Store Connect, then its price and countries.

Also called: LSApplicationCategoryType, App Category, INFOPLIST_KEY_LSApplicationCategoryType, public.app-category, primary category, secondary category, price, price points, base country, storefronts.

## Pitfalls

- **Categories decide where you show up.** On the Mac App Store, your primary category places the app when people browse or filter search results, and in the Categories tab.
- **Games get subcategories.** Choose Games and you can add up to two game subcategories, and Xcode has a value for each, like `…category.puzzle-games`.

## Guide

Before you submit, App Store Connect needs a primary category, a price, and the countries or regions where the app is sold. A Mac app also names its category in Xcode.

### Category: set it twice

Pick a primary and an optional secondary category in App Store Connect. A Mac app also declares its category in its `Info.plist` with `LSApplicationCategoryType`, and Apple says the primary category in App Store Connect should match it. Choose the one that best describes what the app does; Guideline **2.3.5** lets Apple change a category that's way off.

```xml
<key>LSApplicationCategoryType</key>
<string>public.app-category.productivity</string>
```

```swift
INFOPLIST_KEY_LSApplicationCategoryType = public.app-category.productivity
```

### Price

Set a price before you submit. A paid app needs the Account Holder to accept the **Paid Apps Agreement** first; until then, the app can only be free.

1. In App Store Connect, open your app. Under **Monetization** in the sidebar, click **Pricing and Availability**.
2. In **Price Schedule**, click **Add Pricing** and pick a base country or region.
3. Pick a price. You can choose from 800 price points, or request 100 higher ones, up to $10,000.
4. Review the prices Apple generated for the other 174 storefronts. Change any you want to manage yourself, then click **Next** and **Confirm**.

- Your base price: Never changed by Apple.
- Other storefronts: Apple adjusts them from time to time for taxes and exchange rates, and tells you first. Prices you set by hand stay as they are.
- Universal Purchase: One purchase covers every platform in the app record. See [Universal Purchase](universal-purchase.md).

### Availability

Under **App Availability** on the same page, click **Set Up Availability** and choose one of three options:

- All countries or regions: All 175 App Store countries and regions, plus any added later.
- Specific countries or regions: Only the ones you pick, with an option to include new ones.
- Publish as Pre-Order: A release date, and the regions where people can order ahead.

### Unlocking features

Guideline **3.1.1** applies on the Mac too: unlock features with In-App Purchase, not license keys or codes of your own. To offer a free trial of a paid app, Apple describes a non-consumable in-app purchase at price tier 0 named like “14-day Trial”, and before the trial starts the app must say how long it lasts, what stops working when it ends, and what the full version costs.

## Related

[universal-purchase](universal-purchase.md), [mac-screenshots](mac-screenshots.md), [mac-app-review](mac-app-review.md)
