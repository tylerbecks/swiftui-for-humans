import Foundation
import SwiftUI
import Testing
@testable import SwiftUIForHumans

/// Renders every page offscreen and checks that it exports its text. With
/// `SFH_EXPORT_DIR` set in the test runner's environment, also writes the
/// edition's catalog there as `<edition>.json`.
///
/// xcodebuild passes its own `TEST_RUNNER_<NAME>` variables to the tests as
/// `<NAME>`, so `TEST_RUNNER_SFH_EXPORT_DIR=/some/dir scripts/build.sh
/// test-ios` exports the iOS edition. The sandboxed Mac app attaches the
/// file to the test results instead. scripts/export-catalog.sh does both
/// editions and puts the files in agent/build/.
@MainActor
struct ExportCatalogTests {
    @Test func everyPageExportsItsText() throws {
        var pages: [ExportPage] = []
        for page in Catalog.pages {
            let blocks = Self.blocks(for: page)
            #expect(!page.summary.isEmpty, "\(page.id) has no summary")
            #expect(!blocks.isEmpty, "\(page.id) exported no body blocks")
            pages.append(ExportPage(page, blocks: blocks))
        }
        #expect(pages.count == Catalog.pages.count)

        let catalog = ExportCatalog(edition: CatalogPlatform.editionName, pages: pages)
        let data = try Self.encode(catalog)
        // It reads back, so the generator can rely on the format.
        let decoded = try JSONDecoder().decode(ExportCatalog.self, from: data)
        #expect(decoded.pages.map(\.id) == Catalog.pages.map(\.id))

        if let directory = ProcessInfo.processInfo.environment["SFH_EXPORT_DIR"], !directory.isEmpty {
            let name = "\(catalog.edition).json"
            let folder = URL(filePath: directory, directoryHint: .isDirectory)
            do {
                try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
                try data.write(to: folder.appending(path: name), options: .atomic)
            } catch where Self.isSandboxed {
                // The Mac app is sandboxed and can't write outside its
                // container. Attach the file to the test results instead;
                // scripts/export-catalog.sh copies it out from there.
                Attachment.record(data, named: name)
            }
        }
    }

    /// Blocks arrive in document order, an example's code and aside stay
    /// inside the example, and text comes out exactly as the app has it.
    @Test func blocksKeepOrderAndText() {
        let collector = ExportCollector()
        Self.render(ExportCollecting(collector: collector) {
            VStack {
                SectionTitle("First")
                Prose("Use `Text(\"\\(count)\")`.")
                ExampleCard(title: "Card", caption: "A caption.", code: "Text(\"\\(name)\")", aside: Aside(.important, "Watch out.")) {
                    Prose("Inside the preview, so not exported.")
                }
                Aside(.note, "A note.")
                CodeBlock(code: "let x = 1")
                ConnectSteps(steps: ["One", "Two"])
                ConnectFacts(rows: [(label: "Size", value: "44pt")])
                Checklist(pageID: "export-test", items: [ChecklistItem("a", "Title", "Detail", page: "stepper")])
                PageHeader(page: Catalog.pages[0])
                    .exportSkipped()
            }
        })
        #expect(collector.blocks == [
            .heading("First"),
            .prose("Use `Text(\"\\(count)\")`."),
            .example(title: "Card", caption: "A caption.", code: "Text(\"\\(name)\")", aside: Aside(.important, "Watch out.")),
            .aside(Aside(.note, "A note.")),
            .code("let x = 1"),
            .steps(["One", "Two"]),
            .facts([(label: "Size", value: "44pt")]),
            .checklist([ChecklistItem("a", "Title", "Detail", page: "stepper")]),
        ])
        // The source's `\\(name)` is the text `\(name)`.
        #expect(collector.blocks[2].code == #"Text("\(name)")"#)
    }

    /// Outside the export, views report nothing.
    @Test func nothingIsReportedByDefault() {
        let collector = ExportCollector()
        Self.render(ExportCollecting(collector: collector) {
            Prose("Hello")
                .environment(\.exportsCatalogText, false)
        })
        #expect(collector.blocks.isEmpty)
    }

    // MARK: - Helpers

    static var isSandboxed: Bool {
        ProcessInfo.processInfo.environment["APP_SANDBOX_CONTAINER_ID"] != nil
    }

    static func blocks(for page: ComponentPage) -> [ExportBlock] {
        let collector = ExportCollector()
        render(ExportCollecting(collector: collector) {
            page.makeContent()
        })
        return collector.blocks
    }

    /// Lays out `view` once. Pages scroll, so their content gets its full
    /// height whatever size is proposed; nothing in a page's own text sits
    /// in a lazy stack.
    ///
    /// On iOS the page goes in a hosting controller, the way the app shows
    /// it. `ImageRenderer` can't draw UIKit-backed views (the navigation
    /// stack inside a `PhoneScreen`, switches, segmented pickers), and on
    /// CI that tripped an AttributeGraph precondition ("accessing attribute
    /// in a different namespace") that crashed the test host.
    static func render(_ view: some View) {
        let sized = view.frame(width: 700, height: 1000)
        #if canImport(UIKit)
        // Preferences only resolve once the hosting view is in a window.
        let frame = CGRect(x: 0, y: 0, width: 700, height: 1000)
        let scene = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first
        let window = scene.map { UIWindow(windowScene: $0) } ?? UIWindow(frame: frame)
        window.frame = frame
        window.rootViewController = UIHostingController(rootView: sized)
        window.isHidden = false
        window.layoutIfNeeded()
        RunLoop.main.run(until: .now + 0.05)
        window.layoutIfNeeded()
        window.isHidden = true
        window.rootViewController = nil
        #else
        _ = ImageRenderer(content: sized).cgImage
        #endif
    }

    static func encode(_ catalog: ExportCatalog) throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        var data = try encoder.encode(catalog)
        data.append(contentsOf: "\n".utf8)
        return data
    }
}
