//
//  MarvelCharactersFeedLoaderTests.swift
//  CharactersAPIEndToEndTests
//
//  Created by Hugo Alonso on 19/11/2020.
//

import XCTest
import CharactersAPI

//Integration test to verify end2end system work as expected
class MarvelCharactersFeedLoaderTests: XCTestCase {

    func test_charactersCallWithValidResponse_producesMarvelItems() {
        let sut = makeSUT()

        let expect = expectation(description: "A request for data to the network was issued")
        var receivedResult: Result<[MarvelCharacter], Error>!
        sut.characters(page: 0) {
            receivedResult = $0
            expect.fulfill()
        }
        wait(for: [expect], timeout: 5.0)

        let items = extractResultDataFromCall(result: receivedResult)!
        XCTAssertGreaterThan(items.count, 1, "Items Received")
    }

    func test_searchWithValidResponse_producesMarvelItems() {
        let sut = makeSUT()

        let expect = expectation(description: "A request for data to the network was issued")
        var receivedResult: Result<[MarvelCharacter], Error>!
        sut.search(by: "a", in : 0) {
            receivedResult = $0
            expect.fulfill()
        }
        wait(for: [expect], timeout: 5.0)

        let items = extractResultDataFromCall(result: receivedResult)!
        XCTAssertGreaterThan(items.count, 1, "Items Received")
    }

    func test_singleCharacterWithValidResponse_producesAMarvelItem() {
        let sut = makeSUT()

        let expect = expectation(description: "A request for data to the network was issued")
        var receivedResult: Result<MarvelCharacter?, Error>!
        sut.character(id: 1011334) {
            receivedResult = $0
            expect.fulfill()
        }
        wait(for: [expect], timeout: 5.0)

        let item = extractResultDataFromCall(result: receivedResult)!

        XCTAssertEqual(item?.name, "3-D Man")
    }

    func test_singleCharacterWithUnknownIdAndValidResponse_doesNotProduceAMarvelItem() {
        let sut = makeSUT()

        let expect = expectation(description: "A request for data to the network was issued")
        var receivedResult: Result<MarvelCharacter?, Error>!
        sut.character(id: -1) {
            receivedResult = $0
            expect.fulfill()
        }
        wait(for: [expect], timeout: 5.0)

        switch receivedResult {
        case let .success(item):
            XCTAssertNil(item)
        default:
            XCTFail("This is expected to receive a nil item as a response to a not found id")
        }
    }

    private func extractResultDataFromCall<T>(result: Result<T, Error>, file: StaticString = #filePath, line: UInt = #line) -> T? {
        switch result {
        case let .success(item):
            return item
        default:
            XCTFail("Unexpected state, expected success received \(result)", file: file, line: line)
        }
        return nil
    }

    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> CharacterFeedLoader {
        let client = URLSessionHTTPClient()
        let sut = MarvelCharactersFeedLoader(client: client)

        addTeardownBlock { [weak sut, weak client] in
            XCTAssertNil(sut, "Potential memory leak", file: file, line: line)
            XCTAssertNil(client, "Potential memory leak", file: file, line: line)
        }
        return sut
    }
}
