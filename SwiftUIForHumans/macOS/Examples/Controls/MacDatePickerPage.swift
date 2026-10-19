import SwiftUI

extension ComponentPage {
    static let datePicker = ComponentPage(
        id: "date-picker",
        title: "DatePicker",
        summary: "A date and time field, or a calendar, for picking a moment in time.",
        category: .controls,
        symbol: "calendar",
        availability: ["macOS 10.15+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/datepicker",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/pickers",
        aliases: ["date", "time", "calendar", "NSDatePicker", "input type=date", "datetime-local", "due date", "deadline", "schedule", "clock"],
        related: ["picker", "stepper", "form", "popover", "labeled-content"],
        notes: [
            "**Without `displayedComponents`, you get both date and time.** Pass `.date` or `.hourAndMinute` to show only what people should edit.",
            "**The order follows the person's region.** The same picker shows day, month, and year in the order their locale expects.",
        ],
        api: [
            APIItem("`DatePicker(_:selection:)`", "A date and time bound to a `Date`."),
            APIItem("`displayedComponents:`", "`.date`, `.hourAndMinute`, or both."),
            APIItem("`in: Date.now...`", "Limits the range people can pick."),
            APIItem("`.datePickerStyle(.field)`", "An editable text field."),
            APIItem("`.datePickerStyle(.stepperField)`", "The field with a stepper beside it."),
            APIItem("`.datePickerStyle(.graphical)`", "A month calendar people browse."),
        ],
        guidelines: [
            Guideline(
                "Choose the style for the job.",
                "A text field fits a tight space and people who know the exact date and time. A calendar suits browsing through days before choosing one."
            ),
            Guideline(
                "Keep the picker next to what it changes.",
                "Show it in place, in the form row or a popover, instead of switching to another view to pick a date."
            ),
        ]
    ) {
        DatePicker("Date", selection: .constant(MacDatePickerSample.date), displayedComponents: .date)
            .datePickerStyle(.graphical)
            .labelsHidden()
            .scaleEffect(0.6)
            .frame(width: 150, height: 120)
    } content: { page in
        MacDatePickerDemo(page: page)
    }
}

/// A fixed date, so previews and screenshots don't change from day to day.
private enum MacDatePickerSample {
    static let date = Calendar.current.date(from: DateComponents(year: 2026, month: 10, day: 23, hour: 9, minute: 30)) ?? .now
}

private struct MacDatePickerConfig {
    var date = MacDatePickerSample.date
    var style: MacDatePickerStyleOption = .automatic
    var components: MacDateComponentsOption = .dateAndTime
    var hidesLabel = false
    var size: MacDatePickerSizeOption = .regular
    var isDisabled = false
}

private struct MacDatePickerDemo: View {
    let page: ComponentPage

    var body: some View {
        DemoPage(
            page: page,
            initial: MacDatePickerConfig(),
            previewHeight: 300,
            usage: """
            @State private var dueDate = Date.now

            DatePicker("Due date", selection: $dueDate, displayedComponents: .date)
            """,
            usageNote: Aside(.note, "The binding is a full `Date`. Showing only `.date` hides the time but doesn't remove it, so compare days with `Calendar` rather than `==`.")
        ) { $config in
            VStack(spacing: 16) {
                DatePicker("Meeting", selection: $config.date, displayedComponents: config.components.components)
                    .styled(config.style)
                    .modifier(MacDatePickerHidesLabel(isHidden: config.hidesLabel))
                    .controlSize(config.size.size)
                    .disabled(config.isDisabled)
                    .fixedSize()
                Text(config.date.formatted(date: .abbreviated, time: .shortened))
                    .font(.footnote.monospacedDigit())
                    .foregroundStyle(.secondary)
            }
        } controls: { $config in
            Section("Content") {
                OptionPicker("Shows", selection: $config.components)
            }
            Section("Appearance") {
                OptionPicker("Style", selection: $config.style)
                OptionPicker("Size", selection: $config.size)
                Toggle("Hide label", isOn: $config.hidesLabel)
                Toggle("Disabled", isOn: $config.isDisabled)
            }
        } code: { config in
            var lines = ["@State private var meeting = Date.now", ""]
            if let components = config.components.code {
                lines.append("DatePicker(\"Meeting\", selection: $meeting, displayedComponents: \(components))")
            } else {
                lines.append("DatePicker(\"Meeting\", selection: $meeting)")
            }
            if config.style != .automatic {
                lines.append("    .datePickerStyle(\(config.style.label))")
            }
            if config.hidesLabel {
                lines.append("    .labelsHidden()")
            }
            if config.size != .regular {
                lines.append("    .controlSize(\(config.size.label))")
            }
            if config.isDisabled {
                lines.append("    .disabled(true)")
            }
            return lines.joined(separator: "\n")
        } examples: {
            MacDatePickerExamples()
        }
    }
}

// MARK: - Examples

private struct MacDatePickerExamples: View {
    @State private var deadline = MacDatePickerSample.date
    @State private var day = MacDatePickerSample.date
    @State private var reminder = MacDatePickerSample.date
    @State private var tripStart = MacDatePickerSample.date
    @State private var tripEnd = MacDatePickerSample.date.addingTimeInterval(4 * 86_400)

    var body: some View {
        ExampleCard(
            title: "Only future dates",
            caption: "Pass a range with `in:` to stop people from picking a date that makes no sense, like a deadline in the past.",
            code: """
            @State private var deadline = Date.now

            DatePicker("Deadline:", selection: $deadline, in: Date.now..., displayedComponents: .date)
            """,
            minHeight: 120
        ) {
            DatePicker("Deadline:", selection: $deadline, in: MacDatePickerSample.date..., displayedComponents: .date)
                .fixedSize()
        }

        ExampleCard(
            title: "A calendar to browse",
            caption: "`.graphical` shows a month at a time. It fits a sidebar, an inspector, or a popover where people look around before choosing.",
            code: """
            @State private var day = Date.now

            DatePicker("Day", selection: $day, displayedComponents: .date)
                .datePickerStyle(.graphical)
                .labelsHidden()
            """,
            minHeight: 240
        ) {
            DatePicker("Day", selection: $day, displayedComponents: .date)
                .datePickerStyle(.graphical)
                .labelsHidden()
                .fixedSize()
        }

        ExampleCard(
            title: "A time with a stepper",
            caption: "`.stepperField` adds arrows beside the field. Click the hour or the minute, and the arrows change that part.",
            code: """
            @State private var reminder = Date.now

            DatePicker("Remind me at:", selection: $reminder, displayedComponents: .hourAndMinute)
                .datePickerStyle(.stepperField)
            """,
            minHeight: 120
        ) {
            DatePicker("Remind me at:", selection: $reminder, displayedComponents: .hourAndMinute)
                .datePickerStyle(.stepperField)
                .fixedSize()
        }

        ExampleCard(
            title: "A start and an end",
            caption: "For a range, use two pickers and limit the second to dates after the first, so the end can never come first.",
            code: """
            @State private var tripStart = Date.now
            @State private var tripEnd = Date.now

            Form {
                DatePicker("Leaving:", selection: $tripStart, displayedComponents: .date)
                DatePicker("Returning:", selection: $tripEnd, in: tripStart..., displayedComponents: .date)
            }
            """,
            minHeight: 140
        ) {
            Form {
                DatePicker("Leaving:", selection: $tripStart, displayedComponents: .date)
                DatePicker("Returning:", selection: $tripEnd, in: tripStart..., displayedComponents: .date)
            }
            .fixedSize()
        }
    }
}

// MARK: - Options

private enum MacDatePickerStyleOption: DemoOption {
    case automatic, field, stepperField, graphical, compact

    var label: String {
        switch self {
        case .automatic: ".automatic"
        case .field: ".field"
        case .stepperField: ".stepperField"
        case .graphical: ".graphical"
        case .compact: ".compact"
        }
    }
}

private enum MacDateComponentsOption: DemoOption {
    case dateAndTime, date, time

    var label: String {
        switch self {
        case .dateAndTime: "Date and time"
        case .date: ".date"
        case .time: ".hourAndMinute"
        }
    }

    var components: DatePickerComponents {
        switch self {
        case .dateAndTime: [.date, .hourAndMinute]
        case .date: .date
        case .time: .hourAndMinute
        }
    }

    var code: String? {
        switch self {
        case .dateAndTime: nil
        case .date: ".date"
        case .time: ".hourAndMinute"
        }
    }
}

private enum MacDatePickerSizeOption: DemoOption {
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

private struct MacDatePickerHidesLabel: ViewModifier {
    let isHidden: Bool

    func body(content: Content) -> some View {
        if isHidden {
            content.labelsHidden()
        } else {
            content
        }
    }
}

private extension View {
    @ViewBuilder
    func styled(_ style: MacDatePickerStyleOption) -> some View {
        switch style {
        case .automatic: datePickerStyle(.automatic)
        case .field: datePickerStyle(.field)
        case .stepperField: datePickerStyle(.stepperField)
        case .graphical: datePickerStyle(.graphical)
        case .compact: datePickerStyle(.compact)
        }
    }
}
