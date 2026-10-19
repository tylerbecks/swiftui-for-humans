import SwiftUI
import UniformTypeIdentifiers

extension ComponentPage {
    static let dragDrop = ComponentPage(
        id: "drag-drop",
        title: "Drag and drop",
        summary: "Let people drag content within a window, between windows, and to other apps.",
        category: .input,
        kind: .concept,
        symbol: "hand.draw",
        availability: ["macOS 26.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/drag-and-drop",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/drag-and-drop",
        aliases: ["drag", "drop", "draggable", "dropDestination", "onDrag", "onDrop", "Transferable", "NSDraggingSource", "NSDraggingDestination", "dataTransfer", "ondragstart", "drop zone", "kanban", "NSItemProvider"],
        related: ["copy-paste", "file-import-export", "share-link", "hover", "list-styles"],
        notes: [
            "**Common types already work.** `String`, `URL`, and many other system types conform to `Transferable`, so you can drag them without extra code.",
            "**A drag offers a copy unless you allow a move.** Pass `DragConfiguration(allowMove: true)` to `.dragConfiguration(_:)`. People can then hold ⌘ to move, or ⌥ to copy.",
            "**This `.dropDestination` is new in macOS 26.** It replaces the version with an `isTargeted:` closure, which is deprecated.",
        ],
        about: "`.draggable` turns a view into something people can drag, and `.dropDestination` makes a view accept drops. Both work with `Transferable` types, so the same code handles drags inside a window, between your app's windows, and to and from other apps.\n\nA type's transfer representations decide what it becomes: your own data when it lands in your app, and plain text or a file in apps that don't know your type.",
        api: [
            APIItem("`.draggable(_:)`", "Makes a view a drag source for a value."),
            APIItem("`.draggable(_:preview:)`", "The same, with a custom drag image."),
            APIItem("`.dropDestination(for:)`", "Accepts dropped values of a type."),
            APIItem("`.onDropSessionUpdated(_:)`", "Follows a drop, to highlight the target."),
            APIItem("`Transferable`", "How a type turns into data, text, or a file."),
            APIItem("`CodableRepresentation`", "Transfers a `Codable` type as data."),
            APIItem("`ProxyRepresentation`", "Transfers it as another type, like text."),
            APIItem("`.dragConfiguration(_:)`", "Allows move, as well as copy."),
        ],
        guidelines: [
            Guideline(
                "Support drag and drop wherever people might try it.",
                "Most people know it and try it everywhere. Text fields and text views already support it."
            ),
            Guideline(
                "Offer another way to do the same thing.",
                "Some people can't or don't drag. Back every drag with menu commands, like Copy and Paste or Move To."
            ),
            Guideline(
                "Show whether a destination accepts the drop.",
                "Highlight a destination only while content is over it and only if it can take it. Remove the highlight as soon as the pointer leaves."
            ),
            Guideline(
                "Move within a container, copy between containers.",
                "Dropping in the same place, like reordering a list, moves the content. Dropping somewhere else copies it, and a drop into another app always copies."
            ),
            Guideline(
                "Let people drag content to the Finder.",
                "Give it a file format your app can open again, the way Calendar drags an event out as an .ics file."
            ),
            Guideline(
                "Offer the richest version first.",
                "List your type's representations from highest fidelity to lowest, so each destination takes the best one it understands."
            ),
        ]
    ) {
        HStack(spacing: 14) {
            Text("Sunflowers")
                .font(.caption)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(.tint.opacity(0.18), in: .capsule)
                .rotationEffect(.degrees(-6))
            Image(systemName: "arrow.right")
                .foregroundStyle(.secondary)
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(.tint, style: StrokeStyle(lineWidth: 1.5, dash: [5, 4]))
                .frame(width: 70, height: 56)
        }
    } content: { page in
        MacDragDropArticle(page: page)
    }
}

extension Catalog {
    /// A second window with chips and a drop zone, to drag between windows.
    static let dragDropDemoWindow = DemoWindow(id: "drag-drop-board", title: "Drag and Drop", size: CGSize(width: 480, height: 300)) {
        PlantDropBoard()
            .padding(20)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Page

private struct MacDragDropArticle: View {
    let page: ComponentPage

    var body: some View {
        ArticlePage(page: page) {
            if let about = page.about {
                AboutSection(text: about)
            }
            OpenDemoWindowButton(id: "drag-drop-board", label: "Open a Second Window")
                .controlSize(.large)

            SectionTitle("Usage")
                .id("code")
            CodeBlock(code: """
            @State private var basket: [String] = []

            Text("Sunflowers")
                .draggable("Sunflowers")

            BasketView(items: basket)
                .dropDestination(for: String.self) { names, session in
                    basket.append(contentsOf: names)
                }
            """)

            SectionTitle("Examples")
                .id("examples")
            ExampleCard(
                title: "Drag text onto a target",
                caption: "Make each chip `.draggable` and the box a `.dropDestination`. Highlight the box with `.onDropSessionUpdated` while a drag is over it.",
                code: """
                @State private var basket: [String] = []
                @State private var isTargeted = false

                HStack {
                    ForEach(["Sunflowers", "Tulips", "Ferns"], id: \\.self) { plant in
                        Text(plant)
                            .padding(8)
                            .background(.tint.opacity(0.15), in: .capsule)
                            .draggable(plant)
                    }
                }

                Text(basket.isEmpty ? "Drop here" : basket.joined(separator: ", "))
                    .frame(width: 300, height: 90)
                    .background(isTargeted ? Color.accentColor.opacity(0.15) : .clear)
                    .dropDestination(for: String.self) { plants, _ in
                        basket.append(contentsOf: plants)
                    }
                    .onDropSessionUpdated { session in
                        switch session.phase {
                        case .entering, .active: isTargeted = true
                        default: isTargeted = false
                        }
                    }
                """,
                minHeight: 220,
                aside: Aside(.note, "Text from other apps works too: select a word in Notes or TextEdit and drag it into the box. Or open a second window above and drag between the two.")
            ) {
                PlantDropBoard()
            }

            ExampleCard(
                title: "Drag your own type",
                caption: "Make your type `Transferable`. Here a card moves between columns as itself, and lands in other apps as its title.",
                code: """
                struct TodoCard: Identifiable, Codable, Transferable {
                    var id = UUID()
                    var title: String

                    static var transferRepresentation: some TransferRepresentation {
                        CodableRepresentation(contentType: .json)
                        ProxyRepresentation(exporting: \\.title)
                    }
                }

                @State private var todo = [TodoCard(title: "Water the ferns")]
                @State private var done: [TodoCard] = []

                HStack {
                    CardColumn("To Do", cards: todo)
                        .dropDestination(for: TodoCard.self) { cards, _ in
                            move(cards, to: \\.todo)
                        }
                    CardColumn("Done", cards: done)
                        .dropDestination(for: TodoCard.self) { cards, _ in
                            move(cards, to: \\.done)
                        }
                }
                """,
                minHeight: 230,
                aside: Aside(.important, "A type only your app understands should use its own content type, declared with `UTType(exportedAs:)` and listed in your Info.plist. This example uses `.json` so it runs without that setup.")
            ) {
                TodoBoard()
            }

            ExampleCard(
                title: "Accept files from the Finder",
                caption: "Ask for `URL` to accept files and folders dragged from the Finder or another app.",
                code: """
                @State private var files: [URL] = []

                Label("Drop files here", systemImage: "tray.and.arrow.down")
                    .frame(width: 300, height: 120)
                    .dropDestination(for: URL.self) { urls, _ in
                        files.append(contentsOf: urls)
                    }
                """,
                minHeight: 200
            ) {
                FileDropBox()
            }
        }
    }
}

// MARK: - Samples

/// Chips you can drag, and a box that collects them. Shared by the page
/// and the demo window, so you can drag between the two.
private struct PlantDropBoard: View {
    @State private var basket: [String] = []
    @State private var isTargeted = false

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                ForEach(["Sunflowers", "Tulips", "Ferns"], id: \.self) { plant in
                    Text(plant)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(.tint.opacity(0.15), in: .capsule)
                        .draggable(plant)
                }
            }
            Text(basket.isEmpty ? "Drop here" : basket.joined(separator: ", "))
                .foregroundStyle(basket.isEmpty ? .secondary : .primary)
                .multilineTextAlignment(.center)
                .padding()
                .frame(width: 300, height: 90)
                .background(isTargeted ? Color.accentColor.opacity(0.15) : .clear, in: .rect(cornerRadius: 12))
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(isTargeted ? Color.accentColor : Color.secondary.opacity(0.5), style: StrokeStyle(lineWidth: 1.5, dash: [6, 4]))
                }
                .dropDestination(for: String.self) { plants, _ in
                    basket.append(contentsOf: plants)
                }
                .onDropSessionUpdated { session in
                    switch session.phase {
                    case .entering, .active: isTargeted = true
                    default: isTargeted = false
                    }
                }
            if !basket.isEmpty {
                Button("Clear") { basket.removeAll() }
                    .controlSize(.small)
            }
        }
    }
}

private struct TodoCard: Identifiable, Codable, Transferable {
    var id = UUID()
    var title: String

    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .json)
        ProxyRepresentation(exporting: \.title)
    }
}

private struct TodoBoard: View {
    @State private var todo = [TodoCard(title: "Water the ferns"), TodoCard(title: "Buy seeds")]
    @State private var done = [TodoCard(title: "Plant tulips")]

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            column("To Do", cards: todo)
                .dropDestination(for: TodoCard.self) { cards, _ in
                    move(cards, toDone: false)
                }
            column("Done", cards: done)
                .dropDestination(for: TodoCard.self) { cards, _ in
                    move(cards, toDone: true)
                }
        }
        .frame(width: 400)
    }

    private func column(_ title: String, cards: [TodoCard]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            ForEach(cards) { card in
                Text(card.title)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(8)
                    .background(.background, in: .rect(cornerRadius: 8))
                    .overlay {
                        RoundedRectangle(cornerRadius: 8)
                            .strokeBorder(.separator)
                    }
                    .draggable(card)
            }
            Spacer(minLength: 0)
        }
        .padding(10)
        .frame(maxWidth: .infinity, minHeight: 170, alignment: .topLeading)
        .background(.fill.quaternary, in: .rect(cornerRadius: 12))
    }

    private func move(_ cards: [TodoCard], toDone: Bool) {
        let ids = Set(cards.map(\.id))
        todo.removeAll { ids.contains($0.id) }
        done.removeAll { ids.contains($0.id) }
        if toDone {
            done.append(contentsOf: cards)
        } else {
            todo.append(contentsOf: cards)
        }
    }
}

private struct FileDropBox: View {
    @State private var files: [URL] = []

    var body: some View {
        VStack(spacing: 10) {
            Label("Drop files here", systemImage: "tray.and.arrow.down")
                .foregroundStyle(.secondary)
                .frame(width: 300, height: 120)
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Color.secondary.opacity(0.5), style: StrokeStyle(lineWidth: 1.5, dash: [6, 4]))
                }
                .dropDestination(for: URL.self) { urls, _ in
                    files.append(contentsOf: urls)
                }
            if !files.isEmpty {
                Text(files.map(\.lastPathComponent).joined(separator: ", "))
                    .font(.footnote)
                    .lineLimit(2)
                    .frame(maxWidth: 300)
            }
        }
    }
}
