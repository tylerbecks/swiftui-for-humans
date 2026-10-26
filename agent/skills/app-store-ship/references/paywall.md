---
id: paywall
title: Paywall
platforms: [iOS, iPadOS]
availability: iOS 17.0+, macOS 14.0+, visionOS 1.0+
docs: https://developer.apple.com/documentation/storekit/subscriptionstoreview.md
hig: https://developer.apple.com/design/human-interface-guidelines/apple-in-app-purchase.md
reviewed: October 2026
---

# Paywall

Sell digital features with StoreKit's ready-made store views, and show what Apple requires.

## Contents

- Rules
- Pitfalls
- Guide
- Key APIs
- Variants
- Related

## Rules

- **Show the full price people will be billed.** The HIG asks for the total billing amount on every option. A monthly breakdown can sit next to it, not instead of it.
- **Say what happens when a free trial ends.** People need to know they'll be charged automatically, how much, and when.
- **Give existing customers a way back in.** The sign-up screen needs a way for current subscribers to sign in or restore purchases, plus links to your terms and privacy policy.
- **Use Apple's purchase sheet as it is.** The system confirms every purchase to prevent accidents. Don't copy it or change it.
- **Don't pitch a subscription to someone who has one.** They may think it lapsed. Check their status first, and make canceling easy to find in your settings.

## Pitfalls

- **Products load only when StoreKit can find them.** In Xcode, add a StoreKit configuration file and pick it in the scheme to test without App Store Connect.
- **Physical goods can't use In-App Purchase.** In-App Purchase is for digital content and features. Goods and services used outside the app, like groceries or tickets, need another payment method, such as Apple Pay or card entry (Guideline 3.1.3(e)).

## Guide

### What Apple requires

As of 2026, the App Review Guidelines say:

• **3.1.1:** to unlock features or content in your app, use In-App Purchase, not license keys, QR codes, or crypto. Purchases that can be restored need a way to restore them.

• **3.1.2:** an auto-renewable subscription must give ongoing value, last at least seven days, and work on all of the person's devices. Before asking people to subscribe, say clearly what they get for the price.

• **2.1(b):** your in-app purchases must be complete, visible to the reviewer, and working when you submit.

**Note:** There are exceptions for linking to other ways to pay, such as on the United States storefront and for “reader” apps. See Guidelines 3.1.1(a) and 3.1.3 before you rely on one.

### Why

People should know exactly what they'll pay and for how long before they tap Subscribe, and get back what they bought on a new phone.

### Before you submit

- **Digital unlocks use In-App Purchase**: Guideline 3.1.1, unless an exception applies.
- **Restore Purchases is easy to find**: On the paywall, and ideally in settings too.
- **Every option shows its price and length**: The total amount billed, localized by StoreKit.
- **Trials say what's charged after**: How long, then how much, billed automatically.
- **Terms and privacy links are there**: On the paywall and in your App Store metadata.
- **Purchases are ready for review**: Complete, visible, and working (2.1(b)).
- **Tested with StoreKit Testing**: Buy, cancel, and restore in Xcode first.
- **Account deletion covers billing**: Tell people their subscription continues until they cancel. ([delete-account](delete-account.md))

## Key APIs

`SubscriptionStoreView`, `ProductView(id:)`, `StoreView(ids:)`, `.storeButton(_:for:)`, `AppStore.sync()`, `.subscriptionStatusTask`, `.currentEntitlementTask`

## Variants

### A subscription paywall

`SubscriptionStoreView` loads a subscription group and draws the options, prices, buy button, and policy links for you.

```swift
import StoreKit

SubscriptionStoreView(groupID: "21482041") {
    VStack(spacing: 8) {
        Image(systemName: "fork.knife.circle.fill")
            .font(.system(size: 56))
            .foregroundStyle(.tint)
        Text("Recipes Pro")
            .font(.largeTitle.bold())
        Text("Unlimited recipes, meal plans, and shopping lists.")
            .multilineTextAlignment(.center)
    }
    .padding()
}
.storeButton(.visible, for: .restorePurchases)
.subscriptionStoreControlStyle(.picker)
```

**Note:** This catalog has no products to load, so the preview is a static drawing of a paywall like the one the code makes. The code is real StoreKit; run it with a StoreKit configuration file.

### One product

Use `ProductView(id:)` for a single purchase, like a lifetime unlock. Pick `.productViewStyle(.large)` for a hero card.

```swift
ProductView(id: "com.example.recipes.lifetime") {
    Image(systemName: "infinity.circle.fill")
        .font(.largeTitle)
        .foregroundStyle(.tint)
}
.productViewStyle(.compact)
```

More variants, left out to keep this file short: A small store, Your own Restore button, Unlock Pro when subscribed. Apple's docs: https://developer.apple.com/documentation/storekit/subscriptionstoreview.md

## Related

[delete-account](delete-account.md), [request-review](request-review.md), `onboarding` (swiftui-build skill), `settings-screen` (swiftui-build skill)
