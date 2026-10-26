---
id: sign-in-with-apple
title: Sign in with Apple
platforms: [iOS, iPadOS]
availability: iOS 14.0+, macOS 11.0+, visionOS 1.0+
docs: https://developer.apple.com/documentation/authenticationservices/signinwithapplebutton.md
hig: https://developer.apple.com/design/human-interface-guidelines/sign-in-with-apple.md
reviewed: October 2026
---

# Sign in with Apple

Apple's sign-in button, and when App Review expects you to offer it.

Also called: Guideline 4.8, login services, apple login, login with apple, continue with apple, social login, OAuth, SSO, single sign-on, ASAuthorizationAppleIDButton.

## Contents

- Default code
- Rules
- Pitfalls
- Key APIs
- Variants
- Related

## Default code

```swift
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
```

**Important:** Add the **Sign in with Apple** capability to your target in Xcode's Signing & Capabilities tab. Without it the button still draws, but every request fails.

## Rules

- **Make it as big as your other sign-in buttons.** The HIG asks for a Sign in with Apple button no smaller than the others, visible without scrolling.
- **Pick the style that contrasts with the background.** Use `.black` on light backgrounds and `.white` on dark ones. `.whiteOutline` is for white backgrounds where plain white would vanish.
- **Ask people to sign in only when it's worth it.** Let people look around first, and say what an account gets them. Forcing sign-in on launch makes people leave.
- **Don't ask for a password or a “real” email afterwards.** Not needing a password is the point. If someone chose Hide My Email, respect the relay address instead of asking for their personal one.
- **Keep the button at least 140 × 30 points.** As of 2026, the HIG lists 140 pt wide and 30 pt tall as the minimum, with a margin of a tenth of the button's height around it.

## Pitfalls

- **Show which sign-in people used.** A line like “Using Sign in with Apple” in your account screen helps people remember how they signed up.
- **Revoke tokens when an account is deleted.** Apple's account deletion guidance asks apps that use Sign in with Apple to revoke the user's tokens with the Sign in with Apple REST API. See [Delete Account](delete-account.md).

**Note:** You don't need a second option if your app uses only your own accounts (email and password, passkeys), or if people must sign in with an existing school, work, or government ID, or to the third-party service whose content the app shows, like a mail client.

## Key APIs

- `SignInWithAppleButton`: The system button. Takes a label, a request closure, and a completion closure.
- `.signInWithAppleButtonStyle(_:)`: `.black`, `.white`, or `.whiteOutline`.
- `.signIn`, `.signUp`, `.continue`: The three button titles.
- `requestedScopes`: Ask for `.fullName` and `.email`, or nothing.
- `ASAuthorizationAppleIDCredential`: The result: `user`, `email`, `fullName`, tokens.
- `getCredentialState(forUserID:)`: Checks if the Apple sign-in is still valid.

## Variants

### Next to other sign-in buttons

Give `SignInWithAppleButton` the same frame as your other providers, and put it where nobody has to scroll.

```swift
@Environment(\.colorScheme) private var colorScheme

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
```

**Important:** If Google or Facebook is your only login, App Review rejects the app under Guideline 4.8 until you add an equivalent option.

### Read the credential

On success, the credential is an `ASAuthorizationAppleIDCredential`. Its `user` id is stable, so key your account on it.

```swift
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
```

**Important:** The credential carries the name and email only the first time someone signs in. Store them right away: later sign-ins leave out the name, and the email comes only inside the identity token.

## Related

[login-form](login-form.md), [delete-account](delete-account.md), [button](button.md), [settings-screen](settings-screen.md)
