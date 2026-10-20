import SwiftUI

extension ComponentPage {
    static let link = ComponentPage(
        id: "link",
        title: "Link",
        summary: "Text that opens a web page in the person's default browser when clicked.",
        category: .controls,
        symbol: "link",
        availability: ["macOS 11.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/link",
        aliases: ["hyperlink", "<a href>", "anchor", "url", "open url", "openURL", "OpenURLAction", "NSWorkspace open", "web page", "markdown link", "browser"],
        related: ["button", "text-label", "share-link", "copy-paste"],
        notes: [
            "**Universal Links open their app.** For a link that belongs to an installed app, the system opens it there; everything else goes to the default browser.",
            "**Markdown links in `Text` work too.** A string literal like `\"See [our site](https://…)\"` becomes a clickable link, and it goes through the same `openURL` action.",
        ],
        api: [
            APIItem("`Link(_:destination:)`", "A text link to a URL."),
            APIItem("`Link(destination:label:)`", "Any view as the link's label."),
            APIItem("`Text(\"[title](url)\")`", "A link inside a sentence, from Markdown."),
            APIItem("`@Environment(\\.openURL)`", "Opens a URL from your own code."),
            APIItem("`OpenURLAction { url in … }`", "Handles links yourself."),
            APIItem("`.environment(\\.openURL, …)`", "Installs your action for the views inside."),
        ]
    ) {
        VStack(spacing: 10) {
            Link("Privacy Policy", destination: URL(string: "https://www.apple.com/privacy/")!)
            Link(destination: URL(string: "https://www.apple.com/")!) {
                Label("Visit Website", systemImage: "safari")
            }
        }
    } content: { page in
        MacLinkDemo(page: page)
    }
}

private let macLinkURL = URL(string: "https://www.apple.com/privacy/")!

private struct MacLinkConfig {
    var title = "Privacy Policy"
    var showsIcon = false
    var handlesInApp = false
    var isDisabled = false
}

private struct MacLinkDemo: View {
    let page: ComponentPage
    @State private var handled = ""

    var body: some View {
        DemoPage(
            page: page,
            initial: MacLinkConfig(),
            usage: """
            Link("Privacy Policy", destination: URL(string: "https://www.apple.com/privacy/")!)
            """,
            usageNote: Aside(.note, "Like an `<a href>`, but the page opens in the default browser, outside your app. Use a [Button](catalog://button) for actions that stay inside.")
        ) { $config in
            VStack(spacing: 16) {
                Group {
                    if config.showsIcon {
                        Link(destination: macLinkURL) {
                            Label(config.title, systemImage: "hand.raised")
                        }
                    } else {
                        Link(config.title, destination: macLinkURL)
                    }
                }
                .disabled(config.isDisabled)
                .environment(\.openURL, OpenURLAction { url in
                    guard config.handlesInApp else { return .systemAction }
                    handled = "Handled in the app: \(url.absoluteString)"
                    return .handled
                })
                Text(config.handlesInApp ? (handled.isEmpty ? "Click the link; it stays in the app." : handled) : "Opens in your default browser")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        } controls: { $config in
            Section("Content") {
                TextField("Title", text: $config.title)
                Toggle("Show icon", isOn: $config.showsIcon)
            }
            Section("Behavior") {
                Toggle("Handle in the app", isOn: $config.handlesInApp)
                Toggle("Disabled", isOn: $config.isDisabled)
            }
        } code: { config in
            let url = "URL(string: \"https://www.apple.com/privacy/\")!"
            var lines: [String] = []
            if config.showsIcon {
                lines += [
                    "Link(destination: \(url)) {",
                    "    Label(\(swiftString(config.title)), systemImage: \"hand.raised\")",
                    "}",
                ]
            } else {
                lines.append("Link(\(swiftString(config.title)), destination: \(url))")
            }
            if config.isDisabled {
                lines.append(".disabled(true)")
            }
            if config.handlesInApp {
                lines += [
                    ".environment(\\.openURL, OpenURLAction { url in",
                    "    showInApp(url)",
                    "    return .handled",
                    "})",
                ]
            }
            return lines.joined(separator: "\n")
        } examples: {
            MacLinkExamples()
        }
    }
}

// MARK: - Examples

private struct MacLinkExamples: View {
    @Environment(\.openURL) private var openURL
    @State private var lastHelpTopic = ""

    var body: some View {
        ExampleCard(
            title: "A link inside a sentence",
            caption: "Write the link in Markdown inside a `Text` to link a few words in the middle of a sentence.",
            code: """
            Text("By continuing, you agree to the [Privacy Policy](https://www.apple.com/privacy/).")
            """,
            minHeight: 120
        ) {
            Text("By continuing, you agree to the [Privacy Policy](https://www.apple.com/privacy/).")
                .multilineTextAlignment(.center)
        }

        ExampleCard(
            title: "A link with a symbol",
            caption: "`Link(destination:label:)` takes any view as its label, such as a `Label` with an SF Symbol.",
            code: """
            Link(destination: URL(string: "https://developer.apple.com/swift/")!) {
                Label("Learn Swift", systemImage: "swift")
            }
            """,
            minHeight: 120
        ) {
            Link(destination: URL(string: "https://developer.apple.com/swift/")!) {
                Label("Learn Swift", systemImage: "swift")
            }
        }

        ExampleCard(
            title: "Open a URL from code",
            caption: "Read `openURL` from the environment when a button needs to do something first, then open the page.",
            code: """
            @Environment(\\.openURL) private var openURL

            Button("Open Website", systemImage: "safari") {
                logVisit()
                openURL(URL(string: "https://www.apple.com/")!)
            }
            """,
            minHeight: 120
        ) {
            Button("Open Website", systemImage: "safari") {
                openURL(URL(string: "https://www.apple.com/")!)
            }
        }

        ExampleCard(
            title: "Handle links yourself",
            caption: "Set your own `OpenURLAction` to catch links before the browser does, for example to open a help topic inside the app.",
            code: """
            Text("Stuck? Read [Getting Started](help:getting-started) or [Shortcuts](help:shortcuts).")
                .environment(\\.openURL, OpenURLAction { url in
                    guard url.scheme == "help" else { return .systemAction }
                    showHelpTopic(url.absoluteString)
                    return .handled
                })
            """,
            minHeight: 140,
            aside: Aside(.note, "Return `.systemAction` for links you don't handle, so they still open normally.")
        ) {
            VStack(spacing: 10) {
                Text("Stuck? Read [Getting Started](help:getting-started) or [Shortcuts](help:shortcuts).")
                    .environment(\.openURL, OpenURLAction { url in
                        guard url.scheme == "help" else { return .systemAction }
                        lastHelpTopic = url.absoluteString
                        return .handled
                    })
                Text(lastHelpTopic.isEmpty ? "Click a link" : "Showing \(lastHelpTopic)")
                    .font(.footnote.monospaced())
                    .foregroundStyle(.secondary)
            }
        }
    }
}
