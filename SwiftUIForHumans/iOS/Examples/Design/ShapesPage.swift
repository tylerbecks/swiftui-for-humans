import SwiftUI

extension ComponentPage {
    static let shapes = ComponentPage(
        id: "shapes",
        title: "Shapes",
        summary: "Rectangles, circles, capsules, and your own paths, ready to fill, stroke, or clip with.",
        category: .graphics,
        symbol: "square.on.circle",
        availability: ["iOS 13.0+", "macOS 10.15+", "visionOS 1.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/shape",
        aliases: ["border-radius", "rounded corners", "circle", "svg", "path", "pill", "div", "canvas", "draw", "UIBezierPath"],
        related: ["clip-shape", "gradients", "background-overlay", "frame"],
        notes: [
            "**Use shape shorthands wherever a shape is expected.** `.rect(cornerRadius: 12)`, `.capsule`, and `.circle` work in `.clipShape`, `.background(_:in:)`, and `.contentShape`.",
            "**Corners are continuous by default.** Rounded rectangles use Apple's smooth corner curve, which looks softer than CSS `border-radius`.",
        ],
        api: [
            APIItem("`RoundedRectangle(cornerRadius:)`", "A rectangle with rounded corners."),
            APIItem("`Circle()`, `Capsule()`", "A circle, and a pill with fully round ends."),
            APIItem("`.fill(_:)`", "Paints the inside with a color or gradient."),
            APIItem("`.strokeBorder(_:lineWidth:)`", "Draws an outline inside the edge."),
            APIItem("`.clipShape(_:)`", "Cuts any view to a shape."),
            APIItem("`.background(_:in:)`", "Puts a shape-filled background behind a view."),
            APIItem("`.trim(from:to:)`", "Draws only part of the outline, for rings."),
            APIItem("`Shape`", "Your own shape: return a `Path` from `path(in:)`."),
        ]
    ) {
        ShapesThumbnail()
    } content: { page in
        ShapesDemo(page: page)
    }
}

// MARK: - Options

private enum ShapeKind: DemoOption {
    case rectangle, roundedRectangle, circle, ellipse, capsule, unevenRounded, star

    var label: String {
        switch self {
        case .rectangle: "Rectangle"
        case .roundedRectangle: "RoundedRectangle"
        case .circle: "Circle"
        case .ellipse: "Ellipse"
        case .capsule: "Capsule"
        case .unevenRounded: "UnevenRoundedRectangle"
        case .star: "Custom (Star)"
        }
    }

    var usesRadius: Bool { self == .roundedRectangle || self == .unevenRounded }
}

private enum PaintKind: DemoOption {
    case fill, gradient, stroke, strokeBorder, dashed

    var label: String {
        switch self {
        case .fill: "Fill"
        case .gradient: "Gradient fill"
        case .stroke: "Stroke"
        case .strokeBorder: "Stroke border"
        case .dashed: "Dashed stroke"
        }
    }
}

private enum ShapeColor: DemoOption {
    case blue, purple, orange, green, primary

    var label: String {
        switch self {
        case .blue: ".blue"
        case .purple: ".purple"
        case .orange: ".orange"
        case .green: ".green"
        case .primary: ".primary"
        }
    }

    var color: Color {
        switch self {
        case .blue: .blue
        case .purple: .purple
        case .orange: .orange
        case .green: .green
        case .primary: .primary
        }
    }
}

private struct ShapesConfig {
    var kind: ShapeKind = .roundedRectangle
    var paint: PaintKind = .fill
    var color: ShapeColor = .blue
    var cornerRadius = 24.0
    var lineWidth = 6.0
    var points = 5.0
}

/// A star with any number of points. This is the "custom Shape" sample.
private struct Star: Shape {
    var points = 5
    var innerRatio = 0.45

    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outer = min(rect.width, rect.height) / 2
        let inner = outer * innerRatio
        var path = Path()
        for i in 0..<(points * 2) {
            let radius = i.isMultiple(of: 2) ? outer : inner
            let angle = Double(i) * .pi / Double(points) - .pi / 2
            let point = CGPoint(x: center.x + cos(angle) * radius, y: center.y + sin(angle) * radius)
            if i == 0 { path.move(to: point) } else { path.addLine(to: point) }
        }
        path.closeSubpath()
        return path
    }
}

private func anyShape(_ config: ShapesConfig) -> AnyShape {
    switch config.kind {
    case .rectangle: AnyShape(Rectangle())
    case .roundedRectangle: AnyShape(RoundedRectangle(cornerRadius: config.cornerRadius))
    case .circle: AnyShape(Circle())
    case .ellipse: AnyShape(Ellipse())
    case .capsule: AnyShape(Capsule())
    case .unevenRounded: AnyShape(UnevenRoundedRectangle(topLeadingRadius: config.cornerRadius, bottomTrailingRadius: config.cornerRadius))
    case .star: AnyShape(Star(points: Int(config.points)))
    }
}

private func shapeCode(_ config: ShapesConfig) -> String {
    let r = swiftNumber(config.cornerRadius)
    switch config.kind {
    case .rectangle: return "Rectangle()"
    case .roundedRectangle: return "RoundedRectangle(cornerRadius: \(r))"
    case .circle: return "Circle()"
    case .ellipse: return "Ellipse()"
    case .capsule: return "Capsule()"
    case .unevenRounded: return "UnevenRoundedRectangle(topLeadingRadius: \(r), bottomTrailingRadius: \(r))"
    case .star: return "Star(points: \(Int(config.points)))"
    }
}

private struct PaintedShape: View {
    let config: ShapesConfig

    var body: some View {
        let shape = anyShape(config)
        let color = config.color.color
        switch config.paint {
        case .fill:
            shape.fill(color)
        case .gradient:
            shape.fill(color.gradient)
        case .stroke:
            shape.stroke(color, lineWidth: config.lineWidth)
        case .strokeBorder:
            // strokeBorder needs an InsettableShape; the star isn't one, so inset by hand.
            if config.kind == .star {
                shape.stroke(color, lineWidth: config.lineWidth)
            } else {
                insettable.strokeBorder(color, lineWidth: config.lineWidth)
            }
        case .dashed:
            shape.stroke(color, style: StrokeStyle(lineWidth: config.lineWidth, lineCap: .round, dash: [config.lineWidth * 2, config.lineWidth * 1.5]))
        }
    }

    /// The same shape as an `InsettableShape`, for `strokeBorder`.
    private var insettable: some InsettableShape {
        switch config.kind {
        case .rectangle: AnyInsettableShape(Rectangle())
        case .roundedRectangle: AnyInsettableShape(RoundedRectangle(cornerRadius: config.cornerRadius))
        case .circle: AnyInsettableShape(Circle())
        case .ellipse: AnyInsettableShape(Ellipse())
        case .capsule: AnyInsettableShape(Capsule())
        case .unevenRounded: AnyInsettableShape(UnevenRoundedRectangle(topLeadingRadius: config.cornerRadius, bottomTrailingRadius: config.cornerRadius))
        case .star: AnyInsettableShape(Rectangle())
        }
    }
}

/// A small type-eraser for insettable shapes (SwiftUI's `AnyShape` isn't insettable).
private struct AnyInsettableShape: InsettableShape {
    private let base: @Sendable (CGRect) -> Path
    private let insetBy: @Sendable (CGFloat) -> AnyInsettableShape

    init<S: InsettableShape>(_ shape: S) {
        base = { shape.path(in: $0) }
        insetBy = { AnyInsettableShape(shape.inset(by: $0)) }
    }

    func path(in rect: CGRect) -> Path { base(rect) }
    func inset(by amount: CGFloat) -> AnyInsettableShape { insetBy(amount) }
}

// MARK: - Demo

private struct ShapesDemo: View {
    let page: ComponentPage

    var body: some View {
        DemoPage(
            page: page,
            initial: ShapesConfig(),
            usage: """
            RoundedRectangle(cornerRadius: 24)
                .fill(.blue)
                .frame(width: 240, height: 180)
            """,
            usageNote: Aside(.note, "A shape fills all the space it's offered, like a `div` at 100% width and height. Give it a size with `.frame`.")
        ) { $config in
            PaintedShape(config: config)
                .frame(width: config.kind == .circle || config.kind == .star ? 180 : 240, height: 180)
                .animation(.snappy, value: config.cornerRadius)
                .animation(.snappy, value: config.lineWidth)
        } controls: { $config in
            Section("Shape") {
                OptionPicker("Shape", selection: $config.kind)
                if config.kind.usesRadius {
                    ValueSlider("Corner radius", value: $config.cornerRadius, in: 0...90, step: 1)
                }
                if config.kind == .star {
                    ValueSlider("Points", value: $config.points, in: 3...12, step: 1)
                }
            }
            Section("Paint") {
                OptionPicker("Style", selection: $config.paint)
                OptionPicker("Color", selection: $config.color)
                if config.paint == .stroke || config.paint == .strokeBorder || config.paint == .dashed {
                    ValueSlider("Line width", value: $config.lineWidth, in: 1...30, step: 1)
                }
            }
        } code: { config in
            var lines: [String] = []
            if config.kind == .star {
                lines += [
                    "// A custom shape: describe its outline with a Path.",
                    "struct Star: Shape {",
                    "    var points = 5",
                    "",
                    "    func path(in rect: CGRect) -> Path {",
                    "        let center = CGPoint(x: rect.midX, y: rect.midY)",
                    "        let outer = min(rect.width, rect.height) / 2",
                    "        let inner = outer * 0.45",
                    "        var path = Path()",
                    "        for i in 0..<(points * 2) {",
                    "            let radius = i.isMultiple(of: 2) ? outer : inner",
                    "            let angle = Double(i) * .pi / Double(points) - .pi / 2",
                    "            let point = CGPoint(x: center.x + cos(angle) * radius,",
                    "                                y: center.y + sin(angle) * radius)",
                    "            if i == 0 { path.move(to: point) } else { path.addLine(to: point) }",
                    "        }",
                    "        path.closeSubpath()",
                    "        return path",
                    "    }",
                    "}",
                    "",
                ]
            }
            lines.append(shapeCode(config))
            let c = config.color.label
            let w = swiftNumber(config.lineWidth)
            switch config.paint {
            case .fill: lines.append("    .fill(\(c))")
            case .gradient: lines.append("    .fill(\(config.color == .primary ? "Color.primary" : "Color" + c).gradient)")
            case .stroke: lines.append("    .stroke(\(c), lineWidth: \(w))")
            case .strokeBorder:
                lines.append(config.kind == .star ? "    .stroke(\(c), lineWidth: \(w)) // custom shapes can't use strokeBorder" : "    .strokeBorder(\(c), lineWidth: \(w))")
            case .dashed:
                lines.append("    .stroke(\(c), style: StrokeStyle(lineWidth: \(w), lineCap: .round, dash: [\(swiftNumber(config.lineWidth * 2)), \(swiftNumber(config.lineWidth * 1.5))]))")
            }
            let isSquare = config.kind == .circle || config.kind == .star
            lines.append("    .frame(width: \(isSquare ? 180 : 240), height: 180)")
            return lines.joined(separator: "\n")
        } examples: {
            ExampleCard(
                title: "Shapes as backgrounds and clips",
                caption: "Usually a shape styles another view, through `.background(_:in:)`, `.clipShape`, or `.overlay`.",
                code: """
                HStack(spacing: 12) {
                    Text("Tag")
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.blue.opacity(0.15), in: .capsule)

                    Image(systemName: "person.fill")
                        .font(.title)
                        .frame(width: 56, height: 56)
                        .background(.orange.gradient)
                        .foregroundStyle(.white)
                        .clipShape(.circle)

                    Text("Card")
                        .padding()
                        .overlay {
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(.secondary, lineWidth: 1)
                        }
                }
                """,
                minHeight: 140,
                aside: Aside(.important, "Use `.strokeBorder` for borders. `.stroke` centers the line on the edge, so half of it spills outside and can get clipped.")
            ) {
                HStack(spacing: 12) {
                    Text("Tag")
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.blue.opacity(0.15), in: .capsule)

                    Image(systemName: "person.fill")
                        .font(.title)
                        .frame(width: 56, height: 56)
                        .background(.orange.gradient)
                        .foregroundStyle(.white)
                        .clipShape(.circle)

                    Text("Card")
                        .padding()
                        .overlay {
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(.secondary, lineWidth: 1)
                        }
                }
            }

            ProgressRingExample()

            ExampleCard(
                title: "Concentric corners",
                caption: "`ConcentricRectangle` takes its corner radius from its container, so nested corners line up.",
                code: """
                VStack {
                    Text("Inner content")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(.blue.opacity(0.2), in: ConcentricRectangle())
                }
                .padding(10)
                .frame(width: 240, height: 140)
                .background(.fill.tertiary)
                .containerShape(.rect(cornerRadius: 32))
                .clipShape(.rect(cornerRadius: 32))
                """,
                minHeight: 180,
                aside: Aside(.note, "`ConcentricRectangle` is new in iOS 26. Use it for buttons and cards inside sheets and other rounded containers.")
            ) {
                VStack {
                    Text("Inner content")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(.blue.opacity(0.2), in: ConcentricRectangle())
                }
                .padding(10)
                .frame(width: 240, height: 140)
                .background(.fill.tertiary)
                .containerShape(.rect(cornerRadius: 32))
                .clipShape(.rect(cornerRadius: 32))
            }
        }
    }
}

private struct ProgressRingExample: View {
    @State private var progress = 0.65

    var body: some View {
        ExampleCard(
            title: "Progress ring with trim",
            caption: "Use `.trim(from:to:)` to draw only part of a circle's outline, like a progress ring.",
            code: """
            @State private var progress = 0.65

            ZStack {
                Circle()
                    .stroke(.fill.tertiary, lineWidth: 14)
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(.green, style: StrokeStyle(lineWidth: 14, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                Text(progress, format: .percent.precision(.fractionLength(0)))
                    .font(.title2.bold())
            }
            .frame(width: 120, height: 120)
            """,
            minHeight: 220
        ) {
            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .stroke(.fill.tertiary, lineWidth: 14)
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(.green, style: StrokeStyle(lineWidth: 14, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                    Text(progress, format: .percent.precision(.fractionLength(0)))
                        .font(.title2.bold())
                        .monospacedDigit()
                        .contentTransition(.numericText())
                }
                .frame(width: 120, height: 120)
                Slider(value: $progress, in: 0...1)
                    .frame(maxWidth: 260)
                    .accessibilityLabel("Progress")
            }
        }
    }
}

// MARK: - Thumbnail

private struct ShapesThumbnail: View {
    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 12).fill(.blue.gradient).frame(width: 50, height: 50)
            Circle().fill(.orange.gradient).frame(width: 50, height: 50)
            VStack(spacing: 12) {
                Capsule().fill(.green.gradient).frame(width: 58, height: 24)
                Star().fill(.purple.gradient).frame(width: 46, height: 46)
            }
        }
    }
}
