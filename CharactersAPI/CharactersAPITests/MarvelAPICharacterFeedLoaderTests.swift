//
//  MarvelAPICharacterFeedLoaderTests.swift
//  CharactersAPITests
//
//  Created by Hugo Alonso on 16/11/2020.
//

import XCTest
@testable import CharactersAPI

class MarvelAPICharacterFeedLoaderTests: XCTestCase {
    
    func test_load_allCharactersFromURLWhenNoIdPassed() {
        let (client, sut, time) = makeSUT()
        
        sut.characters(page: 0) { _ in }

        expect(
            requestedURL: client.requestedURL,
            toBeEquivalentTo: "https://gateway.marvel.com:443/v1/public/characters?ts=\(time)&apikey=&hash=&limit=10&offset=0&orderBy=name"
        )
    }

    func test_load_allCharactersForSecondPageFromURLWhenNoIdPassed() {
        let (client, sut, time) = makeSUT()

        sut.characters(page: 1) { _ in }

        expect(
            requestedURL: client.requestedURL,
            toBeEquivalentTo: "https://gateway.marvel.com:443/v1/public/characters?ts=\(time)&apikey=&hash=&limit=10&offset=10&orderBy=name"
        )
    }
    
    func test_load_singleCharacterFromURLWhenIdPassed() {
        let (client, sut, time) = makeSUT()
        
        sut.character(id: 1) { _ in }
        
        expect(
            requestedURL: client.requestedURL,
            toBeEquivalentTo: "https://gateway.marvel.com:443/v1/public/characters/1?ts=\(time)&apikey=&hash=&limit=10&offset=0&orderBy=name"
        )
    }
    
    func test_load_anItemFromJSONResponse() {
        let (client, sut, _) = makeSUT()
        let (response, item, _, _, _, _, _, thumbnail) = makeValidJSONResponse(amountOfItems: 1)
        client.returnedJSON = response

        let expect = expectation(description: "Waiting for expectation")

        sut.character(id: 1) { result in
            switch result {
            case let .success(character):
                XCTAssertEqual(character!.id, item["id"] as? Int)
                XCTAssertEqual(character!.description, item["description"] as? String)
                XCTAssertEqual(character!.modified, item["modified"] as? String)
                XCTAssertEqual(character!.thumbnail?.absoluteString, "\(thumbnail["path"]!.replacingOccurrences(of: "http:", with: "https:")).\(thumbnail["extension"]!)")
            case .failure:
                XCTFail("A valid item is expected as a result to the received response")
            }
            expect.fulfill()
        }
        wait(for: [expect], timeout: 1)
    }

    func test_load_onFailure_FailsWithError() {
        let (client, sut, _) = makeSUT()
        let response = makeValidJSONResponse(amountOfItems: 10).response
        client.returnedJSON = response
        let expectedError = NSError(domain: "anyerror", code: 123, userInfo: nil)
        client.returnedError = expectedError

        let expect = expectation(description: "Waiting for expectation")

        sut.characters(page: 0) { result in
            switch result {
            case .success:
                XCTFail()
            case let .failure(receivedError as NSError):
                XCTAssertEqual(expectedError.domain, receivedError.domain)
                XCTAssertEqual(expectedError.code, receivedError.code)
            }
            expect.fulfill()
        }
        wait(for: [expect], timeout: 1)
    }

    func test_load_severalItemsFromJSONResponse() {
        let (client, sut, _) = makeSUT()
        let response = makeValidJSONResponse(amountOfItems: 10).response
        client.returnedJSON = response

        let expect = expectation(description: "Waiting for expectation")

        sut.characters(page: 0) { result in
            switch result {
            case let .success(characters):
                XCTAssertEqual(characters.count, 10)
            case .failure:
                XCTFail()
            }
            expect.fulfill()
        }
        wait(for: [expect], timeout: 1)
    }

    func test_load_returnsErrorOnWrongStatusCode() {
        let (client, sut, _) = makeSUT()
        let response = makeValidJSONResponse(amountOfItems: 10).response
        client.returnedJSON = response
        client.returnedStatusCode = 404

        let expect = expectation(description: "Waiting for expectation")

        sut.characters(page: 0) { result in
            switch result {
            case .success:
                XCTFail()
            case let .failure(error):
                XCTAssertNotNil(error)
            }
            expect.fulfill()
        }
        wait(for: [expect], timeout: 1)
    }


    private func expect(requestedURL: URL?, toBeEquivalentTo expectedURL: String, file: StaticString = #filePath, line: UInt = #line) {
        let expectedURL = URL(string: expectedURL)

        XCTAssertEqual(requestedURL?.host, expectedURL?.host, file: file, line: line)
        XCTAssertEqual(requestedURL?.relativePath, expectedURL?.relativePath, file: file, line: line)
        XCTAssertEqual(requestedURL?.port, expectedURL?.port, file: file, line: line)
        XCTAssertEqual(requestedURL?.pathComponents, expectedURL?.pathComponents, file: file, line: line)
    }
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (client: HTTPClientSpy, loader: CharacterFeedLoader, time: String) {
        let client = HTTPClientSpy()
        let time = Date()

        func dummyHasher(values: String...) -> String {
            return ""
        }
        
        let sut = MarvelAPICharacterFeedLoader(urlDecorator: MarvelURL(
            URL(string: "https://gateway.marvel.com:443/v1/public/")!,
            config: MarvelAPIConfig(itemsPerPage: 10, privateAPIKey: "", publicAPIKey: ""),
            hashResolver: dummyHasher,
            timeProvider: { time }
        ), client: client)

        addTeardownBlock { [weak sut] in
            XCTAssertNil(sut, "Potential memory leak", file: file, line: line)
        }
        
        return (client: client, loader: sut, time: time.timeIntervalSinceReferenceDate.description)
    }
}
