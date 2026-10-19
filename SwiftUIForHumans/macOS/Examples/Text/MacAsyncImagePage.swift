import SwiftUI

extension ComponentPage {
    static let asyncImage = ComponentPage(
        id: "async-image",
        title: "AsyncImage",
        summary: "Downloads and shows an image from a URL, with a placeholder while it loads.",
        category: .textAndImages,
        symbol: "photo.badge.arrow.down",
        availability: ["macOS 12.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/asyncimage",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/image-views",
        aliases: ["<img src>", "remote image", "url image", "image from url", "download image", "lazy load", "loading", "fetch image", "SDWebImage", "Kingfisher", "network client", "sandbox"],
        related: ["image-symbols", "app-sandbox", "privacy-permissions", "stacks-grid"],
        notes: [
            "**A sandboxed app needs the network entitlement.** Turn on Outgoing Connections (Client), `com.apple.security.network.client`, under App Sandbox, or every image fails to load.",
            "**In macOS 27 and later, `AsyncImage` caches downloads.** To change the cache policy, pass a `URLRequest` with `AsyncImage(request:)`.",
        ],
        api: [
            APIItem("`AsyncImage(url:)`", "Loads and shows the image at its own size."),
            APIItem("`AsyncImage(url:content:placeholder:)`", "Style the image and pick a placeholder."),
            APIItem("`AsyncImage(url:transaction:content:)`", "Hands you each loading phase."),
            APIItem("`AsyncImagePhase`", "`.empty`, `.success(image)`, or `.failure(error)`."),
            APIItem("`.frame(width:height:)`", "Reserves the space before the image arrives."),
            APIItem("`.id(_:)`", "Change it to start a fresh download."),
        ],
        guidelines: [
            Guideline(
                "Keep text over images readable.",
                "You can't predict what a downloaded photo looks like. Put a scrim or material behind text that sits on it.",
                good: "A scrim keeps the caption readable.",
                bad: "The caption fades into a bright photo."
            ) {
                MacCaptionSample(hasScrim: true)
            } bad: {
                MacCaptionSample(hasScrim: false)
            },
            Guideline(
                "Make a clickable image a button.",
                "On the Mac, show an image people click inside a `Button`, rather than as a plain image with a gesture."
            ),
            Guideline(
                "Use a symbol for an icon.",
                "SF Symbols are vector images you can tint with the accent color, so they suit interface icons better than downloaded pictures."
            ),
        ]
    ) {
        AsyncImage(url: URL(string: "https://picsum.photos/seed/catalog/600/400")) { image in
            image
                .resizable()
                .scaledToFill()
        } placeholder: {
            ZStack {
                Rectangle().fill(.fill.tertiary)
                ProgressView()
            }
        }
        .frame(width: 200, height: 120)
        .clipShape(.rect(cornerRadius: 12))
    } content: { page in
        MacAsyncImageDemo(page: page)
    }
}

private let workingURL = "https://picsum.photos/seed/catalog/600/400"
private let brokenURL = "https://picsum.photos/this-image-does-not-exist.jpg"

private struct MacAsyncImageConfig {
    var source: MacAsyncSourceOption = .working
    var variant: MacAsyncVariantOption = .phases
    var contentMode: MacAsyncContentModeOption = .fill
    var fadeIn = true
    var cornerRadius = 12.0
    var seed = 0
}

private struct MacAsyncImageDemo: View {
    let page: ComponentPage

    var body: some View {
        DemoPage(
            page: page,
            initial: MacAsyncImageConfig(),
            previewHeight: 280,
            usage: """
            let url = URL(string: "https://example.com/photo.jpg")

            AsyncImage(url: url) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                ProgressView()
            }
            .frame(width: 200, height: 200)
            .clipShape(.rect(cornerRadius: 12))
            """,
            usageNote: Aside(.important, "`.resizable()` and `.scaledToFill()` belong to `Image`, so they go on the `image` inside the closure, not on `AsyncImage`.")
        ) { $config in
            VStack(spacing: 14) {
                preview(config)
                    .frame(width: 280, height: 180)
                    .clipShape(.rect(cornerRadius: config.cornerRadius))
                    .id("\(urlString(config))-\(config.variant)-\(config.fadeIn)")

                Button("Load Another", systemImage: "arrow.clockwise") {
                    config.seed += 1
                }
                .disabled(config.source == .broken)
            }
        } controls: { $config in
            Section("Source") {
                OptionPicker("URL", selection: $config.source)
                OptionPicker("Version", selection: $config.variant)
            }
            Section("Appearance") {
                if config.variant != .simple {
                    OptionPicker("Content mode", selection: $config.contentMode)
                }
                if config.variant == .phases {
                    Toggle("Fade in", isOn: $config.fadeIn)
                }
                ValueSlider("Corner radius", value: $config.cornerRadius, in: 0...40, step: 2)
            }
        } code: { config in
            code(config)
        } examples: {
            MacAsyncImageExamples()
        }
    }

    private func urlString(_ config: MacAsyncImageConfig) -> String {
        switch config.source {
        case .working:
            config.seed == 0 ? workingURL : "https://picsum.photos/seed/catalog\(config.seed)/600/400"
        case .broken:
            brokenURL
        }
    }

    @ViewBuilder
    private func preview(_ config: MacAsyncImageConfig) -> some View {
        let url = URL(string: urlString(config))
        switch config.variant {
        case .simple:
            AsyncImage(url: url, scale: 2)
        case .placeholder:
            AsyncImage(url: url) { image in
                fitted(image, config.contentMode)
            } placeholder: {
                ProgressView()
            }
        case .phases:
            AsyncImage(url: url, transaction: Transaction(animation: config.fadeIn ? .easeInOut(duration: 0.4) : nil)) { phase in
                switch phase {
                case .success(let image):
                    fitted(image, config.contentMode)
                        .transition(.opacity)
                case .failure:
                    ContentUnavailableView("Couldn't Load Image", systemImage: "photo.badge.exclamationmark")
                        .background(.fill.tertiary)
                default:
                    ZStack {
                        Rectangle().fill(.fill.tertiary)
                        ProgressView()
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func fitted(_ image: Image, _ mode: MacAsyncContentModeOption) -> some View {
        switch mode {
        case .fit: image.resizable().scaledToFit()
        case .fill: image.resizable().scaledToFill()
        }
    }

    private func code(_ config: MacAsyncImageConfig) -> String {
        let url = "URL(string: \(swiftString(urlString(config))))"
        let fit = config.contentMode == .fit ? "scaledToFit" : "scaledToFill"
        var lines: [String] = []
        switch config.variant {
        case .simple:
            lines.append("AsyncImage(url: \(url), scale: 2)")
        case .placeholder:
            lines += [
                "AsyncImage(url: \(url)) { image in",
                "    image",
                "        .resizable()",
                "        .\(fit)()",
                "} placeholder: {",
                "    ProgressView()",
                "}",
            ]
        case .phases:
            let transaction = config.fadeIn ? ", transaction: Transaction(animation: .easeInOut)" : ""
            lines += [
                "AsyncImage(url: \(url)\(transaction)) { phase in",
                "    switch phase {",
                "    case .success(let image):",
                "        image",
                "            .resizable()",
                "            .\(fit)()",
                "    case .failure:",
                "        ContentUnavailableView(\"Couldn't Load Image\",",
                "                               systemImage: \"photo.badge.exclamationmark\")",
                "    default:",
                "        ProgressView()",
                "    }",
                "}",
            ]
        }
        lines.append(".frame(width: 280, height: 180)")
        if config.cornerRadius > 0 {
            lines.append(".clipShape(.rect(cornerRadius: \(swiftNumber(config.cornerRadius))))")
        }
        return lines.joined(separator: "\n")
    }
}

// MARK: - Examples

private struct MacAsyncImageExamples: View {
    var body: some View {
        ExampleCard(
            title: "Avatar in a row",
            caption: "Give `AsyncImage` a fixed `.frame` and a person symbol as the placeholder, then clip it to a circle.",
            code: """
            HStack(spacing: 10) {
                AsyncImage(url: URL(string: "https://picsum.photos/seed/avatar/200")) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Image(systemName: "person.fill")
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(.fill.tertiary)
                }
                .frame(width: 40, height: 40)
                .clipShape(.circle)
                VStack(alignment: .leading) {
                    Text("Jordan Lee")
                        .font(.headline)
                    Text("Photographer")
                        .foregroundStyle(.secondary)
                }
            }
            """,
            minHeight: 110
        ) {
            HStack(spacing: 10) {
                AsyncImage(url: URL(string: "https://picsum.photos/seed/avatar/200")) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Image(systemName: "person.fill")
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(.fill.tertiary)
                }
                .frame(width: 40, height: 40)
                .clipShape(.circle)
                VStack(alignment: .leading) {
                    Text("Jordan Lee")
                        .font(.headline)
                    Text("Photographer")
                        .foregroundStyle(.secondary)
                }
            }
        }

        ExampleCard(
            title: "Photo grid",
            caption: "Make square cells in a `LazyVGrid` with `Color.clear` and `.aspectRatio(1)`, then fill each with an image.",
            code: """
            let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 4)

            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(1...8, id: \\.self) { index in
                    Color.clear
                        .aspectRatio(1, contentMode: .fit)
                        .overlay {
                            AsyncImage(url: URL(string: "https://picsum.photos/seed/grid\\(index)/300")) { image in
                                image.resizable().scaledToFill()
                            } placeholder: {
                                Rectangle().fill(.fill.tertiary)
                            }
                        }
                        .clipped()
                }
            }
            .clipShape(.rect(cornerRadius: 10))
            .frame(maxWidth: 420)
            """
        ) {
            MacPhotoGridSample()
        }

        ExampleCard(
            title: "Failure with retry",
            caption: "Switch on the `phase`. For `.failure`, say what happened and offer Try Again, which changes `.id` to start over.",
            code: """
            @State private var attempt = 0

            AsyncImage(url: URL(string: "https://picsum.photos/seed/retry/600/400")) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().scaledToFill()
                case .failure:
                    VStack(spacing: 8) {
                        Label("Couldn't load image", systemImage: "wifi.exclamationmark")
                        Button("Try Again") { attempt += 1 }
                    }
                default:
                    ProgressView()
                }
            }
            .id(attempt)
            .frame(width: 280, height: 160)
            .background(.fill.tertiary)
            .clipShape(.rect(cornerRadius: 12))
            """,
            minHeight: 200,
            aside: Aside(.note, "This preview fails on purpose the first time. Click Try Again to load a real photo.")
        ) {
            MacRetrySample()
        }
    }
}

private struct MacPhotoGridSample: View {
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 4)

    var body: some View {
        LazyVGrid(columns: columns, spacing: 4) {
            ForEach(1...8, id: \.self) { index in
                Color.clear
                    .aspectRatio(1, contentMode: .fit)
                    .overlay {
                        AsyncImage(url: URL(string: "https://picsum.photos/seed/grid\(index)/300")) { image in
                            image.resizable().scaledToFill()
                        } placeholder: {
                            Rectangle().fill(.fill.tertiary)
                        }
                    }
                    .clipped()
            }
        }
        .clipShape(.rect(cornerRadius: 10))
        .frame(maxWidth: 420)
    }
}

private struct MacRetrySample: View {
    @State private var attempt = 0

    /// Fails on the first try so the failure state is visible, then loads.
    private var url: URL? {
        URL(string: attempt == 0 ? brokenURL : "https://picsum.photos/seed/retry\(attempt)/600/400")
    }

    var body: some View {
        AsyncImage(url: url, transaction: Transaction(animation: .easeInOut)) { phase in
            switch phase {
            case .success(let image):
                image.resizable().scaledToFill()
            case .failure:
                VStack(spacing: 8) {
                    Label("Couldn't load image", systemImage: "wifi.exclamationmark")
                        .foregroundStyle(.secondary)
                    Button("Try Again") { attempt += 1 }
                }
            default:
                ProgressView()
            }
        }
        .id(attempt)
        .frame(width: 280, height: 160)
        .background(.fill.tertiary)
        .clipShape(.rect(cornerRadius: 12))
    }
}

/// A caption on a bright photo, with or without a scrim behind it.
private struct MacCaptionSample: View {
    let hasScrim: Bool

    var body: some View {
        SceneryView(.meadow)
            .frame(width: 220, height: 120)
            .overlay(alignment: .bottomLeading) {
                Text("Summer in the hills")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding(10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background {
                        if hasScrim {
                            LinearGradient(colors: [.clear, .black.opacity(0.6)], startPoint: .top, endPoint: .bottom)
                        }
                    }
            }
            .clipShape(.rect(cornerRadius: 10))
    }
}

// MARK: - Options

private enum MacAsyncSourceOption: DemoOption {
    case working, broken

    var label: String {
        switch self {
        case .working: "Working"
        case .broken: "Broken"
        }
    }
}

private enum MacAsyncVariantOption: DemoOption {
    case simple, placeholder, phases

    var label: String {
        switch self {
        case .simple: "url:"
        case .placeholder: "Placeholder"
        case .phases: "Phases"
        }
    }
}

private enum MacAsyncContentModeOption: DemoOption {
    case fill, fit

    var label: String {
        switch self {
        case .fill: "Fill"
        case .fit: "Fit"
        }
    }
}
