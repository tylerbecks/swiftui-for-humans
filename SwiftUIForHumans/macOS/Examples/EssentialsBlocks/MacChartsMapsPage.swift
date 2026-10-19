import Charts
import MapKit
import SwiftUI

extension ComponentPage {
    static let chartsMaps = ComponentPage(
        id: "charts-maps",
        title: "Charts & Maps",
        summary: "Swift Charts with a selectable plot, and a MapKit map that fills a window.",
        category: .frameworks,
        kind: .component,
        symbol: "chart.xyaxis.line",
        availability: ["macOS 14.0+"],
        docsURL: "https://developer.apple.com/documentation/charts",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/charts",
        aliases: [
            "Swift Charts", "chart", "graph", "line chart", "bar chart", "plot", "chartXSelection",
            "RuleMark", "LineMark", "BarMark", "MapKit", "Map", "Marker", "MKMapView", "map controls",
            "Chart.js", "Google Maps", "location",
        ],
        related: ["hover", "inspector", "window-group", "library-window"],
        notes: [
            "**Charts are accessible by default.** Swift Charts gives VoiceOver the marks and an Audio Graph; add a title and a short summary that say what the chart is for.",
            "**Maps load over the network.** A sandboxed app needs the Outgoing Connections (Client) entitlement. See [App Sandbox](catalog://app-sandbox).",
        ],
        api: [
            APIItem("`Chart(data) { }`", "A chart built from marks you list."),
            APIItem("`LineMark`, `BarMark`, `PointMark`", "Lines, bars, and dots."),
            APIItem("`.chartXSelection(value:)`", "Binds the x value people select."),
            APIItem("`RuleMark(x:)`", "A line across the plot, for the selection."),
            APIItem("`Map(initialPosition:) { }`", "An interactive map with your markers."),
            APIItem("`Marker(_:systemImage:coordinate:)`", "A balloon pin with a symbol."),
            APIItem("`.mapControls { }`", "Zoom, compass, and scale controls."),
            APIItem("`.mapStyle(_:)`", "Standard, satellite imagery, or hybrid."),
        ],
        guidelines: [
            Guideline(
                "Say what the chart shows in words.",
                "A short headline above the chart gives the main message at a glance, so people don't have to read the plot to get it.",
                good: "A headline sums up the chart.",
                bad: "People have to work it out."
            ) {
                MacTinyChart(showsHeadline: true)
            } bad: {
                MacTinyChart(showsHeadline: false)
            },
            Guideline(
                "Don't hide important values behind interaction.",
                "Selecting a point to see its value is a nice extra. Anything people must know, like a total or a trend, belongs on the chart itself."
            ),
            Guideline(
                "Keep charts simple.",
                "Too much data in one chart buries what matters. Let people choose a range or a series when they want more detail."
            ),
            Guideline(
                "Let people move around the map.",
                "People expect to zoom and pan any map. Don't cover it with views that block those gestures, and keep the Apple logo and legal link visible."
            ),
            Guideline(
                "Mute the map when your content is the point.",
                "The muted emphasis style lowers the map's colors so your markers and overlays stand out."
            ),
        ]
    ) {
        MacTinyChart(showsHeadline: false)
            .frame(width: 180)
    } content: { page in
        MacChartsMapsArticle(page: page)
    }
}

extension Catalog {
    /// A map that fills a real window, with its controls and a style picker
    /// in the toolbar.
    static let chartsMapsDemoWindow = DemoWindow(
        id: "charts-maps-map",
        title: "Coffee Map",
        size: CGSize(width: 760, height: 520)
    ) {
        MacMapWindowContent()
    }
}

// MARK: - Sample data

private struct MacDayCount: Identifiable {
    let day: Date
    let downloads: Int
    var id: Date { day }

    /// Two weeks of made-up downloads, the same on every launch.
    static let samples: [MacDayCount] = {
        let start = Calendar.current.date(from: DateComponents(year: 2026, month: 10, day: 1)) ?? .now
        let counts = [120, 138, 131, 162, 190, 96, 88, 150, 171, 166, 205, 238, 112, 104]
        return counts.enumerated().map { index, count in
            MacDayCount(day: Calendar.current.date(byAdding: .day, value: index, to: start) ?? start, downloads: count)
        }
    }()
}

private struct MacPlatformShare: Identifiable {
    let name: String
    let downloads: Int
    var id: String { name }

    static let samples = [
        MacPlatformShare(name: "Mac", downloads: 1840),
        MacPlatformShare(name: "iPhone", downloads: 1260),
        MacPlatformShare(name: "iPad", downloads: 610),
    ]
}

private struct MacCafe: Identifiable, Hashable {
    let name: String
    let latitude: Double
    let longitude: Double
    var id: String { name }

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    static let samples = [
        MacCafe(name: "Ferry Building", latitude: 37.7955, longitude: -122.3937),
        MacCafe(name: "Union Square", latitude: 37.7880, longitude: -122.4075),
        MacCafe(name: "Dolores Park", latitude: 37.7596, longitude: -122.4269),
    ]

    static let region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.778, longitude: -122.41),
        span: MKCoordinateSpan(latitudeDelta: 0.06, longitudeDelta: 0.06)
    )
}

// MARK: - Page

private struct MacChartsMapsArticle: View {
    let page: ComponentPage

    var body: some View {
        ArticlePage(page: page) {
            Prose("Swift Charts and MapKit both come as SwiftUI views. A `Chart` draws your data with marks, and a `Map` shows an interactive map with your own markers. Both scale up well in a large Mac window.")

            SectionTitle("Usage")
                .id("code")
            CodeBlock(code: """
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
            """)

            SectionTitle("Charts")
                .id("examples")
            MacChartExamples()

            SectionTitle("Maps")
            MacMapExamples()
        }
    }
}

// MARK: - Chart examples

private struct MacChartExamples: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 44) {
            ExampleCard(
                title: "Select a day to see its value",
                caption: "Bind `.chartXSelection(value:)` to a `Date?`, then draw a `RuleMark` with an annotation at the selected day.",
                code: """
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
                """,
                minHeight: 280,
                aside: Aside(.note, "The selection is a raw x value, not one of your data points. Look up the nearest day yourself to show its count.")
            ) {
                MacSelectableChart()
            }

            ExampleCard(
                title: "Compare categories with bars",
                caption: "Use `BarMark` to compare totals, and state the takeaway above the chart, the way the guidelines suggest.",
                code: """
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
                """,
                minHeight: 220
            ) {
                VStack(alignment: .leading) {
                    Text("Most downloads come from the Mac")
                        .font(.headline)
                    Chart(MacPlatformShare.samples) { share in
                        BarMark(
                            x: .value("Downloads", share.downloads),
                            y: .value("Platform", share.name)
                        )
                        .foregroundStyle(by: .value("Platform", share.name))
                    }
                    .chartLegend(.hidden)
                    .frame(height: 140)
                }
                .frame(maxWidth: 440)
            }
        }
    }
}

private struct MacSelectableChart: View {
    @State private var selectedDay: Date?
    private let days = MacDayCount.samples

    private var selected: MacDayCount? {
        guard let selectedDay else { return nil }
        return days.min { abs($0.day.timeIntervalSince(selectedDay)) < abs($1.day.timeIntervalSince(selectedDay)) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Downloads")
                    .font(.headline)
                Group {
                    if let selected {
                        Text("\(selected.downloads) on \(selected.day.formatted(.dateTime.month().day()))")
                    } else {
                        Text("\(days.map(\.downloads).reduce(0, +)) in the last two weeks")
                    }
                }
                .font(.callout.monospacedDigit())
                .foregroundStyle(.secondary)
            }
            Chart(days) { day in
                LineMark(
                    x: .value("Day", day.day, unit: .day),
                    y: .value("Downloads", day.downloads)
                )
                .interpolationMethod(.monotone)
                if let selected {
                    RuleMark(x: .value("Day", selected.day, unit: .day))
                        .foregroundStyle(.secondary)
                    PointMark(
                        x: .value("Day", selected.day, unit: .day),
                        y: .value("Downloads", selected.downloads)
                    )
                }
            }
            .chartXSelection(value: $selectedDay)
            .frame(height: 200)
        }
        .frame(maxWidth: 480)
    }
}

/// A small line chart, with or without a headline, for the thumbnail and
/// the guideline pair.
private struct MacTinyChart: View {
    let showsHeadline: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if showsHeadline {
                Text("Downloads up 24% this week")
                    .font(.caption.weight(.semibold))
            }
            Chart(MacDayCount.samples) { day in
                LineMark(
                    x: .value("Day", day.day, unit: .day),
                    y: .value("Downloads", day.downloads)
                )
                .interpolationMethod(.monotone)
            }
            .chartXAxis(.hidden)
            .chartYAxis(.hidden)
            .frame(height: 80)
        }
        .frame(width: 220)
    }
}

// MARK: - Map examples

private struct MacMapExamples: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 44) {
            ExampleCard(
                title: "A map with your places",
                caption: "Give `Map` a starting region and list a `Marker` for each place. People can pan, zoom, and rotate it as in Maps.",
                code: """
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
                """,
                minHeight: 300
            ) {
                MacCafeMap()
                    .frame(height: 260)
                    .clipShape(.rect(cornerRadius: 10))
            }

            ExampleCard(
                title: "A map that fills a window",
                caption: "On the Mac a map often is the window. Put the style picker in the toolbar and let the map run edge to edge under it.",
                code: """
                import MapKit

                enum MapKind: String, CaseIterable {
                    case standard = "Standard"
                    case imagery = "Satellite"
                    case hybrid = "Hybrid"

                    var style: MapStyle {
                        switch self {
                        case .standard: .standard
                        case .imagery: .imagery
                        case .hybrid: .hybrid
                        }
                    }
                }

                struct CafeMapWindow: View {
                    @State private var kind = MapKind.standard

                    var body: some View {
                        Map {
                            Marker("Ferry Building", systemImage: "cup.and.saucer.fill",
                                   coordinate: .init(latitude: 37.7955, longitude: -122.3937))
                        }
                        .mapStyle(kind.style)
                        .mapControls {
                            MapZoomStepper()
                            MapCompass()
                        }
                        .toolbar {
                            Picker("Map Style", selection: $kind) {
                                ForEach(MapKind.allCases, id: \\.self) { kind in
                                    Text(kind.rawValue).tag(kind)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                    }
                }
                """,
                minHeight: 120
            ) {
                OpenDemoWindowButton(id: "charts-maps-map", label: "Open the Map Window")
                    .controlSize(.large)
            }
        }
    }
}

private struct MacCafeMap: View {
    var body: some View {
        Map(initialPosition: .region(MacCafe.region)) {
            ForEach(MacCafe.samples) { cafe in
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
    }
}

private enum MacMapKind: String, CaseIterable {
    case standard = "Standard"
    case imagery = "Satellite"
    case hybrid = "Hybrid"

    var style: MapStyle {
        switch self {
        case .standard: .standard
        case .imagery: .imagery
        case .hybrid: .hybrid
        }
    }
}

/// The demo window: a map edge to edge, with its style in the toolbar.
private struct MacMapWindowContent: View {
    @State private var kind = MacMapKind.standard
    @State private var selection: MacCafe?

    var body: some View {
        Map(initialPosition: .region(MacCafe.region), selection: $selection) {
            ForEach(MacCafe.samples) { cafe in
                Marker(cafe.name, systemImage: "cup.and.saucer.fill", coordinate: cafe.coordinate)
                    .tint(.brown)
                    .tag(cafe)
            }
        }
        .mapStyle(kind.style)
        .mapControls {
            MapZoomStepper()
            MapCompass()
            MapScaleView()
        }
        .navigationSubtitle(selection?.name ?? "Click a marker")
        .toolbar {
            Picker("Map Style", selection: $kind) {
                ForEach(MacMapKind.allCases, id: \.self) { kind in
                    Text(kind.rawValue).tag(kind)
                }
            }
            .pickerStyle(.segmented)
        }
    }
}
