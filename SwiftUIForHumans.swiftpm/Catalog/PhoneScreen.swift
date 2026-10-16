import SwiftUI
import UIKit

/// A whole iPhone screen with its own navigation bar, shown inside a
/// `DeviceFrame`. Use it for blocks and any demo whose screen has a title,
/// toolbar, or search field.
///
/// Pass the screen's root view WITHOUT a `NavigationStack`; its
/// `.navigationTitle`, `.toolbar`, and `.searchable` draw in the phone's own
/// bar. Set `hasNavigationBar: false` for screens without one (onboarding).
///
/// Why UIKit: every catalog page already lives inside the app's navigation.
/// A nested SwiftUI `NavigationStack` doesn't get its own bar; its title and
/// toolbar take over the catalog's bar instead (tested on iOS 27). Hosting the
/// screen in its own `UINavigationController` is the only way to keep them
/// inside the frame. Pushes from a `NavigationLink` still go to the catalog's
/// stack, so demos that push should also offer the screen full screen.
struct PhoneScreen<Content: View>: View {
    var hasNavigationBar = true
    var width: CGFloat = 300
    var height: CGFloat = 560
    @ViewBuilder let content: Content
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        DeviceFrame(width: width, height: height) {
            if hasNavigationBar {
                HostedNavigation(
                    root: content
                        .environment(\.colorScheme, colorScheme)
                        .environment(\.horizontalSizeClass, .compact),
                    isDark: colorScheme == .dark
                )
            } else {
                content
                    .environment(\.horizontalSizeClass, .compact)
            }
        }
    }
}

private struct HostedNavigation<Root: View>: UIViewControllerRepresentable {
    let root: Root
    let isDark: Bool

    func makeUIViewController(context: Context) -> PhoneNavigationController {
        let hosting = UIHostingController(rootView: root)
        hosting.view.backgroundColor = .clear
        let navigation = PhoneNavigationController(rootViewController: hosting)
        navigation.view.backgroundColor = .systemBackground
        // UIKit content isn't clipped by SwiftUI's clipShape, so round it to
        // match DeviceFrame's 38pt screen corners.
        navigation.view.clipsToBounds = true
        navigation.view.layer.cornerRadius = 38
        navigation.view.layer.cornerCurve = .continuous
        navigation.navigationBar.prefersLargeTitles = true
        // Behave like an iPhone even when the catalog runs on iPad: compact
        // width keeps .searchable a field rather than an iPad search button.
        navigation.traitOverrides.horizontalSizeClass = .compact
        // The frame has no safe area to inset from, so the bar would get zero
        // margins and large titles would touch the left edge.
        let bar = navigation.navigationBar
        bar.preservesSuperviewLayoutMargins = false
        bar.insetsLayoutMarginsFromSafeArea = false
        bar.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
        navigation.overrideUserInterfaceStyle = isDark ? .dark : .light
        return navigation
    }

    func updateUIViewController(_ navigation: PhoneNavigationController, context: Context) {
        (navigation.viewControllers.first as? UIHostingController<Root>)?.rootView = root
        navigation.overrideUserInterfaceStyle = isDark ? .dark : .light
    }
}

/// Shows the bottom toolbar whenever the screen puts items in it (such as
/// `ToolbarItem(placement: .bottomBar)`), the way a real iPhone screen does.
final class PhoneNavigationController: UINavigationController {
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let hasItems = !(topViewController?.toolbarItems ?? []).isEmpty
        if hasItems == isToolbarHidden {
            setToolbarHidden(!hasItems, animated: false)
        }
    }
}
