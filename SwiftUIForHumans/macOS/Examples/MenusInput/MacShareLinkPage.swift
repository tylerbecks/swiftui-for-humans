import SwiftUI

extension ComponentPage {
    static let shareLink = ComponentPage(
        id: "share-link",
        title: "ShareLink & Transferable",
        summary: "A Share button that sends a link, text, or your own data to Mail, Messages, AirDrop, and more.",
        category: .files,
        kind: .component,
        symbol: "square.and.arrow.up",
        availability: ["macOS 13.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/sharelink",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/activity-views",
        aliases: ["share", "share sheet", "share menu", "NSSharingServicePicker", "NSSharingService", "navigator.share", "AirDrop", "SharePreview", "Transferable", "share button", "UIActivityViewController"],
        related: ["drag-drop", "copy-paste", "file-import-export", "toolbar", "context-menu"],
        notes: [
            "**Some services want a file.** Mail, Messages, AirDrop, and Notes may not appear for every data type. If one is missing, add a `FileRepresentation` to your type.",
            "**A preview skips the wait.** For a URL, the system fetches the page's title and icon over the network. A `SharePreview` you supply shows right away.",
        ],
        api: [
            APIItem("`ShareLink(item:)`", "The standard Share button for one item."),
            APIItem("`ShareLink(_:item:)`", "The same, with your own title."),
            APIItem("`ShareLink(item:preview:)`", "Adds a title and image to show."),
            APIItem("`SharePreview(_:image:)`", "The preview's title and picture."),
            APIItem("`ShareLink(items:)`", "Shares several items at once."),
            APIItem("`subject:`, `message:`", "Fill in a subject and message, like for Mail."),
            APIItem("`Transferable`", "Makes your own type shareable."),
        ],
        guidelines: [
            Guideline(
                "Use the standard Share button.",
                "People know its symbol and what it does. `ShareLink` gives you that button, so don't build another way to reach the same services."
            ),
            Guideline(
                "Put Share where Mac users look for it.",
                "On the Mac, people find sharing in a window's toolbar and in the context menu of the item they want to share."
            ),
            Guideline(
                "Share the richest data you have.",
                "List your type's representations from most to least specific. Each service picks the best one it understands."
            ),
        ]
    ) {
        Label("Share", systemImage: "square.and.arrow.up")
            .font(.title3)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(.fill.tertiary, in: .capsule)
    } content: { page in
        MacShareLinkDemo(page: page)
    }
}

private struct MacShareLinkConfig {
    var content: ShareContentOption = .link
    var label: ShareLabelOption = .standard
    var addsPreview = false
}

private let gardenGuideURL = URL(string: "https://developer.apple.com/xcode/swiftui/")!

private struct MacShareLinkDemo: View {
    let page: ComponentPage

    var body: some View {
        DemoPage(
            page: page,
            initial: MacShareLinkConfig(),
            previewHeight: 200,
            usage: """
            ShareLink(item: URL(string: "https://developer.apple.com/xcode/swiftui/")!)
            """,
            usageNote: Aside(.note, "`ShareLink` makes the button and shows the system's sharing services when people click it. You only supply what to share.")
        ) { $config in
            VStack(spacing: 14) {
                DemoShareLink(config: config)
                    .controlSize(.large)
                Text(config.content.summary)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        } controls: { $config in
            Section("Content") {
                OptionPicker("Share", selection: $config.content)
                Toggle("Preview", isOn: $config.addsPreview)
            }
            Section("Label") {
                OptionPicker("Label", selection: $config.label)
            }
        } code: { config in
            var lines: [String] = []
            switch config.content {
            case .link: lines.append("let item = URL(string: \"https://developer.apple.com/xcode/swiftui/\")!")
            case .text: lines.append("let item = \"Plant tulip bulbs before the first frost.\"")
            case .photo: lines.append("let item = Image(\"photo\")")
            }
            lines.append("")
            var arguments = config.label == .title ? "\"Share Tip\", item: item" : "item: item"
            if config.addsPreview {
                let image = config.content == .photo ? "item" : "Image(systemName: \"leaf\")"
                arguments += ", preview: SharePreview(\"Garden Tip\", image: \(image))"
            } else if config.content == .photo {
                arguments += ", preview: SharePreview(\"Photo\", image: item)"
            }
            lines.append("ShareLink(\(arguments))")
            if config.label == .iconOnly {
                lines.append("    .labelStyle(.iconOnly)")
                lines.append("    .help(\"Share this tip\")")
            }
            return lines.joined(separator: "\n")
        } examples: {
            MacShareLinkExamples()
        }
    }
}

/// The demo's share link, built from the options.
private struct DemoShareLink: View {
    let config: MacShareLinkConfig

    var body: some View {
        Group {
            switch config.content {
            case .link:
                styled(link(gardenGuideURL, preview: tipPreview))
            case .text:
                styled(link("Plant tulip bulbs before the first frost.", preview: tipPreview))
            case .photo:
                let photo = Scenery.lake.image
                styled(previewLink(photo, preview: SharePreview(config.addsPreview ? "Garden Tip" : "Photo", image: photo)))
            }
        }
    }

    private var tipPreview: SharePreview<Image, Never>? {
        config.addsPreview ? SharePreview("Garden Tip", image: Image(systemName: "leaf")) : nil
    }

    /// The standard label or a custom title, to match the generated code.
    @ViewBuilder
    private func previewLink<Item: Transferable>(_ item: Item, preview: SharePreview<Image, Never>) -> some View {
        if config.label == .title {
            ShareLink("Share Tip", item: item, preview: preview)
        } else {
            ShareLink(item: item, preview: preview)
        }
    }

    /// Without a preview, `ShareLink` takes a URL or a string.
    @ViewBuilder
    private func link(_ url: URL, preview: SharePreview<Image, Never>?) -> some View {
        if let preview {
            previewLink(url, preview: preview)
        } else if config.label == .title {
            ShareLink("Share Tip", item: url)
        } else {
            ShareLink(item: url)
        }
    }

    @ViewBuilder
    private func link(_ text: String, preview: SharePreview<Image, Never>?) -> some View {
        if let preview {
            previewLink(text, preview: preview)
        } else if config.label == .title {
            ShareLink("Share Tip", item: text)
        } else {
            ShareLink(item: text)
        }
    }

    @ViewBuilder
    private func styled(_ link: some View) -> some View {
        if config.label == .iconOnly {
            link
                .labelStyle(.iconOnly)
                .help("Share this tip")
        } else {
            link
        }
    }
}

// MARK: - Examples

private struct GardenTip: Transferable {
    let title: String
    let body: String

    static var transferRepresentation: some TransferRepresentation {
        ProxyRepresentation { tip in "\(tip.title)\n\n\(tip.body)" }
    }
}

private struct MacShareLinkExamples: View {
    private let tip = GardenTip(title: "Tulips", body: "Plant the bulbs about 15 cm deep, pointy end up, before the ground freezes.")

    var body: some View {
        ExampleCard(
            title: "In the toolbar",
            caption: "Put a `ShareLink` in the toolbar for whatever the window shows. Icon-only is fine there; add a `.help` tooltip.",
            code: """
            .toolbar {
                ShareLink(item: photo, preview: SharePreview("Sunset", image: photo))
                    .help("Share this photo")
            }
            """,
            minHeight: 240,
            aside: Aside(.note, "A real `.toolbar` here would land in this window's own toolbar, so the preview draws one. The Share button is real.")
        ) {
            MacWindowFrame(title: "Sunset", width: 380, height: 210) {
                SceneryView(.lake)
            } toolbar: {
                ShareLink(item: Scenery.lake.image, preview: SharePreview("Sunset", image: Scenery.lake.image))
                    .labelStyle(.iconOnly)
                    .buttonStyle(.borderless)
                    .help("Share this photo")
            }
        }

        ExampleCard(
            title: "In a context menu",
            caption: "A `ShareLink` works as a context menu item too, so people can share the item they Control-click.",
            code: """
            NoteCard(note)
                .contextMenu {
                    Button("Duplicate") { duplicate(note) }
                    ShareLink(item: note.text)
                }
            """,
            minHeight: 150
        ) {
            VStack(spacing: 8) {
                Text("Order more seed potatoes in March.")
                    .padding(12)
                    .frame(width: 260, alignment: .leading)
                    .background(.fill.tertiary, in: .rect(cornerRadius: 10))
                    .contextMenu {
                        Button("Duplicate") {}
                        ShareLink(item: "Order more seed potatoes in March.")
                    }
                Text("Control-click the note.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }

        ExampleCard(
            title: "Share your own type",
            caption: "Make the type `Transferable`. Here a tip shares as plain text, with a title in the preview.",
            code: """
            struct GardenTip: Transferable {
                let title: String
                let body: String

                static var transferRepresentation: some TransferRepresentation {
                    ProxyRepresentation { tip in "\\(tip.title)\\n\\n\\(tip.body)" }
                }
            }

            ShareLink(item: tip, preview: SharePreview(tip.title, image: Image(systemName: "leaf")))
            """,
            minHeight: 140
        ) {
            ShareLink(item: tip, preview: SharePreview(tip.title, image: Image(systemName: "leaf")))
        }
    }
}

// MARK: - Options

private enum ShareContentOption: DemoOption {
    case link, text, photo

    var label: String {
        switch self {
        case .link: "Link"
        case .text: "Text"
        case .photo: "Photo"
        }
    }

    var summary: String {
        switch self {
        case .link: "Shares a URL."
        case .text: "Shares a string."
        case .photo: "Shares an image, with a preview."
        }
    }
}

private enum ShareLabelOption: DemoOption {
    case standard, title, iconOnly

    var label: String {
        switch self {
        case .standard: "Standard"
        case .title: "Custom title"
        case .iconOnly: "Icon only"
        }
    }

    var title: String {
        self == .title ? "Share Tip" : "Share"
    }
}
