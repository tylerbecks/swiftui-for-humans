import SwiftUI

extension ComponentPage {
    static let shipRejectionGuide = ComponentPage(
        id: "rejection-guide",
        title: "Common Rejections",
        summary: "The guidelines apps break most often, what each means, and how to fix it.",
        category: .startHere,
        kind: .reference,
        symbol: "xmark.seal",
        availability: [],
        docsURL: nil,
        aliases: [
            "rejected", "rejection", "app store rejection", "why was my app rejected",
            "app review guidelines", "guideline numbers", "metadata rejected",
            "Guideline 2.1", "Guideline 2.3", "Guideline 2.3.3", "Guideline 3.1.1",
            "Guideline 4.0", "Guideline 4.2", "Guideline 4.2.2", "Guideline 4.3",
            "Guideline 4.8", "Guideline 5.1.1", "Guideline 5.1.1(ii)", "Guideline 5.1.1(v)",
            "app completeness", "accurate metadata", "minimum functionality", "spam",
            "login services", "data collection", "in-app purchase",
        ],
        related: ["submission-checklist", "app-review", "native-not-web", "states-check"],
        notes: [
            "**The rejection message names the guideline.** Start with that number, fix everything it lists, and reply in App Store Connect if anything is unclear.",
            "**The guidelines change.** Apple calls them a living document. As of October 2026, the latest update is dated June 8, 2026.",
        ],
        sources: [
            "https://developer.apple.com/app-store/review/guidelines/",
            "https://developer.apple.com/distribute/app-review/",
            "https://www.apple.com/legal/app-store/transparency/2025/",
        ],
        reviewed: "October 2026"
    ) {
        RejectionThumbnail()
    } content: { page in
        RejectionArticle(page: page)
    }
}

// MARK: - Data

/// Rejections by App Review Guidelines section, from Apple's 2025 App Store
/// Transparency Report.
private struct RejectionSection: Identifiable {
    let name: String
    let count: Int
    let color: Color
    var id: String { name }

    static let all: [RejectionSection] = [
        RejectionSection(name: "Performance", count: 1_354_418, color: .orange),
        RejectionSection(name: "Legal", count: 495_673, color: .purple),
        RejectionSection(name: "Design", count: 415_532, color: .blue),
        RejectionSection(name: "Business", count: 283_820, color: .green),
        RejectionSection(name: "Safety", count: 151_159, color: .red),
    ]
}

private struct RejectionItem: Identifiable {
    let number: String
    let title: String
    let section: String
    let meaning: String
    let fix: String
    let pageID: String?
    var id: String { number }

    static let all: [RejectionItem] = [
        RejectionItem(
            number: "2.1", title: "App Completeness", section: "Performance",
            meaning: "The app crashes, shows placeholder content, has broken links, or the reviewer can't get in. Apple says it's behind over 40% of unresolved issues.",
            fix: "Test on a device, remove placeholders, add a working demo account, and keep your servers on during review.",
            pageID: "states-check"
        ),
        RejectionItem(
            number: "2.3", title: "Accurate Metadata", section: "Performance",
            meaning: "The description, screenshots, previews, or privacy answers don't match what the app really does.",
            fix: "Describe only features that exist. Screenshots must show the app in use, not just a splash or login screen (2.3.3).",
            pageID: nil
        ),
        RejectionItem(
            number: "3.1.1", title: "In-App Purchase", section: "Business",
            meaning: "The app unlocks features or content without In-App Purchase, for example with license keys or QR codes.",
            fix: "Sell digital content with In-App Purchase and give people a way to restore restorable purchases.",
            pageID: "paywall"
        ),
        RejectionItem(
            number: "4.0", title: "Design", section: "Design",
            meaning: "The interface falls below Apple's minimum standards for a clean, refined, easy-to-use app.",
            fix: "Plan the design carefully and follow the Human Interface Guidelines, starting with system navigation and controls.",
            pageID: "native-not-web"
        ),
        RejectionItem(
            number: "4.2", title: "Minimum Functionality", section: "Design",
            meaning: "The app is a repackaged website, mostly marketing, or a collection of links, without enough to do.",
            fix: "Add real native features and content that make it more useful than the website.",
            pageID: "native-not-web"
        ),
        RejectionItem(
            number: "4.3", title: "Spam", section: "Design",
            meaning: "You submitted several copies of the same app, or one that's no different from many already on the store.",
            fix: "Combine variants into one app, and make sure yours offers something meaningfully different.",
            pageID: nil
        ),
        RejectionItem(
            number: "4.8", title: "Login Services", section: "Design",
            meaning: "The app uses a third-party or social login for the main account without an equivalent private option.",
            fix: "Also offer a login that limits data to name and email, lets people hide their email, and doesn't track for ads without consent, such as Sign in with Apple.",
            pageID: "sign-in-with-apple"
        ),
        RejectionItem(
            number: "5.1.1", title: "Data Collection and Storage", section: "Legal",
            meaning: "Missing privacy policy, unclear permission requests, or collecting more data than the feature needs.",
            fix: "Link a privacy policy in the app and in App Store Connect, and explain every permission in its purpose string.",
            pageID: "privacy-details"
        ),
        RejectionItem(
            number: "5.1.1(v)", title: "Account Sign-In", section: "Legal",
            meaning: "The app forces a login it doesn't need, or lets people create an account but not delete it.",
            fix: "Let people use non-account features without signing in, and offer account deletion inside the app.",
            pageID: "delete-account"
        ),
    ]
}

// MARK: - Thumbnail

private struct RejectionThumbnail: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(["2.1", "4.2", "5.1.1(v)"], id: \.self) { number in
                HStack(spacing: 8) {
                    RejectionNumberChip(number: number)
                    Capsule()
                        .fill(.quaternary)
                        .frame(width: number == "2.1" ? 90 : 60, height: 8)
                }
            }
        }
    }
}

private struct RejectionNumberChip: View {
    let number: String

    var body: some View {
        Text(number)
            .font(.subheadline.monospaced().weight(.semibold))
            .foregroundStyle(.red)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(.red.opacity(0.12), in: .capsule)
            .fixedSize()
    }
}

// MARK: - Page

private struct RejectionArticle: View {
    let page: ComponentPage

    var body: some View {
        ArticlePage(page: page) {
            Prose("Every rejection message cites one or more numbered App Review Guidelines. A few numbers come up again and again. Find yours below, then fix the cause, not just the symptom.")

            SectionTitle("How often apps are rejected")
            Prose("In 2025, Apple reviewed **9,100,620** app submissions and rejected **2,093,244** of them. Performance problems, the section that includes 2.1, led by far:")
            RejectionChart()
            Aside(.note, "One submission can break several guidelines, so the sections add up to more than the total. The Design section covers copycats, minimum functionality, and spam.")

            SectionTitle("The usual suspects")
            Prose("Tap a guideline to see what it means and how to fix it.")
            RejectionList()
        }
    }
}

private struct RejectionChart: View {
    var body: some View {
        let maximum = Double(RejectionSection.all.map(\.count).max() ?? 1)
        VStack(alignment: .leading, spacing: 12) {
            ForEach(RejectionSection.all) { section in
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(section.name)
                            .font(.subheadline.weight(.medium))
                        Spacer()
                        Text(section.count, format: .number)
                            .font(.subheadline.monospacedDigit())
                            .foregroundStyle(.secondary)
                    }
                    GeometryReader { proxy in
                        Capsule()
                            .fill(section.color.gradient)
                            .frame(width: max(6, proxy.size.width * Double(section.count) / maximum))
                    }
                    .frame(height: 10)
                }
                .accessibilityElement(children: .combine)
            }
            Text("Rejections by guideline section, 2025. Source: Apple's App Store Transparency Report.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle()
    }
}

private struct RejectionList: View {
    @State private var expanded: Set<String> = ["2.1"]

    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(RejectionItem.all.enumerated()), id: \.element.id) { index, item in
                if index > 0 {
                    Divider().padding(.leading, 16)
                }
                RejectionRow(item: item, isExpanded: Binding {
                    expanded.contains(item.id)
                } set: { isOn in
                    withAnimation(.snappy) {
                        if isOn { expanded.insert(item.id) } else { expanded.remove(item.id) }
                    }
                })
            }
        }
        .cardStyle()
    }
}

private struct RejectionRow: View {
    let item: RejectionItem
    @Binding var isExpanded: Bool
    @Environment(\.openPage) private var openPage

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button {
                isExpanded.toggle()
            } label: {
                HStack(spacing: 10) {
                    RejectionNumberChip(number: item.number)
                        .frame(minWidth: 92, alignment: .leading)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.title)
                            .font(.body.weight(.semibold))
                            .foregroundStyle(.primary)
                        Text(item.section)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Image(systemName: "chevron.down")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.tertiary)
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                }
                .contentShape(.rect)
            }
            .buttonStyle(.plain)
            .accessibilityValue(isExpanded ? "Expanded" : "Collapsed")

            if isExpanded {
                VStack(alignment: .leading, spacing: 10) {
                    labeled("What it means", item.meaning)
                    labeled("How to fix it", item.fix)
                    if let pageID = item.pageID, let target = Catalog.page(id: pageID) {
                        Button {
                            openPage(target.id)
                        } label: {
                            Text("Read: \(target.title) \(Image(systemName: "chevron.right"))")
                        }
                        .font(.subheadline.weight(.medium))
                    }
                }
                .transition(.opacity)
            }
        }
        .padding(16)
    }

    private func labeled(_ title: String, _ text: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.secondary)
            RichText(text)
                .font(.subheadline)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
