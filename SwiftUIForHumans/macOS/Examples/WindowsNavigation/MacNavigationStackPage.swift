import SwiftUI

extension ComponentPage {
    static let navigationStack = ComponentPage(
        id: "navigation-stack",
        title: "NavigationStack",
        summary: "Push views inside a window, with a Back button in the toolbar.",
        category: .navigation,
        symbol: "square.stack",
        availability: ["macOS 13.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/navigationstack",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/toolbars",
        aliases: [
            "push", "drill down", "back button", "NavigationLink", "navigationDestination",
            "NavigationPath", "path", "router", "routing", "react-router", "history", "NavigationView",
            "deep link",
        ],
        related: ["navigation-split-view", "toolbar", "state-binding", "opening-windows"],
        notes: [
            "**A link needs a destination for its type.** `NavigationLink(value:)` does nothing until a `navigationDestination(for:)` for that type is somewhere in the stack.",
            "**Save the path to restore it.** If every value is `Codable`, `NavigationPath.codable` gives you something to store and decode at the next launch.",
        ],
        about: "A `NavigationStack` shows a root view and pushes views on top of it when people click a `NavigationLink`. The Back button goes in the window's toolbar, and the root can't be popped.\n\nIn a window with a sidebar, put the stack in the detail column of a `NavigationSplitView`, so the sidebar stays put while the detail drills down.",
        composition: """
        NavigationStack(path:)
        └── List
            ├── NavigationLink(value:)
            └── .navigationDestination(for:)
        """,
        api: [
            APIItem("`NavigationStack { }`", "A stack that manages its own state."),
            APIItem("`NavigationLink(_:value:)`", "Pushes a value when clicked."),
            APIItem("`.navigationDestination(for:)`", "The view to show for each value type."),
            APIItem("`NavigationStack(path:)`", "A stack you read and change from code."),
            APIItem("`NavigationPath`", "A path that holds values of different types."),
            APIItem("`path.removeLast()`", "Goes back one level from code."),
            APIItem("`.navigationTitle(_:)`", "The title for each level."),
        ],
        guidelines: [
            Guideline(
                "Use the standard Back button.",
                "People know it from every other app. Use the system's symbol, not a text label that says Back.",
                good: "The system's back chevron.",
                bad: "A text button that says Back."
            ) {
                BackButtonSample(isStandard: true)
            } bad: {
                BackButtonSample(isStandard: false)
            },
            Guideline(
                "Give every level a short title.",
                "The title tells people where they are as they drill down. Aim for a word or two."
            ),
            Guideline(
                "Show levels side by side when there's room.",
                "On a wide window, a split view can show the list and the detail at once, so people don't have to go back and forth."
            ),
        ]
    ) {
        MacWindowFrame(title: "Yosemite", width: 180, height: 100) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Trails")
                    .font(.caption.bold())
                Text("Mist Trail · Half Dome")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    } content: { page in
        MacNavigationStackArticle(page: page)
    }
}

extension Catalog {
    /// A real stack, with the Back button in a real toolbar.
    static let navigationStackDemoWindow = DemoWindow(id: "navigation-stack-parks", title: "Parks", size: CGSize(width: 480, height: 360)) {
        ParksStackSample()
    }
}

// MARK: - Page

private struct MacNavigationStackArticle: View {
    let page: ComponentPage

    var body: some View {
        ArticlePage(page: page) {
            if let about = page.about {
                AboutSection(text: about)
            }
            OpenDemoWindowButton(id: "navigation-stack-parks", label: "Open the Parks Window")
                .controlSize(.large)

            SectionTitle("Usage")
                .id("code")
            CodeBlock(code: """
            let parks = ["Yosemite", "Zion", "Acadia"]

            NavigationStack {
                List(parks, id: \\.self) { park in
                    NavigationLink(park, value: park)
                }
                .navigationDestination(for: String.self) { park in
                    Text(park)
                        .navigationTitle(park)
                }
                .navigationTitle("Parks")
            }
            """)

            if let composition = page.composition {
                CompositionSection(tree: composition)
            }

            SectionTitle("Examples")
                .id("examples")
            ExampleCard(
                title: "Push with links and destinations",
                caption: "Each `NavigationLink` pushes a value, and `navigationDestination(for:)` says what to show for it. Click a park, then a trail.",
                code: """
                struct Park: Hashable {
                    let name: String
                    let trails: [String]
                }

                struct ParksView: View {
                    let parks = [
                        Park(name: "Yosemite", trails: ["Mist Trail", "Half Dome"]),
                        Park(name: "Zion", trails: ["Angels Landing", "The Narrows"]),
                    ]

                    var body: some View {
                        NavigationStack {
                            List(parks, id: \\.name) { park in
                                NavigationLink(park.name, value: park)
                            }
                            .navigationDestination(for: Park.self) { park in
                                List(park.trails, id: \\.self) { trail in
                                    NavigationLink(trail, value: trail)
                                }
                                .navigationTitle(park.name)
                            }
                            .navigationDestination(for: String.self) { trail in
                                Text(trail)
                                    .navigationTitle(trail)
                            }
                            .navigationTitle("Parks")
                        }
                    }
                }
                """,
                minHeight: 250,
                aside: Aside(.note, "A real stack in a page would put its Back button in this app's toolbar, so the preview draws the window. Open the Parks window for the real one.")
            ) {
                StackSketch()
            }

            ExampleCard(
                title: "Control the stack with a path",
                caption: "Bind `NavigationStack(path:)` to an array. Append to push, remove to go back, or empty it to return to the root.",
                code: """
                @State private var path: [String] = []

                NavigationStack(path: $path) {
                    List {
                        Button("Jump to Half Dome") {
                            path = ["Yosemite", "Half Dome"]
                        }
                    }
                    .navigationDestination(for: String.self) { name in
                        Button("Back to All Parks") {
                            path.removeAll()
                        }
                        .navigationTitle(name)
                    }
                    .navigationTitle("Parks")
                }
                """,
                minHeight: 250
            ) {
                StackSketch(showsPathControls: true)
            }

            SectionTitle("Different kinds of values")
            Prose("An array holds one type. To push parks and trails as different types onto one path, use `NavigationPath`, and add a `navigationDestination` for each type.")
            CodeBlock(code: """
            @State private var path = NavigationPath()

            NavigationStack(path: $path) {
                ParkList()
                    .navigationDestination(for: Park.self) { park in
                        ParkView(park: park)
                    }
                    .navigationDestination(for: Trail.self) { trail in
                        TrailView(trail: trail)
                    }
            }
            """)

            SectionTitle("In a split view")
            Prose("Put the stack in the detail column. Selecting in the sidebar replaces the stack's root, and links in the detail push onto it.")
            CodeBlock(code: """
            @State private var selectedPark: String?

            NavigationSplitView {
                List(["Yosemite", "Zion"], id: \\.self, selection: $selectedPark) { park in
                    Text(park)
                }
            } detail: {
                NavigationStack {
                    if let selectedPark {
                        List(["Trails", "Campgrounds"], id: \\.self) { section in
                            NavigationLink(section, value: section)
                        }
                        .navigationDestination(for: String.self) { section in
                            Text(section)
                        }
                        .navigationTitle(selectedPark)
                    }
                }
            }
            """)
        }
    }
}

// MARK: - Samples

private struct SketchPark: Identifiable, Hashable {
    let name: String
    let trails: [String]
    var id: String { name }

    static let all = [
        SketchPark(name: "Yosemite", trails: ["Mist Trail", "Half Dome"]),
        SketchPark(name: "Zion", trails: ["Angels Landing", "The Narrows"]),
        SketchPark(name: "Acadia", trails: ["Precipice Trail", "Jordan Pond"]),
    ]
}

/// A drawn window around a working stack: the path is an array of names,
/// and the toolbar's back chevron pops it.
private struct StackSketch: View {
    var showsPathControls = false
    @State private var path: [String] = []

    var body: some View {
        VStack(spacing: 12) {
            VStack(spacing: 0) {
                HStack(spacing: 12) {
                    WindowsNavWindowButtons()
                    Button {
                        path.removeLast()
                    } label: {
                        Label("Back", systemImage: "chevron.left")
                            .labelStyle(.iconOnly)
                            .imageScale(.large)
                    }
                    .buttonStyle(.borderless)
                    .disabled(path.isEmpty)
                    .help("Back")
                    Text(path.last ?? "Parks")
                        .font(.headline)
                    Spacer()
                }
                .padding(.horizontal, 14)
                .frame(height: 44)
                .background(.bar)
                Divider()
                level
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .id(path.count)
                    .transition(.push(from: .trailing))
            }
            .frame(width: 400, height: 200)
            .clipped()
            .windowsNavChrome()
            .animation(.snappy, value: path)

            if showsPathControls {
                HStack(spacing: 10) {
                    Button("Jump to Half Dome") {
                        path = ["Yosemite", "Half Dome"]
                    }
                    Button("Back to All Parks") {
                        path.removeAll()
                    }
                    .disabled(path.isEmpty)
                }
                Text("path = [\(path.map { "\"\($0)\"" }.joined(separator: ", "))]")
                    .font(.callout.monospaced())
                    .foregroundStyle(.secondary)
            }
        }
    }

    @ViewBuilder private var level: some View {
        if path.isEmpty {
            rows(SketchPark.all.map(\.name))
        } else if path.count == 1, let park = SketchPark.all.first(where: { $0.name == path[0] }) {
            rows(park.trails)
        } else {
            VStack(spacing: 6) {
                Image(systemName: "figure.hiking")
                    .font(.largeTitle)
                    .foregroundStyle(.tint)
                Text(path.last ?? "")
                    .font(.title3.bold())
            }
        }
    }

    private func rows(_ names: [String]) -> some View {
        VStack(spacing: 0) {
            ForEach(names, id: \.self) { name in
                Button {
                    path.append(name)
                } label: {
                    HStack {
                        Text(name)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .contentShape(.rect)
                }
                .buttonStyle(.plain)
                Divider()
                    .padding(.leading, 14)
            }
            Spacer(minLength: 0)
        }
        .padding(.top, 4)
    }
}

/// A toolbar with the standard back chevron, or with a text button.
private struct BackButtonSample: View {
    let isStandard: Bool

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                WindowsNavWindowButtons()
                if isStandard {
                    Image(systemName: "chevron.left")
                        .imageScale(.large)
                        .foregroundStyle(.secondary)
                } else {
                    Text("Back")
                        .font(.callout)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(.fill.tertiary, in: .capsule)
                }
                Text("Zion")
                    .font(.headline)
                Spacer()
            }
            .padding(.horizontal, 14)
            .frame(height: 44)
            .background(.bar)
            Divider()
            Color.clear
        }
        .frame(width: 230, height: 90)
        .windowsNavChrome()
    }
}

/// The demo window's real stack.
private struct ParksStackSample: View {
    var body: some View {
        NavigationStack {
            List(SketchPark.all) { park in
                NavigationLink(park.name, value: park)
            }
            .navigationDestination(for: SketchPark.self) { park in
                List(park.trails, id: \.self) { trail in
                    NavigationLink(trail, value: trail)
                }
                .navigationTitle(park.name)
            }
            .navigationDestination(for: String.self) { trail in
                VStack(spacing: 8) {
                    Image(systemName: "figure.hiking")
                        .font(.system(size: 44))
                        .foregroundStyle(.tint)
                    Text(trail)
                        .font(.title.bold())
                }
                .navigationTitle(trail)
            }
            .navigationTitle("Parks")
        }
    }
}
