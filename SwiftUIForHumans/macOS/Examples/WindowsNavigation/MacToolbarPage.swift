import SwiftUI

extension ComponentPage {
    static let toolbar = ComponentPage(
        id: "toolbar",
        title: "Toolbar",
        summary: "Commands, controls, and search at the top of a window, placed by what they do.",
        category: .navigation,
        symbol: "menubar.dock.rectangle",
        availability: ["macOS 11.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/toolbars",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/toolbars",
        aliases: [
            "NSToolbar", "toolbar item", "ToolbarItem", "ToolbarItemGroup", "placement", "principal",
            "primaryAction", "customize toolbar", "toolbar(id:)", "ToolbarSpacer", "navigationSubtitle",
            "subtitle", "title bar", "app bar", "action bar", "header buttons",
        ],
        related: ["search", "navigation-split-view", "button", "menu", "toggle", "commands", "toolbars-pattern"],
        notes: [
            "**Narrow windows move items into an overflow menu.** Choose a few items that matter, so little ends up hidden there.",
            "**Keep window titles short.** The HIG suggests under 15 characters, so the title leaves room for the toolbar's items.",
        ],
        about: "Add `.toolbar { }` to a view in a window, and its items go in the window's toolbar. Give each `ToolbarItem` a placement that says what it's for, like `.navigation` or `.principal`, and SwiftUI puts it where that kind of item belongs on the Mac.\n\nUse `.toolbar(id:)` with an ID on each item to let people customize the toolbar: they Control-click it and choose Customize Toolbar to add, remove, and rearrange items.",
        composition: """
        .toolbar
        ├── ToolbarItem(placement: .navigation)
        ├── ToolbarItem(placement: .principal)
        ├── ToolbarSpacer(.flexible)
        └── ToolbarItemGroup
            └── Button…
        """,
        api: [
            APIItem("`.toolbar { }`", "Adds items to the window's toolbar."),
            APIItem("`ToolbarItem(placement:)`", "One item, placed by its purpose."),
            APIItem("`.navigation`", "Leading edge, before the title: back and forward."),
            APIItem("`.principal`", "The center of the toolbar."),
            APIItem("`.primaryAction`", "The command people use most here."),
            APIItem("`.toolbar(id:)`", "A toolbar people can customize."),
            APIItem("`ToolbarSpacer(.fixed)`", "Space between items or groups (macOS 26)."),
            APIItem("`.navigationSubtitle(_:)`", "A line of context with the title."),
        ],
        guidelines: [
            Guideline(
                "Use symbols, not words.",
                "Simple, familiar symbols are quicker to scan and take less space. Text works better only for actions a symbol can't show, like Edit.",
                good: "Recognizable symbols.",
                bad: "Text labels crowd the toolbar."
            ) {
                MacWindowFrame(title: "Inbox", width: 280, height: 90) {
                    Color.clear
                } toolbar: {
                    Image(systemName: "square.and.pencil")
                    Image(systemName: "archivebox")
                }
            } bad: {
                MacWindowFrame(title: "Inbox", width: 280, height: 90) {
                    Color.clear
                } toolbar: {
                    Text("Compose").font(.callout).fixedSize()
                    Text("Archive").font(.callout).fixedSize()
                }
            },
            Guideline(
                "Title the window after its content, not your app.",
                "A title like the mailbox or document name tells people where they are. The app's name tells them nothing about what's in the window.",
                good: "The title names what's showing.",
                bad: "The app's name says nothing new."
            ) {
                MacWindowFrame(title: "Inbox", width: 250, height: 90) {
                    Color.clear
                } toolbar: {
                    Image(systemName: "square.and.pencil")
                }
            } bad: {
                MacWindowFrame(title: "MailPro", width: 250, height: 90) {
                    Color.clear
                } toolbar: {
                    Image(systemName: "square.and.pencil")
                }
            },
            Guideline(
                "Put every toolbar command in the menu bar too.",
                "People can hide or customize the toolbar, so it can't be the only home for a command."
            ),
            Guideline(
                "Keep it to a few groups.",
                "Group items by what they do, and aim for no more than three groups. Too many makes the toolbar feel cluttered."
            ),
        ]
    ) {
        MacWindowFrame(title: "Inbox", width: 200, height: 90) {
            Color.clear
        } toolbar: {
            Image(systemName: "square.and.pencil")
            Image(systemName: "trash")
        }
    } content: { page in
        MacToolbarArticle(page: page)
    }
}

extension Catalog {
    /// Real toolbars: every placement, and a customizable one.
    static let toolbarDemoWindows = [
        DemoWindow(id: "toolbar-placements", title: "Inbox", size: CGSize(width: 720, height: 360)) {
            PlacementsSample()
        },
        DemoWindow(id: "toolbar-customizable", title: "Editor", size: CGSize(width: 720, height: 360)) {
            CustomizableSample()
        },
    ]
}

// MARK: - Page

private struct MacToolbarArticle: View {
    let page: ComponentPage

    var body: some View {
        ArticlePage(page: page) {
            if let about = page.about {
                AboutSection(text: about)
            }
            HStack(spacing: 12) {
                OpenDemoWindowButton(id: "toolbar-placements", label: "Open the Placements Window")
                OpenDemoWindowButton(id: "toolbar-customizable", label: "Open a Customizable Toolbar")
            }
            .controlSize(.large)

            SectionTitle("Usage")
                .id("code")
            CodeBlock(code: """
            List(["Lunch on Friday?", "Your receipt"], id: \\.self) { subject in
                Text(subject)
            }
            .navigationTitle("Inbox")
            .toolbar {
                Button("New Message", systemImage: "square.and.pencil") { }
            }
            """)

            if let composition = page.composition {
                CompositionSection(tree: composition)
            }

            SectionTitle("Examples")
                .id("examples")
            ExampleCard(
                title: "Placements",
                caption: "`.navigation` items go at the leading edge before the title, and `.principal` items sit in the center. Mark the command people use most `.primaryAction`.",
                code: """
                @State private var filter = "All"

                List(["Lunch on Friday?", "Your receipt"], id: \\.self) { Text($0) }
                    .navigationTitle("Inbox")
                    .navigationSubtitle("12 messages")
                    .toolbar {
                        ToolbarItem(placement: .navigation) {
                            Button("Back", systemImage: "chevron.left") { }
                        }
                        ToolbarItem(placement: .principal) {
                            Picker("Filter", selection: $filter) {
                                Text("All").tag("All")
                                Text("Unread").tag("Unread")
                            }
                            .pickerStyle(.segmented)
                        }
                        ToolbarItem(placement: .primaryAction) {
                            Button("New Message", systemImage: "square.and.pencil") { }
                        }
                    }
                """,
                minHeight: 220,
                aside: Aside(.note, "A real `.toolbar` in a page would land in this app's own toolbar, so the preview draws one. The Placements window above shows the real thing.")
            ) {
                PlacementsSketch()
            }

            ExampleCard(
                title: "A toolbar people can customize",
                caption: "Give `.toolbar(id:)` and every `ToolbarItem` an ID. Control-click the toolbar in the window to customize it.",
                code: """
                @State private var isBold = false
                @State private var isItalic = false

                TextEditor(text: .constant("Hello"))
                    .toolbar(id: "editor") {
                        ToolbarItem(id: "bold") {
                            Toggle("Bold", systemImage: "bold", isOn: $isBold)
                        }
                        ToolbarItem(id: "italic") {
                            Toggle("Italic", systemImage: "italic", isOn: $isItalic)
                        }
                        ToolbarSpacer(.fixed)
                        ToolbarItem(id: "share") {
                            ShareLink(item: "Hello")
                        }
                    }
                """,
                minHeight: 150,
                aside: Aside(.note, "Add `ToolbarCommands()` to your scene's `.commands` to put a Customize Toolbar item in the View menu too.")
            ) {
                VStack(spacing: 12) {
                    OpenDemoWindowButton(id: "toolbar-customizable", label: "Open a Customizable Toolbar")
                    Text("Customization needs a real window, so this opens one.")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
            }

            ExampleCard(
                title: "Space between groups",
                caption: "`ToolbarSpacer(.fixed)` adds a standard gap, and `.flexible` pushes items apart. Keep text-labeled buttons apart so they don't read as one.",
                code: """
                List(["Notes"], id: \\.self) { Text($0) }
                    .toolbar {
                        ToolbarItem {
                            Button("Share", systemImage: "square.and.arrow.up") { }
                        }
                        ToolbarSpacer(.fixed)
                        ToolbarItem {
                            Button("Delete", systemImage: "trash") { }
                        }
                    }
                """,
                minHeight: 150
            ) {
                MacWindowFrame(title: "Notes", width: 360, height: 110) {
                    Color.clear
                } toolbar: {
                    Image(systemName: "square.and.arrow.up")
                    Spacer()
                        .frame(width: 10)
                    Image(systemName: "trash")
                }
            }
        }
    }
}

// MARK: - Samples

/// A drawn toolbar with the main placements: a navigation item at the
/// leading edge, a title and subtitle, a principal control in the center,
/// and a trailing item.
private struct PlacementsSketch: View {
    @State private var filter = "All"

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                HStack(spacing: 12) {
                    WindowsNavWindowButtons()
                    Image(systemName: "chevron.left")
                        .imageScale(.large)
                        .foregroundStyle(.secondary)
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Inbox")
                            .font(.headline)
                        Text("12 messages")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Image(systemName: "square.and.pencil")
                        .imageScale(.large)
                        .foregroundStyle(.secondary)
                }
                Picker("Filter", selection: $filter) {
                    Text("All").tag("All")
                    Text("Unread").tag("Unread")
                }
                .pickerStyle(.segmented)
                .labelsHidden()
                .frame(width: 110)
            }
            .padding(.horizontal, 14)
            .frame(height: 52)
            .background(.bar)
            Divider()
            VStack(alignment: .leading, spacing: 0) {
                ForEach(filter == "All" ? ["Lunch on Friday?", "Your receipt", "Trip photos"] : ["Lunch on Friday?"], id: \.self) { subject in
                    Text(subject)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 7)
                    Divider()
                        .padding(.leading, 14)
                }
                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(width: 480, height: 190)
        .windowsNavChrome()
    }
}

/// The placements window: a real toolbar with each placement.
private struct PlacementsSample: View {
    @State private var filter = "All"

    var body: some View {
        List(filter == "All" ? ["Lunch on Friday?", "Your receipt", "Trip photos"] : ["Lunch on Friday?"], id: \.self) { subject in
            Text(subject)
        }
        .navigationTitle("Inbox")
        .navigationSubtitle("12 messages")
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button("Back", systemImage: "chevron.left") { }
            }
            ToolbarItem(placement: .principal) {
                Picker("Filter", selection: $filter) {
                    Text("All").tag("All")
                    Text("Unread").tag("Unread")
                }
                .pickerStyle(.segmented)
            }
            ToolbarItem(placement: .primaryAction) {
                Button("New Message", systemImage: "square.and.pencil") { }
            }
        }
    }
}

/// The customizable window: Control-click the toolbar to customize it.
private struct CustomizableSample: View {
    @State private var text = "Control-click the toolbar to customize it."
    @State private var isBold = false
    @State private var isItalic = false

    var body: some View {
        TextEditor(text: $text)
            .font(.title3.weight(isBold ? .bold : .regular))
            .italic(isItalic)
            .padding(8)
            .toolbar(id: "editor") {
                ToolbarItem(id: "bold") {
                    Toggle("Bold", systemImage: "bold", isOn: $isBold)
                }
                ToolbarItem(id: "italic") {
                    Toggle("Italic", systemImage: "italic", isOn: $isItalic)
                }
                ToolbarSpacer(.fixed)
                ToolbarItem(id: "share") {
                    ShareLink(item: text)
                }
            }
    }
}
