import SwiftUI
#if canImport(UIKit)
import UIKit
#else
import AppKit
#endif

// The few places where iOS and macOS need different code. The engine uses
// these instead of `#if os(...)`, and pages never need either: each page
// belongs to one edition.

#if canImport(UIKit)
typealias PlatformFont = UIFont
#else
typealias PlatformFont = NSFont
#endif

enum Pasteboard {
    /// Puts plain text on the clipboard.
    @MainActor static func copy(_ text: String) {
        #if canImport(UIKit)
        UIPasteboard.general.string = text
        #else
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
        #endif
    }
}

extension EnvironmentValues {
    /// True on iPhone, or an iPad window narrow enough to use the iPhone
    /// layout. Always false on the Mac, where windows are never "compact".
    var isCompactLayout: Bool {
        #if os(iOS)
        horizontalSizeClass == .compact
        #else
        false
        #endif
    }
}

/// The pointer effect for something people click, on iPad.
enum CatalogHover {
    case lift
    case highlight
}

extension View {
    /// The iPad pointer effect. The Mac has no pointer effects, so it adds
    /// nothing there.
    @ViewBuilder
    func catalogHover(_ effect: CatalogHover) -> some View {
        #if os(iOS)
        switch effect {
        case .lift: hoverEffect(.lift)
        case .highlight: hoverEffect(.highlight)
        }
        #else
        self
        #endif
    }

    /// A small, inline title for a sheet. The Mac has no navigation bar
    /// title modes, so it adds nothing there.
    @ViewBuilder
    func catalogInlineTitle() -> some View {
        #if os(iOS)
        navigationBarTitleDisplayMode(.inline)
        #else
        self
        #endif
    }

    /// Page titles: a large title on iPhone that collapses as the page
    /// scrolls. On iPad the title stays large in the bar (`.inlineLarge`):
    /// a collapsing large title opens collapsed, and so invisible, whenever
    /// the sidebar swaps the detail page. The Mac shows it in the window's
    /// toolbar as usual.
    func catalogPageTitle() -> some View {
        modifier(CatalogPageTitle())
    }
}

private struct CatalogPageTitle: ViewModifier {
    @Environment(\.isCompactLayout) private var isCompact

    func body(content: Content) -> some View {
        #if os(iOS)
        content.toolbarTitleDisplayMode(isCompact ? .large : .inlineLarge)
        #else
        content
        #endif
    }
}

extension Color {
    /// The plain background behind content: white or black on iOS, the
    /// window background on the Mac.
    static var catalogBackground: Color {
        #if canImport(UIKit)
        Color(.systemBackground)
        #else
        Color(nsColor: .windowBackgroundColor)
        #endif
    }

    /// The background behind grouped lists and forms.
    static var catalogGroupedBackground: Color {
        #if canImport(UIKit)
        Color(.systemGroupedBackground)
        #else
        Color(nsColor: .windowBackgroundColor)
        #endif
    }
}

/// Where a `DemoPage` puts its controls.
enum DemoControlsPlacement {
    /// Inside the demo card, beside the preview, scrolling with it.
    case attached
    /// In a sheet on iPhone, or an inspector on iPad.
    case presented
}

enum CatalogPlatform {
    static var demoControlsPlacement: DemoControlsPlacement {
        #if os(macOS)
        .attached
        #else
        .presented
        #endif
    }

    /// Whether pages and overviews show their title as a large heading in
    /// the content. iOS shows it as the navigation bar's large title; the
    /// Mac's window toolbar shows it small, so the page shows it too.
    /// The modifiers for Previous / Next Page. ⌘[ and ⌘] are Back and
    /// Forward on the Mac, as in Finder and Safari, so pages step with ⌥⌘.
    static var pageStepModifiers: EventModifiers {
        #if os(macOS)
        [.command, .option]
        #else
        [.command]
        #endif
    }

    static var showsTitleInContent: Bool {
        #if os(macOS)
        true
        #else
        false
        #endif
    }
}

extension ToolbarItemPlacement {
    /// The trailing end of the navigation bar on iOS, and the primary
    /// action spot in the Mac window's toolbar.
    static var catalogTrailing: Self {
        #if os(iOS)
        .topBarTrailing
        #else
        .primaryAction
        #endif
    }
}

extension View {
    /// Presents a `DemoPage`'s controls where this platform puts them: a
    /// sheet on iPhone, an inspector on iPad. Does nothing when `isEnabled`
    /// is false, as on the Mac, where the controls sit in the demo card.
    func catalogControlsPresentation<Panel: View>(isPresented: Binding<Bool>, isEnabled: Bool, @ViewBuilder panel: () -> Panel) -> some View {
        modifier(ControlsPresentation(isPresented: isPresented, isEnabled: isEnabled, panel: panel))
    }
}

/// Shows the controls form as a side inspector on wide screens, and as a
/// half-height sheet on iPhone that leaves the preview visible above it.
private struct ControlsPresentation<Panel: View>: ViewModifier {
    @Binding var isPresented: Bool
    let isEnabled: Bool
    @ViewBuilder let panel: Panel
    @Environment(\.isCompactLayout) private var isCompact

    /// Tall enough for about four rows, short enough to leave most of the
    /// preview visible above it.
    private static var compactDetent: PresentationDetent { .height(300) }

    func body(content: Content) -> some View {
        if !isEnabled {
            content
        } else {
            presented(content)
        }
    }

    @ViewBuilder
    private func presented(_ content: Content) -> some View {
        #if os(iOS)
        if isCompact {
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
            inspector(content)
        }
        #else
        inspector(content)
        #endif
    }

    private func inspector(_ content: Content) -> some View {
        content
            .inspector(isPresented: $isPresented) {
                panel
                    .inspectorColumnWidth(min: 280, ideal: 320, max: 400)
            }
            // The page scaffold's appearance button doesn't reach the
            // bar once `.inspector` wraps the page, so it's added here.
            .toolbar {
                ToolbarItemGroup(placement: .primaryAction) {
                    #if os(iOS)
                    PreviewSchemeMenu()
                    #endif
                    Button("Controls", systemImage: "slider.horizontal.3") {
                        isPresented.toggle()
                    }
                }
            }
    }
}
