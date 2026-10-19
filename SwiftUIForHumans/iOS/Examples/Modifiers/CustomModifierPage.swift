import SwiftUI

extension ComponentPage {
    static let customModifier = ComponentPage(
        id: "custom-modifier",
        title: "Custom Modifiers",
        summary: "Bundles a set of modifiers under one name, so you can reuse a style everywhere.",
        category: .modifiers,
        kind: .concept,
        symbol: "wand.and.rays",
        availability: ["iOS 13.0+", "macOS 10.15+", "visionOS 1.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/viewmodifier",
        aliases: ["ViewModifier", "css class", "reusable style", "mixin", "theme", "styled component", "helper", "extension View", "design tokens"],
        related: ["modifier-order", "background-overlay", "button", "environment"],
        notes: [
            "**Start with a plain `extension View` function.** Reach for a `ViewModifier` struct only when the style needs its own `@State` or reads `@Environment`.",
            "**Use a style protocol for controls.** `ButtonStyle`, `ToggleStyle`, and `LabelStyle` also know about pressed and disabled states. See [Button](catalog://button).",
        ],
        api: [
            APIItem("`extension View { func … }`", "The simplest reusable style: a function that returns the chain."),
            APIItem("`ViewModifier`", "A struct that styles any view, and can hold state."),
            APIItem("`body(content:)`", "Where a `ViewModifier` applies its modifiers to `content`."),
            APIItem("`.modifier(_:)`", "Applies a `ViewModifier` to a view."),
            APIItem("`ButtonStyle`", "A reusable look for buttons, with a pressed state."),
        ]
    ) {
        VStack(spacing: 10) {
            ThumbCard(title: "Card style", symbol: "wand.and.stars")
            Text(".cardStyle()")
                .font(.system(.caption, design: .monospaced).weight(.semibold))
                .foregroundStyle(.secondary)
        }
    } content: { page in
        CustomModifierArticle(page: page)
    }
}

private struct ThumbCard: View {
    let title: String
    let symbol: String

    var body: some View {
        Label(title, systemImage: symbol)
            .font(.headline)
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
            .background(.background, in: .rect(cornerRadius: 14))
            .overlay {
                RoundedRectangle(cornerRadius: 14).strokeBorder(.purple.opacity(0.5), lineWidth: 1.5)
            }
            .shadow(color: .purple.opacity(0.25), radius: 10, y: 4)
    }
}

// MARK: - The playground modifier

private enum CardTint: String, CaseIterable, Identifiable {
    case blue, purple, green, orange

    var id: Self { self }

    var color: Color {
        switch self {
        case .blue: .blue
        case .purple: .purple
        case .green: .green
        case .orange: .orange
        }
    }
}

private struct PlaygroundCardStyle: ViewModifier {
    var radius: Double
    var padding: Double
    var tint: Color
    var hasShadow: Bool

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(tint.opacity(0.12), in: .rect(cornerRadius: radius))
            .overlay {
                RoundedRectangle(cornerRadius: radius)
                    .strokeBorder(tint.opacity(0.4))
            }
            .shadow(color: hasShadow ? tint.opacity(0.3) : .clear, radius: 10, y: 4)
    }
}

private extension View {
    func playgroundCardStyle(radius: Double, padding: Double, tint: Color, hasShadow: Bool) -> some View {
        modifier(PlaygroundCardStyle(radius: radius, padding: padding, tint: tint, hasShadow: hasShadow))
    }
}

// MARK: - Example modifiers

private struct AdaptiveCard: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        content
            .padding()
            .background(.background.secondary, in: .rect(cornerRadius: 16))
            .shadow(color: .black.opacity(colorScheme == .dark ? 0 : 0.15), radius: 8, y: 4)
            .overlay {
                if colorScheme == .dark {
                    RoundedRectangle(cornerRadius: 16).strokeBorder(.white.opacity(0.15))
                }
            }
    }
}

private struct LoadingOverlay: ViewModifier {
    var isLoading: Bool

    func body(content: Content) -> some View {
        content
            .opacity(isLoading ? 0.4 : 1)
            .disabled(isLoading)
            .overlay {
                if isLoading {
                    ProgressView()
                }
            }
            .animation(.default, value: isLoading)
    }
}

private extension View {
    func sectionHeaderStyle() -> some View {
        font(.footnote.weight(.semibold))
            .textCase(.uppercase)
            .foregroundStyle(.secondary)
            .tracking(0.5)
    }
}

// MARK: - Page

private struct CustomModifierArticle: View {
    let page: ComponentPage
    @State private var radius = 16.0
    @State private var padding = 16.0
    @State private var tint: CardTint = .purple
    @State private var hasShadow = true
    @State private var isLoading = false

    private var playgroundCode: String {
        let r = swiftNumber(radius)
        let p = swiftNumber(padding)
        let t = tint.rawValue
        var lines = [
            "// 1. Define the style once.",
            "struct CardStyle: ViewModifier {",
            "    func body(content: Content) -> some View {",
            "        content",
            "            .padding(\(p))",
            "            .frame(maxWidth: .infinity, alignment: .leading)",
            "            .background(.\(t).opacity(0.12), in: .rect(cornerRadius: \(r)))",
            "            .overlay {",
            "                RoundedRectangle(cornerRadius: \(r))",
            "                    .strokeBorder(.\(t).opacity(0.4))",
            "            }",
        ]
        if hasShadow {
            lines.append("            .shadow(color: .\(t).opacity(0.3), radius: 10, y: 4)")
        }
        lines += [
            "    }",
            "}",
            "",
            "// 2. Give it a dot-syntax name.",
            "extension View {",
            "    func cardStyle() -> some View {",
            "        modifier(CardStyle())",
            "    }",
            "}",
            "",
            "// 3. Use it anywhere.",
            "Label(\"Your order shipped\", systemImage: \"shippingbox.fill\")",
            "    .font(.headline)",
            "    .cardStyle()",
        ]
        return lines.joined(separator: "\n")
    }

    var body: some View {
        ArticlePage(page: page) {
            Prose("When the same few modifiers show up on every card, give them a name. It's SwiftUI's version of a CSS class: define the look once, apply it in one line, and change every screen in one place.")

            VStack(alignment: .leading, spacing: 12) {
                SectionTitle("Try it")
                Prose("These three views share one `.cardStyle()`. Change the style and all three update.")
                PreviewCard(minHeight: 260) {
                    VStack(spacing: 14) {
                        Label("Your order shipped", systemImage: "shippingbox.fill")
                            .font(.headline)
                            .playgroundCardStyle(radius: radius, padding: padding, tint: tint.color, hasShadow: hasShadow)
                        HStack(spacing: 14) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Steps").font(.caption).foregroundStyle(.secondary)
                                Text("8,412").font(.title2.bold()).monospacedDigit()
                            }
                            .playgroundCardStyle(radius: radius, padding: padding, tint: tint.color, hasShadow: hasShadow)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Sleep").font(.caption).foregroundStyle(.secondary)
                                Text("7h 20m").font(.title2.bold()).monospacedDigit()
                            }
                            .playgroundCardStyle(radius: radius, padding: padding, tint: tint.color, hasShadow: hasShadow)
                        }
                    }
                    .animation(.snappy, value: radius)
                    .animation(.snappy, value: padding)
                    .animation(.snappy, value: tint)
                    .animation(.snappy, value: hasShadow)
                }
                controls
                CodeBlock(code: playgroundCode)
            }
            .id("playground")

            VStack(alignment: .leading, spacing: 28) {
                SectionTitle("Two ways to write one")
                ExampleCard(
                    title: "Just an extension",
                    caption: "Write a function in an `extension View` that returns the chain. Often it's all you need.",
                    code: """
                    extension View {
                        func sectionHeaderStyle() -> some View {
                            font(.footnote.weight(.semibold))
                                .textCase(.uppercase)
                                .foregroundStyle(.secondary)
                                .tracking(0.5)
                        }
                    }

                    Text("Recent activity")
                        .sectionHeaderStyle()
                    """
                ) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Recent activity")
                            .sectionHeaderStyle()
                        Text("You haven't done anything yet today.")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                ExampleCard(
                    title: "A ViewModifier that reads the environment",
                    caption: "Use a `ViewModifier` struct when the style reads `@Environment`, like this light and dark card.",
                    code: """
                    struct AdaptiveCard: ViewModifier {
                        @Environment(\\.colorScheme) private var colorScheme

                        func body(content: Content) -> some View {
                            content
                                .padding()
                                .background(.background.secondary, in: .rect(cornerRadius: 16))
                                .shadow(color: .black.opacity(colorScheme == .dark ? 0 : 0.15), radius: 8, y: 4)
                                .overlay {
                                    if colorScheme == .dark {
                                        RoundedRectangle(cornerRadius: 16).strokeBorder(.white.opacity(0.15))
                                    }
                                }
                        }
                    }

                    Text("Adapts to dark mode")
                        .modifier(AdaptiveCard())
                    """,
                    aside: Aside(.note, "`content` stands for whatever view the modifier is applied to. This card uses a shadow in light mode and an outline in dark mode, where shadows are hard to see.")
                ) {
                    Text("Adapts to dark mode")
                        .modifier(AdaptiveCard())
                }

                ExampleCard(
                    title: "A modifier with a parameter",
                    caption: "Give the modifier properties to pass values in, like this `.loading(_:)` that dims any view.",
                    code: """
                    struct LoadingOverlay: ViewModifier {
                        var isLoading: Bool

                        func body(content: Content) -> some View {
                            content
                                .opacity(isLoading ? 0.4 : 1)
                                .disabled(isLoading)
                                .overlay {
                                    if isLoading {
                                        ProgressView()
                                    }
                                }
                                .animation(.default, value: isLoading)
                        }
                    }

                    extension View {
                        func loading(_ isLoading: Bool) -> some View {
                            modifier(LoadingOverlay(isLoading: isLoading))
                        }
                    }

                    @State private var isLoading = false

                    Button("Place order") { isLoading.toggle() }
                        .buttonStyle(.borderedProminent)
                        .loading(isLoading)
                    """,
                    aside: Aside(.important, "Avoid a catch-all `.if(condition) { … }` helper. Each branch is a different view to SwiftUI, so flipping it resets state instead of animating. Put the condition in the values, like `opacity(isLoading ? 0.4 : 1)` here.")
                ) {
                    VStack(spacing: 14) {
                        Button("Place order") {}
                            .buttonStyle(.borderedProminent)
                            .controlSize(.large)
                            .modifier(LoadingOverlay(isLoading: isLoading))
                        Toggle("isLoading", isOn: $isLoading)
                            .font(.subheadline.monospaced())
                            .fixedSize()
                    }
                }
            }
            .id("examples")
        }
    }

    private var controls: some View {
        VStack(spacing: 14) {
            HStack {
                Text("Tint")
                Spacer()
                Picker("Tint", selection: $tint) {
                    ForEach(CardTint.allCases) { tint in
                        Text(tint.rawValue.capitalized).tag(tint)
                    }
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: 260)
            }
            ValueSlider("Corner radius", value: $radius, in: 0...30, step: 1)
            ValueSlider("Padding", value: $padding, in: 8...28, step: 1)
            Toggle("Shadow", isOn: $hasShadow)
        }
        .padding(16)
        .cardStyle()
    }
}
