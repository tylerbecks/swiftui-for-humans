import SwiftUI

extension ComponentPage {
    static let stepper = ComponentPage(
        id: "stepper",
        title: "Stepper",
        summary: "Up and down arrows that change a number by a fixed amount.",
        category: .controls,
        symbol: "plusminus",
        availability: ["macOS 10.15+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/stepper",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/steppers",
        aliases: ["NSStepper", "increment", "decrement", "plus minus", "counter", "spinner", "input type=number", "number field", "quantity", "copies"],
        related: ["slider", "text-field", "labeled-content", "form", "date-picker"],
        notes: [
            "**On the Mac, a stepper is just two small arrows.** It doesn't show the value, so always put the number next to it: in its label or in a field.",
            "**A range keeps the value in bounds.** With `in: 1...99`, the arrows stop at the ends instead of going past them.",
        ],
        api: [
            APIItem("`Stepper(_:value:in:)`", "Steps a bound number within a range."),
            APIItem("`Stepper(_:value:in:step:)`", "Steps by more than 1."),
            APIItem("`Stepper(_:onIncrement:onDecrement:)`", "Runs your own code for each arrow."),
            APIItem("`TextField(_:value:format:)`", "The field people can type into."),
            APIItem("`.labelsHidden()`", "Hides the label when a field shows the value."),
        ],
        guidelines: [
            Guideline(
                "Make the value it changes obvious.",
                "A stepper doesn't show a number of its own. Keep the value right beside it so people see what each click does.",
                good: "The field shows the number the arrows change.",
                bad: "The arrows alone don't say what changes."
            ) {
                LabeledContent("Copies:") {
                    HStack(spacing: 4) {
                        TextField("Copies", value: .constant(2), format: .number)
                            .frame(width: 44)
                        Stepper("Copies", value: .constant(2), in: 1...99)
                    }
                    .labelsHidden()
                }
                .fixedSize()
            } bad: {
                LabeledContent("Copies:") {
                    Stepper("Copies", value: .constant(2), in: 1...99)
                        .labelsHidden()
                }
                .fixedSize()
            },
            Guideline(
                "Pair it with a field when big changes are likely.",
                "A few clicks are fine for small changes. When values vary a lot, like the number of copies to print, let people type the number too."
            ),
            Guideline(
                "Consider Shift-click for large ranges.",
                "On the Mac, a Shift-click that moves by a bigger amount, like ten steps, saves people a lot of clicking."
            ),
        ]
    ) {
        HStack(spacing: 4) {
            TextField("Copies", value: .constant(2), format: .number)
                .frame(width: 44)
            Stepper("Copies", value: .constant(2), in: 1...99)
        }
        .labelsHidden()
    } content: { page in
        MacStepperDemo(page: page)
    }
}

private struct MacStepperConfig {
    var copies = 1
    var step: MacStepperStepOption = .one
    var showsField = true
    var size: MacStepperSizeOption = .regular
    var isDisabled = false
}

private struct MacStepperDemo: View {
    let page: ComponentPage

    var body: some View {
        DemoPage(
            page: page,
            initial: MacStepperConfig(),
            usage: """
            @State private var copies = 1

            LabeledContent("Copies:") {
                HStack(spacing: 4) {
                    TextField("Copies", value: $copies, format: .number)
                        .frame(width: 44)
                    Stepper("Copies", value: $copies, in: 1...99)
                }
                .labelsHidden()
            }
            """,
            usageNote: Aside(.note, "The field and the stepper share one binding, so typing a number and clicking the arrows stay in sync, like an `<input type=number>`.")
        ) { $config in
            VStack(spacing: 16) {
                Group {
                    if config.showsField {
                        LabeledContent("Copies:") {
                            HStack(spacing: 4) {
                                TextField("Copies", value: $config.copies, format: .number)
                                    .frame(width: 44)
                                Stepper("Copies", value: $config.copies, in: 1...99, step: config.step.value)
                            }
                            .labelsHidden()
                        }
                    } else {
                        Stepper("Copies: \(config.copies)", value: $config.copies, in: 1...99, step: config.step.value)
                    }
                }
                .controlSize(config.size.size)
                .disabled(config.isDisabled)
                .fixedSize()

                Text("copies = \(config.copies)")
                    .font(.footnote.monospaced())
                    .foregroundStyle(.secondary)
            }
        } controls: { $config in
            Section("Content") {
                OptionPicker("Step", selection: $config.step)
                Toggle("Text field", isOn: $config.showsField)
            }
            Section("Appearance") {
                OptionPicker("Size", selection: $config.size)
                Toggle("Disabled", isOn: $config.isDisabled)
            }
        } code: { config in
            let step = config.step == .one ? "" : ", step: \(config.step.value)"
            var lines = ["@State private var copies = \(config.copies)", ""]
            if config.showsField {
                lines += [
                    "LabeledContent(\"Copies:\") {",
                    "    HStack(spacing: 4) {",
                    "        TextField(\"Copies\", value: $copies, format: .number)",
                    "            .frame(width: 44)",
                    "        Stepper(\"Copies\", value: $copies, in: 1...99\(step))",
                    "    }",
                    "    .labelsHidden()",
                    "}",
                ]
            } else {
                lines.append("Stepper(\"Copies: \\(copies)\", value: $copies, in: 1...99\(step))")
            }
            if config.size != .regular {
                lines.append(".controlSize(\(config.size.label))")
            }
            if config.isDisabled {
                lines.append(".disabled(true)")
            }
            return lines.joined(separator: "\n")
        } examples: {
            MacStepperExamples()
        }
    }
}

// MARK: - Examples

private struct MacStepperExamples: View {
    @State private var fontSize = 13
    @State private var margin = 1.0
    @State private var weekday = 0
    @State private var width = 800
    @State private var height = 600

    private let weekdays = Calendar.current.weekdaySymbols

    var body: some View {
        ExampleCard(
            title: "The value in the label",
            caption: "When there's no room for a field, put the current value in the stepper's own label.",
            code: """
            @State private var margin = 1.0

            Stepper(value: $margin, in: 0...3, step: 0.25) {
                Text("Margin: \\(margin, format: .number.precision(.fractionLength(2))) in")
            }
            """,
            minHeight: 120
        ) {
            Stepper(value: $margin, in: 0...3, step: 0.25) {
                Text("Margin: \(margin, format: .number.precision(.fractionLength(2))) in")
            }
            .fixedSize()
        }

        ExampleCard(
            title: "Two values side by side",
            caption: "Give each field its own stepper, and wrap each pair in `LabeledContent` so the rows line up with other form controls.",
            code: """
            @State private var width = 800
            @State private var height = 600

            Form {
                LabeledContent("Width:") {
                    HStack(spacing: 4) {
                        TextField("Width", value: $width, format: .number)
                            .frame(width: 60)
                        Stepper("Width", value: $width, in: 100...4000, step: 10)
                    }
                    .labelsHidden()
                }
                LabeledContent("Height:") {
                    HStack(spacing: 4) {
                        TextField("Height", value: $height, format: .number)
                            .frame(width: 60)
                        Stepper("Height", value: $height, in: 100...4000, step: 10)
                    }
                    .labelsHidden()
                }
            }
            """,
            minHeight: 140
        ) {
            Form {
                LabeledContent("Width:") {
                    HStack(spacing: 4) {
                        TextField("Width", value: $width, format: .number)
                            .frame(width: 60)
                        Stepper("Width", value: $width, in: 100...4000, step: 10)
                    }
                    .labelsHidden()
                }
                LabeledContent("Height:") {
                    HStack(spacing: 4) {
                        TextField("Height", value: $height, format: .number)
                            .frame(width: 60)
                        Stepper("Height", value: $height, in: 100...4000, step: 10)
                    }
                    .labelsHidden()
                }
            }
            .fixedSize()
        }

        ExampleCard(
            title: "Your own steps",
            caption: "`onIncrement` and `onDecrement` run your code instead of adding a number, like cycling through the days of the week.",
            code: """
            @State private var weekday = 0
            let weekdays = Calendar.current.weekdaySymbols

            Stepper {
                Text("Starts on \\(weekdays[weekday])")
            } onIncrement: {
                weekday = (weekday + 1) % weekdays.count
            } onDecrement: {
                weekday = (weekday + weekdays.count - 1) % weekdays.count
            }
            """,
            minHeight: 120
        ) {
            Stepper {
                Text("Starts on \(weekdays[weekday])")
            } onIncrement: {
                weekday = (weekday + 1) % weekdays.count
            } onDecrement: {
                weekday = (weekday + weekdays.count - 1) % weekdays.count
            }
            .fixedSize()
        }
    }
}

// MARK: - Options

private enum MacStepperStepOption: DemoOption {
    case one, five, ten

    var label: String {
        switch self {
        case .one: "1"
        case .five: "5"
        case .ten: "10"
        }
    }

    var value: Int {
        switch self {
        case .one: 1
        case .five: 5
        case .ten: 10
        }
    }
}

private enum MacStepperSizeOption: DemoOption {
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
