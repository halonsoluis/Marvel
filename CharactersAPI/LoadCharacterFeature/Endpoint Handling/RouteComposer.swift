//
//  RouteComposer.swift
//  CharactersAPI
//
//  Created by Hugo Alonso on 16/11/2020.
//

import Foundation

enum RouteComposer {
    ///Fetches lists of characters.
    case characters(url: URL)
    ///Fetches a single character by id.
    case character(url: URL, id: Int)

    var url: URL {
        switch self {
        case let .characters(url):
            return url.appendingPathComponent("characters")
        case let .character(url, id):
            return url.appendingPathComponent("characters").appendingPathComponent(id.description)
        }
    }
}
