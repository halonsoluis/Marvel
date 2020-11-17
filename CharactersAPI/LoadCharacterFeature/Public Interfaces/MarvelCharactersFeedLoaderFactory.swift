//
//  MarvelCharactersFeedLoaderFactory.swift
//  CharactersAPI
//
//  Created by Hugo Alonso on 17/11/2020.
//

import Foundation

public final class MarvelCharactersFeedLoader: CharacterFeedLoader {
    private let client: HTTPClient

    private lazy var characterFeedLoader: CharacterFeedLoader = MarvelAPICharacterFeedLoader(
        urlDecorator: MarvelURL(
            URL(string: "https://gateway.marvel.com:443/v1/public/")!,
            config: .shared,
            hashResolver: MarvelURL.MD5Digester.createHash,
            timeProvider: Date.init
        ), client: client
    )

    public init(client: HTTPClient) {
        self.client = client
    }

    public func characters(page: Int, completion: @escaping MultipleCharacterFeedLoaderResult) {
        characterFeedLoader.characters(page: page, completion: completion)
    }

    public func character(id: Int, completion: @escaping SingleCharacterFeedLoaderResult) {
        characterFeedLoader.character(id: id, completion: completion)
    }

    public func search(by name: String, in page: Int, completion: @escaping MultipleCharacterFeedLoaderResult) {
        characterFeedLoader.search(by: name, in: page, completion: completion)
    }
}
