import SwiftUI

extension ComponentPage {
    static let asyncImage = ComponentPage(
        id: "async-image",
        title: "AsyncImage",
        summary: "Downloads and shows an image from a URL, with a placeholder while it loads.",
        category: .textAndImages,
        symbol: "photo.badge.arrow.down",
        availability: ["iOS 15.0+", "macOS 12.0+", "visionOS 1.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/asyncimage",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/image-views",
        aliases: ["<img src>", "remote image", "url image", "image from url", "lazy load", "loading", "fetch image", "SDWebImage", "Kingfisher", "next/image"],
        related: ["image", "progress-view", "lazy-grids", "list"],
        notes: [
            "**Use the `phase` version to handle errors.** It hands you `.empty` while loading, `.success(image)`, and `.failure(error)`, so you can show a real error state.",
            "**Fade images in instead of popping.** Pass `transaction: Transaction(animation: .easeInOut)` and the image animates in when it arrives.",
        ],
        api: [
            APIItem("`AsyncImage(url:)`", "Loads and shows the image at its own size."),
            APIItem("`AsyncImage(url:content:placeholder:)`", "Lets you style the image and choose a placeholder."),
            APIItem("`AsyncImage(url:transaction:content:)`", "Gives you each loading phase, with an optional animation."),
            APIItem("`AsyncImagePhase`", "`.empty`, `.success(image)`, or `.failure(error)`."),
            APIItem("`.frame(width:height:)`", "Reserves the image's space before it loads."),
            APIItem("`.id(_:)`", "Change it to throw away the view and download again."),
        ],
        guidelines: [
            Guideline(
                "Reserve the image's space before it loads.",
                "A placeholder at the final size keeps text from jumping when the photo arrives, so people don't lose their place.",
                good: "The placeholder is the size of the photo.",
                bad: "A small spinner, so the text will jump."
            ) {
                AsyncLoadingSample(reservesSpace: true)
            } bad: {
                AsyncLoadingSample(reservesSpace: false)
            },
            Guideline(
                "Show a clear failure state.",
                "An empty box looks like the app is still loading. Say the image couldn't load, and offer a way to try again.",
                good: "Says what happened and offers a retry.",
                bad: "An empty box with no explanation."
            ) {
                AsyncFailureSample(explains: true)
            } bad: {
                AsyncFailureSample(explains: false)
            },
            Guideline(
                "Keep text over remote images readable.",
                "You don't know what the photo will look like. Put a gradient or material behind any text on top of it."
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
        .clipShape(.rect(cornerRadius: 14))
    } content: { page in
        AsyncImageDemo(page: page)
    }
}

private let workingURL = "https://picsum.photos/seed/catalog/600/400"
private let brokenURL = "https://picsum.photos/this-image-does-not-exist.jpg"

private struct AsyncImageConfig {
    var source: AsyncSourceOption = .working
    var variant: AsyncVariantOption = .phases
    var contentMode: AsyncContentModeOption = .fill
    var fadeIn = true
    var cornerRadius = 16.0
    var seed = 0
}

private struct AsyncImageDemo: View {
    let page: ComponentPage

    var body: some View {
        DemoPage(
            page: page,
            initial: AsyncImageConfig(),
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
                .buttonStyle(.bordered)
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
                ValueSlider("Corner radius", value: $config.cornerRadius, in: 0...60, step: 2)
            }
        } code: { config in
            code(config)
        } examples: {
            ExampleCard(
                title: "Avatar",
                caption: "Give `AsyncImage` a fixed `.frame` and a person symbol as the placeholder, then clip it to a circle.",
                code: """
                AsyncImage(url: URL(string: "https://picsum.photos/seed/avatar/200")) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Image(systemName: "person.fill")
                        .font(.title)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(.fill.tertiary)
                }
                .frame(width: 72, height: 72)
                .clipShape(.circle)
                """,
                minHeight: 140
            ) {
                HStack(spacing: 14) {
                    AsyncImage(url: URL(string: "https://picsum.photos/seed/avatar/200")) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        Image(systemName: "person.fill")
                            .font(.title)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(.fill.tertiary)
                    }
                    .frame(width: 72, height: 72)
                    .clipShape(.circle)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Jordan Lee")
                            .font(.headline)
                        Text("Photographer")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            ExampleCard(
                title: "Photo grid",
                caption: "Make square cells in a `LazyVGrid` with `Color.clear` and `.aspectRatio(1)`, then fill each with an image.",
                code: """
                let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 3)

                LazyVGrid(columns: columns, spacing: 4) {
                    ForEach(1...6, id: \\.self) { index in
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
                .clipShape(.rect(cornerRadius: 12))
                """,
                aside: Aside(.important, "`AsyncImage` doesn't cache images itself. Cells that scroll away and back may download again, so large grids often use a caching library.")
            ) {
                PhotoGridExample()
            }
            ExampleCard(
                title: "Failure with retry",
                caption: "Switch on the `phase` and show a message and a Try Again button for `.failure`.",
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
                .clipShape(.rect(cornerRadius: 16))
                """,
                minHeight: 200,
                aside: Aside(.note, "Changing `.id(attempt)` makes SwiftUI replace the view, which starts a fresh download. This demo fails on purpose the first time.")
            ) {
                RetryExample()
            }
        }
    }

    private func urlString(_ config: AsyncImageConfig) -> String {
        switch config.source {
        case .working:
            config.seed == 0 ? workingURL : "https://picsum.photos/seed/catalog\(config.seed)/600/400"
        case .broken:
            brokenURL
        }
    }

    @ViewBuilder
    private func preview(_ config: AsyncImageConfig) -> some View {
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
    private func fitted(_ image: Image, _ mode: AsyncContentModeOption) -> some View {
        switch mode {
        case .fit: image.resizable().scaledToFit()
        case .fill: image.resizable().scaledToFill()
        }
    }

    private func code(_ config: AsyncImageConfig) -> String {
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

private struct PhotoGridExample: View {
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 3)

    var body: some View {
        LazyVGrid(columns: columns, spacing: 4) {
            ForEach(1...6, id: \.self) { index in
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
        .clipShape(.rect(cornerRadius: 12))
        .frame(maxWidth: 340)
    }
}

private struct RetryExample: View {
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
                        .buttonStyle(.bordered)
                }
            default:
                ProgressView()
            }
        }
        .id(attempt)
        .frame(width: 280, height: 160)
        .background(.fill.tertiary)
        .clipShape(.rect(cornerRadius: 16))
    }
}

// MARK: - Guideline samples

/// A loading card whose placeholder does or doesn't match the photo's size.
private struct AsyncLoadingSample: View {
    let reservesSpace: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if reservesSpace {
                ZStack {
                    RoundedRectangle(cornerRadius: 10).fill(.fill.tertiary)
                    ProgressView()
                }
                .frame(width: 200, height: 100)
            } else {
                ProgressView()
                    .frame(width: 200, height: 24, alignment: .leading)
            }
            Text("Lisbon, Portugal")
                .font(.headline)
            Text("3 nights · From $420")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(width: 200, height: 170, alignment: .top)
    }
}

/// A failed image, with or without a message and a retry.
private struct AsyncFailureSample: View {
    let explains: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10).fill(.fill.tertiary)
            if explains {
                VStack(spacing: 6) {
                    Label("Couldn't load image", systemImage: "wifi.exclamationmark")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    Button("Try Again") {}
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                }
            }
        }
        .frame(width: 200, height: 110)
    }
}

// MARK: - Options

private enum AsyncSourceOption: DemoOption {
    case working, broken

    var label: String {
        switch self {
        case .working: "Working URL"
        case .broken: "Broken URL"
        }
    }
}

private enum AsyncVariantOption: DemoOption {
    case simple, placeholder, phases

    var label: String {
        switch self {
        case .simple: "url only"
        case .placeholder: "content + placeholder"
        case .phases: "phases"
        }
    }
}

private enum AsyncContentModeOption: DemoOption {
    case fit, fill

    var label: String {
        switch self {
        case .fit: ".scaledToFit()"
        case .fill: ".scaledToFill()"
        }
    }
}
