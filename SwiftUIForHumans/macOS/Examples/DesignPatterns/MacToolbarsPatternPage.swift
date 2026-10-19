import SwiftUI

extension ComponentPage {
    static let toolbarsPattern = ComponentPage(
        id: "toolbars-pattern",
        title: "Toolbars",
        summary: "Which commands earn a place in the toolbar, how to group them, and letting people customize.",
        category: .patterns,
        kind: .concept,
        symbol: "menubar.dock.rectangle",
        availability: ["macOS 13.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/toolbars",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/toolbars",
        aliases: [
            "NSToolbar", "toolbar items", "customize toolbar", "toolbar customization", "toolbar(id:)",
            "ToolbarItem", "ToolbarSpacer", "toolbar placement", "window title", "overflow menu",
            "primaryAction", "principal",
        ],
        related: ["toolbar", "menu-bar-conventions", "search", "inspector", "full-screen"],
        notes: [
            "**On the Mac, `.primaryAction` sits at the leading edge.** On iPhone and iPad it's at the trailing edge, so check placements when you bring an iPad toolbar over.",
            "**Overflow is automatic.** When a window gets too narrow, the system moves center items into an overflow menu. Don't build your own.",
        ],
        api: [
            APIItem("`.toolbar(id:content:)`", "A toolbar people can customize."),
            APIItem("`ToolbarItem(id:placement:)`", "One item, with an ID for customization."),
            APIItem("`ToolbarSpacer(.fixed)`", "A gap between groups of items."),
            APIItem("`.navigation`", "Leading edge, before the title."),
            APIItem("`.principal`", "The center of the toolbar."),
            APIItem("`ToolbarCommands()`", "Adds the toolbar's menu items, like Customize."),
        ],
        guidelines: [
            Guideline(
                "Put the commands people use most in the toolbar.",
                "Not every menu item needs a button. Pick the frequent ones, or the ones for the most important things people work with."
            ),
            Guideline(
                "Make every toolbar item a menu command too.",
                "People can hide or customize the toolbar, so it can't be the only place a command lives."
            ),
            Guideline(
                "Use plain symbols.",
                "Toolbar items don't need outlines or circles: the toolbar already groups them, and the system draws hover and selection.",
                good: "Plain symbols.",
                bad: "Circled symbols that add noise."
            ) {
                DPToolbarSymbols(symbols: ["square.and.arrow.up", "trash"])
            } bad: {
                DPToolbarSymbols(symbols: ["square.and.arrow.up.circle", "trash.circle"])
            },
            Guideline(
                "Title the window with its content, not your app's name.",
                "The title tells people where they are and tells windows apart. Keep it short, under about 15 characters.",
                good: "The note's name.",
                bad: "The app's name."
            ) {
                MacWindowFrame(title: "Trip Notes", width: 230, height: 90) {
                    Color.clear
                } toolbar: {
                    Image(systemName: "square.and.pencil")
                }
            } bad: {
                MacWindowFrame(title: "Scribble", width: 230, height: 90) {
                    Color.clear
                } toolbar: {
                    Image(systemName: "square.and.pencil")
                }
            },
            Guideline(
                "Keep groups few and logical.",
                "Group items by what they do, and aim for no more than three groups. Separate text buttons with space so they don't read as one."
            ),
            Guideline(
                "Let people customize toolbars in apps they live in.",
                "If you offer many items, or people use the app for hours, let them choose what's in the center."
            ),
        ],
        sources: [
            "https://developer.apple.com/design/human-interface-guidelines/toolbars",
            "https://developer.apple.com/documentation/swiftui/toolbars",
            "https://developer.apple.com/documentation/swiftui/view/toolbar(id:content:)",
            "https://developer.apple.com/documentation/swiftui/toolbarspacer",
            "https://developer.apple.com/documentation/swiftui/toolbaritemplacement/primaryaction",
            "https://developer.apple.com/documentation/swiftui/toolbaritemplacement/navigation",
            "https://developer.apple.com/documentation/swiftui/toolbaritemplacement/principal",
            "https://developer.apple.com/documentation/swiftui/toolbarcommands",
        ],
        reviewed: "October 2026"
    ) {
        MacWindowFrame(title: "Notes", width: 200, height: 100) {
            Color.clear
        } toolbar: {
            Image(systemName: "bold")
            Image(systemName: "square.and.arrow.up")
        }
        .accessibilityHidden(true)
    } content: { page in
        MacToolbarsPatternArticle(page: page)
    }
}

extension Catalog {
    /// A real window with a customizable toolbar.
    static let toolbarsPatternDemoWindow = DemoWindow(id: "dp-toolbar-editor", title: "Trip Notes", size: CGSize(width: 620, height: 380)) {
        CustomizableEditorSample()
    }
}

// MARK: - Page

private struct MacToolbarsPatternArticle: View {
    let page: ComponentPage

    var body: some View {
        ArticlePage(page: page) {
            Prose("On the Mac, the toolbar sits at the top of the window, in or below the title bar. It holds the window's title, controls for getting around, and the actions people use most. Because people can hide it or customize it, the toolbar is a shortcut to commands that also live in the menu bar, never the only way to reach them.")

            VStack(alignment: .leading, spacing: 16) {
                SectionTitle("Three areas")
                Prose("Pick an area to see what the HIG puts there.")
                ToolbarAreas()
            }
            .id("demo")

            VStack(alignment: .leading, spacing: 16) {
                SectionTitle("Try a real one")
                Prose("This window's toolbar can be customized. Control-click the toolbar and choose **Customize Toolbar…**, then drag items in and out.")
                OpenDemoWindowButton(id: "dp-toolbar-editor", label: "Open the Editor")
                    .controlSize(.large)
            }

            VStack(alignment: .leading, spacing: 16) {
                SectionTitle("Examples")
                    .id("examples")
                Aside(.note, "A real `.toolbar` here would land in this app's own toolbar, so the previews draw the window. The editor above uses the first example's code.")
                VStack(alignment: .leading, spacing: 44) {
                    ExampleCard(
                        title: "A toolbar people can customize",
                        caption: "Use `.toolbar(id:)` and give each `ToolbarItem` an ID. `ToolbarSpacer(.fixed)` separates the groups.",
                        code: """
                        @State private var text = ""
                        @State private var isBold = false
                        @State private var isItalic = false

                        TextEditor(text: $text)
                            .toolbar(id: "editor") {
                                ToolbarItem(id: "bold") {
                                    Toggle("Bold", systemImage: "bold", isOn: $isBold)
                                }
                                ToolbarItem(id: "italic") {
                                    Toggle("Italic", systemImage: "italic", isOn: $isItalic)
                                }
                                ToolbarSpacer(.fixed)
                                ToolbarItem(id: "share") {
                                    Button("Share", systemImage: "square.and.arrow.up") { }
                                }
                            }
                            .navigationTitle("Trip Notes")
                        """,
                        minHeight: 200,
                        aside: Aside(.note, "To offer customization in the menu bar too, add `ToolbarCommands()` to the scene's `.commands`.")
                    ) {
                        MacWindowFrame(title: "Trip Notes", width: 440, height: 160) {
                            Text("Pack the hiking boots.")
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                                .padding(14)
                        } toolbar: {
                            Image(systemName: "bold")
                            Image(systemName: "italic")
                            Spacer().frame(width: 10)
                            Image(systemName: "square.and.arrow.up")
                        }
                    }

                    ExampleCard(
                        title: "Place items by role",
                        caption: "`.navigation` goes at the leading edge, before the title, and `.principal` in the center.",
                        code: """
                        Text("Page")
                            .toolbar {
                                ToolbarItem(placement: .navigation) {
                                    Button("Back", systemImage: "chevron.backward") { }
                                }
                                ToolbarItem(placement: .principal) {
                                    Picker("View", selection: .constant(0)) {
                                        Text("Day").tag(0)
                                        Text("Week").tag(1)
                                    }
                                    .pickerStyle(.segmented)
                                }
                            }
                        """,
                        minHeight: 140
                    ) {
                        DPPlacementStrip()
                    }

                    ExampleCard(
                        title: "The same command in the menu bar",
                        caption: "Give each toolbar action a menu item, with a shortcut if it's frequent, so it works with the toolbar hidden.",
                        code: """
                        .commands {
                            CommandMenu("Note") {
                                Button("Share Note…") { }
                                Button("Show Note Info") { }
                                    .keyboardShortcut("i")
                            }
                        }
                        """,
                        minHeight: 150
                    ) {
                        DPMenuDrawing(title: "Note", items: [
                            .item("Share Note…", highlighted: true),
                            .item("Show Note Info", "⌘I"),
                        ])
                    }
                }
            }
        }
    }
}

// MARK: - Areas diagram

private enum ToolbarArea: String, CaseIterable, Identifiable {
    case leading = "Leading"
    case center = "Center"
    case trailing = "Trailing"

    var id: Self { self }

    var about: String {
        switch self {
        case .leading: "Going back, showing the sidebar, then the title, and a document menu for things like Rename and Export. People can't customize this area, so it's always there."
        case .center: "Common, useful controls. People can add, remove, and rearrange them, and they move into an overflow menu as the window narrows."
        case .trailing: "Items that must stay visible at every width: buttons that open an inspector, search, and a primary action like Done."
        }
    }
}

/// A drawn toolbar split into its three areas. Pick one to highlight it.
private struct ToolbarAreas: View {
    @State private var area = ToolbarArea.center

    var body: some View {
        DPPanel {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 8) {
                    HStack(spacing: 8) {
                        ForEach([Color.red, .yellow, .green], id: \.self) { color in
                            Circle().fill(color.gradient).frame(width: 12, height: 12)
                        }
                    }
                    .padding(.trailing, 6)
                    group(.leading) {
                        Image(systemName: "sidebar.left")
                        Image(systemName: "chevron.backward")
                        Text("Trip Notes").font(.headline)
                    }
                    Spacer(minLength: 8)
                    group(.center) {
                        Image(systemName: "bold")
                        Image(systemName: "italic")
                        Image(systemName: "photo")
                        Image(systemName: "link")
                    }
                    Spacer(minLength: 8)
                    group(.trailing) {
                        Image(systemName: "magnifyingglass")
                        Image(systemName: "sidebar.right")
                    }
                }
                .imageScale(.large)
                .padding(.horizontal, 12)
                .frame(height: 52)
                .background(.bar, in: .rect(cornerRadius: 10))
                .overlay {
                    RoundedRectangle(cornerRadius: 10).strokeBorder(.separator)
                }

                Picker("Area", selection: $area) {
                    ForEach(ToolbarArea.allCases) { area in
                        Text(area.rawValue).tag(area)
                    }
                }
                .pickerStyle(.segmented)
                .labelsHidden()
                .frame(maxWidth: 320)

                Text(area.about)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: 560, alignment: .leading)
            }
        }
    }

    private func group<Content: View>(_ area: ToolbarArea, @ViewBuilder content: () -> Content) -> some View {
        HStack(spacing: 12) {
            content()
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .foregroundStyle(self.area == area ? AnyShapeStyle(.primary) : AnyShapeStyle(.secondary))
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(self.area == area ? Color.accentColor : .clear, lineWidth: 2)
        }
    }
}

// MARK: - Samples

/// The demo window's editor, using the first example's code.
private struct CustomizableEditorSample: View {
    @State private var text = "Pack the hiking boots."
    @State private var isBold = false
    @State private var isItalic = false

    var body: some View {
        TextEditor(text: $text)
            .font(.body.weight(isBold ? .bold : .regular))
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
                    Button("Share", systemImage: "square.and.arrow.up") { }
                }
            }
    }
}

/// A drawn toolbar showing where `.navigation` and `.principal` land.
private struct DPPlacementStrip: View {
    var body: some View {
        HStack(spacing: 10) {
            HStack(spacing: 8) {
                ForEach([Color.red, .yellow, .green], id: \.self) { color in
                    Circle().fill(color.gradient).frame(width: 12, height: 12)
                }
            }
            Image(systemName: "chevron.backward")
                .foregroundStyle(.secondary)
            Text("Page").font(.headline)
            Spacer()
            Picker("View", selection: .constant(0)) {
                Text("Day").tag(0)
                Text("Week").tag(1)
            }
            .pickerStyle(.segmented)
            .labelsHidden()
            .fixedSize()
            Spacer()
        }
        .padding(.horizontal, 12)
        .frame(width: 440, height: 48)
        .background(.bar, in: .rect(cornerRadius: 10))
        .overlay {
            RoundedRectangle(cornerRadius: 10).strokeBorder(.separator)
        }
    }
}

/// Three toolbar symbols in a small drawn window.
private struct DPToolbarSymbols: View {
    let symbols: [String]

    var body: some View {
        MacWindowFrame(title: "Notes", width: 250, height: 90) {
            Color.clear
        } toolbar: {
            ForEach(symbols, id: \.self) { symbol in
                Image(systemName: symbol)
            }
        }
    }
}
