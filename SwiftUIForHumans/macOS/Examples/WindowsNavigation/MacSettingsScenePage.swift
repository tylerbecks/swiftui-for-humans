import SwiftUI

extension ComponentPage {
    static let settingsScene = ComponentPage(
        id: "settings-scene",
        title: "Settings",
        summary: "The app's Settings window, opened from the app menu or with ⌘,.",
        category: .windows,
        symbol: "gearshape",
        availability: ["macOS 11.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/settings",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/settings",
        aliases: ["preferences", "settings window", "command comma", "⌘,", "SettingsLink", "openSettings", "NSPreferences", "options"],
        related: ["toggle"],
        notes: [
            "**You get the menu item and ⌘, for free.** Adding a `Settings` scene puts Settings… in the app menu and wires up the shortcut.",
            "**Settings is a window like any other.** Use `@AppStorage` so a change shows up in every open window right away.",
        ],
        about: "`Settings` is a scene, like `WindowGroup`. It gives your app one Settings window, the Settings… item in the app menu, and ⌘, to open it.\n\nPut a `Form` inside for a single pane, or a `TabView` to split settings into panes that switch from the window's toolbar.",
        composition: """
        Settings
        └── TabView
            ├── Tab("General")
            │   └── Form
            └── Tab("Advanced")
                └── Form
        """,
        api: [
            APIItem("`Settings { }`", "The scene for the app's Settings window."),
            APIItem("`TabView`", "Inside `Settings`, a toolbar of panes."),
            APIItem("`SettingsLink`", "A button that opens the Settings window."),
            APIItem("`@Environment(\\.openSettings)`", "Opens Settings from your own code."),
            APIItem("`@AppStorage`", "Saves a setting and keeps windows in sync."),
            APIItem("`.formStyle(.grouped)`", "Rows in rounded groups, like System Settings."),
        ],
        guidelines: [
            Guideline(
                "Open settings from the app menu, not a toolbar button.",
                "People look for Settings… in the app menu and press ⌘,. A gear in the toolbar takes space from the commands people use all the time.",
                good: "The toolbar keeps its everyday commands.",
                bad: "A settings gear crowds the toolbar."
            ) {
                MacWindowFrame(title: "Notes", width: 230, height: 90) {
                    Color.clear
                } toolbar: {
                    Image(systemName: "square.and.pencil")
                    Image(systemName: "magnifyingglass")
                }
            } bad: {
                MacWindowFrame(title: "Notes", width: 230, height: 90) {
                    Color.clear
                } toolbar: {
                    Image(systemName: "square.and.pencil")
                    Image(systemName: "gearshape")
                }
            },
            Guideline(
                "Keep it short, and keep task options with the task.",
                "Settings are for things people change rarely. Options like sorting or showing a sidebar belong in the window they affect."
            ),
            Guideline(
                "Reopen the pane people used last.",
                "People often come back to change a related setting. Store the selected tab with `@AppStorage`, as in the example below."
            ),
            Guideline(
                "Don't repeat system settings.",
                "Appearance, scrolling, and accessibility belong to System Settings. A copy in your app suggests the system choice doesn't apply."
            ),
        ]
    ) {
        MacWindowFrame(title: "Settings", width: 200, height: 120) {
            VStack(alignment: .leading, spacing: 6) {
                Toggle("Show preview", isOn: .constant(true))
                Toggle("Play sounds", isOn: .constant(false))
            }
            .toggleStyle(.checkbox)
            .font(.caption)
        }
    } content: { page in
        MacSettingsSceneArticle(page: page)
    }
}

extension Catalog {
    /// The one-pane settings sample, in a real window.
    static let settingsSceneDemoWindow = DemoWindow(id: "settings-one-pane", title: "Reader Settings", size: CGSize(width: 420, height: 200)) {
        OnePaneSettingsSample()
    }
}

// MARK: - Page

private struct MacSettingsSceneArticle: View {
    let page: ComponentPage
    @AppStorage("demo.settings.pane") private var pane = DemoPane.general

    var body: some View {
        ArticlePage(page: page) {
            if let about = page.about {
                AboutSection(text: about)
            }
            HStack(spacing: 12) {
                SettingsLink {
                    Label("Open This App's Settings", systemImage: "gearshape")
                }
                OpenDemoWindowButton(id: "settings-one-pane", label: "Open the One-Pane Sample")
            }
            .controlSize(.large)

            SectionTitle("Usage")
                .id("code")
            CodeBlock(code: """
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
            """)

            if let composition = page.composition {
                CompositionSection(tree: composition)
            }

            SectionTitle("Examples")
                .id("examples")
            ExampleCard(
                title: "One pane",
                caption: "With a handful of settings, use a single grouped `Form` and give the window a fixed width.",
                code: """
                struct SettingsView: View {
                    @AppStorage("showsPreview") private var showsPreview = true
                    @AppStorage("fontSize") private var fontSize = 14.0

                    var body: some View {
                        Form {
                            Toggle("Show preview", isOn: $showsPreview)
                            Slider(value: $fontSize, in: 10...24) {
                                Text("Font size")
                            }
                        }
                        .formStyle(.grouped)
                        .frame(width: 400)
                    }
                }
                """,
                minHeight: 220,
                aside: Aside(.note, "With one pane, the HIG suggests titling the window “App Name Settings”.")
            ) {
                MacWindowFrame(title: "Reader Settings", width: 420, height: 200) {
                    OnePaneSettingsSample()
                }
            }

            ExampleCard(
                title: "Panes that remember where you were",
                caption: "A `TabView` inside `Settings` becomes the toolbar of panes. Bind it to `@AppStorage` so it reopens on the last pane.",
                code: """
                enum SettingsPane: String {
                    case general, advanced
                }

                struct SettingsView: View {
                    @AppStorage("settingsPane") private var pane = SettingsPane.general

                    var body: some View {
                        TabView(selection: $pane) {
                            Tab("General", systemImage: "gearshape", value: .general) {
                                Form { Toggle("Show preview", isOn: .constant(true)) }
                            }
                            Tab("Advanced", systemImage: "gearshape.2", value: .advanced) {
                                Form { Toggle("Enable logging", isOn: .constant(false)) }
                            }
                        }
                        .frame(width: 440)
                    }
                }
                """,
                minHeight: 220
            ) {
                PanesSample(pane: $pane)
            }

            ExampleCard(
                title: "Open Settings from your own UI",
                caption: "Use `SettingsLink` for a button, or `@Environment(\\.openSettings)` from code, like a link in an empty state.",
                code: """
                ContentUnavailableView {
                    Label("No Accounts", systemImage: "person.crop.circle")
                } description: {
                    Text("Add an account in Settings to start syncing.")
                } actions: {
                    SettingsLink {
                        Text("Open Settings")
                    }
                }
                """,
                minHeight: 220
            ) {
                ContentUnavailableView {
                    Label("No Accounts", systemImage: "person.crop.circle")
                } description: {
                    Text("Add an account in Settings to start syncing.")
                } actions: {
                    SettingsLink {
                        Text("Open Settings")
                    }
                }
            }
        }
    }
}

// MARK: - Samples

/// The one-pane example's form, shared by the inline preview and the
/// demo window.
private struct OnePaneSettingsSample: View {
    @State private var showsPreview = true
    @State private var fontSize = 14.0

    var body: some View {
        Form {
            Toggle("Show preview", isOn: $showsPreview)
            Slider(value: $fontSize, in: 10...24) {
                Text("Font size")
            }
        }
        .formStyle(.grouped)
        .scrollDisabled(true)
    }
}

private enum DemoPane: String, CaseIterable {
    case general, advanced

    var title: String { rawValue.capitalized }
    var symbol: String { self == .general ? "gearshape" : "gearshape.2" }
}

/// A drawing of a Settings window with a toolbar of panes. Click a pane to
/// switch; the choice is saved, so it's still selected next time.
private struct PanesSample: View {
    @Binding var pane: DemoPane

    var body: some View {
        MacWindowFrame(title: pane.title, width: 420, height: 200) {
            VStack(spacing: 0) {
                HStack(spacing: 4) {
                    ForEach(DemoPane.allCases, id: \.self) { option in
                        Button {
                            pane = option
                        } label: {
                            VStack(spacing: 3) {
                                Image(systemName: option.symbol)
                                    .imageScale(.large)
                                Text(option.title)
                                    .font(.caption)
                            }
                            .frame(width: 72, height: 46)
                            .foregroundStyle(pane == option ? Color.accentColor : .secondary)
                            .background(pane == option ? AnyShapeStyle(.fill.tertiary) : AnyShapeStyle(.clear), in: .rect(cornerRadius: 8))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 6)
                Divider()
                Form {
                    switch pane {
                    case .general: Toggle("Show preview", isOn: .constant(true))
                    case .advanced: Toggle("Enable logging", isOn: .constant(false))
                    }
                }
                .formStyle(.grouped)
                .scrollDisabled(true)
            }
        }
    }
}
