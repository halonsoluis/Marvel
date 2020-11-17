//
//  MarvelAPICharacterFeedLoader.swift
//  CharactersAPI
//
//  Created by Hugo Alonso on 16/11/2020.
//

import Foundation

final class MarvelAPICharacterFeedLoader {
    let client: HTTPClient
    let router: RouteComposer
    let urlDecorator: (URL) -> MarvelURL

    enum Error: Swift.Error {
        case invalidData
        case invalidStatusCode
        case invalidURL
    }

    init(baseAPIURL: URL = URL(string: "https://gateway.marvel.com:443/v1/public/")!, urlDecorator: @escaping (URL) -> MarvelURL, client: HTTPClient) {
        self.client = client
        self.router = RouteComposer(url: baseAPIURL)
        self.urlDecorator = urlDecorator
    }

    private func loadCharacters(by name: String? = nil, in page: Int = 0, completion: @escaping MultipleCharacterFeedLoaderResult) {
        let url = urlDecorator(resolveBaseURL(for: nil)).url(nameStartingWith: name, for: page)

        performQuery(to: url, completion: completion)
    }

    private func loadCharacter(id: Int, completion: @escaping SingleCharacterFeedLoaderResult) {
        let url = urlDecorator(resolveBaseURL(for: id)).url()

        performQuery(to: url) { result in
            switch result {
            case .success(let items):
                completion(.success(items.first))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    private func performQuery(to url: URL?, completion: @escaping MultipleCharacterFeedLoaderResult) {
        guard let url = url else {
            completion(.failure(Error.invalidURL))
            return
        }
        client.get(from: url, completion: { [weak self] result in
            guard let `self` = self else {
                return
            }
            completion(self.parse(response: result))
        })
    }

    private func parseResult(from data: Data) -> [MarvelCharacter]? {
        guard let box = try? JSONDecoder().decode(DataWrapper<MarvelCharacterItem>.self, from: data) else {
            return nil
        }
        let items = box.data?.results ?? []
        return MarvelAPICharacterMapper.map(items)
    }

    private func parse(response result: Result<(Data, HTTPURLResponse), Swift.Error>) -> Result<[MarvelCharacter], Swift.Error> {
        switch result {
        case let .success((data, response)):
            guard response.statusCode == 200 else {
                return .failure(Error.invalidStatusCode)
            }
            guard let result: [MarvelCharacter] = parseResult(from: data) else {
                return .failure(Error.invalidData)
            }
            return .success(result)
        case let .failure(error):
            return .failure(error)
        }
    }

    private struct MarvelAPICharacterMapper {
        static func mapItem(_ item: MarvelCharacterItem) -> MarvelCharacter {
            MarvelCharacter(
                id: item.id,
                name: item.name,
                description: item.description,
                modified: item.modified,
                thumbnail: item.thumbnail?.resolvedURL
            )
        }

        static func map(_ items: [MarvelCharacterItem]) -> [MarvelCharacter] {
            items.map(mapItem)
        }
    }

    private func resolveBaseURL(for character: Int?) -> URL {
        if let id = character {
            return router.character(withId: id)
        }
        return router.characters()
    }
}

extension MarvelAPICharacterFeedLoader: CharacterFeedLoader {
    public func characters(page: Int, completion: @escaping MultipleCharacterFeedLoaderResult) {
        loadCharacters(in: page, completion: completion)
    }

    public func character(id: Int, completion: @escaping SingleCharacterFeedLoaderResult) {
        loadCharacter(id: id, completion: completion)
    }

    public func search(by name: String, in page: Int, completion: @escaping MultipleCharacterFeedLoaderResult) {
        loadCharacters(by: name, in: page, completion: completion)
    }
}

extension LinkURL {
    var resolvedURL: URL? {
        guard let url = url, let type = type else {
            return nil
        }
        return URL(string: "\(url).\(type)")
    }
}
