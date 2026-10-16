import SwiftUI

/// Photo-like scenes for previews that need something behind them: glass,
/// materials, scrims, and the Image page. Each is drawn in SwiftUI and
/// rendered once to a bitmap with `ImageRenderer`, so it behaves exactly like
/// a real photo (`resizable`, `scaledToFill`, ...), works offline, never
/// changes between launches, and is ours: no stock or Apple photos, so no
/// copyright questions.
///
/// Each scene is picked for what it tests:
/// - `lake`: a sunset over mountains and water. Colorful and mid-toned; the
///   everyday case.
/// - `city`: a city at night. Dark, with bright lights and fine detail for
///   glass to bend.
/// - `meadow`: a bright summer day. Pale and light, the hardest case for
///   legibility, for Do / Don't pairs about contrast.
/// - `wallpaper`: soft color fields, like a Lock Screen wallpaper.
enum Scenery: String, CaseIterable, Identifiable {
    case lake, city, meadow, wallpaper

    var id: Self { self }

    var label: String {
        switch self {
        case .lake: "Sunset photo"
        case .city: "Night photo"
        case .meadow: "Bright photo"
        case .wallpaper: "Wallpaper"
        }
    }

    /// The scene as an image, rendered on first use.
    @MainActor var image: Image {
        if let image = Self.cache[self] { return image }
        let renderer = ImageRenderer(content: art.frame(width: Self.size.width, height: Self.size.height))
        renderer.scale = 4
        let image = renderer.cgImage.map { Image(decorative: $0, scale: 4) } ?? Image(systemName: "photo")
        Self.cache[self] = image
        return image
    }

    /// Scenes are drawn in a 300×200 space (3:2, like a photo).
    static let size = CGSize(width: 300, height: 200)

    @MainActor private static var cache: [Scenery: Image] = [:]

    @ViewBuilder @MainActor private var art: some View {
        switch self {
        case .lake: LakeScene()
        case .city: CityScene()
        case .meadow: MeadowScene()
        case .wallpaper: WallpaperScene()
        }
    }
}

/// A scene that fills its frame like a photo: `.resizable().scaledToFill()`,
/// clipped.
struct SceneryView: View {
    let scenery: Scenery

    init(_ scenery: Scenery) {
        self.scenery = scenery
    }

    var body: some View {
        Color.clear
            .overlay {
                scenery.image
                    .resizable()
                    .scaledToFill()
            }
            .clipped()
            .accessibilityHidden(true)
    }
}

// MARK: - Scenes

/// Sky, sun, two mountain ranges, and a lake with the sun's reflection.
private struct LakeScene: View {
    var body: some View {
        ZStack(alignment: .topLeading) {
            LinearGradient(
                stops: [
                    .init(color: Color(hex: 0x3B5BA9), location: 0),
                    .init(color: Color(hex: 0xE57A7A), location: 0.39),
                    .init(color: Color(hex: 0xFFC07A), location: 0.65),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            Circle()
                .fill(Color(hex: 0xFFE7A8))
                .frame(width: 50, height: 50)
                .offset(x: 190, y: 62)
            Ridge(points: [(0, 130), (0, 105), (55, 70), (110, 110), (165, 80), (230, 118), (300, 92), (300, 130)])
                .fill(Color(hex: 0x6B4E8C))
            Ridge(points: [(0, 140), (0, 122), (80, 100), (150, 128), (210, 112), (300, 130), (300, 140)])
                .fill(Color(hex: 0x2F3D6B))
            LinearGradient(colors: [Color(hex: 0x2A3560), Color(hex: 0x1B2340)], startPoint: .top, endPoint: .bottom)
                .frame(width: 300, height: 64)
                .offset(y: 136)
            ForEach(Array([36.0, 26, 16, 8].enumerated()), id: \.offset) { index, width in
                Rectangle()
                    .fill(Color(hex: 0xFFC07A).opacity(0.6))
                    .frame(width: width, height: 2.5)
                    .offset(x: 215 - width / 2, y: 146 + Double(index) * 9)
            }
        }
        .frame(width: 300, height: 200, alignment: .topLeading)
    }
}

/// A skyline at night with lit windows, a moon, and a river reflecting it.
private struct CityScene: View {
    /// (x, width, height) of each building, back row then front row.
    private static let back: [(Double, Double, Double)] = [
        (0, 34, 92), (30, 26, 120), (52, 40, 84), (88, 22, 132), (106, 36, 100),
        (138, 30, 146), (164, 42, 90), (202, 24, 124), (222, 38, 106), (256, 28, 138), (280, 20, 96),
    ]
    private static let front: [(Double, Double, Double)] = [
        (-4, 46, 70), (40, 30, 96), (68, 52, 62), (118, 34, 110), (150, 48, 76),
        (196, 30, 100), (224, 44, 68), (266, 38, 88),
    ]
    private static let horizon = 160.0

    var body: some View {
        ZStack(alignment: .topLeading) {
            LinearGradient(
                stops: [
                    .init(color: Color(hex: 0x0B1030), location: 0),
                    .init(color: Color(hex: 0x2A1B4D), location: 0.55),
                    .init(color: Color(hex: 0x7A3C6A), location: 0.8),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            ForEach(0..<24, id: \.self) { index in
                Circle()
                    .fill(.white.opacity(0.35 + 0.4 * Self.noise(index, 1)))
                    .frame(width: 1.2, height: 1.2)
                    .offset(x: 300 * Self.noise(index, 2), y: 70 * Self.noise(index, 3))
            }
            Circle()
                .fill(Color(hex: 0xF4EBD0))
                .frame(width: 22, height: 22)
                .shadow(color: Color(hex: 0xF4EBD0).opacity(0.6), radius: 10)
                .offset(x: 46, y: 26)
            ForEach(Array(Self.back.enumerated()), id: \.offset) { index, building in
                Building(width: building.1, height: building.2, color: Color(hex: 0x1F1A3D), seed: index, lit: 0.25)
                    .offset(x: building.0, y: Self.horizon - building.2)
            }
            ForEach(Array(Self.front.enumerated()), id: \.offset) { index, building in
                Building(width: building.1, height: building.2, color: Color(hex: 0x110E22), seed: index + 50, lit: 0.45)
                    .offset(x: building.0, y: Self.horizon - building.2)
            }
            LinearGradient(colors: [Color(hex: 0x1A1438), Color(hex: 0x07060F)], startPoint: .top, endPoint: .bottom)
                .frame(width: 300, height: 40)
                .offset(y: Self.horizon)
            ForEach(0..<18, id: \.self) { index in
                Capsule()
                    .fill((index.isMultiple(of: 3) ? Color(hex: 0x9BD3FF) : Color(hex: 0xFFC56E)).opacity(0.55))
                    .frame(width: 6 + 14 * Self.noise(index, 4), height: 1.5)
                    .offset(x: 300 * Self.noise(index, 5), y: Self.horizon + 4 + 34 * Self.noise(index, 6))
            }
        }
        .frame(width: 300, height: 200, alignment: .topLeading)
        .clipped()
    }

    /// A repeatable value from 0 to 1, so the scene is the same every time.
    static func noise(_ index: Int, _ salt: Int) -> Double {
        let value = sin(Double(index * 127 + salt * 311) * 12.9898) * 43758.5453
        return value - value.rounded(.down)
    }
}

private struct Building: View {
    let width: Double
    let height: Double
    let color: Color
    let seed: Int
    /// The share of windows with lights on.
    let lit: Double

    var body: some View {
        let columns = max(1, Int(width / 7))
        let rows = max(1, Int(height / 9))
        ZStack(alignment: .topLeading) {
            Rectangle().fill(color)
            ForEach(0..<(columns * rows), id: \.self) { index in
                let isOn = CityScene.noise(index + seed * 97, seed) < lit
                if isOn {
                    Rectangle()
                        .fill(CityScene.noise(index, seed + 7) < 0.8 ? Color(hex: 0xFFD27A) : Color(hex: 0x9BD3FF))
                        .frame(width: 2.5, height: 3.5)
                        .offset(x: 3 + Double(index % columns) * 7, y: 5 + Double(index / columns) * 9)
                }
            }
        }
        .frame(width: width, height: height, alignment: .topLeading)
    }
}

/// A bright summer day: pale sky, clouds, light hills, and flowers.
private struct MeadowScene: View {
    var body: some View {
        ZStack(alignment: .topLeading) {
            LinearGradient(colors: [Color(hex: 0xA9D8FF), Color(hex: 0xEEF8FF)], startPoint: .top, endPoint: .bottom)
            RadialGradient(colors: [.white, .white.opacity(0)], center: .init(x: 0.82, y: 0.12), startRadius: 4, endRadius: 90)
            ForEach(Array([(40.0, 34.0, 1.0), (150, 20, 0.8), (226, 52, 0.9)].enumerated()), id: \.offset) { _, cloud in
                Cloud()
                    .fill(.white)
                    .frame(width: 70 * cloud.2, height: 22 * cloud.2)
                    .offset(x: cloud.0, y: cloud.1)
            }
            Ridge(points: [(0, 140), (0, 112), (70, 96), (150, 116), (230, 92), (300, 108), (300, 140)])
                .fill(Color(hex: 0xB5DE84))
            Ridge(points: [(0, 200), (0, 128), (90, 118), (180, 136), (300, 122), (300, 200)])
                .fill(LinearGradient(colors: [Color(hex: 0xCDEB9E), Color(hex: 0xE4F4C4)], startPoint: .top, endPoint: .bottom))
            ForEach(0..<40, id: \.self) { index in
                Circle()
                    .fill(index.isMultiple(of: 3) ? Color.white : Color(hex: 0xFFE066))
                    .frame(width: 3, height: 3)
                    .offset(x: 300 * CityScene.noise(index, 8), y: 140 + 56 * CityScene.noise(index, 9))
            }
        }
        .frame(width: 300, height: 200, alignment: .topLeading)
        .clipped()
    }
}

/// Soft, saturated color fields, like a Lock Screen wallpaper.
private struct WallpaperScene: View {
    var body: some View {
        MeshGradient(
            width: 3,
            height: 3,
            points: [
                [0, 0], [0.5, 0], [1, 0],
                [0, 0.5], [0.62, 0.42], [1, 0.5],
                [0, 1], [0.4, 1], [1, 1],
            ],
            colors: [
                Color(hex: 0x3A1C71), Color(hex: 0x6A3093), Color(hex: 0xD76D77),
                Color(hex: 0x1E5BB8), Color(hex: 0xE0457B), Color(hex: 0xFFAF7B),
                Color(hex: 0x0FA3B1), Color(hex: 0x5ED6A0), Color(hex: 0xFFD56B),
            ]
        )
    }
}

/// A closed polygon through points given in the 300×200 scene's coordinates.
private struct Ridge: Shape {
    let points: [(Double, Double)]

    func path(in rect: CGRect) -> Path {
        Path { path in
            path.addLines(points.map { CGPoint(x: $0.0, y: $0.1) })
            path.closeSubpath()
        }
    }
}

/// Three overlapping puffs on a flat base.
private struct Cloud: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let h = rect.height
        path.addEllipse(in: CGRect(x: rect.minX, y: rect.minY + h * 0.35, width: rect.width * 0.45, height: h * 0.65))
        path.addEllipse(in: CGRect(x: rect.minX + rect.width * 0.22, y: rect.minY, width: rect.width * 0.45, height: h))
        path.addEllipse(in: CGRect(x: rect.minX + rect.width * 0.5, y: rect.minY + h * 0.25, width: rect.width * 0.5, height: h * 0.75))
        return path
    }
}

extension Color {
    /// A color from a hex value such as `0x3B5BA9`.
    init(hex: UInt32) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255
        )
    }
}
