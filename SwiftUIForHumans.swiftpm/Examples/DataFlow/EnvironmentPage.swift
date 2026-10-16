import SwiftUI

extension ComponentPage {
    static let environment = ComponentPage(
        id: "environment",
        title: "@Environment",
        summary: "Reads values the system or an ancestor passes down, like dark mode or the locale.",
        category: .dataFlow,
        kind: .concept,
        symbol: "globe.americas",
        availability: ["iOS 13.0+", "macOS 10.15+", "visionOS 1.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/environment",
        aliases: ["useContext", "React Context", "provide inject", "prop drilling", "dark mode", "theme", "dependency injection", "traitCollection", "global value", "@EnvironmentObject"],
        related: ["observable", "choosing-wrappers", "binding", "sheet"],
        notes: [
            "**Values flow down, never up.** `.environment(\\.key, value)` changes a value for that view and everything inside it, not for parents or siblings. `.font()`, `.tint()`, and `.disabled()` work the same way.",
            "**Mark environment properties `private`.** The view reads them itself; nobody passes them in.",
            "**A missing model crashes.** `@Environment(Model.self)` stops the app if no ancestor called `.environment(model)`. Declare it as `Model?` when it might be absent. See [@Observable](catalog://observable).",
        ],
        api: [
            APIItem("`@Environment(\\.colorScheme)`", "Reads a system value. Others: `dismiss`, `locale`, `openURL`."),
            APIItem("`.environment(\\.key, value)`", "Overrides a value for a view and its children."),
            APIItem("`@Entry var name = default`", "Adds your own value, inside `extension EnvironmentValues`."),
            APIItem("`.environment(model)`", "Shares an `@Observable` model with every view below."),
            APIItem("`@Environment(Model.self)`", "Reads that model back by its type."),
        ]
    ) {
        EnvironmentThumbnail()
    } content: { page in
        EnvironmentDemo(page: page)
    }
}

// MARK: - Thumbnail

private struct EnvironmentThumbnail: View {
    var body: some View {
        HStack(spacing: 10) {
            EnvironmentMiniCard()
                .environment(\.colorScheme, .light)
            EnvironmentMiniCard()
                .environment(\.colorScheme, .dark)
        }
    }
}

private struct EnvironmentMiniCard: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Image(systemName: colorScheme == .dark ? "moon.stars.fill" : "sun.max.fill")
                .font(.title2)
                .foregroundStyle(colorScheme == .dark ? Color.indigo : Color.orange)
            Text(colorScheme == .dark ? "Dark" : "Light")
                .font(.headline)
                .foregroundStyle(.primary)
            Text(colorScheme == .dark ? ".dark" : ".light")
                .font(.caption2.monospaced())
                .foregroundStyle(.secondary)
        }
        .padding(12)
        .frame(width: 96, alignment: .leading)
        .background(.background, in: .rect(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(.separator)
        }
    }
}

// MARK: - Demo

private enum EnvSchemeOption: DemoOption {
    case inherit, light, dark

    var label: String {
        switch self {
        case .inherit: "Inherited"
        case .light: ".light"
        case .dark: ".dark"
        }
    }

    var value: ColorScheme? {
        switch self {
        case .inherit: nil
        case .light: .light
        case .dark: .dark
        }
    }
}

private enum EnvTypeSizeOption: DemoOption {
    case inherit, xSmall, large, xxxLarge, accessibility2

    var label: String {
        switch self {
        case .inherit: "Inherited"
        case .xSmall: ".xSmall"
        case .large: ".large"
        case .xxxLarge: ".xxxLarge"
        case .accessibility2: ".accessibility2"
        }
    }

    var value: DynamicTypeSize? {
        switch self {
        case .inherit: nil
        case .xSmall: .xSmall
        case .large: .large
        case .xxxLarge: .xxxLarge
        case .accessibility2: .accessibility2
        }
    }
}

private enum EnvLocaleOption: DemoOption {
    case inherit, french, japanese, arabic

    var label: String {
        switch self {
        case .inherit: "Inherited"
        case .french: "fr_FR"
        case .japanese: "ja_JP"
        case .arabic: "ar_EG"
        }
    }

    var value: Locale? {
        self == .inherit ? nil : Locale(identifier: label)
    }
}

private struct EnvironmentConfig {
    var scheme: EnvSchemeOption = .dark
    var typeSize: EnvTypeSizeOption = .inherit
    var locale: EnvLocaleOption = .inherit
    var rightToLeft = false
    var isDisabled = false
}

private struct EnvironmentDemo: View {
    let page: ComponentPage

    var body: some View {
        DemoPage(
            page: page,
            initial: EnvironmentConfig(),
            previewHeight: 240,
            usage: """
            @Environment(\\.colorScheme) private var colorScheme

            var body: some View {
                Text(colorScheme == .dark ? "Good night" : "Good morning")
            }
            """,
            usageNote: Aside(.note, "It works like React's `useContext`: any view reads what an ancestor or the system set, without props through every layer.")
        ) { $config in
            EnvironmentDailyCard()
                .modifier(EnvironmentOverrides(config: config))
                .frame(maxWidth: 320)
                .animation(.snappy, value: config.isDisabled)
        } controls: { $config in
            Section {
                OptionPicker("colorScheme", selection: $config.scheme)
                OptionPicker("dynamicTypeSize", selection: $config.typeSize)
                OptionPicker("locale", selection: $config.locale)
                Toggle("Right to left", isOn: $config.rightToLeft)
                Toggle("Disabled", isOn: $config.isDisabled)
            } header: {
                Text("Override for the card")
            } footer: {
                Text("Each override applies to the card and everything inside it. The card reads the values back with @Environment.")
            }
        } code: { config in
            environmentCode(config)
        } examples: {
            EnvironmentExamples()
        }
    }
}

private struct EnvironmentOverrides: ViewModifier {
    let config: EnvironmentConfig
    @Environment(\.colorScheme) private var inheritedScheme
    @Environment(\.dynamicTypeSize) private var inheritedTypeSize
    @Environment(\.locale) private var inheritedLocale

    func body(content: Content) -> some View {
        content
            .environment(\.colorScheme, config.scheme.value ?? inheritedScheme)
            .environment(\.dynamicTypeSize, config.typeSize.value ?? inheritedTypeSize)
            .environment(\.locale, config.locale.value ?? inheritedLocale)
            .environment(\.layoutDirection, config.rightToLeft ? .rightToLeft : .leftToRight)
            .disabled(config.isDisabled)
    }
}

private struct EnvironmentDailyCard: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dynamicTypeSize) private var typeSize
    @Environment(\.locale) private var locale
    @State private var notify = true

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Daily summary", systemImage: "sun.max.fill")
                .font(.headline)
            Text(Date.now, format: .dateTime.weekday(.wide).month(.wide).day())
                .foregroundStyle(.secondary)
            Toggle("Notify me", isOn: $notify)
            Text("\(colorScheme == .dark ? "Dark" : "Light") · \(String(describing: typeSize)) · \(locale.identifier)")
                .font(.caption.monospaced())
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.background.secondary, in: .rect(cornerRadius: 16))
    }
}

private func environmentCode(_ config: EnvironmentConfig) -> String {
    var modifiers: [String] = []
    if config.scheme != .inherit {
        modifiers.append(".environment(\\.colorScheme, \(config.scheme.label))")
    }
    if config.typeSize != .inherit {
        modifiers.append(".environment(\\.dynamicTypeSize, \(config.typeSize.label))")
    }
    if config.locale != .inherit {
        modifiers.append(".environment(\\.locale, Locale(identifier: \"\(config.locale.label)\"))")
    }
    if config.rightToLeft {
        modifiers.append(".environment(\\.layoutDirection, .rightToLeft)")
    }
    if config.isDisabled {
        modifiers.append(".disabled(true) // Sets \\.isEnabled to false")
    }
    let applied = modifiers.isEmpty
        ? "        DailyCard() // Reads whatever its ancestors and the system set"
        : (["        DailyCard()"] + modifiers.map { "            " + $0 }).joined(separator: "\n")

    return """
    struct ContentView: View {
        var body: some View {
    \(applied)
        }
    }

    struct DailyCard: View {
        @Environment(\\.colorScheme) private var colorScheme
        @Environment(\\.dynamicTypeSize) private var typeSize
        @Environment(\\.locale) private var locale
        @State private var notify = true

        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                Label("Daily summary", systemImage: "sun.max.fill")
                    .font(.headline)
                Text(Date.now, format: .dateTime.weekday(.wide).month(.wide).day())
                    .foregroundStyle(.secondary)
                Toggle("Notify me", isOn: $notify)
                Text("\\(colorScheme == .dark ? "Dark" : "Light") · \\(String(describing: typeSize)) · \\(locale.identifier)")
                    .font(.caption.monospaced())
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(.background.secondary, in: .rect(cornerRadius: 16))
        }
    }
    """
}

// MARK: - Examples

private extension EnvironmentValues {
    @Entry var dataFlowDemoCardTint: Color = .blue
}

private struct EnvironmentExamples: View {
    var body: some View {
        ExampleCard(
            title: "Close a sheet with dismiss",
            caption: "Read `dismiss` inside a sheet to close it, without a binding from the parent.",
            code: """
            struct ContentView: View {
                @State private var isShowingSheet = false

                var body: some View {
                    Button("Open sheet") { isShowingSheet = true }
                        .buttonStyle(.borderedProminent)
                        .sheet(isPresented: $isShowingSheet) {
                            SheetContent()
                        }
                }
            }

            struct SheetContent: View {
                @Environment(\\.dismiss) private var dismiss

                var body: some View {
                    VStack(spacing: 16) {
                        Text("All set!")
                            .font(.title2.bold())
                        Button("Done") { dismiss() }
                            .buttonStyle(.borderedProminent)
                    }
                    .presentationDetents([.height(200)])
                }
            }
            """,
            aside: Aside(.note, "Some environment values are actions you call like functions, such as `dismiss()` and `openURL(url)`.")
        ) {
            EnvironmentDismissExample()
        }

        ExampleCard(
            title: "Your own value with @Entry",
            caption: "Declare a value with `@Entry`, set it once with `.environment`, and read it any number of levels down.",
            code: """
            extension EnvironmentValues {
                @Entry var cardTint: Color = .blue
            }

            struct ContentView: View {
                @State private var tint = Color.blue

                var body: some View {
                    VStack(spacing: 16) {
                        Picker("Tint", selection: $tint) {
                            Text("Blue").tag(Color.blue)
                            Text("Pink").tag(Color.pink)
                            Text("Green").tag(Color.green)
                        }
                        .pickerStyle(.segmented)
                        ActionBar()
                    }
                    .environment(\\.cardTint, tint)
                }
            }

            struct ActionBar: View {
                var body: some View {
                    HStack {
                        ActionButton(symbol: "heart.fill")
                        ActionButton(symbol: "star.fill")
                        ActionButton(symbol: "bookmark.fill")
                    }
                }
            }

            struct ActionButton: View {
                let symbol: String
                @Environment(\\.cardTint) private var tint

                var body: some View {
                    Image(systemName: symbol)
                        .font(.title2)
                        .foregroundStyle(.white)
                        .frame(width: 56, height: 56)
                        .background(tint.gradient, in: .rect(cornerRadius: 14))
                }
            }
            """,
            aside: Aside(.note, "`ActionBar` never mentions the tint. Only `ActionButton`, two levels down, reads it.")
        ) {
            EnvironmentEntryExample()
        }

        ExampleCard(
            title: "Respect Reduce Motion",
            caption: "Read `accessibilityReduceMotion` and skip bouncy or zooming animations for people who turned it on.",
            code: """
            @Environment(\\.accessibilityReduceMotion) private var reduceMotion
            @State private var isLiked = false

            var body: some View {
                Button {
                    withAnimation(reduceMotion ? nil : .bouncy) {
                        isLiked.toggle()
                    }
                } label: {
                    Image(systemName: isLiked ? "heart.fill" : "heart")
                        .font(.largeTitle)
                        .foregroundStyle(.pink)
                        .scaleEffect(isLiked ? 1.3 : 1)
                }
                .accessibilityLabel(isLiked ? "Unlike" : "Like")
            }
            """,
            aside: Aside(.note, "Other accessibility settings live here too, such as `accessibilityReduceTransparency` and `dynamicTypeSize`.")
        ) {
            EnvironmentReduceMotionExample()
        }
    }
}

private struct EnvironmentReduceMotionExample: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isLiked = false

    var body: some View {
        Button {
            withAnimation(reduceMotion ? nil : .bouncy) {
                isLiked.toggle()
            }
        } label: {
            Image(systemName: isLiked ? "heart.fill" : "heart")
                .font(.largeTitle)
                .foregroundStyle(.pink)
                .scaleEffect(isLiked ? 1.3 : 1)
        }
        .accessibilityLabel(isLiked ? "Unlike" : "Like")
    }
}

private struct EnvironmentDismissExample: View {
    @State private var isShowingSheet = false

    var body: some View {
        Button("Open sheet") { isShowingSheet = true }
            .buttonStyle(.borderedProminent)
            .sheet(isPresented: $isShowingSheet) {
                EnvironmentSheetContent()
            }
    }
}

private struct EnvironmentSheetContent: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 16) {
            Text("All set!")
                .font(.title2.bold())
            Button("Done") { dismiss() }
                .buttonStyle(.borderedProminent)
        }
        .presentationDetents([.height(200)])
    }
}

private struct EnvironmentEntryExample: View {
    @State private var tint = Color.blue

    var body: some View {
        VStack(spacing: 16) {
            Picker("Tint", selection: $tint) {
                Text("Blue").tag(Color.blue)
                Text("Pink").tag(Color.pink)
                Text("Green").tag(Color.green)
            }
            .pickerStyle(.segmented)
            EnvironmentActionBar()
        }
        .frame(maxWidth: 280)
        .environment(\.dataFlowDemoCardTint, tint)
    }
}

private struct EnvironmentActionBar: View {
    var body: some View {
        HStack {
            EnvironmentActionButton(symbol: "heart.fill")
            EnvironmentActionButton(symbol: "star.fill")
            EnvironmentActionButton(symbol: "bookmark.fill")
        }
    }
}

private struct EnvironmentActionButton: View {
    let symbol: String
    @Environment(\.dataFlowDemoCardTint) private var tint

    var body: some View {
        Image(systemName: symbol)
            .font(.title2)
            .foregroundStyle(.white)
            .frame(width: 56, height: 56)
            .background(tint.gradient, in: .rect(cornerRadius: 14))
    }
}
