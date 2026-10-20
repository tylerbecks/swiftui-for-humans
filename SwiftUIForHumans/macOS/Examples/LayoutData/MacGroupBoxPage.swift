import SwiftUI

extension ComponentPage {
    static let groupBox = ComponentPage(
        id: "group-box",
        title: "GroupBox & DisclosureGroup",
        summary: "Box related controls together, and tuck advanced ones under a disclosure triangle.",
        category: .layout,
        symbol: "rectangle.dashed",
        availability: ["macOS 10.15+", "DisclosureGroup macOS 11.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/groupbox",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/boxes",
        aliases: [
            "GroupBox", "DisclosureGroup", "box", "NSBox", "fieldset", "<fieldset>", "<details>", "<summary>",
            "disclosure triangle", "expand", "collapse", "accordion", "advanced options", "show more",
        ],
        related: ["form", "outline", "stacks-grid"],
        notes: [
            "**On the Mac, a box's title sits above the box.** Pass a string or a `Label`; the box sets its content apart from the window around it.",
            "**For a tree of data, don't nest disclosure groups by hand.** `List(children:)` and `OutlineGroup` build the triangles for you; see [Outline lists](catalog://outline).",
        ],
        about: "`GroupBox` draws a rounded background around related content, with an optional title above it. `DisclosureGroup` shows a label with a triangle that hides or shows its content.\n\nUse a box to set a few controls apart inside a larger window, and a disclosure group to keep advanced options out of the way until someone asks for them.",
        composition: """
        GroupBox("Export")
        └── VStack
            ├── Picker("Format")
            └── DisclosureGroup
                ├── Toggle
                └── Toggle
        """,
        api: [
            APIItem("`GroupBox(_:content:)`", "A box with a text title."),
            APIItem("`GroupBox { } label: { }`", "A box with any title view, like a `Label`."),
            APIItem("`DisclosureGroup(_:content:)`", "Content behind a disclosure triangle."),
            APIItem("`DisclosureGroup(_:isExpanded:)`", "Lets you open or close it from code."),
            APIItem("`.disclosureGroupStyle(_:)`", "Replaces the triangle with your own look."),
        ],
        guidelines: [
            Guideline(
                "Show subgroups with space, not boxes inside boxes.",
                "Every box adds a border. Nest them and the window starts to feel busy and cramped; padding and alignment can do the same job.",
                good: "One box; space separates the two groups.",
                bad: "A box inside a box for each group."
            ) {
                GroupBox("Notifications") {
                    VStack(alignment: .leading, spacing: 14) {
                        VStack(alignment: .leading, spacing: 4) {
                            Toggle("Show banners", isOn: .constant(true))
                            Toggle("Play sound", isOn: .constant(false))
                        }
                        VStack(alignment: .leading, spacing: 4) {
                            Toggle("Badge app icon", isOn: .constant(true))
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(width: 220)
            } bad: {
                GroupBox("Notifications") {
                    VStack(alignment: .leading, spacing: 14) {
                        GroupBox {
                            VStack(alignment: .leading, spacing: 4) {
                                Toggle("Show banners", isOn: .constant(true))
                                Toggle("Play sound", isOn: .constant(false))
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        GroupBox {
                            VStack(alignment: .leading, spacing: 4) {
                                Toggle("Badge app icon", isOn: .constant(true))
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
                .frame(width: 220)
            },
            Guideline(
                "Name a disclosure triangle after what it reveals.",
                "A label like “Advanced Options” tells people what they'll find before they open it. “More” makes them click to find out.",
                good: "The label says what's inside.",
                bad: "A vague label hides what's inside."
            ) {
                DisclosureGroup("Advanced Options") {
                    Toggle("Include metadata", isOn: .constant(true))
                }
                .frame(width: 200)
            } bad: {
                DisclosureGroup("More") {
                    Toggle("Include metadata", isOn: .constant(true))
                }
                .frame(width: 200)
            },
            Guideline(
                "Keep a box small next to the window around it.",
                "A box that fills most of the window stops looking like a group and just crowds everything else."
            ),
            Guideline(
                "Title a box with a short phrase in sentence case.",
                "Skip ending punctuation, except in a settings pane, where Mac box titles end with a colon."
            ),
            Guideline(
                "Leave the everyday controls outside the triangle.",
                "Put what most people need where they can see it, and hide only the advanced options."
            ),
        ]
    ) {
        GroupBox("Export") {
            DisclosureGroup("Options") {
                EmptyView()
            }
            .font(.caption)
        }
        .frame(width: 150)
    } content: { page in
        MacGroupBoxDemo(page: page)
    }
}

// MARK: - Demo

private struct MacGroupBoxConfig {
    var title = "Export"
    var titleIcon = false
    var disclosureLabel = "Advanced Options"
    var isExpanded = false
    var format = "PNG"
    var includesMetadata = true
    var usesSRGB = false
}

private struct MacGroupBoxDemo: View {
    let page: ComponentPage

    var body: some View {
        DemoPage(
            page: page,
            initial: MacGroupBoxConfig(),
            usage: """
            @State private var includesMetadata = true

            GroupBox("Export") {
                DisclosureGroup("Advanced Options") {
                    Toggle("Include metadata", isOn: $includesMetadata)
                }
            }
            """
        ) { $config in
            GroupBoxPreview(config: $config)
        } controls: { $config in
            Section("Box") {
                TextField("Title", text: $config.title)
                Toggle("Icon in title", isOn: $config.titleIcon)
            }
            Section("Disclosure group") {
                TextField("Label", text: $config.disclosureLabel)
                Toggle("Expanded", isOn: $config.isExpanded)
            }
        } code: { config in
            var lines = [
                "@State private var format = \(swiftString(config.format))",
                "@State private var isExpanded = \(config.isExpanded)",
                "@State private var includesMetadata = \(config.includesMetadata)",
                "@State private var usesSRGB = \(config.usesSRGB)",
                "",
            ]
            let body = [
                "VStack(alignment: .leading) {",
                "    Picker(\"Format\", selection: $format) {",
                "        ForEach([\"PNG\", \"JPEG\", \"HEIC\"], id: \\.self) { Text($0) }",
                "    }",
                "    DisclosureGroup(\(swiftString(config.disclosureLabel)), isExpanded: $isExpanded) {",
                "        Toggle(\"Include metadata\", isOn: $includesMetadata)",
                "        Toggle(\"Convert to sRGB\", isOn: $usesSRGB)",
                "    }",
                "}",
                ".frame(maxWidth: .infinity, alignment: .leading)",
            ].map { "    " + $0 }
            if config.titleIcon {
                lines.append("GroupBox {")
                lines += body
                lines.append("} label: {")
                lines.append("    Label(\(swiftString(config.title)), systemImage: \"square.and.arrow.up\")")
                lines.append("}")
            } else {
                lines.append("GroupBox(\(swiftString(config.title))) {")
                lines += body
                lines.append("}")
            }
            lines.append(".frame(width: 300)")
            return lines.joined(separator: "\n")
        } examples: {
            MacGroupBoxExamples()
        }
    }
}

private struct GroupBoxPreview: View {
    @Binding var config: MacGroupBoxConfig

    var body: some View {
        Group {
            if config.titleIcon {
                GroupBox {
                    content
                } label: {
                    Label(config.title, systemImage: "square.and.arrow.up")
                }
            } else {
                GroupBox(config.title) {
                    content
                }
            }
        }
        .frame(width: 300)
        .animation(.snappy, value: config.isExpanded)
    }

    private var content: some View {
        VStack(alignment: .leading) {
            Picker("Format", selection: $config.format) {
                ForEach(["PNG", "JPEG", "HEIC"], id: \.self) { Text($0) }
            }
            DisclosureGroup(config.disclosureLabel, isExpanded: $config.isExpanded) {
                Toggle("Include metadata", isOn: $config.includesMetadata)
                Toggle("Convert to sRGB", isOn: $config.usesSRGB)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Examples

private struct MacGroupBoxExamples: View {
    @State private var opensLastWindow = true
    @State private var checksUpdates = true
    @State private var syncsBookmarks = true
    @State private var syncsHistory = false

    @State private var quality = 0.8
    @State private var keepsOriginal = true
    @State private var stripsLocation = false

    @AppStorage("demo.groupBox.showsDetails") private var showsDetails = false

    var body: some View {
        ExampleCard(
            title: "Titled boxes in a settings pane",
            caption: "Two small `GroupBox`es split a settings pane into topics, each titled with a colon, as Mac settings panes do.",
            code: """
            @State private var opensLastWindow = true
            @State private var checksUpdates = true
            @State private var syncsBookmarks = true
            @State private var syncsHistory = false

            VStack(alignment: .leading, spacing: 16) {
                GroupBox("At startup:") {
                    VStack(alignment: .leading) {
                        Toggle("Reopen last window", isOn: $opensLastWindow)
                        Toggle("Check for updates", isOn: $checksUpdates)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                GroupBox("Sync:") {
                    VStack(alignment: .leading) {
                        Toggle("Bookmarks", isOn: $syncsBookmarks)
                        Toggle("History", isOn: $syncsHistory)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .frame(width: 280)
            """,
            minHeight: 230
        ) {
            VStack(alignment: .leading, spacing: 16) {
                GroupBox("At startup:") {
                    VStack(alignment: .leading) {
                        Toggle("Reopen last window", isOn: $opensLastWindow)
                        Toggle("Check for updates", isOn: $checksUpdates)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                GroupBox("Sync:") {
                    VStack(alignment: .leading) {
                        Toggle("Bookmarks", isOn: $syncsBookmarks)
                        Toggle("History", isOn: $syncsHistory)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .frame(width: 280)
        }

        ExampleCard(
            title: "A box with an icon and a summary",
            caption: "Pass a `Label` as the box's title when a symbol helps people find it at a glance.",
            code: """
            GroupBox {
                VStack(alignment: .leading, spacing: 6) {
                    ProgressView(value: 0.62)
                    Text("310 GB of 500 GB used")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
            } label: {
                Label("Storage", systemImage: "internaldrive")
            }
            .frame(width: 280)
            """,
            minHeight: 150
        ) {
            GroupBox {
                VStack(alignment: .leading, spacing: 6) {
                    ProgressView(value: 0.62)
                    Text("310 GB of 500 GB used")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
            } label: {
                Label("Storage", systemImage: "internaldrive")
            }
            .frame(width: 280)
        }

        ExampleCard(
            title: "Advanced options in a form",
            caption: "Inside a grouped `Form`, a `DisclosureGroup` becomes a row that opens to more rows, below the setting most people need.",
            code: """
            @State private var quality = 0.8
            @State private var keepsOriginal = true
            @State private var stripsLocation = false

            Form {
                Slider(value: $quality, in: 0...1) {
                    Text("Quality")
                }
                DisclosureGroup("Advanced Options") {
                    Toggle("Keep original", isOn: $keepsOriginal)
                    Toggle("Remove location", isOn: $stripsLocation)
                }
            }
            .formStyle(.grouped)
            """,
            minHeight: 210
        ) {
            Form {
                Slider(value: $quality, in: 0...1) {
                    Text("Quality")
                }
                DisclosureGroup("Advanced Options") {
                    Toggle("Keep original", isOn: $keepsOriginal)
                    Toggle("Remove location", isOn: $stripsLocation)
                }
            }
            .formStyle(.grouped)
            .scrollDisabled(true)
            .frame(width: 400, height: 190, alignment: .top)
        }

        ExampleCard(
            title: "Open the way people left it",
            caption: "Bind `isExpanded` to `@AppStorage` so a disclosure group stays open or closed the next time the window opens.",
            code: """
            @AppStorage("showsDetails") private var showsDetails = false

            DisclosureGroup("Details", isExpanded: $showsDetails) {
                LabeledContent("Created", value: "March 3, 2026")
                LabeledContent("Size", value: "2.4 MB")
            }
            .frame(width: 260)
            """,
            minHeight: 150
        ) {
            DisclosureGroup("Details", isExpanded: $showsDetails) {
                LabeledContent("Created", value: "March 3, 2026")
                LabeledContent("Size", value: "2.4 MB")
            }
            .frame(width: 260)
        }
    }
}
