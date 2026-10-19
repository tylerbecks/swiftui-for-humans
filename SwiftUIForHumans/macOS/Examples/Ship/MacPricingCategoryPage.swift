import SwiftUI

extension ComponentPage {
    static let pricingCategory = ComponentPage(
        id: "pricing-category",
        title: "Pricing & Category",
        summary: "Set your Mac app's category in Xcode and App Store Connect, then its price and countries.",
        category: .appStoreConnect,
        kind: .reference,
        symbol: "tag",
        availability: [],
        docsURL: "https://developer.apple.com/documentation/bundleresources/information-property-list/lsapplicationcategorytype",
        aliases: [
            "LSApplicationCategoryType", "App Category", "INFOPLIST_KEY_LSApplicationCategoryType",
            "public.app-category", "primary category", "secondary category", "price", "price points",
            "base country", "storefronts", "availability", "pre-order", "free trial", "Paid Apps Agreement",
            "Guideline 2.3.5", "Guideline 3.1.1",
        ],
        related: ["universal-purchase", "mac-screenshots", "mac-app-review"],
        notes: [
            "**Categories decide where you show up.** On the Mac App Store, your primary category places the app when people browse or filter search results, and in the Categories tab.",
            "**Games get subcategories.** Choose Games and you can add up to two game subcategories, and Xcode has a value for each, like `…category.puzzle-games`.",
        ],
        sources: [
            "https://developer.apple.com/documentation/bundleresources/information-property-list/lsapplicationcategorytype",
            "https://developer.apple.com/documentation/xcode/build-settings-reference",
            "https://developer.apple.com/app-store/categories/",
            "https://developer.apple.com/help/app-store-connect/reference/app-information/app-information",
            "https://developer.apple.com/help/app-store-connect/manage-app-pricing/set-a-price",
            "https://developer.apple.com/help/app-store-connect/manage-your-apps-availability/manage-availability-for-your-app-on-the-app-store",
            "https://developer.apple.com/app-store/review/guidelines/#accurate-metadata",
            "https://developer.apple.com/app-store/review/guidelines/#in-app-purchase",
        ],
        reviewed: "October 2026"
    ) {
        VStack(spacing: 8) {
            Image(systemName: "tag")
                .font(.system(size: 30))
                .foregroundStyle(.tint)
            Text("public.app-category")
                .font(.caption2.monospaced())
                .foregroundStyle(.secondary)
        }
    } content: { page in
        MacPricingCategoryArticle(page: page)
    }
}

// MARK: - Page

private struct MacPricingCategoryArticle: View {
    let page: ComponentPage

    var body: some View {
        ArticlePage(page: page) {
            SectionTitle("Category: set it twice")
            Prose("Pick a primary and an optional secondary category in App Store Connect. A Mac app also declares its category in its `Info.plist` with `LSApplicationCategoryType`, and Apple says the primary category in App Store Connect should match it. Choose the one that best describes what the app does; Guideline **2.3.5** lets Apple change a category that's way off.")
            CategoryPicker()

            SectionTitle("Price")
            Prose("Set a price before you submit. A paid app needs the Account Holder to accept the **Paid Apps Agreement** first; until then, the app can only be free.")
            ConnectSteps(steps: [
                "In App Store Connect, open your app. Under **Monetization** in the sidebar, click **Pricing and Availability**.",
                "In **Price Schedule**, click **Add Pricing** and pick a base country or region.",
                "Pick a price. You can choose from 800 price points, or request 100 higher ones, up to $10,000.",
                "Review the prices Apple generated for the other 174 storefronts. Change any you want to manage yourself, then click **Next** and **Confirm**.",
            ])
            ConnectFacts(rows: [
                ("Your base price", "Never changed by Apple."),
                ("Other storefronts", "Apple adjusts them from time to time for taxes and exchange rates, and tells you first. Prices you set by hand stay as they are."),
                ("Universal Purchase", "One purchase covers every platform in the app record. See [Universal Purchase](catalog://universal-purchase)."),
            ])

            SectionTitle("Availability")
            Prose("Under **App Availability** on the same page, click **Set Up Availability** and choose one of three options:")
            ConnectFacts(rows: [
                ("All countries or regions", "All 175 App Store countries and regions, plus any added later."),
                ("Specific countries or regions", "Only the ones you pick, with an option to include new ones."),
                ("Publish as Pre-Order", "A release date, and the regions where people can order ahead."),
            ])

            SectionTitle("Unlocking features")
            Prose("Guideline **3.1.1** applies on the Mac too: unlock features with In-App Purchase, not license keys or codes of your own. To offer a free trial of a paid app, Apple describes a non-consumable in-app purchase at price tier 0 named like “14-day Trial”, and the app must say before the trial starts how long it lasts and what it costs afterward.")
        }
    }
}

// MARK: - Category picker

private enum MacCategory: String, CaseIterable, Identifiable {
    case business, developerTools = "developer-tools", education, entertainment, finance, games
    case graphicsDesign = "graphics-design", healthcareFitness = "healthcare-fitness", lifestyle
    case medical, music, news, photography, productivity, reference
    case socialNetworking = "social-networking", sports, travel, utilities, video, weather

    var id: Self { self }

    var identifier: String { "public.app-category.\(rawValue)" }

    /// A readable name made from the identifier.
    var name: String {
        rawValue
            .split(separator: "-")
            .map { $0.capitalized }
            .joined(separator: rawValue.contains("-") && self != .socialNetworking && self != .developerTools ? " & " : " ")
    }
}

/// Pick a category and see the Info.plist key and build setting for it.
private struct CategoryPicker: View {
    @State private var category = MacCategory.productivity

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Picker("Category", selection: $category) {
                ForEach(MacCategory.allCases) { category in
                    Text(category.name).tag(category)
                }
            }
            .frame(maxWidth: 300)
            Text("In `Info.plist`:")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            CodeBlock(code: """
            <key>LSApplicationCategoryType</key>
            <string>\(category.identifier)</string>
            """)
            Text("Or, with a generated `Info.plist`, as a build setting:")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            CodeBlock(code: "INFOPLIST_KEY_LSApplicationCategoryType = \(category.identifier)")
        }
        .padding(16)
        .cardStyle()
    }
}
