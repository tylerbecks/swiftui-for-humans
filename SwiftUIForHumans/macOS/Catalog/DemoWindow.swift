import SwiftUI

/// A real window a page can open, for demos that only make sense in a
/// window of their own: toolbars, split views, window styles, Settings.
///
/// Declare it in your group's `<group>DemoWindows` list, then put an
/// `OpenDemoWindowButton(id:)` on the page:
///
/// ```swift
/// DemoWindow(id: "toolbar-basic", title: "Toolbar") {
///     ToolbarDemo()
/// }
/// ```
struct DemoWindow: Identifiable, Sendable {
    let id: String
    let title: String
    /// The window's size when it opens. People can resize it.
    let size: CGSize
    private let content: @MainActor @Sendable () -> AnyView

    init<Content: View>(
        id: String,
        title: String,
        size: CGSize = CGSize(width: 720, height: 460),
        @ViewBuilder content: @escaping @MainActor @Sendable () -> Content
    ) {
        self.id = id
        self.title = title
        self.size = size
        self.content = { AnyView(content()) }
    }

    @MainActor
    func makeContent() -> AnyView {
        content()
    }

    /// The scene that hosts every demo window.
    static let sceneID = "demo"
}

extension Catalog {
    static func demoWindow(id: DemoWindow.ID?) -> DemoWindow? {
        demoWindows.first { $0.id == id }
    }
}

/// Opens one of the edition's demo windows.
struct OpenDemoWindowButton: View {
    let id: DemoWindow.ID
    var label = "Open as Window"
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        Button(label, systemImage: "macwindow.badge.plus") {
            openWindow(id: DemoWindow.sceneID, value: id)
        }
    }
}

/// The root of a demo window. It opens at the demo's own size: the frame is
/// fixed for the first layout, so the window fits it, then relaxes to a
/// minimum so people can resize the window.
struct DemoWindowRoot: View {
    let id: DemoWindow.ID?
    @State private var isSized = false

    var body: some View {
        if let window = Catalog.demoWindow(id: id) {
            window.makeContent()
                .frame(
                    minWidth: isSized ? 320 : window.size.width,
                    maxWidth: isSized ? .infinity : window.size.width,
                    minHeight: isSized ? 200 : window.size.height,
                    maxHeight: isSized ? .infinity : window.size.height
                )
                .navigationTitle(window.title)
                .task {
                    try? await Task.sleep(for: .milliseconds(300))
                    isSized = true
                }
        } else {
            ContentUnavailableView("No Demo", systemImage: "macwindow", description: Text("This demo window isn't available."))
                .frame(minWidth: 320, minHeight: 200)
        }
    }
}
