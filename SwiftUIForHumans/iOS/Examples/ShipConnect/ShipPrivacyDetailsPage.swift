import SwiftUI

extension ComponentPage {
    static let shipPrivacyDetails = ComponentPage(
        id: "privacy-details",
        title: "Privacy Details",
        summary: "Tell Apple what data your app collects, and why it uses certain APIs.",
        category: .appStoreConnect,
        kind: .reference,
        symbol: "hand.raised",
        availability: [],
        docsURL: "https://developer.apple.com/documentation/bundleresources/privacy-manifest-files",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/privacy",
        aliases: [
            "privacy nutrition label", "privacy label", "app privacy", "data collection",
            "privacy manifest", "PrivacyInfo.xcprivacy", "xcprivacy", "required reason API",
            "NSPrivacyAccessedAPITypes", "UserDefaults", "AppStorage", "CA92.1",
            "third-party SDK", "SDK signature", "tracking", "privacy policy", "GDPR",
            "Guideline 5.1.1", "Guideline 5.1.1(i)", "Guideline 5.1.2",
        ],
        related: ["settings-screen", "requesting-permission", "store-forms", "submission-checklist", "rejection-guide"],
        notes: [
            "**You can change your answers without an update.** Edit App Privacy whenever your data use changes; it isn't tied to a build.",
            "**Purpose strings count too.** Guideline 5.1.1(ii) says each permission prompt must explain clearly and completely how you use the data.",
        ],
        api: [
            APIItem("`PrivacyInfo.xcprivacy`", "The privacy manifest file in your target."),
            APIItem("`NSPrivacyAccessedAPITypes`", "Required reason APIs and why you use them."),
            APIItem("`NSPrivacyCollectedDataTypes`", "Data your code or SDK collects."),
            APIItem("`NSPrivacyTracking`", "Whether you use data for tracking."),
            APIItem("`Link`", "Opens your privacy policy in Safari."),
        ],
        guidelines: [
            Guideline(
                "Make the privacy policy easy to find.",
                "Guideline 5.1.1(i) wants a link in App Store Connect and inside the app. A row in Settings is the usual place.",
                good: "A Privacy Policy row in Settings.",
                bad: "No way to reach the policy in the app."
            ) {
                PrivacySettingsSample(showsPolicy: true)
            } bad: {
                PrivacySettingsSample(showsPolicy: false)
            },
            Guideline(
                "Ask only for data you need.",
                "Guideline 5.1.1(iii) and the HIG both say to collect only what a feature needs. Prefer a system picker over full access to Photos or Contacts."
            ),
            Guideline(
                "Get permission before you share data, including with AI.",
                "Guideline 5.1.2(i) says to disclose where personal data goes, including third-party AI services, and get explicit permission first."
            ),
            Guideline(
                "Don't lock features behind a permission.",
                "Under 5.1.2(i), you can't require people to allow notifications, location, or tracking to use your app."
            ),
        ],
        sources: [
            "https://developer.apple.com/app-store/review/guidelines/#data-collection-and-storage",
            "https://developer.apple.com/app-store/review/guidelines/#data-use-and-sharing",
            "https://developer.apple.com/app-store/app-privacy-details/",
            "https://developer.apple.com/help/app-store-connect/manage-app-information/manage-app-privacy/",
            "https://developer.apple.com/documentation/bundleresources/privacy-manifest-files",
            "https://developer.apple.com/documentation/bundleresources/describing-use-of-required-reason-api",
            "https://developer.apple.com/documentation/bundleresources/app-privacy-configuration/nsprivacyaccessedapitypes/nsprivacyaccessedapitype",
            "https://developer.apple.com/support/third-party-SDK-requirements/",
            "https://developer.apple.com/documentation/swiftui/appstorage",
            "https://developer.apple.com/design/human-interface-guidelines/privacy",
        ],
        reviewed: "October 2026"
    ) {
        PrivacyThumbnail()
    } content: { page in
        PrivacyArticle(page: page)
    }
}

// MARK: - Thumbnail

private struct PrivacyThumbnail: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label("Linked to you", systemImage: "person.circle")
            Label("Not linked to you", systemImage: "eye.slash")
        }
        .font(.caption.weight(.medium))
        .padding(12)
        .background(.fill.tertiary, in: .rect(cornerRadius: 12))
    }
}

// MARK: - Page

private struct PrivacyArticle: View {
    let page: ComponentPage

    var body: some View {
        ArticlePage(page: page) {
            Prose("Apple needs three privacy pieces before your app ships: a **privacy policy** link (Guideline 5.1.1(i)), **App Privacy answers** in App Store Connect, which become the privacy label on your product page, and a **privacy manifest** if your code or SDKs use certain APIs.")
            Prose("People read the label before they download, and the manifest stops apps from quietly fingerprinting devices.")

            SectionTitle("The privacy label")
                .id("label")
            Prose("You answer questions about each type of data you or your SDKs collect. **Collect** means sending data off the device and keeping it longer than it takes to handle the request. Data that never leaves the device doesn't count.")
            PrivacyQuiz()
            Aside(.important, "SDKs count as yours. If an analytics or ad SDK collects data, you declare it, even if you never look at that data.")

            SectionTitle("Fill it in")
            ConnectSteps(steps: [
                "In App Store Connect, open your app and choose **App Privacy** in the sidebar.",
                "Click **Get Started** and say whether you or your partners collect data.",
                "Pick every data type you collect, then answer how each one is used, whether it's linked to the person, and whether it's used for tracking.",
                "Next to **Privacy Policy**, click Edit and enter your policy's URL.",
                "Click **Publish**. The label appears on your product page.",
            ])

            SectionTitle("The privacy manifest")
                .id("manifest")
            Prose("`PrivacyInfo.xcprivacy` is a property list in your app target. In Xcode, choose File > New File and pick **App Privacy**. It lists the data you collect, your tracking domains, and any **required reason APIs** you call, with a code for why.")
            CodeBlock(code: """
            <?xml version="1.0" encoding="UTF-8"?>
            <plist version="1.0">
            <dict>
                <key>NSPrivacyTracking</key>
                <false/>
                <key>NSPrivacyAccessedAPITypes</key>
                <array>
                    <dict>
                        <key>NSPrivacyAccessedAPIType</key>
                        <string>NSPrivacyAccessedAPICategoryUserDefaults</string>
                        <key>NSPrivacyAccessedAPITypeReasons</key>
                        <array>
                            <string>CA92.1</string>
                        </array>
                    </dict>
                </array>
            </dict>
            </plist>
            """)
            Aside(.important, "`@AppStorage` reads and writes `UserDefaults`, so almost every SwiftUI app needs this entry. `CA92.1` means only your app reads and writes the values. Since May 1, 2024, App Store Connect doesn't accept uploads that use these APIs without a declared reason.")

            SectionTitle("Required reason APIs")
            Prose("These are the five categories, with the reason most apps use. Pick the code that matches what your app actually does; Apple's docs list the rest.")
            ConnectFacts(rows: [
                ("User defaults", "`CA92.1`: your own app's settings. Use `1C8F.1` for an App Group."),
                ("File timestamps", "`C617.1`: files in your app's container."),
                ("System boot time", "`35F9.1`: measuring time between events."),
                ("Disk space", "`E174.1`: checking for room before writing."),
                ("Active keyboards", "`54BD.1`: adapting your UI to the keyboard."),
            ])

            SectionTitle("Third-party SDKs")
            Prose("Each SDK reports its own data use and required reason APIs in its own manifest; it can't rely on yours. Xcode combines all the manifests into one report to help you fill in the label.")
            Aside(.note, "Apple keeps a list of commonly used SDKs, such as Firebase modules, Alamofire, and SDWebImage. A new app, or an update that adds one, must include that SDK's manifest, and a signature if you add it as a binary.")

            SectionTitle("Link the policy in your app")
            ExampleCard(
                title: "Privacy policy row",
                caption: "Use `Link` in your settings screen; it opens the policy in Safari.",
                code: """
                Form {
                    Section("About") {
                        Link("Privacy Policy", destination: URL(string: "https://example.com/privacy")!)
                    }
                }
                """
            ) {
                Form {
                    Section("About") {
                        Link("Privacy Policy", destination: URL(string: "https://example.com/privacy")!)
                    }
                }
                .scrollDisabled(true)
                .frame(height: 140)
            }

            SectionTitle("Before you submit")
                .id("checklist")
            Checklist(pageID: page.id, items: [
                ChecklistItem("policy-url", "Privacy policy URL in App Store Connect", "It's required for every app."),
                ChecklistItem("policy-in-app", "Privacy policy link in the app", "Somewhere easy to find, like Settings.", page: "settings-screen"),
                ChecklistItem("label", "App Privacy answers published", "Include data your SDKs collect."),
                ChecklistItem("manifest", "Privacy manifest in your target", "`PrivacyInfo.xcprivacy`, with a reason for each required reason API."),
                ChecklistItem("sdks", "SDK manifests included", "Update SDKs on Apple's list to versions that ship one."),
                ChecklistItem("purpose", "A clear purpose string for each permission", "Say what you use the data for.", page: "requesting-permission"),
            ])
        }
    }
}

// MARK: - Quiz

private struct PrivacyQuiz: View {
    private struct Case: Identifiable {
        let id: String
        let isCollected: Bool
        let answer: String
    }

    private let cases = [
        Case(id: "Settings saved with @AppStorage", isCollected: false,
             answer: "It stays on the device, so it isn't collected."),
        Case(id: "Location used on device to sort results", isCollected: false,
             answer: "Processed only on the device, so you don't declare it."),
        Case(id: "Email address used to sign in", isCollected: true,
             answer: "Declare Email Address, linked to the person, used for App Functionality."),
        Case(id: "Crash reports sent to an analytics SDK", isCollected: true,
             answer: "Declare Crash Data under Diagnostics. The SDK collects it for you."),
        Case(id: "Ad SDK that shares a device ID with ad networks", isCollected: true,
             answer: "Declare Device ID, used for Third-Party Advertising and for tracking."),
        Case(id: "Login token sent with each request, not stored", isCollected: false,
             answer: "Data you discard right after handling a request isn't collected."),
    ]

    @State private var selection = "Email address used to sign in"

    var body: some View {
        let current = cases.first { $0.id == selection } ?? cases[0]
        VStack(alignment: .leading, spacing: 14) {
            Text("Do I declare it?")
                .font(.headline)
            Picker("Situation", selection: $selection) {
                ForEach(cases) { Text($0.id).tag($0.id) }
            }
            .pickerStyle(.menu)
            .fixedSize(horizontal: false, vertical: true)

            HStack(alignment: .top, spacing: 12) {
                Image(systemName: current.isCollected ? "checkmark.circle.fill" : "minus.circle.fill")
                    .font(.title2)
                    .foregroundStyle(current.isCollected ? Color.orange : Color.green)
                    .contentTransition(.symbolEffect(.replace))
                VStack(alignment: .leading, spacing: 3) {
                    Text(current.isCollected ? "Collected: declare it" : "Not collected")
                        .font(.body.weight(.semibold))
                    Text(current.answer)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.fill.tertiary, in: .rect(cornerRadius: 12))
            .animation(.smooth, value: selection)
        }
        .padding(16)
        .cardStyle()
    }
}

// MARK: - Do / Don't

private struct PrivacySettingsSample: View {
    let showsPolicy: Bool

    var body: some View {
        VStack(spacing: 0) {
            row("Notifications", symbol: "bell.badge", tint: .red)
            Divider().padding(.leading, 44)
            row("Appearance", symbol: "circle.lefthalf.filled", tint: .indigo)
            if showsPolicy {
                Divider().padding(.leading, 44)
                row("Privacy Policy", symbol: "hand.raised.fill", tint: .blue)
            }
        }
        .background(.background, in: .rect(cornerRadius: 12))
        .frame(maxWidth: 260)
    }

    private func row(_ title: String, symbol: String, tint: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: symbol)
                .font(.footnote)
                .foregroundStyle(.white)
                .frame(width: 26, height: 26)
                .background(tint, in: .rect(cornerRadius: 6))
            Text(title)
                .font(.subheadline)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.tertiary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
    }
}
