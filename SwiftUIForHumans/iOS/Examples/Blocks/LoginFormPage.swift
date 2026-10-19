import SwiftUI
import AuthenticationServices

extension ComponentPage {
    static let loginForm = ComponentPage(
        id: "login-form",
        title: "Login Screen",
        summary: "An email and password sign-in screen with AutoFill, focus handling, and Sign in with Apple.",
        category: .blocks,
        kind: .block,
        symbol: "person.badge.key",
        availability: ["iOS 26.0+"],
        docsURL: "https://developer.apple.com/documentation/authenticationservices/signinwithapplebutton",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/sign-in-with-apple",
        aliases: ["sign in", "log in", "login page", "auth", "authentication", "password field", "input type=password", "sign in with apple", "credentials"],
        related: ["text-field", "secure-field", "focus-state", "button"],
        notes: [
            "**Set `.textContentType` on both fields.** With `.emailAddress` and `.password`, iOS offers saved passwords and AutoFill, the biggest usability win on a login screen.",
            "**Add the Sign in with Apple capability to your app target.** Without it, `SignInWithAppleButton` still draws, but every request fails.",
            "**Put the form in a `ScrollView`.** The keyboard covers half of a small phone, and scrolling keeps every field and button reachable.",
        ],
        guidelines: [
            Guideline(
                "Make Sign in with Apple as big as your other sign-in buttons.",
                "It saves people from typing a password, so it deserves equal weight. A smaller button reads as an afterthought.",
                good: "Both sign-in buttons are the same size.",
                bad: "A shrunken Apple button is easy to miss."
            ) {
                SignInButtonsSample(isEqual: true)
            } bad: {
                SignInButtonsSample(isEqual: false)
            },
            Guideline(
                "Let people look around before you ask them to sign in.",
                "A sign-in wall on first launch makes many people quit. Ask when an account unlocks something they want, and say what it is."
            ),
            Guideline(
                "Use a secure field for the password, and never prefill it.",
                "Hidden characters protect people in public places. An empty field means they authenticate themselves, by typing or with a saved password."
            ),
        ]
    ) {
        BlockThumbnail(hasNavigationBar: false) {
            LoginScreen()
        }
    } content: { page in
        BlockShowcase(
            page: page,
            tryIt: "Try it: type an email, press Return to jump to the password, tap the eye to reveal it, then **Sign In**. Any address with an @ and a 6+ character password works.",
            code: loginFormSource,
            components: ["text-field", "secure-field", "focus-state", "button", "progress-view", "liquid-glass"],
            hasNavigationBar: false
        ) {
            LoginScreen()
        } notes: {
            Aside(.note, "The fields are a [TextField](catalog://text-field) and a [SecureField](catalog://secure-field) that swap when you tap the eye. [@FocusState](catalog://focus-state) plus `.onSubmit` moves to the password on Return, like `tabindex` on the web.")
            Aside(.note, "**Sign In** is a [Button](catalog://button) that stays disabled until the form is valid and shows a [ProgressView](catalog://progress-view) while it works, so nobody taps twice. Sign in with Apple is the real `SignInWithAppleButton` from AuthenticationServices.")
            Aside(.note, "**Why iOS 26?** Only the [Liquid Glass](catalog://liquid-glass) button styles need it. Change `.glassProminent` to `.borderedProminent` and `.glass` to `.bordered`, and the screen runs on iOS 17.")
        }
    }
}

/// Guideline preview: a Sign In button above a Sign in with Apple button,
/// either the same size or shrunken.
private struct SignInButtonsSample: View {
    let isEqual: Bool
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: 12) {
            Button {} label: {
                Text("Sign In")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.capsule)
            .controlSize(.large)

            SignInWithAppleButton(.signIn) { _ in } onCompletion: { _ in }
                .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
                .frame(width: isEqual ? nil : 130, height: isEqual ? 50 : 30)
                .clipShape(.capsule)
        }
        .frame(width: 260)
    }
}

// <block-source>
private struct LoginScreen: View {
    private enum Field {
        case email, password
    }

    @State private var email = ""
    @State private var password = ""
    @State private var showsPassword = false
    @State private var isSigningIn = false
    @State private var signedInEmail: String?
    @FocusState private var focusedField: Field?
    @Environment(\.colorScheme) private var colorScheme

    private var canSignIn: Bool {
        email.contains("@") && password.count >= 6 && !isSigningIn
    }

    var body: some View {
        if let signedInEmail {
            ContentUnavailableView {
                Label {
                    Text("You're signed in")
                } icon: {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                }
            } description: {
                Text(signedInEmail)
            } actions: {
                Button("Sign Out") {
                    self.signedInEmail = nil
                    password = ""
                }
                .buttonStyle(.glass)
            }
        } else {
            form
        }
    }

    private var form: some View {
        ScrollView {
            VStack(spacing: 28) {
                VStack(spacing: 12) {
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 32, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 72, height: 72)
                        .background(.green.gradient, in: .rect(cornerRadius: 18))
                    Text("Welcome back")
                        .font(.title.bold())
                    Text("Sign in to keep your plants thriving.")
                        .foregroundStyle(.secondary)
                }
                .multilineTextAlignment(.center)
                .padding(.top, 24)

                VStack(alignment: .leading, spacing: 12) {
                    TextField("Email", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .focused($focusedField, equals: .email)
                        .submitLabel(.next)
                        .onSubmit { focusedField = .password }
                        .padding(14)
                        .background(.fill.tertiary, in: .rect(cornerRadius: 12))

                    HStack {
                        Group {
                            if showsPassword {
                                TextField("Password", text: $password)
                            } else {
                                SecureField("Password", text: $password)
                            }
                        }
                        .textContentType(.password)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .focused($focusedField, equals: .password)
                        .submitLabel(.go)
                        .onSubmit(signIn)

                        Button {
                            showsPassword.toggle()
                        } label: {
                            Image(systemName: showsPassword ? "eye.slash" : "eye")
                                .foregroundStyle(.secondary)
                        }
                        .accessibilityLabel(showsPassword ? "Hide password" : "Show password")
                    }
                    .padding(14)
                    .background(.fill.tertiary, in: .rect(cornerRadius: 12))

                    Button("Forgot password?") {}
                        .font(.footnote.weight(.medium))
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }

                VStack(spacing: 16) {
                    Button(action: signIn) {
                        ZStack {
                            Text("Sign In")
                                .opacity(isSigningIn ? 0 : 1)
                            if isSigningIn {
                                ProgressView()
                            }
                        }
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.glassProminent)
                    .controlSize(.large)
                    .disabled(!canSignIn)

                    HStack(spacing: 12) {
                        VStack { Divider() }
                        Text("or")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                        VStack { Divider() }
                    }

                    SignInWithAppleButton(.signIn) { request in
                        request.requestedScopes = [.fullName, .email]
                    } onCompletion: { _ in }
                        .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
                        .frame(height: 50)
                        .clipShape(.capsule)
                }

                HStack(spacing: 4) {
                    Text("New here?")
                        .foregroundStyle(.secondary)
                    Button("Create an account") {}
                        .fontWeight(.semibold)
                }
                .font(.subheadline)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .scrollDismissesKeyboard(.interactively)
    }

    private func signIn() {
        guard canSignIn else { return }
        focusedField = nil
        isSigningIn = true
        Task {
            // Replace this pause with your real sign-in request.
            try? await Task.sleep(for: .seconds(1.5))
            isSigningIn = false
            signedInEmail = email
        }
    }
}
// </block-source>

// <block-code>
private let loginFormSource = #"""
import SwiftUI
import AuthenticationServices

struct LoginScreen: View {
    private enum Field {
        case email, password
    }

    @State private var email = ""
    @State private var password = ""
    @State private var showsPassword = false
    @State private var isSigningIn = false
    @State private var signedInEmail: String?
    @FocusState private var focusedField: Field?
    @Environment(\.colorScheme) private var colorScheme

    private var canSignIn: Bool {
        email.contains("@") && password.count >= 6 && !isSigningIn
    }

    var body: some View {
        if let signedInEmail {
            ContentUnavailableView {
                Label {
                    Text("You're signed in")
                } icon: {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                }
            } description: {
                Text(signedInEmail)
            } actions: {
                Button("Sign Out") {
                    self.signedInEmail = nil
                    password = ""
                }
                .buttonStyle(.glass)
            }
        } else {
            form
        }
    }

    private var form: some View {
        ScrollView {
            VStack(spacing: 28) {
                VStack(spacing: 12) {
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 32, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 72, height: 72)
                        .background(.green.gradient, in: .rect(cornerRadius: 18))
                    Text("Welcome back")
                        .font(.title.bold())
                    Text("Sign in to keep your plants thriving.")
                        .foregroundStyle(.secondary)
                }
                .multilineTextAlignment(.center)
                .padding(.top, 24)

                VStack(alignment: .leading, spacing: 12) {
                    TextField("Email", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .focused($focusedField, equals: .email)
                        .submitLabel(.next)
                        .onSubmit { focusedField = .password }
                        .padding(14)
                        .background(.fill.tertiary, in: .rect(cornerRadius: 12))

                    HStack {
                        Group {
                            if showsPassword {
                                TextField("Password", text: $password)
                            } else {
                                SecureField("Password", text: $password)
                            }
                        }
                        .textContentType(.password)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .focused($focusedField, equals: .password)
                        .submitLabel(.go)
                        .onSubmit(signIn)

                        Button {
                            showsPassword.toggle()
                        } label: {
                            Image(systemName: showsPassword ? "eye.slash" : "eye")
                                .foregroundStyle(.secondary)
                        }
                        .accessibilityLabel(showsPassword ? "Hide password" : "Show password")
                    }
                    .padding(14)
                    .background(.fill.tertiary, in: .rect(cornerRadius: 12))

                    Button("Forgot password?") {}
                        .font(.footnote.weight(.medium))
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }

                VStack(spacing: 16) {
                    Button(action: signIn) {
                        ZStack {
                            Text("Sign In")
                                .opacity(isSigningIn ? 0 : 1)
                            if isSigningIn {
                                ProgressView()
                            }
                        }
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.glassProminent)
                    .controlSize(.large)
                    .disabled(!canSignIn)

                    HStack(spacing: 12) {
                        VStack { Divider() }
                        Text("or")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                        VStack { Divider() }
                    }

                    SignInWithAppleButton(.signIn) { request in
                        request.requestedScopes = [.fullName, .email]
                    } onCompletion: { _ in }
                        .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
                        .frame(height: 50)
                        .clipShape(.capsule)
                }

                HStack(spacing: 4) {
                    Text("New here?")
                        .foregroundStyle(.secondary)
                    Button("Create an account") {}
                        .fontWeight(.semibold)
                }
                .font(.subheadline)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .scrollDismissesKeyboard(.interactively)
    }

    private func signIn() {
        guard canSignIn else { return }
        focusedField = nil
        isSigningIn = true
        Task {
            // Replace this pause with your real sign-in request.
            try? await Task.sleep(for: .seconds(1.5))
            isSigningIn = false
            signedInEmail = email
        }
    }
}

#Preview {
    LoginScreen()
}
"""#

// MARK: - Block page parts
// Each Blocks file carries its own private copy of these, so files stay
// independent and nothing leaks into the shared module namespace.

/// The standard block page: live screen in a phone frame, what it is built
/// with (tappable links to those catalog pages), then the full source.
private struct BlockShowcase<Screen: View, Notes: View, More: View>: View {
    let page: ComponentPage
    let tryIt: String
    let code: String
    let components: [ComponentPage.ID]
    let hasNavigationBar: Bool
    let screen: Screen
    let notes: Notes
    let more: More

    @Environment(\.openPage) private var openPage
    @State private var showsFullScreen = false

    init(
        page: ComponentPage,
        tryIt: String,
        code: String,
        components: [ComponentPage.ID],
        hasNavigationBar: Bool = true,
        @ViewBuilder screen: () -> Screen,
        @ViewBuilder notes: () -> Notes,
        @ViewBuilder more: () -> More
    ) {
        self.page = page
        self.tryIt = tryIt
        self.code = code
        self.components = components
        self.hasNavigationBar = hasNavigationBar
        self.screen = screen()
        self.notes = notes()
        self.more = more()
    }

    var body: some View {
        ArticlePage(page: page) {
            VStack(alignment: .leading, spacing: 12) {
                PreviewCard(title: "Live screen", minHeight: 600) {
                    PhoneScreen(hasNavigationBar: hasNavigationBar) {
                        screen
                    }
                }
                Button {
                    showsFullScreen = true
                } label: {
                    Label("Open Full Screen", systemImage: "arrow.up.left.and.arrow.down.right")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                .accessibilityIdentifier("open-full-screen")
                Label {
                    RichText(tryIt)
                        .fixedSize(horizontal: false, vertical: true)
                } icon: {
                    Image(systemName: "hand.tap")
                        .foregroundStyle(.tint)
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
            .id("live")

            VStack(alignment: .leading, spacing: 12) {
                SectionTitle("Built with")
                notes
                FlowLayout(spacing: 8) {
                    ForEach(components.compactMap { Catalog.page(id: $0) }) { linked in
                        Button {
                            openPage(linked.id)
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: linked.symbol)
                                Text(linked.title)
                                Image(systemName: "chevron.right")
                                    .font(.caption2.weight(.bold))
                                    .foregroundStyle(.secondary)
                            }
                            .font(.subheadline.weight(.medium))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(.fill.tertiary, in: .capsule)
                            .contentShape(.capsule)
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("uses-\(linked.id)")
                    }
                }
            }
            // Links written as [Form](catalog://form) in callouts open that page.
            .environment(\.openURL, OpenURLAction { url in
                guard url.scheme == "catalog", let id = url.host(), Catalog.page(id: id) != nil else {
                    return .systemAction
                }
                openPage(id)
                return .handled
            })

            VStack(alignment: .leading, spacing: 12) {
                SectionTitle("Code")
                Prose(hasNavigationBar
                      ? "The complete screen, exactly as it runs above. Paste it into a new SwiftUI file and it compiles as is. Show it inside a `NavigationStack`, as the `#Preview` at the bottom does, so its title and toolbar have a bar to live in."
                      : "The complete screen, exactly as it runs above. Paste it into a new SwiftUI file and it compiles as is; then swap the sample data for your own.")
                CodeBlock(code: code)
            }
            .id("code")

            more
        }
        // A sheet starts a fresh navigation context, so pushes, the search
        // field, and the toolbar all behave exactly as in a real app.
        .sheet(isPresented: $showsFullScreen) {
            Group {
                if hasNavigationBar {
                    NavigationStack { screen }
                } else {
                    screen
                }
            }
            .presentationDragIndicator(.visible)
        }
    }
}

private extension BlockShowcase where More == EmptyView {
    init(
        page: ComponentPage,
        tryIt: String,
        code: String,
        components: [ComponentPage.ID],
        hasNavigationBar: Bool = true,
        @ViewBuilder screen: () -> Screen,
        @ViewBuilder notes: () -> Notes
    ) {
        self.init(page: page, tryIt: tryIt, code: code, components: components,
                  hasNavigationBar: hasNavigationBar, screen: screen, notes: notes) {
            EmptyView()
        }
    }
}

/// The block's real screen, scaled down for the overview card.
private struct BlockThumbnail<Screen: View>: View {
    var hasNavigationBar = true
    @ViewBuilder let screen: Screen

    var body: some View {
        PhoneScreen(hasNavigationBar: hasNavigationBar) {
            screen
        }
        .allowsHitTesting(false)
        .scaleEffect(0.44, anchor: .top)
        .frame(width: 314 * 0.44, height: 136, alignment: .top)
        .padding(.top, 14)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}
