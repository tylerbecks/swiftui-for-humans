import SwiftUI
import Charts

extension ComponentPage {
    static let charts = ComponentPage(
        id: "charts",
        title: "Swift Charts",
        summary: "Bar, line, area, point, and pie charts built from your data in a few lines.",
        category: .frameworks,
        symbol: "chart.bar.xaxis",
        availability: ["iOS 16.0+", "macOS 13.0+", "visionOS 1.0+"],
        docsURL: "https://developer.apple.com/documentation/charts",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/charts",
        aliases: ["graph", "chart.js", "recharts", "d3", "plot", "pie chart", "donut", "bar chart", "line graph", "visualization"],
        related: ["gradients", "system-colors", "gauge", "progress-view"],
        notes: [
            "**Axes, gridlines, and the legend are automatic.** Change them only when you need to, with `.chartXAxis`, `.chartYAxis`, and `.chartLegend`.",
            "**Pie and donut charts need iOS 17.** Use `SectorMark` with `innerRadius: .ratio(0.6)` for a donut.",
        ],
        about: """
        `Chart` comes from the Swift Charts framework. You loop over your data like `ForEach` and describe each value as a *mark*, such as a bar, line, or point. The chart draws the axes, scales, and legend for you.

        Use it for real data, like sales or steps over time. For a single value against a range, use `Gauge` or `ProgressView` instead.
        """,
        composition: """
        Chart(sales)
        ├── BarMark, LineMark, …
        │   └── .foregroundStyle(by:)
        ├── RuleMark
        ├── .chartYScale(domain:)
        └── .chartXSelection(value:)
        """,
        api: [
            APIItem("`Chart(_:content:)`", "Loops over your data and draws marks."),
            APIItem("`BarMark(x:y:)`", "A bar for each value. Swap x and y for horizontal bars."),
            APIItem("`LineMark(x:y:)`", "Connects values with a line, for trends over time."),
            APIItem("`.value(_:_:)`", "Names a value for the axis and VoiceOver."),
            APIItem("`.foregroundStyle(by:)`", "Splits data into colored series, with a legend."),
            APIItem("`RuleMark(y:)`", "A reference line, like a goal or average."),
            APIItem("`.chartYScale(domain:)`", "Sets the axis range, like `0...100`."),
            APIItem("`.chartXSelection(value:)`", "Binds the value under the finger (iOS 17)."),
        ],
        guidelines: [
            Guideline(
                "Start bar charts at zero.",
                "People compare bar heights. Cutting off the bottom makes small differences look huge.",
                good: "Bars start at zero, so heights compare fairly.",
                bad: "A cut-off axis makes June look four times bigger than April."
            ) {
                ChartScaleSample(startsAtZero: true)
            } bad: {
                ChartScaleSample(startsAtZero: false)
            },
            Guideline(
                "Say what the chart shows.",
                "A short title with the main takeaway helps everyone, and VoiceOver users most of all, before they read the details.",
                good: "The title states the takeaway.",
                bad: "Without a title, people must work it out."
            ) {
                ChartTitleSample(showsTitle: true)
            } bad: {
                ChartTitleSample(showsTitle: false)
            },
            Guideline(
                "Don't hide key numbers behind a touch.",
                "Touching to inspect is a bonus. Show the most important value, like today's total, without any interaction."
            ),
            Guideline(
                "Make charts accessible.",
                "Give every `.value` a clear name, and add `.accessibilityLabel` to marks when the default reading isn't enough."
            ),
        ]
    ) {
        ChartsThumbnail()
    } content: { page in
        ChartsDemo(page: page)
    }
}

// MARK: - Data

private struct Sale: Identifiable {
    let month: String
    let amount: Double
    let product: String
    var id: String { month + product }
}

private let months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun"]
private let coffee: [Double] = [32, 45, 38, 56, 61, 74]
private let tea: [Double] = [20, 24, 30, 28, 35, 33]

private let singleSeries: [Sale] = zip(months, coffee).map { Sale(month: $0, amount: $1, product: "Coffee") }
private let twoSeries: [Sale] = singleSeries + zip(months, tea).map { Sale(month: $0, amount: $1, product: "Tea") }

private struct Slice: Identifiable {
    let name: String
    let value: Double
    var id: String { name }
}

private let slices = [
    Slice(name: "Coffee", value: 46),
    Slice(name: "Tea", value: 28),
    Slice(name: "Juice", value: 16),
    Slice(name: "Water", value: 10),
]

// MARK: - Options

private enum MarkKind: DemoOption {
    case bar, line, area, point, sector

    var label: String {
        switch self {
        case .bar: "BarMark"
        case .line: "LineMark"
        case .area: "AreaMark"
        case .point: "PointMark"
        case .sector: "SectorMark"
        }
    }
}

private enum InterpolationOption: DemoOption {
    case linear, catmullRom, monotone, stepCenter

    var label: String {
        switch self {
        case .linear: ".linear"
        case .catmullRom: ".catmullRom"
        case .monotone: ".monotone"
        case .stepCenter: ".stepCenter"
        }
    }

    var method: InterpolationMethod {
        switch self {
        case .linear: .linear
        case .catmullRom: .catmullRom
        case .monotone: .monotone
        case .stepCenter: .stepCenter
        }
    }
}

private enum ChartColorOption: DemoOption {
    case blue, green, orange, purple, gradient

    var label: String {
        switch self {
        case .blue: ".blue"
        case .green: ".green"
        case .orange: ".orange"
        case .purple: ".purple"
        case .gradient: ".blue.gradient"
        }
    }

    var style: AnyShapeStyle {
        switch self {
        case .blue: AnyShapeStyle(.blue)
        case .green: AnyShapeStyle(.green)
        case .orange: AnyShapeStyle(.orange)
        case .purple: AnyShapeStyle(.purple)
        case .gradient: AnyShapeStyle(.blue.gradient)
        }
    }
}

private struct ChartsConfig {
    var mark: MarkKind = .bar
    var twoSeries = false
    var color: ChartColorOption = .blue
    var interpolation: InterpolationOption = .catmullRom
    var showsPoints = false
    var innerRadius = 0.6
    var hidesYAxis = false
    var horizontal = false
}

// MARK: - Demo

private struct ChartsDemo: View {
    let page: ComponentPage

    var body: some View {
        DemoPage(
            page: page,
            initial: ChartsConfig(),
            previewHeight: 280,
            usage: """
            Chart(sales) { sale in
                BarMark(
                    x: .value("Month", sale.month),
                    y: .value("Sales", sale.amount)
                )
            }
            .frame(height: 240)
            """,
            usageNote: Aside(.important, "Add `import Charts` at the top of the file. Your data needs to be `Identifiable`, or pass `id:` like in `ForEach`.")
        ) { $config in
            chart(config)
                .frame(height: 240)
                .animation(.snappy, value: config.twoSeries)
        } controls: { $config in
            Section("Mark") {
                OptionPicker("Mark", selection: $config.mark)
                if config.mark == .sector {
                    ValueSlider("Inner radius", value: $config.innerRadius, in: 0...0.9, step: 0.05)
                } else {
                    Toggle("Two series", isOn: $config.twoSeries)
                    if !config.twoSeries {
                        OptionPicker("Color", selection: $config.color)
                    }
                }
            }
            if config.mark == .line || config.mark == .area {
                Section("Line") {
                    OptionPicker("Interpolation", selection: $config.interpolation)
                    if config.mark == .line {
                        Toggle("Show points", isOn: $config.showsPoints)
                    }
                }
            }
            if config.mark == .bar {
                Section("Bars") {
                    Toggle("Horizontal", isOn: $config.horizontal)
                }
            }
            if config.mark != .sector {
                Section("Axes") {
                    Toggle("Hide y-axis", isOn: $config.hidesYAxis)
                }
            }
        } code: { config in
            code(config)
        } examples: {
            LineOverTimeExample()

            ExampleCard(
                title: "Highlight a value with a rule",
                caption: "Add a `RuleMark` to draw a reference line, like a goal or average, across the bars.",
                code: """
                Chart {
                    ForEach(sales) { sale in
                        BarMark(
                            x: .value("Month", sale.month),
                            y: .value("Sales", sale.amount)
                        )
                        .foregroundStyle(sale.amount >= 50 ? Color.green : Color.gray.opacity(0.5))
                    }
                    RuleMark(y: .value("Goal", 50))
                        .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 4]))
                        .annotation(position: .top, alignment: .leading) {
                            Text("Goal").font(.caption.bold())
                        }
                }
                .frame(height: 200)
                """,
                minHeight: 220
            ) {
                Chart {
                    ForEach(singleSeries) { sale in
                        BarMark(
                            x: .value("Month", sale.month),
                            y: .value("Sales", sale.amount)
                        )
                        .foregroundStyle(sale.amount >= 50 ? Color.green : Color.gray.opacity(0.5))
                    }
                    RuleMark(y: .value("Goal", 50))
                        .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 4]))
                        .annotation(position: .top, alignment: .leading) {
                            Text("Goal").font(.caption.bold())
                        }
                }
                .frame(height: 200)
            }

            SelectableChartExample()

            ExampleCard(
                title: "Sparkline",
                caption: "Hide both axes with `.chartXAxis(.hidden)` for a tiny trend line in a row or stat card.",
                code: """
                HStack {
                    VStack(alignment: .leading) {
                        Text("Revenue").foregroundStyle(.secondary)
                        Text("$74k").font(.title.bold())
                    }
                    Chart(sales) { sale in
                        AreaMark(x: .value("Month", sale.month), y: .value("Sales", sale.amount))
                            .foregroundStyle(.green.opacity(0.2).gradient)
                        LineMark(x: .value("Month", sale.month), y: .value("Sales", sale.amount))
                            .foregroundStyle(.green)
                    }
                    .chartXAxis(.hidden)
                    .chartYAxis(.hidden)
                    .frame(width: 120, height: 50)
                }
                """,
                minHeight: 120
            ) {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Revenue").foregroundStyle(.secondary)
                        Text("$74k").font(.title.bold())
                    }
                    Chart(singleSeries) { sale in
                        AreaMark(x: .value("Month", sale.month), y: .value("Sales", sale.amount))
                            .foregroundStyle(.green.opacity(0.2).gradient)
                        LineMark(x: .value("Month", sale.month), y: .value("Sales", sale.amount))
                            .foregroundStyle(.green)
                    }
                    .chartXAxis(.hidden)
                    .chartYAxis(.hidden)
                    .frame(width: 120, height: 50)
                }
            }
        }
    }

    @ViewBuilder
    private func chart(_ config: ChartsConfig) -> some View {
        if config.mark == .sector {
            Chart(slices) { slice in
                SectorMark(
                    angle: .value("Share", slice.value),
                    innerRadius: .ratio(config.innerRadius),
                    angularInset: 2
                )
                .cornerRadius(4)
                .foregroundStyle(by: .value("Drink", slice.name))
            }
        } else {
            let data = config.twoSeries ? twoSeries : singleSeries
            Chart(data) { sale in
                mark(config, sale)
            }
            .chartYAxis(config.hidesYAxis ? .hidden : .automatic)
        }
    }

    @ChartContentBuilder
    private func mark(_ config: ChartsConfig, _ sale: Sale) -> some ChartContent {
        let x = PlottableValue.value("Month", sale.month)
        let y = PlottableValue.value("Sales", sale.amount)
        switch config.mark {
        case .bar:
            if config.horizontal {
                styled(BarMark(x: .value("Sales", sale.amount), y: .value("Month", sale.month)), config, sale)
            } else {
                styled(BarMark(x: x, y: y), config, sale)
            }
        case .line:
            if config.showsPoints {
                styled(LineMark(x: x, y: y), config, sale)
                    .interpolationMethod(config.interpolation.method)
                    .symbol(.circle)
            } else {
                styled(LineMark(x: x, y: y), config, sale)
                    .interpolationMethod(config.interpolation.method)
            }
        case .area:
            styled(AreaMark(x: x, y: y), config, sale)
                .interpolationMethod(config.interpolation.method)
        case .point:
            styled(PointMark(x: x, y: y), config, sale)
                .symbolSize(80)
        case .sector:
            styled(BarMark(x: x, y: y), config, sale)
        }
    }

    @ChartContentBuilder
    private func styled<M: ChartContent>(_ mark: M, _ config: ChartsConfig, _ sale: Sale) -> some ChartContent {
        if config.twoSeries {
            mark.foregroundStyle(by: .value("Product", sale.product))
        } else {
            mark.foregroundStyle(config.color.style)
        }
    }

    private func code(_ config: ChartsConfig) -> String {
        if config.mark == .sector {
            return """
            import Charts

            struct Slice: Identifiable {
                let name: String
                let value: Double
                var id: String { name }
            }

            let slices = [
                Slice(name: "Coffee", value: 46),
                Slice(name: "Tea", value: 28),
                Slice(name: "Juice", value: 16),
                Slice(name: "Water", value: 10),
            ]

            Chart(slices) { slice in
                SectorMark(
                    angle: .value("Share", slice.value),
                    innerRadius: .ratio(\(swiftNumber(config.innerRadius))),
                    angularInset: 2
                )
                .cornerRadius(4)
                .foregroundStyle(by: .value("Drink", slice.name))
            }
            .frame(height: 240)
            """
        }

        var lines = [
            "import Charts",
            "",
            "struct Sale: Identifiable {",
            "    let id = UUID()",
            "    let month: String",
            "    let amount: Double",
        ]
        if config.twoSeries { lines.append("    let product: String") }
        lines += ["}", "", "let sales = ["]
        if config.twoSeries {
            for (product, values) in [("Coffee", coffee), ("Tea", tea)] {
                for (month, amount) in zip(months, values) {
                    lines.append("    Sale(month: \"\(month)\", amount: \(swiftNumber(amount)), product: \"\(product)\"),")
                }
            }
        } else {
            for (month, amount) in zip(months, coffee) {
                lines.append("    Sale(month: \"\(month)\", amount: \(swiftNumber(amount))),")
            }
        }
        lines += ["]", "", "Chart(sales) { sale in"]

        let horizontal = config.mark == .bar && config.horizontal
        lines.append("    \(config.mark.label)(")
        if horizontal {
            lines.append("        x: .value(\"Sales\", sale.amount),")
            lines.append("        y: .value(\"Month\", sale.month)")
        } else {
            lines.append("        x: .value(\"Month\", sale.month),")
            lines.append("        y: .value(\"Sales\", sale.amount)")
        }
        lines.append("    )")
        if config.twoSeries {
            lines.append("    .foregroundStyle(by: .value(\"Product\", sale.product))")
        } else {
            lines.append("    .foregroundStyle(\(config.color.label))")
        }
        if config.mark == .line || config.mark == .area, config.interpolation != .linear {
            lines.append("    .interpolationMethod(\(config.interpolation.label))")
        }
        if config.mark == .line && config.showsPoints {
            lines.append("    .symbol(.circle)")
        }
        if config.mark == .point {
            lines.append("    .symbolSize(80)")
        }
        lines.append("}")
        if config.hidesYAxis { lines.append(".chartYAxis(.hidden)") }
        lines.append(".frame(height: 240)")
        return lines.joined(separator: "\n")
    }
}

// MARK: - Line over time

private struct DaySteps: Identifiable {
    let date: Date
    let count: Int
    var id: Date { date }
}

private let weekSteps: [DaySteps] = {
    let today = Calendar.current.startOfDay(for: .now)
    let counts = [6200, 8400, 7100, 10300, 9200, 12100, 8800]
    return counts.enumerated().map { index, count in
        DaySteps(date: Calendar.current.date(byAdding: .day, value: index - 6, to: today)!, count: count)
    }
}()

private struct LineOverTimeExample: View {
    var body: some View {
        ExampleCard(
            title: "Trend over time",
            caption: "Plot a `Date` on the x-axis with `LineMark`, and pass `unit: .day` so values snap to days.",
            code: """
            struct DaySteps: Identifiable {
                let date: Date
                let count: Int
                var id: Date { date }
            }

            Chart(steps) { day in
                LineMark(
                    x: .value("Day", day.date, unit: .day),
                    y: .value("Steps", day.count)
                )
                .interpolationMethod(.catmullRom)
                .symbol(.circle)
            }
            .frame(height: 200)
            """,
            minHeight: 220,
            aside: Aside(.note, "Without `unit:`, dates plot as exact moments, and axis labels may show times instead of days.")
        ) {
            Chart(weekSteps) { day in
                LineMark(
                    x: .value("Day", day.date, unit: .day),
                    y: .value("Steps", day.count)
                )
                .interpolationMethod(.catmullRom)
                .symbol(.circle)
            }
            .frame(height: 200)
        }
    }
}

// MARK: - Guideline samples

private struct ChartScaleSample: View {
    let startsAtZero: Bool
    private let data: [(String, Double)] = [("Apr", 56), ("May", 61), ("Jun", 74)]

    var body: some View {
        Chart(data, id: \.0) { month, amount in
            BarMark(x: .value("Month", month), y: .value("Sales", amount))
        }
        .chartYScale(domain: startsAtZero ? 0...80 : 50...80)
        .chartPlotStyle { plot in plot.clipped() }
        .frame(width: 220, height: 120)
    }
}

private struct ChartTitleSample: View {
    let showsTitle: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if showsTitle {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Sales more than doubled")
                        .font(.headline)
                    Text("Jan to Jun")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            Chart(singleSeries) { sale in
                LineMark(x: .value("Month", sale.month), y: .value("Sales", sale.amount))
            }
            .frame(height: 100)
        }
        .frame(width: 240)
    }
}

// MARK: - Selection example

private struct SelectableChartExample: View {
    @State private var selectedMonth: String?

    private var selected: Sale? {
        singleSeries.first { $0.month == selectedMonth }
    }

    var body: some View {
        ExampleCard(
            title: "Touch to inspect",
            caption: "`.chartXSelection(value:)` binds the value under the finger. Touch and drag across the bars.",
            code: """
            @State private var selectedMonth: String?

            Chart(sales) { sale in
                BarMark(
                    x: .value("Month", sale.month),
                    y: .value("Sales", sale.amount)
                )
                .foregroundStyle(selectedMonth == nil || selectedMonth == sale.month
                                 ? Color.blue : Color.blue.opacity(0.3))
            }
            .chartXSelection(value: $selectedMonth)
            .frame(height: 200)
            """,
            minHeight: 260,
            aside: Aside(.note, "The binding goes back to `nil` when the finger lifts. Selection needs iOS 17.")
        ) {
            VStack(alignment: .leading, spacing: 8) {
                Text(selected.map { "\($0.month): \(Int($0.amount)) sold" } ?? "Touch and drag across the bars")
                    .font(.headline)
                    .contentTransition(.numericText())
                Chart(singleSeries) { sale in
                    BarMark(
                        x: .value("Month", sale.month),
                        y: .value("Sales", sale.amount)
                    )
                    .foregroundStyle(selectedMonth == nil || selectedMonth == sale.month
                                     ? Color.blue : Color.blue.opacity(0.3))
                }
                .chartXSelection(value: $selectedMonth)
                .frame(height: 200)
            }
            .animation(.snappy, value: selectedMonth)
        }
    }
}

// MARK: - Thumbnail

private struct ChartsThumbnail: View {
    var body: some View {
        Chart(twoSeries) { sale in
            BarMark(x: .value("Month", sale.month), y: .value("Sales", sale.amount))
                .foregroundStyle(by: .value("Product", sale.product))
                .cornerRadius(3)
        }
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
        .chartLegend(.hidden)
        .frame(width: 200, height: 110)
    }
}
