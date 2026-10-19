import SwiftUI

extension ComponentPage {
    static let shipStoreForms = ComponentPage(
        id: "store-forms",
        title: "Other Required Forms",
        summary: "Age rating, encryption, EU trader status, content rights, and the Xcode you need.",
        category: .appStoreConnect,
        kind: .reference,
        symbol: "list.bullet.clipboard",
        availability: [],
        docsURL: "https://developer.apple.com/help/app-store-connect/reference/app-information/app-information/",
        aliases: [
            "age rating", "age rating questionnaire", "parental controls",
            "Made for Kids", "export compliance", "encryption", "ITSAppUsesNonExemptEncryption",
            "Digital Services Act", "DSA", "trader status", "EU", "European Union",
            "content rights", "third-party content", "Xcode 26", "iOS 26 SDK", "SDK requirement",
            "minimum deployment target", "Guideline 2.3.6", "Guideline 5.2.1",
        ],
        related: ["privacy-details", "screenshots", "accessibility-labels", "submission-checklist", "releasing"],
        notes: [
            "**Most of these live in App Information.** Open your app in App Store Connect and choose App Information under General in the sidebar.",
            "**Requirements change every year.** Check Apple's Upcoming Requirements page before you plan a release.",
        ],
        guidelines: [
            Guideline(
                "Answer the age questions honestly.",
                "Guideline 2.3.6 warns that a wrong rating surprises customers and can draw attention from regulators."
            ),
            Guideline(
                "Rate for what people can reach, not just what you made.",
                "An in-app browser that can open any website makes the app 16+ on its own, and a social media feature makes it at least 13+."
            ),
            Guideline(
                "Only show content you have the rights to.",
                "Guideline 5.2.1 says not to use trademarks, copyrighted work, or patented ideas without permission."
            ),
        ],
        sources: [
            "https://developer.apple.com/help/app-store-connect/reference/app-information/age-ratings-values-and-definitions/",
            "https://developer.apple.com/help/app-store-connect/manage-app-information/set-an-app-age-rating/",
            "https://developer.apple.com/documentation/bundleresources/information-property-list/itsappusesnonexemptencryption",
            "https://developer.apple.com/documentation/security/complying-with-encryption-export-regulations",
            "https://developer.apple.com/help/app-store-connect/manage-compliance-information/manage-european-union-digital-services-act-trader-requirements/",
            "https://developer.apple.com/news/?id=einwn76m",
            "https://developer.apple.com/help/app-store-connect/reference/app-information/app-information/",
            "https://developer.apple.com/news/upcoming-requirements/",
            "https://developer.apple.com/app-store/review/guidelines/#accurate-metadata",
            "https://developer.apple.com/app-store/review/guidelines/#intellectual-property",
        ],
        reviewed: "October 2026"
    ) {
        FormsThumbnail()
    } content: { page in
        FormsArticle(page: page)
    }
}

// MARK: - Thumbnail

private struct FormsThumbnail: View {
    var body: some View {
        HStack(spacing: 6) {
            ForEach(["4+", "9+", "13+", "16+", "18+"], id: \.self) { rating in
                Text(rating)
                    .font(.caption.weight(.bold))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 4)
                    .overlay {
                        RoundedRectangle(cornerRadius: 5)
                            .strokeBorder(.secondary)
                    }
            }
        }
    }
}

// MARK: - Page

private struct FormsArticle: View {
    let page: ComponentPage

    var body: some View {
        ArticlePage(page: page) {
            Prose("Besides screenshots and privacy, App Store Connect asks a few more questions before you can submit. Each takes minutes, but a missing answer blocks your upload or keeps your app out of a region.")

            SectionTitle("Age rating")
                .id("age")
            Prose("Answer the age rating questionnaire under **App Information**. It asks about in-app controls, capabilities like web access and chat, and how often mature content appears. Apple works out the rating from your answers.")
            Prose("As of 2026 the ratings are **4+**, **9+**, **13+**, **16+**, and **18+**. They show on devices running iOS 26 and later, and since January 31, 2026, you must answer the updated questions to submit updates. Some regions, like Australia, Brazil, and Korea, add their own.")
            AgeRatingEstimator()
            Aside(.important, "If people can browse to any website inside your app, that alone makes it 16+. Many apps add an in-app browser without realizing it.")
            Aside(.note, "Choose **Made for Kids** only if your rating is 4+ or 9+. You can't undo it once App Review approves the app, and every update has to follow the Kids category rules.")

            SectionTitle("Encryption")
            Prose("Every upload goes to a server in the U.S., so U.S. export rules apply to any encryption in your app. Add this key to your Info.plist to answer the question once instead of on every upload:")
            CodeBlock(code: """
            <key>ITSAppUsesNonExemptEncryption</key>
            <false/>
            """)
            Prose("Use `false` if your app, and every library in it, uses no encryption or only exempt encryption. HTTPS through `URLSession` is usually exempt. Use `true` for your own encryption, then upload documents in App Store Connect and add the code Apple sends you as `ITSEncryptionExportComplianceCode`.")
            Aside(.note, "Exempt encryption can still mean paperwork: you might need to send a year-end self-classification report to the U.S. government.")

            SectionTitle("EU trader status")
                .id("trader")
            Prose("The EU's Digital Services Act requires developers with apps on the EU App Store to declare whether they're a **trader**. Traders have their address, phone number, and email shown on their product page in the EU. Since February 17, 2025, apps without a trader status have been removed from the EU App Store until one is provided.")
            Prose("You decide whether you're a trader; Apple can't decide for you. Things that point to yes:")
            ConnectFacts(rows: [
                ("Revenue", "The app is paid, has in-app purchases, or shows ads."),
                ("Promotion", "You advertise or sell products or services through it."),
                ("Tax", "You're registered for VAT."),
                ("Profession", "You build it as part of your business or job."),
            ])
            Aside(.note, "A hobbyist with no plan to make money may not be a trader. If you're unsure, ask a lawyer. The Account Holder or an Admin declares it under Business, on the Agreements tab.")

            SectionTitle("Content rights")
            Prose("In **App Information**, you say whether your app contains, shows, or accesses third-party content. If it does, you need the rights to that content in every country where you sell the app.")

            SectionTitle("Build with the current Xcode")
            ConnectFacts(rows: [
                ("Xcode and SDK", "Since April 28, 2026, uploads must be built with **Xcode 26** or later and the **iOS 26 SDK**."),
                ("Minimum iOS", "Since September 9, 2026, iPhone and iPad apps must target **iOS 13** or later."),
            ])

            SectionTitle("Before you submit")
                .id("checklist")
            Checklist(pageID: page.id, items: [
                ChecklistItem("age", "Age rating questionnaire answered", "Under App Information. Answer for the content people can reach."),
                ChecklistItem("encryption", "Encryption answered in Info.plist", "Set `ITSAppUsesNonExemptEncryption` so uploads skip the question."),
                ChecklistItem("trader", "EU trader status declared", "Under Business > Agreements, if your app is on the EU App Store."),
                ChecklistItem("rights", "Content rights answered", "And the rights to any third-party content you show."),
                ChecklistItem("xcode", "Built with Xcode 26 or later", "App Store Connect won't accept builds from older versions."),
                ChecklistItem("privacy", "Privacy label and policy done", "Every app needs both, plus a manifest if it uses required reason APIs.", page: "privacy-details"),
                ChecklistItem("shots", "Screenshots uploaded", "iPhone, plus 13-inch iPad if you support iPad.", page: "screenshots"),
            ])
        }
    }
}

// MARK: - Age rating estimator

private struct AgeRatingEstimator: View {
    private struct Item: Identifiable {
        let id: String
        let minimum: Int
    }

    /// A few questionnaire answers and the lowest rating each one leads to,
    /// from Apple's age rating definitions.
    private let items = [
        Item(id: "Ads, chat, or user-generated content", minimum: 4),
        Item(id: "Health or wellness tips", minimum: 9),
        Item(id: "Loot boxes", minimum: 9),
        Item(id: "A social media feed", minimum: 13),
        Item(id: "Occasional simulated gambling", minimum: 13),
        Item(id: "Browsing to any website", minimum: 16),
        Item(id: "Frequent realistic violence", minimum: 18),
    ]

    @State private var selected: Set<String> = []

    private var rating: Int {
        items.filter { selected.contains($0.id) }.map(\.minimum).max() ?? 4
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .center, spacing: 14) {
                Text("\(rating)+")
                    .font(.title.weight(.bold).monospacedDigit())
                    .contentTransition(.numericText(value: Double(rating)))
                    .frame(minWidth: 72, minHeight: 56)
                    .overlay {
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(.primary, lineWidth: 2)
                    }
                Text("The lowest rating these answers allow. Your other answers can raise it.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .animation(.smooth, value: rating)

            VStack(spacing: 0) {
                ForEach(items) { item in
                    if item.id != items[0].id {
                        Divider()
                    }
                    Toggle(isOn: binding(for: item.id)) {
                        HStack {
                            Text(item.id)
                                .font(.subheadline)
                            Spacer()
                            Text("\(item.minimum)+")
                                .font(.caption.weight(.semibold).monospacedDigit())
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
        }
        .padding(16)
        .cardStyle()
    }

    private func binding(for id: String) -> Binding<Bool> {
        Binding {
            selected.contains(id)
        } set: { isOn in
            if isOn { selected.insert(id) } else { selected.remove(id) }
        }
    }
}
