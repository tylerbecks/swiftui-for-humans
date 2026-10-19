import SwiftUI

// Preview helpers shared by the Design pages. The `MacDesign` prefix keeps
// the names clear of other groups' helpers.

/// The same content twice, forced to light and to dark, each on the real
/// window background.
struct MacDesignAppearancePair<Content: View>: View {
    var minHeight: CGFloat = 80
    @ViewBuilder let content: Content

    var body: some View {
        HStack(spacing: 10) {
            pane(.light)
            pane(.dark)
        }
    }

    private func pane(_ scheme: ColorScheme) -> some View {
        VStack(spacing: 6) {
            content
                .padding(12)
                .frame(maxWidth: .infinity, minHeight: minHeight)
                .background(.windowBackground)
                .clipShape(.rect(cornerRadius: 10))
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(.separator)
                }
                .environment(\.colorScheme, scheme)
            Text(scheme == .dark ? "Dark" : "Light")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

/// One row of a drawn menu.
struct MacDesignMenuItem: Identifiable {
    let id = UUID()
    var title: String
    var symbol: String? = nil
    var shortcut: String? = nil
    var isChecked = false
    var isDisabled = false
    var isSeparator = false

    static var separator: MacDesignMenuItem {
        MacDesignMenuItem(title: "", isSeparator: true)
    }
}

/// A drawing of an open menu, for previews about menu item names and
/// icons. A real `Menu` only opens when clicked, so the page draws one.
struct MacDesignMenuSample: View {
    let items: [MacDesignMenuItem]
    var width: CGFloat = 220

    var body: some View {
        let showsChecks = items.contains(where: \.isChecked)
        VStack(alignment: .leading, spacing: 0) {
            ForEach(items) { item in
                if item.isSeparator {
                    Divider()
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                } else {
                    HStack(spacing: 6) {
                        if showsChecks {
                            Image(systemName: "checkmark")
                                .font(.caption.weight(.semibold))
                                .frame(width: 12)
                                .opacity(item.isChecked ? 1 : 0)
                        }
                        if let symbol = item.symbol {
                            Image(systemName: symbol)
                                .frame(width: 18)
                        }
                        Text(item.title)
                            .lineLimit(1)
                        Spacer(minLength: 12)
                        if let shortcut = item.shortcut {
                            Text(shortcut)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .foregroundStyle(item.isDisabled ? .tertiary : .primary)
                    .padding(.horizontal, 10)
                    .frame(height: 24)
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
        .accessibilityElement(children: .combine)
    }
}

/// An icon and a line of text, for short lists of steps or tips.
struct MacDesignTip: View {
    let symbol: String
    let text: String

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            Image(systemName: symbol)
                .foregroundStyle(.tint)
                .frame(width: 22)
            RichText(text)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
