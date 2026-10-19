import SwiftUI
import UniformTypeIdentifiers

extension ComponentPage {
    static let fileImportExport = ComponentPage(
        id: "file-import-export",
        title: "File import & export",
        summary: "Show the Mac's open and save panels, and read or write the files people pick.",
        category: .files,
        kind: .modifier,
        symbol: "folder",
        availability: ["macOS 11.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/view/fileimporter(ispresented:allowedcontenttypes:oncompletion:)",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/file-management",
        aliases: ["open panel", "save panel", "NSOpenPanel", "NSSavePanel", "file picker", "<input type=file>", "download", "save as", "export", "import", "fileImporter", "fileExporter", "fileMover", "security-scoped", "startAccessingSecurityScopedResource", "UTType"],
        related: ["app-sandbox", "drag-drop", "share-link", "document-group", "document-editor"],
        notes: [
            "**Canceling calls nothing.** If people cancel, SwiftUI sets the binding back to `false` and skips `onCompletion`. The file exporter calls `onCancellation` instead.",
            "**This app does it for real.** It has the user-selected read-write entitlement, so the examples below can read and write what you pick.",
        ],
        api: [
            APIItem("`.fileImporter(isPresented:…)`", "The open panel."),
            APIItem("`.fileExporter(isPresented:item:)`", "The save panel, for a `Transferable` item."),
            APIItem("`.fileMover(isPresented:file:)`", "A panel that moves a file somewhere else."),
            APIItem("`startAccessingSecurityScopedResource()`", "Opens access to a URL from a panel."),
            APIItem("`.fileDialogConfirmationLabel(_:)`", "Renames the panel's main button."),
            APIItem("`.fileDialogMessage(_:)`", "A message in the panel, like a title."),
            APIItem("`.fileDialogDefaultDirectory(_:)`", "The folder the panel opens in."),
        ],
        guidelines: [
            Guideline(
                "Use the system's open and save panels.",
                "People know how to browse files from the Finder and other apps. Build your own file browser only for a strong reason."
            ),
            Guideline(
                "Offer Open and New in the File menu.",
                "People expect File > New and File > Open… with ⌘N and ⌘O, even when your window has buttons for them."
            ),
            Guideline(
                "Name the main button for the task.",
                "If the panel inserts a file rather than opening it, call the button Insert. `.fileDialogConfirmationLabel` sets it."
            ),
            Guideline(
                "Save work automatically.",
                "Don't make people choose Save to keep their work. Save as they go, and when they close the window or switch apps."
            ),
        ]
    ) {
        VStack(spacing: 8) {
            Image(systemName: "folder.fill")
                .font(.system(size: 40))
                .foregroundStyle(.tint)
            HStack(spacing: 6) {
                Text("Open…")
                Text("Save…")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
    } content: { page in
        MacFileImportExportArticle(page: page)
    }
}

// MARK: - Page

private struct MacFileImportExportArticle: View {
    let page: ComponentPage

    var body: some View {
        ArticlePage(page: page) {
            Prose("`.fileImporter`, `.fileExporter`, and `.fileMover` show the Mac's open and save panels. Each gives you back a URL for what people picked.")
            Prose("The URLs are **security-scoped**. Call `startAccessingSecurityScopedResource()` before you read or bookmark one, and the matching stop call when you're done. A sandboxed app also needs the user-selected file entitlement. See [App Sandbox](catalog://app-sandbox).")

            SectionTitle("Usage")
                .id("code")
            CodeBlock(code: """
            @State private var isImporting = false
            @State private var text = ""

            Button("Open…") { isImporting = true }
                .fileImporter(isPresented: $isImporting,
                              allowedContentTypes: [.plainText]) { result in
                    guard case .success(let url) = result else { return }
                    let didAccess = url.startAccessingSecurityScopedResource()
                    defer {
                        if didAccess { url.stopAccessingSecurityScopedResource() }
                    }
                    text = (try? String(contentsOf: url, encoding: .utf8)) ?? ""
                }
            """)
            Aside(.important, "Apple's docs ask you to pair every start call with a stop call. `defer` makes sure the stop call runs, even when reading fails.")

            SectionTitle("Examples")
                .id("examples")
            ImportManyExample()
            ExportTextExample()
            MoveFileExample()
        }
    }
}

// MARK: - Examples

private struct ImportManyExample: View {
    @State private var isImporting = false
    @State private var picked: [String] = []

    var body: some View {
        ExampleCard(
            title: "Pick several files",
            caption: "Pass `allowsMultipleSelection: true` to get an array of URLs, and set a message and button title that fit the task.",
            code: """
            @State private var isImporting = false
            @State private var picked: [String] = []

            Button("Add Photos…") { isImporting = true }
                .fileImporter(isPresented: $isImporting,
                              allowedContentTypes: [.image],
                              allowsMultipleSelection: true) { result in
                    guard case .success(let urls) = result else { return }
                    picked = urls.map(\\.lastPathComponent)
                }
                .fileDialogMessage("Choose photos for the garden journal.")
                .fileDialogConfirmationLabel("Add")
            """,
            minHeight: 150
        ) {
            VStack(spacing: 12) {
                Button("Add Photos…") { isImporting = true }
                    .fileImporter(isPresented: $isImporting, allowedContentTypes: [.image], allowsMultipleSelection: true) { result in
                        guard case .success(let urls) = result else { return }
                        picked = urls.map(\.lastPathComponent)
                    }
                    .fileDialogMessage("Choose photos for the garden journal.")
                    .fileDialogConfirmationLabel("Add")
                Text(picked.isEmpty ? "No photos chosen." : picked.joined(separator: ", "))
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .lineLimit(3)
                    .frame(maxWidth: 360)
            }
        }
    }
}

private struct ExportTextExample: View {
    @State private var note = "Plant the tulip bulbs before the first frost."
    @State private var isExporting = false
    @State private var status = ""

    var body: some View {
        ExampleCard(
            title: "Save text to a file",
            caption: "`.fileExporter(isPresented:item:)` saves any `Transferable` value, like this `String`.",
            code: """
            @State private var note = "Plant the tulip bulbs before the first frost."
            @State private var isExporting = false

            Button("Export…") { isExporting = true }
                .fileExporter(isPresented: $isExporting,
                              item: note,
                              contentTypes: [.plainText],
                              defaultFilename: "Garden Note") { result in
                    if case .failure(let error) = result {
                        print(error.localizedDescription)
                    }
                }
            """,
            minHeight: 200
        ) {
            VStack(spacing: 12) {
                TextEditor(text: $note)
                    .font(.body)
                    .frame(width: 320, height: 80)
                    .overlay {
                        RoundedRectangle(cornerRadius: 6)
                            .strokeBorder(.separator)
                    }
                Button("Export…") { isExporting = true }
                    .fileExporter(isPresented: $isExporting, item: note, contentTypes: [.plainText], defaultFilename: "Garden Note") { result in
                        switch result {
                        case .success(let url): status = "Saved “\(url.lastPathComponent)”."
                        case .failure(let error): status = error.localizedDescription
                        }
                    } onCancellation: {
                        status = "Canceled."
                    }
                if !status.isEmpty {
                    Text(status)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

private struct MoveFileExample: View {
    @State private var draft: URL?
    @State private var isMoving = false
    @State private var status = "Make a sample file, then move it."

    var body: some View {
        ExampleCard(
            title: "Move a file",
            caption: "`.fileMover` asks where to move a file you already have, like a draft from your app's own folder.",
            code: """
            @State private var draft: URL?
            @State private var isMoving = false

            Button("Move Draft…") { isMoving = true }
                .fileMover(isPresented: $isMoving, file: draft) { result in
                    if case .success(let newURL) = result {
                        draft = newURL
                    }
                }
            """,
            minHeight: 160,
            aside: Aside(.note, "The panel only appears when `file` isn't `nil`. Here the sample file starts in this app's temporary folder.")
        ) {
            VStack(spacing: 12) {
                HStack {
                    Button("Make Sample File") { makeDraft() }
                    Button("Move Draft…") { isMoving = true }
                        .disabled(draft == nil)
                        .fileMover(isPresented: $isMoving, file: draft) { result in
                            switch result {
                            case .success(let newURL):
                                draft = newURL
                                status = "Moved to “\(newURL.deletingLastPathComponent().lastPathComponent)”."
                            case .failure(let error):
                                status = error.localizedDescription
                            }
                        }
                }
                Text(status)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func makeDraft() {
        let url = URL.temporaryDirectory.appending(path: "Garden Draft.txt")
        do {
            try "Notes for next spring.".write(to: url, atomically: true, encoding: .utf8)
            draft = url
            status = "Made “Garden Draft.txt”."
        } catch {
            status = error.localizedDescription
        }
    }
}
