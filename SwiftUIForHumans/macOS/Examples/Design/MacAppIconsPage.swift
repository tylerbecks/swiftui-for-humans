import SwiftUI

extension ComponentPage {
    static let appIcons = ComponentPage(
        id: "app-icons",
        title: "App Icons",
        summary: "A square, layered icon that the Mac rounds and finishes in Liquid Glass.",
        category: .foundations,
        kind: .concept,
        symbol: "app.dashed",
        availability: [],
        docsURL: "https://developer.apple.com/documentation/xcode/creating-your-app-icon-using-icon-composer",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/app-icons",
        aliases: ["app icon", "icon", "AppIcon", "Icon Composer", ".icon", "dock icon", "icns", "app icon size", "1024", "dark icon", "tinted icon", "clear icon", "layers", "squircle"],
        related: ["sf-symbols", "dark-mode", "color", "mac-screenshots"],
        notes: [
            "**One Icon Composer file covers every size.** The system scales your icon down for small places, so you don't export a set of sizes anymore.",
            "**SF Symbols can't be part of your icon.** Apple's terms for SF Symbols don't allow them, or look-alikes, in app icons and logos. Draw your own shapes.",
        ],
        guidelines: [
            Guideline(
                "Keep it simple.",
                "Pick one idea that captures your app and draw it with a few bold shapes. Fine details get busy under the system's highlights and disappear at small sizes.",
                good: "One bold shape on a simple background.",
                bad: "Lots of small details."
            ) {
                MacSampleIcon(isBusy: false)
            } bad: {
                MacSampleIcon(isBusy: true)
            },
            Guideline(
                "Leave out words.",
                "Text in an icon isn't accessible or localized, and it's often too small to read. Add it only when it's essential to your brand; the app's name usually appears nearby.",
                good: "The shape alone.",
                bad: "The same icon with the app's name on it."
            ) {
                MacSampleIcon(isBusy: false)
            } bad: {
                MacSampleIcon(isBusy: false, label: "Trips")
            },
            Guideline(
                "Let the system add the effects.",
                "The Mac adds highlights, shadows, refraction, and translucency that respond to the environment. Baked-in shadows, bevels, and glows fight with them and stay static."
            ),
            Guideline(
                "Prefer illustrations to photos and screenshots.",
                "Photos are full of detail that falls apart at small sizes and across appearances. Draw a simple picture of what matters instead, and don't copy your app's interface."
            ),
            Guideline(
                "Keep it recognizable in every appearance.",
                "People can switch their icons to dark, clear, or tinted. Keep the same shapes in each one, so your app is still easy to find."
            ),
            Guideline(
                "Don't draw Apple hardware.",
                "Apple's products are copyrighted, so don't reproduce a Mac, iPhone, or other device in your icon."
            ),
        ],
        sources: [
            "https://developer.apple.com/design/human-interface-guidelines/app-icons",
            "https://developer.apple.com/documentation/xcode/creating-your-app-icon-using-icon-composer",
            "https://developer.apple.com/icon-composer/",
            "https://developer.apple.com/design/human-interface-guidelines/sf-symbols",
        ],
        reviewed: "October 2026"
    ) {
        MacSampleIcon(isBusy: false, size: 88)
    } content: { page in
        MacAppIconsArticle(page: page)
    }
}

// MARK: - Page

private struct MacAppIconsArticle: View {
    let page: ComponentPage

    var body: some View {
        ArticlePage(page: page) {
            Prose("Your icon helps people recognize your app at a glance, everywhere it appears. On the Mac it's a **square, layered design**: you provide a background and one or more foreground layers, and the system rounds the corners and adds Liquid Glass highlights, refraction, and translucency. You put it together in **Icon Composer**, which comes with Xcode.")

            VStack(alignment: .leading, spacing: 16) {
                SectionTitle("Layers, back to front")
                    .id("demo")
                MacIconLayers()
            }

            VStack(alignment: .leading, spacing: 16) {
                SectionTitle("The essentials")
                ConnectFacts(rows: [
                    ("Canvas", "1024 × 1024 pixels, square. Give the system square, unmasked layers; it applies the rounded corners."),
                    ("Layers", "A background, which can be a solid color or gradient set in Icon Composer, plus foreground layers. Icon Composer arranges them in up to four groups."),
                    ("Appearances", "Default, dark, clear, and tinted, with light and dark versions of clear and tinted. The system makes any you don't design yourself."),
                    ("Color", "sRGB, Display P3 for wide color, or Gray Gamma 2.2 for grayscale."),
                ])
            }

            VStack(alignment: .leading, spacing: 16) {
                SectionTitle("Make it in Icon Composer")
                ConnectSteps(steps: [
                    "Draw each layer separately in your design tool, on a 1024 × 1024 canvas or Apple's app icon template. Leave out blurs, shadows, and the background color.",
                    "Export the layers as **SVG**, with text converted to outlines, or as **PNG** for raster art. Don't export the rounded mask.",
                    "In Xcode, choose **Xcode > Open Developer Tool > Icon Composer**. Save the file with the name you'll use in Xcode, like `AppIcon`.",
                    "Drag your layers into the sidebar and arrange them in groups. Set the background fill, adjust the Liquid Glass settings, and preview **Default**, **Dark**, and **Mono** for macOS.",
                    "Drag the `.icon` file into your Xcode project. In the target's **General** tab, under **App Icons and Launch Screen**, make the App Icon name match the file's name.",
                ])
                Aside(.note, "The Icon Composer file replaces an `AppIcon` asset catalog. For earlier versions of macOS, Xcode generates matching images from it when you build.")
            }
        }
    }
}

// MARK: - Samples

/// A made-up icon for a travel app, drawn from simple shapes (no SF
/// Symbols, which aren't allowed in app icons).
private struct MacSampleIcon: View {
    var isBusy: Bool
    var label: String? = nil
    var size: CGFloat = 110

    var body: some View {
        ZStack {
            MacIconBackground()
            MacIconForeground()
            if isBusy {
                // Small houses, trees, and birds: detail that turns to
                // noise at small sizes.
                ForEach(0..<6, id: \.self) { index in
                    Rectangle()
                        .fill(Color(hex: 0x1D5FD1).opacity(0.8))
                        .frame(width: 7, height: 6 + CGFloat(index % 3) * 2)
                        .offset(x: CGFloat(index) * 13 - 33, y: 22 + CGFloat(index % 2) * 6)
                }
                ForEach(0..<5, id: \.self) { index in
                    Circle()
                        .fill(Color(hex: 0x2E8B57))
                        .frame(width: 5, height: 5)
                        .offset(x: CGFloat(index) * 15 - 30, y: 38)
                }
                ForEach(0..<4, id: \.self) { index in
                    Capsule()
                        .fill(.white)
                        .frame(width: 7, height: 2)
                        .rotationEffect(.degrees(index.isMultiple(of: 2) ? 20 : -20))
                        .offset(x: CGFloat(index) * 11 - 38, y: -30 + CGFloat(index % 2) * 5)
                }
            }
            if let label {
                Text(label)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(Color(hex: 0x1D5FD1))
                    .offset(y: 34)
            }
        }
        .frame(width: 110, height: 110)
        .clipShape(.rect(cornerRadius: 25, style: .continuous))
        .scaleEffect(size / 110)
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }
}

private struct MacIconBackground: View {
    var body: some View {
        LinearGradient(colors: [Color(hex: 0x37A0F4), Color(hex: 0x1D5FD1)], startPoint: .top, endPoint: .bottom)
    }
}

/// A sun over a hill: the foreground layers.
private struct MacIconForeground: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(Color(hex: 0xFFD25A))
                .frame(width: 44, height: 44)
                .offset(x: 14, y: -14)
            Ellipse()
                .fill(.white.opacity(0.92))
                .frame(width: 130, height: 70)
                .offset(y: 42)
        }
        .frame(width: 110, height: 110)
    }
}

/// The sample icon pulled apart into its layers, then put back together.
private struct MacIconLayers: View {
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            layer("Background") {
                MacIconBackground()
                    .frame(width: 96, height: 96)
            }
            Image(systemName: "plus")
                .foregroundStyle(.secondary)
                .padding(.top, 40)
            layer("Foreground") {
                MacIconForeground()
                    .scaleEffect(96 / 110)
                    .frame(width: 96, height: 96)
                    .background(Color(white: 0.55))
                    .overlay {
                        Rectangle()
                            .strokeBorder(.separator, style: StrokeStyle(lineWidth: 1, dash: [4, 3]))
                    }
                    .clipped()
            }
            Image(systemName: "arrow.right")
                .foregroundStyle(.secondary)
                .padding(.top, 40)
            layer("Masked by the system") {
                MacSampleIcon(isBusy: false, size: 96)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(Surface.preview)
        .cardStyle()
    }

    private func layer(_ title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(spacing: 10) {
            content()
            Text(title)
                .font(.callout)
                .foregroundStyle(.secondary)
        }
    }
}
