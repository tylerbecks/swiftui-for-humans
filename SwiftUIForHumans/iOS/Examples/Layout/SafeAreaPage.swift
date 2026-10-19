import SwiftUI

extension ComponentPage {
    static let safeArea = ComponentPage(
        id: "safe-area",
        title: "Safe Area",
        summary: "The part of the screen clear of the Dynamic Island, home indicator, bars, and keyboard.",
        category: .layout,
        symbol: "rectangle.inset.filled",
        availability: ["iOS 14.0+", "macOS 11.0+", "visionOS 1.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/view/ignoressafearea(_:edges:)",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/layout",
        aliases: ["notch", "dynamic island", "env(safe-area-inset-top)", "viewport-fit cover", "full screen", "edge to edge", "home indicator", "keyboard avoidance", "insets"],
        related: ["layout-basics", "scroll-view", "padding", "toolbar"],
        notes: [
            "**It's like CSS `env(safe-area-inset-*)`, applied for you.** SwiftUI keeps views inside the safe area by default; you opt out instead of opting in.",
            "**The keyboard is part of the safe area.** SwiftUI moves content up when it appears. Opt out with `.ignoresSafeArea(.keyboard)`.",
        ],
        api: [
            APIItem("`.ignoresSafeArea()`", "Lets a view extend under the bars, island, and home indicator."),
            APIItem("`.ignoresSafeArea(edges: .top)`", "Extends past only some edges."),
            APIItem("`.background(_:)`", "Fills behind a view and extends to the edges on its own."),
            APIItem("`.safeAreaInset(edge:)`", "Pins a bar to an edge and moves content clear of it."),
            APIItem("`.safeAreaPadding(_:_:)`", "Grows the safe area, so scroll content still reaches the edge."),
            APIItem("`.ignoresSafeArea(.keyboard)`", "Stops the keyboard from pushing content up."),
        ],
        guidelines: [
            Guideline(
                "Keep text and controls inside the safe area.",
                "The Dynamic Island and home indicator cover the screen's edges. Anything people need to read or tap belongs inside.",
                good: "The button sits above the home indicator.",
                bad: "The button runs under the home indicator."
            ) {
                SafeAreaButtonSample(insideSafeArea: true)
            } bad: {
                SafeAreaButtonSample(insideSafeArea: false)
            },
            Guideline(
                "Run backgrounds all the way to the edges.",
                "Colors and images that stop at the safe area leave bands at the top and bottom, so the screen looks unfinished.",
                good: "The background fills the whole screen.",
                bad: "Bands at the top and bottom."
            ) {
                SafeAreaBackgroundSample(fills: true)
            } bad: {
                SafeAreaBackgroundSample(fills: false)
            },
        ]
    ) {
        SafeAreaThumbnail()
    } content: { page in
        SafeAreaDemo(page: page)
    }
}

// MARK: - Simulated device

/// Insets used to simulate a phone's safe area inside the preview frame.
private let simulatedTop: CGFloat = 50
private let simulatedBottom: CGFloat = 28

/// Gives the preview screen a safe area like a phone's, with the Dynamic
/// Island and home indicator drawn on top so you can see what's covered.
private struct SimulatedPhone<Content: View>: View {
    var width: CGFloat = 260
    var height: CGFloat = 480
    @ViewBuilder let content: Content

    var body: some View {
        DeviceFrame(width: width, height: height) {
            content
                .safeAreaPadding(.top, simulatedTop)
                .safeAreaPadding(.bottom, simulatedBottom)
                .overlay(alignment: .top) {
                    Capsule()
                        .fill(.black)
                        .frame(width: 84, height: 24)
                        .padding(.top, 11)
                }
                .overlay(alignment: .bottom) {
                    Capsule()
                        .fill(.primary)
                        .frame(width: 96, height: 4)
                        .padding(.bottom, 8)
                }
        }
    }
}

// MARK: - Thumbnail

private struct SafeAreaThumbnail: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(LinearGradient(colors: [.blue, .purple], startPoint: .top, endPoint: .bottom))
            RoundedRectangle(cornerRadius: 4)
                .strokeBorder(.white.opacity(0.9), style: StrokeStyle(lineWidth: 1.5, dash: [4, 3]))
                .padding(.top, 22)
                .padding(.bottom, 12)
                .padding(.horizontal, 4)
            VStack {
                Capsule().fill(.black).frame(width: 26, height: 8).padding(.top, 6)
                Spacer()
                Capsule().fill(.white).frame(width: 30, height: 2.5).padding(.bottom, 5)
            }
        }
        .frame(width: 64, height: 116)
        .padding(3)
        .background(Color(white: 0.12), in: .rect(cornerRadius: 18))
    }
}

// MARK: - Config

private struct SafeAreaConfig {
    var backgroundIgnores = true
    var bottomBar = true
    var horizontalPadding: Double = 16
    var showSafeArea = true
}

// MARK: - Demo

private struct SafeAreaDemo: View {
    let page: ComponentPage
    @State private var isFullScreen = false

    var body: some View {
        DemoPage(
            page: page,
            initial: SafeAreaConfig(),
            previewHeight: 540,
            usage: """
            ZStack {
                LinearGradient(colors: [.blue, .purple], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
                Text("Welcome")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.white)
            }
            """,
            usageNote: Aside(.note, "Put `.ignoresSafeArea()` on the background view only, so text stays clear of the edges. A `.background(_:)` modifier already reaches the edges without it.")
        ) { $config in
            VStack(spacing: 14) {
                SimulatedPhone {
                    SafeAreaScreen(config: config)
                }
                Button("Try it full screen", systemImage: "arrow.up.left.and.arrow.down.right") {
                    isFullScreen = true
                }
                .buttonStyle(.bordered)
                .id("fullscreen")
                .fullScreenCover(isPresented: $isFullScreen) {
                    SafeAreaScreen(config: config)
                        .overlay(alignment: .topTrailing) {
                            Button("Close", systemImage: "xmark") { isFullScreen = false }
                                .labelStyle(.iconOnly)
                                .buttonStyle(.glass)
                                .buttonBorderShape(.circle)
                                .controlSize(.large)
                                .padding(.trailing)
                        }
                }
            }
        } controls: { $config in
            Section("Background") {
                Toggle(".ignoresSafeArea()", isOn: $config.backgroundIgnores)
            }
            Section("Insets") {
                Toggle("Bottom bar with safeAreaInset", isOn: $config.bottomBar)
                ValueSlider("safeAreaPadding (horizontal)", value: $config.horizontalPadding, in: 0...40, step: 1)
            }
            Section("Preview") {
                Toggle("Outline the safe area", isOn: $config.showSafeArea)
            }
        } code: { config in
            var lines = [
                "ZStack {",
                "    LinearGradient(colors: [.blue, .purple], startPoint: .top, endPoint: .bottom)",
            ]
            if config.backgroundIgnores { lines.append("        .ignoresSafeArea()") }
            lines += [
                "    ScrollView {",
                "        VStack(alignment: .leading, spacing: 10) {",
                "            Text(\"Inbox\")",
                "                .font(.largeTitle.bold())",
                "            ForEach(1...12, id: \\.self) { i in",
                "                Text(\"Message \\(i)\")",
                "                    .frame(maxWidth: .infinity, alignment: .leading)",
                "                    .padding()",
                "                    .background(.white.opacity(0.2), in: .rect(cornerRadius: 12))",
                "            }",
                "        }",
                "    }",
                "    .foregroundStyle(.white)",
            ]
            if config.horizontalPadding > 0 {
                lines.append("    .safeAreaPadding(.horizontal, \(swiftNumber(config.horizontalPadding)))")
            }
            if config.bottomBar {
                lines += [
                    "    .safeAreaInset(edge: .bottom) {",
                    "        Button(\"New Message\", systemImage: \"square.and.pencil\") {}",
                    "            .buttonStyle(.glassProminent)",
                    "            .padding(.bottom, 8)",
                    "    }",
                ]
            }
            lines.append("}")
            return lines.joined(separator: "\n")
        } examples: {
            ExampleCard(
                title: "Full-bleed header",
                caption: "Use `.ignoresSafeArea(edges: .top)` on the header art only, so the title stays inside.",
                code: """
                VStack(alignment: .leading, spacing: 16) {
                    ZStack(alignment: .bottomLeading) {
                        LinearGradient(colors: [.orange, .pink], startPoint: .topLeading, endPoint: .bottomTrailing)
                            .ignoresSafeArea(edges: .top)
                        Text("Weekend Trip")
                            .font(.title.bold())
                            .foregroundStyle(.white)
                            .padding()
                    }
                    .frame(height: 160)
                    Text("Saturday, 9:00 AM")
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)
                    Spacer()
                }
                """,
                minHeight: 420
            ) {
                SimulatedPhone(width: 220, height: 360) {
                    VStack(alignment: .leading, spacing: 16) {
                        ZStack(alignment: .bottomLeading) {
                            LinearGradient(colors: [.orange, .pink], startPoint: .topLeading, endPoint: .bottomTrailing)
                                .ignoresSafeArea(edges: .top)
                            Text("Weekend Trip")
                                .font(.title.bold())
                                .foregroundStyle(.white)
                                .padding()
                        }
                        .frame(height: 160)
                        Text("Saturday, 9:00 AM")
                            .foregroundStyle(.secondary)
                            .padding(.horizontal)
                        Spacer()
                    }
                }
            }

            ExampleCard(
                title: "Floating bottom bar",
                caption: "Use `.safeAreaInset(edge: .bottom)` to pin a button, so the last row can scroll above it.",
                code: """
                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(1...20, id: \\.self) { i in
                            Text("Message \\(i)")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                                .background(.fill.tertiary, in: .rect(cornerRadius: 12))
                        }
                    }
                    .padding(.horizontal)
                }
                .safeAreaInset(edge: .bottom) {
                    Button("New Message", systemImage: "square.and.pencil") {}
                        .buttonStyle(.glassProminent)
                        .controlSize(.large)
                }
                """,
                minHeight: 420,
                aside: Aside(.important, "A plain `.overlay(alignment: .bottom)` would cover the last rows. `safeAreaInset` shrinks the safe area by the bar's height, so nothing is hidden.")
            ) {
                SimulatedPhone(width: 220, height: 360) {
                    ScrollView {
                        VStack(spacing: 10) {
                            ForEach(1...20, id: \.self) { i in
                                Text("Message \(i)")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding()
                                    .background(.fill.tertiary, in: .rect(cornerRadius: 12))
                            }
                        }
                        .padding(.horizontal)
                    }
                    .safeAreaInset(edge: .bottom) {
                        Button("New Message", systemImage: "square.and.pencil") {}
                            .buttonStyle(.glassProminent)
                            .controlSize(.large)
                    }
                }
            }

            ExampleCard(
                title: "padding vs. safeAreaPadding",
                caption: "Scroll both rows: `.safeAreaPadding` insets the cards but lets them scroll to the edge.",
                code: """
                // Cards get clipped 24pt from the edges
                ScrollView(.horizontal) { cards }
                    .padding(.horizontal, 24)

                // Cards start 24pt in, but scroll to the edges
                ScrollView(.horizontal) { cards }
                    .safeAreaPadding(.horizontal, 24)
                """,
                aside: Aside(.note, "Plain `.padding` shrinks the scroll view itself, so the top row's cards are cut off at the inset.")
            ) {
                VStack(alignment: .leading, spacing: 12) {
                    Text(".padding").font(.caption.monospaced()).foregroundStyle(.secondary).padding(.leading, 24)
                    ScrollView(.horizontal) { SafeAreaCards() }
                        .scrollIndicators(.hidden)
                        .padding(.horizontal, 24)
                        .background(.fill.quaternary)
                    Text(".safeAreaPadding").font(.caption.monospaced()).foregroundStyle(.secondary).padding(.leading, 24)
                    ScrollView(.horizontal) { SafeAreaCards() }
                        .scrollIndicators(.hidden)
                        .safeAreaPadding(.horizontal, 24)
                        .background(.fill.quaternary)
                }
                .padding(.horizontal, -24)
            }
        }
    }
}

private struct SafeAreaCards: View {
    var body: some View {
        HStack(spacing: 10) {
            ForEach(0..<8, id: \.self) { i in
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(hue: Double(i) / 8, saturation: 0.55, brightness: 0.9).gradient)
                    .frame(width: 90, height: 56)
            }
        }
    }
}

/// The screen shown in the simulated phone and in the full-screen cover.
private struct SafeAreaScreen: View {
    let config: SafeAreaConfig

    var body: some View {
        ZStack {
            if config.backgroundIgnores {
                gradient.ignoresSafeArea()
            } else {
                gradient
            }
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Inbox")
                        .font(.largeTitle.bold())
                    ForEach(1...12, id: \.self) { i in
                        Text("Message \(i)")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(.white.opacity(0.2), in: .rect(cornerRadius: 12))
                    }
                }
            }
            .foregroundStyle(.white)
            .safeAreaPadding(.horizontal, config.horizontalPadding)
            .safeAreaInset(edge: .bottom) {
                if config.bottomBar {
                    Button("New Message", systemImage: "square.and.pencil") {}
                        .buttonStyle(.glassProminent)
                        .padding(.bottom, 8)
                }
            }
        }
        .overlay {
            if config.showSafeArea {
                Rectangle()
                    .strokeBorder(.red, style: StrokeStyle(lineWidth: 2, dash: [6, 4]))
                    .allowsHitTesting(false)
            }
        }
    }

    private var gradient: LinearGradient {
        LinearGradient(colors: [.blue, .purple], startPoint: .top, endPoint: .bottom)
    }
}

// MARK: - Guideline samples

/// A small phone with a bottom button inside or outside the safe area.
private struct SafeAreaButtonSample: View {
    let insideSafeArea: Bool

    var body: some View {
        SimulatedPhone(width: 160, height: 240) {
            VStack {
                Text("Checkout")
                    .font(.headline)
                Spacer()
                Button {
                } label: {
                    Text("Pay Now")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(.horizontal, 12)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea(edges: insideSafeArea ? [] : .bottom)
        }
    }
}

/// A small phone whose background does or doesn't reach the edges.
private struct SafeAreaBackgroundSample: View {
    let fills: Bool

    var body: some View {
        SimulatedPhone(width: 160, height: 240) {
            ZStack {
                if fills {
                    Color.teal.ignoresSafeArea()
                } else {
                    Color.teal
                }
                Text("Welcome")
                    .font(.headline)
                    .foregroundStyle(.white)
            }
        }
    }
}
