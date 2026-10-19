import SwiftUI

extension ComponentPage {
    static let inspector = ComponentPage(
        id: "inspector",
        title: "Inspector",
        summary: "A trailing column that shows and edits the details of whatever is selected.",
        category: .navigation,
        symbol: "sidebar.trailing",
        availability: ["macOS 14.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/view/inspector(ispresented:content:)",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/panels",
        aliases: [
            "inspector", "inspectorColumnWidth", "InspectorCommands", "info panel", "properties panel",
            "attributes inspector", "right sidebar", "trailing sidebar", "details pane", "NSSplitViewItem",
            "Show Inspector", "Control-Command-I", "⌃⌘I",
        ],
        related: ["split-views", "toolbar", "navigation-split-view", "form"],
        notes: [
            "**SwiftUI remembers whether the inspector was open.** When it's a trailing column, its shown or hidden state is restored with the window.",
        ],
        about: "`.inspector(isPresented:content:)` adds a column on the trailing edge of the window, beside your content. It shows the details of the current selection and updates as the selection changes, like the inspector in Keynote.\n\nPut the button that shows and hides it in the toolbar, and add `InspectorCommands` so the menu bar has a command and ⌃⌘I for it too.",
        composition: """
        NavigationStack
        └── Editor
            ├── .toolbar
            │   └── Button("Inspector")
            └── .inspector
                └── Form
        """,
        api: [
            APIItem("`.inspector(isPresented:content:)`", "Adds a trailing inspector column."),
            APIItem("`.inspectorColumnWidth(min:ideal:max:)`", "A width people can drag within."),
            APIItem("`.inspectorColumnWidth(_:)`", "A fixed width."),
            APIItem("`InspectorCommands()`", "A menu command with ⌃⌘I."),
            APIItem("`.interactiveDismissDisabled()`", "Keeps people from dragging it shut."),
        ],
        guidelines: [
            Guideline(
                "Show the details of the current selection.",
                "An inspector follows the selection: pick another item and it updates. For details that shouldn't change, open a separate window instead."
            ),
            Guideline(
                "Keep it on the trailing side, with its button at the trailing end of the toolbar.",
                "That's where people expect to find both. Toolbar items at the trailing end stay visible at every window size."
            ),
            Guideline(
                "Prefer controls that adjust in one step.",
                "Sliders and steppers change a value right away. Typing in a text field, or picking an item from a list, takes more steps.",
                good: "A slider and a stepper adjust directly.",
                bad: "Typing values takes extra steps."
            ) {
                Form {
                    Slider(value: .constant(0.6)) { Text("Opacity") }
                    Stepper("Border: 2 pt", value: .constant(2))
                }
                .formStyle(.columns)
                .frame(width: 230)
            } bad: {
                Form {
                    TextField("Opacity", text: .constant("0.6"))
                    TextField("Border", text: .constant("2 pt"))
                }
                .formStyle(.columns)
                .frame(width: 230)
            },
        ]
    ) {
        HStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 4)
                .fill(.background)
            Divider()
            VStack(alignment: .leading, spacing: 5) {
                ForEach(0..<3) { _ in
                    Capsule().fill(.fill.secondary).frame(width: 30, height: 5)
                }
            }
            .padding(6)
            .frame(width: 44, alignment: .topLeading)
            .frame(maxHeight: .infinity, alignment: .top)
            .background(.fill.quaternary)
        }
        .frame(width: 130, height: 80)
        .clipShape(.rect(cornerRadius: 6))
        .overlay(RoundedRectangle(cornerRadius: 6).strokeBorder(.separator))
    } content: { page in
        MacInspectorArticle(page: page)
    }
}

extension Catalog {
    /// A shape editor with a real inspector and toolbar button.
    static let inspectorDemoWindow = DemoWindow(id: "inspector-editor", title: "Shapes", size: CGSize(width: 780, height: 460)) {
        InspectorDemoWindow()
    }
}

// MARK: - Sample data

private struct ShapeItem: Identifiable, Hashable {
    let id: Int
    var name: String
    var color: Color
    var opacity = 1.0
    var cornerRadius = 12.0

    static let samples = [
        ShapeItem(id: 1, name: "Sky", color: .blue),
        ShapeItem(id: 2, name: "Leaf", color: .green, cornerRadius: 30),
        ShapeItem(id: 3, name: "Sun", color: .orange, opacity: 0.8, cornerRadius: 40),
    ]
}

// MARK: - Page

private struct MacInspectorArticle: View {
    let page: ComponentPage

    var body: some View {
        ArticlePage(page: page) {
            if let about = page.about {
                AboutSection(text: about)
            }
            OpenDemoWindowButton(id: "inspector-editor", label: "Open the Inspector Demo")
                .controlSize(.large)

            SectionTitle("Usage")
                .id("code")
            CodeBlock(code: """
            @State private var showsInspector = true

            NavigationStack {
                Text("Canvas")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .inspector(isPresented: $showsInspector) {
                        Form {
                            Text("Details of the selection")
                        }
                        .inspectorColumnWidth(min: 200, ideal: 240, max: 320)
                    }
                    .toolbar {
                        Button("Inspector", systemImage: "sidebar.trailing") {
                            showsInspector.toggle()
                        }
                    }
            }
            """)
            Aside(.note, "A real inspector in this page would open in this app's own window, so the examples below draw the window. The demo window has the real thing.")

            if let composition = page.composition {
                CompositionSection(tree: composition)
            }

            SectionTitle("Examples")
                .id("examples")
            InspectorExamples()

            SectionTitle("Add the menu command")
            Prose("`InspectorCommands` adds a command for showing and hiding the inspector, with the shortcut ⌃⌘I. It's a scene modifier, so it goes in your `App`, not the view.")
            CodeBlock(code: """
            @main
            struct ShapesApp: App {
                var body: some Scene {
                    WindowGroup {
                        EditorView()
                    }
                    .commands {
                        InspectorCommands()
                    }
                }
            }
            """)
        }
    }
}

// MARK: - Examples

private struct InspectorExamples: View {
    @State private var shapes = ShapeItem.samples
    @State private var selection: ShapeItem.ID? = 1
    @State private var showsInspector = true
    @State private var isFixed = false

    var body: some View {
        ExampleCard(
            title: "Toggle it from the toolbar",
            caption: "Bind `isPresented` to a `Bool` and flip it from a button at the trailing end of the toolbar; try it in the drawn toolbar.",
            code: """
            @State private var showsInspector = true

            Text("Canvas")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .inspector(isPresented: $showsInspector) {
                    Text("Inspector")
                }
                .toolbar {
                    Button("Inspector", systemImage: "sidebar.trailing") {
                        showsInspector.toggle()
                    }
                }
            """,
            minHeight: 260
        ) {
            MacWindowFrame(title: "Shapes", width: 460, height: 230) {
                HStack(spacing: 0) {
                    Text("Canvas")
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    if showsInspector {
                        Divider()
                        Text("Inspector")
                            .foregroundStyle(.secondary)
                            .frame(width: 160)
                            .frame(maxHeight: .infinity)
                            .background(.background.secondary)
                            .transition(.move(edge: .trailing))
                    }
                }
                .clipped()
            } toolbar: {
                Button("Inspector", systemImage: "sidebar.trailing") {
                    withAnimation(.snappy) { showsInspector.toggle() }
                }
                .buttonStyle(.borderless)
                .labelStyle(.iconOnly)
            }
        }

        ExampleCard(
            title: "Details that follow the selection",
            caption: "Pass a binding to the selected item into the inspector, so picking another shape switches what it edits.",
            code: """
            @State private var shapes = ShapeItem.samples
            @State private var selection: ShapeItem.ID? = 1
            @State private var showsInspector = true

            List(shapes, selection: $selection) { shape in
                Label(shape.name, systemImage: "square.fill")
                    .foregroundStyle(shape.color)
            }
            .inspector(isPresented: $showsInspector) {
                if let index = shapes.firstIndex(where: { $0.id == selection }) {
                    Form {
                        TextField("Name", text: $shapes[index].name)
                        Slider(value: $shapes[index].opacity, in: 0...1) {
                            Text("Opacity")
                        }
                        Slider(value: $shapes[index].cornerRadius, in: 0...40) {
                            Text("Corners")
                        }
                    }
                } else {
                    ContentUnavailableView("No Selection", systemImage: "square.dashed")
                }
            }
            """,
            minHeight: 280,
            aside: Aside(.note, "`ShapeItem` is a small `Identifiable` struct with a name, color, opacity, and corner radius.")
        ) {
            MacWindowFrame(title: "Shapes", width: 480, height: 250) {
                HStack(spacing: 0) {
                    List(shapes, selection: $selection) { shape in
                        Label(shape.name, systemImage: "square.fill")
                            .foregroundStyle(shape.color)
                    }
                    .frame(width: 130)
                    Divider()
                    ShapeCanvas(shape: shapes.first { $0.id == selection })
                    Divider()
                    ShapeInspector(shapes: $shapes, selection: selection)
                        .frame(width: 200)
                        .background(.background.secondary)
                }
            }
        }

        ExampleCard(
            title: "A width people can drag, or a fixed one",
            caption: "`.inspectorColumnWidth` with `min`, `ideal`, and `max` lets people resize the column within limits, and one number fixes the width.",
            code: """
            @State private var showsInspector = true

            Text("Canvas")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .inspector(isPresented: $showsInspector) {
                    Form {
                        Text("Details")
                    }
                    .inspectorColumnWidth(min: 200, ideal: 240, max: 320)
                    // Or a fixed width that people can't drag shut:
                    // .inspectorColumnWidth(240)
                    // .interactiveDismissDisabled()
                }
            """,
            minHeight: 240,
            aside: Aside(.important, "On the Mac, people can drag an inspector closed even at a fixed width. Add `.interactiveDismissDisabled()` to prevent it.")
        ) {
            VStack(spacing: 12) {
                MacWindowFrame(title: "Shapes", width: 460, height: 170) {
                    HStack(spacing: 0) {
                        Text("Canvas")
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        Divider()
                        VStack(spacing: 4) {
                            Text("Inspector")
                            Text(isFixed ? "240 pt, fixed" : "200–320 pt, ideal 240")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .frame(width: isFixed ? 200 : 180)
                        .frame(maxHeight: .infinity)
                        .background(.background.secondary)
                    }
                }
                Picker("Width", selection: $isFixed) {
                    Text("Flexible").tag(false)
                    Text("Fixed").tag(true)
                }
                .pickerStyle(.segmented)
                .fixedSize()
            }
        }
    }
}

private struct ShapeCanvas: View {
    let shape: ShapeItem?

    var body: some View {
        ZStack {
            if let shape {
                RoundedRectangle(cornerRadius: shape.cornerRadius)
                    .fill(shape.color.gradient)
                    .opacity(shape.opacity)
                    .frame(width: 90, height: 90)
            } else {
                Text("No Selection").foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct ShapeInspector: View {
    @Binding var shapes: [ShapeItem]
    let selection: ShapeItem.ID?

    var body: some View {
        if let index = shapes.firstIndex(where: { $0.id == selection }) {
            Form {
                TextField("Name", text: $shapes[index].name)
                Slider(value: $shapes[index].opacity, in: 0...1) {
                    Text("Opacity")
                }
                Slider(value: $shapes[index].cornerRadius, in: 0...40) {
                    Text("Corners")
                }
            }
            .formStyle(.grouped)
            .scrollContentBackground(.hidden)
        } else {
            ContentUnavailableView("No Selection", systemImage: "square.dashed")
        }
    }
}

// MARK: - Demo window

private struct InspectorDemoWindow: View {
    @State private var shapes = ShapeItem.samples
    @State private var selection: ShapeItem.ID? = 1
    @State private var showsInspector = true

    var body: some View {
        HSplitView {
            List(shapes, selection: $selection) { shape in
                Label(shape.name, systemImage: "square.fill")
                    .foregroundStyle(shape.color)
            }
            .frame(minWidth: 140, idealWidth: 170, maxWidth: 240)
            ShapeCanvas(shape: shapes.first { $0.id == selection })
                .frame(minWidth: 240)
        }
        .inspector(isPresented: $showsInspector) {
            ShapeInspector(shapes: $shapes, selection: selection)
                .inspectorColumnWidth(min: 200, ideal: 240, max: 320)
        }
        .toolbar {
            Button("Inspector", systemImage: "sidebar.trailing") {
                showsInspector.toggle()
            }
            .help(showsInspector ? "Hide the inspector" : "Show the inspector")
        }
    }
}
