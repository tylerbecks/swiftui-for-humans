import SwiftUI
import WebKit

/// A URL to show in `DocsBrowser`.
struct BrowserPage: Identifiable {
    let url: URL
    var id: URL { url }
}

/// An in-app browser for Apple's docs and design guidelines, built on
/// SwiftUI's `WebView` (iOS 26).
struct DocsBrowser: View {
    let url: URL
    @State private var page = WebPage()
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
