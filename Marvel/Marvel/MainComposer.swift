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

struct BasicCharacterData: Equatable {
    let id: Int?
    let name: String?
    let thumbnail: URL?
    let modified: String?
}

protocol FeedDataProvider {
    var items: [BasicCharacterData] { get }
    var onItemsChangeCallback: (() -> Void)? { get set }

    func perform(action: MarvelFeedProvider.Action)
}

enum Route: Equatable {
    case list
    case search
    case details(for: MarvelCharacter)
}

class MainComposer {

    private var loadImageHandler: LoadImageHandler
    private var prefetchImageHandler: PrefetchImageHandler
    private var router: Router

    init() {
        prefetchImageHandler = { (url: URL, modifiedKey: String) in
            ImageLoader(url: url, uniqueKey: modifiedKey).image.prefetch(completion: { _ in })
        }
        loadImageHandler = { (url: URL, modifiedKey: String, imageView: UIImageView) in
            ImageLoader(url: url, uniqueKey: modifiedKey).image.render(on: imageView, completion: { _ in })
        }
        router = { (route: Route) in
            switch route {
            case .details(for: let item):
                break
            case .list:
                break
            case .search:
                break
            }
        }
    }

    private lazy var itemProvider: FeedDataProvider = {
        let client = URLSessionHTTPClient(session: URLSession.shared)
        let charactersLoader = MarvelCharactersFeedLoader(client: client)

        return MarvelFeedProvider(
            charactersLoader: charactersLoader,
            prefetchImageHandler: prefetchImageHandler,
            loadImageHandler: loadImageHandler,
            router: router
        )
    }()

    lazy var feedView: FeedViewController = {
        FeedViewController(feedDataProvider: itemProvider)
    }()
}
