import SwiftUI

extension ComponentPage {
    static let sheet = ComponentPage(
        id: "sheet",
        title: "Sheet",
        summary: "Slides a view up over the current screen for a focused task, at full or partial height.",
        category: .presentation,
        symbol: "rectangle.bottomhalf.inset.filled",
        availability: ["iOS 13.0+", "macOS 10.15+", "visionOS 1.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/view/sheet(ispresented:ondismiss:content:)",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/sheets",
        aliases: ["modal", "dialog", "bottom sheet", "drawer", "half sheet", "overlay", "present", "UISheetPresentationController", "fullscreen modal"],
        related: ["alert", "popover", "confirmation-dialog", "navigation-stack"],
        notes: [
            "**On iPad a sheet floats as a card.** `.presentationSizing` (iOS 18) sets its size, like `.form` or `.page`.",
            "**A sheet's content is a new screen.** It doesn't inherit the parent's navigation bar, so wrap it in a `NavigationStack` for a title and buttons.",
        ],
        about: """
        A sheet slides a view up over the current screen for a focused task, like composing a message or editing a record. It's driven by state: set a `Bool` to `true` to show it, and swiping down sets it back to `false`.

        Use a push in a [NavigationStack](catalog://navigation-stack) to drill deeper, an [Alert](catalog://alert) for a short question, and `.fullScreenCover` for long or immersive tasks like a camera.
        """,
        composition: """
        .sheet(isPresented:)
        └── NavigationStack
            └── Sheet content
                ├── .toolbar
                │   ├── Cancel
                │   └── Done
                └── .presentationDetents
        """,
        api: [
            APIItem("`.sheet(isPresented:)`", "Shows the sheet while a `Bool` is `true`."),
            APIItem("`.sheet(item:)`", "Shows the sheet for an optional `Identifiable` value."),
            APIItem("`@Environment(\\.dismiss)`", "Closes the sheet from inside it."),
            APIItem("`.presentationDetents(_:)`", "Heights it rests at: `.medium`, `.large`, `.height(_:)`."),
            APIItem("`.presentationDragIndicator(_:)`", "Shows or hides the grabber."),
            APIItem("`.interactiveDismissDisabled(_:)`", "Stops swipe to dismiss, for unsaved changes."),
            APIItem("`.fullScreenCover(isPresented:)`", "Covers the whole screen instead."),
        ],
        guidelines: [
            Guideline(
                "Pair Done with Cancel.",
                "Cancel on the leading side lets people leave without saving. A lone Done makes finishing the task feel like the only way out.",
                good: "Cancel and Done give a clear way out.",
                bad: "Done alone traps people in the task."
            ) {
                SheetBarSample(hasCancel: true)
            } bad: {
                SheetBarSample(hasCancel: false)
            },
            Guideline(
                "Use the medium detent for quick content.",
                "A half-height sheet keeps the screen behind it in view, like the share sheet. Use full height for writing, like a new message."
            ),
            Guideline(
                "Show one sheet at a time.",
                "A sheet over a sheet makes people lose their place. Close the first one before opening another."
            ),
            Guideline(
                "Let people swipe to dismiss.",
                "People expect it. If there are unsaved changes, block the swipe with `.interactiveDismissDisabled` and ask before discarding."
            ),
        ]
    ) {
        SheetThumbnail()
    } content: { page in
        SheetDemo(page: page)
    }
}

private struct SheetConfig {
    var kind: SheetKind = .sheet
    var detents: SheetDetents = .mediumLarge
    var dragIndicator: SheetDragIndicator = .automatic
    var backgroundInteraction = false
    var dismissDisabled = false
    var isPresented = false
}

private struct SheetDemo: View {
    let page: ComponentPage

    var body: some View {
        DemoPage(
            page: page,
            initial: SheetConfig(),
            previewHeight: 200,
            usage: """
            @State private var isPresented = false

            Button("Show Details") {
                isPresented = true
            }
            .sheet(isPresented: $isPresented) {
                Text("Details")
                    .presentationDetents([.medium, .large])
            }
            """,
            usageNote: Aside(.important, "Put `.sheet` on a view that stays on screen, like the button. If the view it's attached to disappears, the sheet closes with it.")
        ) { $config in
            Button(config.kind == .sheet ? "Show Sheet" : "Show Full Screen") {
                config.isPresented = true
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .modifier(SheetPresenter(config: $config))
        } controls: { $config in
            Section("Presentation") {
                OptionPicker("Kind", selection: $config.kind)
                Toggle("Disable swipe to dismiss", isOn: $config.dismissDisabled)
            }
            if config.kind == .sheet {
                Section("Sheet") {
                    OptionPicker("Detents", selection: $config.detents)
                    OptionPicker("Drag indicator", selection: $config.dragIndicator)
                    Toggle("Background interaction", isOn: $config.backgroundInteraction)
                }
            }
        } code: { config in
            code(for: config)
        } examples: {
            SheetExamples()
        }
    }

    private func code(for config: SheetConfig) -> String {
        var lines = [
            "@State private var isPresented = false",
            "",
            "Button(\(config.kind == .sheet ? "\"Show Sheet\"" : "\"Show Full Screen\"")) {",
            "    isPresented = true",
            "}",
            ".buttonStyle(.borderedProminent)",
            config.kind == .sheet ? ".sheet(isPresented: $isPresented) {" : ".fullScreenCover(isPresented: $isPresented) {",
            "    SheetContent()",
        ]
        if config.kind == .sheet {
            if config.detents != .large {
                lines.append("        .presentationDetents(\(config.detents.code))")
            }
            if config.dragIndicator != .automatic {
                lines.append("        .presentationDragIndicator(\(config.dragIndicator.label))")
            }
            if config.backgroundInteraction {
                lines.append("        .presentationBackgroundInteraction(.enabled)")
            }
        }
        if config.dismissDisabled {
            lines.append("        .interactiveDismissDisabled()")
        }
        lines += [
            "}",
            "",
            "struct SheetContent: View {",
            "    @Environment(\\.dismiss) private var dismiss",
            "",
            "    var body: some View {",
            "        NavigationStack {",
            "            Text(\"Hello from the sheet\")",
            "                .navigationTitle(\"Sheet\")",
            "                .navigationBarTitleDisplayMode(.inline)",
            "                .toolbar {",
            "                    Button(\"Done\", role: .close) { dismiss() }",
            "                }",
            "        }",
            "    }",
            "}",
        ]
        return lines.joined(separator: "\n")
    }
}

private struct SheetPresenter: ViewModifier {
    @Binding var config: SheetConfig

    func body(content: Content) -> some View {
        content
            .sheet(isPresented: config.kind == .sheet ? $config.isPresented : .constant(false)) {
                SheetContent()
                    .presentationDetents(config.detents.value)
                    .presentationDragIndicator(config.dragIndicator.value)
                    .presentationBackgroundInteraction(config.backgroundInteraction ? .enabled : .automatic)
                    .interactiveDismissDisabled(config.dismissDisabled)
            }
            .fullScreenCover(isPresented: config.kind == .fullScreenCover ? $config.isPresented : .constant(false)) {
                SheetContent()
                    .interactiveDismissDisabled(config.dismissDisabled)
            }
    }
}

private struct SheetContent: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Text("Hello from the sheet")
                .navigationTitle("Sheet")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    Button("Done", role: .close) { dismiss() }
                }
        }
    }
}

private struct SheetThumbnail: View {
    var body: some View {
        ZStack(alignment: .bottom) {
            LinearGradient(colors: [.blue.opacity(0.25), .teal.opacity(0.2)], startPoint: .top, endPoint: .bottom)
            VStack(spacing: 8) {
                Capsule()
                    .fill(.secondary)
                    .frame(width: 36, height: 5)
                    .padding(.top, 8)
                Text("Sheet")
                    .font(.headline)
                RoundedRectangle(cornerRadius: 6)
                    .fill(.fill.tertiary)
                    .frame(height: 12)
                    .padding(.horizontal, 24)
                RoundedRectangle(cornerRadius: 6)
                    .fill(.fill.tertiary)
                    .frame(height: 12)
                    .padding(.horizontal, 40)
                Spacer(minLength: 0)
            }
            .frame(width: 200, height: 100)
            .background(.background, in: UnevenRoundedRectangle(topLeadingRadius: 22, topTrailingRadius: 22))
            .shadow(color: .black.opacity(0.15), radius: 10, y: -2)
        }
    }
}

// MARK: - Examples

private struct SheetExamples: View {
    @State private var selected: SheetItem?
    @State private var showCompact = false
    @State private var showEditor = false

    var body: some View {
        ExampleCard(
            title: "Cancel and Done buttons",
            caption: "Read `@Environment(\\.dismiss)` inside the sheet and call `dismiss()` from its toolbar buttons.",
            code: """
            @State private var showEditor = false

            Button("New Event") { showEditor = true }
                .sheet(isPresented: $showEditor) {
                    EventEditor()
                }

            struct EventEditor: View {
                @Environment(\\.dismiss) private var dismiss
                @State private var title = ""

                var body: some View {
                    NavigationStack {
                        Form {
                            TextField("Title", text: $title)
                        }
                        .navigationTitle("New Event")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) {
                                Button("Cancel", role: .cancel) { dismiss() }
                            }
                            ToolbarItem(placement: .confirmationAction) {
                                Button("Done", role: .confirm) { dismiss() }
                            }
                        }
                    }
                }
            }
            """,
            minHeight: 120,
            aside: Aside(.note, "The sheet doesn't need the `Bool` binding. `dismiss()` closes whatever presented it.")
        ) {
            Button("New Event") { showEditor = true }
                .buttonStyle(.borderedProminent)
                .sheet(isPresented: $showEditor) {
                    SheetEventEditor()
                }
        }

        ExampleCard(
            title: "Sheet for a tapped item",
            caption: "Use `.sheet(item:)` to open a sheet for the tapped thing and pass it in.",
            code: """
            struct Photo: Identifiable {
                let id: String
            }

            @State private var selected: Photo?

            HStack {
                ForEach(["Beach", "Forest", "City"], id: \\.self) { name in
                    Button(name) { selected = Photo(id: name) }
                }
            }
            .buttonStyle(.bordered)
            .sheet(item: $selected) { photo in
                Text(photo.id)
                    .font(.largeTitle)
                    .presentationDetents([.medium])
            }
            """,
            minHeight: 120,
            aside: Aside(.important, "The item must be `Identifiable`. The sheet opens when it's set and closes by setting it back to `nil`.")
        ) {
            HStack {
                ForEach(["Beach", "Forest", "City"], id: \.self) { name in
                    Button(name) { selected = SheetItem(id: name) }
                }
            }
            .buttonStyle(.bordered)
            .sheet(item: $selected) { photo in
                Text(photo.id)
                    .font(.largeTitle)
                    .presentationDetents([.medium])
            }
        }

        ExampleCard(
            title: "Small sheet that fits its content",
            caption: "Use a fixed `.height` detent for a compact panel, like a tip or a quick setting.",
            code: """
            @State private var showTip = false

            Button("Show Tip") { showTip = true }
                .sheet(isPresented: $showTip) {
                    Label("Swipe left on a row to delete it.", systemImage: "lightbulb")
                        .padding()
                        .presentationDetents([.height(160)])
                        .presentationBackground(.yellow.gradient)
                }
            """,
            minHeight: 120,
            aside: Aside(.note, "`.presentationBackground` swaps the default glass for any color or material.")
        ) {
            Button("Show Tip") { showCompact = true }
                .buttonStyle(.bordered)
                .sheet(isPresented: $showCompact) {
                    Label("Swipe left on a row to delete it.", systemImage: "lightbulb")
                        .padding()
                        .presentationDetents([.height(160)])
                        .presentationBackground(.yellow.gradient)
                }
        }
    }
}

private struct SheetItem: Identifiable {
    let id: String
}

private struct SheetEventEditor: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""

    var body: some View {
        NavigationStack {
            Form {
                TextField("Title", text: $title)
            }
            .navigationTitle("New Event")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done", role: .confirm) { dismiss() }
                }
            }
        }
    }
}

/// The top of a sheet, with or without Cancel, for the Done/Cancel guideline.
private struct SheetBarSample: View {
    let hasCancel: Bool
    @State private var title = "Lunch with Maya"

    var body: some View {
        PhoneScreen(width: 270, height: 150) {
            Form {
                TextField("Title", text: $title)
            }
            .navigationTitle("New Event")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if hasCancel {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel", role: .cancel) {}
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done", role: .confirm) {}
                }
            }
        }
    }
}

// MARK: - Options

private enum SheetKind: DemoOption {
    case sheet, fullScreenCover

    var label: String {
        switch self {
        case .sheet: ".sheet"
        case .fullScreenCover: ".fullScreenCover"
        }
    }
}

private enum SheetDetents: DemoOption {
    case large, medium, mediumLarge, fraction, height

    var label: String {
        switch self {
        case .large: "Large (default)"
        case .medium: "Medium"
        case .mediumLarge: "Medium + Large"
        case .fraction: "Fraction 0.25"
        case .height: "Height 200"
        }
    }

    var code: String {
        switch self {
        case .large: "[.large]"
        case .medium: "[.medium]"
        case .mediumLarge: "[.medium, .large]"
        case .fraction: "[.fraction(0.25)]"
        case .height: "[.height(200)]"
        }
    }

    var value: Set<PresentationDetent> {
        switch self {
        case .large: [.large]
        case .medium: [.medium]
        case .mediumLarge: [.medium, .large]
        case .fraction: [.fraction(0.25)]
        case .height: [.height(200)]
        }
    }
}

private enum SheetDragIndicator: DemoOption {
    case automatic, visible, hidden

    var label: String {
        switch self {
        case .automatic: ".automatic"
        case .visible: ".visible"
        case .hidden: ".hidden"
        }
    }

    var value: Visibility {
        switch self {
        case .automatic: .automatic
        case .visible: .visible
        case .hidden: .hidden
        }
    }
}