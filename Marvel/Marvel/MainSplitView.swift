import Foundation
import UIKit

final class MainSplitView {
    private let mainViewVC: UIViewController

    private lazy var splitView: UISplitViewController = createSplitView()
    private lazy var splitViewDelegate = SplitViewDelegate()

    init(mainViewVC: UIViewController) {
        self.mainViewVC = mainViewVC
    }

    func show(_ view: UIViewController) {
        splitView.showDetailViewController(view, sender: nil)
    }

    func injectAsRoot(in window: UIWindow) {
        window.rootViewController = splitView
    }

    private func createSplitView() -> UISplitViewController {
        let splitView = UISplitViewController()
        splitView.delegate = splitViewDelegate

        splitView.viewControllers.append(UINavigationController(rootViewController: mainViewVC))

        return splitView
    }
}

extension MainSplitView {
    class SplitViewDelegate: UISplitViewControllerDelegate {
        func splitViewController(_: UISplitViewController, collapseSecondary _: UIViewController, onto _: UIViewController) -> Bool {
            true
        }

        func primaryViewController(forCollapsing splitViewController: UISplitViewController) -> UIViewController? {
            splitViewController.viewControllers.first
        }
    }
}
