import SwiftUI

extension ComponentPage {
    static let greatMacApp = ComponentPage(
        id: "great-mac-app",
        title: "What Makes a Great Mac App",
        summary: "Menus, the keyboard, windows, Settings, and drag and drop: what people expect on a Mac.",
        category: .startHere,
        kind: .concept,
        symbol: "star",
        availability: [],
        docsURL: "https://developer.apple.com/documentation/swiftui/commands",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/designing-for-macos",
        aliases: [
            "Mac-like", "mac assed", "feels native", "menu bar", "keyboard shortcuts",
            "multiple windows", "drag and drop", "preferences", "settings", "full keyboard access",
            "Mac conventions", "best practices",
        ],
        related: [
            "mac-native-checklist", "ipad-app-in-window", "commands", "keyboard-shortcuts",
            "window-group", "settings-scene", "drag-drop", "menu-bar-conventions",
        ],
        notes: [
            "**Standard menus do a lot of the work.** The system implements many standard menu items for you, so keeping them pays off twice.",
            "**People switch between apps all day.** Expect your app to be one of several windows on screen, and to move smoothly between active and inactive.",
        ],
        guidelines: [
            Guideline(
                "Disable menu items instead of hiding them.",
                "A menu that always shows the same items teaches people what your app can do, even when an item doesn't apply right now.",
                good: "Delete Stop is there, dimmed.",
                bad: "Delete Stop disappears when nothing is selected."
            ) {
                ShipMenuSketch(title: "Trip", rows: [
                    .item("New Stop", shortcut: "⇧⌘N"),
                    .item("Delete Stop", shortcut: "⌫", isEnabled: false),
                    .separator,
                    .item("Show Map", shortcut: "⌘M"),
                ], width: 190)
            } bad: {
                ShipMenuSketch(title: "Trip", rows: [
                    .item("New Stop", shortcut: "⇧⌘N"),
                    .separator,
                    .item("Show Map", shortcut: "⌘M"),
                ], width: 190)
            },
            Guideline(
                "Use the big display.",
                "Show more content with fewer nested levels and fewer modal steps, while keeping the density comfortable to read."
            ),
            Guideline(
                "Let people shape their windows.",
                "People resize, hide, show, and move windows to fit how they work, and expect full screen for focused work."
            ),
            Guideline(
                "Reward precise input.",
                "A pointer allows exact selection and editing, so support it alongside the keyboard."
            ),
            Guideline(
                "Let people personalize.",
                "Customizable toolbars, windows that show the views people use most, and their choice of colors and fonts all help."
            ),
        ],
        sources: [
            "https://developer.apple.com/design/human-interface-guidelines/designing-for-macos",
            "https://developer.apple.com/design/human-interface-guidelines/the-menu-bar",
            "https://developer.apple.com/design/human-interface-guidelines/keyboards",
            "https://developer.apple.com/design/human-interface-guidelines/windows",
            "https://developer.apple.com/design/human-interface-guidelines/settings",
            "https://developer.apple.com/design/human-interface-guidelines/drag-and-drop",
            "https://developer.apple.com/documentation/swiftui/commands",
            "https://developer.apple.com/documentation/swiftui/view/draggable(_:)",
            "https://developer.apple.com/documentation/swiftui/view/dropdestination(for:isenabled:action:)",
        ],
        reviewed: "October 2026"
    ) {
        ShipThumbnail(symbol: "star", caption: "Great Mac App")
    } content: { page in
        MacGreatMacAppArticle(page: page)
    }
}

// MARK: - Page

private struct MacGreatMacAppArticle: View {
    let page: ComponentPage
    @State private var stops = 0

    var body: some View {
        ArticlePage(page: page) {
            Prose("A Mac sits on a desk, a foot or three from someone's eyes, with a big display, a keyboard, and a pointer. People keep several apps open and spend anything from minutes to hours in one. Five things make an app feel at home there.")

            SectionTitle("1. Every command in the menu bar")
            Prose("People learn what an app does by opening its menus. Keep the standard menus in their usual order, put your own menus between View and Window, and list every command there, even the ones that also have a button. See [Commands](catalog://commands).")
            MenuBarOrder()
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
            ExampleCard(
                title: "Add an app-specific menu",
                caption: "`CommandMenu` adds a menu between View and Window, with shortcuts for the commands people use most.",
                code: """
                WindowGroup {
                    ContentView()
                }
                .commands {
                    CommandMenu("Trip") {
                        Button("New Stop") { addStop() }
                            .keyboardShortcut("n", modifiers: [.shift, .command])
                        Button("Show Map") { showMap() }
                            .keyboardShortcut("m")
                    }
                }
                """,
                minHeight: 170
            ) {
                ShipMenuSketch(title: "Trip", rows: [
                    .item("New Stop", shortcut: "⇧⌘N"),
                    .item("Show Map", shortcut: "⌘M"),
                ])
            }

            SectionTitle("2. The keyboard does everything")
            Prose("Standard shortcuts like ⌘C, ⌘Z, and ⌘W should work as they do everywhere else. Add your own only for frequent commands, list modifiers as ⌃⌥⇧⌘, and support Full Keyboard Access so people can reach every control without a pointer. See [Keyboard Shortcuts](catalog://keyboard-shortcuts).")
            ExampleCard(
                title: "A shortcut on a button",
                caption: "`.keyboardShortcut(_:modifiers:)` clicks the button for you while its window is active, so press ⌥⌘K to try it.",
                code: """
                @State private var stops = 0

                Button("Add Stop") { stops += 1 }
                    .keyboardShortcut("k", modifiers: [.option, .command])
                """,
                minHeight: 140
            ) {
                VStack(spacing: 10) {
                    Button("Add Stop") { stops += 1 }
                        .keyboardShortcut("k", modifiers: [.option, .command])
                    Text("\(stops) stops")
                        .font(.footnote.monospacedDigit())
                        .foregroundStyle(.secondary)
                }
            }

            SectionTitle("3. Windows people control")
            Prose("Windows should adapt smoothly to any size. Where it helps people multitask, let them open content in a window of its own, the way Mail gives each new message its own window. Keep the system's window frame and controls: a custom imitation that doesn't match them exactly makes an app feel broken. See [WindowGroup](catalog://window-group).")
            CodeBlock(code: """
            WindowGroup(for: Trip.ID.self) { $tripID in
                TripView(tripID: tripID)
            }
            .defaultSize(width: 900, height: 600)
            """)

            SectionTitle("4. Settings in the app menu")
            Prose("App-wide options go in a Settings window that opens from the app menu or with ⌘,. A `Settings` scene gives you both. Options for one window, like sorting, stay in that window. See [Settings](catalog://settings-scene).")

            SectionTitle("5. Drag and drop everywhere")
            Prose("People try drag and drop on everything: between your windows, to and from other apps, and into the Finder. Offer another way to do the same thing, like a menu command, for people who can't drag. See [Drag and Drop](catalog://drag-drop).")
            ExampleCard(
                title: "Drag a stop onto the trip",
                caption: "`.draggable(_:)` makes a view a drag source, and `.dropDestination(for:)` accepts what people drop on a view.",
                code: """
                @State private var trip: [String] = []

                HStack {
                    ForEach(["Lisbon", "Porto", "Faro"], id: \\.self) { city in
                        Text(city)
                            .padding(8)
                            .background(.fill.tertiary, in: .capsule)
                            .draggable(city)
                    }
                }
                Text(trip.isEmpty ? "Drop stops here" : trip.joined(separator: " → "))
                    .frame(maxWidth: .infinity, minHeight: 60)
                    .background(.fill.quaternary, in: .rect(cornerRadius: 10))
                    .dropDestination(for: String.self) { cities, _ in
                        trip.append(contentsOf: cities)
                    }
                """,
                minHeight: 200
            ) {
                DragDropSample()
            }
        }
    }
}

// MARK: - Samples

/// The standard menu bar order, with an app-specific menu in its place.
private struct MenuBarOrder: View {
    private let menus = ["File", "Edit", "Format", "View", "Trip", "Window", "Help"]

    var body: some View {
        ViewThatFits(in: .horizontal) {
            bar
            ScrollView(.horizontal, showsIndicators: false) { bar }
        }
    }

    private var bar: some View {
        HStack(spacing: 14) {
            Image(systemName: "apple.logo")
            Text("Trips").bold()
            ForEach(menus, id: \.self) { menu in
                Text(menu)
                    .padding(.horizontal, menu == "Trip" ? 6 : 0)
                    .padding(.vertical, 2)
                    .background(menu == "Trip" ? Color.accentColor.opacity(0.2) : .clear, in: .rect(cornerRadius: 4))
            }
        }
        .font(.callout)
        .padding(.horizontal, 14)
        .padding(.vertical, 6)
        .background(.bar, in: .rect(cornerRadius: 8))
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(.separator)
        }
        .fixedSize()
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Menu bar order: app menu, File, Edit, Format, View, your menus, Window, Help")
    }
}

private struct DragDropSample: View {
    @State private var trip: [String] = []
    @State private var isTargeted = false

    var body: some View {
        VStack(spacing: 14) {
            HStack {
                ForEach(["Lisbon", "Porto", "Faro"], id: \.self) { city in
                    Text(city)
                        .padding(8)
                        .background(.fill.tertiary, in: .capsule)
                        .draggable(city)
                }
            }
            Text(trip.isEmpty ? "Drop stops here" : trip.joined(separator: " → "))
                .foregroundStyle(trip.isEmpty ? .secondary : .primary)
                .frame(maxWidth: 360, minHeight: 60)
                .background(isTargeted ? AnyShapeStyle(Color.accentColor.opacity(0.2)) : AnyShapeStyle(.fill.quaternary), in: .rect(cornerRadius: 10))
                .dropDestination(for: String.self) { cities, _ in
                    trip.append(contentsOf: cities)
                }
                .onDropSessionUpdated { session in
                    isTargeted = session.phase == .entering || session.phase == .active
                }
            if !trip.isEmpty {
                Button("Clear") { trip = [] }
                    .controlSize(.small)
            }
        }
    }
}
