import SwiftUI

/// A page built around one live, configurable demo: preview, generated code,
/// and controls that edit `Config`. Optional `examples` go below the code
/// (use `ExampleCard`s for common variations).
///
/// Where the controls go is `CatalogPlatform.demoControlsPlacement`: on
/// iPhone a sheet and on iPad an inspector (`.presented`); on the Mac inside
/// the demo card, beside the preview (`.attached`), so they scroll away with
/// the demo they change instead of staying on screen with nothing to act on.
///
/// Each demo supplies:
/// - `initial`: the starting configuration
/// - `preview`: the real component, driven by the configuration
/// - `controls`: Form rows that edit the configuration
/// - `code`: the Swift code that reproduces the current configuration
/// - `usage`: the common way to use the component, shown in full under
///   "Usage" (defaults to `code` for the initial configuration)
struct DemoPage<Config, Preview: View, Controls: View, Examples: View>: View {
    let page: ComponentPage
    private let initial: Config
    private let previewHeight: CGFloat
    private let preview: (Binding<Config>) -> Preview
    private let controls: (Binding<Config>) -> Controls
    private let code: (Config) -> String
    private let usage: String?
    private let usageNote: Aside?
    private let examples: Examples

    @State private var config: Config
    @State private var showControls = false
    @State private var didSetInitialControls = false
    @State private var width: CGFloat = 0
    @State private var isPreviewVisible = true
    @Environment(\.isCompactLayout) private var isCompact
    @Environment(\.makeRoomForInspector) private var makeRoomForInspector

    /// Below this width the page and an inspector don't fit side by side.
    private static var inspectorMinWidth: CGFloat { 800 }

    init(
        page: ComponentPage,
        initial: Config,
        previewHeight: CGFloat = 260,
        usage: String? = nil,
        usageNote: Aside? = nil,
        @ViewBuilder preview: @escaping (Binding<Config>) -> Preview,
        @ViewBuilder controls: @escaping (Binding<Config>) -> Controls,
        code: @escaping (Config) -> String,
        @ViewBuilder examples: () -> Examples
    ) {
        self.page = page
        self.initial = initial
        self.previewHeight = previewHeight
        self.preview = preview
        self.controls = controls
        self.code = code
        self.usage = usage
        self.usageNote = usageNote
        self.examples = examples()
        _config = State(initialValue: initial)
    }

    var body: some View {
        ScrollViewReader { proxy in
            scaffold(proxy)
        }
    }

    private func scaffold(_ proxy: ScrollViewProxy) -> some View {
        PageScaffold(page: page) {
            VStack(alignment: .leading, spacing: 12) {
                VStack(spacing: 0) {
                    if Self.attachesControls {
                        attachedPlayground
                            .id("preview")
                    } else {
                        PreviewCard(minHeight: previewHeight, isAttached: true) {
                            preview($config)
                        }
                        .id("preview")
                        .onScrollVisibilityChange(threshold: 0.5) { isPreviewVisible = $0 }
                    }
                    Divider()
                    CodeBlock(code: code(config), isCollapsible: true, isAttached: true)
                }
                .cardStyle()
                if isCompact {
                    Button {
                        showControls = true
                    } label: {
                        Label("Customize", systemImage: "slider.horizontal.3")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                }
            }
            // The live demo's code changes with the controls; the Usage
            // block below exports it for the starting configuration.
            .exportSkipped()
            if let about = page.about {
                AboutSection(text: about)
                    .exportSkipped()
            }
            VStack(alignment: .leading, spacing: 16) {
                SectionTitle("Usage")
                CodeBlock(code: usage ?? code(initial))
                if let usageNote {
                    usageNote
                }
            }
            .id("code")
            .exportBlock { .usage(code: usage ?? code(initial), generatedCode: code(initial), note: usageNote) }
            if let composition = page.composition {
                CompositionSection(tree: composition)
                    .exportSkipped()
            }
            if Examples.self != EmptyView.self {
                VStack(alignment: .leading, spacing: 16) {
                    SectionTitle("Examples")
                    VStack(alignment: .leading, spacing: 44) {
                        examples
                    }
                }
                .id("examples")
            }
        }
        .catalogControlsPresentation(isPresented: $showControls, isEnabled: !Self.attachesControls) {
            Form {
                controls($config)
                Section {
                    Button("Reset", systemImage: "arrow.counterclockwise", role: .destructive) {
                        withAnimation { config = initial }
                    }
                }
            }
        }
        // Set again outside the inspector: on iPad, a title set only inside
        // `.inspector`'s content doesn't reach the navigation bar.
        .navigationTitle(page.title)
        .catalogPageTitle()
        .onGeometryChange(for: CGFloat.self) { $0.size.width } action: { width in
            self.width = width
            // Open the controls on first layout only when the page stays
            // readable beside them; otherwise they wait for the toolbar button.
            guard !Self.attachesControls, !didSetInitialControls else { return }
            didSetInitialControls = true
            showControls = LaunchOptions.take("-showControls", page: page.id) || (!isCompact && width >= Self.inspectorMinWidth)
        }
        .onChange(of: showControls) { _, isShown in
            guard isShown, !Self.attachesControls else { return }
            if isCompact {
                // The sheet covers the bottom of the screen: bring the
                // preview to the top so edits stay visible.
                withAnimation { proxy.scrollTo("preview", anchor: .top) }
            } else {
                if width < Self.inspectorMinWidth {
                    makeRoomForInspector()
                }
                // The inspector edits the preview, so bring it back into
                // view if the page has scrolled past it.
                if !isPreviewVisible {
                    withAnimation { proxy.scrollTo("preview", anchor: .top) }
                }
            }
        }
    }

    private static var attachesControls: Bool {
        CatalogPlatform.demoControlsPlacement == .attached
    }

    /// The preview with its controls beside it, in the same card. In a
    /// narrow window the controls move under the preview.
    private var attachedPlayground: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 0) {
                PreviewCard(minHeight: previewHeight, isAttached: true) {
                    preview($config)
                }
                .frame(minWidth: 340, maxHeight: .infinity)
                // The controls can be taller than the preview; fill the
                // rest of the height with the same surface.
                .background(Surface.preview)
                Divider()
                controlsPanel
                    .frame(width: 280)
            }
            .fixedSize(horizontal: false, vertical: true)
            VStack(spacing: 0) {
                PreviewCard(minHeight: previewHeight, isAttached: true) {
                    preview($config)
                }
                Divider()
                controlsPanel
            }
        }
    }

    private var controlsPanel: some View {
        Form {
            controls($config)
            Section {
                Button("Reset", systemImage: "arrow.counterclockwise") {
                    withAnimation { config = initial }
                }
            }
        }
        .formStyle(.grouped)
        .scrollDisabled(true)
        .scrollContentBackground(.hidden)
        .fixedSize(horizontal: false, vertical: true)
        // Fill the card's height when the preview is the taller side.
        .frame(maxHeight: .infinity, alignment: .top)
        .background(.background.secondary)
    }
}

extension DemoPage where Examples == EmptyView {
    init(
        page: ComponentPage,
        initial: Config,
        previewHeight: CGFloat = 260,
        usage: String? = nil,
        usageNote: Aside? = nil,
        @ViewBuilder preview: @escaping (Binding<Config>) -> Preview,
        @ViewBuilder controls: @escaping (Binding<Config>) -> Controls,
        code: @escaping (Config) -> String
    ) {
        self.init(
            page: page,
            initial: initial,
            previewHeight: previewHeight,
            usage: usage,
            usageNote: usageNote,
            preview: preview,
            controls: controls,
            code: code,
            examples: { EmptyView() }
        )
    }
}
