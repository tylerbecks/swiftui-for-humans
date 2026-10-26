---
id: link
title: Link
platforms: [iOS, iPadOS, macOS]
availability: iOS 14.0+, macOS 11.0+, visionOS 1.0+
docs: https://developer.apple.com/documentation/swiftui/link.md
---

# Link

A control that opens a URL, in Safari or in the app that handles it.

Also called: <a>, href, anchor, hyperlink, url, open url, window.open, openURL, deep link, mailto.

## Contents

- Default code
- Pitfalls
- Key APIs
- Variants
- On macOS
- Related

## Default code

```swift
Link("Terms of Service",
     destination: URL(string: "https://www.apple.com/legal/")!)

// Or inline, with Markdown
Text("Read our [Privacy Policy](https://www.apple.com/privacy/).")
```

**Important:** Markdown links only work in string literals. A `String` variable shows the brackets as typed; use `Text(LocalizedStringKey(string))` instead.

## Pitfalls

- **Web links leave your app.** They open in Safari. Other schemes open their own app: `mailto:` opens Mail, `tel:` the phone, and universal links the matching app.
- **A `Link` is a button.** `.buttonStyle(_:)`, `.tint(_:)`, and `.font(_:)` work on it like on any [Button](button.md).

## Key APIs

- `Link(_:destination:)`: A text link that opens a URL.
- `Link(destination:label:)`: Use any view, like a `Label`, as the link.
- `Text("[title](url)")`: Markdown links inside text.
- `@Environment(\.openURL)`: Opens a URL from your own code.
- `prefersInApp:`: Opens a web page in a Safari sheet inside your app (iOS 26).
- `OpenURLAction`: Intercepts every link tap below it.

## Variants

### Links inside text

Write Markdown links in a `Text` literal for inline links, and color them with `.tint(_:)`.

```swift
Text("By continuing you agree to our [Terms](https://www.apple.com/legal/) and [Privacy Policy](https://www.apple.com/privacy/).")
    .font(.footnote)
    .multilineTextAlignment(.center)
    .tint(.purple)
```

### Open a URL from code

Read `openURL` from the environment to open a link from any action, like a button or list row.

```swift
@Environment(\.openURL) private var openURL

Button("Visit swift.org", systemImage: "safari") {
    if let url = URL(string: "https://www.swift.org") {
        openURL(url)
    }
}
.buttonStyle(.bordered)
```

**Note:** On iOS 26, call `openURL(url, prefersInApp: true)` to show a web page in a Safari sheet without leaving your app.

### Intercept links

Set an `OpenURLAction` in the environment to handle every link tap below it yourself.

```swift
@State private var lastTapped = "Nothing yet"

VStack {
    Text("Open [Settings](myapp://settings) or [Help](myapp://help)")
    Text("Tapped: \(lastTapped)")
        .foregroundStyle(.secondary)
}
.environment(\.openURL, OpenURLAction { url in
    lastTapped = url.host() ?? url.absoluteString
    return .handled
})
```

**Note:** Return `.handled` to stay in the app, or `.systemAction` to open the link normally. Try it: nothing here leaves the app.

### Email and phone

Use `mailto:` and `tel:` URLs to start an email in Mail or a call in Phone.

```swift
HStack {
    Link(destination: URL(string: "mailto:hello@example.com")!) {
        Label("Email", systemImage: "envelope")
    }
    Link(destination: URL(string: "tel:+15555550123")!) {
        Label("Call", systemImage: "phone")
    }
}
.buttonStyle(.bordered)
```

**Note:** The Simulator has no Mail or Phone app, so test these on a device.

## On macOS

Text that opens a web page in the person's default browser when clicked.

### Default code

```swift
Link("Privacy Policy", destination: URL(string: "https://www.apple.com/privacy/")!)
```

**Note:** Like an `<a href>`, but the page opens in the default browser, outside your app. Use a [Button](button.md) for actions that stay inside.

### Pitfalls

- **Universal Links open their app.** For a link that belongs to an installed app, the system opens it there; everything else goes to the default browser.
- **Markdown links in `Text` work too.** A string literal like `"See [our site](https://…)"` becomes a clickable link, and it goes through the same `openURL` action.

### Key APIs

- `OpenURLAction { url in … }`: Handles links yourself.
- `.environment(\.openURL, …)`: Installs your action for the views inside.

### Variants

#### A link inside a sentence

Write the link in Markdown inside a `Text` to link a few words in the middle of a sentence.

```swift
Text("By continuing, you agree to the [Privacy Policy](https://www.apple.com/privacy/).")
```

#### A link with a symbol

`Link(destination:label:)` takes any view as its label, such as a `Label` with an SF Symbol.

```swift
Link(destination: URL(string: "https://developer.apple.com/swift/")!) {
    Label("Learn Swift", systemImage: "swift")
}
```

#### Open a URL from code

Read `openURL` from the environment when a button needs to do something first, then open the page.

```swift
@Environment(\.openURL) private var openURL

Button("Open Website", systemImage: "safari") {
    logVisit()
    openURL(URL(string: "https://www.apple.com/")!)
}
```

#### Handle links yourself

Set your own `OpenURLAction` to catch links before the browser does, for example to open a help topic inside the app.

```swift
Text("Stuck? Read [Getting Started](help:getting-started) or [Shortcuts](help:shortcuts).")
    .environment(\.openURL, OpenURLAction { url in
        guard url.scheme == "help" else { return .systemAction }
        showHelpTopic(url.absoluteString)
        return .handled
    })
```

**Note:** Return `.systemAction` for links you don't handle, so they still open normally.

## Related

[button](button.md), [share-link](share-link.md), [text](text.md), [text-label](text-label.md), [copy-paste](copy-paste.md)
