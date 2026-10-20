import SwiftUI

extension ComponentPage {
    static let privacyPermissions = ComponentPage(
        id: "privacy-permissions",
        title: "Privacy & Permissions",
        summary: "Purpose strings, the privacy manifest, App Privacy answers, and the Mac's permission prompts.",
        category: .requiredByApple,
        kind: .reference,
        symbol: "hand.raised",
        availability: [],
        docsURL: "https://developer.apple.com/documentation/bundleresources/privacy-manifest-files",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/privacy",
        aliases: [
            "privacy", "permissions", "TCC", "purpose string", "usage description",
            "NSCameraUsageDescription", "NSMicrophoneUsageDescription", "NSContactsUsageDescription",
            "PrivacyInfo.xcprivacy", "privacy manifest", "App Privacy", "privacy nutrition label",
            "privacy policy", "Privacy & Security", "Full Disk Access", "Accessibility permission",
            "requestAccess", "Guideline 5.1.1", "Guideline 5.1.1(i)", "Guideline 5.1.1(ii)",
            "Guideline 5.1.1(iii)", "Guideline 5.1.1(iv)", "Guideline 5.1.2(i)",
        ],
        related: ["app-sandbox", "mac-app-review", "universal-purchase", "onboarding"],
        notes: [
            "**One set of App Privacy answers covers every platform.** With Universal Purchase, answer for whichever platform collects the most.",
            "**Required-reason APIs are an iOS-family rule.** The privacy manifest lists them for iOS, iPadOS, tvOS, visionOS, and watchOS; the data your app collects goes in it on every platform, the Mac included.",
            "**Several people can share one Mac.** With fast user switching, don't assume who's signed in.",
        ],
        guidelines: [
            Guideline(
                "Write a purpose string that says what and why.",
                "One short, complete, active sentence about how the app uses the data, with a period at the end. Vague or bossy text gives people no reason to agree.",
                good: "Says exactly what the camera is for.",
                bad: "Vague, and in the passive voice."
            ) {
                PermissionCard(message: "Trips uses the camera to scan your boarding pass.")
            } bad: {
                PermissionCard(message: "Access to the camera is required to continue.")
            },
            Guideline(
                "Ask when people reach the feature, not at launch.",
                "A request out of nowhere feels suspicious. Asking when someone clicks Scan makes the reason obvious."
            ),
            Guideline(
                "Give an explainer one button, and make it open the prompt.",
                "If you show your own window first, give it a single Continue button. A second way out, or a button titled Allow, steers people."
            ),
            Guideline(
                "Have a plan for No.",
                "Guideline 5.1.1(iv) asks for an alternative where possible, like typing an address when someone declines Location."
            ),
        ],
        sources: [
            "https://developer.apple.com/app-store/review/guidelines/#data-collection-and-storage",
            "https://developer.apple.com/app-store/review/guidelines/#data-use-and-sharing",
            "https://developer.apple.com/design/human-interface-guidelines/privacy",
            "https://developer.apple.com/documentation/avfoundation/requesting-authorization-to-capture-and-save-media",
            "https://developer.apple.com/documentation/bundleresources/privacy-manifest-files",
            "https://developer.apple.com/documentation/bundleresources/information-property-list/nscamerausagedescription",
            "https://developer.apple.com/help/app-store-connect/manage-app-information/manage-app-privacy",
            "https://developer.apple.com/help/app-store-connect/reference/app-information/app-information",
            "https://developer.apple.com/app-store/app-privacy-details/",
            "https://support.apple.com/guide/mac-help/change-privacy-security-settings-on-mac-mchl211c911f/mac",
            "https://developer.apple.com/distribute/app-review/",
        ],
        reviewed: "October 2026"
    ) {
        ShipThumbnail(symbol: "hand.raised", caption: "Privacy & Permissions")
    } content: { page in
        MacPrivacyPermissionsArticle(page: page)
    }
}

// MARK: - Page

private struct MacPrivacyPermissionsArticle: View {
    let page: ComponentPage

    var body: some View {
        ArticlePage(page: page) {
            Prose("Guideline **5.1.1** sets the rules. Link a privacy policy in App Store Connect and inside the app **(i)**. Get consent before you collect data, and write purpose strings that clearly and completely explain the use **(ii)**. Ask only for data your core features need **(iii)**, and respect people's choices without tricking or pressuring them **(iv)**.")
            Prose("Under **5.1.2(i)**, you can't use or share personal data without permission, and you must say clearly when it goes to a third party, third-party AI included.")

            SectionTitle("Four places privacy shows up")
            ConnectFacts(rows: [
                ("In the permission prompt", "Your purpose string, from `Info.plist`, appears when the system asks for access."),
                ("In the app bundle", "`PrivacyInfo.xcprivacy`, the privacy manifest, records the data your app and its SDKs collect."),
                ("On the product page", "Your App Privacy answers in App Store Connect, shown to people before they download."),
                ("In your privacy policy", "Required for Mac apps: a link in App Store Connect and one inside the app."),
            ])

            SectionTitle("Camera, microphone, and friends")
            Prose("On the Mac, protected hardware and data need two things before you ask: a purpose string in `Info.plist` and the matching entitlement under App Sandbox (or Hardened Runtime).")
            ConnectFacts(rows: [
                ("Camera", "`NSCameraUsageDescription` + `com.apple.security.device.camera`"),
                ("Microphone", "`NSMicrophoneUsageDescription` + `com.apple.security.device.audio-input`"),
                ("Contacts", "`NSContactsUsageDescription` + `…personal-information.addressbook`"),
                ("Photos", "`NSPhotoLibraryUsageDescription` + `…personal-information.photos-library`"),
            ])

            Aside(.important, "For the camera and microphone, Apple says the system ends your app if the key or the entitlement is missing when it asks for access or starts capturing.")

            ExampleCard(
                title: "Ask when the feature starts",
                caption: "Check `AVCaptureDevice.authorizationStatus(for:)` first, and call `requestAccess(for:)` only while the status is still undetermined.",
                code: """
                import AVFoundation
                import SwiftUI

                struct ScanButton: View {
                    @State private var isDenied = false

                    var body: some View {
                        Button("Scan Boarding Pass") {
                            Task { await scan() }
                        }
                        if isDenied {
                            Text("Turn on Trips in System Settings > Privacy & Security > Camera.")
                                .foregroundStyle(.secondary)
                        }
                    }

                    func scan() async {
                        var status = AVCaptureDevice.authorizationStatus(for: .video)
                        if status == .notDetermined {
                            let granted = await AVCaptureDevice.requestAccess(for: .video)
                            status = granted ? .authorized : .denied
                        }
                        isDenied = status != .authorized
                        // Start the capture session when authorized.
                    }
                }
                """,
                minHeight: 200,
                aside: Aside(.note, "The preview only simulates the answer: this app doesn't use the camera, so it has no camera purpose string to show.")
            ) {
                ScanSample()
            }

            SectionTitle("Permissions people grant in System Settings")
            Prose("People review and change every choice in **System Settings > Privacy & Security**. Some lists, like **Full Disk Access** and **Accessibility**, let people add an app themselves with the add button. If a feature needs one of those, tell people exactly where to go, and keep the rest of the app working without it.")

            SectionTitle("The privacy manifest")
            Prose("Choose File > New File, then **App Privacy** under Resource. Xcode names it `PrivacyInfo.xcprivacy`, the name the system requires. Record the data types you collect, and whether you track. Each third-party SDK can ship its own.")
            CodeBlock(code: """
            <key>NSPrivacyTracking</key>
            <false/>
            <key>NSPrivacyCollectedDataTypes</key>
            <array>
                <dict>
                    <key>NSPrivacyCollectedDataType</key>
                    <string>NSPrivacyCollectedDataTypeEmailAddress</string>
                    <key>NSPrivacyCollectedDataTypeLinked</key>
                    <true/>
                    <key>NSPrivacyCollectedDataTypeTracking</key>
                    <false/>
                    <key>NSPrivacyCollectedDataTypePurposes</key>
                    <array>
                        <string>NSPrivacyCollectedDataTypePurposeAppFunctionality</string>
                    </array>
                </dict>
            </array>
            """)

            SectionTitle("App Privacy answers")
            ConnectSteps(steps: [
                "In App Store Connect, open your app and click **App Privacy** in the sidebar.",
                "Click **Get Started** and say whether you or your partners collect data.",
                "If you do, pick every data type you and your third-party partners collect, then answer the questions for each.",
                "Check the **Product Page Preview**, then click **Publish**. Update the answers whenever your app's data practices change.",
            ])

            SectionTitle("Before you submit")
                .id("checklist")
            Checklist(pageID: page.id, items: [
                ChecklistItem("policy", "Privacy policy linked in two places", "In App Store Connect and somewhere easy to find in the app."),
                ChecklistItem("purpose-strings", "A purpose string for every protected resource", "Clear and complete, one sentence each."),
                ChecklistItem("entitlements", "A matching entitlement for each", "Under App Sandbox in Signing & Capabilities.", page: "app-sandbox"),
                ChecklistItem("ask-in-context", "Requests happen when the feature is used", "Not all at once on first launch."),
                ChecklistItem("declined", "The app still works after No", "With another way to finish the task where possible."),
                ChecklistItem("manifest", "Privacy manifest lists collected data", "And the SDKs you include ship their own."),
                ChecklistItem("app-privacy", "App Privacy answers match the app", "Covering every platform in the record."),
            ])
        }
    }
}

// MARK: - Samples

/// A plain drawing of a permission request, for comparing purpose
/// strings. It isn't the system's alert.
private struct PermissionCard: View {
    let message: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "camera.fill")
                .font(.title2)
                .foregroundStyle(.tint)
            Text("“Trips” would like to access the camera.")
                .font(.callout.bold())
                .multilineTextAlignment(.center)
            Text(message)
                .font(.caption)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            HStack {
                Text("Don't Allow")
                Text("Allow")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(14)
        .frame(width: 230)
        .background(.background, in: .rect(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(.separator)
        }
    }
}

private enum SimulatedAnswer: String, CaseIterable, Identifiable {
    case allow = "Allow"
    case deny = "Don't Allow"
    var id: Self { self }
}

/// The scan button with the system's answer simulated, so trying it
/// doesn't need a camera purpose string in this app.
private struct ScanSample: View {
    @State private var answer = SimulatedAnswer.allow
    @State private var result: String?

    var body: some View {
        VStack(spacing: 14) {
            Picker("Simulated answer", selection: $answer) {
                ForEach(SimulatedAnswer.allCases) { answer in
                    Text(answer.rawValue).tag(answer)
                }
            }
            .pickerStyle(.segmented)
            .labelsHidden()
            .frame(width: 220)
            Text("Simulated answer to the prompt")
                .font(.caption)
                .foregroundStyle(.secondary)
            Button("Scan Boarding Pass") {
                result = answer == .allow
                    ? "Authorized: the scanner would start here."
                    : "Turn on Trips in System Settings > Privacy & Security > Camera."
            }
            Text(result ?? "Click the button to ask.")
                .font(.callout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 360)
        }
        .onChange(of: answer) { result = nil }
    }
}
