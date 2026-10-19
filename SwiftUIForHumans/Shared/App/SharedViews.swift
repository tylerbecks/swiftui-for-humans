import SwiftUI
import StoreKit

/// Shows Apple's rating prompt when `Engagement` says it's a good moment,
/// after a beat so it doesn't land on top of the tap that caused it.
struct ReviewPrompt: ViewModifier {
    @Environment(\.requestReview) private var requestReview

    func body(content: Content) -> some View {
        content
            .onChange(of: Engagement.shared.reviewRequest) {
                Task {
                    try? await Task.sleep(for: .seconds(1.5))
                    requestReview()
                }
            }
    }
}

/// Shown in a tab, or a category, that has no pages yet.
struct ComingSoonView: View {
    let tab: AppTab

    var body: some View {
        ContentUnavailableView {
            Label("Coming Soon", systemImage: tab.symbol)
        } description: {
            Text("Pages for \(tab.title) are on the way.")
        }
    }
}

struct SidebarRow: View {
    let page: ComponentPage
    var detail: String? = nil

    var body: some View {
        Label {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(page.title)
                    if page.isNew {
                        NewBadge()
                    }
                }
                if let detail {
                    Text(detail)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        } icon: {
            Image(systemName: page.symbol)
        }
    }
}
