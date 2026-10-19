import SwiftUI

extension Catalog {
    /// This group's pages, in sidebar order within each category.
    static let textPages: [ComponentPage] = [
        .textField,
        .secureField,
        .textEditor,
        .focusKeyboard,
        .textLabel,
        .imageSymbols,
        .asyncImage,
    ]

    /// Windows this group's pages open with `OpenDemoWindowButton`.
    static let textDemoWindows: [DemoWindow] = [
        focusDefaultDemoWindow,
    ]
}
