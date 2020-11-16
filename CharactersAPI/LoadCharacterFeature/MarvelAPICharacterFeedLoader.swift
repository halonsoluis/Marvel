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

    enum Error: Swift.Error {
        case invalidData
    }

    public init(baseAPIURL: URL = URL(string: "https://gateway.marvel.com:443/v1/public/")!, client: HTTPClient) {
        self.client = client
        self.router = RouteComposer(url: baseAPIURL)
    }

    public func load(id: Int? = nil, completion: @escaping (Result<[MarvelCharacter], Swift.Error>) -> Void) {
        let url = resolveURL(for: id)
        client.get(from: url, completion: { result in
            switch result {
            case let .failure(error):
                completion(.failure(error))
            case let .success(data):
                guard let box = try? JSONDecoder().decode(DataWrapper<MarvelCharacterItem>.self, from: data) else {
                    completion(.failure(MarvelAPICharacterFeedLoader.Error.invalidData))
                    return
                }

                let items = box.data?.results ?? []
                return completion(.success(MarvelAPICharacterMapper.map(items)))
            }
        })
    }

    private class MarvelAPICharacterMapper {
        static func mapItem(_ item: MarvelCharacterItem) -> MarvelCharacter {
            MarvelCharacter(
                id: item.id,
                name: item.name,
                description: item.description,
                modified: item.modified,
                thumbnail: item.thumbnail?.resolvedURL
            )
        }

        static  func map(_ items: [MarvelCharacterItem]) -> [MarvelCharacter] {
            items.map(mapItem)
        }
    }

    private func resolveURL(for character: Int?) -> URL {
        guard let id = character else {
            return router.characters()
        }
        return router.character(withId: id)
    }
}

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (Result<Data, Error>) -> Void)
}
