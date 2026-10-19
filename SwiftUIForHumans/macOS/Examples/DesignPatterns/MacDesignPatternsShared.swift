import SwiftUI

// Small drawings shared by the Design Patterns pages: menus, a menu bar,
// key caps, and a readout of this Mac's own accessibility settings. The
// `DP` prefix keeps the names apart from other groups' helpers.

/// One row of a drawn menu.
struct DPMenuItem: Identifiable {
    enum Kind {
        case item(title: String, shortcut: String?, isEnabled: Bool, isHighlighted: Bool)
        case divider
    }

    let id = UUID()
    let kind: Kind

    static func item(_ title: String, _ shortcut: String? = nil, enabled: Bool = true, highlighted: Bool = false) -> DPMenuItem {
        DPMenuItem(kind: .item(title: title, shortcut: shortcut, isEnabled: enabled, isHighlighted: highlighted))
    }

    static var divider: DPMenuItem { DPMenuItem(kind: .divider) }
}

/// A drawing of an open menu bar menu: its title in the bar, and the menu
/// below it. Used where a real menu would land in this app's own menu bar.
struct DPMenuDrawing: View {
    let title: String
    let items: [DPMenuItem]
    var width: CGFloat = 220

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.callout.weight(.medium))
                .padding(.horizontal, 10)
                .padding(.vertical, 3)
                .background(.fill.secondary, in: .rect(cornerRadius: 5))
                .padding(.bottom, 4)
            VStack(alignment: .leading, spacing: 0) {
                ForEach(items) { item in
                    switch item.kind {
                    case .divider:
                        Divider()
                            .padding(.vertical, 4)
                            .padding(.horizontal, 10)
                    case let .item(title, shortcut, isEnabled, isHighlighted):
                        HStack {
                            Text(title)
                            Spacer(minLength: 16)
                            if let shortcut {
                                Text(shortcut)
                                    .foregroundStyle(isHighlighted ? AnyShapeStyle(.white.opacity(0.85)) : AnyShapeStyle(.secondary))
                            }
                        }
                        .font(.callout)
                        .foregroundStyle(isHighlighted ? AnyShapeStyle(.white) : isEnabled ? AnyShapeStyle(.primary) : AnyShapeStyle(.tertiary))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 3)
                        .background(isHighlighted ? AnyShapeStyle(Color.accentColor) : AnyShapeStyle(.clear), in: .rect(cornerRadius: 5))
                        .padding(.horizontal, 5)
                    }
                }
            }
            .padding(.vertical, 5)
            .frame(width: width)
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

/// Keys drawn as small caps, like "⌘" "Z".
struct DPKeys: View {
    let keys: [String]

    init(_ keys: String...) {
        self.keys = keys
    }

    var body: some View {
        HStack(spacing: 3) {
            ForEach(Array(keys.enumerated()), id: \.offset) { _, key in
                Text(key)
                    .font(.callout.weight(.medium).monospaced())
                    .frame(minWidth: 22, minHeight: 22)
                    .padding(.horizontal, 4)
                    .background(.fill.tertiary, in: .rect(cornerRadius: 5))
                    .overlay {
                        RoundedRectangle(cornerRadius: 5)
                            .strokeBorder(.separator)
                    }
            }
        }
        .accessibilityElement(children: .combine)
    }
}

/// A one-line readout of one of this Mac's accessibility settings, so a
/// page can say what the system is set to right now.
struct DPSystemSetting: View {
    let name: String
    let isOn: Bool

    var body: some View {
        Label {
            Text("On this Mac, **\(name)** is \(isOn ? "on" : "off").")
        } icon: {
            Image(systemName: isOn ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(isOn ? AnyShapeStyle(.green) : AnyShapeStyle(.secondary))
        }
        .font(.callout)
        .foregroundStyle(.secondary)
    }
}

/// A rounded panel for a page's interactive diagram.
struct DPPanel<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        content
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Surface.preview)
            .cardStyle()
    }
}
