---
id: charts-maps
title: Charts & Maps
platforms: [macOS]
availability: macOS 14.0+
docs: https://developer.apple.com/documentation/charts.md
hig: https://developer.apple.com/design/human-interface-guidelines/charts.md
---

# Charts & Maps

Swift Charts with a selectable plot, and a MapKit map that fills a window.

## Contents

- Rules
- Pitfalls
- Key APIs
- Variants
- Related

## Rules

- **Say what the chart shows in words.** A short headline above the chart gives the main message at a glance, so people don't have to read the plot to get it.
- **Don't hide important values behind interaction.** Selecting a point to see its value is a nice extra. Anything people must know, like a total or a trend, belongs on the chart itself.
- **Keep charts simple.** Too much data in one chart buries what matters. Let people choose a range or a series when they want more detail.
- **Let people move around the map.** People expect to zoom and pan any map. Don't cover it with views that block those gestures, and keep the Apple logo and legal link visible.
- **Mute the map when your content is the point.** The muted emphasis style lowers the map's colors so your markers and overlays stand out.

## Pitfalls

- **Charts are accessible by default.** Swift Charts gives VoiceOver the marks and an Audio Graph; add a title and a short summary that say what the chart is for.
- **Maps load over the network.** A sandboxed app needs the Outgoing Connections (Client) entitlement. See [App Sandbox](app-sandbox.md).

## Key APIs

`Chart(data) { }`, `LineMark`, `BarMark`, `PointMark`, `.chartXSelection(value:)`, `RuleMark(x:)`, `Map(initialPosition:) { }`, `Marker(_:systemImage:coordinate:)`, `.mapControls { }`, `.mapStyle(_:)`

## Variants

### Usage

```swift
import Charts

struct DayCount: Identifiable {
    let day: Date
    let downloads: Int
    var id: Date { day }
}

struct DownloadsChart: View {
    let days: [DayCount]

    var body: some View {
        Chart(days) { day in
            LineMark(
                x: .value("Day", day.day, unit: .day),
                y: .value("Downloads", day.downloads)
            )
        }
    }
}
```

### Select a day to see its value

Bind `.chartXSelection(value:)` to a `Date?`, then draw a `RuleMark` with an annotation at the selected day.

```swift
import Charts

@State private var selectedDay: Date?

Chart(days) { day in
    LineMark(
        x: .value("Day", day.day, unit: .day),
        y: .value("Downloads", day.downloads)
    )
    if let selectedDay {
        RuleMark(x: .value("Day", selectedDay, unit: .day))
            .foregroundStyle(.secondary)
            .annotation(position: .top, overflowResolution: .init(x: .fit(to: .chart), y: .disabled)) {
                Text(selectedDay, format: .dateTime.month().day())
                    .font(.caption)
            }
    }
}
.chartXSelection(value: $selectedDay)
.frame(height: 200)
```

**Note:** The selection is a raw x value, not one of your data points. Look up the nearest day yourself to show its count.

### Compare categories with bars

Use `BarMark` to compare totals, and state the takeaway above the chart, the way the guidelines suggest.

```swift
import Charts

struct PlatformShare: Identifiable {
    let name: String
    let downloads: Int
    var id: String { name }
}

let shares = [
    PlatformShare(name: "Mac", downloads: 1840),
    PlatformShare(name: "iPhone", downloads: 1260),
    PlatformShare(name: "iPad", downloads: 610),
]

VStack(alignment: .leading) {
    Text("Most downloads come from the Mac")
        .font(.headline)
    Chart(shares) { share in
        BarMark(
            x: .value("Downloads", share.downloads),
            y: .value("Platform", share.name)
        )
        .foregroundStyle(by: .value("Platform", share.name))
    }
    .chartLegend(.hidden)
    .frame(height: 140)
}
```

### A map with your places

Give `Map` a starting region and list a `Marker` for each place. People can pan, zoom, and rotate it as in Maps.

```swift
import MapKit

struct Cafe: Identifiable {
    let name: String
    let coordinate: CLLocationCoordinate2D
    var id: String { name }
}

let cafes = [
    Cafe(name: "Ferry Building", coordinate: .init(latitude: 37.7955, longitude: -122.3937)),
    Cafe(name: "Union Square", coordinate: .init(latitude: 37.7880, longitude: -122.4075)),
]

let region = MKCoordinateRegion(
    center: .init(latitude: 37.79, longitude: -122.40),
    span: .init(latitudeDelta: 0.04, longitudeDelta: 0.04)
)

Map(initialPosition: .region(region)) {
    ForEach(cafes) { cafe in
        Marker(cafe.name, systemImage: "cup.and.saucer.fill", coordinate: cafe.coordinate)
            .tint(.brown)
    }
}
.mapStyle(.standard(emphasis: .muted))
.mapControls {
    MapZoomStepper()
    MapCompass()
    MapScaleView()
}
.frame(height: 260)
```

More variants, left out to keep this file short: A map that fills a window. Apple's docs: https://developer.apple.com/documentation/charts.md

## Related

[hover](hover.md), [inspector](inspector.md), [window-group](window-group.md), [library-window](library-window.md)
