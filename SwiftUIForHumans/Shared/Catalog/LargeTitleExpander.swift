#if os(iOS)
import SwiftUI
import UIKit

/// Shows the page's large title when the page appears.
///
/// Why UIKit: on iPhone, a page opened from a scrolled-down page (Next,
/// Related) reuses that page's navigation bar, which stays collapsed.
/// SwiftUI has no way to expand a large title, so this asks the hosting
/// navigation bar to size itself again, which brings the large title back.
struct LargeTitleExpander: UIViewRepresentable {
    func makeUIView(context: Context) -> ProbeView {
        ProbeView()
    }

    func updateUIView(_ view: ProbeView, context: Context) {}

    final class ProbeView: UIView {
        override func didMoveToWindow() {
            super.didMoveToWindow()
            guard window != nil else { return }
            Task { @MainActor [weak self] in
                guard let self, let bar = self.navigationController?.navigationBar else { return }
                bar.sizeToFit()
            }
        }

        private var navigationController: UINavigationController? {
            var responder: UIResponder? = self
            while let next = responder?.next {
                if let controller = next as? UIViewController, let navigation = controller.navigationController {
                    return navigation
                }
                responder = next
            }
            return nil
        }
    }
}
#endif
