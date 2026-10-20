import SwiftUI

// Small views for Ship pages on every edition: numbered steps and fact cards.

/// Numbered steps, for instructions in App Store Connect or Xcode.
struct ConnectSteps: View {
    let steps: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                HStack(alignment: .firstTextBaseline, spacing: 12) {
                    Text("\(index + 1)")
                        .font(.subheadline.weight(.bold).monospacedDigit())
                        .foregroundStyle(.white)
                        .frame(width: 24, height: 24)
                        .background(Color.accentColor, in: .circle)
                        .alignmentGuide(.firstTextBaseline) { $0[VerticalAlignment.center] + 5 }
                    RichText(step)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }
}

/// A card of label / value rows, like a spec sheet. Values support inline
/// Markdown.
struct ConnectFacts: View {
    let rows: [(label: String, value: String)]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(rows.enumerated()), id: \.offset) { index, row in
                if index > 0 {
                    Divider()
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text(row.label)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.secondary)
                    RichText(row.value)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 12)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 2)
        .cardStyle()
    }
}
