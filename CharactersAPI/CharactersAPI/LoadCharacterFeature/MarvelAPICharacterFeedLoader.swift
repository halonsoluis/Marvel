//
//  MarvelAPICharacterFeedLoader.swift
//  CharactersAPI
//
//  Created by Hugo Alonso on 16/11/2020.
//

import Foundation

final class MarvelAPICharacterFeedLoader {
    let client: HTTPClient
    let urlDecorator: MarvelURL

    enum Error: Swift.Error, Equatable {
        case invalidData
        case invalidStatusCode(code: Int)
        case invalidURL
    }

    init(urlDecorator: MarvelURL, client: HTTPClient) {
        self.client = client
        self.urlDecorator = urlDecorator
    }

    private func loadCharacters(by name: String? = nil, in page: Int = 0, completion: @escaping MultipleCharacterFeedLoaderResult) {
        let url = urlDecorator.url(route: .characters, nameStartingWith: name, for: page)
        requestCharacter(to: url, completion: completion)
    }

    private func loadCharacter(id: Int, completion: @escaping SingleCharacterFeedLoaderResult) {
        let url = urlDecorator.url(route: .character(id: id))

        requestCharacter(to: url) { result in
            switch result {
            case .success(let items):
                completion(.success(items.first))
            case let .failure(error as Error) where error == Error.invalidStatusCode(code: 404):
                completion(.success(nil))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    private func publicationRouteResolver(characterId: Int, for type: MarvelPublication.Kind) -> RouteComposer {
        switch type {
        case .comics:
            return .comics(characterId: characterId)
        case .events:
            return .events(characterId: characterId)
        case .series:
            return .series(characterId: characterId)
        case .stories:
            return .stories(characterId: characterId)
        }
    }

    private func loadPublication(characterId: Int, type: MarvelPublication.Kind, page: Int, completion: @escaping MultiplePublicationFeedLoaderResult) {
        let url = urlDecorator.url(route: publicationRouteResolver(characterId: characterId, for: type), for: page)

        requestPublication(to: url, completion: completion)
    }

    private func requestPublication(to url: URL?, completion: @escaping MultiplePublicationFeedLoaderResult) {
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

    private func parseResult(from data: Data) -> [MarvelPublication]? {
        guard let box = try? JSONDecoder().decode(DataWrapper<RelatedPublication>.self, from: data) else {
            return nil
        }
        let items = box.data?.results ?? []
        return MarvelAPICharacterMapper.map(items)
    }

    private func parse(response result: Result<(Data, HTTPURLResponse), Swift.Error>) -> Result<[MarvelPublication], Swift.Error> {
        switch result {
        case let .success((data, response)):
            guard response.statusCode == 200 else {
                return .failure(Error.invalidStatusCode(code: response.statusCode))
            }
            guard let result: [MarvelPublication] = parseResult(from: data) else {
                return .failure(Error.invalidData)
            }
            return .success(result)
        case let .failure(error):
            return .failure(error)
        }
    }

    private func requestCharacter(to url: URL?, completion: @escaping MultipleCharacterFeedLoaderResult) {
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
                return .failure(Error.invalidStatusCode(code: response.statusCode))
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

        static func mapItem(_ item: RelatedPublication) -> MarvelPublication {
            MarvelPublication(
                id: item.id,
                title: item.title,
                modified: item.modified,
                thumbnail: item.thumbnail?.resolvedURL
            )
        }

        static func map(_ items: [RelatedPublication]) -> [MarvelPublication] {
            items.map(mapItem)
        }
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

    public func publication(characterId: Int, type: MarvelPublication.Kind, page: Int, completion: @escaping MultiplePublicationFeedLoaderResult) {
        loadPublication(characterId: characterId, type: type, page: page, completion: completion)
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
