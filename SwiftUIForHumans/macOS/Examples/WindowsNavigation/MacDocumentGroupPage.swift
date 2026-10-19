import SwiftUI
import UniformTypeIdentifiers

extension ComponentPage {
    static let documentGroup = ComponentPage(
        id: "document-group",
        title: "DocumentGroup",
        summary: "The scene for document-based apps, with New, Open, and Save built in.",
        category: .windows,
        symbol: "doc.text",
        availability: ["macOS 11.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/documentgroup",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/file-management",
        aliases: [
            "document-based app", "document app", "documents", "NSDocument", "NSDocumentController",
            "FileDocument", "ReferenceFileDocument", "open panel", "save panel", "NSOpenPanel",
            "NSSavePanel", "UTType", "file type", "CFBundleDocumentTypes", "Untitled", "FileWrapper",
        ],
        related: ["file-import-export", "document-editor", "undo-redo", "app-sandbox", "window-group"],
        notes: [
            "**Every document-based app declares its types.** List the content types your app opens under Document Types (`CFBundleDocumentTypes`) in the target's Info pane.",
            "**With several document groups, order matters.** SwiftUI opens a file with the first group whose types match it, so put more specific types first.",
        ],
        about: "`DocumentGroup` makes your app document-based. You give it a document type and the view that edits it. SwiftUI adds File > New and the standard document commands, shows the system's open and save panels, opens each document in its own window, and writes the file back when people save.\n\nModel the document as a struct that conforms to `FileDocument`, and SwiftUI registers undo for every change. If it has to be a class, use `ReferenceFileDocument` and register undo yourself.",
        composition: """
        DocumentGroup(newDocument:)
        └── editor view
            └── file.$document
        """,
        api: [
            APIItem("`DocumentGroup(newDocument:editor:)`", "Creates, opens, and edits one document type."),
            APIItem("`FileDocument`", "A struct document. Undo comes for free."),
            APIItem("`ReferenceFileDocument`", "A class document. You register undo."),
            APIItem("`readableContentTypes`", "The file types the document opens."),
            APIItem("`init(configuration:)`", "Reads the document from a file."),
            APIItem("`fileWrapper(configuration:)`", "Writes the document to a file."),
            APIItem("`file.$document`", "A binding that edits the open document."),
            APIItem("`file.fileURL`", "Where it's saved; `nil` until the first save."),
        ],
        guidelines: [
            Guideline(
                "Start new documents as “Untitled”.",
                "That's the name the system gives a new document until people pick one in the save panel. Keep it, rather than inventing your own.",
                good: "A new document is Untitled.",
                bad: "An invented name before anything is saved."
            ) {
                MacWindowFrame(title: "Untitled", width: 240, height: 100) {
                    Text("Dear Sam,")
                        .font(.callout)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        .padding(10)
                }
            } bad: {
                MacWindowFrame(title: "Document 1", width: 240, height: 100) {
                    Text("Dear Sam,")
                        .font(.callout)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        .padding(10)
                }
            },
            Guideline(
                "Save people's work without asking.",
                "Save periodically while people edit, and when they close the document or switch apps, so work isn't lost."
            ),
            Guideline(
                "Use the system's open and save panels.",
                "People know them from every other Mac app. Build your own file browser only for a strong reason."
            ),
            Guideline(
                "Hide file extensions by default.",
                "Let people show them if they want, and respect that choice in every open and save panel."
            ),
        ]
    ) {
        MacWindowFrame(title: "Untitled", width: 180, height: 110) {
            VStack(alignment: .leading, spacing: 5) {
                Text("Shopping list")
                    .font(.caption.bold())
                Text("Oranges, coffee, basil")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .padding(8)
        }
    } content: { page in
        MacDocumentGroupArticle(page: page)
    }
}

// MARK: - Page

private struct MacDocumentGroupArticle: View {
    let page: ComponentPage

    var body: some View {
        ArticlePage(page: page) {
            if let about = page.about {
                AboutSection(text: about)
            }

            SectionTitle("Usage")
                .id("code")
            CodeBlock(code: """
            @main
            struct EditorApp: App {
                var body: some Scene {
                    DocumentGroup(newDocument: TextFile()) { file in
                        TextEditor(text: file.$document.text)
                    }
                }
            }
            """)

            if let composition = page.composition {
                CompositionSection(tree: composition)
            }

            SectionTitle("What you get for free")
            ConnectFacts(rows: [
                ("The File menu", "File > New, plus the standard document commands for opening and saving."),
                ("Open and save panels", "The system's panels, so people browse files the way they do in every app."),
                ("A window per document", "Each file people open gets its own window."),
                ("Undo", "With `FileDocument`, every change to the struct is undoable without extra code."),
                ("Saving", "SwiftUI writes the file when it's needed, like when people choose Save."),
            ])

            SectionTitle("Examples")
                .id("examples")
            ExampleCard(
                title: "A plain-text document",
                caption: "A `FileDocument` lists the types it reads, loads itself in `init(configuration:)`, and writes itself in `fileWrapper(configuration:)`.",
                code: """
                import SwiftUI
                import UniformTypeIdentifiers

                struct TextFile: FileDocument {
                    static let readableContentTypes = [UTType.plainText]
                    var text = ""

                    init() {}

                    init(configuration: ReadConfiguration) throws {
                        guard let data = configuration.file.regularFileContents else {
                            throw CocoaError(.fileReadCorruptFile)
                        }
                        text = String(decoding: data, as: UTF8.self)
                    }

                    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
                        FileWrapper(regularFileWithContents: Data(text.utf8))
                    }
                }
                """,
                minHeight: 220,
                aside: Aside(.important, "SwiftUI reads and writes documents on a background thread. Don't update the interface from those two methods.")
            ) {
                TextDocumentSample()
            }

            ExampleCard(
                title: "Show where the file is saved",
                caption: "The editor closure also gets `fileURL`, which is `nil` until the first save. Use it for display, and let the document read and write the file.",
                code: """
                DocumentGroup(newDocument: TextFile()) { file in
                    TextEditor(text: file.$document.text)
                        .safeAreaInset(edge: .bottom) {
                            Text(file.fileURL?.lastPathComponent ?? "Not saved yet")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .padding(6)
                        }
                }
                """,
                minHeight: 220
            ) {
                MacWindowFrame(title: "Untitled", width: 380, height: 190) {
                    TextDocumentEditor()
                        .safeAreaInset(edge: .bottom) {
                            Text("Not saved yet")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .padding(6)
                        }
                }
            }

            SectionTitle("Your own file type")
            Prose("For a format of your own, declare a content type in code and in the target's Info pane, with a file extension so the system knows which files are yours.")
            ConnectSteps(steps: [
                "In Xcode, select your app's target and open the **Info** tab.",
                "Under **Exported Type Identifiers**, add your identifier, like `com.example.checklist`, conforming to `public.data`, with the extension `checklist`.",
                "Under **Document Types**, add the same identifier, so the system opens those files with your app.",
                "In code, create the type with `UTType(exportedAs:)` and list it in `readableContentTypes`.",
            ])
            CodeBlock(code: """
            extension UTType {
                static let checklist = UTType(exportedAs: "com.example.checklist")
            }

            struct ChecklistFile: FileDocument {
                static let readableContentTypes = [UTType.checklist]
                var items: [String] = []

                init() {}

                init(configuration: ReadConfiguration) throws {
                    let data = configuration.file.regularFileContents ?? Data()
                    items = try JSONDecoder().decode([String].self, from: data)
                }

                func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
                    FileWrapper(regularFileWithContents: try JSONEncoder().encode(items))
                }
            }
            """)

            Aside(.note, "macOS 27 adds a newer `Document` protocol, and Apple's documentation now lists `FileDocument` as deprecated. `FileDocument` still builds without warnings and runs on every macOS version this app supports, so this page teaches it.")
        }
    }
}

// MARK: - Samples

/// An editable text area standing in for a document window's editor.
private struct TextDocumentEditor: View {
    @State private var text = "Dear Sam,\n\nThe tram leaves at nine."

    var body: some View {
        TextEditor(text: $text)
            .font(.body)
            .scrollContentBackground(.hidden)
            .padding(8)
    }
}

private struct TextDocumentSample: View {
    var body: some View {
        MacWindowFrame(title: "Untitled", width: 380, height: 190) {
            TextDocumentEditor()
        }
    }
}
