import SwiftUI

extension ComponentPage {
    static let layoutAdaptivity = ComponentPage(
        id: "layout-adaptivity",
        title: "Layout & Adaptivity",
        summary: "Build layouts that fit any screen, window size, orientation, and text size.",
        category: .foundations,
        kind: .concept,
        symbol: "rectangle.split.2x1",
        availability: ["iOS 16.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/environmentvalues/horizontalsizeclass",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/layout",
        aliases: ["responsive", "responsive design", "media query", "breakpoint", "@media", "container query", "size class", "horizontalSizeClass", "compact", "regular", "iPad multitasking", "Split View", "Slide Over", "resizable window", "orientation", "landscape", "UIRequiresFullScreen", "adaptive layout"],
        related: ["safe-area", "view-that-fits", "stacks", "grid", "lazy-grids", "navigation-split-view", "dynamic-type", "geometry-reader"],
        notes: [
            "**Full-screen-only iPad apps are going away.** As of iPadOS 26, the `UIRequiresFullScreen` key is deprecated. Starting in iOS 27 and iPadOS 27, apps built with the iOS 27 SDK generally can't use it to opt out of resizing.",
            "**Size classes can change while your app runs.** Rotating, resizing a window, or opening another app beside yours can flip them, so never read them once and cache the result.",
        ],
        api: [
            APIItem("`\\.horizontalSizeClass`", "`.compact` when narrow, `.regular` when wide."),
            APIItem("`ViewThatFits`", "Shows the first child that fits."),
            APIItem("`AnyLayout`", "Switches stack direction without losing state."),
            APIItem("`GridItem(.adaptive)`", "As many columns as fit."),
            APIItem("`.containerRelativeFrame(_:)`", "Sizes a view relative to its container."),
            APIItem("`.onGeometryChange(for:)`", "Reacts to a view's real size."),
        ],
        guidelines: [
            Guideline(
                "Decide by available space, not by device.",
                "Size classes and `ViewThatFits` describe the room you really have. Checking for iPad or landscape breaks as soon as a window gets resized."
            ),
            Guideline(
                "Keep every feature at every size.",
                "A narrow window can show fewer buttons, but the actions should move into a menu, not disappear.",
                good: "Extra actions fold into a More menu.",
                bad: "Export and Print vanish when narrow."
            ) {
                LayoutAdaptToolbar(foldsIntoMenu: true)
            } bad: {
                LayoutAdaptToolbar(foldsIntoMenu: false)
            },
            Guideline(
                "Keep content inside the safe area.",
                "The Dynamic Island, the Home indicator, and bars cover the screen's edges. Let backgrounds run edge to edge, but keep text and controls inside.",
                good: "The title sits below the Dynamic Island.",
                bad: "The title runs under it."
            ) {
                LayoutAdaptSafeAreaSample(respectsSafeArea: true)
            } bad: {
                LayoutAdaptSafeAreaSample(respectsSafeArea: false)
            },
            Guideline(
                "Make room for larger text.",
                "With big Dynamic Type sizes, side-by-side text runs out of room. Stack it vertically instead of cutting it off.",
                good: "The value moves under its label.",
                bad: "Both get truncated."
            ) {
                LayoutAdaptLargeTextRow(stacks: true)
            } bad: {
                LayoutAdaptLargeTextRow(stacks: false)
            },
            Guideline(
                "Test the extremes first.",
                "Check the smallest and largest layouts, then other languages and text sizes. Problems show up at the edges."
            ),
        ],
        sources: [
            "https://developer.apple.com/design/human-interface-guidelines/layout",
            "https://developer.apple.com/documentation/swiftui/environmentvalues/horizontalsizeclass",
            "https://developer.apple.com/documentation/swiftui/userinterfacesizeclass",
            "https://developer.apple.com/documentation/swiftui/viewthatfits",
            "https://developer.apple.com/documentation/swiftui/view/containerrelativeframe(_:alignment:)",
            "https://developer.apple.com/documentation/technotes/tn3192-migrating-your-app-from-the-deprecated-uirequiresfullscreen-key",
        ],
        reviewed: "October 2026"
    ) {
        HStack(alignment: .bottom, spacing: 10) {
            LayoutAdaptThumbScreen(width: 44, height: 84, columns: 1)
            LayoutAdaptThumbScreen(width: 120, height: 84, columns: 2)
        }
        .accessibilityHidden(true)
    } content: { page in
        LayoutAdaptivityArticle(page: page)
    }
}

// MARK: - Page

private struct LayoutAdaptivityArticle: View {
    let page: ComponentPage

    var body: some View {
        ArticlePage(page: page) {
            Prose("Your app never gets one fixed screen. It runs on phones of different sizes, in portrait and landscape, and in iPad windows that people resize at will. Like responsive design on the web, you describe how the layout **adapts**, and SwiftUI does the measuring. The difference: you react to the space you're given, not to the device.")

            VStack(alignment: .leading, spacing: 16) {
                SectionTitle("Resize it")
                LayoutAdaptResizeDemo()
            }
            .id("demo")

            VStack(alignment: .leading, spacing: 16) {
                SectionTitle("Size classes")
                Prose("iOS sums up the space in each direction as one of two **size classes**: `compact` (narrow or short) or `regular` (wide or tall). They're the closest thing to a media query breakpoint, and built-in views like `NavigationSplitView` already use them.")
                Aside(.note, "The device, its orientation, and iPad multitasking all set the size class. Read it, but don't try to guess it from the device.")
            }
            .id("size-classes")

            VStack(alignment: .leading, spacing: 16) {
                SectionTitle("Pick the right tool")
                LayoutAdaptToolTable()
            }
            .id("tools")

            VStack(alignment: .leading, spacing: 16) {
                SectionTitle("Examples")
                VStack(alignment: .leading, spacing: 44) {
                    ExampleCard(
                        title: "Switch layouts with the size class",
                        caption: "Read `horizontalSizeClass` and use `AnyLayout` to stack vertically when compact and side by side when regular.",
                        code: """
                        @Environment(\\.horizontalSizeClass) private var sizeClass

                        let layout = sizeClass == .regular
                            ? AnyLayout(HStackLayout(spacing: 12))
                            : AnyLayout(VStackLayout(alignment: .leading, spacing: 8))
                        layout {
                            Image(systemName: "photo")
                                .font(.title)
                                .frame(width: 80, height: 56)
                                .background(.fill.tertiary, in: .rect(cornerRadius: 8))
                            Text("Trip to Lisbon")
                                .font(.headline)
                        }
                        """,
                        minHeight: 170,
                        aside: Aside(.note, "`AnyLayout` keeps the children's state when it switches, unlike an `if` that swaps an `HStack` for a `VStack`.")
                    ) {
                        HStack(alignment: .top, spacing: 16) {
                            LayoutAdaptSizeClassSample(sizeClass: .compact)
                            LayoutAdaptSizeClassSample(sizeClass: .regular)
                        }
                    }

                    ExampleCard(
                        title: "Show the version that fits",
                        caption: "List options from largest to smallest in `ViewThatFits`, and SwiftUI shows the first one with room.",
                        code: """
                        ViewThatFits(in: .horizontal) {
                            HStack {
                                Button("Reply", systemImage: "arrowshape.turn.up.left") {}
                                Button("Forward", systemImage: "arrowshape.turn.up.right") {}
                            }
                            HStack {
                                Button("Reply", systemImage: "arrowshape.turn.up.left") {}
                                Button("Forward", systemImage: "arrowshape.turn.up.right") {}
                            }
                            .labelStyle(.iconOnly)
                        }
                        .buttonStyle(.bordered)
                        """,
                        minHeight: 150,
                        aside: Aside(.note, "Both versions keep the same actions. The narrow one just drops the words.")
                    ) {
                        VStack(alignment: .leading, spacing: 12) {
                            LayoutAdaptFitsButtons()
                                .frame(width: 280, alignment: .leading)
                            LayoutAdaptFitsButtons()
                                .frame(width: 130, alignment: .leading)
                        }
                    }

                    ExampleCard(
                        title: "Let a grid pick its columns",
                        caption: "Use an adaptive `GridItem` to fit as many columns as the width allows, with no size checks.",
                        code: """
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 70))]) {
                            ForEach(0..<6) { index in
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(.blue.gradient)
                                    .frame(height: 50)
                                    .overlay { Text("\\(index + 1)").foregroundStyle(.white) }
                            }
                        }
                        """,
                        minHeight: 180
                    ) {
                        VStack(spacing: 14) {
                            LayoutAdaptAdaptiveGrid()
                                .frame(width: 280)
                            LayoutAdaptAdaptiveGrid()
                                .frame(width: 160)
                        }
                    }

                    ExampleCard(
                        title: "Size cards to the screen",
                        caption: "Use `.containerRelativeFrame` to make each card a share of the scroll view's width, on any screen.",
                        code: """
                        ScrollView(.horizontal) {
                            HStack(spacing: 12) {
                                ForEach(0..<5) { index in
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(.orange.gradient)
                                        .frame(height: 90)
                                        .containerRelativeFrame(.horizontal, count: 2, spacing: 12)
                                }
                            }
                        }
                        .contentMargins(.horizontal, 16)
                        """,
                        minHeight: 140,
                        aside: Aside(.note, "With `count: 2`, two cards fill the width on iPhone and on a wide iPad window alike. Raise the count for regular widths if you want more.")
                    ) {
                        ScrollView(.horizontal) {
                            HStack(spacing: 12) {
                                ForEach(0..<5) { index in
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(.orange.gradient)
                                        .frame(height: 90)
                                        .overlay { Text("\(index + 1)").font(.headline).foregroundStyle(.white) }
                                        .containerRelativeFrame(.horizontal, count: 2, spacing: 12)
                                }
                            }
                        }
                        .contentMargins(.horizontal, 16)
                        .scrollIndicators(.hidden)
                    }
                }
            }
            .id("examples")
        }
    }
}

// MARK: - Demo

private struct LayoutAdaptResizeDemo: View {
    @State private var width: CGFloat = 300

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Drag to change the window width. The card uses `ViewThatFits`, so it picks its layout from the space alone.")
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            VStack(spacing: 0) {
                ZStack {
                    LayoutAdaptArticleCard()
                        .padding(12)
                        .frame(width: width)
                        .background(Color(.systemBackground), in: .rect(cornerRadius: 14))
                        .overlay {
                            RoundedRectangle(cornerRadius: 14)
                                .strokeBorder(.separator)
                        }
                }
                .frame(maxWidth: .infinity, minHeight: 210)
                .padding(.vertical, 12)
                .background(Surface.preview)
                Divider()
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("Width")
                            .font(.subheadline.weight(.medium))
                        Spacer()
                        Text("\(Int(width)) pt")
                            .font(.subheadline)
                            .monospacedDigit()
                            .foregroundStyle(.secondary)
                    }
                    Slider(value: $width, in: 150...300, step: 5)
                        .accessibilityLabel("Window width")
                }
                .padding(14)
            }
            .cardStyle()
        }
    }
}

private struct LayoutAdaptArticleCard: View {
    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .top, spacing: 12) {
                thumbnail
                text
                    .frame(width: 150, alignment: .leading)
            }
            VStack(alignment: .leading, spacing: 10) {
                thumbnail
                    .frame(maxWidth: .infinity)
                text
            }
        }
    }

    private var thumbnail: some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(.teal.gradient)
            .frame(width: 96, height: 72)
            .overlay {
                Image(systemName: "mountain.2.fill")
                    .font(.title2)
                    .foregroundStyle(.white)
            }
    }

    private var text: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Weekend Hikes")
                .font(.headline)
            Text("Five trails within an hour of the city.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

private struct LayoutAdaptToolTable: View {
    private let rows: [(String, String)] = [
        ("A different structure when wide", "`horizontalSizeClass`"),
        ("The first version that fits", "`ViewThatFits`"),
        ("Columns that fill the width", "`GridItem(.adaptive)`"),
        ("A share of the screen", "`.containerRelativeFrame`"),
        ("The exact size, for drawing", "`.onGeometryChange`"),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(rows.enumerated()), id: \.offset) { index, row in
                if index > 0 { Divider() }
                VStack(alignment: .leading, spacing: 4) {
                    Text(row.0)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                    RichText(row.1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 10)
            }
            Divider()
            Label {
                RichText("Avoid checking `userInterfaceIdiom`, orientation, or screen size to choose a layout.")
                    .fixedSize(horizontal: false, vertical: true)
            } icon: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.red)
            }
            .font(.callout)
            .padding(.top, 12)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.background.secondary, in: .rect(cornerRadius: 16))
    }
}

// MARK: - Example views

private struct LayoutAdaptSizeClassSample: View {
    let sizeClass: UserInterfaceSizeClass

    var body: some View {
        VStack(spacing: 8) {
            LayoutAdaptSizeClassContent()
                .environment(\.horizontalSizeClass, sizeClass)
                .padding(10)
                .background(Color(.systemBackground), in: .rect(cornerRadius: 12))
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(.separator)
                }
            Text(sizeClass == .regular ? "Regular" : "Compact")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

private struct LayoutAdaptSizeClassContent: View {
    @Environment(\.horizontalSizeClass) private var sizeClass

    var body: some View {
        let layout = sizeClass == .regular
            ? AnyLayout(HStackLayout(spacing: 12))
            : AnyLayout(VStackLayout(alignment: .leading, spacing: 8))
        layout {
            Image(systemName: "photo")
                .font(.title)
                .frame(width: 80, height: 56)
                .background(.fill.tertiary, in: .rect(cornerRadius: 8))
            Text("Trip to Lisbon")
                .font(.headline)
                .lineLimit(1)
        }
    }
}

private struct LayoutAdaptFitsButtons: View {
    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack {
                Button("Reply", systemImage: "arrowshape.turn.up.left") {}
                Button("Forward", systemImage: "arrowshape.turn.up.right") {}
            }
            HStack {
                Button("Reply", systemImage: "arrowshape.turn.up.left") {}
                Button("Forward", systemImage: "arrowshape.turn.up.right") {}
            }
            .labelStyle(.iconOnly)
        }
        .buttonStyle(.bordered)
    }
}

private struct LayoutAdaptAdaptiveGrid: View {
    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 70))]) {
            ForEach(0..<6) { index in
                RoundedRectangle(cornerRadius: 10)
                    .fill(.blue.gradient)
                    .frame(height: 50)
                    .overlay { Text("\(index + 1)").foregroundStyle(.white) }
            }
        }
    }
}

// MARK: - Guideline views

private struct LayoutAdaptToolbar: View {
    let foldsIntoMenu: Bool

    var body: some View {
        HStack(spacing: 14) {
            Text("Notes")
                .font(.headline)
                .foregroundStyle(.primary)
            Spacer()
            Image(systemName: "square.and.arrow.up")
            if foldsIntoMenu {
                Menu {
                    Button("Export", systemImage: "arrow.down.doc") {}
                    Button("Print", systemImage: "printer") {}
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .font(.title3)
        .foregroundStyle(.tint)
        .padding(12)
        .frame(width: 170)
        .background(Color(.secondarySystemBackground), in: .rect(cornerRadius: 12))
    }
}

private struct LayoutAdaptSafeAreaSample: View {
    let respectsSafeArea: Bool

    var body: some View {
        ZStack(alignment: .top) {
            LinearGradient(colors: [.indigo, .blue], startPoint: .top, endPoint: .bottom)
            Text("Today")
                .font(.title2.bold())
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 14)
                .padding(.top, respectsSafeArea ? 34 : 8)
            Capsule()
                .fill(.black)
                .frame(width: 56, height: 16)
                .padding(.top, 8)
        }
        .frame(width: 170, height: 100)
        .clipShape(.rect(cornerRadius: 22))
        .overlay {
            RoundedRectangle(cornerRadius: 22)
                .strokeBorder(.separator)
        }
    }
}

private struct LayoutAdaptLargeTextRow: View {
    let stacks: Bool

    var body: some View {
        Group {
            if stacks {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Delivery Address")
                    Text("12 Harbor Street")
                        .foregroundStyle(.secondary)
                }
            } else {
                HStack {
                    Text("Delivery Address")
                    Spacer()
                    Text("12 Harbor Street")
                        .foregroundStyle(.secondary)
                }
                .lineLimit(1)
            }
        }
        .font(.system(size: 24))
        .padding(12)
        .frame(width: 250, alignment: .leading)
        .background(Color(.secondarySystemBackground), in: .rect(cornerRadius: 12))
    }
}

private struct LayoutAdaptThumbScreen: View {
    let width: CGFloat
    let height: CGFloat
    let columns: Int

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<columns, id: \.self) { column in
                VStack(spacing: 4) {
                    ForEach(0..<4, id: \.self) { _ in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(column == 0 && columns > 1 ? Color.secondary.opacity(0.3) : Color.accentColor.opacity(0.6))
                            .frame(height: 10)
                    }
                    Spacer(minLength: 0)
                }
            }
        }
        .padding(7)
        .frame(width: width, height: height)
        .background(Color(.systemBackground), in: .rect(cornerRadius: 10))
        .overlay {
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(.separator)
        }
    }
}
