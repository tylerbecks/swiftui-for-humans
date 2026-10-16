import SwiftUI

extension ComponentPage {
    static let link = ComponentPage(
        id: "link",
        title: "Link",
        summary: "A control that opens a URL, in Safari or in the app that handles it.",
        category: .controls,
        symbol: "link",
        availability: ["iOS 14.0+", "macOS 11.0+", "visionOS 1.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/link",
        higURL: nil,
        aliases: ["<a>", "href", "anchor", "hyperlink", "url", "open url", "window.open", "openURL", "deep link", "mailto"],
        related: ["button", "share-link", "text"],
        notes: [
            "**Web links leave your app.** They open in Safari. Other schemes open their own app: `mailto:` opens Mail, `tel:` the phone, and universal links the matching app.",
            "**A `Link` is a button.** `.buttonStyle(_:)`, `.tint(_:)`, and `.font(_:)` work on it like on any [Button](catalog://button).",
        ],
        api: [
            APIItem("`Link(_:destination:)`", "A text link that opens a URL."),
            APIItem("`Link(destination:label:)`", "Use any view, like a `Label`, as the link."),
            APIItem("`Text(\"[title](url)\")`", "Markdown links inside text."),
            APIItem("`@Environment(\\.openURL)`", "Opens a URL from your own code."),
            APIItem("`prefersInApp:`", "Opens a web page in a Safari sheet inside your app (iOS 26)."),
            APIItem("`OpenURLAction`", "Intercepts every link tap below it."),
        ]
    ) {
        VStack(spacing: 14) {
            Link(destination: URL(string: "https://developer.apple.com")!) {
                Label("Apple Developer", systemImage: "arrow.up.right.square")
            }
            .font(.headline)
            Text("Read our [Privacy Policy](https://www.apple.com/privacy/).")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    } content: { page in
        LinkDemo(page: page)
    }
}

private struct LinkConfig {
    var title = "Apple Developer"
    var destination: LinkDestinationOption = .web
    var showsIcon = true
    var style: LinkStyleOption = .automatic
}

private struct LinkDemo: View {
    let page: ComponentPage

    var body: some View {
        DemoPage(
            page: page,
            initial: LinkConfig(),
            previewHeight: 200,
            usage: """
            Link("Terms of Service",
                 destination: URL(string: "https://www.apple.com/legal/")!)

            // Or inline, with Markdown
            Text("Read our [Privacy Policy](https://www.apple.com/privacy/).")
            """,
            usageNote: Aside(.important, "Markdown links only work in string literals. A `String` variable shows the brackets as typed; use `Text(LocalizedStringKey(string))` instead.")
        ) { $config in
            VStack(spacing: 16) {
                Group {
                    if config.showsIcon {
                        Link(destination: config.destination.url) {
                            Label(config.title, systemImage: config.destination.symbol)
                        }
                    } else {
                        Link(config.title, destination: config.destination.url)
                    }
                }
                .styled(config.style)

                Text(config.destination.hint)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        } controls: { $config in
            Section("Content") {
                TextField("Title", text: $config.title)
                OptionPicker("Destination", selection: $config.destination)
                Toggle("Show icon", isOn: $config.showsIcon)
            }
            Section("Appearance") {
                OptionPicker("Style", selection: $config.style)
            }
        } code: { config in
            var lines: [String] = []
            let url = config.destination.code
            if config.showsIcon {
                lines += [
                    "Link(destination: \(url)) {",
                    "    Label(\(swiftString(config.title)), systemImage: \"\(config.destination.symbol)\")",
                    "}",
                ]
            } else {
                lines.append("Link(\(swiftString(config.title)), destination: \(url))")
            }
            if config.style != .automatic {
                lines.append("    .buttonStyle(\(config.style.label))")
            }
            return lines.joined(separator: "\n")
        } examples: {
            LinkExamples()
        }
    }
}

// MARK: - Examples

private struct LinkExamples: View {
    @State private var lastTapped = "Nothing yet"
    @Environment(\.openURL) private var openURL

    var body: some View {
        ExampleCard(
            title: "Links inside text",
            caption: "Write Markdown links in a `Text` literal for inline links, and color them with `.tint(_:)`.",
            code: """
            Text("By continuing you agree to our [Terms](https://www.apple.com/legal/) and [Privacy Policy](https://www.apple.com/privacy/).")
                .font(.footnote)
                .multilineTextAlignment(.center)
                .tint(.purple)
            """
        ) {
            Text("By continuing you agree to our [Terms](https://www.apple.com/legal/) and [Privacy Policy](https://www.apple.com/privacy/).")
                .font(.footnote)
                .multilineTextAlignment(.center)
                .tint(.purple)
                .frame(maxWidth: 300)
        }

        ExampleCard(
            title: "Open a URL from code",
            caption: "Read `openURL` from the environment to open a link from any action, like a button or list row.",
            code: """
            @Environment(\\.openURL) private var openURL

            Button("Visit swift.org", systemImage: "safari") {
                if let url = URL(string: "https://www.swift.org") {
                    openURL(url)
                }
            }
            .buttonStyle(.bordered)
            """,
            aside: Aside(.note, "On iOS 26, call `openURL(url, prefersInApp: true)` to show a web page in a Safari sheet without leaving your app.")
        ) {
            Button("Visit swift.org", systemImage: "safari") {
                if let url = URL(string: "https://www.swift.org") {
                    openURL(url)
                }
            }
            .buttonStyle(.bordered)
        }

        ExampleCard(
            title: "Intercept links",
            caption: "Set an `OpenURLAction` in the environment to handle every link tap below it yourself.",
            code: """
            @State private var lastTapped = "Nothing yet"

            VStack {
                Text("Open [Settings](myapp://settings) or [Help](myapp://help)")
                Text("Tapped: \\(lastTapped)")
                    .foregroundStyle(.secondary)
            }
            .environment(\\.openURL, OpenURLAction { url in
                lastTapped = url.host() ?? url.absoluteString
                return .handled
            })
            """,
            aside: Aside(.note, "Return `.handled` to stay in the app, or `.systemAction` to open the link normally. Try it: nothing here leaves the app.")
        ) {
            VStack(spacing: 10) {
                Text("Open [Settings](myapp://settings) or [Help](myapp://help)")
                Text("Tapped: \(lastTapped)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .environment(\.openURL, OpenURLAction { url in
                lastTapped = url.host() ?? url.absoluteString
                return .handled
            })
        }

        ExampleCard(
            title: "Email and phone",
            caption: "Use `mailto:` and `tel:` URLs to start an email in Mail or a call in Phone.",
            code: """
            HStack {
                Link(destination: URL(string: "mailto:hello@example.com")!) {
                    Label("Email", systemImage: "envelope")
                }
                Link(destination: URL(string: "tel:+15555550123")!) {
                    Label("Call", systemImage: "phone")
                }
            }
            .buttonStyle(.bordered)
            """,
            aside: Aside(.note, "The Simulator has no Mail or Phone app, so test these on a device.")
        ) {
            HStack {
                Link(destination: URL(string: "mailto:hello@example.com")!) {
                    Label("Email", systemImage: "envelope")
                }
                Link(destination: URL(string: "tel:+15555550123")!) {
                    Label("Call", systemImage: "phone")
                }
            }
            .buttonStyle(.bordered)
        }
    }
}

// MARK: - Options

private enum LinkDestinationOption: DemoOption {
    case web, maps, settings

    var label: String {
        switch self {
        case .web: "Website"
        case .maps: "Maps"
        case .settings: "App settings"
        }
    }

    var url: URL {
        switch self {
        case .web: URL(string: "https://developer.apple.com")!
        case .maps: URL(string: "https://maps.apple.com/?q=Apple+Park")!
        case .settings: URL(string: UIApplication.openSettingsURLString)!
        }
    }

    var code: String {
        switch self {
        case .settings: "URL(string: UIApplication.openSettingsURLString)!"
        default: "URL(string: \"\(url.absoluteString)\")!"
        }
    }

    var symbol: String {
        switch self {
        case .web: "arrow.up.right.square"
        case .maps: "map"
        case .settings: "gear"
        }
    }

    var hint: String {
        switch self {
        case .web: "Opens Safari and leaves this app."
        case .maps: "Apple Maps links open the Maps app."
        case .settings: "Opens this app's page in the Settings app."
        }
    }
}

private enum LinkStyleOption: DemoOption {
    case automatic, bordered, borderedProminent, glass

    var label: String {
        switch self {
        case .automatic: ".automatic"
        case .bordered: ".bordered"
        case .borderedProminent: ".borderedProminent"
        case .glass: ".glass"
        }
    }
}

private extension View {
    @ViewBuilder
    func styled(_ style: LinkStyleOption) -> some View {
        switch style {
        case .automatic: buttonStyle(.automatic)
        case .bordered: buttonStyle(.bordered)
        case .borderedProminent: buttonStyle(.borderedProminent)
        case .glass: buttonStyle(.glass)
        }
    }
}
