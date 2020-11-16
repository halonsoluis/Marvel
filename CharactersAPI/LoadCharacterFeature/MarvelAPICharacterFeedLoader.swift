//
//  MarvelAPICharacterFeedLoader.swift
//  CharactersAPI
//
//  Created by Hugo Alonso on 16/11/2020.
//

import Foundation

public final class MarvelAPICharacterFeedLoader: CharacterFeedLoader {
    let client: HTTPClient

    public init(client: HTTPClient) {
        self.client = client
    }

    public func load(id: Int? = nil, completion: @escaping (Result<MarvelCharacter, Error>) -> Void) {
        let url = resolveURL(for: id)
        client.get(from: url)
    }

    private func resolveURL(for character: Int?) -> URL {
        guard let id = character else {
            return MarvelAPIRoute.characters.route
        }
        return MarvelAPIRoute.character(id: id).route
    }
}

public protocol HTTPClient {
    func get(from url: URL)
}
