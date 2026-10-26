## Don't use when

- Moving to another screen: use `NavigationLink(value:)` with `.navigationDestination(for:)`.
- Opening a web page or another app: use `Link`.
- Switching a setting on or off: use `Toggle`.

## Rules

- **Pick glass styles for floating controls and bordered styles for content.** On iOS and macOS 26+, a button that floats above content uses `.buttonStyle(.glass)`, or `.glassProminent` for the one main action. Buttons inside content keep `.bordered` and `.borderedProminent`. Glass belongs to the controls layer (see `liquid-glass`).
