//
//  CharactersFeedLoaderTests.swift
//  CharactersAPITests
//
//  Created by Hugo Alonso on 16/11/2020.
//

import XCTest
@testable import CharactersAPI

class MarvelAPICharacterFeedLoader: CharacterFeedLoader {
    func load(completion: @escaping (Result<MarvelCharacter, Error>) -> Void) {
    }
}

class HTTPClient {
    var requestedURL: URL?
}

class CharactersFeedLoaderTests: XCTestCase {

    func testInit_doesNot_requestDataFromURL() {
        let client = HTTPClient()
        _ = MarvelAPICharacterFeedLoader()

        XCTAssertNil(client.requestedURL)
    }
}
