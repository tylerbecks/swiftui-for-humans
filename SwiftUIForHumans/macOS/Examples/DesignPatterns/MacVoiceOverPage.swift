import SwiftUI

extension ComponentPage {
    static let voiceOver = ComponentPage(
        id: "voiceover",
        title: "VoiceOver on the Mac",
        summary: "Labels, grouping, and rotors that let the screen reader describe your windows.",
        category: .accessibility,
        kind: .concept,
        symbol: "speaker.wave.2",
        availability: ["macOS 13.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/view-accessibility",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/voiceover",
        aliases: [
            "screen reader", "aria-label", "alt text", "aria-hidden", "role", "accessibilityLabel",
            "accessibilityValue", "accessibilityHint", "accessibilityRotor", "rotor", "accessibilityAction",
            "Accessibility Inspector", "Command-F5", "⌘F5", "NSAccessibility",
        ],
        related: ["keyboard-access", "contrast-transparency", "button", "image-symbols", "toolbar"],
        notes: [
            "**Standard controls describe themselves.** `Button`, `Toggle`, `TextField`, and `Picker` take their label and value from what they show. Add modifiers where a view has no text, or where SwiftUI can't guess.",
            "**Toolbar titles still count.** Hiding a window's title with `.toolbar(removing: .title)` is a visual change; assistive tools still get the title.",
        ],
        api: [
            APIItem("`.accessibilityLabel(_:)`", "The name VoiceOver reads, like `aria-label`."),
            APIItem("`.accessibilityValue(_:)`", "The current value, when it isn't in the label."),
            APIItem("`.accessibilityHidden(true)`", "Skips decoration, like `aria-hidden`."),
            APIItem("`.accessibilityElement(children:)`", "Reads a group as one element, or keeps its parts."),
            APIItem("`.accessibilityAddTraits(.isHeader)`", "Marks a heading people can jump to."),
            APIItem("`.accessibilityAction(named:_:)`", "An extra action, like Delete on a row."),
            APIItem("`.accessibilityRotor(_:entries:entryLabel:)`", "A custom list to jump through."),
        ],
        guidelines: [
            Guideline(
                "Label every key element.",
                "VoiceOver speaks labels people never see. An icon-only button with no label tells them nothing about what it does.",
                good: "The icon button has the label “Share”.",
                bad: "No label, so VoiceOver has only the role."
            ) {
                DPLabelSample(label: "Share")
            } bad: {
                DPLabelSample(label: nil)
            },
            Guideline(
                "Describe images that carry meaning, and hide the rest.",
                "Describe only what the image adds to nearby text. Skipping decoration saves people time."
            ),
            Guideline(
                "Give windows clear titles and sections real headings.",
                "The title is the first thing VoiceOver reports. Headings let people skim a window the way sighted people scan it."
            ),
            Guideline(
                "Say how things belong together.",
                "Closeness and alignment show sighted people that a photo and caption go together. Group them so VoiceOver reads them together too.",
                good: "Each photo is read with its caption.",
                bad: "All the photos, then all the captions."
            ) {
                DPGroupingSample(isGrouped: true)
            } bad: {
                DPGroupingSample(isGrouped: false)
            },
            Guideline(
                "Announce changes people can't see.",
                "When content appears, moves, or finishes loading somewhere else, tell assistive tools, so people's picture of the window stays right."
            ),
        ],
        sources: [
            "https://developer.apple.com/design/human-interface-guidelines/voiceover",
            "https://developer.apple.com/design/human-interface-guidelines/accessibility",
            "https://developer.apple.com/documentation/swiftui/view-accessibility",
            "https://developer.apple.com/documentation/swiftui/view/accessibilityelement(children:)",
            "https://developer.apple.com/documentation/swiftui/view/accessibilityadjustableaction(_:)",
            "https://developer.apple.com/documentation/swiftui/view/accessibilityaction(named:_:)",
            "https://developer.apple.com/documentation/swiftui/view/accessibilityrotor(_:entries:entrylabel:)",
            "https://developer.apple.com/documentation/accessibility/accessibilitynotification/announcement",
            "https://developer.apple.com/documentation/accessibility/performing-accessibility-testing-for-your-app",
            "https://developer.apple.com/documentation/accessibility/accessibility-inspector",
            "https://developer.apple.com/documentation/swiftui/customizing-window-styles-and-state-restoration-behavior-in-macos",
        ],
        reviewed: "October 2026"
    ) {
        VStack(spacing: 12) {
            Image(systemName: "square.and.arrow.up")
                .font(.title2)
                .frame(width: 40, height: 32)
                .background(.fill.tertiary, in: .rect(cornerRadius: 8))
            DPReadout(rows: [("Label", "Share"), ("Role", "Button")])
        }
        .accessibilityHidden(true)
    } content: { page in
        MacVoiceOverArticle(page: page)
    }
}

// MARK: - Page

private struct MacVoiceOverArticle: View {
    let page: ComponentPage

    var body: some View {
        ArticlePage(page: page) {
            Prose("VoiceOver is the Mac's built-in screen reader. It describes what's in a window and lets people move through it and act on it from the keyboard or trackpad, without seeing the screen. For each element it uses a **label** (what it's called), a **value** (its current state), a **role** or traits (button, heading, selected), and an optional **hint**.")
            Prose("SwiftUI fills these in for standard controls. Your job is the views it can't guess: icons, images, custom controls, and groups that only look related.")

            VStack(alignment: .leading, spacing: 16) {
                SectionTitle("Test it yourself")
                ConnectSteps(steps: [
                    "Press **⌘F5** to turn VoiceOver on. Press it again to turn it off, so you know how to leave before you start.",
                    "Do your app's main tasks, like creating, finding, and deleting an item, using only VoiceOver.",
                    "In Xcode, choose **Xcode > Open Developer Tool > Accessibility Inspector**. Run an audit to find unlabeled elements and low contrast.",
                    "Note anything you couldn't reach, couldn't tell apart, or heard in a confusing order.",
                ])
            }
            .id("test")

            VStack(alignment: .leading, spacing: 16) {
                SectionTitle("Examples")
                    .id("examples")
                Prose("Under each preview, the readout shows the label, value, and role the code gives the element, not VoiceOver's exact words.")
                VStack(alignment: .leading, spacing: 44) {
                    ExampleCard(
                        title: "Label an icon-only button",
                        caption: "Use a `Label` with `.labelStyle(.iconOnly)`: the icon shows, and the title becomes what VoiceOver reads.",
                        code: """
                        Button {
                            // Share the note
                        } label: {
                            Label("Share", systemImage: "square.and.arrow.up")
                                .labelStyle(.iconOnly)
                        }
                        """,
                        minHeight: 140,
                        aside: Aside(.note, "With a plain `Image` as the label, add `.accessibilityLabel(\"Share\")` to the button instead.")
                    ) {
                        VStack(spacing: 14) {
                            Button {
                            } label: {
                                Label("Share", systemImage: "square.and.arrow.up")
                                    .labelStyle(.iconOnly)
                            }
                            DPReadout(rows: [("Label", "Share"), ("Role", "Button")])
                        }
                    }

                    ExampleCard(
                        title: "Read a row as one element",
                        caption: "`.accessibilityElement(children: .combine)` joins the texts inside, so people hear the whole row at once.",
                        code: """
                        HStack {
                            Image(systemName: "doc.text")
                                .accessibilityHidden(true)
                            VStack(alignment: .leading) {
                                Text("Trip notes")
                                Text("Edited yesterday")
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .accessibilityElement(children: .combine)
                        """,
                        minHeight: 150,
                        aside: Aside(.important, "Don't combine a row that holds several buttons. Each needs to stay reachable, or become a named action.")
                    ) {
                        VStack(spacing: 14) {
                            HStack {
                                Image(systemName: "doc.text")
                                    .foregroundStyle(.secondary)
                                    .accessibilityHidden(true)
                                VStack(alignment: .leading) {
                                    Text("Trip notes")
                                    Text("Edited yesterday")
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .accessibilityElement(children: .combine)
                            DPReadout(rows: [("Label", "Trip notes, Edited yesterday")])
                        }
                    }

                    ExampleCard(
                        title: "Describe a custom control",
                        caption: "Give a custom control a label and a value, and `.accessibilityAdjustableAction` so VoiceOver can raise and lower it.",
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
                        minHeight: 150
                    ) {
                        StarsSample()
                    }

                    ExampleCard(
                        title: "Offer hover-only buttons as actions",
                        caption: "When a button only appears under the pointer, add the same command with `.accessibilityAction(named:)`.",
                        code: """
                        @State private var isHovering = false

                        HStack {
                            Text("Trip notes")
                            Spacer()
                            if isHovering {
                                Button("Delete", systemImage: "trash") { delete() }
                                    .labelStyle(.iconOnly)
                            }
                        }
                        .onHover { isHovering = $0 }
                        .accessibilityElement(children: .combine)
                        .accessibilityAction(named: "Delete") { delete() }
                        """,
                        minHeight: 140,
                        aside: Aside(.note, "Point at the row to see the button. The action works whether or not it's showing.")
                    ) {
                        HoverActionSample()
                    }

                    ExampleCard(
                        title: "Add a rotor for what people look for",
                        caption: "`.accessibilityRotor` on a list's container gives VoiceOver a shortcut list to jump through, like only the flagged messages.",
                        code: """
                        struct Message: Identifiable {
                            let id = UUID()
                            let subject: String
                            let isFlagged: Bool
                        }

                        let messages = [
                            Message(subject: "Lunch on Friday?", isFlagged: false),
                            Message(subject: "Contract to sign", isFlagged: true),
                            Message(subject: "Photos from the trip", isFlagged: false),
                            Message(subject: "Invoice overdue", isFlagged: true),
                        ]

                        ScrollView {
                            LazyVStack(alignment: .leading) {
                                ForEach(messages) { message in
                                    Label(message.subject, systemImage: message.isFlagged ? "flag.fill" : "envelope")
                                }
                            }
                        }
                        .accessibilityElement(children: .contain)
                        .accessibilityRotor("Flagged", entries: messages.filter(\\.isFlagged), entryLabel: \\.subject)
                        """,
                        minHeight: 180
                    ) {
                        RotorSample()
                    }

                    ExampleCard(
                        title: "Announce a change",
                        caption: "Post `AccessibilityNotification.Announcement` when something finishes out of view, like an export.",
                        code: """
                        @State private var isExporting = false

                        Button("Export PDF") {
                            isExporting = true
                            Task {
                                try? await Task.sleep(for: .seconds(1))
                                isExporting = false
                                AccessibilityNotification.Announcement("Export finished").post()
                            }
                        }
                        .disabled(isExporting)
                        """,
                        minHeight: 140
                    ) {
                        AnnounceSample()
                    }
                }
            }
        }
    }
}

// MARK: - Samples

/// What a code sample gives an element, as label / value rows.
struct DPReadout: View {
    let rows: [(String, String)]

    var body: some View {
        HStack(spacing: 12) {
            ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                HStack(spacing: 5) {
                    Text(row.0)
                        .foregroundStyle(.secondary)
                    Text(row.1)
                        .fontWeight(.medium)
                }
            }
        }
        .font(.caption.monospaced())
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(.fill.tertiary, in: .capsule)
        .accessibilityHidden(true)
    }
}

private struct StarsSample: View {
    @State private var rating = 3

    var body: some View {
        VStack(spacing: 14) {
            HStack {
                ForEach(1...5, id: \.self) { star in
                    Image(systemName: star <= rating ? "star.fill" : "star")
                        .onTapGesture { rating = star }
                }
            }
            .font(.title2)
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
            DPReadout(rows: [("Label", "Rating"), ("Value", "\(rating) of 5 stars")])
        }
    }
}

private struct HoverActionSample: View {
    @State private var isHovering = false
    @State private var isDeleted = false

    var body: some View {
        VStack(spacing: 14) {
            HStack {
                Text(isDeleted ? "Deleted" : "Trip notes")
                    .foregroundStyle(isDeleted ? .secondary : .primary)
                Spacer()
                if isHovering && !isDeleted {
                    Button("Delete", systemImage: "trash") { isDeleted = true }
                        .labelStyle(.iconOnly)
                        .buttonStyle(.borderless)
                }
            }
            .padding(.horizontal, 12)
            .frame(width: 260, height: 36)
            .background(.fill.quaternary, in: .rect(cornerRadius: 8))
            .onHover { isHovering = $0 }
            .accessibilityElement(children: .combine)
            .accessibilityAction(named: "Delete") { isDeleted = true }

            HStack(spacing: 12) {
                DPReadout(rows: [("Label", "Trip notes"), ("Action", "Delete")])
                if isDeleted {
                    Button("Restore") { isDeleted = false }
                        .controlSize(.small)
                }
            }
        }
    }
}

private struct RotorMessage: Identifiable {
    let id = UUID()
    let subject: String
    let isFlagged: Bool
}

private struct RotorSample: View {
    private let messages = [
        RotorMessage(subject: "Lunch on Friday?", isFlagged: false),
        RotorMessage(subject: "Contract to sign", isFlagged: true),
        RotorMessage(subject: "Photos from the trip", isFlagged: false),
        RotorMessage(subject: "Invoice overdue", isFlagged: true),
    ]

    var body: some View {
        VStack(spacing: 14) {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 8) {
                    ForEach(messages) { message in
                        Label(message.subject, systemImage: message.isFlagged ? "flag.fill" : "envelope")
                            .foregroundStyle(message.isFlagged ? AnyShapeStyle(.orange) : AnyShapeStyle(.primary))
                    }
                }
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(width: 280, height: 120)
            .background(.fill.quaternary, in: .rect(cornerRadius: 8))
            .accessibilityElement(children: .contain)
            .accessibilityRotor("Flagged", entries: messages.filter(\.isFlagged), entryLabel: \.subject)
            DPReadout(rows: [("Rotor", "Flagged: 2 entries")])
        }
    }
}

private struct AnnounceSample: View {
    @State private var isExporting = false
    @State private var didFinish = false

    var body: some View {
        VStack(spacing: 14) {
            Button("Export PDF") {
                isExporting = true
                didFinish = false
                Task {
                    try? await Task.sleep(for: .seconds(1))
                    isExporting = false
                    didFinish = true
                    AccessibilityNotification.Announcement("Export finished").post()
                }
            }
            .disabled(isExporting)
            DPReadout(rows: [("Announcement", isExporting ? "…" : didFinish ? "Export finished" : "none yet")])
        }
    }
}

/// An icon toolbar button, with or without a label, and its readout.
private struct DPLabelSample: View {
    let label: String?

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "square.and.arrow.up")
                .font(.title3)
                .frame(width: 40, height: 30)
                .background(.fill.tertiary, in: .rect(cornerRadius: 8))
            DPReadout(rows: [("Label", label ?? "none"), ("Role", "Button")])
        }
    }
}

/// Two photos with captions, read in pairs or in a confusing order.
private struct DPGroupingSample: View {
    let isGrouped: Bool

    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 20) {
                photo("mountain.2.fill", "Ridge")
                photo("water.waves", "Lake")
            }
            Text(isGrouped ? "Ridge photo → Lake photo" : "Photo → Photo → Ridge → Lake")
                .font(.caption.monospaced())
                .foregroundStyle(.secondary)
        }
    }

    private func photo(_ symbol: String, _ caption: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: symbol)
                .font(.title2)
                .frame(width: 70, height: 48)
                .background(.fill.tertiary, in: .rect(cornerRadius: 6))
            Text(caption)
                .font(.caption)
        }
        .overlay {
            if isGrouped {
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(Color.accentColor, style: StrokeStyle(lineWidth: 1.5, dash: [4, 3]))
                    .padding(-5)
            }
        }
    }
}
