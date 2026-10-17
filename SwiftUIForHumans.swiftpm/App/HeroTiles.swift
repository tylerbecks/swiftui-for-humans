import Charts
import SwiftUI

// Small, real components shown as tiles: on the Components tab's hero board
// (`HeroBoard`) and, through the debug-only `HeroReel`, on the website.
// Each tile is designed 240 points wide, and animated tiles take an `on`
// value that flips between two resting states.

/// One tile per component. The raw value names the file on the website.
enum HeroTile: String, CaseIterable, Encodable {
    case symbolSwap, toggle, glassMorph, inbox, slider, chart
    case buttons, wheel, segmented, glassButtons, progress, typography
    case bell, sheet, stepper, gauge, disclosure, textField
    case nowPlaying, colors, emptyState, spinner, settingsRow, tags
    case glassTabs, datePicker, lineChart, library, rating, calendar
    case timer, formatBar, tabs, avatars, battery, files

    /// Height in points; every tile is 240 points wide.
    var height: CGFloat {
        switch self {
        case .toggle: 130
        case .glassMorph: 200
        case .slider: 90
        case .segmented: 84
        case .buttons: 150
        case .progress: 120
        case .symbolSwap: 240
        case .stepper: 80
        case .chart: 190
        case .glassTabs: 170
        case .gauge: 140
        case .typography: 150
        case .textField: 130
        case .spinner: 120
        case .settingsRow: 120
        case .glassButtons: 220
        case .datePicker: 80
        case .tags: 110
        case .colors: 140
        case .sheet: 220
        case .wheel: 200
        case .disclosure: 190
        case .bell: 110
        case .emptyState: 210
        case .inbox: 250
        case .nowPlaying: 160
        case .lineChart: 180
        case .library: 300
        case .rating: 90
        case .calendar: 290
        case .timer: 120
        case .formatBar: 90
        case .tabs: 320
        case .avatars: 100
        case .battery: 100
        case .files: 210
        }
    }

    /// The page a tap opens.
    var pageID: ComponentPage.ID {
        switch self {
        case .symbolSwap, .bell: "symbol-effects"
        case .toggle, .formatBar: "toggle"
        case .glassMorph, .glassButtons, .nowPlaying: "liquid-glass"
        case .inbox, .settingsRow: "list"
        case .slider: "slider"
        case .chart, .lineChart: "charts"
        case .buttons: "button"
        case .wheel, .segmented: "picker"
        case .progress, .spinner: "progress-view"
        case .typography: "font"
        case .sheet: "sheet"
        case .stepper: "stepper"
        case .gauge, .battery: "gauge"
        case .disclosure: "form"
        case .textField: "text-field"
        case .colors: "color-picker"
        case .emptyState: "empty-state"
        case .tags: "shapes"
        case .glassTabs, .tabs: "tab-view"
        case .datePicker, .calendar: "date-picker"
        case .library: "navigation-stack"
        case .rating, .timer: "content-transition"
        case .avatars: "stacks"
        case .files: "label"
        }
    }

    /// What the website's hover label calls it.
    var title: String {
        switch self {
        case .toggle: "Toggle"
        case .glassMorph: "Glass Effect Container"
        case .slider: "Slider"
        case .segmented: "Segmented Picker"
        case .buttons: "Button"
        case .progress: "ProgressView"
        case .symbolSwap: "Symbol Effects"
        case .stepper: "Stepper"
        case .chart: "Bar Chart"
        case .glassTabs: "Liquid Glass"
        case .gauge: "Gauge"
        case .typography: "Text Styles"
        case .textField: "TextField"
        case .spinner: "ProgressView"
        case .settingsRow: "List"
        case .glassButtons: "Glass Buttons"
        case .datePicker: "DatePicker"
        case .tags: "Capsule"
        case .colors: "Color"
        case .sheet: "Sheet"
        case .wheel: "Wheel Picker"
        case .disclosure: "DisclosureGroup"
        case .bell: "Symbol Effects"
        case .emptyState: "ContentUnavailableView"
        case .inbox: "List"
        case .nowPlaying: "Liquid Glass"
        case .lineChart: "Line Chart"
        case .library: "NavigationStack"
        case .rating: "Animation"
        case .calendar: "DatePicker"
        case .timer: "Content Transition"
        case .formatBar: "Toggle Button"
        case .tabs: "TabView"
        case .avatars: "Overlapping Views"
        case .battery: "Gauge"
        case .files: "Label"
        }
    }

    /// Tiles that change over time and are saved as video.
    var isAnimated: Bool {
        switch self {
        case .toggle, .glassMorph, .slider, .segmented, .progress, .symbolSwap,
             .chart, .glassTabs, .spinner, .sheet, .wheel, .disclosure, .bell,
             .lineChart, .rating, .timer, .formatBar, .tabs: true
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
        case .wheel: WheelTile(on: on)
        case .disclosure: DisclosureTile(on: on)
        case .bell: BellTile(on: on)
        case .emptyState: EmptyStateTile()
        case .inbox: InboxTile()
        case .nowPlaying: NowPlayingTile()
        case .lineChart: LineChartTile(on: on)
        case .library: LibraryTile()
        case .rating: RatingTile(on: on)
        case .calendar: CalendarTile()
        case .timer: TimerTile(on: on)
        case .formatBar: FormatBarTile(on: on)
        case .tabs: TabsTile(on: on)
        case .avatars: AvatarsTile()
        case .battery: BatteryTile()
        case .files: FilesTile()
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

private struct WheelTile: View {
    let on: Bool
    var body: some View {
        Picker("Minutes", selection: .constant(on ? 25 : 10)) {
            ForEach(Array(stride(from: 0, through: 60, by: 5)), id: \.self) { minutes in
                Text("\(minutes) min").tag(minutes)
            }
        }
        .pickerStyle(.wheel)
        .labelsHidden()
        .padding(.horizontal, 16)
        .animation(.smooth(duration: 0.8), value: on)
    }
}

private struct DisclosureTile: View {
    let on: Bool
    var body: some View {
        VStack {
            DisclosureGroup("Advanced", isExpanded: .constant(on)) {
                VStack(spacing: 10) {
                    Toggle("Auto-Save", isOn: .constant(true))
                    Toggle("Show Hints", isOn: .constant(false))
                }
                .padding(.top, 10)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 20)
        .padding(.top, 22)
        .animation(.smooth(duration: 0.5), value: on)
    }
}

private struct BellTile: View {
    let on: Bool
    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: "bell.badge.fill")
                .symbolRenderingMode(.multicolor)
                .font(.system(size: 34))
                .symbolEffect(.wiggle, value: on)
            VStack(alignment: .leading, spacing: 2) {
                Text("New Message").font(.headline)
                Text("Just now").font(.caption).foregroundStyle(.secondary)
            }
        }
    }
}

private struct LineChartTile: View {
    let on: Bool
    private let a: [Double] = [4, 6, 5, 7, 6, 8, 7, 9]
    private let b: [Double] = [3, 4, 6, 5, 8, 7, 9, 8]
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Weekly Visitors").font(.caption.weight(.semibold)).foregroundStyle(.secondary)
            Chart(Array((on ? b : a).enumerated()), id: \.offset) { day, value in
                AreaMark(x: .value("Day", day), y: .value("Visitors", value))
                    .foregroundStyle(.linearGradient(colors: [.purple.opacity(0.35), .purple.opacity(0)], startPoint: .top, endPoint: .bottom))
                    .interpolationMethod(.catmullRom)
                LineMark(x: .value("Day", day), y: .value("Visitors", value))
                    .foregroundStyle(.purple)
                    .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round))
                    .interpolationMethod(.catmullRom)
            }
            .chartXAxis(.hidden)
            .chartYAxis(.hidden)
            .chartYScale(domain: 0...10)
        }
        .padding(18)
        .animation(.smooth(duration: 0.9), value: on)
    }
}

private struct RatingTile: View {
    let on: Bool
    var body: some View {
        HStack(spacing: 8) {
            ForEach(1...5, id: \.self) { star in
                Image(systemName: star <= (on ? 5 : 3) ? "star.fill" : "star")
                    .foregroundStyle(.yellow)
                    .contentTransition(.symbolEffect(.replace))
            }
        }
        .font(.title)
    }
}

private struct TimerTile: View {
    let on: Bool
    var body: some View {
        VStack(spacing: 2) {
            Text(on ? "00:25" : "00:24")
                .font(.system(size: 44, weight: .semibold, design: .rounded))
                .monospacedDigit()
                .contentTransition(.numericText(countsDown: !on))
            Text("Focus").font(.subheadline).foregroundStyle(.orange)
        }
        .animation(.snappy, value: on)
    }
}

private struct FormatBarTile: View {
    let on: Bool
    var body: some View {
        HStack(spacing: 6) {
            Toggle(isOn: .constant(on)) { Image(systemName: "bold") }
            Toggle(isOn: .constant(true)) { Image(systemName: "italic") }
            Toggle(isOn: .constant(!on)) { Image(systemName: "underline") }
            Toggle(isOn: .constant(false)) { Image(systemName: "strikethrough") }
        }
        .toggleStyle(.button)
        .controlSize(.large)
        .font(.title3)
        .animation(.snappy, value: on)
    }
}

private struct TabsTile: View {
    let on: Bool
    var body: some View {
        TabView(selection: .constant(on ? 1 : 0)) {
            Tab("Listen", systemImage: "play.circle.fill", value: 0) {
                tabPage("Listen Now", .pink)
            }
            Tab("Browse", systemImage: "square.grid.2x2.fill", value: 1) {
                tabPage("Browse", .indigo)
            }
            Tab("Library", systemImage: "books.vertical.fill", value: 2) {
                tabPage("Library", .teal)
            }
        }
        .environment(\.horizontalSizeClass, .compact)
        .animation(.smooth, value: on)
    }

    private func tabPage(_ title: String, _ color: Color) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title).font(.title2.bold())
            HStack(spacing: 10) {
                RoundedRectangle(cornerRadius: 10).fill(color.gradient)
                RoundedRectangle(cornerRadius: 10).fill(color.opacity(0.5).gradient)
            }
            .frame(height: 90)
            RoundedRectangle(cornerRadius: 10).fill(color.opacity(0.25).gradient).frame(height: 60)
            Spacer()
        }
        .padding(16)
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
private struct EmptyStateTile: View {
    var body: some View {
        ContentUnavailableView.search(text: "dropdown")
            .scaleEffect(0.85)
    }
}

private struct InboxTile: View {
    private let rows: [(String, String, Color)] = [
        ("Maya", "Lunch tomorrow?", .orange),
        ("Sam", "Sent the photos", .teal),
        ("Priya", "Ship it!", .pink),
        ("Leo", "Good morning", .indigo),
    ]
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Messages").font(.title2.bold()).padding(.bottom, 6)
            ForEach(rows, id: \.0) { name, preview, color in
                HStack(spacing: 10) {
                    Text(String(name.prefix(1)))
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(width: 34, height: 34)
                        .background(color.gradient, in: .circle)
                    VStack(alignment: .leading, spacing: 1) {
                        Text(name).font(.subheadline.weight(.semibold))
                        Text(preview).font(.caption).foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .frame(height: 46)
            }
        }
        .padding(.horizontal, 16)
    }
}

private struct NowPlayingTile: View {
    var body: some View {
        ZStack {
            SceneryView(.city)
            HStack(spacing: 22) {
                Image(systemName: "backward.fill")
                Image(systemName: "pause.fill").font(.title)
                Image(systemName: "forward.fill")
            }
            .font(.title3)
            .foregroundStyle(.white)
            .padding(.horizontal, 26)
            .padding(.vertical, 14)
            .glassEffect(.regular, in: .capsule)
        }
    }
}
private struct LibraryTile: View {
    var body: some View {
        NavigationStack {
            List {
                Label("Recently Added", systemImage: "clock")
                Label("Favorites", systemImage: "heart")
                Label("Downloaded", systemImage: "arrow.down.circle")
            }
            .navigationTitle("Library")
            .searchable(text: .constant(""))
        }
        .environment(\.horizontalSizeClass, .compact)
    }
}

private struct CalendarTile: View {
    var body: some View {
        DatePicker("Date", selection: .constant(Date(timeIntervalSince1970: 1_792_195_200)), displayedComponents: .date)
            .datePickerStyle(.graphical)
            .labelsHidden()
            .frame(width: 320)
            .scaleEffect(0.74)
            .frame(width: 240, height: 290)
    }
}

private struct AvatarsTile: View {
    private let colors: [Color] = [.orange, .pink, .teal, .indigo]
    var body: some View {
        HStack(spacing: 14) {
            HStack(spacing: -12) {
                ForEach(colors.indices, id: \.self) { index in
                    Circle()
                        .fill(colors[index].gradient)
                        .frame(width: 40, height: 40)
                        .overlay(Circle().stroke(Color(.secondarySystemGroupedBackground), lineWidth: 3))
                }
            }
            Text("+12").font(.headline).foregroundStyle(.secondary)
        }
    }
}

private struct BatteryTile: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Battery", systemImage: "battery.75percent").font(.subheadline.weight(.medium))
            Gauge(value: 0.76) { EmptyView() } currentValueLabel: { Text("76%") }
                .gaugeStyle(.accessoryLinearCapacity)
                .tint(.green)
        }
        .padding(.horizontal, 20)
    }
}

private struct FilesTile: View {
    private let items: [(String, String, Color)] = [
        ("Designs", "folder.fill", .blue),
        ("Invoice.pdf", "doc.richtext.fill", .red),
        ("Notes.txt", "doc.text.fill", .gray),
        ("Photos", "photo.on.rectangle", .orange),
    ]
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            ForEach(items, id: \.0) { name, symbol, color in
                Label {
                    Text(name)
                } icon: {
                    Image(systemName: symbol).foregroundStyle(color)
                }
            }
        }
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
