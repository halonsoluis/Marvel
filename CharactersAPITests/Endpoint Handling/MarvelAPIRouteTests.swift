//
//  MarvelAPIRouteTests.swift
//  CharactersAPITests
//
//  Created by Hugo Alonso on 16/11/2020.
//

import XCTest
@testable import CharactersAPI

class MarvelAPIRouteTests: XCTestCase {
    func test_GetRoute_ListCharacters() {
        let sut = RouteComposer.characters(url: URL(string: "https://gateway.marvel.com:443/v1/public/")!)
        XCTAssertEqual(sut.url, URL(string: "https://gateway.marvel.com:443/v1/public/characters")!)
    }

    func test_GetRoute_FetchSingleCharacter() {
        let sut = RouteComposer.character(url: URL(string: "https://gateway.marvel.com:443/v1/public/")!, id: 1)
        XCTAssertEqual(sut.url, URL(string: "https://gateway.marvel.com:443/v1/public/characters/1")!)
    }
}
