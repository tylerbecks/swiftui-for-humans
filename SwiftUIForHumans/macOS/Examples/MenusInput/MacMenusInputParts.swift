import SwiftUI

// Small drawings shared by this group's pages. A real menu only appears
// while it's open, so Do / Don't pairs draw one instead.

/// One row in a `MenusInputMenuDrawing`.
struct MenusInputMenuRow: Identifiable {
    enum Kind {
        case item(title: String, shortcut: String?, isEnabled: Bool, isDestructive: Bool)
        case divider
    }

    let id = UUID()
    let kind: Kind

    static func item(_ title: String, _ shortcut: String? = nil, isEnabled: Bool = true, isDestructive: Bool = false) -> Self {
        Self(kind: .item(title: title, shortcut: shortcut, isEnabled: isEnabled, isDestructive: isDestructive))
    }

    static var divider: Self { Self(kind: .divider) }
}

/// A drawing of an open menu: rows of items with optional shortcuts,
/// dividers, and dimmed items.
struct MenusInputMenuDrawing: View {
    var title: String? = nil
    let rows: [MenusInputMenuRow]
    var width: CGFloat = 200

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let title {
                Text(title)
                    .font(.callout.weight(.semibold))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(.fill.tertiary, in: .rect(cornerRadius: 5))
            }
            VStack(alignment: .leading, spacing: 0) {
                ForEach(rows) { row in
                    switch row.kind {
                    case .divider:
                        Divider()
                            .padding(.vertical, 4)
                            .padding(.horizontal, 10)
                    case let .item(title, shortcut, isEnabled, isDestructive):
                        HStack {
                            Text(title)
                                .foregroundStyle(isDestructive ? AnyShapeStyle(.red) : AnyShapeStyle(.primary))
                            Spacer(minLength: 16)
                            if let shortcut {
                                Text(shortcut)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .font(.callout)
                        .opacity(isEnabled ? 1 : 0.4)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 3)
                    }
                }
            }
            .padding(.vertical, 5)
            .frame(width: width, alignment: .leading)
            .background(.background, in: .rect(cornerRadius: 10))
            .overlay {
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(.separator)
            }
            .shadow(color: .black.opacity(0.15), radius: 8, y: 3)
        }
        .accessibilityElement(children: .combine)
    }
}
