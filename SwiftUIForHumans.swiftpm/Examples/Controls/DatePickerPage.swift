import SwiftUI

extension ComponentPage {
    static let datePicker = ComponentPage(
        id: "date-picker",
        title: "DatePicker",
        summary: "A control for choosing a date, a time, or both.",
        category: .controls,
        symbol: "calendar",
        availability: ["iOS 13.0+", "macOS 10.15+", "visionOS 1.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/datepicker",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/pickers",
        aliases: ["calendar", "date input", "input type=date", "time picker", "datetime", "UIDatePicker", "date range", "birthday", "schedule"],
        related: ["picker", "form", "state"],
        notes: [
            "**The picker follows the device's language, calendar, and time zone.** Display dates with `.formatted(date:time:)` instead of building strings, and they'll match.",
        ],
        api: [
            APIItem("`DatePicker(_:selection:displayedComponents:)`", "Binds to a `Date`; shows the date, the time, or both."),
            APIItem("`in:`", "Limits the range, like `Date.now...` or `...Date.now`."),
            APIItem("`.datePickerStyle(_:)`", "`.compact`, `.graphical`, or `.wheel`."),
            APIItem("`.labelsHidden()`", "Hides the label but keeps it for VoiceOver."),
            APIItem("`MultiDatePicker`", "Picks a set of days."),
            APIItem("`.formatted(date:time:)`", "Turns a `Date` into text for display."),
        ],
        guidelines: [
            Guideline(
                "Show only the parts people need.",
                "A birthday has no time, and an alarm has no date. Extra fields make the picker wider and invite wrong input.",
                good: "Just the date for a birthday.",
                bad: "A time nobody needs."
            ) {
                DatePicker("Birthday", selection: .constant(DatePickerSample.date), displayedComponents: .date)
                    .labelsHidden()
            } bad: {
                DatePicker("Birthday", selection: .constant(DatePickerSample.date))
                    .labelsHidden()
            },
            Guideline(
                "Use the compact style in forms.",
                "It takes one row and opens a calendar when tapped. Save `.graphical` for screens where picking a date is the main task."
            ),
            Guideline(
                "Only allow dates that make sense.",
                "Pass a range with `in:` so people can't pick a check-out before check-in, instead of showing an error after."
            ),
        ]
    ) {
        VStack(spacing: 12) {
            DatePicker("Date", selection: .constant(DatePickerSample.date), displayedComponents: .date)
            DatePicker("Time", selection: .constant(DatePickerSample.date), displayedComponents: .hourAndMinute)
        }
        .labelsHidden()
    } content: { page in
        DatePickerDemo(page: page)
    }
}

private enum DatePickerSample {
    /// A fixed date so the thumbnail looks the same every day.
    static let date: Date = {
        var components = DateComponents()
        components.year = 2026
        components.month = 6
        components.day = 9
        components.hour = 9
        components.minute = 41
        return Calendar.current.date(from: components) ?? .now
    }()
}

private struct DatePickerConfig {
    var date = Date.now
    var style: DatePickerStyleOption = .automatic
    var components: DatePickerComponentsOption = .date
    var range: DatePickerRangeOption = .any
    var hidesLabel = false
    var isDisabled = false
}

private struct DatePickerDemo: View {
    let page: ComponentPage

    var body: some View {
        DemoPage(
            page: page,
            initial: DatePickerConfig(),
            previewHeight: 220,
            usage: """
            @State private var dueDate = Date.now

            DatePicker("Due", selection: $dueDate, displayedComponents: .date)
            """,
            usageNote: Aside(.note, "The value is always a full `Date`, a moment in time, even when you only show the day. Display it with `.formatted(date:time:)`, passing `.omitted` for the part you hide.")
        ) { $config in
            VStack(spacing: 16) {
                Group {
                    switch config.range {
                    case .any:
                        DatePicker("Start", selection: $config.date, displayedComponents: config.components.value)
                    case .future:
                        DatePicker("Start", selection: $config.date, in: Date.now..., displayedComponents: config.components.value)
                    case .past:
                        DatePicker("Start", selection: $config.date, in: ...Date.now, displayedComponents: config.components.value)
                    }
                }
                .styled(config.style)
                .modifier(DatePickerHidesLabel(isHidden: config.hidesLabel))
                .disabled(config.isDisabled)
                .frame(maxWidth: 360)
                // The calendar needs 320pt; borrow a little of the card's
                // padding so it fits on the narrowest iPhones.
                .padding(.horizontal, config.style == .graphical || config.style == .wheel ? -8 : 0)

                Text(config.date.formatted(
                    date: config.components == .time ? .omitted : .abbreviated,
                    time: config.components == .date ? .omitted : .shortened
                ))
                .font(.footnote.monospaced())
                .foregroundStyle(.secondary)
            }
        } controls: { $config in
            Section("Picker") {
                OptionPicker("Style", selection: $config.style)
                OptionPicker("Components", selection: $config.components)
                OptionPicker("Range", selection: Binding(
                    get: { config.range },
                    set: { new in
                        config.range = new
                        config.date = .now
                    }
                ))
            }
            Section("Label") {
                Toggle("Hide label", isOn: $config.hidesLabel)
                Toggle("Disabled", isOn: $config.isDisabled)
            }
        } code: { config in
            var lines = ["@State private var date = Date.now", ""]
            var args = "\"Start\", selection: $date"
            switch config.range {
            case .any: break
            case .future: args += ", in: Date.now..."
            case .past: args += ", in: ...Date.now"
            }
            if config.components != .both {
                args += ", displayedComponents: \(config.components.label)"
            }
            lines.append("DatePicker(\(args))")
            if config.style != .automatic {
                lines.append("    .datePickerStyle(\(config.style.label))")
            }
            if config.hidesLabel {
                lines.append("    .labelsHidden()")
            }
            if config.isDisabled {
                lines.append("    .disabled(true)")
            }
            return lines.joined(separator: "\n")
        } examples: {
            DatePickerExamples()
        }
    }
}

// MARK: - Examples

private struct DatePickerExamples: View {
    @State private var checkIn = Date.now
    @State private var checkOut = Date.now.addingTimeInterval(3 * 86_400)
    @State private var birthday = Calendar.current.date(byAdding: .year, value: -30, to: .now) ?? .now
    @State private var alarm = DatePickerSample.date
    @State private var days: Set<DateComponents> = []

    private var nights: Int {
        max(Calendar.current.dateComponents([.day], from: checkIn, to: checkOut).day ?? 0, 0)
    }

    var body: some View {
        ExampleCard(
            title: "Booking a stay",
            caption: "Pass `in: checkIn...` to the check-out picker so a stay can't end before it begins.",
            code: """
            @State private var checkIn = Date.now
            @State private var checkOut = Date.now.addingTimeInterval(3 * 86_400)

            Form {
                DatePicker("Check-in", selection: $checkIn, in: Date.now..., displayedComponents: .date)
                DatePicker("Check-out", selection: $checkOut, in: checkIn..., displayedComponents: .date)
                let nights = Calendar.current.dateComponents([.day], from: checkIn, to: checkOut).day ?? 0
                Text("\\(nights) nights")
                    .foregroundStyle(.secondary)
            }
            """,
            minHeight: 240,
            aside: Aside(.important, "Don't count on the range to fix a date that's already set. If check-in moves past check-out, update check-out in `.onChange(of: checkIn)`.")
        ) {
            Form {
                DatePicker("Check-in", selection: $checkIn, in: Date.now..., displayedComponents: .date)
                DatePicker("Check-out", selection: $checkOut, in: checkIn..., displayedComponents: .date)
                Text("\(nights) nights")
                    .foregroundStyle(.secondary)
            }
            .frame(height: 240)
            .frame(maxWidth: 420)
            .scrollContentBackground(.hidden)
        }

        ExampleCard(
            title: "Time only, as a wheel",
            caption: "Use `.hourAndMinute` with the `.wheel` style for a spinning clock, like the one in Alarms.",
            code: """
            @State private var alarm = Date.now

            DatePicker("Alarm", selection: $alarm, displayedComponents: .hourAndMinute)
                .datePickerStyle(.wheel)
                .labelsHidden()
            """,
            minHeight: 220
        ) {
            DatePicker("Alarm", selection: $alarm, displayedComponents: .hourAndMinute)
                .datePickerStyle(.wheel)
                .labelsHidden()
                .padding(.horizontal, -8)
        }

        ExampleCard(
            title: "Birthday (past dates only)",
            caption: "A one-sided range like `in: ...Date.now` stops the calendar at today.",
            code: """
            @State private var birthday = Date.now

            DatePicker("Birthday", selection: $birthday, in: ...Date.now, displayedComponents: .date)
            """
        ) {
            DatePicker("Birthday", selection: $birthday, in: ...Date.now, displayedComponents: .date)
                .frame(maxWidth: 360)
        }

        ExampleCard(
            title: "Several days with MultiDatePicker",
            caption: "Use `MultiDatePicker` (iOS 16+) to pick several days, stored as a `Set<DateComponents>`.",
            code: """
            @State private var days: Set<DateComponents> = []

            MultiDatePicker("Days off", selection: $days)
            Text("\\(days.count) days selected")
            """,
            minHeight: 420,
            aside: Aside(.note, "Each day is a `DateComponents`, not a `Date`. Convert one with `Calendar.current.date(from:)` when you need it.")
        ) {
            VStack {
                MultiDatePicker("Days off", selection: $days)
                    .frame(maxWidth: 360)
                    .padding(.horizontal, -8)
                Text("\(days.count) days selected")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - Options

private enum DatePickerStyleOption: DemoOption {
    case automatic, compact, graphical, wheel

    var label: String {
        switch self {
        case .automatic: ".automatic"
        case .compact: ".compact"
        case .graphical: ".graphical"
        case .wheel: ".wheel"
        }
    }
}

private enum DatePickerComponentsOption: DemoOption {
    case date, time, both

    var label: String {
        switch self {
        case .date: ".date"
        case .time: ".hourAndMinute"
        case .both: "Date and time"
        }
    }

    var value: DatePickerComponents {
        switch self {
        case .date: .date
        case .time: .hourAndMinute
        case .both: [.date, .hourAndMinute]
        }
    }
}

private enum DatePickerRangeOption: DemoOption {
    case any, future, past

    var label: String {
        switch self {
        case .any: "Any date"
        case .future: "Future only"
        case .past: "Past only"
        }
    }
}

private struct DatePickerHidesLabel: ViewModifier {
    let isHidden: Bool

    func body(content: Content) -> some View {
        if isHidden { content.labelsHidden() } else { content }
    }
}

private extension View {
    @ViewBuilder
    func styled(_ style: DatePickerStyleOption) -> some View {
        switch style {
        case .automatic: datePickerStyle(.automatic)
        case .compact: datePickerStyle(.compact)
        case .graphical: datePickerStyle(.graphical)
        case .wheel: datePickerStyle(.wheel)
        }
    }
}
