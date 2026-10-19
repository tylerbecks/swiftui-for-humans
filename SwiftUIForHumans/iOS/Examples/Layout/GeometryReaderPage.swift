import SwiftUI

extension ComponentPage {
    static let geometryReader = ComponentPage(
        id: "geometry-reader",
        title: "GeometryReader",
        summary: "Three ways to size a view relative to its container or read its size.",
        category: .layout,
        kind: .concept,
        symbol: "ruler",
        availability: ["iOS 13.0+", "macOS 10.15+", "visionOS 1.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/geometryreader",
        aliases: ["getBoundingClientRect", "ResizeObserver", "vw", "percentage width", "measure size", "onLayout", "container width", "containerRelativeFrame", "onGeometryChange"],
        related: ["view-that-fits", "layout-basics", "frame", "scroll-view"],
        notes: [
            "**Reach for `GeometryReader` last.** `containerRelativeFrame` and `onGeometryChange` cover most needs without changing the layout around them.",
            "**`onGeometryChange` is new but back-deployed.** It's available from iOS 16, so you can use it in most apps today.",
        ],
        api: [
            APIItem("`.containerRelativeFrame(_:)`", "Sizes a view as a share of its container, with `count` and `span`."),
            APIItem("`.onGeometryChange(for:of:action:)`", "Reads a size or position into state."),
            APIItem("`GeometryReader { proxy in }`", "Fills the offered space and passes its size to the content."),
            APIItem("`proxy.size`", "The size the reader was offered."),
            APIItem("`proxy.frame(in: .global)`", "A view's position in another coordinate space."),
        ]
    ) {
        GeometryThumbnail()
    } content: { page in
        ArticlePage(page: page) {
            GeometryArticle()
        }
    }
}

// MARK: - Thumbnail

private struct GeometryThumbnail: View {
    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 4) {
                Image(systemName: "arrow.left")
                Rectangle().frame(height: 1)
                Text("200 pt").font(.caption2.monospaced())
                Rectangle().frame(height: 1)
                Image(systemName: "arrow.right")
            }
            .font(.caption2)
            .foregroundStyle(.secondary)
            HStack(spacing: 4) {
                RoundedRectangle(cornerRadius: 8).fill(Color.blue.gradient)
                    .overlay { Text("½").font(.headline).foregroundStyle(.white) }
                    .frame(width: 98)
                RoundedRectangle(cornerRadius: 8).fill(Color.purple.gradient)
                    .overlay { Text("¼").font(.headline).foregroundStyle(.white) }
                    .frame(width: 47)
                RoundedRectangle(cornerRadius: 8).fill(Color.pink.gradient)
                    .overlay { Text("¼").font(.headline).foregroundStyle(.white) }
                    .frame(width: 47)
            }
            .frame(height: 64)
        }
        .frame(width: 200)
    }
}

// MARK: - Article

private struct GeometryArticle: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            VStack(alignment: .leading, spacing: 12) {
                Prose("Where CSS uses `width: 50%` or a `ResizeObserver`, SwiftUI has three tools. Pick the first one that does the job:")
                ChoiceRow(
                    symbol: "rectangle.split.2x1",
                    title: "containerRelativeFrame",
                    text: "Size a view as a fraction of its container. No measuring, no state."
                )
                ChoiceRow(
                    symbol: "eye",
                    title: "onGeometryChange",
                    text: "Read a view's size or position into state, to drive something else."
                )
                ChoiceRow(
                    symbol: "ruler",
                    title: "GeometryReader",
                    text: "Lay out content using the exact size offered. Powerful, but greedy."
                )
            }

            VStack(alignment: .leading, spacing: 28) {
                RelativeFrameDemo()

                ExampleCard(
                    title: "onGeometryChange",
                    caption: "`.onGeometryChange` reads the label's width into `@State` as you type, without changing its layout.",
                    code: """
                    @State private var name = "Hello"
                    @State private var width: CGFloat = 0

                    VStack(spacing: 12) {
                        Text(name)
                            .font(.title.bold())
                            .onGeometryChange(for: CGFloat.self) { proxy in
                                proxy.size.width
                            } action: { newWidth in
                                width = newWidth
                            }
                        Capsule()
                            .fill(.tint)
                            .frame(width: width, height: 6)
                        Text("\\(Int(width)) pt wide")
                            .font(.caption.monospacedDigit())
                        TextField("Text", text: $name)
                            .textFieldStyle(.roundedBorder)
                    }
                    """,
                    aside: Aside(.important, "Don't feed a measured size back into the same view's size. That can loop forever. Use it to drive other views.")
                ) {
                    GeometryChangeDemo()
                }

                ExampleCard(
                    title: "GeometryReader",
                    caption: "A `GeometryReader` fills the offered space and passes its size to the content as `proxy.size`.",
                    code: """
                    GeometryReader { proxy in
                        let size = proxy.size
                        VStack(alignment: .leading) {
                            Text("\\(Int(size.width)) × \\(Int(size.height))")
                                .font(.headline.monospacedDigit())
                            Capsule()
                                .fill(.tint)
                                .frame(width: size.width * 0.3, height: 8)
                            Text("30% of the width")
                                .font(.caption)
                        }
                    }
                    .frame(height: 120)
                    .background(.tint.opacity(0.1))
                    """,
                    minHeight: 160,
                    aside: Aside(.important, "A `GeometryReader` takes all the space it's offered and puts its content at the top-leading corner. In a `VStack`, it pushes everything else away.")
                ) {
                    GeometryReader { proxy in
                        let size = proxy.size
                        VStack(alignment: .leading) {
                            Text("\(Int(size.width)) × \(Int(size.height))")
                                .font(.headline.monospacedDigit())
                            Capsule()
                                .fill(.tint)
                                .frame(width: size.width * 0.3, height: 8)
                            Text("30% of the width")
                                .font(.caption)
                        }
                    }
                    .frame(height: 120)
                    .background(.tint.opacity(0.1))
                }
            }
        }
    }
}

private struct ChoiceRow: View {
    let symbol: String
    let title: String
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: symbol)
                .font(.body.weight(.semibold))
                .foregroundStyle(.tint)
                .frame(width: 32, height: 32)
                .background(.tint.opacity(0.12), in: .rect(cornerRadius: 8))
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline.monospaced())
                Text(text)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

// MARK: - Interactive demos

private struct RelativeFrameDemo: View {
    @State private var count = 3
    @State private var span = 1

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            VStack(alignment: .leading, spacing: 4) {
                Text("containerRelativeFrame")
                    .font(.title3.bold())
                RichText("Split the container into `count` columns and give each card `span` of them. Change the numbers to resize the cards.")
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            PreviewCard(minHeight: 160) {
                preview
            }
            CodeBlock(code: Self.code(count: count, span: min(span, count)))
            Aside(.note, "The container is the nearest scroll view, list, or window, never the parent stack. Here it's the horizontal `ScrollView`.")
        }
    }

    private var preview: some View {
        VStack(spacing: 14) {
            ScrollView(.horizontal) {
                HStack(spacing: 10) {
                    ForEach(0..<6, id: \.self) { i in
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(hue: Double(i) / 6, saturation: 0.55, brightness: 0.9).gradient)
                            .overlay {
                                Text("\(i + 1)")
                                    .font(.headline)
                                    .foregroundStyle(.white)
                            }
                            .frame(height: 80)
                            .containerRelativeFrame(.horizontal, count: count, span: min(span, count), spacing: 10)
                    }
                }
            }
            .scrollIndicators(.hidden)
            .animation(.snappy, value: count)
            .animation(.snappy, value: span)

            // Side by side when there's room, stacked on a narrow iPhone.
            ViewThatFits(in: .horizontal) {
                HStack(spacing: 24) { steppers }
                VStack(spacing: 8) { steppers }
            }
            .font(.subheadline.monospacedDigit())
            .onChange(of: count) { _, new in span = min(span, new) }
        }
    }

    @ViewBuilder
    private var steppers: some View {
        Stepper("count: \(count)", value: $count, in: 1...6)
            .fixedSize()
        Stepper("span: \(min(span, count))", value: $span, in: 1...max(count, 1))
            .fixedSize()
    }

    static func code(count: Int, span: Int) -> String {
        """
        ScrollView(.horizontal) {
            HStack(spacing: 10) {
                ForEach(0..<6, id: \\.self) { i in
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.blue.gradient)
                        .frame(height: 80)
                        .containerRelativeFrame(.horizontal, count: \(count), span: \(span), spacing: 10)
                }
            }
        }
        """
    }
}

private struct GeometryChangeDemo: View {
    @State private var name = "Hello"
    @State private var width: CGFloat = 0

    var body: some View {
        VStack(spacing: 12) {
            Text(name)
                .font(.title.bold())
                .onGeometryChange(for: CGFloat.self) { proxy in
                    proxy.size.width
                } action: { newWidth in
                    width = newWidth
                }
            Capsule()
                .fill(.tint)
                .frame(width: width, height: 6)
                .animation(.snappy, value: width)
            Text("\(Int(width)) pt wide")
                .font(.caption.monospacedDigit())
            TextField("Text", text: $name)
                .textFieldStyle(.roundedBorder)
                .frame(maxWidth: 260)
        }
    }
}
