---
id: charts
title: Swift Charts
platforms: [iOS, iPadOS]
availability: iOS 16.0+, macOS 13.0+, visionOS 1.0+
docs: https://developer.apple.com/documentation/charts.md
hig: https://developer.apple.com/design/human-interface-guidelines/charts.md
---

# Swift Charts

Bar, line, area, point, and pie charts built from your data in a few lines.

Also called: graph, chart.js, recharts, d3, plot, pie chart, donut, bar chart, line graph, visualization.

## Contents

- Use when
- Default code
- Built from
- Rules
- Pitfalls
- Key APIs
- Variants
- Related

## Use when

- `Chart` comes from the Swift Charts framework.
- You loop over your data like `ForEach` and describe each value as a *mark*, such as a bar, line, or point.
- The chart draws the axes, scales, and legend for you.
- Use it for real data, like sales or steps over time.
- For a single value against a range, use `Gauge` or `ProgressView` instead.

## Default code

```swift
Chart(sales) { sale in
    BarMark(
        x: .value("Month", sale.month),
        y: .value("Sales", sale.amount)
    )
}
.frame(height: 240)
```

**Important:** Add `import Charts` at the top of the file. Your data needs to be `Identifiable`, or pass `id:` like in `ForEach`.

## Built from

Chart(sales)
├── BarMark, LineMark, …
│   └── .foregroundStyle(by:)
├── RuleMark
├── .chartYScale(domain:)
└── .chartXSelection(value:)

## Rules

- **Start bar charts at zero.** People compare bar heights. Cutting off the bottom makes small differences look huge.
- **Say what the chart shows.** A short title with the main takeaway helps everyone, and VoiceOver users most of all, before they read the details.
- **Don't hide key numbers behind a touch.** Touching to inspect is a bonus. Show the most important value, like today's total, without any interaction.
- **Make charts accessible.** Give every `.value` a clear name, and add `.accessibilityLabel` to marks when the default reading isn't enough.

## Pitfalls

- **Axes, gridlines, and the legend are automatic.** Change them only when you need to, with `.chartXAxis`, `.chartYAxis`, and `.chartLegend`.
- **Pie and donut charts need iOS 17.** Use `SectorMark` with `innerRadius: .ratio(0.6)` for a donut.

## Key APIs

- `Chart(_:content:)`: Loops over your data and draws marks.
- `BarMark(x:y:)`: A bar for each value. Swap x and y for horizontal bars.
- `LineMark(x:y:)`: Connects values with a line, for trends over time.
- `.value(_:_:)`: Names a value for the axis and VoiceOver.
- `.foregroundStyle(by:)`: Splits data into colored series, with a legend.
- `RuleMark(y:)`: A reference line, like a goal or average.
- `.chartYScale(domain:)`: Sets the axis range, like `0...100`.
- `.chartXSelection(value:)`: Binds the value under the finger (iOS 17).

## Variants

### Trend over time

Plot a `Date` on the x-axis with `LineMark`, and pass `unit: .day` so values snap to days.

```swift
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
```

**Note:** Without `unit:`, dates plot as exact moments, and axis labels may show times instead of days.

### Highlight a value with a rule

Add a `RuleMark` to draw a reference line, like a goal or average, across the bars.

```swift
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
```

### Touch to inspect

`.chartXSelection(value:)` binds the value under the finger. Touch and drag across the bars.

```swift
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
```

**Note:** The binding goes back to `nil` when the finger lifts. Selection needs iOS 17.

### Sparkline

Hide both axes with `.chartXAxis(.hidden)` for a tiny trend line in a row or stat card.

```swift
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
```

## Related

[gradients](gradients.md), [system-colors](system-colors.md), [gauge](gauge.md), [progress-view](progress-view.md)
