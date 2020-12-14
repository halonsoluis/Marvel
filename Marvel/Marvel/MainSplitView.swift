//
//  MainSplitView.swift
//  Marvel
//
//  Created by Hugo Alonso on 13/12/2020.
//

import Foundation
import UIKit

final class MainSplitView {
    private let mainViewVC: UIViewController
    private let detailVC: UIViewController

    private lazy var splitView: UISplitViewController = createSplitView()
    private lazy var splitViewDelegate: SplitViewDelegate = SplitViewDelegate()

    internal init(mainViewVC: UIViewController, detailVC: UIViewController) {
        self.mainViewVC = mainViewVC
        self.detailVC = detailVC
    }

    func forceShowDetailView() {
        splitView.showDetailViewController(detailVC, sender: nil)
    }

    func injectAsRoot(in window: UIWindow) {
        window.rootViewController = splitView
    }

    private func createSplitView() -> UISplitViewController {
        let splitView = UISplitViewController()
        splitView.delegate = splitViewDelegate

        splitView.viewControllers.append(UINavigationController(rootViewController: mainViewVC))
        splitView.viewControllers.append(detailVC)

        return splitView
    }
}

extension MainSplitView {
    class SplitViewDelegate: UISplitViewControllerDelegate {

        func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController:UIViewController, onto primaryViewController:UIViewController) -> Bool {
            return true
        }

        func primaryViewController(forCollapsing splitViewController: UISplitViewController) -> UIViewController? {
            return splitViewController.viewControllers.first
        }
    }
}
