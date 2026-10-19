import SwiftUI
import UIKit

extension ComponentPage {
    static let appIcons = ComponentPage(
        id: "app-icons",
        title: "App Icons",
        summary: "Design one layered icon that the system turns into every appearance and size.",
        category: .foundations,
        kind: .reference,
        symbol: "app.badge",
        availability: ["iOS 26.0+"],
        docsURL: "https://developer.apple.com/documentation/xcode/creating-your-app-icon-using-icon-composer",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/app-icons",
        aliases: ["app icon", "icon", "favicon", "Icon Composer", ".icon file", "AppIcon", "home screen icon", "dark icon", "tinted icon", "clear icon", "Liquid Glass icon", "alternate app icon", "setAlternateIconName", "1024x1024", "icon size"],
        related: ["liquid-glass", "dark-mode", "sf-symbols", "materials"],
        notes: [
            "**Older iOS versions are covered.** When your app supports releases before the Liquid Glass icon style, Xcode builds matching images for them from the same Icon Composer file at build time.",
            "**The `.icon` file replaces the asset catalog icon.** Once it's in your project, Xcode uses it instead of an `AppIcon` image set. Keep the asset catalog only if you want the old artwork on older releases.",
        ],
        api: [
            APIItem("Icon Composer", "Apple's tool for layered icons. Ships with Xcode."),
            APIItem("`AppIcon.icon`", "The file you add to your Xcode project."),
            APIItem("`supportsAlternateIcons`", "Whether the app can switch icons."),
            APIItem("`setAlternateIconName(_:)`", "Switches to an alternate icon. UIKit only."),
        ],
        guidelines: [
            Guideline(
                "Build around one simple idea.",
                "Pick a single shape that captures your app. Fine details turn to mush at small sizes and under the system's highlights and shadows.",
                good: "One bold shape, a plain background.",
                bad: "A busy scene that's lost when small."
            ) {
                AppIconTile(style: .simple)
            } bad: {
                AppIconTile(style: .busy)
            },
            Guideline(
                "Leave the words out.",
                "Your app's name already sits under the icon, and text in the icon can't be read at small sizes or translated. A single letter is fine if it's part of your brand.",
                good: "A symbol does the talking.",
                bad: "Words that are hard to read and can't be localized."
            ) {
                AppIconTile(style: .simple)
            } bad: {
                AppIconTile(style: .text)
            },
            Guideline(
                "Hand over square, flat layers.",
                "The system rounds the corners and adds highlights, shadows, and depth. Pre-rounded corners or baked-in effects clash with them and can leave jagged edges.",
                good: "Square layers, no effects.",
                bad: "Drawn-in corners, gloss, and shadow."
            ) {
                AppIconFlatLayer(baked: false)
            } bad: {
                AppIconFlatLayer(baked: true)
            },
            Guideline(
                "Keep the same features in every appearance.",
                "Dark, clear, and tinted versions should be recognizably the same icon. Swapping elements makes your app hard to find when people change their Home Screen.",
                good: "Dark keeps the same plane.",
                bad: "Dark swaps in a different symbol."
            ) {
                HStack(spacing: 12) {
                    AppIconRender(appearance: .standard, size: 64)
                    AppIconRender(appearance: .dark, size: 64)
                }
            } bad: {
                HStack(spacing: 12) {
                    AppIconRender(appearance: .standard, size: 64)
                    AppIconRender(appearance: .dark, size: 64, glyph: "envelope.fill")
                }
            },
            Guideline(
                "Draw it; don't photograph it.",
                "Photos, screenshots, and copies of standard controls lose detail when small and split badly into layers. Make an illustration of the idea instead."
            ),
        ],
        sources: [
            "https://developer.apple.com/design/human-interface-guidelines/app-icons",
            "https://developer.apple.com/documentation/xcode/creating-your-app-icon-using-icon-composer",
            "https://developer.apple.com/documentation/uikit/uiapplication/setalternateiconname(_:completionhandler:)",
        ],
        reviewed: "October 2026"
    ) {
        HStack(spacing: 10) {
            AppIconRender(appearance: .standard, size: 52)
            AppIconRender(appearance: .dark, size: 52)
            AppIconRender(appearance: .tinted, size: 52)
        }
        .accessibilityHidden(true)
    } content: { page in
        AppIconsArticle(page: page)
    }
}

// MARK: - Page

private struct AppIconsArticle: View {
    let page: ComponentPage

    var body: some View {
        ArticlePage(page: page) {
            Prose("Since iOS 26, app icons are made of **layers** that the system renders in Liquid Glass, with highlights and depth that react to light and movement. You design one icon in **Icon Composer**, and iOS produces every size and every Home Screen appearance from that single file.")

            VStack(alignment: .leading, spacing: 16) {
                SectionTitle("One icon, many appearances")
                AppIconAppearanceDemo()
            }
            .id("demo")

            VStack(alignment: .leading, spacing: 16) {
                SectionTitle("How an icon is built")
                AppIconLayerDiagram()
                Aside(.note, "Group your layers into at most four groups. Each group becomes a level of depth, and you can tune its glass effects together.")
            }
            .id("layers")

            VStack(alignment: .leading, spacing: 16) {
                SectionTitle("Specs")
                AppIconSpecTable()
            }
            .id("specs")

            VStack(alignment: .leading, spacing: 16) {
                SectionTitle("Make it")
                VStack(alignment: .leading, spacing: 12) {
                    AppIconStep(number: 1, text: "Draw the foreground shapes in your design tool on a square canvas. Leave the background, blur, and shadows for later.")
                    AppIconStep(number: 2, text: "Export each layer as **SVG**, or **PNG** for raster art and mesh gradients. Turn text into outlines, and don't export a mask.")
                    AppIconStep(number: 3, text: "Open Icon Composer from **Xcode › Open Developer Tool**. Drag in the layers, set a solid or gradient background, and group them.")
                    AppIconStep(number: 4, text: "Preview **Default**, **Dark**, and **Mono** (which covers clear and tinted), and adjust the colors for each where needed.")
                    AppIconStep(number: 5, text: "Save the `.icon` file, drag it into your project, and make sure the target's **App Icon** name matches the file name.")
                }
            }
            .id("steps")

            VStack(alignment: .leading, spacing: 16) {
                SectionTitle("In code")
                ExampleCard(
                    title: "Let people pick an alternate icon",
                    caption: "Call `setAlternateIconName` from a settings screen. SwiftUI has no equivalent, so this one is UIKit.",
                    code: """
                    Button("Use Night Icon") {
                        Task {
                            guard UIApplication.shared.supportsAlternateIcons else { return }
                            try? await UIApplication.shared.setAlternateIconName("NightIcon")
                        }
                    }
                    """,
                    minHeight: 150,
                    aside: Aside(.important, "Each alternate icon needs its own dark, clear, and tinted versions, and App Review checks it like your main icon. List the extra icons in the target's Alternate App Icon Sets build setting.")
                ) {
                    AppIconAlternatePicker()
                }
            }
            .id("examples")
        }
    }
}

// MARK: - Icon rendering (a sketch, not the system renderer)

private enum AppIconAppearance: String, CaseIterable, Identifiable {
    case standard = "Default"
    case dark = "Dark"
    case clear = "Clear"
    case tinted = "Tinted"

    var id: Self { self }

    var note: String {
        switch self {
        case .standard: "Your colors, as designed."
        case .dark: "Darker background, brighter shapes. Based on your default design."
        case .clear: "See-through glass that picks up the wallpaper."
        case .tinted: "One color, chosen by the person, applied to every icon."
        }
    }
}

private struct AppIconRender: View {
    let appearance: AppIconAppearance
    var size: CGFloat = 96
    var glyph = "paperplane.fill"
    var tint: Color = .orange

    var body: some View {
        ZStack {
            background
            Circle()
                .fill(circleFill)
                .frame(width: size * 0.62, height: size * 0.62)
                .offset(x: -size * 0.08, y: size * 0.06)
            Image(systemName: glyph)
                .font(.system(size: size * 0.38, weight: .semibold))
                .foregroundStyle(glyphFill)
                .offset(x: size * 0.04, y: -size * 0.02)
        }
        .frame(width: size, height: size)
        .clipShape(.rect(cornerRadius: size * 0.225, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: size * 0.225, style: .continuous)
                .strokeBorder(.white.opacity(appearance == .standard ? 0.25 : 0.18), lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.18), radius: size * 0.04, y: size * 0.02)
    }

    @ViewBuilder private var background: some View {
        switch appearance {
        case .standard:
            LinearGradient(colors: [Color(red: 0.25, green: 0.6, blue: 1), Color(red: 0.1, green: 0.35, blue: 0.9)], startPoint: .top, endPoint: .bottom)
        case .dark:
            LinearGradient(colors: [Color(white: 0.2), Color(white: 0.08)], startPoint: .top, endPoint: .bottom)
        case .clear:
            Rectangle().fill(.ultraThinMaterial)
        case .tinted:
            LinearGradient(colors: [tint.opacity(0.35), tint.opacity(0.18)], startPoint: .top, endPoint: .bottom)
                .background(.black)
        }
    }

    private var circleFill: AnyShapeStyle {
        switch appearance {
        case .standard: AnyShapeStyle(.white.opacity(0.25))
        case .dark: AnyShapeStyle(Color(red: 0.25, green: 0.6, blue: 1).opacity(0.3))
        case .clear: AnyShapeStyle(.white.opacity(0.2))
        case .tinted: AnyShapeStyle(tint.opacity(0.3))
        }
    }

    private var glyphFill: AnyShapeStyle {
        switch appearance {
        case .standard: AnyShapeStyle(.white)
        case .dark: AnyShapeStyle(LinearGradient(colors: [Color(red: 0.45, green: 0.75, blue: 1), Color(red: 0.25, green: 0.55, blue: 1)], startPoint: .top, endPoint: .bottom))
        case .clear: AnyShapeStyle(.white.opacity(0.9))
        case .tinted: AnyShapeStyle(tint)
        }
    }
}

private struct AppIconAppearanceDemo: View {
    @State private var appearance: AppIconAppearance = .standard

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("People choose how Home Screen icons look. Pick an appearance to see how one design carries over.")
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            VStack(spacing: 0) {
                ZStack {
                    LinearGradient(
                        colors: appearance == .standard
                            ? [Color(red: 0.98, green: 0.72, blue: 0.55), Color(red: 0.62, green: 0.48, blue: 0.9)]
                            : [Color(red: 0.2, green: 0.16, blue: 0.35), Color(red: 0.05, green: 0.08, blue: 0.2)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                    HStack(spacing: 22) {
                        AppIconHomeSlot(name: "Weather", symbol: "cloud.sun.fill", appearance: appearance)
                        VStack(spacing: 6) {
                            AppIconRender(appearance: appearance, size: 64)
                            Text("Postcard")
                                .font(.caption2)
                                .foregroundStyle(.white)
                        }
                        AppIconHomeSlot(name: "Notes", symbol: "note.text", appearance: appearance)
                    }
                }
                .frame(maxWidth: .infinity, minHeight: 170)
                .animation(.smooth, value: appearance)
                Divider()
                VStack(alignment: .leading, spacing: 10) {
                    Picker("Appearance", selection: $appearance) {
                        ForEach(AppIconAppearance.allCases) { appearance in
                            Text(appearance.rawValue).tag(appearance)
                        }
                    }
                    .pickerStyle(.segmented)
                    Text(appearance.note)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                    Text("A sketch drawn in SwiftUI. The system renders the real versions, in light and dark for clear and tinted.")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(14)
            }
            .cardStyle()
        }
    }
}

/// A neighbouring "app" on the Home Screen, so the sample icon sits in context.
private struct AppIconHomeSlot: View {
    let name: String
    let symbol: String
    let appearance: AppIconAppearance

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: symbol)
                .font(.system(size: 26, weight: .semibold))
                .foregroundStyle(foreground)
                .frame(width: 64, height: 64)
                .background(background, in: .rect(cornerRadius: 64 * 0.225, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 64 * 0.225, style: .continuous)
                        .strokeBorder(.white.opacity(0.18), lineWidth: 1)
                }
            Text(name)
                .font(.caption2)
                .foregroundStyle(.white)
        }
    }

    private var foreground: AnyShapeStyle {
        switch appearance {
        case .standard: AnyShapeStyle(name == "Notes" ? Color.yellow : Color.white)
        case .dark: AnyShapeStyle(name == "Notes" ? Color.yellow : Color.cyan)
        case .clear: AnyShapeStyle(.white.opacity(0.9))
        case .tinted: AnyShapeStyle(Color.orange)
        }
    }

    private var background: AnyShapeStyle {
        switch appearance {
        case .standard: AnyShapeStyle(name == "Notes" ? Color.white.gradient : Color.cyan.gradient)
        case .dark: AnyShapeStyle(Color(white: 0.14))
        case .clear: AnyShapeStyle(.ultraThinMaterial)
        case .tinted: AnyShapeStyle(Color.orange.opacity(0.25))
        }
    }
}

// MARK: - Layers

private struct AppIconLayerDiagram: View {
    var body: some View {
        VStack(spacing: 14) {
            HStack(spacing: 8) {
                layer(label: "Background") {
                    LinearGradient(colors: [Color(red: 0.25, green: 0.6, blue: 1), Color(red: 0.1, green: 0.35, blue: 0.9)], startPoint: .top, endPoint: .bottom)
                }
                Image(systemName: "plus").foregroundStyle(.secondary)
                layer(label: "Group 1") {
                    ZStack {
                        AppIconChecker()
                        Circle()
                            .fill(.white.opacity(0.4))
                            .frame(width: 32, height: 32)
                            .offset(x: -4, y: 3)
                    }
                }
                Image(systemName: "plus").foregroundStyle(.secondary)
                layer(label: "Group 2") {
                    ZStack {
                        AppIconChecker()
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(.white)
                            .shadow(color: .black.opacity(0.2), radius: 1)
                    }
                }
                Image(systemName: "equal").foregroundStyle(.secondary)
                VStack(spacing: 6) {
                    AppIconRender(appearance: .standard, size: 52)
                    Text("Icon")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .font(.caption.weight(.bold))
            Text("You supply square, unmasked layers. The system adds the rounded mask, glass, highlights, and shadows.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .cardStyle()
    }

    private func layer<Content: View>(label: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(spacing: 6) {
            content()
                .frame(width: 52, height: 52)
                .clipShape(.rect(cornerRadius: 3))
                .overlay {
                    RoundedRectangle(cornerRadius: 3)
                        .strokeBorder(.separator)
                }
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .fixedSize()
        }
    }
}

/// The checkerboard design tools use to show transparency.
private struct AppIconChecker: View {
    var body: some View {
        Canvas { context, size in
            let cell: CGFloat = 6.5
            for row in 0..<Int(size.height / cell) + 1 {
                for column in 0..<Int(size.width / cell) + 1 where (row + column).isMultiple(of: 2) {
                    context.fill(Path(CGRect(x: CGFloat(column) * cell, y: CGFloat(row) * cell, width: cell, height: cell)), with: .color(.gray.opacity(0.25)))
                }
            }
        }
    }
}

private struct AppIconSpecTable: View {
    private let rows: [(String, String)] = [
        ("Canvas", "1024 × 1024 px, square. The system rounds the corners."),
        ("Layer files", "SVG for shapes; PNG for raster art and mesh gradients."),
        ("Groups", "Up to four, stacked bottom to top."),
        ("Appearances", "Default, dark, clear (light and dark), and tinted (light and dark)."),
        ("Missing variants", "The system generates any appearance you don't customize."),
        ("Color spaces", "sRGB, Display P3, or Gray Gamma 2.2."),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(rows.enumerated()), id: \.offset) { index, row in
                if index > 0 { Divider() }
                VStack(alignment: .leading, spacing: 2) {
                    Text(row.0)
                        .font(.subheadline.weight(.semibold))
                    Text(row.1)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 9)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 4)
        .background(.background.secondary, in: .rect(cornerRadius: 16))
    }
}

private struct AppIconStep: View {
    let number: Int
    let text: String

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            Text("\(number)")
                .font(.subheadline.bold())
                .foregroundStyle(.white)
                .frame(width: 24, height: 24)
                .background(.tint, in: .circle)
            RichText(text)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

// MARK: - Example and guideline views

private struct AppIconAlternatePicker: View {
    @State private var useNight = false

    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 20) {
                choice(title: "Default", isSelected: !useNight) {
                    AppIconRender(appearance: .standard, size: 60)
                }
                .onTapGesture { useNight = false }
                choice(title: "Night", isSelected: useNight) {
                    AppIconRender(appearance: .dark, size: 60, glyph: "paperplane.fill")
                }
                .onTapGesture { useNight = true }
            }
            Button(useNight ? "Use Default Icon" : "Use Night Icon") {
                useNight.toggle()
            }
            .buttonStyle(.bordered)
            Text("A mock: it doesn't change this app's icon.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private func choice<Content: View>(title: String, isSelected: Bool, @ViewBuilder icon: () -> Content) -> some View {
        VStack(spacing: 6) {
            icon()
                .padding(4)
                .overlay {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .strokeBorder(isSelected ? AnyShapeStyle(.tint) : AnyShapeStyle(.clear), lineWidth: 2.5)
                }
            Label(title, systemImage: isSelected ? "checkmark.circle.fill" : "circle")
                .font(.caption)
                .foregroundStyle(isSelected ? AnyShapeStyle(.tint) : AnyShapeStyle(.secondary))
        }
        .contentShape(.rect)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(title) icon")
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }
}

private struct AppIconTile: View {
    enum Style { case simple, busy, text }
    let style: Style

    var body: some View {
        Group {
            switch style {
            case .simple:
                AppIconRender(appearance: .standard, size: 72)
            case .busy:
                ZStack {
                    LinearGradient(colors: [.green, .teal], startPoint: .top, endPoint: .bottom)
                    ForEach(Array(["sun.max.fill", "cloud.fill", "tree.fill", "car.fill", "house.fill", "bird.fill", "leaf.fill"].enumerated()), id: \.offset) { index, symbol in
                        Image(systemName: symbol)
                            .font(.system(size: 13))
                            .foregroundStyle(.white.opacity(0.9))
                            .offset(x: CGFloat([-20, 18, -14, 20, 0, -22, 14][index]), y: CGFloat([-22, -20, 4, 8, -4, 22, 24][index]))
                    }
                }
                .frame(width: 72, height: 72)
                .clipShape(.rect(cornerRadius: 72 * 0.225, style: .continuous))
            case .text:
                ZStack {
                    LinearGradient(colors: [Color(red: 0.25, green: 0.6, blue: 1), Color(red: 0.1, green: 0.35, blue: 0.9)], startPoint: .top, endPoint: .bottom)
                    VStack(spacing: 0) {
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 18, weight: .semibold))
                        Text("SEND\nPOSTCARDS")
                            .font(.system(size: 8, weight: .heavy))
                            .multilineTextAlignment(.center)
                    }
                    .foregroundStyle(.white)
                }
                .frame(width: 72, height: 72)
                .clipShape(.rect(cornerRadius: 72 * 0.225, style: .continuous))
            }
        }
    }
}

private struct AppIconFlatLayer: View {
    let baked: Bool

    var body: some View {
        ZStack {
            if baked {
                RoundedRectangle(cornerRadius: 18)
                    .fill(LinearGradient(colors: [Color(red: 0.25, green: 0.6, blue: 1), Color(red: 0.1, green: 0.35, blue: 0.9)], startPoint: .top, endPoint: .bottom))
                    .overlay(alignment: .top) {
                        Ellipse()
                            .fill(.white.opacity(0.45))
                            .frame(width: 70, height: 34)
                            .offset(y: -6)
                    }
                    .shadow(color: .black.opacity(0.5), radius: 6, y: 5)
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 30, weight: .semibold))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.6), radius: 3, x: 2, y: 3)
            } else {
                Rectangle()
                    .fill(LinearGradient(colors: [Color(red: 0.25, green: 0.6, blue: 1), Color(red: 0.1, green: 0.35, blue: 0.9)], startPoint: .top, endPoint: .bottom))
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 30, weight: .semibold))
                    .foregroundStyle(.white)
            }
        }
        .frame(width: 80, height: 80)
    }
}
