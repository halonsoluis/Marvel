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

typealias ImageFormula = (url: URL, uniqueKey: String)
typealias Router = (_ route: Route) -> Void
typealias PrefetchImageHandler = (ImageFormula) -> Void
typealias LoadImageHandler = (ImageFormula, _ destinationView: UIImageView) -> Void

enum Route: Equatable {
    case details(for: MarvelCharacter)
}

class MainComposer {
    private var createSectionsForCharacter: ((BasicCharacterData) -> Void)?

    func compose(using window: UIWindow) {

        let marvelFeed = MarvelCharactersFeedLoader(
            client: URLSessionHTTPClient(session: URLSession.shared)
        )

        let characterFeedDataProvider = MainQueueDispatchDecoratorFeedDataProvider(
            MarvelFeedProvider(
                charactersLoader: marvelFeed,
                prefetchImageHandler: Self.prefetchImageHandler,
                loadImageHandler: Self.loadImageHandler,
                router: router
            )
        )

        let feedViewVC = FeedViewController(feedDataProvider: characterFeedDataProvider)

        Self.bind(controller: feedViewVC, feed: characterFeedDataProvider)
        
        let mainView = MainSplitView(mainViewVC: feedViewVC)

        let charactersDetailComposer = CharactersDetailsUseCaseComposer(marvelFeed: marvelFeed)

        createSectionsForCharacter = { (character: BasicCharacterData) in
            mainView.show(
                charactersDetailComposer.createDetails(for: character)
            )
        }

        mainView.injectAsRoot(in: window)
    }

    static func bind(controller: (AnyObject & ContentUpdatable), feed: ContentUpdatePerformer) -> Void {
        var feed = feed
        feed.onItemsChangeCallback = { [weak controller] in
            controller?.update()
        }
    }

    // MARK - Navigation

    private func router(route: Route) {
        switch route {
        case .details(for: let item):
            guard let character = BasicCharacterData(character: item) else { return }

            DispatchQueue.main.async {
                self.createSectionsForCharacter?(character)
            }
        }
    }

    // MARK - Image Handling

    static func prefetchImageHandler(url: URL, modifiedKey: String) {
        ImageCreator(url: url, uniqueKey: modifiedKey)
            .image
            .prefetch(completion: { _ in })
    }

    static func loadImageHandler(imageFormula: ImageFormula, imageView: UIImageView) {
        ImageCreator(url: imageFormula.url, uniqueKey: imageFormula.uniqueKey)
            .image
            .render(on: imageView, completion: { _ in })
    }
}

extension BasicCharacterData {
    init?(character: MarvelCharacter) {
        self.init(
            id: character.id,
            name: character.name,
            description: character.description,
            thumbnail: character.thumbnail,
            modified: character.modified
        )
    }
}
