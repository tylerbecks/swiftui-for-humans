import SwiftUI

extension ComponentPage {
    static let secureField = ComponentPage(
        id: "secure-field",
        title: "SecureField",
        summary: "A text field that hides what people type, for passwords and other secrets.",
        category: .textInput,
        symbol: "key",
        availability: ["macOS 10.15+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/securefield",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/entering-data",
        aliases: ["password", "password field", "<input type=password>", "NSSecureTextField", "secret", "hidden text", "login", "sign in", "textContentType", "AutoFill", "caps lock"],
        related: ["text-field", "focus-keyboard", "form", "keyboard-shortcuts"],
        notes: [
            "**The field protects its text for you.** It shows a dot for each character, won't let people cut or copy the contents, and shows an indicator while Caps Lock is on.",
            "**Consider not asking for a password at all.** The HIG suggests Sign in with Apple, or passkeys, before an app-specific password.",
        ],
        api: [
            APIItem("`SecureField(_:text:prompt:)`", "A hidden field bound to a `String`."),
            APIItem("`.textContentType(.password)`", "Marks the field for password suggestions."),
            APIItem("`.textContentType(.newPassword)`", "For a password people are creating."),
            APIItem("`.textContentType(.username)`", "On the account name field beside it."),
            APIItem("`.onSubmit { }`", "Runs when people press Return."),
            APIItem("`.keyboardShortcut(.defaultAction)`", "Makes Sign In the Return-key button."),
        ],
        guidelines: [
            Guideline(
                "Never fill in a password for people.",
                "Ask people to type it each time, or use biometric or keychain authentication instead.",
                good: "The password field starts empty.",
                bad: "The password field arrives already filled."
            ) {
                MacPasswordSample(password: "")
            } bad: {
                MacPasswordSample(password: "hunter22")
            },
            Guideline(
                "Turn on Sign In only when it can work.",
                "Keep the button disabled until people fill in the required fields, so it's clear what's missing.",
                good: "Sign In waits for the password.",
                bad: "Sign In is clickable with an empty field."
            ) {
                MacSignInButtonSample(isEnabled: false)
            } bad: {
                MacSignInButtonSample(isEnabled: true)
            },
            Guideline(
                "Use a secure field for anything sensitive.",
                "Passwords, PINs, and recovery codes belong in a `SecureField`, never a plain `TextField`."
            ),
        ]
    ) {
        VStack(spacing: 8) {
            TextField("User Name", text: .constant("jappleseed"))
            SecureField("Password", text: .constant("password"))
        }
        .textFieldStyle(.roundedBorder)
        .frame(width: 170)
    } content: { page in
        MacSecureFieldDemo(page: page)
    }
}

private struct MacSecureFieldConfig {
    var title = "Password"
    var prompt = "Required"
    var password = ""
    var submitted = 0
    var contentType: MacContentTypeOption = .password
    var style: MacTextFieldStyleOption = .automatic
    var size: MacTextControlSize = .regular
    var isDisabled = false
}

private struct MacSecureFieldDemo: View {
    let page: ComponentPage

    var body: some View {
        DemoPage(
            page: page,
            initial: MacSecureFieldConfig(),
            usage: """
            @State private var password = ""

            SecureField("Password", text: $password)
                .textContentType(.password)
                .onSubmit {
                    print("Signing in…")
                }
            """,
            usageNote: Aside(.note, "Like `TextField`, the binding updates on every keystroke, so you can check the length or enable a button as people type.")
        ) { $config in
            VStack(spacing: 14) {
                SecureField(config.title, text: $config.password, prompt: config.prompt.isEmpty ? nil : Text(config.prompt))
                    .textContentType(config.contentType.type)
                    .macTextFieldStyle(config.style)
                    .controlSize(config.size.size)
                    .disabled(config.isDisabled)
                    .frame(width: 240)
                    .onSubmit {
                        config.submitted += 1
                    }

                MacTextReadout("password.count = \(config.password.count)")
                MacTextReadout(config.submitted == 0 ? "Press Return to submit" : "onSubmit ran \(config.submitted)×")
            }
        } controls: { $config in
            Section("Content") {
                TextField("Title", text: $config.title)
                TextField("Prompt", text: $config.prompt)
                OptionPicker("Content type", selection: $config.contentType)
            }
            Section("Appearance") {
                OptionPicker("Style", selection: $config.style)
                OptionPicker("Size", selection: $config.size)
                Toggle("Disabled", isOn: $config.isDisabled)
            }
        } code: { config in
            var lines = ["@State private var password = \"\"", ""]
            if config.prompt.isEmpty {
                lines.append("SecureField(\(swiftString(config.title)), text: $password)")
            } else {
                lines.append("SecureField(\(swiftString(config.title)), text: $password, prompt: Text(\(swiftString(config.prompt))))")
            }
            if config.contentType != .none {
                lines.append("    .textContentType(\(config.contentType.label))")
            }
            if config.style != .automatic {
                lines.append("    .textFieldStyle(\(config.style.label))")
            }
            if config.size != .regular {
                lines.append("    .controlSize(\(config.size.label))")
            }
            if config.isDisabled {
                lines.append("    .disabled(true)")
            }
            return lines.joined(separator: "\n")
        } examples: {
            MacSecureFieldExamples()
        }
    }
}

// MARK: - Examples

private struct MacSecureFieldExamples: View {
    var body: some View {
        ExampleCard(
            title: "A sign-in form",
            caption: "Mark the fields with `.textContentType` so the system can suggest saved accounts, and give Sign In `.keyboardShortcut(.defaultAction)` so Return clicks it.",
            code: """
            @State private var username = ""
            @State private var password = ""
            @State private var message = ""

            Form {
                TextField("User Name", text: $username)
                    .textContentType(.username)
                SecureField("Password", text: $password)
                    .textContentType(.password)
                Button("Sign In") {
                    message = "Signed in as \\(username)"
                }
                .keyboardShortcut(.defaultAction)
                .disabled(username.isEmpty || password.isEmpty)
                Text(message)
                    .foregroundStyle(.secondary)
            }
            .frame(width: 320)
            """,
            minHeight: 190,
            aside: Aside(.note, "On the Mac, the default button gets special coloring, so people can see that Return clicks it.")
        ) {
            MacSignInFormSample()
        }

        ExampleCard(
            title: "Create a password",
            caption: "Use `.textContentType(.newPassword)` for a password people are making, and check the two fields match as they type.",
            code: """
            @State private var newPassword = ""
            @State private var confirmation = ""

            Form {
                SecureField("New Password", text: $newPassword)
                    .textContentType(.newPassword)
                SecureField("Verify", text: $confirmation)
                    .textContentType(.newPassword)
                if !confirmation.isEmpty && confirmation != newPassword {
                    Text("The passwords don't match.")
                        .foregroundStyle(.red)
                }
            }
            .frame(width: 320)
            """,
            minHeight: 160
        ) {
            MacNewPasswordSample()
        }

        ExampleCard(
            title: "Show the password",
            caption: "Swap the `SecureField` for a `TextField` bound to the same string, so people can check what they typed.",
            code: """
            @State private var password = ""
            @State private var isShowing = false

            HStack {
                Group {
                    if isShowing {
                        TextField("Password", text: $password)
                    } else {
                        SecureField("Password", text: $password)
                    }
                }
                .frame(width: 200)
                Toggle("Show Password", systemImage: isShowing ? "eye.slash" : "eye", isOn: $isShowing)
                    .toggleStyle(.button)
                    .labelStyle(.iconOnly)
            }
            """,
            minHeight: 120
        ) {
            MacShowPasswordSample()
        }
    }
}

private struct MacSignInFormSample: View {
    @State private var username = ""
    @State private var password = ""
    @State private var message = ""

    var body: some View {
        Form {
            TextField("User Name", text: $username)
                .textContentType(.username)
            SecureField("Password", text: $password)
                .textContentType(.password)
            Button("Sign In") {
                message = "Signed in as \(username)"
            }
            .keyboardShortcut(.defaultAction)
            .disabled(username.isEmpty || password.isEmpty)
            Text(message)
                .foregroundStyle(.secondary)
        }
        .frame(width: 320)
    }
}

private struct MacNewPasswordSample: View {
    @State private var newPassword = ""
    @State private var confirmation = ""

    var body: some View {
        Form {
            SecureField("New Password", text: $newPassword)
                .textContentType(.newPassword)
            SecureField("Verify", text: $confirmation)
                .textContentType(.newPassword)
            if !confirmation.isEmpty && confirmation != newPassword {
                Text("The passwords don't match.")
                    .foregroundStyle(.red)
            }
        }
        .frame(width: 320)
    }
}

private struct MacShowPasswordSample: View {
    @State private var password = "correct horse"
    @State private var isShowing = false

    var body: some View {
        HStack {
            Group {
                if isShowing {
                    TextField("Password", text: $password)
                } else {
                    SecureField("Password", text: $password)
                }
            }
            .frame(width: 200)
            Toggle("Show Password", systemImage: isShowing ? "eye.slash" : "eye", isOn: $isShowing)
                .toggleStyle(.button)
                .labelStyle(.iconOnly)
        }
    }
}

/// A password row for the prefill guideline.
private struct MacPasswordSample: View {
    let password: String

    var body: some View {
        HStack {
            Text("Password:")
            SecureField("Password", text: .constant(password), prompt: Text("Required"))
                .labelsHidden()
                .frame(width: 140)
        }
    }
}

/// A small sign-in sheet for the disabled-button guideline.
private struct MacSignInButtonSample: View {
    let isEnabled: Bool

    var body: some View {
        VStack(alignment: .trailing, spacing: 8) {
            TextField("User Name", text: .constant("jappleseed"))
            SecureField("Password", text: .constant(""), prompt: Text("Password"))
            Button("Sign In") {}
                .keyboardShortcut(.defaultAction)
                .disabled(!isEnabled)
        }
        .labelsHidden()
        .frame(width: 190)
    }
}

// MARK: - Options

private enum MacContentTypeOption: DemoOption {
    case none, password, newPassword

    var label: String {
        switch self {
        case .none: "nil"
        case .password: ".password"
        case .newPassword: ".newPassword"
        }
    }

    /// SwiftUI's `.textContentType(_:)` takes AppKit's `NSTextContentType`
    /// on the Mac; there's no SwiftUI type for it.
    var type: NSTextContentType? {
        switch self {
        case .none: nil
        case .password: .password
        case .newPassword: .newPassword
        }
    }
}
