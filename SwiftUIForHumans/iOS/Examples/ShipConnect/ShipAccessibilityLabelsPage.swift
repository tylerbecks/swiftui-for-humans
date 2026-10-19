import SwiftUI

extension ComponentPage {
    static let shipAccessibilityLabels = ComponentPage(
        id: "accessibility-labels",
        title: "Accessibility Labels",
        summary: "Accessibility Nutrition Labels show which accessibility features your app supports.",
        category: .appStoreConnect,
        kind: .reference,
        symbol: "accessibility",
        availability: [],
        docsURL: "https://developer.apple.com/help/app-store-connect/manage-app-accessibility/overview-of-accessibility-nutrition-labels",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/accessibility",
        aliases: [
            "accessibility label", "accessibility nutrition label", "App Accessibility", "a11y",
            "VoiceOver", "Voice Control", "Larger Text", "Dynamic Type", "Dark Interface",
            "Differentiate Without Color", "Sufficient Contrast", "Reduced Motion",
            "Captions", "Audio Descriptions", "WCAG", "Guideline 2.3",
        ],
        related: ["accessibility", "voiceover", "dynamic-type", "color-and-contrast", "reduce-motion", "dark-mode"],
        notes: [
            "**Answer per device.** Support can differ between iPhone and iPad, so App Store Connect asks for each one, and you should test on each.",
            "**Add an accessibility URL.** An optional link on your product page can explain settings, caption languages, or areas that aren't supported yet.",
            "**Re-check with every update.** Apple asks you to keep the labels accurate as your app changes.",
        ],
        api: [
            APIItem("`.accessibilityLabel(_:)`", "What VoiceOver reads for a view."),
            APIItem("`.font(.body)`", "Text styles scale with Larger Text."),
            APIItem("`\\.dynamicTypeSize`", "The person's text size."),
            APIItem("`\\.accessibilityReduceMotion`", "Reduce Motion is on."),
        ],
        guidelines: [
            Guideline(
                "Claim a feature only if every common task works.",
                "Apple's rule is that people can finish all the app's common tasks with that feature alone. App Review can ask you to fix misleading labels."
            ),
            Guideline(
                "Don't rely on color alone.",
                "To claim Differentiate Without Color Alone, pair color with a shape, symbol, or text.",
                good: "A symbol and a word, as well as color.",
                bad: "Only the dot's color tells them apart."
            ) {
                LabelsStatusSample(usesSymbols: true)
            } bad: {
                LabelsStatusSample(usesSymbols: false)
            },
            Guideline(
                "Let text grow without cutting it off.",
                "Larger Text means text reaches at least 200% without overlapping or heavy truncation. System Zoom doesn't count.",
                good: "The row wraps at large sizes.",
                bad: "The title is cut off."
            ) {
                LabelsTextSample(wraps: true)
            } bad: {
                LabelsTextSample(wraps: false)
            },
            Guideline(
                "Keep a dark interface dark.",
                "For Dark Interface, every common task has to stay dark. A sudden white screen can hurt someone with light sensitivity.",
                good: "Every screen stays dark.",
                bad: "A bright sheet flashes in Dark Mode."
            ) {
                LabelsDarkSample(hasBrightSheet: false)
            } bad: {
                LabelsDarkSample(hasBrightSheet: true)
            },
        ],
        sources: [
            "https://developer.apple.com/help/app-store-connect/manage-app-accessibility/overview-of-accessibility-nutrition-labels",
            "https://developer.apple.com/help/app-store-connect/manage-app-accessibility/manage-accessibility-nutrition-labels",
            "https://developer.apple.com/help/app-store-connect/manage-app-accessibility/voiceover-evaluation-criteria",
            "https://developer.apple.com/help/app-store-connect/manage-app-accessibility/larger-text-evaluation-criteria",
            "https://developer.apple.com/help/app-store-connect/manage-app-accessibility/dark-interface-evaluation-criteria",
            "https://developer.apple.com/design/human-interface-guidelines/accessibility",
        ],
        reviewed: "October 2026"
    ) {
        LabelsThumbnail()
    } content: { page in
        LabelsArticle(page: page)
    }
}

// MARK: - Features

private struct A11yFeature: Identifiable {
    let id: String
    let symbol: String
    let detail: String

    static let all = [
        A11yFeature(id: "VoiceOver", symbol: "speaker.wave.2", detail: "Use the app by touch and speech, without seeing the screen."),
        A11yFeature(id: "Voice Control", symbol: "mic", detail: "Tap, swipe, and type by voice."),
        A11yFeature(id: "Larger Text", symbol: "textformat.size", detail: "Text grows to at least 200%."),
        A11yFeature(id: "Dark Interface", symbol: "moon", detail: "Screens stay dark to avoid bright light."),
        A11yFeature(id: "Differentiate Without Color Alone", symbol: "square.on.circle", detail: "Shapes or text back up color."),
        A11yFeature(id: "Sufficient Contrast", symbol: "circle.righthalf.filled", detail: "Text and icons stand out from the background."),
        A11yFeature(id: "Reduced Motion", symbol: "figure.walk", detail: "Animations that can cause discomfort are toned down."),
        A11yFeature(id: "Captions", symbol: "captions.bubble", detail: "Timed text for speech and sounds in video and audio."),
        A11yFeature(id: "Audio Descriptions", symbol: "text.bubble", detail: "Narration of what happens on screen in video."),
    ]
}

// MARK: - Thumbnail

private struct LabelsThumbnail: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label("VoiceOver", systemImage: "speaker.wave.2")
            Label("Larger Text", systemImage: "textformat.size")
            Label("Dark Interface", systemImage: "moon")
        }
        .font(.caption.weight(.medium))
        .padding(12)
        .background(.fill.tertiary, in: .rect(cornerRadius: 12))
    }
}

// MARK: - Page

private struct LabelsArticle: View {
    let page: ComponentPage

    var body: some View {
        ArticlePage(page: page) {
            Prose("Accessibility Nutrition Labels are a section on your App Store product page that lists the accessibility features your app supports, like VoiceOver and Larger Text. People see them on iOS 26 and later, and can even search for them, as in “VoiceOver note taking apps”.")
            Aside(.note, "As of October 2026 the labels are voluntary. Apple says they'll become required for new apps and updates over time. If you don't answer, your page says you haven't indicated support yet.")

            SectionTitle("The nine features")
                .id("features")
            Prose("Turn on the features your app supports to build a sample of the section. Apple suggests evaluating them in this order, starting with VoiceOver.")
            LabelsBuilder()

            SectionTitle("How to evaluate your app")
            ConnectSteps(steps: [
                "List your app's **common tasks**: its main features, plus first launch, login, purchases, and settings.",
                "Turn on one feature, starting with VoiceOver, and learn to use it well.",
                "Try every common task with only that feature, on each device you support.",
                "Claim the feature only if all of them work. Note the gaps and fix them next release.",
            ])
            Aside(.important, "Zoom and Hover Text don't count as Larger Text support. They work in every app already, so your own text has to grow, through Dynamic Type or an in-app size setting.")

            SectionTitle("Add them in App Store Connect")
            ConnectSteps(steps: [
                "Open your app and choose **App Accessibility** in the sidebar, then **Get Started**.",
                "Pick a device, say whether you support any features, and select them.",
                "Click **Publish**. You can only publish for devices with a live version, and changes can take 24 hours to show.",
            ])

            SectionTitle("In SwiftUI")
                .id("swiftui")
            ExampleCard(
                title: "Label icon-only buttons",
                caption: "Use `.accessibilityLabel(_:)` so VoiceOver and Voice Control have a name to read and say.",
                code: """
                Button {
                    isFavorite.toggle()
                } label: {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                }
                .accessibilityLabel("Favorite")
                """,
                minHeight: 120
            ) {
                LabelsFavoriteSample()
            }
            ExampleCard(
                title: "Stack rows at large text sizes",
                caption: "Read `dynamicTypeSize` and stack the row at accessibility sizes, shown second here, so text never overlaps.",
                code: """
                @Environment(\\.dynamicTypeSize) private var size

                var body: some View {
                    let layout = size.isAccessibilitySize
                        ? AnyLayout(VStackLayout(alignment: .leading))
                        : AnyLayout(HStackLayout())
                    layout {
                        Text("Delivery")
                        Spacer()
                        Text("Tomorrow, 9–11 AM")
                            .foregroundStyle(.secondary)
                    }
                }
                """,
                minHeight: 120
            ) {
                VStack(alignment: .leading, spacing: 14) {
                    LabelsDeliveryRow()
                    Divider()
                    LabelsDeliveryRow()
                        .environment(\.dynamicTypeSize, .accessibility2)
                }
                .frame(maxWidth: 300)
            }
        }
    }
}

// MARK: - Builder

private struct LabelsBuilder: View {
    @State private var supported: Set<String> = ["VoiceOver", "Larger Text", "Dark Interface"]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 10) {
                Text("Accessibility")
                    .font(.headline)
                if supported.isEmpty {
                    Text("The developer hasn't indicated support for any features.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                } else {
                    FlowLayout(spacing: 8) {
                        ForEach(A11yFeature.all.filter { supported.contains($0.id) }) { feature in
                            Label(feature.id, systemImage: feature.symbol)
                                .font(.caption.weight(.medium))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(.fill.tertiary, in: .capsule)
                        }
                    }
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.background, in: .rect(cornerRadius: 12))
            .animation(.smooth, value: supported)

            VStack(spacing: 0) {
                ForEach(A11yFeature.all) { feature in
                    if feature.id != A11yFeature.all[0].id {
                        Divider().padding(.leading, 40)
                    }
                    Toggle(isOn: binding(for: feature.id)) {
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: feature.symbol)
                                .foregroundStyle(.tint)
                                .frame(width: 28)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(feature.id)
                                    .font(.subheadline.weight(.semibold))
                                Text(feature.detail)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                    .padding(.vertical, 10)
                }
            }
        }
        .padding(16)
        .cardStyle()
    }

    private func binding(for id: String) -> Binding<Bool> {
        Binding {
            supported.contains(id)
        } set: { isOn in
            if isOn { supported.insert(id) } else { supported.remove(id) }
        }
    }
}

// MARK: - Examples

private struct LabelsFavoriteSample: View {
    @State private var isFavorite = false

    var body: some View {
        Button {
            isFavorite.toggle()
        } label: {
            Image(systemName: isFavorite ? "heart.fill" : "heart")
                .font(.title)
                .contentTransition(.symbolEffect(.replace))
        }
        .accessibilityLabel("Favorite")
    }
}

private struct LabelsDeliveryRow: View {
    @Environment(\.dynamicTypeSize) private var size

    var body: some View {
        let layout = size.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading))
            : AnyLayout(HStackLayout())
        layout {
            Text("Delivery")
            Spacer()
            Text("Tomorrow, 9–11 AM")
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Do / Don't

private struct LabelsStatusSample: View {
    let usesSymbols: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            row("Server 1", ok: true)
            row("Server 2", ok: false)
        }
        .frame(width: 200)
    }

    private func row(_ name: String, ok: Bool) -> some View {
        HStack {
            Text(name)
            Spacer()
            if usesSymbols {
                Label(ok ? "Up" : "Down", systemImage: ok ? "checkmark.circle.fill" : "xmark.octagon.fill")
                    .foregroundStyle(ok ? .green : .red)
            } else {
                Circle()
                    .fill(ok ? .green : .red)
                    .frame(width: 12, height: 12)
            }
        }
        .font(.subheadline)
    }
}

private struct LabelsTextSample: View {
    let wraps: Bool

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            Image(systemName: "envelope.fill")
                .foregroundStyle(.tint)
            Text("Your order has shipped and arrives Friday")
                .lineLimit(wraps ? nil : 1)
                .fixedSize(horizontal: false, vertical: wraps)
        }
        .font(.title3)
        .frame(width: 220, alignment: .leading)
    }
}

private struct LabelsDarkSample: View {
    let hasBrightSheet: Bool

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(["Inbox", "Drafts", "Sent"], id: \.self) { name in
                    Text(name)
                        .font(.caption)
                        .foregroundStyle(.white)
                }
                Spacer()
            }
            .padding(12)
            .frame(width: 150, height: 120, alignment: .topLeading)
            .background(Color(white: 0.08))

            RoundedRectangle(cornerRadius: 10)
                .fill(hasBrightSheet ? Color.white : Color(white: 0.17))
                .frame(height: 60)
                .overlay {
                    Text("Compose")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(hasBrightSheet ? .black : .white)
                }
        }
        .frame(width: 150, height: 120)
        .clipShape(.rect(cornerRadius: 12))
    }
}
