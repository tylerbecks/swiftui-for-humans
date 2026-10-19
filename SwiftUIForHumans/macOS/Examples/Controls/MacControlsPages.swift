import SwiftUI

extension Catalog {
    /// This group's pages, in sidebar order within each category.
    static let controlsPages: [ComponentPage] = [
        .button,
        .toggle,
        .picker,
        .menu,
        .slider,
        .stepper,
        .datePicker,
        .colorPicker,
        .gaugeProgress,
        .link,
        .controlGroup,
        .labeledContent,
    ]

    /// Windows this group's pages open with `OpenDemoWindowButton`.
    static let controlsDemoWindows: [DemoWindow] = [
        controlGroupDemoWindow,
    ]
}
