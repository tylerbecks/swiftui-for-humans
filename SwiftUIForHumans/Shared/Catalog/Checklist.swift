import SwiftUI

/// One thing to check off on a Ship page.
struct ChecklistItem: Identifiable, Sendable {
    /// Stable and unique within the page; it keys the saved checkmark.
    let id: String
    /// Bold, short: "Add a privacy policy link".
    let title: String
    /// One line of detail. Supports inline Markdown.
    let detail: String
    /// A page that explains this item, opened as `catalog://<id>`.
    let pageID: ComponentPage.ID?

    init(_ id: String, _ title: String, _ detail: String, page pageID: ComponentPage.ID? = nil) {
        self.id = id
        self.title = title
        self.detail = detail
        self.pageID = pageID
    }
}

/// A list of things to check off before shipping, like a pre-flight
/// checklist. Checkmarks are saved per page and item, so they survive
/// relaunches. Rows look like an inset grouped list, but live inside the
/// page's scroll view.
///
///     Checklist(pageID: page.id, items: [
///         ChecklistItem("privacy-policy", "Add a privacy policy link",
///                       "Required in the app and in App Store Connect.",
///                       page: "privacy-details"),
///     ])
struct Checklist: View {
    let pageID: ComponentPage.ID
    let items: [ChecklistItem]
    /// Bumped by Reset so the rows reread their saved state.
    @State private var resetCount = 0
    @State private var doneIDs: Set<String> = []

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                Text("\(doneIDs.count) of \(items.count) done")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
                    .contentTransition(.numericText())
                Spacer()
                Button("Reset", role: .destructive) {
                    for item in items {
                        UserDefaults.standard.removeObject(forKey: Self.key(pageID: pageID, itemID: item.id))
                    }
                    withAnimation {
                        doneIDs = []
                        resetCount += 1
                    }
                }
                .font(.subheadline)
                .disabled(doneIDs.isEmpty)
            }
            .padding(.horizontal, 4)

            VStack(spacing: 0) {
                ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                    if index > 0 {
                        Divider().padding(.leading, 52)
                    }
                    ChecklistRow(storageKey: Self.key(pageID: pageID, itemID: item.id), item: item) { isDone in
                        withAnimation {
                            if isDone { doneIDs.insert(item.id) } else { doneIDs.remove(item.id) }
                        }
                    }
                }
            }
            .id(resetCount)
            .background(.background.secondary, in: .rect(cornerRadius: 16))
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(.separator)
            }
        }
        .exportBlock { .checklist(items) }
        .onAppear {
            doneIDs = Set(items.map(\.id).filter {
                UserDefaults.standard.bool(forKey: Self.key(pageID: pageID, itemID: $0))
            })
        }
    }

    static func key(pageID: ComponentPage.ID, itemID: String) -> String {
        "checklist.\(pageID).\(itemID)"
    }
}

private struct ChecklistRow: View {
    let item: ChecklistItem
    let changed: (Bool) -> Void
    @AppStorage private var isDone: Bool

    init(storageKey: String, item: ChecklistItem, changed: @escaping (Bool) -> Void) {
        self.item = item
        self.changed = changed
        _isDone = AppStorage(wrappedValue: false, storageKey)
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Button {
                isDone.toggle()
                changed(isDone)
                if isDone { Engagement.shared.recordSuccess() }
            } label: {
                Image(systemName: isDone ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(isDone ? AnyShapeStyle(.tint) : AnyShapeStyle(.tertiary))
                    .contentTransition(.symbolEffect(.replace))
                    .frame(width: 28, height: 28)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(item.title)
            .accessibilityValue(isDone ? "Done" : "Not done")
            .accessibilityAddTraits(.isToggle)
            .sensoryFeedback(.selection, trigger: isDone)

            VStack(alignment: .leading, spacing: 3) {
                RichText(item.title)
                    .font(.body.weight(.semibold))
                    .strikethrough(isDone, color: .secondary)
                    .foregroundStyle(isDone ? .secondary : .primary)
                RichText(item.detail)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                if let pageID = item.pageID, let page = Catalog.page(id: pageID),
                   let url = URL(string: "catalog://\(pageID)") {
                    Link(destination: url) {
                        Text("Read: \(page.title) \(Image(systemName: "chevron.right"))")
                    }
                    .font(.subheadline.weight(.medium))
                    .padding(.top, 2)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
    }
}
