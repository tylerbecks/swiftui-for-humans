import SwiftUI

extension ComponentPage {
    static let menuBarExtra = ComponentPage(
        id: "menu-bar-extra",
        title: "MenuBarExtra",
        summary: "A menu bar icon that opens a menu or a small window, whichever app is in front.",
        category: .windows,
        symbol: "menubar.arrow.up.rectangle",
        availability: ["macOS 13.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/menubarextra",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/the-menu-bar",
        aliases: [
            "menu bar extra", "status item", "status bar item", "NSStatusItem", "NSStatusBar",
            "menu bar app", "menulet", "tray icon", "system tray", "LSUIElement", "agent app",
            "menuBarExtraStyle", "isInserted",
        ],
        related: ["menu-bar-utility", "settings-scene", "window", "commands", "menu-bar-conventions"],
        notes: [
            "**Removing it quits a menu bar–only app.** If the extra is the app's only scene and someone removes it from the menu bar, the system ends the app.",
            "**The menu bar is 24 points tall.** Size a custom icon to fit, or use an SF Symbol, which already does.",
        ],
        about: "`MenuBarExtra` is a scene that puts an icon at the trailing end of the menu bar. It stays there while your app runs, even when another app is in front. Clicking it shows a menu, or with `.menuBarExtraStyle(.window)`, a small window of controls.\n\nAdd it beside your `WindowGroup`, or make it the only scene for an app that lives in the menu bar.",
        composition: """
        App
        ├── WindowGroup
        └── MenuBarExtra("Weather", systemImage:)
            └── Button, Toggle, Divider…
        """,
        api: [
            APIItem("`MenuBarExtra(_:systemImage:) { }`", "An icon and title, with a menu."),
            APIItem("`MenuBarExtra(…, isInserted:)`", "Shown only while the binding is true."),
            APIItem("`.menuBarExtraStyle(.menu)`", "The content as a menu that pulls down."),
            APIItem("`.menuBarExtraStyle(.window)`", "The content in a small, popover-like window."),
            APIItem("`@Environment(\\.openWindow)`", "Opens one of your app's windows from the menu."),
            APIItem("`LSUIElement`", "Info.plist key that hides the Dock icon."),
        ],
        guidelines: [
            Guideline(
                "Use a symbol for the icon.",
                "The system tints a symbol or template image so it suits light and dark menu bars and the selected state. A full-color picture can't adapt.",
                good: "A symbol the system can tint.",
                bad: "A colored image that can't adapt."
            ) {
                MenuBarIconSample(isSymbol: true)
            } bad: {
                MenuBarIconSample(isSymbol: false)
            },
            Guideline(
                "Show a menu, not a popover.",
                "A menu is what people expect from a menu bar icon. Save the `.window` style for features too rich for a menu."
            ),
            Guideline(
                "Let people decide whether it appears.",
                "Add a setting to turn it on or off in your Settings window, and consider offering the choice during setup."
            ),
            Guideline(
                "Don't count on it being visible.",
                "The system hides menu bar extras when space runs short. Offer the same features somewhere else too, like a Dock menu."
            ),
        ]
    ) {
        VStack(alignment: .trailing, spacing: 6) {
            WindowsNavMenuBar(width: 200) {
                Image(systemName: "cloud.sun")
                    .foregroundStyle(Color.accentColor)
            }
            WindowsNavMenuDrawing(items: ["18° Partly Cloudy", nil, "Refresh"], width: 130)
                .padding(.trailing, 92)
        }
    } content: { page in
        MacMenuBarExtraArticle(page: page)
    }
}

// MARK: - Page

private struct MacMenuBarExtraArticle: View {
    let page: ComponentPage
    @State private var isInserted = true

    var body: some View {
        ArticlePage(page: page) {
            if let about = page.about {
                AboutSection(text: about)
            }
            Aside(.note, "A menu bar extra is a scene, so a page can't add one to this app. The previews below are drawings with live content; the code is the real thing.")

            SectionTitle("Usage")
                .id("code")
            CodeBlock(code: """
            @main
            struct WeatherApp: App {
                var body: some Scene {
                    WindowGroup {
                        ContentView()
                    }
                    MenuBarExtra("Weather", systemImage: "cloud.sun") {
                        Button("Refresh") { }
                        Divider()
                        Button("Open Weather") { }
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
                title: "A menu",
                caption: "By default, the content is a menu that pulls down from the icon. Use buttons, toggles, and dividers, as in any menu.",
                code: """
                @State private var isPaused = false

                MenuBarExtra("Timer", systemImage: "timer") {
                    Button("Start Focus Session") { }
                    Toggle("Pause Notifications", isOn: $isPaused)
                    Divider()
                    SettingsLink {
                        Text("Settings…")
                    }
                }
                """,
                minHeight: 220
            ) {
                VStack(alignment: .trailing, spacing: 4) {
                    WindowsNavMenuBar(width: 380) {
                        Image(systemName: "timer")
                    }
                    WindowsNavMenuDrawing(
                        items: ["Start Focus Session", "Pause Notifications", nil, "Settings…"],
                        width: 210,
                        highlighted: "Start Focus Session"
                    )
                    .padding(.trailing, 128)
                }
            }

            ExampleCard(
                title: "A small window",
                caption: "With `.menuBarExtraStyle(.window)`, the content shows in a popover-like window, laid out like controls in a normal window.",
                code: """
                MenuBarExtra("Weather", systemImage: "cloud.sun") {
                    WeatherPanel()
                }
                .menuBarExtraStyle(.window)

                struct WeatherPanel: View {
                    @State private var usesCelsius = true

                    var body: some View {
                        VStack(alignment: .leading, spacing: 12) {
                            Label("18°  Partly Cloudy", systemImage: "cloud.sun")
                                .font(.title2)
                            Gauge(value: 0.4) { Text("Rain") }
                            Toggle("Celsius", isOn: $usesCelsius)
                        }
                        .padding()
                        .frame(width: 240)
                    }
                }
                """,
                minHeight: 260
            ) {
                VStack(alignment: .trailing, spacing: 6) {
                    WindowsNavMenuBar(width: 380) {
                        Image(systemName: "cloud.sun")
                    }
                    WeatherPanelSample()
                        .background(.background, in: .rect(cornerRadius: 12))
                        .overlay {
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(.separator)
                        }
                        .shadow(color: .black.opacity(0.15), radius: 8, y: 3)
                        .padding(.trailing, 50)
                }
            }

            ExampleCard(
                title: "Let people turn it off",
                caption: "Pass `isInserted:` a binding, like an `@AppStorage` value, and put a toggle for it in your Settings window.",
                code: """
                @main
                struct WeatherApp: App {
                    @AppStorage("showsInMenuBar") private var showsInMenuBar = true

                    var body: some Scene {
                        WindowGroup {
                            ContentView()
                        }
                        MenuBarExtra("Weather", systemImage: "cloud.sun", isInserted: $showsInMenuBar) {
                            Button("Refresh") { }
                        }
                        Settings {
                            Form {
                                Toggle("Show in menu bar", isOn: $showsInMenuBar)
                            }
                            .padding()
                        }
                    }
                }
                """,
                minHeight: 160
            ) {
                VStack(spacing: 18) {
                    WindowsNavMenuBar(width: 380) {
                        if isInserted {
                            Image(systemName: "cloud.sun")
                                .transition(.opacity)
                        }
                    }
                    .animation(.snappy, value: isInserted)
                    Toggle("Show in menu bar", isOn: $isInserted)
                }
            }

            SectionTitle("An app that lives in the menu bar")
            Prose("Make `MenuBarExtra` the only scene, and set `LSUIElement` to true in your Info.plist so the app stays out of the Dock and the app switcher.")
            CodeBlock(code: """
            @main
            struct ClipboardApp: App {
                var body: some Scene {
                    MenuBarExtra("Clipboard", systemImage: "list.clipboard") {
                        ClipboardMenu()
                    }
                }
            }
            """)
        }
    }
}

// MARK: - Samples

private struct WeatherPanelSample: View {
    @State private var usesCelsius = true

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(usesCelsius ? "18°  Partly Cloudy" : "64°  Partly Cloudy", systemImage: "cloud.sun")
                .font(.title2)
            Gauge(value: 0.4) { Text("Rain") }
            Toggle("Celsius", isOn: $usesCelsius)
        }
        .padding()
        .frame(width: 240)
    }
}

/// A slice of the menu bar with a weather extra, drawn as a symbol or as
/// a full-color image.
private struct MenuBarIconSample: View {
    let isSymbol: Bool

    var body: some View {
        WindowsNavMenuBar(width: 260) {
            if isSymbol {
                Image(systemName: "cloud.sun")
            } else {
                Image(systemName: "cloud.sun.fill")
                    .symbolRenderingMode(.multicolor)
                    .padding(3)
                    .background(
                        LinearGradient(colors: [.blue, .cyan], startPoint: .top, endPoint: .bottom),
                        in: .rect(cornerRadius: 4)
                    )
            }
        }
    }
}
