import SwiftUI

/// A soft, slowly shifting wallpaper: blurred-looking color fields, like
/// out-of-focus petals, with a little film grain. Drawn with a
/// `MeshGradient`, so it's sharp at any size and cheap to draw.
///
/// The seed picks the colors and the shape, within a palette for the tab:
/// blue, lavender, and pink for Components; peach, coral, and gold for
/// Design; sky, teal, and mint for Ship. The same seed always gives the
/// same wallpaper. It has a bright light version and a deeper dark one, and
/// holds still with Reduce Motion on.
///
/// It stays cheap while things scroll over it: the drift is one repeating
/// animation of the mesh points rather than a per-frame timeline, and the
/// grain is a single image drawn once.
struct Wallpaper: View {
    let seed: String
    let tab: AppTab

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var drifted = false

    var body: some View {
        let style = WallpaperStyle(seed: seed, tab: tab, dark: colorScheme == .dark)
        MeshGradient(
            width: 4,
            height: 4,
            points: drifted ? style.driftedPoints : style.points,
            colors: style.colors,
            smoothsColors: true
        )
        .overlay {
            Image(uiImage: WallpaperGrain.image)
                .resizable(resizingMode: .tile)
                .blendMode(.overlay)
                .opacity(colorScheme == .dark ? 0.35 : 0.5)
        }
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(.easeInOut(duration: style.duration).repeatForever(autoreverses: true)) {
                drifted = true
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

/// A page's wallpaper, behind its title. It fades into the page at the
/// bottom, and away as the page scrolls.
struct PageWallpaper: View {
    let page: ComponentPage
    /// 0 at the top of the page, 1 once it's scrolled away.
    var fade: CGFloat = 0

    var body: some View {
        Wallpaper(seed: page.id, tab: page.category.tab)
            .mask(WallpaperFade())
            .opacity(1 - fade)
    }
}

/// Solid at the top, fading out toward the bottom.
struct WallpaperFade: View {
    var body: some View {
        LinearGradient(stops: [
            .init(color: .black, location: 0),
            .init(color: .black, location: 0.4),
            .init(color: .black.opacity(0), location: 1),
        ], startPoint: .top, endPoint: .bottom)
    }
}

/// The colors and shape for one wallpaper.
struct WallpaperStyle {
    let colors: [Color]
    let points: [SIMD2<Float>]
    let driftedPoints: [SIMD2<Float>]
    /// Seconds for one drift, there or back.
    let duration: Double

    init(seed: String, tab: AppTab, dark: Bool) {
        var random = SeededRandom(seed)
        let hues = WallpaperStyle.hues(for: tab)
        // Pick three neighbors from the palette for this wallpaper, so pages
        // share a family but each leans its own way.
        let picks = (0..<3).map { _ in hues[Int(random.next() * Double(hues.count)) % hues.count] }
        colors = (0..<16).map { _ in
            let hue = picks[Int(random.next() * 3) % 3] + (random.next() - 0.5) * 0.04
            let wrapped = hue - floor(hue)
            return dark
                ? Color(hue: wrapped, saturation: 0.55 + random.next() * 0.25, brightness: 0.42 + random.next() * 0.28)
                : Color(hue: wrapped, saturation: 0.22 + random.next() * 0.26, brightness: 0.93 + random.next() * 0.07)
        }
        // A 4×4 grid. Edge points stay on their edges so the mesh always
        // fills the frame; inner points sit off-center and drift.
        var resting: [SIMD2<Float>] = []
        var moved: [SIMD2<Float>] = []
        for row in 0..<4 {
            for column in 0..<4 {
                var x = Float(column) / 3
                var y = Float(row) / 3
                let innerX = column > 0 && column < 3
                let innerY = row > 0 && row < 3
                if innerX { x += Float(random.next() - 0.5) * 0.22 }
                if innerY { y += Float(random.next() - 0.5) * 0.22 }
                resting.append(SIMD2(x, y))
                moved.append(SIMD2(
                    innerX ? x + Float(random.next() - 0.5) * 0.2 : x,
                    innerY ? y + Float(random.next() - 0.5) * 0.2 : y
                ))
            }
        }
        points = resting
        driftedPoints = moved
        duration = 9 + random.next() * 6
    }

    /// Hues each tab draws from, from 0 to 1 around the color wheel.
    private static func hues(for tab: AppTab) -> [Double] {
        switch tab {
        case .design: [0.02, 0.06, 0.1, 0.95, 0.9]       // coral, peach, gold, pink, rose
        case .ship: [0.5, 0.54, 0.58, 0.44, 0.62]        // teal, sky, blue, mint, cornflower
        default: [0.6, 0.66, 0.72, 0.8, 0.88]            // blue, periwinkle, lavender, violet, pink
        }
    }
}

/// A tile of fine noise, made once and repeated across every wallpaper.
enum WallpaperGrain {
    @MainActor static let image: UIImage = {
        let size = 96
        var random = SeededRandom("grain")
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: size, height: size))
        return renderer.image { context in
            for y in 0..<size {
                for x in 0..<size {
                    let value = random.next()
                    UIColor(white: value, alpha: 0.5).setFill()
                    context.fill(CGRect(x: x, y: y, width: 1, height: 1))
                }
            }
        }
    }()
}

/// A small, stable random generator (SplitMix64) seeded from a string, so
/// a wallpaper is the same on every launch. Swift's `hashValue` changes
/// between launches, so it can't be used here.
struct SeededRandom {
    private var state: UInt64

    init(_ seed: String) {
        // FNV-1a over the UTF-8 bytes.
        var hash: UInt64 = 0xcbf2_9ce4_8422_2325
        for byte in seed.utf8 {
            hash = (hash ^ UInt64(byte)) &* 0x100_0000_01b3
        }
        state = hash
    }

    /// A number from 0 up to 1.
    mutating func next() -> Double {
        state &+= 0x9e37_79b9_7f4a_7c15
        var z = state
        z = (z ^ (z >> 30)) &* 0xbf58_476d_1ce4_e5b9
        z = (z ^ (z >> 27)) &* 0x94d0_49bb_1331_11eb
        z ^= z >> 31
        return Double(z >> 11) / Double(1 << 53)
    }
}
