//
//  MarvelAPIRoute.swift
//  CharactersAPI
//
//  Created by Hugo Alonso on 16/11/2020.
//

import Foundation

enum MarvelAPIRoute {
    ///Fetches lists of characters.
    case characters
    ///Fetches a single character by id.
    case character(id: Int)

    var route: URL {
        URL(string: "https://gateway.marvel.com:443/v1/public/\(path)")!
    }
}

extension MarvelAPIRoute {
    private var path: String {
        switch self {
        case .characters:
            return "characters"
        case let .character(id):
            return "characters/\(id)"
        }
    }
}
