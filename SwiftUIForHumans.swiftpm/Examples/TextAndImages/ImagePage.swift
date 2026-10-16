import SwiftUI

extension ComponentPage {
    static let image = ComponentPage(
        id: "image",
        title: "Image",
        summary: "Shows a picture or an SF Symbol, and controls how it fills its frame.",
        category: .textAndImages,
        symbol: "photo",
        availability: ["iOS 13.0+", "macOS 10.15+", "visionOS 1.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/image",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/image-views",
        aliases: ["<img>", "img", "picture", "photo", "UIImageView", "object-fit", "background-size: cover", "contain", "icon", "aspect ratio"],
        related: ["async-image", "sf-symbols", "clip-shape", "frame"],
        notes: [
            "**Fit or fill, like CSS `object-fit`.** `.scaledToFit()` is `contain`: the whole image shows, with gaps. `.scaledToFill()` is `cover`: no gaps, but the edges overflow until you clip them.",
            "**Describe meaningful images for VoiceOver.** Add `.accessibilityLabel`, or use `Image(decorative:)` for images that are only decoration.",
            "**For an image from a URL, use [AsyncImage](catalog://async-image).** `Image` only shows images that are already in your app or in memory.",
        ],
        api: [
            APIItem("`Image(_:)`", "An image from your asset catalog, by name."),
            APIItem("`Image(systemName:)`", "An SF Symbol, sized and colored like text."),
            APIItem("`.resizable()`", "Lets the image stretch to its frame. Must come first."),
            APIItem("`.scaledToFit()`", "Shows the whole image inside the frame."),
            APIItem("`.scaledToFill()`", "Fills the frame, cropping the edges once clipped."),
            APIItem("`.aspectRatio(_:contentMode:)`", "Keeps a set width-to-height ratio."),
            APIItem("`.clipShape(_:)`", "Clips to a shape: `.circle`, `.rect(cornerRadius:)`, and more."),
            APIItem("`.accessibilityLabel(_:)`", "What VoiceOver says for the image."),
        ],
        guidelines: [
            Guideline(
                "Keep text over images readable.",
                "A busy photo can hide white text. Put a dark gradient or a material behind the text so it always contrasts.",
                good: "A dark backing keeps the caption readable.",
                bad: "The caption gets lost in the photo."
            ) {
                ImageCaptionSample(hasScrim: true)
            } bad: {
                ImageCaptionSample(hasScrim: false)
            },
            Guideline(
                "Use SF Symbols for icons.",
                "Symbols scale with Dynamic Type, match the text weight, and take the tint color. Save bitmap images for photos and art."
            ),
            Guideline(
                "Make tappable images buttons.",
                "Put the image in a `Button` label instead of adding `.onTapGesture`. It gets a pressed state and VoiceOver treats it as a button."
            ),
            Guideline(
                "Provide images at @2x and @3x.",
                "iPhone screens have two or three pixels per point. A single small bitmap looks blurry; a PDF or SVG asset scales cleanly."
            ),
        ]
    ) {
        CatalogLandscape.photo
            .resizable()
            .scaledToFill()
            .frame(width: 200, height: 120)
            .clipShape(.rect(cornerRadius: 14))
    } content: { page in
        ImageDemo(page: page)
    }
}

/// A generated landscape so the page works offline. In real code this is an
/// image in the asset catalog, loaded with `Image("landscape")`. It's the
/// lake scene from `Scenery`, drawn in SwiftUI and rendered to a bitmap, so
/// it behaves exactly like a real photo (`resizable`, `scaledToFill`, ...).
@MainActor
private enum CatalogLandscape {
    static var photo: Image { Scenery.lake.image }
}

private struct ImageConfig {
    var source: ImageSourceOption = .photo
    var resizable = true
    var contentMode: ImageContentModeOption = .fill
    var width = 240.0
    var height = 150.0
    var clip: ImageClipOption = .rounded
    var tinted = true
}

private struct ImageDemo: View {
    let page: ComponentPage

    var body: some View {
        DemoPage(
            page: page,
            initial: ImageConfig(),
            previewHeight: 280,
            usage: """
            Image("landscape")
                .resizable()
                .scaledToFill()
                .frame(width: 300, height: 200)
                .clipShape(.rect(cornerRadius: 16))
            """,
            usageNote: Aside(.important, "Without `.resizable()`, an image draws at its own size and ignores the frame. Put it first, right after `Image(...)`.")
        ) { $config in
            VStack(spacing: 14) {
                configuredImage(config)
                    .frame(width: config.width, height: config.height)
                    .imgClip(config.clip)
                    .overlay {
                        Rectangle()
                            .strokeBorder(.secondary, style: StrokeStyle(lineWidth: 1, dash: [4, 3]))
                            .allowsHitTesting(false)
                    }
                    .frame(height: 200)
                    .animation(.snappy, value: config.width)
                    .animation(.snappy, value: config.height)
                Text("Dashed line = the `.frame`")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        } controls: { $config in
            Section("Source") {
                OptionPicker("Image", selection: $config.source)
                if config.source == .symbol {
                    Toggle("Tint color", isOn: $config.tinted)
                }
            }
            Section("Sizing") {
                Toggle(".resizable()", isOn: $config.resizable)
                if config.resizable {
                    OptionPicker("Content mode", selection: $config.contentMode)
                }
                ValueSlider("Width", value: $config.width, in: 80...300, step: 10)
                ValueSlider("Height", value: $config.height, in: 60...200, step: 10)
            }
            Section("Clipping") {
                OptionPicker("Clip", selection: $config.clip)
            }
        } code: { config in
            var lines = [config.source == .photo ? "Image(\"landscape\") // from Assets" : "Image(systemName: \"mountain.2.fill\")"]
            if config.resizable {
                lines.append("    .resizable()")
                if let mode = config.contentMode.code {
                    lines.append("    .\(mode)()")
                }
            }
            if config.source == .symbol, config.tinted {
                lines.append("    .foregroundStyle(.tint)")
            }
            lines.append("    .frame(width: \(swiftNumber(config.width)), height: \(swiftNumber(config.height)))")
            if let clip = config.clip.code {
                lines.append("    \(clip)")
            }
            return lines.joined(separator: "\n")
        } examples: {
            ExampleCard(
                title: "Avatar",
                caption: "Fill a square with `.scaledToFill()`, clip it with `.clipShape(.circle)`, and add a ring overlay.",
                code: """
                Image("profile")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 88, height: 88)
                    .clipShape(.circle)
                    .overlay {
                        Circle().stroke(.background, lineWidth: 3)
                    }
                    .shadow(radius: 4)
                """,
                minHeight: 140
            ) {
                CatalogLandscape.photo
                    .resizable()
                    .scaledToFill()
                    .frame(width: 88, height: 88)
                    .clipShape(.circle)
                    .overlay {
                        Circle().stroke(.background, lineWidth: 3)
                    }
                    .shadow(radius: 4)
            }
            ExampleCard(
                title: "Cover image with a fixed aspect ratio",
                caption: "Size a `Color.clear` box with `.aspectRatio(16 / 9)` and fill its overlay with the image.",
                code: """
                Color.clear
                    .aspectRatio(16 / 9, contentMode: .fit)
                    .overlay {
                        Image("landscape")
                            .resizable()
                            .scaledToFill()
                    }
                    .clipShape(.rect(cornerRadius: 16))
                """,
                aside: Aside(.important, "A filled image is wider than its frame until it's clipped, and it can push the layout around. The overlay keeps the box in charge of the size.")
            ) {
                Color.clear
                    .aspectRatio(16 / 9, contentMode: .fit)
                    .overlay {
                        CatalogLandscape.photo
                            .resizable()
                            .scaledToFill()
                    }
                    .clipShape(.rect(cornerRadius: 16))
                    .frame(maxWidth: 340)
            }
            ExampleCard(
                title: "Sizing SF Symbols",
                caption: "Size an `Image(systemName:)` with `.font`, not `.resizable()`, so it lines up with nearby text.",
                code: """
                HStack(alignment: .firstTextBaseline, spacing: 20) {
                    Image(systemName: "heart.fill").font(.body)
                    Image(systemName: "heart.fill").font(.title)
                    Image(systemName: "heart.fill").font(.largeTitle)
                    Image(systemName: "heart.fill").font(.system(size: 56))
                }
                .foregroundStyle(.pink)
                """,
                minHeight: 140,
                aside: Aside(.note, "Browse every symbol, and its rendering modes, in [SF Symbols](catalog://sf-symbols).")
            ) {
                HStack(alignment: .firstTextBaseline, spacing: 20) {
                    Image(systemName: "heart.fill").font(.body)
                    Image(systemName: "heart.fill").font(.title)
                    Image(systemName: "heart.fill").font(.largeTitle)
                    Image(systemName: "heart.fill").font(.system(size: 56))
                }
                .foregroundStyle(.pink)
            }
            ExampleCard(
                title: "Text over a photo",
                caption: "Add the caption in an `.overlay` with a dark `LinearGradient` behind it, so it stays readable.",
                code: """
                Image("landscape")
                    .resizable()
                    .scaledToFill()
                    .frame(height: 200)
                    .overlay(alignment: .bottomLeading) {
                        Text("Lake Bled at sunset")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(.linearGradient(colors: [.clear, .black.opacity(0.6)], startPoint: .top, endPoint: .bottom))
                    }
                    .clipShape(.rect(cornerRadius: 16))
                """
            ) {
                CatalogLandscape.photo
                    .resizable()
                    .scaledToFill()
                    .frame(height: 200)
                    .overlay(alignment: .bottomLeading) {
                        Text("Lake Bled at sunset")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(.linearGradient(colors: [.clear, .black.opacity(0.6)], startPoint: .top, endPoint: .bottom))
                    }
                    .clipShape(.rect(cornerRadius: 16))
                    .frame(maxWidth: 340)
            }
        }
    }

    @ViewBuilder
    private func configuredImage(_ config: ImageConfig) -> some View {
        let base = config.source == .photo
            ? CatalogLandscape.photo
            : Image(systemName: "mountain.2.fill")
        Group {
            if config.resizable {
                switch config.contentMode {
                case .stretch: base.resizable()
                case .fit: base.resizable().scaledToFit()
                case .fill: base.resizable().scaledToFill()
                }
            } else {
                base
            }
        }
        .foregroundStyle(config.source == .symbol && config.tinted ? AnyShapeStyle(.tint) : AnyShapeStyle(.primary))
    }
}

// MARK: - Guideline samples

/// A photo with a white caption, with or without a gradient behind it.
private struct ImageCaptionSample: View {
    let hasScrim: Bool

    var body: some View {
        CatalogLandscape.photo
            .resizable()
            .scaledToFill()
            .frame(width: 220, height: 120)
            .overlay {
                Text("Sunset hike, 4.2 mi")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(hasScrim ? Color.black.opacity(0.5) : .clear, in: .capsule)
            }
            .clipShape(.rect(cornerRadius: 12))
    }
}

// MARK: - Options

private enum ImageSourceOption: DemoOption {
    case photo, symbol

    var label: String {
        switch self {
        case .photo: "Photo (asset)"
        case .symbol: "SF Symbol"
        }
    }
}

private enum ImageContentModeOption: DemoOption {
    case stretch, fit, fill

    var label: String {
        switch self {
        case .stretch: "Stretch (none)"
        case .fit: ".scaledToFit()"
        case .fill: ".scaledToFill()"
        }
    }

    var code: String? {
        switch self {
        case .stretch: nil
        case .fit: "scaledToFit"
        case .fill: "scaledToFill"
        }
    }
}

private enum ImageClipOption: DemoOption {
    case none, clipped, rounded, circle

    var label: String {
        switch self {
        case .none: "None"
        case .clipped: ".clipped()"
        case .rounded: "Rounded rect"
        case .circle: "Circle"
        }
    }

    var code: String? {
        switch self {
        case .none: nil
        case .clipped: ".clipped()"
        case .rounded: ".clipShape(.rect(cornerRadius: 16))"
        case .circle: ".clipShape(.circle)"
        }
    }
}

private extension View {
    @ViewBuilder
    func imgClip(_ clip: ImageClipOption) -> some View {
        switch clip {
        case .none: self
        case .clipped: clipped()
        case .rounded: clipShape(.rect(cornerRadius: 16))
        case .circle: clipShape(.circle)
        }
    }
}
