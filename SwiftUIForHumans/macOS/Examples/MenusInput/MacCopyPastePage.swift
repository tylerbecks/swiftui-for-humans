import SwiftUI

extension ComponentPage {
    static let copyPaste = ComponentPage(
        id: "copy-paste",
        title: "Copy & paste",
        summary: "Connect the Edit menu's Cut, Copy, Paste, and Delete to your own views.",
        category: .input,
        kind: .concept,
        symbol: "doc.on.clipboard",
        availability: ["macOS 13.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/clipboard",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/edit-menus",
        aliases: ["clipboard", "pasteboard", "NSPasteboard", "copyable", "cuttable", "pasteDestination", "onCopyCommand", "onPasteCommand", "onCutCommand", "onDeleteCommand", "PasteButton", "Edit menu", "⌘C", "⌘V", "navigator.clipboard", "select text", "textSelection"],
        related: ["drag-drop", "commands", "keyboard-shortcuts", "undo-redo", "text-label"],
        notes: [
            "**The commands follow focus.** Edit > Copy turns on when the focused view has something to copy, so people click the list first, then press ⌘C.",
            "**Prefer `Transferable` to item providers.** `.onCopyCommand` and `.onPasteCommand` work with `NSItemProvider`. Apple recommends the `Transferable` modifiers when you can use them.",
        ],
        about: "Every Mac app has an Edit menu with Cut, Copy, Paste, Delete, and Select All, and text fields support them without any code. For your own views, `.copyable`, `.cuttable`, and `.pasteDestination` connect those menu items and their shortcuts to your data.\n\nThey use `Transferable`, like drag and drop, so what people copy from your app pastes into other apps, and the other way around.",
        api: [
            APIItem("`.copyable(_:)`", "The items Edit > Copy puts on the Clipboard."),
            APIItem("`.cuttable(for:action:)`", "Removes items and returns them for Cut."),
            APIItem("`.pasteDestination(for:action:)`", "Accepts items from Edit > Paste."),
            APIItem("`.onDeleteCommand(perform:)`", "Edit > Delete and the Delete key."),
            APIItem("`PasteButton(payloadType:)`", "A Paste button for the Clipboard."),
            APIItem("`.textSelection(.enabled)`", "Lets people select and copy a `Text`."),
        ],
        guidelines: [
            Guideline(
                "Let the Edit menu do the work.",
                "People expect Copy and Paste in the Edit menu and on ⌘C and ⌘V. Extra buttons for the same commands crowd the window."
            ),
            Guideline(
                "Let people copy text they can't edit.",
                "Content like a caption or an address is often worth pasting somewhere else. Make that text selectable, but not the labels of controls."
            ),
            Guideline(
                "Call it Delete, not Erase or Clear.",
                "Edit > Delete does what the Delete key does. Unlike Cut, it doesn't put anything on the Clipboard."
            ),
            Guideline(
                "Support undo.",
                "Menu commands act without asking first. Undo lets people recover from a paste or delete they didn't mean."
            ),
        ]
    ) {
        HStack(spacing: 10) {
            ForEach(["⌘X", "⌘C", "⌘V"], id: \.self) { key in
                Text(key)
                    .font(.title3.weight(.medium))
                    .padding(.horizontal, 10)
                    .frame(height: 40)
                    .background(.background, in: .rect(cornerRadius: 8))
                    .overlay {
                        RoundedRectangle(cornerRadius: 8)
                            .strokeBorder(.separator)
                    }
            }
        }
    } content: { page in
        MacCopyPasteArticle(page: page)
    }
}

// MARK: - Page

private struct MacCopyPasteArticle: View {
    let page: ComponentPage

    var body: some View {
        ArticlePage(page: page) {
            if let about = page.about {
                AboutSection(text: about)
            }

            SectionTitle("Usage")
                .id("code")
            CodeBlock(code: """
            @State private var plants = ["Sunflowers", "Tulips", "Ferns"]
            @State private var selection = Set<String>()

            List(plants, id: \\.self, selection: $selection) { plant in
                Text(plant)
            }
            .copyable(plants.filter { selection.contains($0) })
            .pasteDestination(for: String.self) { pasted in
                plants.append(contentsOf: pasted)
            }
            """)

            SectionTitle("Examples")
                .id("examples")
            PlantClipboardExample()
            DeleteCommandExample()
            PasteButtonExample()
            SelectableTextExample()
        }
    }
}

// MARK: - Examples

private struct PlantClipboardExample: View {
    @State private var plants = ["Sunflowers", "Tulips", "Ferns", "Basil"]
    @State private var selection = Set<String>()

    var body: some View {
        ExampleCard(
            title: "Cut, copy, and paste list rows",
            caption: "Give a selectable `List` all three modifiers, and let the `.pasteDestination` validator drop unwanted items, like empty lines.",
            code: """
            @State private var plants = ["Sunflowers", "Tulips", "Ferns", "Basil"]
            @State private var selection = Set<String>()

            List(plants, id: \\.self, selection: $selection) { plant in
                Text(plant)
            }
            .copyable(plants.filter { selection.contains($0) })
            .cuttable(for: String.self) {
                let cut = plants.filter { selection.contains($0) }
                plants.removeAll { selection.contains($0) }
                return cut
            }
            .pasteDestination(for: String.self) { pasted in
                plants.append(contentsOf: pasted)
            } validator: { pasted in
                pasted
                    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                    .filter { !$0.isEmpty }
            }
            """,
            minHeight: 220,
            aside: Aside(.note, "Click the list, select a row, and press ⌘C. Paste it into Notes, or copy a word from another app and press ⌘V here.")
        ) {
            List(plants, id: \.self, selection: $selection) { plant in
                Text(plant)
            }
            .copyable(plants.filter { selection.contains($0) })
            .cuttable(for: String.self) {
                let cut = plants.filter { selection.contains($0) }
                plants.removeAll { selection.contains($0) }
                return cut
            }
            .pasteDestination(for: String.self) { pasted in
                plants.append(contentsOf: pasted)
            } validator: { pasted in
                pasted
                    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                    .filter { !$0.isEmpty }
            }
            .listStyle(.bordered)
            .frame(width: 300, height: 170)
        }
    }
}

private struct DeleteCommandExample: View {
    @State private var tags = ["garden", "summer", "seeds", "watering"]
    @State private var selection = Set<String>()

    var body: some View {
        ExampleCard(
            title: "The Delete key and Edit > Delete",
            caption: "`.onDeleteCommand` runs when people choose Edit > Delete or press Delete while the view has focus.",
            code: """
            @State private var tags = ["garden", "summer", "seeds", "watering"]
            @State private var selection = Set<String>()

            List(tags, id: \\.self, selection: $selection) { tag in
                Text(tag)
            }
            .onDeleteCommand {
                tags.removeAll { selection.contains($0) }
            }
            """,
            minHeight: 200
        ) {
            VStack(spacing: 10) {
                List(tags, id: \.self, selection: $selection) { tag in
                    Text(tag)
                }
                .onDeleteCommand {
                    tags.removeAll { selection.contains($0) }
                }
                .listStyle(.bordered)
                .frame(width: 300, height: 140)
                if tags.count < 4 {
                    Button("Restore Tags") {
                        tags = ["garden", "summer", "seeds", "watering"]
                    }
                    .controlSize(.small)
                }
            }
        }
    }
}

private struct PasteButtonExample: View {
    @State private var pasted = "Nothing pasted yet."

    var body: some View {
        ExampleCard(
            title: "A Paste button",
            caption: "`PasteButton` reads the Clipboard when clicked and hands you the values of the type you ask for.",
            code: """
            @State private var pasted = ""

            PasteButton(payloadType: String.self) { strings in
                pasted = strings.joined(separator: " ")
            }
            """,
            minHeight: 150,
            aside: Aside(.note, "Add one only where a visible button helps; people look for Edit > Paste and ⌘V first. For a Copy item of your own, like in a context menu, write to `NSPasteboard.general`, since SwiftUI's modifiers only answer the system's Copy command.")
        ) {
            VStack(spacing: 12) {
                PasteButton(payloadType: String.self) { strings in
                    pasted = strings.joined(separator: " ")
                }
                Text(pasted)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                    .frame(maxWidth: 320)
            }
        }
    }
}

private struct SelectableTextExample: View {
    var body: some View {
        ExampleCard(
            title: "Selectable text",
            caption: "`.textSelection(.enabled)` lets people select a `Text` and copy it with ⌘C or the Edit menu.",
            code: """
            VStack(alignment: .leading) {
                Text("Order number")
                    .foregroundStyle(.secondary)
                Text("W-48213-7")
                    .font(.title2.monospaced())
                    .textSelection(.enabled)
            }
            """,
            minHeight: 140
        ) {
            VStack(alignment: .leading) {
                Text("Order number")
                    .foregroundStyle(.secondary)
                Text("W-48213-7")
                    .font(.title2.monospaced())
                    .textSelection(.enabled)
            }
        }
    }
}
