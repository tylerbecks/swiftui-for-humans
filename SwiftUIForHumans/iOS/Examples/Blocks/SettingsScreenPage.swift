import SwiftUI

extension ComponentPage {
    static let settingsScreen = ComponentPage(
        id: "settings-screen",
        title: "Settings Screen",
        summary: "A grouped settings form with toggles, a picker, a drill-down row, and sign-out confirmation.",
        category: .blocks,
        kind: .block,
        symbol: "gearshape",
        availability: ["iOS 16.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/form",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/settings",
        aliases: ["preferences", "settings page", "options screen", "account settings", "UITableView grouped", "static table", "config", "setings"],
        related: ["form", "toggle", "picker", "confirmation-dialog"],
        notes: [
            "**Save preferences with `@AppStorage`.** Swap each `@State` for `@AppStorage(\"key\")` and the choice survives relaunches, much like `localStorage` on the web.",
            "**Use `.pickerStyle(.navigationLink)` for long lists.** A `Picker` in a `Form` opens a menu by default; the navigation-link style pushes a full list instead.",
        ],
        guidelines: [
            Guideline(
                "Keep row titles short and explain in the footer.",
                "Short titles scan quickly down the screen, and one footer sentence gives the detail without wrapping every row.",
                good: "A short title, with the detail in the footer.",
                bad: "The detail crammed into a long, wrapping title."
            ) {
                SettingsFooterSample(isShort: true)
            } bad: {
                SettingsFooterSample(isShort: false)
            },
            Guideline(
                "Pick defaults that suit most people.",
                "Every setting is a decision someone has to make. Good defaults let most people use the app without ever opening Settings."
            ),
            Guideline(
                "Offer few settings, and keep task options on the task's screen.",
                "A long settings list is hard to search. Controls like sort order or filters belong on the screen they change, where people can see the result."
            ),
            Guideline(
                "Put Sign Out in its own section at the bottom.",
                "Keeping it apart from everyday rows prevents accidental taps, and a `confirmationDialog` gives people a second chance."
            ),
        ]
    ) {
        BlockThumbnail {
            SettingsScreen()
        }
    } content: { page in
        BlockShowcase(
            page: page,
            tryIt: "Try it: flip **Allow Notifications** off and watch **Sounds** disable, or tap **Sign Out**. Use **Open Full Screen** to drill into **Text Size**; in the small frame it would cover this page.",
            code: settingsScreenSource,
            components: ["form", "toggle", "picker", "navigation-stack", "slider", "confirmation-dialog", "label"]
        ) {
            SettingsScreen()
        } notes: {
            Aside(.note, "The screen is one [Form](catalog://form) in a [NavigationStack](catalog://navigation-stack), which gives it the Settings app look. Each row type, from [Toggle](catalog://toggle) and [Picker](catalog://picker) to `NavigationLink` and `LabeledContent`, styles itself to match.")
            Aside(.note, "The colored icons are a [Label](catalog://label) with a custom icon: an SF Symbol on a rounded, gradient square. Sign Out asks first with a [confirmation dialog](catalog://confirmation-dialog).")
        }
    }
}

/// Guideline preview: one settings row, with its explanation in a footer or crammed into the title.
private struct SettingsFooterSample: View {
    let isShort: Bool
    @State private var isOn = false

    var body: some View {
        Form {
            Section {
                Toggle(isShort ? "Use Cellular Data" : "Use cellular data to sync your library when Wi-Fi is off", isOn: $isOn)
            } footer: {
                if isShort {
                    Text("When this is off, your library only syncs over Wi-Fi.")
                }
            }
        }
        .scrollDisabled(true)
        .frame(width: 280, height: 150)
        .clipShape(.rect(cornerRadius: 12))
    }
}

// <block-source>
private struct SettingsScreen: View {
    @State private var notificationsOn = true
    @State private var soundsOn = true
    @State private var appearance = "System"
    @State private var textSize = 1.0
    @State private var cellularSync = false
    @State private var confirmsSignOut = false

    var body: some View {
        Form {
            Section {
                HStack(spacing: 14) {
                    Text("JA")
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(.white)
                        .frame(width: 56, height: 56)
                        .background(.blue.gradient, in: .circle)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Jamie Appleseed")
                            .font(.headline)
                        Text(verbatim: "jamie@example.com")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 4)
            }

            Section("Notifications") {
                Toggle(isOn: $notificationsOn) {
                    SettingsLabel("Allow Notifications", symbol: "bell.badge.fill", color: .red)
                }
                Toggle(isOn: $soundsOn) {
                    SettingsLabel("Sounds", symbol: "speaker.wave.2.fill", color: .pink)
                }
                .disabled(!notificationsOn)
            }

            Section("Display") {
                Picker(selection: $appearance) {
                    ForEach(["System", "Light", "Dark"], id: \.self) { option in
                        Text(option)
                    }
                } label: {
                    SettingsLabel("Appearance", symbol: "circle.lefthalf.filled", color: .indigo)
                }
                NavigationLink {
                    Form {
                        Slider(value: $textSize, in: 0.8...1.4) {
                            Text("Text Size")
                        } minimumValueLabel: {
                            Image(systemName: "textformat.size.smaller")
                        } maximumValueLabel: {
                            Image(systemName: "textformat.size.larger")
                        }
                        Text("Apps that support Dynamic Type will adjust to your preferred reading size.")
                            .font(.system(size: 17 * textSize))
                    }
                    .navigationTitle("Text Size")
                } label: {
                    SettingsLabel("Text Size", symbol: "textformat.size", color: .blue)
                }
            }

            Section {
                Toggle(isOn: $cellularSync) {
                    SettingsLabel("Use Cellular Data", symbol: "antenna.radiowaves.left.and.right", color: .green)
                }
            } header: {
                Text("Sync")
            } footer: {
                Text("When this is off, your library only syncs over Wi-Fi.")
            }

            Section("About") {
                LabeledContent("Version", value: "2.4.1")
                Link("Privacy Policy", destination: URL(string: "https://www.apple.com/legal/privacy/")!)
            }

            Section {
                Button("Sign Out", role: .destructive) {
                    confirmsSignOut = true
                }
                .frame(maxWidth: .infinity)
            }
        }
        .navigationTitle("Settings")
        .confirmationDialog("Sign out of this account?", isPresented: $confirmsSignOut, titleVisibility: .visible) {
            Button("Sign Out", role: .destructive) {}
        } message: {
            Text("Your downloads will be removed from this iPhone.")
        }
    }
}

/// A row label with a white symbol on a colored rounded square, like the Settings app.
private struct SettingsLabel: View {
    let title: String
    let symbol: String
    let color: Color

    init(_ title: String, symbol: String, color: Color) {
        self.title = title
        self.symbol = symbol
        self.color = color
    }

    var body: some View {
        Label {
            Text(title)
        } icon: {
            Image(systemName: symbol)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 29, height: 29)
                .background(color.gradient, in: .rect(cornerRadius: 7))
        }
    }
}
// </block-source>

// <block-code>
private let settingsScreenSource = #"""
import SwiftUI

struct SettingsScreen: View {
    @State private var notificationsOn = true
    @State private var soundsOn = true
    @State private var appearance = "System"
    @State private var textSize = 1.0
    @State private var cellularSync = false
    @State private var confirmsSignOut = false

    var body: some View {
        Form {
            Section {
                HStack(spacing: 14) {
                    Text("JA")
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(.white)
                        .frame(width: 56, height: 56)
                        .background(.blue.gradient, in: .circle)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Jamie Appleseed")
                            .font(.headline)
                        Text(verbatim: "jamie@example.com")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 4)
            }

            Section("Notifications") {
                Toggle(isOn: $notificationsOn) {
                    SettingsLabel("Allow Notifications", symbol: "bell.badge.fill", color: .red)
                }
                Toggle(isOn: $soundsOn) {
                    SettingsLabel("Sounds", symbol: "speaker.wave.2.fill", color: .pink)
                }
                .disabled(!notificationsOn)
            }

            Section("Display") {
                Picker(selection: $appearance) {
                    ForEach(["System", "Light", "Dark"], id: \.self) { option in
                        Text(option)
                    }
                } label: {
                    SettingsLabel("Appearance", symbol: "circle.lefthalf.filled", color: .indigo)
                }
                NavigationLink {
                    Form {
                        Slider(value: $textSize, in: 0.8...1.4) {
                            Text("Text Size")
                        } minimumValueLabel: {
                            Image(systemName: "textformat.size.smaller")
                        } maximumValueLabel: {
                            Image(systemName: "textformat.size.larger")
                        }
                        Text("Apps that support Dynamic Type will adjust to your preferred reading size.")
                            .font(.system(size: 17 * textSize))
                    }
                    .navigationTitle("Text Size")
                } label: {
                    SettingsLabel("Text Size", symbol: "textformat.size", color: .blue)
                }
            }

            Section {
                Toggle(isOn: $cellularSync) {
                    SettingsLabel("Use Cellular Data", symbol: "antenna.radiowaves.left.and.right", color: .green)
                }
            } header: {
                Text("Sync")
            } footer: {
                Text("When this is off, your library only syncs over Wi-Fi.")
            }

            Section("About") {
                LabeledContent("Version", value: "2.4.1")
                Link("Privacy Policy", destination: URL(string: "https://www.apple.com/legal/privacy/")!)
            }

            Section {
                Button("Sign Out", role: .destructive) {
                    confirmsSignOut = true
                }
                .frame(maxWidth: .infinity)
            }
        }
        .navigationTitle("Settings")
        .confirmationDialog("Sign out of this account?", isPresented: $confirmsSignOut, titleVisibility: .visible) {
            Button("Sign Out", role: .destructive) {}
        } message: {
            Text("Your downloads will be removed from this iPhone.")
        }
    }
}

/// A row label with a white symbol on a colored rounded square, like the Settings app.
private struct SettingsLabel: View {
    let title: String
    let symbol: String
    let color: Color

    init(_ title: String, symbol: String, color: Color) {
        self.title = title
        self.symbol = symbol
        self.color = color
    }

    var body: some View {
        Label {
            Text(title)
        } icon: {
            Image(systemName: symbol)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 29, height: 29)
                .background(color.gradient, in: .rect(cornerRadius: 7))
        }
    }
}

#Preview {
    NavigationStack {
        SettingsScreen()
    }
}
"""#

// MARK: - Block page parts
// Each Blocks file carries its own private copy of these, so files stay
// independent and nothing leaks into the shared module namespace.

/// The standard block page: live screen in a phone frame, what it is built
/// with (tappable links to those catalog pages), then the full source.
private struct BlockShowcase<Screen: View, Notes: View, More: View>: View {
    let page: ComponentPage
    let tryIt: String
    let code: String
    let components: [ComponentPage.ID]
    let hasNavigationBar: Bool
    let screen: Screen
    let notes: Notes
    let more: More

    @Environment(\.openPage) private var openPage
    @State private var showsFullScreen = false

    init(
        page: ComponentPage,
        tryIt: String,
        code: String,
        components: [ComponentPage.ID],
        hasNavigationBar: Bool = true,
        @ViewBuilder screen: () -> Screen,
        @ViewBuilder notes: () -> Notes,
        @ViewBuilder more: () -> More
    ) {
        self.page = page
        self.tryIt = tryIt
        self.code = code
        self.components = components
        self.hasNavigationBar = hasNavigationBar
        self.screen = screen()
        self.notes = notes()
        self.more = more()
    }

    var body: some View {
        ArticlePage(page: page) {
            VStack(alignment: .leading, spacing: 12) {
                PreviewCard(title: "Live screen", minHeight: 600) {
                    PhoneScreen(hasNavigationBar: hasNavigationBar) {
                        screen
                    }
                }
                Button {
                    showsFullScreen = true
                } label: {
                    Label("Open Full Screen", systemImage: "arrow.up.left.and.arrow.down.right")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                .accessibilityIdentifier("open-full-screen")
                Label {
                    RichText(tryIt)
                        .fixedSize(horizontal: false, vertical: true)
                } icon: {
                    Image(systemName: "hand.tap")
                        .foregroundStyle(.tint)
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
            .id("live")

            VStack(alignment: .leading, spacing: 12) {
                SectionTitle("Built with")
                notes
                FlowLayout(spacing: 8) {
                    ForEach(components.compactMap { Catalog.page(id: $0) }) { linked in
                        Button {
                            openPage(linked.id)
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: linked.symbol)
                                Text(linked.title)
                                Image(systemName: "chevron.right")
                                    .font(.caption2.weight(.bold))
                                    .foregroundStyle(.secondary)
                            }
                            .font(.subheadline.weight(.medium))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(.fill.tertiary, in: .capsule)
                            .contentShape(.capsule)
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("uses-\(linked.id)")
                    }
                }
            }
            // Links written as [Form](catalog://form) in callouts open that page.
            .environment(\.openURL, OpenURLAction { url in
                guard url.scheme == "catalog", let id = url.host(), Catalog.page(id: id) != nil else {
                    return .systemAction
                }
                openPage(id)
                return .handled
            })

            VStack(alignment: .leading, spacing: 12) {
                SectionTitle("Code")
                Prose(hasNavigationBar
                      ? "The complete screen, exactly as it runs above. Paste it into a new SwiftUI file and it compiles as is. Show it inside a `NavigationStack`, as the `#Preview` at the bottom does, so its title and toolbar have a bar to live in."
                      : "The complete screen, exactly as it runs above. Paste it into a new SwiftUI file and it compiles as is; then swap the sample data for your own.")
                CodeBlock(code: code)
            }
            .id("code")

            more
        }
        // A sheet starts a fresh navigation context, so pushes, the search
        // field, and the toolbar all behave exactly as in a real app.
        .sheet(isPresented: $showsFullScreen) {
            Group {
                if hasNavigationBar {
                    NavigationStack { screen }
                } else {
                    screen
                }
            }
            .presentationDragIndicator(.visible)
        }
    }
}

private extension BlockShowcase where More == EmptyView {
    init(
        page: ComponentPage,
        tryIt: String,
        code: String,
        components: [ComponentPage.ID],
        hasNavigationBar: Bool = true,
        @ViewBuilder screen: () -> Screen,
        @ViewBuilder notes: () -> Notes
    ) {
        self.init(page: page, tryIt: tryIt, code: code, components: components,
                  hasNavigationBar: hasNavigationBar, screen: screen, notes: notes) {
            EmptyView()
        }
    }
}

/// The block's real screen, scaled down for the overview card.
private struct BlockThumbnail<Screen: View>: View {
    var hasNavigationBar = true
    @ViewBuilder let screen: Screen

    var body: some View {
        PhoneScreen(hasNavigationBar: hasNavigationBar) {
            screen
        }
        .allowsHitTesting(false)
        .scaleEffect(0.44, anchor: .top)
        .frame(width: 314 * 0.44, height: 136, alignment: .top)
        .padding(.top, 14)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}
