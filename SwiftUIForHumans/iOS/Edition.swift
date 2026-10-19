import SwiftUI

// The iOS edition: its tab intros, sidebar sections, and pages. The engine
// in Shared/ compiles against whichever edition it's built with, so the
// macOS edition defines the same three things for the Mac.

extension AppTab {
    /// One line at the top of the tab's overview.
    var intro: String {
        switch self {
        case .components: "Every SwiftUI component, live. Change it, see it, copy the code."
        case .design: "Apple's Human Interface Guidelines in plain language."
        case .ship: "What Apple checks before your app goes live."
        case .search: ""
        }
    }
}

/// Sidebar sections, in display order. Each one belongs to a tab.
enum ComponentCategory: String, CaseIterable, Identifiable, Sendable {
    // Components
    case controls = "Controls"
    case textInput = "Text Input"
    case textAndImages = "Text & Images"
    case layout = "Layout"
    case lists = "Lists & Navigation"
    case presentation = "Presentation"
    case modifiers = "Modifiers"
    case dataFlow = "Data Flow"
    case animation = "Animation & Effects"
    case graphics = "Shapes & Gradients"
    case frameworks = "Charts & Maps"
    case blocks = "Blocks"
    // Design
    case foundations = "Foundations"
    case accessibility = "Accessibility"
    case patterns = "Patterns"
    // Ship
    case startHere = "Start Here"
    case feelsNative = "Feels Native"
    case requiredByApple = "Required by Apple"
    case appStoreConnect = "App Store Connect"
    case testAndRelease = "Test & Release"

    var id: Self { self }

    var tab: AppTab {
        switch self {
        case .foundations, .accessibility, .patterns: .design
        case .startHere, .feelsNative, .requiredByApple, .appStoreConnect, .testAndRelease: .ship
        default: .components
        }
    }

    var symbol: String {
        switch self {
        case .controls: "slider.horizontal.3"
        case .textInput: "character.cursor.ibeam"
        case .textAndImages: "textformat"
        case .layout: "square.split.2x2"
        case .lists: "list.bullet.rectangle"
        case .presentation: "rectangle.portrait.on.rectangle.portrait"
        case .modifiers: "wand.and.stars"
        case .dataFlow: "arrow.triangle.branch"
        case .animation: "sparkles"
        case .graphics: "square.on.circle"
        case .frameworks: "chart.xyaxis.line"
        case .blocks: "square.stack.3d.up"
        case .foundations: "paintpalette"
        case .accessibility: "accessibility"
        case .patterns: "rectangle.3.group"
        case .startHere: "flag"
        case .feelsNative: "iphone"
        case .requiredByApple: "checkmark.seal"
        case .appStoreConnect: "app.badge"
        case .testAndRelease: "airplane.departure"
        }
    }

    /// One line shown under the section title on the overview.
    var blurb: String {
        switch self {
        case .controls: "Buttons, toggles, pickers, and everything people tap or drag."
        case .textInput: "Fields and editors for typing."
        case .textAndImages: "Showing text, labels, and images."
        case .layout: "Stacks, grids, and scroll views that arrange everything else."
        case .lists: "Lists, forms, and moving between screens."
        case .presentation: "Sheets, alerts, menus, and popovers."
        case .modifiers: "The dot-methods that style and position views, and why their order matters."
        case .dataFlow: "How state moves through your app and keeps views up to date."
        case .animation: "Springs, transitions, and motion that make an app feel alive."
        case .graphics: "Shapes, paths, and gradients for drawing your own graphics."
        case .frameworks: "Swift Charts and MapKit, used from SwiftUI."
        case .blocks: "Whole screens built from the pieces above. Copy and adapt."
        case .foundations: "Apple's colors, type, materials, symbols, and Liquid Glass."
        case .accessibility: "Making your app work for everyone, including VoiceOver and larger text."
        case .patterns: "Common tasks, like onboarding, search, and settings, done the Apple way."
        case .startHere: "What App Review is, and the path from code to the App Store."
        case .feelsNative: "The details that make an app feel at home on iPhone."
        case .requiredByApple: "Rules your app must follow to pass App Review."
        case .appStoreConnect: "Setting up your listing, privacy labels, and pricing."
        case .testAndRelease: "TestFlight, submitting for review, and what to do if you're rejected."
        }
    }
}

extension Catalog {
    /// Every page in the iOS app.
    static let pages: [ComponentPage] =
        controlsPages
        + textPages
        + layoutPages
        + navigationPages
        + modifierPages
        + dataFlowPages
        + animationPages
        + designPages
        + blockPages
        + foundationsPages
        + accessibilityPages
        + patternsPages
        + shipNativePages
        + shipRequiredPages
        + shipConnectPages
}
