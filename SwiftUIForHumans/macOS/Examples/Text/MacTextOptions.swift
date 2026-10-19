import SwiftUI

// Options shared by the Text group's demos. Names start with `MacText` so
// they don't collide with other groups' types in the same module.

/// `.controlSize(_:)` choices for a demo's controls panel.
enum MacTextControlSize: DemoOption {
    case mini, small, regular, large

    var label: String {
        switch self {
        case .mini: ".mini"
        case .small: ".small"
        case .regular: ".regular"
        case .large: ".large"
        }
    }

    var size: ControlSize {
        switch self {
        case .mini: .mini
        case .small: .small
        case .regular: .regular
        case .large: .large
        }
    }
}

/// `.textFieldStyle(_:)` choices on the Mac.
enum MacTextFieldStyleOption: DemoOption {
    case automatic, roundedBorder, squareBorder, plain

    var label: String {
        switch self {
        case .automatic: ".automatic"
        case .roundedBorder: ".roundedBorder"
        case .squareBorder: ".squareBorder"
        case .plain: ".plain"
        }
    }
}

extension View {
    /// Applies one of the demo's text field styles.
    @ViewBuilder
    func macTextFieldStyle(_ style: MacTextFieldStyleOption) -> some View {
        switch style {
        case .automatic: textFieldStyle(.automatic)
        case .roundedBorder: textFieldStyle(.roundedBorder)
        case .squareBorder: textFieldStyle(.squareBorder)
        case .plain: textFieldStyle(.plain)
        }
    }
}

/// A small monospaced readout under a demo, like `text = "Hello"`.
struct MacTextReadout: View {
    let text: String

    init(_ text: String) {
        self.text = text
    }

    var body: some View {
        Text(text)
            .font(.footnote.monospaced())
            .foregroundStyle(.secondary)
            .lineLimit(1)
            .truncationMode(.middle)
    }
}
