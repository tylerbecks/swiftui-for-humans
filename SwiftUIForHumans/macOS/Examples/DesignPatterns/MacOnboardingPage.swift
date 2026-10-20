import SwiftUI

extension ComponentPage {
    static let onboarding = ComponentPage(
        id: "onboarding",
        title: "Onboarding",
        summary: "Open straight into the app, and teach in context instead of up front.",
        category: .patterns,
        kind: .concept,
        symbol: "hand.wave",
        availability: ["macOS 15.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/scene/defaultlaunchbehavior(_:)",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/onboarding",
        aliases: [
            "first launch", "first run", "welcome screen", "welcome window", "splash screen",
            "launch screen", "tutorial", "walkthrough", "coach marks", "TipKit", "TipView",
            "defaultLaunchBehavior", "getting started",
        ],
        related: ["welcome-window", "empty-states", "windows-tabs", "settings-pattern", "privacy-permissions"],
        notes: [
            "**The Mac doesn't use launch screens.** iPhone and iPad apps show one while they start. A Mac app just opens its windows, so make that fast.",
            "**Tips are for features people haven't found.** Apple's TipKit docs say to use them sparingly, not to walk people through the app or to advertise.",
        ],
        api: [
            APIItem("`.defaultLaunchBehavior(.presented)`", "Shows a window at launch when none are restored."),
            APIItem("`.restorationBehavior(.disabled)`", "Keeps a window from coming back on relaunch."),
            APIItem("`ContentUnavailableView`", "An empty state with a next step."),
            APIItem("`TipView`", "A TipKit tip, placed by the feature it explains."),
            APIItem("`Tips.configure()`", "Loads TipKit's saved state at launch."),
        ],
        guidelines: [
            Guideline(
                "Open straight into the app.",
                "People want to start right away. Skip the splash screen, or keep it brief enough to take in at a glance.",
                good: "The first window has the app in it.",
                bad: "A splash screen people have to wait through."
            ) {
                MacWindowFrame(title: "Notes", width: 240, height: 120) {
                    DPNotesList()
                }
            } bad: {
                MacWindowFrame(title: "Notes", width: 240, height: 120) {
                    DPSplash()
                }
            },
            Guideline(
                "Teach by doing.",
                "People remember what they try more than what they read. Let them safely perform the task you're teaching."
            ),
            Guideline(
                "Prefer tips in context to one long tour.",
                "A tip next to the feature, when it's relevant, is easier to absorb than a list of everything up front."
            ),
            Guideline(
                "Make a tutorial optional, and easy to find later.",
                "If people skip it, don't show it on every launch. Put it somewhere like the Help menu."
            ),
            Guideline(
                "Put off setup.",
                "Start with sensible defaults. Ask for permission when someone first uses the feature that needs it, and for ratings after they've used the app a while."
            ),
            Guideline(
                "Leave legal text to the App Store.",
                "The store shows agreements and disclaimers before people download. Don't open the app with them."
            ),
        ],
        sources: [
            "https://developer.apple.com/design/human-interface-guidelines/onboarding",
            "https://developer.apple.com/design/human-interface-guidelines/launching",
            "https://developer.apple.com/design/human-interface-guidelines/offering-help",
            "https://developer.apple.com/documentation/swiftui/scene/defaultlaunchbehavior(_:)",
            "https://developer.apple.com/documentation/swiftui/scene/restorationbehavior(_:)",
            "https://developer.apple.com/documentation/swiftui/contentunavailableview",
            "https://developer.apple.com/documentation/tipkit",
            "https://developer.apple.com/documentation/tipkit/tips/configure(_:)",
        ],
        reviewed: "October 2026"
    ) {
        DPWelcomeContent(isCompact: true)
            .frame(width: 180)
            .scaleEffect(0.85)
            .allowsHitTesting(false)
            .accessibilityHidden(true)
    } content: { page in
        MacOnboardingArticle(page: page)
    }
}

extension Catalog {
    /// A welcome window, as a document app might show at launch.
    static let onboardingDemoWindow = DemoWindow(id: "dp-welcome", title: "Welcome to Scribble", size: CGSize(width: 520, height: 340)) {
        DPWelcomeContent(isCompact: false)
            .padding(28)
    }
}

// MARK: - Page

private struct MacOnboardingArticle: View {
    let page: ComponentPage

    var body: some View {
        ArticlePage(page: page) {
            Prose("The best introduction is the app itself. A Mac app should launch quickly, open into a window people can use right away, and bring back the windows they had open last time. Mac apps don't show a launch screen, and most don't need a splash screen either.")
            Prose("If people need help getting started, make it quick, hands-on, and optional, and spread it out as tips where they're useful.")

            VStack(alignment: .leading, spacing: 16) {
                SectionTitle("A good first launch")
                ConnectFacts(rows: [
                    ("Launch", "Open fast, into a window with the app in it, or an empty state that says what to do first."),
                    ("Restore", "On later launches, reopen windows where people left them. See [Windows & tabs](catalog://windows-tabs)."),
                    ("Teach", "Short tips beside the features they explain, shown when they matter."),
                    ("Ask later", "Permissions when a feature needs them. Ratings and purchases after people have used the app."),
                ])
            }

            VStack(alignment: .leading, spacing: 16) {
                SectionTitle("Try it")
                Prose("Document apps often open a welcome window when there's no document to restore: a quick way to start a new one or open a recent one.")
                OpenDemoWindowButton(id: "dp-welcome", label: "Open the Welcome Window")
                    .controlSize(.large)
            }
            .id("demo")

            VStack(alignment: .leading, spacing: 16) {
                SectionTitle("Examples")
                    .id("examples")
                VStack(alignment: .leading, spacing: 44) {
                    ExampleCard(
                        title: "A welcome window when nothing is restored",
                        caption: "A `Window` with `.defaultLaunchBehavior(.presented)` opens at launch when there are no document windows to bring back.",
                        code: """
                        @main
                        struct ScribbleApp: App {
                            var body: some Scene {
                                DocumentGroup(newDocument: NoteDocument()) { file in
                                    NoteEditor(document: file.$document)
                                }

                                Window("Welcome to Scribble", id: "welcome") {
                                    WelcomeView()
                                }
                                .defaultLaunchBehavior(.presented)
                                .restorationBehavior(.disabled)
                            }
                        }
                        """,
                        minHeight: 300,
                        aside: Aside(.note, "`.restorationBehavior(.disabled)` keeps the welcome window from reopening on its own along with people's documents.")
                    ) {
                        MacWindowFrame(title: "Welcome to Scribble", width: 440, height: 270) {
                            DPWelcomeContent(isCompact: false)
                                .padding(20)
                        }
                    }

                    ExampleCard(
                        title: "An empty state that shows the way",
                        caption: "Use `ContentUnavailableView` for the first, empty window: say what goes here and offer the first step.",
                        code: """
                        ContentUnavailableView {
                            Label("No Notes Yet", systemImage: "note.text")
                        } description: {
                            Text("Notes you write appear here.")
                        } actions: {
                            Button("New Note") { }
                                .buttonStyle(.borderedProminent)
                        }
                        """,
                        minHeight: 220
                    ) {
                        ContentUnavailableView {
                            Label("No Notes Yet", systemImage: "note.text")
                        } description: {
                            Text("Notes you write appear here.")
                        } actions: {
                            Button("New Note") { }
                                .buttonStyle(.borderedProminent)
                        }
                    }

                    ExampleCard(
                        title: "A tip beside the feature",
                        caption: "Define a `Tip`, configure TipKit once at launch, and place a `TipView` next to what it explains.",
                        code: """
                        import TipKit

                        struct PinTip: Tip {
                            var title: Text { Text("Pin important notes") }
                            var message: Text? { Text("Pinned notes stay at the top of the list.") }
                            var image: Image? { Image(systemName: "pin") }
                        }

                        @main
                        struct NotesApp: App {
                            init() {
                                try? Tips.configure()
                            }

                            var body: some Scene {
                                WindowGroup { NotesView() }
                            }
                        }

                        struct NotesView: View {
                            var body: some View {
                                VStack {
                                    TipView(PinTip(), arrowEdge: .bottom)
                                    Button("Pin", systemImage: "pin") { }
                                }
                            }
                        }
                        """,
                        minHeight: 200,
                        aside: Aside(.note, "The preview draws the tip. This catalog doesn't set up TipKit, so a real `TipView` wouldn't appear here.")
                    ) {
                        DPTipDrawing()
                    }
                }
            }
        }
    }
}

// MARK: - Samples

/// The welcome window's content: app icon, title, and a way in.
private struct DPWelcomeContent: View {
    let isCompact: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 24) {
            VStack(spacing: 10) {
                Image(systemName: "note.text")
                    .font(.system(size: isCompact ? 28 : 40))
                    .foregroundStyle(.white)
                    .frame(width: isCompact ? 54 : 76, height: isCompact ? 54 : 76)
                    .background(.orange.gradient, in: .rect(cornerRadius: isCompact ? 12 : 17))
                Text("Welcome to Scribble")
                    .font(isCompact ? .headline : .title3.bold())
                    .multilineTextAlignment(.center)
                if !isCompact {
                    VStack(spacing: 8) {
                        Button("New Note") { }
                            .buttonStyle(.borderedProminent)
                        Button("Open…") { }
                    }
                    .controlSize(.large)
                    .padding(.top, 6)
                }
            }
            .frame(maxWidth: .infinity)
            if !isCompact {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Recent")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    ForEach(["Trip Notes", "Groceries", "Book Club"], id: \.self) { name in
                        Label(name, systemImage: "doc.text")
                    }
                }
                .frame(width: 150, alignment: .leading)
            }
        }
    }
}

/// A short list of notes, for the Do of the first guideline.
private struct DPNotesList: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(["Trip Notes", "Groceries", "Book Club"], id: \.self) { note in
                Label(note, systemImage: "note.text")
                    .font(.caption)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(10)
    }
}

/// A splash screen, for the Don't of the first guideline.
private struct DPSplash: View {
    var body: some View {
        VStack(spacing: 6) {
            Text("Scribble")
                .font(.title2.bold())
                .foregroundStyle(.orange)
            ProgressView()
                .controlSize(.small)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

/// A drawing of a TipKit tip above a Pin button.
private struct DPTipDrawing: View {
    var body: some View {
        VStack(spacing: 10) {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "pin")
                    .font(.title3)
                    .foregroundStyle(.tint)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Pin important notes")
                        .font(.headline)
                    Text("Pinned notes stay at the top of the list.")
                        .foregroundStyle(.secondary)
                }
                Image(systemName: "xmark")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(12)
            .frame(width: 300, alignment: .leading)
            .background(.background, in: .rect(cornerRadius: 12))
            .overlay {
                RoundedRectangle(cornerRadius: 12).strokeBorder(.separator)
            }
            Button("Pin", systemImage: "pin") { }
        }
    }
}
