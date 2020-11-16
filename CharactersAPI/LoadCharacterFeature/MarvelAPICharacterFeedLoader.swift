//
//  MarvelAPICharacterFeedLoader.swift
//  CharactersAPI
//
//  Created by Hugo Alonso on 16/11/2020.
//

import Foundation

public final class MarvelAPICharacterFeedLoader: CharacterFeedLoader {
    let client: HTTPClient
    let router: RouteComposer

    public init(baseAPIURL: URL = URL(string: "https://gateway.marvel.com:443/v1/public/")!, client: HTTPClient) {
        self.client = client
        self.router = RouteComposer(url: baseAPIURL)
    }

    public func load(id: Int? = nil, completion: @escaping (Result<MarvelCharacter, Error>) -> Void) {
        let url = resolveURL(for: id)
        client.get(from: url)
    }

    private func resolveURL(for character: Int?) -> URL {
        guard let id = character else {
            return router.characters()
        }
        return router.character(withId: id)
    }
}

public protocol HTTPClient {
    func get(from url: URL)
}
