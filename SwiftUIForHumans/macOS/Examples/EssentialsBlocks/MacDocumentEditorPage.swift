import SwiftUI

extension ComponentPage {
    static let documentEditor = ComponentPage(
        id: "document-editor",
        title: "Document editor",
        summary: "A text editor that opens, saves, and creates files, with a toolbar for formatting.",
        category: .blocks,
        kind: .block,
        symbol: "doc.text",
        availability: ["macOS 11.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/documentgroup",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/file-management",
        aliases: [
            "DocumentGroup", "FileDocument", "document-based app", "text editor", "NSDocument",
            "open and save", "File menu", "UTType", "CFBundleDocumentTypes", "plain text", "notes app",
        ],
        related: ["document-group", "text-editor", "toolbar", "file-import-export", "app-sandbox", "welcome-window"],
        notes: [
            "**Every document app declares its types.** Add Document Types (`CFBundleDocumentTypes`) to the Info pane, so the Finder knows which files your app opens.",
            "**Use the binding, not the file.** `configuration.fileURL` is fine for showing a name, but read and write only through your `FileDocument`, or you'll fight SwiftUI for the file.",
            "**Sandboxed apps need file access.** Turn on User Selected File with read and write access in the App Sandbox capability. See [App Sandbox](catalog://app-sandbox).",
        ],
        composition: """
        DocumentGroup(newDocument:)
        └── EditorView(document: $document)
            ├── TextEditor(text:)
            ├── .toolbar
            │   └── ControlGroup (text size)
            └── .navigationSubtitle (word count)
        """,
        api: [
            APIItem("`DocumentGroup(newDocument:)`", "A scene of document windows."),
            APIItem("`FileDocument`", "Reads and writes your document as a value."),
            APIItem("`readableContentTypes`", "The file types the document opens."),
            APIItem("`configuration.$document`", "The binding your editor changes."),
            APIItem("`configuration.fileURL`", "The file's location; `nil` until saved."),
            APIItem("`UTType(exportedAs:)`", "Your own file type, declared in Info.plist."),
        ],
        guidelines: [
            Guideline(
                "Save for people.",
                "Don't make people press Save to keep their work. Save as they go, and keep the toolbar for the tools they use while writing.",
                good: "The toolbar holds formatting.",
                bad: "A Save button nobody needs."
            ) {
                MacEditorToolbarSample(showsSave: false)
            } bad: {
                MacEditorToolbarSample(showsSave: true)
            },
            Guideline(
                "Create and open from the File menu.",
                "People expect New and Open in the File menu with their usual shortcuts. A document app gets them without extra code."
            ),
            Guideline(
                "Call a new document “Untitled”.",
                "Let people name it when they save it, in the save panel, along with where it goes."
            ),
            Guideline(
                "Use the standard open and save panels.",
                "People know the Finder's way of browsing files. Build your own file browser only for a strong reason."
            ),
        ]
    ) {
        MacWindowFrame(title: "Untitled", width: 200, height: 120) {
            VStack(alignment: .leading, spacing: 6) {
                ForEach([150.0, 120, 160, 90], id: \.self) { width in
                    Capsule()
                        .fill(.fill.secondary)
                        .frame(width: width, height: 5)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .padding(12)
        }
    } content: { page in
        MacDocumentEditorArticle(page: page)
    }
}

// MARK: - Page

private struct MacDocumentEditorArticle: View {
    let page: ComponentPage

    var body: some View {
        ArticlePage(page: page) {
            Prose("A document app, like Pages or Keynote, lets people make as many files as they want, each in its own window. `DocumentGroup` gives you that: the File menu commands, the open and save panels, and saving, around an editor view you write.")
            Prose("You describe the file with a `FileDocument`: which types it opens, how to read it, and how to write it. `DocumentGroup` is a scene, so this page draws the window; the editor inside is live.")

            SectionTitle("The block")
                .id("code")
            ExampleCard(
                title: "A plain-text editor",
                caption: "A `FileDocument` for plain text, a `DocumentGroup` scene, and an editor with text size buttons in the toolbar and a word count under the title.",
                code: Self.code,
                minHeight: 300
            ) {
                MacEditorDrawing()
            }

            if let composition = page.composition {
                CompositionSection(tree: composition)
            }

            SectionTitle("What DocumentGroup does for you")
            ConnectFacts(rows: [
                ("File menu", "The document commands, like New and Open, and support for many open documents at once."),
                ("Saving", "Edits go through the `$document` binding. SwiftUI writes the file when needed, like when people choose Save."),
                ("Opening files", "When people double-click a file in the Finder, the system finds your app through the types in its Info.plist."),
                ("The file's location", "`configuration.fileURL` says where the file is. It's `nil` for a new document that hasn't been saved."),
            ])

            SectionTitle("Your own file type")
            ExampleCard(
                title: "Declare a custom type",
                caption: "For a format of your own, make a `UTType` with `exportedAs:` and list it in `readableContentTypes`. Declare the same identifier under Exported Type Identifiers in the Info pane.",
                code: """
                import UniformTypeIdentifiers

                extension UTType {
                    static let outline = UTType(exportedAs: "com.example.outline")
                }

                struct OutlineDocument: FileDocument {
                    static let readableContentTypes: [UTType] = [.outline]
                    var data = Data()

                    init() {}

                    init(configuration: ReadConfiguration) throws {
                        data = configuration.file.regularFileContents ?? Data()
                    }

                    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
                        FileWrapper(regularFileWithContents: data)
                    }
                }
                """,
                minHeight: 120,
                aside: Aside(.note, "Give the type a file extension in its declaration, so the system knows which files belong to it.")
            ) {
                Label("com.example.outline", systemImage: "doc.badge.gearshape")
                    .font(.title3.monospaced())
            }
        }
    }

    static let code = """
    import SwiftUI
    import UniformTypeIdentifiers

    struct TextDocument: FileDocument {
        static let readableContentTypes: [UTType] = [.plainText]
        var text: String

        init(text: String = "") {
            self.text = text
        }

        init(configuration: ReadConfiguration) throws {
            guard let data = configuration.file.regularFileContents,
                  let text = String(data: data, encoding: .utf8) else {
                throw CocoaError(.fileReadCorruptFile)
            }
            self.text = text
        }

        func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
            FileWrapper(regularFileWithContents: Data(text.utf8))
        }
    }

    @main
    struct NotesApp: App {
        var body: some Scene {
            DocumentGroup(newDocument: TextDocument()) { file in
                EditorView(document: file.$document)
            }
        }
    }

    struct EditorView: View {
        @Binding var document: TextDocument
        @AppStorage("fontSize") private var fontSize = 14.0

        private var wordCount: Int {
            document.text.split(whereSeparator: \\.isWhitespace).count
        }

        var body: some View {
            TextEditor(text: $document.text)
                .font(.system(size: fontSize))
                .navigationSubtitle("\\(wordCount) words")
                .toolbar {
                    ControlGroup {
                        Button("Smaller", systemImage: "textformat.size.smaller") {
                            fontSize = max(10, fontSize - 1)
                        }
                        Button("Bigger", systemImage: "textformat.size.larger") {
                            fontSize = min(32, fontSize + 1)
                        }
                    }
                }
        }
    }
    """
}

// MARK: - Drawing

/// The editor window, drawn, with a live text editor and toolbar.
private struct MacEditorDrawing: View {
    @State private var text = "Ideas for the next episode\n\n- Keyboard shortcuts people miss\n- Why Settings beats a toolbar gear\n"
    @State private var fontSize = 14.0

    private var wordCount: Int {
        text.split(whereSeparator: \.isWhitespace).count
    }

    var body: some View {
        MacWindowFrame(width: 480, height: 280) {
            TextEditor(text: $text)
                .font(.system(size: fontSize))
                .scrollContentBackground(.hidden)
                .padding(8)
        } toolbar: {
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Ideas.txt")
                        .font(.headline)
                    Text("\(wordCount) words")
                        .font(.caption)
                        .contentTransition(.numericText())
                }
                .foregroundStyle(.primary)
                Spacer()
                ControlGroup {
                    Button("Smaller", systemImage: "textformat.size.smaller") {
                        fontSize = max(10, fontSize - 1)
                    }
                    Button("Bigger", systemImage: "textformat.size.larger") {
                        fontSize = min(32, fontSize + 1)
                    }
                }
                .fixedSize()
            }
            .frame(width: 360)
        }
    }
}

/// A document window's toolbar, with or without a Save button.
private struct MacEditorToolbarSample: View {
    let showsSave: Bool

    var body: some View {
        MacWindowFrame(title: "Ideas", width: 260, height: 90) {
            Color.clear
        } toolbar: {
            Image(systemName: "textformat.size")
            Image(systemName: "list.bullet")
            if showsSave {
                Image(systemName: "square.and.arrow.down")
            }
        }
    }
}
