//
//  CharactersFeedLoaderTests.swift
//  CharactersAPITests
//
//  Created by Hugo Alonso on 16/11/2020.
//

import XCTest
@testable import CharactersAPI

class MarvelAPICharacterFeedLoader: CharacterFeedLoader {
    let client: HTTPClient

    init(client: HTTPClient) {
        self.client = client
    }

    func load(id: Int? = nil, completion: @escaping (Result<MarvelCharacter, Error>) -> Void) {
        let url = resolveURL(for: id)
        client.get(from: url)
    }

    private func resolveURL(for character: Int?) -> URL {
        guard let id = character else {
            return MarvelAPIRoute.characters.route
        }
        return MarvelAPIRoute.character(id: id).route
    }
}

protocol HTTPClient {
    func get(from url: URL)
}

class HTTPClientSpy: HTTPClient {
    var requestedURL: URL?

    func get(from url: URL) {
        requestedURL = url
    }
}

class CharactersFeedLoaderTests: XCTestCase {

    func testInit_doesNot_requestDataFromURL() {
        let client = HTTPClientSpy()
        _ = MarvelAPICharacterFeedLoader(client: client)

        XCTAssertNil(client.requestedURL)
    }

    func test_load_allCharactersFromURLWhenNoIdPassed() {
        let client = HTTPClientSpy()
        let sut = MarvelAPICharacterFeedLoader(client: client)

        sut.load { _ in }

        XCTAssertEqual(client.requestedURL, URL(string: "https://gateway.marvel.com:443/v1/public/characters")!)
    }

    func test_load_singleCharacterFromURLWhenIdPassed() {
        let client = HTTPClientSpy()
        let sut = MarvelAPICharacterFeedLoader(client: client)

        sut.load(id: 1) { _ in }

        XCTAssertEqual(client.requestedURL, URL(string: "https://gateway.marvel.com:443/v1/public/characters/1")!)
    }
}
