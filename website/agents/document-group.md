---
id: document-group
title: DocumentGroup
platforms: [macOS]
availability: macOS 11.0+
docs: https://developer.apple.com/documentation/swiftui/documentgroup.md
hig: https://developer.apple.com/design/human-interface-guidelines/file-management.md
---

# DocumentGroup

The scene for document-based apps, with New, Open, and Save built in.

Also called: document-based app, document app, documents, NSDocument, NSDocumentController, FileDocument, ReferenceFileDocument, open panel, save panel, NSOpenPanel.

## Contents

- Use when
- Built from
- Rules
- Pitfalls
- Key APIs
- Variants
- Related

## Use when

- `DocumentGroup` makes your app document-based.
- You give it a document type and the view that edits it.
- SwiftUI adds File > New and the standard document commands, shows the system's open and save panels, opens each document in its own window, and writes the file back when people save.
- Model the document as a struct that conforms to `FileDocument`, and SwiftUI registers undo for every change.
- If it has to be a class, use `ReferenceFileDocument` and register undo yourself.

## Built from

DocumentGroup(newDocument:)
└── editor view
    └── file.$document

## Rules

- **Start new documents as “Untitled”.** That's the name the system gives a new document until people pick one in the save panel. Keep it, rather than inventing your own.
- **Save people's work without asking.** Save periodically while people edit, and when they close the document or switch apps, so work isn't lost.
- **Use the system's open and save panels.** People know them from every other Mac app. Build your own file browser only for a strong reason.
- **Hide file extensions by default.** Let people show them if they want, and respect that choice in every open and save panel.

## Pitfalls

- **Every document-based app declares its types.** List the content types your app opens under Document Types (`CFBundleDocumentTypes`) in the target's Info pane.
- **With several document groups, order matters.** SwiftUI opens a file with the first group whose types match it, so put more specific types first.

**Note:** Apple's documentation marks `FileDocument` deprecated in macOS 27.2, in favor of the new `Document` protocol, which needs macOS 27. For an app that also runs on earlier versions, `FileDocument` is still the one to use.

## Key APIs

`DocumentGroup(newDocument:editor:)`, `FileDocument`, `ReferenceFileDocument`, `readableContentTypes`, `init(configuration:)`, `fileWrapper(configuration:)`, `file.$document`, `file.fileURL`

## Variants

### Usage

```swift
@main
struct EditorApp: App {
    var body: some Scene {
        DocumentGroup(newDocument: TextFile()) { file in
            TextEditor(text: file.$document.text)
        }
    }
}
```

### A plain-text document

A `FileDocument` lists the types it reads, loads itself in `init(configuration:)`, and writes itself in `fileWrapper(configuration:)`.

```swift
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
```

**Important:** SwiftUI reads and writes documents on a background thread. Don't update the interface from those two methods.

### Show where the file is saved

The editor closure also gets `fileURL`, which is `nil` until the first save. Use it for display, and let the document read and write the file.

```swift
DocumentGroup(newDocument: TextFile()) { file in
    TextEditor(text: file.$document.text)
        .safeAreaInset(edge: .bottom) {
            Text(file.fileURL?.lastPathComponent ?? "Not saved yet")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(6)
        }
}
```

### Your own file type

```swift
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
```

## Related

[file-import-export](file-import-export.md), [document-editor](document-editor.md), [undo-redo](undo-redo.md), [app-sandbox](app-sandbox.md), [window-group](window-group.md)
