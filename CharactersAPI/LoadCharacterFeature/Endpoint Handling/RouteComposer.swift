//
//  RouteComposer.swift
//  CharactersAPI
//
//  Created by Hugo Alonso on 16/11/2020.
//

import Foundation

struct RouteComposer {
    let url: URL

    ///Fetches lists of characters.
    func characters() -> URL {
        url.appendingPathComponent("characters")
    }
    ///Fetches a single character by id.
    func character(withId id: Int) -> URL {
        characters().appendingPathComponent(id.description)
    }
}
