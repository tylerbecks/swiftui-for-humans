import SwiftUI

/// A soft, slowly shifting wallpaper: blurred-looking color fields, like
/// out-of-focus petals, with a little film grain. Drawn with a
/// `MeshGradient`, so it's sharp at any size and cheap to draw.
///
/// The seed picks the colors and the shape, within a palette for the tab:
/// blue, lavender, and pink for Build; peach, coral, and gold for
/// Design; sky, teal, and mint for Ship. The same seed always gives the
/// same wallpaper. It has a bright light version and a deeper dark one, and
/// holds still with Reduce Motion on.
///
/// It stays cheap while things scroll over it: the drift follows the clock
/// through one `TimelineView` at 30 frames a second, which pauses when the
/// wallpaper is off screen or `isPaused`, and the grain is a single image
/// drawn once.
struct Wallpaper: View {
    let seed: String
    let tab: AppTab
    /// Stops the drift, for example once the wallpaper has scrolled away.
    var isPaused = false

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isOnScreen = false

    var body: some View {
        let dark = colorScheme == .dark
        let mesh = WallpaperStyle(seed: seed, tab: tab, dark: dark)
        let ribbons = RibbonStyle(seed: seed, tab: tab, dark: dark)
        // The drift follows the clock rather than a repeating animation, so
        // every wallpaper moves, and picks up again after any pause.
        TimelineView(.animation(minimumInterval: 1 / 30, paused: reduceMotion || isPaused || !isOnScreen)) { context in
            let time = reduceMotion ? 0 : context.date.timeIntervalSinceReferenceDate
            switch WallpaperLook.current {
            case .ribbons:
                RibbonCanvas(style: ribbons, sway: Wallpaper.sway(time, duration: ribbons.duration))
            case .mesh:
                MeshGradient(
                    width: 4,
                    height: 4,
                    points: mesh.points(sway: Wallpaper.sway(time, duration: mesh.duration)),
                    colors: mesh.colors,
                    smoothsColors: true
                )
            }
        }
        .overlay {
            Image(decorative: WallpaperGrain.image, scale: 1)
                .interpolation(.none)
                .resizable(resizingMode: .tile)
                .blendMode(.overlay)
                .opacity(dark ? 0.3 : 0.4)
        }
        .onAppear { isOnScreen = true }
        .onDisappear { isOnScreen = false }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    /// Eases from 0 to 1 over `duration` seconds and back, forever.
    static func sway(_ time: TimeInterval, duration: Double) -> CGFloat {
        CGFloat((1 - cos(time / duration * .pi)) / 2)
    }
}

/// A soft band of the background color behind a large title and the text
/// under it, so they stay readable over a busy wallpaper (the HIG's advice
/// for text over imagery). It's clear above the title, so the wallpaper
/// stays bright under the bar, and feathered so there's no visible edge.
struct TextScrim: View {
    /// Where the large title ends, from the top of this view.
    let titleBottom: CGFloat
    let color: Color

    var body: some View {
        GeometryReader { proxy in
            LinearGradient(stops: stops(height: max(proxy.size.height, 1)), startPoint: .top, endPoint: .bottom)
        }
    }

    private func stops(height: CGFloat) -> [Gradient.Stop] {
        func at(_ y: CGFloat) -> CGFloat { min(max(y / height, 0), 1) }
        return [
            .init(color: color.opacity(0), location: at(titleBottom - 110)),
            .init(color: color.opacity(0.5), location: at(titleBottom - 45)),
            .init(color: color.opacity(0.6), location: at(titleBottom + 90)),
            .init(color: color.opacity(0.6), location: 1),
        ]
    }
}

/// Solid at the top, fading out toward the bottom.
struct WallpaperFade: View {
    var body: some View {
        LinearGradient(stops: [
            .init(color: .black, location: 0),
            .init(color: .black, location: 0.3),
            .init(color: .black.opacity(0), location: 0.85),
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

    /// The mesh partway between its resting and drifted shapes.
    func points(sway: CGFloat) -> [SIMD2<Float>] {
        zip(points, driftedPoints).map { a, b in a + (b - a) * Float(sway) }
    }

    /// Hues each tab draws from, from 0 to 1 around the color wheel.
    static func hues(for tab: AppTab) -> [Double] {
        switch tab {
        case .design: [0.02, 0.06, 0.1, 0.95, 0.9]       // coral, peach, gold, pink, rose
        case .ship: [0.5, 0.54, 0.58, 0.44, 0.62]        // teal, sky, blue, mint, cornflower
        default: [0.6, 0.66, 0.72, 0.8, 0.88]            // blue, periwinkle, lavender, violet, pink
        }
    }
}

/// Which wallpaper the app draws. Launch with `-wallpaper mesh` or
/// `-wallpaper ribbons` to compare them.
enum WallpaperLook {
    case mesh, ribbons

    static let current: WallpaperLook = LaunchOptions.value(for: "-wallpaper") == "mesh" ? .mesh : .ribbons
}

/// A calm color wash crossed by a few sweeping ribbons of light, in the
/// spirit of Apple's colorful desktop wallpapers but drawn from scratch.
/// Each ribbon is a curve stroked three times, wide and faint, then
/// narrower, then a thin bright core, which reads as a glow without the
/// cost of a blur.
struct RibbonStyle {
    struct Line {
        let curve: Ribbon.Curve
        let glow: Color
        let core: Color
    }

    let background: [Color]
    let lines: [Line]
    let dark: Bool
    /// Seconds for one sway, there or back.
    let duration: Double

    init(seed: String, tab: AppTab, dark: Bool) {
        var random = SeededRandom(seed + "ribbons")
        let hues = WallpaperStyle.hues(for: tab)
        let hue = hues[Int(random.next() * Double(hues.count)) % hues.count]
        let accent = hues[Int(random.next() * Double(hues.count)) % hues.count]
        background = dark
            ? [Color(hue: hue, saturation: 0.85, brightness: 0.32), Color(hue: accent, saturation: 0.9, brightness: 0.16)]
            : [Color(hue: hue, saturation: 0.1, brightness: 1), Color(hue: accent, saturation: 0.32, brightness: 0.98)]
        lines = (0..<6).map { index in
            let curve = Ribbon.Curve(random: &random, index: index)
            let ribbonHue = index.isMultiple(of: 2) ? hue : accent
            return Line(
                curve: curve,
                glow: Color(hue: ribbonHue, saturation: dark ? 0.75 : 0.55, brightness: 1),
                core: dark ? Color(hue: ribbonHue, saturation: 0.3, brightness: 1) : .white
            )
        }
        self.dark = dark
        duration = 10 + random.next() * 6
    }
}

/// Draws a ribbon wallpaper at one moment of its sway.
struct RibbonCanvas: View {
    let style: RibbonStyle
    let sway: CGFloat

    var body: some View {
        Canvas { context, size in
            let rect = CGRect(origin: .zero, size: size)
            context.fill(Path(rect), with: .linearGradient(
                Gradient(colors: style.background),
                startPoint: .zero,
                endPoint: CGPoint(x: size.width, y: size.height)
            ))
            let dark = style.dark
            for line in style.lines {
                let path = Ribbon(curve: line.curve, sway: sway).path(in: rect)
                let width = line.curve.width
                context.stroke(path, with: .color(line.glow.opacity(dark ? 0.16 : 0.22)), style: StrokeStyle(lineWidth: width * 9, lineCap: .round))
                context.stroke(path, with: .color(line.glow.opacity(dark ? 0.28 : 0.4)), style: StrokeStyle(lineWidth: width * 3, lineCap: .round))
                context.stroke(path, with: .color(line.core.opacity(dark ? 0.7 : 0.95)), style: StrokeStyle(lineWidth: width, lineCap: .round))
            }
        }
    }
}

/// One sweeping ribbon: a curve from off the left edge to off the right,
/// bowed by two control points that sway between two positions.
struct Ribbon: Shape {
    struct Curve {
        var start: CGPoint
        var end: CGPoint
        var control1: CGPoint
        var control2: CGPoint
        var swayed1: CGPoint
        var swayed2: CGPoint
        var width: CGFloat

        init(random: inout SeededRandom, index: Int) {
            // Twelve draws up front; a closure can't capture an inout value.
            var draws = (0..<12).map { _ in CGFloat(random.next()) }
            func r() -> CGFloat { draws.removeFirst() }
            // Ribbons enter and leave at different heights, crossing the
            // frame in long, shallow arcs. Points are in unit space.
            // They stay in the upper part, behind the title, and clear of
            // the text below it.
            start = CGPoint(x: -0.2, y: 0.05 + r() * 0.6)
            end = CGPoint(x: 1.2, y: -0.1 + r() * 0.6)
            control1 = CGPoint(x: 0.2 + r() * 0.3, y: -0.4 + r() * 1.2)
            control2 = CGPoint(x: 0.55 + r() * 0.3, y: -0.4 + r() * 1.2)
            swayed1 = CGPoint(x: control1.x + (r() - 0.5) * 0.25, y: control1.y + (r() - 0.5) * 0.5)
            swayed2 = CGPoint(x: control2.x + (r() - 0.5) * 0.25, y: control2.y + (r() - 0.5) * 0.5)
            width = 1.2 + r() * 1.8
        }
    }

    let curve: Curve
    var sway: CGFloat

    var animatableData: CGFloat {
        get { sway }
        set { sway = newValue }
    }

    func path(in rect: CGRect) -> Path {
        func point(_ unit: CGPoint) -> CGPoint {
            CGPoint(x: rect.minX + unit.x * rect.width, y: rect.minY + unit.y * rect.height)
        }
        func mix(_ a: CGPoint, _ b: CGPoint) -> CGPoint {
            CGPoint(x: a.x + (b.x - a.x) * sway, y: a.y + (b.y - a.y) * sway)
        }
        var path = Path()
        path.move(to: point(curve.start))
        path.addCurve(
            to: point(curve.end),
            control1: point(mix(curve.control1, curve.swayed1)),
            control2: point(mix(curve.control2, curve.swayed2))
        )
        return path
    }
}

/// A tile of fine noise, made once and repeated across every wallpaper:
/// one gray value per point, drawn with Core Graphics so it's the same on
/// every platform.
enum WallpaperGrain {
    @MainActor static let image: CGImage = {
        let size = 96
        var random = SeededRandom("grain")
        let context = CGContext(
            data: nil,
            width: size,
            height: size,
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: CGColorSpaceCreateDeviceGray(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        )!
        for y in 0..<size {
            for x in 0..<size {
                context.setFillColor(CGColor(gray: random.next(), alpha: 0.5))
                context.fill(CGRect(x: x, y: y, width: 1, height: 1))
            }
        }
        return context.makeImage()!
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
