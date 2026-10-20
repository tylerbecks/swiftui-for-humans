import SwiftUI

// Small drawings shared by the Ship pages. Everything here is a picture
// made of live SwiftUI views, never a screenshot of Apple's UI.

/// One row in a `ShipMenuSketch`.
enum ShipMenuRow: Hashable {
    case item(String, shortcut: String = "", isEnabled: Bool = true)
    case separator
}

/// A drawing of an open menu, for Do / Don't pairs about menu items.
struct ShipMenuSketch: View {
    var title: String
    let rows: [ShipMenuRow]
    var width: CGFloat = 210

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Color.accentColor.opacity(0.18), in: .rect(cornerRadius: 5))
                .padding(.bottom, 4)
            VStack(alignment: .leading, spacing: 0) {
                ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                    switch row {
                    case .item(let name, let shortcut, let isEnabled):
                        HStack {
                            Text(name)
                            Spacer(minLength: 12)
                            Text(shortcut)
                                .foregroundStyle(.secondary)
                        }
                        .font(.callout)
                        .opacity(isEnabled ? 1 : 0.4)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 3)
                    case .separator:
                        Divider()
                            .padding(.vertical, 4)
                            .padding(.horizontal, 10)
                    }
                }
            }
            .padding(.vertical, 5)
            .frame(width: width, alignment: .leading)
            .background(.background, in: .rect(cornerRadius: 8))
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(.separator)
            }
            .shadow(color: .black.opacity(0.12), radius: 6, y: 3)
        }
        .accessibilityElement(children: .combine)
    }
}

/// A row of steps joined by arrows, like Archive → Sign → Notarize.
struct ShipFlow: View {
    let steps: [(symbol: String, title: String)]

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 10) { content(arrow: "arrow.right") }
            VStack(spacing: 8) { content(arrow: "arrow.down") }
        }
    }

    @ViewBuilder
    private func content(arrow: String) -> some View {
        ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
            if index > 0 {
                Image(systemName: arrow)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.tertiary)
            }
            VStack(spacing: 6) {
                Image(systemName: step.symbol)
                    .font(.title2)
                    .foregroundStyle(.tint)
                    .frame(height: 28)
                Text(step.title)
                    .font(.caption.weight(.medium))
                    .multilineTextAlignment(.center)
                    .fixedSize()
            }
            .frame(minWidth: 76)
            .padding(.vertical, 10)
            .padding(.horizontal, 6)
            .background(.fill.quaternary, in: .rect(cornerRadius: 10))
        }
    }
}

/// The overview card picture used by most Ship pages: a symbol and a
/// short caption.
struct ShipThumbnail: View {
    let symbol: String
    let caption: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: symbol)
                .font(.system(size: 34))
                .foregroundStyle(.tint)
            Text(caption)
                .font(.caption.weight(.semibold))
                .multilineTextAlignment(.center)
        }
    }
}
