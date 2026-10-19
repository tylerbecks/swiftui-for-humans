import SwiftUI

extension ComponentPage {
    static let settingsPattern = ComponentPage(
        id: "settings-pattern",
        title: "What goes in Settings",
        summary: "Keep rare, app-wide options in Settings, and task options in the window they affect.",
        category: .patterns,
        kind: .concept,
        symbol: "gearshape.2",
        availability: ["macOS 11.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/settings",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/settings",
        aliases: [
            "preferences", "options", "app settings", "settings window", "⌘,", "Command-Comma",
            "view options", "defaults", "configuration", "document settings",
        ],
        related: ["settings-scene", "menu-bar-conventions", "toolbars-pattern", "onboarding"],
        notes: [
            "**Building the window is a separate page.** [Settings](catalog://settings-scene) shows the `Settings` scene, panes, and `SettingsLink` in code.",
            "**People already know ⌘,.** It opens Settings in nearly every Mac app, and adding a `Settings` scene wires it up for you.",
        ],
        api: [
            APIItem("`Settings { }`", "The scene behind Settings… and ⌘,."),
            APIItem("`@AppStorage`", "Saves a setting and updates every window."),
            APIItem("`SettingsLink`", "A button that opens the Settings window."),
            APIItem("`CommandGroup(after: .saveItem)`", "A home for document options in File."),
            APIItem("`\\.colorScheme`", "Detects light or dark instead of asking."),
        ],
        guidelines: [
            Guideline(
                "Pick defaults that work for most people.",
                "With good defaults, most people never need to open Settings before they get going."
            ),
            Guideline(
                "Keep Settings short.",
                "Every option makes the window harder to scan and the app feel less approachable. Cut the ones few people change."
            ),
            Guideline(
                "Keep task options with the task.",
                "Sorting, filtering, and showing parts of a view belong in the window, where people see the result right away.",
                good: "Sort order is a menu in the window's toolbar.",
                bad: "Sort order is buried in Settings."
            ) {
                MacWindowFrame(title: "Notes", width: 240, height: 110) {
                    DPNoteLines()
                } toolbar: {
                    Image(systemName: "arrow.up.arrow.down")
                }
            } bad: {
                MacWindowFrame(title: "General", width: 240, height: 110) {
                    DPSettingsRow(label: "Sort notes by", value: "Date")
                }
            },
            Guideline(
                "Don't copy system settings.",
                "Appearance, scrolling, and accessibility are set for the whole Mac. A copy in your app suggests the system choice doesn't apply.",
                good: "Only the app's own options.",
                bad: "An Appearance option that repeats System Settings."
            ) {
                MacWindowFrame(title: "General", width: 240, height: 110) {
                    DPSettingsRow(label: "New notes use", value: "Body")
                }
            } bad: {
                MacWindowFrame(title: "General", width: 240, height: 110) {
                    DPSettingsRow(label: "Appearance", value: "Dark")
                }
            },
            Guideline(
                "Don't ask for what you can find out.",
                "Read whether the Mac is in Dark Mode, or which devices are connected, instead of making people tell you."
            ),
        ],
        sources: [
            "https://developer.apple.com/design/human-interface-guidelines/settings",
            "https://developer.apple.com/design/human-interface-guidelines/the-menu-bar",
            "https://developer.apple.com/documentation/swiftui/settings",
            "https://developer.apple.com/documentation/swiftui/settingslink",
            "https://developer.apple.com/documentation/swiftui/commandgroupplacement",
            "https://developer.apple.com/documentation/swiftui/environmentvalues/colorscheme",
        ],
        reviewed: "October 2026"
    ) {
        VStack(spacing: 10) {
            Image(systemName: "gearshape.2")
                .font(.system(size: 34))
                .foregroundStyle(.secondary)
            DPKeys("⌘", ",")
        }
        .accessibilityHidden(true)
    } content: { page in
        MacSettingsPatternArticle(page: page)
    }
}

// MARK: - Page

private struct MacSettingsPatternArticle: View {
    let page: ComponentPage

    var body: some View {
        ArticlePage(page: page) {
            Prose("A Mac app's **Settings window** opens from Settings… in the app menu or with ⌘,. It's for general options that affect the whole app and that people change rarely, like accounts or the default font for new documents. People have to stop what they're doing to open it, so anything they adjust while working belongs in the window instead.")

            VStack(alignment: .leading, spacing: 16) {
                SectionTitle("Where does it go?")
                Prose("Pick a home for each option in a notes app.")
                SettingsQuiz()
            }
            .id("demo")

            VStack(alignment: .leading, spacing: 16) {
                SectionTitle("The Settings window itself")
                Prose("When you do need one, the HIG asks for a few things on the Mac:")
                ConnectFacts(rows: [
                    ("Open it from the app menu", "Put Settings… in the app menu, with ⌘, as its shortcut, rather than a button in the toolbar."),
                    ("Panes in a toolbar that stays put", "Switch between groups of settings with toolbar buttons that people can't customize, and always show which pane is active."),
                    ("Title it after the pane", "Show the current pane's name, or “App Name Settings” for a window with one pane."),
                    ("Come back to the last pane", "People often adjust related settings more than once."),
                    ("Dim minimize and zoom", "People reopen it quickly with ⌘,, and it sizes itself to the pane."),
                ])
            }

            VStack(alignment: .leading, spacing: 16) {
                SectionTitle("Examples")
                    .id("examples")
                VStack(alignment: .leading, spacing: 44) {
                    ExampleCard(
                        title: "View options in the toolbar",
                        caption: "Put a `Picker` in a toolbar `Menu`, so people change the sort order where they see the result.",
                        code: """
                        enum SortOrder: String, CaseIterable {
                            case date = "Date Edited"
                            case title = "Title"
                        }

                        @State private var sort = SortOrder.date

                        NavigationStack {
                            NotesList(sort: sort)
                                .toolbar {
                                    Menu("Sort", systemImage: "arrow.up.arrow.down") {
                                        Picker("Sort By", selection: $sort) {
                                            ForEach(SortOrder.allCases, id: \\.self) { order in
                                                Text(order.rawValue)
                                            }
                                        }
                                    }
                                }
                        }
                        """,
                        minHeight: 200,
                        aside: Aside(.note, "A real `.toolbar` here would land in this app's own toolbar, so the preview draws the window.")
                    ) {
                        SortSample()
                    }

                    ExampleCard(
                        title: "Document options in the File menu",
                        caption: "Put options that belong to one document in the File menu with `CommandGroup(after: .saveItem)`, not in Settings.",
                        code: """
                        DocumentGroup(newDocument: NoteDocument()) { file in
                            NoteEditor(document: file.$document)
                        }
                        .commands {
                            CommandGroup(after: .saveItem) {
                                Button("Document Settings…") { }
                            }
                        }
                        """,
                        minHeight: 180
                    ) {
                        DPMenuDrawing(title: "File", items: [
                            .item("New", "⌘N"),
                            .item("Open…", "⌘O"),
                            .divider,
                            .item("Save", "⌘S"),
                            .item("Document Settings…", highlighted: true),
                        ], width: 240)
                    }

                    ExampleCard(
                        title: "Detect instead of asking",
                        caption: "Read `colorScheme` and follow the Mac's appearance, rather than adding a light and dark choice of your own.",
                        code: """
                        @Environment(\\.colorScheme) private var colorScheme

                        Label(
                            colorScheme == .dark ? "Night chart" : "Day chart",
                            systemImage: colorScheme == .dark ? "moon.stars" : "sun.max"
                        )
                        """,
                        minHeight: 120
                    ) {
                        ColorSchemeSample()
                    }
                }
            }
        }
    }
}

// MARK: - Quiz

private enum OptionHome: String, CaseIterable, Identifiable {
    case window = "The window"
    case settings = "Settings"
    case file = "File menu"
    case system = "System Settings"

    var id: Self { self }
}

private struct QuizOption: Identifiable {
    let id: String
    let answer: OptionHome
    let why: String
}

/// Options with a pop-up for where each belongs, checked as people choose.
private struct SettingsQuiz: View {
    @State private var choices: [String: OptionHome] = [:]

    private let options = [
        QuizOption(id: "Sort notes by date", answer: .window, why: "A view option: change it where you see the result."),
        QuizOption(id: "Default font for new notes", answer: .settings, why: "App-wide, and rarely changed."),
        QuizOption(id: "Sync account", answer: .settings, why: "Accounts are a classic general setting."),
        QuizOption(id: "Page size of this note", answer: .file, why: "It belongs to one document."),
        QuizOption(id: "Light or dark appearance", answer: .system, why: "People set it for the whole Mac."),
        QuizOption(id: "Show the sidebar", answer: .window, why: "Part of the view, with a View menu item."),
    ]

    var body: some View {
        DPPanel {
            Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 12) {
                ForEach(options) { option in
                    GridRow(alignment: .firstTextBaseline) {
                        Text(option.id)
                            .fontWeight(.medium)
                        Picker(option.id, selection: binding(for: option.id)) {
                            Text("Choose…").tag(OptionHome?.none)
                            ForEach(OptionHome.allCases) { home in
                                Text(home.rawValue).tag(Optional(home))
                            }
                        }
                        .labelsHidden()
                        .fixedSize()
                        result(for: option)
                    }
                }
            }
        }
    }

    private func binding(for id: String) -> Binding<OptionHome?> {
        Binding {
            choices[id]
        } set: {
            choices[id] = $0
        }
    }

    @ViewBuilder
    private func result(for option: QuizOption) -> some View {
        if let choice = choices[option.id] {
            if choice == option.answer {
                Label(option.why, systemImage: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                    .fixedSize(horizontal: false, vertical: true)
            } else {
                Label("\(option.answer.rawValue). \(option.why)", systemImage: "arrow.uturn.right.circle.fill")
                    .foregroundStyle(.orange)
                    .fixedSize(horizontal: false, vertical: true)
            }
        } else {
            Text("")
        }
    }
}

// MARK: - Samples

private enum SortOrder: String, CaseIterable {
    case date = "Date Edited"
    case title = "Title"
}

private struct SortSample: View {
    @State private var sort = SortOrder.date

    private var notes: [String] {
        let notes = ["Trip plan", "Groceries", "Book club"]
        return sort == .title ? notes.sorted() : notes
    }

    var body: some View {
        MacWindowFrame(title: "Notes", width: 380, height: 180) {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(notes, id: \.self) { note in
                    Label(note, systemImage: "note.text")
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .padding(14)
        } toolbar: {
            Menu("Sort", systemImage: "arrow.up.arrow.down") {
                Picker("Sort By", selection: $sort) {
                    ForEach(SortOrder.allCases, id: \.self) { order in
                        Text(order.rawValue)
                    }
                }
            }
            .menuIndicator(.hidden)
            .fixedSize()
        }
    }
}

private struct ColorSchemeSample: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Label(
            colorScheme == .dark ? "Night chart" : "Day chart",
            systemImage: colorScheme == .dark ? "moon.stars" : "sun.max"
        )
        .font(.title3)
    }
}

/// Placeholder lines of notes for small window drawings.
private struct DPNoteLines: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(["Trip plan", "Groceries"], id: \.self) { note in
                Label(note, systemImage: "note.text")
                    .font(.caption)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(10)
    }
}

/// One row of a drawn Settings pane: a label and a pop-up's value.
private struct DPSettingsRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
            Spacer()
            HStack(spacing: 4) {
                Text(value)
                Image(systemName: "chevron.up.chevron.down")
                    .font(.caption2)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(.fill.tertiary, in: .rect(cornerRadius: 5))
        }
        .font(.caption)
        .padding(12)
        .frame(maxHeight: .infinity, alignment: .top)
    }
}
