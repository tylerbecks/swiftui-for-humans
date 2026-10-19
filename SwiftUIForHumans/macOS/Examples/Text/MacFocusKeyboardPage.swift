import SwiftUI

extension ComponentPage {
    static let focusKeyboard = ComponentPage(
        id: "focus-keyboard",
        title: "Focus & Keyboard Navigation",
        summary: "Decide which view gets typed keys, and let people move around with Tab.",
        category: .textInput,
        kind: .concept,
        symbol: "keyboard",
        availability: ["macOS 12.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/focus",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/focus-and-selection",
        aliases: ["FocusState", "@FocusState", "focused", "first responder", "becomeFirstResponder", "makeFirstResponder", "autofocus", "tab order", "tabindex", "focus ring", "keyboard navigation", "Full Keyboard Access", "onKeyPress", "key press", "keydown", "focusable", "defaultFocus", "focusSection"],
        related: ["text-field", "secure-field", "keyboard-shortcuts", "keyboard-access", "form"],
        notes: [
            "**Custom views take focus.** Built with the macOS 14 SDK or later, a `.focusable()` view can get focus even with keyboard navigation off. Pass `interactions: .activate` for a button-like view that should wait for it.",
            "**Return `.ignored` to pass a key on.** `.handled` stops the key at your view; `.ignored` lets views further up still get it.",
        ],
        api: [
            APIItem("`@FocusState`", "Reads and moves focus. Use an optional enum or a `Bool`."),
            APIItem("`.focused(_:equals:)`", "Ties a view to one value of the focus state."),
            APIItem("`.defaultFocus(_:_:)`", "Where focus starts when the window opens."),
            APIItem("`.focusable()`", "Lets a custom view take focus."),
            APIItem("`.onKeyPress(_:action:)`", "Runs when a key is pressed while focused."),
            APIItem("`.focusEffectDisabled()`", "Hides the focus ring, for your own look."),
            APIItem("`.focusSection()`", "Tab visits a group's views before moving on."),
        ],
        guidelines: [
            Guideline(
                "Use the system's focus ring.",
                "People know what it means at a glance. Draw your own focus look only when the ring doesn't fit, such as a highlight for items in a collection."
            ),
            Guideline(
                "Don't move focus on your own.",
                "People track where they are by where focus is. Change it only in response to something they do."
            ),
            Guideline(
                "Make content focusable, and let the system handle controls.",
                "Fields, lists, and your custom content should take focus. Full Keyboard Access already lets people reach buttons, toggles, and sliders."
            ),
            Guideline(
                "Ring fields, highlight rows.",
                "A focus ring suits text and search fields. In a list or collection, highlight the whole row or item instead."
            ),
        ]
    ) {
        HStack(spacing: 6) {
            MacKeycap("⇥ tab")
            MacKeycap("←")
            MacKeycap("→")
        }
    } content: { page in
        MacFocusKeyboardArticle(page: page)
    }
}

extension Catalog {
    /// A reply window whose focus starts in the message, not the first field.
    static let focusDefaultDemoWindow = DemoWindow(id: "focus-default", title: "Reply", size: CGSize(width: 440, height: 300)) {
        MacReplySample()
            .padding()
    }
}

// MARK: - Page

private struct MacFocusKeyboardArticle: View {
    let page: ComponentPage

    var body: some View {
        ArticlePage(page: page) {
            Prose("Keyboard focus decides which view gets the keys people press. On the Mac, people type into the focused field and press Tab to move to the next one. A focused text field shows a focus ring.")
            Prose("SwiftUI handles the common cases: text fields take focus when clicked, and Tab moves through them in reading order. Use `@FocusState` when you need to read or move focus yourself.")

            SectionTitle("Keys people use")
            ConnectFacts(rows: [
                ("Tab and ⇧Tab", "Move to the next or previous control."),
                ("⌃Tab and ⌃⇧Tab", "Move to the next or previous group of controls, or out of a table where Tab moves between cells."),
                ("Esc", "Cancel the current action."),
                ("Full Keyboard Access", "With it on, people can reach every control with the keyboard. It's in the Accessibility section of System Settings."),
            ])

            SectionTitle("Examples")
                .id("examples")
            MacFocusExamples()
        }
    }
}

private struct MacFocusExamples: View {
    var body: some View {
        ExampleCard(
            title: "Move focus to what needs fixing",
            caption: "Bind each field to a case with `.focused(_:equals:)`. Setting the `@FocusState` moves focus there, here to the first empty field.",
            code: """
            enum Field: Hashable {
                case name, email
            }

            @State private var name = ""
            @State private var email = ""
            @FocusState private var focusedField: Field?

            Form {
                TextField("Name", text: $name)
                    .focused($focusedField, equals: .name)
                TextField("Email", text: $email)
                    .focused($focusedField, equals: .email)
                Button("Join") {
                    if name.isEmpty {
                        focusedField = .name
                    } else if email.isEmpty {
                        focusedField = .email
                    } else {
                        focusedField = nil
                    }
                }
            }
            .frame(width: 300)
            """,
            minHeight: 160,
            aside: Aside(.important, "Give each field its own value. If two views share one, setting it focuses the first, and SwiftUI warns you at runtime.")
        ) {
            MacFocusMoveSample()
        }

        ExampleCard(
            title: "Start focus in the right place",
            caption: "`.defaultFocus` picks where focus goes when the window opens. In a reply, that's the message, not the To field.",
            code: """
            enum ReplyField: Hashable {
                case to, subject, message
            }

            @State private var to = "sam@example.com"
            @State private var subject = "Re: Saturday"
            @State private var message = ""
            @FocusState private var focus: ReplyField?

            VStack {
                TextField("To", text: $to)
                    .focused($focus, equals: .to)
                TextField("Subject", text: $subject)
                    .focused($focus, equals: .subject)
                TextEditor(text: $message)
                    .focused($focus, equals: .message)
            }
            .defaultFocus($focus, .message)
            """,
            minHeight: 280,
            aside: Aside(.note, "Default focus applies when a window first appears, so open the sample as a window to try it.")
        ) {
            VStack(spacing: 16) {
                OpenDemoWindowButton(id: "focus-default", label: "Open the Reply Window")
                MacWindowFrame(title: "Reply", width: 400, height: 200) {
                    MacReplySample()
                        .padding(12)
                }
            }
        }

        ExampleCard(
            title: "Keys for a custom view",
            caption: "Make a view `.focusable()`, then handle keys with `.onKeyPress`. Click the stars, then press ← or →.",
            code: """
            @State private var rating = 3
            @FocusState private var isFocused: Bool

            HStack {
                ForEach(1...5, id: \\.self) { star in
                    Image(systemName: star <= rating ? "star.fill" : "star")
                }
            }
            .foregroundStyle(.orange)
            .padding(6)
            .focusable()
            .focused($isFocused)
            .onTapGesture { isFocused = true }
            .onKeyPress(.leftArrow) {
                rating = max(1, rating - 1)
                return .handled
            }
            .onKeyPress(.rightArrow) {
                rating = min(5, rating + 1)
                return .handled
            }
            """,
            minHeight: 130
        ) {
            MacStarRatingSample()
        }

        ExampleCard(
            title: "Your own focus look",
            caption: "In a row of items, draw a highlight from `@FocusState` and hide the ring with `.focusEffectDisabled()`.",
            code: """
            struct ColorRow: View {
                @FocusState private var focusedColor: String?
                let colors: [(name: String, color: Color)] = [
                    ("Red", .red), ("Orange", .orange), ("Green", .green), ("Blue", .blue),
                ]

                var body: some View {
                    HStack(spacing: 12) {
                        ForEach(colors, id: \\.name) { item in
                            Circle()
                                .fill(item.color)
                                .frame(width: 32, height: 32)
                                .padding(4)
                                .background(
                                    Circle().fill(focusedColor == item.name ? Color.accentColor.opacity(0.35) : .clear)
                                )
                                .focusable()
                                .focused($focusedColor, equals: item.name)
                                .focusEffectDisabled()
                                .onTapGesture { focusedColor = item.name }
                                .accessibilityLabel(item.name)
                        }
                    }
                    .onKeyPress(.leftArrow) { move(by: -1) }
                    .onKeyPress(.rightArrow) { move(by: 1) }
                }

                func move(by step: Int) -> KeyPress.Result {
                    guard let current = colors.firstIndex(where: { $0.name == focusedColor }) else { return .ignored }
                    let next = min(max(current + step, 0), colors.count - 1)
                    focusedColor = colors[next].name
                    return .handled
                }
            }
            """,
            minHeight: 130,
            aside: Aside(.note, "Click a color, then press ← or → to move the highlight.")
        ) {
            MacSwatchFocusSample()
        }

        ExampleCard(
            title: "Tab down a column first",
            caption: "Tab goes leading to trailing, then down. Add `.focusSection()` to each column so Tab finishes one column before the next.",
            code: """
            @State private var shipName = ""
            @State private var shipStreet = ""
            @State private var billName = ""
            @State private var billStreet = ""

            HStack(alignment: .top, spacing: 20) {
                VStack(alignment: .leading) {
                    Text("Shipping").font(.headline)
                    TextField("Name", text: $shipName)
                    TextField("Street", text: $shipStreet)
                }
                .focusSection()
                VStack(alignment: .leading) {
                    Text("Billing").font(.headline)
                    TextField("Name", text: $billName)
                    TextField("Street", text: $billStreet)
                }
                .focusSection()
            }
            .frame(width: 400)
            """,
            minHeight: 150
        ) {
            MacColumnsSample()
        }
    }
}

// MARK: - Samples

private struct MacFocusMoveSample: View {
    enum Field: Hashable {
        case name, email
    }

    @State private var name = ""
    @State private var email = ""
    @FocusState private var focusedField: Field?

    var body: some View {
        Form {
            TextField("Name", text: $name)
                .focused($focusedField, equals: .name)
            TextField("Email", text: $email)
                .focused($focusedField, equals: .email)
            Button("Join") {
                if name.isEmpty {
                    focusedField = .name
                } else if email.isEmpty {
                    focusedField = .email
                } else {
                    focusedField = nil
                }
            }
        }
        .frame(width: 300)
    }
}

/// The reply form, used by the inline drawing and the real window.
private struct MacReplySample: View {
    enum ReplyField: Hashable {
        case to, subject, message
    }

    @State private var to = "sam@example.com"
    @State private var subject = "Re: Saturday"
    @State private var message = ""
    @FocusState private var focus: ReplyField?

    var body: some View {
        VStack {
            TextField("To", text: $to)
                .focused($focus, equals: .to)
            TextField("Subject", text: $subject)
                .focused($focus, equals: .subject)
            TextEditor(text: $message)
                .focused($focus, equals: .message)
                .clipShape(.rect(cornerRadius: 6))
                .overlay(RoundedRectangle(cornerRadius: 6).strokeBorder(.separator))
        }
        .defaultFocus($focus, .message)
    }
}

private struct MacStarRatingSample: View {
    @State private var rating = 3
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(spacing: 10) {
            HStack {
                ForEach(1...5, id: \.self) { star in
                    Image(systemName: star <= rating ? "star.fill" : "star")
                }
            }
            .foregroundStyle(.orange)
            .padding(6)
            .focusable()
            .focused($isFocused)
            .onTapGesture { isFocused = true }
            .onKeyPress(.leftArrow) {
                rating = max(1, rating - 1)
                return .handled
            }
            .onKeyPress(.rightArrow) {
                rating = min(5, rating + 1)
                return .handled
            }
            .accessibilityElement()
            .accessibilityLabel("Rating")
            .accessibilityValue("\(rating) of 5")

            MacTextReadout("rating = \(rating), isFocused = \(isFocused)")
        }
        .font(.title2)
    }
}

private struct MacSwatchFocusSample: View {
    @FocusState private var focusedColor: String?
    private let colors: [(name: String, color: Color)] = [
        ("Red", .red), ("Orange", .orange), ("Green", .green), ("Blue", .blue),
    ]

    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 12) {
                ForEach(colors, id: \.name) { item in
                    Circle()
                        .fill(item.color)
                        .frame(width: 32, height: 32)
                        .padding(4)
                        .background(
                            Circle().fill(focusedColor == item.name ? Color.accentColor.opacity(0.35) : .clear)
                        )
                        .focusable()
                        .focused($focusedColor, equals: item.name)
                        .focusEffectDisabled()
                        .onTapGesture { focusedColor = item.name }
                        .accessibilityLabel(item.name)
                }
            }
            .onKeyPress(.leftArrow) { move(by: -1) }
            .onKeyPress(.rightArrow) { move(by: 1) }
            MacTextReadout("focusedColor = \(focusedColor.map(swiftString) ?? "nil")")
        }
    }
    private func move(by step: Int) -> KeyPress.Result {
        guard let current = colors.firstIndex(where: { $0.name == focusedColor }) else { return .ignored }
        let next = min(max(current + step, 0), colors.count - 1)
        focusedColor = colors[next].name
        return .handled
    }
}

private struct MacColumnsSample: View {
    @State private var shipName = ""
    @State private var shipStreet = ""
    @State private var billName = ""
    @State private var billStreet = ""

    var body: some View {
        HStack(alignment: .top, spacing: 20) {
            VStack(alignment: .leading) {
                Text("Shipping").font(.headline)
                TextField("Name", text: $shipName)
                TextField("Street", text: $shipStreet)
            }
            .focusSection()
            VStack(alignment: .leading) {
                Text("Billing").font(.headline)
                TextField("Name", text: $billName)
                TextField("Street", text: $billStreet)
            }
            .focusSection()
        }
        .frame(width: 400)
    }
}

/// A key drawn as a keycap, for the thumbnail.
private struct MacKeycap: View {
    let label: String

    init(_ label: String) {
        self.label = label
    }

    var body: some View {
        Text(label)
            .font(.callout.weight(.medium))
            .padding(.horizontal, 10)
            .frame(minWidth: 34, minHeight: 32)
            .background(.background, in: .rect(cornerRadius: 6))
            .overlay(RoundedRectangle(cornerRadius: 6).strokeBorder(.separator))
            .shadow(color: .black.opacity(0.12), radius: 0, y: 1)
    }
}
