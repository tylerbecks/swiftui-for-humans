import SwiftUI

extension ComponentPage {
    static let navigationSplitView = ComponentPage(
        id: "navigation-split-view",
        title: "NavigationSplitView",
        summary: "A sidebar and detail side by side on iPad that collapses into a stack on iPhone.",
        category: .lists,
        symbol: "sidebar.left",
        availability: ["iOS 16.0+", "macOS 13.0+", "visionOS 1.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/navigationsplitview",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/sidebars",
        aliases: ["sidebar", "master detail", "split view", "UISplitViewController", "columns", "two pane", "layout with sidebar", "drawer"],
        related: ["navigation-stack", "list", "tab-view"],
        notes: [
            "**Test on both iPhone and iPad.** One piece of code gives you two layouts, and an empty detail state only shows up on iPad.",
            "**Show an empty state in the detail.** On iPad the detail is visible before anything is selected, so give it a `ContentUnavailableView`.",
        ],
        about: """
        `NavigationSplitView` owns two or three columns: a sidebar, an optional content list, and a detail. On iPad they sit side by side; on iPhone they collapse into one `NavigationStack`, where the sidebar is the first screen and picking a row pushes the detail.

        Use it when your app is organized around a list of sources, like Mail or Notes. For a few top-level sections on iPhone, use [TabView](catalog://tab-view) instead.
        """,
        composition: """
        NavigationSplitView
        ├── sidebar
        │   └── List(selection:)
        ├── content (optional)
        │   └── List(selection:)
        └── detail
            └── View for the selection
        """,
        api: [
            APIItem("`NavigationSplitView { } detail: { }`", "A sidebar and a detail column."),
            APIItem("`content: { }`", "An optional middle column, like Mail's message list."),
            APIItem("`List(_:selection:)`", "The sidebar; its selection drives the detail."),
            APIItem("`columnVisibility:`", "Shows or hides the sidebar in code, on iPad."),
            APIItem("`.navigationSplitViewStyle(_:)`", "`.balanced` or `.prominentDetail`."),
            APIItem("`.navigationSplitViewColumnWidth(_:)`", "Sets a column's width on iPad."),
        ],
        guidelines: [
            Guideline(
                "Give sidebar items familiar symbols.",
                "An SF Symbol beside each label makes the list faster to scan, and it matches the system apps.",
                good: "Symbols make each row easy to spot.",
                bad: "Text alone is slower to scan."
            ) {
                SplitSidebarSample(showsSymbols: true)
            } bad: {
                SplitSidebarSample(showsSymbols: false)
            },
            Guideline(
                "Keep the sidebar to two levels.",
                "Deeper hierarchies get hard to follow in one column. Add a content column between the sidebar and the detail instead."
            ),
            Guideline(
                "Show the sidebar by default.",
                "A hidden sidebar is easy to miss. Let people hide it themselves; iPad already supports the edge swipe."
            ),
        ]
    ) {
        SplitThumbnail()
    } content: { page in
        SplitDemo(page: page)
    }
}

// MARK: - Model

private let splitFolders = ["Inbox", "Drafts", "Sent", "Archive"]

private func splitSymbol(_ folder: String) -> String {
    switch folder {
    case "Inbox": "tray"
    case "Drafts": "doc"
    case "Sent": "paperplane"
    default: "archivebox"
    }
}

private struct SplitConfig {
    var device: SplitDevice = .automatic
    var columns: SplitColumns = .two
    var style: SplitStyleOption = .automatic
    var visibility: SplitVisibility = .automatic
    var folder: String?
    var message: String?
}

private struct SplitDemo: View {
    let page: ComponentPage

    var body: some View {
        DemoPage(
            page: page,
            initial: SplitConfig(),
            previewHeight: 640,
            usage: """
            @State private var folder: String?

            NavigationSplitView {
                List(["Inbox", "Sent"], id: \\.self, selection: $folder) { folder in
                    Label(folder, systemImage: "folder")
                }
                .navigationTitle("Mail")
            } detail: {
                Text(folder ?? "Pick a folder")
            }
            """,
            usageNote: Aside(.note, "Drive the detail with `List(selection:)`; you don't need `NavigationLink`s. On iPhone, picking a row pushes the detail for you.")
        ) { $config in
            SplitPreview(
                onDismiss: { config.folder = nil },
                caption: config.device == .automatic
                    ? "On iPhone the sidebar is the first screen. Pick a folder to open the real split view full screen: a stack on iPhone, side-by-side columns on iPad."
                    : "Pick a folder to open the real split view full screen, laid out as on \(config.device == .iPhone ? "an iPhone" : "an iPad")."
            ) { open in
                SplitSidebarPreview(config: $config, open: open)
            } screen: {
                SplitScreen(config: $config)
                    .modifier(SplitSizeClass(device: config.device))
            }
            .id("phone")
        } controls: { $config in
            Section {
                OptionPicker("Layout", selection: $config.device)
            } footer: {
                Text("Simulates the other device by overriding the size class. Your app gets it from the device automatically.")
            }
            Section {
                OptionPicker("Columns", selection: $config.columns)
                OptionPicker("Style", selection: $config.style)
                OptionPicker("Column visibility", selection: $config.visibility)
            } header: {
                Text("Split view")
            } footer: {
                Text("Style and visibility only change the iPad layout. On iPhone everything collapses into one stack.")
            }
        } code: { config in
            code(for: config)
        } examples: {
            SplitExamples()
        }
    }

    private func code(for config: SplitConfig) -> String {
        var lines: [String] = []
        if config.visibility != .automatic {
            lines.append("@State private var visibility = NavigationSplitViewVisibility\(config.visibility.label)")
        }
        lines.append("@State private var folder: String?")
        if config.columns == .three {
            lines.append("@State private var message: String?")
        }
        lines.append("")
        lines.append("let folders = [\"Inbox\", \"Drafts\", \"Sent\", \"Archive\"]")
        lines.append("")
        lines.append(config.visibility == .automatic ? "NavigationSplitView {" : "NavigationSplitView(columnVisibility: $visibility) {")
        lines += [
            "    List(folders, id: \\.self, selection: $folder) { folder in",
            "        Label(folder, systemImage: \"folder\")",
            "    }",
            "    .navigationTitle(\"Mail\")",
        ]
        if config.columns == .three {
            lines += [
                "} content: {",
                "    if let folder {",
                "        List([\"Lunch on Friday?\", \"Your order shipped\"], id: \\.self, selection: $message) {",
                "            Text($0)",
                "        }",
                "        .navigationTitle(folder)",
                "    } else {",
                "        ContentUnavailableView(\"No Folder\", systemImage: \"folder\")",
                "    }",
                "} detail: {",
                "    if let message {",
                "        Text(message)",
                "    } else {",
                "        ContentUnavailableView(\"No Message\", systemImage: \"envelope\")",
                "    }",
                "}",
            ]
        } else {
            lines += [
                "} detail: {",
                "    if let folder {",
                "        Text(folder)",
                "            .font(.largeTitle)",
                "    } else {",
                "        ContentUnavailableView(\"No Folder\", systemImage: \"folder\")",
                "    }",
                "}",
            ]
        }
        if config.style != .automatic {
            lines.append(".navigationSplitViewStyle(\(config.style.label))")
        }
        return lines.joined(separator: "\n")
    }
}

/// The split view itself, shared by the iPhone and iPad previews.
private struct SplitScreen: View {
    @Binding var config: SplitConfig
    @State private var visibility = NavigationSplitViewVisibility.automatic

    var body: some View {
        Group {
            if config.columns == .three {
                NavigationSplitView(columnVisibility: $visibility) {
                    sidebar
                } content: {
                    if let folder = config.folder {
                        List(["Lunch on Friday?", "Your order shipped"], id: \.self, selection: $config.message) {
                            Text($0)
                        }
                        .navigationTitle(folder)
                    } else {
                        ContentUnavailableView("No Folder", systemImage: "folder")
                    }
                } detail: {
                    if let message = config.message {
                        Text(message)
                    } else {
                        ContentUnavailableView("No Message", systemImage: "envelope")
                    }
                }
            } else {
                NavigationSplitView(columnVisibility: $visibility) {
                    sidebar
                } detail: {
                    if let folder = config.folder {
                        Text(folder)
                            .font(.largeTitle)
                    } else {
                        ContentUnavailableView("No Folder", systemImage: "folder")
                    }
                }
            }
        }
        .splitStyled(config.style)
        .onAppear { visibility = config.visibility.value }
        .onChange(of: config.visibility) { _, new in
            withAnimation { visibility = new.value }
        }
        .onChange(of: config.folder) { _, _ in
            config.message = nil
        }
    }

    private var sidebar: some View {
        List(splitFolders, id: \.self, selection: $config.folder) { folder in
            Label(folder, systemImage: "folder")
        }
        .navigationTitle("Mail")
    }
}

private struct SplitThumbnail: View {
    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 6) {
                ForEach(splitFolders, id: \.self) { folder in
                    Label(folder, systemImage: splitSymbol(folder))
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 5)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(folder == "Inbox" ? AnyShapeStyle(.tint.opacity(0.18)) : AnyShapeStyle(.clear), in: .rect(cornerRadius: 6))
                }
                Spacer(minLength: 0)
            }
            .padding(8)
            .frame(width: 92)
            .background(.background.secondary)
            Divider()
            VStack(spacing: 6) {
                Image(systemName: "envelope.open")
                    .font(.title2)
                    .foregroundStyle(.tint)
                Text("Inbox")
                    .font(.headline)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.background)
        }
        .frame(width: 220, height: 124)
        .clipShape(.rect(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(.separator)
        }
    }
}

private struct SplitSizeClass: ViewModifier {
    let device: SplitDevice

    func body(content: Content) -> some View {
        switch device {
        case .automatic: content
        case .iPhone: content.environment(\.horizontalSizeClass, .compact)
        case .iPad: content.environment(\.horizontalSizeClass, .regular)
        }
    }
}

// MARK: - Options

private enum SplitDevice: DemoOption {
    case automatic, iPhone, iPad

    var label: String {
        switch self {
        case .automatic: "This device"
        case .iPhone: "iPhone (compact)"
        case .iPad: "iPad (regular)"
        }
    }
}

private enum SplitColumns: DemoOption {
    case two, three

    var label: String {
        switch self {
        case .two: "Sidebar + detail"
        case .three: "Sidebar + content + detail"
        }
    }
}

private enum SplitStyleOption: DemoOption {
    case automatic, balanced, prominentDetail

    var label: String {
        switch self {
        case .automatic: ".automatic"
        case .balanced: ".balanced"
        case .prominentDetail: ".prominentDetail"
        }
    }
}

private enum SplitVisibility: DemoOption {
    case automatic, all, doubleColumn, detailOnly

    var label: String {
        switch self {
        case .automatic: ".automatic"
        case .all: ".all"
        case .doubleColumn: ".doubleColumn"
        case .detailOnly: ".detailOnly"
        }
    }

    var value: NavigationSplitViewVisibility {
        switch self {
        case .automatic: .automatic
        case .all: .all
        case .doubleColumn: .doubleColumn
        case .detailOnly: .detailOnly
        }
    }
}

private extension View {
    @ViewBuilder
    func splitStyled(_ style: SplitStyleOption) -> some View {
        switch style {
        case .automatic: navigationSplitViewStyle(.automatic)
        case .balanced: navigationSplitViewStyle(.balanced)
        case .prominentDetail: navigationSplitViewStyle(.prominentDetail)
        }
    }
}

// MARK: - Preview in a phone frame

/// The sidebar as it looks on iPhone, where it's the first screen. Rows can't
/// push inside the frame (a push would land in the catalog's own stack), so
/// they open the real split view full screen instead.
private struct SplitSidebarPreview: View {
    @Binding var config: SplitConfig
    let open: () -> Void

    var body: some View {
        List(splitFolders, id: \.self) { folder in
            Button {
                config.folder = folder
                open()
            } label: {
                Label {
                    Text(folder)
                        .foregroundStyle(Color.primary)
                } icon: {
                    Image(systemName: "folder")
                }
            }
        }
        .navigationTitle("Mail")
    }
}

/// Shows a screen live inside a phone frame, plus the real split view full
/// screen, where it gets the whole window and its own navigation.
private struct SplitPreview<Inline: View, Screen: View>: View {
    var height: CGFloat = 560
    let onDismiss: () -> Void
    let caption: String
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
// MARK: - Examples

private enum SplitFolder: String, CaseIterable, Identifiable {
    case inbox = "Inbox", drafts = "Drafts", sent = "Sent"
    var id: Self { self }

    var symbol: String {
        switch self {
        case .inbox: "tray"
        case .drafts: "doc"
        case .sent: "paperplane"
        }
    }
}

private struct SplitExamples: View {
    var body: some View {
        ExampleCard(
            title: "Sidebar from an enum",
            caption: "Model the sidebar as an enum, bind `List(selection:)` to it, and `switch` in the detail.",
            code: """
            enum Folder: String, CaseIterable, Identifiable {
                case inbox = "Inbox", drafts = "Drafts", sent = "Sent"
                var id: Self { self }
            }

            @State private var folder: Folder? = .inbox

            NavigationSplitView {
                List(Folder.allCases, selection: $folder) { folder in
                    Label(folder.rawValue, systemImage: "folder")
                }
                .navigationTitle("Mail")
            } detail: {
                switch folder {
                case .inbox: Text("Inbox")
                case .drafts: Text("Drafts")
                case .sent: Text("Sent")
                case nil: ContentUnavailableView("No Folder", systemImage: "folder")
                }
            }
            """,
            minHeight: 400,
            aside: Aside(.note, "Starting with a selection, like `.inbox`, fills the detail on iPad. On iPhone the sidebar still shows first.")
        ) {
            SplitPreview(height: 300, onDismiss: {}, caption: "Tap a folder to try it full screen.") { open in
                List(SplitFolder.allCases) { folder in
                    SplitRowButton(title: folder.rawValue, symbol: "folder", action: open)
                }
                .navigationTitle("Mail")
            } screen: {
                SplitEnumExample()
            }
        }

        ExampleCard(
            title: "Drill down in the detail",
            caption: "Wrap the detail in a `NavigationStack` when it pushes screens of its own.",
            code: """
            @State private var folder: String?

            NavigationSplitView {
                List(["Inbox", "Sent"], id: \\.self, selection: $folder) { folder in
                    Text(folder)
                }
                .navigationTitle("Mail")
            } detail: {
                NavigationStack {
                    List(["Lunch on Friday?", "Your order shipped"], id: \\.self) { subject in
                        NavigationLink(subject) {
                            Text(subject)
                        }
                    }
                    .navigationTitle(folder ?? "Mail")
                }
            }
            """,
            minHeight: 400,
            aside: Aside(.important, "Use one stack in the detail only. Don't wrap the whole split view or the sidebar in another `NavigationStack`.")
        ) {
            SplitPreview(height: 300, onDismiss: {}, caption: "Tap a folder to try it full screen.") { open in
                List(["Inbox", "Sent"], id: \.self) { folder in
                    SplitRowButton(title: folder, symbol: nil, action: open)
                }
                .navigationTitle("Mail")
            } screen: {
                SplitDetailStackExample()
            }
        }
    }
}

private struct SplitEnumExample: View {
    @State private var folder: SplitFolder? = .inbox

    var body: some View {
        NavigationSplitView {
            List(SplitFolder.allCases, selection: $folder) { folder in
                Label(folder.rawValue, systemImage: "folder")
            }
            .navigationTitle("Mail")
        } detail: {
            switch folder {
            case .inbox: Text("Inbox")
            case .drafts: Text("Drafts")
            case .sent: Text("Sent")
            case nil: ContentUnavailableView("No Folder", systemImage: "folder")
            }
        }
    }
}

private struct SplitDetailStackExample: View {
    @State private var folder: String?

    var body: some View {
        NavigationSplitView {
            List(["Inbox", "Sent"], id: \.self, selection: $folder) { folder in
                Text(folder)
            }
            .navigationTitle("Mail")
        } detail: {
            NavigationStack {
                List(["Lunch on Friday?", "Your order shipped"], id: \.self) { subject in
                    NavigationLink(subject) {
                        Text(subject)
                    }
                }
                .navigationTitle(folder ?? "Mail")
            }
        }
    }
}

/// A sidebar row that opens the full-screen demo instead of selecting.
private struct SplitRowButton: View {
    let title: String
    let symbol: String?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            if let symbol {
                Label {
                    Text(title).foregroundStyle(Color.primary)
                } icon: {
                    Image(systemName: symbol)
                }
            } else {
                Text(title).foregroundStyle(Color.primary)
            }
        }
    }
}

// MARK: - Guideline samples

/// A small sidebar, with or without symbols.
private struct SplitSidebarSample: View {
    let showsSymbols: Bool

    var body: some View {
        List {
            ForEach(SplitFolder.allCases) { folder in
                if showsSymbols {
                    Label(folder.rawValue, systemImage: folder.symbol)
                } else {
                    Text(folder.rawValue)
                }
            }
        }
        .listStyle(.plain)
        .scrollDisabled(true)
        .frame(width: 240, height: 140)
    }
}
