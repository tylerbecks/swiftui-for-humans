import SwiftUI

extension ComponentPage {
    static let viewThatFits = ComponentPage(
        id: "view-that-fits",
        title: "ViewThatFits",
        summary: "Give it a few versions of a view, and it shows the first one that fits.",
        category: .layout,
        symbol: "rectangle.compress.vertical",
        availability: ["iOS 16.0+", "macOS 13.0+", "visionOS 1.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/viewthatfits",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/layout",
        aliases: ["responsive", "media query", "container query", "breakpoint", "@media", "adaptive layout", "fallback", "truncate"],
        related: ["geometry-reader", "stacks", "layout-basics"],
        notes: [
            "**It's a container query, not a media query.** It reacts to the space its parent offers, not the screen. To adapt to the whole window, read the `horizontalSizeClass` environment value.",
            "**If nothing fits, you get the last option.** Make the last one the smallest, so it fits almost anywhere.",
        ],
        api: [
            APIItem("`ViewThatFits { }`", "Shows the first child that fits, checking width and height."),
            APIItem("`ViewThatFits(in: .horizontal)`", "Checks only the width, and ignores height."),
            APIItem("`.fixedSize()`", "Makes an option report its full, unwrapped size."),
            APIItem("`\\.horizontalSizeClass`", "An environment value, `.compact` or `.regular`, for whole-screen changes."),
            APIItem("`AnyLayout`", "Switches between `HStackLayout` and `VStackLayout` and keeps state."),
        ],
        guidelines: [
            Guideline(
                "Stack side-by-side items when they don't fit.",
                "With large text or a narrow window, a row gets cramped. Switching to a column keeps every label on one line.",
                good: "The buttons stack and keep their full labels.",
                bad: "A fixed row squeezes the label onto three lines."
            ) {
                VTFButtonsSample(adapts: true)
            } bad: {
                VTFButtonsSample(adapts: false)
            },
            Guideline(
                "Show less, but keep every feature.",
                "When space is tight, move actions into a menu rather than dropping them, so the app works the same at every size."
            ),
        ]
    ) {
        VTFThumbnail()
    } content: { page in
        ViewThatFitsDemo(page: page)
    }
}

// MARK: - Thumbnail

private struct VTFThumbnail: View {
    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 8) {
                Label("Reply", systemImage: "arrowshape.turn.up.left")
                Label("Share", systemImage: "square.and.arrow.up")
            }
            .font(.caption.weight(.medium))
            .padding(8)
            .frame(width: 190)
            .background(.fill.tertiary, in: .rect(cornerRadius: 10))
            HStack(spacing: 14) {
                Image(systemName: "arrowshape.turn.up.left")
                Image(systemName: "square.and.arrow.up")
            }
            .font(.caption.weight(.medium))
            .padding(8)
            .frame(width: 90)
            .background(.fill.tertiary, in: .rect(cornerRadius: 10))
        }
        .foregroundStyle(.tint)
    }
}

// MARK: - Config

private struct VTFConfig {
    var width: Double = 300
    var axis: VTFAxis = .horizontal
}

private enum VTFAxis: DemoOption {
    case both, horizontal, vertical

    var label: String {
        switch self {
        case .both: "Both (default)"
        case .horizontal: ".horizontal"
        case .vertical: ".vertical"
        }
    }
}

// MARK: - Demo

private struct ViewThatFitsDemo: View {
    let page: ComponentPage

    var body: some View {
        DemoPage(
            page: page,
            initial: VTFConfig(),
            usage: """
            ViewThatFits(in: .horizontal) {
                Text("Free shipping on orders over $50")
                Text("Free shipping over $50")
                Text("Free shipping")
            }
            .font(.headline)
            """,
            usageNote: Aside(.note, "List the options from largest to smallest. Each is measured at its ideal size, so text is checked on one line, unwrapped.")
        ) { $config in
            VStack(spacing: 16) {
                VTFToolbar(axis: config.axis)
                    .frame(width: config.width)
                    .padding(.vertical, 6)
                    .background {
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(.secondary, style: StrokeStyle(lineWidth: 1, dash: [4, 3]))
                    }
                    .frame(maxWidth: .infinity)

                VStack(spacing: 6) {
                    HStack {
                        Text("Container width")
                        Spacer()
                        Text("\(Int(config.width)) pt")
                            .monospacedDigit()
                            .foregroundStyle(.secondary)
                    }
                    .font(.subheadline)
                    Slider(value: $config.width, in: 60...300, step: 1)
                        .accessibilityIdentifier("vtf-width")
                }
                .frame(maxWidth: 300)
                Text("Drag to shrink the container. The option that's shown changes from labels, to icons, to a menu.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
        } controls: { $config in
            Section("Container") {
                ValueSlider("Width", value: $config.width, in: 60...300, step: 1)
            }
            Section("ViewThatFits") {
                OptionPicker("Axis", selection: $config.axis)
            }
        } code: { config in
            let open = switch config.axis {
            case .both: "ViewThatFits {"
            case .horizontal: "ViewThatFits(in: .horizontal) {"
            case .vertical: "ViewThatFits(in: .vertical) {"
            }
            return """
            \(open)
                // 1. Icons and titles
                HStack(spacing: 16) {
                    Button("Reply", systemImage: "arrowshape.turn.up.left") {}
                    Button("Forward", systemImage: "arrowshape.turn.up.right") {}
                    Button("Delete", systemImage: "trash", role: .destructive) {}
                }
                .fixedSize()
                // 2. Icons only
                HStack(spacing: 20) {
                    Button("Reply", systemImage: "arrowshape.turn.up.left") {}
                    Button("Forward", systemImage: "arrowshape.turn.up.right") {}
                    Button("Delete", systemImage: "trash", role: .destructive) {}
                }
                .labelStyle(.iconOnly)
                // 3. Everything in a menu
                Menu("Actions", systemImage: "ellipsis.circle") {
                    Button("Reply", systemImage: "arrowshape.turn.up.left") {}
                    Button("Forward", systemImage: "arrowshape.turn.up.right") {}
                    Button("Delete", systemImage: "trash", role: .destructive) {}
                }
                .labelStyle(.iconOnly)
            }
            .frame(width: \(Int(config.width)))
            """
        } examples: {
            ExampleCard(
                title: "Side by side, else stacked",
                caption: "Put an `HStack` first and a `VStack` second, so buttons sit in a row only when there's room.",
                code: """
                ViewThatFits {
                    HStack {
                        Button("Not now") {}
                            .buttonStyle(.bordered)
                        Button("Turn on notifications") {}
                            .buttonStyle(.borderedProminent)
                    }
                    VStack {
                        Button("Turn on notifications") {}
                            .buttonStyle(.borderedProminent)
                        Button("Not now") {}
                            .buttonStyle(.bordered)
                    }
                }
                """
            ) {
                VStack(spacing: 14) {
                    ForEach([300.0, 200], id: \.self) { width in
                        ViewThatFits {
                            HStack {
                                Button("Not now") {}
                                    .buttonStyle(.bordered)
                                Button("Turn on notifications") {}
                                    .buttonStyle(.borderedProminent)
                            }
                            VStack {
                                Button("Turn on notifications") {}
                                    .buttonStyle(.borderedProminent)
                                Button("Not now") {}
                                    .buttonStyle(.bordered)
                            }
                        }
                        .frame(width: width)
                        .padding(.vertical, 8)
                        .background {
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(.secondary, style: StrokeStyle(lineWidth: 1, dash: [4, 3]))
                        }
                    }
                }
            }

            ExampleCard(
                title: "Scroll only when needed",
                caption: "Use `ViewThatFits(in: .vertical)` with a `ScrollView` fallback, so only text that's too tall scrolls.",
                code: """
                let terms = Text("By continuing you agree to the terms…")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                ViewThatFits(in: .vertical) {
                    terms
                    ScrollView { terms }
                }
                .frame(height: 120)
                """,
                aside: Aside(.note, "The short text on top doesn't scroll or bounce. The long text below falls back to the `ScrollView`.")
            ) {
                VStack(spacing: 14) {
                    ForEach([false, true], id: \.self) { long in
                        ViewThatFits(in: .vertical) {
                            VTFTerms(long: long)
                            ScrollView { VTFTerms(long: long) }
                        }
                        .frame(height: 120, alignment: .top)
                        .padding(10)
                        .background {
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(.secondary, style: StrokeStyle(lineWidth: 1, dash: [4, 3]))
                        }
                    }
                }
            }
        }
    }
}

private struct VTFTerms: View {
    var long = true

    var body: some View {
        Text(long ? longText : "By continuing you agree to the terms of service.")
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)
    }

    private var longText: String {
        "By continuing you agree to the terms of service. We keep your data on your device, never sell it, and you can delete it at any time from Settings. Scroll to read the rest of this paragraph, which is deliberately long so that it doesn't fit in the box."
    }
}

/// The three options in the main demo, largest first.
private struct VTFToolbar: View {
    let axis: VTFAxis

    var body: some View {
        switch axis {
        case .both: ViewThatFits { options }
        case .horizontal: ViewThatFits(in: .horizontal) { options }
        case .vertical: ViewThatFits(in: .vertical) { options }
        }
    }

    @ViewBuilder
    private var options: some View {
        HStack(spacing: 16) { buttons }
            .fixedSize()
        HStack(spacing: 20) { buttons }
            .labelStyle(.iconOnly)
        Menu("Actions", systemImage: "ellipsis.circle") { buttons }
            .labelStyle(.iconOnly)
    }

    @ViewBuilder
    private var buttons: some View {
        Button("Reply", systemImage: "arrowshape.turn.up.left") {}
        Button("Forward", systemImage: "arrowshape.turn.up.right") {}
        Button("Delete", systemImage: "trash", role: .destructive) {}
    }
}

// MARK: - Guideline samples

/// Two buttons in a narrow container: adapting with ViewThatFits, or a fixed row.
private struct VTFButtonsSample: View {
    let adapts: Bool

    var body: some View {
        Group {
            if adapts {
                ViewThatFits {
                    row
                    VStack { buttons }
                }
            } else {
                row
            }
        }
        .frame(width: 200)
    }

    private var row: some View {
        HStack { buttons }
    }

    @ViewBuilder
    private var buttons: some View {
        Button("Not Now") {}
            .buttonStyle(.bordered)
        Button("Turn On Notifications") {}
            .buttonStyle(.borderedProminent)
    }
}
