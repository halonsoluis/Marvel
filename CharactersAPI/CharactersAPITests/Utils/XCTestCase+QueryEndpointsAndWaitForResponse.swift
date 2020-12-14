//
//  XCTestCase+QueryEndpointsAndWaitForResponse.swift
//  CharactersAPITests
//
//  Created by Hugo Alonso on 20/11/2020.
//

import XCTest
import CharactersAPI

extension XCTestCase {
    func performCharactersRequest(page: Int, using sut: CharacterFeedLoader, timeout: TimeInterval = 1.0) -> Result<[MarvelCharacter], Error> {
        let expect = expectation(description: "A request for data to the network was issued")
        var receivedResult: Result<[MarvelCharacter], Error>!
        sut.characters(page: page) {
            receivedResult = $0
            expect.fulfill()
        }
        wait(for: [expect], timeout: timeout)
        return receivedResult
    }

    func performPublicationRequest(characterId: Int, type: MarvelPublication.Kind, page: Int, using sut: CharacterFeedLoader, timeout: TimeInterval = 1.0) -> Result<[MarvelPublication], Error> {
        let expect = expectation(description: "A request for data to the network was issued")
        var receivedResult: Result<[MarvelPublication], Error>!
        sut.publication(characterId: characterId, type: type, page: page) {
            receivedResult = $0
            expect.fulfill()
        }
        wait(for: [expect], timeout: timeout)
        return receivedResult
    }

    func performSearchRequest(name: String, page: Int, using sut: CharacterFeedLoader, timeout: TimeInterval = 1.0) -> Result<[MarvelCharacter], Error> {
        let expect = expectation(description: "A request for data to the network was issued")
        var receivedResult: Result<[MarvelCharacter], Error>!
        sut.search(by: name, in: page) {
            receivedResult = $0
            expect.fulfill()
        }
        wait(for: [expect], timeout: timeout)
        return receivedResult
    }

    func performCharacterRequest(id: Int = 0, using sut: CharacterFeedLoader, timeout: TimeInterval = 1.0) -> Result<MarvelCharacter?, Error> {
        let expect = expectation(description: "A request for data to the network was issued")
        var receivedResult: Result<MarvelCharacter?, Error>!
        sut.character(id: id) {
            receivedResult = $0
            expect.fulfill()
        }
        wait(for: [expect], timeout: timeout)
        return receivedResult
    }
}
