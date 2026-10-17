import SwiftUI

/// The Components tab's hero: a masonry board of live component tiles,
/// like the website's, below the title. Columns drift slowly, alternating
/// up and down, and every so often one tile, picked at random, changes and
/// settles. Tapping a tile opens its page.
///
/// It's decoration on top of the grid below, which lists every page, so
/// VoiceOver skips it. With Reduce Motion on it holds still, and it stops
/// changing tiles while it's scrolled away or the app is in the background.
struct HeroBoard: View {
    let tiles: [HeroTile]

    @Environment(\.horizontalSizeClass) private var sizeClass
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.scenePhase) private var scenePhase
    @State private var changed: Set<HeroTile> = []
    @State private var isVisible = true
    @State private var start = Date.now

    /// Drifting, and changing tiles, only while someone can see it.
    private var isActive: Bool { isVisible && scenePhase == .active && !reduceMotion }

    /// Tiles are designed 240 points wide and shown smaller.
    private var scale: CGFloat { sizeClass == .compact ? 0.5 : 0.62 }
    private var columnCount: Int { sizeClass == .compact ? 5 : 9 }
    private var height: CGFloat { sizeClass == .compact ? 250 : 300 }
    static let gap: CGFloat = 10

    /// Tiles shown in the app. A NavigationStack or TabView inside a page
    /// takes over the app's own bars, so those tiles stay on the website.
    static let components: [HeroTile] = HeroTile.allCases.filter { ![.library, .tabs].contains($0) }

    var body: some View {
        // The board is exactly `height` tall; the columns overflow it and
        // are clipped, so they never change the layout around it.
        Color.clear
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .overlay(alignment: .top) {
                // Driven frame by frame rather than by a repeating animation,
                // so a tile is where it's drawn and taps land on it.
                TimelineView(.animation(minimumInterval: 1 / 30, paused: !isActive)) { context in
                    let elapsed = reduceMotion ? 0 : context.date.timeIntervalSince(start)
                    HStack(alignment: .top, spacing: Self.gap) {
                        ForEach(0..<columnCount, id: \.self) { column in
                            BoardColumn(
                                tiles: tiles(forColumn: column),
                                changed: changed,
                                scale: scale,
                                progress: progress(column: column, elapsed: elapsed),
                                startOffset: -CGFloat((column * 47) % 120)
                            )
                        }
                    }
                    .fixedSize()
                }
                .rotationEffect(.degrees(-6))
                .scaleEffect(1.1)
                .offset(y: -40)
            }
        .clipped()
        .mask {
            // Fade out at the edges and into the page below.
            LinearGradient(stops: [.init(color: .clear, location: 0), .init(color: .black, location: 0.12), .init(color: .black, location: 0.7), .init(color: .clear, location: 1)], startPoint: .top, endPoint: .bottom)
        }
        .accessibilityHidden(true)
        .onScrollVisibilityChange(threshold: 0.2) { isVisible = $0 }
        .task(id: isActive) {
            guard isActive else { return }
            // Every second or two, one tile changes and stays that way until
            // its next turn.
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(.random(in: 1.0...2.4)))
                guard !Task.isCancelled, let tile = tiles.filter(\.isAnimated).randomElement() else { continue }
                if changed.contains(tile) { changed.remove(tile) } else { changed.insert(tile) }
            }
        }
    }

    /// How far through its loop a column is, from 0 to 1. Columns take
    /// 70 to 110 seconds, and every other one runs the other way.
    private func progress(column: Int, elapsed: TimeInterval) -> CGFloat {
        let duration = 70 + Double((column * 23) % 40)
        let fraction = CGFloat((elapsed / duration).truncatingRemainder(dividingBy: 1))
        return column.isMultiple(of: 2) ? fraction : 1 - fraction
    }

    /// Each column starts at a different tile, so neighbors don't match,
    /// and holds enough tiles to more than fill the board.
    private func tiles(forColumn column: Int) -> [HeroTile] {
        var result: [HeroTile] = []
        var filled: CGFloat = 0
        var index = (column * 5) % tiles.count
        while filled < height * 1.6 || result.count < 3 {
            let tile = tiles[index % tiles.count]
            result.append(tile)
            filled += tile.height * scale + Self.gap
            index += 1
        }
        return result
    }
}

/// One column: its tiles twice over, sliding by exactly one set so the loop
/// has no seam.
private struct BoardColumn: View {
    let tiles: [HeroTile]
    let changed: Set<HeroTile>
    let scale: CGFloat
    let progress: CGFloat
    let startOffset: CGFloat

    private var setHeight: CGFloat {
        tiles.reduce(0) { $0 + $1.height * scale + HeroBoard.gap }
    }

    var body: some View {
        VStack(spacing: HeroBoard.gap) {
            ForEach(Array((tiles + tiles).enumerated()), id: \.offset) { _, tile in
                BoardTile(tile: tile, on: changed.contains(tile), scale: scale)
            }
        }
        .offset(y: startOffset - progress * setHeight)
    }
}

private struct BoardTile: View {
    let tile: HeroTile
    let on: Bool
    let scale: CGFloat
    @Environment(\.openPage) private var openPage

    var body: some View {
        Button {
            openPage(tile.pageID)
        } label: {
            tile.view(on: on)
                .frame(width: 240, height: tile.height)
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(.rect(cornerRadius: 22))
                .overlay {
                    RoundedRectangle(cornerRadius: 22)
                        .strokeBorder(.separator)
                }
                .allowsHitTesting(false)
                .scaleEffect(scale, anchor: .topLeading)
                .frame(width: 240 * scale, height: tile.height * scale, alignment: .topLeading)
                .contentShape(.rect(cornerRadius: 22 * scale))
        }
        .buttonStyle(TileButtonStyle())
        .shadow(color: .black.opacity(0.06), radius: 8, y: 3)
    }
}

private struct TileButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.snappy(duration: 0.2), value: configuration.isPressed)
    }
}
