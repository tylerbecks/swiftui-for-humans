import SwiftUI

/// Shows what VoiceOver would say for a view, styled like the caption panel
/// VoiceOver can show at the bottom of the screen. Used in demos and in
/// Do / Don't pairs where the difference is heard, not seen.
struct A11ySpeech: View {
    let text: String
    var isProblem = false

    init(_ text: String, isProblem: Bool = false) {
        self.text = text
        self.isProblem = isProblem
    }

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Image(systemName: "speaker.wave.2.fill")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.7))
            Text(text)
                .font(.callout.weight(.medium))
                .foregroundStyle(isProblem ? Color(red: 1, green: 0.62, blue: 0.55) : .white)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.black.opacity(0.85), in: .rect(cornerRadius: 10))
        .overlay {
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(.white.opacity(0.2), lineWidth: 0.5)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("VoiceOver says: \(text)")
    }
}

/// A labeled row of switches above a live preview, for settings people can
/// simulate on the page (Reduce Motion, larger text, and so on).
struct A11ySimToggle: View {
    let title: String
    let symbol: String
    @Binding var isOn: Bool

    var body: some View {
        Toggle(isOn: $isOn) {
            Label(title, systemImage: symbol)
        }
        .toggleStyle(.button)
        .buttonStyle(.bordered)
        .tint(isOn ? .accentColor : .secondary)
        .controlSize(.small)
    }
}
