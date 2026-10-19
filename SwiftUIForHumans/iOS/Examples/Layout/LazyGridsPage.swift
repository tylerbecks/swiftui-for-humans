import SwiftUI

extension ComponentPage {
    static let lazyGrids = ComponentPage(
        id: "lazy-grids",
        title: "Lazy Grids",
        summary: "Scrolling grids of many items, like a photo library, built only as they appear.",
        category: .layout,
        symbol: "square.grid.3x2",
        availability: ["iOS 14.0+", "macOS 11.0+", "visionOS 1.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/lazyvgrid",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/collections",
        aliases: ["UICollectionView", "collection view", "photo grid", "gallery", "grid-template-columns", "auto-fill", "minmax", "masonry", "tiles"],
        related: ["grid", "scroll-view", "stacks"],
        notes: [
            "**`.adaptive` is CSS `auto-fill`.** `GridItem(.adaptive(minimum: 100))` works like CSS `auto-fill` with `minmax(100px, 1fr)`: as many columns as fit.",
            "**Columns can't size to their content.** A lazy grid doesn't measure every cell. For a small table whose columns fit their text, use [Grid](catalog://grid).",
        ],
        api: [
            APIItem("`LazyVGrid(columns:spacing:)`", "Scrolls vertically; you describe the columns."),
            APIItem("`LazyHGrid(rows:spacing:)`", "Scrolls sideways; you describe the rows."),
            APIItem("`GridItem(.flexible())`", "One column that shares the width equally."),
            APIItem("`GridItem(.adaptive(minimum:))`", "As many columns as fit, each at least this wide."),
            APIItem("`GridItem(.fixed(_:))`", "One column of an exact width."),
            APIItem("`pinnedViews: [.sectionHeaders]`", "Makes `Section` headers stick while scrolling."),
        ],
        guidelines: [
            Guideline(
                "Show text in a list, not a grid.",
                "Grids are best for images. Text in tiles is harder to scan than the same text in rows.",
                good: "Text reads top to bottom in rows.",
                bad: "Text tiles make the eye zigzag."
            ) {
                LGTextSample(usesGrid: false)
            } bad: {
                LGTextSample(usesGrid: true)
            },
            Guideline(
                "Keep to a simple, regular grid.",
                "People know how a grid of equal tiles works. An unusual layout draws attention to itself instead of the content."
            ),
            Guideline(
                "Don't change the layout while people are using it.",
                "Changing the column count mid-scroll makes people lose their place. Change it only when they ask, like with a zoom control."
            ),
        ]
    ) {
        LazyGridsThumbnail()
    } content: { page in
        LazyGridsDemo(page: page)
    }
}

// MARK: - Shared

private let lazyGridColors: [Color] = [.blue, .purple, .pink, .orange, .yellow, .green, .teal, .indigo, .red, .mint, .cyan, .brown]

private struct LGTile: View {
    let index: Int
    /// Fixed height for vertical grids; nil lets the tile fill its row.
    var height: CGFloat? = 64

    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(lazyGridColors[index % lazyGridColors.count].gradient)
            .frame(height: height)
            .overlay {
                Text("\(index + 1)")
                    .font(.headline)
                    .foregroundStyle(.white)
            }
    }
}

// MARK: - Thumbnail

private struct LazyGridsThumbnail: View {
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 4), spacing: 6) {
            ForEach(0..<12, id: \.self) { i in
                RoundedRectangle(cornerRadius: 6)
                    .fill(lazyGridColors[i].gradient)
                    .frame(height: 30)
            }
        }
        .frame(width: 190)
    }
}

// MARK: - Config

private struct LazyGridConfig {
    var direction: LGDirection = .vertical
    var sizing: LGSizing = .flexible
    var count: Double = 3
    var size: Double = 80
    var spacing: Double = 10
    var itemCount: Double = 12
}

private enum LGDirection: DemoOption {
    case vertical, horizontal

    var label: String {
        switch self {
        case .vertical: "LazyVGrid"
        case .horizontal: "LazyHGrid"
        }
    }
}

private enum LGSizing: DemoOption {
    case fixed, flexible, adaptive

    var label: String {
        switch self {
        case .fixed: ".fixed"
        case .flexible: ".flexible"
        case .adaptive: ".adaptive"
        }
    }

    var explanation: String {
        switch self {
        case .fixed: "Each track is exactly the size you give it. Extra space is left over."
        case .flexible: "The tracks share the available space equally."
        case .adaptive: "One item describes many tracks: it fits as many as it can, each at least the minimum size."
        }
    }
}

private extension LazyGridConfig {
    var items: [GridItem] {
        let spacing = CGFloat(spacing)
        switch sizing {
        case .fixed: return Array(repeating: GridItem(.fixed(size), spacing: spacing), count: Int(count))
        case .flexible: return Array(repeating: GridItem(.flexible(), spacing: spacing), count: Int(count))
        case .adaptive: return [GridItem(.adaptive(minimum: size), spacing: spacing)]
        }
    }

    var itemCode: String {
        let size = swiftNumber(size)
        let spacing = swiftNumber(spacing)
        switch sizing {
        case .fixed: return "Array(repeating: GridItem(.fixed(\(size)), spacing: \(spacing)), count: \(Int(count)))"
        case .flexible: return "Array(repeating: GridItem(.flexible(), spacing: \(spacing)), count: \(Int(count)))"
        case .adaptive: return "[GridItem(.adaptive(minimum: \(size)), spacing: \(spacing))]"
        }
    }
}

// MARK: - Demo

private struct LazyGridsDemo: View {
    let page: ComponentPage

    var body: some View {
        DemoPage(
            page: page,
            initial: LazyGridConfig(),
            previewHeight: 300,
            usage: """
            let columns = [GridItem(.adaptive(minimum: 100))]

            ScrollView {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(1...100, id: \\.self) { i in
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.blue.gradient)
                            .frame(height: 100)
                            .overlay { Text("\\(i)").foregroundStyle(.white) }
                    }
                }
                .padding()
            }
            """,
            usageNote: Aside(.important, "Lazy grids don't scroll on their own. Put a `LazyVGrid` in a `ScrollView`, and a `LazyHGrid` in a `ScrollView(.horizontal)`.")
        ) { $config in
            VStack(spacing: 12) {
                Group {
                    if config.direction == .vertical {
                        ScrollView {
                            LazyVGrid(columns: config.items, spacing: config.spacing) {
                                ForEach(0..<Int(config.itemCount), id: \.self) { LGTile(index: $0) }
                            }
                        }
                    } else {
                        ScrollView(.horizontal) {
                            LazyHGrid(rows: config.items, spacing: config.spacing) {
                                ForEach(0..<Int(config.itemCount), id: \.self) { i in
                                    LGTile(index: i, height: nil)
                                        .frame(width: 64)
                                }
                            }
                        }
                    }
                }
                .frame(height: 240)
                // Fixed tracks can be larger than the box; keep them inside it.
                .clipped()
                .animation(.snappy, value: config.sizing)
                .animation(.snappy, value: config.count)
                .animation(.snappy, value: config.size)
                .animation(.snappy, value: config.spacing)

                Text(config.sizing.explanation)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
        } controls: { $config in
            Section("Grid") {
                Picker("Direction", selection: $config.direction) {
                    ForEach(LGDirection.allCases) { Text($0.label).tag($0) }
                }
                .pickerStyle(.segmented)
                Picker(config.direction == .vertical ? "Column size" : "Row size", selection: $config.sizing) {
                    ForEach(LGSizing.allCases) { Text($0.label).tag($0) }
                }
                .pickerStyle(.segmented)
                if config.sizing != .adaptive {
                    ValueSlider(config.direction == .vertical ? "Columns" : "Rows", value: $config.count, in: 1...6, step: 1)
                }
                if config.sizing != .flexible {
                    ValueSlider(config.sizing == .adaptive ? "Minimum size" : "Size", value: $config.size, in: 40...160, step: 4)
                }
                ValueSlider("Spacing", value: $config.spacing, in: 0...30, step: 1)
            }
            Section("Content") {
                ValueSlider("Items", value: $config.itemCount, in: 1...60, step: 1)
            }
        } code: { config in
            let vertical = config.direction == .vertical
            let name = vertical ? "columns" : "rows"
            var lines = [
                "let \(name) = \(config.itemCode)",
                "",
                vertical ? "ScrollView {" : "ScrollView(.horizontal) {",
                "    \(config.direction.label)(\(name): \(name), spacing: \(swiftNumber(config.spacing))) {",
                "        ForEach(0..<\(Int(config.itemCount)), id: \\.self) { i in",
                "            RoundedRectangle(cornerRadius: 10)",
                "                .fill(.blue.gradient)",
                vertical ? "                .frame(height: 64)" : "                .frame(width: 64)",
            ]
            lines += [
                "                .overlay { Text(\"\\(i + 1)\").foregroundStyle(.white) }",
                "        }",
                "    }",
                "}",
                ".frame(height: 240)",
            ]
            return lines.joined(separator: "\n")
        } examples: {
            ExampleCard(
                title: "Photo grid",
                caption: "Use `.adaptive` columns, 2-point spacing, and `.aspectRatio(1, contentMode: .fit)` for square photo cells.",
                code: """
                let columns = [GridItem(.adaptive(minimum: 80), spacing: 2)]

                ScrollView {
                    LazyVGrid(columns: columns, spacing: 2) {
                        ForEach(0..<30, id: \\.self) { i in
                            Color(hue: Double(i) / 30, saturation: 0.5, brightness: 0.9)
                                .aspectRatio(1, contentMode: .fit)
                        }
                    }
                }
                .frame(height: 240)
                """,
                aside: Aside(.note, "Adaptive columns adjust themselves, so the grid gains columns when you rotate the phone or widen an iPad window.")
            ) {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 80), spacing: 2)], spacing: 2) {
                        ForEach(0..<30, id: \.self) { i in
                            Color(hue: Double(i) / 30, saturation: 0.5, brightness: 0.9)
                                .aspectRatio(1, contentMode: .fit)
                        }
                    }
                }
                .frame(height: 240)
            }

            ExampleCard(
                title: "Sticky section headers",
                caption: "Wrap items in a `Section` and pass `pinnedViews: [.sectionHeaders]` so each header sticks while you scroll.",
                code: """
                ScrollView {
                    LazyVGrid(
                        columns: [GridItem(.adaptive(minimum: 60))],
                        pinnedViews: [.sectionHeaders]
                    ) {
                        ForEach(["Fruit", "Vegetables", "Snacks"], id: \\.self) { name in
                            Section {
                                ForEach(0..<8, id: \\.self) { _ in
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(.fill.secondary)
                                        .frame(height: 60)
                                }
                            } header: {
                                Text(name)
                                    .font(.headline)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.vertical, 6)
                                    .background(.background)
                            }
                        }
                    }
                }
                .frame(height: 240)
                """,
                aside: Aside(.note, "Give a pinned header a background, or the cells scroll visibly behind its text.")
            ) {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))], pinnedViews: [.sectionHeaders]) {
                        ForEach(["Fruit", "Vegetables", "Snacks"], id: \.self) { name in
                            Section {
                                ForEach(0..<8, id: \.self) { _ in
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(.fill.secondary)
                                        .frame(height: 60)
                                }
                            } header: {
                                Text(name)
                                    .font(.headline)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.vertical, 6)
                                    .background(.background)
                            }
                        }
                    }
                }
                .frame(height: 240)
            }

            ExampleCard(
                title: "Two-row shelf",
                caption: "A `LazyHGrid` with two `.flexible()` rows scrolls sideways, like an App Store shelf.",
                code: """
                let rows = [GridItem(.flexible()), GridItem(.flexible())]

                ScrollView(.horizontal) {
                    LazyHGrid(rows: rows, spacing: 12) {
                        ForEach(0..<16, id: \\.self) { i in
                            Label("App \\(i + 1)", systemImage: "app.fill")
                                .frame(width: 140, alignment: .leading)
                        }
                    }
                    .padding(.horizontal)
                }
                .scrollIndicators(.hidden)
                .frame(height: 90)
                """
            ) {
                ScrollView(.horizontal) {
                    LazyHGrid(rows: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        ForEach(0..<16, id: \.self) { i in
                            Label("App \(i + 1)", systemImage: "app.fill")
                                .frame(width: 140, alignment: .leading)
                        }
                    }
                    .padding(.horizontal)
                }
                .scrollIndicators(.hidden)
                .frame(height: 90)
            }
        }
    }
}

// MARK: - Guideline samples

/// The same song titles as rows or as grid tiles.
private struct LGTextSample: View {
    let usesGrid: Bool
    private let songs = ["Morning Light", "Blue Hour", "Paper Boats", "Northbound", "Slow Tide", "Last Train"]

    var body: some View {
        Group {
            if usesGrid {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 6) {
                    ForEach(songs, id: \.self) { song in
                        Text(song)
                            .frame(maxWidth: .infinity, minHeight: 34)
                            .background(.fill.tertiary, in: .rect(cornerRadius: 8))
                    }
                }
            } else {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(Array(songs.enumerated()), id: \.offset) { index, song in
                        if index > 0 { Divider() }
                        Text(song)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 5)
                    }
                }
            }
        }
        .font(.footnote)
        .frame(width: 230)
    }
}
