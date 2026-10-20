import SwiftUI

extension ComponentPage {
    static let shipStatesCheck = ComponentPage(
        id: "states-check",
        title: "Empty, Loading & Error",
        summary: "Give every screen an empty, loading, and error state, and ship no placeholders.",
        category: .feelsNative,
        kind: .reference,
        symbol: "rectangle.dashed",
        availability: [],
        docsURL: "https://developer.apple.com/documentation/swiftui/contentunavailableview",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/loading",
        aliases: [
            "empty state", "loading state", "error state", "skeleton", "skeleton screen",
            "spinner", "placeholder", "lorem ipsum", "zero state", "offline", "retry",
            "app completeness", "Guideline 2.1",
        ],
        related: ["empty-state", "progress-view", "async-image", "submission-checklist", "rejection-guide"],
        notes: [
            "**Test with no network.** Turn on Airplane Mode and open every screen. Reviewers use real networks, and yours won't always be fast.",
            "**Test as a brand-new user.** A fresh account has no data, so every list starts empty. That's the first thing a reviewer with a demo account may see.",
        ],
        api: [
            APIItem("`ContentUnavailableView`", "Empty, no-results, and error screens."),
            APIItem("`.search(text:)`", "A ready-made “No Results” view."),
            APIItem("`ProgressView`", "A spinner or progress bar."),
            APIItem("`.redacted(reason:)`", "Turns content into a skeleton."),
            APIItem("`.task { }`", "Starts loading when the view appears."),
            APIItem("`.refreshable { }`", "Pull to refresh to try again."),
        ],
        guidelines: [
            Guideline(
                "Never ship placeholder content.",
                "Apple rejects apps with placeholder text or images under guideline 2.1. Search your project for “lorem” and “TODO” before you submit.",
                good: "Real content, even if there's little of it.",
                bad: "Lorem ipsum left in a shipping screen."
            ) {
                StatesPlaceholderSample(isFixed: true)
            } bad: {
                StatesPlaceholderSample(isFixed: false)
            },
            Guideline(
                "Show something right away.",
                "The HIG warns that a blank screen looks like a broken app. Show a skeleton or a spinner while content loads.",
                good: "A skeleton shows content is coming.",
                bad: "A blank screen looks broken."
            ) {
                StatesRows(names: StatesDemo.sampleNames)
                    .redacted(reason: .placeholder)
                    .frame(maxWidth: 260)
            } bad: {
                Color.clear
                    .frame(maxWidth: 260, maxHeight: 120)
            },
            Guideline(
                "Say what went wrong and what to do next.",
                "An error should explain the problem in plain words and offer a way out, like Try Again.",
                good: "A plain explanation and a retry button.",
                bad: "A raw error code and no way forward."
            ) {
                ContentUnavailableView {
                    Label("You're Offline", systemImage: "wifi.slash")
                } description: {
                    Text("Check your connection and try again.")
                } actions: {
                    Button("Try Again") {}
                        .buttonStyle(.bordered)
                }
            } bad: {
                Text("Error: NSURLErrorDomain -1009")
                    .font(.footnote.monospaced())
                    .foregroundStyle(.red)
            },
        ],
        sources: [
            "https://developer.apple.com/app-store/review/guidelines/#app-completeness",
            "https://developer.apple.com/distribute/app-review/",
            "https://developer.apple.com/design/human-interface-guidelines/loading",
            "https://developer.apple.com/documentation/swiftui/contentunavailableview",
        ],
        reviewed: "October 2026"
    ) {
        StatesThumbnail()
    } content: { page in
        StatesArticle(page: page)
    }
}

// MARK: - Thumbnail

private struct StatesThumbnail: View {
    var body: some View {
        HStack(spacing: 14) {
            ProgressView()
            Image(systemName: "tray")
                .font(.title2)
                .foregroundStyle(.secondary)
            Image(systemName: "wifi.slash")
                .font(.title2)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .background(.fill.tertiary, in: .rect(cornerRadius: 14))
    }
}

// MARK: - Page

private struct StatesArticle: View {
    let page: ComponentPage

    var body: some View {
        ArticlePage(page: page) {
            SectionTitle("What Apple requires")
            Prose("Guideline **2.1, App Completeness**, says to submit a final version: no placeholder text, empty websites, or other temporary content, and nothing that crashes or shows obvious technical problems. As of 2026, Apple says this guideline is behind over 40% of unresolved review issues.")

            SectionTitle("Why")
            Prose("Real data is messy. Lists are empty on day one, networks drop, and servers fail. A screen that only handles the happy path shows a blank page or a spinner forever, and people assume the app is broken.")

            SectionTitle("Try it")
            Prose("One screen, four states. Tap through them, or let it cycle.")
            StatesDemo()

            SectionTitle("How to do it")
            ExampleCard(
                title: "Model the states",
                caption: "Keep the screen's state in one `enum` and `switch` over it, so the compiler makes you handle every case.",
                code: """
                enum LoadState {
                    case loading
                    case loaded([String])
                    case failed
                }

                @State private var state = LoadState.loading

                var body: some View {
                    switch state {
                    case .loading:
                        ProgressView()
                    case .loaded(let names) where names.isEmpty:
                        ContentUnavailableView("No Friends Yet",
                            systemImage: "person.2",
                            description: Text("Invite someone to get started."))
                    case .loaded(let names):
                        List(names, id: \\.self) { Text($0) }
                    case .failed:
                        ContentUnavailableView("Couldn't Load Friends",
                            systemImage: "wifi.slash")
                    }
                }
                """,
                minHeight: 160,
                aside: Aside(.note, "Start loading in `.task { }` on the view. It starts before the view appears, and SwiftUI cancels it if the view goes away first.")
            ) {
                ContentUnavailableView(
                    "No Friends Yet",
                    systemImage: "person.2",
                    description: Text("Invite someone to get started.")
                )
            }

            ExampleCard(
                title: "A skeleton while loading",
                caption: "Add `.redacted(reason: .placeholder)` to sample rows so people see the layout before the data arrives.",
                code: """
                List(sampleNames, id: \\.self) { name in
                    Label(name, systemImage: "person.crop.circle")
                }
                .redacted(reason: isLoading ? .placeholder : [])
                """,
                minHeight: 160,
                aside: Aside(.important, "Redacted sample rows are fine while loading. Make sure they never stay on screen as the final content.")
            ) {
                StatesRows(names: StatesDemo.sampleNames)
                    .redacted(reason: .placeholder)
                    .frame(maxWidth: 300)
            }

            SectionTitle("Before you submit")
            Checklist(pageID: page.id, items: [
                ChecklistItem("placeholders", "No placeholder text or images",
                              "Search for “lorem”, “TODO”, and test images."),
                ChecklistItem("empty", "Every list has an empty state",
                              "Explain what goes there and how to add the first item.",
                              page: "empty-state"),
                ChecklistItem("loading", "Every load shows progress",
                              "A skeleton or spinner, never a blank screen.",
                              page: "progress-view"),
                ChecklistItem("errors", "Every error explains itself",
                              "Plain words and a way to try again."),
                ChecklistItem("offline", "The app works offline, or says why it can't",
                              "Open every screen in Airplane Mode."),
                ChecklistItem("links", "Every link and button goes somewhere",
                              "No dead links or “coming soon” screens."),
            ])
        }
    }
}

// MARK: - Live demo

private enum StatesDemoState: String, CaseIterable, Identifiable {
    case loading = "Loading"
    case loaded = "Loaded"
    case empty = "Empty"
    case failed = "Error"

    var id: Self { self }
}

private struct StatesDemo: View {
    static let sampleNames = ["Maya Chen", "Leo Okafor", "Sara Lind", "Tom Reyes"]

    @State private var state = StatesDemoState.loading
    @State private var isCycling = false

    var body: some View {
        VStack(spacing: 0) {
            PhoneScreen(width: 280, height: 300) {
                screen
                    .navigationTitle("Friends")
                    .animation(.smooth, value: state)
            }
            .padding(.vertical, 20)
            .frame(maxWidth: .infinity)
            .background(Surface.preview)

            Divider()

            VStack(spacing: 12) {
                Picker("State", selection: $state) {
                    ForEach(StatesDemoState.allCases) { state in
                        Text(state.rawValue).tag(state)
                    }
                }
                .pickerStyle(.segmented)
                Toggle("Cycle automatically", isOn: $isCycling)
            }
            .padding(16)
            .background(Surface.code)
        }
        .cardStyle()
        .task(id: isCycling) {
            while isCycling, !Task.isCancelled {
                try? await Task.sleep(for: .seconds(2))
                guard isCycling, !Task.isCancelled else { break }
                let all = StatesDemoState.allCases
                let next = (all.firstIndex(of: state).map { $0 + 1 } ?? 0) % all.count
                state = all[next]
            }
        }
    }

    @ViewBuilder
    private var screen: some View {
        switch state {
        case .loading:
            StatesRows(names: Self.sampleNames)
                .redacted(reason: .placeholder)
                .frame(maxHeight: .infinity, alignment: .top)
        case .loaded:
            StatesRows(names: Self.sampleNames)
                .frame(maxHeight: .infinity, alignment: .top)
        case .empty:
            ContentUnavailableView {
                Label("No Friends Yet", systemImage: "person.2")
            } description: {
                Text("Invite someone to get started.")
            } actions: {
                Button("Invite a Friend") {}
                    .buttonStyle(.borderedProminent)
            }
        case .failed:
            ContentUnavailableView {
                Label("You're Offline", systemImage: "wifi.slash")
            } description: {
                Text("Check your connection and try again.")
            } actions: {
                Button("Try Again") {
                    state = .loading
                }
                .buttonStyle(.bordered)
            }
        }
    }
}

private struct StatesRows: View {
    let names: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(names, id: \.self) { name in
                Label(name, systemImage: "person.crop.circle")
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                if name != names.last {
                    Divider()
                }
            }
        }
        .padding(.horizontal, 16)
    }
}

// MARK: - Do / Don't samples

private struct StatesPlaceholderSample: View {
    let isFixed: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(isFixed ? "Morning Run" : "Lorem Ipsum")
                .font(.headline)
            Text(isFixed ? "5.2 km along the river, 28 minutes." : "Dolor sit amet, consectetur adipiscing elit.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(14)
        .frame(maxWidth: 260, alignment: .leading)
        .background(.fill.tertiary, in: .rect(cornerRadius: 12))
    }
}
