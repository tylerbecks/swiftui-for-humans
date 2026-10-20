import SwiftUI

// Small views shared by the Patterns pages: a drawn alert for Do / Don't
// previews, a decision table, and a mini screen frame.

/// A drawing of a system alert, for side-by-side Do / Don't previews where
/// a real `.alert` can't be shown. Not interactive.
struct PatternMockAlert: View {
    let title: String
    var message: String? = nil
    var buttons: [String] = ["OK"]
    /// Index of the button drawn bold, like a default action.
    var boldIndex: Int? = nil
    var destructiveIndex: Int? = nil

    var body: some View {
        VStack(spacing: 14) {
            VStack(spacing: 4) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                if let message {
                    Text(message)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)

            let layout = buttons.count > 2
                ? AnyLayout(VStackLayout(spacing: 6))
                : AnyLayout(HStackLayout(spacing: 6))
            layout {
                ForEach(Array(buttons.enumerated()), id: \.offset) { index, title in
                    Text(title)
                        .font(.subheadline.weight(index == boldIndex ? .semibold : .regular))
                        .foregroundStyle(index == destructiveIndex ? AnyShapeStyle(.red) : AnyShapeStyle(.primary))
                        .lineLimit(1)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(.fill.secondary, in: .capsule)
                }
            }
        }
        .padding(16)
        .frame(width: 230)
        .background(.regularMaterial, in: .rect(cornerRadius: 26))
        .overlay {
            RoundedRectangle(cornerRadius: 26).strokeBorder(.separator)
        }
        .shadow(color: .black.opacity(0.12), radius: 12, y: 4)
        .accessibilityElement(children: .combine)
    }
}

/// One row of a "which one should I use?" table.
struct PatternChoice: Identifiable {
    let symbol: String
    let title: String
    let detail: String
    var id: String { title }
}

/// A compact decision table: an icon, a name in code style or bold, and
/// when to use it.
struct PatternDecisionTable: View {
    let rows: [PatternChoice]

    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(rows.enumerated()), id: \.element.id) { index, row in
                if index > 0 {
                    Divider().padding(.leading, 52)
                }
                HStack(alignment: .firstTextBaseline, spacing: 12) {
                    Image(systemName: row.symbol)
                        .font(.body)
                        .foregroundStyle(.tint)
                        .frame(width: 28)
                    VStack(alignment: .leading, spacing: 3) {
                        RichText(row.title)
                            .font(.body.weight(.semibold))
                        RichText(row.detail)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 12)
            }
        }
        .cardStyle()
    }
}

/// A small phone-shaped outline for Do / Don't previews of whole screens.
struct PatternMiniScreen<Content: View>: View {
    var width: CGFloat = 170
    var height: CGFloat = 260
    @ViewBuilder let content: Content

    var body: some View {
        content
            .frame(width: width, height: height)
            .background(.background)
            .clipShape(.rect(cornerRadius: 24))
            .padding(4)
            .background(Color(white: 0.15), in: .rect(cornerRadius: 28))
    }
}
