import SwiftUI

extension ComponentPage {
    static let gradients = ComponentPage(
        id: "gradients",
        title: "Gradients",
        summary: "Smooth blends between colors: in a line, outward from a point, around a circle, or across a mesh.",
        category: .graphics,
        symbol: "circle.lefthalf.filled.righthalf.striped.horizontal",
        availability: ["iOS 13.0+", "macOS 10.15+", "visionOS 1.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/gradient",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/color",
        aliases: ["linear-gradient", "radial-gradient", "conic-gradient", "background-image", "mesh", "fade", "ombre", "CAGradientLayer"],
        related: ["system-colors", "shapes", "foreground-style", "materials"],
        notes: [
            "**Gradients are `ShapeStyle`s, like colors.** Pass one to `.fill`, `.background`, or `.foregroundStyle` to paint shapes, views, or text.",
            "**They map to CSS.** `LinearGradient` is `linear-gradient`, `RadialGradient` is `radial-gradient`, and `AngularGradient` is `conic-gradient`.",
            "**`MeshGradient` needs iOS 18.** It blends a grid of colors; animate its points with `TimelineView` for a living background.",
        ],
        api: [
            APIItem("`Color.blue.gradient`", "A subtle gradient the system tunes for you."),
            APIItem("`LinearGradient`", "Blends colors along a line between two points."),
            APIItem("`RadialGradient`", "Blends outward from a center point."),
            APIItem("`AngularGradient`", "Blends around a center, like a color wheel."),
            APIItem("`MeshGradient`", "Blends a grid of colors (iOS 18)."),
            APIItem("`Gradient.Stop(color:location:)`", "Places a color at an exact spot, from 0 to 1."),
        ],
        guidelines: [
            Guideline(
                "Keep text readable on gradients.",
                "Check contrast at the lightest part of the gradient, not the middle. Add a dark fade or pick deeper colors where text sits.",
                good: "Deep colors keep white text clear.",
                bad: "White text fades into the light end."
            ) {
                GradientBanner(colors: [.indigo, .purple])
            } bad: {
                GradientBanner(colors: [.yellow, .mint])
            },
            Guideline(
                "Check gradients in dark mode.",
                "System colors shift between modes, and a gradient that glows on white can feel harsh on black."
            ),
            Guideline(
                "Don't use a gradient as the only signal.",
                "A green-to-red bar needs a number or a label too, since some people can't tell those colors apart."
            ),
        ]
    ) {
        GradientsThumbnail()
    } content: { page in
        GradientsDemo(page: page)
    }
}

// MARK: - Options

private enum GradientKind: DemoOption {
    case linear, radial, angular, mesh, shorthand

    var label: String {
        switch self {
        case .linear: "LinearGradient"
        case .radial: "RadialGradient"
        case .angular: "AngularGradient"
        case .mesh: "MeshGradient"
        case .shorthand: ".gradient shorthand"
        }
    }
}

private enum Palette: DemoOption {
    case sunset, ocean, forest, candy

    var label: String {
        switch self {
        case .sunset: "Sunset"
        case .ocean: "Ocean"
        case .forest: "Forest"
        case .candy: "Candy"
        }
    }

    var colors: [Color] {
        switch self {
        case .sunset: [.orange, .pink, .purple]
        case .ocean: [.cyan, .blue, .indigo]
        case .forest: [.yellow, .green, .teal]
        case .candy: [.pink, .purple, .blue]
        }
    }

    var names: [String] {
        switch self {
        case .sunset: [".orange", ".pink", ".purple"]
        case .ocean: [".cyan", ".blue", ".indigo"]
        case .forest: [".yellow", ".green", ".teal"]
        case .candy: [".pink", ".purple", ".blue"]
        }
    }

    var meshColors: [Color] {
        let c = colors
        return [c[0], c[0], c[1],
                c[0], c[1], c[2],
                c[1], c[2], c[2]]
    }

    var meshNames: [String] {
        let n = names
        return [n[0], n[0], n[1],
                n[0], n[1], n[2],
                n[1], n[2], n[2]]
    }
}

private enum Direction: DemoOption {
    case topToBottom, leadingToTrailing, diagonal

    var label: String {
        switch self {
        case .topToBottom: "Top to bottom"
        case .leadingToTrailing: "Leading to trailing"
        case .diagonal: "Diagonal"
        }
    }

    var points: (UnitPoint, UnitPoint) {
        switch self {
        case .topToBottom: (.top, .bottom)
        case .leadingToTrailing: (.leading, .trailing)
        case .diagonal: (.topLeading, .bottomTrailing)
        }
    }

    var code: (String, String) {
        switch self {
        case .topToBottom: (".top", ".bottom")
        case .leadingToTrailing: (".leading", ".trailing")
        case .diagonal: (".topLeading", ".bottomTrailing")
        }
    }
}

private struct GradientsConfig {
    var kind: GradientKind = .linear
    var palette: Palette = .sunset
    var direction: Direction = .diagonal
    var radius = 160.0
    var animateMesh = true
}

// MARK: - Mesh

private func meshPoints(time: Double?) -> [SIMD2<Float>] {
    var center = SIMD2<Float>(0.5, 0.5)
    if let time {
        center = SIMD2(Float(0.5 + 0.25 * sin(time)), Float(0.5 + 0.25 * cos(time * 1.3)))
    }
    return [
        [0, 0], [0.5, 0], [1, 0],
        [0, 0.5], center, [1, 0.5],
        [0, 1], [0.5, 1], [1, 1],
    ]
}

private struct MeshFill: View {
    let palette: Palette
    let animate: Bool

    var body: some View {
        if animate {
            TimelineView(.animation) { context in
                let t = context.date.timeIntervalSinceReferenceDate
                MeshGradient(width: 3, height: 3, points: meshPoints(time: t), colors: palette.meshColors)
            }
        } else {
            MeshGradient(width: 3, height: 3, points: meshPoints(time: nil), colors: palette.meshColors)
        }
    }
}

// MARK: - Demo

private struct GradientsDemo: View {
    let page: ComponentPage

    var body: some View {
        DemoPage(
            page: page,
            initial: GradientsConfig(),
            usage: """
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        colors: [.orange, .pink, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(height: 220)
            """
        ) { $config in
            fill(config)
                .frame(height: 220)
                .frame(maxWidth: 420)
                .clipShape(.rect(cornerRadius: 24))
        } controls: { $config in
            Section("Gradient") {
                OptionPicker("Type", selection: $config.kind)
                OptionPicker("Colors", selection: $config.palette)
            }
            switch config.kind {
            case .linear:
                Section("Linear") {
                    OptionPicker("Direction", selection: $config.direction)
                }
            case .radial:
                Section("Radial") {
                    ValueSlider("End radius", value: $config.radius, in: 40...300, step: 10)
                }
            case .mesh:
                Section("Mesh") {
                    Toggle("Animate", isOn: $config.animateMesh)
                }
            case .angular, .shorthand:
                EmptyView()
            }
        } code: { config in
            code(config)
        } examples: {
            ExampleCard(
                title: "Fade for readable text",
                caption: "Lay a clear-to-black `LinearGradient` over a photo so white text reads on any image.",
                code: """
                Image("photo")
                    .resizable()
                    .scaledToFill()
                    .frame(height: 220)
                    .overlay {
                        LinearGradient(colors: [.clear, .black.opacity(0.7)],
                                       startPoint: .center, endPoint: .bottom)
                    }
                    .overlay(alignment: .bottomLeading) {
                        Text("Weekend Getaways")
                            .font(.title2.bold())
                            .foregroundStyle(.white)
                            .padding()
                    }
                    .clipShape(.rect(cornerRadius: 20))
                """,
                minHeight: 220,
                aside: Aside(.note, "Designers call this a scrim. Start it near the middle so the top of the photo stays bright.")
            ) {
                SceneryView(.meadow)
                    .frame(height: 220)
                    .frame(maxWidth: 360)
                    .overlay {
                        LinearGradient(colors: [.clear, .black.opacity(0.7)],
                                       startPoint: .center, endPoint: .bottom)
                    }
                    .overlay(alignment: .bottomLeading) {
                        Text("Weekend Getaways")
                            .font(.title2.bold())
                            .foregroundStyle(.white)
                            .padding()
                    }
                    .clipShape(.rect(cornerRadius: 20))
            }

            ExampleCard(
                title: "Icon tile with the shorthand",
                caption: "Use `Color.pink.gradient` for a quick, subtle gradient, like the icons in Settings.",
                code: """
                let icons: [(String, Color)] = [("heart.fill", .pink), ("bell.fill", .red), ("gearshape.fill", .gray)]

                HStack(spacing: 16) {
                    ForEach(icons, id: \\.0) { symbol, color in
                        Image(systemName: symbol)
                            .font(.title2)
                            .foregroundStyle(.white)
                            .frame(width: 56, height: 56)
                            .background(color.gradient, in: .rect(cornerRadius: 14))
                    }
                }
                """,
                minHeight: 120
            ) {
                HStack(spacing: 16) {
                    ForEach([("heart.fill", Color.pink), ("bell.fill", Color.red), ("gearshape.fill", Color.gray)], id: \.0) { symbol, color in
                        Image(systemName: symbol)
                            .font(.title2)
                            .foregroundStyle(.white)
                            .frame(width: 56, height: 56)
                            .background(color.gradient, in: .rect(cornerRadius: 14))
                    }
                }
            }

            ExampleCard(
                title: "Gradient text",
                caption: "Pass a gradient to `.foregroundStyle` to paint text and SF Symbols.",
                code: """
                Text("Hello, gradients")
                    .font(.largeTitle.bold())
                    .foregroundStyle(
                        LinearGradient(colors: [.orange, .pink, .purple],
                                       startPoint: .leading, endPoint: .trailing)
                    )
                """,
                minHeight: 120
            ) {
                Text("Hello, gradients")
                    .font(.largeTitle.bold())
                    .foregroundStyle(
                        LinearGradient(colors: [.orange, .pink, .purple],
                                       startPoint: .leading, endPoint: .trailing)
                    )
            }

            ExampleCard(
                title: "Hard stops",
                caption: "Put two `Gradient.Stop`s at the same location to get a sharp edge instead of a blend.",
                code: """
                Capsule()
                    .fill(LinearGradient(
                        stops: [
                            .init(color: .green, location: 0),
                            .init(color: .green, location: 0.6),
                            .init(color: .gray.opacity(0.3), location: 0.6),
                            .init(color: .gray.opacity(0.3), location: 1),
                        ],
                        startPoint: .leading, endPoint: .trailing
                    ))
                    .frame(height: 16)
                """,
                minHeight: 100
            ) {
                Capsule()
                    .fill(LinearGradient(
                        stops: [
                            .init(color: .green, location: 0),
                            .init(color: .green, location: 0.6),
                            .init(color: .gray.opacity(0.3), location: 0.6),
                            .init(color: .gray.opacity(0.3), location: 1),
                        ],
                        startPoint: .leading, endPoint: .trailing
                    ))
                    .frame(height: 16)
                    .frame(maxWidth: 300)
            }
        }
    }

    @ViewBuilder
    private func fill(_ config: GradientsConfig) -> some View {
        let colors = config.palette.colors
        switch config.kind {
        case .linear:
            let (start, end) = config.direction.points
            Rectangle().fill(LinearGradient(colors: colors, startPoint: start, endPoint: end))
        case .radial:
            Rectangle().fill(RadialGradient(colors: colors, center: .center, startRadius: 0, endRadius: config.radius))
        case .angular:
            Rectangle().fill(AngularGradient(colors: colors + [colors[0]], center: .center))
        case .mesh:
            MeshFill(palette: config.palette, animate: config.animateMesh)
        case .shorthand:
            Rectangle().fill(colors[1].gradient)
        }
    }

    private func code(_ config: GradientsConfig) -> String {
        let names = config.palette.names
        let list = "[" + names.joined(separator: ", ") + "]"
        let shape = "RoundedRectangle(cornerRadius: 24)"
        switch config.kind {
        case .linear:
            let (start, end) = config.direction.code
            return """
            \(shape)
                .fill(LinearGradient(colors: \(list),
                                     startPoint: \(start), endPoint: \(end)))
                .frame(height: 220)
            """
        case .radial:
            return """
            \(shape)
                .fill(RadialGradient(colors: \(list), center: .center,
                                     startRadius: 0, endRadius: \(swiftNumber(config.radius))))
                .frame(height: 220)
            """
        case .angular:
            let looped = "[" + (names + [names[0]]).joined(separator: ", ") + "]"
            return """
            // Repeat the first color at the end for a seamless loop.
            \(shape)
                .fill(AngularGradient(colors: \(looped), center: .center))
                .frame(height: 220)
            """
        case .shorthand:
            return """
            \(shape)
                .fill(Color\(names[1]).gradient)
                .frame(height: 220)
            """
        case .mesh:
            let m = config.palette.meshNames
            let center = config.animateMesh
                ? "[Float(0.5 + 0.25 * sin(t)), Float(0.5 + 0.25 * cos(t * 1.3))]"
                : "[0.5, 0.5]"
            let mesh = [
                "MeshGradient(",
                "    width: 3, height: 3,",
                "    points: [",
                "        [0, 0], [0.5, 0], [1, 0],",
                "        [0, 0.5], \(center), [1, 0.5],",
                "        [0, 1], [0.5, 1], [1, 1],",
                "    ],",
                "    colors: [",
                "        \(m[0...2].joined(separator: ", ")),",
                "        \(m[3...5].joined(separator: ", ")),",
                "        \(m[6...8].joined(separator: ", ")),",
                "    ]",
                ")",
            ]
            if config.animateMesh {
                return (["TimelineView(.animation) { context in",
                         "    let t = context.date.timeIntervalSinceReferenceDate"]
                        + mesh.map { "    " + $0 }
                        + ["}", ".frame(height: 220)", ".clipShape(.rect(cornerRadius: 24))"])
                    .joined(separator: "\n")
            }
            return (mesh + [".frame(height: 220)", ".clipShape(.rect(cornerRadius: 24))"])
                .joined(separator: "\n")
        }
    }
}

// MARK: - Guideline samples

private struct GradientBanner: View {
    let colors: [Color]

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Summer Sale")
                .font(.title3.bold())
            Text("Up to 40% off")
                .font(.subheadline)
        }
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            LinearGradient(colors: colors, startPoint: .leading, endPoint: .trailing),
            in: .rect(cornerRadius: 16)
        )
        .frame(maxWidth: 260)
    }
}

// MARK: - Thumbnail

private struct GradientsThumbnail: View {
    var body: some View {
        HStack(spacing: 10) {
            RoundedRectangle(cornerRadius: 14)
                .fill(LinearGradient(colors: Palette.sunset.colors, startPoint: .topLeading, endPoint: .bottomTrailing))
            Circle()
                .fill(AngularGradient(colors: Palette.candy.colors + [Palette.candy.colors[0]], center: .center))
                .frame(width: 56)
            MeshGradient(width: 3, height: 3, points: meshPoints(time: nil), colors: Palette.ocean.meshColors)
                .clipShape(.rect(cornerRadius: 14))
        }
        .frame(width: 190, height: 70)
    }
}
