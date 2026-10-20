import SwiftUI

extension ComponentPage {
    static let iPadAppInWindow = ComponentPage(
        id: "ipad-app-in-window",
        title: "Not an iPad App in a Window",
        summary: "The signs of a port that wasn't adapted to the Mac, and what to do instead.",
        category: .feelsNative,
        kind: .concept,
        symbol: "ipad.landscape.badge.play",
        availability: [],
        docsURL: "https://developer.apple.com/documentation/swiftui/navigationsplitview",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/mac-catalyst",
        aliases: [
            "port", "iPad port", "Catalyst app", "tab bar on Mac", "bottom toolbar", "page control",
            "page dots", "popover", "inspector", "sidebar", "fixed window size", "touch targets",
        ],
        related: ["native-vs-catalyst", "mac-native-checklist", "navigation-split-view", "toolbar", "inspector", "toggle"],
        notes: [
            "**Gestures still work, but they can't be the only way.** Taps become clicks and pinch still works on a trackpad, but many people use a mouse or the keyboard.",
            "**The Mac version needs its own icon.** Apple asks for a macOS version of your app icon, in the Mac's rendering style.",
        ],
        guidelines: [
            Guideline(
                "Swap the tab bar for a sidebar.",
                "A split view with a sidebar follows Mac conventions. Each tab becomes a sidebar row, and using a sidebar on iPad too keeps the layout familiar.",
                good: "Sections in a sidebar.",
                bad: "An iPad tab bar along the bottom."
            ) {
                PortWindow {
                    HStack(spacing: 0) {
                        VStack(alignment: .leading, spacing: 6) {
                            ForEach(PortSection.allCases) { section in
                                Label(section.title, systemImage: section.symbol)
                                    .font(.caption)
                                    .foregroundStyle(section == .upcoming ? .primary : .secondary)
                            }
                            Spacer()
                        }
                        .padding(10)
                        .frame(width: 92, alignment: .leading)
                        .background(.fill.quaternary)
                        PortContent()
                    }
                }
            } bad: {
                PortWindow {
                    VStack(spacing: 0) {
                        PortContent()
                        Divider()
                        HStack {
                            ForEach(PortSection.allCases) { section in
                                VStack(spacing: 2) {
                                    Image(systemName: section.symbol)
                                    Text(section.title)
                                        .font(.system(size: 9))
                                }
                                .foregroundStyle(section == .upcoming ? Color.accentColor : .secondary)
                                .frame(maxWidth: .infinity)
                            }
                        }
                        .padding(.vertical, 5)
                    }
                }
            },
            Guideline(
                "Move bottom-edge buttons to the toolbar.",
                "Buttons at the bottom of an iPad screen are easy to reach with a thumb. On a Mac, the most important actions belong at the top of the window.",
                good: "Add sits in the toolbar.",
                bad: "Add floats at the bottom edge."
            ) {
                PortWindow(toolbarSymbol: "plus") {
                    PortContent()
                }
            } bad: {
                PortWindow {
                    VStack(spacing: 0) {
                        PortContent()
                        Button("Add Trip", systemImage: "plus") {}
                            .buttonStyle(.borderedProminent)
                            .controlSize(.small)
                            .padding(8)
                    }
                }
            },
            Guideline(
                "Show details in an inspector, not a popover.",
                "There's room beside the content on a Mac, so details can sit next to it instead of covering it.",
                good: "Details in an inspector at the side.",
                bad: "Details in a popover over the list."
            ) {
                PortWindow {
                    HStack(spacing: 0) {
                        PortContent(selected: true)
                        Divider()
                        PortDetails()
                            .frame(width: 92)
                    }
                }
            } bad: {
                PortWindow {
                    PortContent(selected: true)
                        .overlay(alignment: .trailing) {
                            PortDetails()
                                .frame(width: 92)
                                .background(.background, in: .rect(cornerRadius: 8))
                                .overlay {
                                    RoundedRectangle(cornerRadius: 8)
                                        .strokeBorder(.separator)
                                }
                                .shadow(color: .black.opacity(0.3), radius: 8)
                                .padding(.trailing, 14)
                        }
                }
            },
            Guideline(
                "Give paged content Previous and Next buttons.",
                "Swiping between pages needs a trackpad. Buttons also work with a mouse and from the keyboard.",
                good: "Previous and Next buttons.",
                bad: "Only page dots to swipe through."
            ) {
                PortWindow {
                    PortPage {
                        HStack {
                            Button("Previous", systemImage: "chevron.left") {}
                            Button("Next", systemImage: "chevron.right") {}
                        }
                        .labelStyle(.iconOnly)
                        .controlSize(.small)
                    }
                }
            } bad: {
                PortWindow {
                    PortPage {
                        HStack(spacing: 5) {
                            ForEach(0..<4) { index in
                                Circle()
                                    .fill(index == 1 ? AnyShapeStyle(.primary) : AnyShapeStyle(.tertiary))
                                    .frame(width: 6, height: 6)
                            }
                        }
                        .frame(height: 20)
                    }
                }
            },
            Guideline(
                "Let windows resize.",
                "An iPad app that skips multitasking runs in a fixed-size window on the Mac. Build layouts that grow and shrink with the window."
            ),
            Guideline(
                "Fix text and artwork size.",
                "In Catalyst's iPad idiom, everything scales down to 77%. In the Mac idiom, text shows at full size and can look too big. Use text styles, not fixed font sizes."
            ),
        ],
        sources: [
            "https://developer.apple.com/design/human-interface-guidelines/mac-catalyst",
            "https://developer.apple.com/design/human-interface-guidelines/designing-for-macos",
            "https://developer.apple.com/design/human-interface-guidelines/windows",
            "https://developer.apple.com/documentation/apple-silicon/running-your-ios-apps-in-macos",
            "https://developer.apple.com/documentation/uikit/choosing-a-user-interface-idiom-for-your-mac-app",
            "https://developer.apple.com/documentation/swiftui/navigationsplitview",
        ],
        reviewed: "October 2026"
    ) {
        MacWindowFrame(title: "Trips", width: 190, height: 110) {
            VStack(spacing: 0) {
                Spacer()
                Divider()
                HStack {
                    ForEach(PortSection.allCases) { section in
                        Image(systemName: section.symbol)
                            .frame(maxWidth: .infinity)
                    }
                }
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.vertical, 5)
            }
        }
    } content: { page in
        MacIPadAppInWindowArticle(page: page)
    }
}

extension Catalog {
    /// The sidebar version of a tabbed iPad app, in a real window.
    static let shipSidebarDemoWindow = DemoWindow(id: "ship-sidebar", title: "Trips", size: CGSize(width: 640, height: 400)) {
        SidebarInsteadOfTabsSample()
    }
}

// MARK: - Page

private struct MacIPadAppInWindowArticle: View {
    let page: ComponentPage

    var body: some View {
        ArticlePage(page: page) {
            Prose("Whether you start from Mac Catalyst, run your iPad app as is, or rebuild in SwiftUI, the same habits from the iPad give a port away. Apple's advice for Catalyst apps applies to every Mac app: go beyond showing the iPad layout in a Mac window.")
            Prose("The pairs below show several of them. Each Do differs from its Don't in one thing.")

            SectionTitle("From tabs to a sidebar in SwiftUI")
            ExampleCard(
                title: "Replace a TabView with a split view",
                caption: "On the Mac, `NavigationSplitView` with a `List` in the sidebar does the job a tab bar does on iPad.",
                code: """
                enum TripSection: String, CaseIterable, Identifiable {
                    case upcoming, past, shared
                    var id: Self { self }
                }

                struct TripsView: View {
                    @State private var section: TripSection? = .upcoming

                    var body: some View {
                        NavigationSplitView {
                            List(TripSection.allCases, selection: $section) { section in
                                Label(section.rawValue.capitalized, systemImage: "suitcase")
                            }
                        } detail: {
                            Text(section?.rawValue.capitalized ?? "Choose a section")
                        }
                    }
                }
                """,
                minHeight: 220,
                aside: Aside(.note, "Also list the sections in the View menu, so people can switch with the keyboard. A real split view here would take over this window, so the preview is a drawing.")
            ) {
                VStack(spacing: 14) {
                    MacWindowFrame(title: "Trips", width: 420, height: 170) {
                        HStack(spacing: 0) {
                            VStack(alignment: .leading, spacing: 8) {
                                ForEach(PortSection.allCases) { section in
                                    Label(section.title, systemImage: section.symbol)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 3)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(section == .upcoming ? AnyShapeStyle(.fill.tertiary) : AnyShapeStyle(.clear), in: .rect(cornerRadius: 5))
                                }
                                Spacer()
                            }
                            .font(.callout)
                            .padding(10)
                            .frame(width: 140)
                            .background(.fill.quaternary)
                            Text("Upcoming")
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                    }
                    OpenDemoWindowButton(id: "ship-sidebar", label: "Open the Real Thing")
                }
            }
        }
    }
}

// MARK: - Drawings

private enum PortSection: String, CaseIterable, Identifiable {
    case upcoming, past, shared

    var id: Self { self }
    var title: String { rawValue.capitalized }

    var symbol: String {
        switch self {
        case .upcoming: "suitcase"
        case .past: "clock"
        case .shared: "person.2"
        }
    }
}

/// The small window every Do / Don't on this page uses, so pairs differ
/// only in what's inside.
private struct PortWindow<Content: View>: View {
    var toolbarSymbol: String? = nil
    @ViewBuilder let content: Content

    var body: some View {
        MacWindowFrame(title: "Trips", width: 250, height: 180) {
            content
        } toolbar: {
            if let toolbarSymbol {
                Image(systemName: toolbarSymbol)
            }
        }
    }
}

private struct PortContent: View {
    var selected = false

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(["Lisbon", "Kyoto", "Oslo"], id: \.self) { city in
                Text(city)
                    .font(.caption)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(selected && city == "Kyoto" ? AnyShapeStyle(Color.accentColor.opacity(0.25)) : AnyShapeStyle(.clear), in: .rect(cornerRadius: 4))
            }
            Spacer(minLength: 0)
        }
        .padding(10)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct PortDetails: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Kyoto")
                .font(.caption.bold())
            Text("Apr 3–9")
            Text("2 travelers")
        }
        .font(.caption2)
        .foregroundStyle(.secondary)
        .padding(8)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct PortPage<Controls: View>: View {
    @ViewBuilder let controls: Controls

    var body: some View {
        VStack(spacing: 6) {
            Spacer(minLength: 0)
            Image(systemName: "photo")
                .font(.title2)
                .foregroundStyle(.tertiary)
            Text("Page 2 of 4")
                .font(.caption)
                .foregroundStyle(.secondary)
            Spacer(minLength: 0)
            controls
                .padding(.bottom, 6)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Demo window

/// A real split view with a sidebar, opened in its own window.
private struct SidebarInsteadOfTabsSample: View {
    @State private var section: PortSection? = .upcoming

    var body: some View {
        NavigationSplitView {
            List(PortSection.allCases, selection: $section) { section in
                Label(section.title, systemImage: section.symbol)
            }
            .navigationSplitViewColumnWidth(min: 160, ideal: 180)
        } detail: {
            ContentUnavailableView(section?.title ?? "Choose a Section", systemImage: section?.symbol ?? "sidebar.left", description: Text("Each tab from the iPad app is a sidebar row here."))
        }
        .toolbar {
            Button("Add Trip", systemImage: "plus") {}
        }
    }
}
