import SwiftUI

/// A page built around one live, configurable demo: preview, generated code,
/// and a controls inspector that edits `Config`. Optional `examples` go below
/// the code (use `ExampleCard`s for common variations).
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
    @Environment(\.horizontalSizeClass) private var sizeClass
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
                    PreviewCard(minHeight: previewHeight, isAttached: true) {
                        preview($config)
                    }
                    .id("preview")
                    Divider()
                    CodeBlock(code: code(config), isCollapsible: true, isAttached: true)
                }
                .cardStyle()
                if sizeClass == .compact {
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
            if let about = page.about {
                AboutSection(text: about)
            }
            VStack(alignment: .leading, spacing: 16) {
                SectionTitle("Usage")
                CodeBlock(code: usage ?? code(initial))
                if let usageNote {
                    usageNote
                }
            }
            .id("code")
            if let composition = page.composition {
                CompositionSection(tree: composition)
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
        .modifier(ControlsPresentation(isPresented: $showControls) {
            Form {
                controls($config)
                Section {
                    Button("Reset", systemImage: "arrow.counterclockwise", role: .destructive) {
                        withAnimation { config = initial }
                    }
                }
            }
        })
        // Set again outside the inspector: on iPad, a title set only inside
        // `.inspector`'s content doesn't reach the navigation bar.
        .navigationTitle(page.title)
        .toolbarTitleDisplayMode(.catalogPage(sizeClass))
        .onGeometryChange(for: CGFloat.self) { $0.size.width } action: { width in
            self.width = width
            // Open the controls on first layout only when the page stays
            // readable beside them; otherwise they wait for the toolbar button.
            guard !didSetInitialControls else { return }
            didSetInitialControls = true
            showControls = LaunchOptions.take("-showControls", page: page.id) || (sizeClass == .regular && width >= Self.inspectorMinWidth)
        }
        .onChange(of: showControls) { _, isShown in
            guard isShown else { return }
            if sizeClass == .compact {
                // The sheet covers the bottom of the screen: bring the
                // preview to the top so edits stay visible.
                withAnimation { proxy.scrollTo("preview", anchor: .top) }
            } else if width < Self.inspectorMinWidth {
                makeRoomForInspector()
            }
        }
    }
}

/// Shows the controls form as a side inspector on wide screens, and as a
/// half-height sheet on iPhone that leaves the preview visible above it.
private struct ControlsPresentation<Panel: View>: ViewModifier {
    @Binding var isPresented: Bool
    @ViewBuilder let panel: Panel
    @Environment(\.horizontalSizeClass) private var sizeClass

    /// Tall enough for about four rows, short enough to leave most of the
    /// preview visible above it.
    private static var compactDetent: PresentationDetent { .height(300) }

    func body(content: Content) -> some View {
        if sizeClass == .compact {
            content
                .sheet(isPresented: $isPresented) {
                    NavigationStack {
                        panel
                            .navigationTitle("Controls")
                            .navigationBarTitleDisplayMode(.inline)
                            .toolbar {
                                ToolbarItem(placement: .confirmationAction) {
                                    Button("Done", systemImage: "checkmark") { isPresented = false }
                                }
                            }
                    }
                    .presentationDetents([Self.compactDetent, .large])
                    .presentationBackgroundInteraction(.enabled(upThrough: Self.compactDetent))
                }
        } else {
            content
                .inspector(isPresented: $isPresented) {
                    panel
                        .inspectorColumnWidth(min: 280, ideal: 320, max: 400)
                }
                // The page scaffold's appearance button doesn't reach the
                // bar once `.inspector` wraps the page, so it's added here.
                .toolbar {
                    ToolbarItemGroup(placement: .primaryAction) {
                        PreviewSchemeMenu()
                        Button("Controls", systemImage: "slider.horizontal.3") {
                            isPresented.toggle()
                        }
                    }
                }
        }
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
