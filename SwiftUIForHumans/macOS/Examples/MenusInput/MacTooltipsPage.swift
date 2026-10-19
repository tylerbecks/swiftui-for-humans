import SwiftUI

extension ComponentPage {
    static let tooltips = ComponentPage(
        id: "tooltips",
        title: "Tooltips",
        summary: "A short phrase that appears when the pointer rests on a control.",
        category: .presentation,
        kind: .modifier,
        symbol: "text.bubble",
        availability: ["macOS 11.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/view/help(_:)-6oiyb",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/offering-help",
        aliases: ["help tag", "toolTip", "title attribute", "hover text", "help(_:)", "NSView toolTip", "hint", "icon button"],
        related: ["button", "hover", "toolbar", "voiceover"],
        notes: [
            "**`.help` is also the VoiceOver hint.** One modifier gives pointer users a tooltip and VoiceOver users a hint.",
            "**Tooltips wait for the pointer.** They appear only after the pointer rests on a control for a moment, so keep anything people must know in the window itself.",
        ],
        api: [
            APIItem("`.help(_:)`", "Adds a tooltip and an accessibility hint."),
            APIItem("`.help(Text)`", "The same, from a `Text`."),
            APIItem("`Button(_:systemImage:action:)`", "A button with a title and a symbol."),
            APIItem("`.labelStyle(.iconOnly)`", "Shows only a label's icon; the title stays for VoiceOver."),
        ],
        guidelines: [
            Guideline(
                "Say what the control does, in a few words.",
                "Start with a verb, and keep it to 60 to 75 characters at most. A sentence fragment without articles is fine.",
                good: "A short phrase that starts with a verb.",
                bad: "A long sentence that repeats the obvious."
            ) {
                TooltipDrawing(symbol: "arrow.counterclockwise", text: "Restore default settings")
            } bad: {
                TooltipDrawing(symbol: "arrow.counterclockwise", text: "Click this button to restore all of the default settings in this window to how they were when you first opened the app.")
            },
            Guideline(
                "Don't repeat the control's name.",
                "The name is already on screen or in the label. Use the space to explain what happens."
            ),
            Guideline(
                "Describe only that control.",
                "People hold the pointer over one control to learn about it, not about its neighbors or the whole task."
            ),
            Guideline(
                "Use sentence case, and match the state.",
                "Write “Pin note”, not “Pin Note”, and skip the final period. If the control changes, like Pin and Unpin, change the tooltip too."
            ),
        ]
    ) {
        VStack(spacing: 6) {
            Image(systemName: "arrow.counterclockwise")
                .font(.title2)
                .frame(width: 36, height: 30)
                .background(.fill.tertiary, in: .rect(cornerRadius: 6))
            TooltipBubble(text: "Restore default settings")
        }
    } content: { page in
        MacTooltipsDemo(page: page)
    }
}

private struct MacTooltipsConfig {
    var symbol: TooltipSymbolOption = .restore
    var addsHelp = true
    var text = "Restore default settings"
}

private struct MacTooltipsDemo: View {
    let page: ComponentPage

    var body: some View {
        DemoPage(
            page: page,
            initial: MacTooltipsConfig(),
            previewHeight: 200,
            usage: """
            Button("Restore Defaults", systemImage: "arrow.counterclockwise") {
                restoreDefaults()
            }
            .labelStyle(.iconOnly)
            .help("Restore default settings")
            """,
            usageNote: Aside(.important, "An icon on its own rarely says what a button does. Give every icon-only button a title for VoiceOver and a `.help` tooltip for everyone else.")
        ) { $config in
            VStack(spacing: 14) {
                Button(config.symbol.title, systemImage: config.symbol.rawValue) {}
                    .labelStyle(.iconOnly)
                    .controlSize(.large)
                    .modifier(OptionalHelp(text: config.addsHelp ? config.text : nil))
                Text(config.addsHelp ? "Hold the pointer over the button." : "No tooltip: the icon has to speak for itself.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        } controls: { $config in
            Section("Button") {
                OptionPicker("Symbol", selection: $config.symbol)
                    .onChange(of: config.symbol) { _, symbol in
                        config.text = symbol.help
                    }
            }
            Section("Tooltip") {
                Toggle("Add .help", isOn: $config.addsHelp)
                TextField("Text", text: $config.text)
                    .disabled(!config.addsHelp)
            }
        } code: { config in
            var lines = [
                "Button(\(swiftString(config.symbol.title)), systemImage: \"\(config.symbol.rawValue)\") {",
                "    \(config.symbol.action)()",
                "}",
                ".labelStyle(.iconOnly)",
            ]
            if config.addsHelp {
                lines.append(".help(\(swiftString(config.text)))")
            }
            return lines.joined(separator: "\n")
        } examples: {
            MacTooltipsExamples()
        }
    }
}

private struct OptionalHelp: ViewModifier {
    let text: String?

    func body(content: Content) -> some View {
        if let text {
            content.help(text)
        } else {
            content
        }
    }
}

// MARK: - Examples

private struct MacTooltipsExamples: View {
    @State private var isPinned = false

    var body: some View {
        ExampleCard(
            title: "Icon-only toolbar buttons",
            caption: "Add `.help` to each icon-only toolbar button, so people can find out what it does before they click.",
            code: """
            .toolbar {
                Button("New Note", systemImage: "square.and.pencil") { newNote() }
                    .help("Create a note")
                Button("Share", systemImage: "square.and.arrow.up") { share() }
                    .help("Send this note to someone")
                Button("Delete", systemImage: "trash") { delete() }
                    .help("Move this note to the Trash")
            }
            """,
            minHeight: 190,
            aside: Aside(.note, "Hold the pointer over each symbol in the preview. A real `.toolbar` here would land in this window's own toolbar, so the preview draws one.")
        ) {
            MacWindowFrame(title: "Notes", width: 380, height: 150) {
                Text("Hold the pointer over a toolbar button.")
                    .foregroundStyle(.secondary)
            } toolbar: {
                Group {
                    Button("New Note", systemImage: "square.and.pencil") {}
                        .help("Create a note")
                    Button("Share", systemImage: "square.and.arrow.up") {}
                        .help("Send this note to someone")
                    Button("Delete", systemImage: "trash") {}
                        .help("Move this note to the Trash")
                }
                .labelStyle(.iconOnly)
                .buttonStyle(.borderless)
            }
        }

        ExampleCard(
            title: "A tooltip that follows the state",
            caption: "When a button switches between two actions, switch its `.help` text too, so it describes the next click.",
            code: """
            @State private var isPinned = false

            Button(isPinned ? "Unpin" : "Pin", systemImage: isPinned ? "pin.slash" : "pin") {
                isPinned.toggle()
            }
            .labelStyle(.iconOnly)
            .help(isPinned ? "Unpin this note" : "Pin this note to the top")
            """,
            minHeight: 150
        ) {
            VStack(spacing: 12) {
                Button(isPinned ? "Unpin" : "Pin", systemImage: isPinned ? "pin.slash" : "pin") {
                    isPinned.toggle()
                }
                .labelStyle(.iconOnly)
                .controlSize(.large)
                .help(isPinned ? "Unpin this note" : "Pin this note to the top")
                Text(isPinned ? "Pinned" : "Not pinned")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

/// A still drawing of a button with its tooltip under it, for guideline
/// previews, where hovering can't show the real one.
private struct TooltipDrawing: View {
    let symbol: String
    let text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Image(systemName: symbol)
                .font(.title3)
                .frame(width: 34, height: 28)
                .background(.fill.tertiary, in: .rect(cornerRadius: 6))
            TooltipBubble(text: text)
                .padding(.leading, 18)
        }
        .frame(width: 260, alignment: .leading)
    }
}

private struct TooltipBubble: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.caption)
            .padding(.horizontal, 7)
            .padding(.vertical, 4)
            .background(.background, in: .rect(cornerRadius: 5))
            .overlay {
                RoundedRectangle(cornerRadius: 5)
                    .strokeBorder(.separator)
            }
            .shadow(color: .black.opacity(0.12), radius: 3, y: 1)
            .fixedSize(horizontal: false, vertical: true)
    }
}

// MARK: - Options

private enum TooltipSymbolOption: String, DemoOption {
    case restore = "arrow.counterclockwise"
    case sidebar = "sidebar.left"
    case filter = "line.3.horizontal.decrease.circle"

    var label: String {
        switch self {
        case .restore: "Restore"
        case .sidebar: "Sidebar"
        case .filter: "Filter"
        }
    }

    var title: String {
        switch self {
        case .restore: "Restore Defaults"
        case .sidebar: "Toggle Sidebar"
        case .filter: "Filter"
        }
    }

    var help: String {
        switch self {
        case .restore: "Restore default settings"
        case .sidebar: "Show or hide the sidebar"
        case .filter: "Show only unread messages"
        }
    }

    var action: String {
        switch self {
        case .restore: "restoreDefaults"
        case .sidebar: "toggleSidebar"
        case .filter: "toggleFilter"
        }
    }
}
