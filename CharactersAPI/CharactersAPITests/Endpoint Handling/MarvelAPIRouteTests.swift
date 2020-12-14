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
        let sut = RouteComposer.characters
        XCTAssertEqual(sut.url(from: URL(string: "https://gateway.marvel.com:443/v1/public/")!), URL(string: "https://gateway.marvel.com:443/v1/public/characters")!)
    }

    func test_GetRoute_FetchSingleCharacter() {
        let sut = RouteComposer.character(id: 1)
        XCTAssertEqual(sut.url(from: URL(string: "https://gateway.marvel.com:443/v1/public/")!), URL(string: "https://gateway.marvel.com:443/v1/public/characters/1")!)
    }

    func test_GetRoute_ListComicsForCharacter() {
        let sut = RouteComposer.comics(characterId: 1)
        XCTAssertEqual(sut.url(from: URL(string: "https://gateway.marvel.com:443/v1/public/")!), URL(string: "https://gateway.marvel.com:443/v1/public/characters/1/comics")!)
    }

    func test_GetRoute_ListSeriesForCharacter() {
        let sut = RouteComposer.series(characterId: 1)
        XCTAssertEqual(sut.url(from: URL(string: "https://gateway.marvel.com:443/v1/public/")!), URL(string: "https://gateway.marvel.com:443/v1/public/characters/1/series")!)
    }

    func test_GetRoute_ListEventsForCharacter() {
        let sut = RouteComposer.events(characterId: 1)
        XCTAssertEqual(sut.url(from: URL(string: "https://gateway.marvel.com:443/v1/public/")!), URL(string: "https://gateway.marvel.com:443/v1/public/characters/1/events")!)
    }

    func test_GetRoute_ListStoriesForCharacter() {
        let sut = RouteComposer.stories(characterId: 1)
        XCTAssertEqual(sut.url(from: URL(string: "https://gateway.marvel.com:443/v1/public/")!), URL(string: "https://gateway.marvel.com:443/v1/public/characters/1/stories")!)
    }
}
