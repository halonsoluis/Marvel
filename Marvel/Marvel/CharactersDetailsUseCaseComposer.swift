//
//  CharactersDetailsUseCaseComposer.swift
//  Marvel
//
//  Created by Hugo Alonso on 08/04/2021.
//

import Foundation
import CharactersAPI
import ImageLoader

final class CharactersDetailsUseCaseComposer {
    private let marvelFeed: CharacterFeedLoader

    init(marvelFeed: CharacterFeedLoader) {
        self.marvelFeed = marvelFeed
    }

    func createDetails(for character: BasicCharacterData) -> CharacterDetailsViewController {

        let characterDetails = CharacterDetailsViewController(loadImageHandler: MainComposer.loadImageHandler)

        characterDetails.drawCharacter(
            item: character,
            sections: composeSections(for: character.id)
        )
        return characterDetails
    }

    private func createFeedProvider() -> PublicationFeedDataProvider {
        MainQueueDispatchDecoratorPublicationFeedDataProvider(
            PublicationFeedProvider(
                charactersLoader: marvelFeed,
                prefetchImageHandler: MainComposer.prefetchImageHandler,
                loadImageHandler: MainComposer.loadImageHandler
            )
        )
    }

    private func composeSections(for characterId: Int) -> [PublicationCollection] {

        let sections = MarvelPublication.Kind.allCases.map(\.rawValue)
        let feedProviders = sections.map { _ in createFeedProvider() }

        let collections = zip(sections, feedProviders)
            .map { (characterId, $0, MainComposer.loadImageHandler, $1) }
            .compactMap(PublicationCollection.init)

        zip(collections, feedProviders)
            .forEach(bind)

        return collections
    }

    private func bind(_ body: (collection: PublicationCollection, feed: ContentUpdatePerformer)) -> Void {
        MainComposer.bind(controller: body.collection, feed: body.feed)
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
