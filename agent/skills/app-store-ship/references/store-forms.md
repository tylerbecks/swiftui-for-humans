---
id: store-forms
title: Other Required Forms
platforms: [iOS, iPadOS]
docs: https://developer.apple.com/help/app-store-connect/reference/app-information/app-information/
reviewed: October 2026
---

# Other Required Forms

Age rating, encryption, EU trader status, content rights, and the Xcode you need.

Also called: age rating, age rating questionnaire, parental controls, Made for Kids, export compliance, encryption, ITSAppUsesNonExemptEncryption, Digital Services Act, DSA, trader status.

## Rules

- **Answer the age questions honestly.** Guideline 2.3.6 warns that a wrong rating surprises customers and can draw attention from regulators.
- **Rate for what people can reach, not just what you made.** An in-app browser that can open any website makes the app 16+ on its own, and a social media feature makes it at least 13+.
- **Only show content you have the rights to.** Guideline 5.2.1 says not to use trademarks, copyrighted work, or patented ideas without permission.

## Pitfalls

- **Most of these live in App Information.** Open your app in App Store Connect and choose App Information under General in the sidebar.
- **Requirements change every year.** Check Apple's Upcoming Requirements page before you plan a release.

## Guide

Besides screenshots and privacy, App Store Connect asks a few more questions before you can submit. Each takes minutes, but a missing answer blocks your upload or keeps your app out of a region.

### Age rating

Answer the age rating questionnaire under **App Information**. It asks about in-app controls, capabilities like web access and chat, and how often mature content appears. Apple works out the rating from your answers.

As of 2026 the ratings are **4+**, **9+**, **13+**, **16+**, and **18+**. They show on devices running iOS 26 and later, and since January 31, 2026, you must answer the updated questions to submit updates. Some regions, like Australia, Brazil, and Korea, add their own.

**Important:** If people can browse to any website inside your app, that alone makes it 16+. Many apps add an in-app browser without realizing it.

**Note:** Choose **Made for Kids** only if your rating is 4+ or 9+. You can't undo it once App Review approves the app, and every update has to follow the Kids category rules.

### Encryption

Every upload goes to a server in the U.S., so U.S. export rules apply to any encryption in your app. Add this key to your Info.plist to answer the question once instead of on every upload:

```xml
<key>ITSAppUsesNonExemptEncryption</key>
<false/>
```

Use `false` if your app, and every library in it, uses no encryption or only exempt encryption. HTTPS through `URLSession` is usually exempt. Use `true` for your own encryption, then upload documents in App Store Connect and add the code Apple sends you as `ITSEncryptionExportComplianceCode`.

**Note:** Exempt encryption can still mean paperwork: you might need to send a year-end self-classification report to the U.S. government.

### EU trader status

The EU's Digital Services Act requires developers with apps on the EU App Store to declare whether they're a **trader**. Traders have their address, phone number, and email shown on their product page in the EU. Since February 17, 2025, apps without a trader status have been removed from the EU App Store until one is provided.

You decide whether you're a trader; Apple can't decide for you. Things that point to yes:

- Revenue: The app is paid, has in-app purchases, or shows ads.
- Promotion: You advertise or sell products or services through it.
- Tax: You're registered for VAT.
- Profession: You build it as part of your business or job.

**Note:** A hobbyist with no plan to make money may not be a trader. If you're unsure, ask a lawyer. The Account Holder or an Admin declares it under Business, on the Agreements tab.

### Content rights

In **App Information**, you say whether your app contains, shows, or accesses third-party content. If it does, you need the rights to that content in every country where you sell the app.

### Build with the current Xcode

- Xcode and SDK: Since April 28, 2026, uploads must be built with **Xcode 26** or later and the **iOS 26 SDK**.
- Minimum iOS: Since September 9, 2026, iPhone and iPad apps must target **iOS 13** or later.

### Before you submit

- **Age rating questionnaire answered**: Under App Information. Answer for the content people can reach.
- **Encryption answered in Info.plist**: Set `ITSAppUsesNonExemptEncryption` so uploads skip the question.
- **EU trader status declared**: Under Business > Agreements, if your app is on the EU App Store.
- **Content rights answered**: And the rights to any third-party content you show.
- **Built with Xcode 26 or later**: App Store Connect won't accept builds from older versions.
- **Privacy label and policy done**: Every app needs both, plus a manifest if it uses required reason APIs. ([privacy-details](privacy-details.md))
- **Screenshots uploaded**: iPhone, plus 13-inch iPad if you support iPad. ([screenshots](screenshots.md))

## Related

[privacy-details](privacy-details.md), [screenshots](screenshots.md), [accessibility-labels](accessibility-labels.md), [submission-checklist](submission-checklist.md), [releasing](releasing.md)
