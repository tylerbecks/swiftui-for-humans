---
id: welcome-window
title: Welcome window
platforms: [macOS]
availability: macOS 15.0+
docs: https://developer.apple.com/documentation/swiftui/scene/defaultlaunchbehavior(_:).md
hig: https://developer.apple.com/design/human-interface-guidelines/launching.md
---

# Welcome window

The window a document app shows at launch, with New, Open, and recent files.

## Contents

- Built from
- Rules
- Pitfalls
- Key APIs
- Variants
- Related

## Built from

Window("Welcome to Notes", id:)
├── .windowStyle(.hiddenTitleBar)
├── .defaultLaunchBehavior(.presented)
└── WelcomeView
    ├── icon, name, version
    ├── New and Open buttons
    └── List (recent documents)

## Rules

- **Put people back where they were.** If documents were open when people quit, reopen them instead of greeting them again. With `.presented`, the welcome window shows only when nothing comes back.
- **Offer recent files next to Open.** Most of the time people want what they had yesterday. A list of recent documents saves a trip through the open panel.
- **Get out of the way fast.** People want to start right away. Keep the window to a few ways in, so they can pick one and get to work.

## Pitfalls

- **It appears only when nothing is restored.** With `.defaultLaunchBehavior(.presented)`, the welcome window shows at launch when no document windows come back, and when people click the Dock icon with no windows open.
- **Recent files come from AppKit.** SwiftUI has no list of recent documents, so the block reads AppKit's `NSDocumentController.shared.recentDocumentURLs`.

## Key APIs

`Window(_:id:)`, `.defaultLaunchBehavior(.presented)`, `.restorationBehavior(.disabled)`, `.windowStyle(.hiddenTitleBar)`, `.windowBackgroundDragBehavior`, `\.newDocument`, `\.openDocument`, `\.dismissWindow`

## Variants

### Icon, actions, and recent files

A `Window` with a hidden title bar and a material background. `newDocument` and `openDocument` from the environment do the work.

```swift
@main
struct NotesApp: App {
    var body: some Scene {
        DocumentGroup(newDocument: TextDocument()) { file in
            TextEditor(text: file.$document.text)
        }

        Window("Welcome to Notes", id: "welcome") {
            WelcomeView()
                .toolbar(removing: .title)
                .containerBackground(.thickMaterial, for: .window)
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .windowBackgroundDragBehavior(.enabled)
        .defaultLaunchBehavior(.presented)
        .restorationBehavior(.disabled)
    }
}

struct WelcomeView: View {
    @Environment(\.newDocument) private var newDocument
    @Environment(\.openDocument) private var openDocument
    @Environment(\.dismissWindow) private var dismissWindow
    @State private var isImporting = false
    @State private var openError: String?

    // SwiftUI has no list of recent documents; AppKit keeps it.
    private let recents = NSDocumentController.shared.recentDocumentURLs

    var body: some View {
        HStack(spacing: 0) {
            VStack(spacing: 10) {
                Image(systemName: "note.text")
                    .font(.system(size: 64))
                    .foregroundStyle(.tint)
                Text("Notes")
                    .font(.largeTitle.bold())
                Text("Version 2.0")
                    .foregroundStyle(.secondary)
                VStack(alignment: .leading, spacing: 8) {
                    Button("Create New Document", systemImage: "plus") {
                        newDocument(TextDocument())
                        dismissWindow(id: "welcome")
                    }
                    Button("Open Existing Document…", systemImage: "folder") {
                        isImporting = true
                    }
                }
                .buttonStyle(.borderless)
                .padding(.top, 16)
            }
            .frame(width: 300)
            .padding(32)

            List(recents, id: \.self) { url in
                Button {
                    open(url)
                } label: {
                    Label {
                        VStack(alignment: .leading) {
                            Text(url.deletingPathExtension().lastPathComponent)
                            Text(url.deletingLastPathComponent().path(percentEncoded: false))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    } icon: {
                        Image(systemName: "doc.text")
                    }
                }
                .buttonStyle(.plain)
            }
            .frame(width: 280)
        }
        .frame(height: 400)
        .fileImporter(isPresented: $isImporting, allowedContentTypes: [.plainText]) { result in
            if case .success(let url) = result {
                open(url)
            }
        }
        .alert("Couldn't Open the Document", isPresented: Binding {
            openError != nil
        } set: { isShown in
            if !isShown { openError = nil }
        }) {
            Button("OK") {}
        } message: {
            Text(openError ?? "")
        }
    }

    // Close the welcome window only once the document is open. A recent
    // file may have moved; keep the window so people can pick another.
    private func open(_ url: URL) {
        Task {
            do {
                try await openDocument(at: url)
                dismissWindow(id: "welcome")
            } catch {
                openError = error.localizedDescription
            }
        }
    }
}
```

**Note:** The block uses the `TextDocument` from [Document editor](document-editor.md).

## Related

[document-editor](document-editor.md), [window](window.md), [window-style](window-style.md), [opening-windows](opening-windows.md), [onboarding](onboarding.md)
