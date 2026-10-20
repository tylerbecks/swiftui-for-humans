import SwiftUI
import UniformTypeIdentifiers

extension ComponentPage {
    static let appSandbox = ComponentPage(
        id: "app-sandbox",
        title: "App Sandbox",
        summary: "Every Mac App Store app runs in a sandbox, with only the access it asks for.",
        category: .requiredByApple,
        kind: .reference,
        symbol: "shippingbox",
        availability: [],
        docsURL: "https://developer.apple.com/documentation/security/app-sandbox",
        aliases: [
            "sandbox", "sandboxing", "entitlements", "entitlement", "com.apple.security.app-sandbox",
            "container", "Library/Containers", "Operation not permitted", "file access",
            "security-scoped", "network client", "outgoing connections",
            "Guideline 2.4.5", "Guideline 2.4.5(i)",
        ],
        related: ["settings-scene"],
        notes: [
            "**Your Debug builds are sandboxed too.** The entitlements apply whenever the app is signed, so you find missing access while developing, not in review.",
            "**Asking for an entitlement isn't the same as getting access.** Camera, microphone, and location still show the system's permission prompt.",
        ],
        api: [
            APIItem("`com.apple.security.app-sandbox`", "Turns the sandbox on. Required for the Mac App Store."),
            APIItem("`com.apple.security.network.client`", "Outgoing connections, like loading images."),
            APIItem("`…files.user-selected.read-write`", "Files people pick in an open or save panel."),
            APIItem("`.fileImporter(isPresented:…)`", "Shows an open panel from SwiftUI."),
            APIItem("`startAccessingSecurityScopedResource()`", "Opens access to a file people picked."),
        ],
        guidelines: [
            Guideline(
                "Ask only for the access you use.",
                "The sandbox works by keeping your app to the smallest set of privileges it needs. Turn on what a feature uses, and turn it off when the feature goes."
            ),
            Guideline(
                "Reach people's files through the open and save panels.",
                "The sandbox keeps your app in its own container. A file people pick in a panel is the normal way to read or write anywhere else."
            ),
        ],
        sources: [
            "https://developer.apple.com/app-store/review/guidelines/#hardware-compatibility",
            "https://developer.apple.com/documentation/security/app-sandbox",
            "https://developer.apple.com/documentation/xcode/configuring-the-macos-app-sandbox",
            "https://developer.apple.com/documentation/security/protecting-user-data-with-app-sandbox",
            "https://developer.apple.com/documentation/security/accessing-files-from-the-macos-app-sandbox",
            "https://developer.apple.com/documentation/bundleresources/entitlements/com.apple.security.app-sandbox",
            "https://developer.apple.com/documentation/bundleresources/entitlements/com.apple.security.network.client",
            "https://developer.apple.com/documentation/bundleresources/entitlements/com.apple.security.files.user-selected.read-write",
        ],
        reviewed: "October 2026"
    ) {
        VStack(spacing: 8) {
            Image(systemName: "shippingbox")
                .font(.system(size: 34))
                .foregroundStyle(.tint)
            Text("App Sandbox")
                .font(.caption.weight(.semibold))
        }
    } content: { page in
        MacAppSandboxArticle(page: page)
    }
}

// MARK: - Page

private struct MacAppSandboxArticle: View {
    let page: ComponentPage

    var body: some View {
        ArticlePage(page: page) {
            Prose("Guideline **2.4.5(i)** says apps on the Mac App Store must be appropriately sandboxed. Turn on the App Sandbox, then turn on only the access your features need: the network, files people pick, the camera, and so on.")
            Prose("The sandbox limits what a compromised app can do. If someone tricks your app into running bad code, it can still only reach its own folder and what you declared.")

            SectionTitle("Turn it on")
            ConnectSteps(steps: [
                "In Xcode, select your app's target and open **Signing & Capabilities**.",
                "Click **+ Capability** and add **App Sandbox**. Xcode adds `com.apple.security.app-sandbox` to your entitlements file.",
                "Under App Sandbox, check each resource you use, like **Outgoing Connections (Client)** for network requests.",
                "For **User Selected File**, choose **Read Only** or **Read/Write** if people open or save files.",
                "Run the app, open Activity Monitor, and choose View > Columns > Sandbox. Your app should say **Yes**.",
            ])

            SectionTitle("What the entitlements file looks like")
            Prose("This app's own entitlements: the sandbox, outgoing network connections for photos and maps, and files people pick.")
            CodeBlock(code: """
            <?xml version="1.0" encoding="UTF-8"?>
            <plist version="1.0">
            <dict>
                <key>com.apple.security.app-sandbox</key>
                <true/>
                <key>com.apple.security.network.client</key>
                <true/>
                <key>com.apple.security.files.user-selected.read-write</key>
                <true/>
            </dict>
            </plist>
            """)

            SectionTitle("Where your files live")
            ConnectFacts(rows: [
                ("Your container", "`~/Library/Containers/<bundle ID>`. The system makes it on first launch, and only your app can read and write it."),
                ("Downloads, Pictures, and other folders", "Off limits unless you add the matching entitlement. Without it you get “Operation not permitted.”"),
                ("Files people pick", "Readable or writable when you add the user-selected file entitlement and they choose the file in a panel."),
            ])

            SectionTitle("Open a file people pick")
            ExampleCard(
                title: "Read a file from an open panel",
                caption: "`.fileImporter` shows the open panel. Wrap your reads in `startAccessingSecurityScopedResource()` and its matching stop call.",
                code: """
                import SwiftUI
                import UniformTypeIdentifiers

                struct OpenTextButton: View {
                    @State private var isImporting = false
                    @State private var text = ""

                    var body: some View {
                        Button("Open Text File…") { isImporting = true }
                            .fileImporter(isPresented: $isImporting, allowedContentTypes: [.plainText]) { result in
                                guard case .success(let url) = result else { return }
                                let didAccess = url.startAccessingSecurityScopedResource()
                                defer { if didAccess { url.stopAccessingSecurityScopedResource() } }
                                text = (try? String(contentsOf: url, encoding: .utf8)) ?? ""
                            }
                    }
                }
                """,
                minHeight: 160,
                aside: Aside(.important, "Without the user-selected file entitlement, the open panel still appears, but reading the file fails.")
            ) {
                OpenTextSample()
            }

            SectionTitle("Before you submit")
                .id("checklist")
            Checklist(pageID: page.id, items: [
                ChecklistItem("sandbox", "App Sandbox is on", "`com.apple.security.app-sandbox` is in your entitlements."),
                ChecklistItem("minimal", "Only the entitlements you use", "Remove leftovers from features you cut."),
                ChecklistItem("network", "Network access if you load anything", "Outgoing Connections (Client) for images, APIs, and maps."),
                ChecklistItem("files", "Files go through open and save panels", "Plus the user-selected file entitlement."),
                ChecklistItem("activity-monitor", "Activity Monitor shows Sandbox: Yes", "Check the build you're about to submit."),
            ])
        }
    }
}

/// The open-panel example, live: this app has the user-selected file
/// entitlement, so it can read what you pick.
private struct OpenTextSample: View {
    @State private var isImporting = false
    @State private var text = ""

    var body: some View {
        VStack(spacing: 12) {
            Button("Open Text File…") { isImporting = true }
                .fileImporter(isPresented: $isImporting, allowedContentTypes: [.plainText]) { result in
                    guard case .success(let url) = result else { return }
                    let didAccess = url.startAccessingSecurityScopedResource()
                    defer { if didAccess { url.stopAccessingSecurityScopedResource() } }
                    text = (try? String(contentsOf: url, encoding: .utf8)) ?? ""
                }
            Text(text.isEmpty ? "Pick a .txt file to read it here." : String(text.prefix(140)))
                .font(.callout)
                .foregroundStyle(.secondary)
                .lineLimit(3)
                .frame(maxWidth: 360)
        }
    }
}
