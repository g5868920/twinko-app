import UIKit

/// App-wide navigation convention (founder-approved 2026-07-16): on
/// non-root pushed pages, swiping from the left edge returns to the
/// previous page. The app hides the system navigation bar and draws
/// its own Back controls, which normally disables UIKit's interactive
/// pop — this restores the native edge gesture without any custom
/// full-screen swipe. Root pages are unaffected (`viewControllers
/// .count > 1`).
///
/// Tarot is the one exception: its stages live inside a single pushed
/// view, so it blocks the native pop while it is frontmost and drives
/// its own stage-wise edge-back instead (Tarot redesign §11).
enum InteractivePopGate {
    /// True while a view that manages its own staged back navigation
    /// (Tarot) is the frontmost pushed page.
    static var isBlocked = false
}

extension UINavigationController: UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        viewControllers.count > 1 && !InteractivePopGate.isBlocked
    }
}
