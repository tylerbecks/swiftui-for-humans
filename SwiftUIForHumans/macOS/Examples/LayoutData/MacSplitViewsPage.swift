import SwiftUI

extension ComponentPage {
    static let splitViews = ComponentPage(
        id: "split-views",
        title: "Split views",
        summary: "Panes people resize by dragging the divider between them, side by side or stacked.",
        category: .layout,
        symbol: "rectangle.split.3x1",
        availability: ["macOS 10.15+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/hsplitview",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/split-views",
        aliases: [
            "HSplitView", "VSplitView", "split view", "NSSplitView", "NSSplitViewController", "pane", "panes",
            "divider", "resizable panel", "splitter", "console", "IDE layout", "NavigationSplitView",
        ],
        related: ["navigation-split-view", "inspector", "stacks-grid", "windows-layout"],
        notes: [
            "**`HSplitView` and `VSplitView` are Mac only.** If you share the view with another platform, give it another layout there.",
            "**They add nothing to the toolbar.** Unlike `NavigationSplitView`, there's no sidebar button. If a pane can hide, add your own toolbar button and menu command for it.",
        ],
        about: "`HSplitView` puts its children side by side and `VSplitView` stacks them, each with a divider people drag to resize the panes. Nest one in the other for an editor with a file list on the left and a console underneath.\n\nFor sidebar navigation, with a list that picks what the detail shows, use [NavigationSplitView](catalog://navigation-split-view) instead. It brings the sidebar look and the toolbar's sidebar button.",
        composition: """
        HSplitView
        ├── FileList
        └── VSplitView
            ├── Editor
            └── Console
        """,
        api: [
            APIItem("`HSplitView { }`", "Side-by-side panes with draggable dividers."),
            APIItem("`VSplitView { }`", "Stacked panes with draggable dividers."),
            APIItem("`.frame(minWidth:idealWidth:maxWidth:)`", "Limits how far a pane resizes."),
            APIItem("`NavigationSplitView`", "Sidebar and detail columns for navigation."),
        ],
        guidelines: [
            Guideline(
                "Give every pane a minimum and maximum size.",
                "If a pane can shrink to nothing, its divider seems to disappear and people can't find it to drag back. A `minWidth` keeps it in reach."
            ),
            Guideline(
                "Let people hide a pane, and give them more than one way back.",
                "Someone editing may want the console gone. Offer a toolbar button and a menu command with a keyboard shortcut to show it again."
            ),
            Guideline(
                "Keep the selection highlighted in each pane.",
                "When a choice in one pane decides what the next one shows, a lasting highlight tells people how they got there."
            ),
            Guideline(
                "Consider drag and drop between panes.",
                "Panes show different levels of your content at once, so dragging an item to another pane is a natural way to move it."
            ),
        ]
    ) {
        HStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 4).fill(.fill.secondary).frame(width: 36)
            Divider()
            VStack(spacing: 0) {
                RoundedRectangle(cornerRadius: 4).fill(.background)
                Divider()
                RoundedRectangle(cornerRadius: 4).fill(.fill.tertiary).frame(height: 26)
            }
        }
        .frame(width: 130, height: 80)
        .overlay(RoundedRectangle(cornerRadius: 6).strokeBorder(.separator))
    } content: { page in
        MacSplitViewsArticle(page: page)
    }
}

extension Catalog {
    /// A file list, an editor, and a console, in real split views.
    static let splitViewsPanesDemoWindow = DemoWindow(id: "split-views-panes", title: "Project", size: CGSize(width: 760, height: 480)) {
        PanesDemoWindow()
    }

    /// A real NavigationSplitView, for comparing it with HSplitView.
    static let splitViewsNavigationDemoWindow = DemoWindow(id: "split-views-navigation", title: "Mailboxes", size: CGSize(width: 680, height: 420)) {
        NavigationSplitDemoWindow()
    }
}

// MARK: - Page

private struct MacSplitViewsArticle: View {
    let page: ComponentPage

    var body: some View {
        ArticlePage(page: page) {
            if let about = page.about {
                AboutSection(text: about)
            }
            HStack(spacing: 12) {
                OpenDemoWindowButton(id: "split-views-panes", label: "Open the Panes Demo")
                OpenDemoWindowButton(id: "split-views-navigation", label: "Open a NavigationSplitView")
            }
            .controlSize(.large)

            SectionTitle("Usage")
                .id("code")
            CodeBlock(code: """
            @State private var text = ""

            HSplitView {
                List(["README.md", "App.swift"], id: \\.self) { Text($0) }
                    .frame(minWidth: 150, idealWidth: 200, maxWidth: 320)
                TextEditor(text: $text)
                    .frame(minWidth: 300)
            }
            """)
            Aside(.note, "Put a `minWidth` on each pane. Without one, people can drag a divider until the pane next to it is gone.")

            if let composition = page.composition {
                CompositionSection(tree: composition)
            }

            SectionTitle("Examples")
                .id("examples")
            SplitViewExamples()

            SectionTitle("HSplitView or NavigationSplitView?")
            Prose("Both put panes side by side. They answer different questions: is this pane a way to get around the app, or part of the work itself?")
            ConnectFacts(rows: [
                ("HSplitView and VSplitView", "Panes inside the window's content, side by side or stacked, and nested in each other. Nothing in the toolbar. Mac only."),
                ("NavigationSplitView", "Two or three columns where a selection on the left decides what's on the right. Sidebar style and a sidebar button in the toolbar. Works on every platform."),
            ])
        }
    }
}

// MARK: - Examples

private struct SplitViewExamples: View {
    @State private var showsConsole = true

    var body: some View {
        ExampleCard(
            title: "A list beside an editor",
            caption: "`HSplitView` puts a divider between its children that people drag, and each pane's minimum and maximum width stops it.",
            code: """
            HSplitView {
                List(["README.md", "App.swift", "Model.swift"], id: \\.self) {
                    Text($0)
                }
                .frame(minWidth: 120, idealWidth: 160, maxWidth: 240)
                Text("App.swift")
                    .frame(minWidth: 200, maxWidth: .infinity, maxHeight: .infinity)
            }
            """,
            minHeight: 260
        ) {
            MacWindowFrame(title: "Project", width: 460, height: 220) {
                HSplitView {
                    SampleFileList()
                        .frame(minWidth: 120, idealWidth: 160, maxWidth: 240)
                    SampleEditor()
                        .frame(minWidth: 200, maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        }

        ExampleCard(
            title: "An editor over a console",
            caption: "`VSplitView` stacks its children with a horizontal divider, so people choose how much room the console gets.",
            code: """
            VSplitView {
                Text("App.swift")
                    .frame(maxWidth: .infinity, minHeight: 80, maxHeight: .infinity)
                Text("Build succeeded")
                    .font(.callout.monospaced())
                    .frame(maxWidth: .infinity, minHeight: 50, maxHeight: .infinity, alignment: .topLeading)
                    .padding(8)
            }
            """,
            minHeight: 260
        ) {
            MacWindowFrame(title: "Project", width: 460, height: 220) {
                VSplitView {
                    SampleEditor()
                        .frame(maxWidth: .infinity, minHeight: 80, maxHeight: .infinity)
                    SampleConsole()
                        .frame(maxWidth: .infinity, minHeight: 50, maxHeight: .infinity, alignment: .topLeading)
                }
            }
        }

        ExampleCard(
            title: "A pane people can hide",
            caption: "Leave a pane out with `if` and toggle it from a toolbar button, plus a matching menu command so people have another way back.",
            code: """
            @State private var showsConsole = true

            VSplitView {
                Text("App.swift")
                    .frame(maxWidth: .infinity, minHeight: 80, maxHeight: .infinity)
                if showsConsole {
                    Text("Build succeeded")
                        .frame(maxWidth: .infinity, minHeight: 50, maxHeight: .infinity)
                }
            }
            .toolbar {
                Toggle("Console", systemImage: "rectangle.bottomthird.inset.filled", isOn: $showsConsole)
            }
            """,
            minHeight: 260,
            aside: Aside(.note, "A real `.toolbar` here would land in this window's own toolbar, so the preview draws one. The panes demo window has the real thing.")
        ) {
            MacWindowFrame(title: "Project", width: 460, height: 220) {
                VSplitView {
                    SampleEditor()
                        .frame(maxWidth: .infinity, minHeight: 80, maxHeight: .infinity)
                    if showsConsole {
                        SampleConsole()
                            .frame(maxWidth: .infinity, minHeight: 50, maxHeight: .infinity, alignment: .topLeading)
                    }
                }
            } toolbar: {
                Toggle("Console", systemImage: "rectangle.bottomthird.inset.filled", isOn: $showsConsole)
                    .toggleStyle(.button)
                    .labelStyle(.iconOnly)
            }
        }
    }
}

// MARK: - Samples

private struct SampleFileList: View {
    @State private var selection: String? = "App.swift"

    var body: some View {
        List(["README.md", "App.swift", "Model.swift", "Settings.swift"], id: \.self, selection: $selection) { name in
            Label(name, systemImage: name.hasSuffix(".swift") ? "swift" : "doc.text")
        }
    }
}

private struct SampleEditor: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("struct App {")
            Text("    var name = \"Reader\"")
            Text("}")
        }
        .font(.callout.monospaced())
        .padding(12)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(.background)
    }
}

private struct SampleConsole: View {
    var body: some View {
        Text("Build succeeded in 1.2 s")
            .font(.callout.monospaced())
            .foregroundStyle(.secondary)
            .padding(8)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(.fill.quaternary)
    }
}

// MARK: - Demo windows

private struct PanesDemoWindow: View {
    @State private var showsConsole = true

    var body: some View {
        HSplitView {
            SampleFileList()
                .frame(minWidth: 140, idealWidth: 190, maxWidth: 300)
            VSplitView {
                SampleEditor()
                    .frame(minWidth: 300, maxWidth: .infinity, minHeight: 120, maxHeight: .infinity)
                if showsConsole {
                    SampleConsole()
                        .frame(maxWidth: .infinity, minHeight: 60, idealHeight: 120, maxHeight: .infinity)
                }
            }
        }
        .toolbar {
            Toggle("Console", systemImage: "rectangle.bottomthird.inset.filled", isOn: $showsConsole)
                .help(showsConsole ? "Hide the console" : "Show the console")
        }
    }
}

private struct Mailbox: Identifiable, Hashable {
    let name: String
    let symbol: String
    let messages: [String]
    var id: String { name }
}

private struct NavigationSplitDemoWindow: View {
    private let mailboxes = [
        Mailbox(name: "Inbox", symbol: "tray", messages: ["Lunch on Friday?", "Your receipt", "Trip photos"]),
        Mailbox(name: "Drafts", symbol: "doc", messages: ["Re: Quarterly plan"]),
        Mailbox(name: "Sent", symbol: "paperplane", messages: ["Slides for Monday", "Thanks!"]),
    ]
    @State private var selection: Mailbox.ID? = "Inbox"

    var body: some View {
        NavigationSplitView {
            List(mailboxes, selection: $selection) { mailbox in
                Label(mailbox.name, systemImage: mailbox.symbol)
            }
            .navigationSplitViewColumnWidth(min: 160, ideal: 190)
        } detail: {
            if let mailbox = mailboxes.first(where: { $0.id == selection }) {
                List(mailbox.messages, id: \.self) { Text($0) }
                    .navigationTitle(mailbox.name)
            } else {
                ContentUnavailableView("No Mailbox Selected", systemImage: "tray")
            }
        }
    }
}
