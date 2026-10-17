#if DEBUG
import Charts
import SwiftUI

/// The website's hero board is made from this screen. Launch with
/// `-heroReel <page>` on an 11-inch iPad simulator: it packs real components
/// into 240-point-wide tiles of different heights, like a masonry board, over
/// as many pages as it takes. The animated tiles change every 3 seconds, so
/// each change has time to settle. On launch it saves where every tile is to
/// `Documents/heroReel.json`, which `scripts/hero-reel.sh` uses to cut the
/// screenshots and recordings into tiles. Debug builds only.
struct HeroReel: View {
    static let width: CGFloat = 240
    static let margin: CGFloat = 12
    static let spacing: CGFloat = 12
    static let columns = 3
    static let screenHeight: CGFloat = 1180

    let page: Int
    @State private var on = false

    var body: some View {
        ZStack(alignment: .topLeading) {
            Color(.systemBackground)
            ForEach(Self.layout.filter { $0.page == page }, id: \.tile) { slot in
                slot.tile.view(on: on)
                    .frame(width: slot.frame.width, height: slot.frame.height)
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipped()
                    .offset(x: slot.frame.minX, y: slot.frame.minY)
            }
        }
        .ignoresSafeArea()
        .statusBarHidden()
        .task {
            Self.saveLayout()
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(3))
                on.toggle()
            }
        }
    }

    struct Slot: Encodable {
        let tile: HeroTile
        let page: Int
        let frame: CGRect

        enum CodingKeys: String, CodingKey { case name, title, page, x, y, height, animated }
        func encode(to encoder: Encoder) throws {
            var c = encoder.container(keyedBy: CodingKeys.self)
            try c.encode(tile.rawValue, forKey: .name)
            try c.encode(tile.title, forKey: .title)
            try c.encode(page, forKey: .page)
            try c.encode(frame.minX, forKey: .x)
            try c.encode(frame.minY, forKey: .y)
            try c.encode(frame.height, forKey: .height)
            try c.encode(tile.isAnimated, forKey: .animated)
        }
    }

    /// Each tile goes in the shortest column; a tile that doesn't fit starts
    /// a new page.
    static let layout: [Slot] = {
        var slots: [Slot] = []
        var page = 0
        var bottoms = Array(repeating: margin, count: columns)
        for tile in HeroTile.allCases {
            var column = bottoms.indices.min { bottoms[$0] < bottoms[$1] }!
            if bottoms[column] + tile.height > screenHeight - margin {
                page += 1
                bottoms = Array(repeating: margin, count: columns)
                column = 0
            }
            let x = margin + CGFloat(column) * (width + spacing)
            slots.append(Slot(tile: tile, page: page, frame: CGRect(x: x, y: bottoms[column], width: width, height: tile.height)))
            bottoms[column] += tile.height + spacing
        }
        return slots
    }()

    private static func saveLayout() {
        let url = URL.documentsDirectory.appending(path: "heroReel.json")
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        try? encoder.encode(layout).write(to: url)
    }
}
#endif
