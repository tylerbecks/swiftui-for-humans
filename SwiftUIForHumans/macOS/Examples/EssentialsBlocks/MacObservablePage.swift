import SwiftUI

extension ComponentPage {
    static let observable = ComponentPage(
        id: "observable",
        title: "Observable",
        summary: "One model class that every window, sidebar, and inspector reads and updates.",
        category: .dataFlow,
        kind: .concept,
        symbol: "point.3.connected.trianglepath.dotted",
        availability: ["macOS 14.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/managing-model-data-in-your-app",
        aliases: [
            "@Observable", "@Bindable", "Observation", "model", "view model", "store", "ObservableObject",
            "@StateObject", "@EnvironmentObject", "shared state", "Redux", "global state", "ObservationIgnored",
        ],
        related: ["state-binding", "environment", "window-group", "settings-scene", "inspector"],
        notes: [
            "**Views update only for what their `body` reads.** A view that shows a title redraws when the title changes, not when some other property of the same model does.",
            "**A missing model is a crash.** Reading `@Environment(Model.self)` when no view above put one there stops the app. Declare the property as `Model?` where it may be missing.",
            "**Replaces `ObservableObject` for new code.** No `@Published`, `@StateObject`, or `@EnvironmentObject`: use `@State`, `@Bindable`, and `@Environment(Model.self)`.",
        ],
        api: [
            APIItem("`@Observable class Model`", "Makes every stored property observable."),
            APIItem("`@State private var model = Model()`", "Owns the model; create it once, at the top."),
            APIItem("`.environment(model)`", "Shares it with a scene or view and everything inside."),
            APIItem("`@Environment(Model.self)`", "Reads the shared model anywhere below."),
            APIItem("`@Bindable var model`", "Makes `$model.title` bindings for controls."),
            APIItem("`@ObservationIgnored`", "Leaves a property out of tracking."),
        ]
    ) {
        MacObservableThumbnail()
    } content: { page in
        MacObservableArticle(page: page)
    }
}

extension Catalog {
    /// A real window that shares one model with the Observable page.
    static let observableDemoWindow = DemoWindow(
        id: "observable-reading-list",
        title: "Reading List",
        size: CGSize(width: 380, height: 300)
    ) {
        MacReadingListWindowContent(model: MacReadingList.shared)
    }
}

// MARK: - Model

/// The model the page and its demo window share. One instance for the
/// whole app, like a model created once in the `App`.
@MainActor
@Observable
final class MacReadingList {
    static let shared = MacReadingList()

    var articles = [
        MacArticle(title: "Designing for the Mac"),
        MacArticle(title: "Toolbars that stay out of the way", isRead: true),
        MacArticle(title: "Keyboard shortcuts people expect"),
        MacArticle(title: "Windows, tabs, and spaces"),
    ]
    var showsUnreadCount = true

    var unreadCount: Int {
        articles.filter { !$0.isRead }.count
    }
}

struct MacArticle: Identifiable {
    let id = UUID()
    var title: String
    var isRead = false
}

// MARK: - Thumbnail

private struct MacObservableThumbnail: View {
    var body: some View {
        VStack(spacing: 8) {
            Text("@Observable")
                .font(.caption.monospaced().weight(.semibold))
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(.tint.opacity(0.15), in: .capsule)
            HStack(spacing: 8) {
                ForEach(["macwindow", "sidebar.right", "gearshape"], id: \.self) { symbol in
                    Image(systemName: symbol)
                        .frame(width: 34, height: 28)
                        .background(.fill.tertiary, in: .rect(cornerRadius: 6))
                }
            }
            .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Page

private struct MacObservableArticle: View {
    let page: ComponentPage
    @Bindable private var model = MacReadingList.shared

    var body: some View {
        ArticlePage(page: page) {
            Prose("A Mac app often shows the same data in several places at once: two windows, a sidebar and an inspector, the Settings window. Put that data in a class marked `@Observable`, create it once, and hand it to each place that needs it.")
            Prose("SwiftUI watches which properties each view's `body` reads. When one of them changes, those views redraw, in every window. There's nothing to publish or subscribe to.")

            SectionTitle("Try it")
            Prose("The window below and a real window share one model. Open the window, tick off an article there, and watch the count here change.")
            VStack(spacing: 16) {
                MacWindowFrame(title: "Reader", width: 420, height: 200) {
                    MacReadingListContent(model: model)
                } toolbar: {
                    if model.showsUnreadCount {
                        Text("\(model.unreadCount) unread")
                            .font(.callout.monospacedDigit())
                            .contentTransition(.numericText())
                    }
                }
                OpenDemoWindowButton(id: "observable-reading-list", label: "Open the Reading List Window")
                    .controlSize(.large)
            }
            .animation(.snappy, value: model.unreadCount)
            .padding(24)
            .frame(maxWidth: .infinity)
            .background(Surface.preview)
            .cardStyle()

            SectionTitle("Which property wrapper")
            ConnectFacts(rows: [
                ("The view that creates the model", "`@State private var library = Library()`"),
                ("A view that shows it", "A plain property: `var library: Library`"),
                ("A view whose controls edit it", "`@Bindable var library: Library`, then `$library.name`"),
                ("A view far below, or in another scene", "`@Environment(Library.self) private var library`"),
            ])

            SectionTitle("Examples")
                .id("examples")
            MacObservableExamples(model: model)
        }
    }
}

/// The article list, editable. Used inline and in the demo window.
private struct MacReadingListContent: View {
    @Bindable var model: MacReadingList

    var body: some View {
        List {
            ForEach($model.articles) { $article in
                Toggle(isOn: $article.isRead) {
                    Text(article.title)
                        .foregroundStyle(article.isRead ? .secondary : .primary)
                }
            }
        }
        .scrollDisabled(true)
    }
}

/// The demo window's content: the same list, plus a count in the window's
/// own toolbar.
private struct MacReadingListWindowContent: View {
    @Bindable var model: MacReadingList

    var body: some View {
        NavigationStack {
            List {
                ForEach($model.articles) { $article in
                    Toggle(article.title, isOn: $article.isRead)
                }
            }
            .navigationSubtitle("\(model.unreadCount) unread")
        }
    }
}

// MARK: - Examples

private struct MacObservableExamples: View {
    @Bindable var model: MacReadingList
    @State private var article = MacEditableArticle()

    var body: some View {
        VStack(alignment: .leading, spacing: 44) {
            ExampleCard(
                title: "Create it once, share it with every scene",
                caption: "Own the model with `@State` in your `App`, then pass it to each scene with `.environment(_:)`. Every window and Settings get the same instance.",
                code: """
                @Observable
                class ReadingList {
                    var articles: [Article] = []
                    var showsUnreadCount = true

                    var unreadCount: Int {
                        articles.filter { !$0.isRead }.count
                    }
                }

                struct Article: Identifiable {
                    let id = UUID()
                    var title: String
                    var isRead = false
                }

                @main
                struct ReaderApp: App {
                    @State private var readingList = ReadingList()

                    var body: some Scene {
                        WindowGroup {
                            ContentView()
                        }
                        .environment(readingList)

                        Settings {
                            SettingsView()
                        }
                        .environment(readingList)
                    }
                }
                """,
                minHeight: 220,
                aside: Aside(.note, "Change the setting in the small window and the toolbar of the other one follows. They read the same model.")
            ) {
                HStack(alignment: .top, spacing: 16) {
                    MacWindowFrame(title: "Reader", width: 240, height: 130) {
                        VStack(spacing: 6) {
                            Image(systemName: "books.vertical")
                                .font(.title)
                                .foregroundStyle(.secondary)
                            Text("\(model.articles.count) articles")
                                .foregroundStyle(.secondary)
                        }
                    } toolbar: {
                        if model.showsUnreadCount {
                            Text("\(model.unreadCount) unread")
                                .font(.callout.monospacedDigit())
                        }
                    }
                    MacWindowFrame(title: "Settings", width: 200, height: 130) {
                        Toggle("Show unread count", isOn: $model.showsUnreadCount)
                            .toggleStyle(.checkbox)
                    }
                }
            }

            ExampleCard(
                title: "Edit it with @Bindable",
                caption: "Declare the view's model `@Bindable` to get bindings like `$article.title` for controls, such as the fields in an inspector.",
                code: """
                @Observable
                class EditableArticle {
                    var title = "Designing for the Mac"
                    var author = "Sam Lee"
                    var isRead = false
                }

                struct ArticleInspector: View {
                    @Bindable var article: EditableArticle

                    var body: some View {
                        Form {
                            TextField("Title", text: $article.title)
                            TextField("Author", text: $article.author)
                            Toggle("Read", isOn: $article.isRead)
                        }
                    }
                }
                """,
                minHeight: 170
            ) {
                VStack(spacing: 14) {
                    MacArticleInspector(article: article)
                        .frame(width: 320)
                    Text("“\(article.title)” by \(article.author)")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
            }

            ExampleCard(
                title: "Read it from the environment",
                caption: "Deep in the view tree, read the model with `@Environment(ReadingList.self)`. For bindings, wrap it in a local `@Bindable` inside `body`.",
                code: """
                struct UnreadSettings: View {
                    @Environment(ReadingList.self) private var readingList

                    var body: some View {
                        @Bindable var readingList = readingList
                        Form {
                            Toggle("Show unread count", isOn: $readingList.showsUnreadCount)
                            LabeledContent("Unread", value: readingList.unreadCount, format: .number)
                        }
                    }
                }
                """,
                minHeight: 140
            ) {
                MacUnreadSettings()
                    .environment(model)
                    .frame(width: 320)
            }

            ExampleCard(
                title: "Leave a property out with @ObservationIgnored",
                caption: "Mark caches and other bookkeeping `@ObservationIgnored`. Changing them never redraws a view.",
                code: """
                @Observable
                class PhotoLibrary {
                    var photos: [URL] = []

                    @ObservationIgnored
                    var thumbnailCache: [URL: Data] = [:]
                }
                """,
                minHeight: 120
            ) {
                VStack(alignment: .leading, spacing: 8) {
                    Label("`photos`: tracked, redraws views", systemImage: "eye")
                    Label("`thumbnailCache`: ignored", systemImage: "eye.slash")
                        .foregroundStyle(.secondary)
                }
                .font(.callout)
            }
        }
    }
}

@MainActor
@Observable
private final class MacEditableArticle {
    var title = "Designing for the Mac"
    var author = "Sam Lee"
    var isRead = false
}

private struct MacArticleInspector: View {
    @Bindable var article: MacEditableArticle

    var body: some View {
        Form {
            TextField("Title", text: $article.title)
            TextField("Author", text: $article.author)
            Toggle("Read", isOn: $article.isRead)
        }
    }
}

private struct MacUnreadSettings: View {
    @Environment(MacReadingList.self) private var readingList

    var body: some View {
        @Bindable var readingList = readingList
        Form {
            Toggle("Show unread count", isOn: $readingList.showsUnreadCount)
            LabeledContent("Unread", value: readingList.unreadCount, format: .number)
        }
    }
}
