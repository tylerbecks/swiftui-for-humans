#if DEBUG
import Charts
import SwiftUI

/// The website's hero marquee is made from this screen. Launch with
/// `-heroReel` on the iPad test simulator: it lays out real components as
/// fixed 240×150 tiles, and the animated ones change every 3 seconds, so each
/// change has time to settle. `scripts/hero-reel.sh` crops the
/// screenshot and recording into tiles. Debug builds only.
struct HeroReel: View {
    static let tileSize = CGSize(width: 240, height: 150)
    static let origin = CGPoint(x: 12, y: 12)
    static let spacing: CGFloat = 12
    static let columns = 3

    @State private var on = false

    var body: some View {
        ZStack(alignment: .topLeading) {
            Color(.systemBackground)
            ForEach(Array(HeroTile.allCases.enumerated()), id: \.element) { index, tile in
                tile.view(on: on)
                    .frame(width: Self.tileSize.width, height: Self.tileSize.height)
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipped()
                    .offset(Self.offset(index))
            }
        }
        .ignoresSafeArea()
        .statusBarHidden()
        .task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(3))
                on.toggle()
            }
        }
    }

    static func offset(_ index: Int) -> CGSize {
        CGSize(
            width: origin.x + CGFloat(index % columns) * (tileSize.width + spacing),
            height: origin.y + CGFloat(index / columns) * (tileSize.height + spacing)
        )
    }
}

/// One tile per component. The raw value names the file on the website.
enum HeroTile: String, CaseIterable {
    case toggle, glassMorph, slider, segmented
    case buttons, progress, symbolSwap, stepper
    case chart, glassTabs, gauge, typography
    case textField, spinner, settingsRow, glassButtons
    case datePicker, tags, colors, sheet

    /// Tiles that change over time and are saved as video.
    var isAnimated: Bool {
        switch self {
        case .toggle, .glassMorph, .slider, .segmented, .progress, .symbolSwap,
             .chart, .glassTabs, .spinner, .sheet: true
        default: false
        }
    }

    @ViewBuilder func view(on: Bool) -> some View {
        switch self {
        case .toggle: ToggleTile(on: on)
        case .glassMorph: GlassMorphTile(on: on)
        case .slider: SliderTile(on: on)
        case .segmented: SegmentedTile(on: on)
        case .buttons: ButtonsTile()
        case .progress: ProgressTile(on: on)
        case .symbolSwap: SymbolSwapTile(on: on)
        case .stepper: StepperTile()
        case .chart: ChartTile(on: on)
        case .glassTabs: GlassTabsTile(on: on)
        case .gauge: GaugeTile()
        case .typography: TypographyTile()
        case .textField: TextFieldTile()
        case .spinner: SpinnerTile()
        case .settingsRow: SettingsRowTile()
        case .glassButtons: GlassButtonsTile()
        case .datePicker: DatePickerTile()
        case .tags: TagsTile()
        case .colors: ColorsTile()
        case .sheet: SheetTile(on: on)
        }
    }
}

// MARK: Animated

private struct ToggleTile: View {
    let on: Bool
    var body: some View {
        VStack(spacing: 14) {
            Toggle("Wi-Fi", isOn: .constant(on))
            Toggle("Bluetooth", isOn: .constant(!on))
        }
        .padding(.horizontal, 22)
        .animation(.snappy, value: on)
    }
}

private struct GlassMorphTile: View {
    let on: Bool
    @Namespace private var glass
    var body: some View {
        ZStack {
            SceneryView(.lake)
            GlassEffectContainer(spacing: 24) {
                HStack(spacing: on ? 14 : 0) {
                    Image(systemName: "pencil")
                        .frame(width: 52, height: 52)
                        .glassEffect(.regular.interactive())
                        .glassEffectID("a", in: glass)
                    if on {
                        Image(systemName: "eraser")
                            .frame(width: 52, height: 52)
                            .glassEffect(.regular.interactive())
                            .glassEffectID("b", in: glass)
                        Image(systemName: "scribble")
                            .frame(width: 52, height: 52)
                            .glassEffect(.regular.interactive())
                            .glassEffectID("c", in: glass)
                    }
                }
                .font(.title3.weight(.medium))
                .foregroundStyle(.white)
            }
        }
        .animation(.bouncy(duration: 0.7), value: on)
    }
}

private struct SliderTile: View {
    let on: Bool
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Image(systemName: "speaker.fill")
                Slider(value: .constant(on ? 0.82 : 0.28))
                Image(systemName: "speaker.wave.3.fill")
            }
            .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 22)
        .animation(.easeInOut(duration: 1.2), value: on)
    }
}

private struct SegmentedTile: View {
    let on: Bool
    var body: some View {
        Picker("View", selection: .constant(on ? 2 : 0)) {
            Text("Day").tag(0)
            Text("Week").tag(1)
            Text("Month").tag(2)
        }
        .pickerStyle(.segmented)
        .padding(.horizontal, 22)
        .animation(.snappy, value: on)
    }
}

private struct ProgressTile: View {
    let on: Bool
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Downloading…").font(.subheadline.weight(.medium))
            ProgressView(value: on ? 0.9 : 0.15)
            Text(on ? "9 of 10 files" : "2 of 10 files")
                .font(.caption)
                .foregroundStyle(.secondary)
                .contentTransition(.numericText())
        }
        .padding(.horizontal, 22)
        .animation(.easeInOut(duration: 1.4), value: on)
    }
}

private struct SymbolSwapTile: View {
    let on: Bool
    var body: some View {
        ZStack {
            SceneryView(.city)
            Image(systemName: on ? "pause.fill" : "play.fill")
                .contentTransition(.symbolEffect(.replace))
                .font(.system(size: 30))
                .foregroundStyle(.white)
                .frame(width: 76, height: 76)
                .glassEffect(.regular.interactive(), in: .circle)
        }
    }
}

private struct ChartTile: View {
    let on: Bool
    private let a: [Double] = [3, 5, 4, 7, 6, 8, 5]
    private let b: [Double] = [6, 4, 7, 5, 8, 6, 9]
    var body: some View {
        Chart(Array((on ? b : a).enumerated()), id: \.offset) { day, value in
            BarMark(x: .value("Day", String(day)), y: .value("Steps", value), width: .ratio(0.6))
                .foregroundStyle(.tint)
                .clipShape(.rect(cornerRadius: 4))
        }
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
        .chartYScale(domain: 0...10)
        .padding(.horizontal, 26)
        .padding(.vertical, 22)
        .animation(.spring(duration: 0.8), value: on)
    }
}

private struct GlassTabsTile: View {
    let on: Bool
    @Namespace private var tabs
    private let symbols = ["house.fill", "magnifyingglass", "person.fill"]
    var body: some View {
        ZStack {
            SceneryView(.meadow)
            HStack(spacing: 4) {
                ForEach(symbols.indices, id: \.self) { index in
                    let selected = index == (on ? 2 : 0)
                    Image(systemName: symbols[index])
                        .font(.title3)
                        .foregroundStyle(selected ? Color.accentColor : .primary)
                        .frame(width: 56, height: 44)
                        .background {
                            if selected {
                                Capsule().fill(.fill.secondary)
                                    .matchedGeometryEffect(id: "selection", in: tabs)
                            }
                        }
                }
            }
            .padding(5)
            .glassEffect(.regular.interactive(), in: .capsule)
            .environment(\.colorScheme, .light)
        }
        .animation(.bouncy(duration: 0.6), value: on)
    }
}

private struct SpinnerTile: View {
    var body: some View {
        VStack(spacing: 12) {
            ProgressView().controlSize(.large)
            Text("Loading").font(.subheadline).foregroundStyle(.secondary)
        }
    }
}

private struct SheetTile: View {
    let on: Bool
    var body: some View {
        // A sheet moving between a small and a large detent.
        ZStack(alignment: .bottom) {
            SceneryView(.meadow)
            VStack(spacing: 10) {
                Capsule().fill(.secondary.opacity(0.5)).frame(width: 36, height: 5)
                Text("Share Photo").font(.headline)
                HStack(spacing: 14) {
                    ForEach([Color.orange, .teal, .pink], id: \.self) { color in
                        Circle().fill(color.gradient).frame(width: 34, height: 34)
                    }
                }
            }
            .padding(.top, 8)
            .frame(maxWidth: .infinity)
            .frame(height: on ? 118 : 50, alignment: .top)
            .background(.regularMaterial, in: .rect(cornerRadius: 22))
            .clipped()
            .padding(.horizontal, 8)
        }
        .animation(.smooth(duration: 0.5), value: on)
    }
}

// MARK: Still

private struct ButtonsTile: View {
    var body: some View {
        VStack(spacing: 10) {
            Button("Continue") {}
                .buttonStyle(.borderedProminent)
            Button("Not Now") {}
                .buttonStyle(.bordered)
        }
        .controlSize(.large)
    }
}

private struct StepperTile: View {
    var body: some View {
        Stepper("Guests: 3", value: .constant(3))
            .padding(.horizontal, 22)
    }
}

private struct GaugeTile: View {
    var body: some View {
        HStack(spacing: 22) {
            Gauge(value: 0.72) { Text("CPU") } currentValueLabel: { Text("72") }
                .gaugeStyle(.accessoryCircular)
                .tint(.green)
            Gauge(value: 0.4) { Text("Mem") } currentValueLabel: { Text("40") }
                .gaugeStyle(.accessoryCircular)
                .tint(.orange)
        }
        .scaleEffect(1.3)
    }
}

private struct TypographyTile: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Large Title").font(.largeTitle.bold())
            Text("Headline").font(.headline)
            Text("Body text that reads well.").font(.body).foregroundStyle(.secondary)
        }
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct TextFieldTile: View {
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
                Text("Search").foregroundStyle(.tertiary)
                Spacer()
            }
            .padding(.horizontal, 12)
            .frame(height: 40)
            .background(.fill.tertiary, in: .capsule)
            TextField("Email", text: .constant("you@example.com"))
                .textFieldStyle(.roundedBorder)
        }
        .padding(.horizontal, 20)
    }
}

private struct SettingsRowTile: View {
    var body: some View {
        VStack(spacing: 0) {
            row("airplane", .orange, "Airplane Mode", detail: nil)
            Divider().padding(.leading, 52)
            row("bell.badge.fill", .red, "Alerts", detail: "On")
        }
        .padding(.horizontal, 16)
    }

    private func row(_ symbol: String, _ color: Color, _ title: String, detail: String?) -> some View {
        HStack(spacing: 12) {
            Image(systemName: symbol)
                .font(.subheadline)
                .foregroundStyle(.white)
                .frame(width: 30, height: 30)
                .background(color, in: .rect(cornerRadius: 7))
            Text(title)
            Spacer()
            if let detail { Text(detail).foregroundStyle(.secondary) }
            Image(systemName: "chevron.right").font(.footnote.weight(.semibold)).foregroundStyle(.tertiary)
        }
        .frame(height: 50)
    }
}

private struct GlassButtonsTile: View {
    var body: some View {
        ZStack {
            SceneryView(.wallpaper)
            VStack(spacing: 10) {
                Button("Get Started") {}
                    .buttonStyle(.glassProminent)
                Button("Learn More") {}
                    .buttonStyle(.glass)
            }
            .controlSize(.large)
        }
    }
}

private struct DatePickerTile: View {
    var body: some View {
        DatePicker("Starts", selection: .constant(Date(timeIntervalSince1970: 1_791_000_000)), displayedComponents: [.date, .hourAndMinute])
            .labelsHidden()
            .padding(.horizontal, 16)
    }
}

private struct TagsTile: View {
    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 8) {
                tag("SwiftUI", .blue)
                tag("iOS 26", .purple)
            }
            HStack(spacing: 8) {
                tag("Design", .pink)
                tag("Ship it", .green)
            }
        }
    }

    private func tag(_ text: String, _ color: Color) -> some View {
        Text(text)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(color)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(color.opacity(0.15), in: .capsule)
    }
}

private struct ColorsTile: View {
    private let colors: [Color] = [.red, .orange, .yellow, .green, .mint, .teal, .blue, .indigo, .purple, .pink]
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.fixed(30), spacing: 10), count: 5), spacing: 10) {
            ForEach(colors.indices, id: \.self) { index in
                Circle().fill(colors[index]).frame(width: 30, height: 30)
            }
        }
    }
}
#endif
