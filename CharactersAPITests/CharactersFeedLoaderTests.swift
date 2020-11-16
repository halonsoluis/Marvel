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

    func load(completion: @escaping (Result<MarvelCharacter, Error>) -> Void) {
        client.get(from: URL(string: "www.notarealurl.com")!)
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

    func test_load_requestFromURL() {
        let client = HTTPClientSpy()
        let sut = MarvelAPICharacterFeedLoader(client: client)

        sut.load { _ in }

        XCTAssertNotNil(client.requestedURL)
    }
}
