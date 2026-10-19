import SwiftUI

extension ComponentPage {
    static let symbolEffects = ComponentPage(
        id: "symbol-effects",
        title: "Symbol Effects",
        summary: "Built-in SF Symbol animations, like bounce, pulse, and wiggle, with one modifier.",
        category: .animation,
        kind: .modifier,
        symbol: "wand.and.rays",
        availability: ["iOS 17.0+", "macOS 14.0+", "visionOS 1.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/view/symboleffect(_:options:value:)",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/sf-symbols",
        aliases: ["icon animation", "animated icon", "bounce", "pulse", "wiggle", "spinner icon", "lottie", "font awesome animation", "sfsymbols"],
        related: ["sf-symbols", "content-transition", "phase-animator", "image"],
        notes: [
            "**One modifier covers a whole group.** `.symbolEffect` animates every symbol inside the view, so you can put it on a `Label`, a button, or a stack.",
            "**Newer effects need newer iOS.** `.wiggle`, `.breathe`, and `.rotate` need iOS 18, and `.drawOn` and `.drawOff` need iOS 26.",
        ],
        api: [
            APIItem("`.symbolEffect(_:value:)`", "Plays the effect once each time `value` changes."),
            APIItem("`.symbolEffect(_:isActive:)`", "Runs the effect continuously while `isActive` is true."),
            APIItem("`.bounce`, `.wiggle`", "A quick nudge: something happened, or look here."),
            APIItem("`.pulse`, `.breathe`", "A steady throb for ongoing activity."),
            APIItem("`.variableColor.iterative`", "Lights the symbol's layers one by one."),
            APIItem("`.contentTransition(.symbolEffect(.replace))`", "Animates a change of symbol name."),
            APIItem("`.transition(.symbolEffect(.drawOn))`", "Draws a symbol in along its strokes (iOS 26)."),
        ],
        guidelines: [
            Guideline(
                "Animate one symbol at a time.",
                "A single moving symbol draws the eye to what changed. When several animate together, they compete and the screen feels busy.",
                good: "Only the new message moves.",
                bad: "Every icon moves, so none stands out."
            ) {
                SymbolRowSample(animatesAll: false)
            } bad: {
                SymbolRowSample(animatesAll: true)
            },
            Guideline(
                "Pick the effect that matches the meaning.",
                "People read `.bounce` as \"something just happened\" and `.pulse` or `.variableColor` as \"still working.\" Using one for the other sends the wrong signal."
            ),
            Guideline(
                "Fit the effect to your app's tone.",
                "A playful wiggle suits a game or a social app. A finance or health app usually calls for quieter effects."
            ),
        ]
    ) {
        SymbolThumbnail()
    } content: { page in
        SymbolEffectsDemo(page: page)
    }
}

// MARK: - Model

private enum SymbolEffectOption: DemoOption {
    case bounce, pulse, variableColor, scale, wiggle, breathe, rotate, replace

    var label: String {
        switch self {
        case .bounce: ".bounce"
        case .pulse: ".pulse"
        case .variableColor: ".variableColor"
        case .scale: ".scale"
        case .wiggle: ".wiggle"
        case .breathe: ".breathe"
        case .rotate: ".rotate"
        case .replace: ".replace"
        }
    }

    var supportsDiscrete: Bool { self != .scale }
    var supportsIndefinite: Bool { self != .replace }

    var code: String {
        switch self {
        case .scale: ".scale.up"
        case .variableColor: ".variableColor.iterative"
        default: label
        }
    }

    /// A symbol that shows the effect off well.
    var suggestedSymbol: SymbolOption {
        switch self {
        case .bounce: .bell
        case .pulse: .heart
        case .variableColor: .wifi
        case .scale: .mic
        case .wiggle: .bell
        case .breathe: .heart
        case .rotate: .gear
        case .replace: .play
        }
    }
}

private enum SymbolOption: DemoOption {
    case bell, heart, wifi, mic, gear, play, speaker

    var label: String {
        switch self {
        case .bell: "bell.fill"
        case .heart: "heart.fill"
        case .wifi: "wifi"
        case .mic: "mic.fill"
        case .gear: "gearshape.fill"
        case .play: "play.fill"
        case .speaker: "speaker.wave.3.fill"
        }
    }

    /// The symbol `.replace` swaps to.
    var alternate: String {
        switch self {
        case .bell: "bell.slash.fill"
        case .heart: "heart"
        case .wifi: "wifi.slash"
        case .mic: "mic.slash.fill"
        case .gear: "checkmark.circle.fill"
        case .play: "pause.fill"
        case .speaker: "speaker.slash.fill"
        }
    }
}

private enum SymbolRun: DemoOption {
    case onTap, whileActive

    var label: String {
        switch self {
        case .onTap: "On value change"
        case .whileActive: "While active"
        }
    }
}

private enum SymbolColor: DemoOption {
    case tint, pink, orange, multicolor

    var label: String {
        switch self {
        case .tint: "Tint"
        case .pink: ".pink"
        case .orange: ".orange"
        case .multicolor: "Multicolor"
        }
    }
}

private struct SymbolConfig {
    var effect: SymbolEffectOption = .bounce
    var symbol: SymbolOption = .bell
    var run: SymbolRun = .onTap
    var color: SymbolColor = .tint
    var count = 0
    var isActive = true
    var isAlternate = false

    var resolvedRun: SymbolRun {
        if !effect.supportsDiscrete { return .whileActive }
        if !effect.supportsIndefinite { return .onTap }
        return run
    }
}

// MARK: - Demo

private struct SymbolEffectsDemo: View {
    let page: ComponentPage

    var body: some View {
        DemoPage(
            page: page,
            initial: SymbolConfig(),
            usage: """
            @State private var unread = 0

            Button {
                unread += 1
            } label: {
                Image(systemName: "bell.fill")
                    .symbolEffect(.bounce, value: unread)
            }
            """,
            usageNote: Aside(.note, "Pass `value:` to play the effect once per change, or `isActive:` to keep it running while a flag is true.")
        ) { $config in
            VStack(spacing: 28) {
                Image(systemName: config.effect == .replace && config.isAlternate ? config.symbol.alternate : config.symbol.label)
                    .font(.system(size: 80))
                    .symbolColor(config.color)
                    .modifier(SymbolEffectModifier(config: config))
                    .frame(height: 110)
                    .id("\(config.effect)-\(config.symbol)-\(config.resolvedRun)")

                switch (config.effect, config.resolvedRun) {
                case (.replace, _):
                    Button("Swap", systemImage: "arrow.left.arrow.right") { config.isAlternate.toggle() }
                        .buttonStyle(.borderedProminent)
                case (_, .onTap):
                    Button("Play", systemImage: "play.fill") { config.count += 1 }
                        .buttonStyle(.borderedProminent)
                case (_, .whileActive):
                    Toggle("isActive", isOn: $config.isActive)
                        .font(.body.monospaced())
                        .fixedSize()
                }
            }
        } controls: { $config in
            Section("Effect") {
                Picker("Effect", selection: Binding(
                    get: { config.effect },
                    set: { effect in
                        config.effect = effect
                        config.symbol = effect.suggestedSymbol
                    }
                )) {
                    ForEach(SymbolEffectOption.allCases) { Text($0.label).tag($0) }
                }
                OptionPicker("Symbol", selection: $config.symbol)
                OptionPicker("Color", selection: $config.color)
            }
            Section {
                Picker("Runs", selection: $config.run) {
                    ForEach(SymbolRun.allCases) { Text($0.label).tag($0) }
                }
                .pickerStyle(.segmented)
                .disabled(!config.effect.supportsDiscrete || !config.effect.supportsIndefinite)
            } header: {
                Text("Runs")
            } footer: {
                switch config.effect {
                case .scale: Text("`.scale` only runs while active.")
                case .replace: Text("`.replace` runs when the symbol name changes.")
                default: Text("Once per value change, or continuously while a flag is true.")
                }
            }
        } code: { config in
            symbolCode(config)
        } examples: {
            ExampleCard(
                title: "Notification badge",
                caption: "Pass the unread count to `.symbolEffect(.bounce, value:)` so the bell bounces on each new notification.",
                code: """
                @State private var unread = 0

                Button {
                    unread += 1
                } label: {
                    Image(systemName: "bell.badge.fill")
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.red, .primary)
                        .font(.largeTitle)
                        .symbolEffect(.bounce, value: unread)
                }
                .buttonStyle(.plain)
                """,
                minHeight: 120
            ) {
                BadgeExample()
            }

            ExampleCard(
                title: "Play / pause button",
                caption: "Change the symbol name and add `.contentTransition(.symbolEffect(.replace))` to animate the swap.",
                code: """
                @State private var isPlaying = false

                Button {
                    isPlaying.toggle()
                } label: {
                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                        .font(.largeTitle)
                        .contentTransition(.symbolEffect(.replace))
                        .frame(width: 72, height: 72)
                }
                .buttonStyle(.bordered)
                .buttonBorderShape(.circle)
                """,
                minHeight: 140,
                aside: Aside(.note, "Related symbols, like `bell` and `bell.slash`, morph with Magic Replace. Unrelated ones, like play and pause, scale down and up instead.")
            ) {
                PlayPauseExample()
            }

            ExampleCard(
                title: "Loading indicator",
                caption: "Use `.symbolEffect(_:isActive:)` to animate a symbol while work runs, and stop when it's done.",
                code: """
                @State private var isSyncing = true

                VStack(alignment: .leading, spacing: 16) {
                    Label("Syncing…", systemImage: "arrow.triangle.2.circlepath.icloud")
                        .symbolEffect(.pulse, isActive: isSyncing)
                    Label("Searching", systemImage: "wifi")
                        .symbolEffect(.variableColor.iterative, isActive: isSyncing)
                }
                .font(.title3)
                """,
                minHeight: 120,
                aside: Aside(.note, "Set `isActive` back to `false` when the work finishes. The symbol finishes its current cycle and settles.")
            ) {
                VStack(alignment: .leading, spacing: 16) {
                    Label("Syncing…", systemImage: "arrow.triangle.2.circlepath.icloud")
                        .symbolEffect(.pulse, isActive: true)
                    Label("Searching", systemImage: "wifi")
                        .symbolEffect(.variableColor.iterative, isActive: true)
                }
                .font(.title3)
            }

            ExampleCard(
                title: "Draw on and off",
                caption: "Use `.transition(.symbolEffect(.drawOn))` to trace a symbol along its strokes as it appears.",
                code: """
                @State private var isShown = true

                VStack(spacing: 20) {
                    ZStack {
                        if isShown {
                            Image(systemName: "signature")
                                .font(.system(size: 64))
                                .transition(.symbolEffect(.drawOn))
                        }
                    }
                    .frame(height: 80)

                    Button(isShown ? "Erase" : "Sign") {
                        withAnimation { isShown.toggle() }
                    }
                    .buttonStyle(.bordered)
                }
                """,
                minHeight: 160,
                aside: Aside(.note, "Drawing needs iOS 26 and a symbol that supports it. Check in the SF Symbols app; other symbols fall back to a fade.")
            ) {
                DrawOnExample()
            }
            .id("draw")
        }
    }
}

private extension View {
    @ViewBuilder
    func symbolColor(_ color: SymbolColor) -> some View {
        switch color {
        case .tint: foregroundStyle(.tint)
        case .pink: foregroundStyle(.pink)
        case .orange: foregroundStyle(.orange)
        case .multicolor: symbolRenderingMode(.multicolor)
        }
    }
}

private struct SymbolEffectModifier: ViewModifier {
    let config: SymbolConfig

    func body(content: Content) -> some View {
        let count = config.count
        let isActive = config.isActive
        switch (config.effect, config.resolvedRun) {
        case (.replace, _): content.contentTransition(.symbolEffect(.replace))
        case (.bounce, .onTap): content.symbolEffect(.bounce, value: count)
        case (.bounce, .whileActive): content.symbolEffect(.bounce, isActive: isActive)
        case (.pulse, .onTap): content.symbolEffect(.pulse, value: count)
        case (.pulse, .whileActive): content.symbolEffect(.pulse, isActive: isActive)
        case (.variableColor, .onTap): content.symbolEffect(.variableColor.iterative, value: count)
        case (.variableColor, .whileActive): content.symbolEffect(.variableColor.iterative, isActive: isActive)
        case (.scale, _): content.symbolEffect(.scale.up, isActive: isActive)
        case (.wiggle, .onTap): content.symbolEffect(.wiggle, value: count)
        case (.wiggle, .whileActive): content.symbolEffect(.wiggle, isActive: isActive)
        case (.breathe, .onTap): content.symbolEffect(.breathe, value: count)
        case (.breathe, .whileActive): content.symbolEffect(.breathe, isActive: isActive)
        case (.rotate, .onTap): content.symbolEffect(.rotate, value: count)
        case (.rotate, .whileActive): content.symbolEffect(.rotate, isActive: isActive)
        }
    }
}

private func symbolCode(_ config: SymbolConfig) -> String {
    var lines: [String] = []
    let colorLine: String = switch config.color {
    case .tint: "    .foregroundStyle(.tint)"
    case .pink: "    .foregroundStyle(.pink)"
    case .orange: "    .foregroundStyle(.orange)"
    case .multicolor: "    .symbolRenderingMode(.multicolor)"
    }
    if config.effect == .replace {
        lines += [
            "@State private var isOn = false",
            "",
            "VStack(spacing: 28) {",
            "    Image(systemName: isOn ? \"\(config.symbol.alternate)\" : \"\(config.symbol.label)\")",
            "        .font(.system(size: 80))",
            "    " + colorLine,
            "        .contentTransition(.symbolEffect(.replace))",
            "",
            "    Button(\"Swap\") { isOn.toggle() }",
            "}",
        ]
        return lines.joined(separator: "\n")
    }
    switch config.resolvedRun {
    case .onTap:
        lines += [
            "@State private var count = 0",
            "",
            "VStack(spacing: 28) {",
            "    Image(systemName: \"\(config.symbol.label)\")",
            "        .font(.system(size: 80))",
            "    " + colorLine,
            "        .symbolEffect(\(config.effect.code), value: count)",
            "",
            "    Button(\"Play\") { count += 1 }",
            "}",
        ]
    case .whileActive:
        lines += [
            "@State private var isActive = \(config.isActive)",
            "",
            "VStack(spacing: 28) {",
            "    Image(systemName: \"\(config.symbol.label)\")",
            "        .font(.system(size: 80))",
            "    " + colorLine,
            "        .symbolEffect(\(config.effect.code), isActive: isActive)",
            "",
            "    Toggle(\"isActive\", isOn: $isActive)",
            "        .fixedSize()",
            "}",
        ]
    }
    return lines.joined(separator: "\n")
}

// MARK: - Examples

private struct PlayPauseExample: View {
    @State private var isPlaying = false

    var body: some View {
        Button {
            isPlaying.toggle()
        } label: {
            Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                .font(.largeTitle)
                .contentTransition(.symbolEffect(.replace))
                .frame(width: 72, height: 72)
        }
        .buttonStyle(.bordered)
        .buttonBorderShape(.circle)
        .accessibilityLabel(isPlaying ? "Pause" : "Play")
    }
}

private struct BadgeExample: View {
    @State private var unread = 0

    var body: some View {
        VStack(spacing: 10) {
            Button {
                unread += 1
            } label: {
                Image(systemName: "bell.badge.fill")
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.red, .primary)
                    .font(.largeTitle)
                    .symbolEffect(.bounce, value: unread)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Add notification")
            Text("Tap the bell")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
}

private struct DrawOnExample: View {
    @State private var isShown = true

    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                if isShown {
                    Image(systemName: "signature")
                        .font(.system(size: 64))
                        .transition(.symbolEffect(.drawOn))
                }
            }
            .frame(height: 80)

            Button(isShown ? "Erase" : "Sign", systemImage: isShown ? "eraser" : "pencil") {
                withAnimation { isShown.toggle() }
            }
            .buttonStyle(.bordered)
        }
    }
}

/// A row of tab-bar-style symbols, for the "one at a time" guideline.
private struct SymbolRowSample: View {
    let animatesAll: Bool
    private let symbols = ["message.badge.fill", "phone.fill", "calendar", "gearshape.fill"]

    var body: some View {
        HStack(spacing: 26) {
            ForEach(Array(symbols.enumerated()), id: \.offset) { index, symbol in
                Image(systemName: symbol)
                    .font(.system(size: 28))
                    .foregroundStyle(index == 0 ? Color.accentColor : Color.secondary)
                    .symbolEffect(.bounce, options: .repeat(.periodic(delay: 1)), isActive: animatesAll || index == 0)
            }
        }
    }
}

private struct SymbolThumbnail: View {
    var body: some View {
        HStack(spacing: 22) {
            Image(systemName: "bell.badge.fill")
                .symbolRenderingMode(.palette)
                .foregroundStyle(.red, .primary)
            Image(systemName: "wifi")
                .foregroundStyle(.tint)
            Image(systemName: "heart.fill")
                .foregroundStyle(.pink)
        }
        .font(.system(size: 40))
    }
}
