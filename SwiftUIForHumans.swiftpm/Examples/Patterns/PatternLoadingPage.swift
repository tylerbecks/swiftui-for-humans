import SwiftUI

extension ComponentPage {
    static let patternLoading = ComponentPage(
        id: "loading",
        title: "Loading",
        summary: "Show something right away, then swap in the content, an empty state, or an error.",
        category: .patterns,
        kind: .concept,
        symbol: "hourglass",
        availability: ["iOS 17.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/view/redacted(reason:)",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/loading",
        aliases: ["loading state", "skeleton", "skeleton screen", "shimmer", "spinner", "activity indicator", "placeholder", "Suspense", "useEffect fetch", "fetch data", "async", "redacted", "pull to refresh", "error state", "retry"],
        related: ["progress-view", "empty-state", "async-image", "lifecycle", "launching", "feedback"],
        notes: [
            "**It's a skeleton screen, built in.** `.redacted(reason: .placeholder)` turns your real layout into gray shapes, so you don't build a second, fake version of the screen.",
            "**`.task` is `useEffect` with cleanup for free.** It starts before the view appears and SwiftUI cancels it when the view goes away.",
            "**Refresh on your own, too.** Pull to refresh with `.refreshable` is welcome, but people expect content to update without having to ask every time.",
        ],
        api: [
            APIItem("`.task { }`", "Runs async work as the view appears."),
            APIItem("`.task(id:) { }`", "Cancels and restarts the work when `id` changes."),
            APIItem("`.redacted(reason: .placeholder)`", "Draws views as gray placeholders."),
            APIItem("`ProgressView(value:total:)`", "A bar that fills as work completes."),
            APIItem("`ProgressView()`", "A spinner, for work of unknown length."),
            APIItem("`ContentUnavailableView`", "Empty and error states with an action."),
            APIItem("`.refreshable { }`", "Adds pull to refresh to a `List`."),
        ],
        guidelines: [
            Guideline(
                "Show something right away.",
                "A blank screen looks broken. Draw the layout with placeholders and fill it in as data arrives.",
                good: "Placeholders show what's coming.",
                bad: "A blank screen looks like a bug."
            ) {
                LoadingMiniList(isPlaceholder: true)
            } bad: {
                LoadingMiniList(isPlaceholder: true, isBlank: true)
            },
            Guideline(
                "Say how long, and what's happening.",
                "When you know the size of the work, use a bar instead of a spinner, and label it with what's happening. A plain “Loading” tells people nothing.",
                good: "A bar with a specific label.",
                bad: "A spinner that says “Loading”."
            ) {
                ProgressView(value: 5, total: 12) {
                    Text("Downloading photos")
                } currentValueLabel: {
                    Text("5 of 12")
                }
                .frame(maxWidth: 220)
            } bad: {
                ProgressView("Loading…")
            },
            Guideline(
                "Let people keep going while they wait.",
                "Load in the background and keep the rest of the app usable. If stopping is safe, offer a Cancel button."
            ),
            Guideline(
                "Keep progress moving, and stay on one style.",
                "A frozen bar reads as a frozen app, so explain any stall. Don't morph a spinner into a bar; they're different shapes."
            ),
        ],
        sources: [
            "https://developer.apple.com/design/human-interface-guidelines/loading",
            "https://developer.apple.com/design/human-interface-guidelines/progress-indicators",
            "https://developer.apple.com/documentation/swiftui/view/task(id:name:priority:file:line:_:)",
            "https://developer.apple.com/documentation/swiftui/view/redacted(reason:)",
            "https://developer.apple.com/documentation/swiftui/redactionreasons/placeholder",
            "https://developer.apple.com/documentation/swiftui/contentunavailableview",
            "https://developer.apple.com/documentation/swiftui/view/refreshable(action:)",
        ],
        reviewed: "October 2026"
    ) {
        LoadingThumbnail()
    } content: { page in
        LoadingArticle(page: page)
    }
}

// MARK: - Article

private struct LoadingArticle: View {
    let page: ComponentPage

    var body: some View {
        ArticlePage(page: page) {
            Prose("Every screen that fetches data has four states: loading, loaded, empty, and failed. Plan all four up front. Show the layout right away with placeholders, then swap in the content, an empty message, or an error with a way to try again.")

            VStack(alignment: .leading, spacing: 12) {
                SectionTitle("Try it")
                Prose("Tap **Reload** to watch the screen load, or pick a state to see each one.")
                LoadingStatesDemo()
                Aside(.important, "SwiftUI cancels `.task` when the view disappears, and a fetch that respects cancellation then throws. Check `Task.isCancelled` before you show an error, or people see “Couldn't load” for a screen they just left.")
            }
            .id("playground")

            VStack(alignment: .leading, spacing: 28) {
                SectionTitle("In SwiftUI")
                ExampleCard(
                    title: "Placeholders",
                    caption: "Add `.redacted(reason: .placeholder)` to real rows with sample data to get a skeleton of the screen.",
                    code: """
                    @State private var isLoading = true

                    VStack(alignment: .leading, spacing: 12) {
                        Label("Coffee beans, 1 kg", systemImage: "bag")
                        Label("Oat milk, 6 pack", systemImage: "bag")
                        Label("Paper filters", systemImage: "bag")
                    }
                    .redacted(reason: isLoading ? .placeholder : [])

                    Toggle("Loading", isOn: $isLoading)
                    """
                ) {
                    RedactedExample()
                }

                ExampleCard(
                    title: "Progress you can measure",
                    caption: "Use `ProgressView(value:total:)` with a label when you know how much work is left.",
                    code: """
                    @State private var done = 0

                    ProgressView(value: Double(done), total: 12) {
                        Text("Downloading photos")
                    } currentValueLabel: {
                        Text("\\(done) of 12")
                    }
                    .task {
                        while done < 12 {
                            do { try await Task.sleep(for: .seconds(0.4)) } catch { return }
                            done += 1
                        }
                    }
                    """,
                    aside: Aside(.note, "Pace the bar evenly. Jumping to 90% and then sitting there for minutes feels like the app is stuck.")
                ) {
                    DeterminateExample()
                }
            }
        }
    }
}

// MARK: - Try it

private enum LoadPhase: String, CaseIterable, Identifiable {
    case loading = "Loading"
    case loaded = "Loaded"
    case empty = "Empty"
    case failed = "Failed"
    var id: Self { self }
}

private struct LoadingStatesDemo: View {
    @State private var phase: LoadPhase = .loading
    @State private var reloads = 0

    private let orders = ["Coffee beans", "Oat milk", "Paper filters", "Ceramic mug"]

    var body: some View {
        VStack(spacing: 0) {
            PreviewCard(minHeight: 300, isAttached: true) {
                VStack(spacing: 16) {
                    Group {
                        switch phase {
                        case .loading:
                            rows(orders).redacted(reason: .placeholder)
                        case .loaded:
                            rows(orders)
                        case .empty:
                            ContentUnavailableView(
                                "No Orders",
                                systemImage: "bag",
                                description: Text("Orders you place appear here.")
                            )
                        case .failed:
                            ContentUnavailableView {
                                Label("Couldn't Load Orders", systemImage: "wifi.exclamationmark")
                            } description: {
                                Text("Check your connection and try again.")
                            } actions: {
                                Button("Try Again") { reloads += 1 }
                                    .buttonStyle(.bordered)
                            }
                        }
                    }
                    .frame(maxWidth: 340, minHeight: 230)
                    .animation(.default, value: phase)

                    HStack {
                        Picker("State", selection: $phase) {
                            ForEach(LoadPhase.allCases) { Text($0.rawValue).tag($0) }
                        }
                        .pickerStyle(.segmented)
                        Button("Reload", systemImage: "arrow.clockwise") { reloads += 1 }
                            .labelStyle(.iconOnly)
                            .buttonStyle(.bordered)
                    }
                    .frame(maxWidth: 340)
                }
            }
            Divider()
            CodeBlock(code: Self.code, isCollapsible: true, isAttached: true)
        }
        .cardStyle()
        // Restarts whenever Reload is tapped, like `.task(id:)` in an app.
        .task(id: reloads) {
            phase = .loading
            do { try await Task.sleep(for: .seconds(1.5)) } catch { return }
            phase = .loaded
        }
    }

    private func rows(_ items: [String]) -> some View {
        VStack(spacing: 0) {
            ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                if index > 0 { Divider().padding(.leading, 52) }
                HStack(spacing: 12) {
                    Image(systemName: "bag.fill")
                        .foregroundStyle(.white)
                        .frame(width: 32, height: 32)
                        .background(.orange, in: .rect(cornerRadius: 8))
                    VStack(alignment: .leading) {
                        Text(item).font(.body)
                        Text("Arrives Friday").font(.footnote).foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
            }
        }
        .background(.background.secondary, in: .rect(cornerRadius: 12))
    }

    static let code = """
    enum LoadState<Value> {
        case loading
        case loaded(Value)
        case failed(Error)
    }

    struct OrdersView: View {
        @State private var state: LoadState<[String]> = .loading

        var body: some View {
            Group {
                switch state {
                case .loading:
                    List(0..<4, id: \\.self) { _ in
                        Text("Placeholder order")
                    }
                    .redacted(reason: .placeholder)
                case .loaded(let orders) where orders.isEmpty:
                    ContentUnavailableView(
                        "No Orders",
                        systemImage: "bag",
                        description: Text("Orders you place appear here.")
                    )
                case .loaded(let orders):
                    List(orders, id: \\.self) { Text($0) }
                case .failed:
                    ContentUnavailableView {
                        Label("Couldn't Load Orders", systemImage: "wifi.exclamationmark")
                    } description: {
                        Text("Check your connection and try again.")
                    } actions: {
                        Button("Try Again") { Task { await load() } }
                    }
                }
            }
            .task { await load() }
        }

        func load() async {
            state = .loading
            do {
                state = .loaded(try await fetchOrders())
            } catch {
                // If the view went away, there's nothing to show.
                if !Task.isCancelled { state = .failed(error) }
            }
        }

        func fetchOrders() async throws -> [String] {
            try await Task.sleep(for: .seconds(1))
            return ["Coffee beans", "Oat milk"]
        }
    }
    """
}

// MARK: - Examples

private struct RedactedExample: View {
    @State private var isLoading = true

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 12) {
                Label("Coffee beans, 1 kg", systemImage: "bag")
                Label("Oat milk, 6 pack", systemImage: "bag")
                Label("Paper filters", systemImage: "bag")
            }
            .redacted(reason: isLoading ? .placeholder : [])
            .animation(.default, value: isLoading)

            Toggle("Loading", isOn: $isLoading)
        }
        .frame(maxWidth: 280)
    }
}

private struct DeterminateExample: View {
    @State private var done = 0
    @State private var run = 0

    var body: some View {
        VStack(spacing: 16) {
            ProgressView(value: Double(done), total: 12) {
                Text("Downloading photos")
            } currentValueLabel: {
                Text("\(done) of 12")
            }
            .frame(maxWidth: 280)
            Button("Restart", systemImage: "arrow.clockwise") { run += 1 }
                .buttonStyle(.bordered)
                .disabled(done < 12)
        }
        .task(id: run) {
            done = 0
            while done < 12 {
                do { try await Task.sleep(for: .seconds(0.4)) } catch { return }
                done += 1
            }
        }
    }
}

// MARK: - Do / Don't

private struct LoadingMiniList: View {
    var isPlaceholder: Bool
    var isBlank = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Orders").font(.headline)
            if isBlank {
                Color.clear.frame(height: 96)
            } else {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(["Coffee beans", "Oat milk", "Paper filters"], id: \.self) { item in
                        HStack(spacing: 10) {
                            RoundedRectangle(cornerRadius: 6).fill(.orange).frame(width: 24, height: 24)
                            Text(item).font(.subheadline)
                        }
                    }
                }
                .redacted(reason: isPlaceholder ? .placeholder : [])
            }
        }
        .frame(width: 200, alignment: .leading)
    }
}

// MARK: - Thumbnail

private struct LoadingThumbnail: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(0..<3, id: \.self) { _ in
                HStack(spacing: 10) {
                    RoundedRectangle(cornerRadius: 6).frame(width: 26, height: 26)
                    Text("Placeholder text row")
                }
            }
        }
        .redacted(reason: .placeholder)
        .overlay(alignment: .center) {
            ProgressView()
                .controlSize(.large)
                .padding(12)
                .background(.regularMaterial, in: .rect(cornerRadius: 12))
        }
    }
}
