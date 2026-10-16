import SwiftUI
import MapKit

extension ComponentPage {
    static let map = ComponentPage(
        id: "map",
        title: "Map",
        summary: "An interactive Apple Map with markers, custom pins, styles, and a camera you control.",
        category: .frameworks,
        symbol: "map",
        availability: ["iOS 17.0+", "macOS 14.0+", "visionOS 1.0+"],
        docsURL: "https://developer.apple.com/documentation/mapkit/map",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/maps",
        aliases: ["google maps", "mapbox", "leaflet", "location", "pin", "marker", "MKMapView", "satellite", "directions", "geo"],
        related: ["sheet", "safe-area", "sf-symbols", "charts"],
        notes: [
            "**Showing the person's location needs permission.** Add `NSLocationWhenInUseUsageDescription` to Info.plist, ask with `CLLocationManager`, then add `UserAnnotation()` to the map.",
            "**No API key needed.** Map tiles load over the network, so the map stays blank until they arrive.",
        ],
        about: """
        `Map` shows an interactive Apple Map. You put content inside it, like `Marker`, `Annotation`, and `MapPolyline`, and a camera position binding controls what part of the world it shows.

        It comes from MapKit and works like a SwiftUI view: size it with `.frame`, style it with `.mapStyle`, and add controls with `.mapControls`.
        """,
        composition: """
        Map(position: $position)
        ├── Marker / Annotation
        ├── MapPolyline
        ├── .mapStyle(.standard)
        └── .mapControls
            └── MapCompass()
        """,
        api: [
            APIItem("`Map(position:selection:)`", "A map with a camera binding and optional selection."),
            APIItem("`MapCameraPosition`", "What the map shows: `.automatic`, `.region`, `.camera`, or `.item`."),
            APIItem("`Marker(_:systemImage:coordinate:)`", "The standard balloon pin."),
            APIItem("`Annotation(_:coordinate:)`", "Any SwiftUI view, pinned to a spot."),
            APIItem("`MapPolyline(coordinates:)`", "A line through coordinates, like a route."),
            APIItem("`.mapStyle(_:)`", "`.standard`, `.imagery` (satellite), or `.hybrid`."),
            APIItem("`.mapControls { }`", "Compass, scale, and location buttons."),
            APIItem("`UserAnnotation()`", "The person's location, once they allow it."),
        ],
        guidelines: [
            Guideline(
                "Keep maps interactive.",
                "People expect to pan and zoom any map. If a small map can't move, open a full map when they tap it."
            ),
            Guideline(
                "Mute the map when your pins matter most.",
                "The muted style drops the saturation, so your markers and overlays stand out.",
                good: "A muted map puts the pins first.",
                bad: "Full color competes with the pins."
            ) {
                MapEmphasisSample(isMuted: true)
            } bad: {
                MapEmphasisSample(isMuted: false)
            },
            Guideline(
                "Tint markers to match your app.",
                "Use `.tint` and a symbol that fits the place, so pins feel part of your design and are easy to tell apart."
            ),
            Guideline(
                "Don't cover the Apple logo and legal link for long.",
                "They sit in the map's corner. Leave padding around them, and keep cards and controls from hiding them all the time."
            ),
        ]
    ) {
        MapThumbnail()
    } content: { page in
        MapDemo(page: page)
    }
}

// MARK: - Data

private struct Landmark: Identifiable, Hashable {
    let name: String
    let symbol: String
    let latitude: Double
    let longitude: Double

    var id: String { name }
    var coordinate: CLLocationCoordinate2D { CLLocationCoordinate2D(latitude: latitude, longitude: longitude) }
}

private enum City: DemoOption {
    case sanFrancisco, paris, tokyo, newYork

    var label: String {
        switch self {
        case .sanFrancisco: "San Francisco"
        case .paris: "Paris"
        case .tokyo: "Tokyo"
        case .newYork: "New York"
        }
    }

    var center: CLLocationCoordinate2D {
        switch self {
        case .sanFrancisco: CLLocationCoordinate2D(latitude: 37.814, longitude: -122.451)
        case .paris: CLLocationCoordinate2D(latitude: 48.857, longitude: 2.322)
        case .tokyo: CLLocationCoordinate2D(latitude: 35.684, longitude: 139.757)
        case .newYork: CLLocationCoordinate2D(latitude: 40.736, longitude: -74.005)
        }
    }

    var distance: Double {
        switch self {
        case .sanFrancisco: 15000
        case .paris: 9000
        case .tokyo: 26000
        case .newYork: 24000
        }
    }

    var landmarks: [Landmark] {
        switch self {
        case .sanFrancisco: [
            Landmark(name: "Golden Gate Bridge", symbol: "road.lanes", latitude: 37.8199, longitude: -122.4783),
            Landmark(name: "Palace of Fine Arts", symbol: "building.columns.fill", latitude: 37.8029, longitude: -122.4484),
            Landmark(name: "Alcatraz", symbol: "lock.fill", latitude: 37.8267, longitude: -122.4230),
        ]
        case .paris: [
            Landmark(name: "Eiffel Tower", symbol: "star.fill", latitude: 48.8584, longitude: 2.2945),
            Landmark(name: "Louvre", symbol: "building.columns.fill", latitude: 48.8606, longitude: 2.3376),
            Landmark(name: "Notre-Dame", symbol: "bell.fill", latitude: 48.8530, longitude: 2.3499),
        ]
        case .tokyo: [
            Landmark(name: "Tokyo Tower", symbol: "antenna.radiowaves.left.and.right", latitude: 35.6586, longitude: 139.7454),
            Landmark(name: "Shibuya Crossing", symbol: "figure.walk", latitude: 35.6595, longitude: 139.7005),
            Landmark(name: "Tokyo Skytree", symbol: "star.fill", latitude: 35.7101, longitude: 139.8107),
        ]
        case .newYork: [
            Landmark(name: "Statue of Liberty", symbol: "star.fill", latitude: 40.6892, longitude: -74.0445),
            Landmark(name: "Empire State Building", symbol: "building.2.fill", latitude: 40.7484, longitude: -73.9857),
            Landmark(name: "Central Park", symbol: "tree.fill", latitude: 40.7829, longitude: -73.9654),
        ]
        }
    }
}

// MARK: - Options

private enum MapStyleOption: DemoOption {
    case standard, imagery, hybrid

    var label: String {
        switch self {
        case .standard: "Standard"
        case .imagery: "Satellite (.imagery)"
        case .hybrid: "Hybrid"
        }
    }
}

private enum PinKind: DemoOption {
    case none, marker, annotation

    var label: String {
        switch self {
        case .none: "None"
        case .marker: "Marker"
        case .annotation: "Annotation (custom view)"
        }
    }
}

private struct MapConfig {
    var city: City = .sanFrancisco
    var style: MapStyleOption = .standard
    var realistic = false
    var muted = false
    var hidePOIs = false
    var pins: PinKind = .marker
    var pitch = 0.0
    var heading = 0.0
    var showsControls = true
}

private func cameraFor(_ config: MapConfig) -> MapCamera {
    MapCamera(centerCoordinate: config.city.center, distance: config.city.distance, heading: config.heading, pitch: config.pitch)
}

private func resolvedMapStyle(_ config: MapConfig) -> MapStyle {
    let elevation: MapStyle.Elevation = config.realistic ? .realistic : .automatic
    let poi: PointOfInterestCategories = config.hidePOIs ? .excludingAll : .all
    switch config.style {
    case .standard:
        return .standard(elevation: elevation, emphasis: config.muted ? .muted : .automatic, pointsOfInterest: poi)
    case .imagery:
        return .imagery(elevation: elevation)
    case .hybrid:
        return .hybrid(elevation: elevation, pointsOfInterest: poi)
    }
}

private func styleCode(_ config: MapConfig) -> String? {
    var args: [String] = []
    if config.realistic { args.append("elevation: .realistic") }
    switch config.style {
    case .standard:
        if config.muted { args.append("emphasis: .muted") }
        if config.hidePOIs { args.append("pointsOfInterest: .excludingAll") }
        return args.isEmpty ? nil : ".standard(\(args.joined(separator: ", ")))"
    case .imagery:
        return args.isEmpty ? ".imagery" : ".imagery(\(args.joined(separator: ", ")))"
    case .hybrid:
        if config.hidePOIs { args.append("pointsOfInterest: .excludingAll") }
        return args.isEmpty ? ".hybrid" : ".hybrid(\(args.joined(separator: ", ")))"
    }
}

// MARK: - Demo

/// A custom pin for `Annotation`.
private struct LandmarkPin: View {
    let landmark: Landmark

    var body: some View {
        Image(systemName: landmark.symbol)
            .font(.callout.weight(.semibold))
            .foregroundStyle(.white)
            .padding(8)
            .background(.orange.gradient, in: .circle)
            .overlay { Circle().strokeBorder(.white, lineWidth: 2) }
            .shadow(radius: 3, y: 2)
    }
}

private struct MapPreview: View {
    let config: MapConfig
    @State private var position: MapCameraPosition

    init(config: MapConfig) {
        self.config = config
        _position = State(initialValue: .camera(cameraFor(config)))
    }

    var body: some View {
        Map(position: $position) {
            ForEach(config.city.landmarks) { landmark in
                switch config.pins {
                case .none:
                    EmptyMapContent()
                case .marker:
                    Marker(landmark.name, systemImage: landmark.symbol, coordinate: landmark.coordinate)
                        .tint(.orange)
                case .annotation:
                    Annotation(landmark.name, coordinate: landmark.coordinate) {
                        LandmarkPin(landmark: landmark)
                    }
                }
            }
        }
        .mapStyle(resolvedMapStyle(config))
        .mapControls {
            if config.showsControls {
                MapCompass()
                MapScaleView()
                MapPitchToggle()
            }
        }
        .onChange(of: config.city) { updateCamera() }
        .onChange(of: config.pitch) { updateCamera() }
        .onChange(of: config.heading) { updateCamera() }
    }

    private func updateCamera() {
        withAnimation(.smooth(duration: 0.8)) {
            position = .camera(cameraFor(config))
        }
    }
}

private struct MapDemo: View {
    let page: ComponentPage

    var body: some View {
        DemoPage(
            page: page,
            initial: MapConfig(),
            previewHeight: 340,
            usage: """
            @State private var position: MapCameraPosition = .automatic

            let bridge = CLLocationCoordinate2D(latitude: 37.8199, longitude: -122.4783)

            Map(position: $position) {
                Marker("Golden Gate Bridge", systemImage: "road.lanes", coordinate: bridge)
                    .tint(.orange)
            }
            .mapStyle(.standard(elevation: .realistic))
            """,
            usageNote: Aside(.important, "Add `import MapKit`. Older tutorials use `Map(coordinateRegion:)`, which is deprecated since iOS 17.")
        ) { $config in
            MapPreview(config: config)
                .frame(height: 340)
                .clipShape(.rect(cornerRadius: 16))
                .padding(-8)
        } controls: { $config in
            Section("Place") {
                OptionPicker("City", selection: $config.city)
                OptionPicker("Pins", selection: $config.pins)
            }
            Section("Style") {
                OptionPicker("Style", selection: $config.style)
                Toggle("Realistic 3D elevation", isOn: $config.realistic)
                if config.style == .standard {
                    Toggle("Muted colors", isOn: $config.muted)
                }
                if config.style != .imagery {
                    Toggle("Hide points of interest", isOn: $config.hidePOIs)
                }
                Toggle("Map controls", isOn: $config.showsControls)
            }
            Section {
                ValueSlider("Pitch", value: $config.pitch, in: 0...70, step: 5)
                ValueSlider("Heading", value: $config.heading, in: 0...355, step: 5)
            } header: {
                Text("Camera")
            } footer: {
                Text("Pitch tilts the map; heading rotates it (0 is north). MapKit limits tilt when zoomed far out, so pitch looks subtle at city scale.")
            }
        } code: { config in
            code(config)
        } examples: {
            SelectionExample()
            RouteExample()
            StaticMapExample()
        }
    }

    private func code(_ config: MapConfig) -> String {
        let c = config.city.center
        var lines = [
            "import MapKit",
            "",
            "@State private var position: MapCameraPosition = .camera(",
            "    MapCamera(",
            "        centerCoordinate: CLLocationCoordinate2D(latitude: \(c.latitude), longitude: \(c.longitude)),",
            "        distance: \(Int(config.city.distance)), heading: \(swiftNumber(config.heading)), pitch: \(swiftNumber(config.pitch))",
            "    )",
            ")",
            "",
        ]
        if config.pins == .none {
            lines.append("Map(position: $position)")
        } else {
            lines.append("Map(position: $position) {")
            for landmark in config.city.landmarks {
                let coordinate = "CLLocationCoordinate2D(latitude: \(landmark.latitude), longitude: \(landmark.longitude))"
                if config.pins == .marker {
                    lines.append("    Marker(\(swiftString(landmark.name)), systemImage: \"\(landmark.symbol)\",")
                    lines.append("           coordinate: \(coordinate))")
                    lines.append("        .tint(.orange)")
                } else {
                    lines.append("    Annotation(\(swiftString(landmark.name)), coordinate: \(coordinate)) {")
                    lines.append("        Image(systemName: \"\(landmark.symbol)\")")
                    lines.append("            .font(.callout.weight(.semibold))")
                    lines.append("            .foregroundStyle(.white)")
                    lines.append("            .padding(8)")
                    lines.append("            .background(.orange.gradient, in: .circle)")
                    lines.append("            .overlay { Circle().strokeBorder(.white, lineWidth: 2) }")
                    lines.append("            .shadow(radius: 3, y: 2)")
                    lines.append("    }")
                }
            }
            lines.append("}")
        }
        if let style = styleCode(config) {
            lines.append(".mapStyle(\(style))")
        }
        if config.showsControls {
            lines += [".mapControls {", "    MapCompass()", "    MapScaleView()", "    MapPitchToggle()", "}"]
        }
        lines.append(".frame(height: 340)")
        return lines.joined(separator: "\n")
    }
}

// MARK: - Examples

private struct SelectionExample: View {
    @State private var selection: String?
    @State private var position: MapCameraPosition = .camera(
        MapCamera(centerCoordinate: City.paris.center, distance: City.paris.distance)
    )

    var body: some View {
        ExampleCard(
            title: "Selectable markers",
            caption: "Pass a `selection` binding and `.tag` each marker. Tapping a pin selects and enlarges it.",
            code: """
            struct Landmark: Identifiable {
                let name: String
                let coordinate: CLLocationCoordinate2D
                var id: String { name }
            }

            let landmarks = [
                Landmark(name: "Eiffel Tower", coordinate: .init(latitude: 48.8584, longitude: 2.2945)),
                Landmark(name: "Louvre", coordinate: .init(latitude: 48.8606, longitude: 2.3376)),
                Landmark(name: "Notre-Dame", coordinate: .init(latitude: 48.8530, longitude: 2.3499)),
            ]

            @State private var selection: String?
            @State private var position: MapCameraPosition = .camera(
                MapCamera(centerCoordinate: .init(latitude: 48.857, longitude: 2.322), distance: 9000)
            )

            VStack {
                Map(position: $position, selection: $selection) {
                    ForEach(landmarks) { landmark in
                        Marker(landmark.name, coordinate: landmark.coordinate)
                            .tag(landmark.name)
                    }
                }
                .frame(height: 260)
                Text(selection ?? "Tap a pin")
                    .font(.headline)
            }
            """,
            minHeight: 300
        ) {
            VStack(spacing: 12) {
                Map(position: $position, selection: $selection) {
                    ForEach(City.paris.landmarks) { landmark in
                        Marker(landmark.name, coordinate: landmark.coordinate)
                            .tag(landmark.name)
                    }
                }
                .frame(height: 260)
                .clipShape(.rect(cornerRadius: 12))
                Text(selection ?? "Tap a pin")
                    .font(.headline)
                    .contentTransition(.opacity)
                    .animation(.snappy, value: selection)
            }
        }
    }
}

private struct RouteExample: View {
    private let route = [
        CLLocationCoordinate2D(latitude: 37.8199, longitude: -122.4783),
        CLLocationCoordinate2D(latitude: 37.8060, longitude: -122.4660),
        CLLocationCoordinate2D(latitude: 37.8029, longitude: -122.4484),
        CLLocationCoordinate2D(latitude: 37.8080, longitude: -122.4177),
    ]

    var body: some View {
        ExampleCard(
            title: "Draw a route",
            caption: "`MapPolyline` connects coordinates with a line, like a walking route between two flags.",
            code: """
            let route = [
                CLLocationCoordinate2D(latitude: 37.8199, longitude: -122.4783),
                CLLocationCoordinate2D(latitude: 37.8060, longitude: -122.4660),
                CLLocationCoordinate2D(latitude: 37.8029, longitude: -122.4484),
                CLLocationCoordinate2D(latitude: 37.8080, longitude: -122.4177),
            ]

            Map {
                MapPolyline(coordinates: route)
                    .stroke(.blue, style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round))
                Marker("Start", systemImage: "flag.fill", coordinate: route[0])
                    .tint(.green)
                Marker("End", systemImage: "flag.checkered", coordinate: route[route.count - 1])
                    .tint(.red)
            }
            .frame(height: 240)
            """,
            minHeight: 240,
            aside: Aside(.note, "For real driving directions, get a route from `MKDirections` and pass `MapPolyline(route.polyline)`.")
        ) {
            Map {
                MapPolyline(coordinates: route)
                    .stroke(.blue, style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round))
                Marker("Start", systemImage: "flag.fill", coordinate: route[0])
                    .tint(.green)
                Marker("End", systemImage: "flag.checkered", coordinate: route[route.count - 1])
                    .tint(.red)
            }
            .frame(height: 240)
            .clipShape(.rect(cornerRadius: 12))
        }
    }
}

private struct StaticMapExample: View {
    var body: some View {
        ExampleCard(
            title: "A small, non-interactive map",
            caption: "Pass `interactionModes: []` for an address preview, so the page scrolls past the map.",
            code: """
            let cafe = CLLocationCoordinate2D(latitude: 48.8606, longitude: 2.3376)

            Map(initialPosition: .camera(MapCamera(centerCoordinate: cafe, distance: 1200)),
                interactionModes: []) {
                Marker("Café", systemImage: "cup.and.saucer.fill", coordinate: cafe)
                    .tint(.brown)
            }
            .frame(height: 140)
            .clipShape(.rect(cornerRadius: 16))
            """,
            minHeight: 160,
            aside: Aside(.note, "People still expect a map to respond. Open a full map, or Apple Maps, when they tap it.")
        ) {
            let cafe = CLLocationCoordinate2D(latitude: 48.8606, longitude: 2.3376)
            Map(initialPosition: .camera(MapCamera(centerCoordinate: cafe, distance: 1200)),
                interactionModes: []) {
                Marker("Café", systemImage: "cup.and.saucer.fill", coordinate: cafe)
                    .tint(.brown)
            }
            .frame(height: 140)
            .frame(maxWidth: 360)
            .clipShape(.rect(cornerRadius: 16))
        }
    }
}

// MARK: - Guideline samples

private struct MapEmphasisSample: View {
    let isMuted: Bool

    var body: some View {
        Map(initialPosition: .camera(MapCamera(centerCoordinate: City.paris.center, distance: 9000)),
            interactionModes: []) {
            ForEach(City.paris.landmarks) { landmark in
                Marker(landmark.name, systemImage: landmark.symbol, coordinate: landmark.coordinate)
                    .tint(.orange)
            }
        }
        .mapStyle(.standard(emphasis: isMuted ? .muted : .automatic))
        .frame(width: 260, height: 150)
        .clipShape(.rect(cornerRadius: 12))
    }
}

// MARK: - Thumbnail

private struct MapThumbnail: View {
    var body: some View {
        let landmark = City.sanFrancisco.landmarks[0]
        Map(initialPosition: .camera(MapCamera(centerCoordinate: landmark.coordinate, distance: 6000)),
            interactionModes: []) {
            Marker(landmark.name, systemImage: landmark.symbol, coordinate: landmark.coordinate)
                .tint(.orange)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
