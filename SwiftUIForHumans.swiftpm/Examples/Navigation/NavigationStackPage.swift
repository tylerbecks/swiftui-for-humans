import SwiftUI

extension ComponentPage {
    static let navigationStack = ComponentPage(
        id: "navigation-stack",
        title: "NavigationStack",
        summary: "Pushes screens on top of each other with a back button, like drilling into a folder.",
        category: .lists,
        symbol: "square.stack",
        availability: ["iOS 16.0+", "macOS 13.0+", "visionOS 1.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/navigationstack",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/navigation-and-search",
        aliases: ["router", "routing", "push", "back button", "react router", "UINavigationController", "drill down", "navigation bar", "NavigationView", "page navigation"],
        related: ["navigation-split-view", "list", "toolbar", "tab-view"],
        notes: [
            "**Navigate in code with a path.** Bind the stack to an array: append to push, `removeLast()` to go back, and set it to `[]` to pop to the root. A deep link is just a path.",
            "**Use one stack per tab, and never nest them.** A `NavigationStack` inside another one leads to double bars and links that don't work.",
            "**`NavigationView` is deprecated.** Use `NavigationStack`, or `NavigationSplitView` for a sidebar.",
        ],
        about: """
        `NavigationStack` owns a stack of screens and the navigation bar above them. Each push slides a new screen in with a Back button, and the stack remembers the way back.

        Use it for drill-down hierarchies like Settings or Mail. For a sidebar on iPad, use `NavigationSplitView`. For top-level sections, put one stack in each tab of a `TabView`.
        """,
        composition: """
        NavigationStack
        └── Root view (a List)
            ├── NavigationLink(value:)
            ├── .navigationTitle
            ├── .toolbar
            └── .navigationDestination
                └── Destination view
        """,
        api: [
            APIItem("`NavigationStack(path:)`", "Binds the stack to an array, so you can push, pop, and deep link in code."),
            APIItem("`NavigationLink(_:value:)`", "A row that pushes the screen registered for its value's type."),
            APIItem("`.navigationDestination(for:)`", "Maps a value type to the screen it opens, like a route table."),
            APIItem("`.navigationDestination(item:)`", "Pushes when an optional is set, and pops when it goes back to `nil`."),
            APIItem("`.navigationTitle(_:)`", "The screen's title in the bar."),
            APIItem("`.navigationBarTitleDisplayMode(_:)`", "`.large`, `.inline`, or `.automatic`."),
            APIItem("`.toolbar { }`", "Buttons and menus in the navigation bar."),
        ],
        guidelines: [
            Guideline(
                "Keep titles short.",
                "Aim for a word or two, under 15 characters, so the bar has room for buttons. Don't use your app's name as a title; it doesn't tell people where they are.",
                good: "A short title names the screen.",
                bad: "The app name, plus extra words, gets cut off."
            ) {
                StackTitleSample(title: "Inbox")
            } bad: {
                StackTitleSample(title: "MyMail – All Messages and Folders")
            },
            Guideline(
                "Use a large title at the top of a hierarchy.",
                "It tells people where they are, and it shrinks into the bar as they scroll. Pushed screens usually use `.inline`."
            ),
            Guideline(
                "Keep the standard Back button.",
                "People know it retraces their steps. Don't replace it with a custom “Back” label or hide it unless the screen offers another way out."
            ),
            Guideline(
                "Put only the most important actions in the bar.",
                "iPhone has room for a few. Move the rest into a More menu with `Menu` in the toolbar."
            ),
        ]
    ) {
        StackThumbnail()
    } content: { page in
        NavigationStackDemo(page: page)
    }
}

private let stackFruits = ["Apple", "Banana", "Cherry", "Kiwi", "Lemon"]

private struct StackConfig {
    var titleMode: StackTitleMode = .large
    var links: StackLinkStyle = .value
    var programmatic = true
    var toolbarButton = false
    var path: [String] = []
}

private struct NavigationStackDemo: View {
    let page: ComponentPage

    var body: some View {
        DemoPage(
            page: page,
            initial: StackConfig(),
            previewHeight: 640,
            usage: """
            NavigationStack {
                List(fruits, id: \\.self) { fruit in
                    NavigationLink(fruit, value: fruit)
                }
                .navigationTitle("Fruits")
                .navigationDestination(for: String.self) { fruit in
                    Text(fruit)
                }
            }
            """,
            usageNote: Aside(.important, "Put `.navigationTitle`, `.toolbar`, and `.navigationDestination` on the views inside the stack, not on the `NavigationStack` itself.")
        ) { $config in
            StackPushPreview(
                caption: "Tap a fruit to push it. Pushing opens the real stack full screen, like the root of an app.",
                onDismiss: { config.path = [] }
            ) { open in
                StackRoot(config: $config, open: open)
            } screen: {
                StackScreen(config: $config)
            }
            .id("phone")
        } controls: { $config in
            Section("Links") {
                OptionPicker("Link style", selection: $config.links)
                Toggle("Programmatic path", isOn: $config.programmatic)
                    .disabled(config.links == .destination)
            }
            Section("Navigation bar") {
                OptionPicker("Title display", selection: $config.titleMode)
                Toggle("Toolbar button", isOn: $config.toolbarButton)
            }
        } code: { config in
            code(for: config)
        } examples: {
            StackExamples()
        }
    }

    private func code(for config: StackConfig) -> String {
        var lines: [String] = []
        let usesPath = config.links == .value && config.programmatic
        if usesPath {
            lines += ["@State private var path: [String] = []", ""]
        }
        lines.append("let fruits = [\"Apple\", \"Banana\", \"Cherry\", \"Kiwi\", \"Lemon\"]")
        lines.append("")
        lines.append(usesPath ? "NavigationStack(path: $path) {" : "NavigationStack {")
        lines.append("    List {")
        lines.append("        ForEach(fruits, id: \\.self) { fruit in")
        if config.links == .value {
            lines.append("            NavigationLink(fruit, value: fruit)")
        } else {
            lines.append("            NavigationLink(fruit) {")
            lines.append("                Text(fruit)")
            lines.append("                    .font(.largeTitle)")
            lines.append("                    .navigationTitle(fruit)")
            lines.append("            }")
        }
        lines.append("        }")
        if usesPath {
            lines.append("        Section(\"Navigate in code\") {")
            lines.append("            Button(\"Jump to Kiwi → Lemon\") { path = [\"Kiwi\", \"Lemon\"] }")
            lines.append("            Button(\"Pop to root\") { path = [] }")
            lines.append("            Text(\"path = \\(path)\")")
            lines.append("                .monospaced()")
            lines.append("        }")
        }
        lines.append("    }")
        lines.append("    .navigationTitle(\"Fruits\")")
        if config.titleMode != .automatic {
            lines.append("    .navigationBarTitleDisplayMode(\(config.titleMode.label))")
        }
        if config.toolbarButton {
            lines.append("    .toolbar {")
            lines.append("        Button(\"Add\", systemImage: \"plus\") {}")
            lines.append("    }")
        }
        if config.links == .value {
            lines.append("    .navigationDestination(for: String.self) { fruit in")
            lines.append("        Text(fruit)")
            lines.append("            .font(.largeTitle)")
            lines.append("            .navigationTitle(fruit)")
            lines.append("    }")
        }
        lines.append("}")
        return lines.joined(separator: "\n")
    }
}

/// The real stack, shown full screen. Mirrors the generated code.
private struct StackScreen: View {
    @Binding var config: StackConfig

    var body: some View {
        if config.links == .value {
            NavigationStack(path: $config.path) {
                StackRoot(config: $config, open: nil)
                    .navigationDestination(for: String.self) { fruit in
                        StackDetail(fruit: fruit)
                    }
            }
        } else {
            NavigationStack {
                StackRoot(config: $config, open: nil)
            }
        }
    }
}

/// The root screen. Inside the phone frame (`open` set), rows can't push,
/// because a push would land in the catalog's own stack. They look the same
/// and open the real stack full screen instead.
private struct StackRoot: View {
    @Binding var config: StackConfig
    let open: (() -> Void)?

    var body: some View {
        List {
            ForEach(stackFruits, id: \.self) { fruit in
                if let open {
                    StackLinkRow(title: fruit) {
                        if config.links == .value { config.path = [fruit] }
                        open()
                    }
                } else if config.links == .value {
                    NavigationLink(fruit, value: fruit)
                } else {
                    NavigationLink(fruit) {
                        StackDetail(fruit: fruit)
                    }
                }
            }
            if config.links == .value && config.programmatic {
                Section("Navigate in code") {
                    Button("Jump to Kiwi → Lemon") {
                        config.path = ["Kiwi", "Lemon"]
                        open?()
                    }
                    Button("Pop to root") { config.path = [] }
                        .disabled(config.path.isEmpty)
                    Text("path = \(config.path)")
                        .monospaced()
                }
            }
        }
        .navigationTitle("Fruits")
        .navigationBarTitleDisplayMode(config.titleMode.mode)
        .toolbar {
            if config.toolbarButton {
                Button("Add", systemImage: "plus") {}
            }
        }
    }
}

private struct StackDetail: View {
    let fruit: String

    var body: some View {
        Text(fruit)
            .font(.largeTitle)
            .navigationTitle(fruit)
    }
}

// MARK: - Examples

private struct StackExamples: View {
    var body: some View {
        ExampleCard(
            title: "Routes with an enum",
            caption: "Model each screen as an enum case, and map them all in one `.navigationDestination`, like a route table.",
            code: """
            enum Route: Hashable {
                case profile(String)
                case settings
            }

            @State private var path: [Route] = []

            NavigationStack(path: $path) {
                List {
                    NavigationLink("Maya's profile", value: Route.profile("Maya"))
                    NavigationLink("Settings", value: Route.settings)
                }
                .navigationTitle("Home")
                .navigationDestination(for: Route.self) { route in
                    switch route {
                    case .profile(let name): Text("Profile of \\(name)")
                    case .settings: Text("Settings")
                    }
                }
            }
            """,
            minHeight: 360,
            aside: Aside(.important, "Every value type you push needs a matching `.navigationDestination(for:)` inside the stack. Without one, the link does nothing.")
        ) {
            StackPushPreview(height: 300, caption: "Tap a row to try it full screen.") { open in
                List {
                    StackLinkRow(title: "Maya's profile", action: open)
                    StackLinkRow(title: "Settings", action: open)
                }
                .navigationTitle("Home")
            } screen: {
                StackRouteExample()
            }
        }

        ExampleCard(
            title: "Present a detail from a selection",
            caption: "Use `.navigationDestination(item:)` when a button, not a link, decides where to go.",
            code: """
            @State private var selected: String?

            NavigationStack {
                VStack(spacing: 12) {
                    Button("Open Report") { selected = "Report" }
                    Button("Open Invoice") { selected = "Invoice" }
                }
                .buttonStyle(.bordered)
                .navigationTitle("Documents")
                .navigationDestination(item: $selected) { name in
                    Text(name)
                        .font(.largeTitle)
                }
            }
            """,
            minHeight: 360
        ) {
            StackPushPreview(height: 300, caption: "Tap a button to try it full screen.") { open in
                VStack(spacing: 12) {
                    Button("Open Report", action: open)
                    Button("Open Invoice", action: open)
                }
                .buttonStyle(.bordered)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .navigationTitle("Documents")
            } screen: {
                StackItemExample()
            }
        }
    }
}

private enum StackRoute: Hashable {
    case profile(String)
    case settings
}

private struct StackRouteExample: View {
    @State private var path: [StackRoute] = []

    var body: some View {
        NavigationStack(path: $path) {
            List {
                NavigationLink("Maya's profile", value: StackRoute.profile("Maya"))
                NavigationLink("Settings", value: StackRoute.settings)
            }
            .navigationTitle("Home")
            .navigationDestination(for: StackRoute.self) { route in
                switch route {
                case .profile(let name): Text("Profile of \(name)")
                case .settings: Text("Settings")
                }
            }
        }
    }
}

private struct StackItemExample: View {
    @State private var selected: String?

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                Button("Open Report") { selected = "Report" }
                Button("Open Invoice") { selected = "Invoice" }
            }
            .buttonStyle(.bordered)
            .navigationTitle("Documents")
            .navigationDestination(item: $selected) { name in
                Text(name)
                    .font(.largeTitle)
            }
        }
    }
}

// MARK: - Options

private enum StackTitleMode: DemoOption {
    case automatic, large, inline

    var label: String {
        switch self {
        case .automatic: ".automatic"
        case .large: ".large"
        case .inline: ".inline"
        }
    }

    var mode: NavigationBarItem.TitleDisplayMode {
        switch self {
        case .automatic: .automatic
        case .large: .large
        case .inline: .inline
        }
    }
}

private enum StackLinkStyle: DemoOption {
    case value, destination

    var label: String {
        switch self {
        case .value: "Value + navigationDestination"
        case .destination: "Destination view"
        }
    }
}


// MARK: - Thumbnail

private struct StackThumbnail: View {
    var body: some View {
        ZStack {
            card("Fruits", rows: ["Apple", "Banana", "Kiwi"])
                .offset(x: -36, y: -8)
                .opacity(0.55)
            card("Kiwi", rows: ["Pairs with Lemon", "Pairs with Lime"])
                .offset(x: 36, y: 8)
        }
    }

    private func card(_ title: String, rows: [String]) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.headline)
            ForEach(rows, id: \.self) { row in
                HStack {
                    Text(row)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.tertiary)
                }
                .font(.caption)
                .padding(.vertical, 2)
            }
        }
        .padding(12)
        .frame(width: 140)
        .background(.background, in: .rect(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(.separator)
        }
        .shadow(color: .black.opacity(0.12), radius: 8, y: 3)
    }
}

// MARK: - Push preview

/// A row that looks like a `NavigationLink` but runs an action instead.
private struct StackLinkRow: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
            .foregroundStyle(Color.primary)
            .contentShape(.rect)
        }
    }
}

/// Shows a screen live inside a phone frame, plus the real stack full screen.
/// Pushes can't run inside the frame: a `NavigationLink` there would push onto
/// the catalog's own stack. A full-screen cover starts a fresh navigation
/// context, exactly like the root of a real app.
private struct StackPushPreview<Inline: View, Screen: View>: View {
    var height: CGFloat = 560
    let caption: String
    var onDismiss: () -> Void = {}
    @ViewBuilder let inline: (_ open: @escaping () -> Void) -> Inline
    @ViewBuilder let screen: () -> Screen
    @State private var isPresented = false

    var body: some View {
        VStack(spacing: 14) {
            PhoneScreen(height: height) {
                inline { isPresented = true }
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
        .fullScreenCover(isPresented: $isPresented, onDismiss: onDismiss) {
            screen()
                .overlay(alignment: .bottom) {
                    Button("Close Demo", systemImage: "xmark") {
                        isPresented = false
                    }
                    .buttonStyle(.glassProminent)
                    .controlSize(.large)
                    .padding(.bottom, 8)
                }
        }
    }
}
/// A small phone screen with a title, for the title-length guideline.
private struct StackTitleSample: View {
    let title: String

    var body: some View {
        PhoneScreen(width: 250, height: 190) {
            List {
                Text("Lunch on Friday?")
                Text("Your order has shipped")
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
