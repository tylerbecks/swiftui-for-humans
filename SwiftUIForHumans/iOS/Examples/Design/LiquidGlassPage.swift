import SwiftUI

extension ComponentPage {
    static let liquidGlass = ComponentPage(
        id: "liquid-glass",
        title: "Liquid Glass",
        summary: "The iOS 26 glass look: a lens-like surface that bends light, reacts to touch, and morphs between shapes.",
        category: .foundations,
        symbol: "drop.halffull",
        availability: ["iOS 26.0+", "macOS 26.0+", "tvOS 26.0+", "watchOS 26.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/applying-liquid-glass-to-custom-views",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/materials",
        aliases: ["glass", "glassmorphism", "frosted", "blur", "iOS 26", "new design", "floating button", "backdrop-filter", "glassEffect"],
        related: ["materials", "button", "toolbar", "matched-geometry"],
        notes: [
            "**System components get glass for free.** Tab bars, toolbars, sheets, and menus already use it. Reach for `.glassEffect()` only on your own controls.",
            "**It needs iOS 26.** For older versions, check `if #available(iOS 26, *)` and fall back to a [material](catalog://materials) like `.regularMaterial`.",
        ],
        api: [
            APIItem("`.buttonStyle(.glass)`", "A glass button. `.glassProminent` fills it with the tint."),
            APIItem("`.glassEffect(_:in:)`", "Puts glass behind any view, in a capsule by default."),
            APIItem("`.regular`, `.clear`", "Regular adapts to anything; clear is for photos and video."),
            APIItem("`.regular.tint(_:)`", "Colors the glass, like stained glass."),
            APIItem("`.regular.interactive()`", "Makes the glass react to touch."),
            APIItem("`GlassEffectContainer`", "Renders nearby glass together so shapes can blend."),
            APIItem("`.glassEffectID(_:in:)`", "Morphs glass between views as they come and go."),
        ],
        guidelines: [
            Guideline(
                "Keep glass on the controls layer.",
                "Glass marks things that float above content, like buttons and bars. On list rows or cards, it buries the content it's meant to show off.",
                good: "Plain rows, with one floating glass button.",
                bad: "Glass on every row competes with the content."
            ) {
                GlassLayerSample(glassRows: false)
            } bad: {
                GlassLayerSample(glassRows: true)
            },
            Guideline(
                "Tint only the main action.",
                "A tinted, prominent button draws the eye. If several are tinted, none stands out.",
                good: "One prominent button.",
                bad: "Both buttons are tinted, so neither leads."
            ) {
                GlassStage(height: 110) {
                    HStack(spacing: 8) {
                        Button("Cancel") {}.buttonStyle(.glass)
                        Button("Save") {}.buttonStyle(.glassProminent)
                    }
                    .lineLimit(1)
                }
            } bad: {
                GlassStage(height: 110) {
                    HStack(spacing: 8) {
                        Button("Cancel") {}.buttonStyle(.glassProminent).tint(.red)
                        Button("Save") {}.buttonStyle(.glassProminent)
                    }
                    .lineLimit(1)
                }
            },
            Guideline(
                "Use `.clear` only over rich media.",
                "It's very transparent, so it needs a busy photo or video behind it and bold content on top. Add a dark dimming layer if the media is bright."
            ),
            Guideline(
                "Test with accessibility settings on.",
                "Reduce Transparency and Increase Contrast change how glass looks. System glass handles them; check your custom views too."
            ),
        ],
        isNew: true
    ) {
        LiquidGlassThumbnail()
    } content: { page in
        LiquidGlassDemo(page: page)
    }
}

// MARK: - Options

private enum GlassVariant: DemoOption {
    case regular, clear, identity

    var label: String {
        switch self {
        case .regular: ".regular"
        case .clear: ".clear"
        case .identity: ".identity"
        }
    }

    var glass: Glass {
        switch self {
        case .regular: .regular
        case .clear: .clear
        case .identity: .identity
        }
    }
}

private enum GlassTint: DemoOption {
    case none, blue, purple, orange, green

    var label: String {
        switch self {
        case .none: "None"
        case .blue: ".blue"
        case .purple: ".purple"
        case .orange: ".orange"
        case .green: ".green"
        }
    }

    var color: Color? {
        switch self {
        case .none: nil
        case .blue: .blue
        case .purple: .purple
        case .orange: .orange
        case .green: .green
        }
    }
}

private enum GlassShapeOption: DemoOption {
    case capsule, circle, roundedRectangle

    var label: String {
        switch self {
        case .capsule: "Capsule (default)"
        case .circle: "Circle"
        case .roundedRectangle: "Rounded rectangle"
        }
    }

    var code: String? {
        switch self {
        case .capsule: nil
        case .circle: ".circle"
        case .roundedRectangle: ".rect(cornerRadius: 16)"
        }
    }

    var shape: AnyShape {
        switch self {
        case .capsule: AnyShape(.capsule)
        case .circle: AnyShape(.circle)
        case .roundedRectangle: AnyShape(.rect(cornerRadius: 16))
        }
    }
}

private enum GlassBackdropOption: DemoOption {
    case shapes, sunset, night, bright, wallpaper, plain

    var label: String {
        switch self {
        case .shapes: "Colorful shapes"
        case .sunset: Scenery.lake.label
        case .night: Scenery.city.label
        case .bright: Scenery.meadow.label
        case .wallpaper: Scenery.wallpaper.label
        case .plain: "Plain background"
        }
    }
}

private struct GlassConfig {
    var variant: GlassVariant = .regular
    var tint: GlassTint = .none
    var isInteractive = true
    var shape: GlassShapeOption = .capsule
    var backdrop: GlassBackdropOption = .shapes
}

private func glassValue(_ config: GlassConfig) -> Glass {
    var glass = config.variant.glass
    if let color = config.tint.color { glass = glass.tint(color) }
    if config.isInteractive { glass = glass.interactive() }
    return glass
}

// MARK: - Backdrops

private struct GlassShapesBackdrop: View {
    var body: some View {
        ZStack {
            LinearGradient(colors: [.cyan, .blue], startPoint: .top, endPoint: .bottom)
            Circle().fill(.yellow).frame(width: 150).offset(x: -110, y: -60)
            Circle().fill(.pink).frame(width: 120).offset(x: 120, y: 70)
            RoundedRectangle(cornerRadius: 20).fill(.green).frame(width: 90, height: 90).rotationEffect(.degrees(25)).offset(x: 40, y: -80)
        }
    }
}


private struct GlassBackdrop: View {
    let option: GlassBackdropOption

    var body: some View {
        switch option {
        case .sunset: SceneryView(.lake)
        case .night: SceneryView(.city)
        case .bright: SceneryView(.meadow)
        case .wallpaper: SceneryView(.wallpaper)
        case .shapes: GlassShapesBackdrop()
        case .plain: Rectangle().fill(.background)
        }
    }
}

/// A fixed-height stage with a backdrop that the glass can refract.
private struct GlassStage<Content: View>: View {
    var backdrop: GlassBackdropOption = .shapes
    var height: CGFloat = 220
    @ViewBuilder let content: Content

    var body: some View {
        Color.clear
            .frame(height: height)
            .background { GlassBackdrop(option: backdrop) }
            .overlay { content }
            .clipShape(.rect(cornerRadius: 16))
            .padding(-8)
    }
}

// MARK: - Demo

private struct LiquidGlassDemo: View {
    let page: ComponentPage

    var body: some View {
        DemoPage(
            page: page,
            initial: GlassConfig(),
            previewHeight: 280,
            usage: """
            // A system button
            Button("Save") {
                // Save
            }
            .buttonStyle(.glassProminent)

            // Your own view
            Label("Favorite", systemImage: "heart.fill")
                .padding()
                .glassEffect(.regular.interactive())
            """,
            usageNote: Aside(.important, "Put `.glassEffect()` after `.padding()` and `.frame()`. Like `.background`, it covers the view's size at that point in the chain.")
        ) { $config in
            GlassStage(backdrop: config.backdrop, height: 280) {
                VStack(spacing: 18) {
                    Group {
                        if config.shape == .circle {
                            Image(systemName: "heart.fill")
                                .font(.title)
                                .frame(width: 72, height: 72)
                        } else {
                            Label("Favorite", systemImage: "heart.fill")
                                .font(.title3.weight(.semibold))
                                .padding(.horizontal, 24)
                                .padding(.vertical, 16)
                        }
                    }
                    .glassEffect(glassValue(config), in: config.shape.shape)
                    .accessibilityLabel("Favorite")

                    Text(config.isInteractive ? "Press and hold it" : "Turn on Interactive to make it respond")
                        .font(.footnote.weight(.medium))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.regularMaterial, in: .capsule)
                }
            }
        } controls: { $config in
            Section("Glass") {
                OptionPicker("Variant", selection: $config.variant)
                OptionPicker("Tint", selection: $config.tint)
                Toggle("Interactive", isOn: $config.isInteractive)
                OptionPicker("Shape", selection: $config.shape)
            }
            Section {
                OptionPicker("Background", selection: $config.backdrop)
            } header: {
                Text("Behind it")
            } footer: {
                Text("Glass bends and reflects what's behind it, so try a photo, bright shapes, and a plain background.")
            }
        } code: { config in
            var glass = config.variant.label
            if let _ = config.tint.color { glass += ".tint(\(config.tint.label))" }
            if config.isInteractive { glass += ".interactive()" }
            let isDefault = glass == ".regular"
            let args: String
            switch (isDefault, config.shape.code) {
            case (true, nil): args = ""
            case (true, let shape?): args = "in: \(shape)"
            case (false, nil): args = glass
            case (false, let shape?): args = "\(glass), in: \(shape)"
            }
            let content = config.shape == .circle
                ? """
                Image(systemName: "heart.fill")
                    .font(.title)
                    .frame(width: 72, height: 72)
                """
                : """
                Label("Favorite", systemImage: "heart.fill")
                    .font(.title3.weight(.semibold))
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)
                """
            return content + "\n    .glassEffect(\(args))"
        } examples: {
            GlassButtonsExample()
            FloatingBarExample()
            MorphingExample()
        }
    }
}

// MARK: - Examples

private struct GlassButtonsExample: View {
    var body: some View {
        ExampleCard(
            title: "Glass buttons",
            caption: "Use `.buttonStyle(.glass)` for most buttons and `.glassProminent` for the main action.",
            code: """
            HStack {
                Button("Cancel") {}
                    .buttonStyle(.glass)
                Button("Save") {}
                    .buttonStyle(.glassProminent)
            }
            .controlSize(.large)
            """,
            minHeight: 160,
            aside: Aside(.note, "Buttons in a `.toolbar` already get glass. You don't need a style there.")
        ) {
            GlassStage(height: 160) {
                HStack {
                    Button("Cancel") {}
                        .buttonStyle(.glass)
                    Button("Save") {}
                        .buttonStyle(.glassProminent)
                }
                .controlSize(.large)
            }
        }
    }
}

private struct MorphingExample: View {
    @State private var isExpanded = false
    @Namespace private var glass

    var body: some View {
        ExampleCard(
            title: "Morphing with GlassEffectContainer",
            caption: "Give glass views a `glassEffectID` inside one `GlassEffectContainer`, and they melt into each other. Tap the pencil.",
            code: """
            @State private var isExpanded = false
            @Namespace private var glass

            GlassEffectContainer(spacing: 16) {
                HStack(spacing: 16) {
                    if isExpanded {
                        Image(systemName: "photo")
                            .frame(width: 56, height: 56)
                            .glassEffect(.regular.interactive())
                            .glassEffectID("photo", in: glass)
                        Image(systemName: "camera")
                            .frame(width: 56, height: 56)
                            .glassEffect(.regular.interactive())
                            .glassEffectID("camera", in: glass)
                    }
                    Button {
                        withAnimation(.bouncy) { isExpanded.toggle() }
                    } label: {
                        Image(systemName: isExpanded ? "xmark" : "pencil")
                            .frame(width: 56, height: 56)
                    }
                    .buttonStyle(.plain)
                    .glassEffect(.regular.interactive())
                    .glassEffectID("toggle", in: glass)
                }
                .font(.title2)
            }
            """,
            minHeight: 180,
            aside: Aside(.important, "Glass can't sample other glass. Without the container, nearby glass views look wrong and can't morph.")
        ) {
            GlassStage(height: 180) {
                GlassEffectContainer(spacing: 16) {
                    HStack(spacing: 16) {
                        if isExpanded {
                            Image(systemName: "photo")
                                .frame(width: 56, height: 56)
                                .glassEffect(.regular.interactive())
                                .glassEffectID("photo", in: glass)
                            Image(systemName: "camera")
                                .frame(width: 56, height: 56)
                                .glassEffect(.regular.interactive())
                                .glassEffectID("camera", in: glass)
                        }
                        Button {
                            withAnimation(.bouncy) { isExpanded.toggle() }
                        } label: {
                            Image(systemName: isExpanded ? "xmark" : "pencil")
                                .frame(width: 56, height: 56)
                                .contentTransition(.symbolEffect(.replace))
                        }
                        .buttonStyle(.plain)
                        .glassEffect(.regular.interactive())
                        .glassEffectID("toggle", in: glass)
                        .accessibilityLabel(isExpanded ? "Close" : "Edit")
                    }
                    .font(.title2)
                }
            }
        }
    }
}

private struct FloatingBarExample: View {
    @State private var selection = 0

    var body: some View {
        ExampleCard(
            title: "Floating control bar",
            caption: "Put related buttons in one `.glassEffect()` capsule so they read as a single control.",
            code: """
            HStack(spacing: 4) {
                ForEach(["bold", "italic", "underline"], id: \\.self) { name in
                    Button {
                        // Your action
                    } label: {
                        Image(systemName: name)
                            .font(.title3.weight(.semibold))
                            .frame(width: 44, height: 44)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(4)
            .glassEffect()
            """,
            minHeight: 160
        ) {
            GlassStage(backdrop: .night, height: 160) {
                HStack(spacing: 4) {
                    ForEach(Array(["bold", "italic", "underline"].enumerated()), id: \.offset) { index, name in
                        Button {
                            selection = index
                        } label: {
                            Image(systemName: name)
                                .font(.title3.weight(.semibold))
                                .frame(width: 44, height: 44)
                                .foregroundStyle(selection == index ? AnyShapeStyle(.tint) : AnyShapeStyle(.primary))
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(name.capitalized)
                    }
                }
                .padding(4)
                .glassEffect()
            }
        }
    }
}

// MARK: - Guideline samples

/// A short list with either one floating glass button or glass on every row.
private struct GlassLayerSample: View {
    let glassRows: Bool

    var body: some View {
        GlassStage(height: 190) {
            VStack(spacing: 8) {
                ForEach(["Lunch with Maya", "Pay rent", "Call Mom"], id: \.self) { item in
                    Text(item)
                        .font(.subheadline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(10)
                        .modifier(RowSurface(isGlass: glassRows))
                }
            }
            .padding(.horizontal, 16)
            .frame(maxHeight: .infinity, alignment: .top)
            .padding(.top, 14)
            .overlay(alignment: .bottomTrailing) {
                Image(systemName: "plus")
                    .font(.title3.weight(.semibold))
                    .frame(width: 44, height: 44)
                    .glassEffect(.regular.interactive())
                    .padding(12)
            }
        }
    }
}

private struct RowSurface: ViewModifier {
    let isGlass: Bool

    func body(content: Content) -> some View {
        if isGlass {
            content.glassEffect(in: .rect(cornerRadius: 10))
        } else {
            content.background(.background, in: .rect(cornerRadius: 10))
        }
    }
}

// MARK: - Thumbnail

private struct LiquidGlassThumbnail: View {
    var body: some View {
        GlassShapesBackdrop()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay {
                GlassEffectContainer(spacing: 10) {
                    HStack(spacing: 10) {
                        Label("Favorite", systemImage: "heart.fill")
                            .font(.headline)
                            .padding(.horizontal, 18)
                            .padding(.vertical, 12)
                            .glassEffect()
                        Image(systemName: "plus")
                            .font(.headline)
                            .frame(width: 46, height: 46)
                            .glassEffect(.regular.tint(.blue))
                            .foregroundStyle(.white)
                    }
                }
            }
    }
}
