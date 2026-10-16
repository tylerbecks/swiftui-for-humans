import SwiftUI

extension ComponentPage {
    static let secureField = ComponentPage(
        id: "secure-field",
        title: "SecureField",
        summary: "A text field that hides what people type, for passwords and PINs.",
        category: .textInput,
        symbol: "lock.rectangle",
        availability: ["iOS 13.0+", "macOS 10.15+", "visionOS 1.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/securefield",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/text-fields",
        aliases: ["password", "type=\"password\"", "input password", "pin", "hidden text", "masked input", "isSecureTextEntry", "login"],
        related: ["text-field", "focus-state", "login-form"],
        notes: [
            "**It works like a `TextField`.** It takes the same styles and modifiers, and the string you bind holds the real text. Only the display is hidden.",
            "**iOS locks it down for you.** Autocorrect, dictation, and copying are off, and each character shows for a moment before it turns into a dot.",
        ],
        api: [
            APIItem("`SecureField(_:text:)`", "A hidden-text field bound to a `String`."),
            APIItem("`.textContentType(.password)`", "Offers saved passwords from AutoFill when signing in."),
            APIItem("`.textContentType(.newPassword)`", "Suggests a strong password when signing up."),
            APIItem("`.textContentType(.oneTimeCode)`", "Fills a code from Messages or Mail."),
            APIItem("`.textFieldStyle(_:)`", "The same styles as `TextField`, such as `.roundedBorder`."),
            APIItem("`.onSubmit { }`", "Runs when people tap Return, such as to sign in."),
        ],
        guidelines: [
            Guideline(
                "Always hide passwords and other secrets.",
                "Someone nearby can read a plain field over a shoulder or in a screen recording. A `SecureField` shows dots instead.",
                good: "The password shows as dots.",
                bad: "A plain field shows the password."
            ) {
                SecureSample(isSecure: true)
            } bad: {
                SecureSample(isSecure: false)
            },
            Guideline(
                "Support AutoFill.",
                "With the right `.textContentType`, people sign in with Face ID instead of typing. Mark the username field too, so both fill at once."
            ),
            Guideline(
                "Check a new password before people move on.",
                "Show the rules and whether they're met while people type. Finding out after Submit means typing it all again."
            ),
        ]
    ) {
        VStack(spacing: 10) {
            TextField("Username", text: .constant("taylor"))
            SecureField("Password", text: .constant("hunter22"))
        }
        .textFieldStyle(.roundedBorder)
        .frame(width: 200)
    } content: { page in
        SecureFieldDemo(page: page)
    }
}

private struct SecureFieldConfig {
    var placeholder = "Password"
    var password = ""
    var style: SFStyleOption = .roundedBorder
    var contentType: SFContentType = .password
    var submitsOnReturn = false
    var isDisabled = false
}

private struct SecureFieldDemo: View {
    let page: ComponentPage
    @State private var submitted = 0

    var body: some View {
        DemoPage(
            page: page,
            initial: SecureFieldConfig(),
            previewHeight: 200,
            usage: """
            @State private var password = ""

            SecureField("Password", text: $password)
                .textContentType(.password)
                .textFieldStyle(.roundedBorder)
            """,
            usageNote: Aside(.note, "Use `.password` on a sign-in screen and `.newPassword` on a sign-up screen, so iOS fills in the saved password or suggests a strong one.")
        ) { $config in
            VStack(alignment: .leading, spacing: 14) {
                SecureField(config.placeholder, text: $config.password)
                    .sfStyled(config.style)
                    .textContentType(config.contentType.type)
                    .onSubmit {
                        if config.submitsOnReturn { submitted += 1 }
                    }
                    .disabled(config.isDisabled)
                Text(config.password.isEmpty
                     ? "Type a password. The string you bind still holds the real text."
                     : "password has \(config.password.count) character\(config.password.count == 1 ? "" : "s")"
                     + (submitted > 0 ? " · submitted \(submitted)×" : ""))
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: 320)
        } controls: { $config in
            Section("Content") {
                TextField("Placeholder", text: $config.placeholder)
                OptionPicker("Content type", selection: $config.contentType)
            }
            Section("Appearance") {
                OptionPicker("Style", selection: $config.style)
                Toggle("Run action on Return", isOn: $config.submitsOnReturn)
                Toggle("Disabled", isOn: $config.isDisabled)
            }
        } code: { config in
            var lines = ["@State private var password = \"\"", ""]
            lines.append("SecureField(\(swiftString(config.placeholder)), text: $password)")
            if config.style != .automatic {
                lines.append("    .textFieldStyle(\(config.style.label))")
            }
            if let type = config.contentType.code {
                lines.append("    .textContentType(\(type))")
            }
            if config.submitsOnReturn {
                lines.append("    .onSubmit {")
                lines.append("        // Sign in")
                lines.append("    }")
            }
            if config.isDisabled {
                lines.append("    .disabled(true)")
            }
            return lines.joined(separator: "\n")
        } examples: {
            ExampleCard(
                title: "Sign-in form",
                caption: "In a `Form`, fields need no style. Mark them `.username` and `.password` so AutoFill fills both.",
                code: """
                @State private var username = ""
                @State private var password = ""

                Form {
                    TextField("Username", text: $username)
                        .textContentType(.username)
                        .textInputAutocapitalization(.never)
                    SecureField("Password", text: $password)
                        .textContentType(.password)
                    Button("Sign In") {
                        // Sign in
                    }
                    .disabled(username.isEmpty || password.isEmpty)
                }
                """
            ) {
                SignInFormExample()
            }
            ExampleCard(
                title: "Show / hide password",
                caption: "Swap a `SecureField` for a `TextField` bound to the same string when people tap the eye button.",
                code: """
                @State private var password = ""
                @State private var isRevealed = false

                HStack {
                    Group {
                        if isRevealed {
                            TextField("Password", text: $password)
                        } else {
                            SecureField("Password", text: $password)
                        }
                    }
                    .textContentType(.password)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()

                    Button(isRevealed ? "Hide" : "Show",
                           systemImage: isRevealed ? "eye.slash" : "eye") {
                        isRevealed.toggle()
                    }
                    .labelStyle(.iconOnly)
                    .foregroundStyle(.secondary)
                }
                .padding(12)
                .background(.fill.tertiary, in: .rect(cornerRadius: 10))
                """,
                aside: Aside(.note, "There's no built-in show/hide option. This swap is the usual way, and the text survives it because both fields share one string.")
            ) {
                RevealPasswordExample()
            }
            ExampleCard(
                title: "New password with strength meter",
                caption: "Mark a sign-up field `.newPassword` and show a `Gauge` that updates as people type.",
                code: """
                @State private var password = ""

                private var strength: Int {
                    var score = 0
                    if password.count >= 8 { score += 1 }
                    if password.contains(where: \\.isNumber) { score += 1 }
                    if password.contains(where: { !$0.isLetter && !$0.isNumber }) { score += 1 }
                    return score
                }

                VStack(alignment: .leading, spacing: 8) {
                    SecureField("New password", text: $password)
                        .textContentType(.newPassword)
                        .textFieldStyle(.roundedBorder)
                    Gauge(value: Double(strength), in: 0...3) {}
                        .gaugeStyle(.accessoryLinearCapacity)
                        .tint(strength < 2 ? .orange : .green)
                    Text("Use 8+ characters with a number and a symbol.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                """,
                aside: Aside(.note, "iOS suggests a strong password only when your app has Associated Domains set up for your website, so it can save the password there.")
            ) {
                StrengthExample()
            }
        }
    }
}

// MARK: - Examples

private struct RevealPasswordExample: View {
    @State private var password = "correct horse"
    @State private var isRevealed = false

    var body: some View {
        HStack {
            Group {
                if isRevealed {
                    TextField("Password", text: $password)
                } else {
                    SecureField("Password", text: $password)
                }
            }
            .textContentType(.password)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()

            Button(isRevealed ? "Hide" : "Show", systemImage: isRevealed ? "eye.slash" : "eye") {
                isRevealed.toggle()
            }
            .labelStyle(.iconOnly)
            .foregroundStyle(.secondary)
            .contentTransition(.symbolEffect(.replace))
        }
        .padding(12)
        .background(.fill.tertiary, in: .rect(cornerRadius: 10))
        .frame(maxWidth: 300)
    }
}

private struct StrengthExample: View {
    @State private var password = "swift42"

    private var strength: Int {
        var score = 0
        if password.count >= 8 { score += 1 }
        if password.contains(where: \.isNumber) { score += 1 }
        if password.contains(where: { !$0.isLetter && !$0.isNumber }) { score += 1 }
        return score
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            SecureField("New password", text: $password)
                .textContentType(.newPassword)
                .textFieldStyle(.roundedBorder)
            Gauge(value: Double(strength), in: 0...3) {}
                .gaugeStyle(.accessoryLinearCapacity)
                .tint(strength < 2 ? .orange : .green)
                .animation(.snappy, value: strength)
            Text("Use 8+ characters with a number and a symbol.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: 300)
    }
}

private struct SignInFormExample: View {
    @State private var username = ""
    @State private var password = ""

    var body: some View {
        Form {
            TextField("Username", text: $username)
                .textContentType(.username)
                .textInputAutocapitalization(.never)
            SecureField("Password", text: $password)
                .textContentType(.password)
            Button("Sign In") {}
                .disabled(username.isEmpty || password.isEmpty)
        }
        .scrollDisabled(true)
        .contentMargins(.vertical, 8, for: .scrollContent)
        .frame(height: 195)
        .clipShape(.rect(cornerRadius: 12))
    }
}

// MARK: - Guideline samples

/// A filled sign-in pair whose password field is or isn't secure.
private struct SecureSample: View {
    let isSecure: Bool

    var body: some View {
        VStack(spacing: 10) {
            TextField("Email", text: .constant("taylor@example.com"))
            if isSecure {
                SecureField("Password", text: .constant("sunflower42"))
            } else {
                TextField("Password", text: .constant("sunflower42"))
            }
        }
        .textFieldStyle(.roundedBorder)
        .frame(width: 220)
    }
}

// MARK: - Options

private enum SFStyleOption: DemoOption {
    case automatic, roundedBorder, plain

    var label: String {
        switch self {
        case .automatic: ".automatic"
        case .roundedBorder: ".roundedBorder"
        case .plain: ".plain"
        }
    }
}

private enum SFContentType: DemoOption {
    case none, password, newPassword, oneTimeCode

    var label: String {
        switch self {
        case .none: "None"
        case .password: ".password"
        case .newPassword: ".newPassword"
        case .oneTimeCode: ".oneTimeCode"
        }
    }

    var code: String? { self == .none ? nil : label }

    var type: UITextContentType? {
        switch self {
        case .none: nil
        case .password: .password
        case .newPassword: .newPassword
        case .oneTimeCode: .oneTimeCode
        }
    }
}

private extension View {
    @ViewBuilder
    func sfStyled(_ style: SFStyleOption) -> some View {
        switch style {
        case .automatic: textFieldStyle(.automatic)
        case .roundedBorder: textFieldStyle(.roundedBorder)
        case .plain: textFieldStyle(.plain)
        }
    }
}
