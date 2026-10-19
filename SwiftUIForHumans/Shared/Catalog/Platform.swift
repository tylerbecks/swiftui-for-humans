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

enum CatalogPlatform {
    /// Whether pages and overviews show their title as a large heading in
    /// the content. iOS shows it as the navigation bar's large title; the
    /// Mac's window toolbar shows it small, so the page shows it too.
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
