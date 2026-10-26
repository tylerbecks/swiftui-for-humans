---
id: date-picker
title: DatePicker
platforms: [iOS, iPadOS, macOS]
availability: iOS 13.0+, macOS 10.15+, visionOS 1.0+
docs: https://developer.apple.com/documentation/swiftui/datepicker.md
hig: https://developer.apple.com/design/human-interface-guidelines/pickers.md
---

# DatePicker

A control for choosing a date, a time, or both.

## Contents

- Default code
- Rules
- Pitfalls
- Key APIs
- Variants
- On macOS
- Related

## Default code

```swift
@State private var dueDate = Date.now

DatePicker("Due", selection: $dueDate, displayedComponents: .date)
```

**Note:** The value is always a full `Date`, a moment in time, even when you only show the day. Display it with `.formatted(date:time:)`, passing `.omitted` for the part you hide.

## Rules

- **Show only the parts people need.** A birthday has no time, and an alarm has no date. Extra fields make the picker wider and invite wrong input.
- **Use the compact style in forms.** It takes one row and opens a calendar when tapped. Save `.graphical` for screens where picking a date is the main task.
- **Only allow dates that make sense.** Pass a range with `in:` so people can't pick a check-out before check-in, instead of showing an error after.

## Pitfalls

- **The picker follows the device's language, calendar, and time zone.** Display dates with `.formatted(date:time:)` instead of building strings, and they'll match.

## Key APIs

`DatePicker(_:selection:displayedComponents:)`, `in:`, `.datePickerStyle(_:)`, `.labelsHidden()`, `MultiDatePicker`, `.formatted(date:time:)`

## Variants

### Booking a stay

Pass `in: checkIn...` to the check-out picker so a stay can't end before it begins.

```swift
@State private var checkIn = Date.now
@State private var checkOut = Date.now.addingTimeInterval(3 * 86_400)

Form {
    DatePicker("Check-in", selection: $checkIn, in: Date.now..., displayedComponents: .date)
    DatePicker("Check-out", selection: $checkOut, in: checkIn..., displayedComponents: .date)
    let nights = Calendar.current.dateComponents([.day], from: checkIn, to: checkOut).day ?? 0
    Text("\(nights) nights")
        .foregroundStyle(.secondary)
}
```

**Important:** Don't count on the range to fix a date that's already set. If check-in moves past check-out, update check-out in `.onChange(of: checkIn)`.

### Time only, as a wheel

Use `.hourAndMinute` with the `.wheel` style for a spinning clock, like the one in Alarms.

```swift
@State private var alarm = Date.now

DatePicker("Alarm", selection: $alarm, displayedComponents: .hourAndMinute)
    .datePickerStyle(.wheel)
    .labelsHidden()
```

### Birthday (past dates only)

A one-sided range like `in: ...Date.now` stops the calendar at today.

```swift
@State private var birthday = Date.now

DatePicker("Birthday", selection: $birthday, in: ...Date.now, displayedComponents: .date)
```

### Several days with MultiDatePicker

Use `MultiDatePicker` (iOS 16+) to pick several days, stored as a `Set<DateComponents>`.

```swift
@State private var days: Set<DateComponents> = []

MultiDatePicker("Days off", selection: $days)
Text("\(days.count) days selected")
```

**Note:** Each day is a `DateComponents`, not a `Date`. Convert one with `Calendar.current.date(from:)` when you need it.

## On macOS

A date and time field, or a calendar, for picking a moment in time.

### Default code

```swift
@State private var dueDate = Date.now

DatePicker("Due date", selection: $dueDate, displayedComponents: .date)
```

**Note:** The binding is a full `Date`. Showing only `.date` hides the time but doesn't remove it, so compare days with `Calendar` rather than `==`.

### Rules

- **Choose the style for the job.** A text field fits a tight space and people who know the exact date and time. A calendar suits browsing through days before choosing one.
- **Keep the picker next to what it changes.** Show it in place, in the form row or a popover, instead of switching to another view to pick a date.

### Pitfalls

- **Without `displayedComponents`, you get both date and time.** Pass `.date` or `.hourAndMinute` to show only what people should edit.
- **The order follows the person's region.** The same picker shows day, month, and year in the order their locale expects.
- **The Mac default is a field with arrows.** Click a part, like the month or the minute, then type or click the arrows to change it.

### Key APIs

`DatePicker(_:selection:)`, `displayedComponents:`, `in: Date.now...`, `.datePickerStyle(.stepperField)`, `.datePickerStyle(.field)`, `.datePickerStyle(.graphical)`

### Variants

#### Only future dates

Pass a range with `in:` to stop people from picking a date that makes no sense, like a deadline in the past.

```swift
@State private var deadline = Date.now

DatePicker("Deadline:", selection: $deadline, in: Date.now..., displayedComponents: .date)
```

#### A calendar to browse

`.graphical` shows a month at a time, which suits a sidebar, inspector, or popover where people browse before choosing.

```swift
@State private var day = Date.now

DatePicker("Day", selection: $day, displayedComponents: .date)
    .datePickerStyle(.graphical)
    .labelsHidden()
```

#### Just a time

Pass `.hourAndMinute` to show only a time, for something like a daily reminder where the date doesn't matter.

```swift
@State private var reminder = Date.now

DatePicker("Remind me at:", selection: $reminder, displayedComponents: .hourAndMinute)
```

#### A start and an end

For a range, use two pickers and limit the second to dates after the first, so the end can never come first.

```swift
@State private var tripStart = Date.now
@State private var tripEnd = Date.now

Form {
    DatePicker("Leaving:", selection: $tripStart, displayedComponents: .date)
    DatePicker("Returning:", selection: $tripEnd, in: tripStart..., displayedComponents: .date)
}
```

## Related

[picker](picker.md), [form](form.md), [state](state.md), [stepper](stepper.md), [popover](popover.md), [labeled-content](labeled-content.md)
