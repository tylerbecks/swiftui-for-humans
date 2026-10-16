import SwiftUI

extension ComponentPage {
    static let stepper = ComponentPage(
        id: "stepper",
        title: "Stepper",
        summary: "A pair of minus and plus buttons that change a number by a fixed amount.",
        category: .controls,
        symbol: "plusminus",
        availability: ["iOS 13.0+", "macOS 10.15+", "visionOS 1.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/stepper",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/steppers",
        aliases: ["counter", "quantity", "increment", "decrement", "plus minus", "input type=number", "number input", "UIStepper", "spinner buttons"],
        related: ["slider", "text-field", "form", "state"],
        notes: [
            "**Always pass a range with `in:`.** The minus or plus button dims at each end, so people can't order zero or a negative amount.",
        ],
        api: [
            APIItem("`Stepper(_:value:in:)`", "Binds to a number and stops at the ends of the range."),
            APIItem("`step:`", "How much each tap changes the value."),
            APIItem("`Stepper(value:in:step:label:)`", "Use any view as the label."),
            APIItem("`onIncrement:` / `onDecrement:`", "Run your own code instead of binding to a number."),
            APIItem("`.labelsHidden()`", "Hides the label but keeps it for VoiceOver."),
        ],
        guidelines: [
            Guideline(
                "Show the value next to the stepper.",
                "The stepper only draws minus and plus. Without the number in view, people can't tell what they're changing.",
                good: "The label shows the current value.",
                bad: "No value, so each tap is a guess."
            ) {
                Stepper("Guests: 4", value: .constant(4), in: 1...10)
                    .frame(width: 220)
            } bad: {
                Stepper("Guests", value: .constant(4), in: 1...10)
                    .frame(width: 220)
            },
            Guideline(
                "Use a stepper for small changes.",
                "A few taps is fine; fifty is not. When values vary widely, pair it with a text field, as in the example above."
            ),
        ]
    ) {
        Stepper("Guests: 4", value: .constant(4), in: 1...10)
            .font(.headline)
            .frame(width: 200)
    } content: { page in
        StepperDemo(page: page)
    }
}

private struct StepperConfig {
    var value = 2
    var step: StepperStepOption = .one
    var range: StepperRangeOption = .oneToTen
    var showsValue = true
    var hidesLabel = false
    var isDisabled = false
}

private struct StepperDemo: View {
    let page: ComponentPage

    var body: some View {
        DemoPage(
            page: page,
            initial: StepperConfig(),
            previewHeight: 200,
            usage: """
            @State private var guests = 2

            Stepper("Guests: \\(guests)", value: $guests, in: 1...10)
            """,
            usageNote: Aside(.important, "The stepper only draws the buttons. Put the value in the label yourself, or people can't see what they're changing.")
        ) { $config in
            VStack(spacing: 16) {
                Group {
                    if let range = config.range.range {
                        Stepper(config.showsValue ? "Guests: \(config.value)" : "Guests", value: $config.value, in: range, step: config.step.rawValue)
                    } else {
                        Stepper(config.showsValue ? "Guests: \(config.value)" : "Guests", value: $config.value, step: config.step.rawValue)
                    }
                }
                .monospacedDigit()
                .modifier(StepperHidesLabel(isHidden: config.hidesLabel))
                .disabled(config.isDisabled)
                .frame(maxWidth: 320)

                Text("value = \(config.value)")
                    .font(.footnote.monospaced())
                    .foregroundStyle(.secondary)
            }
        } controls: { $config in
            Section("Value") {
                OptionPicker("Step", selection: $config.step)
                OptionPicker("Range", selection: Binding(
                    get: { config.range },
                    set: { new in
                        config.range = new
                        if let range = new.range {
                            config.value = min(max(config.value, range.lowerBound), range.upperBound)
                        }
                    }
                ))
            }
            Section("Label") {
                Toggle("Show value in label", isOn: $config.showsValue)
                Toggle("Hide label", isOn: $config.hidesLabel)
                Toggle("Disabled", isOn: $config.isDisabled)
            }
        } code: { config in
            var lines = ["@State private var guests = \(config.value)", ""]
            var args = config.showsValue ? "\"Guests: \\(guests)\"" : "\"Guests\""
            args += ", value: $guests"
            if config.range != .none {
                args += ", in: \(config.range.label)"
            }
            if config.step != .one {
                args += ", step: \(config.step.rawValue)"
            }
            lines.append("Stepper(\(args))")
            if config.hidesLabel {
                lines.append("    .labelsHidden()")
            }
            if config.isDisabled {
                lines.append("    .disabled(true)")
            }
            return lines.joined(separator: "\n")
        } examples: {
            StepperExamples()
        }
    }
}

// MARK: - Examples

private struct StepperExamples: View {
    @State private var quantity = 1
    @State private var hours = 8.0
    @State private var sizeIndex = 2
    @State private var copies = 1
    private let sizes = ["XS", "S", "M", "L", "XL"]

    var body: some View {
        ExampleCard(
            title: "Quantity in a cart",
            caption: "Use `.labelsHidden()` and show the value in your own layout, like a quantity in a cart.",
            code: """
            @State private var quantity = 1

            HStack {
                VStack(alignment: .leading) {
                    Text("Cold Brew").font(.headline)
                    Text("$\\(quantity * 4).00").foregroundStyle(.secondary)
                }
                Spacer()
                Text("\\(quantity)")
                    .monospacedDigit()
                Stepper("Quantity", value: $quantity, in: 1...9)
                    .labelsHidden()
            }
            """,
            aside: Aside(.note, "Keep a real label like “Quantity” even when hidden. VoiceOver reads it so people know what the buttons change.")
        ) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Cold Brew").font(.headline)
                    Text("$\(quantity * 4).00")
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                }
                Spacer()
                Text("\(quantity)")
                    .monospacedDigit()
                Stepper("Quantity", value: $quantity, in: 1...9)
                    .labelsHidden()
            }
            .frame(maxWidth: 360)
        }

        ExampleCard(
            title: "Decimal steps",
            caption: "Bind a `Double` and pass `step: 0.5` to change the value by half an hour per tap.",
            code: """
            @State private var hours = 8.0

            Stepper(value: $hours, in: 4...12, step: 0.5) {
                Text("Sleep goal: \\(hours.formatted()) hours")
            }
            """
        ) {
            Stepper(value: $hours, in: 4...12, step: 0.5) {
                Text("Sleep goal: \(hours.formatted()) hours")
                    .monospacedDigit()
            }
            .frame(maxWidth: 360)
        }

        ExampleCard(
            title: "With a text field",
            caption: "Pair the stepper with a `TextField(value:format:)` so people can type a large number directly.",
            code: """
            @State private var copies = 1

            HStack {
                Text("Copies")
                Spacer()
                TextField("Copies", value: $copies, format: .number)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 64)
                Stepper("Copies", value: $copies, in: 1...999)
                    .labelsHidden()
            }
            """,
            aside: Aside(.important, "The text field ignores the stepper's range. Clamp typed values yourself, for example in `.onChange(of: copies)`.")
        ) {
            HStack {
                Text("Copies")
                Spacer()
                TextField("Copies", value: $copies, format: .number)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 64)
                Stepper("Copies", value: $copies, in: 1...999)
                    .labelsHidden()
            }
            .frame(maxWidth: 360)
        }

        ExampleCard(
            title: "Step through a list",
            caption: "Use `onIncrement:` and `onDecrement:` to step through any list of values, like clothing sizes.",
            code: """
            let sizes = ["XS", "S", "M", "L", "XL"]
            @State private var sizeIndex = 2

            Stepper {
                Text("Size: \\(sizes[sizeIndex])")
            } onIncrement: {
                sizeIndex = min(sizeIndex + 1, sizes.count - 1)
            } onDecrement: {
                sizeIndex = max(sizeIndex - 1, 0)
            }
            """
        ) {
            Stepper {
                Text("Size: \(sizes[sizeIndex])")
            } onIncrement: {
                sizeIndex = min(sizeIndex + 1, sizes.count - 1)
            } onDecrement: {
                sizeIndex = max(sizeIndex - 1, 0)
            }
            .frame(maxWidth: 360)
        }
    }
}

// MARK: - Options

private enum StepperStepOption: Int, DemoOption {
    case one = 1, two = 2, five = 5

    var label: String { "\(rawValue)" }
}

private enum StepperRangeOption: DemoOption {
    case none, oneToTen, zeroToTwenty

    var label: String {
        switch self {
        case .none: "None"
        case .oneToTen: "1...10"
        case .zeroToTwenty: "0...20"
        }
    }

    var range: ClosedRange<Int>? {
        switch self {
        case .none: nil
        case .oneToTen: 1...10
        case .zeroToTwenty: 0...20
        }
    }
}

private struct StepperHidesLabel: ViewModifier {
    let isHidden: Bool

    func body(content: Content) -> some View {
        if isHidden { content.labelsHidden() } else { content }
    }
}
