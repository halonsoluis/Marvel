//
//  MarvelCharactersFeedLoaderTests.swift
//  CharactersAPITests
//
//  Created by Hugo Alonso on 18/11/2020.
//

import XCTest
import CharactersAPI

//Integration test to verify end2end system work as expected
class MarvelCharactersFeedLoaderTests: XCTestCase {

    func test_charactersCall_produces_a_httpRequest() {
        let client = HTTPClientSpy()
        let sut = MarvelCharactersFeedLoader(client: client)

        sut.characters(page: 0, completion: { _ in })

        XCTAssertNotNil(client.requestedURL)
    }

    func test_search_produces_a_httpRequest() {
        let client = HTTPClientSpy()
        let sut = MarvelCharactersFeedLoader(client: client)

        sut.search(by: "", in: 0, completion: { _ in })

        XCTAssertNotNil(client.requestedURL)
    }

    func test_singleCharacter_produces_a_httpRequest() {
        let client = HTTPClientSpy()
        let sut = MarvelCharactersFeedLoader(client: client)

        sut.character(id: 0, completion: { _ in })

        XCTAssertNotNil(client.requestedURL)
    }

}
