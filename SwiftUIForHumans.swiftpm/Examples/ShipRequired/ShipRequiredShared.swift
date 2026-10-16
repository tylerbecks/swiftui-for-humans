import SwiftUI

// Small drawings shared by the Required by Apple pages, for Do / Don't
// previews where a whole PhoneScreen would be too big. Not interactive.

/// A small screen with an inline title and grouped rows, like a Settings page.
struct ShipMiniScreen<Content: View>: View {
    let title: String
    var width: CGFloat = 250
    @ViewBuilder let content: Content

    var body: some View {
        VStack(spacing: 10) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .frame(maxWidth: .infinity)
                .padding(.top, 12)
            VStack(alignment: .leading, spacing: 10) {
                content
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 14)
        }
        .frame(width: width)
        .background(Color(.systemGroupedBackground), in: .rect(cornerRadius: 20))
        .overlay {
            RoundedRectangle(cornerRadius: 20).strokeBorder(.separator)
        }
        .allowsHitTesting(false)
    }
}

/// A group of rows inside a `ShipMiniScreen`.
struct ShipMiniGroup: View {
    var header: String? = nil
    let rows: [ShipMiniRow]
    var footer: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let header {
                Text(header.uppercased())
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .padding(.leading, 10)
            }
            VStack(spacing: 0) {
                ForEach(Array(rows.enumerated()), id: \.offset) { index, row in
                    if index > 0 { Divider().padding(.leading, 10) }
                    row
                }
            }
            .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 10))
            if let footer {
                Text(footer)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 10)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

struct ShipMiniRow: View {
    let title: String
    var value: String? = nil
    var tint: Color? = nil
    var chevron = false

    var body: some View {
        HStack {
            Text(title)
                .foregroundStyle(tint.map { AnyShapeStyle($0) } ?? AnyShapeStyle(.primary))
            Spacer(minLength: 6)
            if let value {
                Text(value).foregroundStyle(.secondary)
            }
            if chevron {
                Image(systemName: "chevron.right")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
        }
        .font(.footnote)
        .lineLimit(1)
        .padding(.horizontal, 10)
        .padding(.vertical, 9)
    }
}
