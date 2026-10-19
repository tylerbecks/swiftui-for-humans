import SwiftUI

extension ComponentPage {
    static let stateBinding = ComponentPage(
        id: "state-binding",
        title: "State & Binding",
        summary: "@State keeps a value a view owns, and @Binding lets another view change it.",
        category: .dataFlow,
        kind: .concept,
        symbol: "arrow.left.arrow.right.circle",
        availability: ["macOS 10.15+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/state",
        aliases: [
            "@State", "@Binding", "state", "binding", "useState", "props", "two-way binding", "v-model",
            "source of truth", "$", "projected value", "constant", "selection", "local state",
        ],
        related: ["observable", "environment", "toggle", "table"],
        notes: [
            "**Declare `@State` as `private`.** Apple's docs say so: setting it from an initializer can conflict with the storage SwiftUI manages for it.",
            "**With Xcode 27, `@State` is a macro.** It creates its starting value only the first time SwiftUI makes the view, so a model object in `@State` isn't rebuilt each time the parent redraws.",
            "**Only the owner says `@State`.** Every other view gets either a plain value to read or a `Binding` to write. Two `@State` properties for one value means two copies that drift apart.",
        ],
        api: [
            APIItem("`@State private var`", "A value this view owns and SwiftUI stores."),
            APIItem("`@Binding var`", "Reads and writes a value another view owns."),
            APIItem("`$value`", "The binding to a `@State` value, to pass along."),
            APIItem("`$draft.title`", "A binding to one property of a struct."),
            APIItem("`ForEach($items) { $item in }`", "A binding to each element of an array."),
            APIItem("`.constant(_:)`", "A binding that never changes, for previews."),
        ]
    ) {
        MacStateBindingThumbnail()
    } content: { page in
        MacStateBindingArticle(page: page)
    }
}

// MARK: - Thumbnail

private struct MacStateBindingThumbnail: View {
    var body: some View {
        HStack(spacing: 10) {
            VStack(spacing: 4) {
                Text("@State")
                    .font(.caption.monospaced().weight(.semibold))
                Toggle("Playing", isOn: .constant(true))
                    .toggleStyle(.checkbox)
                    .font(.caption)
            }
            .padding(10)
            .background(.fill.tertiary, in: .rect(cornerRadius: 10))
            Image(systemName: "arrow.left.arrow.right")
                .foregroundStyle(.tint)
            VStack(spacing: 4) {
                Text("@Binding")
                    .font(.caption.monospaced().weight(.semibold))
                Image(systemName: "pause.fill")
                    .imageScale(.large)
            }
            .padding(10)
            .background(.fill.tertiary, in: .rect(cornerRadius: 10))
        }
    }
}

// MARK: - Page

private struct MacStateBindingArticle: View {
    let page: ComponentPage

    var body: some View {
        ArticlePage(page: page) {
            Prose("Every value a view shows has one owner, its **source of truth**. Mark it `@State` in the view that owns it, and SwiftUI stores it and redraws whatever reads it when it changes.")
            Prose("When another view needs to change that value, such as a button in the window's toolbar, pass it a **binding** with `$`. The child declares `@Binding` and reads and writes the owner's value directly, like a controlled input in React.")

            SectionTitle("Try it")
            Prose("The window owns `isPlaying`. The play button in its toolbar only has a binding, yet clicking it changes what the window shows.")
            MacOwnerAndChildDiagram()

            SectionTitle("Which one to use")
            ConnectFacts(rows: [
                ("This view creates the value and changes it", "`@State private var isPlaying = false`"),
                ("A child view changes the owner's value", "`@Binding var isPlaying: Bool`, passed as `$isPlaying`"),
                ("A child view only shows it", "A plain property: `let isPlaying: Bool`"),
                ("Several windows or many views share it", "An [Observable](catalog://observable) model class, kept in `@State` once"),
            ])

            SectionTitle("Examples")
                .id("examples")
            MacStateBindingExamples()
        }
    }
}

/// The owner and child, drawn as two labeled boxes around a live window:
/// the window's content reads the state, and the toolbar button writes it
/// through a binding.
private struct MacOwnerAndChildDiagram: View {
    @State private var isPlaying = false

    var body: some View {
        VStack(spacing: 16) {
            MacWindowFrame(title: "Podcasts", width: 420, height: 170) {
                VStack(spacing: 8) {
                    Image(systemName: isPlaying ? "waveform" : "waveform.slash")
                        .font(.system(size: 34))
                        .foregroundStyle(isPlaying ? AnyShapeStyle(.tint) : AnyShapeStyle(.secondary))
                        .contentTransition(.symbolEffect(.replace))
                    Text(isPlaying ? "Playing “Episode 12”" : "Paused")
                        .foregroundStyle(.secondary)
                }
            } toolbar: {
                MacPlayButton(isPlaying: $isPlaying)
            }
            HStack(alignment: .top, spacing: 12) {
                MacDiagramBox(
                    title: "Owner: the window",
                    code: "@State private var isPlaying = \(isPlaying)",
                    detail: "Stores the value and redraws when it changes."
                )
                Image(systemName: "arrow.left.arrow.right")
                    .foregroundStyle(.tint)
                    .padding(.top, 26)
                MacDiagramBox(
                    title: "Child: the play button",
                    code: "@Binding var isPlaying: Bool",
                    detail: "Gets `$isPlaying` and writes straight to the owner."
                )
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(Surface.preview)
        .cardStyle()
    }
}

private struct MacDiagramBox: View {
    let title: String
    let code: String
    let detail: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.subheadline.weight(.semibold))
            Text(code)
                .font(.caption.monospaced())
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(.fill.tertiary, in: .rect(cornerRadius: 5))
            RichText(detail)
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(12)
        .frame(maxWidth: 220, alignment: .leading)
        .overlay {
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(.separator)
        }
    }
}

private struct MacPlayButton: View {
    @Binding var isPlaying: Bool

    var body: some View {
        Button(isPlaying ? "Pause" : "Play", systemImage: isPlaying ? "pause.fill" : "play.fill") {
            isPlaying.toggle()
        }
        .labelStyle(.iconOnly)
        .buttonStyle(.borderless)
    }
}

// MARK: - Examples

private struct MacStateBindingExamples: View {
    @State private var showsCompleted = true
    @State private var draft = MacNoteDraft()
    @State private var tasks = MacTaskItem.samples
    @State private var selection: Set<MacMailbox.ID> = ["inbox"]

    var body: some View {
        VStack(alignment: .leading, spacing: 44) {
            ExampleCard(
                title: "A view option the view owns",
                caption: "Use `@State` for a value only this view needs, like whether a list shows finished tasks. Controls take `$showsCompleted`.",
                code: """
                @State private var showsCompleted = true

                let tasks = ["Write outline", "Record intro", "Edit episode"]
                let finished: Set = ["Write outline"]

                VStack(alignment: .leading) {
                    Toggle("Show completed", isOn: $showsCompleted)
                    ForEach(tasks, id: \\.self) { task in
                        if showsCompleted || !finished.contains(task) {
                            Label(task, systemImage: finished.contains(task) ? "checkmark.circle.fill" : "circle")
                        }
                    }
                }
                """,
                minHeight: 170
            ) {
                let tasks = ["Write outline", "Record intro", "Edit episode"]
                let finished: Set = ["Write outline"]
                VStack(alignment: .leading) {
                    Toggle("Show completed", isOn: $showsCompleted)
                    ForEach(tasks, id: \.self) { task in
                        if showsCompleted || !finished.contains(task) {
                            Label(task, systemImage: finished.contains(task) ? "checkmark.circle.fill" : "circle")
                        }
                    }
                }
                .frame(width: 220, alignment: .leading)
                .animation(.snappy, value: showsCompleted)
            }

            ExampleCard(
                title: "Selection is a binding too",
                caption: "`List(selection:)` writes the selected rows into your `@State`. With a `Set`, people can select several rows on the Mac without an edit mode.",
                code: """
                struct Mailbox: Identifiable {
                    let id: String
                    let name: String
                    let symbol: String
                }

                let mailboxes = [
                    Mailbox(id: "inbox", name: "Inbox", symbol: "tray"),
                    Mailbox(id: "flagged", name: "Flagged", symbol: "flag"),
                    Mailbox(id: "drafts", name: "Drafts", symbol: "doc"),
                    Mailbox(id: "sent", name: "Sent", symbol: "paperplane"),
                ]

                @State private var selection: Set<Mailbox.ID> = ["inbox"]

                List(mailboxes, selection: $selection) { mailbox in
                    Label(mailbox.name, systemImage: mailbox.symbol)
                }
                Text("\\(selection.count) selected")
                """,
                minHeight: 230,
                aside: Aside(.note, "Bind to a single optional ID instead of a `Set` when only one row can be selected at a time.")
            ) {
                VStack(spacing: 8) {
                    List(MacMailbox.samples, selection: $selection) { mailbox in
                        Label(mailbox.name, systemImage: mailbox.symbol)
                    }
                    .frame(width: 240, height: 150)
                    .clipShape(.rect(cornerRadius: 8))
                    Text("\(selection.count) selected")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
            }

            ExampleCard(
                title: "Bind to one property of a struct",
                caption: "Keep related fields in one struct in `@State`. `$draft.title` is a binding to just that field, so each control edits its own part.",
                code: """
                struct NoteDraft {
                    var title = "Weekly review"
                    var isPinned = false
                    var color = Color.yellow
                }

                @State private var draft = NoteDraft()

                Form {
                    TextField("Title", text: $draft.title)
                    Toggle("Pin to top", isOn: $draft.isPinned)
                    ColorPicker("Color", selection: $draft.color)
                }
                """,
                minHeight: 160
            ) {
                Form {
                    TextField("Title", text: $draft.title)
                    Toggle("Pin to top", isOn: $draft.isPinned)
                    ColorPicker("Color", selection: $draft.color)
                }
                .frame(width: 300)
            }

            ExampleCard(
                title: "A binding for each row",
                caption: "`ForEach($tasks) { $task in … }` hands every row a binding to its own element, so a checkbox can tick off one task in the array.",
                code: """
                struct TaskItem: Identifiable {
                    let id = UUID()
                    var title: String
                    var isDone = false
                }

                @State private var tasks = [
                    TaskItem(title: "Export the audio"),
                    TaskItem(title: "Write show notes", isDone: true),
                    TaskItem(title: "Upload the episode"),
                ]

                VStack(alignment: .leading) {
                    ForEach($tasks) { $task in
                        Toggle(task.title, isOn: $task.isDone)
                    }
                    Text("\\(tasks.filter(\\.isDone).count) of \\(tasks.count) done")
                        .foregroundStyle(.secondary)
                }
                """,
                minHeight: 160
            ) {
                VStack(alignment: .leading) {
                    ForEach($tasks) { $task in
                        Toggle(task.title, isOn: $task.isDone)
                    }
                    Text("\(tasks.filter(\.isDone).count) of \(tasks.count) done")
                        .foregroundStyle(.secondary)
                        .contentTransition(.numericText())
                        .animation(.snappy, value: tasks.filter(\.isDone).count)
                }
                .frame(width: 220, alignment: .leading)
            }

            ExampleCard(
                title: "Write your own control with @Binding",
                caption: "A reusable control declares `@Binding` and never owns the value. Pass `.constant(_:)` when you only need to show it, as in a preview.",
                code: """
                struct RatingControl: View {
                    @Binding var rating: Int

                    var body: some View {
                        HStack(spacing: 2) {
                            ForEach(1...5, id: \\.self) { star in
                                Button("\\(star) stars", systemImage: star <= rating ? "star.fill" : "star") {
                                    rating = star
                                }
                                .labelStyle(.iconOnly)
                                .buttonStyle(.borderless)
                            }
                        }
                    }
                }

                @State private var rating = 3

                VStack {
                    RatingControl(rating: $rating)
                    RatingControl(rating: .constant(5))
                        .disabled(true)
                }
                """,
                minHeight: 140,
                aside: Aside(.important, "Don't add `@State` inside the control to copy the value. The copy stops following the owner, and the two disagree.")
            ) {
                MacRatingSample()
            }
        }
    }
}

private struct MacRatingSample: View {
    @State private var rating = 3

    var body: some View {
        VStack(spacing: 12) {
            MacRatingControl(rating: $rating)
            MacRatingControl(rating: .constant(5))
                .disabled(true)
            Text("rating = \(rating)")
                .font(.footnote.monospaced())
                .foregroundStyle(.secondary)
        }
    }
}

private struct MacRatingControl: View {
    @Binding var rating: Int

    var body: some View {
        HStack(spacing: 2) {
            ForEach(1...5, id: \.self) { star in
                Button("\(star) stars", systemImage: star <= rating ? "star.fill" : "star") {
                    rating = star
                }
                .labelStyle(.iconOnly)
                .buttonStyle(.borderless)
            }
        }
        .imageScale(.large)
    }
}

// MARK: - Sample data

private struct MacNoteDraft {
    var title = "Weekly review"
    var isPinned = false
    var color = Color.yellow
}

private struct MacTaskItem: Identifiable {
    let id = UUID()
    var title: String
    var isDone = false

    static let samples = [
        MacTaskItem(title: "Export the audio"),
        MacTaskItem(title: "Write show notes", isDone: true),
        MacTaskItem(title: "Upload the episode"),
    ]
}

private struct MacMailbox: Identifiable {
    let id: String
    let name: String
    let symbol: String

    static let samples = [
        MacMailbox(id: "inbox", name: "Inbox", symbol: "tray"),
        MacMailbox(id: "flagged", name: "Flagged", symbol: "flag"),
        MacMailbox(id: "drafts", name: "Drafts", symbol: "doc"),
        MacMailbox(id: "sent", name: "Sent", symbol: "paperplane"),
    ]
}
