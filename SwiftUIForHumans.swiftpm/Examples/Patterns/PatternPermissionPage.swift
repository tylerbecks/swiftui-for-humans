import SwiftUI

extension ComponentPage {
    static let patternRequestingPermission = ComponentPage(
        id: "requesting-permission",
        title: "Requesting Permission",
        summary: "Ask for access when a feature needs it, say why, and handle “no” gracefully.",
        category: .patterns,
        kind: .concept,
        symbol: "hand.raised",
        availability: ["iOS 14.0+"],
        docsURL: "https://developer.apple.com/documentation/uikit/requesting-access-to-protected-resources",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/privacy",
        aliases: ["permission prompt", "permissions", "authorization", "purpose string", "usage description", "Info.plist", "NSCameraUsageDescription", "camera permission", "location permission", "pre-permission", "priming screen", "open settings", "navigator.permissions", "Guideline 5.1.1(iv)", "Guideline 5.1.1(iii)"],
        related: ["onboarding", "launching", "alert", "entering-data", "privacy-details"],
        notes: [
            "**A missing purpose string is a crash and a rejection.** Without the Info.plist key, the access attempt fails and may crash, and App Review rejects the build. That includes APIs used by SDKs you add.",
            "**You usually get one prompt.** After people answer, the system remembers and doesn't ask again. Only Settings can change it, and people can change it there at any time.",
            "**Sometimes a picker beats a permission.** As of 2026, Guideline 5.1.1(iii) asks you to use a system picker or share sheet, like `PhotosPicker`, instead of full access to Photos or Contacts where you can.",
        ],
        api: [
            APIItem("`NSCameraUsageDescription`", "Info.plist key with your purpose string."),
            APIItem("`authorizationStatus(for:)`", "Checks camera access before you ask."),
            APIItem("`requestAccess(for:)`", "Shows the system prompt, once."),
            APIItem("`openSettingsURLString`", "Opens your app's page in Settings."),
            APIItem("`LocationButton`", "One-time location, no up-front prompt."),
            APIItem("`PhotosPicker`", "Lets people pick photos to share with you."),
        ],
        guidelines: [
            Guideline(
                "Ask when people use the feature, not at launch.",
                "A prompt makes sense right after someone taps Scan Receipt. On first launch it's a mystery, unless the app can't work at all without it.",
                good: "Asked after tapping Scan.",
                bad: "Asked on the welcome screen."
            ) {
                PermissionContextMock(isInContext: true)
            } bad: {
                PermissionContextMock(isInContext: false)
            },
            Guideline(
                "Write a purpose string that says exactly why.",
                "The system prompt shows your sentence under its title. Make it one specific, complete sentence about what people get.",
                good: "Says what the camera is for.",
                bad: "Says nothing useful."
            ) {
                PatternMockAlert(title: "“Expenses” Would Like to Access the Camera", message: "Scan receipts to add expenses automatically.", buttons: ["Don't Allow", "Allow"])
            } bad: {
                PatternMockAlert(title: "“Expenses” Would Like to Access the Camera", message: "This app needs camera access.", buttons: ["Don't Allow", "Allow"])
            },
            Guideline(
                "Give an explanation screen one button: Continue.",
                "If you explain before the prompt, the only button should open it. A button called Allow, or a way to skip, steers people, and the HIG calls that manipulative.",
                good: "One button that opens the prompt.",
                bad: "Allow and Not Now."
            ) {
                PermissionPrimerMock(isGood: true)
            } bad: {
                PermissionPrimerMock(isGood: false)
            },
            Guideline(
                "Have a plan for “Don't Allow”.",
                "Keep the rest of the app working and offer another way, like typing an address when location is off. As of 2026, App Review Guideline 5.1.1(iv) asks for this."
            ),
            Guideline(
                "Ask only for what the feature needs.",
                "Don't require the microphone to post a photo. As of 2026, Guideline 5.1.1(iv) forbids pushing people into access a feature doesn't need."
            ),
        ],
        sources: [
            "https://developer.apple.com/design/human-interface-guidelines/privacy",
            "https://developer.apple.com/documentation/uikit/requesting-access-to-protected-resources",
            "https://developer.apple.com/app-store/review/guidelines/#data-collection-and-storage",
            "https://developer.apple.com/documentation/bundleresources/information-property-list/nscamerausagedescription",
            "https://developer.apple.com/documentation/avfoundation/avcapturedevice/authorizationstatus(for:)",
            "https://developer.apple.com/documentation/avfoundation/avcapturedevice/requestaccess(for:completionhandler:)",
            "https://developer.apple.com/documentation/uikit/uiapplication/opensettingsurlstring",
            "https://developer.apple.com/documentation/corelocationui/locationbutton",
            "https://developer.apple.com/documentation/photokit/selecting-photos-and-videos-in-ios",
        ],
        reviewed: "October 2026"
    ) {
        PermissionThumbnail()
    } content: { page in
        PermissionArticle(page: page)
    }
}

// MARK: - Article

private struct PermissionArticle: View {
    let page: ComponentPage

    var body: some View {
        ArticlePage(page: page) {
            Prose("iOS guards the camera, microphone, location, photos, contacts, and more. The first time your app reaches for one, the system asks people with an alert that shows your own explanation, called a purpose string. Ask at the moment it makes sense, and design for both answers.")

            VStack(alignment: .leading, spacing: 12) {
                SectionTitle("Try it")
                Prose("Tap **Scan Receipt** and answer the prompt, which is simulated here. Then try **Reset** and say no.")
                PermissionFlowDemo()
                Aside(.important, "Check the status every time the feature opens, not once at launch. People can turn access off in Settings whenever they like.")
            }
            .id("playground")

            VStack(alignment: .leading, spacing: 28) {
                SectionTitle("In SwiftUI")

                ExampleCard(
                    title: "The purpose string",
                    caption: "Add the usage description key for each resource to Info.plist. The system shows it in the prompt.",
                    code: """
                    <!-- Info.plist -->
                    <key>NSCameraUsageDescription</key>
                    <string>Scan receipts to add expenses automatically.</string>
                    """,
                    aside: Aside(.note, "In Xcode you can also add it in the target's Info tab, or as the `INFOPLIST_KEY_NSCameraUsageDescription` build setting. Localize it like any other text.")
                ) {
                    PatternMockAlert(title: "“Expenses” Would Like to Access the Camera", message: "Scan receipts to add expenses automatically.", buttons: ["Don't Allow", "Allow"])
                }

                ExampleCard(
                    title: "An explanation screen, if you need one",
                    caption: "When the context doesn't explain itself, show one screen with a single Continue button that opens the prompt.",
                    code: """
                    VStack(spacing: 16) {
                        Image(systemName: "doc.viewfinder")
                            .font(.system(size: 56))
                            .foregroundStyle(.tint)
                        Text("Scan Receipts")
                            .font(.title2.bold())
                        Text("Point your camera at a receipt and Expenses fills in the amount and date for you.")
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.secondary)
                        Button("Continue") {
                            Task { await AVCaptureDevice.requestAccess(for: .video) }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                    """,
                    aside: Aside(.important, "Don't add Not Now, Close, or Cancel, and don't title the button Allow. As of 2026, the HIG says either one can feel manipulative, and App Review rejects misleading pre-prompt screens for tracking.")
                ) {
                    PermissionPrimerExample()
                }

                ExampleCard(
                    title: "Send people to Settings",
                    caption: "When access is off, explain what it's for and open your app's Settings page with `openSettingsURLString`.",
                    code: """
                    @Environment(\\.openURL) private var openURL

                    Button("Open Settings") {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            openURL(url)
                        }
                    }
                    """
                ) {
                    PermissionSettingsExample()
                }
            }
        }
    }
}

// MARK: - Try it

private enum PermissionStatus: String, CaseIterable, Identifiable {
    case notAsked = "Not Asked"
    case allowed = "Allowed"
    case denied = "Denied"
    var id: Self { self }
}

private struct PermissionFlowDemo: View {
    @State private var status: PermissionStatus = .notAsked
    @State private var isPrompting = false
    @State private var addedPhoto = false
    @Environment(\.openURL) private var openURL

    var body: some View {
        VStack(spacing: 0) {
            PreviewCard(minHeight: 420, isAttached: true) {
                VStack(spacing: 16) {
                    screen
                        .frame(width: 280, height: 340)
                        .background(.background)
                        .clipShape(.rect(cornerRadius: 28))
                        .overlay {
                            RoundedRectangle(cornerRadius: 28).strokeBorder(.separator)
                        }
                        .overlay {
                            if isPrompting { prompt }
                        }
                        .animation(.snappy, value: status)
                        .animation(.snappy, value: isPrompting)

                    HStack {
                        Text("Status: **\(status.rawValue)**")
                            .font(.subheadline)
                        Spacer()
                        Button("Reset") {
                            status = .notAsked
                            isPrompting = false
                            addedPhoto = false
                        }
                        .disabled(status == .notAsked && !isPrompting)
                    }
                    .frame(width: 280)
                }
            }
            Divider()
            CodeBlock(code: Self.code, isCollapsible: true, isAttached: true)
        }
        .cardStyle()
    }

    @ViewBuilder
    private var screen: some View {
        switch status {
        case .notAsked:
            VStack(spacing: 14) {
                Image(systemName: "doc.text.viewfinder")
                    .font(.system(size: 44))
                    .foregroundStyle(.tint)
                Text("Receipts").font(.title3.bold())
                Text("Add an expense by scanning its receipt.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                Button("Scan Receipt", systemImage: "camera") { isPrompting = true }
                    .buttonStyle(.borderedProminent)
            }
            .padding()
        case .allowed:
            ZStack {
                Color.black
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(.white.opacity(0.9), style: StrokeStyle(lineWidth: 3, dash: [28, 120]))
                    .frame(width: 170, height: 220)
                VStack {
                    Spacer()
                    Text("Point at a receipt")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.white)
                        .padding(.bottom, 24)
                }
            }
        case .denied:
            ContentUnavailableView {
                Label("Camera Access Is Off", systemImage: "video.slash")
            } description: {
                Text(addedPhoto ? "Photo added. You can also turn on Camera in Settings." : "Turn on Camera in Settings to scan receipts, or add a photo instead.")
            } actions: {
                Button("Open Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        openURL(url)
                    }
                }
                .buttonStyle(.borderedProminent)
                Button("Choose Photo") { addedPhoto = true }
            }
        }
    }

    /// A drawing of the system prompt, with working buttons.
    private var prompt: some View {
        ZStack {
            Color.black.opacity(0.25)
            VStack(spacing: 14) {
                VStack(spacing: 4) {
                    Text("“Expenses” Would Like to Access the Camera")
                        .font(.subheadline.weight(.semibold))
                    Text("Scan receipts to add expenses automatically.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .multilineTextAlignment(.center)
                HStack(spacing: 6) {
                    Button { answer(.denied) } label: {
                        Text("Don't Allow").frame(maxWidth: .infinity)
                    }
                    Button { answer(.allowed) } label: {
                        Text("Allow").frame(maxWidth: .infinity)
                    }
                }
                .font(.subheadline)
                .buttonStyle(.bordered)
                .buttonBorderShape(.capsule)
                .tint(.primary)
            }
            .padding(16)
            .frame(width: 240)
            .background(.regularMaterial, in: .rect(cornerRadius: 26))
        }
        .clipShape(.rect(cornerRadius: 28))
        .transition(.opacity)
    }

    private func answer(_ newStatus: PermissionStatus) {
        isPrompting = false
        status = newStatus
    }

    static let code = """
    import AVFoundation
    import SwiftUI

    struct ScanReceiptButton: View {
        @State private var status = AVCaptureDevice.authorizationStatus(for: .video)
        @Environment(\\.openURL) private var openURL

        var body: some View {
            switch status {
            case .authorized:
                Text("Camera ready") // Show your scanner here.
            case .denied, .restricted:
                ContentUnavailableView {
                    Label("Camera Access Is Off", systemImage: "video.slash")
                } description: {
                    Text("Turn on Camera in Settings to scan receipts, or add a photo instead.")
                } actions: {
                    Button("Open Settings") {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            openURL(url)
                        }
                    }
                }
            default:
                Button("Scan Receipt", systemImage: "camera") {
                    Task {
                        _ = await AVCaptureDevice.requestAccess(for: .video)
                        status = AVCaptureDevice.authorizationStatus(for: .video)
                    }
                }
            }
        }
    }
    """
}

// MARK: - Examples

private struct PermissionPrimerExample: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.viewfinder")
                .font(.system(size: 56))
                .foregroundStyle(.tint)
            Text("Scan Receipts")
                .font(.title2.bold())
            Text("Point your camera at a receipt and Expenses fills in the amount and date for you.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            Button("Continue") { }
                .buttonStyle(.borderedProminent)
        }
        .padding()
        .frame(maxWidth: 320)
    }
}

private struct PermissionSettingsExample: View {
    @Environment(\.openURL) private var openURL

    var body: some View {
        Button("Open Settings") {
            if let url = URL(string: UIApplication.openSettingsURLString) {
                openURL(url)
            }
        }
        .buttonStyle(.borderedProminent)
    }
}

// MARK: - Do / Don't

private struct PermissionContextMock: View {
    let isInContext: Bool

    var body: some View {
        PatternMiniScreen(width: 200, height: 240) {
            ZStack {
                VStack(spacing: 10) {
                    Image(systemName: isInContext ? "doc.text.viewfinder" : "sparkles")
                        .font(.system(size: 30))
                        .foregroundStyle(.tint)
                    Text(isInContext ? "Receipts" : "Welcome to Expenses")
                        .font(.subheadline.bold())
                    Text(isInContext ? "Scan Receipt" : "Get Started")
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .foregroundStyle(.white)
                        .background(.tint, in: .capsule)
                }
                .padding(.bottom, 80)
                Color.black.opacity(0.2)
                PatternMockAlert(title: "“Expenses” Would Like to Access the Camera", buttons: ["Don't Allow", "Allow"])
                    .scaleEffect(0.75)
                    .offset(y: 40)
            }
        }
    }
}

private struct PermissionPrimerMock: View {
    let isGood: Bool

    var body: some View {
        PatternMiniScreen(width: 200, height: 240) {
            VStack(spacing: 10) {
                Image(systemName: "doc.viewfinder")
                    .font(.system(size: 34))
                    .foregroundStyle(.tint)
                Text("Scan Receipts").font(.headline)
                Text("Fill in expenses from a photo of the receipt.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                Spacer().frame(height: 6)
                Text(isGood ? "Continue" : "Allow")
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .foregroundStyle(.white)
                    .background(.tint, in: .capsule)
                if !isGood {
                    Text("Not Now")
                        .font(.subheadline)
                        .foregroundStyle(.tint)
                }
            }
            .padding(16)
        }
    }
}

// MARK: - Thumbnail

private struct PermissionThumbnail: View {
    var body: some View {
        PatternMockAlert(title: "“Expenses” Would Like to Access the Camera", message: "Scan receipts to add expenses automatically.", buttons: ["Don't Allow", "Allow"])
            .scaleEffect(0.85)
    }
}
