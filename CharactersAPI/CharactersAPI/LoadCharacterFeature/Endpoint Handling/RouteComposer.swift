//
//  RouteComposer.swift
//  CharactersAPI
//
//  Created by Hugo Alonso on 16/11/2020.
//

import Foundation

enum RouteComposer {
    ///Fetches lists of characters.
    case characters
    ///Fetches a single character by id.
    case character(id: Int)

    ///Fetches lists of comics filtered by a character id.
    case comics(characterId: Int)

    ///Fetches lists of events filtered by a character id.
    case events(characterId: Int)

    ///Fetches lists of series filtered by a character id.
    case series(characterId: Int)

    ///Fetches lists of stories filtered by a character id.
    case stories(characterId: Int)

    func url(from baseURL: URL) -> URL {
        switch self {
        case .characters:
            return characters(from: baseURL)
        case .character(let id):
            return character(id: id, from: baseURL)
        case .comics(characterId: let id):
            return endpoint("comics", id: id, from: baseURL)
        case .events(characterId: let id):
            return endpoint("events", id: id, from: baseURL)
        case .series(characterId: let id):
            return endpoint("series", id: id, from: baseURL)
        case .stories(characterId: let id):
            return endpoint("stories", id: id, from: baseURL)
        }
    }

    private func characters(from baseURL: URL) -> URL {
        baseURL.appendingPathComponent("characters")
    }

    private func character(id: Int, from baseURL: URL) -> URL {
        characters(from: baseURL)
            .appendingPathComponent(id.description)
    }

    private func endpoint(_ endpoint: String, id: Int, from baseURL: URL) -> URL {
        character(id: id, from: baseURL)
            .appendingPathComponent(endpoint)
    }
}
