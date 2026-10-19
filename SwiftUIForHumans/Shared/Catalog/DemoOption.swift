import SwiftUI

/// An enum of choices for a control in the inspector, e.g. button styles.
/// `code` is the Swift spelling used in generated snippets (e.g. ".bordered").
protocol DemoOption: CaseIterable, Hashable, Identifiable where AllCases: RandomAccessCollection {
    var label: String { get }
}

extension DemoOption {
    var id: Self { self }
}

/// A picker row for any `DemoOption`.
struct OptionPicker<Option: DemoOption>: View {
    let title: String
    @Binding var selection: Option

    init(_ title: String, selection: Binding<Option>) {
        self.title = title
        _selection = selection
    }

    var body: some View {
        Picker(title, selection: $selection) {
            ForEach(Option.allCases) { option in
                Text(option.label).tag(option)
            }
        }
    }
}

/// A labeled slider row that shows its current value.
struct ValueSlider: View {
    let title: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    var step: Double = 0.05

    init(_ title: String, value: Binding<Double>, in range: ClosedRange<Double>, step: Double = 0.05) {
        self.title = title
        _value = value
        self.range = range
        self.step = step
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(title)
                Spacer()
                Text(swiftNumber(value))
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
            }
            Slider(value: $value, in: range, step: step)
                .accessibilityLabel(title)
                .accessibilityValue(swiftNumber(value))
        }
    }
}

/// Formats a number the way you'd write it in Swift source: "0.5", "1", "-0.25".
func swiftNumber(_ value: Double) -> String {
    let rounded = (value * 100).rounded() / 100
    return rounded.formatted(
        .number
            .precision(.fractionLength(0...2))
            .grouping(.never)
            .locale(Locale(identifier: "en_US_POSIX"))
    )
}

/// Escapes a user-entered label so generated code stays valid Swift.
func swiftString(_ text: String) -> String {
    let escaped = text
        .replacingOccurrences(of: "\\", with: "\\\\")
        .replacingOccurrences(of: "\"", with: "\\\"")
    return "\"\(escaped)\""
}
