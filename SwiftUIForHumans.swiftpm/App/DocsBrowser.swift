import SwiftUI
import WebKit

/// A URL to show in `DocsBrowser`.
struct BrowserPage: Identifiable {
    let url: URL
    var id: URL { url }
}

/// An in-app browser for Apple's docs and design guidelines, built on
/// SwiftUI's `WebView` (iOS 26).
///
/// It only browses Apple's sites (and swift.org). A link anywhere else opens
/// in Safari instead. An in-app browser that can go anywhere counts as
/// unrestricted web access in the App Store age rating questionnaire, which
/// raises the rating.
struct DocsBrowser: View {
    let url: URL
    @State private var page = WebPage(navigationDecider: AppleSitesOnly())
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            WebView(page)
                .ignoresSafeArea(edges: .bottom)
                .overlay(alignment: .top) {
                    if page.isLoading {
                        ProgressView(value: page.estimatedProgress)
                            .progressViewStyle(.linear)
                    }
                }
                .navigationTitle(page.title.isEmpty ? "Loading…" : page.title)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button(role: .close) { dismiss() }
                    }
                    ToolbarItemGroup(placement: .primaryAction) {
                        ShareLink(item: page.url ?? url)
                        Link(destination: page.url ?? url) {
                            Label("Open in Safari", systemImage: "safari")
                        }
                        // The app sends web links here; this one should
                        // really leave for Safari.
                        .environment(\.openURL, OpenURLAction { _ in .systemAction })
                    }
                }
        }
        .presentationSizing(.page)
        .onAppear {
            page.load(URLRequest(url: url))
        }
    }
}

/// The sites the in-app browser shows.
enum AppleSites {
    static let hosts = ["apple.com", "swift.org"]

    static func contains(_ url: URL) -> Bool {
        guard url.scheme == "https" || url.scheme == "http", let host = url.host()?.lowercased() else { return false }
        return hosts.contains { host == $0 || host.hasSuffix(".\($0)") }
    }
}

/// Keeps the browser on Apple's sites and sends any other link to Safari.
private struct AppleSitesOnly: WebPage.NavigationDeciding {
    func decidePolicy(for action: WebPage.NavigationAction, preferences: inout WebPage.NavigationPreferences) async -> WKNavigationActionPolicy {
        guard let url = action.request.url else { return .cancel }
        // Pages load images and frames from other hosts; only check where
        // the page itself goes.
        if url.scheme == "about" || url.scheme == "blob" || url.scheme == "data" || AppleSites.contains(url) {
            return .allow
        }
        // SwiftUI's `openURL` isn't reachable from here, and this link should
        // leave the app anyway.
        await UIApplication.shared.open(url)
        return .cancel
    }
}
