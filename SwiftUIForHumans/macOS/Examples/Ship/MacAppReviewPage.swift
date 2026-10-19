import SwiftUI

extension ComponentPage {
    static let macAppReview = ComponentPage(
        id: "mac-app-review",
        title: "Mac App Review",
        summary: "Guideline 2.4.5's extra Mac App Store rules, and the issues that most often stall review.",
        category: .requiredByApple,
        kind: .reference,
        symbol: "person.text.rectangle",
        availability: [],
        docsURL: "https://developer.apple.com/distribute/app-review/",
        aliases: [
            "App Review", "rejection", "rejected", "Mac App Store rules", "license key", "serial number",
            "launch at login", "login item", "SMAppService", "auto-update", "root privileges", "setuid",
            "installer", "kext", "deprecated", "Java", "localization",
            "Guideline 2.4.5", "Guideline 2.4.5(i)", "Guideline 2.4.5(ii)", "Guideline 2.4.5(iii)",
            "Guideline 2.4.5(iv)", "Guideline 2.4.5(v)", "Guideline 2.4.5(vi)", "Guideline 2.4.5(vii)",
            "Guideline 2.4.5(viii)", "Guideline 2.4.5(ix)", "Guideline 2.1", "Guideline 2.3.3",
            "Guideline 2.5.1", "Guideline 2.5.2", "Guideline 3.1.1", "Guideline 4.2", "Guideline 5.1.1",
        ],
        related: ["app-sandbox", "updates-outside-store", "privacy-permissions", "mac-screenshots", "pricing-category", "testflight-mac"],
        notes: [
            "**2.1 is the big one.** Apple says over 40% of unresolved issues come from Guideline 2.1, App Completeness: crashes, placeholder content, and missing information.",
            "**Plug-ins are an exception to In-App Purchase.** Mac App Store apps may host plug-ins or extensions that are unlocked some other way.",
        ],
        guidelines: [
            Guideline(
                "Open to your app, not a license screen.",
                "Guideline 2.4.5(vi) rules out license screens at launch, license keys, and your own copy protection. The Mac App Store handles purchases; use In-App Purchase to unlock more.",
                good: "The app opens straight to its content.",
                bad: "A license key prompt blocks the app."
            ) {
                ReviewWindow {
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(["Lisbon", "Kyoto", "Oslo"], id: \.self) { city in
                            Label(city, systemImage: "airplane")
                                .font(.caption)
                        }
                    }
                }
            } bad: {
                ReviewWindow {
                    VStack(spacing: 8) {
                        Text("Enter your license key")
                            .font(.caption.bold())
                        TextField("XXXX-XXXX-XXXX", text: .constant(""))
                            .textFieldStyle(.roundedBorder)
                            .controlSize(.small)
                            .frame(width: 150)
                    }
                }
            },
            Guideline(
                "Ask before starting at login.",
                "Guideline 2.4.5(iii) needs consent before your app or its helpers run at startup or keep running after people quit. Make it a setting that's off until people turn it on."
            ),
        ],
        sources: [
            "https://developer.apple.com/app-store/review/guidelines/#hardware-compatibility",
            "https://developer.apple.com/app-store/review/guidelines/#software-requirements",
            "https://developer.apple.com/app-store/review/guidelines/#app-completeness",
            "https://developer.apple.com/app-store/review/guidelines/#accurate-metadata",
            "https://developer.apple.com/app-store/review/guidelines/#in-app-purchase",
            "https://developer.apple.com/app-store/review/guidelines/#minimum-functionality",
            "https://developer.apple.com/app-store/review/guidelines/#data-collection-and-storage",
            "https://developer.apple.com/distribute/app-review/",
            "https://developer.apple.com/documentation/servicemanagement/smappservice",
        ],
        reviewed: "October 2026"
    ) {
        ShipThumbnail(symbol: "person.text.rectangle", caption: "Guideline 2.4.5")
    } content: { page in
        MacAppReviewArticle(page: page)
    }
}

// MARK: - Page

private struct MacAppReviewArticle: View {
    let page: ComponentPage

    var body: some View {
        ArticlePage(page: page) {
            Prose("Mac apps go through the same App Review as iPhone apps, under the same guidelines. Guideline **2.4.5** adds nine rules for apps on the Mac App Store. Here they are in plain words.")

            SectionTitle("Guideline 2.4.5, in full")
            ConnectFacts(rows: [
                ("(i) Sandboxed", "Appropriately sandboxed, following the macOS file system documentation. Change other apps' data, like bookmarks, contacts, or calendar events, only through the APIs made for it. See [App Sandbox](catalog://app-sandbox)."),
                ("(ii) Packaged with Xcode", "Packaged and submitted with Xcode's tools, with no third-party installers. One self-contained app bundle that installs nothing in shared locations."),
                ("(iii) Nothing runs without consent", "No launching at startup or login, and no processes left running after quit, unless people agree. Don't add yourself to the Dock or leave shortcuts on the desktop."),
                ("(iv) No downloaded features", "Don't download or install other apps, kernel extensions, code, or resources that add features or change what App Review saw."),
                ("(v) No root", "Don't ask for root privileges or use setuid attributes."),
                ("(vi) No licensing of your own", "No license screen at launch, no license keys, and no custom copy protection."),
                ("(vii) Updates through the store", "The Mac App Store delivers every update; no other update mechanism. See [Updates Outside the Store](catalog://updates-outside-store)."),
                ("(viii) Current macOS, current tech", "Run on the currently shipping macOS, without deprecated or optionally installed technologies such as Java."),
                ("(ix) Every language in one bundle", "All localizations ship inside the single app bundle."),
            ])

            SectionTitle("Start at login, with consent")
            ExampleCard(
                title: "An Open at Login setting",
                caption: "`SMAppService.mainApp` registers your app as a login item, so tie it to a toggle that's off until people turn it on.",
                code: """
                import ServiceManagement
                import SwiftUI

                struct LoginItemToggle: View {
                    @State private var opensAtLogin = SMAppService.mainApp.status == .enabled

                    var body: some View {
                        Toggle("Open at login", isOn: $opensAtLogin)
                            .onChange(of: opensAtLogin) { _, isOn in
                                do {
                                    if isOn {
                                        try SMAppService.mainApp.register()
                                    } else {
                                        try SMAppService.mainApp.unregister()
                                    }
                                } catch {
                                    opensAtLogin = SMAppService.mainApp.status == .enabled
                                }
                            }
                    }
                }
                """,
                minHeight: 140,
                aside: Aside(.note, "The preview's toggle doesn't change your login items. People can also review login items in System Settings, and `SMAppService.openSystemSettingsLoginItems()` opens that pane.")
            ) {
                LoginItemSample()
            }

            SectionTitle("Issues Apple sees most")
            Prose("Apple lists the most common reasons submissions get stuck. None are Mac-only, and Mac apps run into them just the same:")
            ConnectFacts(rows: [
                ("Crashes and bugs · 2.1", "Test thoroughly on the latest macOS and fix bugs before you submit."),
                ("Broken links · 2.1, 5.1", "Support and privacy policy links must work, in the app and in App Store Connect."),
                ("Placeholder content · 2.1", "Finish every image and every piece of text before you submit."),
                ("Incomplete information · 2.1", "Give App Review a demo account and any setup steps in App Review Information."),
                ("Unclear data requests · 5.1.1(ii)", "Every protected resource needs a purpose string that clearly explains the use. See [Privacy & Permissions](catalog://privacy-permissions)."),
                ("Inaccurate screenshots · 2.3.3", "Show the app in use, not a title screen or splash. See [Screenshots & Metadata](catalog://mac-screenshots)."),
                ("Not enough lasting value · 4.2", "Offer enough features and content to be useful. A repackaged website or a set of links isn't enough."),
            ])

            SectionTitle("Rules Mac apps often meet elsewhere")
            ConnectFacts(rows: [
                ("2.5.1 Public APIs only", "And the app must run on the currently shipping macOS."),
                ("2.5.2 Self-contained", "Read and write only inside your container, and don't download code that changes your app's features."),
                ("3.1.1 In-App Purchase", "Unlock features with In-App Purchase, not license keys or codes of your own."),
            ])

            SectionTitle("Before you submit")
                .id("checklist")
            Checklist(pageID: page.id, items: [
                ChecklistItem("sandbox", "App Sandbox is on", "With only the entitlements you use.", page: "app-sandbox"),
                ChecklistItem("xcode-upload", "Archived and uploaded with Xcode", "No installer package of your own."),
                ChecklistItem("login-consent", "Nothing starts at login without consent", "Login items are an opt-in setting."),
                ChecklistItem("no-updater", "No update checker in the store build", "Updates come from the Mac App Store.", page: "updates-outside-store"),
                ChecklistItem("no-license", "No license keys or license screens", "Use In-App Purchase to unlock features.", page: "pricing-category"),
                ChecklistItem("current-macos", "Tested on the current macOS", "No deprecated or optionally installed technologies."),
                ChecklistItem("review-info", "App Review Information is complete", "Demo account, notes, and a contact who answers."),
            ])
        }
    }
}

// MARK: - Samples

private struct ReviewWindow<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        MacWindowFrame(title: "Trips", width: 250, height: 150) {
            content
        }
    }
}

/// The login item toggle, without registering anything.
private struct LoginItemSample: View {
    @State private var opensAtLogin = false

    var body: some View {
        VStack(spacing: 8) {
            Toggle("Open at login", isOn: $opensAtLogin)
            Text(opensAtLogin ? "Would call SMAppService.mainApp.register()" : "Off until people turn it on")
                .font(.footnote.monospaced())
                .foregroundStyle(.secondary)
        }
    }
}
