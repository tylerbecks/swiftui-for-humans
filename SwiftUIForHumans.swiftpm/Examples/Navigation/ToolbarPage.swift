import SwiftUI

extension ComponentPage {
    static let toolbar = ComponentPage(
        id: "toolbar",
        title: "Toolbar",
        summary: "Puts buttons and menus in the bar at the top or bottom of a screen.",
        category: .lists,
        symbol: "menubar.rectangle",
        availability: ["iOS 14.0+", "macOS 11.0+", "visionOS 1.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/view/toolbar(content:)",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/toolbars",
        aliases: ["navbar", "nav bar", "header buttons", "app bar", "action bar", "UIBarButtonItem", "UIToolbar", "bottom bar", "title bar"],
        related: ["navigation-stack", "button", "menu", "searchable"],
        notes: [
            "**Neighboring buttons share one glass capsule.** `ToolbarSpacer(.fixed)` splits them into separate groups, and `ToolbarSpacer(.flexible)` pushes them apart.",
            "**Add a second line under the title.** `.navigationSubtitle` (iOS 26) shows a smaller line, like Mail's unread count.",
        ],
        about: """
        `.toolbar` fills the bars of the screen it's attached to: the navigation bar at the top and an optional bar at the bottom. Each screen brings its own items, and they swap as you push and pop.

        A plain `Button` lands in the trailing spot. Wrap it in `ToolbarItem(placement:)` to put it somewhere else.
        """,
        composition: """
        NavigationStack
        └── Screen view
            └── .toolbar
                ├── ToolbarItem
                ├── ToolbarSpacer
                ├── ToolbarItem
                └── ToolbarItem(.bottomBar)
        """,
        api: [
            APIItem("`.toolbar { }`", "Adds items to the screen's bars."),
            APIItem("`ToolbarItem(placement:)`", "Puts one item in a specific spot."),
            APIItem("`.topBarLeading`, `.topBarTrailing`", "The left or right side of the top bar."),
            APIItem("`.confirmationAction`", "Save or Done, styled as the prominent action."),
            APIItem("`.cancellationAction`", "Cancel, where the platform expects it."),
            APIItem("`.bottomBar`", "A bar at the bottom of the screen."),
            APIItem("`ToolbarSpacer(_:placement:)`", "Splits or spreads glass groups."),
            APIItem("`.toolbar(_:for:)`", "Hides or shows a bar, such as `.navigationBar`."),
        ],
        guidelines: [
            Guideline(
                "Use symbols for common actions.",
                "Familiar SF Symbols like share and plus are quicker to recognize than words, and leave room for the title. Keep text for actions like Edit that have no clear symbol.",
                good: "Familiar symbols, compact and clear.",
                bad: "Text labels crowd out the title."
            ) {
                ToolbarGuidelineSample(style: .symbols)
            } bad: {
                ToolbarGuidelineSample(style: .text)
            },
            Guideline(
                "Keep the bar uncluttered.",
                "Show the two or three actions people use most, and move the rest into a More menu built with `Menu`.",
                good: "Main actions, plus a More menu.",
                bad: "Too many buttons to tell apart."
            ) {
                ToolbarGuidelineSample(style: .moreMenu)
            } bad: {
                ToolbarGuidelineSample(style: .crowded)
            },
            Guideline(
                "Mark one primary action.",
                "Put Done or Save in `.confirmationAction`, so it's tinted and sits on the trailing side. More than one makes the focus unclear."
            ),
            Guideline(
                "Keep the standard Back and Close buttons.",
                "People already know what they do. Don't swap them for a text label that says Back or Close."
            ),
        ]
    ) {
        ToolbarThumbnail()
    } content: { page in
        ToolbarDemo(page: page)
    }
}

private struct ToolbarConfig {
    var titleMode: ToolbarTitleMode = .large
    var subtitle = true
    var leading = true
    var trailingGroup = true
    var spacer = true
    var principal = false
    var bottomBar = false
}

private struct ToolbarDemo: View {
    let page: ComponentPage

    var body: some View {
        DemoPage(
            page: page,
            initial: ToolbarConfig(),
            previewHeight: 600,
            usage: """
            NavigationStack {
                List(1...20, id: \\.self) { Text("Note \\($0)") }
                    .navigationTitle("Notes")
                    .toolbar {
                        Button("Add", systemImage: "plus") {
                            // Add a note
                        }
                    }
            }
            """,
            usageNote: Aside(.important, "Put `.toolbar` on a view inside the `NavigationStack`, not on the stack itself, or the items won't show.")
        ) { $config in
            PhoneScreen {
                ToolbarScreen(config: $config)
            }
            .id("phone")
        } controls: { $config in
            Section("Title") {
                OptionPicker("Display mode", selection: $config.titleMode)
                Toggle("Subtitle", isOn: $config.subtitle)
                Toggle("Picker in the center", isOn: $config.principal)
            }
            Section("Items") {
                Toggle("Leading button", isOn: $config.leading)
                Toggle("Trailing group", isOn: $config.trailingGroup)
                Toggle("Spacer in the group", isOn: $config.spacer)
                    .disabled(!config.trailingGroup)
                Toggle("Bottom bar", isOn: $config.bottomBar)
            }
        } code: { config in
            code(for: config)
        } examples: {
            ToolbarExamples()
        }
    }

    private func code(for config: ToolbarConfig) -> String {
        var lines = config.principal ? ["@State private var filter = 0", ""] : []
        lines += ["NavigationStack {", "    List(1...20, id: \\.self) { Text(\"Note \\($0)\") }", "        .navigationTitle(\"Notes\")"]
        if config.subtitle {
            lines.append("        .navigationSubtitle(\"20 notes\")")
        }
        if config.titleMode != .automatic {
            lines.append("        .navigationBarTitleDisplayMode(\(config.titleMode.label))")
        }
        var items: [String] = []
        if config.leading {
            items += [
                "ToolbarItem(placement: .topBarLeading) {",
                "    Button(\"Edit\") {}",
                "}",
            ]
        }
        if config.principal {
            items += [
                "ToolbarItem(placement: .principal) {",
                "    Picker(\"Filter\", selection: $filter) {",
                "        Text(\"All\").tag(0)",
                "        Text(\"Mine\").tag(1)",
                "    }",
                "    .pickerStyle(.segmented)",
                "}",
            ]
        }
        if config.trailingGroup {
            items += ["ToolbarItem(placement: .topBarTrailing) {", "    Button(\"Share\", systemImage: \"square.and.arrow.up\") {}", "}"]
            if config.spacer {
                items.append("ToolbarSpacer(.fixed, placement: .topBarTrailing)")
            }
            items += ["ToolbarItem(placement: .topBarTrailing) {", "    Button(\"Add\", systemImage: \"plus\") {}", "}"]
        }
        if config.bottomBar {
            items += [
                "ToolbarItem(placement: .bottomBar) {",
                "    Button(\"Filter\", systemImage: \"line.3.horizontal.decrease\") {}",
                "}",
                "ToolbarSpacer(.flexible, placement: .bottomBar)",
                "ToolbarItem(placement: .bottomBar) {",
                "    Button(\"Compose\", systemImage: \"square.and.pencil\") {}",
                "}",
            ]
        }
        if !items.isEmpty {
            lines.append("        .toolbar {")
            lines += items.map { "            " + $0 }
            lines.append("        }")
        }
        lines.append("}")
        return lines.joined(separator: "\n")
    }
}

private struct ToolbarScreen: View {
    @Binding var config: ToolbarConfig
    @State private var filter = 0

    var body: some View {
        List(1...20, id: \.self) { Text("Note \($0)") }
            .navigationTitle("Notes")
            .navigationSubtitle(config.subtitle ? "20 notes" : "")
            .navigationBarTitleDisplayMode(config.titleMode.mode)
            .toolbar(config.bottomBar ? .visible : .hidden, for: .bottomBar)
            .toolbar {
                if config.leading {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Edit") {}
                    }
                }
                if config.principal {
                    ToolbarItem(placement: .principal) {
                        Picker("Filter", selection: $filter) {
                            Text("All").tag(0)
                            Text("Mine").tag(1)
                        }
                        .pickerStyle(.segmented)
                    }
                }
                if config.trailingGroup {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Share", systemImage: "square.and.arrow.up") {}
                    }
                    if config.spacer {
                        ToolbarSpacer(.fixed, placement: .topBarTrailing)
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Add", systemImage: "plus") {}
                    }
                }
                if config.bottomBar {
                    ToolbarItem(placement: .bottomBar) {
                        Button("Filter", systemImage: "line.3.horizontal.decrease") {}
                    }
                    ToolbarSpacer(.flexible, placement: .bottomBar)
                    ToolbarItem(placement: .bottomBar) {
                        Button("Compose", systemImage: "square.and.pencil") {}
                    }
                }
            }
    }
}

private struct ToolbarThumbnail: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "chevron.left")
                    .frame(width: 34, height: 34)
                    .glassEffect(.regular, in: .circle)
                Spacer()
                HStack(spacing: 14) {
                    Image(systemName: "square.and.arrow.up")
                    Image(systemName: "plus")
                }
                .padding(.horizontal, 12)
                .frame(height: 34)
                .glassEffect(.regular, in: .capsule)
            }
            .font(.callout.weight(.medium))
            Text("Notes")
                .font(.title.bold())
            Text("20 notes")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .frame(width: 230)
    }
}

// MARK: - Examples

private struct ToolbarExamples: View {
    @State private var showEditor = false

    var body: some View {
        ExampleCard(
            title: "Save and Cancel in a sheet",
            caption: "Use `.cancellationAction` and `.confirmationAction` to put Cancel and Save where people expect them.",
            code: """
            @State private var showEditor = false

            Button("New Event") { showEditor = true }
                .sheet(isPresented: $showEditor) {
                    NavigationStack {
                        Form {
                            TextField("Title", text: .constant(""))
                        }
                        .navigationTitle("New Event")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) {
                                Button("Cancel", role: .cancel) { showEditor = false }
                            }
                            ToolbarItem(placement: .confirmationAction) {
                                Button("Add", role: .confirm) { showEditor = false }
                            }
                        }
                    }
                }
            """,
            minHeight: 120,
            aside: Aside(.note, "A sheet doesn't get a bar of its own. Wrap its content in a `NavigationStack` to show a title and toolbar.")
        ) {
            Button("New Event") { showEditor = true }
                .buttonStyle(.borderedProminent)
                .sheet(isPresented: $showEditor) {
                    NavigationStack {
                        Form {
                            TextField("Title", text: .constant(""))
                        }
                        .navigationTitle("New Event")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) {
                                Button("Cancel", role: .cancel) { showEditor = false }
                            }
                            ToolbarItem(placement: .confirmationAction) {
                                Button("Add", role: .confirm) { showEditor = false }
                            }
                        }
                    }
                }
        }

        ExampleCard(
            title: "Menu in the toolbar",
            caption: "Put a `Menu` in the toolbar to tuck less common actions behind one More button.",
            code: """
            NavigationStack {
                Text("Document")
                    .navigationTitle("Report")
                    .toolbar {
                        Menu("More", systemImage: "ellipsis") {
                            Button("Duplicate", systemImage: "plus.square.on.square") {}
                            Button("Rename", systemImage: "pencil") {}
                            Button("Delete", systemImage: "trash", role: .destructive) {}
                        }
                    }
            }
            """,
            minHeight: 340
        ) {
            PhoneScreen(height: 320) {
                Text("Document")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .navigationTitle("Report")
                    .toolbar {
                        Menu("More", systemImage: "ellipsis") {
                            Button("Duplicate", systemImage: "plus.square.on.square") {}
                            Button("Rename", systemImage: "pencil") {}
                            Button("Delete", systemImage: "trash", role: .destructive) {}
                        }
                    }
            }
        }
    }
}

// MARK: - Options

private enum ToolbarTitleMode: DemoOption {
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
// MARK: - Guideline samples

private enum ToolbarSampleStyle {
    case symbols, text, moreMenu, crowded
}

/// A small screen whose toolbar shows one guideline.
private struct ToolbarGuidelineSample: View {
    let style: ToolbarSampleStyle

    var body: some View {
        PhoneScreen(width: 270, height: 150) {
            List {
                Text("Groceries")
                Text("Trip ideas")
            }
            .navigationTitle("Notes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                switch style {
                case .symbols:
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Share", systemImage: "square.and.arrow.up") {}
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Add", systemImage: "plus") {}
                    }
                case .text:
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Share Note") {}
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Add New") {}
                    }
                case .moreMenu:
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Add", systemImage: "plus") {}
                    }
                    ToolbarSpacer(.fixed, placement: .topBarTrailing)
                    ToolbarItem(placement: .topBarTrailing) {
                        Menu("More", systemImage: "ellipsis") {
                            Button("Share", systemImage: "square.and.arrow.up") {}
                            Button("Pin", systemImage: "pin") {}
                        }
                    }
                case .crowded:
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Pin", systemImage: "pin") {}
                    }
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Lock", systemImage: "lock") {}
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Share", systemImage: "square.and.arrow.up") {}
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Tag", systemImage: "tag") {}
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Add", systemImage: "plus") {}
                    }
                }
            }
        }
    }
}
