import SwiftUI

extension ComponentPage {
    static let settingsWindow = ComponentPage(
        id: "settings-window",
        title: "Settings window",
        summary: "A Settings window with a toolbar of panes, ready to copy into your app.",
        category: .blocks,
        kind: .block,
        symbol: "gearshape.2",
        availability: ["macOS 15.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/settings",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/settings",
        aliases: [
            "preferences", "preferences window", "settings panes", "settings tabs", "⌘,", "command comma",
            "AppStorage", "UserDefaults", "options", "NSPreferencePane", "accounts pane",
        ],
        related: ["settings-scene", "settings-pattern", "form", "toggle", "picker"],
        notes: [
            "**`@AppStorage` keeps every window in sync.** A setting changed here shows up in your other windows right away, and it's saved for the next launch.",
            "**The `TabView` becomes the toolbar.** Inside `Settings`, its tabs turn into the toolbar of panes, so you don't build that toolbar yourself.",
        ],
        composition: """
        Settings
        └── SettingsView
            └── TabView(selection:)
                ├── Tab("General")
                │   └── Form
                ├── Tab("Accounts")
                │   └── List + add and remove
                └── Tab("Advanced")
                    └── Form
        """,
        api: [
            APIItem("`Settings { }`", "The scene behind Settings… and ⌘,."),
            APIItem("`TabView(selection:)`", "In `Settings`, the toolbar of panes."),
            APIItem("`Tab(_:systemImage:value:)`", "One pane, with its icon and title."),
            APIItem("`@AppStorage`", "Saves a setting in `UserDefaults`."),
            APIItem("`.formStyle(.grouped)`", "Rows in rounded groups, like System Settings."),
            APIItem("`SettingsLink`", "A button that opens the Settings window."),
        ],
        guidelines: [
            Guideline(
                "Don't copy system settings.",
                "Scrolling, accessibility, and sign-in methods belong to System Settings. A copy in your app suggests the system choice doesn't apply.",
                good: "Settings only this app has.",
                bad: "A scrolling option the system owns."
            ) {
                MacSettingsRowSample(isSystemSetting: false)
            } bad: {
                MacSettingsRowSample(isSystemSetting: true)
            },
            Guideline(
                "Offer as few settings as you can.",
                "Good defaults mean most people never open the window. Every extra option makes the one people want harder to find."
            ),
            Guideline(
                "Keep the toolbar of panes still.",
                "Don't let people customize it or hide it, and always show which pane is active. People find settings by where they are."
            ),
            Guideline(
                "Reopen the last pane.",
                "People often come back to adjust a related setting. Bind the `TabView` to `@AppStorage`, as the block does."
            ),
            Guideline(
                "Leave task options in the window.",
                "Sorting, filters, and showing a sidebar belong next to the content they change, not in Settings."
            ),
        ]
    ) {
        MacWindowFrame(title: "General", width: 200, height: 120) {
            HStack(spacing: 10) {
                ForEach(["gearshape", "at", "gearshape.2"], id: \.self) { symbol in
                    Image(systemName: symbol)
                        .foregroundStyle(symbol == "gearshape" ? AnyShapeStyle(.tint) : AnyShapeStyle(.secondary))
                }
            }
            .imageScale(.large)
            .frame(maxHeight: .infinity, alignment: .top)
            .padding(.top, 12)
        }
    } content: { page in
        MacSettingsWindowArticle(page: page)
    }
}

// MARK: - Page

private struct MacSettingsWindowArticle: View {
    let page: ComponentPage

    var body: some View {
        ArticlePage(page: page) {
            Prose("Three panes most apps need: **General** for everyday options, **Accounts** for sign-ins, and **Advanced** for the rest. Each pane is a grouped `Form`, the options are saved with `@AppStorage`, and the window reopens on the last pane people used.")
            Prose("Pages can't add a scene to this app, so the window below is drawn, with real panes inside. Click the toolbar to switch panes. To compare with the real thing, open this app's own Settings.")
            SettingsLink {
                Label("Open This App's Settings", systemImage: "gearshape")
            }
            .controlSize(.large)

            SectionTitle("The block")
                .id("code")
            ExampleCard(
                title: "General, Accounts, and Advanced",
                caption: "Add `Settings { SettingsView() }` to your `App`. The `TabView` inside becomes the toolbar of panes.",
                code: Self.code,
                minHeight: 340
            ) {
                MacSettingsDrawing()
            }

            if let composition = page.composition {
                CompositionSection(tree: composition)
            }

            SectionTitle("Open a pane from elsewhere")
            Prose("Because the pane is stored with `@AppStorage`, any view can pick it before opening the window, like a link from an empty state straight to Accounts.")
            CodeBlock(code: """
            struct AddAccountButton: View {
                @AppStorage("settingsPane") private var pane = SettingsPane.general
                @Environment(\\.openSettings) private var openSettings

                var body: some View {
                    Button("Add an Account…") {
                        pane = .accounts
                        openSettings()
                    }
                }
            }
            """)
        }
    }

    static let code = """
    @main
    struct ReaderApp: App {
        var body: some Scene {
            WindowGroup {
                ContentView()
            }
            Settings {
                SettingsView()
            }
        }
    }

    enum SettingsPane: String {
        case general, accounts, advanced
    }

    struct SettingsView: View {
        @AppStorage("settingsPane") private var pane = SettingsPane.general

        var body: some View {
            TabView(selection: $pane) {
                Tab("General", systemImage: "gearshape", value: .general) {
                    GeneralSettingsView()
                }
                Tab("Accounts", systemImage: "at", value: .accounts) {
                    AccountsSettingsView()
                }
                Tab("Advanced", systemImage: "gearshape.2", value: .advanced) {
                    AdvancedSettingsView()
                }
            }
            .frame(width: 460)
        }
    }

    enum RefreshInterval: String, CaseIterable, Identifiable {
        case hourly = "Every hour"
        case daily = "Every day"
        case manually = "Manually"

        var id: Self { self }
    }

    struct GeneralSettingsView: View {
        @AppStorage("refreshInterval") private var refreshInterval = RefreshInterval.hourly
        @AppStorage("opensLinksInBackground") private var opensLinksInBackground = false
        @AppStorage("fontSize") private var fontSize = 14.0

        var body: some View {
            Form {
                Picker("Check for new articles", selection: $refreshInterval) {
                    ForEach(RefreshInterval.allCases) { interval in
                        Text(interval.rawValue).tag(interval)
                    }
                }
                Toggle("Open links in the background", isOn: $opensLinksInBackground)
                Slider(value: $fontSize, in: 10...24) {
                    Text("Font size")
                }
            }
            .formStyle(.grouped)
        }
    }

    struct AccountsSettingsView: View {
        @State private var accounts = ["sam@example.com", "work@example.com"]
        @State private var selection: String?

        var body: some View {
            Form {
                Section {
                    List(accounts, id: \\.self, selection: $selection) { account in
                        Label(account, systemImage: "person.crop.circle")
                    }
                    .frame(height: 120)
                } footer: {
                    HStack {
                        Button("Add Account", systemImage: "plus") {
                            accounts.append("new@example.com")
                        }
                        Button("Remove Account", systemImage: "minus") {
                            accounts.removeAll { $0 == selection }
                        }
                        .disabled(selection == nil)
                    }
                    .labelStyle(.iconOnly)
                    .buttonStyle(.borderless)
                }
            }
            .formStyle(.grouped)
        }
    }

    struct AdvancedSettingsView: View {
        @AppStorage("showsDebugMenu") private var showsDebugMenu = false

        var body: some View {
            Form {
                Toggle("Show Debug menu", isOn: $showsDebugMenu)
                LabeledContent("Cache") {
                    Button("Clear Cache") { }
                }
            }
            .formStyle(.grouped)
        }
    }
    """
}

// MARK: - Drawing

private enum MacSettingsPane: String, CaseIterable {
    case general, accounts, advanced

    var title: String { rawValue.capitalized }

    var symbol: String {
        switch self {
        case .general: "gearshape"
        case .accounts: "at"
        case .advanced: "gearshape.2"
        }
    }
}

private enum MacRefreshInterval: String, CaseIterable, Identifiable {
    case hourly = "Every hour"
    case daily = "Every day"
    case manually = "Manually"

    var id: Self { self }
}

/// The Settings window, drawn: a toolbar of panes over the real pane
/// content. The selected pane is saved, like the real block.
private struct MacSettingsDrawing: View {
    @AppStorage("demo.settingsWindow.pane") private var pane = MacSettingsPane.general

    var body: some View {
        MacWindowFrame(title: pane.title, width: 460, height: 300) {
            VStack(spacing: 0) {
                HStack(spacing: 4) {
                    ForEach(MacSettingsPane.allCases, id: \.self) { option in
                        Button {
                            pane = option
                        } label: {
                            VStack(spacing: 3) {
                                Image(systemName: option.symbol)
                                    .imageScale(.large)
                                Text(option.title)
                                    .font(.caption)
                            }
                            .frame(width: 76, height: 46)
                            .foregroundStyle(pane == option ? Color.accentColor : .secondary)
                            .background(pane == option ? AnyShapeStyle(.fill.tertiary) : AnyShapeStyle(.clear), in: .rect(cornerRadius: 8))
                            .contentShape(.rect)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 6)
                Divider()
                Group {
                    switch pane {
                    case .general: MacGeneralPane()
                    case .accounts: MacAccountsPane()
                    case .advanced: MacAdvancedPane()
                    }
                }
                .frame(maxHeight: .infinity, alignment: .top)
            }
        }
    }
}

private struct MacGeneralPane: View {
    @State private var refreshInterval = MacRefreshInterval.hourly
    @State private var opensLinksInBackground = false
    @State private var fontSize = 14.0

    var body: some View {
        Form {
            Picker("Check for new articles", selection: $refreshInterval) {
                ForEach(MacRefreshInterval.allCases) { interval in
                    Text(interval.rawValue).tag(interval)
                }
            }
            Toggle("Open links in the background", isOn: $opensLinksInBackground)
            Slider(value: $fontSize, in: 10...24) {
                Text("Font size")
            }
        }
        .formStyle(.grouped)
        .scrollDisabled(true)
    }
}

private struct MacAccountsPane: View {
    @State private var accounts = ["sam@example.com", "work@example.com"]
    @State private var selection: String?

    var body: some View {
        Form {
            Section {
                List(accounts, id: \.self, selection: $selection) { account in
                    Label(account, systemImage: "person.crop.circle")
                }
                .frame(height: 120)
            } footer: {
                HStack {
                    Button("Add Account", systemImage: "plus") {
                        accounts.append("new\(accounts.count)@example.com")
                    }
                    Button("Remove Account", systemImage: "minus") {
                        accounts.removeAll { $0 == selection }
                        selection = nil
                    }
                    .disabled(selection == nil)
                }
                .labelStyle(.iconOnly)
                .buttonStyle(.borderless)
            }
        }
        .formStyle(.grouped)
        .scrollDisabled(true)
    }
}

private struct MacAdvancedPane: View {
    @State private var showsDebugMenu = false

    var body: some View {
        Form {
            Toggle("Show Debug menu", isOn: $showsDebugMenu)
            LabeledContent("Cache") {
                Button("Clear Cache") {}
            }
        }
        .formStyle(.grouped)
        .scrollDisabled(true)
    }
}

/// One grouped form, with an app setting or a copied system setting, for
/// the guideline pair.
private struct MacSettingsRowSample: View {
    let isSystemSetting: Bool

    var body: some View {
        Form {
            Toggle("Open links in the background", isOn: .constant(true))
            if isSystemSetting {
                Picker("Show scroll bars", selection: .constant(0)) {
                    Text("Automatically").tag(0)
                    Text("Always").tag(1)
                }
            } else {
                Picker("Check for articles", selection: .constant(0)) {
                    Text("Every hour").tag(0)
                    Text("Every day").tag(1)
                }
            }
        }
        .formStyle(.grouped)
        .scrollDisabled(true)
        .frame(width: 290, height: 120)
    }
}
