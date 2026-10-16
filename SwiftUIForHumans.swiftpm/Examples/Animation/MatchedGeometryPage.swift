import SwiftUI

extension ComponentPage {
    static let matchedGeometry = ComponentPage(
        id: "matched-geometry",
        title: "Matched Geometry",
        summary: "Morph one view into another, like a sliding tab highlight or a card growing full screen.",
        category: .animation,
        kind: .modifier,
        symbol: "rectangle.on.rectangle.angled",
        availability: ["iOS 14.0+", "macOS 11.0+", "visionOS 1.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/view/matchedgeometryeffect(id:in:properties:anchor:issource:)",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/motion",
        aliases: ["hero animation", "shared element transition", "FLIP", "layoutId", "framer motion layout", "morph", "zoom transition", "magic move", "namespace"],
        related: ["transitions", "navigation-stack", "spring", "sheet"],
        notes: [
            "**Both views need the same `id` and the same `@Namespace`.** Declare the namespace once in the parent, and pass it to child views as a `Namespace.ID`.",
            "**It only links frames.** Each view still fades in or out with its own transition while its frame moves, so add `.transition(.identity)` if you see a cross-fade you don't want.",
        ],
        api: [
            APIItem("`@Namespace`", "A scope for ids, declared once in the parent view."),
            APIItem("`.matchedGeometryEffect(id:in:)`", "Links this view's frame to others with the same id."),
            APIItem("`isSource:`", "Pass `false` on copies that should follow, not lead."),
            APIItem("`.matchedTransitionSource(id:in:)`", "Marks the tile a new screen zooms out of (iOS 18+)."),
            APIItem("`.navigationTransition(.zoom(sourceID:in:))`", "Zooms a pushed screen or sheet from its source."),
        ],
        guidelines: [
            Guideline(
                "Morph only things people see as the same object.",
                "A thumbnail growing into its detail explains where the detail came from. Morphing unrelated views into each other just confuses."
            ),
            Guideline(
                "Let people go back the way they came.",
                "A screen that zoomed out of a tile should shrink back into it. The zoom transition does this, including swipe to dismiss."
            ),
            Guideline(
                "Keep it quick.",
                "A hero animation people see every time they open an item should feel instant. Use a short spring like `.snappy`."
            ),
        ]
    ) {
        MatchedThumbnail()
    } content: { page in
        MatchedGeometryArticle(page: page)
    }
}

// MARK: - Article

private struct MatchedGeometryArticle: View {
    let page: ComponentPage

    var body: some View {
        ArticlePage(page: page) {
            VStack(alignment: .leading, spacing: 16) {
                Prose("On the web you'd measure two elements and animate between their boxes (FLIP, or `layoutId` in Framer Motion). In SwiftUI you give both views the same id. When one leaves as the other arrives in an animated change, SwiftUI moves the frame from one to the other.")
            }

            ExampleCard(
                title: "Sliding tab indicator",
                caption: "Draw one `.matchedGeometryEffect(id:in:)` highlight behind the selected tab, and it slides between tabs.",
                code: """
                @State private var selected = "Music"
                @Namespace private var tabs

                HStack(spacing: 4) {
                    ForEach(["Music", "Podcasts", "Books"], id: \\.self) { tab in
                        Text(tab)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(selected == tab ? .white : .primary)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background {
                                if selected == tab {
                                    Capsule()
                                        .fill(.indigo)
                                        .matchedGeometryEffect(id: "highlight", in: tabs)
                                }
                            }
                            .onTapGesture {
                                withAnimation(.snappy) { selected = tab }
                            }
                    }
                }
                .padding(4)
                .background(.fill.tertiary, in: .capsule)
                """,
                minHeight: 120,
                aside: Aside(.important, "The change must happen inside `withAnimation`. Without it, the highlight jumps to the new tab.")
            ) {
                TabIndicatorExample()
            }

            ExampleCard(
                title: "Card that expands",
                caption: "Give each shared piece its own `matchedGeometryEffect` id, so the art and title travel between layouts.",
                code: """
                @State private var isExpanded = false
                @Namespace private var card

                VStack {
                    if isExpanded {
                        VStack(alignment: .leading, spacing: 12) {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(.orange.gradient)
                                .matchedGeometryEffect(id: "art", in: card)
                                .frame(height: 160)
                            Text("Sunset Drive")
                                .font(.title2.bold())
                                .matchedGeometryEffect(id: "title", in: card)
                            Text("A playlist for golden hour.")
                                .foregroundStyle(.secondary)
                        }
                    } else {
                        HStack(spacing: 12) {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(.orange.gradient)
                                .matchedGeometryEffect(id: "art", in: card)
                                .frame(width: 56, height: 56)
                            Text("Sunset Drive")
                                .font(.headline)
                                .matchedGeometryEffect(id: "title", in: card)
                            Spacer()
                        }
                    }
                }
                .onTapGesture {
                    withAnimation(.spring(duration: 0.5, bounce: 0.2)) {
                        isExpanded.toggle()
                    }
                }
                """,
                minHeight: 280,
                aside: Aside(.important, "Each id can be on screen only once. If both versions show at the same time, give one `isSource: false`, or SwiftUI warns and the result is unpredictable.")
            ) {
                ExpandingCardExample()
            }
            .id("expand")

            VStack(alignment: .leading, spacing: 16) {
                SectionTitle("Zoom into a new screen")
                Prose("To open a new screen, skip matched geometry and use the zoom transition (iOS 18+). It's how Photos and the App Store open items, and swiping down shrinks the screen back into its tile.")
            }

            ExampleCard(
                title: "Zoom transition",
                caption: "Pair `.matchedTransitionSource(id:in:)` on the tile with `.navigationTransition(.zoom(sourceID:in:))` on the new screen.",
                code: """
                struct Album: Identifiable {
                    let id: Int
                    let name: String
                    let color: Color
                }

                @Namespace private var zoom
                @State private var selected: Album?
                let albums = [
                    Album(id: 0, name: "Pink", color: .pink),
                    Album(id: 1, name: "Orange", color: .orange),
                    Album(id: 2, name: "Teal", color: .teal),
                    Album(id: 3, name: "Indigo", color: .indigo),
                ]

                LazyVGrid(columns: [GridItem(), GridItem()], spacing: 12) {
                    ForEach(albums) { album in
                        Button {
                            selected = album
                        } label: {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(album.color.gradient)
                                .frame(height: 100)
                        }
                        .matchedTransitionSource(id: album.id, in: zoom)
                    }
                }
                .fullScreenCover(item: $selected) { album in
                    Rectangle()
                        .fill(album.color.gradient)
                        .ignoresSafeArea()
                        .overlay {
                            Button("Close") { selected = nil }
                                .buttonStyle(.borderedProminent)
                        }
                        .navigationTransition(.zoom(sourceID: album.id, in: zoom))
                }
                """,
                minHeight: 260,
                aside: Aside(.note, "The same two modifiers work for a `NavigationLink` push and a `.sheet`. Put `.navigationTransition` on the destination's root view.")
            ) {
                ZoomExample()
            }
            .id("zoom")
        }
    }
}

// MARK: - Examples

private struct TabIndicatorExample: View {
    @State private var selected = "Music"
    @Namespace private var tabs

    var body: some View {
        HStack(spacing: 4) {
            ForEach(["Music", "Podcasts", "Books"], id: \.self) { tab in
                Text(tab)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(selected == tab ? .white : .primary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background {
                        if selected == tab {
                            Capsule()
                                .fill(.indigo)
                                .matchedGeometryEffect(id: "highlight", in: tabs)
                        }
                    }
                    .contentShape(.capsule)
                    .onTapGesture {
                        withAnimation(.snappy) { selected = tab }
                    }
                    .accessibilityAddTraits(.isButton)
            }
        }
        .padding(4)
        .background(.fill.tertiary, in: .capsule)
    }
}

private struct ExpandingCardExample: View {
    @State private var isExpanded = false
    @Namespace private var card

    var body: some View {
        VStack {
            if isExpanded {
                VStack(alignment: .leading, spacing: 12) {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.orange.gradient)
                        .matchedGeometryEffect(id: "art", in: card)
                        .frame(height: 160)
                    Text("Sunset Drive")
                        .font(.title2.bold())
                        .matchedGeometryEffect(id: "title", in: card)
                    Text("A playlist for golden hour.")
                        .foregroundStyle(.secondary)
                }
            } else {
                HStack(spacing: 12) {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.orange.gradient)
                        .matchedGeometryEffect(id: "art", in: card)
                        .frame(width: 56, height: 56)
                    Text("Sunset Drive")
                        .font(.headline)
                        .matchedGeometryEffect(id: "title", in: card)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .frame(maxWidth: 360)
        .contentShape(.rect)
        .onTapGesture {
            withAnimation(.spring(duration: 0.5, bounce: 0.2)) {
                isExpanded.toggle()
            }
        }
        .accessibilityAddTraits(.isButton)
        .accessibilityLabel("Sunset Drive")
        .accessibilityHint(isExpanded ? "Collapses the card" : "Expands the card")
    }
}

private struct ZoomAlbum: Identifiable {
    let id: Int
    let name: String
    let color: Color
}

private struct ZoomExample: View {
    @Namespace private var zoom
    @State private var selected: ZoomAlbum?
    private let albums = [
        ZoomAlbum(id: 0, name: "Pink", color: .pink),
        ZoomAlbum(id: 1, name: "Orange", color: .orange),
        ZoomAlbum(id: 2, name: "Teal", color: .teal),
        ZoomAlbum(id: 3, name: "Indigo", color: .indigo),
    ]

    var body: some View {
        LazyVGrid(columns: [GridItem(), GridItem()], spacing: 12) {
            ForEach(albums) { album in
                Button {
                    selected = album
                } label: {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(album.color.gradient)
                        .frame(height: 100)
                        .overlay(alignment: .bottomLeading) {
                            Text(album.name)
                                .font(.headline)
                                .foregroundStyle(.white)
                                .padding(10)
                        }
                }
                .buttonStyle(.plain)
                .matchedTransitionSource(id: album.id, in: zoom)
            }
        }
        .frame(maxWidth: 420)
        .fullScreenCover(item: $selected) { album in
            Rectangle()
                .fill(album.color.gradient)
                .ignoresSafeArea()
                .overlay {
                    VStack(spacing: 20) {
                        Text(album.name)
                            .font(.largeTitle.bold())
                            .foregroundStyle(.white)
                        Button("Close") { selected = nil }
                            .buttonStyle(.borderedProminent)
                            .tint(.black.opacity(0.3))
                    }
                }
                .navigationTransition(.zoom(sourceID: album.id, in: zoom))
        }
    }
}

private struct MatchedThumbnail: View {
    var body: some View {
        HStack(spacing: 16) {
            RoundedRectangle(cornerRadius: 8)
                .fill(.orange.gradient)
                .frame(width: 36, height: 36)
            Image(systemName: "arrow.right")
                .font(.headline)
                .foregroundStyle(.secondary)
            RoundedRectangle(cornerRadius: 16)
                .fill(.orange.gradient)
                .frame(width: 96, height: 96)
                .overlay(alignment: .bottomLeading) {
                    Capsule()
                        .fill(.white.opacity(0.8))
                        .frame(width: 50, height: 8)
                        .padding(10)
                }
        }
    }
}
