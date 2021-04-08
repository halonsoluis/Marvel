//
//  CharactersFeedUseCaseComposer.swift
//  Marvel
//
//  Created by Hugo Alonso on 08/04/2021.
//

import Foundation

import Foundation
import CharactersAPI
import ImageLoader

final class CharactersFeedUseCaseComposer {
    private let marvelFeed: CharacterFeedLoader
    private let router: Router

    init(marvelFeed: CharacterFeedLoader, router: @escaping Router) {
        self.marvelFeed = marvelFeed
        self.router = router
    }

    func composeFeedListController() -> FeedViewController {
        let characterFeedDataProvider = createFeedDataProvider()
        let feedViewVC = FeedViewController(
            feedDataProvider: characterFeedDataProvider
        )

        MainComposer.bind(controller: feedViewVC, feed: characterFeedDataProvider)

        return feedViewVC
    }
    
    private func createFeedDataProvider() -> FeedDataProvider {
        MainQueueDispatchDecoratorFeedDataProvider(
            MarvelFeedProvider(
                charactersLoader: marvelFeed,
                prefetchImageHandler: MainComposer.prefetchImageHandler,
                loadImageHandler: MainComposer.loadImageHandler,
                router: router
            )
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
