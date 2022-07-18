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
typealias PrefetchImageHandler = (ImageFormula) -> Cancellable?
typealias LoadImageHandler = (ImageFormula, _ destinationView: UIImageView) -> Cancellable?

enum Route: Equatable {
    case details(for: MarvelCharacter)
}

final class MainComposer {
    private var createSectionsForCharacter: ((BasicCharacterData) -> Void)?

    func compose(using window: UIWindow) {

        let marvelFeed = MarvelCharactersFeedLoader(
            client: URLSessionHTTPClient(session: URLSession.shared)
        )

        let feedUseCase = CharactersFeedUseCaseComposer(
            marvelFeed: marvelFeed,
            router: router
        )

        let detailsUseCase = CharactersDetailsUseCaseComposer(
            marvelFeed: marvelFeed
        )

        let mainView = MainSplitView(
            mainViewVC: feedUseCase.composeFeedListController()
        )

        createSectionsForCharacter = { (character: BasicCharacterData) in
            mainView.show(
                detailsUseCase.createDetails(for: character)
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
            guard let character = BasicCharacterData(character: item) else {
                return
            }

            DispatchQueue.main.async {
                self.createSectionsForCharacter?(character)
            }
        }
    }

    // MARK - Image Handling

    static func prefetchImageHandler(url: URL, modifiedKey: String) -> Cancellable? {
        ImageCreator(url: url, uniqueKey: modifiedKey)
            .image
            .prefetch(completion: { _ in })
    }

    static func loadImageHandler(imageFormula: ImageFormula, imageView: UIImageView) -> Cancellable? {
        ImageCreator(url: imageFormula.url, uniqueKey: imageFormula.uniqueKey)
            .image
            .render(on: imageView, completion: { _ in })
    }
}
