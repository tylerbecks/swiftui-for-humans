import SwiftUI

extension ComponentPage {
    static let shareLink = ComponentPage(
        id: "share-link",
        title: "ShareLink",
        summary: "A button that opens the share sheet to send a link, text, or image.",
        category: .controls,
        symbol: "square.and.arrow.up",
        availability: ["iOS 16.0+", "macOS 13.0+", "visionOS 1.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/sharelink",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/activity-views",
        aliases: ["share sheet", "share button", "navigator.share", "web share", "UIActivityViewController", "activity view", "export", "send", "AirDrop"],
        related: ["link", "button", "toolbar", "image"],
        notes: [
            "**You can share anything `Transferable`.** `URL`, `String`, `Image`, and `Data` work out of the box; make your own types conform to share them too.",
        ],
        api: [
            APIItem("`ShareLink(item:)`", "A Share button for a `URL` or `String`."),
            APIItem("`ShareLink(item:preview:)`", "Shares any `Transferable` item, like an `Image`."),
            APIItem("`SharePreview(_:image:)`", "The title and thumbnail at the top of the sheet."),
            APIItem("`subject:` / `message:`", "Email subject and extra text, where apps support them."),
            APIItem("`ShareLink(items:)`", "Shares several items at once."),
            APIItem("`label:`", "A custom label instead of the standard Share button."),
        ],
        guidelines: [
            Guideline(
                "Use the standard Share symbol.",
                "People look for `square.and.arrow.up` when they want to send something. A different icon makes them hunt for it.",
                good: "The symbol people already know.",
                bad: "A custom icon hides the action."
            ) {
                ShareLink(item: URL(string: "https://www.swift.org")!)
                    .labelStyle(.iconOnly)
                    .buttonStyle(.bordered)
                    .buttonBorderShape(.circle)
                    .controlSize(.large)
            } bad: {
                ShareLink(item: URL(string: "https://www.swift.org")!) {
                    Label("Share", systemImage: "paperplane")
                        .labelStyle(.iconOnly)
                }
                .buttonStyle(.bordered)
                .buttonBorderShape(.circle)
                .controlSize(.large)
            },
            Guideline(
                "Don't rebuild actions the share sheet already has.",
                "Copy, Print, AirDrop, and Save to Files are built in. Your own versions would sit next to them and confuse people."
            ),
            Guideline(
                "Give shared items a clear preview.",
                "A `SharePreview` with a title and image shows people what they're about to send at the top of the sheet."
            ),
        ]
    ) {
        HStack(spacing: 12) {
            ShareLink(item: URL(string: "https://developer.apple.com")!)
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            ShareLink(item: URL(string: "https://developer.apple.com")!) {
                Image(systemName: "square.and.arrow.up")
                    .padding(6)
            }
            .buttonStyle(.glass)
            .buttonBorderShape(.circle)
        }
    } content: { page in
        ShareLinkDemo(page: page)
    }
}

private struct ShareLinkConfig {
    var item: ShareItemOption = .url
    var label: ShareLabelOption = .standard
    var style: ShareStyleOption = .bordered
    var addsSubject = false
    var addsPreview = false
}

private struct ShareLinkDemo: View {
    let page: ComponentPage

    var body: some View {
        DemoPage(
            page: page,
            initial: ShareLinkConfig(),
            previewHeight: 200,
            usage: """
            let article = URL(string: "https://www.swift.org")!

            ShareLink(item: article)

            ShareLink(item: article) {
                Label("Share Article", systemImage: "square.and.arrow.up")
            }
            """,
            usageNote: Aside(.important, "Only `URL` and `String` items work without a preview. For an `Image` or your own type, also pass a `preview:` made with `SharePreview`.")
        ) { $config in
            VStack(spacing: 16) {
                ConfiguredShareLink(config: config)
                    .styled(config.style)
                    .controlSize(.large)

                Text("Tap to open the share sheet")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        } controls: { $config in
            Section("Content") {
                OptionPicker("Share", selection: $config.item)
                Toggle("Subject and message", isOn: $config.addsSubject)
                Toggle("Custom preview", isOn: $config.addsPreview)
            }
            Section("Appearance") {
                OptionPicker("Label", selection: $config.label)
                OptionPicker("Style", selection: $config.style)
            }
        } code: { config in
            shareCode(config)
        } examples: {
            ShareLinkExamples()
        }
    }
}

private let sampleURL = URL(string: "https://developer.apple.com/swiftui/")!
private let sampleText = "SwiftUI makes building iOS apps fun."

/// ShareLink's initializers differ by item type and options, so build each case.
private struct ConfiguredShareLink: View {
    let config: ShareLinkConfig

    var body: some View {
        let subject = config.addsSubject ? Text("Check this out") : nil
        let message = config.addsSubject ? Text("I thought you'd like this.") : nil
        let preview = SharePreview("SwiftUI", image: Image(systemName: "swift"))
        // Without a preview, only URL and String items have initializers.
        switch (config.item, config.addsPreview, config.label) {
        case (.url, true, .custom):
            ShareLink(item: sampleURL, subject: subject, message: message, preview: preview) { customLabel }
        case (.url, true, _):
            ShareLink(item: sampleURL, subject: subject, message: message, preview: preview)
                .modifier(ShareIconOnly(isOn: config.label == .iconOnly))
        case (.url, false, .custom):
            ShareLink(item: sampleURL, subject: subject, message: message) { customLabel }
        case (.url, false, _):
            ShareLink(item: sampleURL, subject: subject, message: message)
                .modifier(ShareIconOnly(isOn: config.label == .iconOnly))
        case (.text, true, .custom):
            ShareLink(item: sampleText, subject: subject, message: message, preview: preview) { customLabel }
        case (.text, true, _):
            ShareLink(item: sampleText, subject: subject, message: message, preview: preview)
                .modifier(ShareIconOnly(isOn: config.label == .iconOnly))
        case (.text, false, .custom):
            ShareLink(item: sampleText, subject: subject, message: message) { customLabel }
        case (.text, false, _):
            ShareLink(item: sampleText, subject: subject, message: message)
                .modifier(ShareIconOnly(isOn: config.label == .iconOnly))
        }
    }

    private var customLabel: some View {
        Label("Send to a Friend", systemImage: "paperplane")
    }
}

private struct ShareIconOnly: ViewModifier {
    let isOn: Bool

    func body(content: Content) -> some View {
        if isOn { content.labelStyle(.iconOnly) } else { content }
    }
}

private func shareCode(_ config: ShareLinkConfig) -> String {
    var lines: [String] = []
    var args: String
    switch config.item {
    case .url: args = "item: URL(string: \"https://developer.apple.com/swiftui/\")!"
    case .text: args = "item: \(swiftString(sampleText))"
    }
    var extra: [String] = []
    if config.addsSubject {
        extra.append("subject: Text(\"Check this out\")")
        extra.append("message: Text(\"I thought you'd like this.\")")
    }
    if config.addsPreview {
        extra.append("preview: SharePreview(\"SwiftUI\", image: Image(systemName: \"swift\"))")
    }
    let open: String
    if extra.isEmpty {
        open = "ShareLink(\(args))"
    } else {
        open = "ShareLink(\n    \(args),\n" + extra.map { "    " + $0 }.joined(separator: ",\n") + "\n)"
    }
    if config.label == .custom {
        lines.append(open + " {")
        lines.append("    Label(\"Send to a Friend\", systemImage: \"paperplane\")")
        lines.append("}")
    } else {
        lines.append(open)
    }
    if config.label == .iconOnly {
        lines.append(".labelStyle(.iconOnly)")
    }
    if config.style != .automatic {
        lines.append(".buttonStyle(\(config.style.label))")
    }
    lines.append(".controlSize(.large)")
    return lines.map { $0.hasPrefix(".") ? "    " + $0 : $0 }.joined(separator: "\n")
}

// MARK: - Examples

private struct ShareLinkExamples: View {
    private let photo = Image(systemName: "mountain.2.fill")

    var body: some View {
        ExampleCard(
            title: "Share button in a toolbar",
            caption: "Put a `ShareLink` in `.toolbar` on a detail screen, where people look for sharing first.",
            code: """
            NavigationStack {
                Text("Article")
                    .navigationTitle("Article")
                    .toolbar {
                        ShareLink(item: URL(string: "https://www.swift.org")!)
                    }
            }
            """,
            minHeight: 200,
            aside: Aside(.note, "In a toolbar, `ShareLink` shows only its icon. It's the same button people see in Safari and Photos.")
        ) {
            PhoneScreen(width: 280, height: 200) {
                Text("Article")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .navigationTitle("Article")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ShareLink(item: URL(string: "https://www.swift.org")!)
                    }
            }
        }

        ExampleCard(
            title: "Share an image",
            caption: "Pass an `Image` as `item:` with a `SharePreview` that names it and shows a thumbnail in the sheet.",
            code: """
            let photo = Image(systemName: "mountain.2.fill")

            VStack {
                photo
                    .font(.system(size: 60))
                    .foregroundStyle(.teal)
                ShareLink(
                    item: photo,
                    preview: SharePreview("Mountains", image: photo)
                ) {
                    Label("Share Photo", systemImage: "photo")
                }
                .buttonStyle(.bordered)
            }
            """
        ) {
            VStack(spacing: 16) {
                photo
                    .font(.system(size: 60))
                    .foregroundStyle(.teal)
                ShareLink(
                    item: photo,
                    preview: SharePreview("Mountains", image: photo)
                ) {
                    Label("Share Photo", systemImage: "photo")
                }
                .buttonStyle(.bordered)
            }
        }

        ExampleCard(
            title: "Share several items",
            caption: "Pass an array to `items:`, and build a `SharePreview` for each one in the closure.",
            code: """
            let links = [
                URL(string: "https://www.swift.org")!,
                URL(string: "https://developer.apple.com")!,
            ]

            ShareLink(items: links) { url in
                SharePreview(url.host() ?? "Link")
            } label: {
                Label("Share 2 Links", systemImage: "link")
            }
            .buttonStyle(.bordered)
            """
        ) {
            let links = [
                URL(string: "https://www.swift.org")!,
                URL(string: "https://developer.apple.com")!,
            ]
            ShareLink(items: links) { url in
                SharePreview(url.host() ?? "Link")
            } label: {
                Label("Share 2 Links", systemImage: "link")
            }
            .buttonStyle(.bordered)
        }
    }
}

// MARK: - Options

private enum ShareItemOption: DemoOption {
    case url, text

    var label: String {
        switch self {
        case .url: "URL"
        case .text: "Text"
        }
    }
}

private enum ShareLabelOption: DemoOption {
    case standard, iconOnly, custom

    var label: String {
        switch self {
        case .standard: "Standard"
        case .iconOnly: "Icon only"
        case .custom: "Custom"
        }
    }
}

private enum ShareStyleOption: DemoOption {
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
    func styled(_ style: ShareStyleOption) -> some View {
        switch style {
        case .automatic: buttonStyle(.automatic)
        case .bordered: buttonStyle(.bordered)
        case .borderedProminent: buttonStyle(.borderedProminent)
        case .glass: buttonStyle(.glass)
        }
    }
}
