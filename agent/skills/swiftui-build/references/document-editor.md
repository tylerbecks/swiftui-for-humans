---
id: document-editor
title: Document editor
platforms: [macOS]
availability: macOS 12.0+
docs: https://developer.apple.com/documentation/swiftui/documentgroup.md
hig: https://developer.apple.com/design/human-interface-guidelines/file-management.md
---

# Document editor

A text editor that opens, saves, and creates files, with a toolbar for formatting.

Also called: DocumentGroup, FileDocument, document-based app, text editor, NSDocument, open and save, File menu, UTType, CFBundleDocumentTypes, plain text.

## Contents

- Built from
- Rules
- Pitfalls
- Key APIs
- Variants
- Related

## Built from

DocumentGroup(newDocument:)
└── EditorView(document: $document)
    ├── TextEditor(text:)
    ├── .toolbar
    │   └── ControlGroup (text size)
    └── .navigationSubtitle (word count)

## Rules

- **Save for people.** Don't make people press Save to keep their work. Save as they go, and keep the toolbar for the tools they use while writing.
- **Create and open from the File menu.** People expect New and Open in the File menu with their usual shortcuts. A document app gets them without extra code.
- **Call a new document “Untitled”.** Let people name it when they save it, in the save panel, along with where it goes.
- **Use the standard open and save panels.** People know the Finder's way of browsing files. Build your own file browser only for a strong reason.

## Pitfalls

- **Every document app declares its types.** Add Document Types (`CFBundleDocumentTypes`) to the Info pane, so the Finder knows which files your app opens.
- **Use the binding, not the file.** `configuration.fileURL` is fine for showing a name, but read and write only through your `FileDocument`, or you'll fight SwiftUI for the file.
- **Sandboxed apps need file access.** Turn on User Selected File with read and write access in the App Sandbox capability. See App Sandbox (`app-sandbox`, app-store-ship skill).

## Key APIs

- `DocumentGroup(newDocument:)`: A scene of document windows.
- `FileDocument`: Reads and writes your document as a value.
- `readableContentTypes`: The file types the document opens.
- `configuration.$document`: The binding your editor changes.
- `configuration.fileURL`: The file's location; `nil` until saved.
- `UTType(exportedAs:)`: Your own file type, declared in Info.plist.

## Variants

### A plain-text editor

A `FileDocument` for plain text, a `DocumentGroup` scene, and an editor with text size buttons in the toolbar and a word count under the title.

```swift
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
        document.text.split(whereSeparator: \.isWhitespace).count
    }

    var body: some View {
        TextEditor(text: $document.text)
            .font(.system(size: fontSize))
            .navigationSubtitle("\(wordCount) words")
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
```

### Declare a custom type

For a format of your own, make a `UTType` with `exportedAs:` and list it in `readableContentTypes`. Declare the same identifier under Exported Type Identifiers in the Info pane.

```swift
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
```

**Note:** Give the type a file extension in its declaration, so the system knows which files belong to it.

## Related

[document-group](document-group.md), [text-editor](text-editor.md), [toolbar](toolbar.md), [file-import-export](file-import-export.md), `app-sandbox` (app-store-ship skill), [welcome-window](welcome-window.md)
