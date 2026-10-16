import SwiftUI

extension ComponentPage {
    static let dynamicType = ComponentPage(
        id: "dynamic-type",
        title: "Dynamic Type",
        summary: "Let text grow to the size people choose, and keep layouts readable when it does.",
        category: .accessibility,
        kind: .concept,
        symbol: "textformat.size.larger",
        availability: ["iOS 15.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/dynamictypesize",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/typography",
        aliases: ["larger text", "text size", "font scaling", "rem", "zoom", "responsive text", "accessibility sizes", "ScaledMetric", "UIContentSizeCategory", "preferredFont"],
        related: ["typography", "font", "view-that-fits", "accessibility", "sf-symbols"],
        notes: [
            "**There are 12 sizes.** Seven standard ones, from `xSmall` to `xxxLarge`, plus five accessibility sizes, `accessibility1` to `accessibility5`. The default is `large`, where `.body` is 17 points.",
            "**Try it in Settings.** Accessibility > Display & Text Size > Larger Text, with Larger Accessibility Sizes turned on, unlocks the five biggest sizes.",
        ],
        api: [
            APIItem("`.font(.body)`", "A text style. All of them scale."),
            APIItem("`@ScaledMetric`", "Scales your own numbers, like an icon size."),
            APIItem("`\\.dynamicTypeSize`", "The current size, to adapt a layout."),
            APIItem("`.isAccessibilitySize`", "True for the five largest sizes."),
            APIItem("`ViewThatFits`", "Picks the first layout that fits."),
            APIItem("`.dynamicTypeSize(_:)`", "Sets or limits the size for a view."),
            APIItem("`.accessibilityShowsLargeContentViewer()`", "A big popup for items that must stay small."),
        ],
        guidelines: [
            Guideline(
                "Let text wrap instead of cutting it off.",
                "At large sizes, a one-line limit hides most of the text. Let it take as many lines as it needs, especially in scrolling content.",
                good: "The message wraps onto more lines.",
                bad: "`.lineLimit(1)` cuts it to a few words."
            ) {
                Text("Your package was left at the front door.")
                    .font(.body)
                    .dynamicTypeSize(.accessibility2)
                    .frame(maxWidth: 260, alignment: .leading)
            } bad: {
                Text("Your package was left at the front door.")
                    .font(.body)
                    .lineLimit(1)
                    .dynamicTypeSize(.accessibility2)
                    .frame(maxWidth: 260, alignment: .leading)
            },
            Guideline(
                "Stack side-by-side items at large sizes.",
                "A label and a value on one line crowd each other when text is huge. Put the value under the label instead.",
                good: "Stacked at an accessibility size.",
                bad: "Squeezed into one row."
            ) {
                DynamicTypeDetailRow(stacks: true)
                    .dynamicTypeSize(.accessibility2)
                    .frame(maxWidth: 260)
            } bad: {
                DynamicTypeDetailRow(stacks: false)
                    .dynamicTypeSize(.accessibility2)
                    .frame(maxWidth: 260)
            },
            Guideline(
                "Grow meaningful icons with the text.",
                "An icon that carries meaning should stay as easy to see as the words next to it. SF Symbols scale with the font automatically."
            ),
            Guideline(
                "Keep the most important things at the top.",
                "When text grows, the layout gets longer. Keep the order the same so people don't lose track of the main content."
            ),
            Guideline(
                "Support at least 200 percent.",
                "Apple asks for text that can reach about twice its default size. On iPhone, the accessibility sizes go past 200 percent at `accessibility3` and past 300 percent at `accessibility5`."
            ),
        ],
        sources: [
            "https://developer.apple.com/design/human-interface-guidelines/typography",
            "https://developer.apple.com/design/human-interface-guidelines/accessibility",
            "https://developer.apple.com/documentation/swiftui/dynamictypesize",
            "https://developer.apple.com/documentation/swiftui/scaledmetric",
            "https://developer.apple.com/documentation/swiftui/viewthatfits",
            "https://developer.apple.com/help/app-store-connect/manage-app-accessibility/larger-text-evaluation-criteria",
        ],
        reviewed: "October 2026"
    ) {
        HStack(alignment: .lastTextBaseline, spacing: 10) {
            Text("Aa").font(.caption)
            Text("Aa").font(.body)
            Text("Aa").font(.title)
            Text("Aa").font(.largeTitle.bold())
        }
        .foregroundStyle(.primary)
        .dynamicTypeSize(.large)
        .accessibilityHidden(true)
    } content: { page in
        DynamicTypeArticle(page: page)
    }
}

// MARK: - Page

private struct DynamicTypeArticle: View {
    let page: ComponentPage

    var body: some View {
        ArticlePage(page: page) {
            Prose("**Dynamic Type** is the text size people pick in Settings. It works like `rem` on the web: text set with a text style, such as `.font(.body)`, scales with it. There are 12 sizes, and the largest makes text more than three times its default size, so your layouts need room to grow.")

            VStack(alignment: .leading, spacing: 16) {
                SectionTitle("Try every size")
                DynamicTypePlayground()
                Aside(.important, "`.font(.system(size: 17))` is a fixed size, like `px`, and never grows. Use a text style, or `@ScaledMetric` for your own numbers.")
            }
            .id("demo")

            VStack(alignment: .leading, spacing: 16) {
                SectionTitle("Examples")
                VStack(alignment: .leading, spacing: 44) {
                    ExampleCard(
                        title: "Scale your own sizes",
                        caption: "`@ScaledMetric` grows a number, like an avatar size or padding, in step with a text style.",
                        code: """
                        @ScaledMetric(relativeTo: .body) private var avatar = 40.0

                        HStack {
                            Circle()
                                .fill(.blue.gradient)
                                .frame(width: avatar, height: avatar)
                            Text("Maya Chen")
                        }
                        """,
                        minHeight: 130
                    ) {
                        VStack(alignment: .leading, spacing: 14) {
                            DynamicTypeScaledAvatar()
                            DynamicTypeScaledAvatar()
                                .dynamicTypeSize(.accessibility1)
                        }
                    }

                    ExampleCard(
                        title: "Switch layout at accessibility sizes",
                        caption: "Read `dynamicTypeSize` and check `.isAccessibilitySize` to turn a row into a column.",
                        code: """
                        @Environment(\\.dynamicTypeSize) private var typeSize

                        let layout = typeSize.isAccessibilitySize
                            ? AnyLayout(VStackLayout(alignment: .leading))
                            : AnyLayout(HStackLayout())

                        layout {
                            Text("Pickup")
                            Spacer(minLength: 0)
                            Text("Today, 4:30 PM")
                                .foregroundStyle(.secondary)
                        }
                        """,
                        minHeight: 160,
                        aside: Aside(.note, "`AnyLayout` swaps the container without rebuilding the views inside, so their state survives the switch.")
                    ) {
                        VStack(spacing: 14) {
                            DynamicTypeAdaptiveRow()
                            Divider()
                            DynamicTypeAdaptiveRow()
                                .dynamicTypeSize(.accessibility2)
                        }
                        .frame(maxWidth: 320)
                    }

                    ExampleCard(
                        title: "Let SwiftUI pick the layout",
                        caption: "`ViewThatFits` tries each child in order and shows the first that fits, here buttons side by side, then stacked.",
                        code: """
                        ViewThatFits(in: .horizontal) {
                            HStack {
                                Button("Not Now") {}
                                    .buttonStyle(.bordered)
                                Button("Turn On Notifications") {}
                                    .buttonStyle(.borderedProminent)
                            }
                            VStack {
                                Button("Turn On Notifications") {}
                                    .buttonStyle(.borderedProminent)
                                Button("Not Now") {}
                                    .buttonStyle(.bordered)
                            }
                        }
                        """,
                        minHeight: 200
                    ) {
                        VStack(spacing: 18) {
                            DynamicTypeFittingButtons()
                            Divider()
                            DynamicTypeFittingButtons()
                                .dynamicTypeSize(.accessibility1)
                        }
                        .frame(maxWidth: 330)
                    }

                    ExampleCard(
                        title: "Items that must stay small",
                        caption: "For chrome that can't grow, like a custom tab bar, add `.accessibilityShowsLargeContentViewer()`: a long press shows a big version.",
                        code: """
                        HStack(spacing: 32) {
                            Label("Home", systemImage: "house")
                            Label("Library", systemImage: "books.vertical")
                        }
                        .labelStyle(.iconOnly)
                        .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                        .accessibilityShowsLargeContentViewer()
                        """,
                        minHeight: 120,
                        aside: Aside(.important, "Use this only for small, repeated chrome. Never cap the size of body text or the main content.")
                    ) {
                        HStack(spacing: 32) {
                            Label("Home", systemImage: "house")
                            Label("Library", systemImage: "books.vertical")
                        }
                        .labelStyle(.iconOnly)
                        .font(.title2)
                        .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                        .accessibilityShowsLargeContentViewer()
                    }

                    ExampleCard(
                        title: "Preview a big size",
                        caption: "Put `.dynamicTypeSize(_:)` on a preview to check a large size without changing Settings.",
                        code: """
                        #Preview {
                            ContentView()
                                .dynamicTypeSize(.accessibility3)
                        }
                        """,
                        minHeight: 110
                    ) {
                        Text("Arrives Friday")
                            .font(.body)
                            .dynamicTypeSize(.accessibility3)
                    }
                }
            }
            .id("examples")
        }
    }
}

// MARK: - Playground

private struct DynamicTypePlayground: View {
    @State private var index = 3.0
    @State private var usesFixedSizes = false
    @State private var adapts = true

    private var size: DynamicTypeSize {
        let all = DynamicTypeSize.allCases
        return all[min(max(Int(index), 0), all.count - 1)]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Drag through all 12 sizes. Then switch to fixed sizes, or turn off the layout change, to see what breaks.")
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            VStack(spacing: 0) {
                PreviewCard(minHeight: 300, isAttached: true) {
                    DynamicTypeMessageRow(fixed: usesFixedSizes, adapts: adapts)
                        .dynamicTypeSize(size)
                        .frame(maxWidth: 340)
                        .animation(.snappy, value: size)
                }
                Divider()
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Text size")
                        Spacer()
                        Text(DynamicTypeSize.name(size))
                            .monospacedDigit()
                            .foregroundStyle(size.isAccessibilitySize ? AnyShapeStyle(.tint) : AnyShapeStyle(.secondary))
                    }
                    .font(.subheadline.weight(.medium))
                    Slider(value: $index, in: 0...Double(DynamicTypeSize.allCases.count - 1), step: 1)
                        .accessibilityLabel("Text size")
                        .accessibilityValue(DynamicTypeSize.name(size))
                    FlowLayout(spacing: 8) {
                        A11ySimToggle(title: "Fixed sizes", symbol: "lock", isOn: $usesFixedSizes)
                        A11ySimToggle(title: "Stack at big sizes", symbol: "rectangle.split.1x2", isOn: $adapts)
                    }
                    .padding(.top, 4)
                }
                .padding(14)
                Divider()
                CodeBlock(code: code, isCollapsible: true, isAttached: true)
            }
            .cardStyle()
        }
    }

    private var code: String {
        let name = usesFixedSizes ? ".system(size: 17, weight: .semibold)" : ".headline"
        let time = usesFixedSizes ? ".system(size: 15)" : ".subheadline"
        let body = usesFixedSizes ? ".system(size: 15)" : ".subheadline"
        let header = adapts ? """
        let layout = typeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading))
            : AnyLayout(HStackLayout(alignment: .firstTextBaseline))

        layout {
        """ : "HStack(alignment: .firstTextBaseline) {"
        return """
        @Environment(\\.dynamicTypeSize) private var typeSize

        \(header)
            Text("Maya Chen")
                .font(\(name))
            Spacer(minLength: 0)
            Text("9:41 AM")
                .font(\(time))
                .foregroundStyle(.secondary)
        }
        Text("Are we still on for lunch tomorrow?")
            .font(\(body))
        """
    }
}

/// A message row, like a mail inbox, that can use fixed sizes or styles.
private struct DynamicTypeMessageRow: View {
    let fixed: Bool
    let adapts: Bool
    @Environment(\.dynamicTypeSize) private var typeSize
    @ScaledMetric(relativeTo: .headline) private var avatar = 40.0

    var body: some View {
        let stack = adapts && typeSize.isAccessibilitySize
        let layout = stack
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: 2))
            : AnyLayout(HStackLayout(alignment: .firstTextBaseline))
        HStack(alignment: .top, spacing: 12) {
            if !stack {
                Text("MC")
                    .font(fixed ? .system(size: 15, weight: .semibold) : .subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(width: fixed ? 40 : avatar, height: fixed ? 40 : avatar)
                    .background(.blue.gradient, in: .circle)
            }
            VStack(alignment: .leading, spacing: 4) {
                layout {
                    Text("Maya Chen")
                        .font(fixed ? .system(size: 17, weight: .semibold) : .headline)
                    Spacer(minLength: 0)
                    Text("9:41 AM")
                        .font(fixed ? .system(size: 15) : .subheadline)
                        .foregroundStyle(.secondary)
                }
                Text("Are we still on for lunch tomorrow? I found a new place near the office.")
                    .font(fixed ? .system(size: 15) : .subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(stack ? nil : 2)
                    .fixedSize(horizontal: false, vertical: stack)
            }
        }
        .padding(14)
        .background(.background.secondary, in: .rect(cornerRadius: 16))
    }
}

extension DynamicTypeSize {
    /// A short display name, e.g. "Large (default)" or "AX3".
    fileprivate static func name(_ size: DynamicTypeSize) -> String {
        switch size {
        case .xSmall: "xSmall"
        case .small: "Small"
        case .medium: "Medium"
        case .large: "Large (default)"
        case .xLarge: "xLarge"
        case .xxLarge: "xxLarge"
        case .xxxLarge: "xxxLarge"
        case .accessibility1: "AX1"
        case .accessibility2: "AX2"
        case .accessibility3: "AX3"
        case .accessibility4: "AX4"
        case .accessibility5: "AX5"
        @unknown default: "Unknown"
        }
    }
}

// MARK: - Example views

private struct DynamicTypeScaledAvatar: View {
    @ScaledMetric(relativeTo: .body) private var avatar = 40.0

    var body: some View {
        HStack {
            Circle()
                .fill(.blue.gradient)
                .frame(width: avatar, height: avatar)
            Text("Maya Chen")
        }
    }
}

private struct DynamicTypeAdaptiveRow: View {
    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        let layout = typeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading))
            : AnyLayout(HStackLayout())
        layout {
            Text("Pickup")
            Spacer(minLength: 0)
            Text("Today, 4:30 PM")
                .foregroundStyle(.secondary)
        }
    }
}

private struct DynamicTypeFittingButtons: View {
    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack {
                Button("Not Now") {}
                    .buttonStyle(.bordered)
                Button("Turn On Notifications") {}
                    .buttonStyle(.borderedProminent)
            }
            VStack {
                Button("Turn On Notifications") {}
                    .buttonStyle(.borderedProminent)
                Button("Not Now") {}
                    .buttonStyle(.bordered)
            }
        }
    }
}

/// For the guideline pair: label and value, stacked or squeezed.
private struct DynamicTypeDetailRow: View {
    let stacks: Bool

    var body: some View {
        let layout = stacks
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: 2))
            : AnyLayout(HStackLayout())
        layout {
            Text("Delivery")
            if !stacks { Spacer(minLength: 0) }
            Text("Friday")
                .foregroundStyle(.secondary)
        }
        .lineLimit(stacks ? nil : 1)
    }
}
