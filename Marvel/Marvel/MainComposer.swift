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

        let publicationsProvider: () -> PublicationFeedDataProvider = {
            MainQueueDispatchDecoratorPublicationFeedDataProvider(
                PublicationFeedProvider(
                    charactersLoader: marvelFeed,
                    prefetchImageHandler: Self.prefetchImageHandler,
                    loadImageHandler: Self.loadImageHandler
                )
            )
        }

        let feedViewVC = FeedViewController(feedDataProvider: characterFeedDataProvider)
        let characterDetails = CharacterDetailsViewController(
            loadImageHandler: Self.loadImageHandler
        )
        let mainView = MainSplitView(mainViewVC: feedViewVC, detailVC: characterDetails)

        createSectionsForCharacter = { (character: BasicCharacterData) in
            characterDetails.drawCharacter(
                item: character,
                sections: MarvelPublication.Kind.allCases
                    .map { (character.id, $0.rawValue, Self.loadImageHandler, publicationsProvider()) }
                    .compactMap(PublicationCollection.init)
            )
            mainView.forceShowDetailView()
        }
        mainView.injectAsRoot(in: window)
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

    private static func prefetchImageHandler(url: URL, modifiedKey: String) {
        ImageCreator(url: url, uniqueKey: modifiedKey)
            .image
            .prefetch(completion: { _ in })
    }

    private static func loadImageHandler(imageFormula: (url: URL, uniqueKey: String), imageView: UIImageView, completion: @escaping (Error?)->Void) {
        ImageCreator(url: imageFormula.url, uniqueKey: imageFormula.uniqueKey)
            .image
            .render(on: imageView, completion: completion)
    }

    private static func loadImageHandler(imageFormula: ImageFormula, imageView: UIImageView) {
        loadImageHandler(
            imageFormula: imageFormula,
            imageView: imageView,
            completion: { _ in }
        )
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

extension BasicPublicationData {
    init?(publication: MarvelPublication) {
        self.init(
            id: publication.id,
            title: publication.title,
            thumbnail: publication.thumbnail,
            modified: publication.modified
        )
    }
}
