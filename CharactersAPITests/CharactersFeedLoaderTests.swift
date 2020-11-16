//
//  CharactersFeedLoaderTests.swift
//  CharactersAPITests
//
//  Created by Hugo Alonso on 16/11/2020.
//

import XCTest
import CharactersAPI

class CharactersFeedLoaderTests: XCTestCase {

    func testInit_doesNot_requestDataFromURL() {
        let (client, _) = makeSUT()

        XCTAssertNil(client.requestedURL)
    }

    func test_load_allCharactersFromURLWhenNoIdPassed() {
        let (client, sut) = makeSUT()

        sut.load(id: nil) { _ in }

        XCTAssertEqual(client.requestedURL, URL(string: "https://gateway.marvel.com:443/v1/public/characters")!)
    }

    func test_load_singleCharacterFromURLWhenIdPassed() {
        let (client, sut) = makeSUT()

        sut.load(id: 1) { _ in }

        XCTAssertEqual(client.requestedURL, URL(string: "https://gateway.marvel.com:443/v1/public/characters/1")!)
    }

    private func makeSUT() -> (client: HTTPClientSpy, loader: CharacterFeedLoader) {
        let client = HTTPClientSpy()
        let sut = MarvelAPICharacterFeedLoader(client: client)

        return (client: client, loader: sut)
    }
}

class HTTPClientSpy: HTTPClient {
    var requestedURL: URL?

    func get(from url: URL) {
        requestedURL = url
    }
}
