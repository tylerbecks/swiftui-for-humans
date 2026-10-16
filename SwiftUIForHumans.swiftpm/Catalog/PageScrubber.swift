import SwiftUI

// A page scrubber, like Google Docs' or Photos': on long pages a glass
// handle appears at the right edge while you scroll. Drag it to move through
// the page quickly while an outline of the sections shows where you are, or
// tap it to open the outline and jump to a section.
//
// SwiftUI has no built-in version for a ScrollView (the section index in
// iOS 26 only works in a List), so it's built from scroll geometry and
// `ScrollPosition`. Section headings register themselves with
// `.outlineEntry(_:level:)`.

/// One heading in the page outline, positioned in the page's content.
struct OutlineEntry: Equatable, Sendable {
    let title: String
    let level: Int
    let y: CGFloat

    /// The scroll anchor ID of a heading, for jumping to it.
    static func anchor(for title: String) -> String { "outline-\(title)" }
}

struct OutlineEntriesKey: PreferenceKey {
    static let defaultValue: [OutlineEntry] = []

    static func reduce(value: inout [OutlineEntry], nextValue: () -> [OutlineEntry]) {
        value += nextValue()
    }
}

extension View {
    /// Lists this view in the page outline. Level 1 is a section heading,
    /// level 2 an example inside a section.
    func outlineEntry(_ title: String, level: Int = 1) -> some View {
        id(OutlineEntry.anchor(for: title))
            .background {
            GeometryReader { geometry in
                Color.clear.preference(
                    key: OutlineEntriesKey.self,
                    value: [OutlineEntry(title: title, level: level, y: geometry.frame(in: .named(PageScrubber.contentSpace)).minY)]
                )
            }
        }
    }
}

/// The scroll state the scrubber needs from the page's ScrollView.
struct PageScrollMetrics: Equatable {
    var offset: CGFloat = 0
    var contentHeight: CGFloat = 0
    var containerHeight: CGFloat = 0
    var topInset: CGFloat = 0
    var bottomInset: CGFloat = 0

    init() {}

    init(_ geometry: ScrollGeometry) {
        offset = geometry.contentOffset.y
        contentHeight = geometry.contentSize.height
        containerHeight = geometry.containerSize.height
        topInset = geometry.contentInsets.top
        bottomInset = geometry.contentInsets.bottom
    }

    /// The smallest and largest content offsets.
    var minOffset: CGFloat { -topInset }
    var maxOffset: CGFloat { max(minOffset, contentHeight - containerHeight + bottomInset) }

    /// 0 at the top of the page, 1 at the bottom.
    var progress: CGFloat {
        let range = maxOffset - minOffset
        guard range > 0 else { return 0 }
        return min(max((offset - minOffset) / range, 0), 1)
    }

    /// The top of the visible area, in content coordinates.
    var visibleTop: CGFloat { offset + topInset }

    /// Worth a scrubber: more than about one and a half screens.
    var isLong: Bool { contentHeight > containerHeight * 1.5 }
}

/// Scroll state shared by the page and its scrubber. It's a separate
/// observable object so that scrolling only re-renders the scrubber, not
/// the whole page.
@MainActor @Observable
final class PageScrollModel {
    var metrics = PageScrollMetrics() {
        didSet {
            if metrics.offset != oldValue.offset { lastMovement += 1 }
        }
    }
    /// Counts scroll position changes; the scrubber shows on each change
    /// and hides after the page has been still for a few seconds.
    var lastMovement = 0
    var entries: [OutlineEntry] = []
    /// Long enough for the scrubber, which then replaces the scroll bar.
    /// Kept apart from `metrics` so the page only re-renders when it flips.
    var isLong = false
}

/// The handle and outline, laid over the page's ScrollView.
struct PageScrubber: View {
    static let contentSpace = "page-content"

    let title: String
    let model: PageScrollModel
    /// Scrolls the page so content position `y` sits at the top of the
    /// visible area, just under the navigation bar. Used while scrubbing.
    let scrollTo: (CGFloat) -> Void
    /// Scrolls to a heading by its title, or to the top for `nil`.
    let jumpTo: (String?) -> Void
    /// Called when a scrub ends, so the page can let go of the scroll
    /// position the scrub set.
    let scrubEnded: () -> Void

    @State private var isVisible = false
    /// True while a finger is on the handle. `@GestureState` resets when
    /// the gesture ends *or* is cancelled, and `onEnded` only runs for the
    /// first, so the drag is finished from `onChange(of: isDragging)`.
    @GestureState private var isDragging = false
    @State private var dragStart: CGFloat?
    @State private var isOutlineOpen = false
    /// The outline was left open by a scrub, so it closes with the handle
    /// when the page goes idle. One opened with a tap stays until dismissed.
    @State private var isOutlineFromScrub = false

    private var metrics: PageScrollMetrics { model.metrics }
    /// The page title first, then headings in page order.
    private var entries: [OutlineEntry] {
        [OutlineEntry(title: title, level: 1, y: 0)] + model.entries.sorted { $0.y < $1.y }
    }

    private let handleSize = CGSize(width: 40, height: 54)
    /// How much of the handle tucks past the screen edge, like Google Docs'
    /// half-hidden tab, so it hugs the edge instead of covering content.
    private let tuck: CGFloat = 14
    private let margin: CGFloat = 12

    /// While dragging or reading the outline, the handle stays.
    /// `-showScrubber` keeps it on screen, for testing.
    private var isHeld: Bool {
        isDragging || (isOutlineOpen && !isOutlineFromScrub) || LaunchOptions.isSet("-showScrubber")
    }

    /// How long the page must be still before the handle leaves.
    private static var idleDelay: Duration { .seconds(2) }

    /// The section that the top of the screen is in.
    private var currentIndex: Int? {
        entries.lastIndex { $0.y <= metrics.visibleTop + 100 } ?? (entries.isEmpty ? nil : 0)
    }

    var body: some View {
        GeometryReader { geometry in
            let track = geometry.size.height - margin * 2 - handleSize.height
            ZStack(alignment: .topTrailing) {
                if isOutlineOpen || isDragging {
                    // Fade the page so the outline reads; tap to close.
                    Rectangle()
                        .fill(.background.opacity(0.75))
                        .ignoresSafeArea()
                        .onTapGesture { close() }
                        .transition(.opacity)
                    outline
                        .frame(maxHeight: geometry.size.height - margin * 2)
                        .padding(.trailing, handleSize.width - tuck + 10)
                        .frame(width: geometry.size.width, height: geometry.size.height, alignment: .trailing)
                        .transition(.opacity.combined(with: .scale(scale: 0.96, anchor: .trailing)))
                }
                if isVisible && metrics.isLong {
                    handle
                        .offset(x: tuck, y: margin + track * metrics.progress)
                        .gesture(drag(track: track))
                        // Slides in from the right edge and back out.
                        .transition(.offset(x: handleSize.width + 16))
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .topTrailing)
        }
        .animation(.spring(duration: 0.35, bounce: 0.15), value: isVisible)
        .animation(.smooth(duration: 0.2), value: isOutlineOpen || isDragging)
        .sensoryFeedback(.selection, trigger: isDragging ? currentIndex : nil)
        .onChange(of: isDragging) { _, dragging in
            if !dragging { finishDrag() }
        }
        // Restarts on every scroll movement and on every change to
        // dragging or the outline: show now, hide after the idle delay.
        .task(id: [model.lastMovement, isHeld ? 1 : 0]) {
            guard model.lastMovement > 0 || isHeld else { return }
            isVisible = true
            guard !isHeld else { return }
            try? await Task.sleep(for: Self.idleDelay)
            guard !Task.isCancelled else { return }
            isVisible = false
            close()
        }
    }

    private var handle: some View {
        VStack(spacing: 2) {
            Image(systemName: "chevron.up")
            Image(systemName: "chevron.down")
        }
        .font(.footnote.weight(.semibold))
        .foregroundStyle(.secondary)
        // Keep the chevrons in the visible part of the tab.
        .padding(.trailing, tuck)
        .frame(width: handleSize.width, height: handleSize.height)
        .contentShape(.capsule)
        .glassEffect(.regular.interactive(), in: .capsule)
        .accessibilityHidden(true)
    }

    /// Fits its content, and scrolls only when the outline is taller than
    /// the screen.
    private var outline: some View {
        ViewThatFits(in: .vertical) {
            outlineRows
            ScrollView {
                outlineRows
            }
        }
        .fixedSize(horizontal: true, vertical: false)
        .glassEffect(.regular, in: .rect(cornerRadius: 22))
        .accessibilityHidden(true)
    }

    private var outlineRows: some View {
            VStack(alignment: .trailing, spacing: 2) {
                ForEach(Array(entries.enumerated()), id: \.offset) { index, entry in
                    let isCurrent = index == currentIndex
                    Button {
                        jump(to: entry)
                    } label: {
                        Text(entry.title)
                            .font(entry.level == 1 ? .subheadline.weight(.semibold) : .footnote)
                            .foregroundStyle(isCurrent ? AnyShapeStyle(.white) : AnyShapeStyle(entry.level == 1 ? .primary : .secondary))
                            .lineLimit(1)
                            .padding(.horizontal, 12)
                            .padding(.vertical, entry.level == 1 ? 7 : 5)
                            .background(isCurrent ? AnyShapeStyle(.tint) : AnyShapeStyle(.clear), in: .capsule)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(8)
    }

    private func drag(track: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .global)
            .updating($isDragging) { _, state, _ in state = true }
            .onChanged { value in
                guard dragStart != nil || abs(value.translation.height) > 4 else { return }
                if dragStart == nil {
                    dragStart = metrics.progress
                    close()
                }
                // Keep the handle under the finger: move it along the track
                // from where the drag began, and scroll the page to match.
                let progress = min(max((dragStart ?? 0) + value.translation.height / track, 0), 1)
                scrollTo(progress * (metrics.maxOffset - metrics.minOffset))
            }

    }

    private func finishDrag() {
        if dragStart == nil {
            // A tap toggles the outline, which then stays open.
            isOutlineFromScrub = false
            isOutlineOpen.toggle()
        } else {
            // After a scrub, keep the outline up so its sections can be
            // tapped. It leaves with the handle.
            isOutlineFromScrub = true
            isOutlineOpen = true
            scrubEnded()
        }
        dragStart = nil
    }

    private func jump(to entry: OutlineEntry) {
        jumpTo(entry.y == 0 ? nil : entry.title)
        close()
    }

    private func close() {
        isOutlineOpen = false
        isOutlineFromScrub = false
    }
}
