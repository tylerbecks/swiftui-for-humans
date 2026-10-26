---
id: delete-account
title: Delete Account
platforms: [iOS, iPadOS]
hig: https://developer.apple.com/design/human-interface-guidelines/managing-accounts.md
reviewed: October 2026
---

# Delete Account

If people can create an account in your app, they must be able to delete it there too.

## Rules

- **Put it where people look: account settings.** Apple asks for a deletion option that's easy to find, typically in your account settings. Don't bury it in the privacy policy or terms.
- **Delete the account, not just deactivate it.** You can offer a pause too, but deactivating or disabling alone doesn't meet the rule.
- **Don't send people to support.** Unless your app is in a highly regulated field like banking or health, you can't require a call, an email, or a chat. Asking for a code sent to their email or phone is fine.
- **Link straight to the web deletion page.** If deletion finishes on your website, link to that exact page, not your home page. Apple rejects flows that make deletion unnecessarily hard.
- **Say how long it takes, and confirm when it's done.** Manual deletion that takes a while is allowed, as long as people know what to expect and hear back at the end.

## Guide

### What Apple requires

As of 2026, App Review Guideline **5.1.1(v)** says that if your app supports account creation, people must be able to **start deleting their account from inside the app**. Deleting means removing the account and its personal data, except what you're legally required to keep.

**Note:** This includes accounts your app creates automatically, like guest accounts, and accounts people create through a link to your website. Supporting deletion only where the law requires it (GDPR, CCPA) isn't enough: it has to work for everyone.

### Why

People shared personal data with you to make the account. Letting them take it back, without hunting or emailing anyone, keeps that trust.

A complete flow: a row in Settings, a screen that says what happens, one confirmation, and a result. Tap **Delete Account** to walk through it.

### What to say

Keep each message short and specific:

• **What goes:** the account and everything in it, including posts and photos other people can see.

• **What stays:** anything the law makes you keep, and why.

• **Subscriptions:** billing continues through Apple until people cancel.

• **When:** how long it takes, and that you'll confirm when it's done.

**Note:** You may offer to schedule deletion for when a subscription ends, as long as people can also delete right away.

### Before you submit

- **Deletion starts inside the app**: Usually a Delete Account row in account settings. (`settings-screen` (swiftui-build skill))
- **It deletes, not deactivates**: The account and the personal data you don't have to keep.
- **No call, email, or chat needed**: Only highly regulated apps (5.1.1(ix)) may use a support flow.
- **Web flows get a direct link**: To the deletion page itself, not your home page or policy.
- **Shared content goes too**: Posts, photos, and reviews other people can see.
- **Subscriptions are explained**: Billing continues through Apple until people cancel. ([paywall](paywall.md))
- **People know when it's done**: Say how long it takes, then confirm.
- **Sign in with Apple tokens are revoked**: With the Sign in with Apple REST API. ([sign-in-with-apple](sign-in-with-apple.md))

## Variants

### The Settings row

Put a `NavigationLink` to the deletion screen in its own section at the bottom of your account settings.

```swift
Form {
    Section("Account") {
        LabeledContent("Email", value: "maya@example.com")
        Button("Sign Out") { signOut() }
    }
    Section {
        NavigationLink("Delete Account") {
            DeleteAccountView()
        }
        .foregroundStyle(.red)
    }
}
.navigationTitle("Account")
```

More variants, left out to keep this file short: The deletion screen.

## Related

`settings-screen` (swiftui-build skill), `confirmation-dialog` (swiftui-build skill), [sign-in-with-apple](sign-in-with-apple.md), [paywall](paywall.md)
