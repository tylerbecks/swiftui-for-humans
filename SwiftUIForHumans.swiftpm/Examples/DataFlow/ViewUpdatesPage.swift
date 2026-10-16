import SwiftUI
import Observation

extension ComponentPage {
    static let viewUpdates = ComponentPage(
        id: "view-updates",
        title: "How Views Update",
        summary: "See which views run their body again when state changes, and why the rest don't.",
        category: .dataFlow,
        kind: .concept,
        symbol: "arrow.clockwise.circle",
        availability: ["iOS 17.0+", "macOS 14.0+", "visionOS 1.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/model-data",
        aliases: ["re-render", "rerender", "render cycle", "virtual DOM", "reconciliation", "diffing", "view not updating", "refresh", "setNeedsDisplay", "performance"],
        related: ["state", "observable", "choosing-wrappers", "lifecycle"],
        notes: [
            "**Running `body` isn't redrawing pixels.** SwiftUI compares the result with what's on screen and only touches what's different, much like React's reconciliation.",
            "**Small views keep updates small.** A child's `body` reruns only when its inputs or the state it reads change, so split big views into parts.",
        ]
    ) {
        ViewUpdatesThumbnail()
    } content: { page in
        ViewUpdatesArticle(page: page)
    }
}

// MARK: - Thumbnail

private struct ViewUpdatesThumbnail: View {
    var body: some View {
        VStack(spacing: 8) {
            ViewUpdatesThumbBox(title: "Parent", lit: true)
            HStack(spacing: 8) {
                ViewUpdatesThumbBox(title: "Count", lit: true)
                ViewUpdatesThumbBox(title: "Name", lit: false)
                ViewUpdatesThumbBox(title: "Badge", lit: false)
            }
        }
        .frame(width: 220)
    }
}

private struct ViewUpdatesThumbBox: View {
    let title: String
    let lit: Bool

    var body: some View {
        VStack(spacing: 2) {
            Text(title)
                .font(.caption.weight(.semibold))
            Text(lit ? "body ×2" : "body ×1")
                .font(.caption2.monospaced())
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(.fill.tertiary, in: .rect(cornerRadius: 10))
        .overlay {
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(lit ? Color.yellow : Color.clear, lineWidth: 2.5)
        }
    }
}

// MARK: - Redraw flash

private final class ViewUpdatesRenderCounter {
    var count = 0

    func next() -> Int {
        count += 1
        return count
    }
}

/// A box that flashes yellow whenever the view that owns it runs `body`, and
/// shows how many times that has happened.
private struct ViewUpdatesBox<Content: View>: View {
    let title: String
    let renders: Int
    var tint: Color = .gray
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Text(title)
                    .font(.caption.weight(.semibold))
                    .lineLimit(1)
                Spacer(minLength: 4)
                Text("×\(renders)")
                    .font(.caption2.monospaced())
                    .foregroundStyle(.secondary)
                    .contentTransition(.numericText())
                    .animation(.snappy, value: renders)
            }
            content
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(tint.opacity(0.1), in: .rect(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(.yellow, lineWidth: 3)
                .keyframeAnimator(initialValue: 0.0, trigger: renders) { view, opacity in
                    view.opacity(opacity)
                } keyframes: { _ in
                    LinearKeyframe(1.0, duration: 0.05)
                    LinearKeyframe(0.0, duration: 0.9, timingCurve: .easeOut)
                }
                .allowsHitTesting(false)
        }
    }
}

// MARK: - Article

private struct ViewUpdatesArticle: View {
    let page: ComponentPage

    var body: some View {
        ArticlePage(page: page) {
            Prose("A SwiftUI view is a lightweight description, not a thing on screen. When state changes, SwiftUI calls `body` again on the views that depend on it, compares the new description with the old one, and updates only what's different.")

            ViewUpdatesSteps()

            Aside(.important, "Keep `body` fast and free of side effects: no network calls and no changing state. SwiftUI may call it at any time, so start work from a button, `.task`, or `.onChange`.")

            ExampleCard(
                title: "Values flow down",
                caption: "Each box flashes yellow and counts when its `body` runs; a child reruns only when its input changes.",
                code: """
                struct Parent: View {
                    @State private var count = 0
                    @State private var name = "Taylor"

                    var body: some View {
                        VStack {
                            HStack {
                                Button("count + 1") { count += 1 }
                                Button("Rename") { name = name == "Taylor" ? "Sam" : "Taylor" }
                            }
                            CountView(count: count)
                            NameView(name: name)
                            Badge()
                        }
                    }
                }

                struct CountView: View {
                    let count: Int
                    var body: some View { Text("count = \\(count)") }
                }

                struct NameView: View {
                    let name: String
                    var body: some View { Text("name = \\(name)") }
                }

                struct Badge: View {
                    var body: some View { Image(systemName: "star.fill") }
                }
                """,
                minHeight: 300,
                aside: Aside(.note, "The parent reads both values, so it reruns every time. `Badge` takes no inputs, so it never does.")
            ) {
                ViewUpdatesValueDemo()
            }
            .id("values")

            ExampleCard(
                title: "@Observable tracks what you read",
                caption: "Move the values into an `@Observable` model, and only the view that reads a changed property reruns.",
                code: """
                @Observable
                class Model {
                    var count = 0
                    var name = "Taylor"
                }

                struct Parent: View {
                    @State private var model = Model()

                    var body: some View {
                        VStack {
                            HStack {
                                Button("count + 1") { model.count += 1 }
                                Button("Rename") { model.name = model.name == "Taylor" ? "Sam" : "Taylor" }
                            }
                            CountView(model: model) // Reads model.count
                            NameView(model: model)  // Reads model.name
                        }
                    }
                }

                struct CountView: View {
                    let model: Model
                    var body: some View { Text("count = \\(model.count)") }
                }

                struct NameView: View {
                    let model: Model
                    var body: some View { Text("name = \\(model.name)") }
                }
                """,
                minHeight: 260,
                aside: Aside(.note, "The parent passes the model along but never reads `count` or `name` in `body`, so now even the parent stays still.")
            ) {
                ViewUpdatesObservableDemo()
            }
            .id("observable-demo")

            SectionTitle("Debugging updates")
            Prose("When a view updates more than you expect, add `let _ = Self._printChanges()` as the first line of its `body`. Xcode's console then prints what caused each update, such as `Parent: _count changed.`")
        }
    }
}

// MARK: - Steps

private struct ViewUpdatesSteps: View {
    private let steps = [
        ("hand.tap", "Something happens", "A tap, a timer, or data arrives."),
        ("square.and.pencil", "State changes", "`count += 1` writes to `@State`."),
        ("magnifyingglass", "SwiftUI finds dependents", "Views that read `count` are marked."),
        ("arrow.clockwise", "body runs again", "Only for those views, top down."),
        ("rectangle.on.rectangle", "Screen updates", "Only the differences are drawn."),
    ]

    @State private var active: Int?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("One update, step by step")
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Button(active == nil ? "Play" : "Playing", systemImage: "play.fill") {
                    Task { await play() }
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
                .disabled(active != nil)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)

            Divider()

            VStack(alignment: .leading, spacing: 14) {
                ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                    HStack(spacing: 12) {
                        Image(systemName: step.0)
                            .font(.body.weight(.semibold))
                            .frame(width: 36, height: 36)
                            .foregroundStyle(active == index ? Color.white : Color.accentColor)
                            .background(active == index ? AnyShapeStyle(Color.accentColor) : AnyShapeStyle(Color.accentColor.opacity(0.12)), in: .circle)
                            .scaleEffect(active == index ? 1.12 : 1)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("\(index + 1). \(step.1)")
                                .font(.subheadline.weight(.semibold))
                            RichText(step.2)
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .opacity(active == nil || active == index ? 1 : 0.45)
                }
            }
            .padding(16)
        }
        .cardStyle()
        .animation(.snappy, value: active)
    }

    private func play() async {
        for index in steps.indices {
            active = index
            try? await Task.sleep(for: .milliseconds(750))
        }
        active = nil
    }
}

// MARK: - Demo 1: values

/// Counts body runs per view. Children get it as a plain reference, which
/// SwiftUI compares by identity, so it never causes an update by itself.
@MainActor
private final class ViewUpdatesTally {
    private var counts: [String: Int] = [:]

    func tick(_ key: String) -> Int {
        counts[key, default: 0] += 1
        return counts[key, default: 0]
    }
}

private struct ViewUpdatesValueDemo: View {
    @State private var count = 0
    @State private var name = "Taylor"
    @State private var tally = ViewUpdatesTally()

    var body: some View {
        let renders = tally.tick("Parent")
        ViewUpdatesBox(title: "Parent", renders: renders, tint: .blue) {
            VStack(spacing: 8) {
                HStack {
                    Button("count + 1") { count += 1 }
                    Button("Rename") { name = name == "Taylor" ? "Sam" : "Taylor" }
                }
                .buttonStyle(.bordered)
                .frame(maxWidth: .infinity)
                ViewUpdatesCountView(count: count, tally: tally)
                ViewUpdatesNameView(name: name, tally: tally)
                ViewUpdatesBadge(tally: tally)
            }
        }
        .frame(maxWidth: 320)
    }
}

private struct ViewUpdatesCountView: View {
    let count: Int
    let tally: ViewUpdatesTally

    var body: some View {
        let renders = tally.tick("CountView")
        ViewUpdatesBox(title: "CountView", renders: renders, tint: .green) {
            Text("count = \(count)")
                .font(.footnote.monospaced())
        }
    }
}

private struct ViewUpdatesNameView: View {
    let name: String
    let tally: ViewUpdatesTally

    var body: some View {
        let renders = tally.tick("NameView")
        ViewUpdatesBox(title: "NameView", renders: renders, tint: .purple) {
            Text("name = \"\(name)\"")
                .font(.footnote.monospaced())
        }
    }
}

private struct ViewUpdatesBadge: View {
    let tally: ViewUpdatesTally

    var body: some View {
        let renders = tally.tick("Badge")
        ViewUpdatesBox(title: "Badge", renders: renders, tint: .orange) {
            Image(systemName: "star.fill")
                .foregroundStyle(.orange)
        }
    }
}

// MARK: - Demo 2: @Observable

@Observable
private final class ViewUpdatesModel {
    var count = 0
    var name = "Taylor"
}

private struct ViewUpdatesObservableDemo: View {
    @State private var model = ViewUpdatesModel()
    @State private var counter = ViewUpdatesRenderCounter()

    var body: some View {
        let renders = counter.next()
        ViewUpdatesBox(title: "Parent", renders: renders, tint: .blue) {
            VStack(spacing: 8) {
                HStack {
                    Button("count + 1") { model.count += 1 }
                    Button("Rename") { model.name = model.name == "Taylor" ? "Sam" : "Taylor" }
                }
                .buttonStyle(.bordered)
                .frame(maxWidth: .infinity)
                ViewUpdatesModelCountView(model: model)
                ViewUpdatesModelNameView(model: model)
            }
        }
        .frame(maxWidth: 320)
    }
}

private struct ViewUpdatesModelCountView: View {
    let model: ViewUpdatesModel
    @State private var counter = ViewUpdatesRenderCounter()

    var body: some View {
        let renders = counter.next()
        ViewUpdatesBox(title: "CountView", renders: renders, tint: .green) {
            Text("count = \(model.count)")
                .font(.footnote.monospaced())
        }
    }
}

private struct ViewUpdatesModelNameView: View {
    let model: ViewUpdatesModel
    @State private var counter = ViewUpdatesRenderCounter()

    var body: some View {
        let renders = counter.next()
        ViewUpdatesBox(title: "NameView", renders: renders, tint: .purple) {
            Text("name = \"\(model.name)\"")
                .font(.footnote.monospaced())
        }
    }
}
