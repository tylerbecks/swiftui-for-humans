import SwiftUI

extension ComponentPage {
    static let viewThatFits = ComponentPage(
        id: "view-that-fits",
        title: "ViewThatFits & window sizes",
        summary: "Adapt a layout to the window's actual width, since Mac windows resize freely.",
        category: .layout,
        kind: .concept,
        symbol: "arrow.left.and.right.square",
        availability: ["macOS 13.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/viewthatfits",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/layout",
        aliases: [
            "ViewThatFits", "onGeometryChange", "GeometryReader", "responsive", "media query", "@media",
            "breakpoint", "container query", "size class", "horizontalSizeClass", "AnyLayout", "window size",
            "minimum window size", "defaultSize", "windowResizability", "adaptive layout",
        ],
        related: ["stacks-grid", "split-views", "window-group", "windows-layout"],
        notes: [
            "**Size classes don't help on the Mac.** The horizontal size class there is always `.regular`, however narrow the window gets.",
            "**Keep geometry work light.** Geometry can change on every frame of a scroll or resize. Return a small value, like a `Bool`, so the action runs only when it flips.",
        ],
        api: [
            APIItem("`ViewThatFits(in:)`", "Shows the first child that fits."),
            APIItem("`.onGeometryChange(for:of:action:)`", "Reports a value from the view's size."),
            APIItem("`AnyLayout`", "Switches layouts without losing state."),
            APIItem("`HStackLayout`, `VStackLayout`", "Stacks you can put in `AnyLayout`."),
            APIItem("`.frame(minWidth:minHeight:)`", "On the root view: the window's minimum."),
            APIItem("`.defaultSize(width:height:)`", "A scene's size when its window first opens."),
        ],
        guidelines: [
            Guideline(
                "Keep every feature available at every size.",
                "A narrow window can show fewer controls at once, but the rest should move into a menu, not disappear.",
                good: "Narrow: the extra actions move into a menu.",
                bad: "Narrow: the extra actions are just gone."
            ) {
                NarrowToolbarSample(showsOverflow: true)
            } bad: {
                NarrowToolbarSample(showsOverflow: false)
            },
            Guideline(
                "Plan for very wide and very narrow windows.",
                "People resize Mac windows to any shape. Check your layout at the smallest size you allow and at the largest."
            ),
            Guideline(
                "Change the layout in ways people recognize.",
                "When space runs out, rearrange what's there, like stacking side-by-side items, rather than switching to a different design."
            ),
        ]
    ) {
        VStack(spacing: 6) {
            HStack(spacing: 4) {
                ForEach(0..<3) { _ in
                    RoundedRectangle(cornerRadius: 3).fill(.tint.opacity(0.6)).frame(width: 30, height: 16)
                }
            }
            .padding(5)
            .frame(width: 120)
            .overlay(RoundedRectangle(cornerRadius: 5).strokeBorder(.separator))
            HStack(spacing: 4) {
                RoundedRectangle(cornerRadius: 3).fill(.tint.opacity(0.6)).frame(width: 30, height: 16)
                Image(systemName: "ellipsis.circle").font(.caption)
            }
            .padding(5)
            .frame(width: 70)
            .overlay(RoundedRectangle(cornerRadius: 5).strokeBorder(.separator))
        }
    } content: { page in
        MacViewThatFitsArticle(page: page)
    }
}

extension Catalog {
    /// A window to resize: its layout changes with the width.
    static let viewThatFitsDemoWindow = DemoWindow(id: "view-that-fits-window", title: "Resize Me", size: CGSize(width: 640, height: 360)) {
        ResizeDemoWindow()
    }
}

// MARK: - Page

private struct MacViewThatFitsArticle: View {
    let page: ComponentPage
    @State private var toolbarWidth = 460.0
    @State private var cardWidth = 520.0

    var body: some View {
        ArticlePage(page: page) {
            Prose("On iPhone and iPad, layouts often switch on the size class. On the Mac it's always `.regular`, and a window can be any width people drag it to. So adapt to the space you actually have.")
            Prose("SwiftUI gives you two tools. `ViewThatFits` tries a few layouts in order and shows the first that fits. `onGeometryChange` reports the width, so you can pick a layout at a breakpoint you choose, like a CSS media query.")
            OpenDemoWindowButton(id: "view-that-fits-window", label: "Open a Window to Resize")
                .controlSize(.large)

            SectionTitle("ViewThatFits")
            ExampleCard(
                title: "Labels, then icons, then a menu",
                caption: "`ViewThatFits(in: .horizontal)` shows the first child whose ideal width fits; drag the slider to narrow the space.",
                code: """
                ViewThatFits(in: .horizontal) {
                    HStack {
                        Button("New Note", systemImage: "square.and.pencil") { }
                        Button("Share", systemImage: "square.and.arrow.up") { }
                        Button("Delete", systemImage: "trash") { }
                    }
                    HStack {
                        Button("New Note", systemImage: "square.and.pencil") { }
                        Button("Share", systemImage: "square.and.arrow.up") { }
                        Button("Delete", systemImage: "trash") { }
                    }
                    .labelStyle(.iconOnly)
                    Menu("Actions", systemImage: "ellipsis.circle") {
                        Button("New Note", systemImage: "square.and.pencil") { }
                        Button("Share", systemImage: "square.and.arrow.up") { }
                        Button("Delete", systemImage: "trash") { }
                    }
                    .fixedSize()
                }
                """,
                minHeight: 160,
                aside: Aside(.note, "List the children in order of preference, usually widest first. `in: .horizontal` checks only the width, so a child that's taller still counts as fitting.")
            ) {
                VStack(spacing: 16) {
                    ActionsThatFit()
                        .frame(width: toolbarWidth, alignment: .leading)
                        .padding(8)
                        .overlay(RoundedRectangle(cornerRadius: 8).strokeBorder(.separator))
                    ResizeSlider(width: $toolbarWidth, range: 100...480)
                }
            }

            SectionTitle("onGeometryChange")
            ExampleCard(
                title: "Stack the columns below a width you choose",
                caption: "`.onGeometryChange` turns the width into a `Bool`, and `AnyLayout` switches between `HStackLayout` and `VStackLayout` without losing the state of the views inside.",
                code: """
                @State private var isNarrow = false

                let layout = isNarrow
                    ? AnyLayout(VStackLayout(alignment: .leading))
                    : AnyLayout(HStackLayout(alignment: .top))

                layout {
                    Image(systemName: "photo")
                        .font(.largeTitle)
                        .frame(width: 120, height: 80)
                        .background(.fill.tertiary, in: .rect(cornerRadius: 8))
                    VStack(alignment: .leading) {
                        Text("Lake Tahoe").font(.headline)
                        Text("Clear water and granite peaks.")
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .onGeometryChange(for: Bool.self) { proxy in
                    proxy.size.width < 360
                } action: { narrow in
                    isNarrow = narrow
                }
                """,
                minHeight: 230,
                aside: Aside(.note, "The transform runs often, so keep it cheap and return the smallest value you need. The action runs only when that value changes.")
            ) {
                VStack(spacing: 16) {
                    AdaptiveCard()
                        .frame(width: cardWidth)
                        .padding(8)
                        .overlay(RoundedRectangle(cornerRadius: 8).strokeBorder(.separator))
                    ResizeSlider(width: $cardWidth, range: 200...560)
                }
            }

            SectionTitle("Which one?")
            ConnectFacts(rows: [
                ("ViewThatFits", "You have a few finished layouts, from roomy to compact, and want the biggest one that fits its content."),
                ("onGeometryChange", "You want a breakpoint you choose, or a number to work with, like how many columns to show."),
                ("horizontalSizeClass", "Not on the Mac. It's always `.regular`, so it can't tell a narrow window from a wide one."),
            ])

            SectionTitle("Window sizes")
            Prose("Give the window's root view a minimum size with `.frame(minWidth:minHeight:)`, so people can't shrink it until your layout breaks. Set the size a new window opens at with `.defaultSize` on the scene.")
            CodeBlock(code: """
            @main
            struct NotesApp: App {
                var body: some Scene {
                    WindowGroup {
                        ContentView()
                            .frame(minWidth: 480, minHeight: 320)
                    }
                    .defaultSize(width: 900, height: 600)
                }
            }
            """)
            Aside(.note, "By default, a window can't get smaller than its content's minimum size. A `Settings` window also can't get bigger than its content. Change that with `.windowResizability(_:)`.")
        }
    }
}

// MARK: - Samples

private struct ActionsThatFit: View {
    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack { buttons }
            HStack { buttons }
                .labelStyle(.iconOnly)
            Menu("Actions", systemImage: "ellipsis.circle") { buttons }
                .fixedSize()
        }
    }

    @ViewBuilder private var buttons: some View {
        Button("New Note", systemImage: "square.and.pencil") {}
        Button("Share", systemImage: "square.and.arrow.up") {}
        Button("Delete", systemImage: "trash") {}
    }
}

private struct AdaptiveCard: View {
    @State private var isNarrow = false

    var body: some View {
        let layout = isNarrow ? AnyLayout(VStackLayout(alignment: .leading)) : AnyLayout(HStackLayout(alignment: .top))
        layout {
            SceneryView(.lake)
                .frame(width: 120, height: 80)
                .clipShape(.rect(cornerRadius: 8))
            VStack(alignment: .leading) {
                Text("Lake Tahoe").font(.headline)
                Text("Clear water and granite peaks.")
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .onGeometryChange(for: Bool.self) { proxy in
            proxy.size.width < 360
        } action: { narrow in
            withAnimation(.snappy) { isNarrow = narrow }
        }
    }
}

/// A slider that stands in for resizing the window.
private struct ResizeSlider: View {
    @Binding var width: Double
    let range: ClosedRange<Double>

    var body: some View {
        HStack {
            Image(systemName: "arrow.left.and.right")
                .foregroundStyle(.secondary)
            Slider(value: $width, in: range) {
                Text("Width")
            }
            .labelsHidden()
            .frame(width: 180)
            Text("\(Int(width)) pt")
                .monospacedDigit()
                .foregroundStyle(.secondary)
                .frame(width: 52, alignment: .trailing)
        }
        .font(.callout)
    }
}

/// A narrow toolbar for the "keep every feature" guideline.
private struct NarrowToolbarSample: View {
    let showsOverflow: Bool

    var body: some View {
        MacWindowFrame(title: "Notes", width: 220, height: 90) {
            Color.clear
        } toolbar: {
            Image(systemName: "square.and.pencil")
            if showsOverflow {
                Image(systemName: "ellipsis.circle")
            }
        }
    }
}

// MARK: - Demo window

private struct ResizeDemoWindow: View {
    @State private var width = 0.0

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            ActionsThatFit()
            AdaptiveCard()
            Spacer()
            Text("Window content is \(Int(width)) points wide. Drag the window's edge.")
                .font(.callout)
                .foregroundStyle(.secondary)
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .onGeometryChange(for: Double.self) { proxy in
            proxy.size.width.rounded()
        } action: { newWidth in
            width = newWidth
        }
    }
}
