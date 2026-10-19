import SwiftUI

extension ComponentPage {
    static let patternModality = ComponentPage(
        id: "modality",
        title: "Modality",
        summary: "When to use a sheet, full-screen cover, alert, or popover, and how people get out.",
        category: .patterns,
        kind: .concept,
        symbol: "rectangle.portrait.on.rectangle.portrait",
        availability: ["iOS 15.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/view/fullscreencover(ispresented:ondismiss:content:)",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/modality",
        aliases: ["modal", "dialog", "<dialog>", "overlay", "lightbox", "bottom sheet", "drawer", "presentation", "full screen modal", "fullScreenCover", "action sheet", "dismiss", "close button", "unsaved changes"],
        related: ["sheet", "alert", "popover", "confirmation-dialog", "feedback", "navigation-stack"],
        notes: [
            "**Push for drill-down, present for a side task.** Use a [NavigationStack](catalog://navigation-stack) push to go deeper into content, and a modal to step aside for a moment, like opening a `<dialog>` on the web.",
            "**`dismiss` closes whatever presented the view.** Read `@Environment(\\.dismiss)` inside the sheet or cover, not in the view that opened it.",
        ],
        api: [
            APIItem("`.sheet(isPresented:)`", "A card that slides up for a short task."),
            APIItem("`.fullScreenCover(isPresented:)`", "Covers the screen; no swipe to close."),
            APIItem("`.popover(isPresented:)`", "A bubble on iPad; a sheet on iPhone."),
            APIItem("`.confirmationDialog(...)`", "Choices for an action people started."),
            APIItem("`@Environment(\\.dismiss)`", "Closes the current sheet or cover."),
            APIItem("`.interactiveDismissDisabled()`", "Blocks swipe-to-close, e.g. with edits."),
            APIItem("`Button(role: .confirm)`", "A Done button in a sheet's toolbar."),
        ],
        guidelines: [
            Guideline(
                "Always give an obvious way out.",
                "People look for buttons at the top of a sheet, and expect to swipe it down. If there's a Done button, pair it with Cancel so finishing isn't the only exit.",
                good: "Cancel and Done, with a title.",
                bad: "Done is the only way out."
            ) {
                ModalityMiniSheet(hasCancel: true)
            } bad: {
                ModalityMiniSheet(hasCancel: false)
            },
            Guideline(
                "Ask before throwing away work.",
                "If closing would lose what people typed, whether by button or by swipe, ask first and offer to keep editing or discard."
            ),
            Guideline(
                "Keep it short, and name the task.",
                "A modal is a quick detour. A clear title, like “New Event”, helps people remember why they're there; a deep hierarchy inside makes them forget."
            ),
            Guideline(
                "Show one at a time.",
                "Close a sheet before you open another. Only an alert may appear on top of a modal, and never two alerts at once."
            ),
            Guideline(
                "Use popovers on iPad, sheets on iPhone.",
                "A popover is for a few options in a wide layout. On iPhone, SwiftUI shows a popover as a sheet, which is usually what you want."
            ),
        ],
        sources: [
            "https://developer.apple.com/design/human-interface-guidelines/modality",
            "https://developer.apple.com/design/human-interface-guidelines/sheets",
            "https://developer.apple.com/design/human-interface-guidelines/popovers",
            "https://developer.apple.com/design/human-interface-guidelines/action-sheets",
            "https://developer.apple.com/documentation/swiftui/view/fullscreencover(ispresented:ondismiss:content:)",
            "https://developer.apple.com/documentation/swiftui/view/interactivedismissdisabled(_:)",
            "https://developer.apple.com/documentation/swiftui/environmentvalues/dismiss",
            "https://developer.apple.com/documentation/swiftui/buttonrole/confirm",
            "https://developer.apple.com/documentation/swiftui/view/popover(ispresented:attachmentanchor:arrowedge:content:)",
        ],
        reviewed: "October 2026"
    ) {
        ModalityThumbnail()
    } content: { page in
        ModalityArticle(page: page)
    }
}

// MARK: - Article

private struct ModalityArticle: View {
    let page: ComponentPage

    var body: some View {
        ArticlePage(page: page) {
            Prose("A modal view takes people out of what they were doing until they finish or close it. That focus is useful for a short task or a critical choice, and annoying for anything else. Present modally only when it clearly helps, and always make the way out obvious.")

            VStack(alignment: .leading, spacing: 12) {
                SectionTitle("Which one?")
                PatternDecisionTable(rows: [
                    PatternChoice(symbol: "rectangle.bottomhalf.inset.filled", title: "[Sheet](catalog://sheet)", detail: "A short, focused task, like adding an event or picking filters."),
                    PatternChoice(symbol: "rectangle.inset.filled", title: "Full-screen cover", detail: "Photos, video, the camera, or a multistep task like editing."),
                    PatternChoice(symbol: "exclamationmark.bubble", title: "[Alert](catalog://alert)", detail: "Critical news that needs a decision now."),
                    PatternChoice(symbol: "list.bullet.rectangle", title: "[Confirmation dialog](catalog://confirmation-dialog)", detail: "Choices about an action people started, like discarding a draft."),
                    PatternChoice(symbol: "bubble.middle.top", title: "[Popover](catalog://popover)", detail: "A few options on iPad. On iPhone it becomes a sheet."),
                ])
            }

            VStack(alignment: .leading, spacing: 28) {
                SectionTitle("In SwiftUI")

                ExampleCard(
                    title: "Sheet with Cancel and Done",
                    caption: "Put Cancel on the leading side and Done on the trailing side, using the `.cancellationAction` and `.confirmationAction` placements.",
                    code: """
                    struct NewEventSheet: View {
                        @Environment(\\.dismiss) private var dismiss
                        @State private var title = ""

                        var body: some View {
                            NavigationStack {
                                Form {
                                    TextField("Title", text: $title)
                                }
                                .navigationTitle("New Event")
                                .navigationBarTitleDisplayMode(.inline)
                                .toolbar {
                                    ToolbarItem(placement: .cancellationAction) {
                                        Button("Cancel", role: .cancel) { dismiss() }
                                    }
                                    ToolbarItem(placement: .confirmationAction) {
                                        Button("Done", role: .confirm) { dismiss() }
                                            .disabled(title.isEmpty)
                                    }
                                }
                            }
                        }
                    }

                    // In the presenting view:
                    // .sheet(isPresented: $isAdding) { NewEventSheet() }
                    """
                ) {
                    ModalitySheetExample(protectsEdits: false)
                }

                ExampleCard(
                    title: "Protect unsaved changes",
                    caption: "Block the swipe with `.interactiveDismissDisabled`, and ask with a `.confirmationDialog` before Cancel throws away text.",
                    code: """
                    struct NoteSheet: View {
                        @Environment(\\.dismiss) private var dismiss
                        @State private var text = ""
                        @State private var confirmDiscard = false

                        var body: some View {
                            NavigationStack {
                                TextEditor(text: $text)
                                    .navigationTitle("New Note")
                                    .navigationBarTitleDisplayMode(.inline)
                                    .toolbar {
                                        ToolbarItem(placement: .cancellationAction) {
                                            Button("Cancel", role: .cancel) {
                                                if text.isEmpty { dismiss() } else { confirmDiscard = true }
                                            }
                                            .confirmationDialog("Discard this note?", isPresented: $confirmDiscard) {
                                                Button("Discard Note", role: .destructive) { dismiss() }
                                                Button("Keep Editing", role: .cancel) { }
                                            }
                                        }
                                        ToolbarItem(placement: .confirmationAction) {
                                            Button("Save", role: .confirm) { dismiss() }
                                        }
                                    }
                            }
                            .interactiveDismissDisabled(!text.isEmpty)
                        }
                    }
                    """,
                    aside: Aside(.note, "Try it: type something, then swipe the sheet down. It springs back instead of losing your text.")
                ) {
                    ModalitySheetExample(protectsEdits: true)
                }

                ExampleCard(
                    title: "Full-screen cover",
                    caption: "Use `.fullScreenCover` for immersive content. It can't be swiped away, so add a clear close button.",
                    code: """
                    @State private var isViewing = false

                    Button("View Photo") { isViewing = true }
                        .fullScreenCover(isPresented: $isViewing) {
                            NavigationStack {
                                Image(systemName: "photo")
                                    .font(.system(size: 120))
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .toolbar {
                                        Button("Close", systemImage: "xmark", role: .close) {
                                            isViewing = false
                                        }
                                    }
                            }
                        }
                    """
                ) {
                    ModalityCoverExample()
                }

                ExampleCard(
                    title: "Popover that adapts",
                    caption: "A `.popover` points at its button on iPad and turns into a sheet on iPhone, so one modifier fits both.",
                    code: """
                    @State private var showsFilters = false

                    Button("Filters", systemImage: "line.3.horizontal.decrease") {
                        showsFilters = true
                    }
                    .popover(isPresented: $showsFilters) {
                        VStack(alignment: .leading) {
                            Toggle("Unread Only", isOn: .constant(true))
                            Toggle("With Attachments", isOn: .constant(false))
                        }
                        .padding()
                        .frame(minWidth: 260)
                        .presentationDetents([.medium])
                    }
                    """,
                    aside: Aside(.note, "Adding `.presentationCompactAdaptation` with `.popover` keeps a real popover on iPhone, but small screens are usually better served by the sheet.")
                ) {
                    ModalityPopoverExample()
                }
            }
        }
    }
}

// MARK: - Examples

private struct ModalitySheetExample: View {
    let protectsEdits: Bool
    @State private var isPresented = false

    var body: some View {
        Button(protectsEdits ? "New Note" : "New Event") { isPresented = true }
            .buttonStyle(.borderedProminent)
            .sheet(isPresented: $isPresented) {
                if protectsEdits {
                    ModalityNoteSheet()
                } else {
                    ModalityEventSheet()
                }
            }
    }
}

private struct ModalityEventSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""

    var body: some View {
        NavigationStack {
            Form {
                TextField("Title", text: $title)
            }
            .navigationTitle("New Event")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done", role: .confirm) { dismiss() }
                        .disabled(title.isEmpty)
                }
            }
        }
    }
}

private struct ModalityNoteSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var text = ""
    @State private var confirmDiscard = false

    var body: some View {
        NavigationStack {
            TextEditor(text: $text)
                .padding(.horizontal)
                .navigationTitle("New Note")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel", role: .cancel) {
                            if text.isEmpty { dismiss() } else { confirmDiscard = true }
                        }
                        .confirmationDialog("Discard this note?", isPresented: $confirmDiscard) {
                            Button("Discard Note", role: .destructive) { dismiss() }
                            Button("Keep Editing", role: .cancel) { }
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save", role: .confirm) { dismiss() }
                    }
                }
        }
        .interactiveDismissDisabled(!text.isEmpty)
    }
}

private struct ModalityCoverExample: View {
    @State private var isViewing = false

    var body: some View {
        Button("View Photo") { isViewing = true }
            .buttonStyle(.borderedProminent)
            .fullScreenCover(isPresented: $isViewing) {
                NavigationStack {
                    Image(systemName: "photo")
                        .font(.system(size: 120))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .toolbar {
                            Button("Close", systemImage: "xmark", role: .close) {
                                isViewing = false
                            }
                        }
                }
            }
    }
}

private struct ModalityPopoverExample: View {
    @State private var showsFilters = false
    @State private var unreadOnly = true
    @State private var attachments = false

    var body: some View {
        Button("Filters", systemImage: "line.3.horizontal.decrease") {
            showsFilters = true
        }
        .buttonStyle(.bordered)
        .popover(isPresented: $showsFilters) {
            VStack(alignment: .leading) {
                Toggle("Unread Only", isOn: $unreadOnly)
                Toggle("With Attachments", isOn: $attachments)
            }
            .padding()
            .frame(minWidth: 260)
            .presentationDetents([.medium])
        }
    }
}

// MARK: - Do / Don't

/// A drawing of a sheet's top: grabber, buttons, and title.
private struct ModalityMiniSheet: View {
    let hasCancel: Bool

    var body: some View {
        VStack(spacing: 0) {
            Capsule().fill(.tertiary).frame(width: 32, height: 4).padding(.top, 6)
            HStack {
                Text(hasCancel ? "Cancel" : " ")
                    .foregroundStyle(.tint)
                    .frame(width: 56, alignment: .leading)
                Spacer()
                Text("New Event").font(.subheadline.weight(.semibold))
                Spacer()
                Text("Done")
                    .fontWeight(.semibold)
                    .foregroundStyle(.tint)
                    .frame(width: 56, alignment: .trailing)
            }
            .font(.subheadline)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            VStack(spacing: 8) {
                RoundedRectangle(cornerRadius: 8).fill(.fill.tertiary).frame(height: 30)
                RoundedRectangle(cornerRadius: 8).fill(.fill.tertiary).frame(height: 30)
            }
            .padding(.horizontal, 12)
            Spacer(minLength: 12)
        }
        .frame(width: 240, height: 140)
        .background(.background.secondary, in: UnevenRoundedRectangle(topLeadingRadius: 18, topTrailingRadius: 18))
    }
}

// MARK: - Thumbnail

private struct ModalityThumbnail: View {
    var body: some View {
        ZStack(alignment: .bottom) {
            RoundedRectangle(cornerRadius: 14)
                .fill(.fill.tertiary)
                .frame(width: 150, height: 120)
            ModalityMiniSheet(hasCancel: true)
                .scaleEffect(0.7, anchor: .bottom)
                .frame(width: 170, height: 100)
                .shadow(color: .black.opacity(0.15), radius: 8, y: -2)
        }
    }
}
