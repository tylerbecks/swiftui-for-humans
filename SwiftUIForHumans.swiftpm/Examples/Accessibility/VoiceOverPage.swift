import SwiftUI

extension ComponentPage {
    static let voiceOver = ComponentPage(
        id: "voiceover",
        title: "VoiceOver",
        summary: "Labels, traits, and grouping that tell the screen reader what each view is.",
        category: .accessibility,
        kind: .concept,
        symbol: "speaker.wave.2",
        availability: ["iOS 14.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/view-accessibility",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/voiceover",
        aliases: ["screen reader", "aria-label", "alt text", "alt", "aria-hidden", "role", "accessibilityLabel", "accessibilityHint", "accessibilityTraits", "label", "Voice Control"],
        related: ["accessibility", "button", "label", "image", "dynamic-type"],
        notes: [
            "**Standard controls are labeled for you.** `Button`, `Toggle`, `Slider`, and `TextField` take their label and value from what they show. Add modifiers where a view has no text.",
            "**Voice Control uses the same labels.** People say a control's name to tap it, so a missing label also breaks voice commands.",
            "**Listen to it.** Turn on VoiceOver on a device, or open Accessibility Inspector in Xcode, and swipe through each screen.",
        ],
        api: [
            APIItem("`.accessibilityLabel(_:)`", "The name VoiceOver reads, like `alt` or `aria-label`."),
            APIItem("`.accessibilityValue(_:)`", "The current value, when it differs from the label."),
            APIItem("`.accessibilityHint(_:)`", "What happens when it's activated. Optional."),
            APIItem("`.accessibilityAddTraits(_:)`", "What it is: `.isHeader`, `.isButton`, `.isSelected`."),
            APIItem("`.accessibilityElement(children:)`", "Reads children as one stop: `.combine` or `.ignore`."),
            APIItem("`.accessibilityHidden(true)`", "Skips decoration, like `aria-hidden`."),
            APIItem("`.accessibilityAction(named:_:)`", "A named action in the Actions rotor."),
        ],
        guidelines: [
            Guideline(
                "Label every icon-only button.",
                "Without a label, VoiceOver has nothing useful to say, and people can't tell what the button does.",
                good: "A short name: “Share”.",
                bad: "No label, so it's just a button."
            ) {
                VoiceOverIconPair(label: "Share, Button")
            } bad: {
                VoiceOverIconPair(label: "Button", isProblem: true)
            },
            Guideline(
                "Leave the control type out of the label.",
                "VoiceOver already says “Button” from the trait. Writing it in the label makes it say it twice.",
                good: "Label “Delete”.",
                bad: "Label “Delete button”."
            ) {
                VStack(spacing: 10) {
                    Button("Delete", role: .destructive) {}.buttonStyle(.bordered)
                    A11ySpeech("Delete, Button")
                }
            } bad: {
                VStack(spacing: 10) {
                    Button("Delete", role: .destructive) {}.buttonStyle(.bordered)
                    A11ySpeech("Delete button, Button", isProblem: true)
                }
            },
            Guideline(
                "Make labels make sense on their own.",
                "People often jump between controls without hearing what's around them. “Remove AirPods” works out of context; three buttons all called “Delete” don't."
            ),
            Guideline(
                "Hide images that are only decoration.",
                "Skipping them saves people time. Describe images that carry meaning, but only what the image adds beyond nearby text."
            ),
            Guideline(
                "Mark headings.",
                "VoiceOver users can jump from heading to heading with the rotor, the way sighted people skim. Use the `.isHeader` trait on section titles."
            ),
            Guideline(
                "Keep hints short and about the result.",
                "A hint like “Saves the recipe” says what happens. Skip the gesture (“Double-tap to…”), which VoiceOver already explains."
            ),
        ],
        sources: [
            "https://developer.apple.com/design/human-interface-guidelines/voiceover",
            "https://developer.apple.com/documentation/swiftui/view-accessibility",
            "https://developer.apple.com/documentation/swiftui/accessibilitychildbehavior",
            "https://developer.apple.com/documentation/swiftui/view/accessibilityhint(_:)",
            "https://developer.apple.com/documentation/uikit/uiaccessibilityelement/accessibilityhint",
            "https://developer.apple.com/documentation/uikit/uiaccessibilityelement/accessibilitylabel",
            "https://developer.apple.com/help/app-store-connect/manage-app-accessibility/voiceover-evaluation-criteria",
        ],
        reviewed: "October 2026"
    ) {
        VStack(spacing: 12) {
            Button {
            } label: {
                Image(systemName: "square.and.arrow.up")
            }
            .buttonStyle(.bordered)
            .buttonBorderShape(.circle)
            .controlSize(.large)
            A11ySpeech("Share, Button")
        }
        .allowsHitTesting(false)
    } content: { page in
        VoiceOverArticle(page: page)
    }
}

// MARK: - Page

private struct VoiceOverArticle: View {
    let page: ComponentPage
    @State private var rating = 3
    @State private var likes = 12

    var body: some View {
        ArticlePage(page: page) {
            Prose("VoiceOver reads the screen aloud, one element at a time, as people swipe. For each element it speaks a **label** (what it is called), a **value** (its current state), its **traits** (button, heading, selected), and, after a pause, an optional **hint**. Your job is to fill those in where SwiftUI can't guess them.")

            VStack(alignment: .leading, spacing: 16) {
                SectionTitle("Hear it")
                VoiceOverPlayground()
                Aside(.note, "This is a close approximation. The exact wording and pauses depend on the device, the language, and the person's VoiceOver settings.")
            }
            .id("demo")

            VStack(alignment: .leading, spacing: 16) {
                SectionTitle("Examples")
                VStack(alignment: .leading, spacing: 44) {
                    ExampleCard(
                        title: "Label an icon-only button",
                        caption: "Use `Label` with `.labelStyle(.iconOnly)`: the icon shows, and the title becomes the VoiceOver label.",
                        code: """
                        Button {
                            // Share the recipe
                        } label: {
                            Label("Share", systemImage: "square.and.arrow.up")
                                .labelStyle(.iconOnly)
                        }
                        """,
                        minHeight: 140,
                        aside: Aside(.note, "For a plain `Image` label, add `.accessibilityLabel(\"Share\")` to the button instead.")
                    ) {
                        VStack(spacing: 12) {
                            Button {
                            } label: {
                                Label("Share", systemImage: "square.and.arrow.up")
                                    .labelStyle(.iconOnly)
                            }
                            .buttonStyle(.bordered)
                            A11ySpeech("Share, Button")
                        }
                    }

                    ExampleCard(
                        title: "Read a row as one stop",
                        caption: "`.accessibilityElement(children: .combine)` merges the texts inside, so people hear the whole row in one swipe.",
                        code: """
                        HStack {
                            Image(systemName: "fork.knife")
                                .accessibilityHidden(true)
                            VStack(alignment: .leading) {
                                Text("Lemon Pasta")
                                Text("25 min")
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .accessibilityElement(children: .combine)
                        """,
                        minHeight: 150,
                        aside: Aside(.important, "Don't combine a row that holds several buttons. Each one needs its own stop, or a named action.")
                    ) {
                        VStack(spacing: 12) {
                            VoiceOverRecipeRow()
                                .accessibilityElement(children: .combine)
                            A11ySpeech("Lemon Pasta, 25 min")
                        }
                        .frame(maxWidth: 300)
                    }

                    ExampleCard(
                        title: "Describe a custom control",
                        caption: "Give a custom control a label and a value, and `.accessibilityAdjustableAction` so people swipe up or down to change it.",
                        code: """
                        @State private var rating = 3

                        HStack {
                            ForEach(1...5, id: \\.self) { star in
                                Image(systemName: star <= rating ? "star.fill" : "star")
                                    .onTapGesture { rating = star }
                            }
                        }
                        .foregroundStyle(.orange)
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel("Rating")
                        .accessibilityValue("\\(rating) of 5 stars")
                        .accessibilityAdjustableAction { direction in
                            switch direction {
                            case .increment: rating = min(rating + 1, 5)
                            case .decrement: rating = max(rating - 1, 1)
                            @unknown default: break
                            }
                        }
                        """,
                        minHeight: 140
                    ) {
                        VStack(spacing: 12) {
                            HStack {
                                ForEach(1...5, id: \.self) { star in
                                    Image(systemName: star <= rating ? "star.fill" : "star")
                                        .font(.title2)
                                        .onTapGesture { rating = star }
                                }
                            }
                            .foregroundStyle(.orange)
                            .accessibilityElement(children: .ignore)
                            .accessibilityLabel("Rating")
                            .accessibilityValue("\(rating) of 5 stars")
                            .accessibilityAdjustableAction { direction in
                                switch direction {
                                case .increment: rating = min(rating + 1, 5)
                                case .decrement: rating = max(rating - 1, 1)
                                @unknown default: break
                                }
                            }
                            A11ySpeech("Rating, \(rating) of 5 stars, Adjustable")
                        }
                    }

                    ExampleCard(
                        title: "Name your gestures",
                        caption: "If a custom gesture does something, like double-tap to like, add `.accessibilityAction(named:)` so VoiceOver users can do it too.",
                        code: """
                        @State private var likes = 12

                        Text("Photo by Ana")
                            .onTapGesture(count: 2) { likes += 1 }
                            .accessibilityAction(named: "Like") { likes += 1 }
                        """,
                        minHeight: 140,
                        aside: Aside(.note, "Named actions show up in VoiceOver's Actions rotor. People swipe up or down to pick one.")
                    ) {
                        VStack(spacing: 8) {
                            Text("Photo by Ana")
                                .font(.headline)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 14)
                                .background(.fill.tertiary, in: .rect(cornerRadius: 12))
                                .onTapGesture(count: 2) { likes += 1 }
                                .accessibilityAction(named: "Like") { likes += 1 }
                            Label("\(likes)", systemImage: "heart.fill")
                                .font(.subheadline)
                                .foregroundStyle(.pink)
                                .contentTransition(.numericText())
                                .animation(.snappy, value: likes)
                            Text("Double-tap the card")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }

                    ExampleCard(
                        title: "Mark section headings",
                        caption: "Add `.accessibilityAddTraits(.isHeader)` to a title so people can jump to it with the rotor.",
                        code: """
                        Text("Ingredients")
                            .font(.title2.bold())
                            .accessibilityAddTraits(.isHeader)
                        """,
                        minHeight: 120,
                        aside: Aside(.note, "Some system titles may already be headings. Check in Accessibility Inspector before adding the trait.")
                    ) {
                        VStack(spacing: 12) {
                            Text("Ingredients")
                                .font(.title2.bold())
                                .accessibilityAddTraits(.isHeader)
                            A11ySpeech("Ingredients, Heading")
                        }
                    }
                }
            }
            .id("examples")
        }
    }
}

// MARK: - Playground

private enum VoiceOverSample: String, CaseIterable, Identifiable {
    case iconButton = "Icon button"
    case row = "Row"
    case heading = "Heading"

    var id: Self { self }
}

/// Change modifiers on a view and see what VoiceOver would read, one
/// swipe at a time.
private struct VoiceOverPlayground: View {
    @State private var sample: VoiceOverSample = .iconButton
    @State private var hasLabel = false
    @State private var hasHint = false
    @State private var hidesImage = false
    @State private var combines = false
    @State private var isHeader = false

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Pick a view, turn modifiers on, and see what VoiceOver reads for each swipe.")
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            VStack(spacing: 0) {
                Picker("View", selection: $sample) {
                    ForEach(VoiceOverSample.allCases) { Text($0.rawValue).tag($0) }
                }
                .pickerStyle(.segmented)
                .padding(14)
                Divider()
                PreviewCard(minHeight: 230, isAttached: true) {
                    VStack(spacing: 18) {
                        preview
                        VStack(alignment: .leading, spacing: 6) {
                            ForEach(Array(stops.enumerated()), id: \.offset) { index, stop in
                                HStack(alignment: .firstTextBaseline, spacing: 8) {
                                    Text("Swipe \(index + 1)")
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(.secondary)
                                        .frame(width: 58, alignment: .leading)
                                    A11ySpeech(stop.text, isProblem: stop.isProblem)
                                }
                            }
                        }
                    }
                    .animation(.snappy, value: stops.map(\.text))
                }
                Divider()
                FlowLayout(spacing: 8) {
                    switch sample {
                    case .iconButton:
                        A11ySimToggle(title: ".accessibilityLabel", symbol: "textformat", isOn: $hasLabel)
                        A11ySimToggle(title: ".accessibilityHint", symbol: "lightbulb", isOn: $hasHint)
                    case .row:
                        A11ySimToggle(title: ".accessibilityHidden", symbol: "eye.slash", isOn: $hidesImage)
                        A11ySimToggle(title: ".combine", symbol: "rectangle.compress.vertical", isOn: $combines)
                    case .heading:
                        A11ySimToggle(title: ".isHeader", symbol: "textformat.size.larger", isOn: $isHeader)
                    }
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                Divider()
                CodeBlock(code: code, isCollapsible: false, isAttached: true)
            }
            .cardStyle()
        }
    }

    @ViewBuilder
    private var preview: some View {
        switch sample {
        case .iconButton:
            Button {
            } label: {
                Image(systemName: "square.and.arrow.up")
            }
            .buttonStyle(.bordered)
            .buttonBorderShape(.circle)
            .controlSize(.large)
            .accessibilityLabel("Share")
        case .row:
            VoiceOverRecipeRow()
                .frame(maxWidth: 300)
        case .heading:
            Text("Ingredients")
                .font(.title2.bold())
        }
    }

    private var stops: [(text: String, isProblem: Bool)] {
        switch sample {
        case .iconButton:
            var text = hasLabel ? "Share, Button" : "Button"
            if hasHint { text += ". Shares this recipe." }
            return [(text, !hasLabel)]
        case .row:
            if combines {
                return [("Lemon Pasta, 25 min", false)]
            }
            var result: [(String, Bool)] = []
            if !hidesImage { result.append(("Image", true)) }
            result.append(("Lemon Pasta", false))
            result.append(("25 min", false))
            return result
        case .heading:
            return [(isHeader ? "Ingredients, Heading" : "Ingredients", false)]
        }
    }

    private var code: String {
        switch sample {
        case .iconButton:
            var lines = [
                "Button {",
                "    // Share",
                "} label: {",
                "    Image(systemName: \"square.and.arrow.up\")",
                "}",
            ]
            if hasLabel { lines.append(".accessibilityLabel(\"Share\")") }
            if hasHint { lines.append(".accessibilityHint(\"Shares this recipe.\")") }
            return lines.joined(separator: "\n")
        case .row:
            return """
            HStack {
                Image(systemName: "fork.knife")\(hidesImage ? "\n        .accessibilityHidden(true)" : "")
                VStack(alignment: .leading) {
                    Text("Lemon Pasta")
                    Text("25 min")
                }
            }\(combines ? "\n.accessibilityElement(children: .combine)" : "")
            """
        case .heading:
            return """
            Text("Ingredients")
                .font(.title2.bold())\(isHeader ? "\n    .accessibilityAddTraits(.isHeader)" : "")
            """
        }
    }
}

// MARK: - Shared previews

private struct VoiceOverRecipeRow: View {
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "fork.knife")
                .foregroundStyle(.white)
                .frame(width: 40, height: 40)
                .background(.orange.gradient, in: .rect(cornerRadius: 10))
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text("Lemon Pasta")
                    .font(.headline)
                Text("25 min")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
        }
        .padding(12)
        .background(.background.secondary, in: .rect(cornerRadius: 14))
    }
}

private struct VoiceOverIconPair: View {
    let label: String
    var isProblem = false

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "square.and.arrow.up")
                .font(.title3)
                .foregroundStyle(.tint)
                .frame(width: 44, height: 44)
                .background(.fill.tertiary, in: .circle)
                .accessibilityHidden(true)
            A11ySpeech(label, isProblem: isProblem)
        }
    }
}
