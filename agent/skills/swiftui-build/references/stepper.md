---
id: stepper
title: Stepper
platforms: [iOS, iPadOS, macOS]
availability: iOS 13.0+, macOS 10.15+, visionOS 1.0+
docs: https://developer.apple.com/documentation/swiftui/stepper.md
hig: https://developer.apple.com/design/human-interface-guidelines/steppers.md
---

# Stepper

A pair of minus and plus buttons that change a number by a fixed amount.

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
@State private var guests = 2

Stepper("Guests: \(guests)", value: $guests, in: 1...10)
```

**Important:** The stepper only draws the buttons. Put the value in the label yourself, or people can't see what they're changing.

## Rules

- **Show the value next to the stepper.** The stepper only draws minus and plus. Without the number in view, people can't tell what they're changing.
- **Use a stepper for small changes.** A few taps is fine; fifty is not. When values vary widely, pair it with a text field, as in the example above.

## Pitfalls

- **Always pass a range with `in:`.** The minus or plus button dims at each end, so people can't order zero or a negative amount.

## Key APIs

`Stepper(_:value:in:)`, `step:`, `Stepper(value:in:step:label:)`, `onIncrement:` / `onDecrement:`, `.labelsHidden()`

## Variants

### Quantity in a cart

Use `.labelsHidden()` and show the value in your own layout, like a quantity in a cart.

```swift
@State private var quantity = 1

HStack {
    VStack(alignment: .leading) {
        Text("Cold Brew").font(.headline)
        Text("$\(quantity * 4).00").foregroundStyle(.secondary)
    }
    Spacer()
    Text("\(quantity)")
        .monospacedDigit()
    Stepper("Quantity", value: $quantity, in: 1...9)
        .labelsHidden()
}
```

**Note:** Keep a real label like “Quantity” even when hidden. VoiceOver reads it so people know what the buttons change.

### Decimal steps

Bind a `Double` and pass `step: 0.5` to change the value by half an hour per tap.

```swift
@State private var hours = 8.0

Stepper(value: $hours, in: 4...12, step: 0.5) {
    Text("Sleep goal: \(hours.formatted()) hours")
}
```

## On macOS

Up and down arrows that change a number by a fixed amount.

### Default code

```swift
@State private var copies = 1

LabeledContent("Copies:") {
    HStack(spacing: 4) {
        TextField("Copies", value: $copies, format: .number)
            .frame(width: 44)
        Stepper("Copies", value: $copies, in: 1...99)
    }
    .labelsHidden()
}
```

**Note:** The field and the stepper share one binding, so typing a number and clicking the arrows stay in sync, like an `<input type=number>`.

### Rules

- **Make the value it changes obvious.** A stepper doesn't show a number of its own. Keep the value right beside it so people see what each click does.
- **Pair it with a field when big changes are likely.** A few clicks are fine for small changes. When values vary a lot, like the number of copies to print, let people type the number too.
- **Consider Shift-click for large ranges.** On the Mac, a Shift-click that moves by a bigger amount, like ten steps, saves people a lot of clicking.

### Pitfalls

- **On the Mac, a stepper is just two small arrows.** It doesn't show the value, so always put the number next to it: in its label or in a field.
- **A range keeps the value in bounds.** With `in: 1...99`, the arrows stop at the ends instead of going past them.

### Key APIs

`Stepper(_:value:in:step:)`, `Stepper(_:onIncrement:onDecrement:)`, `TextField(_:value:format:)`

### Variants

#### The value in the label

When there's no room for a field, put the current value in the stepper's own label.

```swift
@State private var margin = 1.0

Stepper(value: $margin, in: 0...3, step: 0.25) {
    Text("Margin: \(margin, format: .number.precision(.fractionLength(2))) in")
}
```

#### Two values side by side

Give each field its own stepper, and wrap each pair in `LabeledContent` so the rows line up with other form controls.

```swift
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
```

More variants, left out to keep this file short: With a text field, Step through a list, Your own steps (macOS). Apple's docs: https://developer.apple.com/documentation/swiftui/stepper.md

## Related

[slider](slider.md), [text-field](text-field.md), [form](form.md), [state](state.md), [labeled-content](labeled-content.md), [date-picker](date-picker.md)
