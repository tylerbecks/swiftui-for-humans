import StoreKit
import SwiftUI

extension ComponentPage {
    static let shipPaywall = ComponentPage(
        id: "paywall",
        title: "Paywall",
        summary: "Sell digital features with StoreKit's ready-made store views, and show what Apple requires.",
        category: .requiredByApple,
        kind: .reference,
        symbol: "creditcard",
        availability: ["iOS 17.0+", "macOS 14.0+", "visionOS 1.0+"],
        docsURL: "https://developer.apple.com/documentation/storekit/subscriptionstoreview",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/apple-in-app-purchase",
        aliases: [
            "Guideline 3.1.1", "Guideline 3.1.2", "Guideline 2.1(b)", "in-app purchase", "IAP", "subscription",
            "subscriptions", "StoreKit", "SubscriptionStoreView", "ProductView", "StoreView", "restore purchases",
            "free trial", "premium", "pro upgrade", "checkout", "Stripe", "RevenueCat", "upsell", "pricing page",
        ],
        related: ["delete-account", "request-review", "onboarding", "settings-screen"],
        notes: [
            "**Products load only when StoreKit can find them.** In Xcode, add a StoreKit configuration file and pick it in the scheme to test without App Store Connect.",
            "**Physical goods can't use In-App Purchase.** In-App Purchase is for digital content and features. Goods and services used outside the app, like groceries or tickets, need another payment method, such as Apple Pay or card entry (Guideline 3.1.3(e)).",
        ],
        api: [
            APIItem("`SubscriptionStoreView`", "A full subscription paywall for one subscription group."),
            APIItem("`ProductView(id:)`", "One product with its name, price, and buy button."),
            APIItem("`StoreView(ids:)`", "A list of products."),
            APIItem("`.storeButton(_:for:)`", "Shows Restore Purchases, Redeem Code, and more."),
            APIItem("`AppStore.sync()`", "Restores purchases. Call only from a tap."),
            APIItem("`.subscriptionStatusTask`", "Tells you if someone is subscribed."),
            APIItem("`.currentEntitlementTask`", "Tells you if someone owns a product."),
        ],
        guidelines: [
            Guideline(
                "Show the full price people will be billed.",
                "The HIG asks for the total billing amount on every option. A monthly breakdown can sit next to it, not instead of it.",
                good: "The yearly price is the big number.",
                bad: "Only a per-month figure, billed yearly in fine print."
            ) {
                PaywallPriceSample(isGood: true)
            } bad: {
                PaywallPriceSample(isGood: false)
            },
            Guideline(
                "Say what happens when a free trial ends.",
                "People need to know they'll be charged automatically, how much, and when.",
                good: "The trial length and the price after it.",
                bad: "A free trial with no price in sight."
            ) {
                PaywallTrialSample(isGood: true)
            } bad: {
                PaywallTrialSample(isGood: false)
            },
            Guideline(
                "Give existing customers a way back in.",
                "The sign-up screen needs a way for current subscribers to sign in or restore purchases, plus links to your terms and privacy policy."
            ),
            Guideline(
                "Use Apple's purchase sheet as it is.",
                "The system confirms every purchase to prevent accidents. Don't copy it or change it."
            ),
            Guideline(
                "Don't pitch a subscription to someone who has one.",
                "They may think it lapsed. Check their status first, and make canceling easy to find in your settings."
            ),
        ],
        sources: [
            "https://developer.apple.com/app-store/review/guidelines/#in-app-purchase",
            "https://developer.apple.com/app-store/review/guidelines/#subscriptions",
            "https://developer.apple.com/app-store/review/guidelines/#app-completeness",
            "https://developer.apple.com/design/human-interface-guidelines/apple-in-app-purchase",
            "https://developer.apple.com/documentation/storekit/subscriptionstoreview",
            "https://developer.apple.com/documentation/storekit/productview",
            "https://developer.apple.com/documentation/storekit/storeview",
            "https://developer.apple.com/documentation/storekit/appstore/sync()",
            "https://developer.apple.com/documentation/xcode/setting-up-storekit-testing-in-xcode",
        ],
        reviewed: "October 2026"
    ) {
        PaywallThumbnail()
    } content: { page in
        PaywallArticle(page: page)
    }
}

// MARK: - Article

private struct PaywallArticle: View {
    let page: ComponentPage

    var body: some View {
        ArticlePage(page: page) {
            VStack(alignment: .leading, spacing: 12) {
                SectionTitle("What Apple requires")
                Prose("As of 2026, the App Review Guidelines say:")
                VStack(alignment: .leading, spacing: 8) {
                    Prose("• **3.1.1:** to unlock features or content in your app, use In-App Purchase, not license keys, QR codes, or crypto. Purchases that can be restored need a way to restore them.")
                    Prose("• **3.1.2:** an auto-renewable subscription must give ongoing value, last at least seven days, and work on all of the person's devices. Before asking people to subscribe, say clearly what they get for the price.")
                    Prose("• **2.1(b):** your in-app purchases must be complete, visible to the reviewer, and working when you submit.")
                }
                .padding(.leading, 8)
                Aside(.note, "There are exceptions for linking to other ways to pay, such as on the United States storefront and for “reader” apps. See Guidelines 3.1.1(a) and 3.1.3 before you rely on one.")
            }

            VStack(alignment: .leading, spacing: 12) {
                SectionTitle("Why")
                Prose("People should know exactly what they'll pay and for how long before they tap Subscribe, and get back what they bought on a new phone.")
            }

            VStack(alignment: .leading, spacing: 28) {
                SectionTitle("In SwiftUI")

                ExampleCard(
                    title: "A subscription paywall",
                    caption: "`SubscriptionStoreView` loads a subscription group and draws the options, prices, buy button, and policy links for you.",
                    code: """
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
                    """,
                    minHeight: 600,
                    aside: Aside(.note, "This catalog has no products to load, so the preview is a static drawing of a paywall like the one the code makes. The code is real StoreKit; run it with a StoreKit configuration file.")
                ) {
                    PaywallMock()
                }

                ExampleCard(
                    title: "One product",
                    caption: "Use `ProductView(id:)` for a single purchase, like a lifetime unlock. Pick `.productViewStyle(.large)` for a hero card.",
                    code: """
                    ProductView(id: "com.example.recipes.lifetime") {
                        Image(systemName: "infinity.circle.fill")
                            .font(.largeTitle)
                            .foregroundStyle(.tint)
                    }
                    .productViewStyle(.compact)
                    """
                ) {
                    PaywallProductRow(symbol: "infinity.circle.fill", name: "Lifetime Unlock", detail: "Every Pro feature, forever.", price: "$49.99")
                        .frame(maxWidth: 360)
                }

                ExampleCard(
                    title: "A small store",
                    caption: "`StoreView(ids:)` lists several products, such as tips or packs, and adds columns when there's room.",
                    code: """
                    StoreView(ids: [
                        "com.example.recipes.tip.small",
                        "com.example.recipes.tip.large",
                    ])
                    .storeButton(.visible, for: .restorePurchases)
                    """
                ) {
                    VStack(spacing: 14) {
                        PaywallProductRow(symbol: "cup.and.saucer.fill", name: "Small Tip", detail: "Buy the team a coffee.", price: "$0.99")
                        PaywallProductRow(symbol: "birthday.cake.fill", name: "Large Tip", detail: "Buy the team a cake.", price: "$4.99")
                    }
                    .frame(maxWidth: 360)
                }

                ExampleCard(
                    title: "Your own Restore button",
                    caption: "In a custom paywall, call `AppStore.sync()` from a Restore Purchases button.",
                    code: """
                    Button("Restore Purchases") {
                        Task {
                            try? await AppStore.sync()
                        }
                    }
                    """,
                    aside: Aside(.important, "Call `sync()` only when someone taps the button: it asks them to sign in to the App Store. StoreKit already keeps purchases up to date on its own, including after a reinstall.")
                ) {
                    Button("Restore Purchases") {}
                        .font(.subheadline)
                }

                ExampleCard(
                    title: "Unlock Pro when subscribed",
                    caption: "`.subscriptionStatusTask(for:)` runs whenever the subscription status changes, so the app unlocks or locks right away.",
                    code: """
                    @State private var isPro = false

                    Text(isPro ? "Pro" : "Free")
                        .subscriptionStatusTask(for: "21482041") { taskState in
                            if let statuses = taskState.value {
                                isPro = statuses.contains { $0.state == .subscribed }
                            }
                        }
                    """,
                    aside: Aside(.note, "For a one-time purchase, use `.currentEntitlementTask(for:)` with the product ID instead.")
                ) {
                    Label("Pro", systemImage: "checkmark.seal.fill")
                        .font(.headline)
                        .foregroundStyle(.tint)
                }
            }

            VStack(alignment: .leading, spacing: 12) {
                SectionTitle("Before you submit")
                Checklist(pageID: page.id, items: [
                    ChecklistItem("iap", "Digital unlocks use In-App Purchase", "Guideline 3.1.1, unless an exception applies."),
                    ChecklistItem("restore", "Restore Purchases is easy to find", "On the paywall, and ideally in settings too."),
                    ChecklistItem("price", "Every option shows its price and length", "The total amount billed, localized by StoreKit."),
                    ChecklistItem("trial", "Trials say what's charged after", "How long, then how much, billed automatically."),
                    ChecklistItem("links", "Terms and privacy links are there", "On the paywall and in your App Store metadata."),
                    ChecklistItem("submitted", "Purchases are ready for review", "Complete, visible, and working (2.1(b))."),
                    ChecklistItem("tested", "Tested with StoreKit Testing", "Buy, cancel, and restore in Xcode first."),
                    ChecklistItem("deletion", "Account deletion covers billing", "Tell people their subscription continues until they cancel.", page: "delete-account"),
                ])
            }
            .id("checklist")
        }
    }
}

// MARK: - Mock paywall

private enum PaywallPlan: String, CaseIterable, Identifiable {
    case yearly, monthly
    var id: Self { self }
}

/// A drawing of a subscription paywall, shaped like `SubscriptionStoreView`
/// with a picker control style. Selecting a plan works; buying doesn't.
private struct PaywallMock: View {
    @State private var plan: PaywallPlan = .yearly
    @State private var tapped = false

    var body: some View {
        VStack(spacing: 12) {
            DeviceFrame(height: 540) {
                VStack(spacing: 0) {
                    HStack {
                        Spacer()
                        Image(systemName: "xmark")
                            .font(.footnote.weight(.bold))
                            .foregroundStyle(.secondary)
                            .frame(width: 30, height: 30)
                            .background(.fill.tertiary, in: .circle)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 18)

                    VStack(spacing: 8) {
                        Image(systemName: "fork.knife.circle.fill")
                            .font(.system(size: 52))
                            .foregroundStyle(.tint)
                        Text("Recipes Pro")
                            .font(.title.bold())
                        Text("Unlimited recipes, meal plans, and shopping lists.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.horizontal, 22)

                    Spacer(minLength: 12)

                    VStack(spacing: 10) {
                        planRow(.yearly, title: "Yearly", price: "$29.99/year", detail: "7 days free")
                        planRow(.monthly, title: "Monthly", price: "$3.99/month", detail: nil)

                        Button {
                            tapped = true
                        } label: {
                            Text(plan == .yearly ? "Try It Free" : "Subscribe")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        .padding(.top, 4)

                        Text(plan == .yearly ? "Free for 7 days, then $29.99 per year. Renews until canceled." : "$3.99 per month. Renews until canceled.")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)

                        HStack(spacing: 6) {
                            Text("Restore Purchases")
                            Text("·")
                            Text("Terms of Service")
                            Text("·")
                            Text("Privacy Policy")
                        }
                        .font(.caption2)
                        .foregroundStyle(.tint)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 22)
                }
            }
            Text(tapped ? "In your app, this opens Apple's purchase sheet." : "Pick a plan. Buying is simulated.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }

    private func planRow(_ value: PaywallPlan, title: String, price: String, detail: String?) -> some View {
        Button {
            withAnimation(.snappy) { plan = value }
        } label: {
            HStack(spacing: 10) {
                Image(systemName: plan == value ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(plan == value ? AnyShapeStyle(.tint) : AnyShapeStyle(.tertiary))
                VStack(alignment: .leading, spacing: 2) {
                    Text(title).font(.subheadline.weight(.semibold))
                    if let detail {
                        Text(detail).font(.caption).foregroundStyle(.secondary)
                    }
                }
                Spacer()
                Text(price)
                    .font(.subheadline.weight(.semibold))
                    .monospacedDigit()
            }
            .padding(12)
            .background(.fill.quinary, in: .rect(cornerRadius: 14))
            .overlay {
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(plan == value ? AnyShapeStyle(.tint) : AnyShapeStyle(.separator), lineWidth: plan == value ? 2 : 1)
            }
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
    }
}

/// A drawing of a compact `ProductView` row.
private struct PaywallProductRow: View {
    let symbol: String
    let name: String
    let detail: String
    let price: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: symbol)
                .font(.largeTitle)
                .foregroundStyle(.tint)
            VStack(alignment: .leading, spacing: 2) {
                Text(name).font(.headline)
                Text(detail).font(.subheadline).foregroundStyle(.secondary)
            }
            Spacer(minLength: 8)
            Button(price) {}
                .buttonStyle(.bordered)
                .buttonBorderShape(.capsule)
                .allowsHitTesting(false)
        }
    }
}

// MARK: - Guideline samples

private struct PaywallPriceSample: View {
    let isGood: Bool

    var body: some View {
        VStack(spacing: 4) {
            Text("Yearly")
                .font(.subheadline.weight(.semibold))
            if isGood {
                Text("$29.99/year")
                    .font(.title2.bold())
                Text("Just $2.50/month")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                Text("$2.50/mo")
                    .font(.title2.bold())
                Text("billed annually")
                    .font(.system(size: 8))
                    .foregroundStyle(.tertiary)
            }
        }
        .frame(width: 200)
        .padding(.vertical, 14)
        .background(.fill.quinary, in: .rect(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14).strokeBorder(.separator)
        }
    }
}

private struct PaywallTrialSample: View {
    let isGood: Bool

    var body: some View {
        VStack(spacing: 8) {
            Text(isGood ? "Try It Free" : "Start Free Trial")
                .font(.headline)
                .frame(width: 220)
                .padding(.vertical, 12)
                .foregroundStyle(.white)
                .background(.tint, in: .capsule)
            if isGood {
                Text("Free for 7 days, then $29.99 per year.\nRenews until canceled.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            } else {
                Text("No commitment!")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - Thumbnail

private struct PaywallThumbnail: View {
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: "fork.knife.circle.fill")
                .font(.title)
                .foregroundStyle(.tint)
            Text("Recipes Pro").font(.subheadline.bold())
            HStack(spacing: 6) {
                Text("Yearly").font(.caption2.weight(.semibold))
                Spacer()
                Text("$29.99").font(.caption2.weight(.semibold))
            }
            .padding(8)
            .frame(width: 160)
            .overlay {
                RoundedRectangle(cornerRadius: 10).strokeBorder(.tint, lineWidth: 1.5)
            }
            Text("Subscribe")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white)
                .frame(width: 160, height: 26)
                .background(.tint, in: .capsule)
        }
    }
}
