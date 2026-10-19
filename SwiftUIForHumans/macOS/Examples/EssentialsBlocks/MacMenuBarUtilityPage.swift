import SwiftUI

extension ComponentPage {
    static let menuBarUtility = ComponentPage(
        id: "menu-bar-utility",
        title: "Menu bar utility",
        summary: "A small app that lives in the menu bar and opens a panel when clicked.",
        category: .blocks,
        kind: .block,
        symbol: "menubar.arrow.up.rectangle",
        availability: ["macOS 14.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/menubarextra",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/the-menu-bar",
        aliases: [
            "MenuBarExtra", "status item", "status bar app", "menu bar app", "tray icon", "NSStatusItem",
            "agent app", "LSUIElement", "no Dock icon", "popover from menu bar", "menuBarExtraStyle",
        ],
        related: ["menu-bar-extra", "menu-bar-conventions", "settings-scene", "popover"],
        notes: [
            "**No Dock icon.** For an app that lives only in the menu bar, set `LSUIElement` to `YES` in its Info.plist, so it stays out of the Dock and the app switcher.",
            "**Removing the extra quits the app.** When an app's only scene is a `MenuBarExtra` and people remove it from the menu bar, the system ends the app.",
        ],
        composition: """
        MenuBarExtra("Focus", systemImage:)
        ├── .menuBarExtraStyle(.window)
        └── FocusPanel
            ├── TimelineView (countdown)
            ├── Picker (length)
            ├── Button("Start")
            └── SettingsLink, Quit
        """,
        api: [
            APIItem("`MenuBarExtra(_:systemImage:)`", "A scene that lives in the menu bar."),
            APIItem("`.menuBarExtraStyle(.window)`", "Opens a panel of your own views."),
            APIItem("`.menuBarExtraStyle(.menu)`", "Pulls down a regular menu."),
            APIItem("`MenuBarExtra(…isInserted:)`", "Lets a setting show or hide the extra."),
            APIItem("`LSUIElement`", "Info.plist key that hides the Dock icon."),
            APIItem("`SettingsLink`", "Opens your Settings window from the panel."),
        ],
        guidelines: [
            Guideline(
                "Use a symbol for the menu bar icon.",
                "A template symbol is drawn in the menu bar's own colors, so it looks right in light and dark menu bars and when it's highlighted.",
                good: "A symbol that matches the menu bar.",
                bad: "A full-color icon that stands out."
            ) {
                MacMenuBarStrip(usesSymbol: true)
            } bad: {
                MacMenuBarStrip(usesSymbol: false)
            },
            Guideline(
                "Show a menu unless you need more.",
                "Clicking an extra usually opens a menu. Use the window style only when the feature is too rich for menu items, like this timer."
            ),
            Guideline(
                "Let people choose to show it.",
                "Put a “Show in menu bar” setting in Settings, and offer it during setup so people find it."
            ),
            Guideline(
                "Don't count on it being visible.",
                "The system hides extras when the menu bar runs out of room. Make the same features reachable from your app's windows or its Dock menu too."
            ),
        ]
    ) {
        VStack(spacing: 6) {
            MacMenuBarStrip(usesSymbol: true)
                .frame(width: 190)
            RoundedRectangle(cornerRadius: 10)
                .fill(.background)
                .frame(width: 110, height: 60)
                .overlay {
                    Text("25:00")
                        .font(.title3.monospacedDigit().weight(.semibold))
                }
                .shadow(color: .black.opacity(0.15), radius: 6, y: 2)
                .frame(maxWidth: 190, alignment: .trailing)
        }
    } content: { page in
        MacMenuBarUtilityArticle(page: page)
    }
}

// MARK: - Page

private struct MacMenuBarUtilityArticle: View {
    let page: ComponentPage

    var body: some View {
        ArticlePage(page: page) {
            Prose("Some apps don't need a window at all: a timer, a clipboard history, a network monitor. A `MenuBarExtra` scene puts an icon in the menu bar that's there even when your app isn't the frontmost one. Click it, and a panel of your own SwiftUI views drops down.")
            Prose("A menu bar extra is a scene, and pages can't add scenes to this app, so the menu bar and panel below are drawn. The timer inside is live.")

            SectionTitle("The block")
                .id("code")
            ExampleCard(
                title: "A focus timer in the menu bar",
                caption: "`MenuBarExtra` with `.menuBarExtraStyle(.window)` shows your view in a panel under the icon. Start the timer to try it.",
                code: Self.code,
                minHeight: 360,
                aside: Aside(.note, "The Quit button calls AppKit's `NSApplication.shared.terminate(nil)`. Without a Dock icon, it's how people quit.")
            ) {
                MacMenuBarDrawing()
            }

            if let composition = page.composition {
                CompositionSection(tree: composition)
            }

            SectionTitle("Variations")
            ExampleCard(
                title: "A plain menu",
                caption: "For a handful of commands, use `.menuBarExtraStyle(.menu)`. Buttons become menu items, and `Divider` separates groups.",
                code: """
                MenuBarExtra("Clipboard", systemImage: "list.clipboard") {
                    Button("Paste Last Item") { }
                    Button("Clear History") { }
                    Divider()
                    Button("Quit Clipboard") {
                        NSApplication.shared.terminate(nil)
                    }
                    .keyboardShortcut("q")
                }
                .menuBarExtraStyle(.menu)
                """,
                minHeight: 200
            ) {
                MacMenuDrawing()
            }

            ExampleCard(
                title: "Let people hide it",
                caption: "Pass `isInserted:` a binding to `@AppStorage`, and put the same key behind a checkbox in Settings.",
                code: """
                @main
                struct FocusApp: App {
                    @AppStorage("showsMenuBarExtra") private var showsMenuBarExtra = true

                    var body: some Scene {
                        WindowGroup {
                            ContentView()
                        }
                        MenuBarExtra("Focus", systemImage: "timer", isInserted: $showsMenuBarExtra) {
                            FocusPanel()
                        }
                        .menuBarExtraStyle(.window)
                        Settings {
                            Form {
                                Toggle("Show in menu bar", isOn: $showsMenuBarExtra)
                            }
                            .padding()
                        }
                    }
                }
                """,
                minHeight: 120
            ) {
                MacShowInMenuBarSample()
            }
        }
    }

    static let code = """
    @main
    struct FocusApp: App {
        var body: some Scene {
            MenuBarExtra("Focus", systemImage: "timer") {
                FocusPanel()
            }
            .menuBarExtraStyle(.window)

            Settings {
                Text("Focus Settings")
                    .padding()
            }
        }
    }

    struct FocusPanel: View {
        @State private var minutes = 25
        @State private var endDate: Date?

        var body: some View {
            VStack(spacing: 14) {
                TimelineView(.periodic(from: .now, by: 1)) { context in
                    Text(remaining(at: context.date), format: .time(pattern: .minuteSecond))
                        .font(.system(size: 44, weight: .semibold, design: .rounded))
                        .monospacedDigit()
                }
                Picker("Length", selection: $minutes) {
                    Text("15 min").tag(15)
                    Text("25 min").tag(25)
                    Text("50 min").tag(50)
                }
                .pickerStyle(.segmented)
                .labelsHidden()
                .disabled(endDate != nil)

                Button(endDate == nil ? "Start" : "Stop") {
                    endDate = endDate == nil ? .now.addingTimeInterval(Double(minutes * 60)) : nil
                }
                .buttonStyle(.borderedProminent)
                .keyboardShortcut(.defaultAction)

                Divider()
                HStack {
                    SettingsLink {
                        Text("Settings…")
                    }
                    Spacer()
                    Button("Quit Focus") {
                        // Quits through AppKit.
                        NSApplication.shared.terminate(nil)
                    }
                }
                .buttonStyle(.borderless)
            }
            .padding()
            .frame(width: 260)
        }

        private func remaining(at date: Date) -> Duration {
            guard let endDate else { return .seconds(minutes * 60) }
            return .seconds(max(0, endDate.timeIntervalSince(date)))
        }
    }
    """
}

// MARK: - Drawings

/// The menu bar's trailing end: other extras, the clock, and this app's
/// icon, highlighted while its panel is open.
private struct MacMenuBarStrip: View {
    let usesSymbol: Bool
    var isHighlighted = false

    var body: some View {
        HStack(spacing: 14) {
            Spacer(minLength: 0)
            Group {
                if usesSymbol {
                    Image(systemName: "timer")
                } else {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(LinearGradient(colors: [.orange, .pink], startPoint: .top, endPoint: .bottom))
                        .frame(width: 16, height: 16)
                        .overlay {
                            Image(systemName: "timer")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundStyle(.white)
                        }
                }
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(isHighlighted ? AnyShapeStyle(.fill.secondary) : AnyShapeStyle(.clear), in: .rect(cornerRadius: 5))
            Image(systemName: "wifi")
            Image(systemName: "battery.75percent")
            Text("Mon 9:41")
        }
        .font(.callout)
        .padding(.horizontal, 12)
        .frame(height: 26)
        .background(.bar)
        .clipShape(.rect(cornerRadius: 6))
        .overlay {
            RoundedRectangle(cornerRadius: 6)
                .strokeBorder(.separator)
        }
    }
}

/// The menu bar with the focus timer's panel open under its icon. The
/// panel is the real view.
private struct MacMenuBarDrawing: View {
    var body: some View {
        VStack(alignment: .trailing, spacing: 6) {
            MacMenuBarStrip(usesSymbol: true, isHighlighted: true)
                .frame(width: 440)
            MacFocusPanel()
                .background(.background, in: .rect(cornerRadius: 12))
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(.separator)
                }
                .shadow(color: .black.opacity(0.18), radius: 10, y: 4)
                .padding(.trailing, 112)
        }
    }
}

private struct MacFocusPanel: View {
    @State private var minutes = 25
    @State private var endDate: Date?

    var body: some View {
        VStack(spacing: 14) {
            TimelineView(.periodic(from: .now, by: 1)) { context in
                Text(remaining(at: context.date), format: .time(pattern: .minuteSecond))
                    .font(.system(size: 44, weight: .semibold, design: .rounded))
                    .monospacedDigit()
            }
            Picker("Length", selection: $minutes) {
                Text("15 min").tag(15)
                Text("25 min").tag(25)
                Text("50 min").tag(50)
            }
            .pickerStyle(.segmented)
            .labelsHidden()
            .disabled(endDate != nil)

            Button(endDate == nil ? "Start" : "Stop") {
                endDate = endDate == nil ? .now.addingTimeInterval(Double(minutes * 60)) : nil
            }
            .buttonStyle(.borderedProminent)

            Divider()
            HStack {
                Button("Settings…") {}
                Spacer()
                Button("Quit Focus") {}
            }
            .buttonStyle(.borderless)
        }
        .padding()
        .frame(width: 260)
    }

    private func remaining(at date: Date) -> Duration {
        guard let endDate else { return .seconds(minutes * 60) }
        return .seconds(max(0, endDate.timeIntervalSince(date)))
    }
}

/// A pull-down menu under a menu bar icon, drawn.
private struct MacMenuDrawing: View {
    var body: some View {
        VStack(alignment: .trailing, spacing: 6) {
            MacMenuBarStrip(usesSymbol: true, isHighlighted: true)
                .frame(width: 440)
            VStack(alignment: .leading, spacing: 0) {
                MacMenuRow(title: "Paste Last Item")
                MacMenuRow(title: "Clear History")
                Divider()
                    .padding(.vertical, 4)
                MacMenuRow(title: "Quit Clipboard", shortcut: "⌘Q")
            }
            .padding(5)
            .frame(width: 200)
            .background(.background, in: .rect(cornerRadius: 8))
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(.separator)
            }
            .shadow(color: .black.opacity(0.18), radius: 10, y: 4)
            .padding(.trailing, 170)
        }
    }
}

private struct MacMenuRow: View {
    let title: String
    var shortcut: String? = nil

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            if let shortcut {
                Text(shortcut)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 3)
    }
}

private struct MacShowInMenuBarSample: View {
    @State private var showsMenuBarExtra = true

    var body: some View {
        VStack(spacing: 14) {
            Group {
                if showsMenuBarExtra {
                    MacMenuBarStrip(usesSymbol: true)
                } else {
                    MacMenuBarWithoutExtra()
                }
            }
            .frame(width: 300)
            Toggle("Show in menu bar", isOn: $showsMenuBarExtra.animation(.snappy))
                .toggleStyle(.checkbox)
        }
    }
}

private struct MacMenuBarWithoutExtra: View {
    var body: some View {
        HStack(spacing: 14) {
            Spacer(minLength: 0)
            Image(systemName: "wifi")
            Image(systemName: "battery.75percent")
            Text("Mon 9:41")
        }
        .font(.callout)
        .padding(.horizontal, 12)
        .frame(height: 26)
        .background(.bar)
        .clipShape(.rect(cornerRadius: 6))
        .overlay {
            RoundedRectangle(cornerRadius: 6)
                .strokeBorder(.separator)
        }
    }
}
