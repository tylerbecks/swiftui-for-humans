import SwiftUI

extension ComponentPage {
    static let choosingWrappers = ComponentPage(
        id: "choosing-wrappers",
        title: "Which Wrapper?",
        summary: "Answer two questions to pick the right property wrapper for your data.",
        category: .dataFlow,
        kind: .concept,
        symbol: "signpost.right.and.left",
        availability: ["iOS 17.0+", "macOS 14.0+", "visionOS 1.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/model-data",
        aliases: ["property wrapper", "state management", "useState vs props", "which one", "data flow", "@StateObject vs @ObservedObject", "store", "context", "cheat sheet"],
        related: ["state", "binding", "observable", "environment"],
        notes: [
            "**Start with the smallest tool.** A plain `let` for read-only input, `@State` for a value the view owns. Reach for an `@Observable` class only when several screens share data.",
            "**`$` turns a property into a `Binding`.** It works on `@State`, `@Binding`, and `@Bindable` properties, and it's what controls like `Toggle` and `TextField` take.",
        ]
    ) {
        ChoosingThumbnail()
    } content: { page in
        ChoosingArticle(page: page)
    }
}

// MARK: - Thumbnail

private struct ChoosingThumbnail: View {
    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "questionmark")
                    .font(.subheadline.bold())
                    .foregroundStyle(.white)
                    .frame(width: 28, height: 28)
                    .background(Color.accentColor, in: .circle)
                Text("Who owns the data?")
                    .font(.subheadline.weight(.semibold))
            }
            Image(systemName: "arrow.down")
                .font(.caption.bold())
                .foregroundStyle(.secondary)
            VStack(spacing: 6) {
                HStack(spacing: 6) {
                    ChoosingChip(text: "@State", color: .blue)
                    ChoosingChip(text: "@Binding", color: .green)
                }
                HStack(spacing: 6) {
                    ChoosingChip(text: "@Bindable", color: .teal)
                    ChoosingChip(text: "@Environment", color: .orange)
                }
            }
        }
    }
}

private struct ChoosingChip: View {
    let text: String
    let color: Color

    var body: some View {
        Text(text)
            .font(.caption.monospaced().weight(.semibold))
            .foregroundStyle(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.14), in: .capsule)
            .fixedSize()
    }
}

// MARK: - Decision data

private enum ChoosingSource: CaseIterable, Identifiable {
    case creates, parent, environment

    var id: Self { self }

    var title: String {
        switch self {
        case .creates: "This view creates it"
        case .parent: "A parent passes it in"
        case .environment: "The system or a distant ancestor"
        }
    }

    var detail: String {
        switch self {
        case .creates: "A toggle's on/off, text being typed, a screen's model"
        case .parent: "A row's item, a child editing its parent's value"
        case .environment: "Dark mode, dismiss, an app-wide settings object"
        }
    }

    var symbol: String {
        switch self {
        case .creates: "sparkles"
        case .parent: "arrow.down.square"
        case .environment: "globe"
        }
    }

    var question: String {
        switch self {
        case .creates: "What kind of data is it?"
        case .parent: "Does this view need to change it?"
        case .environment: "What is it?"
        }
    }

    var answers: [ChoosingAnswer] {
        switch self {
        case .creates: [
            ChoosingAnswer(title: "A simple value", detail: "Bool, Int, String, an enum, or a small struct", result: .state),
            ChoosingAnswer(title: "A model shared with other views", detail: "A class with data and logic, like a cart or a profile", result: .stateObservable),
        ]
        case .parent: [
            ChoosingAnswer(title: "No, it only shows it", detail: "Read-only input, like a prop", result: .plainLet),
            ChoosingAnswer(title: "Yes, and it's a simple value", detail: "The parent keeps it in @State", result: .binding),
            ChoosingAnswer(title: "Yes, and it's an @Observable model", detail: "The child needs $model.property for a control", result: .bindable),
        ]
        case .environment: [
            ChoosingAnswer(title: "A system value or action", detail: "colorScheme, locale, dismiss, openURL…", result: .environment),
            ChoosingAnswer(title: "My own @Observable model", detail: "Injected higher up with .environment(model)", result: .environmentObservable),
        ]
        }
    }
}

private struct ChoosingAnswer: Identifiable {
    var id: String { title }
    let title: String
    let detail: String
    let result: ChoosingResult
}

private enum ChoosingResult {
    case state, stateObservable, plainLet, binding, bindable, environment, environmentObservable

    var title: String {
        switch self {
        case .state: "@State"
        case .stateObservable: "@Observable + @State"
        case .plainLet: "A plain let"
        case .binding: "@Binding"
        case .bindable: "@Bindable"
        case .environment: "@Environment(\\.key)"
        case .environmentObservable: "@Environment(Model.self)"
        }
    }

    var color: Color {
        switch self {
        case .state, .stateObservable: .blue
        case .plainLet: .gray
        case .binding: .green
        case .bindable: .teal
        case .environment, .environmentObservable: .orange
        }
    }

    var explanation: String {
        switch self {
        case .state:
            "The view owns the value. Mark it `private` and pass `$value` to any control or child that edits it."
        case .stateObservable:
            "Mark the class `@Observable`, then create it once with `@State` in the view that owns it. Pass it down to the views that need it."
        case .plainLet:
            "No wrapper needed. The child redraws on its own whenever the parent passes a new value."
        case .binding:
            "The child reads and writes the parent's `@State` directly. The parent passes it with `$`."
        case .bindable:
            "Pass the model as usual, and mark the property `@Bindable` so you can write `$cart.coupon`."
        case .environment:
            "Read a value the system or an ancestor provides. Mark it `private`. For your own values, add one with `@Entry`."
        case .environmentObservable:
            "An ancestor calls `.environment(model)` once. Any view below reads it by type, with no passing through every layer."
        }
    }

    var analogy: String {
        switch self {
        case .state: "React: useState"
        case .stateObservable: "React: a store, like Zustand or MobX"
        case .plainLet: "React: a prop"
        case .binding: "React: a prop plus its setter"
        case .bindable: "React: a store object passed as a prop"
        case .environment: "React: useContext"
        case .environmentObservable: "React: a context provider holding a store"
        }
    }

    var code: String {
        switch self {
        case .state:
            """
            @State private var isOn = false

            Toggle("Wi-Fi", isOn: $isOn)
            """
        case .stateObservable:
            """
            @Observable
            class Cart {
                var items: [String] = []
            }

            // In the view that owns it:
            @State private var cart = Cart()
            """
        case .plainLet:
            """
            struct Row: View {
                let title: String

                var body: some View {
                    Text(title)
                }
            }
            """
        case .binding:
            """
            struct WiFiRow: View {
                @Binding var isOn: Bool

                var body: some View {
                    Toggle("Wi-Fi", isOn: $isOn)
                }
            }

            // Parent: WiFiRow(isOn: $isOn)
            """
        case .bindable:
            """
            struct CouponField: View {
                @Bindable var cart: Cart

                var body: some View {
                    TextField("Coupon", text: $cart.coupon)
                }
            }
            """
        case .environment:
            """
            @Environment(\\.dismiss) private var dismiss

            Button("Done") { dismiss() }
            """
        case .environmentObservable:
            """
            // High up: ContentView().environment(cart)

            @Environment(Cart.self) private var cart

            Text("\\(cart.items.count) items")
            """
        }
    }

    var pageID: String {
        switch self {
        case .state: "state"
        case .stateObservable, .bindable: "observable"
        case .plainLet, .binding: "binding"
        case .environment, .environmentObservable: "environment"
        }
    }
}

// MARK: - Article

private struct ChoosingArticle: View {
    let page: ComponentPage

    var body: some View {
        ArticlePage(page: page) {
            Prose("Picking the wrong property wrapper is the most common cause of \"why isn't my view updating?\" bugs. The right one depends on two things: **who owns the data**, and **who needs to change it**.")

            ChoosingGuide()

            SectionTitle("Cheat sheet")
            ChoosingSummaryTable()

            Aside(.important, "Give each piece of data one owner. If two views each keep their own `@State` for the same thing, they drift apart. Move it up to their nearest common parent and pass it down.")

            SectionTitle("Older names you'll see")
            Prose("Tutorials from before iOS 17 use `ObservableObject`. It still works, but new code uses the simpler `@Observable` versions:")
            ChoosingLegacyTable()
        }
    }
}

private struct ChoosingGuide: View {
    @State private var source: ChoosingSource?
    @State private var answer: ChoosingAnswer.ID?
    @Environment(\.openPage) private var openPage

    private var result: ChoosingResult? {
        guard let source, let answer else { return nil }
        return source.answers.first { $0.id == answer }?.result
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Decision guide")
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Button("Start over", systemImage: "arrow.counterclockwise") {
                    source = nil
                    answer = nil
                }
                .font(.subheadline)
                .disabled(source == nil)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)

            Divider()

            VStack(alignment: .leading, spacing: 20) {
                ChoosingStep(number: 1, question: "Where does the data come from?") {
                    ForEach(ChoosingSource.allCases) { option in
                        ChoosingOptionButton(
                            title: option.title,
                            detail: option.detail,
                            symbol: option.symbol,
                            isSelected: source == option,
                            isDimmed: source != nil && source != option
                        ) {
                            source = option
                            answer = nil
                        }
                        .accessibilityIdentifier("choose-source-\(option)")
                    }
                }

                if let source {
                    ChoosingStep(number: 2, question: source.question) {
                        ForEach(source.answers) { option in
                            ChoosingOptionButton(
                                title: option.title,
                                detail: option.detail,
                                symbol: nil,
                                isSelected: answer == option.id,
                                isDimmed: answer != nil && answer != option.id
                            ) {
                                answer = option.id
                            }
                        }
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }

                if let result {
                    ChoosingResultCard(result: result) {
                        openPage(result.pageID)
                    }
                    .id(result.title)
                    .transition(.opacity.combined(with: .scale(scale: 0.96, anchor: .top)))
                }
            }
            .padding(16)
        }
        .cardStyle()
        .animation(.snappy, value: source)
        .animation(.snappy, value: answer)
    }
}

private struct ChoosingStep<Content: View>: View {
    let number: Int
    let question: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Text("\(number)")
                    .font(.caption.bold())
                    .foregroundStyle(.white)
                    .frame(width: 22, height: 22)
                    .background(Color.accentColor, in: .circle)
                Text(question)
                    .font(.headline)
            }
            content
        }
    }
}

private struct ChoosingOptionButton: View {
    let title: String
    let detail: String
    let symbol: String?
    let isSelected: Bool
    let isDimmed: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                if let symbol {
                    Image(systemName: symbol)
                        .font(.body.weight(.semibold))
                        .foregroundStyle(Color.accentColor)
                        .frame(width: 28)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                    Text(detail)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .multilineTextAlignment(.leading)
                Spacer(minLength: 4)
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isSelected ? Color.accentColor : Color.secondary.opacity(0.5))
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(isSelected ? Color.accentColor.opacity(0.12) : Color.clear, in: .rect(cornerRadius: 12))
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(isSelected ? Color.accentColor : Color.secondary.opacity(0.25), lineWidth: isSelected ? 1.5 : 1)
            }
            .contentShape(.rect(cornerRadius: 12))
            .opacity(isDimmed ? 0.55 : 1)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

private struct ChoosingResultCard: View {
    let result: ChoosingResult
    let openPage: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                Text("Use")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(result.title)
                    .font(.title3.monospaced().bold())
                    .foregroundStyle(result.color)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            RichText(result.explanation)
                .fixedSize(horizontal: false, vertical: true)
            Label(result.analogy, systemImage: "globe")
                .font(.footnote)
                .foregroundStyle(.secondary)
            CodeBlock(code: result.code)
            Button(action: openPage) {
                Label("Open the \(Catalog.page(id: result.pageID)?.title ?? "") page", systemImage: "arrow.right")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .accessibilityIdentifier("choose-open-page")
        }
        .padding(14)
        .background(result.color.opacity(0.08), in: .rect(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(result.color.opacity(0.4))
        }
    }
}

// MARK: - Tables

private struct ChoosingSummaryTable: View {
    private struct Row: Identifiable {
        var id: String { wrapper }
        let wrapper: String
        let color: Color
        let owner: String
        let canWrite: Bool
        let web: String
    }

    private let rows = [
        Row(wrapper: "@State", color: .blue, owner: "This view", canWrite: true, web: "useState"),
        Row(wrapper: "let", color: .gray, owner: "Parent", canWrite: false, web: "props"),
        Row(wrapper: "@Binding", color: .green, owner: "Parent", canWrite: true, web: "prop + setter"),
        Row(wrapper: "@Bindable", color: .teal, owner: "Model", canWrite: true, web: "store prop"),
        Row(wrapper: "@Environment", color: .orange, owner: "Ancestor", canWrite: false, web: "useContext"),
    ]

    var body: some View {
        Grid(alignment: .leading, horizontalSpacing: 12, verticalSpacing: 0) {
            GridRow {
                Text("Wrapper")
                Text("Owner")
                Text("Writes")
                Text("Web")
            }
            .font(.caption.weight(.semibold))
            .foregroundStyle(.secondary)
            .padding(.vertical, 10)

            ForEach(rows) { row in
                Divider()
                GridRow {
                    Text(row.wrapper)
                        .font(.footnote.monospaced().weight(.semibold))
                        .foregroundStyle(row.color)
                    Text(row.owner)
                    Image(systemName: row.canWrite ? "checkmark" : "minus")
                        .foregroundStyle(row.canWrite ? Color.green : Color.secondary)
                        .accessibilityLabel(row.canWrite ? "Yes" : "No")
                        .gridColumnAlignment(.center)
                    Text(row.web)
                        .foregroundStyle(.secondary)
                }
                .font(.footnote)
                .padding(.vertical, 10)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 4)
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle()
    }
}

private struct ChoosingLegacyTable: View {
    private let rows: [(String, String)] = [
        ("ObservableObject + @Published", "@Observable"),
        ("@StateObject", "@State"),
        ("@ObservedObject", "let or @Bindable"),
        ("@EnvironmentObject", "@Environment(Model.self)"),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(rows.enumerated()), id: \.offset) { index, row in
                if index > 0 { Divider() }
                ViewThatFits(in: .horizontal) {
                    HStack(spacing: 8) {
                        Text(row.0)
                            .foregroundStyle(.secondary)
                            .fixedSize()
                        Image(systemName: "arrow.right")
                            .foregroundStyle(.green)
                        Text(row.1)
                            .fixedSize()
                        Spacer(minLength: 0)
                    }
                    VStack(alignment: .leading, spacing: 3) {
                        Text(row.0)
                            .foregroundStyle(.secondary)
                        Label(row.1, systemImage: "arrow.turn.down.right")
                            .labelStyle(ChoosingTightLabelStyle())
                    }
                }
                .font(.footnote.monospaced())
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle()
    }
}

private struct ChoosingTightLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 6) {
            configuration.icon
                .foregroundStyle(.green)
            configuration.title
        }
    }
}
