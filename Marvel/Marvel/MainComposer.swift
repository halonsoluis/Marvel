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

struct BasicCharacterData: Hashable {
    let id: Int
    let name: String
    let thumbnail: URL
    let modified: String

    init?(id: Int?, name: String?, thumbnail: URL?, modified: String?) {
        guard let id = id, let name = name, let thumbnail = thumbnail, let modified = modified else { return nil }
        self.init(id: id, name: name, thumbnail: thumbnail, modified: modified)
    }

    init(id: Int, name: String, thumbnail: URL, modified: String) {
        self.id = id
        self.name = name
        self.thumbnail = thumbnail
        self.modified = modified
    }

    func hash(into hasher: inout Hasher) {
        return hasher.combine(id)
    }

    static func == (lhs: BasicCharacterData, rhs: BasicCharacterData) -> Bool {
        return lhs.id == rhs.id
    }
}

protocol FeedDataProvider {
    var items: [BasicCharacterData] { get }
    var onItemsChangeCallback: (() -> Void)? { get set }

    func perform(action: MarvelFeedProvider.Action)
}

enum Route: Equatable {
    case details(for: MarvelCharacter)
}

class MainComposer {
    private let baseView: UIWindow

    init(baseView: UIWindow) {
        self.baseView = baseView
    }

    func start() {
        let baseNavigation = UINavigationController(rootViewController: feedView())
        baseView.rootViewController = baseNavigation
    }

    func feedView() -> FeedViewController {
        FeedViewController(feedDataProvider: itemProvider)
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
    func characterDetails(item: MarvelCharacter) -> UIViewController {
        CharacterDetailsViewController(item: item, loadImageHandler: loadImageHandlerWithCompletion)
    }

    private func router(route: Route, using baseWindow: UIWindow ) {
        switch route {
        case .details(for: let item):
            DispatchQueue.main.async {
                (self.baseView.rootViewController as? UINavigationController)?.pushViewController(self.characterDetails(item: item), animated: true)
            }
        }
    }
}
