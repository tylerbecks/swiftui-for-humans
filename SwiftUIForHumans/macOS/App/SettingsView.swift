import SwiftUI

/// The app's Settings window (⌘,). Inside a `Settings` scene, the
/// `TabView` becomes the window's toolbar of panes, and the window reopens
/// on the last pane used.
struct SettingsView: View {
    @AppStorage("settings.pane") private var pane = SettingsPane.general

    var body: some View {
        TabView(selection: $pane) {
            Tab("General", systemImage: "gearshape", value: .general) {
                GeneralPane()
            }
            Tab("Checklists", systemImage: "checklist", value: .checklists) {
                ChecklistsPane()
            }
        }
        .frame(width: 440)
    }
}

private enum SettingsPane: String {
    case general, checklists
}

private struct GeneralPane: View {
    @AppStorage(PreviewScheme.storageKey) private var scheme: PreviewScheme = .system

    var body: some View {
        Form {
            Picker("Preview appearance", selection: $scheme) {
                ForEach(PreviewScheme.allCases) { option in
                    Text(option.rawValue).tag(option)
                }
            }
            Text("Shows every live preview in light or dark, whatever the rest of the app uses.")
                .font(.callout)
                .foregroundStyle(.secondary)
        }
        .formStyle(.grouped)
        .fixedSize(horizontal: false, vertical: true)
    }
}

private struct ChecklistsPane: View {
    @State private var confirmsReset = false
    @State private var checkedCount = Self.checkedKeys().count

    var body: some View {
        Form {
            LabeledContent("Checked items", value: "\(checkedCount)")
            Button("Clear All Checklists…", role: .destructive) {
                confirmsReset = true
            }
            .disabled(checkedCount == 0)
        }
        .formStyle(.grouped)
        .fixedSize(horizontal: false, vertical: true)
        .confirmationDialog("Clear all checklists?", isPresented: $confirmsReset) {
            Button("Clear All", role: .destructive) {
                Self.checkedKeys().forEach(UserDefaults.standard.removeObject(forKey:))
                checkedCount = 0
            }
        } message: {
            Text("Every ticked item on every Ship page is unticked.")
        }
        .onAppear { checkedCount = Self.checkedKeys().count }
    }

    /// Ticked checklist items are stored as `checklist.<page>.<item>`.
    private static func checkedKeys() -> [String] {
        UserDefaults.standard.dictionaryRepresentation()
            .filter { $0.key.hasPrefix("checklist.") && ($0.value as? Bool) == true }
            .map(\.key)
    }
}
