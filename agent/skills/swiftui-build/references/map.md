---
id: map
title: Map
platforms: [iOS, iPadOS]
availability: iOS 17.0+, macOS 14.0+, visionOS 1.0+
docs: https://developer.apple.com/documentation/mapkit/map.md
hig: https://developer.apple.com/design/human-interface-guidelines/maps.md
---

# Map

An interactive Apple Map with markers, custom pins, styles, and a camera you control.

Also called: google maps, mapbox, leaflet, location, pin, marker, MKMapView, satellite, directions, geo.

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

- `Map` shows an interactive Apple Map.
- You put content inside it, like `Marker`, `Annotation`, and `MapPolyline`, and a camera position binding controls what part of the world it shows.
- It comes from MapKit and works like a SwiftUI view: size it with `.frame`, style it with `.mapStyle`, and add controls with `.mapControls`.

## Default code

```swift
@State private var position: MapCameraPosition = .automatic

let bridge = CLLocationCoordinate2D(latitude: 37.8199, longitude: -122.4783)

Map(position: $position) {
    Marker("Golden Gate Bridge", systemImage: "road.lanes", coordinate: bridge)
        .tint(.orange)
}
.mapStyle(.standard(elevation: .realistic))
```

**Important:** Add `import MapKit`. Older tutorials use `Map(coordinateRegion:)`, which is deprecated since iOS 17.

## Built from

Map(position: $position)
├── Marker / Annotation
├── MapPolyline
├── .mapStyle(.standard)
└── .mapControls
    └── MapCompass()

## Rules

- **Keep maps interactive.** People expect to pan and zoom any map. If a small map can't move, open a full map when they tap it.
- **Mute the map when your pins matter most.** The muted style drops the saturation, so your markers and overlays stand out.
- **Tint markers to match your app.** Use `.tint` and a symbol that fits the place, so pins feel part of your design and are easy to tell apart.
- **Don't cover the Apple logo and legal link for long.** They sit in the map's corner. Leave padding around them, and keep cards and controls from hiding them all the time.

## Pitfalls

- **Showing the person's location needs permission.** Add `NSLocationWhenInUseUsageDescription` to Info.plist, ask with `CLLocationManager`, then add `UserAnnotation()` to the map.
- **No API key needed.** Map tiles load over the network, so the map stays blank until they arrive.

## Key APIs

`Map(position:selection:)`, `MapCameraPosition`, `Marker(_:systemImage:coordinate:)`, `Annotation(_:coordinate:)`, `MapPolyline(coordinates:)`, `.mapStyle(_:)`, `.mapControls { }`, `UserAnnotation()`

## Variants

### Selectable markers

Pass a `selection` binding and `.tag` each marker. Tapping a pin selects and enlarges it.

```swift
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
```

### Draw a route

`MapPolyline` connects coordinates with a line, like a walking route between two flags.

```swift
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
```

**Note:** For real driving directions, get a route from `MKDirections` and pass `MapPolyline(route.polyline)`.

### A small, non-interactive map

Pass `interactionModes: []` for an address preview, so the page scrolls past the map.

```swift
let cafe = CLLocationCoordinate2D(latitude: 48.8606, longitude: 2.3376)

Map(initialPosition: .camera(MapCamera(centerCoordinate: cafe, distance: 1200)),
    interactionModes: []) {
    Marker("Café", systemImage: "cup.and.saucer.fill", coordinate: cafe)
        .tint(.brown)
}
.frame(height: 140)
.clipShape(.rect(cornerRadius: 16))
```

**Note:** People still expect a map to respond. Open a full map, or Apple Maps, when they tap it.

## Related

[sheet](sheet.md), [safe-area](safe-area.md), `sf-symbols` (apple-design skill), [charts](charts.md)
