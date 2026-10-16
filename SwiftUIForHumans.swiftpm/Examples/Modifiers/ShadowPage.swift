import SwiftUI

extension ComponentPage {
    static let shadow = ComponentPage(
        id: "shadow",
        title: "shadow",
        summary: "Draws a soft shadow behind a view to lift it off the background.",
        category: .modifiers,
        kind: .modifier,
        symbol: "shadow",
        availability: ["iOS 13.0+", "macOS 10.15+", "visionOS 1.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/view/shadow(color:radius:x:y:)",
        aliases: ["box-shadow", "drop shadow", "elevation", "glow", "text-shadow", "depth", "CALayer shadow"],
        related: ["clip-shape", "background-overlay", "visual-effects", "materials"],
        notes: [
            "**The default shadow is strong.** It's black at 33% opacity. Most designs use `.black.opacity(0.1)` to `0.2`.",
            "**Shadows barely show in dark mode.** iOS shows depth there with a lighter fill or a material instead, so don't rely on a shadow alone.",
        ],
        api: [
            APIItem("`.shadow(radius:)`", "A default gray shadow, blurred by `radius`."),
            APIItem("`.shadow(color:radius:x:y:)`", "Sets the color and moves the shadow by `x` and `y`."),
            APIItem("`radius:`", "The blur amount, like the blur in CSS `box-shadow`."),
            APIItem("`.background { Shape().shadow() }`", "Shadows only the card, not its contents."),
            APIItem("`.shadow(.drop(…))`", "A shadow as a fill style, for shapes and text."),
        ]
    ) {
        ShadowThumbnail()
    } content: { page in
        ShadowDemo(page: page)
    }
}

/// A white card in light mode; a lighter gray card in dark mode, where a
/// black fill would hide both the card and its shadow.
private struct ShadowThumbnail: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        RoundedRectangle(cornerRadius: 18)
            .fill(colorScheme == .dark ? AnyShapeStyle(.background.tertiary) : AnyShapeStyle(.background))
            .frame(width: 150, height: 92)
            .shadow(color: .black.opacity(0.22), radius: 14, x: 0, y: 8)
            .overlay {
                Image(systemName: "square.stack.3d.up.fill")
                    .font(.title)
                    .foregroundStyle(.tint)
            }
    }
}

private struct ShadowConfig {
    var color: ShadowColor = .black
    var opacity = 0.2
    var radius = 16.0
    var x = 0.0
    var y = 8.0
}

private enum ShadowColor: DemoOption {
    case black, blue, pink

    var label: String {
        switch self {
        case .black: ".black"
        case .blue: ".blue"
        case .pink: ".pink"
        }
    }

    var color: Color {
        switch self {
        case .black: .black
        case .blue: .blue
        case .pink: .pink
        }
    }
}

private enum ShadowPreset: String, CaseIterable, Identifiable {
    case subtle = "Subtle"
    case card = "Card"
    case floating = "Floating"
    case glow = "Glow"

    var id: Self { self }

    func apply(to config: inout ShadowConfig) {
        switch self {
        case .subtle: config = ShadowConfig(color: .black, opacity: 0.1, radius: 4, x: 0, y: 2)
        case .card: config = ShadowConfig(color: .black, opacity: 0.2, radius: 16, x: 0, y: 8)
        case .floating: config = ShadowConfig(color: .black, opacity: 0.3, radius: 30, x: 0, y: 20)
        case .glow: config = ShadowConfig(color: .blue, opacity: 0.7, radius: 24, x: 0, y: 0)
        }
    }
}

private struct ShadowDemo: View {
    let page: ComponentPage

    var body: some View {
        DemoPage(
            page: page,
            initial: ShadowConfig(),
            previewHeight: 280,
            usage: """
            Text("Balance: $2,480")
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.background)
                        .shadow(color: .black.opacity(0.15), radius: 12, y: 6)
                }
            """,
            usageNote: Aside(.note, "`x` and `y` move the shadow and `radius` blurs it. There is no spread setting like in CSS.")
        ) { $config in
            VStack(alignment: .leading, spacing: 6) {
                Image(systemName: "creditcard.fill")
                    .font(.title)
                    .foregroundStyle(.tint)
                Spacer()
                Text("Balance")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text("$2,480.00")
                    .font(.title2.bold())
            }
            .padding(20)
            .frame(width: 220, height: 150, alignment: .leading)
            .background(.background.secondary, in: .rect(cornerRadius: 20))
            .shadow(color: config.color.color.opacity(config.opacity), radius: config.radius, x: config.x, y: config.y)
            .animation(.snappy, value: config.radius)
            .animation(.snappy, value: config.x)
            .animation(.snappy, value: config.y)
            .animation(.snappy, value: config.opacity)
        } controls: { $config in
            Section("Shadow") {
                OptionPicker("Color", selection: $config.color)
                ValueSlider("Opacity", value: $config.opacity, in: 0...1)
                ValueSlider("Radius (blur)", value: $config.radius, in: 0...50, step: 1)
                ValueSlider("x", value: $config.x, in: -30...30, step: 1)
                ValueSlider("y", value: $config.y, in: -30...30, step: 1)
            }
            Section("Presets") {
                ForEach(ShadowPreset.allCases) { preset in
                    Button(preset.rawValue) {
                        withAnimation { preset.apply(to: &config) }
                    }
                }
            }
        } code: { config in
            """
            VStack(alignment: .leading, spacing: 6) {
                Image(systemName: "creditcard.fill")
                    .font(.title)
                    .foregroundStyle(.tint)
                Spacer()
                Text("Balance")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text("$2,480.00")
                    .font(.title2.bold())
            }
            .padding(20)
            .frame(width: 220, height: 150, alignment: .leading)
            .background(.background.secondary, in: .rect(cornerRadius: 20))
            .shadow(color: \(config.color.label).opacity(\(swiftNumber(config.opacity))), radius: \(swiftNumber(config.radius)), x: \(swiftNumber(config.x)), y: \(swiftNumber(config.y)))
            """
        } examples: {
            ExampleCard(
                title: "Shadow on every child",
                caption: "Put `.shadow` on a background shape so only the card casts one, not each piece of text.",
                code: """
                // Every text gets a shadow
                VStack {
                    Text("Title").font(.headline)
                    Text("Subtitle")
                }
                .shadow(radius: 4)

                // Only the card gets a shadow
                VStack {
                    Text("Title").font(.headline)
                    Text("Subtitle")
                }
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.background.secondary)
                        .shadow(radius: 4)
                }
                """,
                aside: Aside(.important, "A shadow on a container with no background is applied to every child separately, so each line of text gets its own shadow.")
            ) {
                HStack(spacing: 32) {
                    VStack {
                        Text("Title").font(.headline)
                        Text("Subtitle")
                    }
                    .shadow(radius: 4)

                    VStack {
                        Text("Title").font(.headline)
                        Text("Subtitle")
                    }
                    .padding()
                    .background {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.background.secondary)
                            .shadow(radius: 4)
                    }
                }
            }

            ExampleCard(
                title: "Readable text on a busy image",
                caption: "Use a tight, dark `.shadow` to help white text stand out on a bright photo.",
                code: """
                ZStack {
                    LinearGradient(colors: [.yellow, .orange, .pink], startPoint: .top, endPoint: .bottom)
                        .clipShape(.rect(cornerRadius: 12))
                    Text("Golden hour")
                        .font(.largeTitle.bold())
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.5), radius: 3, y: 2)
                }
                .frame(height: 120)
                """
            ) {
                ZStack {
                    LinearGradient(colors: [.yellow, .orange, .pink], startPoint: .top, endPoint: .bottom)
                        .clipShape(.rect(cornerRadius: 12))
                    Text("Golden hour")
                        .font(.largeTitle.bold())
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.5), radius: 3, y: 2)
                }
                .frame(height: 120)
            }

            ExampleCard(
                title: "Colored glow",
                caption: "Give `.shadow` the view's own color and no offset, and it reads as a glow.",
                code: """
                Circle()
                    .fill(.purple)
                    .frame(width: 60, height: 60)
                    .shadow(color: .purple.opacity(0.8), radius: 20)
                """
            ) {
                Circle()
                    .fill(.purple)
                    .frame(width: 60, height: 60)
                    .shadow(color: .purple.opacity(0.8), radius: 20)
            }
        }
    }
}
