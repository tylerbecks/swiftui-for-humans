import SwiftUI

// The macOS edition: its tab intros, sidebar sections, pages, and demo
// windows. The engine in Shared/ compiles against whichever edition it's
// built with; the iOS edition defines the same things for iPhone and iPad.

extension AppTab {
    /// One line at the top of the tab's overview.
    var intro: String {
        switch self {
        case .design: "How great Mac apps look, feel, and behave."
        case .build: "Every SwiftUI component on the Mac, live. Tweak it, then copy the code."
        case .ship: "Get your Mac app through review and onto people's Macs."
        case .search: ""
        }
    }
}

/// Sidebar sections, in display order. Each one belongs to a tab.
enum ComponentCategory: String, CaseIterable, Identifiable, Codable, Sendable {
    // Components
    case controls = "Controls"
    case textInput = "Text Input"
    case textAndImages = "Text & Images"
    case layout = "Layout"
    case lists = "Lists & Tables"
    case windows = "Windows & Scenes"
    case navigation = "Navigation"
    case menus = "Menus & Commands"
    case presentation = "Presentation"
    case input = "Pointer & Input"
    case files = "Files & Sharing"
    case dataFlow = "Data Flow"
    case animation = "Animation"
    case frameworks = "Charts & Maps"
    case blocks = "Blocks"
    // Design
    case foundations = "Foundations"
    case accessibility = "Accessibility"
    case patterns = "Patterns"
    // Ship
    case startHere = "Start Here"
    case feelsNative = "Feels Like a Mac"
    case requiredByApple = "Required by Apple"
    case appStoreConnect = "App Store Connect"
    case testAndRelease = "Test & Release"

    var id: Self { self }

    var tab: AppTab {
        switch self {
        case .foundations, .accessibility, .patterns: .design
        case .startHere, .feelsNative, .requiredByApple, .appStoreConnect, .testAndRelease: .ship
        default: .build
        }
    }

    var symbol: String {
        switch self {
        case .controls: "slider.horizontal.3"
        case .textInput: "character.cursor.ibeam"
        case .textAndImages: "textformat"
        case .layout: "square.split.2x2"
        case .lists: "tablecells"
        case .windows: "macwindow.on.rectangle"
        case .navigation: "sidebar.left"
        case .menus: "menubar.rectangle"
        case .presentation: "rectangle.on.rectangle"
        case .input: "cursorarrow.rays"
        case .files: "doc.on.doc"
        case .dataFlow: "arrow.triangle.branch"
        case .animation: "sparkles"
        case .frameworks: "chart.xyaxis.line"
        case .blocks: "square.stack.3d.up"
        case .foundations: "paintpalette"
        case .accessibility: "accessibility"
        case .patterns: "rectangle.3.group"
        case .startHere: "flag"
        case .feelsNative: "macbook"
        case .requiredByApple: "checkmark.seal"
        case .appStoreConnect: "app.badge"
        case .testAndRelease: "airplane.departure"
        }
    }

    /// One line shown under the section title on the overview.
    var blurb: String {
        switch self {
        case .controls: "Buttons, toggles, pickers, and the rest of the Mac's controls."
        case .textInput: "Fields and editors, and moving between them with the keyboard."
        case .textAndImages: "Showing text, labels, symbols, and images."
        case .layout: "Stacks, grids, forms, and split views that grow with the window."
        case .lists: "Sidebars, tables, and outlines for browsing lots of data."
        case .windows: "Windows, Settings, menu bar extras, and documents."
        case .navigation: "Split views, toolbars, search, and inspectors."
        case .menus: "The menu bar, keyboard shortcuts, and context menus."
        case .presentation: "Sheets, alerts, popovers, and tooltips."
        case .input: "Hover, drag and drop, copy and paste, and trackpad gestures."
        case .files: "Opening, saving, and sharing files and data."
        case .dataFlow: "How state moves through your app and keeps views up to date."
        case .animation: "Springs and transitions, tuned for a pointer and a big screen."
        case .frameworks: "Swift Charts and MapKit, used from SwiftUI."
        case .blocks: "Whole windows built from the pieces above. Copy and adapt."
        case .foundations: "Mac colors, type, materials, symbols, and app icons."
        case .accessibility: "Keyboard access, VoiceOver, and display settings on the Mac."
        case .patterns: "Menus, Settings, undo, windows, and other Mac conventions."
        case .startHere: "Native, Catalyst, or an iPad app: how to bring your app to the Mac."
        case .feelsNative: "The details that set a real Mac app apart from an iPad app in a window."
        case .requiredByApple: "Sandboxing, privacy, and the rules Mac apps must follow."
        case .appStoreConnect: "Universal Purchase, Mac screenshots, and your listing."
        case .testAndRelease: "TestFlight for Mac, notarization, and shipping outside the store."
        }
    }
}

extension Catalog {
    /// Every page in the Mac app. Each group of examples owns one list, in
    /// its `<Group>Pages.swift` under `Examples/`.
    static let pages: [ComponentPage] =
        controlsPages
        + textPages
        + layoutDataPages
        + windowsNavigationPages
        + menusInputPages
        + essentialsBlocksPages
        + designPages
        + designPatternsPages
        + shipPages

    /// Every window a page can open with `OpenDemoWindowButton`.
    static let demoWindows: [DemoWindow] =
        controlsDemoWindows
        + textDemoWindows
        + layoutDataDemoWindows
        + windowsNavigationDemoWindows
        + menusInputDemoWindows
        + essentialsBlocksDemoWindows
        + designDemoWindows
        + designPatternsDemoWindows
        + shipDemoWindows
}
