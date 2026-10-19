import SwiftUI

// Small drawings and sample data shared by this group's pages. Names start
// with `WindowsNav` so they don't collide with other groups.

// MARK: - Notes sample

/// Three notes that the WindowGroup and Opening Windows pages open in real
/// windows, one window per note.
enum WindowsNavNote: String, CaseIterable, Identifiable {
    case groceries, trip, ideas

    var id: String { rawValue }

    /// The demo window that shows this note.
    var windowID: String { "note-\(rawValue)" }

    var title: String {
        switch self {
        case .groceries: "Groceries"
        case .trip: "Trip to Lisbon"
        case .ideas: "App Ideas"
        }
    }

    var body: String {
        switch self {
        case .groceries: "Oranges, coffee beans, oat milk, basil."
        case .trip: "Book the tram tour. Try the custard tarts in Belém."
        case .ideas: "A habit tracker that lives in the menu bar."
        }
    }

    var symbol: String {
        switch self {
        case .groceries: "cart"
        case .trip: "airplane"
        case .ideas: "lightbulb"
        }
    }

    static var demoWindows: [DemoWindow] {
        allCases.map { note in
            DemoWindow(id: note.windowID, title: note.title, size: CGSize(width: 380, height: 240)) {
                WindowsNavNoteWindow(note: note)
            }
        }
    }
}

/// The content of a note's window. Its Close button uses `dismiss`, which
/// closes the window it's in.
struct WindowsNavNoteWindow: View {
    let note: WindowsNavNote
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(note.title, systemImage: note.symbol)
                .font(.title2.bold())
            Text(note.body)
                .foregroundStyle(.secondary)
            Spacer()
            HStack {
                Text("Open it again from the page: this window comes to the front.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                Spacer()
                Button("Close") { dismiss() }
                    .keyboardShortcut(.cancelAction)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

// MARK: - Window drawings

/// Close, minimize, and zoom, for drawings that don't use `MacWindowFrame`
/// (a hidden title bar, other toolbar styles).
struct WindowsNavWindowButtons: View {
    var body: some View {
        HStack(spacing: 8) {
            ForEach([Color.red, .yellow, .green], id: \.self) { color in
                Circle()
                    .fill(color.gradient)
                    .frame(width: 12, height: 12)
                    .overlay(Circle().strokeBorder(.black.opacity(0.12)))
            }
        }
        .accessibilityHidden(true)
    }
}

/// The rounded border and shadow `MacWindowFrame` uses, for custom window
/// drawings.
struct WindowsNavWindowChrome: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(.background)
            .clipShape(.rect(cornerRadius: 14))
            .overlay {
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(.separator)
            }
            .shadow(color: .black.opacity(0.18), radius: 10, y: 4)
    }
}

extension View {
    func windowsNavChrome() -> some View {
        modifier(WindowsNavWindowChrome())
    }
}

// MARK: - Menu drawings

/// A drawing of the right end of the menu bar, with menu bar extras and
/// the clock. Pass the extras' symbols, leftmost first.
struct WindowsNavMenuBar<Extra: View>: View {
    var width: CGFloat = 320
    @ViewBuilder let extra: Extra

    var body: some View {
        HStack(spacing: 14) {
            Spacer(minLength: 0)
            extra
            Image(systemName: "wifi")
            Image(systemName: "battery.75percent")
            Text("Mon 9:41")
                .font(.callout)
        }
        .imageScale(.medium)
        .padding(.horizontal, 12)
        .frame(width: width, height: 24)
        .background(.fill.tertiary)
        .overlay(alignment: .bottom) {
            Divider()
        }
        .accessibilityElement(children: .contain)
    }
}

/// A drawing of an open menu: rows of items, with `nil` for a separator.
struct WindowsNavMenuDrawing: View {
    let items: [String?]
    var width: CGFloat = 190
    /// The item drawn as highlighted, as if the pointer is over it.
    var highlighted: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                if let item {
                    Text(item)
                        .font(.callout)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 3)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundStyle(item == highlighted ? Color.white : Color.primary)
                        .background(item == highlighted ? Color.accentColor : Color.clear, in: .rect(cornerRadius: 5))
                } else {
                    Divider()
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                }
            }
        }
        .padding(5)
        .frame(width: width)
        .background(.background, in: .rect(cornerRadius: 9))
        .overlay {
            RoundedRectangle(cornerRadius: 9)
                .strokeBorder(.separator)
        }
        .shadow(color: .black.opacity(0.15), radius: 8, y: 3)
    }
}
