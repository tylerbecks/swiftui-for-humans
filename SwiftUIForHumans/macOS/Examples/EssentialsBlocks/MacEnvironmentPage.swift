import SwiftUI

extension ComponentPage {
    static let environment = ComponentPage(
        id: "environment",
        title: "Environment",
        summary: "Values that flow down from a window to every view inside it, from control size to actions.",
        category: .dataFlow,
        kind: .concept,
        symbol: "square.stack.3d.down.right",
        availability: ["macOS 10.15+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/environmentvalues",
        aliases: [
            "@Environment", "EnvironmentValues", "@Entry", "EnvironmentKey", "context", "React context",
            "useContext", "dependency injection", "controlSize", "openWindow", "openSettings",
            "appearsActive", "key window", "dismissWindow", "inherited values",
        ],
        related: ["observable", "state-binding", "opening-windows", "settings-scene", "button"],
        notes: [
            "**It only flows down.** A value you set applies to that view and the views inside it. Parents and siblings never see it.",
            "**Prefer the dedicated modifier.** Write `.controlSize(.small)` rather than `.environment(\\.controlSize, .small)`, and give your own values a modifier too.",
            "**Actions live here too.** `openWindow`, `dismissWindow`, and `openSettings` are values you call like functions.",
        ],
        api: [
            APIItem("`@Environment(\\.controlSize)`", "Reads a value from the environment."),
            APIItem("`.environment(\\.key, value)`", "Sets a value for this view and its children."),
            APIItem("`@Entry var name = default`", "Declares your own environment value."),
            APIItem("`\\.openWindow`", "Opens a `Window` or `WindowGroup` by ID."),
            APIItem("`\\.openSettings`", "Opens the app's Settings window."),
            APIItem("`\\.appearsActive`", "False while the window isn't the key window."),
            APIItem("`\\.dismissWindow`", "Closes a window by ID."),
        ]
    ) {
        MacEnvironmentThumbnail()
    } content: { page in
        MacEnvironmentArticle(page: page)
    }
}

extension Catalog {
    /// The small window the openWindow example opens.
    static let environmentDemoWindow = DemoWindow(
        id: "environment-activity",
        title: "Activity",
        size: CGSize(width: 320, height: 220)
    ) {
        MacActivityWindowContent()
    }
}

extension EnvironmentValues {
    /// How much room each episode row gets. The page's `@Entry` example.
    @Entry var macSampleRowDensity: MacSampleRowDensity = .comfortable
}

enum MacSampleRowDensity: String, CaseIterable, Identifiable {
    case compact, comfortable

    var id: Self { self }
}

// MARK: - Thumbnail

private struct MacEnvironmentThumbnail: View {
    var body: some View {
        VStack(spacing: 6) {
            Text(".controlSize(.small)")
                .font(.caption.monospaced())
                .foregroundStyle(.secondary)
            Image(systemName: "arrow.down")
                .foregroundStyle(.tint)
            HStack(spacing: 6) {
                Button("Save") {}
                Toggle("Sync", isOn: .constant(true))
            }
            .controlSize(.small)
            .padding(8)
            .background(.fill.tertiary, in: .rect(cornerRadius: 8))
        }
    }
}

// MARK: - Page

private struct MacEnvironmentArticle: View {
    let page: ComponentPage

    var body: some View {
        ArticlePage(page: page) {
            Prose("The environment is a set of values every view can read without anyone passing them in: the window's color scheme, the size of its controls, whether it's the window people are working in, and actions like opening another window.")
            Prose("Set a value on a container and every view inside gets it, like CSS inheritance or React context. A view reads it with `@Environment`.")

            SectionTitle("Try it")
            Prose("One `.controlSize` on the container sets the size of every control inside it.")
            MacControlSizeFlow()

            SectionTitle("Values you'll use on the Mac")
            ConnectFacts(rows: [
                ("controlSize", "Mini, small, regular, or large controls. Set it with `.controlSize(_:)`."),
                ("openWindow", "Opens a `Window` or a `WindowGroup` by its ID. An open `Window` comes to the front."),
                ("openSettings", "Opens your app's Settings window, the same one ⌘, opens."),
                ("appearsActive", "Whether views should look active. False in a window that isn't the key window."),
                ("dismissWindow", "Closes a window by its ID."),
                ("colorScheme", "Light or dark, for the rare view that has to draw itself differently."),
            ])

            SectionTitle("Examples")
                .id("examples")
            MacEnvironmentExamples()
        }
    }
}

private struct MacControlSizeFlow: View {
    @State private var size = MacEnvControlSize.small
    @State private var isOn = true
    @State private var level = 0.4
    @State private var quality = "High"

    var body: some View {
        VStack(spacing: 18) {
            Picker("Control size", selection: $size) {
                ForEach(MacEnvControlSize.allCases) { option in
                    Text(option.rawValue).tag(option)
                }
            }
            .pickerStyle(.segmented)
            .labelsHidden()
            .frame(width: 320)

            VStack(alignment: .leading, spacing: 10) {
                Text("VStack { … }.controlSize(.\(size.rawValue))")
                    .font(.caption.monospaced())
                    .foregroundStyle(.secondary)
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Button("Export…") {}
                        Button("Share") {}
                            .buttonStyle(.borderedProminent)
                    }
                    Toggle("Include artwork", isOn: $isOn)
                    Picker("Quality", selection: $quality) {
                        Text("High").tag("High")
                        Text("Medium").tag("Medium")
                    }
                    .frame(width: 200)
                    Slider(value: $level, in: 0...1) {
                        Text("Volume")
                    }
                    .frame(width: 200)
                }
                .controlSize(size.size)
                .padding(16)
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(.tint, style: StrokeStyle(lineWidth: 1, dash: [4, 3]))
                }
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(Surface.preview)
        .cardStyle()
    }
}

private enum MacEnvControlSize: String, CaseIterable, Identifiable {
    case mini, small, regular, large

    var id: Self { self }

    var size: ControlSize {
        switch self {
        case .mini: .mini
        case .small: .small
        case .regular: .regular
        case .large: .large
        }
    }
}

// MARK: - Examples

private struct MacEnvironmentExamples: View {
    @State private var density = MacSampleRowDensity.compact

    var body: some View {
        VStack(alignment: .leading, spacing: 44) {
            ExampleCard(
                title: "Open another window",
                caption: "Read `openWindow` and call it with the ID of a `Window` or `WindowGroup` in your app. This one opens a real window.",
                code: """
                @main
                struct ReaderApp: App {
                    var body: some Scene {
                        WindowGroup {
                            ContentView()
                        }
                        Window("Activity", id: "activity") {
                            ActivityView()
                        }
                    }
                }

                struct ShowActivityButton: View {
                    @Environment(\\.openWindow) private var openWindow

                    var body: some View {
                        Button("Show Activity") {
                            openWindow(id: "activity")
                        }
                    }
                }
                """,
                minHeight: 120,
                aside: Aside(.note, "A `Window` also gets an item in the Window menu, so people can reopen it without your button.")
            ) {
                MacShowActivityButton()
            }

            ExampleCard(
                title: "Open Settings from your own button",
                caption: "Call `openSettings` to show your Settings window, for example from an empty state. This one opens this app's Settings.",
                code: """
                struct AccountsEmptyState: View {
                    @Environment(\\.openSettings) private var openSettings

                    var body: some View {
                        ContentUnavailableView {
                            Label("No Accounts", systemImage: "person.crop.circle")
                        } actions: {
                            Button("Add an Account…") {
                                openSettings()
                            }
                        }
                    }
                }
                """,
                minHeight: 180
            ) {
                MacAccountsEmptyState()
            }

            ExampleCard(
                title: "Look inactive when the window isn't key",
                caption: "Read `appearsActive` in custom views and drop the accent color when it's false. Click another window to see this badge turn gray.",
                code: """
                struct LiveBadge: View {
                    @Environment(\\.appearsActive) private var appearsActive

                    var body: some View {
                        Label("Live", systemImage: "dot.radiowaves.left.and.right")
                            .font(.callout.weight(.semibold))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .foregroundStyle(appearsActive ? .white : .secondary)
                            .background(appearsActive ? Color.accentColor : Color.secondary.opacity(0.2), in: .capsule)
                    }
                }
                """,
                minHeight: 120,
                aside: Aside(.note, "Selection in lists and tables turns gray on its own. Views and styles you draw yourself need to check `appearsActive`.")
            ) {
                MacLiveBadge()
            }

            ExampleCard(
                title: "Your own value with @Entry",
                caption: "Declare a value with `@Entry` in an `EnvironmentValues` extension, and add a modifier that sets it. Rows read it; one modifier changes them all.",
                code: """
                enum RowDensity {
                    case compact, comfortable
                }

                extension EnvironmentValues {
                    @Entry var rowDensity: RowDensity = .comfortable
                }

                extension View {
                    func rowDensity(_ density: RowDensity) -> some View {
                        environment(\\.rowDensity, density)
                    }
                }

                struct EpisodeRow: View {
                    @Environment(\\.rowDensity) private var density
                    let title: String

                    var body: some View {
                        Label(title, systemImage: "waveform")
                            .padding(.vertical, density == .compact ? 2 : 8)
                    }
                }

                VStack(alignment: .leading, spacing: 0) {
                    EpisodeRow(title: "Episode 12")
                    EpisodeRow(title: "Episode 11")
                }
                .rowDensity(.compact)
                """,
                minHeight: 200
            ) {
                VStack(spacing: 14) {
                    Picker("Density", selection: $density) {
                        ForEach(MacSampleRowDensity.allCases) { option in
                            Text(option.rawValue.capitalized).tag(option)
                        }
                    }
                    .pickerStyle(.segmented)
                    .labelsHidden()
                    .frame(width: 240)
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(["Episode 12", "Episode 11", "Episode 10"], id: \.self) { title in
                            MacEpisodeRow(title: title)
                            Divider()
                        }
                    }
                    .frame(width: 240)
                    .environment(\.macSampleRowDensity, density)
                    .animation(.snappy, value: density)
                }
            }
        }
    }
}

private struct MacShowActivityButton: View {
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        Button("Show Activity", systemImage: "chart.bar.doc.horizontal") {
            openWindow(id: DemoWindow.sceneID, value: "environment-activity")
        }
        .controlSize(.large)
    }
}

private struct MacAccountsEmptyState: View {
    @Environment(\.openSettings) private var openSettings

    var body: some View {
        ContentUnavailableView {
            Label("No Accounts", systemImage: "person.crop.circle")
        } actions: {
            Button("Add an Account…") {
                openSettings()
            }
        }
    }
}

private struct MacLiveBadge: View {
    @Environment(\.appearsActive) private var appearsActive

    var body: some View {
        VStack(spacing: 10) {
            Label("Live", systemImage: "dot.radiowaves.left.and.right")
                .font(.callout.weight(.semibold))
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .foregroundStyle(appearsActive ? .white : .secondary)
                .background(appearsActive ? Color.accentColor : Color.secondary.opacity(0.2), in: .capsule)
            Text("appearsActive = \(appearsActive ? "true" : "false")")
                .font(.footnote.monospaced())
                .foregroundStyle(.secondary)
        }
    }
}

private struct MacEpisodeRow: View {
    @Environment(\.macSampleRowDensity) private var density
    let title: String

    var body: some View {
        Label(title, systemImage: "waveform")
            .padding(.vertical, density == .compact ? 2 : 8)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// The content of the window the openWindow example opens.
private struct MacActivityWindowContent: View {
    @Environment(\.dismissWindow) private var dismissWindow

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.bar.doc.horizontal")
                .font(.system(size: 36))
                .foregroundStyle(.tint)
            Text("Opened with `openWindow`.")
            Button("Close") {
                dismissWindow()
            }
            .keyboardShortcut(.cancelAction)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
