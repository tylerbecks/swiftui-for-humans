import AuthenticationServices
import SwiftUI

extension ComponentPage {
    static let shipSignInWithApple = ComponentPage(
        id: "sign-in-with-apple",
        title: "Sign in with Apple",
        summary: "Apple's sign-in button, and when App Review expects you to offer it.",
        category: .requiredByApple,
        kind: .component,
        symbol: "apple.logo",
        availability: ["iOS 14.0+", "macOS 11.0+", "visionOS 1.0+"],
        docsURL: "https://developer.apple.com/documentation/authenticationservices/signinwithapplebutton",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/sign-in-with-apple",
        aliases: [
            "Guideline 4.8", "login services", "apple login", "login with apple", "continue with apple",
            "social login", "OAuth", "SSO", "single sign-on", "ASAuthorizationAppleIDButton",
            "AuthenticationServices", "Hide My Email", "private relay email", "Google sign-in", "Facebook login",
        ],
        related: ["login-form", "delete-account", "button", "settings-screen"],
        notes: [
            "**Show which sign-in people used.** A line like “Using Sign in with Apple” in your account screen helps people remember how they signed up.",
            "**Revoke tokens when an account is deleted.** Apple's account deletion guidance asks apps that use Sign in with Apple to revoke the user's tokens with the Sign in with Apple REST API. See [Delete Account](catalog://delete-account).",
        ],
        api: [
            APIItem("`SignInWithAppleButton`", "The system button. Takes a label, a request closure, and a completion closure."),
            APIItem("`.signInWithAppleButtonStyle(_:)`", "`.black`, `.white`, or `.whiteOutline`."),
            APIItem("`.signIn`, `.signUp`, `.continue`", "The three button titles."),
            APIItem("`requestedScopes`", "Ask for `.fullName` and `.email`, or nothing."),
            APIItem("`ASAuthorizationAppleIDCredential`", "The result: `user`, `email`, `fullName`, tokens."),
            APIItem("`getCredentialState(forUserID:)`", "Checks if the Apple sign-in is still valid."),
        ],
        guidelines: [
            Guideline(
                "Make it as big as your other sign-in buttons.",
                "The HIG asks for a Sign in with Apple button no smaller than the others, visible without scrolling.",
                good: "Same width and height as Google.",
                bad: "A shrunken Apple button under the rest."
            ) {
                SIWASizeSample(isEqual: true)
            } bad: {
                SIWASizeSample(isEqual: false)
            },
            Guideline(
                "Pick the style that contrasts with the background.",
                "Use `.black` on light backgrounds and `.white` on dark ones. `.whiteOutline` is for white backgrounds where plain white would vanish.",
                good: "Black on a light background.",
                bad: "Black on a dark background disappears."
            ) {
                SIWAContrastSample(isGood: true)
            } bad: {
                SIWAContrastSample(isGood: false)
            },
            Guideline(
                "Ask people to sign in only when it's worth it.",
                "Let people look around first, and say what an account gets them. Forcing sign-in on launch makes people leave."
            ),
            Guideline(
                "Don't ask for a password or a “real” email afterwards.",
                "Not needing a password is the point. If someone chose Hide My Email, respect the relay address instead of asking for their personal one."
            ),
            Guideline(
                "Keep the button at least 140 × 30 points.",
                "As of 2026, the HIG lists 140 pt wide and 30 pt tall as the minimum, with a margin of a tenth of the button's height around it."
            ),
        ],
        sources: [
            "https://developer.apple.com/app-store/review/guidelines/#login-services",
            "https://developer.apple.com/design/human-interface-guidelines/sign-in-with-apple",
            "https://developer.apple.com/documentation/authenticationservices/signinwithapplebutton",
            "https://developer.apple.com/documentation/signinwithapple/authenticating-users-with-sign-in-with-apple",
            "https://developer.apple.com/documentation/authenticationservices/implementing-user-authentication-with-sign-in-with-apple",
            "https://developer.apple.com/help/app-review/guideline-reference/5-1-1-account-deletion",
        ],
        reviewed: "October 2026"
    ) {
        VStack(spacing: 10) {
            SIWAThumbnailButton()
            Text("Continue with Email")
                .font(.subheadline.weight(.semibold))
                .frame(width: 180, height: 36)
                .overlay {
                    RoundedRectangle(cornerRadius: 8).strokeBorder(.separator)
                }
        }
    } content: { page in
        SIWADemo(page: page)
    }
}

// MARK: - Demo

private struct SIWAConfig {
    var label: SIWALabelOption = .signIn
    var style: SIWAStyleOption = .matchScheme
    var height: Double = 50
    var result = ""
}

private struct SIWADemo: View {
    let page: ComponentPage

    var body: some View {
        DemoPage(
            page: page,
            initial: SIWAConfig(),
            usage: """
            SignInWithAppleButton(.signIn) { request in
                request.requestedScopes = [.fullName, .email]
            } onCompletion: { result in
                switch result {
                case .success(let authorization):
                    print(authorization.credential)
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
            .signInWithAppleButtonStyle(.black)
            .frame(height: 50)
            """,
            usageNote: Aside(.important, "Add the **Sign in with Apple** capability to your target in Xcode's Signing & Capabilities tab. Without it the button still draws, but every request fails.")
        ) { $config in
            VStack(spacing: 14) {
                SIWALiveButton(config: $config)
                    .id(config.label)
                Text(config.result.isEmpty ? "Tap to try. This catalog has no sign-in capability, so you'll see the error it returns." : config.result)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 300)
                    .fixedSize(horizontal: false, vertical: true)
            }
        } controls: { $config in
            Section("Button") {
                OptionPicker("Label", selection: $config.label)
                OptionPicker("Style", selection: $config.style)
                ValueSlider("Height", value: $config.height, in: 30...64, step: 2)
            }
        } code: { config in
            var lines: [String] = []
            if config.style == .matchScheme {
                lines += ["@Environment(\\.colorScheme) private var colorScheme", ""]
            }
            lines.append("SignInWithAppleButton(\(config.label.code)) { request in")
            lines.append("    request.requestedScopes = [.fullName, .email]")
            lines.append("} onCompletion: { result in")
            lines.append("    // Handle the result")
            lines.append("}")
            switch config.style {
            case .matchScheme:
                lines.append(".signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)")
            default:
                lines.append(".signInWithAppleButtonStyle(\(config.style.label))")
            }
            lines.append(".frame(height: \(swiftNumber(config.height)))")
            return lines.joined(separator: "\n")
        } examples: {
            SIWAExamples()
        }
    }
}

/// The real button, driven by the config. Recreated when the label changes,
/// because the label is fixed at init.
private struct SIWALiveButton: View {
    @Binding var config: SIWAConfig
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        SignInWithAppleButton(config.label.buttonLabel) { request in
            request.requestedScopes = [.fullName, .email]
        } onCompletion: { result in
            switch result {
            case .success:
                config.result = "Signed in."
            case .failure(let error):
                let code = (error as? ASAuthorizationError)?.code
                config.result = code == .canceled
                    ? "Canceled."
                    : "Error \((error as NSError).code), as expected: this catalog doesn't have the capability. In your app, Apple's sign-in sheet opens instead."
            }
        }
        .signInWithAppleButtonStyle(config.style.style(for: colorScheme))
        .frame(maxWidth: 375)
        .frame(height: config.height)
    }
}

// MARK: - Examples

private struct SIWAExamples: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionTitle("When App Review requires it")
            Prose("As of 2026, Guideline 4.8 says: if you use a third-party or social login, like Google or Facebook, for people's main account, you must **also** offer an equivalent login service that:")
            VStack(alignment: .leading, spacing: 6) {
                Prose("• collects only a name and email address,")
                Prose("• lets people keep their email address private, and")
                Prose("• doesn't track what they do in your app for ads without consent.")
            }
            .padding(.leading, 8)
            Prose("Sign in with Apple is built to do all three: people can hide their email behind a relay address, and Apple doesn't use it to profile them. That's why it's the usual answer.")
            Aside(.note, "You don't need a second option if your app uses only your own accounts (email and password, passkeys), or if people must sign in with an existing school, work, or government ID, or to the third-party service whose content the app shows, like a mail client.")
        }
        .id("required")

        ExampleCard(
            title: "Next to other sign-in buttons",
            caption: "Give `SignInWithAppleButton` the same frame as your other providers, and put it where nobody has to scroll.",
            code: """
            @Environment(\\.colorScheme) private var colorScheme

            VStack(spacing: 12) {
                SignInWithAppleButton(.continue) { request in
                    request.requestedScopes = [.fullName, .email]
                } onCompletion: { result in
                    // Handle the result
                }
                .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
                .frame(height: 50)

                Button {
                    // Your Google sign-in
                } label: {
                    Text("Continue with Google")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.extraLarge)
            }
            """,
            aside: Aside(.important, "If Google or Facebook is your only login, App Review rejects the app under Guideline 4.8 until you add an equivalent option.")
        ) {
            SIWAProviderStack()
                .frame(maxWidth: 340)
        }

        ExampleCard(
            title: "Read the credential",
            caption: "On success, the credential is an `ASAuthorizationAppleIDCredential`. Its `user` id is stable, so key your account on it.",
            code: """
            SignInWithAppleButton(.signIn) { request in
                request.requestedScopes = [.fullName, .email]
            } onCompletion: { result in
                guard case .success(let authorization) = result,
                      let credential = authorization.credential
                        as? ASAuthorizationAppleIDCredential
                else { return }

                let userID = credential.user        // Always there
                let email = credential.email        // First time only
                let name = credential.fullName      // First time only
                // Send these to your server and save them now.
            }
            """,
            aside: Aside(.important, "The credential carries the name and email only the first time someone signs in. Store them right away: later sign-ins leave out the name, and the email comes only inside the identity token.")
        ) {
            SIWACredentialSample()
        }
    }
}

private struct SIWAProviderStack: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: 12) {
            SignInWithAppleButton(.continue) { request in
                request.requestedScopes = [.fullName, .email]
            } onCompletion: { _ in }
            .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
            .frame(height: 50)

            Button {
            } label: {
                Text("Continue with Google")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .controlSize(.extraLarge)
        }
    }
}

/// A drawing of what a credential holds on first and later sign-ins.
private struct SIWACredentialSample: View {
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            column("First sign-in", rows: [("user", "001234.abc…"), ("email", "x7k2@privaterelay…"), ("fullName", "Maya Chen")])
            column("Later sign-ins", rows: [("user", "001234.abc…"), ("email", "nil"), ("fullName", "nil")])
        }
        .frame(maxWidth: 380)
    }

    private func column(_ title: String, rows: [(String, String)]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline.weight(.semibold))
            ForEach(rows, id: \.0) { key, value in
                VStack(alignment: .leading, spacing: 1) {
                    Text(key)
                        .font(.caption.monospaced())
                        .foregroundStyle(.secondary)
                    Text(value)
                        .font(.caption.monospaced())
                        .foregroundStyle(value == "nil" ? AnyShapeStyle(.orange) : AnyShapeStyle(.primary))
                        .lineLimit(1)
                }
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.fill.quaternary, in: .rect(cornerRadius: 12))
    }
}

// MARK: - Guideline samples

private struct SIWASizeSample: View {
    let isEqual: Bool
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: 10) {
            if isEqual {
                apple.frame(height: 44)
            }
            Button {
            } label: {
                Text("Continue with Google").frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
            Button {
            } label: {
                Text("Continue with Email").frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
            if !isEqual {
                apple.frame(width: 140, height: 30)
            }
        }
        .frame(maxWidth: 260)
    }

    private var apple: some View {
        SignInWithAppleButton(.continue) { _ in } onCompletion: { _ in }
            .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
            .allowsHitTesting(false)
    }
}

private struct SIWAContrastSample: View {
    let isGood: Bool

    var body: some View {
        SignInWithAppleButton(.signIn) { _ in } onCompletion: { _ in }
            .signInWithAppleButtonStyle(.black)
            .frame(width: 220, height: 44)
            .allowsHitTesting(false)
            .padding(20)
            .background(isGood ? Color(white: 0.96) : Color(white: 0.06), in: .rect(cornerRadius: 14))
    }
}

/// The thumbnail draws a lookalike: the real button grabs taps and has no
/// fixed size for a 150pt card.
private struct SIWAThumbnailButton: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        SignInWithAppleButton(.signIn) { _ in } onCompletion: { _ in }
            .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
            .frame(width: 180, height: 36)
            .allowsHitTesting(false)
    }
}

// MARK: - Options

private enum SIWALabelOption: DemoOption {
    case signIn, signUp, continueLabel

    var label: String {
        switch self {
        case .signIn: ".signIn"
        case .signUp: ".signUp"
        case .continueLabel: ".continue"
        }
    }

    var code: String { label }

    var buttonLabel: SignInWithAppleButton.Label {
        switch self {
        case .signIn: .signIn
        case .signUp: .signUp
        case .continueLabel: .continue
        }
    }
}

private enum SIWAStyleOption: DemoOption {
    case matchScheme, black, white, whiteOutline

    var label: String {
        switch self {
        case .matchScheme: "Match light/dark"
        case .black: ".black"
        case .white: ".white"
        case .whiteOutline: ".whiteOutline"
        }
    }

    func style(for scheme: ColorScheme) -> SignInWithAppleButton.Style {
        switch self {
        case .matchScheme: scheme == .dark ? .white : .black
        case .black: .black
        case .white: .white
        case .whiteOutline: .whiteOutline
        }
    }
}
