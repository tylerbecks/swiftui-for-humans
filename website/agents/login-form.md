---
id: login-form
title: Login Screen
platforms: [iOS, iPadOS]
availability: iOS 26.0+
docs: https://developer.apple.com/documentation/authenticationservices/signinwithapplebutton.md
hig: https://developer.apple.com/design/human-interface-guidelines/sign-in-with-apple.md
---

# Login Screen

An email and password sign-in screen with AutoFill, focus handling, and Sign in with Apple.

## Rules

- **Make Sign in with Apple as big as your other sign-in buttons.** It saves people from typing a password, so it deserves equal weight. A smaller button reads as an afterthought.
- **Let people look around before you ask them to sign in.** A sign-in wall on first launch makes many people quit. Ask when an account unlocks something they want, and say what it is.
- **Use a secure field for the password, and never prefill it.** Hidden characters protect people in public places. An empty field means they authenticate themselves, by typing or with a saved password.

## Pitfalls

- **Set `.textContentType` on both fields.** With `.emailAddress` and `.password`, iOS offers saved passwords and AutoFill, the biggest usability win on a login screen.
- **Add the Sign in with Apple capability to your app target.** Without it, `SignInWithAppleButton` still draws, but every request fails.
- **Put the form in a `ScrollView`.** The keyboard covers half of a small phone, and scrolling keeps every field and button reachable.

**Note:** The fields are a [TextField](text-field.md) and a [SecureField](secure-field.md) that swap when you tap the eye. [@FocusState](focus-state.md) plus `.onSubmit` moves to the password on Return, like `tabindex` on the web.

**Note:** **Sign In** is a [Button](button.md) that stays disabled until the form is valid and shows a [ProgressView](progress-view.md) while it works, so nobody taps twice. Sign in with Apple is the real `SignInWithAppleButton` from AuthenticationServices.

**Note:** **Why iOS 26?** Only the [Liquid Glass](liquid-glass.md) button styles need it. Change `.glassProminent` to `.borderedProminent` and `.glass` to `.bordered`, and the screen runs on iOS 17.

More variants, left out to keep this file short: Code. Apple's docs: https://developer.apple.com/documentation/authenticationservices/signinwithapplebutton.md

## Related

[text-field](text-field.md), [secure-field](secure-field.md), [focus-state](focus-state.md), [button](button.md)
