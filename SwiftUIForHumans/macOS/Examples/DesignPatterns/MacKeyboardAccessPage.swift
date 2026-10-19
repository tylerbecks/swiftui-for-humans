import SwiftUI

extension ComponentPage {
    static let keyboardAccess = ComponentPage(
        id: "keyboard-access",
        title: "Keyboard access",
        summary: "Let people reach every control and command without touching the pointer.",
        category: .accessibility,
        kind: .concept,
        symbol: "keyboard",
        availability: ["macOS 14.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/focus",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/keyboards",
        aliases: [
            "Full Keyboard Access", "keyboard navigation", "tab order", "focus order", "focus ring",
            "tabindex", "FocusState", "focusable", "focusSection", "onKeyPress", "defaultFocus",
            "arrow keys", "accessibility keyboard",
        ],
        related: ["focus-keyboard", "keyboard-shortcuts", "commands", "voiceover", "menu-bar-conventions"],
        notes: [
            "**Buttons join the Tab order only when keyboard navigation is on.** That's the Mac convention for button-like views, so test your windows with the setting both on and off.",
            "**Every menu item is keyboard access for free.** People can reach the menu bar from the keyboard, so a command that lives in a menu works for them even without its own shortcut.",
        ],
        api: [
            APIItem("`.focusable(_:interactions:)`", "Lets a custom view take keyboard focus."),
            APIItem("`@FocusState`", "Reads and moves focus from your code."),
            APIItem("`.focused(_:equals:)`", "Ties a view to a `@FocusState` value."),
            APIItem("`.defaultFocus(_:_:)`", "Picks what has focus when the window opens."),
            APIItem("`.focusSection()`", "Visits a group's views before moving on."),
            APIItem("`.onKeyPress(_:action:)`", "Handles a key while the view has focus."),
            APIItem("`.keyboardShortcut(_:modifiers:)`", "Gives a button or menu item a shortcut."),
        ],
        guidelines: [
            Guideline(
                "Don't hide actions behind hover.",
                "A button that only appears under the pointer can't be reached from the keyboard. Show it, put it in a menu, or both.",
                good: "Delete is a visible button and a menu item.",
                bad: "Delete only appears when the pointer is over the row."
            ) {
                DPHoverRow(showsButton: true)
            } bad: {
                DPHoverRow(showsButton: false)
            },
            Guideline(
                "Keep standard shortcuts doing standard things.",
                "People carry ⌘C, ⌘Z, and ⌘W from app to app. Give your own command a new shortcut instead of borrowing one people already know.",
                good: "⌘C copies, as everywhere else.",
                bad: "⌘C archives, so copying breaks."
            ) {
                DPMenuDrawing(title: "Edit", items: [
                    .item("Cut", "⌘X"),
                    .item("Copy", "⌘C", highlighted: true),
                    .item("Paste", "⌘V"),
                ], width: 190)
            } bad: {
                DPMenuDrawing(title: "Edit", items: [
                    .item("Cut", "⌘X"),
                    .item("Archive", "⌘C", highlighted: true),
                    .item("Paste", "⌘V"),
                ], width: 190)
            },
            Guideline(
                "Build custom shortcuts on Command.",
                "Use ⌘ first, add ⇧ for a related variant, and save ⌥ for rarer commands. Avoid ⌃: the system uses it for moving focus and other features."
            ),
            Guideline(
                "Give shortcuts only to frequent commands.",
                "A few well-chosen shortcuts are easy to learn. Dozens of new ones make the app feel hard, and every command is still reachable through the menu bar."
            ),
            Guideline(
                "Let people move focus themselves.",
                "Jumping focus somewhere on its own makes people hunt for it. Move it only in response to what they did, like pressing Return in a field."
            ),
        ],
        sources: [
            "https://developer.apple.com/design/human-interface-guidelines/keyboards",
            "https://developer.apple.com/design/human-interface-guidelines/focus-and-selection",
            "https://developer.apple.com/design/human-interface-guidelines/accessibility",
            "https://developer.apple.com/documentation/swiftui/focus",
            "https://developer.apple.com/documentation/swiftui/view/focusable(_:interactions:)",
            "https://developer.apple.com/documentation/swiftui/view/focussection()",
            "https://developer.apple.com/documentation/swiftui/view/defaultfocus(_:_:priority:)",
            "https://developer.apple.com/documentation/swiftui/view/onkeypress(_:action:)",
            "https://developer.apple.com/documentation/appkit/nsapplication/isfullkeyboardaccessenabled",
        ],
        reviewed: "October 2026"
    ) {
        VStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 6)
                .fill(.background)
                .frame(width: 130, height: 24)
                .overlay(alignment: .leading) {
                    Text("Name")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.leading, 8)
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 6)
                        .strokeBorder(Color.accentColor, lineWidth: 3)
                }
            DPKeys("⇥ tab")
        }
        .accessibilityHidden(true)
    } content: { page in
        MacKeyboardAccessArticle(page: page)
    }
}

// MARK: - Page

private struct MacKeyboardAccessArticle: View {
    let page: ComponentPage

    var body: some View {
        ArticlePage(page: page) {
            Prose("Many Mac users keep their hands on the keyboard, and some can't use a pointer at all. **Full Keyboard Access**, in the Accessibility section of System Settings, lets people move through windows, menus, and controls and use them with the keyboard alone. A lighter setting, **Keyboard navigation** in System Settings > Keyboard, lets Tab reach every control. Apple asks apps to support Full Keyboard Access, and SwiftUI does most of the work: standard controls already take part.")
            Prose("Your part is custom views, the order focus moves in, and making sure no action needs the pointer.")

            VStack(alignment: .leading, spacing: 16) {
                SectionTitle("Try it")
                Prose("Click the Name field, then press Tab and ⇧Tab. The readout shows what has focus. Turn on Keyboard navigation in System Settings > Keyboard and try again: now the swatches and the Save button join in.")
                KeyboardPlayground()
            }
            .id("demo")

            VStack(alignment: .leading, spacing: 16) {
                SectionTitle("Keys the system already uses")
                Prose("These come from the HIG's list of standard shortcuts. Test your window with them, and don't assign them to anything else.")
                ConnectFacts(rows: [
                    ("Tab and ⇧Tab", "Move to the next or previous control."),
                    ("⌃Tab", "Move to the next group of controls, or out of a table where Tab moves between cells."),
                    ("⌃F2 and ⌃F5", "Move focus to the menu bar, or to the window's toolbar."),
                    ("⌘`", "Switch to the app's next window."),
                    ("Esc and ⌘.", "Cancel the current action."),
                ])
            }

            VStack(alignment: .leading, spacing: 16) {
                SectionTitle("Examples")
                    .id("examples")
                VStack(alignment: .leading, spacing: 44) {
                    ExampleCard(
                        title: "Make a custom control focusable",
                        caption: "Add `.focusable()` so Tab can reach the view, then `.onKeyPress` to change it with the arrow keys.",
                        code: """
                        @State private var rating = 3

                        HStack {
                            ForEach(1...5, id: \\.self) { star in
                                Image(systemName: star <= rating ? "star.fill" : "star")
                                    .onTapGesture { rating = star }
                            }
                        }
                        .foregroundStyle(.orange)
                        .focusable()
                        .onKeyPress(.leftArrow) {
                            rating = max(rating - 1, 1)
                            return .handled
                        }
                        .onKeyPress(.rightArrow) {
                            rating = min(rating + 1, 5)
                            return .handled
                        }
                        """,
                        minHeight: 150,
                        aside: Aside(.note, "Click the stars, then press ← and →. Built with the macOS 14 SDK or later, `.focusable()` takes focus even with keyboard navigation off.")
                    ) {
                        RatingExample()
                    }

                    ExampleCard(
                        title: "Move to the next field on Return",
                        caption: "Tie each field to `@FocusState` with `.focused(_:equals:)`, set it in `.onSubmit`, and pick the first field with `.defaultFocus`.",
                        code: """
                        enum Field: Hashable {
                            case name, email
                        }

                        @State private var name = ""
                        @State private var email = ""
                        @FocusState private var focus: Field?

                        Form {
                            TextField("Name", text: $name)
                                .focused($focus, equals: .name)
                                .onSubmit { focus = .email }
                            TextField("Email", text: $email)
                                .focused($focus, equals: .email)
                        }
                        .defaultFocus($focus, .name)
                        """,
                        minHeight: 150
                    ) {
                        SubmitExample()
                    }

                    ExampleCard(
                        title: "Keep a column together",
                        caption: "Tab moves across a row first, so add `.focusSection()` to each column to finish one before the next.",
                        code: """
                        @State private var shipping = ["", ""]
                        @State private var billing = ["", ""]

                        HStack(alignment: .top) {
                            VStack {
                                TextField("Shipping street", text: $shipping[0])
                                TextField("Shipping city", text: $shipping[1])
                            }
                            .focusSection()
                            VStack {
                                TextField("Billing street", text: $billing[0])
                                TextField("Billing city", text: $billing[1])
                            }
                            .focusSection()
                        }
                        """,
                        minHeight: 140,
                        aside: Aside(.note, "Without `.focusSection()`, Tab would go from Shipping street to Billing street, across the row.")
                    ) {
                        ColumnsExample()
                    }
                }
            }
        }
    }
}

// MARK: - Playground

private enum PlaygroundField: Hashable {
    case name, email, color, save

    var label: String {
        switch self {
        case .name: "Name field"
        case .email: "Email field"
        case .color: "Color swatches"
        case .save: "Save button"
        }
    }
}

/// A small form where every part reports when it has focus.
private struct KeyboardPlayground: View {
    @State private var name = ""
    @State private var email = ""
    @State private var color = 0
    @FocusState private var focus: PlaygroundField?

    private let colors: [Color] = [.blue, .green, .orange, .pink]

    var body: some View {
        DPPanel {
            HStack(alignment: .top, spacing: 28) {
                Form {
                    TextField("Name", text: $name)
                        .focused($focus, equals: .name)
                    TextField("Email", text: $email)
                        .focused($focus, equals: .email)
                    LabeledContent("Color") {
                        HStack(spacing: 6) {
                            ForEach(colors.indices, id: \.self) { index in
                                Circle()
                                    .fill(colors[index])
                                    .frame(width: 18, height: 18)
                                    .overlay {
                                        if index == color {
                                            Circle().strokeBorder(.primary, lineWidth: 2)
                                        }
                                    }
                                    .onTapGesture { color = index }
                            }
                        }
                        .padding(3)
                        .focusable(interactions: .activate)
                        .focused($focus, equals: .color)
                        .onKeyPress(.leftArrow) {
                            color = max(color - 1, 0)
                            return .handled
                        }
                        .onKeyPress(.rightArrow) {
                            color = min(color + 1, colors.count - 1)
                            return .handled
                        }
                        .accessibilityLabel("Color")
                        .accessibilityValue(["Blue", "Green", "Orange", "Pink"][color])
                    }
                    Button("Save") {}
                        .focused($focus, equals: .save)
                }
                .frame(maxWidth: 320)

                VStack(alignment: .leading, spacing: 6) {
                    Text("Has focus")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Text(focus?.label ?? "Nothing")
                        .font(.title3.weight(.semibold))
                        .contentTransition(.opacity)
                    Text("The swatches are focusable only for activation, like a button, so they wait for keyboard navigation.")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, 6)
                }
                .frame(maxWidth: 240, alignment: .leading)
            }
        }
    }
}

// MARK: - Examples

private struct RatingExample: View {
    @State private var rating = 3

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                ForEach(1...5, id: \.self) { star in
                    Image(systemName: star <= rating ? "star.fill" : "star")
                        .onTapGesture { rating = star }
                }
            }
            .font(.title2)
            .foregroundStyle(.orange)
            .padding(6)
            .focusable()
            .onKeyPress(.leftArrow) {
                rating = max(rating - 1, 1)
                return .handled
            }
            .onKeyPress(.rightArrow) {
                rating = min(rating + 1, 5)
                return .handled
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Rating")
            .accessibilityValue("\(rating) of 5")

            Text("rating = \(rating)")
                .font(.footnote.monospaced())
                .foregroundStyle(.secondary)
        }
    }
}

private struct SubmitExample: View {
    enum Field: Hashable {
        case name, email
    }

    @State private var name = ""
    @State private var email = ""
    @FocusState private var focus: Field?

    var body: some View {
        Form {
            TextField("Name", text: $name)
                .focused($focus, equals: .name)
                .onSubmit { focus = .email }
            TextField("Email", text: $email)
                .focused($focus, equals: .email)
        }
        .defaultFocus($focus, .name)
        .frame(maxWidth: 340)
    }
}

private struct ColumnsExample: View {
    @State private var shipping = ["", ""]
    @State private var billing = ["", ""]

    var body: some View {
        HStack(alignment: .top) {
            VStack {
                TextField("Shipping street", text: $shipping[0])
                TextField("Shipping city", text: $shipping[1])
            }
            .focusSection()
            VStack {
                TextField("Billing street", text: $billing[0])
                TextField("Billing city", text: $billing[1])
            }
            .focusSection()
        }
        .frame(maxWidth: 440)
    }
}

/// A list row whose Delete button is either always visible or, for the
/// Don't, missing (it would only show under the pointer).
private struct DPHoverRow: View {
    let showsButton: Bool

    var body: some View {
        HStack {
            Image(systemName: "doc.text")
                .foregroundStyle(.secondary)
            Text("Trip notes")
            Spacer()
            if showsButton {
                Button("Delete", systemImage: "trash") {}
                    .labelStyle(.iconOnly)
                    .buttonStyle(.borderless)
            }
        }
        .padding(.horizontal, 12)
        .frame(width: 230, height: 36)
        .background(.fill.quaternary, in: .rect(cornerRadius: 8))
    }
}
