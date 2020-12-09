//
//  MainComposer.swift
//  Marvel
//
//  Created by Hugo Alonso on 27/11/2020.
//

import Foundation
import UIKit
import CharactersAPI
import ImageLoader

typealias Router = (_ route: Route) -> Void
typealias PrefetchImageHandler = (_ url: URL, _ uniqueKey: String) -> Void
typealias LoadImageHandler = (_ url: URL, _ uniqueKey: String, _ destinationView: UIImageView) -> Void

enum Route: Equatable {
    case details(for: MarvelCharacter)
}

class MainComposer {
    private let baseView: UIWindow

    private lazy var splitView: UISplitViewController = createSplitView()
    private lazy var splitViewDelegate: SplitViewDelegate = SplitViewDelegate()
    private lazy var feedViewVC = FeedViewController(feedDataProvider: MainQueueDispatchDecorator(itemProvider))
    private lazy var characterDetailsVC = CharacterDetailsViewController(loadImageHandler: loadImageHandlerWithCompletion)

    init(baseView: UIWindow) {
        self.baseView = baseView
    }

    func start() {
        baseView.rootViewController = splitView
    }

    private func createSplitView() -> UISplitViewController {
        let splitView = UISplitViewController()
        splitView.delegate = splitViewDelegate

        splitView.viewControllers.append(UINavigationController(rootViewController: feedViewVC))
        splitView.viewControllers.append(characterDetailsVC)

        return splitView
    }

    private func loadImageHandler(url: URL, modifiedKey: String, imageView: UIImageView) {
        loadImageHandlerWithCompletion(url: url, modifiedKey: modifiedKey, imageView: imageView, completion: { _ in })
    }

    private func loadImageHandlerWithCompletion(url: URL, modifiedKey: String, imageView: UIImageView, completion: @escaping (Error?)->Void) {
        ImageCreator(url: url, uniqueKey: modifiedKey).image.render(on: imageView, completion: completion)
    }

    private func prefetchImageHandler(url: URL, modifiedKey: String) {
        ImageCreator(url: url, uniqueKey: modifiedKey).image.prefetch(completion: { _ in })
    }

    private lazy var itemProvider: FeedDataProvider = {
        let client = URLSessionHTTPClient(session: URLSession.shared)
        let charactersLoader = MarvelCharactersFeedLoader(client: client)

        func routerIntercept(route: Route) {
            router(route: route, using: baseView)
        }

        return MarvelFeedProvider(
            charactersLoader: charactersLoader,
            prefetchImageHandler: prefetchImageHandler,
            loadImageHandler: loadImageHandler,
            router: routerIntercept
        )
    }()
}

// MARK - Navigation
extension MainComposer {

    private func router(route: Route, using baseWindow: UIWindow ) {
        switch route {
        case .details(for: let item):
            DispatchQueue.main.async {
                self.characterDetailsVC.drawCharacter(item: item)
                self.splitView.showDetailViewController(self.characterDetailsVC, sender: nil)
            }
        }
    }
}

extension MainComposer {
    class SplitViewDelegate: UISplitViewControllerDelegate {

        func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController:UIViewController, onto primaryViewController:UIViewController) -> Bool {
            return true
        }

        func primaryViewController(forCollapsing splitViewController: UISplitViewController) -> UIViewController? {
            return splitViewController.viewControllers.first
        }
    }
}
