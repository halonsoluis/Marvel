//
//  MarvelAPIRouteTests.swift
//  CharactersAPITests
//
//  Created by Hugo Alonso on 16/11/2020.
//

import XCTest
@testable import CharactersAPI

class MarvelAPIRouteTests: XCTestCase {
    func testGetRouteListCharacters() {
        XCTAssertEqual(MarvelAPIRoute.characters.route, "https://gateway.marvel.com:443/v1/public/characters")
    }

    func testGetRouteFetchSingleCharacter() {
        XCTAssertEqual(MarvelAPIRoute.character(id: 1).route, "https://gateway.marvel.com:443/v1/public/characters/1")
    }
}
