import SwiftUI

extension ComponentPage {
    static let macNativeChecklist = ComponentPage(
        id: "mac-native-checklist",
        title: "Mac-Native Checklist",
        summary: "The details Mac users and reviewers notice, in one list to check before you ship.",
        category: .feelsNative,
        kind: .reference,
        symbol: "checklist",
        availability: [],
        docsURL: nil,
        higURL: "https://developer.apple.com/design/human-interface-guidelines/designing-for-macos",
        aliases: [
            "checklist", "Mac polish", "pre-flight", "menu bar", "Window menu", "View menu",
            "context menu", "full keyboard access", "undo", "full screen", "Help menu", "About",
        ],
        related: [
            "great-mac-app", "ipad-app-in-window", "commands", "keyboard-shortcuts", "context-menu",
            "settings-scene", "undo-redo", "full-screen", "keyboard-access", "drag-drop",
        ],
        notes: [
            "**Check with the keyboard only.** Turn on Full Keyboard Access in System Settings, then try to reach every control and menu item without the pointer.",
            "**Open your app next to a Mac app you like.** Compare the menus item by item. Gaps show up fast.",
        ],
        sources: [
            "https://developer.apple.com/design/human-interface-guidelines/designing-for-macos",
            "https://developer.apple.com/design/human-interface-guidelines/the-menu-bar",
            "https://developer.apple.com/design/human-interface-guidelines/keyboards",
            "https://developer.apple.com/design/human-interface-guidelines/windows",
            "https://developer.apple.com/design/human-interface-guidelines/drag-and-drop",
            "https://developer.apple.com/design/human-interface-guidelines/settings",
            "https://developer.apple.com/design/human-interface-guidelines/mac-catalyst",
        ],
        reviewed: "October 2026"
    ) {
        VStack(alignment: .leading, spacing: 6) {
            Label("Menu bar", systemImage: "checkmark.circle.fill")
            Label("Keyboard", systemImage: "checkmark.circle.fill")
            Label("Windows", systemImage: "circle")
        }
        .font(.caption)
        .foregroundStyle(.secondary)
        .symbolRenderingMode(.hierarchical)
    } content: { page in
        MacNativeChecklistArticle(page: page)
    }
}

// MARK: - Page

private struct MacNativeChecklistArticle: View {
    let page: ComponentPage

    var body: some View {
        ArticlePage(page: page) {
            Prose("Each item comes from the macOS Human Interface Guidelines. None of them is an App Review rule on its own, but together they're the difference between an app that feels at home on the Mac and one that doesn't. Your checkmarks are saved on this Mac.")

            SectionTitle("Menu bar")
            Checklist(pageID: page.id, items: [
                ChecklistItem("menu-order", "Standard menus, in order", "Your app's menu, File, Edit, Format, View, your own menus, Window, Help. Leave out File and Format if they don't apply.", page: "commands"),
                ChecklistItem("every-command", "Every command is in a menu", "Even commands that also have a toolbar button or a context menu item."),
                ChecklistItem("disable-not-hide", "Unavailable items are dimmed, not hidden", "The menus show the same items every time."),
                ChecklistItem("about", "About comes first in the app menu", "With a short app name and no version number in the item's title."),
                ChecklistItem("window-menu", "A Window menu, even with one window", "With Minimize and Zoom, so Full Keyboard Access can reach them."),
                ChecklistItem("view-menu", "View menu items say what they'll do", "Show Sidebar when it's hidden, Hide Sidebar when it's showing."),
                ChecklistItem("help-menu", "A Help menu at the end", "Point it to your help or support page."),
            ])

            SectionTitle("Keyboard")
            Checklist(pageID: page.id, items: [
                ChecklistItem("standard-shortcuts", "Standard shortcuts work", "⌘C, ⌘V, ⌘Z, ⌘W, ⌘Q, and the rest do what they do everywhere.", page: "keyboard-shortcuts"),
                ChecklistItem("custom-shortcuts", "Custom shortcuts only for frequent commands", "And never a standard shortcut reused for something else."),
                ChecklistItem("modifier-order", "Modifiers listed as ⌃⌥⇧⌘", "Control, Option, Shift, Command, in that order."),
                ChecklistItem("full-keyboard-access", "Every control works with Full Keyboard Access", "Tab and the arrow keys reach everything.", page: "keyboard-access"),
            ])

            SectionTitle("Windows")
            Checklist(pageID: page.id, items: [
                ChecklistItem("resizable", "Windows resize smoothly", "The layout adapts to any reasonable size, not one fixed iPad-sized frame.", page: "window-group"),
                ChecklistItem("new-window", "Content can open in its own window", "Where that helps people work on two things at once."),
                ChecklistItem("full-screen", "Full screen works", "Enter Full Screen in the View menu.", page: "full-screen"),
                ChecklistItem("system-frame", "The system's window frame and controls", "No custom title bars or imitation window buttons."),
                ChecklistItem("no-bottom-actions", "Nothing critical in a bottom bar", "People often move windows partly off screen."),
            ])

            SectionTitle("Input and editing")
            Checklist(pageID: page.id, items: [
                ChecklistItem("context-menus", "Objects have context menus", "Mac users expect a Control-click on almost anything to offer actions.", page: "context-menu"),
                ChecklistItem("drag-drop", "Drag and drop works, including to the Finder", "With another way to do the same thing.", page: "drag-drop"),
                ChecklistItem("undo", "Undo and Redo in the Edit menu", "With the action's name, like Undo Paste.", page: "undo-redo"),
                ChecklistItem("pointer", "Buttons sit near the content, not at screen edges", "Ergonomic bottom bars from the iPad don't apply on a Mac."),
            ])

            SectionTitle("Settings and system")
            Checklist(pageID: page.id, items: [
                ChecklistItem("settings", "Settings… in the app menu with ⌘,", "Only app-wide options. Window options stay in the window.", page: "settings-scene"),
                ChecklistItem("dark-mode", "Light and dark appearances both look right", "Use system colors and materials.", page: "dark-mode"),
                ChecklistItem("mac-icon", "A Mac version of your app icon", "Not the iPad icon.", page: "app-icons"),
                ChecklistItem("users", "No assumptions about who's signed in", "With fast user switching, several people can be active on one Mac."),
            ])
        }
    }
}
