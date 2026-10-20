import SwiftUI

extension ComponentPage {
    static let accessibilityOverview = ComponentPage(
        id: "accessibility",
        title: "Accessibility",
        summary: "What to support from day one so everyone can use your app.",
        category: .accessibility,
        kind: .concept,
        symbol: "accessibility",
        availability: [],
        docsURL: "https://developer.apple.com/documentation/swiftui/view-accessibility",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/accessibility",
        aliases: ["a11y", "accessible", "screen reader", "aria", "WCAG", "inclusive design", "disability", "assistive technology", "Accessibility Nutrition Labels"],
        related: ["voiceover", "dynamic-type", "reduce-motion", "color-and-contrast", "accessibility-labels", "typography"],
        notes: [
            "**Accessibility Inspector finds problems for you.** It ships with Xcode and highlights missing labels, small targets, and low contrast while your app runs.",
            "**As of October 2026, Accessibility Nutrition Labels are voluntary.** You declare in App Store Connect which features your app supports, and they show on your product page. Apple says they'll become required for new apps and updates over time, without a date yet.",
        ],
        api: [
            APIItem("`.accessibilityLabel(_:)`", "What VoiceOver says for a view."),
            APIItem("`.font(.body)`", "A text style that grows with Dynamic Type."),
            APIItem("`\\.accessibilityReduceMotion`", "True when people turn on Reduce Motion."),
            APIItem("`\\.colorSchemeContrast`", "`.increased` when Increase Contrast is on."),
            APIItem("`\\.dynamicTypeSize`", "The text size people picked in Settings."),
        ],
        guidelines: [
            Guideline(
                "Make controls at least 44 × 44 points.",
                "Small targets are hard to hit, especially with limited dexterity. Grow the tappable area with padding or a frame, even if the icon stays small.",
                good: "A 44 pt target around a small icon.",
                bad: "The target is only as big as the glyph."
            ) {
                A11yTargetDemo(size: 44)
            } bad: {
                A11yTargetDemo(size: 22)
            },
            Guideline(
                "Leave room between controls.",
                "Spacing matters as much as size. About 12 points around controls with a background, and about 24 around plain icons, keeps people from tapping the wrong one."
            ),
            Guideline(
                "Offer a button for every gesture.",
                "If a swipe deletes or a long press opens options, give people another way to do it too, such as a visible button or menu."
            ),
            Guideline(
                "Don't hide things on a timer.",
                "Messages that dismiss themselves can vanish before someone using VoiceOver or reading slowly gets to them. Let people close them."
            ),
        ],
        sources: [
            "https://developer.apple.com/design/human-interface-guidelines/accessibility",
            "https://developer.apple.com/documentation/swiftui/view-accessibility",
            "https://developer.apple.com/documentation/accessibility/performing-accessibility-testing-for-your-app",
            "https://developer.apple.com/documentation/accessibility/performing-accessibility-audits-for-your-app",
            "https://developer.apple.com/help/app-store-connect/manage-app-accessibility/overview-of-accessibility-nutrition-labels",
        ],
        reviewed: "October 2026"
    ) {
        HStack(spacing: 18) {
            Image(systemName: "accessibility")
                .font(.system(size: 44))
                .foregroundStyle(.tint)
            VStack(alignment: .leading, spacing: 8) {
                Label("VoiceOver", systemImage: "speaker.wave.2")
                Label("Larger Text", systemImage: "textformat.size")
                Label("Reduce Motion", systemImage: "circle.dotted.and.circle")
            }
            .font(.caption.weight(.medium))
            .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Accessibility")
    } content: { page in
        AccessibilityOverviewArticle(page: page)
    }
}

// MARK: - Page

private struct AccessibilityOverviewArticle: View {
    let page: ComponentPage

    var body: some View {
        ArticlePage(page: page) {
            Prose("People use iPhone in many ways: listening with **VoiceOver**, reading at a much larger text size, with motion turned down, or without telling certain colors apart. SwiftUI's standard controls handle a lot of this for you. Your work is mostly in the custom parts: icon-only buttons, fixed sizes, your own animations, and color choices.")

            VStack(alignment: .leading, spacing: 16) {
                SectionTitle("Try the settings")
                A11ySettingsDemo()
                Aside(.note, "The switches here only change this preview. Your app reads the real settings from the environment, as in the code above.")
            }
            .id("demo")

            VStack(alignment: .leading, spacing: 16) {
                SectionTitle("Start here")
                Prose("Check these off as you build. Each one links to a page that shows how.")
                Checklist(pageID: page.id, items: [
                    ChecklistItem("labels", "Label every icon-only button", "Give it a short name VoiceOver can read, like “Share”.", page: "voiceover"),
                    ChecklistItem("decorative", "Hide decorative images", "Use `Image(decorative:)` or `.accessibilityHidden(true)`.", page: "voiceover"),
                    ChecklistItem("text-styles", "Use text styles, not fixed sizes", "`.font(.body)` grows with the person's text size.", page: "dynamic-type"),
                    ChecklistItem("ax-sizes", "Check the largest text sizes", "Text should wrap, not overlap or cut off.", page: "dynamic-type"),
                    ChecklistItem("motion", "Swap big motion for fades", "Do it when Reduce Motion is on, and add Pause to anything that loops.", page: "reduce-motion"),
                    ChecklistItem("contrast", "Meet 4.5:1 contrast for text", "In light and dark mode.", page: "color-and-contrast"),
                    ChecklistItem("color-alone", "Never rely on color alone", "Add an icon, shape, or word to every status.", page: "color-and-contrast"),
                    ChecklistItem("targets", "Make targets at least 44 × 44 pt", "Add padding around small icons.", page: "button"),
                    ChecklistItem("nutrition-labels", "Tell the App Store what you support", "Accessibility Nutrition Labels in App Store Connect.", page: "accessibility-labels"),
                ])
            }
            .id("checklist")
        }
    }
}

// MARK: - Settings demo

private struct A11ySettingsDemo: View {
    @State private var largeText = false
    @State private var reduceMotion = false
    @State private var shapes = false
    @State private var voiceOver = false

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("One card, built to respond to four settings. Turn them on to see what changes.")
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            VStack(spacing: 0) {
                PreviewCard(minHeight: 260, isAttached: true) {
                    VStack(spacing: 16) {
                        A11yDeliveryCard(reduceMotion: reduceMotion, showsShapes: shapes)
                            .dynamicTypeSize(largeText ? .accessibility2 : .large)
                            .frame(maxWidth: 360)
                        if voiceOver {
                            A11ySpeech("Order 1042, Out for delivery, Arrives today by 6 PM")
                                .transition(.opacity)
                        }
                    }
                    .animation(.default, value: voiceOver)
                }
                Divider()
                FlowLayout(spacing: 8) {
                    A11ySimToggle(title: "Larger Text", symbol: "textformat.size", isOn: $largeText)
                    A11ySimToggle(title: "Reduce Motion", symbol: "circle.dotted.and.circle", isOn: $reduceMotion)
                    A11ySimToggle(title: "Shapes, Not Just Color", symbol: "square.on.circle", isOn: $shapes)
                    A11ySimToggle(title: "VoiceOver", symbol: "speaker.wave.2", isOn: $voiceOver)
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                Divider()
                CodeBlock(code: A11yDeliveryCard.code, isCollapsible: true, isAttached: true)
            }
            .cardStyle()
        }
    }
}

/// A delivery status card that reads the accessibility settings.
private struct A11yDeliveryCard: View {
    let reduceMotion: Bool
    let showsShapes: Bool
    @Environment(\.dynamicTypeSize) private var typeSize
    @ScaledMetric(relativeTo: .title2) private var iconBox = 48.0
    @State private var bounce = false

    var body: some View {
        let layout = typeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: 10))
            : AnyLayout(HStackLayout(spacing: 12))
        layout {
            Image(systemName: "box.truck.fill")
                .font(.title2)
                .foregroundStyle(.white)
                .frame(width: iconBox, height: iconBox)
                .background(.blue.gradient, in: .rect(cornerRadius: 12))
                .offset(y: bounce && !reduceMotion ? -4 : 0)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 4) {
                Text("Order 1042")
                    .font(.headline)
                HStack(spacing: 6) {
                    Image(systemName: showsShapes ? "shippingbox.circle.fill" : "circle.fill")
                        .font(showsShapes ? .subheadline : .system(size: 8))
                        .foregroundStyle(.green)
                    Text("Out for delivery")
                        .font(.subheadline)
                }
                Text("Arrives today by 6 PM")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
        }
        .padding(14)
        .background(.background.secondary, in: .rect(cornerRadius: 16))
        .accessibilityElement(children: .combine)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
                bounce = true
            }
        }
    }

    static let code = """
    struct DeliveryCard: View {
        @Environment(\\.dynamicTypeSize) private var typeSize
        @Environment(\\.accessibilityReduceMotion) private var reduceMotion
        @State private var bounce = false

        var body: some View {
            let layout = typeSize.isAccessibilitySize
                ? AnyLayout(VStackLayout(alignment: .leading))
                : AnyLayout(HStackLayout())
            layout {
                Image(systemName: "box.truck.fill")
                    .font(.title2)
                    .offset(y: bounce && !reduceMotion ? -4 : 0)
                    .accessibilityHidden(true)
                VStack(alignment: .leading) {
                    Text("Order 1042").font(.headline)
                    Label("Out for delivery", systemImage: "shippingbox.circle.fill")
                        .font(.subheadline)
                    Text("Arrives today by 6 PM")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .accessibilityElement(children: .combine)
            .onAppear {
                withAnimation(.easeInOut.repeatForever()) { bounce = true }
            }
        }
    }
    """
}

// MARK: - Guideline previews

/// An icon button whose tappable area is drawn as a dashed outline.
private struct A11yTargetDemo: View {
    let size: CGFloat

    var body: some View {
        HStack(spacing: 14) {
            ForEach(["star", "square.and.arrow.up", "trash"], id: \.self) { symbol in
                Image(systemName: symbol)
                    .font(.body)
                    .frame(width: size, height: size)
                    .overlay {
                        RoundedRectangle(cornerRadius: 6)
                            .strokeBorder(.tint, style: StrokeStyle(lineWidth: 1, dash: [3, 3]))
                    }
            }
        }
        .foregroundStyle(.tint)
        .accessibilityHidden(true)
    }
}
