import SwiftUI

extension ComponentPage {
    static let writing = ComponentPage(
        id: "writing",
        title: "Writing for the Mac",
        summary: "Menu and button names people recognize: verbs, title case, and an ellipsis when more is needed.",
        category: .foundations,
        kind: .concept,
        symbol: "character.cursor.ibeam",
        availability: [],
        docsURL: nil,
        higURL: "https://developer.apple.com/design/human-interface-guidelines/writing",
        aliases: ["copy", "microcopy", "ux writing", "labels", "menu item names", "ellipsis", "…", "three dots", "title case", "capitalization", "error messages", "button labels", "click not tap", "voice", "tone"],
        related: ["commands", "menu-bar-conventions", "button", "alert", "keyboard-shortcuts", "empty-states"],
        notes: [
            "**Pick a capitalization style and stick to it.** Menus use title case on the Mac. For other text, like headings and alerts, choose title or sentence case per kind of element and use it everywhere.",
            "**Say window, not scene.** People see windows. Scene, view, and other words from your code don't belong in the interface.",
        ],
        api: [
            APIItem("`Button(\"Export…\")`", "A command that asks for more before it runs."),
            APIItem("`CommandGroup(after:)`", "Adds items to a standard menu."),
            APIItem("`CommandMenu(_:)`", "A menu of your own in the menu bar."),
            APIItem("`.keyboardShortcut(_:modifiers:)`", "Shows the shortcut next to the item."),
            APIItem("`.help(_:)`", "A short tooltip describing a control."),
            APIItem("`String(localized:)`", "Text that can be translated."),
        ],
        guidelines: [
            Guideline(
                "Add an ellipsis when a command needs more input.",
                "The … tells people a window or panel will ask for something before the command finishes, like a file name for Export. Use the ellipsis character, not three periods.",
                good: "Export… opens a panel first.",
                bad: "Export looks like it runs right away."
            ) {
                MacDesignMenuSample(items: [
                    MacDesignMenuItem(title: "Duplicate", shortcut: "⇧⌘S"),
                    MacDesignMenuItem(title: "Rename…"),
                    MacDesignMenuItem(title: "Export…", shortcut: "⇧⌘E"),
                ], width: 200)
            } bad: {
                MacDesignMenuSample(items: [
                    MacDesignMenuItem(title: "Duplicate", shortcut: "⇧⌘S"),
                    MacDesignMenuItem(title: "Rename…"),
                    MacDesignMenuItem(title: "Export", shortcut: "⇧⌘E"),
                ], width: 200)
            },
            Guideline(
                "Use title case in menus.",
                "Capitalize every word except articles, coordinating conjunctions, and short prepositions, and always capitalize the last word: Bring All to Front.",
                good: "Show Sidebar, in title case.",
                bad: "Show sidebar, in sentence case."
            ) {
                MacDesignMenuSample(items: [
                    MacDesignMenuItem(title: "Show Sidebar"),
                    MacDesignMenuItem(title: "Show Toolbar", shortcut: "⌥⌘T"),
                ], width: 200)
            } bad: {
                MacDesignMenuSample(items: [
                    MacDesignMenuItem(title: "Show sidebar"),
                    MacDesignMenuItem(title: "Show Toolbar", shortcut: "⌥⌘T"),
                ], width: 200)
            },
            Guideline(
                "Start actions with a verb.",
                "A button or menu item that does something should say what it does. Plain beats clever.",
                good: "The button says what happens.",
                bad: "A clever label hides the action."
            ) {
                MacWritingButtons(primary: "Send Invitation")
            } bad: {
                MacWritingButtons(primary: "Let's Go!")
            },
            Guideline(
                "Let a toggled item say what it will do.",
                "Instead of two items, one item can switch between Show Map and Hide Map. For an attribute that's on, like a text style, a checkmark works better."
            ),
            Guideline(
                "Write errors that help.",
                "Show the message next to the problem, don't blame anyone, and say how to fix it. Skip “Oops” and avoid “we”: it's never clear who that is.",
                good: "Says how to fix it.",
                bad: "Only says it's wrong."
            ) {
                MacWritingFieldError(message: "Use at least 3 characters.")
            } bad: {
                MacWritingFieldError(message: "Invalid name.")
            },
            Guideline(
                "Describe the Mac's own actions.",
                "People click, double-click, and press keys on a Mac. Saying tap, or describing a gesture the Mac doesn't have, sounds like an app from another device."
            ),
        ],
        sources: [
            "https://developer.apple.com/design/human-interface-guidelines/writing",
            "https://developer.apple.com/design/human-interface-guidelines/menus",
            "https://developer.apple.com/design/human-interface-guidelines/buttons",
            "https://developer.apple.com/design/human-interface-guidelines/the-menu-bar",
        ],
        reviewed: "October 2026"
    ) {
        MacDesignMenuSample(items: [
            MacDesignMenuItem(title: "New Trip", shortcut: "⌘N"),
            MacDesignMenuItem(title: "Export…", shortcut: "⇧⌘E"),
        ], width: 160)
        .font(.caption)
    } content: { page in
        MacWritingArticle(page: page)
    }
}

// MARK: - Page

private struct MacWritingArticle: View {
    let page: ComponentPage

    var body: some View {
        ArticlePage(page: page) {
            Prose("The words in your app are part of its design. On the Mac, many of them live in menus, buttons, and window titles, where people expect the same patterns they see in every other app: verbs, title case, and an ellipsis when a command needs more from them.")

            VStack(alignment: .leading, spacing: 16) {
                SectionTitle("Mac conventions")
                ConnectFacts(rows: [
                    ("Ellipsis (…)", "On a menu item that needs more input before it can finish, like **Export As…** or **Print…**, and on a button that opens another window or view, like **Edit…**."),
                    ("Title case", "For menu items and multiword menu titles: **Bring All to Front**, **Move To…**, **Show Sidebar**."),
                    ("Verbs", "For anything that acts: **Duplicate**, **Rename…**, **Send Invitation**. Keep menu items short and leave out articles."),
                    ("Changing labels", "One item that says what it will do next, like **Show Map** and **Hide Map**, instead of two items."),
                ])
            }

            VStack(alignment: .leading, spacing: 16) {
                SectionTitle("In SwiftUI")
                    .id("examples")
                VStack(alignment: .leading, spacing: 44) {
                    ExampleCard(
                        title: "Name menu commands the Mac way",
                        caption: "Give each command a verb in title case, and end it with … when it opens a panel or window to ask for more.",
                        code: """
                        .commands {
                            CommandGroup(after: .newItem) {
                                Button("Duplicate Trip") { }
                                    .keyboardShortcut("s", modifiers: [.shift, .command])
                                Button("Export Itinerary…") { }
                                    .keyboardShortcut("e", modifiers: [.shift, .command])
                            }
                        }
                        """,
                        minHeight: 140,
                        aside: Aside(.note, "Menu bar menus belong to the app, not a page, so the preview draws this one. See [Commands](catalog://commands) for adding them.")
                    ) {
                        MacDesignMenuSample(items: [
                            MacDesignMenuItem(title: "New Window", shortcut: "⌘N"),
                            .separator,
                            MacDesignMenuItem(title: "Duplicate Trip", shortcut: "⇧⌘S"),
                            MacDesignMenuItem(title: "Export Itinerary…", shortcut: "⇧⌘E"),
                        ], width: 240)
                    }

                    ExampleCard(
                        title: "A label that follows the state",
                        caption: "Switch the title with the state, so the item always says what clicking it will do.",
                        code: """
                        @State private var showsMap = true

                        Button(showsMap ? "Hide Map" : "Show Map") {
                            showsMap.toggle()
                        }
                        """,
                        minHeight: 110
                    ) {
                        MacToggledLabelSample()
                    }

                    ExampleCard(
                        title: "An error next to the field",
                        caption: "Show the message right under the field, and say what to type instead of what went wrong.",
                        code: """
                        @State private var name = "Li"

                        VStack(alignment: .leading, spacing: 4) {
                            TextField("Trip name", text: $name)
                            if name.count < 3 {
                                Text("Use at least 3 characters.")
                                    .font(.callout)
                                    .foregroundStyle(.red)
                            }
                        }
                        .frame(width: 240)
                        """,
                        minHeight: 120
                    ) {
                        MacFieldErrorSample()
                    }

                    ExampleCard(
                        title: "A button that opens more",
                        caption: "A push button that opens another window or view ends in …, like the Edit… buttons in Safari's AutoFill settings.",
                        code: """
                        LabeledContent("Saved addresses") {
                            Button("Edit…") { }
                        }
                        .frame(width: 280)
                        """,
                        minHeight: 100
                    ) {
                        LabeledContent("Saved addresses") {
                            Button("Edit…") { }
                        }
                        .frame(width: 280)
                    }
                }
            }
        }
    }
}

// MARK: - Samples

private struct MacToggledLabelSample: View {
    @State private var showsMap = true

    var body: some View {
        VStack(spacing: 10) {
            Button(showsMap ? "Hide Map" : "Show Map") {
                showsMap.toggle()
            }
            Text(showsMap ? "The map is showing." : "The map is hidden.")
                .font(.callout)
                .foregroundStyle(.secondary)
        }
    }
}

private struct MacFieldErrorSample: View {
    @State private var name = "Li"

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            TextField("Trip name", text: $name)
            if name.count < 3 {
                Text("Use at least 3 characters.")
                    .font(.callout)
                    .foregroundStyle(.red)
            }
        }
        .frame(width: 240)
    }
}

private struct MacWritingButtons: View {
    let primary: String

    var body: some View {
        HStack {
            Button("Cancel") { }
            Button(primary) { }
                .buttonStyle(.borderedProminent)
        }
    }
}

private struct MacWritingFieldError: View {
    let message: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            TextField("Trip name", text: .constant("Li"))
            Text(message)
                .font(.callout)
                .foregroundStyle(.red)
        }
        .frame(width: 200)
    }
}
