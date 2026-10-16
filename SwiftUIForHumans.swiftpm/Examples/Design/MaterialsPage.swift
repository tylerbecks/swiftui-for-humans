import SwiftUI

extension ComponentPage {
    static let materials = ComponentPage(
        id: "materials",
        title: "Materials",
        summary: "Frosted, blurred backgrounds that let the content behind them show through.",
        category: .design,
        symbol: "square.stack.3d.down.forward",
        availability: ["iOS 15.0+", "macOS 12.0+", "visionOS 1.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/material",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/materials",
        aliases: ["blur", "frosted glass", "backdrop-filter", "translucent", "UIVisualEffectView", "UIBlurEffect", "vibrancy", "glassmorphism"],
        related: ["liquid-glass", "background-overlay", "system-colors", "visual-effects"],
        notes: [
            "**A material is a `ShapeStyle`.** Use it anywhere a color goes: `.background(.thinMaterial)`, `.fill`, or `.presentationBackground` on a sheet.",
            "**It's CSS `backdrop-filter: blur()` with extras.** It also adapts to light and dark mode and adds a tint so text stays readable.",
            "**For controls and bars, use [Liquid Glass](catalog://liquid-glass).** Since iOS 26, materials are for backgrounds inside your content.",
        ],
        api: [
            APIItem("`.background(.regularMaterial)`", "Fills a view's background with blur."),
            APIItem("`.background(_:in:)`", "The same, clipped to a shape like `.capsule`."),
            APIItem("`.ultraThinMaterial`", "The most see-through of five thicknesses."),
            APIItem("`.ultraThickMaterial`", "The most solid; best contrast for text."),
            APIItem("`.foregroundStyle(.secondary)`", "Vibrant text that blends with the material."),
            APIItem("`.presentationBackground(_:)`", "A see-through background for a sheet."),
        ],
        guidelines: [
            Guideline(
                "Use vibrant text styles on materials.",
                "`.secondary` and `.tertiary` pick up the colors behind the blur and stay readable. A fixed `.gray` looks flat and muddy.",
                good: "`.secondary` takes on the colors behind it.",
                bad: "Fixed `.gray` looks flat and dull."
            ) {
                MaterialChip(secondary: AnyShapeStyle(.secondary))
            } bad: {
                MaterialChip(secondary: AnyShapeStyle(.gray))
            },
            Guideline(
                "Use thicker materials behind text.",
                "Thin materials keep more of the background visible, which helps people keep their place. Thicker ones give text and fine details more contrast."
            ),
            Guideline(
                "Keep materials in the content layer.",
                "Use them for cards, captions, and overlays. Floating controls and bars get Liquid Glass instead."
            ),
            Guideline(
                "Pick a material for its purpose, not its color.",
                "Its tint changes with the mode and accessibility settings, so don't count on a particular shade."
            ),
        ]
    ) {
        MaterialsThumbnail()
    } content: { page in
        MaterialsDemo(page: page)
    }
}

// MARK: - Options

private enum MaterialOption: DemoOption {
    case ultraThin, thin, regular, thick, ultraThick, bar

    var label: String {
        switch self {
        case .ultraThin: ".ultraThinMaterial"
        case .thin: ".thinMaterial"
        case .regular: ".regularMaterial"
        case .thick: ".thickMaterial"
        case .ultraThick: ".ultraThickMaterial"
        case .bar: ".bar"
        }
    }

    var shortLabel: String {
        switch self {
        case .ultraThin: "Ultra thin"
        case .thin: "Thin"
        case .regular: "Regular"
        case .thick: "Thick"
        case .ultraThick: "Ultra thick"
        case .bar: "Bar"
        }
    }

    var material: Material {
        switch self {
        case .ultraThin: .ultraThinMaterial
        case .thin: .thinMaterial
        case .regular: .regularMaterial
        case .thick: .thickMaterial
        case .ultraThick: .ultraThickMaterial
        case .bar: .bar
        }
    }
}

private enum MaterialShapeOption: DemoOption {
    case roundedRectangle, capsule, rectangle

    var label: String {
        switch self {
        case .roundedRectangle: "Rounded rectangle"
        case .capsule: "Capsule"
        case .rectangle: "Rectangle"
        }
    }

    var code: String {
        switch self {
        case .roundedRectangle: ".rect(cornerRadius: 20)"
        case .capsule: ".capsule"
        case .rectangle: ".rect"
        }
    }

    var shape: AnyShape {
        switch self {
        case .roundedRectangle: AnyShape(.rect(cornerRadius: 20))
        case .capsule: AnyShape(.capsule)
        case .rectangle: AnyShape(.rect)
        }
    }
}

private enum BackdropOption: DemoOption {
    case photo, shapes, text

    var label: String {
        switch self {
        case .photo: "Photo"
        case .shapes: "Colorful shapes"
        case .text: "Text"
        }
    }
}

private struct MaterialsConfig {
    var material: MaterialOption = .ultraThin
    var shape: MaterialShapeOption = .roundedRectangle
    var backdrop: BackdropOption = .shapes
    var vibrantText = true
}

// MARK: - Backdrops

/// Bright circles: always available, even offline, and shows blur clearly.
private struct ColorfulBackdrop: View {
    var body: some View {
        ZStack {
            Color.indigo
            Circle().fill(.pink).frame(width: 180).offset(x: -90, y: -50)
            Circle().fill(.orange).frame(width: 140).offset(x: 100, y: 40)
            Circle().fill(.mint).frame(width: 110).offset(x: -20, y: 80)
            Capsule().fill(.yellow).frame(width: 160, height: 36).rotationEffect(.degrees(-20)).offset(x: 60, y: -70)
        }
    }
}

private struct TextBackdrop: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            ForEach(0..<14, id: \.self) { row in
                Text("The quick brown fox jumps over the lazy dog. 0123456789")
                    .font(.headline)
                    .foregroundStyle(row.isMultiple(of: 2) ? Color.primary : Color.blue)
                    .lineLimit(1)
                    .fixedSize()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.background)
    }
}

private struct PhotoBackdrop: View {
    var body: some View {
        AsyncImage(url: URL(string: "https://picsum.photos/seed/catalog/800/600")) { image in
            image.resizable().scaledToFill()
        } placeholder: {
            ColorfulBackdrop()
        }
    }
}

private struct Backdrop: View {
    let option: BackdropOption

    var body: some View {
        switch option {
        case .photo: PhotoBackdrop()
        case .shapes: ColorfulBackdrop()
        case .text: TextBackdrop()
        }
    }
}

// MARK: - Demo

private struct MaterialsDemo: View {
    let page: ComponentPage

    var body: some View {
        DemoPage(
            page: page,
            initial: MaterialsConfig(),
            previewHeight: 300,
            usage: """
            VStack(alignment: .leading) {
                Text("Now Playing")
                    .font(.headline)
                Text("Midnight City")
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(.regularMaterial, in: .rect(cornerRadius: 16))
            """,
            usageNote: Aside(.note, "A material blurs whatever is behind the view, so it only shows over an image or color. On a plain background it looks like a gray fill.")
        ) { $config in
            Color.clear
                .frame(height: 300)
                .background { Backdrop(option: config.backdrop) }
                .overlay {
                    VStack(alignment: .leading, spacing: 6) {
                        Label("Now Playing", systemImage: "music.note")
                            .font(.headline)
                        Text("Primary text stays crisp.")
                            .foregroundStyle(config.vibrantText ? AnyShapeStyle(.secondary) : AnyShapeStyle(.gray))
                        Text(config.material.label)
                            .font(.footnote.monospaced())
                            .foregroundStyle(config.vibrantText ? AnyShapeStyle(.tertiary) : AnyShapeStyle(.gray))
                    }
                    .padding()
                    .padding(.horizontal, config.shape == .capsule ? 12 : 0)
                    .background(config.material.material, in: config.shape.shape)
                    .padding(20)
                    .animation(.snappy, value: config.material)
                }
                .clipShape(.rect(cornerRadius: 14))
                .padding(-8)
        } controls: { $config in
            Section("Material") {
                Picker("Thickness", selection: $config.material) {
                    ForEach(MaterialOption.allCases) { option in
                        Text(option.shortLabel).tag(option)
                    }
                }
                OptionPicker("Shape", selection: $config.shape)
            }
            Section {
                Toggle("Vibrant text", isOn: $config.vibrantText)
            } footer: {
                Text("On uses `.secondary` and `.tertiary`, which blend with the material. Off uses a fixed `.gray`.")
            }
            Section("Behind it") {
                OptionPicker("Background", selection: $config.backdrop)
            }
        } code: { config in
            let secondary = config.vibrantText ? ".secondary" : ".gray"
            let tertiary = config.vibrantText ? ".tertiary" : ".gray"
            return """
            VStack(alignment: .leading, spacing: 6) {
                Label("Now Playing", systemImage: "music.note")
                    .font(.headline)
                Text("Primary text stays crisp.")
                    .foregroundStyle(\(secondary))
                Text("\(config.material.label)")
                    .font(.footnote.monospaced())
                    .foregroundStyle(\(tertiary))
            }
            .padding()\(config.shape == .capsule ? "\n.padding(.horizontal, 12)" : "")
            .background(\(config.material.label), in: \(config.shape.code))
            """
        } examples: {
            ExampleCard(
                title: "Caption over a photo",
                caption: "Put `.ultraThinMaterial` behind a caption so it stays readable on any image, light or dark.",
                code: """
                AsyncImage(url: URL(string: "https://picsum.photos/800/600")) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Color.gray
                }
                .frame(height: 220)
                .overlay(alignment: .bottom) {
                    VStack(alignment: .leading) {
                        Text("Photo of the Day").font(.headline)
                        Text("Readable on any image").foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(.ultraThinMaterial)
                }
                .clipShape(.rect(cornerRadius: 20))
                """,
                minHeight: 220
            ) {
                PhotoBackdrop()
                    .frame(height: 220)
                    .frame(maxWidth: 360)
                    .overlay(alignment: .bottom) {
                        VStack(alignment: .leading) {
                            Text("Photo of the Day").font(.headline)
                            Text("Readable on any image").foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(.ultraThinMaterial)
                    }
                    .clipShape(.rect(cornerRadius: 20))
            }

            ExampleCard(
                title: "Floating badge",
                caption: "Use `.background(.thinMaterial, in: .capsule)` for counts, tags, and status that sit above content.",
                code: """
                Label("3 new", systemImage: "bell.fill")
                    .font(.subheadline.weight(.semibold))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(.thinMaterial, in: .capsule)
                """,
                minHeight: 160
            ) {
                ColorfulBackdrop()
                    .frame(height: 160)
                    .overlay {
                        Label("3 new", systemImage: "bell.fill")
                            .font(.subheadline.weight(.semibold))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(.thinMaterial, in: .capsule)
                    }
                    .clipShape(.rect(cornerRadius: 14))
                    .padding(-8)
            }

            ExampleCard(
                title: "Progress overlay",
                caption: "Show a `ProgressView` on `.regularMaterial` while work runs, so the screen behind stays visible.",
                code: """
                @State private var isSaving = true

                List(["Groceries", "Errands", "Work"], id: \\.self) { item in
                    Text(item)
                }
                .overlay {
                    if isSaving {
                        ProgressView("Saving…")
                            .padding(24)
                            .background(.regularMaterial, in: .rect(cornerRadius: 16))
                    }
                }
                """,
                minHeight: 220,
                aside: Aside(.note, "Disable the content underneath, or people can still tap it through the overlay.")
            ) {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(["Groceries", "Errands", "Work", "Gym"], id: \.self) { item in
                        Label(item, systemImage: "list.bullet")
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(.fill.tertiary, in: .rect(cornerRadius: 10))
                    }
                }
                .frame(maxWidth: 320)
                .overlay {
                    ProgressView("Saving…")
                        .padding(24)
                        .background(.regularMaterial, in: .rect(cornerRadius: 16))
                }
            }
        }
    }
}

/// The same chip on a material, with vibrant or fixed secondary text.
private struct MaterialChip: View {
    let secondary: AnyShapeStyle

    var body: some View {
        ColorfulBackdrop()
            .frame(width: 260, height: 120)
            .overlay {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Now Playing").font(.headline)
                    Text("Midnight City · M83")
                        .font(.subheadline)
                        .foregroundStyle(secondary)
                }
                .padding(12)
                .background(.thinMaterial, in: .rect(cornerRadius: 14))
            }
            .clipShape(.rect(cornerRadius: 12))
    }
}

// MARK: - Thumbnail

private struct MaterialsThumbnail: View {
    var body: some View {
        ColorfulBackdrop()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Material").font(.headline)
                    Text(".ultraThinMaterial").font(.caption.monospaced()).foregroundStyle(.secondary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(.ultraThinMaterial, in: .rect(cornerRadius: 14))
            }
    }
}
