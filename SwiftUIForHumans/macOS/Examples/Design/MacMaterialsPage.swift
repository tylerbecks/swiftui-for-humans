import SwiftUI

extension ComponentPage {
    static let materials = ComponentPage(
        id: "materials",
        title: "Materials & Liquid Glass",
        summary: "Liquid Glass for controls that float above content, standard materials within it.",
        category: .foundations,
        kind: .concept,
        symbol: "square.stack.3d.down.forward",
        availability: ["macOS 26.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/applying-liquid-glass-to-custom-views",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/materials",
        aliases: ["liquid glass", "glass", "glassEffect", "blur", "frosted glass", "translucency", "vibrancy", "NSVisualEffectView", "backdrop-filter", "material", "regularMaterial", "thinMaterial", "sidebar material"],
        related: ["color", "dark-mode", "contrast-transparency", "toolbar", "navigation-split-view"],
        notes: [
            "**Standard components already use Liquid Glass.** Toolbars, sidebars, and system controls pick it up on their own in macOS 26. Reach for `.glassEffect` only for your own controls.",
            "**A material blurs your app, not the desktop.** SwiftUI's materials blur the content inside your window, not what's behind it on screen.",
        ],
        api: [
            APIItem("`.glassEffect(_:in:)`", "Liquid Glass behind a custom control."),
            APIItem("`GlassEffectContainer`", "Groups glass shapes so they blend together."),
            APIItem("`.buttonStyle(.glass)`", "A button with a Liquid Glass background."),
            APIItem("`.buttonStyle(.glassProminent)`", "Tinted glass, for the main action."),
            APIItem("`.glassEffect(.clear)`", "The see-through variant, for over media."),
            APIItem("`.background(.regularMaterial)`", "A standard material in the content layer."),
            APIItem("`\\.accessibilityReduceTransparency`", "True when people turn translucency down."),
        ],
        guidelines: [
            Guideline(
                "Keep Liquid Glass out of the content.",
                "Glass marks the layer of controls and navigation that floats above your content. Glass cards and backgrounds inside the content blur that line; use a standard material there instead."
            ),
            Guideline(
                "Use glass sparingly on your own controls.",
                "Glass draws attention to what's beneath it. Save it for the few custom controls that matter most, like the playback controls over a video."
            ),
            Guideline(
                "Use clear glass only over rich media.",
                "The clear variant lets photos and video show through. Over bright content, add a dark layer at about 35% opacity behind it so labels stay readable."
            ),
            Guideline(
                "Pick a material for its purpose, not its color.",
                "People's settings change how materials look. A thicker material gives text more contrast; a thinner one keeps more of the background visible."
            ),
            Guideline(
                "Use vibrant colors on materials.",
                "Hierarchical styles like `.secondary` blend with a material for contrast. A fixed color, like `.gray`, turns that blending off.",
                good: "`.secondary` text on the material.",
                bad: "Fixed `.gray` text on the material."
            ) {
                MacMaterialCaption(usesVibrancy: true)
            } bad: {
                MacMaterialCaption(usesVibrancy: false)
            },
        ],
        sources: [
            "https://developer.apple.com/design/human-interface-guidelines/materials",
            "https://developer.apple.com/documentation/swiftui/applying-liquid-glass-to-custom-views",
            "https://developer.apple.com/documentation/swiftui/view/glasseffect(_:in:)",
            "https://developer.apple.com/documentation/swiftui/glasseffectcontainer",
            "https://developer.apple.com/documentation/swiftui/material",
            "https://developer.apple.com/documentation/swiftui/environmentvalues/accessibilityreducetransparency",
        ],
        reviewed: "October 2026"
    ) {
        ZStack {
            SceneryView(.lake)
            Image(systemName: "play.fill")
                .font(.title2)
                .frame(width: 52, height: 52)
                .glassEffect()
        }
        .frame(width: 150, height: 100)
        .clipShape(.rect(cornerRadius: 12))
    } content: { page in
        MacMaterialsArticle(page: page)
    }
}

// MARK: - Page

private struct MacMaterialsArticle: View {
    let page: ComponentPage

    var body: some View {
        ArticlePage(page: page) {
            Prose("A material lets some of what's behind it show through, which keeps a sense of place while separating layers. The Mac has two kinds. **Liquid Glass** is the layer of controls and navigation, like toolbars and sidebars, that floats above your content. **Standard materials** add structure inside the content itself.")

            VStack(alignment: .leading, spacing: 16) {
                SectionTitle("Which one where")
                ConnectFacts(rows: [
                    ("Liquid Glass", "Toolbars, sidebars, and controls that float over content. System components use it automatically; `.glassEffect` adds it to your own."),
                    ("Standard materials", "Structure in the content layer, like a caption bar over a photo. Thin to thick: `.ultraThinMaterial` through `.ultraThickMaterial`."),
                    ("Vibrancy", "On a material, text in `.primary` or `.secondary` blends with the background for contrast. You get it by using hierarchical styles."),
                ])
            }

            VStack(alignment: .leading, spacing: 16) {
                SectionTitle("Try the variants")
                    .id("demo")
                MacGlassDemo()
                Aside(.note, "Glass looks different when people turn on Reduce Transparency or Increase Contrast, so check your controls with those settings too.")
            }

            VStack(alignment: .leading, spacing: 16) {
                SectionTitle("In SwiftUI")
                    .id("examples")
                VStack(alignment: .leading, spacing: 44) {
                    ExampleCard(
                        title: "Glass buttons over media",
                        caption: "Use `.buttonStyle(.glass)` for controls that float over a photo or video, and wrap them in a `GlassEffectContainer`.",
                        code: """
                        ZStack(alignment: .bottom) {
                            Image("photo")
                                .resizable()
                                .scaledToFill()
                            GlassEffectContainer {
                                HStack {
                                    Button("Previous", systemImage: "backward.fill") { }
                                    Button("Play", systemImage: "play.fill") { }
                                    Button("Next", systemImage: "forward.fill") { }
                                }
                                .labelStyle(.iconOnly)
                                .buttonStyle(.glass)
                            }
                            .padding()
                        }
                        .frame(width: 360, height: 200)
                        .clipped()
                        """,
                        minHeight: 240
                    ) {
                        ZStack(alignment: .bottom) {
                            SceneryView(.city)
                            GlassEffectContainer {
                                HStack {
                                    Button("Previous", systemImage: "backward.fill") { }
                                    Button("Play", systemImage: "play.fill") { }
                                    Button("Next", systemImage: "forward.fill") { }
                                }
                                .labelStyle(.iconOnly)
                                .buttonStyle(.glass)
                            }
                            .padding()
                        }
                        .frame(width: 360, height: 200)
                        .clipShape(.rect(cornerRadius: 12))
                    }

                    ExampleCard(
                        title: "Clear glass with a dimming layer",
                        caption: "Use `.glassEffect(.clear)` over bright media, with a dark layer behind it so the label stays readable.",
                        code: """
                        ZStack {
                            Image("photo")
                                .resizable()
                                .scaledToFill()
                            Color.black.opacity(0.35)
                            Label("Lisbon", systemImage: "mappin")
                                .font(.title3)
                                .foregroundStyle(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .glassEffect(.clear)
                        }
                        .frame(width: 360, height: 200)
                        .clipped()
                        """,
                        minHeight: 240
                    ) {
                        ZStack {
                            SceneryView(.meadow)
                            Color.black.opacity(0.35)
                            Label("Lisbon", systemImage: "mappin")
                                .font(.title3)
                                .foregroundStyle(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .glassEffect(.clear)
                        }
                        .frame(width: 360, height: 200)
                        .clipShape(.rect(cornerRadius: 12))
                    }

                    ExampleCard(
                        title: "A material in the content",
                        caption: "Put `.regularMaterial` behind a caption on a photo, and use `.secondary` for the detail so it picks up vibrancy.",
                        code: """
                        Image("photo")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 360, height: 200)
                            .overlay(alignment: .bottom) {
                                VStack(alignment: .leading) {
                                    Text("Sunset at Belém")
                                        .font(.headline)
                                    Text("May 14, 8:52 PM")
                                        .foregroundStyle(.secondary)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(10)
                                .background(.regularMaterial)
                            }
                            .clipped()
                        """,
                        minHeight: 240
                    ) {
                        SceneryView(.lake)
                            .frame(width: 360, height: 200)
                            .overlay(alignment: .bottom) {
                                VStack(alignment: .leading) {
                                    Text("Sunset at Belém")
                                        .font(.headline)
                                    Text("May 14, 8:52 PM")
                                        .foregroundStyle(.secondary)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(10)
                                .background(.regularMaterial)
                            }
                            .clipShape(.rect(cornerRadius: 12))
                    }

                    ExampleCard(
                        title: "Respect Reduce Transparency",
                        caption: "Read `accessibilityReduceTransparency` and swap a custom translucent background for a solid one when it's on.",
                        code: """
                        @Environment(\\.accessibilityReduceTransparency) private var reduceTransparency

                        Text("Downloading 3 photos…")
                            .padding(10)
                            .background(reduceTransparency ? AnyShapeStyle(.windowBackground) : AnyShapeStyle(.thinMaterial), in: .rect(cornerRadius: 8))
                        """,
                        minHeight: 150,
                        aside: Aside(.note, "System materials and Liquid Glass adjust for this setting on their own. Check your own translucent views.")
                    ) {
                        MacReduceTransparencySample()
                    }
                }
            }
        }
    }
}

// MARK: - Demo

private enum MacGlassVariant: String, CaseIterable, Identifiable {
    case regular = "Regular"
    case clear = "Clear"

    var id: Self { self }
    var glass: Glass { self == .regular ? .regular : .clear }
}

/// Glass controls over a backdrop. Switch the variant, the backdrop, and the
/// dimming layer.
private struct MacGlassDemo: View {
    @State private var variant = MacGlassVariant.regular
    @State private var scenery = Scenery.lake
    @State private var dims = false

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                SceneryView(scenery)
                if dims {
                    Color.black.opacity(0.35)
                }
                VStack(spacing: 14) {
                    Label("Lisbon", systemImage: "mappin")
                        .font(.title3)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .glassEffect(variant.glass)
                    GlassEffectContainer {
                        HStack(spacing: 10) {
                            ForEach(["backward.fill", "play.fill", "forward.fill"], id: \.self) { symbol in
                                Image(systemName: symbol)
                                    .font(.title3)
                                    .frame(width: 44, height: 44)
                                    .glassEffect(variant.glass)
                            }
                        }
                    }
                }
            }
            .frame(height: 280)
            .clipped()
            Divider()
            HStack(spacing: 20) {
                Picker("Glass", selection: $variant) {
                    ForEach(MacGlassVariant.allCases) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
                .pickerStyle(.segmented)
                .fixedSize()
                Picker("Backdrop", selection: $scenery) {
                    ForEach(Scenery.allCases) { option in
                        Text(option.label).tag(option)
                    }
                }
                .fixedSize()
                Toggle("Dimming layer", isOn: $dims)
                Spacer(minLength: 0)
            }
            .padding(14)
        }
        .cardStyle()
    }
}

private struct MacReduceTransparencySample: View {
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    var body: some View {
        ZStack {
            SceneryView(.meadow)
            Text("Downloading 3 photos…")
                .padding(10)
                .background(reduceTransparency ? AnyShapeStyle(.windowBackground) : AnyShapeStyle(.thinMaterial), in: .rect(cornerRadius: 8))
        }
        .frame(width: 300, height: 110)
        .clipShape(.rect(cornerRadius: 12))
    }
}

// MARK: - Guideline samples

private struct MacMaterialCaption: View {
    let usesVibrancy: Bool

    var body: some View {
        SceneryView(.lake)
            .frame(width: 240, height: 120)
            .overlay(alignment: .bottom) {
                VStack(alignment: .leading) {
                    Text("Sunset at Belém")
                        .font(.headline)
                    Text("May 14, 8:52 PM")
                        .foregroundStyle(usesVibrancy ? AnyShapeStyle(.secondary) : AnyShapeStyle(Color.gray))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(10)
                .background(.regularMaterial)
            }
            .clipShape(.rect(cornerRadius: 10))
    }
}
