import SwiftUI

extension ComponentPage {
    static let tabView = ComponentPage(
        id: "tab-view",
        title: "TabView",
        summary: "Switches between top-level sections with a tab bar, or swipes through pages like a carousel.",
        category: .lists,
        symbol: "rectangle.split.3x1",
        availability: ["iOS 13.0+", "macOS 10.15+", "visionOS 1.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/tabview",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/tab-bars",
        aliases: ["tab bar", "tabs", "bottom navigation", "UITabBarController", "carousel", "pager", "swiper", "page control", "onboarding pages", "bottom nav"],
        related: ["navigation-stack", "navigation-split-view", "onboarding", "toolbar"],
        notes: [
            "**Prefer `Tab` over `.tabItem`.** The `Tab` type (iOS 18) supports search tabs, sections, and sidebars. The older `.tabItem` modifier still works but can't do those.",
            "**The tab bar floats as Liquid Glass.** `.tabBarMinimizeBehavior(.onScrollDown)` shrinks it while people scroll, and `.tabViewBottomAccessory` adds a bar above it, like Music's mini player.",
        ],
        about: """
        `TabView` owns the app's top-level sections and the tab bar that switches between them. Each tab keeps its own state, so people can leave a tab and come back to the same place.

        Use it for three to five main areas, like Home, Search, and Profile. With `.tabViewStyle(.page)`, the same view becomes a swipeable carousel.
        """,
        composition: """
        TabView(selection:)
        ├── Tab("Home")
        │   └── NavigationStack
        │       └── Root view
        ├── Tab("Inbox")
        │   └── NavigationStack
        └── Tab(role: .search)
        """,
        api: [
            APIItem("`Tab(_:systemImage:content:)`", "One tab with a label and an SF Symbol."),
            APIItem("`TabView(selection:)`", "Binds the current tab, so you can switch in code."),
            APIItem("`.badge(_:)`", "A red count on a tab."),
            APIItem("`Tab(role: .search)`", "A separate search tab at the trailing end."),
            APIItem("`TabSection(_:content:)`", "Groups tabs in the iPad sidebar."),
            APIItem("`.tabViewStyle(_:)`", "`.sidebarAdaptable` for iPad, or `.page` for a carousel."),
            APIItem("`.tabBarMinimizeBehavior(_:)`", "Shrinks the tab bar while people scroll."),
            APIItem("`.tabViewBottomAccessory { }`", "A bar above the tabs, like a mini player."),
        ],
        guidelines: [
            Guideline(
                "Use tabs to navigate, not to act.",
                "A tab switches sections. An action like New Post belongs in a toolbar button, where people expect to find it.",
                good: "Every tab opens a section.",
                bad: "An action hides among the sections."
            ) {
                TabGuidelineSample(tabs: [("Home", "house"), ("Search", "magnifyingglass"), ("Profile", "person.crop.circle")])
            } bad: {
                TabGuidelineSample(tabs: [("Home", "house"), ("New Post", "plus.square"), ("Profile", "person.crop.circle")])
            },
            Guideline(
                "Label tabs with one word.",
                "Short labels fit on every iPhone and are quick to read. Pair each with a filled SF Symbol.",
                good: "One word per tab.",
                bad: "Long labels crowd the bar."
            ) {
                TabGuidelineSample(tabs: [("Home", "house"), ("Inbox", "tray"), ("Profile", "person.crop.circle")])
            } bad: {
                TabGuidelineSample(tabs: [("My Home Feed", "house"), ("All Messages", "tray"), ("Account Settings", "person.crop.circle")])
            },
            Guideline(
                "Keep the tab bar visible.",
                "Hiding it makes people forget where they are. Only a sheet or full-screen cover should cover it."
            ),
            Guideline(
                "Use five tabs or fewer on iPhone.",
                "Extra tabs end up behind a More tab, where people rarely find them. Offer a sidebar with `.sidebarAdaptable` for bigger apps."
            ),
            Guideline(
                "Save badges for things that need attention.",
                "A badge on every tab turns into noise. Use one for unread messages, not for marketing."
            ),
        ]
    ) {
        TabThumbnail()
    } content: { page in
        TabDemo(page: page)
    }
}

private struct TabConfig {
    var style: TabStyleOption = .tabBar
    var badge = true
    var searchTab = false
    var minimize = false
    var accessory = false
    var indexDisplay: TabIndexDisplay = .automatic
    var selection = 0
}

private struct TabDemo: View {
    let page: ComponentPage

    var body: some View {
        DemoPage(
            page: page,
            initial: TabConfig(),
            previewHeight: 640,
            usage: """
            TabView {
                Tab("Home", systemImage: "house") {
                    NavigationStack {
                        Text("Home")
                            .navigationTitle("Home")
                    }
                }
                Tab("Profile", systemImage: "person.crop.circle") {
                    Text("Profile")
                }
            }
            """,
            usageNote: Aside(.important, "Put a `NavigationStack` inside each tab, not one around the `TabView`, so every tab keeps its own back history.")
        ) { $config in
            switch config.style {
            case .tabBar:
                TabFullScreenPreview(caption: "Switch tabs. Turn on Minimize on scroll in the controls, then scroll Home.") {
                    TabScreen(config: $config, inPhoneFrame: true)
                } screen: {
                    TabScreen(config: $config, inPhoneFrame: false)
                }
                .id("phone")
            case .page:
                VStack(spacing: 10) {
                    TabScreen(config: $config, inPhoneFrame: false)
                        .frame(maxWidth: 360)
                        .frame(height: 230)
                    Text("selection = \(config.selection)")
                        .font(.footnote.monospaced())
                        .foregroundStyle(.secondary)
                }
            }
        } controls: { $config in
            Section("Style") {
                OptionPicker("Style", selection: $config.style)
            }
            if config.style == .tabBar {
                Section {
                    Toggle("Badge on Inbox", isOn: $config.badge)
                    Toggle("Search tab", isOn: $config.searchTab)
                    Toggle("Minimize on scroll", isOn: $config.minimize)
                    Toggle("Bottom accessory", isOn: $config.accessory)
                } header: {
                    Text("Tab bar")
                } footer: {
                    Text("Scroll the Home list to see the tab bar minimize.")
                }
            } else {
                Section("Pages") {
                    OptionPicker("Index dots", selection: $config.indexDisplay)
                }
            }
        } code: { config in
            config.style == .tabBar ? tabBarCode(config) : pageCode(config)
        } examples: {
            TabExamples()
        }
    }

    private func tabBarCode(_ config: TabConfig) -> String {
        var lines = [
            "@State private var selection = 0",
            "",
            "TabView(selection: $selection) {",
            "    Tab(\"Home\", systemImage: \"house\", value: 0) {",
            "        NavigationStack {",
            "            List(1...30, id: \\.self) { Text(\"Item \\($0)\") }",
            "                .navigationTitle(\"Home\")",
            "        }",
            "    }",
            "    Tab(\"Inbox\", systemImage: \"tray\", value: 1) {",
            "        Text(\"Inbox\")",
            "    }",
        ]
        if config.badge {
            lines.append("    .badge(3)")
        }
        lines += [
            "    Tab(\"Profile\", systemImage: \"person.crop.circle\", value: 2) {",
            "        Text(\"Profile\")",
            "    }",
        ]
        if config.searchTab {
            lines += [
                "    Tab(value: 3, role: .search) {",
                "        Text(\"Search\")",
                "    }",
            ]
        }
        lines.append("}")
        if config.minimize {
            lines.append(".tabBarMinimizeBehavior(.onScrollDown)")
        }
        if config.accessory {
            lines += [
                ".tabViewBottomAccessory {",
                "    Label(\"Now Playing\", systemImage: \"music.note\")",
                "}",
            ]
        }
        return lines.joined(separator: "\n")
    }

    private func pageCode(_ config: TabConfig) -> String {
        let style = config.indexDisplay == .automatic ? ".page" : ".page(indexDisplayMode: \(config.indexDisplay.label))"
        return """
        @State private var selection = 0

        TabView(selection: $selection) {
            ForEach(0..<3, id: \\.self) { index in
                RoundedRectangle(cornerRadius: 24)
                    .fill([Color.blue, .purple, .orange][index].gradient)
                    .overlay {
                        Text("Page \\(index + 1)")
                            .font(.title.bold())
                            .foregroundStyle(.white)
                    }
                    .padding(24)
                    .tag(index)
            }
        }
        .tabViewStyle(\(style))
        """
    }
}

private struct TabScreen: View {
    @Binding var config: TabConfig
    /// Inside the phone frame a NavigationStack has no bar of its own, so
    /// Home draws its large title as a list header instead.
    let inPhoneFrame: Bool

    var body: some View {
        switch config.style {
        case .tabBar:
            tabBar
                .id("tabs-\(config.searchTab)")
        case .page:
            pages
        }
    }

    @ViewBuilder
    private var tabBar: some View {
        let tabs = TabView(selection: $config.selection) {
            Tab("Home", systemImage: "house", value: 0) {
                if inPhoneFrame {
                    List {
                        Section {
                            ForEach(1...30, id: \.self) { Text("Item \($0)") }
                        } header: {
                            Text("Home")
                                .font(.largeTitle.bold())
                                .foregroundStyle(Color.primary)
                                .textCase(nil)
                                .padding(.top, 24)
                        }
                    }
                } else {
                    NavigationStack {
                        List(1...30, id: \.self) { Text("Item \($0)") }
                            .navigationTitle("Home")
                    }
                }
            }
            Tab("Inbox", systemImage: "tray", value: 1) {
                Text("Inbox")
            }
            .badge(config.badge ? 3 : 0)
            Tab("Profile", systemImage: "person.crop.circle", value: 2) {
                Text("Profile")
            }
            if config.searchTab {
                Tab(value: 3, role: .search) {
                    Text("Search")
                }
            }
        }
        .tabBarMinimizeBehavior(config.minimize ? .onScrollDown : .automatic)

        if config.accessory {
            tabs.tabViewBottomAccessory {
                Label("Now Playing", systemImage: "music.note")
            }
        } else {
            tabs
        }
    }

    private var pages: some View {
        TabView(selection: $config.selection) {
            ForEach(0..<3, id: \.self) { index in
                RoundedRectangle(cornerRadius: 24)
                    .fill([Color.blue, .purple, .orange][index].gradient)
                    .overlay {
                        Text("Page \(index + 1)")
                            .font(.title.bold())
                            .foregroundStyle(.white)
                    }
                    .padding(24)
                    .tag(index)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: config.indexDisplay.mode))
    }
}

private struct TabThumbnail: View {
    var body: some View {
        HStack(spacing: 22) {
            ForEach(Array(zip(["house.fill", "tray", "person.crop.circle"], ["Home", "Inbox", "Profile"])), id: \.0) { symbol, title in
                VStack(spacing: 3) {
                    Image(systemName: symbol)
                        .font(.title3)
                        .overlay(alignment: .topTrailing) {
                            if title == "Inbox" {
                                Text("3")
                                    .font(.caption2.bold())
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 5)
                                    .background(.red, in: .capsule)
                                    .offset(x: 9, y: -6)
                            }
                        }
                    Text(title)
                        .font(.caption2.weight(.medium))
                }
                .foregroundStyle(title == "Home" ? AnyShapeStyle(.tint) : AnyShapeStyle(.primary))
            }
        }
        .padding(.horizontal, 22)
        .padding(.vertical, 10)
        .glassEffect(.regular, in: .capsule)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            LinearGradient(colors: [.blue.opacity(0.35), .purple.opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }
}

// MARK: - Examples

private struct TabExamples: View {
    var body: some View {
        ExampleCard(
            title: "A stack in every tab",
            caption: "Give each `Tab` its own `NavigationStack`, so pushing in one tab doesn't affect the others.",
            code: """
            TabView {
                Tab("Inbox", systemImage: "tray") {
                    NavigationStack {
                        List(["Lunch on Friday?", "Your order shipped"], id: \\.self) { subject in
                            NavigationLink(subject) { Text(subject) }
                        }
                        .navigationTitle("Inbox")
                    }
                }
                .badge(2)
                Tab("Settings", systemImage: "gear") {
                    NavigationStack {
                        List {
                            NavigationLink("Notifications") { Text("Notifications") }
                        }
                        .navigationTitle("Settings")
                    }
                }
            }
            """,
            minHeight: 440,
            aside: Aside(.note, "Push a message in Inbox, switch to Settings and back: Inbox is still on the message.")
        ) {
            TabFullScreenPreview(height: 360, caption: "Open it full screen to push inside each tab.") {
                TabStacksExample(inPhoneFrame: true)
            } screen: {
                TabStacksExample(inPhoneFrame: false)
            }
        }

        ExampleCard(
            title: "Image carousel",
            caption: "Use `.tabViewStyle(.page)` with a fixed height for a swipeable gallery anywhere on a screen.",
            code: """
            TabView {
                ForEach(["mountain.2.fill", "water.waves", "sun.horizon.fill"], id: \\.self) { symbol in
                    Image(systemName: symbol)
                        .font(.system(size: 56))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(.teal.gradient)
                        .foregroundStyle(.white)
                }
            }
            .tabViewStyle(.page)
            .indexViewStyle(.page(backgroundDisplayMode: .always))
            .frame(height: 200)
            .clipShape(.rect(cornerRadius: 20))
            """,
            minHeight: 220,
            aside: Aside(.note, "`.indexViewStyle(.page(backgroundDisplayMode: .always))` puts a backdrop behind the dots so they show on light images.")
        ) {
            TabView {
                ForEach(["mountain.2.fill", "water.waves", "sun.horizon.fill"], id: \.self) { symbol in
                    Image(systemName: symbol)
                        .font(.system(size: 56))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(.teal.gradient)
                        .foregroundStyle(.white)
                }
            }
            .tabViewStyle(.page)
            .indexViewStyle(.page(backgroundDisplayMode: .always))
            .frame(height: 200)
            .clipShape(.rect(cornerRadius: 20))
        }

        ExampleCard(
            title: "Sidebar on iPad",
            caption: "Use `.tabViewStyle(.sidebarAdaptable)` and `TabSection` to let iPad users turn the tabs into a sidebar.",
            code: """
            TabView {
                Tab("Listen Now", systemImage: "play.circle") {
                    Text("Listen Now")
                }
                TabSection("Library") {
                    Tab("Artists", systemImage: "music.mic") {
                        Text("Artists")
                    }
                    Tab("Albums", systemImage: "square.stack") {
                        Text("Albums")
                    }
                }
            }
            .tabViewStyle(.sidebarAdaptable)
            """,
            minHeight: 440
        ) {
            TabFullScreenPreview(height: 360, caption: "On iPhone it's a tab bar. Open it full screen on iPad and tap the sidebar button to switch to a sidebar.") {
                TabSidebarExample()
            } screen: {
                TabSidebarExample()
            }
        }
    }
}

private struct TabStacksExample: View {
    /// Inside the phone frame a NavigationStack has no bar of its own, so
    /// the rows only show the root screens there.
    let inPhoneFrame: Bool

    var body: some View {
        TabView {
            Tab("Inbox", systemImage: "tray") {
                screen("Inbox") {
                    ForEach(["Lunch on Friday?", "Your order shipped"], id: \.self) { subject in
                        NavigationLink(subject) { Text(subject) }
                    }
                }
            }
            .badge(2)
            Tab("Settings", systemImage: "gear") {
                screen("Settings") {
                    NavigationLink("Notifications") { Text("Notifications") }
                }
            }
        }
    }

    @ViewBuilder
    private func screen<Rows: View>(_ title: String, @ViewBuilder rows: () -> Rows) -> some View {
        if inPhoneFrame {
            List {
                Section {
                    rows().disabled(true)
                } header: {
                    Text(title)
                        .font(.largeTitle.bold())
                        .foregroundStyle(Color.primary)
                        .textCase(nil)
                        .padding(.top, 24)
                }
            }
        } else {
            NavigationStack {
                List { rows() }
                    .navigationTitle(title)
            }
        }
    }
}

/// A small tab app for the tab guidelines.
private struct TabGuidelineSample: View {
    let tabs: [(String, String)]

    var body: some View {
        PhoneScreen(hasNavigationBar: false, width: 270, height: 150) {
            TabView {
                ForEach(tabs, id: \.0) { title, symbol in
                    Tab(title, systemImage: symbol) {
                        Color.clear
                    }
                }
            }
        }
    }
}

// MARK: - Options

private enum TabStyleOption: DemoOption {
    case tabBar, page

    var label: String {
        switch self {
        case .tabBar: "Tab bar"
        case .page: ".page (carousel)"
        }
    }
}

private enum TabIndexDisplay: DemoOption {
    case automatic, always, never

    var label: String {
        switch self {
        case .automatic: ".automatic"
        case .always: ".always"
        case .never: ".never"
        }
    }

    var mode: PageTabViewStyle.IndexDisplayMode {
        switch self {
        case .automatic: .automatic
        case .always: .always
        case .never: .never
        }
    }
}

// MARK: - Full-screen preview

private struct TabSidebarExample: View {
    var body: some View {
        TabView {
            Tab("Listen Now", systemImage: "play.circle") {
                Text("Listen Now")
            }
            TabSection("Library") {
                Tab("Artists", systemImage: "music.mic") {
                    Text("Artists")
                }
                Tab("Albums", systemImage: "square.stack") {
                    Text("Albums")
                }
            }
        }
        .tabViewStyle(.sidebarAdaptable)
    }
}

/// Shows a tab app live inside a phone frame, with a button to open it full
/// screen, where it gets the whole window and the device's real size class.
private struct TabFullScreenPreview<Inline: View, Screen: View>: View {
    var height: CGFloat = 560
    let caption: String
    @ViewBuilder let inline: () -> Inline
    @ViewBuilder let screen: () -> Screen
    @State private var isPresented = false

    var body: some View {
        VStack(spacing: 14) {
            PhoneScreen(hasNavigationBar: false, height: height) {
                inline()
            }
            Button("Try It Full Screen", systemImage: "arrow.up.left.and.arrow.down.right") {
                isPresented = true
            }
            .buttonStyle(.borderedProminent)
            Text(caption)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 300)
                .fixedSize(horizontal: false, vertical: true)
        }
        .fullScreenCover(isPresented: $isPresented) {
            screen()
                .overlay(alignment: .topTrailing) {
                    Button("Close Demo", systemImage: "xmark") {
                        isPresented = false
                    }
                    .labelStyle(.iconOnly)
                    .buttonStyle(.glass)
                    .buttonBorderShape(.circle)
                    .controlSize(.large)
                    .padding(.trailing, 16)
                }
        }
    }
}