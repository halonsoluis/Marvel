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

    func url(from baseURL: URL) -> URL {
        switch self {
        case .characters:
            return baseURL.appendingPathComponent("characters")
        case .character(let id):
            return baseURL.appendingPathComponent("characters").appendingPathComponent(id.description)
        }
    }
}
