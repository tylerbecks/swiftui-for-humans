import SwiftUI

/// How far a list has scrolled from rest, and how tall the bars above it are.
/// An observable object rather than state on the list's view, so a scroll
/// redraws only what reads it (the hero backdrop), not the whole list.
@Observable final class ListScroll {
    struct Reading: Equatable {
        var offset: CGFloat = 0
        var underBar: CGFloat = 0
    }

    var reading = Reading()
}

/// The tab's wallpaper behind the tab's first screen (the sidebar list on
/// iPhone, the overview on iPad), moving with it: full width, up under the
/// large title, and fading out behind the first rows. Scrolling only moves
/// it, so it never rebuilds while the content scrolls, and it stops
/// drifting once it has scrolled out of sight.
struct HeroBackdrop: View {
    let tab: AppTab
    let scroll: ListScroll
    /// The color behind the content, which the scrim under the title fades to.
    var background = Color.catalogGroupedBackground

    var body: some View {
        let reading = scroll.reading
        let height = reading.underBar + 260
        Wallpaper(seed: tab.rawValue, tab: tab, isPaused: reading.offset > height)
            .overlay(TextScrim(titleBottom: reading.underBar, color: background))
            .mask(WallpaperFade())
            .frame(height: height)
            .offset(y: -reading.offset)
            .ignoresSafeArea(edges: [.top, .horizontal])
    }
}
