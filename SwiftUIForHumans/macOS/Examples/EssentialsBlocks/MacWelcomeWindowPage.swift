import SwiftUI

extension ComponentPage {
    static let welcomeWindow = ComponentPage(
        id: "welcome-window",
        title: "Welcome window",
        summary: "The window a document app shows at launch, with New, Open, and recent files.",
        category: .blocks,
        kind: .block,
        symbol: "macwindow.and.cursorarrow",
        availability: ["macOS 15.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/scene/defaultlaunchbehavior(_:)",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/launching",
        aliases: [
            "welcome screen", "start window", "launcher", "splash", "recent documents", "open recent",
            "Xcode welcome", "hiddenTitleBar", "defaultLaunchBehavior", "restorationBehavior", "start page",
        ],
        related: ["document-editor", "window", "window-style", "opening-windows", "onboarding"],
        notes: [
            "**It appears only when nothing is restored.** With `.defaultLaunchBehavior(.presented)`, the welcome window shows at launch when no document windows come back, and when people click the Dock icon with no windows open.",
            "**Recent files come from AppKit.** SwiftUI has no list of recent documents, so the block reads AppKit's `NSDocumentController.shared.recentDocumentURLs`.",
        ],
        composition: """
        Window("Welcome to Notes", id:)
        ├── .windowStyle(.hiddenTitleBar)
        ├── .defaultLaunchBehavior(.presented)
        └── WelcomeView
            ├── icon, name, version
            ├── New and Open buttons
            └── List (recent documents)
        """,
        api: [
            APIItem("`Window(_:id:)`", "A single window, like Welcome."),
            APIItem("`.defaultLaunchBehavior(.presented)`", "Shows it at launch if nothing is restored."),
            APIItem("`.restorationBehavior(.disabled)`", "Doesn't bring it back on the next launch."),
            APIItem("`.windowStyle(.hiddenTitleBar)`", "Hides the title and the title bar's backing."),
            APIItem("`.windowBackgroundDragBehavior`", "Lets people drag the window by its background."),
            APIItem("`\\.newDocument`, `\\.openDocument`", "Create or open a document from code."),
            APIItem("`\\.dismissWindow`", "Closes the welcome window by its ID."),
        ],
        guidelines: [
            Guideline(
                "Put people back where they were.",
                "If documents were open when people quit, reopen them instead of greeting them again. With `.presented`, the welcome window shows only when nothing comes back."
            ),
            Guideline(
                "Offer recent files next to Open.",
                "Most of the time people want what they had yesterday. A list of recent documents saves a trip through the open panel."
            ),
            Guideline(
                "Get out of the way fast.",
                "People want to start right away. Keep the window to a few ways in, so they can pick one and get to work."
            ),
        ]
    ) {
        MacWelcomeDrawing(isThumbnail: true)
    } content: { page in
        MacWelcomeWindowArticle(page: page)
    }
}

// MARK: - Page

private struct MacWelcomeWindowArticle: View {
    let page: ComponentPage

    var body: some View {
        ArticlePage(page: page) {
            Prose("Many document apps open with a welcome window: the app's icon and name, buttons to create or open a document, and the files people worked on last. It's a `Window` scene next to your `DocumentGroup`, shown at launch only when no documents come back.")
            Prose("Scenes can't be added from a page, so the window below is drawn. It has the same layout as the block, with sample recent files.")

            SectionTitle("The block")
                .id("code")
            ExampleCard(
                title: "Icon, actions, and recent files",
                caption: "A `Window` with a hidden title bar and a material background. `newDocument` and `openDocument` from the environment do the work.",
                code: Self.code,
                minHeight: 320,
                aside: Aside(.note, "The block uses the `TextDocument` from [Document editor](catalog://document-editor).")
            ) {
                MacWelcomeDrawing(isThumbnail: false)
            }

            if let composition = page.composition {
                CompositionSection(tree: composition)
            }

            SectionTitle("What each modifier does")
            ConnectFacts(rows: [
                ("defaultLaunchBehavior(.presented)", "Shows the window at launch when no other windows are restored, and when people click the Dock icon while no windows are open."),
                ("restorationBehavior(.disabled)", "Leaves it out of window restoration, so it doesn't come back on its own next time."),
                ("windowStyle(.hiddenTitleBar)", "Hides the window's title and the backing of its title bar, so the content reaches the top."),
                ("containerBackground(_:for: .window)", "Fills the whole window background, here with a material."),
                ("windowBackgroundDragBehavior(.enabled)", "With no title bar to grab, people can move the window by dragging its background."),
                ("windowResizability(.contentSize)", "Sizes the window to its content, which has a fixed size."),
            ])
        }
    }

    static let code = """
    @main
    struct NotesApp: App {
        var body: some Scene {
            DocumentGroup(newDocument: TextDocument()) { file in
                TextEditor(text: file.$document.text)
            }

            Window("Welcome to Notes", id: "welcome") {
                WelcomeView()
                    .toolbar(removing: .title)
                    .containerBackground(.thickMaterial, for: .window)
            }
            .windowStyle(.hiddenTitleBar)
            .windowResizability(.contentSize)
            .windowBackgroundDragBehavior(.enabled)
            .defaultLaunchBehavior(.presented)
            .restorationBehavior(.disabled)
        }
    }

    struct WelcomeView: View {
        @Environment(\\.newDocument) private var newDocument
        @Environment(\\.openDocument) private var openDocument
        @Environment(\\.dismissWindow) private var dismissWindow
        @State private var isImporting = false

        // SwiftUI has no list of recent documents; AppKit keeps it.
        private let recents = NSDocumentController.shared.recentDocumentURLs

        var body: some View {
            HStack(spacing: 0) {
                VStack(spacing: 10) {
                    Image(systemName: "note.text")
                        .font(.system(size: 64))
                        .foregroundStyle(.tint)
                    Text("Notes")
                        .font(.largeTitle.bold())
                    Text("Version 2.0")
                        .foregroundStyle(.secondary)
                    VStack(alignment: .leading, spacing: 8) {
                        Button("Create New Document", systemImage: "plus") {
                            newDocument(TextDocument())
                            dismissWindow(id: "welcome")
                        }
                        Button("Open Existing Document…", systemImage: "folder") {
                            isImporting = true
                        }
                    }
                    .buttonStyle(.borderless)
                    .padding(.top, 16)
                }
                .frame(width: 300)
                .padding(32)

                List(recents, id: \\.self) { url in
                    Button {
                        open(url)
                    } label: {
                        Label {
                            VStack(alignment: .leading) {
                                Text(url.deletingPathExtension().lastPathComponent)
                                Text(url.deletingLastPathComponent().path(percentEncoded: false))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        } icon: {
                            Image(systemName: "doc.text")
                        }
                    }
                    .buttonStyle(.plain)
                }
                .frame(width: 280)
            }
            .frame(height: 400)
            .fileImporter(isPresented: $isImporting, allowedContentTypes: [.plainText]) { result in
                if case .success(let url) = result {
                    open(url)
                }
            }
        }

        private func open(_ url: URL) {
            Task {
                try? await openDocument(at: url)
                dismissWindow(id: "welcome")
            }
        }
    }
    """
}

// MARK: - Drawing

/// The welcome window, drawn: no title bar, the app on the left and recent
/// files on the right.
private struct MacWelcomeDrawing: View {
    let isThumbnail: Bool
    @State private var selection: String?

    private let recents = [
        ("Ideas", "~/Documents/Notes"),
        ("Meeting notes", "~/Documents/Work"),
        ("Packing list", "~/Desktop"),
        ("Recipes", "~/Documents/Notes"),
    ]

    var body: some View {
        HStack(spacing: 0) {
            VStack(spacing: isThumbnail ? 4 : 8) {
                Image(systemName: "note.text")
                    .font(.system(size: isThumbnail ? 26 : 48))
                    .foregroundStyle(.tint)
                Text("Notes")
                    .font(isThumbnail ? .headline : .title.bold())
                if !isThumbnail {
                    Text("Version 2.0")
                        .foregroundStyle(.secondary)
                    VStack(alignment: .leading, spacing: 8) {
                        Button("Create New Document", systemImage: "plus") {}
                        Button("Open Existing Document…", systemImage: "folder") {}
                    }
                    .buttonStyle(.borderless)
                    .padding(.top, 12)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay(alignment: .topLeading) {
                HStack(spacing: 8) {
                    Circle().fill(Color.red.gradient)
                    Circle().fill(Color.yellow.gradient)
                    Circle().fill(Color.green.gradient)
                }
                .frame(width: isThumbnail ? 40 : 52, height: 12)
                .padding(12)
                .accessibilityHidden(true)
            }
            Divider()
            if isThumbnail {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(0..<4) { _ in
                        Capsule().fill(.fill.secondary).frame(width: 60, height: 5)
                    }
                }
                .frame(width: 84)
            } else {
                List(recents, id: \.0, selection: $selection) { name, folder in
                    Label {
                        VStack(alignment: .leading) {
                            Text(name)
                            Text(folder)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    } icon: {
                        Image(systemName: "doc.text")
                    }
                }
                .scrollContentBackground(.hidden)
                .frame(width: 200)
            }
        }
        .frame(width: isThumbnail ? 210 : 480, height: isThumbnail ? 120 : 280)
        .background(.background)
        .clipShape(.rect(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(.separator)
        }
        .shadow(color: .black.opacity(0.18), radius: 10, y: 4)
    }
}
