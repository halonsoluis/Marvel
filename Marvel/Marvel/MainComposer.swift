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
typealias PrefetchImageHandler = ((url: URL, uniqueKey: String)) -> Void
typealias LoadImageHandler = ((url: URL, uniqueKey: String), _ destinationView: UIImageView) -> Void

enum Route: Equatable {
    case details(for: MarvelCharacter)
}

class MainComposer {
    private let baseView: UIWindow

    private lazy var splitView: UISplitViewController = createSplitView()
    private lazy var splitViewDelegate: SplitViewDelegate = SplitViewDelegate()
    private lazy var feedViewVC = FeedViewController(
        feedDataProvider: MainQueueDispatchDecoratorFeedDataProvider(itemProvider)
    )
    private lazy var characterDetailsVC = CharacterDetailsViewController(
        loadImageHandler: loadImageHandlerWithCompletion,
        feedDataProvider: { MainQueueDispatchDecoratorPublicationFeedDataProvider(self.publicationsProvider()) }
    )

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

    private func loadImageHandler(imageFormula: (url: URL, uniqueKey: String), imageView: UIImageView) {
        loadImageHandlerWithCompletion(imageFormula: imageFormula, imageView: imageView, completion: { _ in })
    }

    private func loadImageHandlerWithCompletion(imageFormula: (url: URL, uniqueKey: String), imageView: UIImageView, completion: @escaping (Error?)->Void) {
        createImageLoader(url: imageFormula.url, modifiedKey: imageFormula.uniqueKey).render(on: imageView, completion: completion)
    }

    private func prefetchImageHandler(url: URL, modifiedKey: String) {
        createImageLoader(url: url, modifiedKey: modifiedKey).prefetch(completion: { _ in })
    }

    private func createImageLoader(url: URL, modifiedKey: String) -> Image {
        ImageCreator(url: url, uniqueKey: modifiedKey).image
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

    private func publicationsProvider() -> PublicationFeedDataProvider  {
        let client = URLSessionHTTPClient(session: URLSession.shared)
        let charactersLoader = MarvelCharactersFeedLoader(client: client)

        func routerIntercept(route: Route) {
            router(route: route, using: baseView)
        }

        return PublicationFeedProvider(
            charactersLoader: charactersLoader,
            prefetchImageHandler: prefetchImageHandler,
            loadImageHandler: loadImageHandler
        )
    }
}

// MARK - Navigation
extension MainComposer {

    func publicationFeedDataProvider() -> PublicationFeedDataProvider {
        MainQueueDispatchDecoratorPublicationFeedDataProvider(self.publicationsProvider())
    }

    private func router(route: Route, using baseWindow: UIWindow ) {
        switch route {
        case .details(for: let item):
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else { return }

                let sections = MarvelPublication.Kind.allCases.map { publicationKind in
                    PublicationCollection(
                        characterId: item.id!,
                        section: publicationKind,
                        loadImageHandler: strongSelf.loadImageHandlerWithCompletion,
                        feedDataProvider: strongSelf.publicationFeedDataProvider()
                    )
                }

                strongSelf.characterDetailsVC.drawCharacter(item: item, sections: sections)
                strongSelf.splitView.showDetailViewController(strongSelf.characterDetailsVC, sender: nil)
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
